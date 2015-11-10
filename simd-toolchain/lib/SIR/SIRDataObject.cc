#include "SIR/SIRDataObject.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"

using namespace ES_SIMD;

SIRDataObject::~SIRDataObject() {}

bool SIRDataObject::
IsReferenced() const {
  for (SIRValue::use_const_iterator uIt=use_begin(); uIt != use_end(); ++uIt) {
    if (SIRFunction::classof(*uIt)
        && parent_->IsActiveFunction(static_cast<SIRFunction*>(*uIt)))
    {return true;}
    if (SIRBasicBlock::classof(*uIt)
        && parent_->IsActiveFunction(
          static_cast<SIRBasicBlock*>(*uIt)->GetParent())) { return true; }
    if (SIRInstruction::classof(*uIt)
        && parent_->IsActiveFunction(
          static_cast<SIRInstruction*>(*uIt)->GetParent()->GetParent()))
    { return true; }
    if (SIRDataObject::classof(*uIt)
        && static_cast<SIRDataObject*>(*uIt)->IsReferenced())
    { return true; }
  }
  return false;
  // return !use_empty();
}// IsReferenced()

void SIRDataObject::
AddInit(const std::string&s, SIRValue* v) {
  initSym_.push_back(std::make_pair(s, v));
  if (!v) { return; }
  if (SIRDataObject::classof(v)) {static_cast<SIRDataObject*>(v)->AddUse(this);}
}

std::ostream& SIRDataObject::
Print(std::ostream& o) const { return o<< name_; }

std::ostream& SIRDataObject::
ValuePrint(std::ostream& o) const { return o<< name_; }

std::ostream& SIRDataObject::
TargetPrettyPrint(std::ostream& o) const {
  o <<"        .type          "<< name_ <<", @object\n"
    <<"        .global        "<< name_ <<"\n"
    <<"        .address       "<< address_ <<"\n";
  if (init_.empty() && initSym_.empty()) {
    o <<"        .comm          "<< name_<<", "<< size_ <<"\n";
  } else if (!init_.empty()){
    for (int i = 0, e = init_.size(); i < e; ++i) {
      o <<"        ";
      switch(init_[i].first) {
      case SIRDataType::Int32: o <<".long          "; break;
      case SIRDataType::Int16: o <<".short         "; break;
      case SIRDataType::Int8 : o <<".byte          "; break;
      default:                 o <<".data          "; break;
      }
      o << static_cast<unsigned>(init_[i].second) <<"\n";
    }
    o <<"        .size          "<< name_ <<", "<< size_<<"\n";
  } else if (!initSym_.empty()) {
    for (int i = 0, e = initSym_.size(); i < e; ++i) {
      o <<"        .long          ";
      if (initSym_[i].second) {
        if (SIRDataObject::classof(initSym_[i].second)) {
          o << static_cast<SIRDataObject*>(initSym_[i].second)->GetAddress()
            <<'\n';
        } else { o << initSym_[i].second->GetName() <<'\n'; }
      } else { o << initSym_[i].first <<'\n';             }
    }
    o <<"        .size          "<< name_ <<", "<< size_<<"\n";
  }
  return o;
}

void SIRDataObject::
Dump(Json::Value& info) const {
  info["name"] = name_;
  info["address"] = address_;
  info["size"] = size_;
  if (IsVector()) { info["type"] = "vector"; }
  else            { info["type"] = "scalar"; }
}// Dump
