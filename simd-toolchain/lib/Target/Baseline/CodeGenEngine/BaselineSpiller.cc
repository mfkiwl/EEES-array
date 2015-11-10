#include "BaselineCodeGenEngine.hh"
#include "BaselineRegAlloc.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineInstrData.hh"
#include "BaselineBlockData.hh"
#include "BaselineFuncData.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetModuleData.hh"
#include "Target/TargetIssuePacket.hh"
#include "Target/RegAlloc.hh"
#include "Target/TargetFuncRegAllocInfo.hh"
#include "Target/InterferenceGraph.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/LogUtils.hh"

using namespace std;
using namespace ES_SIMD;

struct SpillCandidate {
  int   value_;
  float cost_;
  bool operator<(const SpillCandidate& rhs) const { return cost_ < rhs.cost_; }
  SpillCandidate(int v, float c) : value_(v), cost_(c) {}
  SpillCandidate() {}
};// struct SpillCandidate

// Just change the reg operand to long immediate, the immediate instruction
// will be inserted by InsertImm
static void
RematImm(SIRInstruction* instr, int reg, SIRConstant* imm) {
  if (!instr || !instr->UsesValue(reg)) { return; }
  for (SIRInstruction::operand_reverse_iterator oIt = instr->operand_rbegin();
       oIt != instr->operand_rend(); ++oIt) {
    if ((*oIt) && ((*oIt)->GetValueID()==reg)){instr->ReplaceOperand(*oIt,imm);}
  }
}// RematImm()

static int
SpillBlockImmReg(SIRBasicBlock* bb, int reg, int val) {
  int rm = 0;
  BaselineBlockData& bData
    = *dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
  SIRConstant* imm = bb->GetParent()->GetParent()->AddOrGetImmediate(val);
  for (BaselineBlockData::iterator pIt = bData.begin(); pIt != bData.end();) {
    bool isNOP = (*pIt)->IsNOP();
    if (SIRInstruction* instr = (*pIt)->GetInstr(BaselineBasicInfo::CP)) {
      RematImm(instr, reg, imm);
      if (instr->GetValueID() == reg) { (*pIt)->RemoveInstr(instr); }
    }
    if (SIRInstruction* instr = (*pIt)->GetInstr(BaselineBasicInfo::PE)) {
      RematImm(instr, reg, imm);
      if (instr->GetValueID() == reg) { (*pIt)->RemoveInstr(instr); }
    }
    if (!isNOP && (*pIt)->IsNOP()) { pIt = bData.erase(pIt); ++rm; }
    else { ++pIt; }
  }// for bData iterator pIt
  bData.InitIssueTime();
  return rm;
}// SpillBlockImmReg()

static int SpillFuncImmReg(SIRFunction* func, int ireg, int ival) {
  int rm = 0;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    rm += SpillBlockImmReg(*bIt, ireg, ival);
  }
  return rm;
}// SpillFuncImmReg()

static void
InsertSpillStore(SIRFunction* func, int val, bool vect,
                 map<SIRInstruction*, int>& spillValues,
                 const BaselineBasicInfo& target, bool dbg,ostream& dbgs) {
  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  TargetFuncRegAllocInfo* raInfo = func->GetTargetData()->GetRegAllocInfo();
  int slotIdx = raInfo->GetSpillSlotIndex(val, vect);
  int so = fData->GetSpillSlotOffset(slotIdx, vect);
  SIRConstant* offset = func->GetParent()->AddOrGetImmediate(so);
  // Check if we are spilling an argument
  if (func->IsArgumentValue(val)) {
    raInfo->AddSpilledArg(val, so);
    // store->AddOperand(func->GetArgumentFromValue(val));
  }// if (func->IsArgumentValue(val))
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    BaselineBlockData& bData
      = *dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
    for (BaselineBlockData::iterator pIt = bData.begin();
         pIt != bData.end(); ++pIt) {
      SIRInstruction* instr = (*pIt)->GetInstr(vect);
      if (!instr || (instr->GetValueID() != val)) { continue; }
      int newVal = func->AllocateValue();
      raInfo->SetValueRegClass(newVal, vect);
      raInfo->AddSpillTempValue(newVal, val);
      raInfo->AddNonSpillValue(newVal);
      raInfo->SetValueRegClass(newVal, vect);
      spillValues[instr] = newVal;
      SIRInstruction* store = new SIRInstruction(TargetOpcode::SW, bb, vect);
      store->AddOperand(func->GetStackPointer());
      store->AddOperand(instr);
      store->AddOperand(offset);
      func->GetParent()->GetTargetData()->InitTargetData(store);
      // Now insert store to the block
      //// First check if we are in branch delay slot
      bool delaySlot = bData.IsBranchDelaySlot(pIt);
      if (!delaySlot) {
        BaselineBlockData::iterator insIt = pIt, tIt = pIt;
        int pad = fData->GetTarget().GetOperationLatency(instr) - 1;
        for (int i = 0; i < pad; ++i) {
          // If padding is required, we may also run into delay slot;
          ++tIt;
          bool pDelaySlot = bData.IsBranchDelaySlot(tIt);
          ES_ASSERT_MSG(!pDelaySlot, "not implementted yet");
          if (tIt == bData.end()) { bData.InsertNOPBefore(bData.end()); }
          ++insIt;
        }
        bData.InsertAfter(insIt, store);
      } else {// if (!delaySlot)
        if (!vect) {
          // Here we need to move the instruction in delay slot in front of
          // the branch.
          // NOTE: we don't check for timing because the maximum latency is 2,
          //       which is alway satisfied in this case. If the maximum latency
          //       increases, the implementation should be changed.
          BaselineBlockData::iterator brIt = pIt; --brIt;
          bData.InsertBefore(brIt, instr);
          (*pIt)->SetInstr(store, vect);
          bData.InitIssueTime();
          // We move the instruction in the delay slot up, so check if there is
          // sufficient distance between production and consumption.
          int ct = instr->GetTargetData()->GetIssueTime(), cPadding = 0;
          for (int i = 0, e= instr->operand_size(); i < e; ++i) {
            if (SIRInstruction* o
                = dynamic_cast<SIRInstruction*>(instr->GetOperand(i))) {
              if (o->GetParent() == bb) {
                int s = ct - o->GetTargetData()->GetIssueTime();
                int l = o->GetTargetData()->GetLatency();
                if (s < l) { cPadding = max(cPadding, l-s); }
              }// if (o->GetParent() == bb)
            }// if (SIRInstruction* o=dynamic_cast<SIRInstruction*>(c->GetOperand(i)))
          }// for i = 0 to c->operand_size()-1
          BaselineBlockData::iterator cIt = brIt; --cIt;
          for (int i = 0; i < cPadding; ++i) { bData.InsertNOPBefore(cIt); }
        } else { ES_ASSERT_MSG(false, "not implemented yet"); }
      }// if (!delaySlot) else
      ES_LOG_P(dbg, dbgs, "Spill store V_"<< val << "->V_"<< newVal<<"\n");
      // pIt = ++insIt; ++pIt;
    }// bData iterator pIt
    bData.InitIssueTime();
  }// for func iterator bIt
}// InsertSpillStore()

static void
InsertSpillReload(SIRFunction* func,int val,bool vect,
                  const BaselineBasicInfo& target, bool dbg,ostream& dbgs) {
  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  TargetFuncRegAllocInfo* raInfo = func->GetTargetData()->GetRegAllocInfo();
  int slotIdx = raInfo->GetSpillSlotIndex(val, vect);
  int so = fData->GetSpillSlotOffset(slotIdx, vect);
  SIRConstant* offset = func->GetParent()->AddOrGetImmediate(so);
  unsigned lat = fData->GetLoadLatency(vect) - 1;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    BaselineBlockData& bData
      = *dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
    for (BaselineBlockData::iterator pIt = bData.begin();
         pIt != bData.end(); ++pIt) {
      SIRInstruction* instr = (*pIt)->GetInstr(vect);
      if (!instr || !(instr->UsesValue(val))) { continue; }
      // Skip stack load
      if (IsTargetStore(instr->GetTargetOpcode())
          && (instr->GetOperand(0)->GetValueID()
              == func->GetStackPointer()->GetValueID())) { continue; }
      int pt = (*pIt)->IssueTime();
      BaselineInstrData* iData = dynamic_cast<BaselineInstrData*>(
        instr->GetTargetData());
      bool skip = false;
      for (int i=0, e=instr->operand_size(); i < e; ++i) {
        if (SIRInstruction* prod
            = dynamic_cast<SIRInstruction*>(instr->GetOperand(i))) {
          if ((prod->GetValueID() == val) && (prod->GetParent() == bb)) {
            if (iData->GetOperandBypass(i) >= 0) { skip = true; }
            int at = prod->GetTargetData()->GetIssueTime()
              + target.GetOperationLatency(prod);
            if ((pt-at) <= static_cast<int>(lat)) { skip = true; }
          }
        }
      }// for i = 0 to instr->operand_size()-1
      if (skip) { continue; }
      SIRInstruction* reload = new SIRInstruction(TargetOpcode::LW, bb, vect);
      int newVal = func->AllocateValue();
      raInfo->SetValueRegClass(newVal, vect);
      raInfo->AddSpillTempValue(newVal, val);
      raInfo->AddNonSpillValue(newVal);
      reload->SetValueID(newVal);
      reload->AddOperand(func->GetStackPointer());
      reload->AddOperand(offset);
      func->GetParent()->GetTargetData()->InitTargetData(reload);
      for (SIRInstruction::operand_iterator oIt = instr->operand_begin();
           oIt != instr->operand_end(); ++oIt) {
        if ((*oIt)->GetValueID() == val) { instr->ReplaceOperand(*oIt,reload); }
      }
      for (unsigned i = 0; i < lat; ++i) {
        if (pIt == bData.begin()) { bData.InsertBefore(pIt, NULL); }
        --pIt;
      }
      if (bData.IsBranchDelaySlot(pIt)) { --pIt; }
      bData.InsertBefore(pIt, reload);
      ES_LOG_P(dbg, dbgs, "Spill reload V_"<< val << "->V_"<< newVal<<"\n");
    }// bData iterator pIt
    bData.InitIssueTime();
  }// for func iterator bIt
}// InsertSpillReload()

static void
InitSpillCandidate(
  vector<SpillCandidate>& candidates, const BitVector& spillCandidate,
  const BaselineFuncData* fData) {
  TargetFuncRegAllocInfo* raInfo = fData->GetRegAllocInfo();
  if (spillCandidate.any()) {
    candidates.reserve(spillCandidate.count());
    candidates.clear();
    for (unsigned i = 0; i < spillCandidate.size(); ++i) {
      if (spillCandidate[i] && !raInfo->IsValueSpilled(i)) {
        float avgCost = raInfo->GetSpillCost(i) / raInfo->ValueConflictCount(i);
        candidates.push_back(SpillCandidate(i, avgCost));
      }// if (cpSpillCandidate[i])
    }// for  i = 0 to vc-1
    sort(candidates.begin(), candidates.end());
  }// if (cpSpillCandidate.any())
}// InitSpillCandidate()

static bool
cmp_bdata_rpressure(const BaselineBlockData* lhs, const BaselineBlockData* rhs){
  return (lhs->PERegPressure() > rhs->PERegPressure()) ||
    (lhs->CPRegPressure() > rhs->CPRegPressure());
}

static unsigned
GetSpillCandidateIdx(const vector<SpillCandidate>& candidates,
                     const BaselineBlockData* bData, bool vector, unsigned s) {
  for (unsigned i = s; i < candidates.size(); ++i) {
    if (bData->IsSpillCandidate(candidates[i].value_, vector)) { return i; }
  }
  return 0;
}

bool ES_SIMD::
BaselineEarlyLiveIntervalSpill (
  SIRFunction* func, const BaselineBasicInfo& target, bool dbg, ostream& dbgs) {

  CalculateLiveIntervals(func, dbg, dbgs);
  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  TargetFuncRegAllocInfo* raInfo = func->GetTargetData()->GetRegAllocInfo();
  Int2IntMap& conflictCounter = raInfo->ConflictCounter();
  conflictCounter.clear();
  unsigned vc = func->GetNumValues(), cpConflicts = 0, peConflicts = 0;
  BitVector cpSpillCandidate(vc), peSpillCandidate(vc);
  vector<SpillCandidate> cpCandidates, peCandidates;
  const Int2IntMap& valueRegClassMap = raInfo->ValueRegClassMap();
  // R0 (ZERO) is not tracked by register allocator, so RF size should be
  // substracted by 1 here
  const unsigned cpRFSize = target.GetCPAvailPhyRegs().size() - 1;
  const unsigned peRFSize = target.GetCPAvailPhyRegs().size() - 1;
  fData->UpdateRegPressure();
  ES_LOG_P(dbg, dbgs, "CP pressure="
           << raInfo->GetRegPressure(BaselineBasicInfo::CP)
           <<", PE pressure="
           << raInfo->GetRegPressure(BaselineBasicInfo::PE)<<"\n");
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    BaselineBlockData& bData
      = *dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
    bData.MergeValConflicTo(conflictCounter);
    bData.GetSpillCandidates(cpSpillCandidate, peSpillCandidate,
                             raInfo->NonSpillVals(), valueRegClassMap, target);
    cpConflicts += bData.NumConflict(0);
    peConflicts += bData.NumConflict(1);
  }// for func iterator bIt
  InitSpillCandidate(cpCandidates, cpSpillCandidate, fData);
  InitSpillCandidate(peCandidates, peSpillCandidate, fData);
  if ((raInfo->GetRegPressure(BaselineBasicInfo::CP) <= cpRFSize)
      && (raInfo->GetRegPressure(BaselineBasicInfo::PE) <= peRFSize)) {
    return true;
  }
  if (!cpCandidates.empty()) {
    ES_LOG_P(dbg, dbgs, "CP can spill "<< cpSpillCandidate.count()
             <<" values (conflist = "<< cpConflicts <<"): {");
    for (unsigned i = 0; i < cpCandidates.size(); ++i) {
      SpillCandidate& sc = cpCandidates[i];
      ES_LOG_P(dbg, dbgs, sc.value_ <<":"<< raInfo->GetSpillCost(sc.value_) <<":"
               << raInfo->ValueConflictCount(sc.value_) <<"("<< sc.cost_ <<")");
      ES_LOG_P(dbg && raInfo->IsImmReg(sc.value_), dbgs, "<i>");
      ES_LOG_P(dbg, dbgs, ", ");
    }// for  i = 0 to vc-1
    ES_LOG_P(dbg, dbgs, "}\n");
  }// if (cpSpillCandidate.any())

  vector<BaselineBlockData*> spillBlocks;
  spillBlocks.reserve(func->size());
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    BaselineBlockData* bData
      = dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
    if ((bData->CPRegPressure()>cpRFSize)||(bData->PERegPressure()>peRFSize)){
      spillBlocks.push_back(bData);
    }
  }// for func iterator bIt
  sort(spillBlocks.begin(), spillBlocks.end(), cmp_bdata_rpressure);
  unsigned cpIdx = 0, peIdx = 0;
  const unsigned cpThreshold = cpRFSize;
  const unsigned peThreshold = peRFSize;
  while ((raInfo->GetRegPressure(BaselineBasicInfo::CP) > cpThreshold)
         || (raInfo->GetRegPressure(BaselineBasicInfo::PE) > peThreshold)) {
    for (unsigned i = 0; i < spillBlocks.size(); ++i) {
      BaselineBlockData* bData = spillBlocks[i];
      SIRBasicBlock* bb = bData->BasicBlock();
      ES_LOG_P(dbg, dbgs, func->GetName() <<".B"<< bb->GetBasicBlockID()
               <<" (P=["<< bData->CPRegPressure() <<", "
               << bData->PERegPressure()<<"]) needs spilling\n");
      if (bData->PERegPressure() > peThreshold) {
        peIdx = GetSpillCandidateIdx(peCandidates, bData, true, peIdx);
        SpillValue(func, peCandidates[peIdx].value_, true, dbg, dbgs);
        ++peIdx;
      }// if (bData->PERegPressure() > peThreshold)
      if (bData->CPRegPressure() > cpThreshold) {
        cpIdx = GetSpillCandidateIdx(cpCandidates, bData, false, cpIdx);
        SpillValue(func, cpCandidates[cpIdx].value_, false, dbg, dbgs);
        ES_LOG_P(dbg, dbgs, "Spilled "<< cpCandidates[cpIdx].value_
                 <<" in "<<func->GetName()<<".B"<< bb->GetBasicBlockID()<<"\n");
        ++cpIdx;
      }// if (bData->PERegPressure() > peThreshold)
      fData->UpdateRegPressure();
    }// for i = 0 to spillBlocks.size()-1
  }// while (needSpilling)
  ES_LOG_P(dbg, dbgs, "CP pressure="
           << raInfo->GetRegPressure(BaselineBasicInfo::CP)<<", PE pressure="
           << raInfo->GetRegPressure(BaselineBasicInfo::PE)<<"\n");
  return false;
}// BaselineEarlyLiveIntervalSpill()

void ES_SIMD::
SpillValue(SIRFunction* func, int val, bool vector, bool dbg, ostream& dbgs) {
  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  SIRModule* module = func->GetParent();
  TargetFuncRegAllocInfo* raInfo = fData->GetRegAllocInfo();
  map<SIRInstruction*, int> spillStoreValues;
  if (raInfo->IsImmReg(val)) {
    int ival = func->GetTargetData()->GetRegAllocInfo()->GetRegImmediate(val);
    SpillFuncImmReg(func, val, ival);
  } else if (func->IsConstPoolUser(val)
             && (module->GetConstReloadCost(func->GetConstPoolUserImm(val))<2)){
    if (SpillFuncImmReg(func, val, func->GetConstPoolUserImm(val))) {
      BaselineFixJointPoints(func, fData->GetTarget(), dbg, dbgs);
    }
  } else {
    InsertSpillStore (func, val, vector, spillStoreValues,
                      fData->GetTarget(), dbg, dbgs);
    /// NOTE: probably too excessive
    UpdateBaselineFuncBypass(func, fData->GetTarget(), false, dbgs);
    InsertSpillReload(func, val, vector, fData->GetTarget(), dbg, dbgs);
    for (map<SIRInstruction*, int>::iterator it = spillStoreValues.begin();
         it != spillStoreValues.end(); ++it) {
      it->first->SetValueID(it->second);
    }
  }
  raInfo->AddSpilledValue(val);
}// SpillValue()
