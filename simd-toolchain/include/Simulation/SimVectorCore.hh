#ifndef ES_SIMD_SIMVECTORCORE_HH
#define ES_SIMD_SIMVECTORCORE_HH

#include <deque>
#include <sstream>

#include "DataTypes/EnumFactory.hh"
#include "Utils/BitUtils.hh"
#include "Utils/LogUtils.hh"
#include "Simulation/SimSRAM.hh"
#include "Simulation/SimCore.hh"
#include "Simulation/SimOperation.hh"
#include "SimMemoryCmd.hh"

namespace ES_SIMD {

  /// \brief A generic vector processor core.
  ///
  /// UnsignedType is the unsigned data type, SignedType is corresponding signed
  /// type of UnsignedType.
  template <typename UnsignedType, typename SignedType>
  class SimVectorCore : public SimCoreBase {
    const unsigned wordAddrMask_;
  public:
    enum {
      COMM_DIR_HEAD  = 1000, COMM_DIR_TAIL   = 2000,
      COMM_LEFT_BASE = 1000, COMM_RIGHT_BASE = 2000,
      COMM_BROADCAST = 3000
    };
    SimVectorCore(const std::string& name, const uint64_t& refTimer,
                  unsigned vectLen, unsigned nFlags, unsigned iContextSize,
                  unsigned rfSize, unsigned logLv, std::ostream& log,
                  unsigned traceLv, std::ostream& trace, std::ostream& err)
      : SimCoreBase(name, refTimer, sizeof(UnsignedType)*8, logLv, log, traceLv,
                    trace, err),
        wordAddrMask_((sizeof(UnsignedType) == 2) ? 1 : 3),
        vectorLength_(vectLen), flags_(nFlags, BitVector(vectLen)),
        intContext_(iContextSize*vectLen), regFileSize_(rfSize),
        headBoundaryMode_(CommBoundaryMode::Zero),
        tailBoundaryMode_(CommBoundaryMode::Zero), commDir_(0),
        syncCommBuffHead_(0), syncCommBuffTail_(0), immHigh_(0), immHOffset_(0),
        immHMask_(0), exeOperands_(3*vectLen), exeFlagsIn_(vectLen),
        exeArithOut_(vectorLength_), exeFlagOut_(vectLen),
        exePredicate_(vectLen), commitPredicate_(vectLen),
        intCommitValue_(0, std::vector<UnsignedType>(vectLen)),
        dataMemory_(NULL), cp_(NULL) {
      SetIntContextSize(iContextSize);
      SetIntRFSize(rfSize);
    }
    virtual ~SimVectorCore() {}

    CommBoundaryMode_t& HeadBoundaryModeRef() { return headBoundaryMode_; }
    CommBoundaryMode_t& TailBoundaryModeRef() { return tailBoundaryMode_; }

    /// Communication interface
    /// \brief Read data from the first PE
    UnsignedType ReadHead(unsigned i) const {
      return intContext_[i*vectorLength_];
    }
    /// \brief Read data from the last PE
    UnsignedType ReadTail(unsigned i) const {
      return intContext_[(i+1)*vectorLength_-1];
    }

    virtual void InitializeCore() {}
    /// \brief Connect vector data memory to the processor
    void ConnectDataMemory(SimVectorSRAM<UnsignedType>* dm) {dataMemory_ = dm; }
    void ConnectControlProcessor(const SimCoreBase* cp) { cp_ = cp; }
    void SetImmHighOffset(unsigned o) {
      immHOffset_ = o;
      immHMask_   = MaxUImmNBits(o);
    }

    virtual void Reset();
    virtual void Fetch();
    virtual void Decode();
    virtual void Execute();
    virtual void Commit();
    /// \brief Interface for other components to read data from the core.
    virtual uint32_t SyncCommunicate(unsigned dir) const;
    virtual void Synchronize() {
      if (!cp_) {
        Error(GetRefTime(), SimErrorCode::IllegalCommunication,
              "Cannot communicate with CP when CP is not connected");
      }
      if (commDir_ > 0) {
        ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Sync\n");
        if (commDir_ == COMM_LEFT_BASE) {
          exeOperands_[0] = cp_->SyncCommunicate(commDir_);
          ES_LOG_P(traceLevel_, trace_, "  >>LEFT="<< exeOperands_[0] <<"\n");
        } else if (commDir_ == COMM_RIGHT_BASE) {
          exeOperands_[vectorLength_-1] = cp_->SyncCommunicate(commDir_);
          ES_LOG_P(traceLevel_, trace_,
                   "  >>RIGHT="<< exeOperands_[vectorLength_-1] <<"\n");
        } else if (commDir_ == COMM_BROADCAST) {
          UnsignedType val
            = static_cast<UnsignedType>(cp_->SyncCommunicate(commDir_));
          ES_LOG_P(traceLevel_, trace_, "  >>BROADCAST="<< val <<"\n");
          fill(exeOperands_.begin(), exeOperands_.begin() + vectorLength_, val);
        } else {
          std::stringstream ss;
          ss <<"Illegal communication direction "<< commDir_;
          Error(GetRefTime(), SimErrorCode::IllegalCommunication, ss.str());
        }
        commDir_ = 0;
      }
    }
    unsigned GetVectorLength() const { return vectorLength_; }
    std::ostream& PrintSimStatistics(std::ostream& o) const { return o; }
    const UnsignedType* GetCurrentContextPtr(unsigned i) const {
      return &intContext_[i*vectorLength_];
    }
  private:
    typedef std::pair<unsigned, UIntVector> FlagResult;
    void GetContextValue(UnsignedType* dst, unsigned oidx) {
      if (oidx == 0) {
        memset(dst, 0, sizeof(UnsignedType)*vectorLength_);
        return;
      }
      const UnsignedType* src = &intContext_[oidx*vectorLength_];
      if (!IsExplicitBypass()) {
        for (unsigned i = 0; i < vectorLength_; ++i) {
          dst[i] = GetAutoBypassValue(oidx, i);
        }
      } else { memcpy(dst, src, sizeof(UnsignedType)*vectorLength_); }
    }// GetContextValue()
    /// \brief Get the context value with automatic bypassing
    /// \param sidx Source context index.
    /// \param vidx Source vector index
    /// \return The context value.
    UnsignedType GetAutoBypassValue(unsigned sidx, unsigned vidx) {
      for (
        typename std::deque<ExeVectorResultValue<UnsignedType> >::const_iterator it
          = contextResultQueue_.begin();
        it != contextResultQueue_.end(); ++it) {
        const ExeVectorResultValue<UnsignedType>& r = *it;
        if (r.Finished() && (r.stage_ < executeStage_.GetNumOfSubStages())
            && (r.contextID_ == sidx) && r.predicate_[vidx]) {
          return r.value_[vidx];
        }// if (r.Finished())
      }
      if ((intCommitValue_.first == sidx) && commitPredicate_[vidx]) {
        return intCommitValue_.second[vidx];
      }
      return intContext_[sidx*vectorLength_ + vidx];
    }
    void PushFlagResult(unsigned l, unsigned f) {
      flagResultQueue_.push_back(
        FlagVectorResult(l, f, exeFlagOut_, exePredicate_));
    }
    void PushContextResult(unsigned fu, unsigned lat, unsigned stage,
                           unsigned dst, const std::vector<UnsignedType>& v,
                           const BitVector& predicate) {
      contextResultQueue_.push_back(
        ExeVectorResultValue<UnsignedType>(fu, lat, stage, dst, v, predicate));
    }
    void PushMemoryRequest(SimVectorMemoryCommand<UnsignedType>& cmd) {
      memoryRequestQueue_.push_back(cmd);
    }
    void UpdateFlag();
    void UpdateContext();
    void UpdateMemoryRequest();
    void PECommunication(UnsignedType* dstVector, unsigned src);

    void GenerateVectorMemoryCommand(
      TargetOpcode_t opc, const UnsignedType* base, int offset,
      const UnsignedType* data, unsigned vectLen,
      SimVectorMemoryCommand<UnsignedType>& cmd);

    unsigned vectorLength_;
    /// Core context variables
    std::vector<BitVector> flags_;
    std::vector<UnsignedType> intContext_; ///< RF and explicit bypass registers
    unsigned regFileSize_;      ///< Register file size
    CommBoundaryMode_t headBoundaryMode_;
    CommBoundaryMode_t tailBoundaryMode_;
    unsigned commDir_;
    UnsignedType syncCommBuffHead_;
    UnsignedType syncCommBuffTail_;
    bool hasImmHigh_;
    UnsignedType immHigh_;
    unsigned immHOffset_;
    unsigned immHMask_;

    /// Execute stage context
    std::vector<UnsignedType> exeOperands_;
    BitVector exeFlagsIn_;
    std::vector<UnsignedType> exeArithOut_;
    BitVector exeFlagOut_;
    BitVector exePredicate_;

    /// Result to commit
    BitVector commitPredicate_;
    std::pair<unsigned, std::vector<UnsignedType> > intCommitValue_;

    /// Result queues
    ///   First value is the delay, second is the actual result
    std::deque<FlagVectorResult> flagResultQueue_;
    std::deque<ExeVectorResultValue<UnsignedType> > contextResultQueue_;
    std::deque<SimVectorMemoryCommand<UnsignedType> > memoryRequestQueue_;

    SimVectorSRAM<UnsignedType>* dataMemory_;
    const SimCoreBase* cp_;
  };// class SimVectorCore

  //////////////////////////////////////////////////////////////////////////////
  ///              SimVectorCore template method implementation
  //////////////////////////////////////////////////////////////////////////////
  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::Reset() {
    if (dataMemory_ == NULL) {
      Error(0, SimErrorCode::InvalidInitialization, "Data memory not connected");
      return;
    }
    SimCoreBase::Reset();
    immHigh_    = 0;
    hasImmHigh_ = false;
    commDir_    = 0;
    syncCommBuffHead_ = syncCommBuffTail_ = 0;
    for (unsigned i = 0; i < flags_.size(); ++i) {
      flags_[i].reset();
    }
    exeFlagsIn_.reset();
    exeFlagOut_.reset();
    exePredicate_.set();
    commitPredicate_.set();
    memset(&intContext_[0],  0, sizeof(UnsignedType)*intContext_.size());
    memset(&exeOperands_[0], 0, sizeof(UnsignedType)*exeOperands_.size());
    memset(&exeArithOut_[0], 0, sizeof(UnsignedType)*exeArithOut_.size());
    memset(&intCommitValue_.second[0], 0,
           sizeof(UnsignedType)*intCommitValue_.second.size());
    intCommitValue_.first = 0;

    flagResultQueue_.clear();
    contextResultQueue_.clear();
    memoryRequestQueue_.clear();
    // r1 is hardwired to PEID
    for (unsigned i = 0; i < vectorLength_; ++i) {
      intContext_[vectorLength_ + i] = i;
    }
  }// Reset()

  template <typename UnsignedType, typename SignedType>
  uint32_t SimVectorCore<UnsignedType, SignedType>::
  SyncCommunicate(unsigned dir) const {
    uint32_t val = 0;
    switch (dir) {
    case COMM_DIR_HEAD: val = syncCommBuffHead_; break;
    case COMM_DIR_TAIL: val = syncCommBuffTail_; break;
    default: {
      std::stringstream ss;
      ss <<"Illegal communication direction "<< dir <<" for "<< GetName();
      Error(GetRefTime(), SimErrorCode::IllegalCommunication, ss.str());
    }};// switch(dir)
    return val;
  }// SyncCommunicate()

  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::Fetch() {
    ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Fetch\n");
    const SimOperation* fOp = fetchStage_.Advance();
    if (fOp != NULL) {
      ES_LOG_P(traceLevel_ && !fOp->IsNOP(), trace_, "  >>OP "<< *fOp <<"\n");
      decodeStage_.IssueOperation(fOp);
    }// if (fOp != NULL)
  }// Fetch()

  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::Decode() {
    ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Decode\n");
    const SimOperation* dOp = decodeStage_.Advance();
    if (dOp) {
      ES_LOG_P(traceLevel_ && !dOp->IsNOP(), trace_, "  >>OP "<< *dOp <<"\n");
      executeStage_.IssueOperation(dOp);
      ES_LOG_P(traceLevel_ && (dOp->GetNumSrcOperands() > 0), trace_,
               "  >>Dispatching ");
      unsigned oidx = 0, fidx = 0;
      // Calculate predicate
      exePredicate_.set();
      for (unsigned i = 0; i < dOp->GetNumPredicates(); ++i) {
        exePredicate_ &= flags_[dOp->GetPredicate(i).GetID()];
      }
      ES_LOG_P(traceLevel_ && !exePredicate_.all(), trace_,
               "P="<< exePredicate_ << ", ");
      dOp->IncPredCount(vectorLength_ - exePredicate_.count());
      for (unsigned i = 0; i < dOp->GetNumSrcOperands(); ++i) {
        const SimOperand& o = dOp->GetSrcOperand(i);
        ES_LOG_P(traceLevel_, trace_, o);
        switch(o.GetType()) {
        case SimOperandType::ContextValue:
          GetContextValue(&exeOperands_[oidx*vectorLength_], o.GetID());
          if (oidx == 0) {
            syncCommBuffHead_ = exeOperands_[0];
            syncCommBuffTail_ = exeOperands_[vectorLength_-1];
          }// if (oidx == 0)
          if (traceLevel_ > 0) {
            PrintVector(trace_,exeOperands_, oidx*vectorLength_,vectorLength_);
          }
          ++ oidx;
          break;
        case SimOperandType::Communication:
          PECommunication(&exeOperands_[oidx*vectorLength_], o.GetID());
          if (oidx == 0) {
            int idx = (o.GetID() % 1000);
            const UnsignedType* synVal = &intContext_[idx*vectorLength_];
            syncCommBuffHead_ = IsExplicitBypass() ? synVal[0]
              : GetAutoBypassValue(idx, 0);
            syncCommBuffTail_ = IsExplicitBypass() ? synVal[vectorLength_-1]
              : GetAutoBypassValue(idx, vectorLength_-1);
          }// if (oidx == 0)
          if (traceLevel_ > 0) {
            PrintVector(trace_,exeOperands_,oidx*vectorLength_,vectorLength_);
          }
          ++ oidx;
          break;
        case SimOperandType::Flag:
          exeFlagsIn_ = flags_[o.GetID()];
          ++fidx;
          // if (traceLevel_ > 0) {
          //   PrintVector(trace_, flags_, o.GetID()*vectorLength_, vectorLength_);
          // }
          // ES_LOG_P(traceLevel_, trace_, "="<< GetFlag(o.GetID()));
          break;
        case SimOperandType::IntImmediate:
          if (IsTargetImmediateOp(dOp->GetFirstOpcode())) {
            immHigh_ = o.GetUIntValue();
            hasImmHigh_ = true;
          } else {
            UnsignedType val = o.GetUIntValue();
            if (hasImmHigh_) {
              val = (val & immHMask_) | (immHigh_<<immHOffset_);
              hasImmHigh_ = false;
              immHigh_ = 0;
            }
            fill(exeOperands_.begin() + oidx*vectorLength_,
                 exeOperands_.begin() + (oidx+1)*vectorLength_, val);
            ++ oidx;
          }
          break;
        default:
          break;
        }// switch(o.GetType())
        ES_LOG_P(traceLevel_, trace_, ", ");
      }// for i = 0 to dOp->GetNumSrcOperands()-1
      ES_LOG_P(traceLevel_ && (dOp->GetNumSrcOperands() > 0), trace_,"\n");
      if (!IsTargetImmediateOp(dOp->GetFirstOpcode())) {
        immHigh_ = 0;
        hasImmHigh_ = false;
      }
    }// if (dOp != NULL)
  }// Decode()

  template<typename UnsignedType, typename SignedType>
  void IntVectorArithOperation(
    TargetOpcode_t opc,const UnsignedType* va,const UnsignedType* vb,UnsignedType* vo,
    const BitVector& fi, BitVector& fo, unsigned vectLen) {
    for (unsigned i = 0; i < vectLen; ++i) {
      UnsignedType a = va[i], b=vb[i];
      SignedType sA = static_cast<SignedType>(a),
        sB = static_cast<SignedType>(b);
      bool f = fi[i];
      switch (opc) {
        // ALU Operations
      case TargetOpcode::CMOV :vo[i] = f ? a : b;                         break;
      case TargetOpcode::ADD  :vo[i] = static_cast<UnsignedType>(sA + sB);break;
      case TargetOpcode::SUB  :vo[i] = static_cast<UnsignedType>(sA - sB);break;
      case TargetOpcode::RSUB :vo[i] = static_cast<UnsignedType>(sB - sA);break;
      case TargetOpcode::SFGEU:fo[i] = (a >= b);                          break;
      case TargetOpcode::SFGTU:fo[i] = (a >  b);                          break;
      case TargetOpcode::SFLEU:fo[i] = (a <= b);                          break;
      case TargetOpcode::SFLTU:fo[i] = (a <  b);                          break;
      case TargetOpcode::SFEQ :fo[i] = (a == b);                          break;
      case TargetOpcode::SFNE :fo[i] = (a != b);                          break;
      case TargetOpcode::SFGES:fo[i] = (sA >= sB);                        break;
      case TargetOpcode::SFGTS:fo[i] = (sA >  sB);                        break;
      case TargetOpcode::SFLES:fo[i] = (sA <= sB);                        break;
      case TargetOpcode::SFLTS:fo[i] = (sA <  sB);                        break;
      case TargetOpcode::XOR  :vo[i] = a ^ b;                             break;
      case TargetOpcode::AND  :vo[i] = a & b;                             break;
      case TargetOpcode::OR   :vo[i] = a | b;                             break;
      case TargetOpcode::MUL  :vo[i] = static_cast<UnsignedType>(sA * sB);break;
      case TargetOpcode::MULU :vo[i] = a * b;                             break;
      case TargetOpcode::SLL  :vo[i] = a << b;                            break;
      case TargetOpcode::SRA  :vo[i] = static_cast<UnsignedType>(sA>> sB);break;
      case TargetOpcode::SRL  :vo[i] = a >> b;                            break;
      default:                                                            break;
      }// switch(opc)
      if (IsTargetCompare(opc)) { vo[i] = sA - sB; }
    }// for i = 0 to vectLen-1
  }// ArithOperation

  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::GenerateVectorMemoryCommand(
    TargetOpcode_t opc, const UnsignedType* base, int offset,
    const UnsignedType* data, unsigned vectLen,
    SimVectorMemoryCommand<UnsignedType>& cmd) {
    if (IsTargetStore(opc)) { cmd.Value().resize(vectLen); }
    switch (opc) {
    case TargetOpcode::LW:
      cmd.Type() = (sizeof(UnsignedType) == 2) ?
        MemoryCommandType::Read16 : MemoryCommandType::Read32;
      break;
    case TargetOpcode::LH:
      cmd.Type() = (sizeof(UnsignedType) == 2) ?
        MemoryCommandType::Read8 : MemoryCommandType::Read16;
      break;
    case TargetOpcode::LB:
      cmd.Type() = MemoryCommandType::Read8;
      break;
    case TargetOpcode::SW:
      cmd.Type() = (sizeof(UnsignedType) == 2) ?
        MemoryCommandType::Write16 : MemoryCommandType::Write32;
      memcpy(&cmd.Value()[0],  data, vectLen*sizeof(UnsignedType));
      break;
    case TargetOpcode::SH:
      cmd.Type() = (sizeof(UnsignedType) == 2) ?
        MemoryCommandType::Write8 : MemoryCommandType::Write16;
      memcpy(&cmd.Value()[0],  data, vectLen*sizeof(UnsignedType));
      break;
    case TargetOpcode::SB:
      cmd.Type() = MemoryCommandType::Write8;
      memcpy(&cmd.Value()[0], data, vectLen*sizeof(UnsignedType));
      break;
    default: break;
    }// switch(opc)
    // Memory uses word address, so the request address has to be adjusted
    // lshmt: left shift amount, for adjusting offset value to get byte address
    // rshmt: right shift amount, for getting the word address
    unsigned lshmt = 0, rshmt = (sizeof(UnsignedType) == 2) ? 1 : 2;
    switch (cmd.Type()) {
    case MemoryCommandType::Read32: case MemoryCommandType::Write32:
      lshmt = 2; break;
    case MemoryCommandType::Read16: case MemoryCommandType::Write16:
      lshmt = 1; break;
    default: break;
    }
    cmd.VectorAddress().resize(vectLen);
    for (unsigned i = 0; i < vectLen; ++i) {
      unsigned byteAddr = base[i] + (offset << lshmt);
      cmd.VectorAddress()[i] = byteAddr >> rshmt;// Word address for memory
      switch (cmd.Type()) {
      case MemoryCommandType::Read16: case MemoryCommandType::Write16:
        cmd.VectorBE().resize(vectorLength_);
#ifndef SOLVER_BIG_ENDIAN
        cmd.VectorBE()[i] =  3U << (byteAddr & wordAddrMask_);
#else
        cmd.VectorBE()[i] = 12U >> (byteAddr & wordAddrMask_);
#endif
        break;
      case MemoryCommandType::Read8: case MemoryCommandType::Write8:
        cmd.VectorBE().resize(vectorLength_);
#ifndef SOLVER_BIG_ENDIAN
        cmd.VectorBE()[i] = 1U << (byteAddr & wordAddrMask_);
#else
        cmd.VectorBE()[i] = 8U >> (byteAddr & wordAddrMask_);
#endif
        break;
      default: break;
      }
    }// for i = 0 to vector Length
  }// GenerateVectorMemoryCommand()

  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::Execute() {
    ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Execute\n");
    const SimOperation* eOp = executeStage_.Back();
    const SimOperation* rOp = executeStage_.Advance();
    if (eOp != NULL) {
      // A new operation is issued to execute stage
      ES_LOG_P(traceLevel_ && !eOp->IsNOP(), trace_, "  >>OP "<< *eOp <<"\n");
      ES_LOG_P(traceLevel_ && !eOp->IsNOP() && !exePredicate_.all(), trace_,
               "  >>P="<< exePredicate_ <<"\n");
      TargetOpcode_t opc = eOp->GetFirstOpcode();
      if (IsTargetIntArithmetic(opc)) {
        // unsigned lat = eOp->GetExeLatency(), fu=eOp->GetBinding();
        const UnsignedType* a = &exeOperands_[0];
        const UnsignedType* b = &exeOperands_[vectorLength_];
        IntVectorArithOperation<UnsignedType, SignedType>(
          opc, a, b, &exeArithOut_[0], exeFlagsIn_, exeFlagOut_, vectorLength_);
        if (IsTargetCompare(opc)) {
          PushFlagResult(eOp->GetExeLatency(), eOp->GetDstOperand(0).GetID());
          PushContextResult(
            eOp->GetBinding(), eOp->GetExeLatency(), 0, 0,
            exeArithOut_, exePredicate_);
        } else if (NumTargetOpResult(opc) > 0) {//if(IsTargetCompare(opc))
          PushContextResult(
            eOp->GetBinding(), eOp->GetExeLatency(), 0,
            eOp->GetDstOperand(0).GetID(), exeArithOut_, exePredicate_);
        }// if (NumTargetOpResult(opc) > 0)
      } else if (IsTargetMemoryOp(opc)) {// if (IsTargetIntArithmetic(opc))
        SimVectorMemoryCommand<UnsignedType> cmd;
        cmd.Delay() = eOp->GetExeLatency() - 1;
        int offset = IsTargetStore(opc) ?
          eOp->GetSrcOperand(2).GetIntValue() : eOp->GetSrcOperand(1).GetIntValue();
        GenerateVectorMemoryCommand(
          opc, &exeOperands_[0], offset, &exeOperands_[vectorLength_],
          vectorLength_, cmd);
        cmd.Predicate() = exePredicate_;
        if (IsTargetLoad(opc)) {
          cmd.Destination() = eOp->GetDstOperand(0).GetID();
        }
        ES_LOG_P(traceLevel_, trace_, "  >>R:"<< cmd <<"\n");
        PushMemoryRequest(cmd);
      }// if (IsMemoryOp(opc))
    }// if (eOp != NULL)
    UpdateFlag();
    UpdateMemoryRequest();
    UpdateContext();
    if (rOp != NULL)
      commitStage_.IssueOperation(rOp);
  }// Execute()

  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::Commit() {
    ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Commit\n");
    const SimOperation* cOp = commitStage_.Advance();
    if (cOp != NULL) {
      ES_LOG_P(traceLevel_&&!cOp->IsNOP(), trace_, "  >>OP "<< *cOp <<'\n');
      if (intCommitValue_.first > 1) {
        unsigned wbAddr = GetCommitPipeReg()*vectorLength_;
        unsigned cmAddr = intCommitValue_.first*vectorLength_;
        for (unsigned i = 0; i < vectorLength_; ++i) {
          if (!commitPredicate_[i]) { continue; }
          UnsignedType val = intCommitValue_.second[i];
          if (IsExplicitBypass()) { intContext_[wbAddr + i] = val; }
          intContext_[cmAddr + i] = val;
        }// for i = 0 to vectorLength_-1
        ES_LOG_P(traceLevel_ && !commitPredicate_.all(), trace_,
                 "  >>P="<< commitPredicate_<<'\n');
        if (IsExplicitBypass()) {
          ES_LOG_P(traceLevel_, trace_, "  >>$("<< GetCommitPipeReg()
                   <<")"<< intCommitValue_.second <<'\n');
        }
        ES_LOG_P(traceLevel_, trace_, "  >>$("<< intCommitValue_.first
                 <<")"<< intCommitValue_.second <<'\n');
        intCommitValue_.first = 0;
      }// if (commitValue_.first > 0)
    }// if (cOp != NULL)
  }// Commit()

  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::UpdateFlag() {
    for (std::deque<FlagVectorResult>::iterator it
           = flagResultQueue_.begin(); it != flagResultQueue_.end(); ++it) {
      FlagVectorResult& f = *it;
      if (f.delay_ > 0) {
        if (--f.delay_ == 0) {
          int fid = f.flagID_;
          BitVector& tf = flags_[fid];
          ES_LOG_P(traceLevel_, trace_, "  >>$F("<< fid <<")="<< f.value_
                   <<"(P="<< f.predicate_ <<")\n");
          for (unsigned i = 0; i < vectorLength_; ++i) {
            if (f.predicate_[i]) { tf[i] = f.value_[i]; }
          }
        }
      }// if (f.first)
    }// for flagResultQueue_ iterator it
    while (!flagResultQueue_.empty()) {
      if (flagResultQueue_.front().delay_ > 0)
        break;
      flagResultQueue_.pop_front();
    }// while (!flagResultQueue_.empty())
  }// UpdateFlag()

  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::UpdateContext() {
    unsigned commited = 0;
    for (typename std::deque<ExeVectorResultValue<UnsignedType> >::iterator it
           = contextResultQueue_.begin();it != contextResultQueue_.end();++it) {
      ExeVectorResultValue<UnsignedType>& r = *it;
      if (!r.Finished()) { --r.delay_; }
      if (!r.Finished()) { ++r.stage_; continue; }
      if (r.stage_ < executeStage_.GetNumOfSubStages()) {
        // At the moment, the result always flow through the pipeline regardless of
        // whether it needs to be written back
        unsigned pipeReg = IsExplicitBypass() ?
          GetFUStageContextID(r.fu_, r.stage_) : 0;
        if (pipeReg > 0) {
          ES_ASSERT_MSG(
            pipeReg<intContext_.size(), "Illegal context id "<<pipeReg);
          ES_LOG_P(traceLevel_,trace_,"  >>$("<< pipeReg <<")"<< r.value_ <<"\n");
          // memcpy(&intContext_[pipeReg*vectorLength_], &r.value_[0],
          //        sizeof(UnsignedType)*vectorLength_);
          for (unsigned i = 0; i < vectorLength_; ++i) {
            if (r.predicate_[i]) {
              intContext_[pipeReg*vectorLength_+i] = r.value_[i];
            }
          }
        }// if (pipeReg > 0)
        if ((++r.stage_ == executeStage_.GetNumOfSubStages())
            && (r.contextID_ > 0)) {
          ES_LOG_P(traceLevel_, trace_,
                   "  >>Committing $("<< r.contextID_ <<")("<< r.stage_ <<")"
                   << r.value_ <<"\n");
          intCommitValue_.first = r.contextID_;
          memcpy(&intCommitValue_.second[0], &r.value_[0],
                 sizeof(UnsignedType)*vectorLength_);
          commitPredicate_ = r.predicate_;
          ++ commited;
        }// if (--r.delay_ == 0)
      }// if (r.delay)
    }// for contextResultQueue_ iterator it
    if (commited > 1) {
      std::stringstream ss;
      ss << "Attempting to commit "<< commited <<" values in one cycle\n";
      Error(GetRefTime(), SimErrorCode::RFWritePortConflict, ss.str());
    }
    while (!contextResultQueue_.empty()) {
      ExeVectorResultValue<UnsignedType>& r = contextResultQueue_.front();
      if (!r.Finished() || (r.stage_ < executeStage_.GetNumOfSubStages()))
        break;
      contextResultQueue_.pop_front();
    }// while (!contextResultQueue_.empty())
  }// UpdateContext()

  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::UpdateMemoryRequest() {
    unsigned memOp = 0;
    for (typename std::deque<SimVectorMemoryCommand<UnsignedType> >::iterator it
           = memoryRequestQueue_.begin();it != memoryRequestQueue_.end();++it){
      SimVectorMemoryCommand<UnsignedType>& c = *it;
      if (c.State() == SimMemCmdState::Init) {
        if (c.Delay() > 0) {
          --c.Delay();
        } else {// if (c.Delay() > 0)
          ++ memOp;
          c.State() = SimMemCmdState::Finished;
          c.Delay() = dataMemory_->GetLatency() - 1;
          // unsigned byteEnable = 0xF;
          if (c.IsLoad()) {
            c.Value().resize(vectorLength_);
          }
          switch (c.Type()) {
          case MemoryCommandType::Read32:
            dataMemory_->VectorRead(&c.Value()[0], c.VectorAddress());
            break;
          case MemoryCommandType::Read16:
            if (sizeof(UnsignedType) == 2) {
              dataMemory_->VectorRead(&c.Value()[0], c.VectorAddress());
            } else if (sizeof(UnsignedType) == 4) {
              dataMemory_->VectorReadBE(c.Value(),c.VectorAddress(),c.VectorBE());
              for (unsigned i = 0; i < vectorLength_; ++i) {
#ifdef SOLVER_LITTLE_ENDIAN
                if (c.VectorBE()[i] == 0x3) { c.Value()[i] >>= 16; }
#else
                if (c.VectorBE()[i] == 0xC) { c.Value()[i] >>= 16; }
#endif
                c.Value()[i] &= 0xFFFF;
              }
            }
            break;
          case MemoryCommandType::Read16SExt:
            if (sizeof(UnsignedType) == 2) {
              dataMemory_->VectorRead(&c.Value()[0], c.VectorAddress());
            } else if (sizeof(UnsignedType) == 4) {
              dataMemory_->VectorReadBE(c.Value(),c.VectorAddress(),c.VectorBE());
              for (unsigned i = 0; i < vectorLength_; ++i) {
#ifdef SOLVER_LITTLE_ENDIAN
                if (c.VectorBE()[i] == 0x3) { c.Value()[i] >>= 16; }
#else
                if (c.VectorBE()[i] == 0xC) { c.Value()[i] >>= 16; }
#endif
                c.Value()[i] = SignExtendNBitImm(c.Value()[i] & 0xFFFF, 16);
              }
            }
            break;
          case MemoryCommandType::Read8:
            dataMemory_->VectorReadBE(c.Value(),c.VectorAddress(),c.VectorBE());
            for (unsigned i = 0; i < vectorLength_; ++i) {
              switch (c.VectorBE()[i]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wshift-count-overflow"
#if SOLVER_LITTLE_ENDIAN
              case 0x4: c.Value()[i] = (c.Value()[i] >>  8); break;
              case 0x2: c.Value()[i] = (c.Value()[i] >> 16); break;
              case 0x1: c.Value()[i] = (c.Value()[i] >> 24); break;
#else
              case 0x2: c.Value()[i] = (c.Value()[i] >>  8); break;
              case 0x4: c.Value()[i] = (c.Value()[i] >> 16); break;
              case 0x8: c.Value()[i] = (c.Value()[i] >> 24); break;
#endif
              }// switch (c.VectorBE()[i])
              c.Value()[i] &= 0xFF;
            }// for i = 0 to vectorLength_-1
            break;
          case MemoryCommandType::Read8SExt:
            dataMemory_->VectorReadBE(c.Value(),c.VectorAddress(),c.VectorBE());
            for (unsigned i = 0; i < vectorLength_; ++i) {
              switch (c.VectorBE()[i]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wshift-count-overflow"
#if SOLVER_LITTLE_ENDIAN
              case 0x4: c.Value()[i] = (c.Value()[i] >>  8) & 0xFF; break;
              case 0x2: c.Value()[i] = (c.Value()[i] >> 16) & 0xFF; break;
              case 0x1: c.Value()[i] = (c.Value()[i] >> 24) & 0xFF; break;
#else
              case 0x2: c.Value()[i] = (c.Value()[i] >>  8) & 0xFF; break;
              case 0x4: c.Value()[i] = (c.Value()[i] >> 16) & 0xFF; break;
              case 0x8: c.Value()[i] = (c.Value()[i] >> 24) & 0xFF; break;
#endif
              }// switch (c.VectorBE()[i])
              c.Value()[i] = SignExtendNBitImm(c.Value()[i], 8);
            }// for i = 0 to vectorLength_-1
            break;
          case MemoryCommandType::Write32:
            dataMemory_->VectorWrite(
              &c.Value()[0], c.VectorAddress(), c.Predicate());
            break;
          case MemoryCommandType::Write16: {
            if (sizeof(UnsignedType) == 2) {
              dataMemory_->VectorWrite(
                &c.Value()[0], c.VectorAddress(), c.Predicate());
            } else if (sizeof(UnsignedType) == 4) {
              for (unsigned i = 0; i < vectorLength_; ++i) {
#ifdef SOLVER_LITTLE_ENDIAN
                if (c.VectorBE()[i] == 0x3) { c.Value()[i] <<= 16; }
#else
                if (c.VectorBE()[i] == 0xC) { c.Value()[i] <<= 16; }
#endif
              }
              dataMemory_->VectorWriteBE(c.Value(), c.VectorAddress(), c.VectorBE());
            }
            break;
          }
          case MemoryCommandType::Write8: {
            for (unsigned i = 0; i < vectorLength_; ++i) {
              switch (c.VectorBE()[i]) {
#ifdef SOLVER_LITTLE_ENDIAN
              case 0x4: c.Value()[i] <<=  8; break;
              case 0x2: c.Value()[i] <<= 16; break;
              case 0x1: c.Value()[i] <<= 24; break;
#else
              case 0x2: c.Value()[i] <<=  8; break;
              case 0x4: c.Value()[i] <<= 16; break;
              case 0x8: c.Value()[i] <<= 24; break;
#endif
#pragma clang diagnostic pop
              }// switch (c.VectorBE()[i])
            }// for i = 0 to vectorLength_-1
            dataMemory_->VectorWriteBE(c.Value(), c.VectorAddress(), c.VectorBE());
            break;
          }
          default: break;
          }// switch (c.Type())
          ES_LOG_P(traceLevel_, trace_, "  >>A:"<< c <<"\n");
          if (c.IsLoad()) {
            ES_LOG_P(traceLevel_, trace_, "  >>C:"<< c.Destination()
                     <<"("<< GetMemoryStage() + 1 <<")\n");
            PushContextResult(2, 1, GetMemoryStage(), c.Destination(),
                              c.Value(), c.Predicate());
          }// if (c.IsTargetLoad())
        }// if (c.Delay() > 0)
      }// if (c.State() == SimMemCmdState::Init)
    }// for memoryRequestQueue_ iterator it
    while (!memoryRequestQueue_.empty()) {
      SimVectorMemoryCommand<UnsignedType>& r = memoryRequestQueue_.front();
      if (!r.Finished())
        break;
      memoryRequestQueue_.pop_front();
    }// while (!flagResultQueue_.empty())
  }// UpdateMemoryRequest()

  template <typename UnsignedType, typename SignedType>
  void SimVectorCore<UnsignedType, SignedType>::
  PECommunication(UnsignedType* dstVector, unsigned src) {
    unsigned s = src;
    if (src == COMM_BROADCAST) {  commDir_ = COMM_BROADCAST; }
    else if (src >= COMM_RIGHT_BASE) {
      s = src - COMM_RIGHT_BASE;
      if (s == 0) {
        memset(dstVector, 0, sizeof(UnsignedType)*vectorLength_);
        return;
      }
      const UnsignedType* srcVector = &intContext_[s*vectorLength_];
      if (!IsExplicitBypass()) {
        for (unsigned j = 0; j < (vectorLength_-1); ++j) {
          dstVector[j] = GetAutoBypassValue(s, j+1);
        }
      } else {
        memcpy(dstVector, srcVector+1, sizeof(UnsignedType)*(vectorLength_-1));
      }
      switch(tailBoundaryMode_) {
      case CommBoundaryMode::Zero: dstVector[vectorLength_-1] = 0; break;
      case CommBoundaryMode::Self:
        dstVector[vectorLength_-1]
          = IsExplicitBypass() ? srcVector[vectorLength_-1]
          : GetAutoBypassValue(s, vectorLength_-1);
        break;
      case CommBoundaryMode::Wrap:
        dstVector[vectorLength_-1]
          = IsExplicitBypass() ? srcVector[0] : GetAutoBypassValue(s, 0);
        break;
      case CommBoundaryMode::Scalar:
        if (cp_ == NULL) {
          Error(GetRefTime(), SimErrorCode::IllegalCommunication,
                "Cannot use scalar boundary mode when CP is not connected");
          break;
        }
        commDir_ = COMM_RIGHT_BASE;
        //ES_NOTSUPPORTED("Scalar mode not implemented yet");
      default: break;
      }// switch(boundaryMode_)
    } else if (src >= COMM_LEFT_BASE) {
      s = src - COMM_LEFT_BASE;
      if (s == 0) {
        memset(dstVector, 0, sizeof(UnsignedType)*vectorLength_);
        return;
      }
      const UnsignedType* srcVector = &intContext_[s*vectorLength_];
      if (!IsExplicitBypass()) {
        for (unsigned j = 1; j < vectorLength_; ++j) {
          dstVector[j] = GetAutoBypassValue(s, j-1);
        }
      } else {
        memcpy(dstVector+1, srcVector, sizeof(UnsignedType)*(vectorLength_-1));
      }
      switch(headBoundaryMode_) {
      case CommBoundaryMode::Zero:dstVector[0] = 0; break;
      case CommBoundaryMode::Self:dstVector[0]
          = IsExplicitBypass() ? srcVector[0] : GetAutoBypassValue(s, 0);
        break;
      case CommBoundaryMode::Wrap:dstVector[0]
          = IsExplicitBypass() ? srcVector[vectorLength_-1]
          : GetAutoBypassValue(s, vectorLength_-1);
        break;
      case CommBoundaryMode::Scalar:commDir_=COMM_LEFT_BASE; break;
      default: break;
      }// switch(boundaryMode_)
    }
  }// PECommunication()
}// namespace ES_SIMD

#endif//ES_SIMD_SIMVECTORCORE_HH
