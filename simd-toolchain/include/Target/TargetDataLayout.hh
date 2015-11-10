#ifndef ES_SIMD_TARGETDATALAYOUT_HH
#define ES_SIMD_TARGETDATALAYOUT_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class TargetDataLayoutPass : public SIRModulePass {
  public:
    TargetDataLayoutPass(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRModulePass("GenericDataLayout", "Generic data layout pass",
                      logLv, log, err) {}
    virtual ~TargetDataLayoutPass();
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class TargetDataLayoutPass
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETDATALAYOUT_HH
