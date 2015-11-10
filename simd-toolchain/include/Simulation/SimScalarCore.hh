#ifndef ES_SIMD_SIMSCALARCORE_HH
#define ES_SIMD_SIMSCALARCORE_HH

#include <deque>
#include "Utils/BitUtils.hh"
#include "Utils/LogUtils.hh"
#include "Simulation/SimDefs.hh"
#include "Simulation/SimCore.hh"
#include "Simulation/SimSyncChannel.hh"
#include "Simulation/SimMemoryCmd.hh"
#include "Simulation/SimSRAM.hh"
#include "Simulation/SimOperand.hh"
#include "Simulation/SimProgramSection.hh"

namespace ES_SIMD {

  template <typename UnsignedType, typename SignedType>
  class SimScalarCore : public SimCoreBase {
    bool traceBranch_;
    unsigned linkReg_;
    const unsigned wordAddrMask_;
  public:
    SimScalarCore(const std::string& name, const uint64_t& refTimer,
                  unsigned nFlags, unsigned iContextSize, unsigned rfSize,
                  unsigned logLv, std::ostream& log, unsigned traceLv,
                  std::ostream& trace, std::ostream& err)
      : SimCoreBase(name, refTimer, sizeof(UnsignedType)*8, logLv, log, traceLv,trace,err),
        traceBranch_(false), linkReg_(9),
        wordAddrMask_((sizeof(UnsignedType) == 2) ? 1 : 3), flags_(nFlags, 0),
        intContext_(iContextSize, 0), regFileSize_(rfSize), commDir_(0),
        immHigh_(0), immHOffset_(0), immHOffsetJType_(0), immHMask_(0),
        immHMaskJType_(0), exeOperands_(3), exeFlagsIn_(1), pe_(NULL) {
      SetIntContextSize(iContextSize);
      SetIntRFSize(rfSize);
    }
    virtual ~SimScalarCore() {};
    virtual std::ostream& PrintSimStatistics(std::ostream& o) const;
    virtual void SetBranchTrace(bool t) { traceBranch_ = t;}
    virtual void Reset() {
      SimCoreBase::Reset();
      std::fill(flags_.begin(), flags_.end(), 0);
      std::fill(intContext_.begin(), intContext_.end(), 0);
      std::fill(exeOperands_.begin(), exeOperands_.end(), 0);
      std::fill(exeFlagsIn_.begin(),  exeFlagsIn_.end(), 0);
      commDir_ = 0;
      immHigh_ = 0;
      intCommitValue_.first = 0;
      intCommitValue_.second = 0;
      flagResultQueue_.clear();
      contextResultQueue_.clear();
      memoryRequestQueue_.clear();
      hasImmHight_ = false;
    }
    virtual void Fetch();
    virtual void Decode();
    virtual void Execute();
    virtual void Commit();
    virtual void CycleFinal() {
      if (FetchWaiting())
        UpdateProgramCounter();
    }
    virtual void Synchronize() {
      if (commDir_ > 0) {
        ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Sync\n");
        exeOperands_[0] = pe_->SyncCommunicate(commDir_);
        ES_LOG_P(traceLevel_, trace_, "  >>C{"<< commDir_ <<"}="
                 << exeOperands_[0] <<'\n');
        commDir_ = 0;
      }
    }

    virtual uint32_t SyncCommunicate(unsigned dir) const {
      return exeOperands_[0];
    }
    void InitializeCore() {}
    void ConnectDataMemory(SimScalarSRAM<UnsignedType>* dm) {dataMemory_ = dm; };
    void ConnectPEArray(const SimCoreBase* pe) { pe_ = pe; }
    void SetImmHighOffset(unsigned o) {
      immHOffset_ = o;
      immHMask_   = MaxUImmNBits(o);
    }
    void SetImmHighOffsetJType(unsigned o) {
      immHOffsetJType_ = o;
      immHMaskJType_   = MaxUImmNBits(o);
    }
    UnsignedType GetCurrentContextValue(unsigned i) const { return intContext_[i]; }
  private:
    typedef std::pair<unsigned, unsigned> FlagResult;
    UnsignedType GetContextValue(unsigned i) const {
      UnsignedType v = intContext_[i];
      if (!IsExplicitBypass() && (i > 0)) {
        // Check if pipeline value should be bypassed
        for (typename std::deque<ExeResultValue<UnsignedType> >::const_iterator it
               = contextResultQueue_.begin();
             it != contextResultQueue_.end(); ++it) {
          const ExeResultValue<UnsignedType>& r = *it;
          if (r.Finished() && (r.stage_ < executeStage_.GetNumOfSubStages())
              && (r.contextID_ == i)) {
            return r.value_;
          }// if (r.Finished())
        }
        if (intCommitValue_.first == i)
          return intCommitValue_.second;
      }// if (!IsExplicitBypass() && (i > 0))
      return v;
    }
    void UpdateFlag();
    void UpdateContext();
    void UpdateMemoryRequest();
    void SetMaxExeOperands(unsigned n) { exeOperands_.resize(n); }

    void SetFlag(unsigned i, unsigned f) { flags_[i] = f; }
    bool GetFlag(unsigned i) const {
      return (flags_[i] != 0) ? true : false;
    }
    void PushFlagResult(const std::pair<unsigned, FlagResult>& f) {
      flagResultQueue_.push_back(f);
    }
    void PushContextResult(const ExeResultValue<UnsignedType>& r) {
      contextResultQueue_.push_back(r);
    }
    void PushMemoryRequest(const SimMemoryCommand& c) {
      memoryRequestQueue_.push_back(c);
    }
    bool CondBranchTaken(const SimOperation& o) const {
      TargetOpcode_t opc = o.GetFirstOpcode();
      if (IsTargetBranch(opc)) {
        if (opc == TargetOpcode::BF) {
          return GetFlag(o.GetSrcOperand(0).GetID());
        } else if (opc == TargetOpcode::BNF){
          return !GetFlag(o.GetSrcOperand(0).GetID());
        }// if (opc == TargetOpcode::BNF)
      }// if (IsTargetBranch(opc))
      return false;
    }// CondBranchTaken()

    UnsignedType GetPEValue(unsigned dir, unsigned id) const {
      if (pe_ == NULL) {
        Error(GetRefTime(), SimErrorCode::IllegalCommunication,
              "No PE to communicate");
      }
      return static_cast<UnsignedType>(pe_->SyncCommunicate(dir));
    }// GetPEValue()
    void GenerateMemoryCommand(TargetOpcode_t opc, int base,
                               int offset, UnsignedType data, SimMemoryCommand& cmd);

    /// Core context variables
    UIntVector   flags_;        ///< Flags
    std::vector<UnsignedType> intContext_; ///< Register file and pipeline registers
    unsigned regFileSize_;
    unsigned commDir_;
    bool hasImmHight_;
    UnsignedType immHigh_;                 ///< Higher bits of immediate value
    unsigned immHOffset_;       ///< Offset of higher imm bits
    unsigned immHOffsetJType_;  ///< Offset of higher imm bits for branch
    unsigned immHMask_;         ///< Bit mask of higher imm bits
    unsigned immHMaskJType_;    ///< Bit mask of higher imm bits for branch

    /// Execute stage context
    std::vector<UnsignedType> exeOperands_; ///< execution stage operands
    UIntVector     exeFlagsIn_;    ///< execution flag inputs
    std::deque<ExeResultValue<UnsignedType> > contextResultQueue_;
    std::deque<SimMemoryCommand> memoryRequestQueue_;
    /// Result to commit
    std::pair<unsigned, UnsignedType> intCommitValue_;
    SimScalarSRAM<UnsignedType>* dataMemory_;
    // First value is the delay, second is the actual result
    std::deque<std::pair<unsigned, FlagResult> > flagResultQueue_;
    const SimCoreBase* pe_;
  };// class SimScalarCore

  //////////////////////////////////////////////////////////////////////////////
  ///              SimScalarCore template method implementation
  //////////////////////////////////////////////////////////////////////////////
  template<typename UnsignedType, typename SignedType>
  void SimScalarCore<UnsignedType, SignedType>::Fetch() {
    ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Fetch\n");
    const SimOperation* fOp = fetchStage_.Advance();
    if (fOp != NULL) {
      ES_LOG_P(traceLevel_ && !fOp->IsNOP(), trace_, "  >>OP "<< *fOp <<'\n');
      decodeStage_.IssueOperation(fOp);
      if ((fOp->GetFirstOpcode() == TargetOpcode::J)
          && (fOp->GetSrcOperand(0).GetType() == SimOperandType::IntImmediate)
          && (fOp->GetSrcOperand(0).GetIntValue() == 0)) {
        ES_LOG_P(logLevel_, log_, "Encounter self branch at 0x"
                 << std::hex << fOp->GetAddress() <<" in cycle "<< std::dec
                 << GetRefTime() <<", terminating...\n");
        ES_LOG_P(traceLevel_, trace_, "  >>Terminate\n");
        Terminate();
      }
    }// if (fOp != NULL)
  }// Fetch()

  template<typename UnsignedType, typename SignedType>
  void SimScalarCore<UnsignedType, SignedType>::Decode() {
    ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Decode\n");
    unsigned nextPC = GetProgramCounter() + 1U;
    const SimOperation* dOp = decodeStage_.Advance();
    if (dOp != NULL) {
      // If an operation enters decode stage, it is considered executed
      dOp->IncExeCount();
      ++coreStat_.issued_;
      ES_LOG_P(traceLevel_ && !dOp->IsNOP(), trace_, "  >>OP "<< *dOp <<'\n');
      // Check predication
      unsigned np = dOp->GetNumPredicates();
      for (unsigned i = 0; i < np; ++i) {
        if (!flags_[dOp->GetPredicate(i).GetID()]) {
          SetNextPC(nextPC);
          return;
        }
      }
      executeStage_.IssueOperation(dOp);
      TargetOpcode_t opc = dOp->GetFirstOpcode();
      if (IsTargetBranch(opc)) {
        ++coreStat_.branches_;
        if (IsTargetCondBranch(opc)) {
          if (CondBranchTaken(*dOp)) {
            ++coreStat_.takenBranches_;
            nextPC = dOp->GetAddress() + dOp->GetSrcOperand(1).GetIntValue();
            ES_LOG_P(traceLevel_, trace_,"  >>Branch to "<< nextPC <<'\n');
            ES_LOG_P(!traceLevel_&&traceBranch_, trace_, std::dec<< GetRefTime()
                     <<':'<<GetProgramCounter()<<':'<<nextPC<<'\n');
          }
        } else {// if (CondBranchTaken(*dOp))
          const SimOperand& jop = dOp->GetSrcOperand(0);
          if (jop.GetType() == SimOperandType::IntImmediate) {
            int val = jop.GetIntValue();
            if (immHigh_ > 0) {
              val = (val & immHMask_) | (immHigh_<<immHOffset_);
            }
            nextPC = dOp->GetAddress() + val;
          } else if (jop.GetType() == SimOperandType::ContextValue) {
            nextPC = GetContextValue(jop.GetID());
          } else {
            std::stringstream ss;
            ss << "Illegal branch operand type \""
               << SimOperandType::GetString(jop.GetType()) <<"\"";
            Error(GetRefTime(), SimErrorCode::IllegalOperand, ss.str());
          }
          ++coreStat_.takenBranches_;
          ES_LOG_P(traceLevel_ && !dOp->IsNOP(), trace_,
                   "  >>Branch to "<< nextPC <<'\n');
          ES_LOG_P(!traceLevel_&&traceBranch_, trace_, std::dec << GetRefTime()
                   <<':'<<GetProgramCounter()<<':'<<nextPC<<'\n');
          if (IsTargetCall(opc)) {
            intContext_[linkReg_] = dOp->GetAddress() + 2;
          }
        }// if (IsTargetCondBranch(opc))
      } else {// if (IsTargetBranch(opc))
        ES_LOG_P(traceLevel_ && (dOp->GetNumSrcOperands() > 0), trace_,
                 "  >>Dispatching ");
        unsigned oidx = 0, fidx = 0;
        for (unsigned i = 0; i < dOp->GetNumSrcOperands(); ++i) {
          const SimOperand& o = dOp->GetSrcOperand(i);
          ES_LOG_P(traceLevel_ && (i > 0), trace_,", ");
          ES_LOG_P(traceLevel_, trace_,o);
          switch(o.GetType()) {
          case SimOperandType::ContextValue:
            exeOperands_[oidx++] = GetContextValue(o.GetID());
            ES_LOG_P(traceLevel_, trace_, "="<< GetContextValue(o.GetID()));
            break;
          case SimOperandType::Communication: {
            unsigned cid = o.GetID() % 1000;
            // exeOperands_[oidx++] = GetPEValue(o.GetID() - cid, cid);
            commDir_ = o.GetID() - cid;
            ++oidx;
            break;
          }
          case SimOperandType::Flag:
            exeFlagsIn_[fidx++] = GetFlag(o.GetID());
            ES_LOG_P(traceLevel_, trace_, "="<< GetFlag(o.GetID()));
            break;
          case SimOperandType::IntImmediate:
            if (IsTargetImmediateOp(opc)) {
              immHigh_ = o.GetUIntValue();
              hasImmHight_ = true;
            } else {
              UnsignedType val = o.GetUIntValue();
              if (hasImmHight_) {
                val = (val & immHMask_) | (immHigh_<<immHOffset_);
                hasImmHight_ = false;
                immHigh_ = 0;
                ES_LOG_P(traceLevel_, trace_, "(="<< val <<")");
              }
              exeOperands_[oidx++] = val;
            }
            break;
          default:
            break;
          }// switch(o.GetType())
        }// for i = 0 to dOp->GetNumSrcOperands()-1
        ES_LOG_P(traceLevel_ && (dOp->GetNumSrcOperands() > 0), trace_,'\n');
      }// if (IsBranch(opc))
      if (!IsTargetImmediateOp(opc)) {
        immHigh_ = 0;
        hasImmHight_ = false;
      }
    }// if (dOp != NULL)
    SetNextPC(nextPC);
  }// Decode()

  template<typename UnsignedType, typename SignedType>
  void IntArithOperation(
    TargetOpcode_t opc, UnsignedType a, UnsignedType b, UnsignedType& o,
    unsigned flagIn, unsigned& flagOut) {
    SignedType sA = static_cast<SignedType>(a), sB = static_cast<SignedType>(b);
    bool f = (flagIn != 0);
    switch (opc) {
      // ALU Operations
    case TargetOpcode::CMOV : o = f ? a : b;                          break;
    case TargetOpcode::ADD  : o = static_cast<UnsignedType>(sA + sB); break;
    case TargetOpcode::SUB  : o = static_cast<UnsignedType>(sA - sB); break;
    case TargetOpcode::RSUB : o = static_cast<UnsignedType>(sB - sA); break;
    case TargetOpcode::SFGEU: flagOut = (a >= b);                     break;
    case TargetOpcode::SFGTU: flagOut = (a >  b);                     break;
    case TargetOpcode::SFLEU: flagOut = (a <= b);                     break;
    case TargetOpcode::SFLTU: flagOut = (a <  b);                     break;
    case TargetOpcode::SFEQ : flagOut = (a == b);                     break;
    case TargetOpcode::SFNE : flagOut = (a != b);                     break;
    case TargetOpcode::SFGES: flagOut = (sA >= sB);                   break;
    case TargetOpcode::SFGTS: flagOut = (sA >  sB);                   break;
    case TargetOpcode::SFLES: flagOut = (sA <= sB);                   break;
    case TargetOpcode::SFLTS: flagOut = (sA <  sB);                   break;
    case TargetOpcode::XOR : o = a ^ b;                               break;
    case TargetOpcode::AND : o = a & b;                               break;
    case TargetOpcode::OR  : o = a | b;                               break;
    case TargetOpcode::MUL : o = static_cast<UnsignedType>(sA * sB);  break;
    case TargetOpcode::MULU: o = a * b;                               break;
    case TargetOpcode::SLL : o = a << b;                              break;
    case TargetOpcode::SRA : o = static_cast<UnsignedType>(sA >> sB); break;
    case TargetOpcode::SRL : o = a >> b;                              break;
    default: break;
    }// switch(opc)
    if (IsTargetCompare(opc)) { o = sA - sB; }
  }// ArithOperation

  template <typename UnsignedType, typename SignedType>
  void SimScalarCore<UnsignedType, SignedType>::GenerateMemoryCommand(
    TargetOpcode_t opc, int base,
    int offset, UnsignedType data, SimMemoryCommand& cmd) {
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
      cmd.Value() = data;
      break;
    case TargetOpcode::SH:
      cmd.Type() = (sizeof(UnsignedType) == 2) ?
        MemoryCommandType::Write8 : MemoryCommandType::Write16;
      cmd.Value() = data;
      break;
    case TargetOpcode::SB:
      cmd.Type() = MemoryCommandType::Write8;
      cmd.Value() = data;
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
    int byteAddr = base + (offset << lshmt);
    cmd.Address() = byteAddr >> rshmt;// Word address for memory
    // Calculate byte enable
    switch (cmd.Type()) {
    case MemoryCommandType::Read16: case MemoryCommandType::Write16:
#ifndef SOLVER_BIG_ENDIAN
      cmd.ByteEnable() =  3U << (byteAddr & wordAddrMask_);
#else
      cmd.ByteEnable() = 12U >> (byteAddr & wordAddrMask_);
#endif
      break;
    case MemoryCommandType::Read8: case MemoryCommandType::Write8:
#ifndef SOLVER_BIG_ENDIAN
      cmd.ByteEnable() = 1U << (byteAddr & wordAddrMask_);
#else
      cmd.ByteEnable() = 8U >> (byteAddr & wordAddrMask_);
#endif
      break;
    default: break;
    }
  }// GenerateMemoryCommand()

  template<typename UnsignedType, typename SignedType>
  void SimScalarCore<UnsignedType, SignedType>::Execute() {
    ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Execute\n");
    // TODO: figure out a proper way to stall for memory latency if needed
    const SimOperation* eOp = executeStage_.Back();
    const SimOperation* rOp = executeStage_.Advance();
    if (eOp != NULL) {
      // A new operation is issued to execute stage
      ES_LOG_P(traceLevel_ && !eOp->IsNOP(), trace_, "  >>OP "<< *eOp <<'\n');
      TargetOpcode_t opc = eOp->GetFirstOpcode();
      if (IsTargetIntArithmetic(opc)) {
        // The result is calculated regard less of the execution latency
        unsigned lat = eOp->GetExeLatency(), fu=eOp->GetBinding();
        UnsignedType a = exeOperands_[0], b = exeOperands_[1], out = 0;
        unsigned f=exeFlagsIn_[0], fout = 0;
        IntArithOperation<UnsignedType, SignedType>(opc, a, b, out, f, fout);
        ES_LOG_P(traceLevel_, trace_, "  >>O="<< out <<",flagO="
                 << fout <<",lat="<< lat <<'\n');
        if (IsTargetCompare(opc)) {
          const SimOperand& fop = eOp->GetDstOperand(0);
          PushFlagResult(std::make_pair(lat, std::make_pair(fop.GetID(), fout)));
          PushContextResult(ExeResultValue<UnsignedType>(fu, lat, 0,  0, out));
        } else if (NumTargetOpResult(opc) > 0) {
          PushContextResult(ExeResultValue<UnsignedType>(
                              fu, lat, 0,  eOp->GetDstOperand(0).GetID(), out));
        }
      } else if (IsTargetMemoryOp(opc)) {
        SimMemoryCommand cmd;
        cmd.Delay() = eOp->GetExeLatency() - 1;
        int offset = IsTargetStore(opc) ? exeOperands_[2] : exeOperands_[1];
        GenerateMemoryCommand(opc,exeOperands_[0],offset,exeOperands_[1],cmd);
        if (IsTargetLoad(opc)) {
          cmd.Destination() = eOp->GetDstOperand(0).GetID();
        }
        ES_LOG_P(traceLevel_, trace_, "  >>R:"<< cmd <<'\n');
        PushMemoryRequest(cmd);
      }// if (IsMemoryOp(opc))
    }// if (eOp != NULL)
    UpdateFlag();
    UpdateMemoryRequest();
    UpdateContext();
    if (rOp != NULL)
      commitStage_.IssueOperation(rOp);
  }// Execute()

  template<typename UnsignedType, typename SignedType>
  void SimScalarCore<UnsignedType, SignedType>::Commit() {
    ES_LOG_P(traceLevel_, trace_, " |=["<< GetName() <<"]Commit\n");
    const SimOperation* cOp = commitStage_.Advance();
    if (cOp != NULL) {
      ES_LOG_P(traceLevel_ && !cOp->IsNOP(), trace_, "  >>OP "<< *cOp <<'\n');
      if (intCommitValue_.first > 0) {
        if (IsExplicitBypass()) {
          intContext_[GetCommitPipeReg()] = intCommitValue_.second;
          ES_LOG_P(traceLevel_, trace_, "  >>$("<< GetCommitPipeReg()
                   <<")="<< intCommitValue_.second <<'\n');
        }
        intContext_[intCommitValue_.first] = intCommitValue_.second;
        ES_LOG_P(traceLevel_, trace_, "  >>$("<< intCommitValue_.first
                 <<")="<< intCommitValue_.second <<'\n');
        intCommitValue_.first = 0;
      }// if (commitValue_.first > 0)
    }// if (cOp != NULL)
  }// Commit()

  template<typename UnsignedType, typename SignedType>
  void SimScalarCore<UnsignedType, SignedType>::UpdateFlag() {
    for (std::deque<std::pair<unsigned, FlagResult> >::iterator it
           = flagResultQueue_.begin(); it != flagResultQueue_.end(); ++it) {
      std::pair<unsigned, FlagResult>& f = *it;
      if (f.first > 0) {
        if (--f.first == 0) {
          ES_LOG_P(traceLevel_, trace_,
                   "  >>$F("<< f.second.first <<")="<< f.second.second<<'\n');
          flags_[f.second.first] = f.second.second;
        }
      }// if (f.first)
    }// for flagResultQueue_ iterator it
    while (!flagResultQueue_.empty()) {
      if (flagResultQueue_.front().first > 0)
        break;
      flagResultQueue_.pop_front();
    }// while (!flagResultQueue_.empty())
  }// UpdateFlag()

  template<typename UnsignedType, typename SignedType>
  void SimScalarCore<UnsignedType, SignedType>::UpdateContext() {
    unsigned commited = 0;
    for (typename std::deque<ExeResultValue<UnsignedType> >::iterator it
           = contextResultQueue_.begin(); it != contextResultQueue_.end(); ++it) {
      ExeResultValue<UnsignedType>& r = *it;
      if (!r.Finished()) { --r.delay_; }
      if (!r.Finished()) {
        ++r.stage_;
        continue;
      }
      if (r.stage_ < executeStage_.GetNumOfSubStages()) {
        // At the moment, the result always flow through the pipeline regardless of
        // whether it needs to be written back
        unsigned pipeReg = IsExplicitBypass() ?
          GetFUStageContextID(r.fu_, r.stage_) : 0;
        if (pipeReg > 0) {
          ES_LOG_P(traceLevel_, trace_,
                   "  >>$("<< pipeReg <<")="<< r.value_ <<"<"<< r.stage_
                   <<"/"<< executeStage_.GetNumOfSubStages() <<">\n");
          ES_ASSERT_MSG(pipeReg < intContext_.size(),
                        "Illegal context id "<< pipeReg);
          intContext_[pipeReg] = r.value_;
        }
        if ((++r.stage_ == executeStage_.GetNumOfSubStages())
            && (r.contextID_ > 0)) {
          ES_LOG_P(traceLevel_, trace_,
                   "  >>Committing $("<< r.contextID_ <<")="<< r.value_ <<"("
                   << r.stage_ <<")"<<'\n');
          intCommitValue_.first  = r.contextID_;
          intCommitValue_.second = r.value_;
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
      ExeResultValue<UnsignedType>& r = contextResultQueue_.front();
      if (!r.Finished() || (r.stage_ < executeStage_.GetNumOfSubStages()))
        break;
      contextResultQueue_.pop_front();
    }// while (!contextResultQueue_.empty())
  }// UpdateContext()

  template<typename UnsignedType, typename SignedType>
  void SimScalarCore<UnsignedType, SignedType>::UpdateMemoryRequest() {
    unsigned memOp = 0;
    for (std::deque<SimMemoryCommand>::iterator it
           = memoryRequestQueue_.begin();it != memoryRequestQueue_.end();++it) {
      SimMemoryCommand& c = *it;
      if (c.State() == SimMemCmdState::Init) {
        if (c.Delay() > 0) { --c.Delay(); continue; }
        unsigned cAddr = c.Address();
        // This is a memory mapped object
        if ((mmapObjMask_ & cAddr) == mmapObjMask_) {
          if (!IsElementOf(cAddr, mmapObjects_)) {
            Error(GetRefTime(), SimErrorCode::InvalidMemAddr,
                  "Invalid address of mem-mapped object "+Int2DecString(cAddr)
                  +"(0x"+Int2HexString(cAddr)+", Mask=0x"
                  +Int2HexString(mmapObjMask_)+")");
            return;
          }
          unsigned mAddr= cAddr^mmapObjMask_;
          if (IsMemReadCmd(c.Type())) {
            c.Value() = mmapObjects_[cAddr]->Read(mAddr);
          } else {
            mmapObjects_[cAddr]->Write(c.Value(), mAddr);
          }
          c.State() = SimMemCmdState::Finished;
          c.Delay() = dataMemory_->GetLatency() - 1;
        } else {// if (mmapObjMask_ & cAddr)
          ++ memOp;
          c.State() = SimMemCmdState::Finished;
          c.Delay() = dataMemory_->GetLatency() - 1;
          switch (c.Type()) {
          case MemoryCommandType::Read32:
            c.Value() = (*dataMemory_)[c.Address()];
            break;
          case MemoryCommandType::Read16:
            if (sizeof(UnsignedType) == 4) {
              c.Value() = dataMemory_->ReadBE(c.Address(), c.ByteEnable());
              c.Value() = (c.ByteEnable()==0xC) ? (c.Value()>>16) : c.Value();
              c.Value() = c.Value() & 0xFFFF;
            } else if (sizeof(UnsignedType) == 2) {
              c.Value() = (*dataMemory_)[c.Address()];
            }
            break;
          case MemoryCommandType::Read16SExt:
            if (sizeof(UnsignedType) == 4) {
              c.Value() = dataMemory_->ReadBE(c.Address(), c.ByteEnable());
              c.Value() = (c.ByteEnable()==0xC) ? (c.Value()>>16) : c.Value();
              c.Value() = SignExtendNBitImm(c.Value()&0xFFFF, 16);
            } else if (sizeof(UnsignedType) == 2) {
              c.Value() = (*dataMemory_)[c.Address()];
            }
            break;
          case MemoryCommandType::Read8:
            c.Value() = dataMemory_->ReadBE(c.Address(), c.ByteEnable());
            switch (c.ByteEnable()) {
            case 0x2: c.Value() = (c.Value() >>  8); break;
            case 0x4: c.Value() = (c.Value() >> 16); break;
            case 0x8: c.Value() = (c.Value() >> 24); break;
            }
            c.Value() &= 0xFF;
            break;
          case MemoryCommandType::Read8SExt:
            c.Value() = dataMemory_->ReadBE(c.Address(), c.ByteEnable());
            switch (c.ByteEnable()) {
            case 0x2: c.Value() = (c.Value() >>  8); break;
            case 0x4: c.Value() = (c.Value() >> 16); break;
            case 0x8: c.Value() = (c.Value() >> 24); break;
            }
            c.Value() = SignExtendNBitImm(c.Value() & 0xFF, 8);
            break;
          case MemoryCommandType::Write32:
            (*dataMemory_)[c.Address()] = c.Value();
            break;
          case MemoryCommandType::Write16:
            if (sizeof(UnsignedType) == 4) {
              UnsignedType val = (c.ByteEnable() == 0xC) ? (c.Value()<<16) : c.Value();
              dataMemory_->WriteBE(c.Address(), c.ByteEnable(), val);
            } else if (sizeof(UnsignedType) == 2) {
              (*dataMemory_)[c.Address()] = c.Value();
            }
            break;
          case MemoryCommandType::Write8: {
            UnsignedType val = c.Value();
            if (sizeof(UnsignedType) == 4) {
              switch (c.ByteEnable()) {
              case 0x2: val <<=  8; break;
              case 0x4: val <<= 16; break;
              case 0x8: val <<= 24; break;
              }
            } else if (sizeof(UnsignedType) == 2) {
              val = (c.ByteEnable() == 0x2) ? (val<<8) : val;
            }
            dataMemory_->WriteBE(c.Address(), c.ByteEnable(), val);
            break;
          }
          default: break;
          }// switch (c.Type())
        }// if (mmapObjMask_ & cAddr)
        ES_LOG_P(traceLevel_, trace_, "  >>A:"<< c <<'\n');
        if (c.IsLoad()) {
          ES_LOG_P(traceLevel_, trace_, "  >>C:"<< c.Destination()
                   <<"("<< (GetMemoryStage()+1) <<")="<< c.Value() <<'\n');
          PushContextResult(ExeResultValue<UnsignedType>(
                              2, 1, GetMemoryStage(), c.Destination(), c.Value()));
        }// if (c.IsLoad())
      }// if (c.State() == SimMemCmdState::Init)
    }// for memoryRequestQueue_ iterator it
    while (!memoryRequestQueue_.empty()) {
      SimMemoryCommand& r = memoryRequestQueue_.front();
      if (!r.Finished()) { break; }
      memoryRequestQueue_.pop_front();
    }// while (!flagResultQueue_.empty())
  }// UpdateMemoryRequest()

  template<typename UnsignedType, typename SignedType>
  std::ostream& SimScalarCore<UnsignedType, SignedType>::
  PrintSimStatistics(std::ostream& o) const{
    o <<"issued="<< coreStat_.issued_<<'\n';
    o <<"branch="<< coreStat_.branches_<<'\n';
    o <<"taken_br="<< coreStat_.takenBranches_<<'\n';
    return o;
  }// PrintSimStatistics
}// namespace ES_SIMD

#endif//ES_SIMD_SIMSCALARCORE_HH
