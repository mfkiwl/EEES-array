#include <iostream>
#include <sstream>
#include <llvm/Support/CommandLine.h>

#include "Target/TargetBasicInfo.hh"
#include "Target/TargetBinaryProgram.hh"
#include "Simulation/CycleAccurateSimulator.hh"
#include "Simulation/SimProcessor.hh"
#include "Utils/CmdUtils.hh"
#include "Utils/FileUtils.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace llvm;
using namespace ES_SIMD;

enum DebugLev {
  nodebuginfo=0, quick=2, info, detailed
};

enum TraceLev {
  notrace, brief, pipeline, full, branch
};

/// Generic options
cl::opt<DebugLev> debugLevel(
  "debug-level", cl::desc("Set the debugging level (default=none)"),
  cl::values(clEnumValN(nodebuginfo, "none", "disable debug information"),
             clEnumVal(quick, "enable quick debug information"),
             clEnumVal(info,  "enable comprehensive debug information"),
             clEnumVal(detailed, "enable most detailed debug information"),
             clEnumValEnd), cl::init(nodebuginfo));
cl::opt<bool> quiet ("quiet", cl::desc("Suppress any terminal output"));
cl::opt<bool> verboseMode("verbose", cl::desc("Run in verbose mode"));
cl::alias verboseA("V", cl::desc("Alias for -verbose"),
                   cl::aliasopt(verboseMode));


/// s-sim specific options
cl::opt<string> maxCycle(
  "max-cycle", cl::desc("Maximum number of cycles"));
cl::list<string> iMemFilenames(
  "imem", cl::desc("Specify instruction memory initialization file"),
  cl::value_desc("option:filename"), cl::CommaSeparated);
cl::list<string> dMemFilenames(
  "dmem", cl::desc("Specify data memory initialization file"),
  cl::value_desc("option:filename"), cl::CommaSeparated);
cl::list<string> dBinFilenames(
  "dbin", cl::desc("Specify binary file for data memory"),
  cl::value_desc("option:address:filename"), cl::CommaSeparated);
cl::opt<string> archString("arch", cl::desc("Specify target architecture name"),
                           cl::value_desc("target"), cl::init("baseline"));
cl::opt<string> archFilename("arch-cfg", cl::value_desc("target"),
                             cl::desc("Specify target architecture"
                                      "configuration filename"),
                             cl::ValueRequired);
cl::list<std::string> archParams("arch-param", cl::CommaSeparated,
                                 cl::desc("Target parameter string"));
// Output options
cl::opt<TraceLev> traceLevel(
  "trace-level", cl::desc("Set simulation trace level (default=none)"),
  cl::values(clEnumValN(notrace, "none", "disable trace generation"),
             clEnumVal(brief, "generate minimum level of trace"),
             clEnumVal(pipeline,  "generate trace of pipeline events"),
             clEnumVal(full, "generate most detailed trace"),
             clEnumVal(branch, "generate taken branch trace"),
             clEnumValEnd), cl::init(notrace));
cl::opt<bool> printStat("print-stat", cl::desc("Print simulation statistics"));
cl::opt<bool> dumpDMem("dump-dmem", cl::desc("Dump content of data memory"));
cl::opt<std::string> dumpDMemPrefix(
  "dump-dmem-prefix", cl::desc("Prefix of data memory dump files"),
  cl::init("dmem"));

void PrintVersion() {
  PrintToolVersion(cout, "s-sim", "ES SIMD Simulator");
}

int
main(int argc, char **argv) {
  cl::SetVersionPrinter(PrintVersion);
  cl::ParseCommandLineOptions(
    argc, argv, "ES SIMD simulator\n\n"
    "  This program simulates binary program\n");
  int err = 0;
  bool verbose = !quiet && (verboseMode || (debugLevel > nodebuginfo));
  if (iMemFilenames.empty()) {
    cerr<< argv[0]<<": no instruction init file \n";
    return -1;
  }
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

  tgt->InitSimulationInfo();
  int logLv = static_cast<int>(debugLevel);
  if (verbose && (logLv <=0)) {
    logLv = 1;
  }
  int traceLv = traceLevel;
  if (traceLevel == branch) { traceLv = 0; }
  CycleAccurateSimulator sim(archString, logLv, cout, traceLv, cerr);
  stringstream& trace = sim.GetTraceStream();
  sim.AddSimProcessor(SimProcessorFactory::GetSimProcessor(
                        tgt->GetName(), tgt.get(), logLv, cout,
                        traceLv, trace, cerr));
  ImmediateReader immRd;
  uint64_t mc = maxCycle.empty() ? 0 : immRd.GetUInt64Immediate(maxCycle);
  if (immRd.error_) {
    ES_ERROR_MSG(cerr, "Invalid max-cycle value \""<< maxCycle <<"\"\n");
    return -1;
  }
  sim.InitializeSimulator(mc);
  for (unsigned i = 0; i < iMemFilenames.size(); ++i) {
    if (!sim.AddInstructionInit(iMemFilenames[i])) {
      ES_ERROR_MSG(cerr, "Instruction initialization command \""
                   << iMemFilenames[i] <<"\" failed!\n");
      return -1;
    }
  }// for i = 0 to iMemFilenames.size()-1
  for (unsigned i = 0; i < dMemFilenames.size(); ++i) {
    if (!sim.AddDataInit(dMemFilenames[i])) {
      ES_ERROR_MSG(cerr, "Data initialization command \""
                   << dMemFilenames[i] <<"\" failed!\n");
      return -1;
    }
  }// for i = 0 to dMemFilenames.size()-1
  for (unsigned i = 0; i < dBinFilenames.size(); ++i) {
    if (!sim.AddDataBinary(dBinFilenames[i])) {
      ES_ERROR_MSG(cerr, "Data binary command \""
                   << dBinFilenames[i] <<"\" failed!\n");
      return -1;
    }
  }// for i = 0 to iBinFilenames.size()-1
  ES_LOG_P(verbose, cout, "Reseting...\n");
  if (traceLevel == branch) { sim.SetBranchTrace(true); }
  sim.Reset();
  ES_LOG_P(verbose, cout, "Running simulation...\n");
  sim.Run();
  if (verbose) {
    cout <<"Finished.\n";
    sim.PrintSimulationInfo(cout);
  }// if (verbose)
  if (printStat) {
    cout <<">> BEGIN Simulation statistics\n";
    sim.PrintSimulationStat(cout);
    cout <<">> END Simulation statistics\n";
  }
  if (sim.error_empty()) {
    if (dumpDMem) {
      sim.DumpDataMemory(dumpDMemPrefix);
    }// if (dumpDMem)
  } else {
    cerr << sim.error_size() <<" simulation error(s) occured\n";
    err = sim.error_size();
    sim.PrintSimulationErrors(cerr);
  }// if (!sim.error_empty())
  sim.ReleaseResources();
  trace.seekg(0, ios::end);
  size_t tsize = trace.tellg();
  trace.seekg(0, ios::beg);
  if (tsize > 0) {
    ES_LOG_P(verbose, cout, "Writing trace to sim-trace.txt...\n");
    WriteStringToFile(trace, "sim-trace.txt");
  }
  return err;
}// main()
