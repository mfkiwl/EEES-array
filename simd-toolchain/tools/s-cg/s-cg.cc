#include <iostream>
#include <sstream>
#include <fstream>
#include <llvm/Support/CommandLine.h>

#include "Program/ProcessingDriver.hh"
#include "Target/TargetBasicInfo.hh"
#include "Utils/CmdUtils.hh"
#include "Utils/FileUtils.hh"
#include "Utils/StringUtils.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace llvm;
using namespace ES_SIMD;

enum DebugLev {
  nodebuginfo=0, quick=2, info, detailed
};

/// Generic options
cl::opt<DebugLev> parserDebugLevel(
  "parser-info-level", cl::desc("Set the IR parser info level (default=none)"),
  cl::values(clEnumValN(nodebuginfo, "none", "disable debug information"),
             clEnumVal(quick, "enable quick debug information"),
             clEnumVal(info,  "enable comprehensive debug information"),
             clEnumVal(detailed, "enable most detailed debug information"),
             clEnumValEnd), cl::init(nodebuginfo));
cl::opt<bool> quiet ("quiet", cl::desc("Suppress any non-error output"));
cl::opt<bool> verboseMode("verbose", cl::desc("Run in verbose mode"));
cl::alias verboseA("V", cl::desc("Alias for -verbose"),
                   cl::aliasopt(verboseMode));


/// s-cg specific options
cl::opt<string> outputFilename(
  "o", cl::desc("Specify output filename (prefix if there are multiple files)"),
  cl::value_desc("filename"), cl::init("out.s")) ;
cl::list<string> inputFiles(cl::Positional, cl::desc("<input files>"));
cl::opt<string> archString("arch", cl::desc("Specify target architecture name"),
                           cl::value_desc("target"), cl::init("baseline"));
cl::opt<string> archCfgFile(
  "arch-cfg", cl::desc("Specify a target configuration file"),
  cl::value_desc("filename"));
cl::list<std::string> archParams("arch-param", cl::CommaSeparated,
                                 cl::desc("Target parameter string"));
cl::list<std::string> initASM("init-asm", cl::CommaSeparated,
                              cl::desc("Init assembly files"));
cl::list<std::string>  dumpDDG("ddg", cl::CommaSeparated,
                               cl::desc("Dump block DDG (func:block_id)"));
cl::list<std::string>  dumpDDGTrees(
  "ddg-tree", cl::CommaSeparated,
  cl::desc("Dump block DDG sub-trees(func:block_id)"));
cl::opt<bool> printCFG("cfg", cl::desc("Output control flow graph"));
cl::opt<bool> noSymTab("nosymtab", cl::desc("Do not output symbol table"));
cl::opt<bool> outputJSON("json", cl::desc("Emit program info in JSON format"));
cl::opt<bool> styledJSON("json-styled",
                         cl::desc("Produce JSON in a more readable style"));
cl::opt<bool> parseOnly("parse-only", cl::desc("Only parse IR"));
cl::opt<bool> bareMode("bare", cl::desc("Run in bare mode"));
cl::opt<bool> noSched(
  "no-sched", cl::desc("Follow the IR instruction order as much as possible"));
cl::opt<bool> printPassName(
  "print-pass-name",
  cl::desc("Print the names of the passes executed"));
cl::opt<bool> printFuncInfo(
  "print-func-info",
  cl::desc("Print function information after IR finalization"));
cl::list<std::string> logPasses("log-pass", cl::CommaSeparated,
                                cl::desc("log specified passes"));
cl::opt<bool> printParsing("print-parsing",
                           cl::desc("Print parsing result to stdout"));
cl::opt<bool> printGenerate(
  "print-generate",
  cl::desc("Print code generation result to stdout"));
cl::opt<bool> printCGStat(
  "print-codegen-stat",
  cl::desc("Print code generation statistics"));
cl::list<string> codeGenDbg("cg-dbg", cl::CommaSeparated,
                            cl::desc("Code generator debug option"));
cl::opt<bool> debugMode("debug", cl::desc("Run with full debug output"));

void PrintVersion() { PrintToolVersion(cout,"s-cg","ES SIMD code generator"); }

int
main(int argc, char **argv) {
  cl::SetVersionPrinter(PrintVersion);
  cl::ParseCommandLineOptions(
    argc, argv, "ES SIMD Code Generator\n\n"
    "  This program translates Solver IR to target assembly\n");
  bool verbose = !quiet && verboseMode;
  if (inputFiles.empty()) {
    cerr<< argv[0]<<": no input file \n";
    return -1;
  }
  int logLv = 0;
  if (debugMode) { logLv = 10; }
  if (quiet) { logLv = 0; }
  ProcessingDriver drv("Solver Code Generator", logLv, cout, cerr);
  drv.SetPrintPassName(printPassName);
  drv.SetPrintFunctionInfo(printFuncInfo);
  if (!archCfgFile.empty()) {
    Json::Value archCfg;
    ES_LOG_P(verbose, cout, "Configuring target with "<< archCfgFile <<'\n');
    if (ReadJSONFile(archCfgFile, archCfg) != FileStatus::OK) { return -1; }
    if (!archString.empty() && (archCfg["arch"].asString() != archString)) {
      ES_WARNING_MSG(cerr, "Architecture name \""<< archString <<"\" does not"
                     <<" match name in configuration file (\""
                     << archCfg["arch"].asString()<<"\")\n");
    }
    drv.InitializeCodeGenerator(archCfg);
  } else {// if (!archCfgFile.empty())
    ES_LOG_P(verbose, cout, "Initializating target: "<< archString <<'\n');
    drv.InitializeCodeGenerator(archString);
  }// // if (!archCfgFile.empty())
  if (!drv.PrintErrors(cerr)) { return -1; }
  drv.SetCodeGeneratorBareMode(bareMode);
  drv.SetNoSchedule(noSched);
  for (unsigned i = 0; i < codeGenDbg.size(); ++i) {
    ToLowerCase(codeGenDbg[i]);
    if (!drv.SetCodeGenDbg(codeGenDbg[i]) && !quiet) {
      ES_WARNING_MSG(cerr, "Unknown CodeGenerator debug option \""
                     << codeGenDbg[i] <<"\"\n");
    } else if (codeGenDbg[i] == "none"){ break; }
  }

  for (unsigned i = 0; i < archParams.size(); ++i) {
    size_t sep = archParams[i].find(":");
    string k, v;
    if (sep != string::npos) {
      k = archParams[i].substr(0, sep);
      v = archParams[i].substr(sep+1, archParams[i].length()-sep-1);
    } else { k = archParams[i]; }
    if (!drv.SetTargetParam(k, v) && !quiet) {
      ES_WARNING_MSG(cerr, "Failed to set target parameter: "
                     << archParams[i] <<"\n");
    }
  }// for i = 0 to archParams.size()
  drv.InitTargetCodeGenPipeline();
  for (unsigned i = 0; i < logPasses.size(); ++i) {
    drv.SetPassLogLevel(logPasses[i], 10);
  }
  drv.SetIRParserLogLevel(parserDebugLevel);
  for (unsigned i = 0; i < inputFiles.size(); ++i) {
    ES_LOG_P(verbose, cout, "Adding IR source: "<< inputFiles[i] <<'\n');
    drv.AddSIRSource(inputFiles[i]);
    if (!drv.PrintErrors(cerr)) { return -1; }
  }
  ES_LOG_P(verbose, cout, "All IR files parsed.\n");
  if (printParsing) { drv.PrettyPrintSIRParsing(cout); }

  if (parseOnly) { return 0; }
  ES_LOG_P(verbose, cout, "Generating target code...\n");
  drv.GenerateTargetCode();
  if (printGenerate) { drv.PrettyPrintTargetCode(cout); }
  if (!drv.PrintErrors(cerr)) return -1;

  if (outputJSON) {
    Json::Value progInfo;
    drv.DumpModule(progInfo);
    if (!styledJSON) {
      Json::FastWriter wrt;
      wrt.enableYAMLCompatibility();
      WriteStringToFile(wrt.write(progInfo), outputFilename+".json");
    } else {
      Json::StyledWriter wrt;
      WriteStringToFile(wrt.write(progInfo), outputFilename+".json");
    }
    //return 0;
  }
  stringstream outss;

  vector<string> lns;
  if (printCGStat) { drv.PrintCodeGenStat(cout); }
  for (unsigned i = 0; i < initASM.size(); ++i) {
    lns.clear();
    if (FileStatus::OK != ReadFileLines(lns, "#", initASM[i]) ) {
      ES_ERROR_MSG(cerr, "Failed to open "<<initASM[i]<<"\n");
      return -1;
    }
    for (unsigned i = 0; i < lns.size(); ++i) { outss << lns[i] <<'\n'; }
  }
  ES_LOG_P(verbose, cout, "Emitting target ASM...\n");
  drv.EmitTargetASM(outss);
  if (!drv.PrintErrors(cerr)) { return -1; }
  else { WriteStringToFile(outss, outputFilename); }
  if (printCFG) {
    stringstream css;
    drv.PrintCFG(css);
    WriteStringToFile(css, outputFilename+".cfg");
  }
  static ImmediateReader immRd;
  for (int i=0, e=dumpDDG.size(); i < e; ++i) {
    size_t sep = dumpDDG[i].find(":");
    string f, v;
    if (sep != string::npos) {
      f = dumpDDG[i].substr(0, sep);
      v = dumpDDG[i].substr(sep+1, dumpDDG[i].length()-sep-1);
    } else { ES_WARNING_MSG(cerr, "Unknown DDG: "<< dumpDDG[i] <<"\n"); }
    int bid = immRd.GetIntImmediate(v);
    if (immRd.error_) {
      ES_WARNING_MSG(cerr, "Unknown DDG: "<< dumpDDG[i] <<"\n");
    } else {
      stringstream css;
      drv.DrawDDG(f, bid, css);
      WriteStringToFile(css, f +".B"+ v +".ddg.dot");
    }
    // drv.SetDumpBlockDDG(f, v);
  }// for i = 0 to dumpDDG.size()-1
  for (int i=0, e=dumpDDGTrees.size(); i < e; ++i) {
    size_t sep = dumpDDGTrees[i].find(":");
    string f, v;
    if (sep != string::npos) {
      f = dumpDDGTrees[i].substr(0, sep);
      v = dumpDDGTrees[i].substr(sep+1, dumpDDGTrees[i].length()-sep-1);
    } else { ES_WARNING_MSG(cerr, "Unknown DDG: "<< dumpDDGTrees[i] <<"\n"); }
    int bid = immRd.GetIntImmediate(v);
    if (immRd.error_) {
      ES_WARNING_MSG(cerr, "Unknown DDG: "<< dumpDDGTrees[i] <<"\n");
    } else {
      stringstream css;
      drv.DrawDDGSubTrees(f, bid, css);
      WriteStringToFile(css, f +".B"+ v +".ddg.tree.dot");
    }
    // drv.SetDumpBlockDDG(f, v);
  }// for i = 0 to dumpDDG.size()-1
  if (!noSymTab) {
    stringstream css;
    drv.PrintSymbolTable(css);
    WriteStringToFile(css, outputFilename+".stab");
  }
}// main()
