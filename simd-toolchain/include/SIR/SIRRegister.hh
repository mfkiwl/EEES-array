#ifndef ES_SIMD_SIRREGISTER_HH
#define ES_SIMD_SIRREGISTER_HH

#include "SIR/SIRValue.hh"

namespace ES_SIMD {
  class SIRFunction;

  class SIRRegister : public SIRValue {
    friend class SIRParser;
  private:
    SIRValue* parent_;
    bool isVector_;
    int  regClass_;
  public:
    SIRRegister(bool vector, const std::string& name, SIRValue* parent)
      : SIRValue(name, SIRValue::VK_Register), parent_(parent),
        isVector_(vector), regClass_(vector ? 1 : 0) {}
    SIRRegister(bool vector, const std::string& name, int vid,
                SIRValue* parent)
      : SIRValue(name, SIRValue::VK_Register), parent_(parent)
      , isVector_(vector) {
      valueID_ = vid;
    }
    virtual ~SIRRegister();

    SIRValue* GetParent() const { return parent_; }
    virtual std::ostream& Print(std::ostream& o) const;
    virtual std::ostream& ValuePrint(std::ostream& o) const;
    std::ostream& PrintValueTree(std::ostream& o, const std::string& p) const;

    bool IsVector()    const { return isVector_; }
    void SetValueType(int v) { isVector_ = v;   }
    void SetRegClass(int rc) { regClass_ = rc;  }
    int  GetRegClass() const { return regClass_;}

    // For LLVM-style RTTI
    static bool classof(const SIRValue *v) {
      return v->getKind() == VK_Register;
    }
  };// class SIRRegister
}// namespace ES_SIMD

#endif//ES_SIMD_SIRREGISTER_HH
