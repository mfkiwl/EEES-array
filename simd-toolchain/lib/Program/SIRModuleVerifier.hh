#ifndef SIRMODULEVERIFIER_HH
#define SIRMODULEVERIFIER_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  /// \brief Check whether a module is ready for code generation.
  class SIRModuleVerifier : public SIRModulePass {
  public:
    SIRModuleVerifier(unsigned logLv,std::ostream& log,std::ostream& err)
      : SIRModulePass("SIRModuleVerifier", "SIR module verifier",
                      logLv, log, err) {}
    virtual ~SIRModuleVerifier();
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class SIRModuleVerifier
}// namespace ES_SIMD

#endif//SIRMODULEVERIFIER_HH
