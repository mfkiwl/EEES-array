#include "BaselineCodeGenEngine.hh"
#include "BaselineBlockData.hh"
#include "BaselineInstrData.hh"
#include "BaselineBasicInfo.hh"
#include "Target/DataDependencyGraph.hh"
#include "Target/TargetIssuePacket.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"
#include "llvm/Support/Casting.h"

using namespace std;
using namespace ES_SIMD;

static int
BlockPaddingCost(SIRBasicBlock* bb) {
  int c = 1;
  for (int i = 0, e = bb->GetLoopDepth(); i < e; ++i) { c = c*10; }
  return c;
}

static void
PadBefore(int padding, BaselineBlockData* bData, SIRBasicBlock* bb) {
  for (int i = 0; i < padding; ++i) {
    bData->InsertNOPBefore(bData->begin());
  }// for i = 0 to padding-1
}// PadBefore()

static void
PadAfter(int padding, int pePad, BaselineBlockData* bData, SIRBasicBlock* bb,
         bool dbg, ostream& dbgs) {
  BaselineBlockData::iterator padIt = bData->end();
  if (bData->size() >= 2) {
    BaselineBlockData::iterator lastIt = bData->end();
    BaselineBlockData::iterator pIt = --lastIt; --pIt;
    if ((*pIt)->HasBranch()) {
      SIRInstruction *c = (*lastIt)->GetInstr(BaselineBasicInfo::CP);
      SIRInstruction *v0 = (*pIt)->GetInstr(BaselineBasicInfo::PE),
        *v1 = (*lastIt)->GetInstr(BaselineBasicInfo::PE);
      bool isCoupled = false;
      if (c && v1) {
        // Check if C and V1 have to be in the same cycle
        BaselineInstrData* cData
          = dynamic_cast<BaselineInstrData*>(c->GetTargetData());
        isCoupled = (cData->GetCommProducer() == v1)
          || (cData->GetCommConsumer() == v1);
      }
      // The following sequence:
      //      Branch ||  V0
      //        C    ||  V1
      //
      // should be transformed to:
      //         (Not coupled)               (coupled)
      //        C    ||  V0        or     NOP    ||  V0
      //      Branch ||  V1                C     ||  V1
      //             NOP                 Branch  ||  NOP
      //                                         NOP
      if (!isCoupled) {
        if (c)  { (*lastIt)->RemoveInstr(c);  }
        if (v0) { (*pIt)->RemoveInstr(v0);    }
        if (v1) { (*lastIt)->RemoveInstr(v1); }

        if (c)  { bData->InsertBeforeWithTimingCheck(pIt, c);  }
        if (pePad > 1) {
          if (v1) { bData->InsertBeforeWithTimingCheck(pIt, v1); }
          if (v0) { bData->InsertBeforeWithTimingCheck(pIt, v0); }
          pePad -= 2;
        } else {
          if (v0) { bData->InsertBeforeWithTimingCheck(pIt, v0); }
          if (v1) { (*pIt)->SetInstr(v1, 1); }
          pePad -= 1;
        }
      } else {// if (isCoupled)
        if (c)  { (*lastIt)->RemoveInstr(c);  }
        if (v0) { (*pIt)->RemoveInstr(v0);    }
        if (v1) { (*lastIt)->RemoveInstr(v1); }

        if (c)  { bData->InsertBeforeWithTimingCheck(pIt, c);  }
        if (v1) { bData->InsertBeforeWithTimingCheck(pIt, v1); }
        BaselineBlockData::iterator vIt = pIt; --vIt;
        if (v0) { bData->InsertBeforeWithTimingCheck(vIt, v0); }
        pePad -= 2;
      }// if (isCoupled)
      bData->InitIssueTime();
      padding -= 2;
      if ((padding <= 0) && (pePad <= 0)) { return; }
      padIt = pIt;
      padding = max(pePad, padding);
    }// if ((*pIt)->HasBranch())
  }// if (!bData->empty())
  for (int i = 0; i < padding; ++i) { bData->InsertNOPBefore(padIt); }
}// PadBefore()

static int
CountValueJointPoint(SIRInstruction* instr, int threshold, SIRBasicBlock* bb) {
  int iVal = instr->GetValueID();
  if (!bb->IsValueLiveOut(iVal)) { return 0; }
  int jp = 0;
  for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
       sIt != bb->succ_end(); ++sIt) {
    int ut = (*sIt)->GetTargetData()->ValueFirstUsedTime(iVal);
    if ((ut >=0) && (ut < threshold)) { ++jp; }
  }
  return jp;
}// CountValueJointPoint()


/// Check if v is only defined in pred
static bool LiveInOneBlock(int v, SIRBasicBlock* pred, SIRBasicBlock* bb) {
  if (!pred->IsValueLiveOut(v) || !bb->IsPredecessor(pred)) { return false; }
  for (SIRBasicBlock::pred_iterator pIt = bb->pred_begin();
       pIt != bb->pred_end(); ++pIt) {
    if (((*pIt) != pred) && (*pIt)->IsValueLiveOut(v)) { return false; }
  }
  return true;
}

/// First element is the value, second element is its distance to the end.
typedef pair<SIRInstruction*, int> JointPointValue;

/// Get the number of possible cross block bypass
static unsigned
CountCrossBlockBypass(vector<JointPointValue>& jp, int threshold,
                      SIRBasicBlock* bb, bool dbg, ostream& dbgs) {
  unsigned bypass = 0;
  for (int i=0, e=jp.size(); i < e; ++i) {
    SIRInstruction* instr = jp[i].first;
    int t = jp[i].second;
    int iVal = instr->GetValueID();
    bool b = true;
    int u = 0;
    for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
         sIt != bb->succ_end(); ++sIt) {
      SIRBasicBlock* sbb = *sIt;
      if (!sbb->IsValueLiveIn(iVal)) { continue; }
      int ut = sbb->GetTargetData()->ValueFirstUsedTime(iVal);
      if (ut < 0) { continue; }
      ++u;
      if ((t+ut) < threshold) {
        // Joint-point issue, check if bb is the only source.
        // If so, cross-block bypass is possible.
        if (!LiveInOneBlock(iVal, bb, sbb)) { b = false; }
        else { }
      }// if ((t+ut) < threshold)
    }
    if (u && b) { ++bypass; }
  }// for i = 0 to jp.size()-1
  return bypass;
}// CheckCrossBlockBypass()

static void
BaselineFixBlockLiveOutJointPoints (
  SIRBasicBlock* bb, const BaselineBasicInfo& tgt, bool dbg, ostream& dbgs) {
  if (!tgt.IsCPExplicitBypass() && !tgt.IsPEExplicitBypass()) { return; }
  int cpThreshold = tgt.IsCPExplicitBypass() ? (tgt.GetCPNumStages() - 3) : 0;
  int peThreshold = tgt.IsPEExplicitBypass() ? (tgt.GetPENumStages() - 3) : 0;
  BaselineBlockData* bData
    = dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
  bData->InitIssueTime();
  if (bData->empty()) { return; }
  vector<SIRInstruction*> cpLOVals(cpThreshold, NULL);
  vector<SIRInstruction*> peLOVals(peThreshold, NULL);
  vector<JointPointValue> cpJPVals, peJPVals;
  int bbLen = bData->back()->IssueTime();
  int thres = max(cpThreshold, peThreshold);
  int maxPad = 0, cpPad = 0, pePad = 0;
  for (BaselineBlockData::reverse_iterator pIt = bData->rbegin();
       pIt != bData->rend(); ++pIt) {
    TargetIssuePacket* packet = *pIt;
    int t = bbLen - packet->IssueTime();
    if (t > thres) { break; }
    if (t < cpThreshold) {
      if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::CP)) {
        int val = instr->GetValueID();
        if (bb->IsValueLiveOut(val)) { cpLOVals[t] = instr; }
        if (CountValueJointPoint(instr, cpThreshold-t, bb)) {
          cpJPVals.push_back(make_pair(instr, t));
          maxPad = max(maxPad, cpThreshold-t);
          cpPad  = max(cpPad,  cpThreshold-t);
        }
      }
    }// if (t < cpThreshold)
    if (t < peThreshold) {
      if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::PE)) {
        int val = instr->GetValueID();
        if (bb->IsValueLiveOut(val)) { peLOVals[t] = instr; }
        if (CountValueJointPoint(instr, peThreshold-t, bb)) {
          peJPVals.push_back(make_pair(instr, t));
          maxPad = max(maxPad, peThreshold-t);
          pePad  = max(pePad,  peThreshold-t);
        }
      }// if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::PE))
    }// if (t < peThreshold)
  }// for bData reverse_iterator pIt
  if (!maxPad) { return; }
  if (CountCrossBlockBypass(cpJPVals, cpThreshold, bb, true, dbgs)
      == cpJPVals.size()) {}
  // Check how many actual joint-point cases are there
  int pad = 0;
  int succCost = 0;
  for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
       sIt != bb->succ_end(); ++sIt) {
    SIRBasicBlock* sbb = *sIt;
    BaselineBlockData* sData
      = dynamic_cast<BaselineBlockData*>(sbb->GetTargetData());
    int spad = 0;
    for (int i = 0; i < cpThreshold; ++i) {
      if (SIRValue* loVal = cpLOVals[i]) {
        int ut = sData->ValueFirstUsedTime(loVal->GetValueID());
        if (ut >= 0) { spad = max(cpThreshold - (ut + i), spad); }
      }
    }
    for (int i = 0; i < peThreshold; ++i) {
      if (SIRValue* loVal = peLOVals[i]) {
        int ut = sData->ValueFirstUsedTime(loVal->GetValueID());
        if (ut >= 0) { spad = max(peThreshold - (ut + i), spad); }
      }
    }
    succCost += BlockPaddingCost(sbb) * spad;
    pad = max(spad, pad);
  }// for bb succ_iterator sIt
  int bbCost = BlockPaddingCost(bb)
    * (bb->HasBranch() ? max(1, maxPad-2) : maxPad);
  if (bbCost < succCost) {
    ES_LOG_P(dbg, dbgs, "-->> Pad "<< maxPad <<" at the end of "
               <<bb->GetParent()->GetName()<<".B"<< bb->GetBasicBlockID()<<'\n');
    PadAfter(maxPad, pePad, bData, bb, dbg, dbgs);
    return;
  }

  // Pad the successor blocks
  for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
       sIt != bb->succ_end(); ++sIt) {
    SIRBasicBlock* sbb = *sIt;
    BaselineBlockData* sData
      = dynamic_cast<BaselineBlockData*>(sbb->GetTargetData());
    int spad = 0;
    for (int i = 0; i < cpThreshold; ++i) {
      if (SIRValue* loVal = cpLOVals[i]) {
        int ut = sData->ValueFirstUsedTime(loVal->GetValueID());
        if (ut >= 0) { spad = max(cpThreshold - (ut + i), spad); }
      }
    }
    for (int i = 0; i < peThreshold; ++i) {
      if (SIRValue* loVal = peLOVals[i]) {
        int ut = sData->ValueFirstUsedTime(loVal->GetValueID());
        if (ut >= 0) { spad = max(peThreshold - (ut + i), spad); }
      }
    }
    if (spad > 0) {
      ES_LOG_P(dbg, dbgs, "-->> Pad "<< spad <<" at the beginning of "
               <<bb->GetParent()->GetName()<<".B"<<sbb->GetBasicBlockID()<<'\n');
      PadBefore(spad, sData, sbb); sData->InitIssueTime();
    }
  }// for bb succ_iterator sIt
}// BaselineFixBlockLiveOutJointPoints()

void ES_SIMD::
BaselineFixJointPoints(
  SIRFunction* func, const BaselineBasicInfo& tgt, bool dbg, ostream& dbgs) {
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    (*bIt)->GetTargetData()->InitIssueTime();
  }
  IntSet fixedBlocks;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    if (!IsElementOf((*bIt)->GetBasicBlockID(), fixedBlocks)) {
      BaselineFixBlockLiveOutJointPoints(*bIt, tgt, dbg, dbgs);
      fixedBlocks.insert((*bIt)->GetBasicBlockID());
    }
  }
}// BaselineFixJointPoints()
