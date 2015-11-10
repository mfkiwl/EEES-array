#ifndef ES_SIMD_SIMOPERAND_HH
#define ES_SIMD_SIMOPERAND_HH

#define SIMOPERANDTYPE_ENUM(DEF, DEFV)       \
  DEF(ContextValue)                          \
  DEF(IntImmediate)                          \
  DEF(Communication)                         \
  DEF(Flag)

namespace ES_SIMD {
  DECLARE_ENUM(SimOperandType,SIMOPERANDTYPE_ENUM)

  class SimOperand {
  public:
    friend std::ostream& operator<<(std::ostream& o, const SimOperand& t);
    SimOperand(SimOperandType_t t, unsigned i) : type_(t), value_(i) {}
    SimOperand() : type_(SimOperandType::SimOperandTypeEnd) {}
    SimOperandType_t GetType() const { return type_; }
    unsigned GetID() const { return value_; }
    unsigned GetUIntValue() const { return value_; }
    int GetIntValue() const { return static_cast<int>(value_); }
    bool operator==(const SimOperand& t) const {
      return (type_ == t.type_) && (value_ == t.value_);
    }
  private:
    SimOperandType_t type_;
    unsigned value_;
  };// class SimOperand
}// namespace ES_SIMD

#endif//ES_SIMD_SIMOPERAND_HH
