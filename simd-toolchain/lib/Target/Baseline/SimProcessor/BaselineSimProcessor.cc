#include <algorithm>
#include <sstream>
#include "Simulation/SimProgramSection.hh"
#include "Simulation/SimScalarCore.hh"
#include "Simulation/SimVectorCore.hh"
#include "BaselineInstruction.hh"
#include "BaselineInstructionPacket.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineSimProcessor.hh"
#include "Utils/FileUtils.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

RegisterSimProcessor<BaselineSimProcessor> BaselineSimProcessor::reg_("baseline");
static ImmediateReader immRd;

class BaselineCommBoundaryConfig : public SimScalarMMapObject {
  /// Context
  const uint64_t& refTimer_;
  CommBoundaryMode_t mode_;
  CommBoundaryMode_t *headMode_;
  CommBoundaryMode_t *tailMode_;
public:
  BaselineCommBoundaryConfig(
    SimCoreBase* pe, const uint64_t& refTimer, unsigned logLv, ostream& log,
    unsigned traceLv, ostream& trace, ostream& err);
  virtual ~BaselineCommBoundaryConfig() {}
  virtual uint32_t Read(unsigned  addr)  const {
    return static_cast<uint32_t>(mode_);
  }
  virtual void Write(uint32_t dat, unsigned addr) {
    if (dat >= CommBoundaryMode::CommBoundaryModeEnd) {
      Error(refTimer_, SimErrorCode::InvalidMemAddr,
            "Invalid address of mem-mapped object "+Int2DecString(addr));
    }// if (dat >= CommBoundaryMode::CommBoundaryModeEnd)
    mode_ = static_cast<CommBoundaryMode_t>(dat);
    ES_LOG_P(traceLevel_,trace_,"  >>MM-OBJ: "<< GetName() <<"="<<mode_<<'\n');
    if (headMode_) { *headMode_ = mode_; }
    if (tailMode_) { *tailMode_ = mode_; }
  }
  virtual void Reset() {
    mode_ = CommBoundaryMode::Zero;
    if (headMode_) { *headMode_ = mode_; }
    if (tailMode_) { *tailMode_ = mode_; }
  }
};// class BaselineCommBoundaryConfig

BaselineCommBoundaryConfig::
BaselineCommBoundaryConfig (
  SimCoreBase* pe, const uint64_t& refTimer, unsigned logLv, ostream& log,
  unsigned traceLv, ostream& trace, ostream& err)
  : SimScalarMMapObject("CommBoundary", logLv, log, traceLv, trace, err),
    refTimer_(refTimer), mode_(CommBoundaryMode::Zero),
    headMode_(NULL), tailMode_(NULL) {
  switch (pe->GetDataWidth()){
  case 32:{
    SimVectorCore<uint32_t, int32_t>* pe32
      = static_cast<SimVectorCore<uint32_t, int32_t>*>(pe);
    headMode_ = &pe32->HeadBoundaryModeRef();
    tailMode_ = &pe32->TailBoundaryModeRef();
    break;
  }
  case 16: {
    SimVectorCore<uint16_t, int16_t>* pe16
      = static_cast<SimVectorCore<uint16_t, int16_t>*>(pe);
    headMode_ = &pe16->HeadBoundaryModeRef();
    tailMode_ = &pe16->TailBoundaryModeRef();
    break;
  }
  }
}// BaselineCommBoundaryConfig()

BaselineSimProcessor::
BaselineSimProcessor(
  const TargetBasicInfo* t, unsigned logLv, std::ostream& log,
  unsigned traceLv, std::ostream& trace, std::ostream& err)
  : SimProcessorBase(t->GetName(), logLv, log, traceLv, trace, err),
    tgtInfo_(*dynamic_cast<const BaselineBasicInfo*>(t)),
    cp_(NULL), peArray_(NULL), cpDataMemory_(NULL) {
  const BaselineBasicInfo& tgt = tgtInfo_;
  unsigned cpFlags = tgt.CPHasPredicates() ? tgt.GetCPNumPredicates() : 1;
  unsigned peFlags = tgt.PEHasPredicates() ? tgt.GetPENumPredicates() : 1;
  switch (tgtInfo_.GetCPDataWidth()){
  case 32:{
    ES_LOG_P(logLv > 0, log, "Initializing 32-bit CP");
    ES_LOG_P((logLv >0) && tgt.IsCPExplicitBypass(), log, ", explicit bypass");
    ES_LOG_P(logLv > 0, log, ", RF="<< tgt.GetCPRFSize() <<", stage="
             << tgt.GetCPNumStages() <<"\n");
    SimScalarCore<uint32_t, int32_t>* cp32
      = new SimScalarCore<uint32_t, int32_t>(
        "CP", GetSimCycleRef(), cpFlags, tgt.GetNumberOfCPReg(),
        tgt.GetCPRFSize(), logLv, log, traceLv, trace, err);
    SimScalarSRAM<uint32_t>* cpDMem32 = new SimScalarSRAM<uint32_t>(
      "CP-DMem", GetSimCycleRef(), tgt.GetCPDMemDepth(),
      1, logLv, log, traceLv, trace, err);
    cp_ = cp32;
    cpDataMemory_ = cpDMem32;
    cp32->ConnectDataMemory(cpDMem32);
    cp32->SetImmHighOffset(tgtInfo_.GetCPImmHighOffset());
    cp32->SetImmHighOffsetJType(tgtInfo_.GetCPImmHighOffsetJType());
    break;
  }
  case 16: {
  ES_LOG_P(logLv > 0, log, "Initializing 16-bit CP\n");
    SimScalarCore<uint16_t, int16_t>* cp16
      = new SimScalarCore<uint16_t, int16_t>(
        "CP", GetSimCycleRef(), cpFlags, tgt.GetNumberOfCPReg(),
        tgt.GetCPRFSize(), logLv, log, traceLv, trace, err);
    SimScalarSRAM<uint16_t>* cpDMem16 = new SimScalarSRAM<uint16_t>(
      "CP-DMem", GetSimCycleRef(), tgt.GetCPDMemDepth(),
      1, logLv, log, traceLv, trace, err);
    cp_ = cp16;
    cpDataMemory_ = cpDMem16;
    cp16->ConnectDataMemory(cpDMem16);
    cp16->SetImmHighOffset(tgtInfo_.GetCPImmHighOffset());
    cp16->SetImmHighOffsetJType(tgtInfo_.GetCPImmHighOffsetJType());
    break;
  }
  default: {
    stringstream ss;
    ss <<"\""<< tgtInfo_.GetCPDataWidth()
       << "\" is not a valid data width for CP";
    Error(0, SimErrorCode::InvalidConfig, ss.str());
    break;
  }};
  cp_->SetNumberOfFU(3);
  cp_->SetExeMaxStages(tgtInfo_.GetCPNumStages() - 3);
  cp_->SetMemoryStage((tgtInfo_.GetCPNumStages() == 4) ? 0 : 1);
  if(tgtInfo_.IsCPExplicitBypass()) {
    cp_->SetExplicitBypass(true);
    cp_->SetCommitPipeReg(tgtInfo_.GetCPCommitRegID());
    cp_->SetFUOutQueueContextMap(0, tgtInfo_.GetCPFUOutQueue(0)); // ALU
    cp_->SetFUOutQueueContextMap(1, tgtInfo_.GetCPFUOutQueue(1)); // MUL
    cp_->SetFUOutQueueContextMap(2, tgtInfo_.GetCPFUOutQueue(2)); // LSU
  }
  subObjects_.insert(cp_);
  subObjects_.insert(cpDataMemory_);
  cp_->SetMemMapObjectMask(0xFFFF0000);
  if (tgtInfo_.GetNumPE() <= 0) { return; }
  switch (tgtInfo_.GetPEDataWidth()){
  case 32:{ ES_LOG_P(logLv > 0, log, "Initializing 32-bit PE array of size "
                     << tgtInfo_.GetNumPE() <<"\n");
      SimVectorCore<uint32_t, int32_t>* pe32
        = new SimVectorCore<uint32_t, int32_t>(
        "PE", GetSimCycleRef(), tgtInfo_.GetNumPE(), peFlags,
        tgtInfo_.GetNumberOfPEReg(), tgt.GetPERFSize(),
        logLv, log, traceLv, trace, err);
      SimVectorSRAM<uint32_t>* peDMem32 = new SimVectorSRAM<uint32_t>(
        "PE-DMem", GetSimCycleRef(), tgt.GetNumPE(), tgt.GetPEDMemDepth(),
        1, logLv, log, traceLv, trace, err);
      pe32->ConnectDataMemory(peDMem32);
      pe32->SetImmHighOffset(tgtInfo_.GetPEImmHighOffset());
      peArray_ = pe32;
      peDataMemory_ = peDMem32;
      break;
  }
  case 16: { ES_LOG_P(logLv > 0, log, "Initializing 16-bit PE array of size "
                      << tgtInfo_.GetNumPE() <<"\n");
      SimVectorCore<uint16_t, int16_t>* pe16
        = new SimVectorCore<uint16_t, int16_t>(
        "PE", GetSimCycleRef(), tgtInfo_.GetNumPE(), peFlags,
        tgtInfo_.GetNumberOfPEReg(), tgt.GetPERFSize(),
        logLv, log, traceLv, trace, err);
      SimVectorSRAM<uint16_t>* peDMem16 = new SimVectorSRAM<uint16_t>(
        "PE-DMem", GetSimCycleRef(), tgt.GetNumPE(), tgt.GetPEDMemDepth(),
        1, logLv, log, traceLv, trace, err);
      pe16->ConnectDataMemory(peDMem16);
      pe16->SetImmHighOffset(tgtInfo_.GetPEImmHighOffset());
      peArray_ = pe16;
      peDataMemory_ = peDMem16;
      break;
  }
  default: {
    stringstream ss;
    ss <<"\""<< tgtInfo_.GetNumPE()
       << "\" is not a valid data width for PE";
    Error(0, SimErrorCode::InvalidConfig, ss.str());
    break;
  }};
  peArray_->SetNumberOfFU(3);
  peArray_->SetExeMaxStages(tgtInfo_.GetPENumStages() - 3);
  peArray_->SetMemoryStage((tgtInfo_.GetPENumStages() == 4) ? 0 : 1);
  if(tgtInfo_.IsPEExplicitBypass()) {
    peArray_->SetExplicitBypass(true);
    peArray_->SetCommitPipeReg(tgtInfo_.GetPECommitRegID());
    peArray_->SetFUOutQueueContextMap(0, tgtInfo_.GetPEFUOutQueue(0)); // ALU
    peArray_->SetFUOutQueueContextMap(1, tgtInfo_.GetPEFUOutQueue(1)); // MUL
    peArray_->SetFUOutQueueContextMap(2, tgtInfo_.GetPEFUOutQueue(2)); // LSU
  }
  if (cp_->GetDataWidth() == 32) {
    static_cast<SimScalarCore<uint32_t, int32_t>*>(cp_)
      ->ConnectPEArray(peArray_);
  } else if (cp_->GetDataWidth() == 16) {
    static_cast<SimScalarCore<uint16_t, int16_t>*>(cp_)
      ->ConnectPEArray(peArray_);
  }
  if (peArray_->GetDataWidth() == 32) {
    static_cast<SimVectorCore<uint32_t, int32_t>*>(peArray_)
      ->ConnectControlProcessor(cp_);
  } else if (peArray_->GetDataWidth() == 16) {
    static_cast<SimVectorCore<uint16_t, int16_t>*>(peArray_)
      ->ConnectControlProcessor(cp_);
  }
  subObjects_.insert(peArray_);
  subObjects_.insert(peDataMemory_);
  BaselineCommBoundaryConfig* commBoundaryCfg
    = new BaselineCommBoundaryConfig(
      peArray_, GetSimCycleRef(), logLv, log, traceLv, trace, err);
  cp_->AddMMapScalarObject(0xFFFFFFFF, commBoundaryCfg);
}// BaselineSimProcessor()

BaselineSimProcessor::~BaselineSimProcessor() {}

void BaselineSimProcessor::SetBranchTrace(bool t) {
  if (cp_) { cp_->SetBranchTrace(t); }
}

void BaselineSimProcessor::InitProcessor() {}

void BaselineSimProcessor::
Reset() {
  if (cp_ == NULL) {
    Error(0, SimErrorCode::InvalidInitialization,
          "CP not initialized before reset");
  } else {// if (cp == NULL)
    cp_->Reset();
  }// if (cp == NULL)
  if (peArray_ == NULL) {
    Error(0, SimErrorCode::InvalidInitialization,
          "PE array not initialized before reset");
  } else {// if (peArray_ == NULL)
    peArray_->Reset();
  }// if (peArray_ == NULL)
  SimProcessorBase::Reset();
  if (cpCode_.empty()) {
    Terminate();
  } else {
    // Prefill instruction buffer after reset
    cp_->FillInstrBuffer(&cpCode_[0]);
    peArray_->FillInstrBuffer(&peCode_[0]);
  }
  for (int i=0, e=cpCode_.size(); i < e; ++i) { cpCode_[i].Reset(); }
  for (int i=0, e=peCode_.size(); i < e; ++i) { peCode_[i].Reset(); }
}// Reset()

void BaselineSimProcessor::
CycleAction() {
  ES_LOG_P(traceLevel_, trace_, "=["<< GetName() <<"] >>"<< GetSimulationCycle()
           <<"<< CP-PC="<< cp_->GetProgramCounter() <<"\n");

  cp_->CycleInit();   /**/ peArray_->CycleInit();
  cp_->Commit();      /**/ peArray_->Commit();
  cp_->Execute();     /**/ peArray_->Execute();
  cp_->Decode();      /**/ peArray_->Decode();
  cp_->Synchronize(); /**/ peArray_->Synchronize();
  cp_->Fetch();       /**/ peArray_->Fetch();
  cp_->CycleFinal();  /**/ peArray_->CycleFinal();

  // Instruction memory actions
  //   CP and PE array runs in lockstep
  if (cp_->FetchWaiting()) {// && peArray_->FetchWaiting()) {
    unsigned cpc = cp_->GetProgramCounter();
    if (cpc < cpCode_.size()) {
      cp_->FillInstrBuffer(&cpCode_[cpc]);
      peArray_->FillInstrBuffer(&peCode_[cpc]);
    } else {
      stringstream ss;
      ss << "Instruction address 0x"<< hex << cpc << " out of range\n";
      Error(GetSimulationCycle(), SimErrorCode::InvalidInstrAddr, ss.str());
    }
  }// if ((cp_->FetchWaiting()) && (cp_->FetchWaiting()))

  // Data memory actions
  IncSimCycle();
  if (cp_->IsTerminated() || (GetSimulationCycle() > GetMaxSimulationCycle())
      || !SimObjectBase::error_empty()) {
    Terminate();
  }
}// CycleAction()

bool BaselineSimProcessor::
AddInstructionInit(const std::string& cmd) {
  size_t p = cmd.find(':');
  if (p == string::npos) {
    err_<<"Invalid instruction initialization command \""<< cmd <<"\" for "
        << GetName() <<"\n";
    return false;
  }
  bool succ = false;
  if (cmd.substr(0, p) == "cp") {
    succ = InitInstructionMemory(false, cmd.substr(p+1));
  } else if (cmd.substr(0, p) == "pe") {
    succ = InitInstructionMemory(true, cmd.substr(p+1));
  } else if (cmd.substr(0, p) == "uni") {
    succ = InitInstructionMemory(false, cmd.substr(p+1)+".cp.imem_init")
      && InitInstructionMemory(true, cmd.substr(p+1)+".pe.imem_init");
  }else {
    err_ <<"Unknown instruction init command: \""<< cmd <<"\"";
    string m = "Unknown instruction init command: \"\"";
    m.insert(35, cmd);
    Error(0, SimErrorCode::InvalidInitialization, m);
    return false;
  }
  if (succ) {
    if (cpCode_.size() < peCode_.size()) { cpCode_.resize(peCode_.size()); }
    if (peCode_.size() < cpCode_.size()) { peCode_.resize(cpCode_.size()); }
  }
  return succ;
}// AddInstructionInit()

bool BaselineSimProcessor::
AddDataInit(const std::string& cmd) {
  size_t p = cmd.find(':');
  if (p == string::npos) {
    err_<<"Invalid data initialization command \""<< cmd <<"\" for "
        << GetName() <<"\n";
    return false;
  }
  if (cmd.substr(0, p) == "cp") {
    return InitDataMemory(false, cmd.substr(p+1));
  } else if (cmd.substr(0, p) == "pe") {
    return InitDataMemory(true, cmd.substr(p+1));
  } else {
    string m = "Unknown data init command: \"\"";
    m.insert(28, cmd);
    Error(0, SimErrorCode::InvalidInitialization, m);
    return false;
  }
  return true;
}// AddDataInit()

bool BaselineSimProcessor::
AddDataBinary(const std::string& cmd) {
  vector<string> cmds;
  TokenizeString(cmds, cmd, ":");
  if (cmds.size() != 3) {
    err_<<"Invalid data binary command \""<< cmd <<"\" for "
        << GetName() <<"\n";
    return false;
  }
  vector<char> data;
  if (ReadBinaryFile(data, cmds[2]) != FileStatus::OK) {
    err_<<"Cannot open "<< cmds[2]<<'\n';
    return false;
  }
  int start = immRd.GetIntImmediate(cmds[1]);
  if (immRd.error_ || ((cmds[0] != "cp") && (cmds[0] != "pe"))) {
    err_<<"Invalid data binary command \""<< cmd <<"\" for "
        << GetName() <<"\n";
    return false;
  }
  SimSRAMBase* mem =  (cmds[0] == "pe") ? peDataMemory_ : cpDataMemory_;
  if (mem == NULL) {
    Error(0, SimErrorCode::InvalidInitialization,
          cmds[0] + "data memory not initialized");
    return false;
  }
  ES_LOG_P(logLevel_, log_, "Initializing "<< data.size()<<" bytes in "
           << cmds[0] <<" data memory @"<< start <<" using "<< cmds[2] <<".\n");
  if ((start + data.size()) > mem->GetByteSize()) {
    err_<<"Data binary out of range in command \""<< cmd <<"\" (start="<< start
        <<", num_bytes="<< data.size()<<", mem_size="<< mem->GetByteSize()<<")\n";
    return false;
  }
  for (int i = 0, e = data.size(), a = start; i < e; ++i) {
    mem->InitByte(a++, data[i]);
  }
  return true;
}// AddDataBinary()

bool BaselineSimProcessor::
InitInstructionMemory(bool isPE, const std::string& iFilename) {
  static BaselineInstructionPacket dummyPacket(tgtInfo_);
  vector<string> fileBuff;
  list<MemDataSection> iMemData;
  if (ReadFileLines(fileBuff, "#", iFilename) != FileStatus::OK) {
    stringstream ss;
    ss << "Could not open file "<< iFilename;
    Error(0, SimErrorCode::InvalidInitialization, ss.str());
    return false;
  }
  ES_LOG_P(logLevel_, log_, "Initializing "<<(isPE ? "PE":"CP")
           <<" instruction memory using " << iFilename <<"...\n");
  ReadVerilogMemHex(fileBuff, tgtInfo_.GetPEInstrWidth(), iMemData);
  SimProgramSection& code = isPE ? peCode_ : cpCode_;
  for (list<MemDataSection>::iterator it = iMemData.begin();
       it != iMemData.end(); ++it) {
    MemDataSection& dat = *it;
    ES_LOG_P(logLevel_, log_, (isPE?"[V] ":"[S] ")<< dat.size()
             <<" words starting at "<< dat.start_ <<"\n");
    unsigned sz = dat.start_ + dat.size();
    if (code.size() < sz) { code.resize(sz); }
    for (unsigned i = 0; i < dat.size(); ++i) {
      BaselineInstruction instr(dummyPacket, isPE);
      if (!tgtInfo_.DecodeInstruction(&instr, dat[i])) {
        err_<<"Failed to decode "<<(isPE?"PE":"CP")<<" instruction "<< i <<"\n";
        return false;
      }
      SimOperation& op = code[dat.start_ + i];
      op.SetAddress(dat.start_ + i);
      if (instr.GetOpcode() == TargetOpcode::NOP)
        continue;
      // Check if the target supports the opcode
      if ((isPE && !tgtInfo_.IsValidPEOpc(instr.GetOpcode()))
          || (!isPE && !tgtInfo_.IsValidCPOpc(instr.GetOpcode()))) {
        stringstream ss;
        ss << "Invalid target opcode \""<< instr.GetOpcode() <<"\"";
        Error(0, SimErrorCode::InvalidInstruction, ss.str());
      }
      op.SetOpcode(instr.GetOpcode())
        .SetExeLatency(isPE ? tgtInfo_.GetPEOperationLatency(instr.GetOpcode())
                       : tgtInfo_.GetCPOperationLatency(instr.GetOpcode()))
        .SetBinding(isPE ? tgtInfo_.GetPEOperationBinding(instr.GetOpcode())
                    : tgtInfo_.GetCPOperationBinding(instr.GetOpcode()));
      if (IsTargetCompare(instr.GetOpcode()) && (instr.GetNumDstOperands()==0)){
        op.AppendDstOperand(SimOperandType::Flag, 0);
      }
      for (unsigned j = 0; j < instr.pred_size(); ++j) {
        op.AppendPredicate(instr.GetPredicate(j).GetValue());
      }
      for (unsigned j = 0; j < instr.GetNumDstOperands(); ++j) {
        const TargetOperand& dst = instr.GetDstOperand(j);
        int d = dst.GetValue();
        SimOperandType_t t = SimOperandType::ContextValue;
        switch (dst.GetType()) {
        case TargetOperandType::Register:  break;
        case TargetOperandType::Bypass:    break;
        case TargetOperandType::Predicate: t = SimOperandType::Flag; break;
        default: return false;
        }
        op.AppendDstOperand(t, d);
      }// for j = 0 to instr.GetNumDstOperands()-1
      if (OpUsesFlag(instr.GetOpcode())) {
        op.AppendSrcOperand(SimOperandType::Flag, 0);
      }
      for (unsigned j = 0; j < instr.GetNumSrcOperands(); ++j) {
        const TargetOperand& src = instr.GetSrcOperand(j);
        int s = src.GetValue();
        SimOperandType_t t = SimOperandType::ContextValue;
        switch (src.GetType()) {
        case TargetOperandType::Bypass: break;
        case TargetOperandType::Communication:
          t = SimOperandType::Communication;
          break;
        case TargetOperandType::IntImmediate:
          t = SimOperandType::IntImmediate;
          break;
        case TargetOperandType::Predicate:
          ES_UNREACHABLE("Cannot directly use predicate as source");
        default: break;
        }
        op.AppendSrcOperand(t, s);
      }// for j = 0 to instr.GetNumSrcOperands()-1
    }// for i = 0 to dat.size()-1
  }// for iMemData iterator it
  return true;
}// InitInstructionMemory()

bool BaselineSimProcessor::
InitDataMemory(bool isPE, const std::string& iFilename) {
  static BaselineInstructionPacket dummyPacket(tgtInfo_);
  vector<string> fileBuff;
  list<MemDataSection> dMemData;
  if (ReadFileLines(fileBuff, "#", iFilename) != FileStatus::OK) {
    stringstream ss;
    ss << "Could not open file "<< iFilename;
    Error(0, SimErrorCode::InvalidInitialization, ss.str());
    return false;
  }
  SimSRAMBase* mem = isPE ? peDataMemory_ : cpDataMemory_;
  if (mem == NULL) {
    Error(0, SimErrorCode::InvalidInitialization,
          string(isPE ? "PE":"CP") + "data memory not initialized");
    return false;
  }
  ES_LOG_P(logLevel_, log_, "Initializing "<<(isPE ? "PE":"CP")
           <<" data memory using " << iFilename <<"...\n");
  ReadVerilogMemHex(
    fileBuff,isPE?tgtInfo_.GetPEDataWidth():tgtInfo_.GetCPDataWidth(),dMemData);
  for (list<MemDataSection>::iterator it = dMemData.begin();
       it != dMemData.end(); ++it) {
    MemDataSection& dat = *it;
    ES_LOG_P(logLevel_, log_, (isPE?"[V] ":"[S] ")<< dat.size()
             <<" words starting at "<< dat.start_ <<"\n");
    for (unsigned i = 0; i < dat.size(); ++i) {
      mem->InitWord(dat.start_+i, dat[i][0]);
    }
  }
  return true;
}// InitDataMemory()

void BaselineSimProcessor::
DumpScalarDataMemory(std::ostream& o) const {
  UInt32Vector dump;
  dump.reserve(cpDataMemory_->GetDepth());
  if (cp_->GetDataWidth() == 32) {
    const std::vector<uint32_t>& data
      = dynamic_cast<SimScalarSRAM<uint32_t>*>(cpDataMemory_)->Data();
    for (unsigned i = 0; i < data.size(); ++i) {
      dump.push_back(data[i]);
    }
  } else if (cp_->GetDataWidth() == 16) {
    const std::vector<uint16_t>& data
      = dynamic_cast<SimScalarSRAM<uint16_t>*>(cpDataMemory_)->Data();
    for (unsigned i = 0; i < data.size(); ++i) {
      dump.push_back(data[i]);
    }
  } else {
    return;
  }
  WriteVerilogMemHex(o, dump, cp_->GetDataWidth(), 0);
}// DumpScalarDataMemory()

void BaselineSimProcessor::
DumpVectorDataMemory(std::ostream& o) const {
  UInt32Vector dump;
  dump.reserve(peDataMemory_->GetDepth() * tgtInfo_.GetNumPE());
  if (peArray_->GetDataWidth() == 32) {
    const std::vector<uint32_t>& data
      = dynamic_cast<SimVectorSRAM<uint32_t>*>(peDataMemory_)->Data();
    for (unsigned i = 0; i < data.size(); ++i) {
      dump.push_back(data[i]);
    }
  } else if (peArray_->GetDataWidth() == 16) {
    const std::vector<uint16_t>& data
      = dynamic_cast<SimVectorSRAM<uint16_t>*>(peDataMemory_)->Data();
    for (unsigned i = 0; i < data.size(); ++i) {
      dump.push_back(data[i]);
    }
  } else {
    return;
  }
  WriteVerilogMemHex(o, dump, peArray_->GetDataWidth(), 0);
}// DumpVectorDataMemory()

uint32_t BaselineSimProcessor::
GetProgramCounter() const { return cp_->GetProgramCounter(); }

uint32_t BaselineSimProcessor::
GetScalarContextValue(unsigned addr) const {
  if (addr >= cp_->GetIntContextSize()) { return 0; }
  if (cp_->GetDataWidth() == 32) {
    return (dynamic_cast<const SimScalarCore<uint32_t, int32_t>*>(cp_)
            ->GetCurrentContextValue(addr));
  } else if (cp_->GetDataWidth() == 16) {
    return (dynamic_cast<SimScalarCore<uint16_t, int16_t>*>(cp_)
            ->GetCurrentContextValue(addr));
  }
  return 0;
}// GetScalarContextValue()

void BaselineSimProcessor::
GetVectorContextValue(unsigned addr, uint32_t* val) const {
  if (!peArray_ || (addr >= peArray_ ->GetIntContextSize())) { return; }
  if (peArray_->GetDataWidth() == 32) {
    const SimVectorCore<uint32_t, int32_t>* c
      = dynamic_cast<const SimVectorCore<uint32_t, int32_t>*>(peArray_);
    const uint32_t* data =  c->GetCurrentContextPtr(addr);
    for (unsigned i = 0; i < c->GetVectorLength(); ++i) {val[i]=data[i];}
  } else if (peArray_->GetDataWidth() == 16) {
    const SimVectorCore<uint16_t, int16_t>* c
      = dynamic_cast<const SimVectorCore<uint16_t, int16_t>*>(peArray_);
    const uint16_t* data = c->GetCurrentContextPtr(addr);
    for (unsigned i = 0; i < c->GetVectorLength(); ++i) {val[i]=data[i];}
  }
}// GetVectorContextValue()

uint32_t BaselineSimProcessor::
GetScalarMemoryValue(unsigned addr) const {
  if (addr >= cpDataMemory_->GetDepth()) { return 0; }
  if (cp_->GetDataWidth() == 32) {
    return (dynamic_cast<const SimScalarSRAM<uint32_t>*>(cpDataMemory_)
            ->Data()[addr]);
  } else if (cp_->GetDataWidth() == 16) {
    return (dynamic_cast<const SimScalarSRAM<uint16_t>*>(cpDataMemory_)
            ->Data()[addr]);
  }
  return 0;
}// GetScalarMemoryValue()

void BaselineSimProcessor::
GetVectorMemoryValue(unsigned addr, uint32_t* val) const {
  if (!peDataMemory_ || (addr >= peDataMemory_->GetDepth())) { return; }
  unsigned vl = GetVectorLength();
  if (peArray_->GetDataWidth() == 32) {
    const uint32_t* data
      = &dynamic_cast<SimVectorSRAM<uint32_t>*>(peDataMemory_)
      ->Data()[addr*vl];
    for (unsigned i = 0; i < vl; ++i) { val[i] = data[i]; }
  } else if (peArray_->GetDataWidth() == 16) {
    const uint16_t* data
      = &dynamic_cast<SimVectorSRAM<uint16_t>*>(peDataMemory_)
      ->Data()[addr*vl];
    for (unsigned i = 0; i < vl; ++i) { val[i] = data[i]; }
  }
}// GetVectorMemoryValue()

size_t BaselineSimProcessor::GetScalarContextSize() const {
  return cp_ ? cp_->GetIntContextSize(): 0;
}

size_t BaselineSimProcessor::GetVectorContextSize() const {
  return peArray_ ? peArray_->GetIntContextSize() : 0;
}

size_t BaselineSimProcessor::GetScalarMemorySize() const  {
  return cpDataMemory_ ? cpDataMemory_->GetDepth() : 0;
}
size_t BaselineSimProcessor::GetVectorMemorySize() const  {
  return peDataMemory_? peDataMemory_->GetDepth() : 0;
}

unsigned BaselineSimProcessor::
GetVectorLength() const {
  if (!peArray_) { return 0; }
  if (peArray_->GetDataWidth() == 32) {
    return dynamic_cast<const SimVectorCore<uint32_t, int32_t>*>(peArray_)
      ->GetVectorLength();
  } else if (peArray_->GetDataWidth() == 16) {
    return dynamic_cast<const SimVectorCore<uint16_t, int16_t>*>(peArray_)
      ->GetVectorLength();
  }
  return 0;
}// GetVectorLength()

char GetContextChar(int id, bool v, bool upper, const BaselineBasicInfo& tgt) {
  if (!id) { return upper ? 'N':'n'; }
  bool rf = v ? tgt.IsPEPhyRegister(id) : tgt.IsCPPhyRegister(id);
  if (rf) { return upper?'R':'r'; }
  return upper ? 'W':'w';
}// GetContextChar()

static ostream&
PrintOperationProp(bool vect, const SimOperation& op,
                   const BaselineBasicInfo& tgt, ostream& o) {
  if (op.IsNOP()) { return o; }
  o << (vect?"v.":"s.");
  bool isLoad = false, isStore = false;
  for (int i=0, e=op.GetNumOpcode(); i < e; ++i) {
    if (i) { o <<"-"; }
    o << op.GetOpcode(i);
    if (IsTargetLoad(op.GetOpcode(i)))  { isLoad  = true; }
    if (IsTargetStore(op.GetOpcode(i))) { isStore = true; }
  }
  if (int np = op.GetNumPredicates()) { o <<"|p"<< np; }
  for (int i=0, e=op.GetNumDstOperands(); i < e; ++i) {
    const SimOperand& dOp = op.GetDstOperand(i);
    int idx = dOp.GetID();
    o <<'|';
    switch(dOp.GetType()) {
    case SimOperandType::ContextValue:
      o << GetContextChar(idx, vect, true, tgt);
      break;
    case SimOperandType::Flag: o <<'F'; break;
    default: break;
    }
  }
  for (int i=0, e=op.GetNumSrcOperands(); i < e; ++i) {
    const SimOperand& sOp = op.GetSrcOperand(i);
    int idx = sOp.GetID();
    o <<'|';
    switch(sOp.GetType()) {
    case SimOperandType::ContextValue:
      o << GetContextChar(idx, vect, false, tgt);
      break;
    case SimOperandType::Flag:          o <<'f'; break;
    case SimOperandType::IntImmediate:  o <<'i'; break;
    case SimOperandType::Communication: o <<'c'; break;
    default: break;
    }
  }
  if (isLoad)  { o <<"|m"; }
  if (isStore) { o <<"|M"; }
  return o;
}// PrintOperationProp()

void BaselineSimProcessor::
PrintSimStatistics(std::ostream& o) const {
  o <<">> BEGIN "<< GetName() <<" statistics\n\n";
  if (cp_) {
    o <<">> BEGIN code frequency\n";
    for (int i=0, e=cpCode_.size(), ps = peCode_.size(); i < e; ++i) {
      const SimOperation& cOp = cpCode_[i];
      if (unsigned c = cOp.GetExeCount()){
        o << cOp.GetAddress() <<':'<<c;
        if ((i < ps) && peCode_[i].GetPredCount()) {
          o <<':'<< peCode_[i].GetPredCount();
        }
        if (!cOp.IsNOP()) { 
          o <<':'; 
          PrintOperationProp(false, cOp, tgtInfo_, o);
        }// if (!cOp.IsNOP())
        if (i < ps) {
          const SimOperation& pOp = peCode_[i];
          if (!pOp.IsNOP()) {
            o <<':';
            PrintOperationProp(true, pOp, tgtInfo_,o);
          }// if (!pOp.IsNOP())
        }//if ((i < ps) && peCode_[i].GetPredCount()) 
        o <<'\n';
      }// if (unsigned c = cOp.GetExeCount())
    }// for i = 0 to cpCode_.size()-1
    o <<">> END code frequency\n\n";
    o <<">> BEGIN CP statistics\n";
    cp_->PrintSimStatistics(o);
    o <<">> END CP statistics\n\n";
  }// if (cp_)
  if (peArray_) {
    o <<">> BEGIN PE statistics\n";
    o <<">> END PE statistics\n\n";
  }// if (peArray_)
  o <<">> END "<< GetName() <<" statistics\n";
}// PrintSimStatistics()

void BaselineSimProcessor::
PrintScalarOperation(unsigned addr, std::ostream& o) const {
  if (addr < cpCode_.size()) {
    if (cpCode_[addr].IsNOP()) { o <<"NOP";          }
    else                       { o << cpCode_[addr]; }
  } else { o << "--";         }
}

void BaselineSimProcessor::
PrintVectorOperation(unsigned addr, std::ostream& o) const {
  if (addr < peCode_.size()) {
    if (peCode_[addr].IsNOP()) { o <<"NOP";          }
    else                       { o << peCode_[addr]; }
  } else { o << "--";         }
}
