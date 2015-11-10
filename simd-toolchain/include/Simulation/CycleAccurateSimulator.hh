#ifndef ES_SIMD_CYCLEACCURATESIMULATOR_HH
#define ES_SIMD_CYCLEACCURATESIMULATOR_HH

#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"
#include "Utils/Timer.hh"
#include "Simulation/SimObjectBase.hh"
#include <sstream>

namespace ES_SIMD {
  class SimProcessorBase;

  /// \brief Base class for cycle accurate simulator
  class CycleAccurateSimulator : NonCopyable {
  public:
    CycleAccurateSimulator(const std::string& name, unsigned logLv,
                           std::ostream& log, unsigned traceLv,
                           std::ostream& err);
    ~CycleAccurateSimulator();
    const std::string& GetName() const { return name_; }
    /// \brief Initialize the simulator.
    /// \param mc The maximum number of cycles.
    void InitializeSimulator(uint64_t mc);
    /// \brief Set the maximum number of cycles.
    /// \param mc The maximum number of cycles.
    void SetMaxCycle(uint64_t mc) { maxCycle_ = mc; }
    uint64_t GetMaxCycle() { return maxCycle_; }
    /// \brief Reset the simulator.
    ///
    /// All processors are reset, but memory content remains unchanged.
    void Reset();
    /// \brief Run the simulator.
    ///
    /// The simulator runs until maximum cycle is reached or all processors
    /// have terminated.
    void Run();
    /// \brief Run the simulator for c cycles.
    ///
    /// The simulator runs for c cycles. If all processors have terminated
    /// before the given number of cycles, the simulator also stops.
    /// \param c The number of cycles to run.
    void Run(uint64_t c);
    /// \brief Run the simulator for c cycles.
    ///
    /// The simulator stops if any of the following happens:
    /// - The simulator has runs for c cycles
    /// - All processors have terminated.
    /// - Any of the processor trys to fetch a trapped PC address.
    /// \param c The number of cycles to run.
    void RunPCTrap(uint64_t c);
    /// \brief Add a processor to the simulator
    void AddSimProcessor(SimProcessorBase* p);
    void ReleaseResources();
    void PrintSimulationInfo(std::ostream& out);
    void PrintSimulationStat(std::ostream& out);
    void PrintSimulationErrors(std::ostream& out) {
      SimObjectBase::PrintErrors(out);
    }

    /// \brief Add a program counter trap for a processor.
    ///
    /// The PC trap only affect the simulation when simulation is run
    /// with RunPCTrap().
    /// \param proc Processor ID.
    /// \param trap The PC value to trap.
    void AddPCTrap(unsigned proc, uint32_t trap) {
      if (proc < processors_.size()) { traps_[proc].insert(trap); }
    }
    /// \brief Remove a program counter trap for a processor.
    ///
    /// The PC trap only affect the simulation when simulation is run
    /// with RunPCTrap().
    /// \param proc Processor ID.
    /// \param trap The PC trap value to remove.
    void RemovePCTrap(unsigned proc, uint32_t trap) {
      if (proc < processors_.size()) { traps_[proc].erase(trap); }
    }
    /// \brief Clear all program counter traps for a processor.
    ///
    /// The PC trap only affect the simulation when simulation is run
    /// with RunPCTrap().
    /// \param proc Processor ID.
    void ClearPCTrap(unsigned proc) {
      if (proc < processors_.size()) { traps_[proc].clear(); }
    }
    bool AddInstructionInit(const std::string& cmd);
    bool AddDataInit(const std::string& cmd);
    bool AddDataBinary(const std::string& cmd);

    /// \brief Get the number of simulated cycles.
    uint64_t GetSimulationCycle() const { return simCycle_; }
    /// \brief Check if the simulation is finished.
    ///
    /// Simulation is considered finised if all processors have finished
    /// (usually caused by a self branch), or maximum cycles is reached.
    bool SimulationFinished() { return simFinished_; }
    void   error_clear() { SimObjectBase::error_clear(); }
    bool   error_empty() const{ return SimObjectBase::error_empty(); }
    size_t error_size()  const{ return SimObjectBase::error_size();  }
    void PrintErrors(std::ostream& o) const  { SimObjectBase::PrintErrors(o); }
    void DumpDataMemory(const std::string& prefix);
    uint32_t GetProgramCounter(unsigned proc) const;

    size_t GetScalarContextSize(unsigned proc) const ;
    size_t GetVectorContextSize(unsigned proc) const ;
    size_t GetScalarMemorySize(unsigned proc) const ;
    size_t GetVectorMemorySize(unsigned proc) const ;
    uint32_t GetScalarContextValue(unsigned proc, unsigned addr) const ;
    void     GetVectorContextValue(unsigned proc, unsigned addr,
                                   uint32_t* val) const;
    uint32_t GetScalarMemoryValue(unsigned proc, unsigned addr) const;
    void     GetVectorMemoryValue(unsigned proc, unsigned addr,
                                  uint32_t* val) const;
    void PrintScalarOperation(unsigned proc,unsigned adr,std::ostream& o) const;
    void PrintVectorOperation(unsigned proc,unsigned adr,std::ostream& o) const;
    unsigned GetVectorLength(unsigned proc) const;

    void SetLogLevel(unsigned l);
    void SetTraceLevel(unsigned l);
    void SetBranchTrace(bool t);

    std::stringstream& GetTraceStream() const { return traceSS_; }
    /// \brief Get the size of the current simulation trace in bytes.
    size_t GetTraceSize() const;
    /// \brief Read the simulation trace and clear the buffer.
    size_t ReadOutTrace(char *buff, size_t buff_size) const;
  protected:
    std::string name_;
    uint64_t maxCycle_;
    unsigned logLevel_;
    unsigned traceLevel_;
    std::ostream& log_;
    std::ostream& err_;
    mutable std::stringstream traceSS_;
    Timer simTimer_;

    // Simulation variables
    uint64_t simCycle_;
    unsigned terminated_;
    bool     simFinished_;

    // Processors to simulate
    std::vector<SimProcessorBase*> processors_;
    /// PC traps
    std::vector<std::set<uint32_t> > traps_;
  };// class CycleAccurateSimulator
}// namespace ES_SIMD

#endif//ES_SIMD_CYCLEACCURATESIMULATOR_HH
