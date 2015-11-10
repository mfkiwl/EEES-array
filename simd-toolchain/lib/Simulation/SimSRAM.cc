#include "Simulation/SimSRAM.hh"

using namespace std;
using namespace ES_SIMD;

const uint32_t SimSRAMBase::ByteMask[16] = {
  0x00000000, 0x000000FF, 0x0000FF00, 0x0000FFFF,
  0x00FF0000, 0x00FF00FF, 0x00FFFF00, 0x00FFFFFF,
  0xFF000000, 0xFF0000FF, 0xFF00FF00, 0xFF00FFFF,
  0xFFFF0000, 0xFFFF00FF, 0xFFFFFF00, 0xFFFFFFFF,
};

SimSRAMBase::~SimSRAMBase() {}
