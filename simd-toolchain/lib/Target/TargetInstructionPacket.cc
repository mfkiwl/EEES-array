#include "Target/TargetInstructionPacket.hh"
#include "Target/TargetInstruction.hh"

using namespace std;
using namespace ES_SIMD;

TargetInstructionPacket::
~TargetInstructionPacket() {
  for (iterator it = instrs_.begin(); it != instrs_.end(); ++it) {
    delete *it;
    *it = NULL;
  }
}// ~TargetInstructionPacket()

bool TargetInstructionPacket::
Valid() const {
  for (const_iterator it = instrs_.begin(); it != instrs_.end(); ++it) {
    if ((*it != NULL) && !(*it)->Valid())
      return false;
  }
  return true;
}// Valid()

std::ostream& TargetInstructionPacket::
Print(std::ostream& out) const {
  for (const_iterator it = instrs_.begin(); it != instrs_.end(); ++it) {
    if (*it != NULL) {
      if (it != instrs_.begin())
        out <<" || ";
      (*it)->Print(out);
    }
  }
  return out;
}// Print()

std::ostream& TargetInstructionPacket::
PrintASM(std::ostream& out, const Int2StrMap& syms) const {
  for (const_iterator it = instrs_.begin(); it != instrs_.end(); ++it) {
    if (*it != NULL) {
      if (it != instrs_.begin())
        out <<"    || ";
      else
        out <<"       ";
      (*it)->PrintASM(out, syms);
      out <<"\n";
    }
  }
  return out;
}// Print()
