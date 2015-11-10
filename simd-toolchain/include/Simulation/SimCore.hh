#ifndef ES_SIMD_SIMCORE_HH
#define ES_SIMD_SIMCORE_HH

#include "Simulation/SimObjectBase.hh"
#include "Simulation/SimPipelineStage.hh"

#define COMMBOUNDARYMODE_ENUM(DEF, DEFV)  \
  DEFV(Zero,   0)                         \
  DEFV(Scalar, 1)                         \
  DEFV(Wrap,   2)                         \
  DEFV(Self,   3)

namespace ES_SIMD {
  DECLARE_ENUM(CommBoundaryMode, COMMBOUNDARYMODE_ENUM)

  class  SimOperation;
  struct SimCoreStatictics {
    unsigned cycles_;
    unsigned issued_;
    unsigned stall_;
    unsigned nops_;
    unsigned immInstr_;
    unsigned branches_;
    unsigned takenBranches_;
    unsigned dmemWrite_;
    unsigned dmemRead_;
    unsigned intRegWrite_;
    unsigned intRegRead_;
    unsigned bypass_;
    unsigned comm_;
    unsigned aluOp_;
    unsigned mulOp_;
    unsigned memOp_;
    void Reset() {
      cycles_ = issued_ = stall_ = nops_ = immInstr_ = branches_
        = takenBranches_ = dmemWrite_ = dmemRead_ = intRegWrite_
        = intRegRead_ = bypass_ = comm_ = aluOp_ = mulOp_ = memOp_ = 0;
    }
  };// SimCoreStatictics ()

  class SimScalarMMapObject : public SimObjectBase {
  public:
    virtual uint32_t Read(unsigned  addr)  const = 0;
    virtual void     Write(uint32_t dat, unsigned addr) = 0;
  protected:
    SimScalarMMapObject(
      const std::string& name, unsigned logLv, std::ostream& log,
      unsigned traceLv, std::ostream& trace, std::ostream& err)
      : SimObjectBase(name, logLv, log, traceLv, trace, err) {}
  };// class SimScalarMMapObject

  /// \brief a generic core simulation model.
  ///
  /// In general, a core has four logical stages: fetch, decode, execute and
  /// commit. They are basically the same as the stages in classical processor
  /// pipeline:
  /// - Fetch: fetch instruction from instruction memory
  /// - Decode: decode the instruction, calculate next instruction address, and
  ///           dispatch operations (operands and control signals)
  /// - Execute: perform the actual operation (EX and MEM in 5-stage RISC)
  /// - Commit: write the operation results to context storage (WB in RISC)
  /// Each stage may have sub-stages.
  class SimCoreBase : public SimObjectBase {
    /// Core parameters
    unsigned dataWidth_;      ///< Width of datapath
    unsigned intRFSize_;      ///< Size of integer RF
    unsigned intContextSize_; ///< Size of integer context (RF + bypass)
    UIntVector2D exeFUContextMap_;
    bool explicitBypass_;
    unsigned commitPipeReg_;
    unsigned memStage_;

    /// Context
    const uint64_t& refTimer_;
    unsigned programCounter_;///< Instruction address for fetch stage
    unsigned nextPC_;        ///< Next instruction address
    bool terminated_;        ///< Whether current simulation has been finished
  protected:
    mutable SimCoreStatictics coreStat_;

    SimPipelineStage fetchStage_;
    SimPipelineStage decodeStage_;
    SimPipelineStage executeStage_;
    SimPipelineStage commitStage_;

    uint32_t mmapObjMask_;
    std::tr1::unordered_map<unsigned, SimScalarMMapObject*> mmapObjects_;
  public:
    virtual void Reset();
    virtual void SetBranchTrace(bool t) {}

    void AddMMapScalarObject(unsigned addr, SimScalarMMapObject* obj) {
      mmapObjects_[addr] = obj;
      subObjects_.insert(obj);
    }
    void CycleAction();
    unsigned GetPC() const { return programCounter_; }
    bool IsTerminated() const { return terminated_; }
    unsigned GetDataWidth() const { return dataWidth_; }

    void SetMemMapObjectMask(uint32_t m) { mmapObjMask_ = m; }
    void SetFetchLatency (unsigned l)  { fetchStage_.SetSubStages(l);   }
    void SetDecodeLatency (unsigned l) { decodeStage_.SetSubStages(l);  }
    void SetExeMaxStages(unsigned l)   { executeStage_.SetSubStages(l); }
    void SetCommitLatency (unsigned l) { commitStage_.SetSubStages(l);  }
    void SetIntRFSize(unsigned s)      { intRFSize_ = s;      }
    void SetIntContextSize(unsigned s) { intContextSize_ = s; }
    void SetNumberOfFU(unsigned n)     { exeFUContextMap_.resize(n); }
    void SetFUOutQueueContextMap(unsigned f, const UIntVector& q) {
      exeFUContextMap_[f] = q;
    }
    void SetMemoryStage(unsigned s) { memStage_ = s; }
    void SetExplicitBypass(bool eb)   { explicitBypass_ = eb; }
    void SetCommitPipeReg(unsigned r) { commitPipeReg_ = r; }

    unsigned GetExeMaxStages() const {return executeStage_.GetNumOfSubStages();}
    unsigned GetFetchLatency() const {return fetchStage_.GetNumOfSubStages();}
    unsigned GetDecodeLatency()const {return decodeStage_.GetNumOfSubStages();}
    unsigned GetCommitLatency()const {return commitStage_.GetNumOfSubStages();}

    bool     IsExplicitBypass()  const { return explicitBypass_; }
    unsigned GetNumOfFU()        const { return exeFUContextMap_.size(); }
    unsigned GetIntRFSize()      const { return intRFSize_;      }
    unsigned GetIntContextSize() const { return intContextSize_; }
    unsigned GetProgramCounter() const { return programCounter_; }
    void FillInstrBuffer(const SimOperation* op) {
      fetchStage_.IssueOperation(op);
    }
    bool FetchWaiting() const {
      return !fetchStage_.Filled() && fetchStage_.Ready();
    }

    virtual void InitializeCore() = 0;
    virtual std::ostream& PrintSimStatistics(std::ostream& o) const = 0;

    // Simulation methods
    virtual void Fetch()   = 0;
    /// @brief in simulation, the jobs of decode stage include: resloving branches,
    ///        handling interlocks, dispatching operands.
    virtual void Decode()  = 0;
    virtual void Execute() = 0;
    virtual void Commit()  = 0;
    virtual void CycleInit();
    virtual void CycleFinal();
    /// @brief Inter-core communication interface. Default implementation
    ///        generates an error.
    /// @param dir direction
    /// @param id  ID of the request. Usually the context ID.
    /// @return the requested value
    virtual uint32_t Communicate(unsigned dir, unsigned id) const;
    /// @brief Inter-core communication interface.
    ///        Default implementation generates an error.
    /// @return the requested value
    virtual uint32_t SyncCommunicate(unsigned dir) const;
    virtual void Synchronize();
  protected:
    SimCoreBase(const std::string& name, const uint64_t& refTimer,
                unsigned dataWidth, unsigned logLv, std::ostream& log,
                unsigned traceLv, std::ostream& trace, std::ostream& err)
      : SimObjectBase(name,logLv,log,traceLv,trace,err), dataWidth_(dataWidth),
        explicitBypass_(false), commitPipeReg_(0), memStage_(0),
        refTimer_(refTimer), programCounter_(0), nextPC_(0), terminated_(true),
        mmapObjMask_(0xFFFF0000) {
      fetchStage_.ConnectStage(NULL, &decodeStage_);
      decodeStage_.ConnectStage(&fetchStage_, &executeStage_);
      executeStage_.ConnectStage(&decodeStage_, &commitStage_);
      commitStage_.ConnectStage(&executeStage_, NULL);
    }
    virtual ~SimCoreBase();

    void UpdateProgramCounter() { programCounter_ = nextPC_; }
    void SetNextPC(unsigned npc) { nextPC_ = npc; }
    unsigned GetNextPC() const { return nextPC_; }
    void Terminate() { terminated_ = true; }

    uint64_t GetRefTime() const { return refTimer_; };
    unsigned GetFUStageContextID(unsigned fu, unsigned stage) const {
      return exeFUContextMap_[fu][stage];
    }
    unsigned GetCommitPipeReg() const { return commitPipeReg_; }
    unsigned GetMemoryStage() const { return memStage_; }
  };// class SimCoreBase
}// namespace ES_SIMD

#endif//ES_SIMD_SIMCORE_HH
















