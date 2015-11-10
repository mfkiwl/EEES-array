#include "BaselineCodeGenEngine.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineInstrData.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetModuleData.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/StringUtils.hh"
#include <llvm/Support/Casting.h>

using namespace std;
using namespace ES_SIMD;

static SIRBasicBlock::iterator ExpandSelect(SIRBasicBlock::iterator iIt,
                                            SIRFunction* func) {
  SIRInstruction* instr = *iIt;
  SIRBasicBlock* p = instr->GetParent();
  SIROpcode_t irOpc = instr->GetSIROpcode();
  TargetOpcode_t cmpOp = GetTargetCompareOpcode(irOpc);
  SIRValue* lhs  = instr->GetOperand(0);
  SIRValue* rhs  = instr->GetOperand(1);
  int vIdx = (GetSIROpNumInput(irOpc) == 2) ? 0 : 2;
  SIRValue* tVal = instr->GetOperand(vIdx);
  SIRValue* fVal = instr->GetOperand(vIdx + 1);
  SIRInstruction* cmpInstr = new SIRInstruction(
    cmpOp, p, instr->IsVectorInstr());
  cmpInstr->AddOperand(lhs);
  cmpInstr->AddOperand(rhs);
  cmpInstr->SetName("p0");
  cmpInstr->SetValueID(func->AllocateFlag());
  SIRInstruction* cmovInstr = new SIRInstruction(
    TargetOpcode::CMOV, p, instr->IsVectorInstr());
  cmovInstr->AddOperand(cmpInstr);
  cmovInstr->AddOperand(tVal);
  cmovInstr->AddOperand(fVal);
  std::vector<SIRInstruction*> cons;
  for (SIRValue::use_iterator uIt = instr->use_begin();
       uIt != instr->use_end(); ++uIt) {
    if (llvm::isa<SIRInstruction>(*uIt)) {
      cons.push_back(llvm::cast<SIRInstruction>(*uIt));
    }
  }
  for (unsigned i = 0; i < cons.size(); ++i) {
    cons[i]->ReplaceOperand(instr, cmovInstr);
  }
  cmovInstr->SetName(instr->GetName());
  cmovInstr->SetValueID(instr->GetValueID());
  SIRBasicBlock::iterator iit = p->insert(iIt, cmovInstr);
  p->insert(iit, cmpInstr);
  return p->erase(iIt);
}// ExpandSelect()

static SIRBasicBlock::iterator ExpandCondBranch(SIRBasicBlock::iterator iIt,
                                                SIRFunction* func) {
  SIRInstruction* instr = *iIt;
  SIRBasicBlock* p = instr->GetParent();
  SIROpcode_t irOpc = instr->GetSIROpcode();
  TargetOpcode_t cmpOp = GetTargetCompareOpcode(irOpc);
  ES_ASSERT_MSG(instr->operand_size() == 3, "SIR conditional branch should have"
                " three inputs");
  SIRValue* lhs = instr->GetOperand(0);
  SIRValue* rhs = instr->GetOperand(1);
  SIRValue* tgt = instr->GetOperand(2);
  ES_ASSERT_MSG(!instr->IsVectorInstr(), "Branch on PE");
  SIRInstruction* cmpInstr = new SIRInstruction(
    cmpOp, p, instr->IsVectorInstr());
  cmpInstr->AddOperand(lhs);
  cmpInstr->AddOperand(rhs);
  cmpInstr->SetName("p0");
  cmpInstr->SetValueID(func->AllocateFlag());
  SIRInstruction* brInstr = new SIRInstruction(
    TargetOpcode::BF, p, instr->IsVectorInstr());
  brInstr->AddOperand(cmpInstr);
  brInstr->AddOperand(tgt);
  SIRBasicBlock::iterator iit = p->insert(iIt, brInstr);
  p->insert(iit, cmpInstr);
  // There should be no consumer, so just insert the new instruction is fine
  return p->erase(iIt);
}// ExpandSelect()

// sign-extended load (lbs, lhs) is expanded to two shifts and one load
static SIRBasicBlock::iterator
ExpandSExtLoad(SIRBasicBlock::iterator iIt, SIRFunction* func, int dwidth) {
  SIRInstruction* instr = *iIt;
  TargetOpcode_t opc = TargetOpcode::TargetOpcodeEnd;
  int s = dwidth;
  switch (instr->GetSIROpcode()) {
  case SIROpcode::LBS: opc = TargetOpcode::LB; s -= 8;  break;
  case SIROpcode::LHS: opc = TargetOpcode::LH; s -= 16; break;
  default: return ++iIt;
  }
  instr->SetTargetOpcode(opc);
  if (s == 0) { return ++iIt; }
  std::vector<SIRInstruction*> cons;
  for (SIRValue::use_iterator uIt = instr->use_begin();
       uIt != instr->use_end(); ++uIt) {
    if (llvm::isa<SIRInstruction>(*uIt)) {
      cons.push_back(llvm::cast<SIRInstruction>(*uIt));
    }
  }
  bool vec = instr->IsVectorInstr();
  int val = instr->GetValueID();
  SIRBasicBlock* p = instr->GetParent();
  SIRInstruction* shl = new SIRInstruction(TargetOpcode::SLL, p, vec);
  shl->AddOperand(instr).AddOperand(func->GetParent()->AddOrGetImmediate(s));
  shl->SetValueID(func->AllocateValue());
  SIRInstruction* shr = new SIRInstruction(TargetOpcode::SRA, p, vec);
  shr->AddOperand(shl).AddOperand(func->GetParent()->AddOrGetImmediate(s));
  shr->SetValueID(val);
  instr->SetValueID(func->AllocateValue());
  for (unsigned i = 0; i < cons.size(); ++i) {
    cons[i]->ReplaceOperand(instr, shr);
  }
  for (SIRFunction::cs_iterator cIt = func->cs_begin();
       cIt != func->cs_end(); ++cIt) { (*cIt)->ReplaceArgument(instr, shr); }
  SIRBasicBlock::iterator iit = p->insert(++iIt, shr);
  iit = p->insert(iit, shl);
  return ++iit;
}// ExpandSExtLoad()

static void ExpandLoadStore(
  SIRBasicBlock::iterator iIt, SIRFunction* func) {
  SIRInstruction* instr = *iIt;
  TargetOpcode_t opc = instr->GetTargetOpcode();
  if (!IsTargetMemoryOp(opc)) { return; }
  unsigned oIdx = IsTargetStore(opc) ? 2 : 1;
  SIRValue* offsetValue = instr->GetOperand(oIdx);
  if (llvm::isa<SIRConstant>(offsetValue)) { return; }
  int bIdx = IsTargetStore(opc) ? 1 : 0;
  SIRValue* baseValue = instr->GetOperand(bIdx);
  bool vect = baseValue->IsVectorValue() || offsetValue->IsVectorValue();
  SIRInstruction* agInstr = new SIRInstruction(
    TargetOpcode::ADD, instr->GetParent(), vect);
  instr->GetParent()->insert(iIt, agInstr);
  agInstr->AddOperand(baseValue);
  agInstr->AddOperand(offsetValue);
  agInstr->SetValueID(func->AllocateValue());
  agInstr->SetName("w"+Int2DecString(agInstr->GetValueID()));
  SIRConstant* zero = func->GetParent()->AddOrGetImmediate(0);
  instr->ChangeOperand(bIdx, agInstr);
  instr->ChangeOperand(oIdx, zero);
  return;
}// ExpandLoadStore()

static void AdjustStoreOperands(SIRInstruction* instr) {
  ES_ASSERT_MSG(IsTargetStore(instr->GetTargetOpcode()),
                "Trying to adjust operands of a non-store instruction");
  SIRValue* dst  = instr->GetOperand(0);
  SIRValue* base = instr->GetOperand(1);
  instr->ChangeOperand(0, NULL);
  instr->ChangeOperand(1, NULL);
  instr->ChangeOperand(0, base);
  instr->ChangeOperand(1, dst);
}// AdjustStoreOperands()

/// "y = x - imm" should be transform to "y = x + (-imm)" as "sub y, x, imm"
/// is not supported in baseline.
static void ConvertSubImm(SIRInstruction* instr) {
  SIRValue* opA = instr->GetOperand(0);
  SIRValue* opB = instr->GetOperand(1);
  if (!SIRConstant::classof(opB) || SIRConstant::classof(opA)) { return; }
  SIRConstant* c = static_cast<SIRConstant*>(opB);
  int ival = c->GetImmediate();
  SIRConstant* nc = instr->GetParent()->GetParent()->GetParent()
    ->AddOrGetImmediate(-ival);
  instr->SetTargetOpcode(TargetOpcode::ADD);
  instr->ChangeOperand(1, NULL);
  instr->ChangeOperand(1, nc);
}// ConvertSubImm()

static SIRBasicBlock::iterator
BaselineTranslateSIRInstr(SIRBasicBlock::iterator iIt, SIRBasicBlock* bb,
                          const BaselineBasicInfo& target) {
  if (iIt == bb->end())
    return iIt;
  SIRInstruction* instr = *iIt;
  SIROpcode_t irOpc = instr->GetSIROpcode();
  SIRFunction* func = bb->GetParent();
  if (instr->IsVectorInstr()) {
    // This is PE operation
    TargetOpcode_t tOpc = target.TranslatePEOpcode(irOpc);
    if (tOpc != TargetOpcode::TargetOpcodeEnd) { instr->SetTargetOpcode(tOpc); }
    else if (IsSIRSelect(irOpc))   { return ExpandSelect(iIt, func); }
    else if (IsSIRSExtLoad(irOpc)) {
      return ExpandSExtLoad(iIt, func, target.GetPEDataWidth());
    }
  } else {// if (instr->IsVectorInstr())
    // This is CP operation
    TargetOpcode_t tOpc = target.TranslateCPOpcode(irOpc);
    if (tOpc != TargetOpcode::TargetOpcodeEnd) { instr->SetTargetOpcode(tOpc); }
    else if (IsSIRSelect(irOpc)) { return ExpandSelect(iIt, func); }
    else if (IsSIRCondBranch(irOpc)) { return ExpandCondBranch(iIt, func); }
    else if (IsSIRSExtLoad(irOpc)) {
      return ExpandSExtLoad(iIt, func, target.GetCPDataWidth());
    }
    if (tOpc == TargetOpcode::J) {
      SIRValue* btgt = instr->GetOperand(0);
      if (SIRInstruction::classof(btgt) || SIRRegister::classof(btgt)) {
        instr->SetTargetOpcode(TargetOpcode::JR);
      }
    }
  }// if (instr->IsVectorInstr())
  if (IsTargetMemoryOp(instr->GetTargetOpcode())) { ExpandLoadStore(iIt,func); }
  if (IsTargetStore(instr->GetTargetOpcode())) { AdjustStoreOperands(instr); }
  if (instr->GetTargetOpcode() == TargetOpcode::SUB) { ConvertSubImm(instr); }
  return ++iIt;
}// BaselineTranslateSIRInstr()

BaselineBlockTranslationPass::~BaselineBlockTranslationPass() {}

void BaselineBlockTranslationPass::
ModuleInit(SIRModule* m) { mData_ = m->GetTargetData(); }

void BaselineBlockTranslationPass::
FunctionInit(SIRFunction* func) { func->UpdateRegValueType(); }


bool BaselineBlockTranslationPass::
RunOnSIRBasicBlock(SIRBasicBlock* bb) {
  for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end();) {
    iIt = BaselineTranslateSIRInstr(iIt, bb, target_);
  }
  for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
    if (!(*iIt)->HasTargetOpcode()) {
      string opc = GetString((*iIt)->GetSIROpcode());
      errors_.push_back(
        Error(ErrorCode::SIRTranslationFailure,
              "Failed to translate \""+opc+"\"",(*iIt)->GetFileLocation()));
      break;
    }// if (!(*iIt)->HasTargetOpcode())
    mData_->InitTargetData(*iIt);
  }// for bb iterator iIt
  return true;
}// BaselineBlockTranslationPass::RunOnSIRBasicBlock()
