#include "BaselineCodeGenEngine.hh"
#include "BaselineRegAlloc.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineInstrData.hh"
#include "BaselineBlockData.hh"
#include "BaselineFuncData.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRKernel.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetModuleData.hh"
#include "Target/RegAlloc.hh"
#include "Target/InterferenceGraph.hh"
#include "Target/TargetFuncRegAllocInfo.hh"
#include "Target/TargetIssuePacket.hh"
#include "Utils/BitUtils.hh"
#include "Utils/StringUtils.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/LogUtils.hh"
#include "llvm/Support/Casting.h"
#include <cmath>

using namespace std;
using namespace ES_SIMD;

static void
SetInstrLiveInterval (
  const SIRInstruction* instr, BlockLiveInterval& liveIntervals,
  float blockCostBase, Int2IntMap& def, Int2IntMap& lastUse, IntSet& deadValues,
  Int2FloatMap& spillCost, BaselineFuncData* fData, bool dbg, ostream& dbgs) {
  if (!instr) { return; }
  TargetFuncRegAllocInfo* raInfo = fData->GetRegAllocInfo();
  const BaselineInstrData* idata
    = dynamic_cast<const BaselineInstrData*>(instr->GetTargetData());
  int issueTime = idata->GetIssueTime() + 1;
  for (SIRInstruction::operand_const_iterator oIt = instr->operand_begin();
       oIt != instr->operand_end(); ++oIt) {
    int ov = (*oIt)->GetValueID();
    if (SIRFunction::IsValidValueID(ov)) {
      ES_ASSERT_MSG(IsElementOf(ov, def) || IsElementOf(ov, deadValues)
                    || fData->GetRegAllocInfo()->IsPreDefinedValue(ov),
                    "Value V_"<< ov <<" used before def by: "<<*instr
                    <<" in "<< instr->GetParent()->GetParent()->GetName()<<".B"
                    << instr->GetParent()->GetBasicBlockID());
      // Value is ignored unless it is stored in RF
      if (IsElementOf(ov,deadValues)||raInfo->IsPreDefinedValue(ov)) {continue;}
        lastUse[ov] = issueTime;
        // Add spill cost for loading
        spillCost[ov] += raInfo->IsImmReg(ov)?(blockCostBase/2):blockCostBase;
    }//if (SIRFunction::IsValidValueID(ov))
  }// for instr->operand_const_iterator oIt
  // Add output value
  int v = instr->GetValueID();
  if(SIRFunction::IsValidValueID(v)) {
    if (!idata->ToRF()) { deadValues.insert(v); return; }
    if (fData->GetRegAllocInfo()->IsPreDefinedValue(v)) { return; }
    if (IsElementOf(v, lastUse) && (GetValue(v, lastUse) >= 0)) {
      ES_ASSERT_MSG(IsElementOf(v, def), "Value used before def");
      ES_ASSERT_MSG(def[v] <= lastUse[v], "Backward life range for "<< v
                    <<" ["<< def[v] <<", "<< lastUse[v] <<")");
      liveIntervals[v].AddLiveRange(def[v], lastUse[v]);
      ES_LOG_P(dbg, dbgs, ">>-- 1:LR_"<< v <<"["<< def[v] <<","
               << lastUse[v] <<")\n");
    }
    fData->GetRegAllocInfo()->SetValueRegClass(v, instr->IsVectorInstr()?1:0);
    def[v]     = issueTime;
    lastUse[v] = -1;
    // Add spill cost for storing
    spillCost[v] += blockCostBase * 1.5f;
  }// if(SIRFunction::IsValidValueID(v))
}// SetInstrLiveInterval()

void
CreateBaselineBlockLiveIntervals (
  BaselineBlockData& blockRAInfo, BaselineFuncData* fData,
  bool dbg, ostream& dbgs) {

  TargetFuncRegAllocInfo* fRAInfo = fData->GetRegAllocInfo();
  blockRAInfo.Reset();
  blockRAInfo.InitValueInfo();
  SIRBasicBlock* bb = blockRAInfo.BasicBlock();
  BlockLiveInterval& liveIntervals = blockRAInfo.LiveIntervals();
  Int2FloatMap& spillCost = blockRAInfo.SpillCost();
  Int2IntMap def;
  Int2IntMap lastUse;
  IntSet deadValues;
  const IntSet& immRegs = fRAInfo->ImmRegs();
  def.clear();
  lastUse.clear();
  // Simple loop-base cost estimation: 10 times more costly for each level
  float blockCostBase = pow(10.0f, bb->GetLoopDepth());
  ES_LOG_P(dbg, dbgs, "BB_"<< bb->GetBasicBlockID() <<" is in loop level "
           << bb->GetLoopDepth() <<", base cost = "<< blockCostBase <<"\n");
  for (IntSet::const_iterator it = immRegs.begin();
       it != immRegs.end(); ++it) { def[*it] = 0; }
  for (SIRBasicBlock::li_const_iterator lIt = bb->li_begin();
       lIt != bb->li_end(); ++lIt) {
    def[(*lIt)->GetValueID()] = 0;
    fRAInfo->SetValueRegClass((*lIt)->GetValueID(), (*lIt)->IsVector() ? 1 : 0);
  }
  for (BaselineBlockData::const_iterator pIt = blockRAInfo.begin();
       pIt != blockRAInfo.end(); ++pIt) {
    SIRInstruction* cpInstr = (*pIt)->GetInstr(BaselineBasicInfo::CP);
    SIRInstruction* peInstr = (*pIt)->GetInstr(BaselineBasicInfo::PE);
    if (peInstr && cpInstr
        && (dynamic_cast<BaselineInstrData*>(peInstr->GetTargetData())
            ->GetCommConsumer()== cpInstr)) {
      SetInstrLiveInterval (peInstr, liveIntervals, blockCostBase, def, lastUse,
                          deadValues, spillCost, fData, dbg, dbgs);
      SetInstrLiveInterval (cpInstr, liveIntervals, blockCostBase, def, lastUse,
                          deadValues, spillCost, fData, dbg, dbgs);
    } else {
      SetInstrLiveInterval (cpInstr, liveIntervals, blockCostBase, def, lastUse,
                            deadValues, spillCost, fData, dbg, dbgs);
      SetInstrLiveInterval (peInstr, liveIntervals, blockCostBase, def, lastUse,
                            deadValues, spillCost, fData, dbg, dbgs);
    }
  }// for blockRAInfo const_iterator pIt
  int issueTime = blockRAInfo.Length() + 2;
  for (SIRBasicBlock::li_const_iterator lIt = bb->lo_begin();
       lIt != bb->lo_end(); ++lIt) { lastUse[(*lIt)->GetValueID()]=issueTime; }

  for (Int2IntMap::const_iterator vIt = lastUse.begin(); vIt != lastUse.end(); ++vIt) {
    if (fRAInfo->IsValueSpilled(vIt->first)) { continue; }
    if (vIt->second >= 0) {
      liveIntervals[vIt->first].AddLiveRange(def[vIt->first], vIt->second);
      ES_LOG_P(dbg, dbgs, ">>-- LR_"<< vIt->first <<"["<< def[vIt->first]
               <<","<< vIt->second <<")\n");
    }// if (vIt->second >= 0)
  }
}// CreateBlockLiveIntervals()

void ES_SIMD::
CalculateLiveIntervals(SIRFunction* func, bool dbg, ostream& dbgs) {
  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  TargetFuncRegAllocInfo* raInfo = fData->GetRegAllocInfo();
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    BaselineBlockData& bRAInfo
      = *dynamic_cast<BaselineBlockData*>((*bIt)->GetTargetData());
    CreateBaselineBlockLiveIntervals(bRAInfo, fData, dbg, dbgs);
    bRAInfo.MergeSpillCostTo(raInfo->SpillCost());
  }// for func iterator bIt
}// CalculateLiveIntervals()

static void
InsertImm(SIRFunction* func, const BaselineBasicInfo& target) {
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    dynamic_cast<BaselineBlockData*>((*bIt)->GetTargetData())
      ->InsertImmInstr(target);
  }// for func iterator bIt
}// InsertImm()

struct RegisterCalleeCost {
  Int2IntMap clobberedCache_;
  const SIRFunction* func_;
  int regClass_;
  void Init(int rc, SIRFunction* func) {
    clobberedCache_.clear();
    regClass_ = rc;
    func_ = func;
  }
  bool CheckCalleeClobber(int r) {
    for (SIRFunction::callee_const_iterator it = func_->callee_begin();
         it != func_->callee_end(); ++it) {
      if (!(*it) || !SIRFunction::classof(*it)) { return true; }
      TargetFuncData* cData = static_cast<SIRFunction*>(*it)->GetTargetData();
      ES_ASSERT_MSG(cData, "No target data for function "
                    <<static_cast<SIRFunction*>(*it)->GetName());
      if (cData->ClobbersPhyReg(r, regClass_)) { return true; }
    }
    return false;
  }
  bool operator()(int lhs, int rhs) {
    bool lClobbered = false, rClobbered = false;
    if (IsElementOf(lhs,clobberedCache_)) { lClobbered = clobberedCache_[lhs]; }
    else { clobberedCache_[lhs] = lClobbered = CheckCalleeClobber(lhs); }
    if (IsElementOf(rhs,clobberedCache_)) { rClobbered = clobberedCache_[rhs]; }
    else { clobberedCache_[rhs] = rClobbered = CheckCalleeClobber(rhs); }
    return (!lClobbered && rClobbered)
      || (!rClobbered && lClobbered && (lhs < rhs));
  }
};// struct RegisterCalleeCost

static bool
FunctionRegAllocPass(SIRFunction* func, Int2FloatMap& spillCandidates,
                     const BaselineBasicInfo& target, bool dbg, ostream& dbgs) {
  static RegisterCalleeCost costComparator;
  InterferenceGraph intGraph;
  IntSet possibleSpills;
  TargetFuncRegAllocInfo* raInfo = func->GetTargetData()->GetRegAllocInfo();
  const Int2IntMap& preAllocatedValues = raInfo->PreAllocatedValues();
  // Build interferene graph
  for (Int2IntMap::const_iterator it = preAllocatedValues.begin();
       it != preAllocatedValues.end(); ++it) {
    int rc = raInfo->GetValueRegClass(it->first);
    ES_ASSERT_MSG( rc >=0, "No reg class assigned to V_"<< it->first);
    intGraph.AddResourceNode(it->first, rc);
  }
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    BaselineBlockData& bRAInfo
      = *dynamic_cast<BaselineBlockData*>((*bIt)->GetTargetData());
    intGraph.AddBlockResources(
      bRAInfo.LiveIntervals(), bRAInfo.Length(), raInfo->ValueRegClassMap());
    if (dbg) {
      dbgs <<">> BB_"<< (*bIt)->GetBasicBlockID() <<" LiveIntervals:\n";
      for (BlockLiveInterval::iterator liIt = bRAInfo.LiveIntervals().begin();
           liIt != bRAInfo.LiveIntervals().end(); ++liIt) {
        dbgs <<">>-- V_"<< liIt->first <<": "<< liIt->second <<"\n";
      }
    }// if (dbgs)
  }// for func iterator bIt
  ES_LOG_P(dbg, dbgs, "IntGraph has "<< intGraph.size() <<" nodes and "
           << intGraph.edge_size() <<" edges\n");
  IntVector availCPRegs = target.GetCPAvailPhyRegs();
  IntVector availPERegs = target.GetPEAvailPhyRegs();
  costComparator.Init(0, func);
  sort(availCPRegs.begin(), availCPRegs.end(), costComparator);
  costComparator.Init(0, func);
  sort(availPERegs.begin(), availPERegs.end(), costComparator);
  ES_LOG_P(dbg, dbgs, availCPRegs.size() <<" CP registers available\n"
           << availPERegs.size() <<" PE registers available\n");
  tr1::unordered_map<int, const IntVector*> availRegs;
  availRegs[0] = &availCPRegs;
  availRegs[1] = &availPERegs;
  // Color the interference graph
  intGraph.ColorNodes(raInfo->RegAssignment(), possibleSpills, availRegs,
                      raInfo->PreAllocatedValues(), raInfo->ReservedPhyRegs());
  ES_LOG_P(dbg &&!possibleSpills.empty(), dbgs,
           possibleSpills.size() <<" possible spills\n");
  if (dbg && possibleSpills.empty()) {
    for (Int2IntMap::iterator it = raInfo->RegAssignment().begin();
         it != raInfo->RegAssignment().end(); ++ it) {
      if (raInfo->IsPreAllocValue(it->first)) { dbgs <<"<p>"; }
      dbgs <<"Color[V_"<< it->first<<"]="<< it->second <<"\n";
    }
  }
  spillCandidates.clear();
  if (!possibleSpills.empty()) {
    for (IntSet::const_iterator it = possibleSpills.begin();
         it != possibleSpills.end(); ++it) {
      int v = *it;
      if (raInfo->IsNonSpillValue(v)) { continue; }
      int d = intGraph.Degree(intGraph.GetResourceNode(v));
      float c = raInfo->GetSpillCost(v) / d;
      ES_LOG_P(dbg, dbgs, "C[V_"<< v <<"]="<< c <<" (d="<< d <<")\n");
      spillCandidates[v] = c;
    }// for possibleSpills const_iterator it
  }// if (!possibleSpills.empty())
  return possibleSpills.empty();
}// FunctionRegAllocPass()

void ES_SIMD::
FunctionRegAlloc(
  SIRFunction* func, const BaselineBasicInfo& target, bool dbg, ostream& dbgs) {

  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  TargetFuncRegAllocInfo* raInfo = func->GetTargetData()->GetRegAllocInfo();
  CalculateLiveIntervals(func, dbg, dbgs);
  Int2FloatMap possibleSpills;
  while(!FunctionRegAllocPass(func, possibleSpills, target, dbg, dbgs)) {
    int sp     = -1;
    float cost = 0.0f;
    for (Int2FloatMap::iterator it = possibleSpills.begin();
         it != possibleSpills.end(); ++it) {
      if ((sp < 0) || (it->second < cost)) {
        sp = it->first;
        cost = it->second;
      }
    }
    ES_LOG_P(dbg, dbgs, "L: Spilling V_"<< sp <<"\n");
    SpillValue(func, sp, raInfo->GetValueRegClass(sp), dbg, dbgs);
    fData->UpdateRegPressure();
    InsertImm(func, target);
    UpdateBaselineFuncBypass(func, target, dbg, dbgs);
    CalculateLiveIntervals(func, dbg, dbgs);
  }// while(!FunctionRegAllocPass(func, possibleSpills, target, dbg, dbgs))
  ES_LOG_P(dbg && raInfo->GetNumStackSpills(BaselineBasicInfo::CP), dbgs,
           raInfo->GetNumStackSpills(BaselineBasicInfo::CP)
           <<" CP values spilled to stack\n");
  ES_LOG_P(dbg && raInfo->GetNumStackSpills(BaselineBasicInfo::PE), dbgs,
           raInfo->GetNumStackSpills(BaselineBasicInfo::PE)
           <<" PE values spilled to stack\n");
  //if (dbg) { fData->ValuePrint(dbgs); }
}// FunctionRegAlloc()

void ES_SIMD::
AssignPhyRegisters(SIRFunction* func, bool dbg, ostream& dbgs) {
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    BaselineBlockData& bData
      = *dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
    for (BaselineBlockData::iterator pIt = bData.begin();
         pIt != bData.end(); ++pIt) {
      if (SIRInstruction* ci = (*pIt)->GetInstr(BaselineBasicInfo::CP)) {
        ci->GetTargetData()->AssignPhyRegisters();
      }
      if (SIRInstruction* pi = (*pIt)->GetInstr(BaselineBasicInfo::PE)) {
        pi->GetTargetData()->AssignPhyRegisters();
      }
    }// for bData iterator pIt
  }// for func iterator bIt
}// AssignPhyRegisters()

static void AdjustLSAddrOffset(SIRInstruction* instr, SIRModule* module) {
  if (!instr) { return; }
  TargetOpcode_t opc = instr->GetTargetOpcode();
  if (!IsTargetMemoryOp(opc)) { return; }
  SIRConstant* offset = NULL;
  if (IsTargetLoad(opc)) {
    SIRValue* o = instr->GetOperand(1);
    ES_ASSERT_MSG(llvm::isa<SIRConstant>(o), "Offset if not constant");
    offset = llvm::cast<SIRConstant>(o);
  } else {
    SIRValue* o = instr->GetOperand(2);
    ES_ASSERT_MSG(llvm::isa<SIRConstant>(o), "Offset if not constant");
    offset = llvm::cast<SIRConstant>(o);
  }
  int offsetVal = offset->GetImmediate();
  switch (opc) {
  case TargetOpcode::LW: case TargetOpcode::SW: {
    SIRConstant* newOffset = module->AddOrGetImmediate(offsetVal>>2);
    instr->ReplaceOperand(offset, newOffset);
    break;
  }
  case TargetOpcode::LH: case TargetOpcode::SH: {
    SIRConstant* newOffset = module->AddOrGetImmediate(offsetVal>>1);
    instr->ReplaceOperand(offset, newOffset);
    break;
  }
  default:break;
  }// switch (opc)
}// AdjustLSAddrOffset

static void
AdjustAddrOffset(SIRFunction* func) {
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    BaselineBlockData& bData
      = *dynamic_cast<BaselineBlockData*>((*bIt)->GetTargetData());
    for (BaselineBlockData::iterator pIt = bData.begin();
         pIt != bData.end(); ++pIt) {
      AdjustLSAddrOffset((*pIt)->GetInstr(BaselineBasicInfo::CP), func->GetParent());
      AdjustLSAddrOffset((*pIt)->GetInstr(BaselineBasicInfo::PE), func->GetParent());
    }
  }// for func iterator bIt
}// AdjustAddrOffset()

BaselineFuncRegAllocPass::~BaselineFuncRegAllocPass() {}

bool BaselineFuncRegAllocPass::
RunOnSIRFunction(SIRFunction* func) {
  func->SetTargetStackOffset(func->GetSIRStackOffset());
  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  fData->InitRegAlloc();
  TargetFuncRegAllocInfo* raInfo = fData->GetRegAllocInfo();
  raInfo->ReservePhyReg(BaselineBasicInfo::CP, 0);
  raInfo->ReservePhyReg(BaselineBasicInfo::PE, 0);
  raInfo->AddNonSpillValue(func->GetZeroRegister()->GetValueID());
  raInfo->AddNonSpillValue(func->GetStackPointer()->GetValueID());
  // Should not try to spill LR and use it as temp if there is func calls,
  // as it will be overwritten by hardware when calling another function
  if (!func->IsLeaf()) {
    raInfo->AddNonSpillValue(func->GetLinkRegister()->GetValueID());
  }
  raInfo->AddPreAllocatedValue(func->GetZeroRegister()->GetValueID(), 0);
  raInfo->AddPreAllocatedValue(func->GetLinkRegister()->GetValueID(), 9);
  raInfo->SetValueRegClass(func->GetZeroRegister()->GetValueID(), 0);
  raInfo->SetValueRegClass(func->GetLinkRegister()->GetValueID(), 0);

  raInfo->AddPreAllocatedValue(func->GetStackPointer()->GetValueID(), 1);
  raInfo->SetValueRegClass(func->GetStackPointer()->GetValueID(), 0);
  raInfo->ReservePhyReg(BaselineBasicInfo::CP, 1);
  raInfo->ReservePhyReg(BaselineBasicInfo::PE, 1); // PE ID register
  raInfo->ReservePhyReg(BaselineBasicInfo::CP, 2); // PE stack pointer
  ES_LOG_P(logLv_, log_, func->GetName() <<" has "<< func->arg_size()
           <<" arguments\n");
  if (func->arg_size() <= 6) {
    // arguments can fit in registers
    int aIdx = 3;
    for (SIRFunction::arg_iterator aIt = func->arg_begin();
         aIt != func->arg_end(); ++aIt) {
      int va = (*aIt)->GetValueID();
      ES_LOG_P(logLv_, log_, "Arg: V_"<< va <<"("<<(*aIt)->GetName()
               <<")="<< aIdx<<"\n");
      raInfo->AddPreAllocatedValue(va, aIdx);
      raInfo->SetValueRegClass(va, 0);
      ++ aIdx;
    }
  }// if (func->arg_size() <= 6)
  if (!func->ret_empty()) {
    int rv = (*func->ret_begin())->GetValueID();
    ES_LOG_P(logLv_, log_, "Return: V_"<< rv <<"="<< 11 <<"\n");
    raInfo->AddPreAllocatedValue(rv, 11);
    raInfo->SetValueRegClass(rv, 0);
  }
  // Call sites
  for (SIRFunction::cs_iterator cIt = func->cs_begin();
       cIt != func->cs_end(); ++cIt) {
    SIRCallSite* cs = *cIt;
    int aIdx = 3;
    for (unsigned i = 0; i < cs->arg_size(); ++i) {
      if (cs->GetArgument(i)) {
        int va = cs->GetArgument(i)->GetValueID();
        raInfo->AddPreAllocatedValue(va, aIdx);
        raInfo->SetValueRegClass(va, 0);
        ++ aIdx;
      }// if (cs->GetArgument(i))
    }
    int rv = cs->GetCallerInstr()->GetValueID();
    if (rv >= 0) {
      raInfo->AddPreAllocatedValue(rv, 11);
      raInfo->SetValueRegClass(rv, 0);
    }
  }// for func cs_iterator cIt
  raInfo->AddPreDefinedValue(func->GetZeroRegister()->GetValueID());
  int pv = func->GetPEIDRegister()->GetValueID();
  raInfo->AddPreAllocatedValue(pv, 1);
  raInfo->AddPreDefinedValue(pv);
  raInfo->SetValueRegClass(pv, 1);
  if (func->GetNumPERegister()->use_size()) {
    int np = func->GetNumPERegister()->GetValueID();
    raInfo->AddPreAllocatedValue(np, 13);
    raInfo->AddPreDefinedValue(np);
    raInfo->ReservePhyReg(BaselineBasicInfo::CP, 13);
    raInfo->SetValueRegClass(np, 0);
  }
  if (func->IsSolverKernel()) {
    int lp = func->GetSolverKernel()->GetLocalPredicate()->GetValueID();
    raInfo->AddPreAllocatedValue(lp, 1);
    raInfo->SetValueRegClass(lp, 3); // PE flags
  }// if (SIRKernel* kernel = func->GetSolverKernel())
  AdjustAddrOffset(func);
  InsertImm(func, target_);
  UpdateBaselineFuncBypass(func, target_, logLv_, log_);
  if (logLv_) { fData->ValuePrint(log_); }
  while(!BaselineEarlyLiveIntervalSpill(func, target_, (logLv_>1), log_)) {
    InsertImm(func, target_);
    UpdateBaselineFuncBypass(func, target_, (logLv_>1), log_);
  }
  FunctionRegAlloc(func, target_,logLv_,log_);
  AssignPhyRegisters(func, logLv_, log_);
  return true;
}// BaselineFuncRegAllocPass::RunOnSIRFunction()

static bool
CalleesAllocated(const SIRFunction* func, const set<SIRFunction*>& s) {
  for (SIRFunction::callee_const_iterator it = func->callee_begin();
       it != func->callee_end(); ++it) {
    if (SIRFunction::classof(*it)) {
      SIRFunction* t = static_cast<SIRFunction*>(*it);
      if (!IsElementOf(t, s)) { return false; }
    } else { ES_NOTIMPLEMENTED("Non-function callee"); }
  }
  return true;
}

bool BaselineFuncRegAllocPass::
RunOnSIRModule(SIRModule* m) {
  bool change = false;
  mData_ = m->GetTargetData();
  set<SIRFunction*> allocatedFuncs;
  size_t nFun = m->size();
  while (allocatedFuncs.size() < nFun) {
    for (SIRModule::iterator it = m->begin(); it != m->end(); ++it) {
      SIRFunction* func = *it;
      if (IsElementOf(func, allocatedFuncs) ) { continue; }
      if (!CalleesAllocated(func, allocatedFuncs) ) { continue; }
      ES_LOG_P(logLv_, log_, "======== Allocate registers for "
               << func->GetName() <<" ==========\n");
      change |= RunOnSIRFunction(*it);
      ES_LOG_P(logLv_, log_, "======== "<< func->GetName()
               <<" allocated ==========\n");
      allocatedFuncs.insert(*it);
    }
  }// while (allocatedFuncs.size() < nFun)
  return change;
}// BaselineFuncRegAllocPass::RunOnSIRModule()

