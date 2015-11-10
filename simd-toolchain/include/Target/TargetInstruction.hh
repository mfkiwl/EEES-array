#ifndef ES_SIMD_TARGETINSTRUCTION_HH
#define ES_SIMD_TARGETINSTRUCTION_HH

#include <string>
#include <vector>
#include "DataTypes/Object.hh"
#include "DataTypes/EnumFactory.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/TargetOpcode.hh"
#include "Target/TargetOperand.hh"

#define TARGETINSTRTYPE_ENUM(DEF, DEFV)         \
  DEF(Scalar)                                   \
  DEF(Vector)

namespace ES_SIMD {
  DECLARE_ENUM(TargetInstrType, TARGETINSTRTYPE_ENUM)

  class TargetInstructionPacket;

  class TargetInstruction : NonCopyable {
  private:
    TargetInstructionPacket& parent_;
    int id_;
    TargetInstrType_t type_;
    TargetOpcode_t opcode_;
    std::vector<TargetOperand> srcOperands_;
    std::vector<TargetOperand> dstOperands_;
    std::vector<TargetOperand> predicates_;
  public:
    typedef std::vector<TargetOperand>::iterator       pred_iterator;
    typedef std::vector<TargetOperand>::const_iterator pred_const_iterator;

    TargetInstruction(TargetInstructionPacket& p, bool isVec = false)
      :parent_(p), id_(-1),
       type_(isVec ? TargetInstrType::Vector : TargetInstrType::Scalar){}
    virtual ~TargetInstruction();

    /// Getters and Setters
    TargetInstruction& SetIndex(int idx)     { id_ = idx; return *this; }
    int  GetIndex()  const { return id_; }
    TargetInstruction& SetOpcode(TargetOpcode_t opc) {
      opcode_ = opc;
      return *this;
    }
    TargetOpcode_t GetOpcode()  const { return opcode_; }
    TargetInstrType_t GetType() const { return type_; }
    TargetInstructionPacket& GetParent() { return parent_; }
    const TargetInstructionPacket& GetParent() const { return parent_; }

    TargetInstruction& AppendOperand(TargetOperandType_t t, int v) {
      return AppendOperand(TargetOperand(t, v));
    }
    TargetInstruction& AppendOperand(TargetOperand o);
    TargetInstruction& AppendPredicate(TargetOperand o) {
      predicates_.push_back(o);
      return *this;
    }
    TargetInstruction& AppendPredicate(int p) {
      predicates_.push_back(TargetOperand(TargetOperandType::Predicate, p));
      return *this;
    }
    unsigned GetNumSrcOperands() const {
      return srcOperands_.size();
    }
    TargetOperand& GetSrcOperand(unsigned i) {
      return srcOperands_[i];
    }
    const TargetOperand& GetSrcOperand(unsigned i) const {
      return srcOperands_[i];
    }
    TargetOperand&       GetPredicate(unsigned i)       {return predicates_[i];}
    const TargetOperand& GetPredicate(unsigned i) const {return predicates_[i];}
    unsigned GetNumDstOperands() const {
      return dstOperands_.size();
    }
    TargetOperand& GetDstOperand(unsigned i) {
      return dstOperands_[i];
    }
    const TargetOperand& GetDstOperand(unsigned i) const {
      return dstOperands_[i];
    }

    virtual bool Valid() const;
    /// Helpers
    virtual std::ostream& Print(std::ostream& out) const;
    virtual std::ostream& PrintASM(std::ostream& out,
                                   const Int2StrMap& syms) const;
    bool IsScalarInstr() const { return type_ == TargetInstrType::Scalar; }
    bool IsVectorInstr() const { return type_ == TargetInstrType::Vector; }
    bool Predicated()    const { return !predicates_.empty(); }

    bool   pred_empty() const { return predicates_.empty(); }
    size_t pred_size()  const { return predicates_.size();  }
    pred_iterator       pred_begin()       { return predicates_.begin(); }
    pred_iterator       pred_end()         { return predicates_.end();   }
    pred_const_iterator pred_begin() const { return predicates_.begin(); }
    pred_const_iterator pred_end()   const { return predicates_.end();   }
  };// class TargetInstruction
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETINSTRUCTION_HH
