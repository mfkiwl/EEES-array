#ifndef ES_SIMD_BASELINEINSTRFORMAT_HH
#define ES_SIMD_BASELINEINSTRFORMAT_HH

#include <utility>
#include "DataTypes/EnumFactory.hh"

#define BASELINEINSTRTYPE_ENUM(DEF, DEFV)       \
  DEF(RType)                                    \
  DEF(IType)                                    \
  DEF(JReg)                                     \
  DEF(JImm)                                     \
  DEF(Misc)                                     \
  DEF(Special)                                  \
  DEF(NOP)

namespace ES_SIMD {
  DECLARE_ENUM(BaselineInstrType, BASELINEINSTRTYPE_ENUM)

  struct BaselineInstrFormat {
    int totalBits_;
    std::pair<int, int> pred_;
    std::pair<int, int> comm_;
    std::pair<int, int> opcode_;
    std::pair<int, int> jOpcode_;
    std::pair<int, int> iImm_;
    std::pair<int, int> stImmH_;
    std::pair<int, int> stImmL_;
    std::pair<int, int> jImm_;
    std::pair<int, int> dst_;
    std::pair<int, int> jReg_;
    std::pair<int, int> jType_;
    std::pair<int, int> immInstrImm_;
    int iTypeBit_;
    int srcOperandStart_;
    int regAddrBits_;
    int bypassIDBits_;
    void Initialize(bool hasBranch, unsigned predicates);
    int  GetTotalBits() const { return totalBits_; }
  };// struct BaselineInstrFormat
}// namespace ES_TTA

#endif//ES_SIMD_BASELINEINSTRFORMAT_HH
