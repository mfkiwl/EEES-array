#include <SIR/SIRConstant.hh>
#include <SIR/SIRRegister.hh>
#include <SIR/SIRInstruction.hh>
#include <SIR/SIRBasicBlock.hh>
#include <SIR/SIRFunction.hh>
#include <SIR/SIRModule.hh>
#include <SIR/SIRKernel.hh>
#include <SIR/SIRLoop.hh>
#include <SIR/SIRDataObject.hh>
#include <Transform/SIRFinalize.hh>
#include <Utils/LogUtils.hh>
#include <Utils/StringUtils.hh>
#include <Utils/DbgUtils.hh>

using namespace std;
using namespace ES_SIMD;

bool SIRGlobalSymbolPass::
RunOnSIRModule(SIRModule* m) {
  bool change = false;
  for(SIRModule::iterator it = m->begin(); it != m->end(); ++it) {
    SIRFunction* func = *it;
    ES_LOG_P(logLv_ > 1, log_, ">>-- In "<< func->GetName() <<"()\n");
    for(SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
      change |= RunOnSIRBasicBlock(*bIt);
    }
  }
  for (SIRModule::dobj_iterator dIt = m->dobj_begin();
       dIt != m->dobj_end(); ++dIt) {
    SIRDataObject* obj = dIt->second;
    for (SIRDataObject::sym_iterator sIt = obj->sym_begin();
         sIt != obj->sym_end(); ++sIt) {
      const string& l = sIt->first;
      SIRValue* tv = sIt->second;
      if (tv && (!SIRConstant::classof(tv)
                 || !static_cast<SIRConstant*>(tv)->IsSymbol())){ continue; }
      SIRValue* val = m->GetSymbolValue(l);
      if (!val || (SIRConstant::classof(val)
                   && static_cast<SIRConstant*>(val)->IsSymbol())) {
        PassError(ErrorCode::IRUndefinedSymbol, "Undefined Symbol \""+l+"\"");
        break;
      }
      sIt->second = val;
      if (SIRDataObject::classof(val)) { val->AddUse(obj); }
    }// for obj sym_iterator sIt
  }// for m dobj_iterator dIt
  return change;
}// SIRGlobalSymbolPass::RunOnSIRModule()

bool SIRGlobalSymbolPass::
RunOnSIRBasicBlock(SIRBasicBlock* bb) {
  bool change = false;
  SIRFunction* func = bb->GetParent();
  SIRModule* m = func->GetParent();
  for(SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
    SIRInstruction* instr = *iIt;
    if (instr->GetSIROpcode() == SIROpcode::CALL) {
      if (instr->operand_size() != 1) {
        Error(ErrorCode::IRIllegalOperand,
              "CALL should have exactly one constant operand",
              instr->GetFileLocation());
        break;
      }
      if (!SIRConstant::classof(instr->GetOperand(0))) { continue; }
      SIRConstant* tc = static_cast<SIRConstant*>(instr->GetOperand(0));
      if (!tc->IsSymbol()) { continue; }
      SIRValue* t = m->GetSymbolValue(tc->GetSymbol());
      if (!t) {
        Error(ErrorCode::IRUndefinedSymbol, "Undefined IR Symbol \""
              + tc->GetSymbol() +"\"", instr->GetFileLocation());
        break;
      }
      if (!SIRFunction::classof(t)) {
        Error(ErrorCode::IRIllegalOperand,"CALL operand should be function",
              instr->GetFileLocation());
        break;
      }
      func->AddCallee(static_cast<SIRFunction*>(t));
    }// if (instr->GetSIROpcode() == SIROpcode::CALL)
    for (SIRInstruction::operand_iterator oIt = instr->operand_begin();
         oIt != instr->operand_end(); ++oIt) {
      if (SIRConstant::classof(*oIt)) {
        SIRConstant* c = static_cast<SIRConstant*>(*oIt);
        if (!c->IsSymbol()) { continue; }
        SIRValue* val = m->GetSymbolValue(c->GetSymbol());
        if (!val) { continue; }
        if (SIRDataObject::classof(val)) {
          func->AddDataObject(static_cast<SIRDataObject*>(val));
        }
        instr->ChangeOperand(oIt, val);
        ES_LOG_P(logLv_, log_, ">>-->> Symbol \""<< c->GetSymbol() <<"\" points"
                 <<" to "<< val->getKindName() <<" <"<< val->GetName() <<">\n");
      }
    }// for instr operand_iterator oIt
  }// for bb iterator iIt
  return change;
}// SIRGlobalSymbolPass::RunOnSIRBasicBlock()

bool SIRCFGPass::
RunOnSIRFunction(SIRFunction* func) {
  if (func->empty()) { return false; }
  ES_LOG_P(logLv_ > 1, log_,
           ">> Constructing CFG for "<< func->GetName() <<"...\n");
  tr1::unordered_map<int, SIRBasicBlock*> bbTable;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    bbTable[(*bIt)->GetBasicBlockID()] = *bIt;
  }
  for(SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt){
      SIRBasicBlock* bb = *bIt;
      for(SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end();){
        SIRInstruction* instr = *iIt;
        switch (instr->GetSIROpcode()) {
        default: ++iIt; break;
        case SIROpcode::PRED: {
          int p;
          if (!SIRConstant::GetImmediate(instr->GetOperand(0), p)
              || !IsElementOf(p, bbTable)) {
            Error(ErrorCode::IRIllegalOperand,
                  "Unknown block id", instr->GetFileLocation());
            break;
          }
          bb->pred_push_back(bbTable[p]);
          iIt = bb->erase(iIt);
          break;
        }// case: SIROpcode::PRED
        case SIROpcode::SUCC: {
          int s;
          if (!SIRConstant::GetImmediate(instr->GetOperand(0), s)
              || !IsElementOf(s, bbTable)) {
            Error(ErrorCode::IRIllegalOperand,
                  "Unknown block id", instr->GetFileLocation());
            break;
          }
          bb->succ_push_back(bbTable[s]);
          iIt = bb->erase(iIt);
          break;
        }// case: SIROpcode::SUCC
        // Dominator/Post-Dominator Tree and Loop information will be
        // re-calculated so just ignore the info in IR.
        case SIROpcode::DOM:  case SIROpcode::PDOM:
        case SIROpcode::LOOP: case SIROpcode::LHDR: case SIROpcode::LEXT:
          iIt = bb->erase(iIt);
          break;
        }// switch (instr->GetSIROpcode())
      }// for bb iterator iIt
  }// for func itetator bIt

  func->UpdateControlFlowInfo();
  return true;
}// SIRCFGPass::RunOnSIRFunction()

bool SIRInitValueInfoPass::
RunOnSIRFunction(SIRFunction* func) {
  if (func->empty()) { return false; }
  InitStackInfo(func);
  InitCallSite(func);
  tr1::unordered_map<string, int> valTab;
  tr1::unordered_map<int, string> valNameTab;
  InitLiveness(func,  valTab, valNameTab);
  UpdateValueID(func, valTab, valNameTab);
  if (func->IsSolverKernel()) { func->GetSolverKernel()->InitCodeGen(); }

  // Remove return instruction
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    bool isExit = bb->IsExitBlock();
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end();) {
      if (isExit && ((*iIt)->GetSIROpcode() == SIROpcode::RET)) {
        iIt = bb->erase(iIt);
      } else { ++iIt; }
    }// for bb iterator iIt
  }// for func iterator bIt
  func->UpdateLiveness();
  if (func->GetNumPERegister()->use_size()) {
    func->GetParent()->GetDataObject("__pe_array_size")->AddUse(func);
  }
  if (logLv_) { func->ValuePrint(log_); }
  return true;
}// SIRInitValueInfoPass::RunOnSIRFunction()

void SIRInitValueInfoPass::
InitStackInfo(SIRFunction* func) {
  ES_ASSERT_MSG(func->GetEntryBlock(), "No entry block in: "<< func->GetName());
  // Assume that stack is always allocated by the following instruction in the
  // entry block:
  //     add SP, SP, -size
  // and it is release by the following instruction in the exit block(s)
  //     add SP, SP, size
  int stOffset = 0;
  SIRBasicBlock* ebb = func->GetEntryBlock();
  SIRRegister* sp = func->GetStackPointer();
  for (SIRBasicBlock::iterator iIt = ebb->begin(); iIt != ebb->end();) {
    SIRInstruction* instr = *iIt;
    if (instr->GetName() == "SP" && (instr->GetSIROpcode() == SIROpcode::ADD)
        && (instr->GetOperand(0)->GetName() == "SP")) {
      ES_ASSERT_MSG(SIRConstant::classof(instr->GetOperand(1)),
                    "Non-constant stack offset");
      int oVal =static_cast<SIRConstant*>(instr->GetOperand(1))->GetImmediate();
      // Allocation and release may be in the same block.
      if (oVal > 0) { ++iIt; continue; }
      stOffset = -oVal;
      ES_LOG_P(logLv_, log_, "-->> "<< func->GetName() <<" IR stack offset = "
               << stOffset <<'\n');
      SIRBasicBlock::iterator iiIt = iIt;
      for (++iiIt; iiIt != ebb->end(); ++iiIt) {
        (*iiIt)->ReplaceOperand(instr, sp);
      }
      iIt = ebb->erase(iIt);
    } else { ++iIt; }
  }// for func->entryBlock_ iterator iIt

  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    if (!bb->IsExitBlock()) { continue; }
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end();) {
      SIRInstruction* instr = *iIt;
      if (instr->GetName() == "SP" && (instr->GetSIROpcode() == SIROpcode::ADD)
          && (instr->GetOperand(0)->GetName() == "SP")) {
        ES_ASSERT_MSG(SIRConstant::classof(instr->GetOperand(1)),
                      "Non-constant stack offset");
        ES_ASSERT_MSG(static_cast<SIRConstant*>(instr->GetOperand(1))
                      ->GetImmediate() == stOffset, "Stack size mismatch");
        iIt = bb->erase(iIt);
      } else { ++iIt; }
    }// for bb iterator iIt
  }// for func iterator bIt
  func->SetSIRStackOffset(static_cast<unsigned>(stOffset));
}// SIRInitValueInfoPass::InitStackInfo()

void SIRInitValueInfoPass::
InitCallSite(SIRFunction* func) {
  static ImmediateReader immRd;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (instr->GetSIROpcode() != SIROpcode::CALL) { continue; }
      SIRCallSite* cs = func->GetCallSite(instr);
      ES_ASSERT_MSG(cs, "No call-site");
      if (!SIRFunction::classof(instr->GetOperand(0))) { continue; }
      SIRFunction* callee = static_cast<SIRFunction*>(instr->GetOperand(0));
      cs->SetCallee(callee);
      ES_LOG_P(logLv_, log_, ">> Calling "<< callee->GetName()
               <<" in "<< func->GetName() <<"\n");
      if (callee->arg_size() > 0) {
        cs->arg_resize(callee->arg_size());
        ES_LOG_P(logLv_, log_, ">>-- "<< callee->GetName()<<" requires "
                 << callee->arg_size() <<"("<< callee->GetNumFormalArguments()
                 <<") arguments\n");
        SIRBasicBlock::iterator aIt = iIt;
        // Find arguments defined in call block
        if (aIt != bb->begin()) {
          do {
            --aIt;
            SIRInstruction* aInstr = *aIt;
            if (aInstr->HasName() && (aInstr->GetName()[0] == 'a')) {
              unsigned aid = immRd.GetIntImmediate(aInstr->GetName().substr(1));
              if ((aid < cs->arg_size()) && !cs->GetArgument(aid)) {
                ES_LOG_P(logLv_, log_,">>-- Def arg_"<< aid <<": "<< *aInstr<<"\n");
                cs->SetArgument(aid, aInstr);
              }// if ((aid < cs->arg_size()) && !cs->GetArgument(aid))
            }
          } while (aIt != bb->begin());
        }// if (aIt != bb->begin())
        for (int i = 0, e=cs->arg_size(); i < e; ++i) {
          if (cs->GetArgument(i)) { continue; }
          const string& aName = "a" + Int2DecString(i);
          for (SIRBasicBlock::li_iterator lIt = bb->li_begin();
               lIt != bb->li_end(); ++lIt) {
            if ((*lIt)->GetName() == aName) { cs->SetArgument(i, *lIt); break; }
          }
          if (!cs->GetArgument(i)) {
            SIRRegister* li = new SIRRegister(false, aName, bb);
            bb->AddLiveIn(li);
            cs->SetArgument(i, li);
          }
        }
      }// if (callee->arg_size() > 0)
    }// for bb iterator iIt
  }// for func iterator bIt
}// InitCallSite()

void SIRInitValueInfoPass::
InitLiveness(SIRFunction* func, tr1::unordered_map<string, int>& valTab,
             tr1::unordered_map<int, string>& valNameTab) {
  ES_LOG_P(logLv_>1,log_,">> Initialize liveness and value IDs for "
           << func->GetName() <<'\n');
  func->GetStackPointer()->SetValueID(valTab["SP"] = func->AllocateValue());
  func->GetFramePointer()->SetValueID(valTab["FP"] = func->AllocateValue());
  func->GetLinkRegister()->SetValueID(valTab["RA"] = func->AllocateValue());
  valNameTab[func->GetStackPointer()->GetValueID()] = "SP";
  valNameTab[func->GetFramePointer()->GetValueID()] = "FP";
  valNameTab[func->GetLinkRegister()->GetValueID()] = "RA";

  if (SIRKernel* k = func->GetSolverKernel()) {
    for (int i = 0; i < 3; ++i) {
#undef SetVal
#define SetVal(N) k->Get##N(i)->SetValueID(\
        valTab[k->Get##N(i)->GetName()] = func->AllocateValue());       \
      valNameTab[k->Get##N(i)->GetValueID()] = k->Get##N(i)->GetName()

      SetVal(LocalID);  SetVal(GroupID);   SetVal(GlobalID);
      SetVal(NumGroup); SetVal(GroupSize); SetVal(GlobalSize);
      SetVal(LocalDimCounter);SetVal(GroupDimCounter);SetVal(GlobalDimCounter);
    }// for i = 0 to 2
#undef SetVal
#define SetVal(N) k->Get##N()->SetValueID(\
      valTab[k->Get##N()->GetName()] = func->AllocateValue());          \
    valNameTab[k->Get##N()->GetValueID()] = k->Get##N()->GetName()

    SetVal(LocalCounter); SetVal(GroupCounter); SetVal(GlobalCounter);

    k->GetLocalPredicate()->SetValueID(
      valTab[k->GetLocalPredicate()->GetName()]= func->AllocateFlag());
    valNameTab[k->GetLocalPredicate()->GetValueID()]
      = k->GetLocalPredicate()->GetName();
  }// if (func->IsSolverKernel())
#undef SetVal
  // First add all values need to keep track of in valTab
  for(SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt){
    SIRBasicBlock* bb = *bIt;
    //// Live-in variables of each block
    for (SIRBasicBlock::li_iterator lIt = bb->li_begin();
         lIt != bb->li_end(); ++lIt) {
      const string& rn = (*lIt)->GetName();
      if (!IsElementOf(rn, valTab)) {
        (*lIt)->SetValueID(valTab[(*lIt)->GetName()] = func->AllocateValue());
        valNameTab[(*lIt)->GetValueID()] = (*lIt)->GetName();
        ES_LOG_P(logLv_, log_, "-->>  "<< (*lIt)->GetName() <<" = "
                 <<(*lIt)->GetValueID()<<": LI B"<<bb->GetBasicBlockID()<<"\n");
      } else { (*lIt)->SetValueID(valTab[rn]); }
      if (!(*lIt)->GetParent()) { bb->AddBlockRegister(*lIt); }
    }

    // Set a "name" for call instruction that has return value
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt !=bb->end(); ++iIt) {
      if (SIRFunction* t = (*iIt)->GetCallTarget()) {
        if (!t->ret_empty()) { (*iIt)->SetName("v0"); }
      }// if (SIRFunction* t = (*iIt)->GetCallTarget())
    }
  }// for func iterator bIt
  // Assign value IDs to function arguments
  for (SIRFunction::arg_iterator aIt = func->arg_begin();
       aIt != func->arg_end(); ++aIt) {
    SIRRegister* arg = *aIt;
    const string& rn = arg->GetName();
    if (IsElementOf(rn, valTab)) { arg->SetValueID(valTab[rn]); }
    else {
      arg->SetValueID(valTab[rn] = func->AllocateValue());
      valNameTab[arg->GetValueID()] = rn;
    }// if (IsElementOf(rn, valTab))
    ES_LOG_P(logLv_, log_, "-->> arg "<< arg->GetName() <<" = "
             << arg->GetValueID()<<'\n');
  }// for func arg_iterator aIt

  for (SIRFunction::ret_iterator rIt = func->ret_begin();
       rIt != func->ret_end(); ++rIt) {
    SIRRegister* rr = *rIt;
    const string& rn = rr->GetName();
    if (IsElementOf(rn, valTab)) { rr->SetValueID(valTab[rn]);}
    else { rr->SetValueID(valTab[rn] = func->AllocateValue()); }
    ES_LOG_P(logLv_, log_, "-->> return value "<< rr->GetName() <<" = "
             << rr->GetValueID()<<'\n');
  }// for func ret_iterator rIt

  tr1::unordered_map<int, BitVector> blockLiveIns;
  tr1::unordered_map<int, BitVector> blockLiveOuts;
  tr1::unordered_map<int, BitVector> blockDefs;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    blockLiveIns [bb->GetBasicBlockID()].resize(func->GetNumValues());
    blockLiveOuts[bb->GetBasicBlockID()].resize(func->GetNumValues());
    blockDefs    [bb->GetBasicBlockID()].resize(func->GetNumValues());
  }

  for(SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt){
    SIRBasicBlock* bb = *bIt;
    BitVector& bbLI  = blockLiveIns[bb->GetBasicBlockID()];
    BitVector& bbDef = blockDefs[bb->GetBasicBlockID()];
    for (SIRBasicBlock::li_iterator lIt = bb->li_begin();
         lIt != bb->li_end(); ++lIt) { bbLI.set(valTab[(*lIt)->GetName()]); }
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      if (IsElementOf((*iIt)->GetName(), valTab)) {
        bbDef.set(valTab[(*iIt)->GetName()]);
      }
    }
    if (!bb->IsExitBlock()) { continue; }
    BitVector& bbLO  = blockLiveOuts[bb->GetBasicBlockID()];
    for (SIRFunction::ret_iterator rIt = func->ret_begin();
         rIt != func->ret_end(); ++rIt) { bbLO.set((*rIt)->GetValueID()); }
  }// for func iterator bIt

  int numBB = func->size();
  BitVector nIn(func->GetNumValues()), nOut(func->GetNumValues());
  // Solve dataflow equation
  while(1) {
    int fi = 0;
    for (SIRFunction::iterator bIt = func->begin();bIt != func->end();++bIt) {
      SIRBasicBlock* bb = *bIt;
      int bid = bb->GetBasicBlockID();
      nIn = blockLiveOuts[bid];
      nIn.reset(blockDefs[bid]);
      nIn |= blockLiveIns[bid];
      nOut = blockLiveOuts[bid];
      for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
           sIt != bb->succ_end(); ++sIt) {
        nOut |= blockLiveIns[(*sIt)->GetBasicBlockID()];
      }// for curBB->successors iterator
      if ((nIn == blockLiveIns[bid]) && (nOut == blockLiveOuts[bid])) { ++ fi; }
      else {
        blockLiveIns[bid]  = nIn;
        blockLiveOuts[bid] = nOut;
      }
    }// for func iterator
    if(fi == numBB) break;
  }// while(1)

  for(SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt){
    SIRBasicBlock* bb = *bIt;
    BitVector& li = blockLiveIns[bb->GetBasicBlockID()];
    BitVector& lo = blockLiveOuts[bb->GetBasicBlockID()];
    for (unsigned i = 0; i < func->GetNumValues(); ++i) {
      if (li[i]) { bb->AddLiveInValue(func->IsSolverKernel(),valNameTab[i],i); }
    }
    for (unsigned i = 0; i < func->GetNumValues(); ++i) {
      if (lo[i]){ bb->AddLiveOutValue(func->IsSolverKernel(),valNameTab[i],i); }
    }
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt!= bb->end(); ++iIt) {
      const string& n = (*iIt)->GetName();
      if (IsElementOf(n, valTab)) { (*iIt)->SetValueID(valTab[n]); }
    }
  }// for func iterator bIt
}// SIRInitValueInfoPass::InitLiveness()

void SIRInitValueInfoPass::
UpdateValueID(SIRFunction* func, tr1::unordered_map<string, int>& valTab,
              tr1::unordered_map<int, string>& valNameTab) {
  ES_LOG_P(logLv_, log_,">> Update value IDs for "<< func->GetName() <<'\n');
  valTab["ZERO"]  = SIRFunction::ZERO_REG_VALUE;
  valTab["PEID"]  = SIRFunction::PEID_REG_VALUE;
  valTab["NUMPE"] = SIRFunction::NUMPE_REG_VALUE;
  tr1::unordered_map<string, int> bbValTab;
  tr1::unordered_map<int, string> bbValNameTab;
  IntSet bbDefs;
  for (SIRFunction::iterator bIt = func->begin(); bIt !=func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    ES_LOG_P(logLv_, log_, "-->> In BB"<< bb->GetBasicBlockID() <<'\n');
    bbDefs.clear();
    for (SIRBasicBlock::reverse_iterator iIt = bb->rbegin();
         iIt != bb->rend(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if ((GetSIROpNumOutput(instr->GetSIROpcode()) <= 0)
          && !instr->GetCallTarget()) { continue; }
      const string& iName = instr->GetName();
      if (!iName.empty() && ((iName[0] == 'v') || (iName[0] == 'a'))) {
        if (IsElementOf(iName, valTab)) { instr->SetValueID(valTab[iName]); }
        else { instr->SetValueID(valTab[iName] = func->AllocateValue()); }
      } else {
        // Assign new value ID for new definition
        if ((instr->GetValueID()<0)||IsElementOf(instr->GetValueID(),bbDefs)) {
          instr->SetValueID(func->AllocateValue());
          ES_LOG_P(logLv_,log_,"-->> New value: V_"<< instr->GetValueID() <<" for "
                   << *instr <<'\n');
        }
      }
      bbDefs.insert(instr->GetValueID());
      if (!instr->GetCallTarget())  { continue; }
      SIRBasicBlock::iterator it = iIt.base();
      while (it != bb->end()) {
        SIRInstruction* sInstr = *it;
        for (SIRInstruction::operand_iterator oIt = sInstr->operand_begin();
             oIt != sInstr->operand_end(); ++oIt) {
          if (SIRRegister::classof(*oIt)) {
            const string& oName = (*oIt)->GetName();
            if ((oName.size()>1) && (oName[0]=='v'))
            { sInstr->ChangeOperand(oIt, instr); }
          }
        }
        const string& sName = sInstr->GetName();
        if ((sName.size() > 1) && (sName[0] == 'v')) { break; }
        ++it;
      }// while(it != bb->end())
    }// bb reverse_iterator iIt
  }// for func iterator bIt
}// UpdateValueID()

static int GetImmValue(SIRInstruction* instr, unsigned i = 0) {
  // FIXME: should be a parsing error check instead of assertion
  ES_ASSERT_MSG((instr->operand_size() > i)
                && SIRConstant::classof(instr->GetOperand(i)),
                "Illegal operand");
  SIRConstant* c = static_cast<SIRConstant*>(instr->GetOperand(i));
  return c->GetImmediate();
}

bool SIRKernelParamPass::
RunOnSIRFunction(SIRFunction* func) {
  bool changed = true;
  if (func->IsLeaf()) { return false; }
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    SIRKernelLaunch kernelParams;
    kernelParams.clear();
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end();) {
      SIRInstruction* instr = *iIt;
      switch (instr->GetSIROpcode()) {
      case SIROpcode::NUMGR: {
        int gx = GetImmValue(instr, 0), gy = GetImmValue(instr, 1),
          gz = GetImmValue(instr, 2);
        if (gz > 1) { kernelParams.globalDim_ = 3; }
        else if (gy > 1) { kernelParams.globalDim_ = 2; }
        else { kernelParams.globalDim_ = 1; }
        kernelParams.numGroups_[0] = gx;
        kernelParams.numGroups_[1] = gy;
        kernelParams.numGroups_[2] = gz;
        iIt = bb->erase(iIt);
        break;
      }
      case SIROpcode::GRSIZE: {
        int gx = GetImmValue(instr, 0), gy = GetImmValue(instr, 1),
          gz = GetImmValue(instr, 2);
        if (gz > 1) { kernelParams.groupDim_ = 3; }
        else if (gy > 1) { kernelParams.groupDim_ = 2; }
        else { kernelParams.groupDim_ = 1; }
        kernelParams.groupSize_[0] = gx;
        kernelParams.groupSize_[1] = gy;
        kernelParams.groupSize_[2] = gz;
        iIt = bb->erase(iIt);
        break;
      }
      case SIROpcode::CALL: {
        if (SIRFunction* tgtFn
            = dynamic_cast<SIRFunction*>(instr->GetOperand(0))) {
          if (tgtFn->IsSolverKernel()) {
            SIRKernel* k = tgtFn->GetSolverKernel();
            if (k->GetLaunchParams().Valid()) {
              ES_NOTSUPPORTED("Current implementation can only launch each"
                              " kernel once");
            }
            k->GetLaunchParams() = kernelParams;
            ES_LOG_P(logLv_>1, log_, ">>>> Launching "<< tgtFn->GetName()
                     <<" with "<< kernelParams <<"\n");
            kernelParams.clear();
            changed = true;
          }
        }// if (tgtFn = instr->GetOperand(0))
        ++iIt;
        break;
      }// case SIROpcode::CALL:
      default: ++iIt; break;
      }// switch (instr->GetSIROpcode())
    }// for bb iterator iIt
  }// for func iterator bIt
  return changed;
}// SIRKernelParamPass::RunOnSIRFunction()
