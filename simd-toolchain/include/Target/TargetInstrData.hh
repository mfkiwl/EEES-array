#ifndef ES_SIMD_TARGETINSTRDATA_HH
#define ES_SIMD_TARGETINSTRDATA_HH

#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"
#include <json/json.h>
#include <iostream>

namespace ES_SIMD {
  class SIRInstruction;

  class TargetInstrData : NonCopyable {
  protected:
    SIRInstruction* instr_;
    int  issueTime_;
    int  latency_;
    int  destPhyReg_;
    IntVector operandPhyReg_;
    TargetInstrData(SIRInstruction* instr);
  public:
    virtual ~TargetInstrData();

    SIRInstruction* Instruction () const { return instr_; }

    /// Timing
    int  GetLatency()  const { return latency_; }
    void SetIssueTime(int t)  { issueTime_ = t;    }
    int  GetIssueTime() const { return issueTime_; }
    /// \brief Get the distance in time to another instruction.
    ///
    /// The distance is defined as T(this)-T(instr). So if instr is scheduled
    /// after this, the distance should be negative.
    /// \note If instr is not in the same block as this one, the distance may
    ///       be undefined if there is no path between them.
    /// \param The instruction to be check.
    /// \return The distance between instr and this one. If there is no path
    ///         between, std::numeric_limits<int>::max() will be returned.
    int  GetDistance(const SIRInstruction* instr) const;

    int  GetNumOperands() const { return operandPhyReg_.size(); }
    virtual void AssignPhyRegisters() {}
    virtual void ResetOperandInfo();
    void SetDestPhyReg(int r)  { destPhyReg_ = r;    }
    int  GetDestPhyReg() const { return destPhyReg_; }
    void ResetPhyReg();
    void SetOperandPhyReg(int o, int r) { operandPhyReg_[o] = r;    }
    int  GetOperandPhyReg(int o)  const { return operandPhyReg_[o]; }

    virtual void SwapOperand(unsigned a, unsigned b);

    virtual void Print(std::ostream& o) const = 0;
    virtual bool IsTargetCopy() const;
    virtual void Dump(Json::Value& iInfo) const;
    std::string GetAsmString() const;
  };
};// namespace ES_SIMD

#endif//ES_SIMD_TARGETINSTRDATA_HH
