#ifndef ES_SIMD_BASELINEPOSTRATRANSFORM_HH
#define ES_SIMD_BASELINEPOSTRATRANSFORM_HH

#include "SIR/Pass.hh"
#include "DataTypes/ContainerTypes.hh"

namespace ES_SIMD {
  class SIRFunction;
  class SIRRegister;
  class SIRInstruction;
  class SIRCallSite;
  class BaselineBasicInfo;
  class BaselineBlockData;
  class BaselineFuncData;
  class TargetModuleData;
  class TargetFuncRegAllocInfo;

  class LowerMOV : public SIRBasicBlockPass {
  public:
    LowerMOV(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRBasicBlockPass("BaselineLowerMOV", "Baseline MOV lowering pass",
                          logLv, log, err) {}
    virtual bool RunOnSIRBasicBlock(SIRBasicBlock* bb);
  };// class LowerMOV

  class LowerRSUB : public SIRBasicBlockPass {
  public:
    LowerRSUB(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRBasicBlockPass("BaselineLowerRSUB", "Baseline RSUB lowering pass",
                          logLv, log, err) {}
    virtual bool RunOnSIRBasicBlock(SIRBasicBlock* bb);
  };// class LowerRSUB

  class BaselineCallerSavedRegPass : public SIRFunctionPass {
    const BaselineBasicInfo& target_;
    SIRModule*              module_;
    TargetModuleData*       mData_;
    SIRFunction*            func_;
    BaselineFuncData*       fData_;
    TargetFuncRegAllocInfo* raInfo_;
    std::tr1::unordered_map<int, SIRInstruction*> defInstrs_;
    void SavePhyRegs(const std::vector<SIRRegister*>& savedRegs,
                     const SIRCallSite* cs);
    void RestorePhyRegs(const std::vector<SIRRegister*>& savedRegs,
                        const SIRCallSite* cs);
  public:
    BaselineCallerSavedRegPass(const BaselineBasicInfo& t, unsigned logLv,
                       std::ostream& log, std::ostream& err)
      : SIRFunctionPass(
        "BaselineCallerSaved", "Baseline caller saved register pass",
        logLv, log, err), target_(t), mData_(NULL), func_(NULL), fData_(NULL),
        raInfo_(NULL) {}
    virtual void ModuleInit(SIRModule* m);
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class BaselineCallerSavedRegPass

  class EmitFuncProEpilogue : public SIRFunctionPass {
    const BaselineBasicInfo& target_;
  public:
    EmitFuncProEpilogue(const BaselineBasicInfo& target,
                        unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRFunctionPass("BaselineFuncProEpilogue",
                        "Baseline function prologue/epilogue emission pass",
                        logLv, log, err), target_(target) {}
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class EmitFuncPrologueEpilogue

  class CrossFuncBypassCheck : public SIRFunctionPass {
    const BaselineBasicInfo& target_;
  public:
    CrossFuncBypassCheck(const BaselineBasicInfo& t, unsigned logLv,
                         std::ostream& log, std::ostream& err)
      : SIRFunctionPass("BaselineCrossFuncBypassCheck",
                        "Baseline cross-function bypassing state checking pass",
                        logLv, log, err), target_(t) {}
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class CrossFuncBypassCheck

  class CrossBlockTimingCheck : public SIRFunctionPass {
    const BaselineBasicInfo& target_;
  public:
    CrossBlockTimingCheck(const BaselineBasicInfo& t, unsigned logLv,
                          std::ostream& log, std::ostream& err)
      : SIRFunctionPass("BaselineCrossBlockTimingCheck",
                        "Baseline cross-block timing checking pass",
                        logLv, log, err), target_(t) {}
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class CrossBlockTimingCheck

  class TargetAddressPass : public SIRModulePass {
  public:
    TargetAddressPass(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRModulePass("BaselineTargetAddress",
                      "Baseline target address pass",
                      logLv, log, err) {}
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class TargetAddressPass

}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEPOSTRATRANSFORM_HH

