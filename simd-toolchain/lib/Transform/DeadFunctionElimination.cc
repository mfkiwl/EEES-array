#include "Transform/DeadFunctionElimination.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Utils/LogUtils.hh"

using namespace std;
using namespace ES_SIMD;

static void
AddCallTree(SIRFunction* f, std::set<SIRFunction*>& callTree,
            const std::set<SIRFunction*>* exclude) {
  if (exclude && IsElementOf(f, *exclude)) { return; }
  callTree.insert(f);
  for (SIRFunction::callee_iterator cIt = f->callee_begin();
         cIt != f->callee_end(); ++cIt) {
    if (SIRFunction::classof(*cIt)){
      AddCallTree(static_cast<SIRFunction*>(*cIt), callTree, exclude);
    }
  }
}// DelCallTree()

DeadFunctionElimination::~DeadFunctionElimination() {}

bool DeadFunctionElimination::
RunOnSIRModule(SIRModule* m) {
  bool changed = false;
  std::set<SIRFunction*> delFuncs;
  std::set<SIRFunction*> calledFuncs;
  if (m->IsBareModule()) { return changed; }
  if (!m->GetEntryFunction()) {
    errors_.push_back(Error(ErrorCode::IRUndefinedSymbol, "No entry function"));
    return changed;
  }
  AddCallTree(m->GetEntryFunction(), calledFuncs, NULL);
  bool use_heap = false;
  for (SIRModule::iterator fIt = m->begin(); fIt != m->end(); ++fIt) {
    SIRFunction* func = *fIt;
    if (!func->caller_empty() || (m->GetEntryFunction() == func)) {
      if ((func->GetName() == "malloc")||(func->GetName() == "free")) {
        use_heap = true;
      }
      continue;
    }
    /// Not only the dead function itself should be deleted, the whole call tree
    /// of it should be removed from the module
    ES_LOG_P(logLv_, log_, ">> Adding call tree of "<< func->GetName() <<'\n');
    AddCallTree(func, delFuncs, &calledFuncs);
  }// for m iterator fIt
  //for (unsigned i = 0; i < delFuncs.size(); ++i) {
  for (set<SIRFunction*>::iterator it = delFuncs.begin();
       it != delFuncs.end(); ++it) {
    SIRFunction* df = *it;//delFuncs[i];
    if (use_heap && (df->GetName() == "init_malloc")) { continue; }
    ES_LOG_P(logLv_, log_, ">> Removing "<< df->GetName() <<'\n');
    m->remove(df);
  }
  return changed;
}// RunOnSIRModule()
