#include "Target/TargetBinaryProgram.hh"
#include "Target/TargetInstructionPacket.hh"

using namespace std;
using namespace ES_SIMD;

TargetBinaryProgram::
~TargetBinaryProgram() {
  for (iterator it = binaryInstrs_.begin(); it != binaryInstrs_.end(); ++it) {
    delete *it;
    *it = NULL;
  }
}// ~TargetBinaryProgram()

bool TargetBinaryProgram::
Valid() const {
  for (const_iterator it = binaryInstrs_.begin(); it != binaryInstrs_.end(); ++it) {
    if ((*it != NULL) && !(*it)->Valid())
      return false;
  }
  return true;
}// ~TargetBinaryProgram()

bool TargetBinaryProgram::
ResolveSymbols() {
  return true;
}

bool TargetBinaryProgram::
PrepBinary() {
  return ResolveSymbols();
}// PrepBinary()

std::ostream& TargetBinaryProgram::
Print(std::ostream& out) const {
  for (const_iterator pIt = binaryInstrs_.begin();
       pIt != binaryInstrs_.end(); ++pIt) {
    if (*pIt != NULL) {
      int addr = (*pIt)->GetIndex();
      if (IsElementOf(addr, addr2SymID_)) {
        const IntSet& symSet = addr2SymID_.find(addr)->second;
        for (IntSet::const_iterator sIt = symSet.begin();
             sIt != symSet.end(); ++sIt) {
          out << id2symbol_.find(*sIt)->second <<":\n";
        }
      }// if (IsElementOf(addr, addr2SymID_))
      out <<"    ";
      (*pIt)->Print(out) <<"\n";
    } else {
      out << "    nop\n";
    }
  }
  return out;
}// Print

std::ostream& TargetBinaryProgram::
PrintASM(std::ostream& out) const {
  for (const_iterator pIt = binaryInstrs_.begin();
       pIt != binaryInstrs_.end(); ++pIt) {
    if (*pIt != NULL) {
      int addr = (*pIt)->GetIndex();
      if (IsElementOf(addr, addr2SymID_)) {
        const IntSet& symSet = addr2SymID_.find(addr)->second;
        for (IntSet::const_iterator sIt = symSet.begin();
             sIt != symSet.end(); ++sIt) {
          out << id2symbol_.find(*sIt)->second <<":\n";
        }
      }// if (IsElementOf(addr, addr2SymID_))
      (*pIt)->PrintASM(out, id2symbol_);
    } else {
      out <<"       nop\n";
    }
  }
  return out;
}// PrintASM()

FileStatus_t TargetBinaryProgram::
SaveVerilogMemHex(const std::string& filename) const {
  return FileStatus::OK;
}
