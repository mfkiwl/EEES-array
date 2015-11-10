#include "SIR/SIRValue.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRInstruction.hh"

using namespace std;
using namespace ES_SIMD;

int SIRValue::ValueCounter = 0;

SIRValue::~SIRValue() {
  for (std::set<SIRValue*>::iterator it = children_.begin();
       it != children_.end(); ++it) { delete *it; }
}

bool SIRValue::
IsVectorValue() const {
  if (SIRInstruction::classof(this)) {
    return static_cast<const SIRInstruction*>(this)->IsVectorInstr();
  }
  if (SIRRegister::classof(this)) {
    return static_cast<const SIRRegister*>(this)->IsVector();
  }
  return false;
}// IsVectorValue()

void SIRValue::AddChild(SIRValue* v) {  children_.insert(v); }

bool SIRValue::EqualsTo(const SIRValue* v) const {
  if(ValueEqual(v)) { return true; }
  if (SIRInstruction::classof(v)) {
    const SIRInstruction* ins = static_cast<const SIRInstruction*>(v);
    if ((ins->GetSIROpcode() == SIROpcode::MOV)
      || (ins->GetTargetOpcode() == TargetOpcode::MOV)) {
      return ins->GetOperand(0)->EqualsTo(v);
    }
  }// if (SIRInstruction::classof(v))
  return false;
}

ostream& SIRValue::
Print(ostream& o) const {
  o <<"SIRValue<"<< dec << uid_ << ">";
  if (!name_.empty()) { o <<"("<< name_ <<")"; }
  return o;
}// Print()

ostream& SIRValue::
SIRPrettyPrint(ostream& o) const {
  if (!name_.empty()) { o << name_; }
  return o;
}

ostream& SIRValue::
TargetPrettyPrint(ostream& o) const { return SIRPrettyPrint(o); }

ostream& SIRValue::
ValuePrint(ostream& o) const { return o<<"<V_"<< valueID_<<">"; }

ostream& SIRValue::
PrintValueTree(std::ostream& o, const string& p) const {
  if (valueID_ >= 0)  { o << p <<"<V_"<< valueID_<<">"; }
  if (!name_.empty()) { o <<"("<< getKindName() <<":"<< name_ <<")"; }
  return o;
}// ValueTreePrint()

void SIRValue::
Dump(Json::Value& val) const {
  val["UID"]  = uid_;
  if (valueID_ >= 0)  { val["VID"] = valueID_; }
  if (!name_.empty()) { val["name"] = name_;   }
  val["kind"] = getKindName();
}// Dump()

std::ostream& ES_SIMD::
operator<<(std::ostream& o, const SIRValue& v) {  return v.Print(o); }

void ES_SIMD::
push_back_uid(std::vector<SIRValue*>& cont, SIRValue* val) {
  for (std::vector<SIRValue*>::iterator it = cont.begin();
       it != cont.end(); ++it) {
    if (*it && val && (*it)->GetUID() == val->GetUID()) { return; }
  }
  cont.push_back(val);
}

void ES_SIMD::
push_back_uval(std::vector<SIRValue*>& cont, SIRValue* val) {
  for (std::vector<SIRValue*>::iterator it = cont.begin();
       it != cont.end(); ++it) {
    if (*it && val && (*it)->GetValueID() == val->GetValueID()) { return; }
  }
  cont.push_back(val);
}
