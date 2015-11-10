#include "Target/TargetIssuePacket.hh"
#include "Target/TargetInstrData.hh"
#include "SIR/SIRInstruction.hh"
#include <sstream>
#include <iomanip>

using namespace ES_SIMD;
using namespace std;

void TargetIssuePacket::
SetIssueTime(int t) {
  issueTime_ = t;
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i]) { instrs_[i]->GetTargetData()->SetIssueTime(t); }
  }
}

int TargetIssuePacket::
GetIssueID(const SIRInstruction* instr) const {
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i] == instr) { return i;}
  }
  return -1;
}

bool TargetIssuePacket::
IsNOP() const {
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i] && !instrs_[i]->IsNOP()) { return false; }
  }
  return true;
}

bool TargetIssuePacket::
HasCall() const {
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i] && IsTargetCall(instrs_[i]->GetTargetOpcode())){return true;}
  }
  return false;
}

bool TargetIssuePacket::
HasBranch() const {
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i] && IsTargetBranch(instrs_[i]->GetTargetOpcode())) {
      return true;
    }
  }
  return false;
}

void TargetIssuePacket::
RemoveInstr(SIRInstruction* instr) {
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i] == instr) { instrs_[i] = NULL; }
  }
}

bool TargetIssuePacket::
DefinesValue(int v) const {
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i] && (instrs_[i]->GetValueID() == v)) { return true; }
  }
  return false;
}// DefinesValue()

SIRInstruction* TargetIssuePacket::
GetValueInstr(int v) const {
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i] && (instrs_[i]->GetValueID() == v)) { return instrs_[i]; }
  }
  return NULL;
}

bool TargetIssuePacket::
UsesValue(int v) const {
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i] && instrs_[i]->UsesValue(v)) { return true; }
  }
  return false;
}// UsesValue()

int TargetIssuePacket::
ValueUseCount(int v) const {
  int c = 0;
  for (int i =0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i] && instrs_[i]->UsesValue(v)) { ++c; }
  }
  return c;
}// UsesValue()

bool TargetIssuePacket::
ReplaceOperandValue(SIRValue* val) {
  int v = val->GetValueID();
  bool r = false;
  for (int i=0, e=instrs_.size(); i < e; ++i) {
    // FIXME: should it be broadcasting for PE?
    if (instrs_[i] && instrs_[i]->UsesValue(v)) {
      for (int j=0, je=instrs_[i]->operand_size(); j < je; ++j) {
        if (instrs_[i]->GetOperand(j)->GetValueID() == v) {
          instrs_[i]->ChangeOperand(j, val);
          r = true;
        }
      }
    }// if (instrs_[i] && instrs_[i]->UsesValue(v))
  }// for i = 0 to instrs_.size()-1
  return r;
}// ReplaceOperandValue()

void TargetIssuePacket::
Print(std::ostream& o) const {
  int n = 0;
  stringstream ss;
  for (int i=0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i]) {
      if (n++) { o <<"\n     || ";}
      else     { o <<  "        ";}
      ss.str(string());
      instrs_[i]->GetTargetData()->Print(ss);
      o << setw(40) << left << ss.str();
      TargetOpcode_t opc = instrs_[i]->GetTargetOpcode();
      if (!instrs_[i]->IsNOP()
          && (!IsTargetBranch(opc)
              || IsTargetCondBranch(opc) || IsTargetBranchReg(opc))) {
        o <<"  # "; instrs_[i]->ValuePrint(o);
      }
    }
  }
  if (!n) { o <<"        nop"; return; }
}// TargetIssuePacket::Print()

void TargetIssuePacket::
ValuePrint(std::ostream& o) const {
  int n = 0;
  for (int i=0, e=instrs_.size(); i < e; ++i) {
    if (instrs_[i]) {
      if (n++) { o <<"  ||  "; }
      instrs_[i]->ValuePrint(o);
    }
  }
  if (!n) { o <<"nop"; return; }
}// ValuePrint()

void TargetIssuePacket::
Dump(Json::Value& pInfo) const {
  pInfo["time"] = IssueTime();
  for (int i=0, e=instrs_.size(); i < e; ++i) {
    Json::Value iVal;
    if (instrs_[i]) {
    } else { iVal["opcode"] = "nop"; }
    pInfo["operations"].append(iVal);
  }
}// Dump()
