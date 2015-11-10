#include "SIR/SIRRegister.hh"
#include "SIR/SIRFunction.hh"
#include "llvm/Support/Casting.h"

using namespace std;
using namespace ES_SIMD;

SIRRegister::
~SIRRegister() {}

ostream& SIRRegister::
Print(ostream& o) const { return o << "%" << name_; }

ostream& SIRRegister::
ValuePrint(std::ostream& o) const {
  o<<"<V_"<< valueID_ <<">";
  if (HasName()) { o << "(%"<< name_ <<")"; }
  return o;
}// ValuePrint()

ostream& SIRRegister::
PrintValueTree(std::ostream& o, const string& p) const {
  if (valueID_ >= 0)  { o << p <<"<V_"<< valueID_<<">"; }
  if (SIRFunction* func = dynamic_cast<SIRFunction*>(parent_)) {
    if (func->IsArgumentValue(valueID_)) { o <<":ARG"; }
  }
  if (!name_.empty()) { o <<"("<< name_ <<")"; }
  if (isVector_) { o <<"[v]"; }
  return o;
}// ValueTreePrint()
