#include <iomanip>
#include <sstream>
#include "Utils/StringUtils.hh"
#include "BaselineInstruction.hh"
#include "BaselineInstructionPacket.hh"
#include "BaselineBasicInfo.hh"

using namespace std;
using namespace ES_SIMD;

BaselineInstruction::
BaselineInstruction(BaselineInstructionPacket& p, bool isPE)
  : TargetInstruction(p, isPE) {}

bool BaselineInstruction::
Valid() const {
  if (!this->TargetInstruction::Valid())
    return false;
  return true;
}// Valid()

std::ostream& BaselineInstruction::
Print(std::ostream& out) const {
  string ops;
  if (IsVectorInstr())
    ops = "v.";
  ops += TargetOpcode::GetString(GetOpcode());
  ToLowerCase(ops);
  stringstream ss;
  const BaselineBasicInfo& tgtInfo = dynamic_cast<
    const BaselineInstructionPacket&>(GetParent()).GetTargetInfo();
  TargetOpType_t ot = TargetOpcProperty::GetOperationType(GetOpcode());
  for (unsigned i = 0; i < GetNumDstOperands(); ++i) {
    if (i > 0)
      ss <<", ";
    if ((GetDstOperand(i).type_ == TargetOperandType::Bypass)
        && (GetDstOperand(i).value_ == -1)) {
      ss <<"--";
    } else {
      tgtInfo.PrintOperand(ss, GetDstOperand(i), GetType());
    }
  }
  for (unsigned i = 0; i < GetNumSrcOperands(); ++i) {
    if ((GetNumDstOperands() > 0) || (i > 0))
      ss <<", ";
    if (GetSrcOperand(i).type_ == TargetOperandType::IntImmediate) {
      if ((ot != TargetOpType::Branch) && (ot != TargetOpType::System)
          && (ot != TargetOpType::Immediate)) {
        ops += "i";
      }
      ss << GetSrcOperand(i).value_;
    } else if (GetSrcOperand(i).type_ == TargetOperandType::Label) {
      if ((ot != TargetOpType::Branch) && (ot != TargetOpType::System)
          && (ot != TargetOpType::Immediate)) {
        ops += "i";
      }
      ss <<"L"<< GetSrcOperand(i).value_;
    } else {
      tgtInfo.PrintOperand(ss, GetSrcOperand(i), GetType());
    }
  }
  for (pred_const_iterator pIt = pred_begin(); pIt != pred_end(); ++pIt) {
    ops += ".P" + Int2DecString(pIt->GetValue());
  }
  return out << setw(10) << left << ops <<"  "<< ss.str();
}// Print()

std::ostream& BaselineInstruction::
PrintASM(std::ostream& out, const Int2StrMap& syms) const {
  string ops;
  if (IsVectorInstr())
    ops = "v.";
  ops += TargetOpcode::GetString(GetOpcode());
  ToLowerCase(ops);
  stringstream ss;
  const BaselineBasicInfo& tgtInfo = dynamic_cast<
    const BaselineInstructionPacket&>(GetParent()).GetTargetInfo();
  TargetOpType_t ot = TargetOpcProperty::GetOperationType(GetOpcode());
  for (unsigned i = 0; i < GetNumDstOperands(); ++i) {
    if (i > 0)
      ss <<", ";
    if ((GetDstOperand(i).type_ == TargetOperandType::Bypass)
        && (GetDstOperand(i).value_ == -1)) {
      ss <<"--";
    } else {
      tgtInfo.PrintOperand(ss, GetDstOperand(i), GetType());
    }
  }
  for (unsigned i = 0; i < GetNumSrcOperands(); ++i) {
    if ((GetNumDstOperands() > 0) || (i > 0))
      ss <<", ";
    if (GetSrcOperand(i).type_ == TargetOperandType::IntImmediate) {
      if ((ot != TargetOpType::Branch) && (ot != TargetOpType::System)
          && (ot != TargetOpType::Immediate)) {
        ops += "i";
      }
      ss << dec << GetSrcOperand(i).value_;
    } else if (GetSrcOperand(i).type_ == TargetOperandType::Label) {
      if ((ot != TargetOpType::Branch) && (ot != TargetOpType::System)
          && (ot != TargetOpType::Immediate)) {
        ops += "i";
      }
      if (IsElementOf(GetSrcOperand(i).value_, syms)) {
        ss << syms.find(GetSrcOperand(i).value_)->second;
      } else {
        ss <<"L"<< dec << GetSrcOperand(i).value_;
      }
    } else {
      tgtInfo.PrintOperand(ss, GetSrcOperand(i), GetType());
    }
  }
  for (pred_const_iterator pIt = pred_begin(); pIt != pred_end(); ++pIt) {
    ops += ".P" + Int2DecString(pIt->GetValue());
  }
  return out << setw(10) << left << ops <<"  "<< ss.str();
  //return out << ss.str();
}// PrintASM()
