#include "Target/TargetInstrData.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "Utils/DbgUtils.hh"

#include <limits>
#include <sstream>

using namespace std;
using namespace ES_SIMD;

TargetInstrData::TargetInstrData(SIRInstruction* instr)
  : instr_(instr), issueTime_(-1), latency_(0) , destPhyReg_(-1) {
  operandPhyReg_.resize(instr->operand_size(), -1);
}

TargetInstrData::~TargetInstrData() {}

void TargetInstrData::ResetOperandInfo() {
  operandPhyReg_.resize(instr_->operand_size(), -1);
}

void TargetInstrData::
ResetPhyReg() {
  fill(operandPhyReg_.begin(), operandPhyReg_.end(), -1);
  destPhyReg_ = -1;
}// ResetPhyReg()

void TargetInstrData::
SwapOperand(unsigned a, unsigned b) {
  if ((a > operandPhyReg_.size())||(b > operandPhyReg_.size())) { return; }
  swap(operandPhyReg_[a],   operandPhyReg_[b]);
}

static bool IsZero(SIRValue* val, SIRFunction* func) {
  if (SIRConstant::classof(val)) {
    SIRConstant* c = static_cast<SIRConstant*>(val);
    return !c->IsSymbol() && (c->GetImmediate() == 0);
  } else if (SIRRegister::classof(val)) {
    return val->GetValueID() == func->GetZeroRegister()->GetValueID();
  }
  return false;
}

bool TargetInstrData::
IsTargetCopy() const {
  TargetOpcode_t top = instr_->GetTargetOpcode();
  if (top == TargetOpcode::MOV) { return true; }
  SIRFunction* func = instr_->GetParent()->GetParent();
  if ((top == TargetOpcode::ADD) || (top == TargetOpcode::OR)) {
    if (IsZero(instr_->GetOperand(0), func)
        || IsZero(instr_->GetOperand(1), func)) { return true; }
  }// if ((top == TargetOpcode::ADD) || (top == TargetOpcode::OR))
  return false;
}// IsTargetCopy()

int TargetInstrData::
GetDistance(const SIRInstruction* instr) const {
  if (instr == instr_) { return 0; }
  ES_ASSERT_MSG(instr->GetTargetData(), "Not initialized for target: "<<*instr);
  // The same block
  if (instr->GetParent() == instr_->GetParent()) {
    return GetIssueTime() - instr->GetTargetData()->GetIssueTime();
  }
  ES_NOTIMPLEMENTED("Distance between arbitrary instructions");
  // The same function, different blocks
  if (instr->GetParent()->GetParent() == instr_->GetParent()->GetParent()) {
  }// if (instr->GetParent()->GetParent() == instr_->GetParent()->GetParent())
  // instr is in an other function
  // const SIRFunction *func  = instr_->GetParent()->GetParent();
  // const SIRFunction *iFunc = instr->GetParent()->GetParent();
  return numeric_limits<int>::max();
}// GetDistance()

std::string TargetInstrData::
GetAsmString() const {
  stringstream ss;
  Print(ss);
  return ss.str();
}

void TargetInstrData::
Dump(Json::Value& iInfo) const {
  iInfo["asm"] = GetAsmString();
}// Dump()
