#ifndef ES_SIMD_TARGETOPERAND_HH
#define ES_SIMD_TARGETOPERAND_HH

#include "DataTypes/EnumFactory.hh"

#define TARGETOPERANDTYPE_ENUM(DEF, DEFV)          \
  DEF(Register)                                    \
  DEF(Predicate)                                   \
  DEF(Bypass)                                      \
  DEF(Communication)                               \
  DEF(IntImmediate)                                \
  DEF(Label)

#define TARGETSYMBOLTYPE_ENUM(DEF, DEFV)    \
  DEF(Code)                                 \
  DEF(Data)

namespace ES_SIMD {
    DECLARE_ENUM(TargetOperandType, TARGETOPERANDTYPE_ENUM)
    DECLARE_ENUM(TargetSymbolType, TARGETSYMBOLTYPE_ENUM)

    struct TargetOperand {
      TargetOperandType_t type_;
      /// For register, predicate, bypass and communication, value_ is the id.
      /// For immediate, value_ stores the actual value
      /// For label, value_ stores the unique idendifier of the label.
      int value_;
      int GetValue() const { return value_; }
      TargetOperandType_t GetType() const { return type_; }
      TargetOperand() : type_(TargetOperandType::TargetOperandTypeEnd),
                        value_(-1) {}
      TargetOperand(TargetOperandType_t t, int v) : type_(t), value_(v) {}
      bool ValidDestination() {
        return (type_ == TargetOperandType::Register)
          || (type_ == TargetOperandType::Bypass);
      }
    };// struct TargetOperand

    struct TargetSymbol {
      TargetSymbolType_t type_;
      int id_;
      std::string value_;
      int address_;
      TargetSymbol() : type_(TargetSymbolType::TargetSymbolTypeEnd),
                       id_(-1), address_(-1) {}
      TargetSymbol(
        const std::string& v, int i,
        TargetSymbolType_t t = TargetSymbolType::TargetSymbolTypeEnd,int adr=-1)
        : type_(t), id_(i), value_(v), address_(adr) {}
    };//struct TargetSymbol
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETOPERAND_HH
