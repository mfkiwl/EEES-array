#include "BaselineKernelBuilder.hh"
#include "BaselineBasicInfo.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "SIR/SIRKernel.hh"
#include "SIR/SIRMemLocation.hh"
#include "SIR/SIRExpr.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

BaselineKernelBuilder::~BaselineKernelBuilder() {}

void BaselineKernelBuilder::
ModuleInit(SIRModule* m) { module_ = m; }

bool BaselineKernelBuilder::
RunOnSIRFunction(SIRFunction* func) {
  if (!func || !func->IsSolverKernel() || func->empty()) { return false; }

  ES_LOG_P(logLv_, log_, ">> Building Solver kernel "<< func->GetName() <<"\n");
  func_ = func;
  kernel_ = func_->GetSolverKernel();
  const SIRKernelLaunch& kl = kernel_->GetLaunchParams();
  if (!kl.Valid()) { ES_NOTIMPLEMENTED("Dynamic kernel launch"); }
  unsigned totNumGroups = kl.GetTotalNumGroups();
  unsigned totGroupSize = kl.GetTotalGroupSize();
  ES_LOG_P(logLv_, log_, ">> Kernel has "<< totNumGroups <<" group(s) and "
           << totGroupSize <<" item(s) in each group\n");
  func_->front()->SetName("$"+func_->GetName() + ".kernel");
  if (totNumGroups == 1) {
    MapSingleGroupKernel();
  } else {// if (totNumGroups == 1)
    TransformIndex();
    InsertLocalLoop();
    InsertGlobalLoop();
    KernelAddressCodeGen();
  }// if (totNumGroups == 1)
  EliminateRedudantAccess();
  func_->RemoveDeadValues();
  func_->front()->SetName(func_->GetName());
  func_->SetEntryBlock(func_->front());
  /// Insert kernel exit
  SIRBasicBlock *kExit = new SIRBasicBlock(func_->GetNewBasicBlockID(), func_);
  kExit->pred_push_back(func_->back());
  func_->back()->succ_push_back(kExit);
  func_->push_back(kExit);
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    (*bIt)->SetExitBlock(false);
  }
  kExit->SetExitBlock(true);
  func_->UpdateControlFlowInfo();
  func_->UpdateLiveness();
  if (logLv_) { func_->ValuePrint(log_); }
  return true;
}// RunOnSIRFunction()

void BaselineKernelBuilder::
TransformIndex() {
  // Get the row address and column offset of each memory address
  for (SIRFunction::iterator bIt = func_->begin(); bIt != func_->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (!IsSIRMemoryOp(instr->GetSIROpcode())) { continue; }
      ES_LOG_P(logLv_, log_, "-->> Analyzing "<< *instr <<'\n');
      unsigned base = IsSIRLoad(instr->GetSIROpcode()) ? 0 : 1;
      SIRMemLocation* mloc = AnalyzeKernelAddress(
        instr->GetOperand(base), instr->GetOperand(base+1),
        instr->GetSIROpcode());
      instr->SetMemLocationInfo(mloc);
    }// for bb iterator iIt
  }// for func iterator bIt
}// TransformIndex()

void BaselineKernelBuilder::
InsertLocalLoop() {
  // For now, the whole workgroup is flatten in one loop.
  const SIRKernelLaunch& kl = kernel_->GetLaunchParams();
  unsigned totGroupSize = kl.GetTotalGroupSize();
  if (totGroupSize <= 1) { return; }
  std::list<SIRBasicBlock*> kernelBlocks;
  for (SIRFunction::iterator it = func_->begin(); it != func_->end(); ++it) {
    kernelBlocks.push_back(*it);
  }
  SIRFunction::iterator entIter = func_->begin(), extIter = func_->end();
  unsigned nExt = 0;
  for (SIRFunction::iterator bIt = func_->begin(); bIt != func_->end(); ++bIt) {
    if ((*bIt)->IsExitBlock()) { ++nExt; extIter = bIt; }
  }// for func iterator bit
  if (nExt != 1) { ES_NOTIMPLEMENTED("Kernel with #ExitBlock != 1"); }
  SIRBasicBlock *localPH=NULL, *localHdr=*entIter, *localExt=*extIter;
  BuildLoopWithPreHeader(localPH, localHdr, localExt,
                         module_->AddOrGetImmediate(totGroupSize),
                         func_->GetNumPERegister(), SIROpcode::SUB,
                         kernelBlocks, *entIter, *extIter, func_);
  kernel_->SetLocalPreHeader(localPH);
  kernel_->SetLocalHeader(localHdr);
  kernel_->SetLocalExit(localExt);
  int lBoundVal = -1;
  for (SIRBasicBlock::iterator it=localPH->begin(); it != localPH->end(); ++it) {
    if (((*it)->GetSIROpcode() == SIROpcode::MOV)
        && (*it)->GetOperand(0) == module_->AddOrGetImmediate(totGroupSize)) {
      lBoundVal = (*it)->GetValueID();
      break;
    }
  }
  ES_ASSERT(lBoundVal>=0);
  // Calculate kernel predicate
  SIRInstruction& lPred = localHdr->BuildSIRInstr(
    localHdr->begin(), true, SIROpcode::SFGTS,
    kernel_->GetLocalPredicate()->GetValueID())
    .AddOperand(localHdr->AddOrGetBlockRegister(lBoundVal, false))
    .AddOperand(func_->GetPEIDRegister());
  for (std::list<SIRBasicBlock*>::iterator bIt = kernelBlocks.begin();
       bIt != kernelBlocks.end(); ++bIt) { (*bIt)->AddBlockPredicate(&lPred); }
}// InsertLocalLoop()

void BaselineKernelBuilder::
InsertGlobalLoop() {
  const SIRKernelLaunch& kl = kernel_->GetLaunchParams();
  unsigned totNumGroup = kl.GetTotalNumGroups();
  if (totNumGroup <= 1) {
    kernel_->SetGlobalPreHeader(kernel_->GetLocalPreHeader());
    kernel_->SetGlobalHeader   (kernel_->GetLocalHeader());
    kernel_->SetGlobalExit     (kernel_->GetLocalExit());
    return;
  }// if (totNumGroup <= 1)
  std::list<SIRBasicBlock*> kernelBlocks;
  for (SIRFunction::iterator it = func_->begin(); it != func_->end(); ++it) {
    kernelBlocks.push_back(*it);
  }
  SIRFunction::iterator entIter = func_->begin(), extIter = func_->end();
  if (kernel_->GetLocalPreHeader()) {
    entIter = find(func_->begin(), func_->end(), kernel_->GetLocalPreHeader());
  }
  if (kernel_->GetLocalExit()) {
    extIter = find(func_->begin(), func_->end(), kernel_->GetLocalExit());
  } else {
    unsigned nExt = 0;
    for (SIRFunction::iterator bIt = func_->begin(); bIt != func_->end(); ++bIt) {
      if ((*bIt)->IsExitBlock()) { ++nExt; extIter = bIt; }
    }// for func iterator bit
    if (nExt != 1) { ES_NOTIMPLEMENTED("Kernel with #ExitBlock != 1"); }
  }
  SIRBasicBlock *globalPH=NULL, *globalHdr=kernel_->GetLocalPreHeader(),
    *globalExt=NULL;
  BuildLoopWithPreHeader(
    globalPH, globalHdr, globalExt, module_->AddOrGetImmediate(totNumGroup),
    module_->AddOrGetImmediate(-1), SIROpcode::ADD, kernelBlocks,
    *entIter, *extIter, func_);
  kernel_->SetGlobalPreHeader(globalPH);
  kernel_->SetGlobalHeader(globalHdr);
  kernel_->SetGlobalExit(globalExt);
}// InsertGlobalLoop()

static int
InsertVarDistanceStore(SIRBasicBlock::iterator it, SIRValue* rowAddrVal,
                       SIRBasicBlock*  bb, const BaselineBasicInfo& target,
                       bool logLv, ostream& logs) {
  int sp = 1;
  SIRInstruction* mInstr = *it;
  SIRMemLocation* mloc = mInstr->GetMemLocationInfo();
  SIRBinExprNode* colOffset = mloc->GetColumnOffset();
  SIRFunction* func = bb->GetParent();
  SIRModule* module = func->GetParent();
  SIRKernel* kernel = func->GetSolverKernel();
  int nPE = target.GetNumPE();
  int maxDist = CalculateMaxCommDist(colOffset, nPE, kernel, func);
  ES_LOG_P(logLv, logs, ">>-- Variable distance store: "<< *colOffset
                 <<", max offset = "<< maxDist <<"\n");
  SIRBasicBlock::iterator spIt = it;
  SIRBasicBlock* nbb = bb->SplitBlock(spIt);
  SIRFunction::iterator insIt = find(func->begin(), func->end(), bb); ++insIt;
  func->insert(insIt, nbb);
  SIRBasicBlock* nnbb = nbb;
  spIt = nbb->find(nbb->begin(), nbb->end(), mInstr);
  if (++spIt != nbb->end()) {
    ++sp; nnbb = nbb->SplitBlock(spIt);
    func->insert(insIt, nnbb);
  }
  if (kernel->GetLocalExit() == bb)  { kernel->SetLocalExit(nnbb);  }
  if (kernel->GetGlobalExit() == bb) { kernel->SetGlobalExit(nnbb); }
  SIRBasicBlock *commBody = nbb;
  vector<SIRBasicBlock*> commSuccs;// Not creating new block, use empty succ
  insIt = find(func->begin(), func->end(), nbb);
  BuildEmptyLoop(
    insIt, bb, commBody, commSuccs, module->AddOrGetImmediate(maxDist+1),
    module->AddOrGetImmediate(-1), SIROpcode::ADD, func);
  SIRBinExprNode* colAddr = SIRBinExprNode::CreateBinExprNode(
    module, SIROpcode::ADD, colOffset,
    SIRBinExprNode::CreateBinExprNode(func->GetPEIDRegister()))->Simplify();
  SIRInstruction* colAddrVal = &bb->BuildSIRInstr(bb->end(), true, colAddr);
  SIRValue* baseVal = mInstr->GetOperand(1);
  bool vectColAddr = colAddrVal->IsVectorInstr(),
    vectRowAddr = rowAddrVal->IsVectorValue();
  /// Base + row address
  SIRInstruction* calRowAddr = &bb->BuildSIRInstr(
    bb->end(), vectRowAddr, SIROpcode::ADD, func->AllocateValue())
    .AddOperand(baseVal).AddOperand(rowAddrVal);
  colAddrVal->SetInstrType(SIRInstruction::IT_Vector);
  ES_LOG_P(logLv, logs, "-->> Column addr = "<< *colAddr
           <<(vectColAddr ? "[Vector]\n":"\n"));
  ES_LOG_P(logLv, logs, "-->> Row addr = "<< *mloc->GetRowAddress()
           <<(vectRowAddr ? "[Vector]\n":"\n"));
  SIRBasicBlock::iterator mIt = find(nbb->begin(), nbb->end(), mInstr);
  // Calculate predicate for the store
  SIRRegister* colAddrReg = nbb->AddOrGetBlockRegister(
    colAddrVal->GetValueID(), true);
  SIRInstruction* stPred = &nbb->BuildSIRInstr(
    mIt, true, SIROpcode::SFEQ, func->AllocateFlag())
    .AddOperand(colAddrReg).AddOperand(func->GetPEIDRegister());
  mInstr->AddPredicate(stPred);
  SIRRegister* stValReg
    = nbb->AddOrGetBlockRegister(mInstr->GetOperand(0)->GetValueID(), true);
  ++mIt;
  if (vectRowAddr){
    SIRInstruction* raCpy = &bb->BuildSIRInstr(
      bb->end(), true, SIROpcode::MOV, func->AllocateValue())
      .AddOperand(calRowAddr);
    mInstr->ChangeOperand(1, raCpy);
    nbb->BuildSIRInstr(mIt, true, SIROpcode::READ_R, raCpy->GetValueID())
      .AddOperand(raCpy).AddOperand(module->AddOrGetImmediate(1));
  } else {
    SIRRegister* rowAddrReg
      = nbb->AddOrGetBlockRegister(calRowAddr->GetValueID(), vectRowAddr);
    mInstr->ChangeOperand(1, rowAddrReg);
  }// if (vectRowAddr)
  mInstr->ChangeOperand(2, module->AddOrGetImmediate(0));
  if (vectColAddr) {
    nbb->BuildSIRInstr(mIt, true, SIROpcode::READ_R, colAddrReg->GetValueID())
      .AddOperand(colAddrReg).AddOperand(module->AddOrGetImmediate(1));
  }// if (vectRowAddr)
  // Shift the value to be stored
  nbb->BuildSIRInstr(mIt, true, SIROpcode::READ_R, stValReg->GetValueID())
    .AddOperand(stValReg).AddOperand(module->AddOrGetImmediate(1));
  nbb->SetInfo("Shifting loop for V_"+Int2DecString(stValReg->GetValueID()));
  return sp;
}// InsertVarDistanceStore()

static int
InsertVarDistanceLoad(SIRBasicBlock::iterator it, SIRValue* rowAddrVal,
                       SIRBasicBlock* bb, const BaselineBasicInfo& target,
                       bool logLv, ostream& logs) {
  int sp = 1;
  SIRInstruction* mInstr = *it;
  SIRMemLocation* mloc = mInstr->GetMemLocationInfo();
  SIRBinExprNode* colOffset = mloc->GetColumnOffset();
  SIRFunction* func = bb->GetParent();
  SIRModule* module = func->GetParent();
  SIRKernel* kernel = func->GetSolverKernel();
  int nPE = target.GetNumPE();
  ES_LOG_P(logLv, logs,">>-- Variable distance load: "<< *colOffset <<"\n");
  SIRBasicBlock::iterator spIt = it;
  SIRBasicBlock* nbb = bb->SplitBlock(spIt);
  SIRFunction::iterator insIt = find(func->begin(), func->end(), bb); ++insIt;
  func->insert(insIt, nbb);
  SIRBasicBlock* nnbb = nbb;
  spIt = nbb->find(nbb->begin(), nbb->end(), mInstr);
  if (++spIt != nbb->end()) {
    ++sp; nnbb = nbb->SplitBlock(spIt);
    func->insert(insIt, nnbb);
  }
  if (kernel->GetLocalExit() == bb)  { kernel->SetLocalExit(nnbb);  }
  if (kernel->GetGlobalExit() == bb) { kernel->SetGlobalExit(nnbb); }
  SIRBasicBlock *commBody = nbb;
  vector<SIRBasicBlock*> commSuccs;
  insIt = find(func->begin(), func->end(), nbb);
  BuildEmptyLoop(
    insIt, bb, commBody, commSuccs, module->AddOrGetImmediate(nPE),
    module->AddOrGetImmediate(-1), SIROpcode::ADD, func);
  SIRBinExprNode* colAddr = SIRBinExprNode::CreateBinExprNode(
    module, SIROpcode::ADD, colOffset,
    SIRBinExprNode::CreateBinExprNode(func->GetPEIDRegister()))->Simplify();
  SIRInstruction* colAddrVal = &bb->BuildSIRInstr(bb->end(), true, colAddr);
  bool vectColAddr = colAddrVal->IsVectorInstr(),
    vectRowAddr = rowAddrVal->IsVectorValue();
  colAddrVal->SetInstrType(SIRInstruction::IT_Vector);
  /// Base + row address
  SIRInstruction* calRowAddr = &bb->BuildSIRInstr(
    bb->end(), true, SIROpcode::ADD, func->AllocateValue())
    .AddOperand(mInstr->GetOperand(0)).AddOperand(rowAddrVal);
  mInstr->ChangeOperand(1, module->AddOrGetImmediate(0));
  ES_LOG_P(logLv, logs, "-->> Column addr = "<< *colAddr
           <<(vectColAddr ? "[Vector]\n":"\n"));
  ES_LOG_P(logLv, logs, "-->> Row addr = "<< *mloc->GetRowAddress()
           <<(vectRowAddr ? "[Vector]\n":"\n"));
  SIRBasicBlock::iterator mIt = find(nbb->begin(), nbb->end(), mInstr);
  // Calculate predicate for the load
  SIRRegister* colAddrReg = nbb->AddOrGetBlockRegister(
    colAddrVal->GetValueID(), true);
  SIRInstruction* ldPred = &nbb->BuildSIRInstr(
    mIt, true, SIROpcode::SFEQ, func->AllocateFlag())
    .AddOperand(colAddrReg).AddOperand(func->GetPEIDRegister());
  mInstr->AddPredicate(ldPred);
  ++mIt;
  if (vectRowAddr){
    SIRInstruction* raCpy = &bb->BuildSIRInstr(
      bb->end(), true, SIROpcode::MOV, func->AllocateValue())
      .AddOperand(calRowAddr);
    mInstr->ChangeOperand(0, raCpy);
    nbb->BuildSIRInstr(mIt, true, SIROpcode::READ_R, raCpy->GetValueID())
      .AddOperand(raCpy).AddOperand(module->AddOrGetImmediate(1));
  } else {
    SIRRegister* rowAddrReg
      = nbb->AddOrGetBlockRegister(calRowAddr->GetValueID(), vectRowAddr);
    mInstr->ChangeOperand(0, rowAddrReg);
  }// if (vectRowAddr)
  if (vectColAddr) {
    nbb->BuildSIRInstr(mIt, true, SIROpcode::READ_R, colAddrReg->GetValueID())
      .AddOperand(colAddrReg).AddOperand(module->AddOrGetImmediate(1));
  }// if (vectRowAddr)
  // Shift the loaded value
  int mVal = mInstr->GetValueID();
  nbb->BuildSIRInstr(mIt, true, SIROpcode::READ_R, mVal)
    .AddOperand(mInstr).AddOperand(module->AddOrGetImmediate(1));
  nbb->SetInfo("Shifting loop for V_"+Int2DecString(mVal));
  return sp;
}// InsertVarDistanceLoad()

void BaselineKernelBuilder::
KernelAddressCodeGen() {
  ES_LOG_P(logLv_, log_, ">> Generating address expressions\n");
  ExprInvariantChecker invCheck(func_, logLv_, log_);
  bool useLocCnt = false, useGlbCnt = false, useGrpCnt = false;
  for (SIRFunction::iterator bIt = func_->begin(); bIt != func_->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (!IsSIRMemoryOp(instr->GetSIROpcode())) { continue; }
      if (!instr->IsVectorInstr()) { continue; }
      SIRMemLocation* mloc = instr->GetMemLocationInfo();
      SIRRegister* baseReg      = mloc->GetScalarBaseReg();
      SIRBinExprNode* rowAddr   = mloc->GetRowAddress();
      SIRBinExprNode* colOffset = mloc->GetColumnOffset();
      ES_ASSERT(baseReg && rowAddr && colOffset);
      useLocCnt |= rowAddr->UsesValue(kernel_->GetLocalCounter()->GetValueID());
      useGlbCnt |= rowAddr->UsesValue(kernel_->GetGlobalCounter()->GetValueID());
      ES_LOG_P(logLv_, log_, ">>-- "<< func_->GetName() <<".B"
               << bb->GetBasicBlockID() <<" Addr("<< mloc->GetAddressSpace()
               <<"): base reg = "<< *baseReg <<", row addr = "<< *rowAddr
               <<", column offset = "<< *colOffset <<"\n");
      SIRValue* rAddrValue = kernel_->GetCachedExprValue(rowAddr);
      if (rAddrValue) {
        ES_LOG_P(logLv_,log_,">>-->> Hit in expr cache: "<< *rAddrValue <<"\n");
      } else {// if (rAddrValue)
        invCheck.Reset();
        rowAddr->VisitNodesPreOrder(invCheck);
        SIRBasicBlock* hdr = NULL;
        if (invCheck.globalInvariant_ || invCheck.localInvariant_) {
          ES_LOG_P(logLv_, log_, ">>-->>-- Invariant row address: "
                   << *rowAddr <<"\n");
          hdr = invCheck.globalInvariant_ ?
            kernel_->GetGlobalPreHeader() : kernel_->GetLocalHeader();
          rAddrValue = &hdr->BuildSIRInstr(hdr->begin(), false, rowAddr);
          kernel_->SetExprValue(rowAddr, rAddrValue);
        } else {
          // Address needs to be computed in place
          ES_LOG_P(logLv_,log_,">>-->>-- Dynamic row address "<<*rowAddr<<"\n");
          rAddrValue = &bb->BuildSIRInstr(iIt, true, rowAddr);
        }// if (invCheck.globalInvariant_ || invCheck.localInvariant_)
        ES_ASSERT_MSG(rAddrValue, "Invalid row address value for "<< *rowAddr);
      }// if (rAddrValue)
      ES_ASSERT_MSG(SIRInstruction::classof(rAddrValue),
                    "Row address value should be an instruction");
      SIRValue* offVal = rAddrValue;
      if (static_cast<SIRInstruction*>(rAddrValue)->GetParent() != bb) {
        offVal = bb->AddOrGetLiveIn(rAddrValue->IsVectorValue(),
                                    rAddrValue->GetValueID());
      }
      unsigned oi = IsSIRLoad(instr->GetSIROpcode()) ? 0 : 1;
      instr->ChangeOperand(oi, baseReg);
      instr->ChangeOperand(oi+1, offVal);
      // Check if communication is required
      if (colOffset->IsLeaf()) {
        if (colOffset->IsConstant()) {
          int commDist = colOffset->GetConstant();
          if (commDist == 0) { continue; }
          SIROpcode_t comOpc = (commDist>0)?SIROpcode::READ_R:SIROpcode::READ_L;
          ES_LOG_P(logLv_, log_, ">>-->>-- "<< comOpc <<" -- "<< commDist <<"\n");
          SIRBasicBlock::iterator ip = iIt; ++ip;
          int ldVal = instr->GetValueID();
          instr->SetValueID(func_->AllocateValue());
          SIRInstruction* cInstr = &bb->BuildSIRInstr(ip, true, comOpc, ldVal);
          cInstr->AddOperand(instr).AddOperand(
            module_->AddOrGetImmediate(abs(commDist)));
          for (SIRBasicBlock::iterator dIt = ip; dIt != bb->end(); ++dIt) {
            (*dIt)->ReplaceOperand(instr, cInstr);
          }
        }// if (SIRConstant::classof(coVal))
      } else {// if (colOffset->IsLeaf())
        if (IsSIRStore(instr->GetSIROpcode())) {
          int sp = InsertVarDistanceStore(iIt, offVal, bb, target_, logLv_, log_);
          iIt = bb->end(); --iIt;
          for (int i = 0; i < sp; ++i) { ++bIt; }
        } else {
          int sp = InsertVarDistanceLoad(iIt, offVal, bb, target_, logLv_, log_);
          iIt = bb->end(); --iIt;
          // for (int i = 0; i < sp; ++i) { ++bIt; }
          ++bIt;
          // ES_NOTIMPLEMENTED("Variable distance load");
        }
      }// // if (colOffset->IsLeaf())
    }// for bb iterator iIt
  }// for func iterator bIt
  /// Local counter init and update
  if (useLocCnt) {
    SIRInstruction* lCnt = &kernel_->GetLocalPreHeader()->BuildSIRInstr(
      kernel_->GetLocalPreHeader()->end(), false, SIROpcode::MOV,
      kernel_->GetLocalCounter()->GetValueID())
      .AddOperand(module_->AddOrGetImmediate(0));
    SIRBasicBlock::iterator eIt = kernel_->GetLocalExit()->end();
    kernel_->GetLocalExit()->BuildSIRInstr(
      --eIt, false, SIROpcode::ADD, lCnt->GetValueID())
      .AddOperand(kernel_->GetLocalCounter())
      .AddOperand(module_->AddOrGetImmediate(1));
  }// if (useLocCnt)
  /// Group counter init and update
  if (useGrpCnt) {
    SIRInstruction* gCnt = &kernel_->GetLocalPreHeader()->BuildSIRInstr(
      kernel_->GetLocalPreHeader()->end(), false, SIROpcode::MOV,
      kernel_->GetGroupCounter()->GetValueID())
      .AddOperand(module_->AddOrGetImmediate(0));
    SIRBasicBlock::iterator eIt = kernel_->GetLocalExit()->end();
    kernel_->GetLocalExit()->BuildSIRInstr(
      --eIt, false, SIROpcode::ADD, gCnt->GetValueID())
      .AddOperand(kernel_->GetGroupCounter())
      .AddOperand(module_->AddOrGetImmediate(1));
  }// if (useGrpCnt)
  /// Global counter init and update
  if (useGlbCnt) {
    SIRInstruction* gCnt = &kernel_->GetGlobalPreHeader()->BuildSIRInstr(
      kernel_->GetGlobalPreHeader()->begin(), false, SIROpcode::MOV,
      kernel_->GetGlobalCounter()->GetValueID())
      .AddOperand(module_->AddOrGetImmediate(0));
    SIRBasicBlock::iterator eIt = kernel_->GetLocalExit()->end();
    kernel_->GetLocalExit()->BuildSIRInstr(
      --eIt, false, SIROpcode::ADD, gCnt->GetValueID())
      .AddOperand(kernel_->GetGlobalCounter())
      .AddOperand(module_->AddOrGetImmediate(1));
    for (SIRBasicBlock::iterator iIt = kernel_->GetGlobalPreHeader()->begin();
         iIt != kernel_->GetGlobalPreHeader()->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (instr == gCnt) { continue; }
      for (unsigned i = 0; i < instr->operand_size(); ++i) {
        if (instr->GetOperand(i)->GetValueID() == gCnt->GetValueID()) {
          instr->ChangeOperand(i, gCnt);
        }
      }
      if (instr->GetValueID() == gCnt->GetValueID()) { break; }
    }
  }// if (useGlbCnt)
  if(logLv_) { func_->ValuePrint(log_); }
}// KernelAddressCodeGen()

void BaselineKernelBuilder::
EliminateRedudantAccess() {
  vector<SIRInstruction*> loads;
  for (SIRFunction::iterator bIt = func_->begin(); bIt != func_->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (!instr->IsVectorInstr()||!IsSIRLoad(instr->GetSIROpcode())){continue;}
      SIRMemLocation* mloc = instr->GetMemLocationInfo();
      if (!mloc) { continue; }
      SIRRegister* baseReg      = mloc->GetScalarBaseReg();
      SIRBinExprNode* rowAddr   = mloc->GetRowAddress();
      if (baseReg && rowAddr) { loads.push_back(instr); }
    }// for bb iterator iIt
  }// for func iterator bIt
  vector<BitVector> addrMatrix(loads.size(), BitVector(loads.size(), false));
  // addrMatrix[i][j]: true if load[i] and load[j] have the same address.
  // Note that addrMatrix[i][i] is left unset to make analysis easier.
  set<SIRInstruction*> replacedInstr;
  for (int i = 0, e = loads.size(); i < e; ++i) {
    if (IsElementOf(loads[i], replacedInstr)) { continue; }
    SIRMemLocation* iLoc = loads[i]->GetMemLocationInfo();
    int iBaseVal = iLoc->GetScalarBaseReg()->GetValueID();
    SIRBinExprNode* iRow  = iLoc->GetRowAddress();
    for (int j = i+1; j < e; ++j) {
      SIRMemLocation* jLoc = loads[j]->GetMemLocationInfo();
      if ((jLoc->GetScalarBaseReg()->GetValueID() == iBaseVal)
          && (*jLoc->GetRowAddress() == *iRow)) { addrMatrix[i][j] = true; }
    }// for j = i+1 to e-1
    SIRBasicBlock* ibb = loads[i]->GetParent();
    SIRBasicBlock::iterator iIt = ibb->find(ibb->begin(), ibb->end(), loads[i]);
    SIRBasicBlock::const_iterator ciIt = ibb->find(ibb->begin(), ibb->end(), loads[i]);
    vector<SIRInstruction*>::iterator ldBegin = loads.begin();
    int iVal = loads[i]->GetValueID();
    int iLocID = loads[i]->GetMemoryLocationID();
    // Check if there is redundant loads in ibb
    bool killed = false;
    for (++iIt; iIt != ibb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (!instr->IsVectorInstr()){continue;}
      // Load is killed by another definition
      if (instr->GetValueID() == iVal) { killed = true; break; }
      // Check if there is a store to the same address (including possible alias)
      if (IsSIRStore(instr->GetSIROpcode())) {
        int sLocID = instr->GetMemoryLocationID();
        // Possible alias, let's be conservative
        if (!instr->GetMemLocationInfo()
            && ( (iLocID <=0) || (sLocID <=0)
                 || func_->AliasTableValue(iLocID, sLocID) )) {
          killed = true; break;
        }
        SIRMemLocation* sLoc = instr->GetMemLocationInfo();
        if ((sLoc->GetScalarBaseReg()->GetValueID() == iBaseVal)
            && (*sLoc->GetRowAddress() == *iRow)) { killed = true; break; }
      }// if (IsSIRStore(instr->GetSIROpcode()))
      if (!IsSIRLoad(instr->GetSIROpcode())) { continue; }
      vector<SIRInstruction*>::iterator lIt = find(ldBegin, loads.end(), instr);
      if ((lIt == loads.end()) || !addrMatrix[i][lIt-ldBegin]) { continue; }
      ibb->ReplaceInstrValue(iIt, loads[i]);
      replacedInstr.insert(*iIt);
    }// for ibb iterator iIt
    if (killed || !ibb->InstrLiveOut(ciIt)) { continue; }
    // TODO: propagate value across blocks
  }// for i = 0 to loads.size()-1
}// EliminateRedudantAccess()

SIRMemLocation* BaselineKernelBuilder::
AnalyzeKernelAddress(SIRValue* base, SIRValue* offset, SIROpcode_t opc) {
  SIRMemLocation* memLoc = new SIRMemLocation(base, offset, opc, func_);
  ES_LOG_P(logLv_, log_, ">>-- Addr = "<< *(memLoc->GetExpr())
           <<" in address space "<< memLoc->GetAddressSpace() <<"\n");
  LowerKernelSpecialRegs sRegLowering(func_,target_,logLv_,log_);
  if (memLoc->TransformToStandardForm()) {
    memLoc->GetExpr()->GetRHS()->GetLHS()->VisitNodesPreOrder(sRegLowering);
    LowerStandardKernelAddress(memLoc);
  } else if (memLoc->IsShiftedStandardKernelForm()) {
    memLoc->GetExpr()->GetRHS()->GetLHS()->GetLHS()
      ->VisitNodesPreOrder(sRegLowering);
    LowerShiftedStandardKernelAddress(memLoc);
  } else {// if (memLoc->IsStandardKernelForm())
    ES_NOTIMPLEMENTED("Kernel address in non-standard form: "<< *memLoc);
  }// if (memLoc->IsStandardKernelForm())
  return memLoc;
}// AnalyzeKernelAddress()

/// Calculate row address: offset / NUMPE
static SIRBinExprNode*
CalculateRowAddress(SIRBinExprNode* expr, SIRKernel* kernel,
                    const BaselineBasicInfo& target) {
  if (!expr) { return NULL; }
  ES_ASSERT_MSG(kernel->GetLaunchParams().Valid(),
                "Non-static launch parameters not supported");
  SIRFunction* func = kernel->GetParent();
  SIRModule* module = func->GetParent();
  int numPE = target.GetNumPE();
  SIRRegister* nPEReg = func->GetNumPERegister();
  SIRRegister* peIDReg = func->GetPEIDRegister();
  if (expr->IsLeaf()) {
    if (expr->GetValue()->ValueEqual(peIDReg)) {
      expr->SetValue(module->AddOrGetImmediate(0));
    } else if (expr->IsConstant()) {
      expr->SetValue(module->AddOrGetImmediate(expr->GetConstant() / numPE));
    } else {// if expr->GetValue()->ValueEqual(func->GetPEIDRegister())
      int gid = kernel->GetGlobalDimCounterIndex(expr->GetValue());
      if (gid >= 0) {
        if (kernel->GetGlobalDimCounterMax(gid) < numPE) {
          expr->SetValue(module->AddOrGetImmediate(0));
        }
      }// if (gid >= 0)
    }// if expr->GetValue()->ValueEqual(func->GetPEIDRegister())
  } else {// if (expr->IsLeaf())
    SIROpcode_t opc = expr->GetOpcode();
    switch (opc) {
    case SIROpcode::MUL:
      if (expr->GetRHS()->ValueEqual(nPEReg)
          || expr->GetRHS()->ConstantEqual(numPE)) { *expr = *expr->GetLHS(); }
      else if (expr->GetLHS()->ValueEqual(nPEReg)
               || expr->GetLHS()->ConstantEqual(numPE)) {
        *expr = *expr->GetRHS();
      }
      break;
    case SIROpcode::ADD: case SIROpcode::SUB: {
      //SIRBinExprNode* origExpr = SIRBinExprNode::CreateBinExprNode(expr);
      //cout <<"L["<< *origExpr <<"]: "<< *expr->GetLHS() << " = ";
      CalculateRowAddress(expr->GetLHS(), kernel, target);
      //cout << *expr->GetLHS() << endl;
      //cout <<"R["<< *origExpr <<"]: "<< *expr->GetRHS() <<" = ";
      CalculateRowAddress(expr->GetRHS(), kernel, target);
      //cout << *expr->GetRHS() << endl;
      // if (!(*expr == *origExpr)) { CalculateRowAddress(expr, kernel, target); }
      break;
    }
    default:
      ES_NOTIMPLEMENTED("Cannot handle expression: "<< *expr);
    }
  }// if (expr->IsLeaf()) else
  expr->Simplify();
  return expr;
}// CalculateRowAddress()

static SIRBinExprNode*
CalculateModNumPE(SIRBinExprNode* expr, int numPE, SIRRegister* nPEReg,
                   SIRRegister* peIDReg, SIRModule* module) {
  SIRConstant* zero = module->AddOrGetImmediate(0);
  if (expr->IsLeaf()) {
    if (expr->ValueEqual(nPEReg) ||(expr->ConstantEqual(numPE))) {
      expr->SetValue(zero);
    }
  } else {
    SIROpcode_t opc = expr->GetOpcode();
    SIRBinExprNode* origExpr = SIRBinExprNode::CreateBinExprNode(expr);
    switch (opc) {
    case SIROpcode::MUL:
      if (expr->GetRHS()->ValueEqual(nPEReg)
          || expr->GetRHS()->ConstantEqual(numPE)
          || expr->GetLHS()->ValueEqual(nPEReg)
          || expr->GetLHS()->ConstantEqual(numPE)) { expr->SetValue(zero); }
      break;
    case SIROpcode::ADD: case SIROpcode::SUB: {
      CalculateModNumPE(expr->GetLHS(), numPE, nPEReg, peIDReg, module);
      CalculateModNumPE(expr->GetRHS(), numPE, nPEReg, peIDReg, module);
      expr->Simplify();
      if (!(*expr == *origExpr)) {
        CalculateModNumPE(expr, numPE, nPEReg, peIDReg, module);
      }
      break;
    }
    default: ES_NOTIMPLEMENTED("Cannot handle expression: "<< *expr);
    }
  }
  return expr;
}// CalculateModeNumPE

/// Calculate column offset: (offset % NUMPE) - PEID
static SIRBinExprNode*
CalculateColumnOffset(SIRBinExprNode* expr, SIRKernel* kernel,
                      const BaselineBasicInfo& target) {
  if (!expr) { return NULL; }
  // cout <<"col expr: "<< *expr << endl;
  ES_ASSERT(kernel->GetLaunchParams().Valid());
  SIRFunction* func = kernel->GetParent();
  SIRModule* module = func->GetParent();
  int numPE = target.GetNumPE();
  SIRRegister* nPEReg  = func->GetNumPERegister();
  SIRRegister* peIDReg = func->GetPEIDRegister();
  SIRConstant* zero = module->AddOrGetImmediate(0);
  if (expr->IsLeaf()) {
    if (expr->ValueEqual(peIDReg)) { expr->SetValue(zero); }
    else {
      expr = SIRBinExprNode::CreateBinExprNode(
        module, SIROpcode::SUB, expr,
        SIRBinExprNode::CreateBinExprNode(func->GetPEIDRegister()));
    }// if expr->GetValue()->ValueEqual(func->GetPEIDRegister())
  } else {// if (expr->IsLeaf())
    expr = CalculateModNumPE(expr, numPE, nPEReg, peIDReg,module);
    if (expr->ValueEqual(peIDReg)) { expr->SetValue(zero); }
    else {
      expr = SIRBinExprNode::CreateBinExprNode(
        module, SIROpcode::SUB, expr,
        SIRBinExprNode::CreateBinExprNode(func->GetPEIDRegister()));
    }// if expr->GetValue()->ValueEqual(func->GetPEIDRegister())
  }// if (expr->IsLeaf()) else
  expr->Simplify();
  // cout <<" * ret "<< *expr << " [orig: "<< *origExpr <<"]"<<endl;
  return expr;
}// CalculateColumnOffset()

void BaselineKernelBuilder::
LowerStandardKernelAddress(SIRMemLocation* mloc) {
  ES_ASSERT_MSG(mloc->IsStandardKernelForm(),
                "Cannot lower address not in standard form");
  SIRBinExprNode* addr = mloc->GetExpr();
  SIRRegister* baseReg=static_cast<SIRRegister*>(addr->GetLHS()->GetValue());
  SIRBinExprNode* offset = addr->GetRHS()->GetLHS();
  ES_LOG_P(logLv_, log_, ">>-->> In standard kernel form: base = "
           << *baseReg <<", offset = "<< *offset <<"\n");
  /// Transform offset expression
  /// Calculate row address: offset / NUMPE
  SIRBinExprNode* rowAddr = SIRBinExprNode::CreateBinExprNode(offset);
  rowAddr = CalculateRowAddress(rowAddr, kernel_, target_);
  /// Calculate column offset: (offset % NUMPE) - PEID
  SIRBinExprNode* colOffset = SIRBinExprNode::CreateBinExprNode(offset);
  colOffset = CalculateColumnOffset(offset, kernel_, target_);
  ES_LOG_P(logLv_, log_, "-->>-- rowAddr = "<< *rowAddr
           <<", colOffset = "<<*colOffset <<'\n');
  // if (!colOffset->IsConstant()) {
  //   ES_NOTIMPLEMENTED("Non-constant communication: offset="<< *offset
  //                     <<", rowAddr="<<*rowAddr <<", colOffset="<<*colOffset);
  // }
  mloc->SetKernelAddress(rowAddr, colOffset);
}// LowerStandardKernelAddress()

void BaselineKernelBuilder::
LowerShiftedStandardKernelAddress(SIRMemLocation* mloc) {
  ES_ASSERT_MSG(mloc->IsShiftedStandardKernelForm(),
                "Cannot lower address not in standard form");
  SIRBinExprNode* addr = mloc->GetExpr();
  SIRRegister* baseReg=static_cast<SIRRegister*>(addr->GetLHS()->GetValue());
  SIRBinExprNode* offset = addr->GetRHS()->GetLHS()->GetLHS();
  SIRBinExprNode* sh_offset   = addr->GetRHS()->GetRHS();
  if (!sh_offset->IsConstant()) {
    ES_NOTIMPLEMENTED("Non-constant shifted offset");
  }
  int so = static_cast<SIRConstant*>(sh_offset->GetValue())->GetImmediate();
  int alignment = mloc->GetShiftAmount() * 2;
  ES_LOG_P(logLv_, log_, ">>-->> In shifted standard kernel form: base = "
           << *baseReg <<", offset = "<< *offset <<", sh_offset="
           << *sh_offset <<" ("<< (so/alignment) <<")\n");
  /// Transform offset expression
  /// Calculate row address: offset / NUMPE
  SIRBinExprNode* rowAddr = SIRBinExprNode::CreateBinExprNode(offset);
  rowAddr = CalculateRowAddress(rowAddr, kernel_, target_);
  /// Calculate column offset: (offset % NUMPE) - PEID
  SIRBinExprNode* colNsOffset = SIRBinExprNode::CreateBinExprNode(offset);
  SIRBinExprNode* colShOffset = SIRBinExprNode::CreateBinExprNode(
    module_->AddOrGetImmediate(so/alignment));
  SIRBinExprNode* colOffset = SIRBinExprNode::CreateBinExprNode(
    module_, SIROpcode::ADD, colNsOffset, colShOffset);
  colOffset = CalculateColumnOffset(colOffset, kernel_, target_);
  colOffset->Simplify();
  ES_LOG_P(logLv_, log_, ">>-->>-- Adjust offset = "<< *colOffset <<"\n");
  if (!colOffset->IsLeaf() || !SIRConstant::classof(colOffset->GetValue())) {
    ES_NOTIMPLEMENTED("Non-constant communication offset");
  }
  mloc->SetKernelAddress(rowAddr, colOffset);
}// LowerShiftedStandardKernelAddress()

static void
NormalizeSingleGroupSRegs(SIRFunction* func, int numPE) {
  SIRKernel* kernel = func->GetSolverKernel();
  const SIRKernelLaunch& kl = kernel->GetLaunchParams();
  SIRConstant* one  = func->GetParent()->AddOrGetImmediate(1);
  vector<SIRConstant*> glbSize(3, NULL);
  vector<SIRValue*>    glbID(3, NULL);
  for (int i=0; i < 3; ++i) {
    int gsz = kl.numGroups_[i]*kl.groupSize_[i];
    glbSize[i] = func->GetParent()->AddOrGetImmediate(gsz);
    if (gsz > 1) { glbID[i] = kernel->GetGlobalID(i); }
    else         { glbID[i] = one; }
  }
  bool subIDX =  (kl.numGroups_[0]*kl.groupSize_[0] == numPE);
  SIRRegister* peIDReg = func->GetPEIDRegister();
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      for (int i=0, e=instr->operand_size(); i < e; ++i) {
        for (int j = 0; j < 3; ++j) {
          if (subIDX && (j == 0)) {
            instr->ReplaceOperand(kernel->GetLocalID(j), peIDReg);
          } else {
            instr->ReplaceOperand(kernel->GetLocalID(j), glbID[j]);
          }
          instr->ReplaceOperand(kernel->GetGroupSize(j),
                                kernel->GetGlobalSize(j));
          instr->ReplaceOperand(kernel->GetGroupID(j),    one);
          instr->ReplaceOperand(kernel->GetNumGroup(j),   one);
          instr->ReplaceOperand(kernel->GetGlobalSize(j), glbSize[j]);
          if (kernel->GetGlobalID(j) != glbID[j]) {
            instr->ReplaceOperand(kernel->GetGlobalID(j), glbID[j]);
          }
        }
      }
    }// for bb iterator iIt
  }// for func iterator bIt
}// NormalizeSingleGroupSRegs()

void BaselineKernelBuilder::
MapSingleGroupKernel() {
  const SIRKernelLaunch& kl = kernel_->GetLaunchParams();
  int x_sz = kl.GetGroupSize(0), y_sz = kl.GetGroupSize(1),
    z_sz = kl.GetGroupSize(2), numPE = target_.GetNumPE();
  ES_LOG_P(logLv_, log_, ">> Mapping single-group kernel ("<< x_sz <<", "
           << y_sz <<", "<< z_sz <<") on "<< numPE <<" PEs\n");
  func_->front()->SetName("$"+func_->GetName() + ".kernel");
  ES_LOG_P(logLv_, log_, "-->> Normalizing special registers\n");
  NormalizeSingleGroupSRegs(func_, numPE);
  // Get the row address and column offset of each memory address
  for (SIRFunction::iterator bIt = func_->begin(); bIt != func_->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (!instr->IsVectorInstr()) { continue; }
      if (!IsSIRMemoryOp(instr->GetSIROpcode())) { continue; }
      unsigned base = IsSIRLoad(instr->GetSIROpcode()) ? 0 : 1;
      SIRMemLocation* mloc = AnalyzeSingleGroupAddress(
        instr->GetOperand(base), instr->GetOperand(base+1),
        instr->GetSIROpcode());
      instr->SetMemLocationInfo(mloc);
    }// for bb iterator iIt
  }// for func iterator bIt
  InsertSingleGroupLoops();
  KernelAddressCodeGen();
  /// Insert initialization and update of the counters for each dimension
  if (kernel_->GetGlobalDimCounter(0)->use_size() > 0) {
    SIRInstruction* xCnt = &kernel_->GetLocalPreHeader()->BuildSIRInstr(
      kernel_->GetLocalPreHeader()->end(), false, SIROpcode::MOV,
      kernel_->GetGlobalDimCounter(0)->GetValueID())
      .AddOperand(module_->AddOrGetImmediate(0));
    SIRBasicBlock::iterator eIt = kernel_->GetLocalExit()->end();
    kernel_->GetLocalExit()->BuildSIRInstr(
      --eIt, false, SIROpcode::ADD, xCnt->GetValueID())
      .AddOperand(kernel_->GetGlobalDimCounter(0))
      .AddOperand(module_->AddOrGetImmediate(1));
  }// if (kernel_->GetGlobalDimCounter(0)->use_size() > 0) {
  int yCntVal = -1;
  if (kernel_->GetGlobalDimCounter(1)->use_size() > 0) {
    SIRInstruction* yCnt = &kernel_->GetGlobalPreHeader()->BuildSIRInstr(
      kernel_->GetGlobalPreHeader()->begin(), false, SIROpcode::MOV,
      kernel_->GetGlobalDimCounter(1)->GetValueID())
      .AddOperand(module_->AddOrGetImmediate(0));
    yCntVal = yCnt->GetValueID();
    SIRBasicBlock::iterator eIt = kernel_->GetGlobalExit()->end();
    kernel_->GetGlobalExit()->BuildSIRInstr(
      --eIt, false, SIROpcode::ADD, yCnt->GetValueID())
      .AddOperand(kernel_->GetGlobalDimCounter(1))
      .AddOperand(module_->AddOrGetImmediate(1));
    for (SIRBasicBlock::iterator iIt = kernel_->GetGlobalPreHeader()->begin();
         iIt != kernel_->GetGlobalPreHeader()->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (instr == yCnt) { continue; }
      for (unsigned i = 0; i < instr->operand_size(); ++i) {
        if (instr->GetOperand(i)->GetValueID() == yCnt->GetValueID()) {
          instr->ChangeOperand(i, yCnt);
        }
      }
      if (instr->GetValueID() == yCnt->GetValueID()) { break; }
    }// for kernel_->GetGlobalPreHeader() iterator iIt
  }// if (kernel_->GetGlobalDimCounter(1)->use_size() > 0)
  if (kernel_->GetGlobalDimCounter(2)->use_size() > 0) {
    ES_NOTIMPLEMENTED("3-diminsional group");
  }// if (kernel_->GetGlobalDimCounter(2)->use_size() > 0)
}// BaselineMapSingleGroupKernel()

SIRMemLocation* BaselineKernelBuilder::
AnalyzeSingleGroupAddress(SIRValue* base, SIRValue* offset, SIROpcode_t opc) {
  SIRMemLocation* memLoc = new SIRMemLocation(base, offset, opc, func_);
  ES_LOG_P(logLv_, log_, ">>-- Addr = "<< *(memLoc->GetExpr())
           <<" in address space "<< memLoc->GetAddressSpace() <<"\n");
  LowerSingleGroupKernelSRegs sRegLowering(func_,target_,logLv_,log_);
  if (memLoc->TransformToStandardForm()) {
    memLoc->GetExpr()->GetRHS()->GetLHS()->VisitNodesPreOrder(sRegLowering);
    LowerStandardKernelAddress(memLoc);
  } else if (memLoc->IsShiftedStandardKernelForm()) {
    memLoc->GetExpr()->GetRHS()->GetLHS()->GetLHS()
      ->VisitNodesPreOrder(sRegLowering);
    LowerShiftedStandardKernelAddress(memLoc);
  } else {// if (memLoc->IsStandardKernelForm())
    ES_NOTIMPLEMENTED("Kernel address in non-standard form: "<< *memLoc);
  }// if (memLoc->IsStandardKernelForm())
  return memLoc;
}// AnalyzeKernelAddress()

void BaselineKernelBuilder::
InsertSingleGroupLoops() {
  // For now, the whole workgroup is flatten in one loop.
  const SIRKernelLaunch& kl = kernel_->GetLaunchParams();
  unsigned totGroupSize = kl.GetTotalGroupSize();
  if (totGroupSize <= 1) { return; }
  int glbSize[3];
  int numPE = target_.GetNumPE();
  for (int i = 0; i < 3; ++i) { glbSize[i] = kl.groupSize_[i]; }
  std::list<SIRBasicBlock*> localBlocks;
  for (SIRFunction::iterator it = func_->begin(); it != func_->end(); ++it) {
    localBlocks.push_back(*it);
  }
  SIRFunction::iterator entIter = func_->begin(), extIter = func_->end();
  unsigned nExt = 0;
  for (SIRFunction::iterator bIt = func_->begin(); bIt != func_->end(); ++bIt) {
    if ((*bIt)->IsExitBlock()) { ++nExt; extIter = bIt; }
  }// for func iterator bit
  if (nExt != 1) { ES_NOTIMPLEMENTED("Kernel with #ExitBlock != 1"); }

  int lBoundVal = -1;
  SIRBasicBlock *localPH=NULL, *localHdr=*entIter, *localExt=*extIter;
  if (glbSize[0] > numPE) {
    ES_LOG_P(logLv_, log_, ">>-- Building X-Loop (Bound="<< glbSize[0] <<")\n");
    BuildLoopWithPreHeader(localPH, localHdr, localExt,
                           module_->AddOrGetImmediate(glbSize[0]),
                           func_->GetNumPERegister(), SIROpcode::SUB,
                           localBlocks, *entIter, *extIter, func_);
    kernel_->SetLocalPreHeader(localPH);
    kernel_->SetLocalHeader(localHdr);
    kernel_->SetLocalExit(localExt);
    for (SIRBasicBlock::iterator it=localPH->begin(); it != localPH->end(); ++it) {
      if (((*it)->GetSIROpcode() == SIROpcode::MOV)
          && (*it)->GetOperand(0) == module_->AddOrGetImmediate(glbSize[0])) {
        lBoundVal = (*it)->GetValueID();
        break;
      }
    }
    ES_ASSERT(func_->IsValidValueID(lBoundVal));
  } else {// if (glbSize[0] > numPE)
    kernel_->SetLocalPreHeader(localHdr);
    kernel_->SetLocalHeader(localHdr);
    kernel_->SetLocalExit(localExt);
  }// if (glbSize[0] > numPE)
  if (glbSize[0] % numPE) {
    // Calculate kernel predicate
    SIRInstruction& lPred = localHdr->BuildSIRInstr(
      localHdr->begin(), true, SIROpcode::SFGTS,
      kernel_->GetLocalPredicate()->GetValueID())
      .AddOperand(localHdr->AddOrGetBlockRegister(lBoundVal, false))
      .AddOperand(func_->GetPEIDRegister());
    for (std::list<SIRBasicBlock*>::iterator bIt = localBlocks.begin();
         bIt != localBlocks.end(); ++bIt) { (*bIt)->AddBlockPredicate(&lPred); }
  }// if (glbSize[0] % numPE)

  int glbCount = glbSize[1] * glbSize[2];
  if (glbCount > 1) {
    std::list<SIRBasicBlock*> glbBlocks;
    for (SIRFunction::iterator it = func_->begin(); it != func_->end(); ++it) {
      glbBlocks.push_back(*it);
    }
    SIRBasicBlock *globalPH=NULL, *globalHdr=NULL, *globalExt=NULL;
    SIRFunction::iterator entIter = func_->begin(), extIter = func_->end();
    if (kernel_->GetLocalPreHeader()) {
      entIter = find(func_->begin(), func_->end(), kernel_->GetLocalPreHeader());
      globalHdr=kernel_->GetLocalPreHeader();
    }// if (kernel_->GetLocalPreHeader())
    if (kernel_->GetLocalExit()) {
      extIter = find(func_->begin(), func_->end(), kernel_->GetLocalExit());
    } else {
      unsigned nExt = 0;
      for (SIRFunction::iterator bIt = func_->begin(); bIt != func_->end(); ++bIt) {
        if ((*bIt)->IsExitBlock()) { ++nExt; extIter = bIt; }
      }// for func iterator bit
      if (nExt != 1) { ES_NOTIMPLEMENTED("Kernel with #ExitBlock != 1"); }
    }// if (kernel_->GetLocalExit()) else
    BuildLoopWithPreHeader(
      globalPH, globalHdr, globalExt, module_->AddOrGetImmediate(glbCount),
      module_->AddOrGetImmediate(-1), SIROpcode::ADD, glbBlocks,
      *entIter, *extIter, func_);
    kernel_->SetGlobalPreHeader(globalPH);
    kernel_->SetGlobalHeader(globalHdr);
    kernel_->SetGlobalExit(globalExt);
  } else {// if (glbCount > 1)
    kernel_->SetGlobalPreHeader(kernel_->GetLocalPreHeader());
    kernel_->SetGlobalHeader   (kernel_->GetLocalHeader());
    kernel_->SetGlobalExit     (kernel_->GetLocalExit());
  }// if (glbCount > 1)
}// InsertSingleGroupLoops()
