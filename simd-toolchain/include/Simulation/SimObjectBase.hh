#ifndef ES_SIMD_SIMOBJECTBASE_HH
#define ES_SIMD_SIMOBJECTBASE_HH

#include <string>
#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"
#include "Simulation/SimDefs.hh"

namespace ES_SIMD {
  class SimObjectBase : NonCopyable {
  public:
    virtual ~SimObjectBase();
    unsigned GetID() const { return id_; }
    const std::string& GetName() const { return name_; }
    virtual void Reset() = 0;
    void Error(uint64_t t, SimErrorCode_t c, const std::string& m) const;
    void SetTraceLevel(unsigned l) {
      traceLevel_ = l;
      for (std::tr1::unordered_set<SimObjectBase*>::iterator it
             = subObjects_.begin(); it != subObjects_.end(); ++it) {
        (*it)->SetTraceLevel(l);
      }
    }
    void SetLogLevel(unsigned l)   {
      logLevel_ = l;
      for (std::tr1::unordered_set<SimObjectBase*>::iterator it
             = subObjects_.begin(); it != subObjects_.end(); ++it) {
        (*it)->SetLogLevel(l);
      }
    }

    static bool   error_empty() { return SimErrors.empty(); }
    static size_t error_size()  { return SimErrors.size();  }
    static void   error_clear() { SimErrors.clear(); }
    static std::ostream& PrintErrors(std::ostream& o);
  protected:
    SimObjectBase(const std::string& name, unsigned logLv, std::ostream& log,
                  unsigned traceLv, std::ostream& trace,
                  std::ostream& err);
    static unsigned SimObjectCounter;
    static std::vector<SimulationError> SimErrors;       ///< Global error list
    static bool Initialize();
    static bool Initialized;
    unsigned logLevel_;
    std::ostream& log_;
    unsigned traceLevel_;
    std::ostream& trace_;
    std::ostream& err_;
    std::tr1::unordered_set<SimObjectBase*> subObjects_;
  private:
    unsigned id_;
    std::string name_;
  };// class SimObjectBase
}// namespace ES_SIMD

#endif//ES_SIMD_SIMOBJECTBASE_HH
