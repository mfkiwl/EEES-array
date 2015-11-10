#include "Utils/StringUtils.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRMemLocation.hh"
#include "llvm/Support/Casting.h"
#include <iomanip>

using namespace std;
using namespace ES_SIMD;

SIRInstruction::
SIRInstruction(SIROpcode_t opcode, SIRBasicBlock* bb, bool isKernel)
  : SIRValue(SIRValue::VK_Instruction), parent_(bb),
    opcode_(static_cast<unsigned>(opcode)),
    type_(isKernel ? IT_Vector : IT_Scalar), memoryLoacation_(0),
    targetData_(NULL), memLocationInfo_(NULL) {}

SIRInstruction::
SIRInstruction(TargetOpcode_t opcode, SIRBasicBlock* bb,
               bool isKernel)
  : SIRValue(SIRValue::VK_Instruction), parent_(bb),
    opcode_(static_cast<unsigned>(opcode)),
    type_(isKernel ? IT_Vector : IT_Scalar), memoryLoacation_(0),
    targetData_(NULL), memLocationInfo_(NULL) {}

SIRInstruction::
SIRInstruction(unsigned opcode, SIRBasicBlock* bb, bool isKernel)
  : SIRValue(SIRValue::VK_Instruction), parent_(bb),
    opcode_(opcode), type_(isKernel?IT_Vector:IT_Scalar), memoryLoacation_(0),
    targetData_(NULL), memLocationInfo_(NULL) {}

SIRInstruction::
~SIRInstruction() { delete memLocationInfo_; }

bool SIRInstruction::
IsBroadcasting() const {
  if (!IsVectorInstr() && (use_size() == 1)
      && SIRInstruction::classof(*use_begin())
      && static_cast<SIRInstruction*>(*use_begin())->IsVectorInstr()) {
    return true;
  }
  return false;
}// IsBroadcasting()

SIRValue*  SIRInstruction::
GetBranchTarget() const {
  if (!IsSIRBranch(GetSIROpcode()) && !IsTargetBranch(GetTargetOpcode())) {
    return NULL;
  }
  return operands_.back();
}// GetBranchTarget()

SIRFunction* SIRInstruction::
GetCallTarget() const {
  if ((GetSIROpcode() != SIROpcode::CALL)
      && (GetTargetOpcode() != TargetOpcode::JAL)) { return NULL; }
  return SIRFunction::classof(operands_[0]) ?
    static_cast<SIRFunction*>(operands_[0]) : NULL;
}// GetCallTarget()

bool SIRInstruction::
UsesValue(const SIRValue* v) const {
  if (v == NULL) { return false; }
  return UsesValue(v->GetValueID());
}// UsesValue()

bool SIRInstruction::
UsesValue(int v) const {
  if (v < 0) { return false; }
  for (unsigned i = 0; i < operands_.size(); ++i) {
    if (operands_[i]->GetValueID() == v) { return true; }
  }
  return false;
}// UsesValue()

int SIRInstruction::
UsedFlag() const {
  for (unsigned i = 0; i < operands_.size(); ++i) {
    if (SIRFunction::IsValidFlagID(operands_[i]->GetValueID())) {
      return operands_[i]->GetValueID();
    }
  }
  return -1;
}// UsedFlag()
int SIRInstruction::
DefinedFlag() const {
  return SIRFunction::IsValidFlagID(GetValueID()) ? GetValueID() : -1;
}// DefinedFlag()

void SIRInstruction::
RemoveOperand(unsigned idx) {
  if (idx > operands_.size()) { return; }
  SIRValue* oldOp = operands_[idx];
  for (int i = idx+1, e=operands_.size(); i < e; ++i) {
    operands_[i-1] = operands_[i];
  }
  operands_.pop_back();
  if (oldOp) {
    for (int i = idx+1, e=operands_.size(); i < e; ++i) {
      if (operands_[i] == oldOp) { return; }
    }
    // oldOp is no longer used by this, remove this from its use list
    oldOp->RemoveUse(this);
  }
}// RemoveOperand()

bool SIRInstruction::
PredicatedBy(const SIRValue* p) const {
  if (!HasPredicate() || !p) { return false; }
  for (unsigned i = 0; i < predicates_.size(); ++i) {
    if (p->GetValueID() == predicates_[i]->GetValueID()) { return true; }
  }
  return false;
}// PredicatedBy()

bool SIRInstruction::
UsedAsPredicate() const {
  if (!IsSIRCompare(GetSIROpcode()) && !IsTargetCompare(GetTargetOpcode())) {
    return false;
  }
  for (SIRValue::use_const_iterator it = use_begin(); it != use_end(); ++it) {
    if (!*it) { continue; }
    if (SIRBasicBlock::classof(*it) || SIRFunction::classof(*it)) {
      return true;
    } else if (llvm::isa<SIRInstruction>(*it)) {
      if (llvm::cast<SIRInstruction>(*it)->PredicatedBy(this)) { return true; }
    }
  }
  return false;
}// UsedAsPredicate()

void SIRInstruction::
AddPredicate(SIRValue* p) {
  if (!p) { return; }
  push_back_uval(predicates_, p);
  p->AddUse(this);
}// AddPredicate()

bool SIRInstruction::
PredicateValueEqual(const SIRInstruction* instr) const {
  if (!HasPredicate()) { return !instr->HasPredicate(); }
  if (predicate_size() == instr->predicate_size()) {
    // Predicates are unordered, so we need to check all
    for (int i=0, e=predicate_size(); i < e; ++i) {
      SIRValue* p = GetPredicate(i);
      if (!instr->PredicatedBy(p)) { return false; }
    }
    return true;
  }// if (predicate_size() == instr->predicate_size())
  return false;
}// PredicateValueEqual()

std::ostream& SIRInstruction::
Print(std::ostream& o) const {
  string opc;
  if (HasTargetOpcode())   { opc = GetString(GetTargetOpcode()); }
  else if (HasSIROpcode()) { opc = GetString(GetSIROpcode());    }
  ToLowerCase(opc);
  if (IsVectorInstr()) { opc = "v."+opc; }
  for (unsigned i = 0; i < predicates_.size(); ++i) {
    opc += ".P" + Int2DecString(predicates_[i]->GetValueID());
  }
  o << setw(20) << left << opc;
  if (valueID_ >=0) {
    if (!name_.empty()) { o << "%"<< name_; }
    else { o << "%w" << valueID_; }
    if (!operands_.empty()) { o <<", "; }
  }
  for (std::vector<SIRValue*>::const_iterator it = operands_.begin();
       it != operands_.end(); ++it) {
    if (it != operands_.begin())
      o <<", ";
    const SIRValue* op = *it;
    if (llvm::isa<SIRInstruction>(op)) {
      o <<"%"<< op->GetName();
    } else if (llvm::isa<SIRFunction>(op) || llvm::isa<SIRBasicBlock>(op)) {
      o << op->GetName();
    } else {
      o << left << *op;
    }
  }// for operands_ iterator it
  return o;
}// Print()

std::ostream& SIRInstruction::
SIRPrettyPrint(std::ostream& o) const {
  SIROpcode_t opcode = static_cast<SIROpcode_t>(opcode_);
  string opc = GetString(opcode);
  ToLowerCase(opc);
  if (IsVectorInstr()) { opc = "v."+opc; }
  for (unsigned i = 0; i < predicates_.size(); ++i) {
    opc += ".P" + Int2DecString(predicates_[i]->GetValueID());
  }
  o << setw(20) << left << opc;
  if (GetSIROpNumOutput(opcode) > 0) {
    if (!name_.empty()) { o << "%"<< name_; }
    else { o << "%w" << valueID_; }
    if (!operands_.empty())
      o <<", ";
  }
  for (std::vector<SIRValue*>::const_iterator it = operands_.begin();
       it != operands_.end(); ++it) {
    if (it != operands_.begin())
      o <<", ";
    const SIRValue* op = *it;
    if (llvm::isa<SIRInstruction>(op)) {
      o <<"%"<< op->GetName();
    } else if (llvm::isa<SIRFunction>(op) || llvm::isa<SIRBasicBlock>(op)) {
      o << op->GetName();
    } else {
      o << left << *op;
    }
  }// for operands_ iterator it
  return o;
}// SIRPrettyPrint()

std::ostream& SIRInstruction::
TargetPrettyPrint(std::ostream& o) const {
  if (!HasTargetOpcode()&&HasSIROpcode()) {return SIRPrettyPrint(o) <<"<SIR>";}
  TargetOpcode_t opcode
    = static_cast<TargetOpcode_t>(opcode_);
  string opc = GetString(opcode);
  ToLowerCase(opc);
  if (IsVectorInstr()) { opc = "v."+opc; }
  for (unsigned i = 0; i < predicates_.size(); ++i) {
    opc += ".P" + Int2DecString(predicates_[i]->GetValueID());
  }
  o << setw(20) << left << opc;
  if (GetTargetOpNumOutput(opcode) > 0) {
    if (!name_.empty()) { o << "%"<< name_; }
    else { o << "%w" << valueID_; }
    if (!operands_.empty()) { o <<", "; }
  } else if (UsedAsPredicate()) {
    o <<"P"<< GetValueID();
    if (!operands_.empty()) { o <<", "; }
  }
  for (std::vector<SIRValue*>::const_iterator it = operands_.begin();
       it != operands_.end(); ++it) {
    if (it != operands_.begin())
      o <<", ";
    const SIRValue* op = *it;
    if (llvm::isa<SIRInstruction>(op)) {
      o <<"%"<< op->GetName();
    } else if (llvm::isa<SIRFunction>(op) || llvm::isa<SIRBasicBlock>(op)) {
      o << op->GetName();
    } else {
      o << left << *op;
    }
  }// for operands_ iterator it
  return o;
}// TargetPrettyPrint()

std::ostream& SIRInstruction::
ValuePrint(std::ostream& o) const {
  int nOut = 0;
  string opc;
  if (!HasTargetOpcode() && HasSIROpcode()) {
    SIROpcode_t opcode = static_cast<SIROpcode_t>(opcode_);
    opc = GetString(opcode);
    nOut = GetSIROpNumOutput(opcode);
  } else {
    TargetOpcode_t opcode = static_cast<TargetOpcode_t>(opcode_);
    opc = GetString(opcode);
    nOut = GetTargetOpNumOutput(opcode);
    if ((nOut == 0) && IsTargetCompare(opcode)) {
      nOut = 1;
    }
  }
  ToLowerCase(opc);
  if ( valueID_ >= 0) {
    o <<"V_"<< valueID_;
    if (!name_.empty() && (name_[0] != 'r') && name_[0] != 'w') {
      o << "("<< name_<<")";
    };
    o<<" = ";
  }
  if (IsVectorInstr()) { o << "v."; }
  o << opc <<"  ";
  for (std::vector<SIRValue*>::const_iterator it = operands_.begin();
       it != operands_.end(); ++it) {
    if (it != operands_.begin())
      o <<", ";
    const SIRValue* op = *it;
    if (SIRInstruction::classof(op) || SIRRegister::classof(op)) {
      o<<"V_"<< op->GetValueID();
      const string& oName = op->GetName();
      if ((oName.size() > 0) && (oName[0] != 'r') && (oName[0] != 'w')) {
        o <<'('<< op->GetName()<<')';
      }
    } else if (llvm::isa<SIRFunction>(op) || llvm::isa<SIRBasicBlock>(op)) {
      o << op->GetName();
    } else { op->ValuePrint(o);}
  }// for operands_ iterator it
  return o;
}// ValuePrint()

ostream& SIRInstruction::
PrintValueTree(std::ostream& o, const string& p) const {
  SIRValue::PrintValueTree(o, p) <<"[";
  if (HasSIROpcode()) { o << GetSIROpcode() <<"]\n"; }
  else {  o << GetTargetOpcode()<<"]\n"; }
  for (unsigned i = 0; i < operands_.size(); ++i) {
    operands_[i]->PrintValueTree(o, p+"---");
    o<<"\n";
  }
  return o;
}// PrintValueTree()

void SIRInstruction::
Dump(Json::Value& info) const {
  if (HasSIROpcode()) { info["opcode"] = GetString(GetSIROpcode());    }
  else                { info["opcode"] = GetString(GetTargetOpcode()); }
  if (GetValueID() >= 0) { info["value"] = GetValueID(); }
}// Dump()
