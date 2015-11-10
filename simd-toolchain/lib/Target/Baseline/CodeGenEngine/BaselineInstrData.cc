#include "BaselineInstrData.hh"
#include "BaselineFuncData.hh"
#include "BaselineBlockData.hh"
#include "BaselineBasicInfo.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "Target/TargetFuncRegAllocInfo.hh"
#include "Target/TargetIssuePacket.hh"
#include "Utils/StringUtils.hh"
#include "Utils/DbgUtils.hh"
#include "llvm/Support/Casting.h"
#include <iomanip>

using namespace std;
using namespace ES_SIMD;

BaselineInstrData::
BaselineInstrData(SIRInstruction* instr, const BaselineBasicInfo& target)
  : TargetInstrData(instr), toWB_(instr->GetValueID() >= 0),
    toRF_(instr->GetValueID() >= 0), isPredicateValue_(instr->UsedAsPredicate()),
    commProd_(NULL), commCons_(NULL) {
  operandBypassID_.resize(instr->operand_size(), -1);
  operandComm_.resize(instr_->operand_size(), COMM_NONE);
  predicatePhyID_.resize(instr->predicate_size(), -1);
  if (instr->IsVectorInstr()){//  && !IsSIRCommunication(instr->GetSIROpcode())
      // && !IsTargetCommunication(instr->GetTargetOpcode())) {
    for (unsigned i = 0; i < instr->operand_size(); ++i) {
      SIRValue* o = instr->GetOperand(i);
      if (SIRRegister::classof(o) || SIRInstruction::classof(o)) {
        if (!o->IsVectorValue()
            && !o->ValueEqual(
              instr->GetParent()->GetParent()->GetZeroRegister())) {
          // o->ValuePrint(cout) <<"=B=>";
          // instr->ValuePrint(cout)<<'\n';
          operandComm_[i] = COMM_BROADCAST;
        }
      }
    }
  }// if (instr->IsVectorInstr())
  latency_ = target.GetOperationLatency(instr);
}// BaselineInstrData()

BaselineInstrData::~BaselineInstrData() {}

void BaselineInstrData::
ResetOperandInfo() {
  TargetInstrData::ResetOperandInfo();
  operandBypassID_.resize(instr_->operand_size(), -1);
  operandComm_.resize(instr_->operand_size(), COMM_NONE);
}// ResetOperandInfo()

void BaselineInstrData::
ResetBypass() {
  fill(operandBypassID_.begin(), operandBypassID_.end(), -1);
  toRF_ = toWB_ = (instr_->GetValueID() >= 0);
}// ResetBypass()

void BaselineInstrData::
SwapOperand(unsigned a, unsigned b) {
  if ((a > operandBypassID_.size())||(b > operandBypassID_.size())) { return; }
  swap(operandBypassID_[a], operandBypassID_[b]);
  swap(operandPhyReg_[a],   operandPhyReg_[b]);
  swap(operandComm_[a],     operandComm_[b]);
}

bool BaselineInstrData::
HasBroadcast() const {
  for (unsigned i = 0; i < operandComm_.size(); ++i){
    if (operandComm_[i] == COMM_BROADCAST) { return true; }
  }
  return false;
}// HasBroadcast()

bool BaselineInstrData::
IsBroadcastedValue(int v) const {
  if (!instr_->IsVectorInstr()) { return false; }
  for (unsigned i = 0; i < operandComm_.size(); ++i){
    if (operandComm_[i] == COMM_BROADCAST) {
      if (SIRInstruction* p = dynamic_cast<SIRInstruction*>(
            instr_->GetOperand(i))) {
        return p->GetValueID() == v;
      }
    }// if (operandComm_[i] == COMM_BROADCAST)
  }
  return false;
}// IsBroadcastedValue()

void BaselineInstrData::
AssignPhyRegisters() {
  SIRFunction* func = instr_->GetParent()->GetParent();
  TargetFuncRegAllocInfo* raInfo = func->GetTargetData()->GetRegAllocInfo();
  int v = instr_->GetValueID();
  int rc = raInfo->GetValueRegClass(v);
  if (ToRF() && SIRFunction::IsValidValueID(v)) {
    if (instr_->IsBroadcasting()) { SetDestPhyReg(0); }
    else {
      int pr = raInfo->GetValuePhyRegister(v);
      ES_ASSERT_MSG(pr>= 0, "In "<< instr_->GetParent()->GetParent()->GetName()
                    <<": V_"<< v <<" ("<< instr_->GetName()
                    <<") is not assigned to a register");
      SetDestPhyReg(pr);
      raInfo->AddUsedPhyRegs(pr, rc);
    }
  }
  for (unsigned i = 0; i < instr_->operand_size(); ++i) {
    const SIRValue* op = instr_->GetOperand(i);
    if (SIRFunction::IsValidFlagID(op->GetValueID())) { continue; }
    if (SIRInstruction::classof(op) || SIRRegister::classof(op)) {
      if (!instr_->IsVectorInstr() || op->IsVectorValue()
          || (op->GetValueID() == func->GetZeroRegister()->GetValueID())) {
        int pr = raInfo->GetValuePhyRegister(op->GetValueID());
        if (pr >= 0) { SetOperandPhyReg(i, pr); }
        else {
          ES_ASSERT_MSG(operandBypassID_[i] >= 0, "V_"<<op->GetValueID()
                        <<" is not assigned to a register");
        }// if(pr >= 0)
      }
    }// if (llvm::isa<SIRInstr_uction>(op) || llvm::isa<SIRRegister>(op))
  }// for i = 0 to instr_->operand_size()-1

  if (instr_->UsedAsPredicate()) {
    int pv = raInfo->GetValuePhyRegister(v);

    // FIXME: Now the only place predications is used is in communication and
    //        local predication for kernels. So for now it is safe to just
    //        assign P2 to predicates.
    //        But we should NOT do this at all....
    if (pv < 0) { pv = 2; }
    // ES_ASSERT_MSG(pv>=0, "P"<< v <<" is not assigned to a flag");
    SetIsPredicateValue(true);
    SetDestPhyReg(pv);
  }// if (instr_->UsedAsPredicate())
  for (unsigned i = 0; i < instr_->predicate_size(); ++i) {
    int pv = raInfo->GetValuePhyRegister(instr_->GetPredicate(i)->GetValueID());
    // FIXME: see the description above
    if (pv < 0) { pv = 2; }
    ES_ASSERT_MSG(pv>=0, "P"<< instr_->GetPredicate(i)->GetValueID()
                  <<" is not assigned to a flag");
    SetPredicatePhyID(i, pv);
  }
}// AssignPhyRegisters()

void BaselineInstrData::
Print(std::ostream& o) const {
  const BaselineBasicInfo& tgt
    = dynamic_cast<BaselineFuncData*>(
      instr_->GetParent()->GetParent()->GetTargetData())->GetTarget();
  TargetOpcode_t opcode = instr_->GetTargetOpcode();
  string opc = GetString(opcode);
  ToLowerCase(opc);
  for (unsigned i = 0; i < predicatePhyID_.size(); ++i) {
    opc += ".P"+Int2DecString(predicatePhyID_[i]);
  }
  if (instr_->IsVectorInstr()) { opc = "v."+opc; }
  o << setw(15) << left << opc;
  if (GetTargetOpNumOutput(opcode) > 0) {
    if (toRF_)      { o <<"r"<< destPhyReg_; }
    else if (toWB_) { o <<"WB";              }
    else            { o <<"--";              }
    if (!instr_->operand_empty()) { o <<", ";}
  } else if (isPredicateValue_) {
    o <<"P"<< destPhyReg_;
    if (!instr_->operand_empty()) { o <<", ";}
  }
  for (unsigned i = 0; i < instr_->operand_size(); ++i) {
    const SIRValue* op = instr_->GetOperand(i);
    bool isFlag = false;
    if (llvm::isa<SIRInstruction>(op) || llvm::isa<SIRRegister>(op)) {
      if (operandComm_[i] == COMM_BROADCAST) { o <<"CP"; }
      else if (operandComm_[i] == COMM_LEFT) { o <<"l."; }
      else if (operandComm_[i] == COMM_RIGHT){ o <<"r."; }
      else if (operandComm_[i] == COMM_HEAD) { o <<"h."; }
      else if (operandComm_[i] == COMM_TAIL) { o <<"t."; }
      if (operandComm_[i] != COMM_BROADCAST) {
        if (operandBypassID_[i] >= 0) {
          o << (instr_->IsVectorInstr()?tgt.GetPEBypassName(operandBypassID_[i])
                : tgt.GetCPBypassName(operandBypassID_[i]));
        } else if (SIRFunction::IsValidValueID(op->GetValueID())) {
          ES_ASSERT_MSG(operandPhyReg_[i]>=0, "Invalid register id for V_"
                        << op->GetValueID()<<"(["<< i <<"] of "<< *instr_
                        <<", <"<< instr_->GetOperand(i)->getKindName() <<">)");
          o <<"r"<< operandPhyReg_[i];
        } else if (SIRFunction::IsValidFlagID(op->GetValueID())) {
          isFlag = true;
        }
      }
    } else if (llvm::isa<SIRFunction>(op) || llvm::isa<SIRBasicBlock>(op)) {
      o << op->GetName();
    } else { o << left << *op; }
    if (!isFlag && (i < (instr_->operand_size()-1))) { o <<", "; }
  }
}// Print()

void ES_SIMD::
SetupCommPair(SIRInstruction* prod, SIRInstruction* cons) {
  BaselineInstrData* pData
    = dynamic_cast<BaselineInstrData*>(prod->GetTargetData());
  BaselineInstrData* cData
    = dynamic_cast<BaselineInstrData*>(cons->GetTargetData());
  ES_ASSERT_MSG(pData && cData, "Invalid Baseline target instruction");
  pData->SetCommConsumer(cons);
  cData->SetCommProducer(prod);
}// SetupCommPair()

void BaselineInstrData::
Dump(Json::Value& iInfo) const {
  iInfo["asm"] = GetAsmString();
  iInfo["latency"] = GetLatency();
  TargetOpcode_t opcode = instr_->GetTargetOpcode();
  if (GetTargetOpNumOutput(opcode) > 0) {
    if (toRF_ )     { iInfo["dst"] ="r"+ Int2DecString(destPhyReg_); }
    else if (toWB_) { iInfo["dst"] ="WB"; }
    else            { iInfo["dst"] ="--"; }
  } else if (isPredicateValue_) {iInfo["dst"] ="P"+Int2DecString(destPhyReg_);}
  const TargetBlockData* bData = instr_->GetParent()->GetTargetData();
  for (SIRValue::use_iterator uIt = instr_->use_begin();
       uIt != instr_->use_end(); ++uIt) {
    if (const SIRInstruction* uI = dynamic_cast<const SIRInstruction*>(*uIt)) {
      if(TargetIssuePacket* up = bData->FindPacket(uI)) {
        Json::Value uVal;
        uVal["time"]  = up->IssueTime();
        uVal["issue"] = up->GetIssueID(uI);
        iInfo["users"].append(uVal);
      }// if(TargetIssuePacket* pp = bData->FindPacket(pProd))
    }
  }
  for (int i=0, e=instr_->predicate_size(); i < e; ++i) {
    Json::Value pVal;
    pVal["pid"] = predicatePhyID_[i];
    if (SIRInstruction* pProd
        = dynamic_cast<SIRInstruction*>(instr_->GetPredicate(i))) {
      if(TargetIssuePacket* pp = bData->FindPacket(pProd)) {
        pVal["produce_time"] = pp->IssueTime();
        pVal["produce_issue"] = pp->GetIssueID(pProd);
      }// if(TargetIssuePacket* pp = bData->FindPacket(pProd))
    }
    iInfo["predicates"].append(pVal);
  }// for i = 0 to instr_->predicate_size()-1
  for (int i=0, e=instr_->operand_size(); i < e; ++i) {
    Json::Value oVal;
    const SIRValue* op = instr_->GetOperand(i);
    if (llvm::isa<SIRInstruction>(op) || llvm::isa<SIRRegister>(op)) {
      switch (operandComm_[i]) {
      case COMM_BROADCAST: oVal["comm"] = "Broadcast"; break;
      case COMM_LEFT     : oVal["comm"] = "Left";      break;
      case COMM_RIGHT    : oVal["comm"] = "Right";     break;
      case COMM_HEAD     : oVal["comm"] = "Tail";      break;
      }
      if (op->GetValueID() >= 0) {
        oVal["value"] = op->GetValueID();
      }
      if (operandComm_[i] != COMM_BROADCAST) {
        if (operandBypassID_[i] >= 0) { oVal["bypass"] = operandBypassID_[i]; }
        else if (SIRFunction::IsValidValueID(op->GetValueID())) {
          ES_ASSERT_MSG(operandPhyReg_[i]>=0, "Invalid register id");
          oVal["reg"] = operandPhyReg_[i];
        } else if (SIRFunction::IsValidFlagID(op->GetValueID())) {

          oVal["flag"] = 0;
        }
      }
      if (SIRFunction::IsValidFlagID(op->GetValueID())) { oVal["type"] = "flag";
      } else { oVal["type"] = "value"; }
      if (llvm::isa<SIRInstruction>(op)) {
        const SIRInstruction* oI = static_cast<const SIRInstruction*>(op);
        if(TargetIssuePacket* pp = bData->FindPacket(oI)) {
          oVal["produce_time"] = pp->IssueTime();
          oVal["produce_issue"] = pp->GetIssueID(oI);
        }// if(TargetIssuePacket* pp = bData->FindPacket(oI))
      }
    } else if (llvm::isa<SIRFunction>(op)) {
      oVal["type"] = "function";
      oVal["id"] = op->GetName();
    } else if(llvm::isa<SIRBasicBlock>(op)) {
      oVal["type"] = "bb";
      oVal["id"]   = static_cast<const SIRBasicBlock*>(op)->GetBasicBlockID();
    } else if (llvm::isa<SIRConstant>(op)){
      oVal["type"] = "immediate";
      oVal["id"] = static_cast<const SIRConstant*>(op)->GetImmediate();
    }
    iInfo["operands"].append(oVal);
  }// for i = 0 to instr_->operand_size()-1
}// Dump()
