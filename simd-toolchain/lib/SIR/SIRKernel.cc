#include "SIR/SIRKernel.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRFunction.hh"

using namespace std;
using namespace ES_SIMD;

SIRKernel::SIRKernel(SIRFunction* func)
  : SIRValue(func->GetName(), SIRValue::VK_Kernel), parent_(func),
    localHdrBlk_(NULL), localPreHdrBlk_ (NULL), localExtBlk_   (NULL),
    globalHdrBlk_(NULL), globalPreHdrBlk_(NULL), globalExtBlk_  (NULL) {
  for (int i =0; i < 3; ++i) {
    string dim = (i == 0) ? "X" : ((i == 1) ? "Y" : "Z");
    localID_   [i]    = new SIRRegister(true, "ITEM_ID."     + dim, this);
    groupID_   [i]    = new SIRRegister(true, "GROUP_ID."    + dim, this);
    globalID_  [i]    = new SIRRegister(true, "GLOBAL_ID."   + dim, this);
    numGroup_  [i]    = new SIRRegister(true, "NUM_GROUP."   + dim, this);
    groupSize_ [i]    = new SIRRegister(true, "GROUP_SIZE."  + dim, this);
    globalSize_[i]    = new SIRRegister(true, "GLOBAL_SIZE." + dim, this);
    localDimCnt_ [i]  = new SIRRegister(false,"LOCAL_CNT."   + dim, this);
    groupDimCnt_ [i]  = new SIRRegister(false,"GROUP_CNT."   + dim, this);
    globalDimCnt_[i]  = new SIRRegister(false,"GLOBAL_CNT."  + dim, this);
    specialRegs_["ITEM_ID."     + dim] = localID_[i];
    specialRegs_["GROUP_ID."    + dim] = groupID_[i];
    specialRegs_["GLOBAL_ID."   + dim] = globalID_[i];
    specialRegs_["NUM_GROUP."   + dim] = numGroup_[i];
    specialRegs_["GROUP_SIZE."  + dim] = groupSize_[i];
    specialRegs_["GLOBAL_SIZE." + dim] = globalSize_[i];
    specialRegs_["LOCAL_CNT."   + dim] = localDimCnt_[i];
    specialRegs_["GROUP_CNT."   + dim] = groupDimCnt_[i];
    specialRegs_["GLOBAL_CNT."  + dim] = globalDimCnt_[i];

    AddChild(localID_[i]);
    AddChild(groupID_[i]);
    AddChild(globalID_[i]);
    AddChild(numGroup_[i]);
    AddChild(groupSize_[i]);
    AddChild(globalSize_[i]);
    AddChild(localDimCnt_[i]);
    AddChild(groupDimCnt_[i]);
    AddChild(globalDimCnt_[i]);
  }// for i = 0 to 2
  localCounter_       = new SIRRegister(false, "LOCAL_CNT" , this);
  groupCounter_       = new SIRRegister(false, "GROUP_CNT" , this);
  globalCounter_      = new SIRRegister(false, "GLOBAL_CNT", this);
  localPredicate_     = new SIRRegister(false, "LOCAL_PRED", this);
  kernelStackPointer_ = new SIRRegister(false, "VSP", this);
  launchFramePointer_ = new SIRRegister(false, "LFP", this);
  specialRegs_["LOCAL_CNT" ] = localCounter_;
  specialRegs_["GROUP_CNT"] = globalCounter_;
  specialRegs_["GLOBAL_CNT"] = globalCounter_;
  specialRegs_["LOCAL_PRED"] = localCounter_;
  specialRegs_["VSP"] = kernelStackPointer_;
  specialRegs_["LFP"] = launchFramePointer_;
  AddChild(localCounter_);
  AddChild(groupCounter_);
  AddChild(globalCounter_);
  AddChild(localPredicate_);
  AddChild(kernelStackPointer_);
  AddChild(launchFramePointer_);
}// SIRKernel()

SIRKernel::~SIRKernel() {}// ~SIRKernel()

bool SIRKernel::IsGlobalCounter(int v) const {
  return globalCounter_->GetValueID() == v;
}
bool SIRKernel::IsLocalCounter(int v) const  {
  return localCounter_->GetValueID() == v;
}

int SIRKernel::
GetGlobalDimCounterIndex(int v) const  {
  for (int i = 0; i < 3; ++i) {
    if (globalDimCnt_[i]->GetValueID() == v) { return i; }
  }
  return -1;
}// GetGlobalDimCounterIndex()

int SIRKernel::
GetGlobalDimCounterIndex(SIRValue* v) const {
  return GetGlobalDimCounterIndex(v->GetValueID());
}

void SIRKernel::
InitCodeGen() {
  for (int i = 0; i < 3; ++i) {
    virtualSpecialRegs_.insert(localID_[i]->GetValueID());
    virtualSpecialRegs_.insert(groupID_[i]->GetValueID());
    virtualSpecialRegs_.insert(globalID_[i]->GetValueID());

    virSRegValueLUT_[localID_[i]->GetValueID() ] = LOCAL_ID_X  + i;
    virSRegValueLUT_[groupID_[i]->GetValueID() ] = GROUP_ID_X  + i;
    virSRegValueLUT_[globalID_[i]->GetValueID()] = GLOBAL_ID_X + i;
  }
}

bool SIRKernel::
IsSpecialRegister(int v) const {
  for (tr1::unordered_map<std::string, SIRRegister*>::const_iterator it
         = specialRegs_.begin(); it != specialRegs_.end(); ++it) {
    if (it->second->GetValueID() == v) { return true; }
  }
  return false;
}// IsSpecialRegister()

SIRRegister* SIRKernel::
GetSpecialRegister(const std::string& reg) const {
  return IsElementOf(reg, specialRegs_)? specialRegs_.find(reg)->second : NULL;
}// GetSpecialRegister()

SIRRegister* SIRKernel::
GetVirtualSRegFromID(int i) const {
  switch(i) {
  default         : return NULL;
  case SIRKernel::GLOBAL_ID_X: return globalID_[0];
  case SIRKernel::GLOBAL_ID_Y: return globalID_[1];
  case SIRKernel::GLOBAL_ID_Z: return globalID_[2];
  case SIRKernel::GROUP_ID_X : return groupID_[0];
  case SIRKernel::GROUP_ID_Y : return groupID_[1];
  case SIRKernel::GROUP_ID_Z : return groupID_[2];
  case SIRKernel::LOCAL_ID_X : return localID_[0];
  case SIRKernel::LOCAL_ID_Y : return localID_[1];
  case SIRKernel::LOCAL_ID_Z : return localID_[2];
  }
}// GetVirtualSRegFromID()
ostream& ES_SIMD::
operator<<(ostream& o, const SIRKernelLaunch& k) {
  if ((k.globalDim_ <= 0) && (k.groupDim_ <=0)) { return o <<"<<<NIL>>>"; }
  o <<"<<<(";
  for (unsigned i = 0; i < 3; ++i) {
    if (i > 0) { o <<", "; }
    o << k.numGroups_[i];
  }
  o <<"), (";
  for (unsigned i = 0; i < 3; ++i) {
    if (i > 0) { o <<", "; }
    o << k.groupSize_[i];
  }
  o <<")>>>";
  return o;
}
