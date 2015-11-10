#include <iostream>
#include <sstream>
#include <llvm/Support/CommandLine.h>

#include "Target/TargetBasicInfo.hh"
#include "Target/TargetBinaryProgram.hh"
#include "Target/TargetASMParser.hh"
#include "Utils/CmdUtils.hh"
#include "Utils/FileUtils.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace llvm;
using namespace ES_SIMD;

enum DebugLev {
  nodebuginfo=0, quick=2, info, detailed
};

enum OutFormat {
  assembly, verilog, binary
};

/// Generic options
cl::opt<DebugLev> debugLevel(
  "parser-info-level", cl::desc("Set the parser info level (default=none)"),
  cl::values(clEnumValN(nodebuginfo, "none", "disable debug information"),
             clEnumVal(quick, "enable quick debug information"),
             clEnumVal(info,  "enable comprehensive debug information"),
             clEnumVal(detailed, "enable most detailed debug information"),
             clEnumValEnd), cl::init(nodebuginfo));
cl::opt<bool> quiet ("quiet", cl::desc("Suppress any terminal output"));
cl::opt<bool> verboseMode("verbose", cl::desc("Run in verbose mode"));
cl::alias verboseA("V", cl::desc("Alias for -verbose"),
                   cl::aliasopt(verboseMode));


/// s-as specific options
cl::opt<OutFormat> outputFormat(
  "out-format", cl::desc("Set the output file format (default=verilog)"),
  cl::values(clEnumVal(verilog, "file compatible with $readmemh in Verilog"),
             clEnumValN(assembly, "asm", "assembly"),
             clEnumVal(binary,           "binary"),
             clEnumValEnd), cl::init(verilog));

cl::opt<string> outputFilename(
  "o", cl::desc("Specify output filename (prefix if there are multiple files)"),
  cl::value_desc("filename"), cl::init("a.out"));
cl::opt<string> inputFilename(cl::Positional, cl::desc("<input file>"));
cl::opt<string> archString("arch", cl::desc("Specify target architecture name"),
                           cl::value_desc("target"), cl::init("baseline"));
cl::opt<string> archFilename("arch-cfg", cl::value_desc("target"),
                             cl::desc("Specify target architecture"
                                      "configuration filename"),
                             cl::ValueRequired);
cl::list<std::string> archParams("arch-param", cl::CommaSeparated,
                                 cl::desc("Target parameter string"));
cl::opt<bool> printParsing("print-parsing",
                           cl::desc("Print parsing result to stdout"));

void PrintVersion() {
  PrintToolVersion(cout, "s-as", "ES SIMD assembler");
}

int
main(int argc, char **argv) {
  cl::SetVersionPrinter(PrintVersion);
  cl::ParseCommandLineOptions(
    argc, argv, "ES SIMD Assembler\n\n"
    "  This program translates assembly to binary\n");
  bool verbose = !quiet && (verboseMode || (debugLevel > nodebuginfo));
  if (inputFilename.empty()) {
    cerr<< argv[0]<<": no input file \n";
    return -1;
  }
  ES_LOG_P(verbose, cout, "Input file: "<< inputFilename <<"\n"
           <<"Output file: "<< outputFilename <<"\n");
  // Initialize target information
  auto_ptr<ES_SIMD::TargetBasicInfo> tgt;
  if (!archFilename.empty()) {
    ES_LOG_P(verbose, cout, "Using target configuration in "
             << archFilename <<"\n");
    Json::Value archCfg;
    if (ReadJSONFile(archFilename, archCfg) != FileStatus::OK) { return -1; }
    tgt.reset(TargetBasicInfoFactory::GetTargetBasicInfo(archCfg));
  } else {
    ES_LOG_P(verbose, cout, "Target arch: "<< archString <<"\n");
    tgt.reset(TargetBasicInfoFactory::GetTargetBasicInfo(archString));
  }// if (archFilename.empty())
  if ((tgt.get() == NULL) || !tgt->ValidateTarget()) {
    ES_ERROR_MSG_T(cerr, "Internal", "Target initialization failed!\n");
    return -1;
  }
  for (unsigned i = 0; i < archParams.size(); ++i) {
    size_t sep = archParams[i].find(":");
    string k, v;
    if (sep != string::npos) {
      k = archParams[i].substr(0, sep);
      v = archParams[i].substr(sep+1, archParams[i].length()-sep-1);
    } else {
      k = archParams[i];
    }
    if (!tgt->SetTargetParam(k, v) && !quiet) {
      ES_WARNING_MSG(cerr, "Failed to set target parameter: "
                     << archParams[i] <<"\n");
    }
  }// for i = 0 to archParams.size()

  tgt->InitCodeGenInfo();
  int logLv = static_cast<int>(debugLevel);
  if (verbose && (logLv <=0)) {
    logLv = 1;
  }
  auto_ptr<TargetASMParser> tgtParser(
    TargetASMParserFactory::GetTargetASMParser(tgt.get(),logLv,cout,cerr));
  if (tgtParser.get() == NULL) {
    ES_ERROR_MSG_T(
      cerr, "Internal", "Assembly parser initialization failed!\n");
    return -1;
  }
  auto_ptr<TargetBinaryProgram> tgtProg(
    tgt->CreateBinaryProgram(0, inputFilename));
  if (tgtProg.get() == NULL) {
    ES_ERROR_MSG_T(
      cerr, "Internal", "Binary program initialization failed!\n");
    return -1;
  }
  tgtParser->SetTargetProgram(tgtProg.get());
  ES_LOG_P(verbose, cout, "Target assembly parser initialized\n");
  tgtParser->ReadASMFile(inputFilename);
  ES_LOG_P(verbose, cout, "Running assembly parser...\n");
  tgtParser->Run();
  if (tgtParser->TerminatedByError()) {
    ES_ERROR_MSG(cerr, "Encounter error(s) while parsing assembly file "
                 << inputFilename <<"\n");
    return -1;
  }

  ES_LOG_P(debugLevel>=quick, cout, ">> Preparing binary information...\n");
  tgtProg->PrepBinary();

  if (printParsing) {
    tgtProg->Print(cout);
  }

  switch (outputFormat) {
  case assembly: {
    stringstream ss;
    tgtProg->PrintASM(ss);
    if (outputFilename == "-") {
      ES_LOG_P(verbose, cout, "Writing ASM output:\n");
      cout << ss.str();
    } else {
      ES_LOG_P(verbose, cout, "Writing ASM output to "<< outputFilename <<"\n");
      WriteStringToFile(ss, outputFilename);
    }
    break;
  }
  case verilog: {
    ES_LOG_P(verbose, cout, "Writing Verilog memory init output...\n");
    FileStatus_t fs = tgtProg->SaveVerilogMemHex(outputFilename);
    if (fs != FileStatus::OK) {
      ES_ERROR_MSG(cerr, "Failed to save Verilog hex file(s): "<< fs <<"\n");
      return -1;
    }
    break;
  }
  case binary:
    ES_LOG_P(verbose, cout, "Writing binary output\n");
    ES_NOTSUPPORTED("Binary output not implemented");
    break;
  default:
    ES_ERROR_MSG(cerr, "Unknown output format\n");
    break;
  }
}// main()
