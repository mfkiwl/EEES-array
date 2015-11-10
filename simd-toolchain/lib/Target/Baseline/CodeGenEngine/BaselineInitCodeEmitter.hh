#ifndef ES_SIMD_BASELINEINITCODEEMITTER_HH
#define ES_SIMD_BASELINEINITCODEEMITTER_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;

  class BaselineInitCodeEmitter : public SIRModulePass {
    const BaselineBasicInfo& target_;
  public:
    BaselineInitCodeEmitter(const BaselineBasicInfo& target,
      unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRModulePass("BaselineInitCode",
                      "Baseline initialization code emission pass",
                      logLv, log, err), target_(target) {}
    virtual ~BaselineInitCodeEmitter();
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class BaselineInitCodeEmitter
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEINITCODEEMITTER_HH
