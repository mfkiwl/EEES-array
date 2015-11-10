#ifndef ES_SIMD_SIRSIMPLFYBRANCH_HH
#define ES_SIMD_SIRSIMPLFYBRANCH_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class SIRSimplfyBranch : public SIRFunctionPass {
  public:
    SIRSimplfyBranch(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRFunctionPass("SIRBranchSimplify",
                        "SIR branch simplification pass", logLv, log, err) {}
    virtual ~SIRSimplfyBranch();
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class SIRSimplfyBranch
}// namespace ES_SIMD

#endif//ES_SIMD_SIRSIMPLFYBRANCH_HH
