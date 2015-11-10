#ifndef ES_SIMD_SIMPROCESSOR_HH
#define ES_SIMD_SIMPROCESSOR_HH

#include "Simulation/SimObjectBase.hh"
#include <memory>

namespace ES_SIMD {
  class TargetBasicInfo;
  class SimProcessorBase : public SimObjectBase {
  public:
    virtual ~SimProcessorBase();
    virtual void CycleAction() = 0;
    virtual void InitProcessor() = 0;
    virtual bool AddInstructionInit(const std::string& cmd) = 0;
    virtual bool AddDataInit(const std::string& cmd) = 0;
    virtual bool AddDataBinary(const std::string& cmd) = 0;
    virtual void Reset();

    void SetMaxSimulationCycle(uint64_t mc) { maxCycle_ = mc; }

    bool IsTerminated() const { return terminated_; }
    uint64_t GetSimulationCycle() const { return simCycle_; }
    uint64_t GetMaxSimulationCycle() const { return maxCycle_; }
    virtual void SetBranchTrace(bool t);
    virtual uint32_t GetProgramCounter() const = 0;
    virtual uint32_t GetScalarContextValue(unsigned addr) const = 0;
    virtual void     GetVectorContextValue(unsigned addr, uint32_t* val) const = 0;
    virtual uint32_t GetScalarMemoryValue(unsigned addr) const = 0;
    virtual void     GetVectorMemoryValue(unsigned addr, uint32_t* val) const = 0;
    virtual size_t GetScalarContextSize() const = 0;
    virtual size_t GetVectorContextSize() const = 0;
    virtual size_t GetScalarMemorySize() const = 0;
    virtual size_t GetVectorMemorySize() const = 0;
    virtual unsigned GetVectorLength() const = 0;
    virtual void PrintScalarOperation(unsigned addr, std::ostream& o) const = 0;
    virtual void PrintVectorOperation(unsigned addr, std::ostream& o) const = 0;
    virtual void DumpScalarDataMemory(std::ostream& o) const = 0;
    virtual void DumpVectorDataMemory(std::ostream& o) const = 0;
    virtual void PrintSimStatistics(std::ostream& o) const = 0;
  protected:
    SimProcessorBase(const std::string& name, unsigned logLv, std::ostream& log,
                     unsigned traceLv, std::ostream& trace, std::ostream& err)
      : SimObjectBase(name, logLv, log, traceLv, trace, err),
        terminated_(true), simCycle_(0), maxCycle_(0xFFFFFFFFFFFFFFFFLL) {}
    void IncSimCycle() { ++simCycle_; }
    void Terminate()   { terminated_ = true; }
    const uint64_t& GetSimCycleRef() const { return simCycle_; }
  private:
    bool terminated_;
    uint64_t simCycle_;
    uint64_t maxCycle_;
  };// class SimProcessorBase

  template <typename T>
  SimProcessorBase* CreateSimProcessor(
    const TargetBasicInfo* tgt, int logLv,std::ostream& log,
    int traceLv, std::ostream& trace, std::ostream& err) {
    return new T(tgt, logLv, log, traceLv, trace, err);
  }

  /// @brief Factory class for SimProcessor
  class SimProcessorFactory {
  public:
    typedef SimProcessorBase*(*SimProcessorCreator)(
      const TargetBasicInfo* tgt, int logLv, std::ostream& log,
      int traceLv,std::ostream& trace, std::ostream& err);
    typedef std::map<std::string, SimProcessorCreator> TargetSimCreatorMap;
    /// @brief Create a target assembly parser based on a TargetBasicInfo.
    /// @param arch    The name of the target architecture.
    /// @param tgt     The target.
    /// @param logLv   Verbose level.
    /// @param log     The log output stream.
    /// @param traceLv Simulation trace level.
    /// @param trace   The trace output stream.
    /// @param err     The error output stream.
    /// @return        a pointer to the generated SimProcessor for the target.
    ///                NULL if there is any error
    static SimProcessorBase* GetSimProcessor(
      const std::string& arch, const TargetBasicInfo* tgt, int logLv,
      std::ostream& log, unsigned traceLv, std::ostream& trace, std::ostream& err) {
      TargetSimCreatorMap* m = GetMap();
      TargetSimCreatorMap::iterator it = m->find(arch);
      return (it == m->end()) ? NULL
        : it->second(tgt, logLv, log, traceLv, trace, err);
    }
    static TargetSimCreatorMap* GetMap() {
      if (!map_.get()) { map_.reset(new TargetSimCreatorMap()); }
      return map_.get();
    }
  private:
    static std::auto_ptr<TargetSimCreatorMap> map_;
  };// class SimProcessorFactory

  template <typename T>
  class RegisterSimProcessor : public SimProcessorFactory {
  public:
    RegisterSimProcessor(const std::string name) {
      (*GetMap())[name] = CreateSimProcessor<T>;
    }
  };
}// namespace ES_SIMD

#endif//ES_SIMD_SIMPROCESSOR_HH


