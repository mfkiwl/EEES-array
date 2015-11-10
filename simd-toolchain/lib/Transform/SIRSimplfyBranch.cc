#include "Transform/SIRSimplfyBranch.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/LogUtils.hh"

using namespace std;
using namespace ES_SIMD;

SIRSimplfyBranch::~SIRSimplfyBranch() {}

bool SIRSimplfyBranch::
RunOnSIRFunction(SIRFunction* func) {
  bool changed = false;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end();) {
    SIRBasicBlock* bb = *bIt;
    // Check how many branches are there
    SIRBasicBlock::iterator lIt = bb->end(), slIt = bb->end();
    SIRInstruction* lastBr = NULL, * secLastBr = NULL;
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      if (IsSIRBranch(instr->GetSIROpcode())) {
        ES_ASSERT_MSG(!lastBr||!secLastBr, "More than 2 branches in a block");
        if (!secLastBr) { slIt = iIt; secLastBr = instr; }
        else { lIt = iIt; lastBr = instr; }
      }
    }
    if (!lastBr || !secLastBr ) { ++bIt; continue; }
    changed = true;
    // If second last branch is unconditional, just remove the last branch
    if (IsSIRUnCondBranch(secLastBr->GetSIROpcode())) {
      ES_LOG_P(logLv_>1, log_, ">>-->> Last branch is redudant\n");
      bb->erase(lIt); ++bIt; continue;
    }
    ES_ASSERT_MSG(IsSIRUnCondBranch(lastBr->GetSIROpcode())
                  && IsSIRCondBranch(secLastBr->GetSIROpcode()),
                  "Block ends with two branches should be CondBr+UnCondBr");
    ES_LOG_P(logLv_>1, log_, ">>-- BB"<< bb->GetBasicBlockID() <<" in "<< func->GetName()
             <<" has two branches\n");
    SIRFunction::iterator fIt = bIt; ++fIt;
    SIRBasicBlock* ftBlk =  (fIt == func->end()) ? NULL : *fIt;
    SIRBasicBlock* lastTgtBlk
      = dynamic_cast<SIRBasicBlock*>(lastBr->GetBranchTarget());
    if (ftBlk && lastTgtBlk && (ftBlk == lastTgtBlk)) {
      ES_LOG_P(logLv_>1, log_, ">>-->> Last branch is redudant\n");
      bb->erase(lIt); ++bIt; continue;
    }
    SIRBasicBlock* nxtBlk = bb->SplitBlock(lIt);
    ++bIt; bIt = func->insert(bIt, nxtBlk);
  }// for func iterator bIt
  if (changed) {
    ES_LOG_P(logLv_, log_, "Update liveness of "<< func->GetName() <<"...\n");
    func->UpdateControlFlowInfo();
    func->UpdateLiveness();
  }
  return changed;
}// RunOnSIRFunction()
