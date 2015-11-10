#include "SIR/SIRFunction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRRegister.hh"
#include "Transform/SIRCallSiteProcessing.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

bool SIRCallSiteProcessing::
RunOnSIRFunction(SIRFunction* func) {
  bool change = false;
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
        change = true;
        if (cs->arg_size() < callee->arg_size()) {
          cs->arg_resize(callee->arg_size());
        }
        ES_LOG_P(logLv_, log_, ">>-- "<< callee->GetName()<<" requires "
                 << callee->arg_size() <<"("<< callee->GetNumFormalArguments()
                 <<") arguments\n");
        SIRBasicBlock::iterator aIt = iIt;
        // Find arguments defined in call block
        if (aIt != bb->begin()) {
          do {
            --aIt;
            SIRInstruction* aInstr = *aIt;
            if ((aInstr->GetValueID() > 0) && aInstr->HasName()
                && (aInstr->GetName()[0] == 'a')) {
              unsigned aid = immRd.GetIntImmediate(aInstr->GetName().substr(1));
              if ((aid < cs->arg_size()) && !cs->GetArgument(aid)) {
                ES_LOG_P(logLv_, log_,">>-- Def arg_"<< aid <<": "<< *aInstr<<"\n");
                cs->SetArgument(aid, aInstr);
              }// if ((aid < cs->arg_size()) && !cs->GetArgument(aid))
            }
          } while (aIt != bb->begin());
        }// if (aIt != bb->begin())
        for (int i = 0, e=cs->arg_size(); i < e; ++i ){
          if (cs->GetArgument(i)) { continue; }
          const string& aName = "a" + Int2DecString(i);
          for (SIRBasicBlock::li_iterator lIt = bb->li_begin();
               lIt != bb->li_end(); ++lIt) {
            if ((*lIt)->GetName() == aName) { cs->SetArgument(i, *lIt); break; }
          }
          ES_ASSERT_MSG (func->GetNumFormalArguments() > i,
                    "Callsite argument not propoerly handled");
          if (!cs->GetArgument(i)) { cs->SetArgument(i, func->GetArgument(i)); }
        }
      }// if (callee->arg_size() > 0)
    }// for bb iterator iIt
  }// for func iterator bIt
  if (change) { func->UpdateLiveness(); }
  return change;
}// RunOnSIRFunction()
