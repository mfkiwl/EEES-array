#include "Target/TargetModuleData.hh"
#include "Target/TargetFuncData.hh"
#include "Target/TargetBlockData.hh"
#include "Target/TargetInstrData.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRModule.hh"

using namespace std;
using namespace ES_SIMD;

TargetModuleData::
~TargetModuleData() {
  for (tr1::unordered_map<const SIRFunction*, TargetFuncData*>::iterator it
         = funcData_.begin(); it != funcData_.end(); ++it){delete it->second;}
  for (tr1::unordered_map<const SIRBasicBlock*, TargetBlockData*>::iterator it
         = blockData_.begin(); it != blockData_.end(); ++it){delete it->second;}
  for (tr1::unordered_map<const SIRInstruction*, TargetInstrData*>::iterator it
         = instrData_.begin(); it != instrData_.end(); ++it){delete it->second;}
}

void TargetModuleData::
PrintStatistics(ostream& o) const {
  o <<">> BEGIN Module Statistics\n";
  o <<">> "<< module_->size() <<" functions.\n";
  for (SIRModule::const_iterator fIt = module_->begin();
       fIt != module_->end(); ++fIt) {
    (*fIt)->GetTargetData()->PrintStatistics(o);
    o <<'\n';
  }
  for (SIRModule::dobj_const_iterator dIt = module_->dobj_begin();
       dIt != module_->dobj_end(); ++ dIt) {
    const SIRDataObject* dobj = dIt->second;
    if (!dobj->IsReferenced()) { continue; }
    o <<">> BEGIN data-object statistics\n";
    o <<"name:"<< dobj->GetName() <<'\n';
    o <<"vector:"<< dobj->IsVector() <<'\n';
    o <<"size:"<< dobj->GetSize() <<'\n';
    o <<"address:"<< dobj->GetAddress() <<'\n';
    o <<">> END data-object statistics\n";
  }
  o <<">> END Module Statistics\n";
}// PrintStatistics()

void TargetModuleData::
PrintSymbolTable(std::ostream& o) const {
  for (SIRModule::const_iterator fIt = module_->begin();
       fIt != module_->end(); ++fIt) {
    const SIRFunction* func = *fIt;
    o <<"F:"<< func->GetName() <<':'
      << func->GetTargetData()->GetTargetAddress() <<':'
      << func->GetTargetData()->GetCodeSize()<<'\n';
    for (SIRFunction::const_iterator bIt = func->begin();
         bIt != func->end();++bIt) {
      o <<"B:"<< func->GetName() <<':'<<(*bIt)->GetBasicBlockID()
        <<':'<<(*bIt)->GetTargetData()->GetTargetAddress()
        <<':'<<(*bIt)->GetTargetData()->GetTargetSize()<<'\n';
    }
  }// for const_iterator fIt
  for (SIRModule::dobj_const_iterator dIt = module_->dobj_begin();
       dIt != module_->dobj_end(); ++ dIt) {
    const SIRDataObject* dobj = dIt->second;
    if (!dobj->IsReferenced()) { continue; }
    o <<"D:"<< dobj->GetName() <<(dobj->IsVector() ?":V":":S")
      <<':'<< dobj->GetAddress() <<':'<< dobj->GetSize() <<'\n';
  }// for dataObjects_ const_iterator dIt
}// PrintSymbolTable()

ostream& TargetModuleData::Print(std::ostream& o)      const { return o; }
ostream& TargetModuleData::ValuePrint(std::ostream& o) const { return o; }

void TargetModuleData::
Dump(Json::Value& mInfo) const {
  if (!module_->GetName().empty()) { mInfo["name"] = module_->GetName(); }
  for (SIRModule::const_iterator fIt = module_->begin();
       fIt != module_->end(); ++fIt) {
    Json::Value funcVal;
    const SIRFunction* func = *fIt;
    (*fIt)->Dump(funcVal);
    funcVal["address"] = func->GetTargetData()->GetTargetAddress();
    funcVal["size"]    = func->GetTargetData()->GetCodeSize();
    for (SIRFunction::const_iterator bIt = func->begin();
         bIt != func->end(); ++bIt) {
      Json::Value bVal;
      (*bIt)->Dump(bVal);
      (*bIt)->GetTargetData()->Dump(bVal);
      funcVal["bb"].append(bVal);
    }
    mInfo["functions"][(*fIt)->GetName()] = funcVal;
  }// for module const_iterator fIt
  for (SIRModule::dobj_const_iterator dIt = module_->dobj_begin();
       dIt != module_->dobj_end(); ++ dIt) {
    const SIRDataObject* dobj = dIt->second;
    if (!dobj->IsReferenced()) { continue; }
    Json::Value objVal;
    dobj->Dump(objVal);
    mInfo["data_objects"][dobj->GetName()] = objVal;
  }// for dataObjects_ const_iterator dIt
}// Dump()
