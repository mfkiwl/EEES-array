#include "BaselineCodeGenEngine.hh"
#include "BaselineInstrData.hh"
#include "BaselineBlockData.hh"
#include "BaselineBasicInfo.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "Target/TargetIssuePacket.hh"
#include "Target/TargetFuncData.hh"
#include "Target/TargetFuncRegAllocInfo.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/LogUtils.hh"
#include "llvm/Support/Casting.h"

using namespace std;
using namespace ES_SIMD;

static int
GetBypassID(const SIRInstruction* instr, const BaselineBasicInfo& target) {
  return instr->IsVectorInstr() ?
    target.GetPEOperationBinding(instr->GetTargetOpcode())
    : target.GetCPOperationBinding(instr->GetTargetOpcode());
}// GetBypassID()

static int GetInstrLastUse(SIRInstruction* instr) {
  int lastUse = -1;
  for (SIRValue::use_iterator uIt = instr->use_begin();
       uIt != instr->use_end(); ++uIt) {
    if (llvm::isa<SIRInstruction>(*uIt)) {
      SIRInstruction* user = llvm::cast<SIRInstruction>(*uIt);
      if (user->GetParent() != instr->GetParent()) { continue; }
      int ut = dynamic_cast<BaselineInstrData*>(user->GetTargetData())
        ->GetIssueTime();
      ES_ASSERT_MSG(ut >= 0, "Instruction (BB"
                    << instr->GetParent()->GetBasicBlockID() <<":"<< *user
                    <<") not scheduled");
      lastUse = max(ut, lastUse);
    }// if (llvm::isa<SIRInstruction>(*uIt))
  }// for instr use_iterator uIt
  return lastUse;
}// GetInstrLastUse()

// Find the time of the last use of each value
static void FindLastUse(SIRBasicBlock* bb, Int2IntMap& lastUse) {
  BaselineBlockData* bData = dynamic_cast<BaselineBlockData*>(
    bb->GetTargetData());
  for (BaselineBlockData::iterator pIt = bData->begin();
       pIt != bData->end(); ++pIt) {
    TargetIssuePacket* packet = *pIt;
    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::CP)) {
      int val = instr->GetValueID();
      if (SIRFunction::IsValidValueID(val)) {
        int lu = GetInstrLastUse(instr);
        if (lu >= 0) { lastUse[val] = lu; }
      }// if (SIRFunction::IsValidValueID(val))
    }// if (SIRInstruction* instr = packet->GetCPInstr())
    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::PE)) {
      int val = instr->GetValueID();
      if (SIRFunction::IsValidValueID(val)) {
        int lu = GetInstrLastUse(instr);
        if (lu >= 0) { lastUse[val] = lu; }
      }// if (SIRFunction::IsValidValueID(val))
    }// if (SIRInstruction* instr = packet->GetPEInstr())
  }// for bData iterator pIt
}// FindLastUse()

static int
GetExitFUTime(BaselineBlockData::iterator it, BaselineBlockData& bData,
              bool vect, const BaselineBasicInfo& target) {
  SIRInstruction* instr = (*it)->GetInstr(vect);
  if (!instr) { return bData.size(); }
  int binding = GetBypassID(instr, target);
  int nStage = vect ? target.GetPENumStages() : target.GetCPNumStages();
  int delay = ((nStage == 5) && (binding == 0)) ? 1 : 0;
  for (++it; it != bData.end(); ++it) {
    if (SIRInstruction* nInstr = (*it)->GetInstr(vect)) {
      if ((GetBypassID(nInstr, target) == binding)
          && !IsTargetStore(nInstr->GetTargetOpcode())) {
        BaselineInstrData* nData
          = dynamic_cast<BaselineInstrData*>(nInstr->GetTargetData());
        return nData->GetIssueTime() + nData->GetLatency() + delay;
      }
    }// if (SIRInstruction* nInstr = (*nIt)->GetInstr(vect))
  }// for bData iterator it
  return bData.size();
}// GetExitFUTime()

static int
GetRetireTime(BaselineBlockData::iterator it, BaselineBlockData& bData,
              bool vect, const BaselineBasicInfo& target, const IntSet& wbVals){
  SIRInstruction* instr = (*it)->GetInstr(vect);
  int wbDelay = (vect ? target.GetPENumStages() : target.GetCPNumStages()) - 2;
  if (!instr) { return bData.size(); }

  for (++it; it != bData.end(); ++it) {
    if (SIRInstruction* nInstr = (*it)->GetInstr(vect)) {
      int nVal = nInstr->GetValueID();
      if (SIRFunction::IsValidValueID(nVal) && IsElementOf(nVal, wbVals)) {
        BaselineInstrData* nData
          = dynamic_cast<BaselineInstrData*>(nInstr->GetTargetData());
        return nData->GetIssueTime() + wbDelay;
      }
    }// if (SIRInstruction* nInstr = (*nIt)->GetCPInstr())
  }// for bData iterator nIt
  return bData.size();
}// GetRetireTime()

static bool
CheckAndSetNoWB(SIRInstruction* instr, const BaselineBasicInfo& target,
                const Int2IntMap& exitFUTime, const IntSet& liveOuts) {
  bool noWB = true;
  BaselineInstrData* iData
    = dynamic_cast<BaselineInstrData*>(instr->GetTargetData());
  int exitTime  = GetValue(instr->GetUID(), exitFUTime);
  int availTime = iData->GetIssueTime() + iData->GetLatency();
  int binding = GetBypassID(instr, target);
  int bid = instr->GetParent()->GetBasicBlockID();
  int iVal = instr->GetValueID();
  int stages = instr->IsVectorInstr() ?
    target.GetPENumStages() : target.GetCPNumStages();
  if (IsElementOf(iVal, liveOuts)) {
    iData->SetToWriteback(true);
    iData->SetToRF(true);
  }
  for (SIRValue::use_iterator uIt = instr->use_begin();
       uIt != instr->use_end(); ++uIt) {
    if (SIRInstruction* u = dynamic_cast<SIRInstruction*>(*uIt)) {
      if (u->GetParent()->GetBasicBlockID() != bid) { continue; }
      BaselineInstrData* uData = dynamic_cast<BaselineInstrData*>(
        u->GetTargetData());
      int ut = uData->GetIssueTime();
      if (!((ut>=availTime) || (uData->IsBroadcastedValue(iVal))
            || (iData->GetCommConsumer() == u))) {
        for (BaselineBlockData::iterator it = instr->GetParent()->GetTargetData()->begin();
             it != instr->GetParent()->GetTargetData()->end(); ++it) {
          cerr <<(*it)->IssueTime() <<": ";(*it)->ValuePrint(cerr);
          cerr <<'\n';
        }
      }
      ES_ASSERT_MSG((ut>=availTime) || (uData->IsBroadcastedValue(iVal))
                    || (iData->GetCommConsumer() == u),
                    "V_"<< iVal <<" ("<< *instr <<") used at "<< ut
                    <<" before available at "<< availTime<<" in "
                    <<instr->GetParent()->GetParent()->GetName() <<".B"<< bid);
      bool force = (instr->HasPredicate() && !instr->PredicateValueEqual(u));
      if ((ut < exitTime) && !force) {
        int bypassID = binding;
        if ((stages == 5) && (binding == 0) && (ut > availTime)) {bypassID = 3;}
        // The value is available at FU output port
        for (unsigned i = 0, e = u->operand_size(); i < e; ++i) {
          if (u->GetOperand(i)->GetValueID() == iVal) {
            uData->SetOperandBypass(i, bypassID);
          }
        }
      } else { noWB = false; }// if (ut < exitTime)
    }// if (SIRInstruction* u = dynamic_cast<SIRInstruction*>(*uIt))
  }// for instr use_iterator uIt
  if (noWB && !IsElementOf(iVal, liveOuts)) {
    iData->SetToWriteback(false);
    iData->SetToRF(false);
    return true;
  }
  iData->SetToWriteback(true);
  return false;
}// CheckAndSetNoWB()

static bool
CheckAndSetNoRF(SIRInstruction* instr, int retireTime,  int wb,
                const BaselineBasicInfo& target, const IntSet& wbValues,
                const Int2IntMap& exitFUTime, const IntSet& liveOuts) {
  int iVal = instr->GetValueID();
  int bid = instr->GetParent()->GetBasicBlockID();
  if (SIRFunction::IsValidValueID(instr->GetValueID())) {
    if (!IsElementOf(iVal, wbValues)) { return false; }
    BaselineInstrData* iData = dynamic_cast<BaselineInstrData*>(
      instr->GetTargetData());
    int exitTime = GetValue(instr->GetUID(), exitFUTime);
    bool noRF = true;
    for (SIRValue::use_iterator uIt = instr->use_begin();
         uIt != instr->use_end(); ++uIt) {
      if (SIRInstruction* u = dynamic_cast<SIRInstruction*>(*uIt)) {
        if (u->GetParent()->GetBasicBlockID() != bid) { continue; }
        BaselineInstrData* uData = dynamic_cast<BaselineInstrData*>(
          u->GetTargetData());
        int ut = uData->GetIssueTime();
        bool force = (instr->HasPredicate() && !instr->PredicateValueEqual(u));
        if ((ut >= exitTime) && (ut < retireTime) && !force) {
          // The value is available at WB stage
          for (unsigned i = 0, e = u->operand_size(); i < e; ++i) {
            if (u->GetOperand(i)->GetValueID() == iVal) {
              uData->SetOperandBypass(i, wb);
            }
          }
        } else if ((ut >= retireTime)|| force){
          /// FIXME: if somehow bypass is cancled, the value may not have a
          ///        valid physical register.
          noRF = false;
          for (unsigned i = 0, e = u->operand_size(); i < e; ++i) {
            if (u->GetOperand(i)->GetValueID() == iVal) {
              uData->SetOperandBypass(i, -1);
            }
          }
        }// if (ut > retireTime)
      }// if (SIRInstruction* u = dynamic_cast<SIRInstruction*>(*uIt))
    }// for instr use_iterator uIt
    if (!noRF) {
      iData->SetToWriteback(true);
      iData->SetToRF(true);
      return true;
    } else if (!IsElementOf(iVal, liveOuts)) {
      iData->SetToRF(false);
      return false;
    }
  }// if (SIRFunction::IsValidValueID(instr->GetValueID()))
  return false;
}// CheckAndSetNoRF()

void ES_SIMD::
SetBaselineBlockBypass(SIRBasicBlock* bb, const BaselineBasicInfo& target,
                       bool dbg, ostream& dbgs) {
  bool cpBypass = target.IsCPExplicitBypass();
  bool peBypass = target.IsPEExplicitBypass();
  if (!cpBypass && !peBypass) { return; }
  ES_LOG_P(dbg, dbgs, "- Setting BB"<< bb->GetBasicBlockID()<<" bypass state\n");
  if (dbg) { bb->GetTargetData()->ValuePrint(dbgs); }
  Int2IntMap lastUse;
  Int2IntMap exitFUTime;
  ES_LOG_P(dbg, dbgs, "-- Calculating last use of each value\n");
  FindLastUse(bb, lastUse);
  IntSet liveOuts;
  for (SIRBasicBlock::lo_iterator it=bb->lo_begin(); it != bb->lo_end(); ++it) {
    liveOuts.insert((*it)->GetValueID());
  }
  int cpWB  = (target.GetCPNumStages() == 5)  ? 4 : 3;
  int peWB  = (target.GetPENumStages() == 5)  ? 4 : 3;
  BaselineBlockData& bData
      = *dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
  bData.InitIssueTime();

  // First pass: get the time when the value is pushed out of the FU
  for (BaselineBlockData::iterator pIt=bData.begin();pIt != bData.end();++pIt) {
    TargetIssuePacket* packet = *pIt;
    if (cpBypass) {
      if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::CP)) {
        if (SIRFunction::IsValidValueID(instr->GetValueID())) {
          exitFUTime[instr->GetUID()]= GetExitFUTime(pIt, bData, false, target);
          ES_LOG_P(dbg, dbgs, ">> CP: V_"<< instr->GetValueID()
                   <<" issued at "<< instr->GetTargetData()->GetIssueTime()
                   <<", avail at "<< (instr->GetTargetData()->GetIssueTime()
                                      + instr->GetTargetData()->GetLatency())
                   <<", exits FU at "<< exitFUTime[instr->GetUID()]<<'\n');
        }// if (SIRFunction::IsValidValueID(instr->GetValueID()))
      }// if (SIRInstruction* instr = packet->GetCPInstr())
    }// if (cpBypass)

    if (peBypass) {
      if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::PE)) {
        if (SIRFunction::IsValidValueID(instr->GetValueID())) {
          exitFUTime[instr->GetUID()] = GetExitFUTime(pIt, bData, true, target);
          ES_LOG_P(dbg, dbgs, ">> PE: V_"<< instr->GetValueID()
                   <<" issued at "<< instr->GetTargetData()->GetIssueTime()
                   <<", avail at "<< (instr->GetTargetData()->GetIssueTime()
                                      + instr->GetTargetData()->GetLatency())
                   <<", exits FU at "<< exitFUTime[instr->GetUID()]<<'\n');
        }// if (SIRFunction::IsValidValueID(instr->GetValueID()))
      }// if (SIRInstruction* instr = packet->GetPEInstr())
    }// if (peBypass)
  }// for bData iterator pIt

  // Second pass: mark the values that doesn't need to go to WB stage
  IntSet wbValues; // Values put in this set may go to WB and RF
  for (BaselineBlockData::iterator pIt=bData.begin();pIt != bData.end();++pIt) {
    TargetIssuePacket* packet = *pIt;
    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::CP)) {
      int iVal = instr->GetValueID();
      if (SIRFunction::IsValidValueID(instr->GetValueID())) {
        if (!CheckAndSetNoWB(instr, target, exitFUTime, liveOuts)) {
          wbValues.insert(iVal);
          ES_LOG_P(dbg, dbgs, ">> Needs CP WB: V_"<< iVal<<'\n');
        }
      }// if (SIRFunction::IsValidValueID(instr->GetValueID()))
    }// if (SIRInstruction* instr = packet->GetCPInstr())

    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::PE)) {
      int iVal = instr->GetValueID();
      if (SIRFunction::IsValidValueID(instr->GetValueID())) {
        if (!CheckAndSetNoWB(instr, target, exitFUTime, liveOuts)) {
          wbValues.insert(iVal);
          ES_LOG_P(dbg, dbgs, ">> Needs PE WB: V_"<< iVal<<'\n');
        }
      }// if (SIRFunction::IsValidValueID(instr->GetValueID()))
    }// if (SIRInstruction* instr = packet->GetPEInstr())
  }// // for bData iterator pIt

  // Third pass: mark the values that doesn't need to go to RF
  Int2IntMap retireTime;// Time when a value no longer in bypass network
  for (BaselineBlockData::iterator pIt=bData.begin();pIt != bData.end();++pIt) {
    TargetIssuePacket* packet = *pIt;
    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::CP)) {
      int iVal = instr->GetValueID();
      if (SIRFunction::IsValidValueID(instr->GetValueID())) {
        if (IsElementOf(iVal, wbValues)) {
          int retireTime = GetRetireTime(pIt, bData, false, target, wbValues);
          bool r = CheckAndSetNoRF(instr, retireTime,  cpWB, target, wbValues,
                                   exitFUTime, liveOuts);
          ES_LOG_P(dbg && r, dbgs, ">> To CP RF: V_"<< iVal <<" (retire="<<
                   retireTime <<")\n");
        }
      }
    }// if (SIRInstruction* instr = packet->GetCPInstr())

    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::PE)) {
      int iVal = instr->GetValueID();
      if (SIRFunction::IsValidValueID(instr->GetValueID())) {
        if (!IsElementOf(iVal, wbValues)) { continue; }
        int retireTime = GetRetireTime(pIt, bData, true, target, wbValues);
        bool r = CheckAndSetNoRF(instr, retireTime,  peWB, target, wbValues,
                        exitFUTime, liveOuts);
        ES_LOG_P(dbg && r, dbgs, ">> To PE RF: V_"<< iVal<<" (retire="<<
                 retireTime <<")\n");
      }// if (SIRFunction::IsValidValueID(instr->GetValueID()))
    }// if (SIRInstruction* instr = packet->GetPEInstr())
  }// // for bData iterator pIt
}// SetBaselineBlockBypass()
