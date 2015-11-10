#ifndef ES_SIMD_BASELINEREGALLOC_HH
#define ES_SIMD_BASELINEREGALLOC_HH

#include "BaselineBlockData.hh"
#include "Target/TargetLiveInterval.hh"
#include "SIR/SIRBasicBlock.hh"
#include "DataTypes/SIROpcode.hh"
#include "DataTypes/ContainerTypes.hh"


namespace ES_SIMD {
  class SIRBasicBlock;
  class SIRFunction;
  class BaselineBasicInfo;
  class TargetModuleData;

  class BaselineFuncRegAllocPass : public SIRModulePass {
    const BaselineBasicInfo& target_;
    TargetModuleData* mData_;
    bool RunOnSIRFunction(SIRFunction* func);
  public:
    BaselineFuncRegAllocPass(
      const BaselineBasicInfo& target, unsigned logLv,
      std::ostream& log, std::ostream& err)
      : SIRModulePass("BaselineFuncRegAlloc",
                      "Baseline function register allocator pass",
                      logLv, log, err),
        target_(target) {}
    virtual ~BaselineFuncRegAllocPass();
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class BaselineFuncRegAllocPass()

  void CalculateLiveIntervals(SIRFunction* func, bool dbg, std::ostream& dbgs);
  bool BaselineEarlyLiveIntervalSpill (
    SIRFunction* func, const BaselineBasicInfo& target,
    bool dbg, std::ostream& dbgs);
  void SpillValue(SIRFunction* func, int val, bool vector,
                  bool dbg, std::ostream& dbgs);
  void FunctionRegAlloc(SIRFunction* func, const BaselineBasicInfo& target,
                        bool dbg, std::ostream& dbgs);
  void AssignPhyRegisters(SIRFunction* func, bool dbg, std::ostream& dbgs);
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEREGALLOC_HH
