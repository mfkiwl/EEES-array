#include "BaselineInstrFormat.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

void BaselineInstrFormat::
Initialize(bool hasBranch, unsigned predicates) {
  switch(predicates) {
  default: ES_UNREACHABLE("Predicate should be 0 or 3, "<<predicates<<" given");
  case 3:
    totalBits_ = 28;
    pred_ = make_pair(26, 27);
    break;
  case 0:
    totalBits_ = 26;
    pred_ = make_pair(-1, -1);
    break;
  }
  comm_        = make_pair(24, 25);
  opcode_      = make_pair(18, 22);
  iImm_        = make_pair( 0,  7);
  stImmH_      = make_pair(13, 17);
  stImmL_      = make_pair( 0,  2);
  dst_         = make_pair(13, 17);
  immInstrImm_ = make_pair( 0, 17);
  iTypeBit_        = 23;
  srcOperandStart_ = 12;
  regAddrBits_     = 5;
  bypassIDBits_    = 2;

  if (hasBranch) {
    jImm_    = make_pair( 0, 15);
    jOpcode_ = make_pair(16, 18);
    jReg_    = make_pair( 3,  7);
    jType_   = make_pair(19, 23);
  } else {
    jImm_    = make_pair(-1, -1);
    jOpcode_ = make_pair(-1, -1);
    jReg_    = make_pair(-1, -1);
    jType_   = make_pair(-1, -1);
  }
}// Initialize()

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD,BaselineInstrType,BASELINEINSTRTYPE_ENUM)
