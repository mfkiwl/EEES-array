#include "Transform/SplitSIRCallBlock.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

SplitSIRCallBlock::~SplitSIRCallBlock() {}

bool SplitSIRCallBlock::
RunOnSIRFunction(SIRFunction* func) {
  bool change = false;
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end();) {
    SIRBasicBlock* bb = *bIt;
    SIRBasicBlock::iterator sp = bb->end();
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      if ((*iIt)->GetSIROpcode() == SIROpcode::CALL) { sp = iIt; break; }
    }// for bb iterator iIt
    if ((sp != bb->end()) && ((++sp != bb->end()) || bb->IsExitBlock()) ) {
      change = true;
      ES_LOG_P(logLv_, log_, "Splitting BB_"<< bb->GetBasicBlockID() <<"...\n");
      SIRBasicBlock *nxtBlk = bb->SplitBlock(sp);
      ++bIt;
      bIt = func->insert(bIt, nxtBlk);
    } else { ++bIt; }// if (sp != bb->end())
  }// for func bIt
  if (change) {
    if (logLv_) { func->ValuePrint(log_); }
    ES_LOG_P(logLv_, log_, "Update liveness of "<< func->GetName() <<"...\n");
    func->UpdateControlFlowInfo();
    func->UpdateLiveness();
    if (logLv_) { func->ValuePrint(log_); }
  }
  return change;
}// RunOnSIRFunction()

