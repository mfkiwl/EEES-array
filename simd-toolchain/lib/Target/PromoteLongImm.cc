#include "Target/PromoteLongImm.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetBasicInfo.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace ES_SIMD;
using namespace std;

struct OperandIdentifier {
  SIRFunction::iterator   bIter_;
  SIRBasicBlock::iterator iIter_;
  int                     oid_;
  OperandIdentifier() {}
  OperandIdentifier(SIRFunction::iterator bIt, SIRBasicBlock::iterator iIt,
                    int oid) : bIter_(bIt), iIter_(iIt), oid_(oid) {}
};// OperandIdentifier

static float GetBlockDomCost(SIRBasicBlock* bb,
                             const vector<OperandIdentifier>& o) {
  float cost = pow(10, static_cast<float>(bb->GetLoopDepth()));
  for (int i=0, e=o.size(); i < e; ++i) {
    ES_ASSERT_MSG(bb->Dominates(*o[i].bIter_),
                  "Tring to calculate domination cost for non-dominator");
    cost += static_cast<float>(bb->GetDomTreeDistance(*o[i].bIter_));
  }
  return cost;
}

static SIRBasicBlock*
FindMinCostDominator(const vector<OperandIdentifier>& o, SIRFunction* func) {
  SIRBasicBlock* dom = func->GetEntryBlock();
  float cost = GetBlockDomCost(dom, o);
  for (SIRFunction::iterator sIt = func->begin(); sIt != func->end(); ++sIt) {
    SIRBasicBlock* sbb = *sIt;
    bool dominates = true;
    for (int i=0, e=o.size(); i < e; ++i) {
      if (!sbb->Dominates(*o[i].bIter_)) { dominates = false; }
    }// for i=0 to o.size()-1
    if (!dominates) { continue; }
    float sCost = GetBlockDomCost(sbb, o);
    if (sCost < cost) { dom = sbb; cost = sCost; }
  }// for dom succ_iterator sIt
  return dom;
}// FindMinCostDominator()

void PromoteLongImmPass::
ModuleInit(SIRModule* m) {
  module_ = m;
}// ModuleInit()

bool PromoteLongImmPass::
SetTargetImmediates(SIRFunction* func) {
  bool changed = false;
  for (SIRFunction::iterator bIt = func->begin(); bIt!= func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      for (int i=0, e=instr->operand_size(); i < e; ++i) {
        if (SIRRegister* r = dynamic_cast<SIRRegister*>(instr->GetOperand(i))) {
          if (r == func->GetNumPERegister()) {
            changed = true;
            SIRConstant* c
              = module_->AddOrGetImmediate(target_.GetTargetConstant(r));
            instr->ChangeOperand(i, c);
          }// if (r == func->GetNumPERegister())
        }
      }// for i = 0 to operand_size()-1
    }// for bb iterator iIt
  }// for func iterator bIt
  return changed;
}// SetTargetImmediates()

bool PromoteLongImmPass::
RunOnSIRFunction(SIRFunction* func) {
  SetTargetImmediates(func);
  typedef tr1::unordered_map<int, std::vector<OperandIdentifier> > LongImmMap;
  LongImmMap longImms;
  Int2FloatMap longImmCost; // Total cost of the value
  Int2IntMap   longImmReloadCost;
  /// First find the immediate values that need to be promoted
  for (SIRFunction::iterator bIt = func->begin(); bIt!= func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    float bCost = pow(10, static_cast<float>(bb->GetLoopDepth()));
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      int iCost = target_.InstrImmediateCost(instr);
      if (iCost <= 0) { continue; }
      ES_LOG_P(logLv_, log_,">> Long immediate used in "<< func->GetName()
               <<".B"<< bb->GetBasicBlockID()<<"(Loop depth = "
               << bb->GetLoopDepth() <<"): "<< *instr <<'\n');
      SIRConstant* c = NULL;
      int oidx = 0;
      for (int i=0, e=instr->operand_size(); i < e; ++i) {
        if (SIRConstant::classof(instr->GetOperand(i))) {
          c = static_cast<SIRConstant*>(instr->GetOperand(i));
          oidx = i;
          break;
        }
      }// for i = 0 to operand_size()-1
      ES_ASSERT_MSG(c && c->IsImmediate(), "Invalid immediate operand");
      int ival = c->GetImmediate();
      longImms[ival].push_back(OperandIdentifier(bIt, iIt, oidx));
      longImmCost[ival] += bCost * iCost;
      longImmReloadCost[ival] = iCost;
    }// for bb iterator iIt
  }// for func iterator bIt
  if (longImms.empty()) { return false; }
  const float threshold = target_.ImmediatePromoteThreshold();
  for(LongImmMap::iterator lIt=longImms.begin(); lIt != longImms.end(); ++lIt) {
    float immCost = longImmCost[lIt->first];
    if (immCost <= threshold) { continue; }
    SIRBasicBlock* insBlock = FindMinCostDominator(lIt->second, func);
    ES_ASSERT_MSG(insBlock, "Cannot find block to load "<< lIt->first);
    ES_LOG_P(logLv_, log_, ">> Promoting "<< lIt->first <<" to memory, cost = "
             << immCost <<", to be loaded in "<< func->GetName() <<".B"
             << insBlock->GetBasicBlockID()<<'\n');
    SIRDataObject* immObj = module_->AddOrGetConstPoolValue(
      lIt->first, target_.GetConstantPoolDataType(),
      longImmReloadCost[lIt->first]);
    immObj->AddUse(func);
    SIRInstruction* loadImm = new SIRInstruction(SIROpcode::LW,  insBlock, false);
    /// Add a vector imm in case it is needed in the PE array
    SIRInstruction* vectImm = new SIRInstruction(SIROpcode::MOV, insBlock, true);
    int iValueID = func->AllocateValue();
    int vectImmID = func->AllocateValue();
    loadImm->SetValueID(iValueID);
    loadImm->AddOperand(func->GetZeroRegister()).AddOperand(immObj);
    vectImm->SetValueID(vectImmID);
    vectImm->AddOperand(loadImm);
    insBlock->insert(insBlock->begin(), vectImm);
    insBlock->insert(insBlock->begin(), loadImm);
    func->AddConstPoolUser(iValueID, lIt->first);
    ES_LOG_P(logLv_, log_, ">> "<< lIt->first <<" used by V_"<< iValueID<<" in "
             << func->GetName() <<".B"<< insBlock->GetBasicBlockID()<<'\n');
    vector<OperandIdentifier> immUsers = lIt->second;
    for (int i=0, e=immUsers.size(); i < e; ++i) {
      SIRInstruction* instr = *immUsers[i].iIter_;
      SIRValue* newOperand = NULL;
      // FIXME: could be a problem if there is spilling
      if (*immUsers[i].bIter_ == insBlock) {
        newOperand = instr->IsVectorInstr() ? vectImm : loadImm;
      } else {
        if (instr->IsVectorInstr()) {
          newOperand=(*immUsers[i].bIter_)->AddOrGetLiveIn(true, vectImmID);
        } else {
          newOperand=(*immUsers[i].bIter_)->AddOrGetLiveIn(false, iValueID);
        }
      }
      ES_ASSERT_MSG(newOperand, "Invalid operand for long immediate "
                    <<lIt->first);
      instr->ChangeOperand(immUsers[i].oid_, newOperand);
    }// for i=0 to immUsers.size()-1
  }// for longImms iterator lIt
  func->UpdateLiveness();
  func->RemoveDeadValues();
  return true;
}// PromoteLongImmPass::RunOnSIRFunction()
