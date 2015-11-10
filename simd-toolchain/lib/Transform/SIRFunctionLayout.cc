#include "Transform/SIRFunctionLayout.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Utils/LogUtils.hh"

using namespace std;
using namespace ES_SIMD;

SIRFunctionLayoutPass::~SIRFunctionLayoutPass() {}

bool SIRFunctionLayoutPass::
RunOnSIRModule(SIRModule* m) {
  bool changed = false;
  SIRModule::iterator entry = m->end();
  for (SIRModule::iterator fIt = m->begin(); fIt != m->end(); ++fIt) {
    if ((*fIt)->GetName() == "__start") {
      entry = fIt;
      break;
    } else if ((entry == m->end()) && ((*fIt)->GetName() == "main")) {
      entry = fIt;
    }
  }// for m iterator fIt
  if (entry == m->end()) { return changed; }
  ES_LOG_P(logLv_, log_,">>--Found entry point "<< (*entry)->GetName()<<"\n");
  m->SetEntryFunction(entry);
  return changed;
}// RunOnSIRModule()
