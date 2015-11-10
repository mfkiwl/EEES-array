#ifndef ES_SIMD_PROMOTELONGIMM_HH
#define ES_SIMD_PROMOTELONGIMM_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class TargetBasicInfo;
  /// \brief Promote long immediate values to memory location if the cost
  ///        of encoding them is too high.
  class PromoteLongImmPass : public SIRFunctionPass {
    const TargetBasicInfo& target_;
    SIRModule* module_;
    bool SetTargetImmediates(SIRFunction* func);
  public:
    PromoteLongImmPass(const TargetBasicInfo& t, unsigned logLv,
                       std::ostream& log, std::ostream& err)
      : SIRFunctionPass(
        "PromoteLongImm", "Target long immediate promotion pass",
        logLv, log, err), target_(t) {}
    virtual void ModuleInit(SIRModule* m);
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class PromoteLongImmPass
}//namespace ES_SIMD

#endif//ES_SIMD_PROMOTELONGIMM_HH
