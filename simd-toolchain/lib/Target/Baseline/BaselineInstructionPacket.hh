#ifndef ES_SIMD_BASELINEINSTRUCTIONPACKET_HH
#define ES_SIMD_BASELINEINSTRUCTIONPACKET_HH

#include "Target/TargetInstructionPacket.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;

  class BaselineInstructionPacket : public TargetInstructionPacket {
  public:
    BaselineInstructionPacket(const BaselineBasicInfo& ti)
      : targetInfo_(ti) {}
    const BaselineBasicInfo& GetTargetInfo() const { return targetInfo_; }
  protected:
    const BaselineBasicInfo& targetInfo_;
  };// class BaselineInstructionPacket;
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEINSTRUCTION_HH
