#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "SIR/Pass.hh"
#include "Utils/LogUtils.hh"
#include "llvm/Support/Casting.h"

using namespace std;
using namespace ES_SIMD;

Pass::~Pass() {}
void Pass::ModuleInit (SIRModule* m) {}
void Pass::ModuleFinal(SIRModule* m) {}

bool Pass::
RunOnModule(SIRModule* m) {
  bool ch = false;
  ModuleInit(m);
  switch (getKind()) {
  default: break;
  case PK_SIRModulePass: {
    SIRModulePass* mp = static_cast<SIRModulePass*>(this);
    ch = mp->RunOnSIRModule(m);
    break;
  }
  case PK_SIRFunctionPass: {
    SIRFunctionPass* fp = static_cast<SIRFunctionPass*>(this);
    for (SIRModule::iterator fIt = m->begin(); fIt != m->end(); ++fIt) {
      ch |= fp->RunOnSIRFunction(*fIt);
    }
    break;
  }
  case PK_SIRBasicBlockPass: {
    SIRBasicBlockPass* bp = static_cast<SIRBasicBlockPass*>(this);
    for (SIRModule::iterator fIt = m->begin(); fIt != m->end(); ++fIt) {
      bp->FunctionInit(*fIt);
      for (SIRFunction::iterator bIt = (*fIt)->begin();
           bIt != (*fIt)->end(); ++bIt) {
        ch |= bp->RunOnSIRBasicBlock(*bIt);
      }
      bp->FunctionFinal(*fIt);
    }
    break;
  }
  }// switch (getKind())
  ModuleFinal(m);
  return ch;
}// RunOnModule()

SIRModulePass::~SIRModulePass() {}

SIRFunctionPass::~SIRFunctionPass() {}

SIRBasicBlockPass::~SIRBasicBlockPass() {}
void SIRBasicBlockPass::FunctionInit (SIRFunction* func) {}
void SIRBasicBlockPass::FunctionFinal(SIRFunction* func) {}
