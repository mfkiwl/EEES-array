#ifndef ES_SIMD_BASELINEINSTRUCTION_HH
#define ES_SIMD_BASELINEINSTRUCTION_HH

#include "Target/TargetInstruction.hh"

namespace ES_SIMD {
  class BaselineInstructionPacket;

  class BaselineInstruction : public TargetInstruction {
  public:
    BaselineInstruction(BaselineInstructionPacket& p, bool isPE);
    virtual bool Valid() const;
    virtual std::ostream& Print(std::ostream& out) const;
    virtual std::ostream& PrintASM(std::ostream& out,
                                   const Int2StrMap& syms) const;
  };// class BaselineInstruction;
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEINSTRUCTION_HH
