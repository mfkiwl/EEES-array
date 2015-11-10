#ifndef  ES_SIMD_SIRLOCALOPT_HH
#define  ES_SIMD_SIRLOCALOPT_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class SIRFunction;

  class SIRLocalOpt : public SIRFunctionPass {
  public:
    SIRLocalOpt(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRFunctionPass("SIRLocalOpt", "SIR function local optimization pass",
                        logLv, log, err) {}
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class SIRLocalOpt
}// namespace ES_SIMD

#endif// ES_SIMD_SIRLOCALOPT_HH
