#ifndef ES_SIMD_SIRCALLSITEPROCESSING_HH
#define ES_SIMD_SIRCALLSITEPROCESSING_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class SIRFunction;

  class SIRCallSiteProcessing : public SIRFunctionPass {
  public:
    SIRCallSiteProcessing(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRFunctionPass("SIRCallSiteProc", "SIR call site processing pass",
                        logLv, log, err) {}
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };
}// namespace ES_SIMD

#endif//ES_SIMD_SIRCALLSITEPROCESSING_HH
