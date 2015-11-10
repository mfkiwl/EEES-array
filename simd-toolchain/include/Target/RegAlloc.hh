#ifndef ES_SIMD_REGALLOC_HH
#define ES_SIMD_REGALLOC_HH

#include "Target/TargetLiveInterval.hh"
#include "DataTypes/ContainerTypes.hh"

namespace ES_SIMD {
  class SIRBasicBlock;

  int CreateBlockLiveIntervals (
    const SIRBasicBlock* bb, BlockLiveInterval& blockLiveInterval,
    std::tr1::unordered_map<int, float>& costMap);
};// namespace ES_SIMD

#endif//ES_SIMD_REGALLOC_HH
