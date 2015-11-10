#ifndef ES_SIMD_SIRFINALIZE_HH
#define ES_SIMD_SIRFINALIZE_HH

#include <SIR/Pass.hh>

namespace ES_SIMD {

  class SIRGlobalSymbolPass : public SIRModulePass {
  public:
    SIRGlobalSymbolPass(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRModulePass("SIRGlobalSymbol", "SIR global symbol pass",
                          logLv, log, err) {}
    virtual bool RunOnSIRModule(SIRModule* m);
  private:
    bool RunOnSIRBasicBlock(SIRBasicBlock* bb);
  };// class SIRGlobalSymoblPass

  class SIRCFGPass : public SIRFunctionPass {
  public:
    SIRCFGPass(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRFunctionPass("SIRCFG", "SIR CFG construction pass",
                        logLv, log, err) {}
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class SIRCFGPass

  class SIRKernelParamPass : public SIRFunctionPass {
  public:
    SIRKernelParamPass(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRFunctionPass("SIRKernelParamInit",
                        "SIR kernel parameter initializationpass",
                        logLv, log, err) {}
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class SIRCFGPass

  class SIRInitValueInfoPass : public SIRFunctionPass {
  public:
    SIRInitValueInfoPass(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRFunctionPass("SIRValueInit","SIR value initialization pass",
                        logLv, log, err) {}
    virtual bool RunOnSIRFunction(SIRFunction* func);
  private:
    void InitStackInfo(SIRFunction* func);
    void InitCallSite(SIRFunction* func);
    void InitValueID(SIRFunction* func);
    void InitLiveness(
      SIRFunction* func , std::tr1::unordered_map<std::string, int>& valTab,
      std::tr1::unordered_map<int, std::string>& valNameTab);
    void UpdateValueID(
      SIRFunction* func, std::tr1::unordered_map<std::string, int>& valTab,
      std::tr1::unordered_map<int, std::string>& valNameTab);
    void UpdateValueType(SIRFunction* func);
  };// class SIRInitValueInfoPass
}// namespace ES_SIMD

#endif//ES_SIMD_SIRFINALIZE_HH
