#include "DataTypes/ContainerTypes.hh"
#include "Target/TargetInstruction.hh"

using namespace std;
using namespace ES_SIMD;

TargetInstruction::
~TargetInstruction(){}

bool TargetInstruction::
Valid() const {
  if (!IsElementOf(opcode_, TargetOpcProperty::targetOpProp))
    return false;
  for (unsigned i = 0; i < predicates_.size(); ++i) {
    if (predicates_[i].GetType() != TargetOperandType::Predicate) {
      return false;
    }
  }
  const TargetOpcProperty& prop = TargetOpcProperty::targetOpProp[opcode_];
  if (srcOperands_.size() != prop.numOfInput_) { return false; }
  if (dstOperands_.size() != prop.numOfOutput_) {
    if (!IsTargetCompare(opcode_) || (dstOperands_.size() != 1)
        || (dstOperands_[0].GetType() != TargetOperandType::Predicate)) {
      return false;
    }
  }// if (dstOperands_.size() != prop.numOfOutput_)
  return true;
}// Valid()

TargetInstruction& TargetInstruction::
AppendOperand(TargetOperand o) {
  if (dstOperands_.size() < TargetOpcProperty::GetNumOfOutput(opcode_)) {
    dstOperands_.push_back(o);
  } else if (IsTargetCompare(opcode_)
             && (o.GetType() == TargetOperandType::Predicate)) {
    dstOperands_.push_back(o);
  } else {
    srcOperands_.push_back(o);
  }
  return *this;
}

std::ostream& TargetInstruction::
Print(std::ostream& out) const {
  out << opcode_;
  return out;
}// Print()

std::ostream& TargetInstruction::
PrintASM(std::ostream& out, const Int2StrMap& syms) const {
  out << opcode_;
  return out;
}// Print()


////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD,TargetInstrType,TARGETINSTRTYPE_ENUM)
