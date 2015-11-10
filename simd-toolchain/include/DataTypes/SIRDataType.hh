#ifndef ES_SIMD_SIRDATATYPE_HH
#define ES_SIMD_SIRDATATYPE_HH

#include "DataTypes/EnumFactory.hh"

#define SIRDATATYPE_ENUM(DEF, DEFV)                           \
  DEF(Int8)  DEF(Int16)   DEF(Int32)                          \
  DEF(GenericVInt8)  DEF(GenericVInt16)  DEF(GenericVInt32)   \
  DEF(ASCIIStr)                                               \
  DEF(BasicBlock) DEF(Function)                               \
  DEF(DataObject) DEF(VDataObject)                            \
  DEF(Void) DEF(VVoid) DEF(Unknown)

namespace ES_SIMD {
  DECLARE_ENUM(SIRDataType, SIRDATATYPE_ENUM)
}

#endif//ES_SIMD_SIRDATATYPE_HH
