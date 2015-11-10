#ifndef ES_SIMD_BASELINEDATALAYOUT_HH
#define ES_SIMD_BASELINEDATALAYOUT_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;

  class BaselineDataLayoutPass : public SIRModulePass {
    const BaselineBasicInfo& target_;
  public:
    BaselineDataLayoutPass(const BaselineBasicInfo& target, unsigned logLv,
                           std::ostream& log, std::ostream& err)
      : SIRModulePass("BaselineDataLayout",
                      "Baseline data layout pass", logLv, log, err),
        target_(target) {}
    virtual ~BaselineDataLayoutPass();
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class BaselineDataLayoutPass
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEDATALAYOUT_HH
