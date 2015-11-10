#ifndef ES_SIMD_SIMOPERATION_HH
#define ES_SIMD_SIMOPERATION_HH

#include "DataTypes/TargetOpcode.hh"
#include "Simulation/SimOperand.hh"

namespace ES_SIMD {
  class SimOperation {
  public:
    friend std::ostream& operator<<(std::ostream& o, const SimOperation& t);
    SimOperation() :exeLatency_(1), exeCount_(0), predicatedCount_(0) {}
    SimOperation(int adr) : address_(adr), exeLatency_(1), exeCount_(0) {}
    ~SimOperation() {}

    void Reset() { exeCount_ = 0; predicatedCount_ = 0; }

    SimOperation& SetAddress(unsigned i)    { address_ = i; return *this; }
    SimOperation& SetExeLatency(unsigned l) { exeLatency_ = l; return *this; }
    SimOperation& SetBinding(unsigned b)    { binding_ = b; return *this; }
    SimOperation& AppendSrcOperand(SimOperandType_t t, unsigned i) {
      srcOperand_.push_back(SimOperand(t, i));
      return *this;
    }
    SimOperation& ResizeDstOperand(unsigned n) {
      dstOperand_.resize(n);
      return *this;
    }
    SimOperation& ResizeSrcOperand(unsigned n) {
      srcOperand_.resize(n);
      return *this;
    }
    SimOperation& AppendDstOperand(SimOperandType_t t, unsigned i) {
      dstOperand_.push_back(SimOperand(t, i));
      return *this;
    }
    SimOperation& AppendPredicate(unsigned i) {
      predicates_.push_back(SimOperand(SimOperandType::Flag, i));
      return *this;
    }
    SimOperation& SetOpcode(TargetOpcode_t o) {
      opcodes_.clear();
      opcodes_.push_back(o);
      return *this;
    }
    SimOperation& AppendOpcode(TargetOpcode_t o) {
      opcodes_.push_back(o);
      return *this;
    }

    unsigned GetAddress()    const { return address_;    }
    unsigned GetExeLatency() const { return exeLatency_; }
    unsigned GetBinding()    const { return binding_;    }

    SimOperand&       GetPredicate(unsigned i)       { return predicates_[i]; }
    const SimOperand& GetPredicate(unsigned i) const { return predicates_[i]; }

    SimOperand&       GetSrcOperand(unsigned i)       { return srcOperand_[i]; }
    const SimOperand& GetSrcOperand(unsigned i) const { return srcOperand_[i]; }

    SimOperand&       GetDstOperand(unsigned i)       { return dstOperand_[i]; }
    const SimOperand& GetDstOperand(unsigned i) const { return dstOperand_[i]; }

    TargetOpcode_t GetFirstOpcode() const {
      return opcodes_.empty() ? TargetOpcode::NOP : opcodes_[0];
    }
    size_t GetNumOpcode() const { return opcodes_.size(); }
    TargetOpcode_t GetOpcode(unsigned i) const { return opcodes_[i]; }
    unsigned GetNumDstOperands() const { return dstOperand_.size(); }
    unsigned GetNumSrcOperands() const { return srcOperand_.size(); }
    unsigned GetNumPredicates()  const { return predicates_.size(); }
    bool IsNOP() const {
      return opcodes_.empty()
        || ((opcodes_.size()==1) && (opcodes_[0] == TargetOpcode::NOP));
    }

    unsigned GetExeCount()   const { return exeCount_;   }
    void     IncExeCount()   const { ++ exeCount_;       }
    void  IncPredCount(unsigned m) const { predicatedCount_ += m;   }
    uint64_t        GetPredCount() const { return predicatedCount_; }
  private:
    unsigned address_;
    std::vector<TargetOpcode_t> opcodes_;
    std::vector<SimOperand> predicates_;
    std::vector<SimOperand> srcOperand_;
    std::vector<SimOperand> dstOperand_;
    unsigned exeLatency_;
    unsigned binding_;
    mutable unsigned exeCount_;        ///< Number of execution.
    mutable uint64_t predicatedCount_; ///< Number of predicated operations.
  };// class SimOperation
}// namespace ES_SIMD

#endif//ES_SIMD_SIMOPERATION_HH
