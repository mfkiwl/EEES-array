#ifndef ES_SIMD_SIRFUNCTIONLAYOUT_HH
#define ES_SIMD_SIRFUNCTIONLAYOUT_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class SIRFunctionLayoutPass : public SIRModulePass {
  public:
    SIRFunctionLayoutPass(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRModulePass("SIRFuncLayout", "SIR function layout pass",
                      logLv, log, err) {}
    virtual ~SIRFunctionLayoutPass();
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class SIRFunctionLayoutPass
}// namespace ES_SIMD

#endif//ES_SIMD_SIRFUNCTIONLAYOUT_HH
