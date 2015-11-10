#ifndef ES_SIMD_TARGETCODEGENENGINE_HH
#define ES_SIMD_TARGETCODEGENENGINE_HH

#include "DataTypes/Error.hh"
#include "DataTypes/Object.hh"
#include <iostream>
#include <vector>
#include <map>
#include <memory>

namespace ES_SIMD {
  class TargetBasicInfo;
  class SIRModule;
  class SIRFunction;
  class SIRBasicBlock;
  class Pass;
  class TargetModuleData;

  class TargetCodeGenEngine : NonCopyable {
  public:
    enum ScheduleMode {
      DefaultSched = 0, IROrder,
    };
  protected:
    SIRModule* module_; ///< The module to be processed
    TargetModuleData* moduleData_;
    ScheduleMode schedMode_;
  public:
    virtual ~TargetCodeGenEngine();

    void Initialize(SIRModule* module);
    void EmitTargetModule(std::ostream& out);
    void SetScheduleMode(ScheduleMode m) { schedMode_ = m; }

    virtual TargetModuleData* GetModuleData() = 0;
    virtual void AddTargetTranslatePasses(
      std::vector<Pass*>& passes, unsigned logLv,
      std::ostream& log, std::ostream& err);
    virtual void AddTargetSchedPasses(
      std::vector<Pass*>& passes, unsigned logLv,
      std::ostream& log, std::ostream& err);
    virtual void AddTargetRAPasses(
      std::vector<Pass*>& passes, unsigned logLv,
      std::ostream& log, std::ostream& err);
    virtual void AddTargetPostRAPasses(
      std::vector<Pass*>& passes, unsigned logLv,
      std::ostream& log, std::ostream& err);
  protected:
    TargetCodeGenEngine();

    /// Processing hooks for specific targets
    virtual void EmitTargetFunction(SIRFunction* func, std::ostream& out);
    virtual Pass* GetDataLayoutPass(
      unsigned logLv, std::ostream& log, std::ostream& err) const;
    void ResolveKernelLaunchParams(SIRFunction* func);
  };// class TargetCodeGenEngine

  template <typename T>
  TargetCodeGenEngine* CreateTargetCodeGenEngine(const TargetBasicInfo* tgt) {
    return new T(tgt);
  }

  /// \brief Factory class for TargetCodeGenEngine
  class TargetCodeGenEngineFactory {
  public:
    typedef TargetCodeGenEngine*(*TargetCGCreator)(const TargetBasicInfo* tgt);
    typedef std::map<std::string, TargetCGCreator> TargetCGCreatorMap;
    /// \brief Create a target code generator based on a TargetBasicInfo.
    /// \param tgt   The target.
    /// \return a pointer to the generated TargetCodeGenEngine for the target.
    ///         NULL if there is any error
    static TargetCodeGenEngine* GetTargetCodeGenEngine(
      const TargetBasicInfo* tgt);
    static TargetCGCreatorMap* GetMap() {
      if (!map_.get()) { map_.reset(new TargetCGCreatorMap()); }
      return map_.get();
    }
  protected:
    static std::auto_ptr<TargetCGCreatorMap> map_;
  };// class TargetCodeGenEngineFactory

  template <typename T>
  class RegisterTargetCodeGenEngine : public TargetCodeGenEngineFactory {
  public:
    RegisterTargetCodeGenEngine(const std::string name) {
      (*GetMap())[name] = CreateTargetCodeGenEngine<T>;
    }
  };

  class TargetCodeGenDataInit : public SIRModulePass {
  public:
    TargetCodeGenDataInit(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRModulePass("TargetCodeGenDataInit", "CodeGen info init pass",
                      logLv, log, err) {}
    virtual ~TargetCodeGenDataInit() {}
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class TargetCodeGenDataInit

  class TargetTimingVerifier : public SIRModulePass {
  public:
    TargetTimingVerifier(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRModulePass("TargetTimingVerifier", "Timing verification pass",
                      logLv, log, err) {}
    virtual ~TargetTimingVerifier() {}
    virtual bool RunOnSIRModule(SIRModule* m);
  };// class TargetTimingVerifier
}// ES_SIMD

#endif//ES_SIMD_TARGETCODEGENENGINE_HH
