#include "Transform/SIRLocalOpt.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace ES_SIMD;
using namespace std;

static bool
BlockConstPropagation(SIRBasicBlock* bb, bool log, ostream& logs) {
  bool changed = false;
  for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end();++iIt) {
    SIRInstruction* instr = *iIt;
    if (instr->GetSIROpcode() != SIROpcode::MOV) { continue; }
    bool movConst = false;
    switch (instr->GetOperand(0)->getKind()) {
    case SIRValue::VK_Constant: case SIRValue::VK_DataObject:
    case SIRValue::VK_Function: case SIRValue::VK_BasicBlock:
      movConst = true; break;
    case SIRValue::VK_Register: case SIRValue::VK_Instruction:
      movConst = false; break;
    default: ES_UNREACHABLE(""); break;
    }// switch (instr->GetOperand(0)->getKind())
    if (!movConst) { continue; }
    int iVal = instr->GetValueID();
    if (bb->IsValueLiveOut(iVal)) { continue; }
    SIRBasicBlock::iterator sIt = iIt;
    SIRValue* c = instr->GetOperand(0);
    for (++sIt; sIt != bb->end(); ++sIt) {
      SIRInstruction* sInstr = *sIt;
      if (sInstr->UsesValue(iVal)) {
        ES_LOG_P(log,logs,"-->> "<< bb->GetParent()->GetName() <<".B"
                 << bb->GetBasicBlockID() <<": replacing V_"<<iVal
                 <<" with "<<*c<<"\n-->>-- ");
        if (log) { sInstr->ValuePrint(logs)<<'\n';}
        sInstr->ReplaceOperand(instr, c);
        changed = true;
      }
      if (sInstr->GetValueID() == iVal) { break; }
    }
  }// for bb iterator iIt
  return changed;
}// BlockConstPropagation()

bool SIRLocalOpt::
RunOnSIRFunction(SIRFunction* func) {
  bool changed = false;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    changed |= BlockConstPropagation(bb, logLv_, log_);
  }// for func iterator bIt
  if (changed) {
    func->RemoveDeadValues();
    func->UpdateLiveness();
    if (logLv_){ log_<<"-->> "<<func->GetName()<<":\n";func->ValuePrint(log_); }
  }
  return changed;
}// RunOnSIRFunction()
