#include "BaselinePostRATransform.hh"
#include "BaselineInstrData.hh"
#include "BaselineBlockData.hh"
#include "BaselineFuncData.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineCodeGenEngine.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetModuleData.hh"
#include "Target/TargetIssuePacket.hh"
#include "Target/TargetFuncRegAllocInfo.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/BitUtils.hh"

using namespace ES_SIMD;
using namespace std;

static bool
IsCallerSavedReg(int v, const BaselineFuncData* fData, const SIRCallSite* cs) {
  if (fData->Function()->IsSpecialRegister(v)) { return false; }
  if (v == cs->GetCallerInstr()->GetValueID())    { return false; }
  if (const SIRFunction* callee = cs->GetCallee()) {
    int vr = fData->GetRegAllocInfo()->GetValuePhyRegister(v);
    int vc = fData->GetRegAllocInfo()->GetValueRegClass(v);
    if (!callee->GetTargetData()->ClobbersPhyReg(vr, vc)) { return false; }
    if (cs->IsArgument(v)) {
      // If it is an argument, it is marked live-out regardless of the actual
      // liveness beyond the call block. Here we check if it is really live-out.
      const SIRBasicBlock* cb = cs->GetCallerInstr()->GetParent();
      for (SIRBasicBlock::succ_const_iterator sIt = cb->succ_begin();
           sIt != cb->succ_end(); ++sIt) {
        if ((*sIt)->IsValueLiveIn(v)) { return true; }
      }
      return false;
    }// if (cs->IsArgumentValue(v))
  }// if (const SIRFunction* callee = cs->GetCallee())
  return true;
}// IsCallerSavedReg()

void BaselineCallerSavedRegPass::
ModuleInit(SIRModule* m) {
  module_ = m;
  mData_ = m->GetTargetData();
}// ModuleInit()

void BaselineCallerSavedRegPass::
SavePhyRegs(const vector<SIRRegister*>& savedRegs, const SIRCallSite* cs) {
  SIRBasicBlock* cb    = cs->GetCallerInstr()->GetParent();
  BaselineBlockData* cbData
    = dynamic_cast<BaselineBlockData*>(cb->GetTargetData());
  BaselineBlockData::iterator savIt = cbData->end(); --savIt; --savIt;
  TargetIssuePacket* delaySlockPacket = cbData->back();
  for (int i = 0, e = savedRegs.size(); i < e; ++i) {
    SIRRegister* reg = savedRegs[i];
    int v = reg->GetValueID();
    if (func_->IsConstPoolUser(v)) { continue; }
    int pReg = raInfo_->GetValuePhyRegister(v);
    bool vect = raInfo_->GetValueRegClass(v);
    ES_LOG_P(logLv_, log_, ">>-- Saving "<<*reg<<"(V_"<< v << (vect?" PE":" CP")
              <<".r"<< pReg <<") BB"<< cb->GetBasicBlockID() <<" of "
             << func_->GetName() <<'\n');
    int so = fData_->GetSpillSlotOffset(raInfo_->GetSpillSlotIndex(v,vect),vect);
    uint32_t spillOffset = static_cast<uint32_t>(so);
    bool fit = target_.ImmCanFit(TargetOpcode::SW, vect, so);
    SIRInstruction *store = new SIRInstruction(TargetOpcode::SW, cb, vect);
    SIRInstruction *stImmInstr = NULL;
    if (!fit) {
      stImmInstr = new SIRInstruction(TargetOpcode::SIMM, cb, vect);
      unsigned ibits = target_.GetImmSize(store);
      uint32_t high = spillOffset >> ibits;
      spillOffset  = ExtractBitsFromWord(spillOffset, 0, ibits-1);
      mData_->InitTargetData(stImmInstr);
      stImmInstr->AddOperand(func_->GetParent()->AddOrGetImmediate(high));
    }// if (!fit)
    SIRConstant* offset = func_->GetParent()->AddOrGetImmediate(spillOffset);
    // Saving
    SIRInstruction* delaySlotInstr = delaySlockPacket->GetInstr(vect);
    store->AddOperand(func_->GetStackPointer());
    if (IsElementOf(v, defInstrs_)) { store->AddOperand(GetValue(v,defInstrs_)); }
    else { store->AddOperand(reg); }
    store->AddOperand(offset);
    BaselineInstrData* stData = dynamic_cast<BaselineInstrData*>(
      mData_->InitTargetData(store));
    stData->SetOperandPhyReg(0, raInfo_->GetValuePhyRegister(
                               func_->GetStackPointer()->GetValueID()));
    stData->SetOperandPhyReg(1, pReg);
    // Iterator for padding in case the store is too early
    BaselineBlockData::iterator stIt = savIt;
    if (delaySlotInstr && (delaySlotInstr->GetValueID() == v)) {
      if (stImmInstr) {
        delaySlockPacket->RemoveInstr(delaySlotInstr);
        cbData->InsertBefore(savIt, stImmInstr);
        cbData->InsertBefore(savIt, store);
        cbData->InsertBefore(savIt, delaySlotInstr);
        --stIt;
      } else {// if (stImmInstr)
        cbData->InsertBefore(savIt, delaySlotInstr);
        delaySlockPacket->SetInstr(store, vect);
        cb->AddManagedValue(store);
      }// if (stImmInstr)
      --stIt;
    } else {// if (delaySlotInstr && (delaySlotInstr->GetValueID() == v))
      if (stImmInstr) {
        cbData->InsertBefore(savIt, stImmInstr); 
        cbData->InsertBefore(savIt, store);
        --stIt; --stIt;
      } else {
        if (!delaySlotInstr
            || delaySlotInstr->GetTargetOpcode() == TargetOpcode::NOP) {
          delaySlockPacket->SetInstr(store, vect);
          cb->AddManagedValue(store);
        } else {
          if (delaySlotInstr) {
            delaySlockPacket->RemoveInstr(delaySlotInstr);
            cbData->InsertBeforeWithTimingCheck(savIt, delaySlotInstr);
            delaySlockPacket->SetInstr(store, vect);
            cb->AddManagedValue(store);
            // --stIt;
          } else {// if (delaySlotInstr)
            cbData->InsertBefore(savIt, store);
          }
          --stIt;
        }
      }// if (stImmInstr)
    }// if (delaySlotInstr && (delaySlotInstr->GetValueID() == v)) else
    cbData->InitIssueTime();
    // Make sure the value is available when storing it
    if (IsElementOf(v, defInstrs_)) {
      BaselineInstrData* dd = dynamic_cast<BaselineInstrData*>(
        GetValue(v, defInstrs_)->GetTargetData());
      int dt = dd->GetIssueTime() + dd->GetLatency();
      int delay = dt-stData->GetIssueTime();
      if (!cs->IsArgument(v)) {
        GetValue(v, defInstrs_)->SetValueID(func_->AllocateValue());
      }
      for (int d = 0; d < delay; ++d) { cbData->InsertNOPBefore(stIt); }
      if (delay > 0) { cbData->InitIssueTime(); }
    }// if (IsElementOf(v, defInstrs_))
  }// for i = 0 to savedRegs.size()  
}// SavePhyRegs()

void BaselineCallerSavedRegPass::
RestorePhyRegs(const vector<SIRRegister*>& savedRegs, const SIRCallSite* cs) {
  SIRBasicBlock* cb    = cs->GetCallerInstr()->GetParent();
  BaselineBlockData* cbData
    = dynamic_cast<BaselineBlockData*>(cb->GetTargetData());
  BaselineBlockData::iterator resIt = cbData->end(); --resIt;
  for (int i = 0, e = savedRegs.size(); i < e; ++i) {
    SIRRegister* reg = savedRegs[i];
    int v = reg->GetValueID();
    int pReg = raInfo_->GetValuePhyRegister(v);
    bool vect = raInfo_->GetValueRegClass(v);
    bool isInConstPool = func_->IsConstPoolUser(v);
    int lo = isInConstPool ?
      (module_->GetConstPoolObject(func_->GetConstPoolUserImm(v))
       ->GetAddress() / 4)
      : fData_->GetSpillSlotOffset(raInfo_->GetSpillSlotIndex(v,vect),vect);
    ES_LOG_P(logLv_&&isInConstPool,log_,">>-- Reloading long imm V_"<<v<<'\n');
    uint32_t loadOffset = static_cast<uint32_t>(lo);
    bool fit = target_.ImmCanFit(TargetOpcode::SW, vect, lo);
    SIRInstruction *load = new SIRInstruction(TargetOpcode::LW, cb, vect);
    SIRInstruction *ldImmInstr = NULL;
    if (!fit) {
      ldImmInstr = new SIRInstruction(TargetOpcode::SIMM, cb, vect);
      unsigned ibits = target_.GetImmSize(load);
      uint32_t high = loadOffset >> ibits;
      loadOffset  = ExtractBitsFromWord(loadOffset, 0, ibits-1);
      mData_->InitTargetData(ldImmInstr);
      ldImmInstr->AddOperand(func_->GetParent()->AddOrGetImmediate(high));
    }// if (!fit)
    SIRConstant* offset = func_->GetParent()->AddOrGetImmediate(loadOffset);
    SIRValue* loadBase = isInConstPool ? func_->GetZeroRegister()
      : func_->GetStackPointer();
    load->AddOperand(loadBase).AddOperand(offset).SetValueID(v);
    BaselineInstrData* ldData = dynamic_cast<BaselineInstrData*>(
      mData_->InitTargetData(load));
    ldData->SetOperandPhyReg(0, raInfo_->GetValuePhyRegister(
                               loadBase->GetValueID()));
    ldData->SetDestPhyReg(pReg);
    cbData->InsertAfter(resIt, load);
    if (ldImmInstr) { cbData->InsertAfter(resIt, ldImmInstr); }
  }// for i = 0 to savedRegs.size()-1
}//RestorePhyRegs()

struct CmpRegDefTime {
  Int2IntMap defTime;
  bool operator()(const SIRRegister* lhs, const SIRRegister* rhs) const {
    int lv = lhs->GetValueID(), rv = rhs->GetValueID();
    if (IsElementOf(lv, defTime) && IsElementOf(rv, defTime)) {
      return GetValue(lv, defTime) < GetValue(rv, defTime);
    }
    return false;
  }
};

bool BaselineCallerSavedRegPass::
RunOnSIRFunction(SIRFunction* func) {
  bool changed = false;
  func_  = func;
  fData_ = dynamic_cast<BaselineFuncData*>(func->GetTargetData());
  raInfo_ = func->GetTargetData()->GetRegAllocInfo();
  vector<SIRRegister*> savedRegs;
  CmpRegDefTime csrDefTimeCmp;
  defInstrs_.clear();
  for (SIRFunction::cs_iterator cIt = func_->cs_begin();
       cIt != func_->cs_end(); ++cIt) {
    SIRCallSite* cs = *cIt;
    SIRBasicBlock* cb    = cs->GetCallerInstr()->GetParent();
    BaselineBlockData* cbData
      = dynamic_cast<BaselineBlockData*>(cb->GetTargetData());
    ES_LOG_P(logLv_, log_, ">> Call-site "
             << (cs->GetCallee() ? "("+cs->GetCallee()->GetName()+")":"")
             <<" in BB"<< cb->GetBasicBlockID()
             <<" of "<< func_->GetName() <<'\n');
    if (logLv_) { cbData->ValuePrint(log_); }
    savedRegs.clear();
    savedRegs.reserve(cb->lo_size());
    for (SIRBasicBlock::lo_iterator lIt = cb->lo_begin();
         lIt != cb->lo_end(); ++lIt) {
      int lv = (*lIt)->GetValueID();
      int lr = raInfo_->GetValuePhyRegister(lv);
      if (lr < 0) { continue; }
      ES_LOG_P(logLv_, log_, ">>-- Checking "<< (*lIt)->GetName() <<"(V_"<< lv
               << ((*lIt)->IsVector()?" PE":" CP")<<".r"<< lr <<")\n");
      if (IsCallerSavedReg(lv, fData_, cs)) { savedRegs.push_back(*lIt); }
    }// for cb lo_iterator lIt
    if (savedRegs.empty()) { continue; }
    changed = true;
    csrDefTimeCmp.defTime.clear();
    defInstrs_.clear();
    for (BaselineBlockData::iterator pIt = cbData->begin();
         pIt != cbData->end(); ++pIt) {
      for (int i = 0, e = savedRegs.size(); i < e; ++i) {
        if(SIRInstruction* d=(*pIt)->GetValueInstr(savedRegs[i]->GetValueID())){
          BaselineInstrData* dData
            = dynamic_cast<BaselineInstrData*>(d->GetTargetData());
          csrDefTimeCmp.defTime[savedRegs[i]->GetValueID()]
            = dData->GetIssueTime() + dData->GetLatency();
          defInstrs_[savedRegs[i]->GetValueID()] = d;
        }
      }
    }// for cbData iterator pIt
    sort(savedRegs.begin(), savedRegs.end(), csrDefTimeCmp);
    SavePhyRegs(savedRegs, cs);
    RestorePhyRegs(savedRegs, cs);
    SetBaselineBlockBypass(cb, target_, logLv_, log_);
    if (logLv_) { cbData->ValuePrint(log_); }
  }// for SIRFunction cs_iterator cIt
  if (changed) { BaselineFixJointPoints(func, target_, logLv_, log_); }
  return changed;
}// RunOnSIRFunction()
