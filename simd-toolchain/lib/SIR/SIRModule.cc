#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRKernel.hh"
#include "SIR/SIRLoop.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRModule.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

SIRModule* SIRModule::
GetSIRModule(SIRValue* v) {
  if (!v) { return NULL; }
  switch(v->getKind()) {
  case SIRValue::VK_Function: return static_cast<SIRFunction*>(v)->GetParent();
  case SIRValue::VK_BasicBlock:
    return static_cast<SIRBasicBlock*>(v)->GetParent()->GetParent();
  case SIRValue::VK_Loop:
    return static_cast<SIRLoop*>(v)->GetParent()->GetParent();
  case SIRValue::VK_Kernel:
    return static_cast<SIRKernel*>(v)->GetParent()->GetParent();
  case SIRValue::VK_Instruction:
    return static_cast<SIRInstruction*>(v)->GetParent()->GetParent()->GetParent();
  case SIRValue::VK_Constant: return static_cast<SIRConstant*>(v)->GetParent();
  case SIRValue::VK_Register:
    return GetSIRModule(static_cast<SIRRegister*>(v)->GetParent());
  case SIRValue::VK_DataObject:
    return static_cast<SIRDataObject*>(v)->GetParent();
  default: return NULL;
  }// switch(v->getKind())
}// GetSIRModule()

SIRModule::
SIRModule() : targetData_(NULL), entryFunction_(NULL), bare_(false) {
  AddDataObject(new SIRDataObject("__heap_start", this));
  AddDataObject(new SIRDataObject("__stack_start", this));
  AddDataObject(new SIRDataObject("__pe_array_size", this));
  globalSymbols_.insert("__heap_start");
  globalSymbols_.insert("__stack_start");
  globalSymbols_.insert("__pe_array_size");
}

SIRModule::
~SIRModule() {
  for (iterator it = begin(); it != end(); ++it) { delete *it; }
  for(set<SIRBinExprNode*>::iterator it = binExprNodes_.begin();
      it != binExprNodes_.end(); ++it ) { delete *it; }
  for (constant_iterator it = const_begin(); it != const_end(); ++it) {
    delete *it;
  }
  for (dobj_iterator it = dobj_begin(); it != dobj_end(); ++it) {
    delete it->second; 
  }
  for (tr1::unordered_set<SIRFunction*>::iterator it = inactiveFuncs_.begin();
       it != inactiveFuncs_.end(); ++it) { delete *it; }
}// ~SIRModule()

/// Basically remove all non-global symbols
void SIRModule::
CleanupSymbols(std::tr1::unordered_set<std::string>& localSyms) {
  for(tr1::unordered_map<std::string, SIRValue*>::iterator
        it = symbols_.begin(), e = symbols_.end(); it != e;) {
    if (!IsElementOf(it->first, globalSymbols_)) {
      tr1::unordered_map<std::string, SIRValue*>::iterator d = it;
      ++it;
      symbols_.erase(d);
    } else if (IsElementOf(it->first, localSyms)) {
      tr1::unordered_map<std::string, SIRValue*>::iterator d = it;
      globalSymbols_.erase(it->first);
      ++it;
      symbols_.erase(d);
    } else { ++it; }
  }
}// CleanupSymbols()

void SIRModule::
AddDataObject(SIRDataObject* dobj) {
  if (dobj) { 
    if (IsElementOf(dobj->GetName(), dataObjects_)
        && (dataObjects_[dobj->GetName()] != dobj)) {
      delete dataObjects_[dobj->GetName()];
    }
    dataObjects_[dobj->GetName()] = dobj;
    symbols_[dobj->GetName()] = dobj;
    globalSymbols_.insert(dobj->GetName());
  }
}// AddDataObject()

void SIRModule::
AddFunction(SIRFunction* func) {
  if (func->GetName() == "__start") {
    functionList_.push_front(func);
  } else {
    functionList_.push_back(func);
  }
  inactiveFuncs_.erase(func);
  symbols_[func->GetName()] = func;
}// AddFunction()

SIRConstant* SIRModule::
AddOrGetImmediate(int v) {
  if (immediates_.find(v) == immediates_.end()) {
    SIRConstant* imm = new SIRConstant(v, this);
    constList_.push_back(imm);
    return immediates_[v] = imm;
  }
  return immediates_[v];
}// AddOrGetImmediate()

SIRValue* SIRModule::
AddOrGetSymbol(const std::string& s) {
  if (symbols_.find(s) == symbols_.end()) {
    // No such symbol, first treat it as some unknown constant
    SIRConstant* sym = new SIRConstant(s, this);
    constList_.push_back(sym);
    return symbols_[s] = sym;
  }
  return symbols_[s];
}// AddOrGetSymbol()

SIRDataObject* SIRModule::
AddOrGetConstPoolValue(int imm, SIRDataType_t vType, int reloadCost) {
  SIRDataObject* val = GetConstPoolObject(imm);
  if (!val) {
    string name ="$const_"+ string(GetString(vType)) + "_"+Int2HexString(imm);
    val = new SIRDataObject(name, this);
    AddDataObject(val);
    val->AddInit(vType, imm);
    switch(vType) {
    case SIRDataType::Int32: val->SetSize(4); break;
    case SIRDataType::Int16: val->SetSize(2); break;
    case SIRDataType::Int8:  val->SetSize(1); break;
    default: break;
    }
    constantPool_[imm] = val;
    constReloadCost_[imm] = reloadCost;
  }// if (!val)
  return val;
}// AddOrGetConstPoolValue()

SIRDataObject* SIRModule::
GetConstPoolObject(int imm) const{
  return IsElementOf(imm, constantPool_) ? GetValue(imm, constantPool_) : NULL;
}

void SIRModule::
SIRPrettyPrint(ostream& o) const {
  o <<"        .text\n";
  for (const_iterator it = begin(); it != end(); ++it) {
    (*it)->SIRPrettyPrint(o);
    o <<"\n";
  }
}// PrettyPrint()

void SIRModule::
ValuePrint(ostream& o) const {
  for (const_iterator it = begin(); it != end(); ++it) {
    (*it)->ValuePrint(o);
    o <<"\n";
  }
}// PrettyPrint()

void SIRModule::
TargetPrettyPrint(ostream& o) const {
  o <<"        .text\n";
  for (const_iterator it = begin(); it != end(); ++it) {
    (*it)->TargetPrettyPrint(o);
    o <<"\n";
  }
}// PrettyPrint()

void SIRModule::
remove(SIRFunction* func) {
  for (SIRFunction::dobj_iterator it = func->dobj_begin();
       it != func->dobj_end(); ++it) { (*it)->RemoveUse(func); }
  functionList_.remove(func);
  inactiveFuncs_.insert(func);
}// remove()

bool SIRModule::
IsActiveFunction(const SIRFunction* f) const {
  for (const_iterator fIt = begin(); fIt != end(); ++fIt) {
    if ((*fIt)->GetUID() == f->GetUID()) { return true; }
  }
  return false;
}// IsActiveFunction()

bool SIRModule::
HasVectorKernel() const {
  for (const_iterator fIt = begin(); fIt != end(); ++fIt) {
    if ((*fIt)->IsSolverKernel()) { return true; }
  }
  return false;
}// HasVectorKernel()

void SIRModule::
PrintCFG(std::ostream& o) const {
  for (const_iterator fIt = begin(); fIt != end(); ++fIt) {
    const SIRFunction* func = *fIt;
    const string& fn = func->GetName();
    for (SIRFunction::const_iterator bIt = func->begin();
         bIt != func->end();++bIt) {
      const SIRBasicBlock* bb = *bIt;
      int bid = bb->GetBasicBlockID();
      for (SIRBasicBlock::succ_const_iterator sIt = bb->succ_begin();
           sIt != bb->succ_end(); ++sIt){
        o << fn <<":e:"<< bid <<':'<< (*sIt)->GetBasicBlockID() <<'\n';
      }
    }//for func const_iterator bIt
    for (SIRFunction::const_iterator bIt = func->begin();
         bIt != func->end();++bIt) {
      const SIRBasicBlock* bb = *bIt;
      for (SIRBasicBlock::const_iterator iIt = bb->begin();
           iIt != bb->end(); ++iIt) {
        const SIRInstruction* instr = *iIt;
        if (IsTargetCall(instr->GetTargetOpcode())
            || (instr->GetSIROpcode() == SIROpcode::CALL)) {
          if (const SIRFunction* callee = instr->GetCallTarget()) {
            o << fn <<":c:"<< bb->GetBasicBlockID() <<':'
              << callee->GetName()<<'\n';
          }// if callee is SIRFunction
        }// if instr is call
      }// for bb const_iterator iIt
    }// for func const_iterator bIt
  }// for const_iterator fIt
}// PrintCFG()
