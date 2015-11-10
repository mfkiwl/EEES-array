#ifndef ES_SIMD_SIRCONSTANT_HH
#define ES_SIMD_SIRCONSTANT_HH

#include "SIR/SIRValue.hh"

namespace ES_SIMD {
  class SIRModule;

  /// \brief A class that represents a single constant value.
  class SIRConstant : public SIRValue {
  public:
    enum ConstantType_t {
      Symbol, Immediate, StackIndex, SpillSlot, Unknown, ConstantEnd
    };
    static bool GetImmediate(const SIRValue* op, int& imm);
  private:
    SIRModule* parent_;
    ConstantType_t type_;
    int immediate_;
    std::string symbol_;
  public:
    SIRConstant(int imm, SIRModule* module)
      : SIRValue(SIRValue::VK_Constant), parent_(module), type_(Immediate),
        immediate_(imm) {}

    SIRConstant(const std::string& sym, SIRModule* module)
      : SIRValue(SIRValue::VK_Constant), parent_(module), type_(Symbol),
        symbol_(sym) {}
    virtual ~SIRConstant();

    SIRModule* GetParent() const { return parent_; }

    bool IsSymbol()    const { return type_ == Symbol;    }
    bool IsImmediate() const { return type_ == Immediate; }
    
    int GetImmediate() const { return immediate_; }
    const std::string& GetSymbol() const { return symbol_; }

    virtual bool EqualsTo(const SIRValue* v) const;
    virtual std::ostream& Print(std::ostream& o) const;
    virtual std::ostream& ValuePrint(std::ostream& o) const;
    std::ostream& PrintValueTree(std::ostream& o, const std::string& p) const;

    // For LLVM-style RTTI
    static bool classof(const SIRValue *v) {
      return v->getKind() == VK_Constant;
    }
  };// class SIRConstant
}// namespace ES_SIMD

#endif//ES_SIMD_SIRCONSTANT_HH
