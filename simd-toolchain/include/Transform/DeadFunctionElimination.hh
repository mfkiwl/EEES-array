#ifndef ES_SIMD_DEADFUNCTIONELIMINATION_HH
#define ES_SIMD_DEADFUNCTIONELIMINATION_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class DeadFunctionElimination : public SIRModulePass {
  public:
    DeadFunctionElimination(unsigned logLv,std::ostream& log,std::ostream& err)
      : SIRModulePass("DeadFuncElim", "Dead function elimination pass",
                      logLv, log, err) {}
    virtual ~DeadFunctionElimination();
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class DeadFunctionElimination
}// namespace ES_SIMD

#endif//ES_SIMD_DEADFUNCTIONELIMINATION_HH
