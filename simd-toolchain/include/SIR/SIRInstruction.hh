#ifndef ES_SIMD_SIRINSTRUCTION_HH
#define ES_SIMD_SIRINSTRUCTION_HH

#include "SIR/SIRValue.hh"
#include "DataTypes/SIROpcode.hh"
#include "DataTypes/TargetOpcode.hh"
#include "DataTypes/FileLocation.hh"

namespace ES_SIMD {
  class SIRFunction;
  class SIRBasicBlock;
  class SIRRegister;
  class TargetInstrData;
  class SIRMemLocation;

  /// \brief Class for instructions in SIR.
  ///
  /// An SIR instruction should belong to exactly one SIR basic block.
  class SIRInstruction : public SIRValue {
  public:
    typedef std::vector<SIRValue*>::iterator       operand_iterator;
    typedef std::vector<SIRValue*>::const_iterator operand_const_iterator;
    typedef std::vector<SIRValue*>::reverse_iterator operand_reverse_iterator;

    friend class SIRParser;
    enum InstrType { IT_Scalar, IT_Vector };
  private:
    SIRBasicBlock* parent_;
    unsigned opcode_;
    std::vector<SIRValue*> operands_;
    std::vector<SIRValue*> predicates_;
    FileLocation fileLoc_;
    InstrType type_;
    unsigned memoryLoacation_;
    TargetInstrData* targetData_;
    SIRMemLocation* memLocationInfo_;
  public:
    SIRInstruction(SIROpcode_t opcode, SIRBasicBlock* bb, bool isKernel);
    SIRInstruction(TargetOpcode_t opcode, SIRBasicBlock* bb, bool isKernel);
    SIRInstruction(unsigned opcode, SIRBasicBlock* bb, bool isKernel);
    virtual ~SIRInstruction();

    void SetParent(SIRBasicBlock* bb) { parent_ = bb; }
    SIRBasicBlock* GetParent() const { return parent_; }
    void SetTargetData(TargetInstrData* idata)   { targetData_ = idata; }
    TargetInstrData* GetTargetData() const { return targetData_;  }

    void SetMemLocationInfo(SIRMemLocation* mLoc) { memLocationInfo_ = mLoc; }
    SIRMemLocation* GetMemLocationInfo() const    { return memLocationInfo_; }

    SIRFunction* GetCallTarget() const;
    SIRValue*    GetBranchTarget() const;

    void SetInstrType(InstrType t) { type_ = t; }
    void SetTargetOpcode(TargetOpcode_t tOp) {
        opcode_ = static_cast<unsigned>(tOp);
    }
    SIROpcode_t GetSIROpcode()    const {
      return (opcode_ < SIROpcode::SIROpcodeEnd) ?
        static_cast<SIROpcode_t>(opcode_) : SIROpcode::SIROpcodeEnd;
    }
    TargetOpcode_t GetTargetOpcode()    const {
      return !IsValidTargetOpcode(opcode_) ? TargetOpcode::TargetOpcodeEnd
        : static_cast<TargetOpcode_t>(opcode_);
    }
    unsigned GetOpcode() const { return opcode_; }
    const FileLocation& GetFileLocation() const { return fileLoc_; }
    void SetMemoryLocationID(unsigned i) { memoryLoacation_ = i; }
    unsigned GetMemoryLocationID() const { return memoryLoacation_; }

    bool HasFileLocation() const { return !fileLoc_.fileName_.empty(); }

    bool IsNOP() const {
      return (opcode_ == SIROpcode::NOP) || (opcode_ == TargetOpcode::NOP);
    }
    bool IsVectorInstr() const { return type_ == IT_Vector; }
    bool IsBroadcasting() const;
    bool HasSIROpcode() const { return opcode_ < SIROpcode::SIROpcodeEnd; }
    bool HasTargetOpcode() const {
      return (opcode_ > SIROpcode::SIROpcodeEnd)
        && (opcode_ < TargetOpcode::TargetOpcodeEnd);
    }
    bool UsesValue(const SIRValue* v) const;
    bool UsesValue(int v) const;

    int UsedFlag() const;
    int DefinedFlag() const;

    // Operand interface
    SIRInstruction& AddOperand(SIRValue* op) {
      operands_.push_back(op);
      op->AddUse(this);
      return *this;
    }
    void RemoveOperand(unsigned i);
    void ChangeOperand(operand_iterator it, SIRValue* op) {
      SIRValue* oldOp = *it;
      *it = op;
      if (op != NULL) { op->AddUse(this); }
      if (oldOp) {
        for (int i = 0, e = operands_.size(); i < e; ++i) {
          if (operands_[i] == oldOp) { return; }
        }
        // oldOp is no longer used by this, remove this from its use list
        oldOp->RemoveUse(this);
      }// if (oldOp)
    }

    void ChangeOperand(unsigned i, SIRValue* op) {
      if (i > operands_.size()) { return; }
      SIRValue* oldOp = operands_[i];
      operands_[i] = op;
      if (op != NULL) { op->AddUse(this); }
      if (oldOp) {
        for (int i = 0, e = operands_.size(); i < e; ++i) {
          if (operands_[i] == oldOp) { return; }
        }
        // oldOp is no longer used by this, remove this from its use list
        oldOp->RemoveUse(this);
      }
    }

    void ReplaceOperand(SIRValue* oldOp, SIRValue* newOp) {
      int oid = oldOp->GetUID();
      bool c = false;
      for (int i = 0, e = operands_.size(); i < e; ++i) {
        if (oid == operands_[i]->GetUID()) { operands_[i] = newOp; c = true; }
      }
      if (c) {
        oldOp->RemoveUse(this);
        if (newOp) { newOp->AddUse(this); }
      }
    }
    SIRValue* GetOperand(unsigned i) const {
      return (i < operands_.size()) ? operands_[i] : NULL;
    }

    // Predicate interface
    bool PredicatedBy(const SIRValue* v) const;
    bool UsedAsPredicate() const;
    bool HasPredicate() const { return !predicates_.empty(); }
    SIRValue* GetPredicate(unsigned i) const {
      return (i < predicates_.size()) ? predicates_[i] : NULL;
    }
    /// \brief Whethe another instruction has exactly the same predicate
    bool PredicateValueEqual(const SIRInstruction* instr) const;
    void AddPredicate(SIRValue* p);
    size_t predicate_size() const { return predicates_.size(); }

    virtual std::ostream& Print(std::ostream& o) const;
    virtual std::ostream& SIRPrettyPrint(std::ostream& o) const;
    virtual std::ostream& TargetPrettyPrint(std::ostream& o) const;
    virtual std::ostream& ValuePrint(std::ostream& o) const;
    virtual std::ostream& PrintValueTree(
      std::ostream& o, const std::string& p) const;
    virtual void Dump(Json::Value& info) const;

    // For LLVM-style RTTI
    static bool classof(const SIRValue *v) {
      return v->getKind() == VK_Instruction;
    }
    // Container interface and iterators
    bool   operand_empty() const { return operands_.empty(); }
    size_t operand_size()  const { return operands_.size();  }
    operand_iterator       operand_begin()       { return operands_.begin(); }
    operand_const_iterator operand_begin() const { return operands_.begin(); }
    operand_iterator       operand_end()         { return operands_.end();   }
    operand_const_iterator operand_end()   const { return operands_.end();   }
    operand_reverse_iterator operand_rbegin()    { return operands_.rbegin();}
    operand_reverse_iterator operand_rend()      { return operands_.rend();  }
  };// class SIRInstruction
}// namespace ES_SIMD

#endif//ES_SIMD_SIRINSTRUCTION_HH
