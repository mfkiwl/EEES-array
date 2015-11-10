#include "Target/TargetFuncRegAllocInfo.hh"
#include "SIR/SIRFunction.hh"
#include "Utils/DbgUtils.hh"

using namespace ES_SIMD;
using namespace std;

TargetFuncRegAllocInfo::~TargetFuncRegAllocInfo() {}

void TargetFuncRegAllocInfo::
InitRegAlloc(int numRegClass) {
  numRegClasses_ = numRegClass;
  regPressure_.resize(numRegClass);
  fill(regPressure_.begin(), regPressure_.end(), 0);
  spillCounter_.resize(numRegClass);
  fill(spillCounter_.begin(), spillCounter_.end(), 0);
  usedPhyRegs_.resize(numRegClass);
  reservedPhyRegs_.resize(numRegClass);
  spills_.resize(numRegClass);
  spillSlotVal_.resize(numRegClass);
  immRegs_.clear();
  promotedImmRegs_.resize(numRegClass);
  for (int i = 0; i < numRegClass; ++i) {
    usedPhyRegs_[i].clear();
    reservedPhyRegs_[i].clear();
    spills_[i].clear();
    spillSlotVal_[i].clear();
    promotedImmRegs_[i].clear();
  }
}// InitRegAlloc

TargetSpillSlot& TargetFuncRegAllocInfo::
GetSpillSlot(int v, unsigned rc) {
  ES_ASSERT_MSG(rc < spills_.size(), "Invalid register class "<< rc);
  if (!IsElementOf(v, spills_[rc])){
    spills_[rc][v].SetValue(v);
    spills_[rc][v].SetIndex(spillCounter_[rc]);
    spillSlotVal_[rc][spillCounter_[rc]++] = v;
  }
  return spills_[rc][v];
}// GetSpillSlot()

int TargetFuncRegAllocInfo::
PromoteImmToReg(int imm, unsigned rc) {
  if (rc > promotedImmRegs_.size()) { return -1; }
  if (IsElementOf(imm,promotedImmRegs_[rc])) {return promotedImmRegs_[rc][imm];}
  int r = promotedImmRegs_[rc][imm] = func_->AllocateValue();
  SetValueRegClass(r, rc);
  immRegs_.insert(r);
  return r;
}// PromoteImmToReg()

int TargetFuncRegAllocInfo::
GetRegImmediate(int ireg) const {
  for (int i=0, e= promotedImmRegs_.size(); i < e; ++i) {
    for (Int2IntMap::const_iterator it = promotedImmRegs_[i].begin(),
           eit = promotedImmRegs_[i].end(); it != eit; ++it) {
      if (it->second == ireg) { return it->first; }
    }
  }
  return 0;
}//GetRegImmediate()
