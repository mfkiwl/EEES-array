#ifndef ES_SIMD_CMDUTILS_HH
#define ES_SIMD_CMDUTILS_HH

#include "Version.hh"
#include <iostream>

namespace ES_SIMD {
  void PrintVersionInfo(std::ostream& out);
  void PrintToolVersion(std::ostream& out, const char* toolName,
                        const char* desc);
}// namespace ES_SIMD

#endif//ES_SIMD_CMDUTILS_HH
