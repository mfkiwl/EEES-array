#ifndef ES_SIMD_BASELINECODEGENENGINE_HH
#define ES_SIMD_BASELINECODEGENENGINE_HH

#include "SIR/SIRBasicBlock.hh"
#include "SIR/Pass.hh"
#include "Target/TargetCodeGenEngine.hh"
#include "Target/TargetLiveInterval.hh"
#include "DataTypes/SIROpcode.hh"
#include "DataTypes/TargetOpcode.hh"
#include "DataTypes/ContainerTypes.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;
  class InterferenceGraph;
  class DataDependencyGraph;
  class BUSelector;
  class SIRModule;

  class BaselineCodeGenEngine : public TargetCodeGenEngine {
  public:
    typedef std::tr1::unordered_map<SIROpcode_t,
                                    TargetOpcode_t> OpTranslationTab;
  private:
    const BaselineBasicInfo& target_;
  public:
    BaselineCodeGenEngine(const TargetBasicInfo* t);
    virtual ~BaselineCodeGenEngine();

    const BaselineBasicInfo& GetTarget() const { return target_; }

    virtual TargetModuleData* GetModuleData();
    virtual void AddTargetTranslatePasses(
      std::vector<Pass*>& passes, unsigned logLv,
      std::ostream& log, std::ostream& err);
    virtual void AddTargetSchedPasses(
      std::vector<Pass*>& passes, unsigned logLv,
      std::ostream& log, std::ostream& err);
    void AddTargetRAPasses(
      std::vector<Pass*>& passes, unsigned logLv,
      std::ostream& log, std::ostream& err);
    virtual void AddTargetPostRAPasses(
      std::vector<Pass*>& passes, unsigned logLv,
      std::ostream& log, std::ostream& err);
  protected:
    virtual Pass* GetDataLayoutPass(
      unsigned logLv, std::ostream& log, std::ostream& err) const;
  private:
    static RegisterTargetCodeGenEngine<BaselineCodeGenEngine> reg_;
  };// class BaselineCodeGenEngine

  class BaselineBlockSchedulingPass : public SIRFunctionPass {
    const BaselineBasicInfo& target_;
    TargetCodeGenEngine::ScheduleMode schedMode_;
    TargetModuleData* mData_;
    void ScheduleBaselineBasicBlock(
      SIRBasicBlock* bb, DataDependencyGraph& ddg, BUSelector& selector);
  public:
    virtual void ModuleInit(SIRModule* m);
    BaselineBlockSchedulingPass(
      const BaselineBasicInfo& target, TargetCodeGenEngine::ScheduleMode mode,
      unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRFunctionPass("BaselineBBSched",
                        "Baseline block scheduling pass", logLv, log, err),
        target_(target), schedMode_(mode), mData_(NULL) {}
    virtual ~BaselineBlockSchedulingPass();
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class BaselineBlockSchedulingPass()

  class BaselineBlockTranslationPass : public SIRBasicBlockPass {
    const BaselineBasicInfo& target_;
    TargetModuleData* mData_;
  public:
    BaselineBlockTranslationPass(
      const BaselineBasicInfo& target, unsigned logLv,
      std::ostream& log, std::ostream& err)
      : SIRBasicBlockPass("BaselineTranslation",
                          "Baseline SIR translation pass", logLv, log, err),
        target_(target), mData_(NULL) {}
    virtual ~BaselineBlockTranslationPass();
    virtual void ModuleInit(SIRModule* m);
    virtual void FunctionInit(SIRFunction* func);
    virtual bool RunOnSIRBasicBlock(SIRBasicBlock* bb);
  };// class BaselineBlockTranslationPass

  class BaselineLowerCommunication : public SIRBasicBlockPass {
    const BaselineBasicInfo& target_;
    TargetModuleData* mData_;
    SIRBasicBlock::iterator LowerInterPEComm(SIRBasicBlock::iterator it);
    SIRBasicBlock::iterator LowerShiftToPE(SIRBasicBlock::iterator it);
    SIRBasicBlock::iterator LowerPECPComm(SIRBasicBlock::iterator it);
  public:
    BaselineLowerCommunication(
      const BaselineBasicInfo& target, unsigned logLv,
      std::ostream& log, std::ostream& err)
      : SIRBasicBlockPass("BaselineLowerCommunication",
                          "Baseline communication lowering pass", logLv, log, err),
        target_(target), mData_(NULL) {}
    virtual ~BaselineLowerCommunication();
    virtual void ModuleInit(SIRModule* m);
    virtual void FunctionInit(SIRFunction* func);
    virtual bool RunOnSIRBasicBlock(SIRBasicBlock* bb);
  };// class BaselineLowerCommunication

  void ScheduleBaselineBasicBlock(
    SIRBasicBlock* bb, DataDependencyGraph& ddg,
    BUSelector& selector, const BaselineBasicInfo& target,
    std::vector<Error>& error, bool dbg, std::ostream& dbgs);
  void SetBaselineBlockBypass(
    SIRBasicBlock* bb, const BaselineBasicInfo& target,
    bool dbg, std::ostream& dbgs);

  void BaselineAnalyzeJointPoint(
    SIRFunction* func, std::tr1::unordered_map<int, IntSet>& defJPs,
    std::tr1::unordered_map<int, IntSet>& useJPs,
    std::tr1::unordered_map<int, DataDependencyGraph*>& blockDDGs,
    const BaselineBasicInfo& tgt, bool dbg, std::ostream& dbgs);
  void BaselineFixJointPoints(
    SIRFunction* func,const BaselineBasicInfo& tgt,bool dbg,std::ostream& dbgs);
  void InsertBefore(SIRBasicBlock::iterator it, SIRInstruction* instr);
  void UpdateBaselineFuncBypass(
    SIRFunction* func, const BaselineBasicInfo& target,
    bool dbg, std::ostream& dbgs);
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINECODEGENENGINE_HH
