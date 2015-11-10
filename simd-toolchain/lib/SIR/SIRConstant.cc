#include "SIR/SIRConstant.hh"

using namespace std;
using namespace ES_SIMD;

SIRConstant::
~SIRConstant() {}

ostream& SIRConstant::
Print(ostream& o) const {
  if (type_ == Symbol) {
    o << symbol_;
  } else if (type_ == Immediate) {
    o << immediate_;
  } else {
    SIRValue::Print(o);
  }
  return o;
}// Print

bool SIRConstant::
EqualsTo(const SIRValue* v) const {
  if (v && (v->GetUID() == GetUID())) { return true; }
  if (v && classof(v)) {
    const SIRConstant* vc = static_cast<const SIRConstant*>(v);
    if (vc->type_ == type_) {
      if (type_ == Symbol) {
        return vc->symbol_ == symbol_;
      } else if (type_ == Immediate) {
        return vc->immediate_ == immediate_;
      }
    }
  }// if (classof(v))
  return false;
}// EqualsTo()

ostream& SIRConstant::ValuePrint(ostream& o) const { return Print(o); }

ostream& SIRConstant::
PrintValueTree(std::ostream& o, const string& p) const {
  o << p <<"Const<";
  Print(o);
  return o<<">";
}// PrintValueTree()

bool SIRConstant::
GetImmediate(const SIRValue* op, int& imm) {
  if ((op != NULL) && SIRConstant::classof(op)) {
    const SIRConstant* c = static_cast<const SIRConstant*>(op);
    if (c->IsImmediate()) {
      imm = c->GetImmediate();
      return true;
    }
  }
  return false;
}
