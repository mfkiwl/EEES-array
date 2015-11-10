#ifndef ES_SIMD_BASELINEKERNELBUILDER_HH
#define ES_SIMD_BASELINEKERNELBUILDER_HH

#include "SIR/Pass.hh"
#include "DataTypes/SIROpcode.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;
  class SIRValue;
  class SIRKernel;
  class SIRMemLocation;
  class SIRBinExprNode;

  class BaselineKernelBuilder : public SIRFunctionPass {
    SIRModule* module_;
    SIRFunction* func_;
    SIRKernel* kernel_;
    const BaselineBasicInfo& target_;
  public:
    BaselineKernelBuilder(unsigned logLv, std::ostream& log, std::ostream& err,
                          const BaselineBasicInfo& target)
      : SIRFunctionPass("BaselineKernelBuilder",
                        "Baseline Kernel Builder", logLv, log, err),
        module_(NULL), func_(NULL), kernel_(NULL), target_(target) {}
    virtual ~BaselineKernelBuilder();
    virtual void ModuleInit(SIRModule* m);
    virtual bool RunOnSIRFunction(SIRFunction* func);
  private:
    /// Helpers
    void TransformIndex();
    void KernelAddressCodeGen();
    void EliminateRedudantAccess();
    void InsertLocalLoop();
    void InsertGlobalLoop();
    SIRMemLocation* AnalyzeKernelAddress(
      SIRValue* base, SIRValue* offset, SIROpcode_t opc);
    void LowerStandardKernelAddress(SIRMemLocation* mloc);
    void LowerShiftedStandardKernelAddress(SIRMemLocation* mloc);

    /// Functions for single-group kernels
    void MapSingleGroupKernel();
    SIRMemLocation* AnalyzeSingleGroupAddress(
      SIRValue* base, SIRValue* offset, SIROpcode_t opc);
    void InsertSingleGroupLoops();
  };// class BaselineKernelBuilder

  struct LowerKernelSpecialRegs {
    SIRFunction* func_;
    SIRKernel*   kernel_;
    const BaselineBasicInfo& target_;
    unsigned numPE_;
    int logLv_;
    std::ostream& log_;
    LowerKernelSpecialRegs(SIRFunction* func, const BaselineBasicInfo& target,
                           int logLv, std::ostream& log);
    void operator()(SIRBinExprNode* n);
  };// struct LowerKernelSpecialRegs

  struct LowerSingleGroupKernelSRegs {
    SIRFunction* func_;
    SIRKernel*   kernel_;
    const BaselineBasicInfo& target_;
    int numPE_;
    int glbSize_[3];
    int logLv_;
    std::ostream& log_;
    LowerSingleGroupKernelSRegs(
      SIRFunction* func, const BaselineBasicInfo& target,
      int logLv, std::ostream& log);
    void operator()(SIRBinExprNode* n);
  };// struct LowerSingleGroupKernelSRegs

  struct ExprInvariantChecker {
    SIRFunction* func_;
    SIRKernel*   kernel_;
    bool localInvariant_;
    bool globalInvariant_;
    int logLv_;
    std::ostream& log_;
    void Reset() { localInvariant_ = globalInvariant_ = true; }
    ExprInvariantChecker(SIRFunction* func, int logLv, std::ostream& log);
    void operator()(SIRBinExprNode* n);
  };// struct ExprInvariantChecker()

  int CalculateMaxCommDist(SIRBinExprNode* offset, int nPE, SIRKernel* kernel,
                           SIRFunction* func);
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEKERNELBUILDER_HH
