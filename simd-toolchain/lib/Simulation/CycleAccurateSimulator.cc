#include <sstream>
#include "Utils/StringUtils.hh"
#include "Utils/FileUtils.hh"
#include "Utils/LogUtils.hh"
#include "Simulation/CycleAccurateSimulator.hh"
#include "Simulation/SimObjectBase.hh"
#include "Simulation/SimProcessor.hh"

using namespace std;
using namespace ES_SIMD;

static ImmediateReader immRd;

CycleAccurateSimulator::
CycleAccurateSimulator(
  const std::string& name, unsigned logLv, std::ostream& log,
  unsigned traceLv, std::ostream& err)
  : name_(name), maxCycle_(0), logLevel_(logLv), traceLevel_(traceLv),
    log_(log), err_(err), simTimer_("sim"), simCycle_(0),
    terminated_(0), simFinished_(true) {}

CycleAccurateSimulator::
~CycleAccurateSimulator() {
  for (int i = 0, e=processors_.size(); i < e; ++i) { delete processors_[i]; }
}

void CycleAccurateSimulator::
SetLogLevel(unsigned l)   {
  logLevel_ = l;
  for (unsigned i = 0; i < processors_.size(); ++i) {
    processors_[i]->SetLogLevel(l);
  }// for i =0 to processors_.size()-1
}

void CycleAccurateSimulator::
SetTraceLevel(unsigned l) {
  traceLevel_ = l;
  for (unsigned i = 0; i < processors_.size(); ++i) {
    processors_[i]->SetTraceLevel(l);
  }// for i =0 to processors_.size()-1
}

void CycleAccurateSimulator::
SetBranchTrace(bool t) {
  for (unsigned i = 0; i < processors_.size(); ++i) {
    processors_[i]->SetBranchTrace(t);
  }
}

void CycleAccurateSimulator::
Reset() {
  simCycle_ = 0;
  terminated_ = 0;
  simFinished_ = false;
  for (unsigned i = 0; i < processors_.size(); ++i) {
    processors_[i]->Reset();
  }// for i =0 to processors_.size()-1
}// Reset()

void CycleAccurateSimulator::
Run() {
  if(!SimObjectBase::error_empty()) { return; }
  simTimer_.Start();
  while (terminated_ < processors_.size()) {
    for (unsigned i = 0; i < processors_.size(); ++i) {
      processors_[i]->CycleAction();
      if (!SimObjectBase::error_empty()) {}
      if (processors_[i]->IsTerminated()) {
        ES_LOG_P(logLevel_, log_, processors_[i]->GetName() <<" terminated\n");
        ++terminated_;
      }
    }// for i =0 to processors_.size()-1
    ++simCycle_;
    if (maxCycle_ && (simCycle_ > maxCycle_)) {
      err_<<"Maximum cycle ("<< maxCycle_ <<") reached, terminating...\n";
      err_<<"Something probaly has gone wrong. Check trace file\n";
      break;
    }
  }// while (terminated_ < processors_.size())
  simFinished_ = true;
  simTimer_.Stop();
}// Run()

void CycleAccurateSimulator::
Run(uint64_t c) {
  if(!SimObjectBase::error_empty() || (c <=0)) { return; }
  while (c-- != 0) {
    for (unsigned i = 0; i < processors_.size(); ++i) {
      processors_[i]->CycleAction();
      if (!SimObjectBase::error_empty()) {}
      if (processors_[i]->IsTerminated()) {
        ES_LOG_P(logLevel_, log_, processors_[i]->GetName() <<" terminated\n");
        ++terminated_;
      }
    }// for i =0 to processors_.size()-1
    ++simCycle_;
    if (terminated_ >= processors_.size()) {
      simFinished_ = true;
      break;
    }
    if (maxCycle_ && (simCycle_ > maxCycle_)) {
      err_<<"Maximum cycle ("<< maxCycle_ <<") reached, terminating...\n";
      err_<<"Something probaly has gone wrong. Check trace file\n";
      break;
    }
  }// while (c != 0)
}// Run(c)


void CycleAccurateSimulator::
RunPCTrap(uint64_t c) {
  if(!SimObjectBase::error_empty() || (c <= 0)) { return; }
  while (c-- != 0) {
    bool trapped  = false;
    for (int i = 0, e=processors_.size(); i < e; ++i) {
      processors_[i]->CycleAction();
      if (!SimObjectBase::error_empty()) {}
      if (processors_[i]->IsTerminated()) {
        ES_LOG_P(logLevel_, log_, processors_[i]->GetName() <<" terminated\n");
        ++terminated_;
      }
      trapped |= IsElementOf(processors_[i]->GetProgramCounter(), traps_[i]);
    }// for i =0 to processors_.size()-1
    ++simCycle_;
    if (terminated_ >= processors_.size()) { simFinished_ = true; break; }
    if (trapped) { break; }
    if (maxCycle_ && (simCycle_ > maxCycle_)) {
      err_<<"Maximum cycle ("<< maxCycle_ <<") reached, terminating...\n";
      err_<<"Something probaly has gone wrong. Try to check simulation trace\n";
      break;
    }
  }// while (c != 0)
}// RunPCTrap()

void CycleAccurateSimulator::
InitializeSimulator(uint64_t mc) {
  maxCycle_ = mc;
}// InitializeSimulator()

void CycleAccurateSimulator::
ReleaseResources() {}// ReleaseResources()

void CycleAccurateSimulator::
PrintSimulationInfo(std::ostream& out) {
  if (!SimObjectBase::error_empty()) {
    out << "Simulation terminated due to error!\n";
    SimObjectBase::PrintErrors(out);
  }// if (SimObjectBase::HasError())
  out << simCycle_ <<" cycles simulated, elapsed time "<< simTimer_ <<"\n";
}// PrintSimulationInfo()

void CycleAccurateSimulator::
PrintSimulationStat(std::ostream& out) {
  for (unsigned i = 0; i < processors_.size(); ++i) {
    processors_[i]->PrintSimStatistics(out);
  }// for i =0 to processors_.size()-1
}// PrintSimulationInfo()

bool CycleAccurateSimulator::
AddInstructionInit(const std::string& cmd) {
  size_t p = cmd.find(':');
  if (p == string::npos) {
    err_<<"Invalid instruction initialization command \""<< cmd <<"\"\n";
    return false;
  }
  unsigned i = immRd.GetIntImmediate(cmd.substr(0, p));
  if (immRd.error_ || (i >= processors_.size())) {
    err_<<"Invalid processor id \""<< cmd.substr(0, p) <<"\"\n";
    return false;
  }
  if (processors_[i] == NULL) {
    err_ <<"Processor No."<< i << " is not properly initialized\n";
    return false;
  }
  return processors_[i]->AddInstructionInit(cmd.substr(p+1));
}// AddInstructionInit()

bool CycleAccurateSimulator::
AddDataInit(const std::string& cmd) {
  size_t p = cmd.find(':');
  if (p == string::npos) {
    err_<<"Invalid data initialization command \""<< cmd <<"\"\n";
    return false;
  }
  unsigned i = immRd.GetIntImmediate(cmd.substr(0, p));
  if (immRd.error_ || (i >= processors_.size())) {
    err_<<"Invalid processor id \""<< cmd.substr(0, p) <<"\"\n";
    return false;
  }
  if (processors_[i] == NULL) {
    err_ <<"Processor No."<< i << " is not properly initialized\n";
    return false;
  }
  return processors_[i]->AddDataInit(cmd.substr(p+1));
}// AddDataInit()

bool CycleAccurateSimulator::
AddDataBinary(const std::string& cmd) {
  size_t p = cmd.find(':');
  if (p == string::npos) {
    err_<<"Invalid data binary command \""<< cmd <<"\"\n";
    return false;
  }
  unsigned i = immRd.GetIntImmediate(cmd.substr(0, p));
  if (immRd.error_ || (i >= processors_.size())) {
    err_<<"Invalid processor id \""<< cmd.substr(0, p) <<"\"\n";
    return false;
  }
  if (processors_[i] == NULL) {
    err_ <<"Processor No."<< i << " is not properly initialized\n";
    return false;
  }
  return processors_[i]->AddDataBinary(cmd.substr(p+1));
}// AddInstructionBinary()

void CycleAccurateSimulator::
DumpDataMemory(const std::string& prefix) {
  for (unsigned i = 0; i < processors_.size(); ++i) {
    stringstream ss, vs;
    processors_[i]->DumpScalarDataMemory(ss);
    processors_[i]->DumpVectorDataMemory(vs);
    if (FileStatus::OK != WriteStringToFile(
         ss, prefix + "." + processors_[i]->GetName() + ".scalar.dump")) {
      ES_ERROR_MSG(
        err_, "Failed to dump scalar memory content of \""
        << processors_[i]->GetName() <<"\" to "<<prefix <<"."
        << processors_[i]->GetName() <<".scalar.dump");
    }
    if (FileStatus::OK != WriteStringToFile(
          vs, prefix + "." + processors_[i]->GetName() + ".vector.dump")) {
      ES_ERROR_MSG(
        err_, "Failed to dump vector memory content of \""
        << processors_[i]->GetName() <<"\" to "<<prefix <<"."
        << processors_[i]->GetName() <<".vector.dump");
    }
  }// for i = 0 to processors_.size()-1
}// DumpDataMemory()

uint32_t CycleAccurateSimulator::
GetScalarContextValue(unsigned proc, unsigned addr) const {
  if (proc < processors_.size()) {
    return processors_[proc]->GetScalarContextValue(addr);
  }
  return 0;
}

void CycleAccurateSimulator::
GetVectorContextValue(unsigned proc, unsigned addr, uint32_t* val) const {
  if (proc < processors_.size()) {
    processors_[proc]->GetVectorContextValue(addr, val);
  }
}

uint32_t CycleAccurateSimulator::
GetScalarMemoryValue(unsigned proc, unsigned addr) const {
  if (proc < processors_.size()) {
    return processors_[proc]->GetScalarMemoryValue(addr);
  }
  return 0;
}

void CycleAccurateSimulator::
GetVectorMemoryValue(unsigned proc, unsigned addr, uint32_t* val) const {
  if (proc < processors_.size()) {
    processors_[proc]->GetVectorMemoryValue(addr, val);
  }
}

unsigned CycleAccurateSimulator::
GetVectorLength(unsigned proc) const {
  if (proc < processors_.size()) {
    return processors_[proc]->GetVectorLength();
  }
  return 0;
}// GetVectorLength(unsigned proc)

size_t CycleAccurateSimulator::
GetScalarContextSize(unsigned proc) const {
  if (proc < processors_.size()) {
    return processors_[proc]->GetScalarContextSize();
  }
  return 0;
}// GetScalarContextSize()

size_t CycleAccurateSimulator::
GetVectorContextSize(unsigned proc) const {
  if (proc < processors_.size()) {
    return processors_[proc]->GetVectorContextSize();
  }
  return 0;
}// GetVectorContextSize()

size_t CycleAccurateSimulator::
GetScalarMemorySize(unsigned proc) const {
  if (proc < processors_.size()) {
    return processors_[proc]->GetScalarMemorySize();
  }
  return 0;
}// GetScalarMemorySize()

size_t CycleAccurateSimulator::
GetVectorMemorySize(unsigned proc) const {
  if (proc < processors_.size()) {
    return processors_[proc]->GetVectorMemorySize();
  }
  return 0;
}// GetVectorMemorySize()

uint32_t CycleAccurateSimulator::
GetProgramCounter(unsigned proc) const {
  return (proc < processors_.size()) ?
    processors_[proc]->GetProgramCounter() : 0;
}

void CycleAccurateSimulator::
AddSimProcessor(SimProcessorBase* p) {
  processors_.push_back(p);
  traps_.resize(processors_.size());
}

void CycleAccurateSimulator::
PrintScalarOperation(unsigned proc, unsigned addr, std::ostream& o) const {
  if (proc < processors_.size()) {
    processors_[proc]->PrintScalarOperation(addr, o);
  }
}

void CycleAccurateSimulator::
PrintVectorOperation(unsigned proc, unsigned addr, std::ostream& o) const {
  if (proc < processors_.size()) {
    processors_[proc]->PrintVectorOperation(addr, o);
  }
}
size_t CycleAccurateSimulator::
GetTraceSize() const { return GetStringStreamSize(traceSS_); }

size_t CycleAccurateSimulator::
ReadOutTrace(char *buff, size_t buff_size) const {
  traceSS_.read(buff, buff_size);
  streamsize gc = traceSS_.gcount();
  traceSS_.str("");
  traceSS_.clear();
  return gc;
}
