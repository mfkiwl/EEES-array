#include "BaselineBlockData.hh"
#include "BaselineFuncData.hh"
#include "BaselineBasicInfo.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "Target/TargetFuncRegAllocInfo.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

BaselineFuncData::
BaselineFuncData(SIRFunction* func, const BaselineBasicInfo& target)
  : TargetFuncData(func), target_(target),
    cpStackOffset_(func->IsSolverKernel()? 0 : func->GetSIRStackOffset()),
    peStackOffset_(func->IsSolverKernel()?func->GetSIRStackOffset() : 0) {}

BaselineFuncData::~BaselineFuncData() {}

unsigned BaselineFuncData::
GetLoadLatency(bool vect) const {
  return vect ? target_.GetPEOperationLatency(TargetOpcode::LW)
    : target_.GetCPOperationLatency(TargetOpcode::LW);
}

int BaselineFuncData::
GetCodeSize() const {
  int s = 0;
  for (SIRFunction::iterator it = func_->begin(); it != func_->end(); ++it) {
    s += (*it)->GetTargetData()->GetTargetSize();
  }
  return s;
}

unsigned BaselineFuncData::GetCPStackOffset() const {
  const unsigned slotSize = (target_.GetCPDataWidth() == 32) ? 4 : 2;
  return GetRegAllocInfo()->GetNumStackSpills(BaselineBasicInfo::CP) * slotSize
    + cpStackOffset_;
}

unsigned BaselineFuncData::GetPEStackOffset() const {
  const unsigned slotSize = (target_.GetPEDataWidth() == 32) ? 4 : 2;
  return GetRegAllocInfo()->GetNumStackSpills(BaselineBasicInfo::PE)*slotSize
    + peStackOffset_;
}

unsigned BaselineFuncData::GetCPSpillSlotOffset(unsigned idx) const {
  const bool d32 = (target_.GetCPDataWidth() == 32);
  const unsigned slotSize = d32 ? 4 : 2;
  unsigned addr = cpStackOffset_ + idx*slotSize;
  return addr >> (d32?2:1);
}

unsigned BaselineFuncData::GetPESpillSlotOffset(unsigned idx) const {
  const bool d32 = (target_.GetPEDataWidth() == 32);
  const unsigned slotSize = (target_.GetPEDataWidth() == 32) ? 4 : 2;
  unsigned addr = peStackOffset_ + idx*slotSize;
  return addr >> (d32?2:1);
}

void BaselineFuncData::
InitRegAlloc() {
  delete regAllocInfo_;
  regAllocInfo_ = new TargetFuncRegAllocInfo(func_);
  /// There are four different types of registers:
  /// CP RF, PE RF, CP Predicates, PE Predicates
  regAllocInfo_->InitRegAlloc(4);
}// InitRegAlloc()

void BaselineFuncData::
UpdateRegPressure() {
  size_t& cpPressure
    = GetRegAllocInfo()->GetRegPressureRef(BaselineBasicInfo::CP);
  size_t& pePressure
    = GetRegAllocInfo()->GetRegPressureRef(BaselineBasicInfo::PE);
  cpPressure = pePressure = 0;
  for (SIRFunction::iterator bIt = func_->begin(); bIt != func_->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    BaselineBlockData& bData
      = *dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
    bData.InitIssueTime();
    bData.CalculateRegPressure(regAllocInfo_->ValueRegClassMap(),
                               regAllocInfo_->SpilledValues(), target_);
    cpPressure = max(cpPressure, bData.CPRegPressure());
    pePressure = max(pePressure, bData.PERegPressure());
  }// for func_ iterator bIt
}// UpdateRegPressure()

bool BaselineFuncData::
ClobbersPhyReg(int r, int rc) const {
  if (r == 0) { return false; }                // ZERO
  if ((rc == 1) && (r == 1)) { return false; } // PEID
  if (GetRegAllocInfo()->ClobbersPhyReg(r, rc)) { return true; }
  // Check callees
  for (SIRFunction::callee_const_iterator it = func_->callee_begin();
       it != func_->callee_end(); ++it) {
    // If there is unknown callee, make conservative assumption that it clobbers
    // everything.
    if (!(*it) || !SIRFunction::classof(*it)) { return true; }
    TargetFuncData* cData = static_cast<SIRFunction*>(*it)->GetTargetData();
    ES_ASSERT_MSG(cData, "No target data for function "
                  <<static_cast<SIRFunction*>(*it)->GetName());
    if (cData->ClobbersPhyReg(r, rc)) { return true; }
  }
  return false;
}// ClobbersPhyReg()

void BaselineFuncData::
Print(std::ostream& o) const {
  o <<"        .global        "<< func_->GetName() <<"\n";
  o <<"        .type          "<< func_->GetName() <<",@function\n";
  o <<"        .ent           "<< func_->GetName() <<"\n";
  o << func_->GetName() <<": ";
  for (SIRFunction::const_iterator bIt = func_->begin();
       bIt != func_->end(); ++bIt) {
    const SIRBasicBlock* bb = *bIt;
    if ((bb != func_->GetEntryBlock()) && bb->HasName()) {
      o << bb->GetName() <<": ";
    }
    o <<"# BB_"<< bb->GetBasicBlockID() <<":";
    if (bb->GetLoop()) { o <<"    l="<< bb->GetLoopDepth(); }
    if (bb->IsExitBlock()) { o <<"        .exit";}
    if (bb == func_->GetEntryBlock()) { o <<"    .entry";}
    o <<"\n";
    bb->GetTargetData()->Print(o);
  }// for func_ iterator bIt
  o <<"        .end           "<< func_->GetName() <<"\n";
}// Print()

void BaselineFuncData::
ValuePrint(std::ostream& o) const {
  o << func_->GetName() <<": ";
  for (SIRFunction::const_iterator bIt = func_->begin();
       bIt != func_->end(); ++bIt) {
    const SIRBasicBlock* bb = *bIt;
    if ((bb != func_->GetEntryBlock()) && bb->HasName()) {
      o << bb->GetName() <<": ";
    }
    o <<"# BB_"<< bb->GetBasicBlockID() <<":";
    if (bb->GetLoop()) { o <<"    l="<< bb->GetLoopDepth(); }
    if (bb->IsExitBlock()) { o <<"    .exit";}
    if (bb == func_->GetEntryBlock()) { o <<"    .entry";}
    o <<"\n";
    bb->GetTargetData()->ValuePrint(o);
  }// for func_ iterator bIt
  o <<"        .end           "<< func_->GetName() <<"\n";
}// ValuePrint()

void BaselineFuncData::
PrintCodeGenStat(std::ostream& o) const {
  // Calculate statistics from blocks
  int totalInstr = 0;
  for (SIRFunction::const_iterator bIt = func_->begin();
       bIt != func_->end(); ++bIt) {
    BaselineBlockData* bd
      = dynamic_cast<BaselineBlockData*>((*bIt)->GetTargetData());
    totalInstr += bd->size();
  }
  o <<"issue_packet:"<< totalInstr <<"\n";
}// PrintStat()
