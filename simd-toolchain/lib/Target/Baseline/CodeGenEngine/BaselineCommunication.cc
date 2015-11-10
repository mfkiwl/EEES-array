#include "BaselineInstrData.hh"
#include "BaselineCodeGenEngine.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetModuleData.hh"
#include "Utils/DbgUtils.hh"

using namespace ES_SIMD;
using namespace std;

BaselineLowerCommunication::~BaselineLowerCommunication() {}

void BaselineLowerCommunication::
ModuleInit(SIRModule* m) { mData_ = m->GetTargetData(); }

void BaselineLowerCommunication::
FunctionInit(SIRFunction* func) { func->UpdateRegValueType(); }

bool BaselineLowerCommunication::
RunOnSIRBasicBlock(SIRBasicBlock* bb) {
  bool changed = false;
  for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end();) {
    SIRInstruction* instr = *iIt;
    TargetOpcode_t opc = instr->GetTargetOpcode();
    if (!IsTargetCommunication(opc)){ ++iIt; continue; }
    switch (opc) {
    case TargetOpcode::MOV_L: case TargetOpcode::MOV_R:
      changed = true; iIt = LowerInterPEComm(iIt);
      continue;
    case TargetOpcode::PUSH_H: case TargetOpcode::PUSH_T:
      changed = true; iIt = LowerShiftToPE(iIt);
      continue;
    case TargetOpcode::MOV_H: case TargetOpcode::MOV_T:
      changed = true; iIt = LowerPECPComm(iIt);
      continue;
    default: ES_UNREACHABLE("Unknown communication opcode "<< opc);
    }
    ++iIt;
  }// for bb iterator iIt
  if (changed && logLv_) {
    log_<<"-->> "<< bb->GetParent()->GetName() <<".B"<< bb->GetBasicBlockID()
        <<":\n"; bb->ValuePrint(log_);
  }
  return changed;
}// RunOnSIRBasicBlock()


/// Transform:
///     peVal = v.push_X cpSrc
/// to: 
///     cv = mov cpSrc || peVal = v.mov_x cv
SIRBasicBlock::iterator BaselineLowerCommunication::
LowerShiftToPE(SIRBasicBlock::iterator it) {
  SIRInstruction* instr = *it;
  SIRBasicBlock* bb = instr->GetParent();
  if (logLv_) {
    log_<<"-->> "<< bb->GetParent()->GetName() <<".B"<<bb->GetBasicBlockID()
        <<" - Lowering shift-to-PE: ";instr->ValuePrint(log_) <<'\n';
  }
  int dir = (instr->GetTargetOpcode() == TargetOpcode::PUSH_H) ?
    BaselineInstrData::COMM_RIGHT : BaselineInstrData::COMM_LEFT;
  SIRValue* cpSrc = instr->GetOperand(0);
  SIRValue* peSrc = instr->GetOperand(1);
  SIRInstruction& commInstr = bb->BuildSIRInstr(
    it, false, SIROpcode::MOV, bb->GetParent()->AllocateValue());
  commInstr.AddOperand(cpSrc).SetTargetOpcode(TargetOpcode::MOV);
  bb->GetParent()->GetParent()->GetTargetData()->InitTargetData(&commInstr);
  commInstr.AddUse(instr);
  SetupCommPair(&commInstr, instr);
  instr->SetTargetOpcode(TargetOpcode::MOV);
  instr->RemoveOperand(1);
  instr->ChangeOperand(0, peSrc);
  BaselineInstrData* iData
    = dynamic_cast<BaselineInstrData*>(instr->GetTargetData());
  iData->SetOperandComm(0, dir);
  return ++it;
}// LowerShiftToPE()

SIRBasicBlock::iterator BaselineLowerCommunication::
LowerInterPEComm(SIRBasicBlock::iterator it) {
  SIRInstruction* instr = *it;
  SIRBasicBlock* bb = instr->GetParent();
  if (logLv_) {
    log_<<"-->> "<< bb->GetParent()->GetName() <<".B"<<bb->GetBasicBlockID()
        <<" - Lowering inter-PE: ";instr->ValuePrint(log_) <<'\n';
  }
  SIRValue* srcValue  = instr->GetOperand(0);
  SIRValue* distValue = instr->GetOperand(1);
  int dir = (instr->GetTargetOpcode() == TargetOpcode::MOV_R) ?
    BaselineInstrData::COMM_RIGHT : BaselineInstrData::COMM_LEFT;
  if (SIRConstant::classof(distValue)) {
    // For constant distance, expand the communication to a series of shifts
    int dist = static_cast<SIRConstant*>(distValue)->GetImmediate();
    SIRBasicBlock::iterator ip = it; ++ip;
    for (int i = 1; i < dist; i ++) {
      SIRInstruction& commInstr = bb->BuildSIRInstr(
        ip, true, SIROpcode::MOV, bb->GetParent()->AllocateValue());
      commInstr.SetTargetOpcode(TargetOpcode::MOV);
      commInstr.AddOperand(srcValue);
      BaselineInstrData* iData = dynamic_cast<BaselineInstrData*>(
        bb->GetParent()->GetParent()->GetTargetData()
        ->InitTargetData(&commInstr));
      iData->SetOperandComm(0, dir);
      srcValue = &commInstr;
    }// for i = 1 to dist-1
    vector<SIRInstruction*> users;
    users.reserve(instr->use_size());
    for (SIRInstruction::use_iterator uIt = instr->use_begin();
         uIt != instr->use_end(); ++uIt) {
      if (SIRInstruction::classof(*uIt)) {
        users.push_back(static_cast<SIRInstruction*>(*uIt));
      }
    }
    for (int i = 0, e = users.size(); i < e; ++i) {
      SIRInstruction* uInstr = users[i];
      if (uInstr->GetOperand(0) == instr) {
        uInstr->ChangeOperand(0, srcValue);
        BaselineInstrData* uData
          = static_cast<BaselineInstrData*>(uInstr->GetTargetData());
        uData->SetOperandComm(0, dir);
      }// if (uInstr->GetOperand(0) == instr)
    }// for i = 0 to users.size()-1
    // FIXME: check if this behave correctly across blocks
    if (instr->use_empty() && !bb->InstrLiveOut(it) ) { return bb->erase(it); }
    if (srcValue != instr->GetOperand(0)) {instr->ChangeOperand(0, srcValue);}
    instr->SetTargetOpcode(TargetOpcode::MOV);
    instr->RemoveOperand(1);
    BaselineInstrData* iData
      = static_cast<BaselineInstrData*>(instr->GetTargetData());
    iData->ResetOperandInfo();
    iData->SetOperandComm(0, dir);
  } else { ES_NOTIMPLEMENTED("Variable communication distance"); }
  return ++it;
}// LowerInterPEComm()

SIRBasicBlock::iterator BaselineLowerCommunication::
LowerPECPComm(SIRBasicBlock::iterator it) {
  SIRInstruction* instr = *it;
  SIRBasicBlock* bb = instr->GetParent();
  if (logLv_) {
    log_<<"-->> "<< bb->GetParent()->GetName() <<".B"<<bb->GetBasicBlockID()
        <<" - Lowering CP-PE: ";instr->ValuePrint(log_) <<'\n';
  }
  SIRValue* srcValue  = instr->GetOperand(0);
  SIRValue* distValue = instr->GetOperand(1);
  int dir = (instr->GetTargetOpcode() == TargetOpcode::MOV_H) ?
    BaselineInstrData::COMM_HEAD : BaselineInstrData::COMM_TAIL;
  int pDir = (dir == BaselineInstrData::COMM_HEAD) ?
    BaselineInstrData::COMM_RIGHT : BaselineInstrData::COMM_LEFT;
  if (SIRConstant::classof(distValue)) {
    // For constant distance, we simply expand the communication to a series
    // of shifts
    int dist = static_cast<SIRConstant*>(distValue)->GetImmediate();
    SIRBasicBlock::iterator ip = it;
    //++ip;
    for (int i = 1; i < dist; i ++) {
      SIRInstruction& commInstr = bb->BuildSIRInstr(
        ip, true, SIROpcode::MOV, bb->GetParent()->AllocateValue());
      commInstr.SetTargetOpcode(TargetOpcode::MOV);
      commInstr.AddOperand(srcValue);
      BaselineInstrData* iData = dynamic_cast<BaselineInstrData*>(
        bb->GetParent()->GetParent()->GetTargetData()
        ->InitTargetData(&commInstr));
      iData->SetOperandComm(0, pDir);
      srcValue = &commInstr;
    }
    SIRInstruction& vopInstr = bb->BuildSIRInstr(
      ip, true, SIROpcode::MOV, bb->GetParent()->AllocateValue());
    vopInstr.AddOperand(srcValue).SetTargetOpcode(TargetOpcode::MOV);
    BaselineInstrData* vData =  dynamic_cast<BaselineInstrData*>(
      bb->GetParent()->GetParent()->GetTargetData()->InitTargetData(&vopInstr));
    if (dist > 1) { vData->SetOperandComm(0, pDir); }
    // if (instr->GetOperand(0) != srcValue) { instr->ChangeOperand(0, srcValue); }
    instr->ChangeOperand(0, &vopInstr);
    instr->SetTargetOpcode(TargetOpcode::MOV);
    instr->RemoveOperand(1);
    BaselineInstrData* iData
      = static_cast<BaselineInstrData*>(instr->GetTargetData());
    iData->ResetOperandInfo();
    iData->SetOperandComm(0, dir);
    SetupCommPair(&vopInstr, instr);
    if (logLv_) {
      log_<<"-->>-- Setup communication pair: [";
      vopInstr.ValuePrint(log_)<< "] and [";
      instr->ValuePrint(log_) <<"]\n";
    }
  } else { ES_NOTIMPLEMENTED("Variable communication distance"); }
  return ++it;
}// LowerPECPComm()
