#include "BaselinePostRATransform.hh"
#include "BaselineCodeGenEngine.hh"
#include "BaselineInstrData.hh"
#include "BaselineBlockData.hh"
#include "BaselineFuncData.hh"
#include "BaselineBasicInfo.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetIssuePacket.hh"
#include "Target/TargetModuleData.hh"
#include "Target/TargetFuncRegAllocInfo.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/BitUtils.hh"
#include "llvm/Support/Casting.h"

using namespace std;
using namespace ES_SIMD;

bool LowerMOV::
RunOnSIRBasicBlock(SIRBasicBlock* bb) {
  bool changed = false;
  SIRModule* m = bb->GetParent()->GetParent();
  SIRFunction* func = bb->GetParent();
  for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
    SIRInstruction* instr = *iIt;
    if (instr->GetTargetOpcode() != TargetOpcode::MOV) { continue; }
    changed = true;
    SIRValue* src = instr->GetOperand(0);
    if (llvm::isa<SIRInstruction>(src) || llvm::isa<SIRRegister>(src)) {
      instr->SetTargetOpcode(TargetOpcode::ADD);
      instr->AddOperand(m->AddOrGetImmediate(0));
    } else if (llvm::isa<SIRConstant>(src) || src->HasName()) {
      instr->SetTargetOpcode(TargetOpcode::ADD);
      instr->ReplaceOperand(src, func->GetZeroRegister());
      instr->AddOperand(src);
      BaselineInstrData* idata
        = dynamic_cast<BaselineInstrData*>(instr->GetTargetData());
      idata->ResetOperandInfo();
      idata->SetOperandPhyReg(0, 0);
    } else {
      errors_.push_back(
        Error(ErrorCode::SIRTranslationFailure,
              "Failed to lower MOV",(*iIt)->GetFileLocation()));
    }
  }
  return changed;
}// LowerMOV::RunOnSIRBasicBlock()

bool LowerRSUB::
RunOnSIRBasicBlock(SIRBasicBlock* bb) {
  bool changed = false;
  for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (instr->GetTargetOpcode() != TargetOpcode::SUB) { continue; }
      SIRValue* src0 = instr->GetOperand(0);
      if (!llvm::isa<SIRInstruction>(src0) && !llvm::isa<SIRRegister>(src0)) {
        changed = true;
        SIRValue* src1 = instr->GetOperand(1);
        ES_ASSERT_MSG(llvm::isa<SIRConstant>(src0),
                      "Expected a constant or label in rsubi");
        SIRConstant* c = static_cast<SIRConstant*>(src0);
        BaselineInstrData* iData
          = dynamic_cast<BaselineInstrData*>(instr->GetTargetData());
        if (c->IsImmediate() && (c->GetImmediate() == 0)) {
          instr->ChangeOperand(0, bb->GetParent()->GetZeroRegister());
          iData->SetOperandPhyReg(0, 0);
          continue;
        }
        instr->SetTargetOpcode(TargetOpcode::RSUB);
        instr->ChangeOperand(0, NULL);
        instr->ChangeOperand(1, NULL);
        instr->ChangeOperand(0, src1);
        instr->ChangeOperand(1, src0);
        dynamic_cast<BaselineInstrData*>(instr->GetTargetData())
          ->SwapOperand(0, 1);
      }
    }
  return changed;
}// LowerRSUB::RunOnSIRBasicBlock()

static void
AddReturn(SIRBasicBlock* bb, SIRRegister* ra, bool delayFilled,
          const BaselineBasicInfo& target) {
  SIRInstruction* rInstr=new SIRInstruction(TargetOpcode::JR,  bb, false);
  rInstr->AddOperand(ra);
  BaselineInstrData* rData = dynamic_cast<BaselineInstrData*>(
    bb->GetParent()->GetParent()->GetTargetData()->InitTargetData(rInstr));
  rData->SetOperandPhyReg(0, 9);
  bb->push_back(rInstr);
  BaselineBlockData* bData = dynamic_cast<BaselineBlockData*>(
    bb->GetTargetData());
  bData->InsertBefore(bData->end(), rInstr);
  BaselineBlockData::iterator it = bData->end();
  --it;
  if (!delayFilled) {
    SIRInstruction* dInstr=new SIRInstruction(TargetOpcode::NOP, bb, false);
    bb->GetParent()->GetParent()->GetTargetData()->InitTargetData(dInstr);
    bb->push_back(dInstr);
    bData->InsertBefore(bData->end(), dInstr);
  }
  bData->InitIssueTime();
  if (!target.IsCPExplicitBypass() || (it == bData->begin())) { return; }
  // Check if RA needs to be bypassed
  --it;
  int bid = -1;
  unsigned threshold = target.GetCPNumStages() - 3;
  int rv = ra->GetValueID();
  for (unsigned i = 0; i < threshold; ++i, --it) {
    SIRInstruction* instr = (*it)->GetInstr(BaselineBasicInfo::CP);
    if (instr && (instr->GetValueID() == rv)) {
      int binding  = target.GetPEOperationBinding(instr->GetTargetOpcode());
      unsigned lat = target.GetCPOperationLatency(instr->GetTargetOpcode());
      if ((i - lat + 1) == 0) { bid = binding; }
      break;
    }// if (instr && instr->GetValueID() == rv)
    if (it == bData->begin()) { break; }
  }// for i = 0 to threshold-1
  if (bid >= 0) {
    rData->SetOperandBypass(0, bid);
  }
}// AddReturn()

static void
AddStackAlloc(SIRFunction* func, unsigned offset, bool vect,
              const BaselineBasicInfo& target) {
  if (!offset) { return; }
  SIRBasicBlock* bb = func->GetEntryBlock();
  BaselineBlockData* bData = dynamic_cast<BaselineBlockData*>(
    bb->GetTargetData());
  int sp = func->GetStackPointer()->GetValueID();
  SIRInstruction* addInstr=new SIRInstruction(TargetOpcode::ADD, bb, vect);
  addInstr->SetValueID(sp);
  addInstr->AddOperand(func->GetStackPointer());
  bool fit = target.ImmCanFit(TargetOpcode::ADD, vect, -offset);
  SIRInstruction* immInstr = NULL;
  uint32_t allocImm = static_cast<uint32_t>(-offset);
  if (!fit) {
    immInstr=new SIRInstruction(TargetOpcode::SIMM, bb, vect);
    unsigned ibits = target.GetImmSize(addInstr);
    uint32_t high = allocImm >> ibits;
    allocImm  = ExtractBitsFromWord(allocImm, 0, ibits-1);
    immInstr->AddOperand(func->GetParent()->AddOrGetImmediate(high));
    func->GetParent()->GetTargetData()->InitTargetData(immInstr);
  }// if (!fit)
  addInstr->AddOperand(func->GetParent()->AddOrGetImmediate(allocImm));
  BaselineInstrData* addData = dynamic_cast<BaselineInstrData*>(
    func->GetParent()->GetTargetData()->InitTargetData(addInstr));
  addData->SetDestPhyReg(1);
  addData->SetOperandPhyReg(0, 1);
  bData->InsertBefore(bData->begin(), addInstr);
  bb->AddLiveOutValue(false, "SP", sp);
  BaselineBlockData::iterator it = bData->begin();
  if (immInstr) {
    bData->InsertBefore(bData->begin(), immInstr);
  }
  if (!target.IsCPExplicitBypass()) { return; }
  unsigned threshold = target.GetCPNumStages() - 3;
  ++it;
  // Check if SP needs to be bypassed
  int bid = 0;
  for (unsigned i = 0; (i < threshold) && (it != bData->end()); ++i, ++it) {
    SIRInstruction* instr = (*it)->GetInstr(BaselineBasicInfo::CP);
    if (instr && instr->UsesValue(sp)) {
      BaselineInstrData* idata = dynamic_cast<BaselineInstrData*>(
        instr->GetTargetData());
      for (unsigned i = 0; i < instr->operand_size(); ++i) {
        if (instr->GetOperand(i)->GetValueID() == sp) {
          idata->SetOperandBypass(i, bid);
        }
      }
    }// if (SIRInstruction* instr = packet->GetCPInstr()) {
  }// for i = 0 to threshold-1
}// AddStackAlloc()

static int
AddStackFree(SIRFunction* func, SIRBasicBlock* bb, unsigned offset, bool vect,
              const BaselineBasicInfo& target) {
  if (!offset) { return 0; }
  int instrCount = 1;
  BaselineBlockData* bData
    = dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
  SIRInstruction* addInstr = new SIRInstruction(TargetOpcode::ADD, bb, vect);
  addInstr->SetValueID(func->GetStackPointer()->GetValueID());
  addInstr->AddOperand(func->GetStackPointer());
  bool fit = target.ImmCanFit(TargetOpcode::ADD, vect, offset);
  SIRInstruction* immInstr = NULL;
  uint32_t allocImm = static_cast<uint32_t>(offset);
  if (!fit) {
    ++instrCount;
    immInstr = new SIRInstruction(TargetOpcode::SIMM, bb, vect);
    unsigned ibits = target.GetImmSize(addInstr);
    uint32_t high = allocImm >> ibits;
    allocImm  = ExtractBitsFromWord(allocImm, 0, ibits-1);
    immInstr->AddOperand(func->GetParent()->AddOrGetImmediate(high));
    func->GetParent()->GetTargetData()->InitTargetData(immInstr);
  }// if (!fit)
  addInstr->AddOperand(func->GetParent()->AddOrGetImmediate(allocImm));
  BaselineInstrData* addData = dynamic_cast<BaselineInstrData*>(
    func->GetParent()->GetTargetData()->InitTargetData(addInstr));
  addData->SetDestPhyReg(1);
  addData->SetOperandPhyReg(0, 1);
  addInstr->SetTargetData(addData);
  if (immInstr) { bData->InsertBefore(bData->end(), immInstr); }
  bData->InsertBefore(bData->end(), addInstr);
  return instrCount;
}// AddStackFree()

// Spill special registers
static void
AddSRSpill(SIRFunction* func, SIRBasicBlock* bb, SIRValue* val,
           bool vect, const BaselineBasicInfo& target) {
  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  TargetFuncRegAllocInfo* raInfo = fData->GetRegAllocInfo();
  int v = val->GetValueID();
  if (!fData->GetRegAllocInfo()->IsValueSpilled(v)
      && (func->IsLeaf() || !val->ValueEqual(func->GetLinkRegister()))) {
    return;
  }
  BaselineBlockData* bData
    = dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
  int so = fData->GetSpillSlotOffset(raInfo->GetSpillSlotIndex(v, vect), vect);
  int reg = raInfo->GetValuePhyRegister(v);
  bool fit = target.ImmCanFit(TargetOpcode::SW, vect, so);
  uint32_t spillOffset = static_cast<uint32_t>(so);
  SIRInstruction* store = new SIRInstruction(TargetOpcode::SW, bb, vect);
  SIRInstruction* immInstr = NULL;
  if (!fit) {
    immInstr = new SIRInstruction(TargetOpcode::SIMM, bb, vect);
    unsigned ibits = target.GetImmSize(store);
    uint32_t high = spillOffset >> ibits;
    spillOffset  = ExtractBitsFromWord(spillOffset, 0, ibits-1);
    immInstr->AddOperand(func->GetParent()->AddOrGetImmediate(high));
    func->GetParent()->GetTargetData()->InitTargetData(immInstr);
  }// if (!fit)
  SIRConstant* offset = func->GetParent()->AddOrGetImmediate(spillOffset);
  store->AddOperand(func->GetStackPointer());
  store->AddOperand(val);
  store->AddOperand(offset);
  BaselineInstrData* stData = dynamic_cast<BaselineInstrData*>(
    func->GetParent()->GetTargetData()->InitTargetData(store));
  stData->SetOperandPhyReg(0, raInfo->GetValuePhyRegister(
                             func->GetStackPointer()->GetValueID()));
  stData->SetOperandPhyReg(1, reg);
  bData->InsertBefore(bData->begin(), store);
  if (immInstr) { bData->InsertBefore(bData->begin(), immInstr); }
}// AddSRSpill()

// Reload special registers
static void
AddSRReload(SIRFunction* func, SIRBasicBlock* bb, SIRValue* val,
            bool vect, const BaselineBasicInfo& target) {
  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  TargetFuncRegAllocInfo* raInfo = fData->GetRegAllocInfo();
  int v = val->GetValueID();
  if (!fData->GetRegAllocInfo()->IsValueSpilled(v)
      && (func->IsLeaf() || !val->ValueEqual(func->GetLinkRegister()))) {
    return;
  }
  BaselineBlockData* bData
    = dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
  int so = fData->GetSpillSlotOffset(raInfo->GetSpillSlotIndex(v, vect), vect);
  int reg = raInfo->GetValuePhyRegister(v);
  uint32_t spillOffset = static_cast<uint32_t>(so);
  SIRInstruction* load = new SIRInstruction(TargetOpcode::LW, bb, vect);
  SIRInstruction* immInstr = NULL;
  bool fit = target.ImmCanFit(TargetOpcode::LW, vect, so);
  if (!fit) {
    immInstr = new SIRInstruction(TargetOpcode::SIMM, bb, vect);
    unsigned ibits = target.GetImmSize(load);
    uint32_t high = spillOffset >> ibits;
    spillOffset  = ExtractBitsFromWord(spillOffset, 0, ibits-1);
    immInstr->AddOperand(func->GetParent()->AddOrGetImmediate(high));
    func->GetParent()->GetTargetData()->InitTargetData(immInstr);
  }// if (!fit)
  SIRConstant* offset = func->GetParent()->AddOrGetImmediate(spillOffset);
  load->AddOperand(func->GetStackPointer());
  load->AddOperand(offset);
  load->SetValueID(v);
  BaselineInstrData* ldData = dynamic_cast<BaselineInstrData*>(
    func->GetParent()->GetTargetData()->InitTargetData(load));
  ldData->SetOperandPhyReg(0, raInfo->GetValuePhyRegister(
                             func->GetStackPointer()->GetValueID()));
  ldData->SetDestPhyReg(reg);
  bData->InsertNoLater(bData->begin(), load);
  if (immInstr) { bData->InsertBefore(bData->begin(), immInstr); }
}// AddSRReload()

bool EmitFuncProEpilogue::
RunOnSIRFunction(SIRFunction* func) {
  TargetModuleData* mData = func->GetParent()->GetTargetData();
  BaselineFuncData* fData = dynamic_cast<BaselineFuncData*>(
    func->GetTargetData());
  TargetFuncRegAllocInfo* raInfo = func->GetTargetData()->GetRegAllocInfo();
  // Prologue
  SIRRegister* numPE = func->GetNumPERegister();
  if (!func->GetParent()->IsBareModule() && (numPE->use_size() > 0)) {
    int adr = func->GetParent()->GetDataObject("__pe_array_size")->GetAddress();
    SIRBasicBlock* bb = func->GetEntryBlock();
    SIRInstruction* load = new SIRInstruction(TargetOpcode::LW, bb, false);
    load->AddOperand(func->GetZeroRegister()).AddOperand(
      func->GetParent()->AddOrGetImmediate(adr*8/target_.GetDataWidth(0)));
    load->SetValueID(numPE->GetValueID());
    BaselineInstrData* ldData = dynamic_cast<BaselineInstrData*>(
      mData->InitTargetData(load));
    ldData->SetOperandPhyReg(0, raInfo->GetValuePhyRegister(
                               func->GetZeroRegister()->GetValueID()));
    ldData->SetDestPhyReg(raInfo->GetValuePhyRegister(numPE->GetValueID()));
    BaselineBlockData* bData
      = static_cast<BaselineBlockData*>(bb->GetTargetData());
    bData->InsertBeforeWithTimingCheck(bData->begin(), load);
    if (target_.IsCPExplicitBypass()) {
      unsigned threshold = target_.GetCPNumStages() - 3;
      BaselineBlockData::iterator it = bData->begin();
      ++it;
      int nv = numPE->GetValueID();
      // Check if consumer timing is met
      int delay = target_.GetOperationLatency(load)-1;
      int pad = 0;
      for (int i = 0, e=delay; i < e; ++i, ++it) {
        SIRInstruction* instr = (*it)->GetInstr(BaselineBasicInfo::CP);
        if (instr && instr->UsesValue(nv)) { pad = delay - i; }
      }
      for (int i = 0, e = pad; i < e; ++i) { bData->InsertNOPBefore(it); }
      // Check if NUMPE needs to be bypassed
      int bid = 2;
      it = bData->begin();
      for (int i = 0, e=delay+1; i < e; ++i) { ++it; }
      for (unsigned i = 0; (i < threshold) && (it != bData->end()); ++i, ++it) {
        SIRInstruction* instr = (*it)->GetInstr(BaselineBasicInfo::CP);
        if (instr && instr->UsesValue(nv)) {
          BaselineInstrData* idata = dynamic_cast<BaselineInstrData*>(
            instr->GetTargetData());
          for (unsigned i = 0; i < instr->operand_size(); ++i) {
            if (instr->GetOperand(i)->GetValueID() == nv) {
              idata->SetOperandBypass(i, bid);
            }
          }
        }// if (SIRInstruction* instr = packet->GetCPInstr()) {
      }// for i = 0 to threshold-1
    }//if (target_.IsCPExplicitBypass())
  }// if (numPE->use_size() > 0)
  const Int2IntMap spilledArgs = fData->GetRegAllocInfo()->SpilledArgs();
  for (Int2IntMap::const_iterator it = spilledArgs.begin();
       it != spilledArgs.end(); ++it) {
    SIRBasicBlock* bb = func->GetEntryBlock();
    BaselineBlockData* bData
      = dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
    int so = it->second;
    int reg = raInfo->GetValuePhyRegister(it->first);
    bool fit = target_.ImmCanFit(TargetOpcode::SW, false, so);
    uint32_t spillOffset = static_cast<uint32_t>(so);
    SIRInstruction* store = new SIRInstruction(TargetOpcode::SW, bb, false);
    SIRInstruction* immInstr = NULL;
    if (!fit) {
      immInstr = new SIRInstruction(TargetOpcode::SIMM, bb, false);
      unsigned ibits = target_.GetImmSize(store);
      uint32_t high = spillOffset >> ibits;
      spillOffset  = ExtractBitsFromWord(spillOffset, 0, ibits-1);
      immInstr->AddOperand(func->GetParent()->AddOrGetImmediate(high));
      mData->InitTargetData(immInstr);
    }// if (!fit)
    SIRConstant* offset = func->GetParent()->AddOrGetImmediate(spillOffset);
    store->AddOperand(func->GetStackPointer());
    store->AddOperand(func->GetArgumentFromValue(it->first));
    store->AddOperand(offset);
    BaselineInstrData* stData = dynamic_cast<BaselineInstrData*>(
      mData->InitTargetData(store));
    stData->SetOperandPhyReg(0, raInfo->GetValuePhyRegister(
                               func->GetStackPointer()->GetValueID()));
    stData->SetOperandPhyReg(1, reg);
    bData->InsertBefore(bData->begin(), store);
    if (immInstr) { bData->InsertBefore(bData->begin(), immInstr); }
  }
  AddSRSpill(func, func->GetEntryBlock(), func->GetLinkRegister(),
             false, target_);
  unsigned cpSO = fData->GetCPStackOffset(), peSO = fData->GetPEStackOffset();
  AddStackAlloc(func, cpSO, false, target_);
  AddStackAlloc(func, peSO, true,  target_);
  // Epilogue
  int lDeyal = target_.GetCPOperationLatency(TargetOpcode::LW) - 1;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    if (!(*bIt)->IsExitBlock()) { continue; }
    AddSRReload(func, bb, func->GetLinkRegister(), false, target_);
    int p = AddStackFree(func, *bIt, peSO, true,  target_);
    bool fit = target_.ImmCanFit(TargetOpcode::ADD, false, cpSO);
    if ((cpSO > 0) && fit && (p >= lDeyal) && !target_.IsCPExplicitBypass()) {
      AddReturn(*bIt, func->GetLinkRegister(), true, target_);
      AddStackFree(func, *bIt, cpSO, false, target_);
    } else {
      AddStackFree(func, *bIt, cpSO, false, target_);
      AddReturn(*bIt, func->GetLinkRegister(), false, target_);
    }
  }// for func iterator bIt
  return true;
}// EmitFuncProEpilogue::RunOnSIRFunction()

bool CrossFuncBypassCheck::
RunOnSIRFunction(SIRFunction* func) {
  if (func->cs_empty()) { return false; }
  bool changed = false;
  int threshold = (target_.GetCPNumStages() == 4) ? 1 : 2;
  for (SIRFunction::cs_iterator cIt = func->cs_begin();
       cIt != func->cs_end(); ++cIt) {
    SIRBasicBlock* cb = (*cIt)->GetCallerInstr()->GetParent();
    BaselineBlockData* cbData
      = dynamic_cast<BaselineBlockData*>(cb->GetTargetData());
    // Iterator pointing to call instruction
    BaselineBlockData::iterator callIter = cbData->begin();
    while (callIter != cbData->end()) {
      if ((*callIter)->GetInstr(BaselineBasicInfo::CP)
          == (*cIt)->GetCallerInstr()) { break; }
      ++callIter;
    }// while (callIter != cbData.end())
    if ((callIter == cbData->end()) || !(*callIter)->HasCall()) {
      errors_.push_back(
        Error(ErrorCode::CodeGenError,
              "No call instruction found in call site in " + func->GetName()));
      return true;
    }
    // Iterator pointing to the packet in the delay slot
    BaselineBlockData::iterator dlIter = callIter;
    ++dlIter;
    if (dlIter == cbData->end()) {
      errors_.push_back(
        Error(ErrorCode::CodeGenError,
              "Call delay slot not filled in " + func->GetName()));
      return true;
    }
    SIRInstruction* lastInstr = (*dlIter)->GetInstr(BaselineBasicInfo::CP);
    SIRFunction* callee = (*cIt)->GetCallee();
    int argID = (*cIt)->GetArgumentID(lastInstr);
    if (argID < 0) { continue; }
    if (target_.IsCPExplicitBypass()) {
      bool bypass = true;
      if (callee) {
        ES_LOG_P(logLv_, log_, ">>-- Checking a"<< argID <<" usage in "
             << callee->GetName() <<'\n');
        int ut = callee->GetTargetData()->GetValueFirstUsedTime(
          callee->GetArgument(argID)->GetValueID());
        ES_LOG_P(logLv_, log_, ">>-->> a"<< argID <<" used in "
                 << callee->GetName() <<" at "<< ut <<'\n');
        if ((ut < 0) || (ut > threshold)) { bypass = false; }
      }// if (callee)
      if (bypass) {
        ES_LOG_P(logLv_, log_, ">>-->> Joint-point issue for a"<< argID <<'\n');
        if (logLv_) { cbData->ValuePrint(log_); }
        cbData->InitIssueTime();
        SetBaselineBlockBypass(cb, target_, false, log_);
        (*dlIter)->RemoveInstr(lastInstr);
        cbData->InsertBeforeWithTimingCheck(callIter, lastInstr);
        SetBaselineBlockBypass(cb, target_, false, log_);
      }// if (bypass)
    } else {// if (target_.IsCPExplicitBypass())
      int ut = callee->GetTargetData()->GetValueFirstUsedTime(
          callee->GetArgument(argID)->GetValueID());
      int l = target_.GetOperationLatency(lastInstr) - 1 - ut;
      if (l > 0) {
        (*dlIter)->RemoveInstr(lastInstr);
        cbData->InsertBeforeWithTimingCheck(callIter, lastInstr);
      }// if (l > 0)
    }// // if (target_.IsCPExplicitBypass())
  }// for func cs_iterator cIt
  return changed;
}// CrossFuncBypassCheck::RunOnSIRFunction()

static int
BlockPaddingCost(SIRBasicBlock* bb) {
  int c = 1;
  for (int i = 0, e = bb->GetLoopDepth(); i < e; ++i) { c = c*10; }
  return c;
}

bool CrossBlockTimingCheck::
RunOnSIRFunction(SIRFunction* func) {
  bool change = false;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    BaselineBlockData* bData = dynamic_cast<BaselineBlockData*>(
      bb->GetTargetData());
    if (bData->empty()) { continue; }
    BaselineBlockData::iterator lastIt = bData->end();
    --lastIt;
    SIRInstruction* lastCPInstr = (*lastIt)->GetInstr(BaselineBasicInfo::CP);
    SIRInstruction* lastPEInstr = (*lastIt)->GetInstr(BaselineBasicInfo::PE);

    bool cPad = false, pPad = false;
    // Check if CP value needs padding
    int sCPadding = 0;
    if (lastCPInstr && (target_.GetOperationLatency(lastCPInstr) > 1)) {
      int lastCPVal = lastCPInstr->GetValueID();
      if (func->IsValidValueID(lastCPVal)) {
        for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
             sIt != bb->succ_end(); ++sIt) {
          if ((*sIt)->GetTargetData()->ValueFirstUsedTime(lastCPVal) == 0) {
            cPad = true;
            sCPadding += BlockPaddingCost(*sIt);
          }
        }
      }// if (func->IsValidValueID(lastCPVal))
    }// if (lastCPInstr)

    // Check if PE value needs padding
    int sPPadding = 0;
    if (lastPEInstr && (target_.GetOperationLatency(lastPEInstr) > 1)) {
      int lastPEVal = lastPEInstr->GetValueID();
      if (func->IsValidValueID(lastPEVal)) {
        for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
             sIt != bb->succ_end(); ++sIt) {
          if ((*sIt)->GetTargetData()->ValueFirstUsedTime(lastPEVal) == 0) {
            pPad = true;
            sPPadding += BlockPaddingCost(*sIt);
          }
        }
      }// if (func->IsValidValueID(lastPEVal))
    }// if (lastPEInstr)
    int sPadding = max(sCPadding, sPPadding);
    if (cPad || pPad) {
      if (sPadding < BlockPaddingCost(bb)) {
        for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
             sIt != bb->succ_end(); ++sIt) {
          BaselineBlockData* sData
            = dynamic_cast<BaselineBlockData*>((*sIt)->GetTargetData());
          sData->InsertNOPBefore(sData->begin());
        }
      } else {// if (sPadding < BlockPaddingCost(bb))
        BaselineBlockData::iterator brIt = lastIt;
        if (brIt != bData->begin()) {
          --brIt;
          // if lastInstr is in branch delay slot
          if ((*brIt)->HasBranch()) {
            if (cPad) {
              (*lastIt)->RemoveInstr(lastCPInstr);
              bData->InsertBefore(brIt, lastCPInstr);
              if (lastCPInstr) {
                /// The relative position is changed, so we need to check if the
                /// timing is still correct
                bData->InitIssueTime();
                int ct = lastCPInstr->GetTargetData()->GetIssueTime();
                int lPadding = 0;
                for (int i = 0, e= lastCPInstr->operand_size(); i < e; ++i) {
                  if (SIRInstruction* o
                      = dynamic_cast<SIRInstruction*>(lastCPInstr->GetOperand(i))) {
                    if (o->GetParent() == bb) {
                      int s = ct - o->GetTargetData()->GetIssueTime();
                      int l = o->GetTargetData()->GetLatency();
                      if (s < l) { lPadding = max(lPadding, l-s); }
                    }// if (o->GetParent() == bb)
                  }// if (SIRInstruction* o=dynamic_cast<SIRInstruction*>(c->GetOperand(i)))
                }// for i = 0 to c->operand_size()-1
                BaselineBlockData::iterator lpIt = brIt; --lpIt;
                for (int i = 0; i < lPadding; ++i) { bData->InsertNOPBefore(lpIt); }
              }// if (lastCPInstr)
            }// if (cPad)
            if (pPad) {
              (*lastIt)->RemoveInstr(lastPEInstr);
              if (SIRInstruction* brPInstr = (*brIt)->GetInstr(BaselineBasicInfo::PE)) {
                bData->InsertBefore(brIt, brPInstr);
              }
              (*brIt)->SetInstr(lastPEInstr, BaselineBasicInfo::PE);
            }// if (pPad)
          } else { bData->InsertNOPBefore(bData->end()); }
        } else { bData->InsertNOPBefore(bData->end());}
      }// if (sPadding < BlockPaddingCost(bb))
    }// if (pad)
  }// for func iterator bIt
  return change;
}// CrossBlockTimingCheck::RunOnSIRFunction()

bool TargetAddressPass::
RunOnSIRModule(SIRModule* m) {
  int addr = 0;
  for (SIRModule::iterator fIt = m->begin(); fIt != m->end(); ++fIt) {
    SIRFunction* func = *fIt;
    func->GetTargetData()->SetTargetAddress(addr);
    for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
      (*bIt)->GetTargetData()->SetTargetAddress(addr);
      addr += (*bIt)->GetTargetData()->GetTargetSize();
    }
  }// for m iterator fIt
  return false;
}// RunOnSIRModule()
