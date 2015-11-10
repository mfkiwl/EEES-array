#include "BaselineBlockData.hh"
#include "BaselineFuncData.hh"
#include "BaselineInstrData.hh"
#include "BaselineBasicInfo.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetModuleData.hh"
#include "Target/TargetIssuePacket.hh"
#include "Utils/BitUtils.hh"
#include "Utils/DbgUtils.hh"
#include "llvm/Support/Casting.h"

using namespace std;
using namespace ES_SIMD;

BaselineBlockData::
~BaselineBlockData() {
  for (iterator it = begin(); it != end(); ++it) {
    delete *it;
  }
}// ~BaselineBlockData()

bool BaselineBlockData::
IsBranchDelaySlot(iterator it) const {
  if (it != begin()) { --it; if ((*it)->HasBranch()) { return true; } }
  return false;
}

bool BaselineBlockData::
IsBranchDelaySlot(const_iterator it) const {
  if (it != begin()) { --it; if ((*it)->HasBranch()) { return true; } }
  return false;
}

void BaselineBlockData::
Reset() {
  liveIntervals_.clear();
  defs_.clear();
  uses_.clear();
  spillCost_.clear();
  valConflicts_.clear();
  regPressure_.resize(2);
  regPressure_[0] = regPressure_[1] = 0;
}// Reset()

void BaselineBlockData::
InitValueInfo() {
  defs_.clear();
  uses_.clear();
  baseSpillCost_ = pow(10.0f, bb_->GetLoopDepth());
  for (iterator pIt = begin(); pIt != end(); ++pIt) {
    TargetIssuePacket* packet = *pIt;
    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::CP)) {
      if (instr->GetValueID() >= 0) { defs_.insert(instr->GetValueID()); }
      for (SIRInstruction::operand_const_iterator oIt = instr->operand_begin();
           oIt != instr->operand_end(); ++oIt) {
        int ov = (*oIt)->GetValueID();
        if (SIRFunction::IsValidValueID(ov)) { uses_.insert(ov); }
      }// for instr->operand_const_iterator oIt
    }// if (SIRInstruction* instr = packet->GetCPInstr())
    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::PE)) {
      if (instr->GetValueID() >= 0) { defs_.insert(instr->GetValueID()); }
      for (SIRInstruction::operand_const_iterator oIt = instr->operand_begin();
           oIt != instr->operand_end(); ++oIt) {
        int ov = (*oIt)->GetValueID();
        if (SIRFunction::IsValidValueID(ov)) { uses_.insert(ov); }
      }// for instr->operand_const_iterator oIt
    }// if (SIRInstruction* instr = packet->GetPEInstr())
  }// for iterator pIt
}// InitValueInfo()

void BaselineBlockData::
CalculateRegPressure(
  const Int2IntMap& valueRegClassMap, const IntSet& spilledValues,
  const BaselineBasicInfo& target) {

  // R0 (ZERO) is not tracked by register allocator, so RF size should be
  // substracted by 1 here
  unsigned cpRFSize = target.GetCPAvailPhyRegs().size() - 1,
    peRFSize = target.GetCPAvailPhyRegs().size() - 1;
  InitIssueTime();
  valLiveMap_.resize(length_);
  int vc = bb_->GetParent()->GetNumValues();
  cycleRegPressure_.resize(length_);
  valConflicts_.clear();
  numConflicts_[0] = numConflicts_[1] = 0;
  size_t cpPressure = 0, pePressure = 0;
  for (int i = 0; i < length_; ++i) {
    BitVector& liveVals = valLiveMap_[i];
    liveVals.resize(vc);
    liveVals.reset();
    size_t cp = 0, pp = 0;
    for (BlockLiveInterval::iterator rIt = liveIntervals_.begin();
         rIt != liveIntervals_.end(); ++rIt) {
      int r = rIt->first;
      if (IsElementOf(r, spilledValues)) { continue; }
      if (rIt->second.AliveAt(i+1)) {
        ES_ASSERT_MSG(r < static_cast<int>(liveVals.size()), "ID out of range");
        liveVals.set(r);
        if (GetValue(r, valueRegClassMap) == 0) { ++cp; } else { ++pp; }
      }// if (rIt->second.AliveAt(i))
    }// for bLI iterator rIt
    cycleRegPressure_[i] = make_pair(cp, pp);
    cpPressure = max(cpPressure, cp);
    pePressure = max(pePressure, pp);
    bool cpConflict = (cp > cpRFSize), peConflict = (pp > peRFSize);
    if (cpConflict) { ++numConflicts_[0]; }
    if (peConflict) { ++numConflicts_[1]; }
    if (cpConflict || peConflict) {
      for (unsigned j = 0; j < liveVals.size(); ++j) {
        if (!liveVals[j]) { continue; }
        if (cpConflict && GetValue(static_cast<int>(j), valueRegClassMap) == 0){
          ++valConflicts_[j];
        }// if (cpConflict)
        if (peConflict && GetValue(static_cast<int>(j), valueRegClassMap) == 1){
          ++valConflicts_[j];
        }// if (cpConflict)
      }// for (unsigned j = 0; j < liveVals.size(); ++j) {
    }// if (cpConflict || peConflict)
  }// // for i = 0 to length_-1
  regPressure_.resize(2);
  regPressure_[0] = cpPressure;
  regPressure_[1] = pePressure;
}// CalculateRegPressure()

void BaselineBlockData::
GetSpillCandidates(
  BitVector& cpSpillCandidates,BitVector& peSpillCandidates,
  const IntSet& nonSpillVals, const Int2IntMap& valueRegClassMap,
  const BaselineBasicInfo& target) {
  unsigned cpRFSize = target.GetCPAvailPhyRegs().size() - 1,
    peRFSize = target.GetCPAvailPhyRegs().size() - 1;
  int vc = bb_->GetParent()->GetNumValues();
  blockSpillCandidate_[0].resize(vc);
  blockSpillCandidate_[1].resize(vc);
  blockSpillCandidate_[0].reset();
  blockSpillCandidate_[1].reset();
  for (int i = 0; i < length_; ++i) {
    size_t cp = cycleRegPressure_[i].first, pp = cycleRegPressure_[i].second;
    bool spillCP = (cp > cpRFSize), spillPE = (pp > peRFSize);
    if (!spillCP && !spillPE) { continue; }
    const BitVector& liveVals = valLiveMap_[i];
    for (int j = 0; j < static_cast<int>(liveVals.size()); ++j) {
      if (liveVals[j] && !IsElementOf(j, nonSpillVals)) {
        ES_ASSERT_MSG(IsElementOf(j, valueRegClassMap),
                      "V_"<< j <<" has no class");
        if (GetValue(j, valueRegClassMap) == 0) {
          blockSpillCandidate_[0].set(j);
          cpSpillCandidates.set(j);
        } else {// if (GetValue(j, valueRegClassMap) == 0)
          blockSpillCandidate_[0].set(j);
          peSpillCandidates.set(j);
        }// if (GetValue(j, valueRegClassMap) == 0)
      }// if (liveVals[j])
    }// for i = 0 to liveVals.size()-1
  }// for i = 1 to length_-1
}// GetSpillCandidates()

void BaselineBlockData::
MergeValConflicTo(Int2IntMap& conflict) const {
  for (Int2IntMap::const_iterator it = valConflicts_.begin();
       it != valConflicts_.end(); ++it) {
    conflict[it->first] += it->second;
  }
}// MergeValConflicTo()

void BaselineBlockData::
InsertNoLater(iterator it, SIRInstruction* instr) {
  if ((it != end()) && !instr->IsNOP()) {
    TargetIssuePacket* packet = *it;
    bool vector = instr && instr->IsVectorInstr();
    if (!packet->GetInstr(vector) || packet->GetInstr(vector)->IsNOP()) {
      packet->SetInstr(instr, vector); return;
    }
  }// if ((it != end()) && !instr->IsNOP())
  InsertBefore(it, instr);
}// InsertNoLater()

void BaselineBlockData::
InsertBefore(BaselineBlockData::iterator it, SIRInstruction* instr) {
  BaselineBlockData::iterator ip = it;
  bool vector = instr && instr->IsVectorInstr();
  if (instr) { bb_->AddManagedValue(instr); }
  // First try to put instr to an existing packet.
  // But if instr is a NOP, we assume that an extra cycle is required, therefore
  // there is no need to check whether the previous cycle is free
  if (instr && !instr->IsNOP() && it != begin()) {
    TargetIssuePacket* packet = *--it;
    if (!packet->GetInstr(vector)) {
      packet->SetInstr(instr, vector); return;
    }
  }// if (it != begin())
  // We need to create a new packet for instr
  TargetIssuePacket* p = new TargetIssuePacket(0, 2);
  p->SetInstr(vector ? NULL  : instr, 0);
  p->SetInstr(vector ? instr : NULL,  1);
  insert(ip, p);
  InitIssueTime();
}// InsertBefore()

void BaselineBlockData::
InsertBeforeWithTimingCheck(iterator it, SIRInstruction* instr) {
  InsertBefore(it, instr);
  // Check if the timing is still correct after moving instr
  int pad = 0;
  for (int i=0,e=instr->operand_size(); i < e; ++i) {
    if (SIRInstruction* prod
        = dynamic_cast<SIRInstruction*>(instr->GetOperand(i))) {
      if (prod->GetParent() == instr->GetParent()) {
        int d  = instr->GetTargetData()->GetDistance(prod);
        int pl = prod->GetTargetData()->GetLatency();
        ES_ASSERT_MSG(d>0, "Negative distance between prod and cons\n");
        pad = max(pad, pl-d);
      }
    }// if prod
  }
  --it;
  for (int i=0; i < pad; ++i) { InsertNOPBefore(it); }
}// InsertBeforeWithTimingCheck()

void BaselineBlockData::
InsertAfter(BaselineBlockData::iterator it, SIRInstruction* instr) {
  BaselineBlockData::iterator ip = it;
  bool vector = instr && instr->IsVectorInstr();
  if (instr) { bb_->AddManagedValue(instr); }
  if (ip != end()) {
    ++ ip;
    // First try to put instr to an existing packet.
    // But if instr is a NOP, we assume that an extra cycle is required, so
    // there is no need to check whether the next cycle is free
    if (instr && !instr->IsNOP() && (ip != end())) {
      TargetIssuePacket* packet = *ip;
      if (!packet->GetInstr(vector)) {
        packet->SetInstr(instr, vector); return;
      }
    }
  }// if (ip != end())
  // We need to create a new packet for instr
  TargetIssuePacket* p = new TargetIssuePacket(0, 2);
  p->SetInstr(vector ? NULL  : instr, 0);
  p->SetInstr(vector ? instr : NULL,  1);
  insert(ip, p);
  InitIssueTime();
}// InsertAfter()

void BaselineBlockData::
InsertNOPBefore(BaselineBlockData::iterator it) {
  SIRInstruction* pI = new SIRInstruction(TargetOpcode::NOP, bb_, false);
  bb_->GetParent()->GetParent()->GetTargetData()->InitTargetData(pI);
  InsertBefore(it, pI);
}// InsertNOPBefore()

static SIRInstruction* GenerateImmInstr(
  SIRInstruction* instr, SIRInstruction::operand_iterator oIt, int val,
  SIRFunction* func, const BaselineBasicInfo& target) {

  unsigned ibits = target.GetImmSize(instr);
  uint32_t high = val >> ibits;
  uint32_t low  = ExtractBitsFromWord(val, 0, ibits-1);
  unsigned maxBits = instr->IsVectorInstr() ? target.GetPEMaxImmSize()
    : target.GetCPMaxImmSize();
  bool zimm = !SignedImmCanFitNBits(val, maxBits);
  SIRInstruction* immInstr = new SIRInstruction(
    zimm ? TargetOpcode::ZIMM : TargetOpcode::SIMM, instr->GetParent(),
    instr->IsVectorInstr());
  func->GetParent()->GetTargetData()->InitTargetData(immInstr);
  immInstr->AddOperand(func->GetParent()->AddOrGetImmediate(high));
  instr->ChangeOperand(oIt, func->GetParent()->AddOrGetImmediate(low));
  return immInstr;
}// GenerateImmInstr()

void BaselineBlockData::
InsertImmInstr(const BaselineBasicInfo& target) {
  for (BaselineBlockData::iterator pIt = begin(); pIt != end(); ++pIt) {
    SIRInstruction* cpInstr = (*pIt)->GetInstr(BaselineBasicInfo::CP);
    SIRInstruction* peInstr = (*pIt)->GetInstr(BaselineBasicInfo::PE);
    SIRInstruction* cpImmInstr = NULL, * peImmInstr = NULL;

    SIRFunction* func = bb_->GetParent();
    if (cpInstr) {
      for (SIRInstruction::operand_iterator oIt = cpInstr->operand_begin();
           oIt != cpInstr->operand_end(); ++oIt) {
        if (!llvm::isa<SIRConstant>(*oIt)) { continue; }
        SIRConstant* imm = llvm::cast<SIRConstant>(*oIt);
        int val = imm->GetImmediate();
        if (target.ImmCanFit(cpInstr->GetTargetOpcode(),false,val)){ continue; }
        // If there is already an immediate instruction, don't do anything
        if (pIt != begin()) {
          iterator pi = pIt;
          --pi;
          SIRInstruction* pCPInstr = (*pi)->GetInstr(BaselineBasicInfo::CP);
          if (pCPInstr && IsTargetImmediateOp(pCPInstr->GetTargetOpcode())) {
            continue;
          }
        }
        cpImmInstr = GenerateImmInstr(cpInstr, oIt, val, func, target);
        // There supposed to be only one immediate, so we're done
        break;
      }// for instr operand_iterator oIt
    }// if (cpInstr)
    if (peInstr) {
      for (SIRInstruction::operand_iterator oIt = peInstr->operand_begin();
           oIt != peInstr->operand_end(); ++oIt) {
        if (!llvm::isa<SIRConstant>(*oIt))
          continue;
        SIRConstant* imm = llvm::cast<SIRConstant>(*oIt);
        int val = imm->GetImmediate();
        if (target.ImmCanFit(peInstr->GetTargetOpcode(),false,val)){ continue; }
        // If there is already an immediate instruction, don't do anything
        if (pIt != begin()) {
          iterator pi = pIt;
          --pi;
          SIRInstruction* pPEInstr = (*pi)->GetInstr(BaselineBasicInfo::PE);
          if (pPEInstr && IsTargetImmediateOp(pPEInstr->GetTargetOpcode())) {
            continue;
          }
        }
        peImmInstr = GenerateImmInstr(peInstr, oIt, val, func, target);
        // There supposed to be only one immediate, so we're done
        break;
      }// for instr operand_iterator oIt
    }// if (peInstr)
    if (cpImmInstr) {
      if (pIt != begin()) {
        BaselineBlockData::iterator bIt = pIt; --bIt;
        SIRInstruction* bInstr = (*bIt)->GetInstr(BaselineBasicInfo::CP);
        // If the previous instruction is a branch, this instruction is in branch
        // delay slot, so we first move it in front of the branch
        if (bInstr && bInstr->GetBranchTarget()) {
          (*pIt)->RemoveInstr(cpInstr);
          InsertBefore(bIt, cpImmInstr);
          InsertBefore(bIt, cpInstr);
        } else { InsertBefore(pIt, cpImmInstr); }
      } else { InsertBefore(pIt, cpImmInstr); }
    }// if (cpImmInstr)
    if (peImmInstr) { InsertBefore(pIt, peImmInstr); }
  }// for iterator pIt
}// InsertImmInstr()

void BaselineBlockData::
ResetBypass() {
  for (iterator pIt = begin(); pIt != end(); ++pIt) {
    TargetIssuePacket* packet = dynamic_cast<TargetIssuePacket*>(*pIt);
    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::CP)) {
      dynamic_cast<BaselineInstrData*>(instr->GetTargetData())->ResetBypass();
    }
    if (SIRInstruction* instr = packet->GetInstr(BaselineBasicInfo::PE)) {
      dynamic_cast<BaselineInstrData*>(instr->GetTargetData())->ResetBypass();
    }
  }// for const_iterator pIt
}// Print()

void BaselineBlockData::
Print(std::ostream& o) const {
  for (const_iterator pIt = begin(); pIt != end(); ++pIt) {
    (*pIt)->Print(o); o <<"\n";
  }// for const_iterator pIt
}// Print()

void BaselineBlockData::
ValuePrint(std::ostream& o) const {
  for (const_iterator pIt = begin(); pIt != end(); ++pIt) {
    o <<"        "; (*pIt)->ValuePrint(o); o <<"\n";
  }// for const_iterator pIt
}// ValuePrint()

void BaselineBlockData::
PrintCodeGenStat(std::ostream& o) const {
  const BaselineBasicInfo& target
    = dynamic_cast<BaselineFuncData*>(bb_->GetParent()->GetTargetData())
    ->GetTarget();
  Str2IntMap blkStat;
  for (const_iterator it = begin(); it != end(); ++it) {
    TargetIssuePacket* packet = *it;
    // Collect CP instruction statistics
    if (const SIRInstruction* cpInstr=packet->GetInstr(BaselineBasicInfo::CP)) {
      TargetOpcode_t opc = cpInstr->GetTargetOpcode();
      if (opc != TargetOpcode::NOP) { ++blkStat["totalCPOp"]; }
      if (IsTargetBranch(opc)) {
        ++ blkStat["totalBr"];
        if (IsTargetCall(opc))       { ++ blkStat["call"]; }
        if (IsTargetCondBranch(opc)) { ++ blkStat["condBr"]; }
      }// if (IsBranch(opc))
      if (IsTargetStore(opc)) { ++ blkStat["memWrite"]; }
      if (IsTargetLoad(opc))  { ++ blkStat["memRead"];  }
      switch(target.GetCPOperationBinding(opc)) {
      case 0: ++ blkStat["cpALUOp"]; break;
      case 1: ++ blkStat["cpMULOp"]; break;
      case 2: ++ blkStat["cpLSUOp"]; break;
      }
      const BaselineInstrData* cpIData
        = dynamic_cast<const BaselineInstrData*>(cpInstr->GetTargetData());
      if (cpIData->ToRF()
          && (target.IsCPPhyRegister(cpIData->GetDestPhyReg() > 0))) {
        ++ blkStat["regWrite"];
      }
      if ((NumTargetOpResult(opc) > 0) && !cpIData->ToRF()) {
        ++ blkStat["bypassWrite"];
      }
      for (int i = 0; i < cpIData->GetNumOperands(); ++i) {
        if (target.IsCPPhyRegister(cpIData->GetOperandPhyReg(i))
            && (cpIData->GetOperandBypass(i) < 0)) { ++ blkStat["regRead"]; }
        if (cpIData->GetOperandBypass(i) >= 0) { ++ blkStat["bypassRead"]; }
      }
    }// if (const SIRInstruction* cpInstr = packet->GetCPInstr())

    // Collect PE instruction statistics
    if (const SIRInstruction* peInstr=packet->GetInstr(BaselineBasicInfo::PE)) {
      TargetOpcode_t opc = peInstr->GetTargetOpcode();
      if (opc != TargetOpcode::NOP) { ++blkStat["totalPEOp"]; }
      if (IsTargetStore(opc)) { ++ blkStat["vmemWrite"]; }
      if (IsTargetLoad(opc))  { ++ blkStat["vmemRead"];  }
      switch(target.GetPEOperationBinding(opc)) {
      case 0: ++ blkStat["peALUOp"]; break;
      case 1: ++ blkStat["peMULOp"]; break;
      case 2: ++ blkStat["peLSUOp"]; break;
      }
      const BaselineInstrData* peIData
        = dynamic_cast<const BaselineInstrData*>(peInstr->GetTargetData());
      if (peIData->ToRF()
          && (target.IsPEPhyRegister(peIData->GetDestPhyReg() > 0))) {
        ++blkStat["vregWrite"];
      }
      if ((NumTargetOpResult(opc) > 0) && !peIData->ToRF()) {
        ++ blkStat["vBypassWrite"];
      }
      for (int i = 0; i < peIData->GetNumOperands(); ++i) {
        if (target.IsPEPhyRegister(peIData->GetOperandPhyReg(i))
            && (peIData->GetOperandBypass(i) < 0)) { ++ blkStat["vregRead"]; }
        if (peIData->GetOperandBypass(i) >= 0) { ++ blkStat["vBypassRead"]; }
      }
    }// if (const SIRInstruction* peInstr = packet->GetPEInstr())
  }// for const_iterator it
  o <<"issue_packet:"<< size() <<'\n';
  o <<"cp_op:"<< blkStat["totalCPOp"] <<'\n';
  if (blkStat["cpALUOp"]) {o<<"cp_alu_op:"<<blkStat["cpALUOp"]<<'\n';}
  if (blkStat["cpMULOp"]) {o<<"cp_mul_op:"<<blkStat["cpMULOp"]<<'\n';}
  if (blkStat["cpLSUOp"]) {o<<"cp_lsu_op:"<<blkStat["cpLSUOp"]<<'\n';}
  if (blkStat["memRead"]) {
    o<<"cp_load:"<< blkStat["memRead"] <<'\n';
  }
  if (blkStat["memWrite"]) {
    o<<"cp_store:"<< blkStat["memWrite"]  <<'\n';
  }
  if (blkStat["totalBr"]) {
    o <<"branch:"<< blkStat["totalBr"] <<'\n';
    if (blkStat["condBr"]) {
      o <<"cond_br:"<< blkStat["condBr"] <<'\n';
    }
    if (blkStat["call"]) {
      o <<"call:"<< blkStat["call"]   <<'\n';
    }
  }
  o <<"cp_reg_wr:"<< blkStat["regWrite"] <<'\n';
  if (target.IsCPExplicitBypass()) {
    o <<"cp_bypass_wr:"<< blkStat["bypassWrite"] <<'\n';
  }
  o <<"cp_reg_rd:"<< blkStat["regRead"]  <<'\n';
  if (target.IsCPExplicitBypass()) {
    o <<"cp_bypass_rd:"<< blkStat["bypassRead"] <<'\n';
  }

  if (!blkStat["totalPEOp"]) { return; }
  o <<"pe_op:"   << blkStat["totalPEOp"] <<'\n';
  if (blkStat["peALUOp"]){o <<"pe_alu_op:"<<blkStat["peALUOp"]<<'\n';}
  if (blkStat["peMULOp"]){o <<"pe_mul_op:"<<blkStat["peMULOp"]<<'\n';}
  if (blkStat["peLSUOp"]){o <<"pe_lsu_op:"<<blkStat["peLSUOp"]<<'\n';}
  if (blkStat["vmemRead"])  {
    o <<"pe_load:"<< blkStat["vmemRead"] <<'\n';
  }
  if (blkStat["vmemWrite"]) {
    o <<"pe_store:"<< blkStat["vmemWrite"] <<'\n';
  }
  o <<"pe_reg_wr:"<< blkStat["vregWrite"] <<'\n';
  if (target.IsPEExplicitBypass()) {
    o <<"pe_bypass_wr:"<< blkStat["vBypassWrite"] <<'\n';
  }
  o <<"pe_reg_rd:"<< blkStat["vregRead"]  <<'\n';
  if (target.IsPEExplicitBypass()) {
    o <<"pe_bypass_rd:"<< blkStat["vBypassRead"] <<'\n';
  }
}// PrintCodeGenStat()
