#include "Simulation/SimProgramSection.hh"

using namespace std;
using namespace ES_SIMD;

SimProgramSection::
~SimProgramSection() {}// ~SimProgramSection()

ostream& ES_SIMD::
operator<<(ostream& o, const SimOperand& t) {
  switch(t.type_) {
  case SimOperandType::ContextValue: o <<"$("<< t.value_<<")";     break;
  case SimOperandType::IntImmediate: o << t.GetIntValue();         break;
  case SimOperandType::Flag:         o <<"$F("<< t.value_<<")";    break;
  case SimOperandType::Communication:o <<"$COMM("<< t.value_<<")"; break;
  default: o << "??"; break;
  }
  return o;
}

ostream& ES_SIMD::
operator<<(ostream&o, const SimOperation& t) {
  o << "@"<< t.address_;
  if (t.opcodes_.empty()) {
    o <<"<NOP>";
  } else {
    o <<"<";
    for(unsigned i = 0; i < t.opcodes_.size(); ++i) {
      if (i > 0)
        o << "-";
      o << TargetOpcode::GetString(t.opcodes_[i]);
    }
    for(unsigned i = 0; i < t.predicates_.size(); ++i) {
      o <<".P"<< t.predicates_[i].GetID();
    }
    o <<">";
  }// if (t.opcodes_.empty())
  if (!t.dstOperand_.empty()) {
    o << "  {";
    for (unsigned i = 0; i < t.dstOperand_.size(); ++i) {
      if (i > 0)
        o << ", ";
      o << t.dstOperand_[i];
    }
    o <<"}";
  }// if (!t.dstOperands_.empty())
  if (!t.srcOperand_.empty()) {
    o << (t.dstOperand_.empty() ? "   {" :" <= {");
    for (unsigned i = 0; i < t.srcOperand_.size(); ++i) {
      if (i > 0)
        o << ", ";
      o << t.srcOperand_[i];
    }
    o <<"}";
  }// if (!t.dstOperands_.empty())
  o <<"  ";
  if (t.binding_ != 0xFFFF)
    o <<"FU"<< t.binding_;
  o <<"[l="<<t.exeLatency_<<"]";
  return o;
}
////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD,SimOperandType,SIMOPERANDTYPE_ENUM)














