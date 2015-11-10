#ifndef ES_SIMD_DBGUTILS_HH
#define ES_SIMD_DBGUTILS_HH

#include <iostream>
#include <assert.h>
#include <stdlib.h>

namespace ES_SIMD {
  void PrintStackTrace();
}

#ifndef NDEBUG
#define ES_UNREACHABLE(msg) do {                                \
    std::cerr << "Internal Error: unreachable point at line "   \
              <<__LINE__<< " in " <<__FILE__<< std::endl        \
              << "Message: " << msg << std::endl;               \
    PrintStackTrace();                                          \
    abort();                                                    \
  } while(0)
#else
#define ES_UNREACHABLE(msg) do {                    \
    std::cerr << "Internal Error, terminating.\n "  \
              << "Message: " << msg << std::endl;   \
    PrintStackTrace();                              \
    abort();                                        \
  } while (0)
#endif

#ifndef NDEBUG
#define ES_NOTSUPPORTED(msg) do {                                   \
    std::cerr << "Internal Error: not supported feature at line "   \
              <<__LINE__<< " in " << __FILE__<< std::endl           \
              << "Message: " << msg << std::endl;                   \
    abort();                                                        \
  } while(0)
#else
#define ES_NOTSUPPORTED(msg) do {                               \
    std::cerr << "Internal Error: not supported feature."       \
              << std::endl << "Message: " << msg << std::endl;  \
    abort();                                                    \
  } while(0)
#endif

#ifndef NDEBUG
#define ES_ASSERT_MSG(cond, msg) do {                       \
    if (!(cond)) {                                          \
      std::cerr << "Assertion failed: at line " <<__LINE__  \
                << " in " <<__FILE__<< std::endl            \
                << "Message: " << msg << std::endl;         \
      PrintStackTrace();                                    \
      abort();                                              \
    }                                                       \
  } while(0)
#else
#define ES_ASSERT_MSG(cond, msg)
#endif

#ifndef NDEBUG
#define ES_ASSERT(cond) do {                                \
    if (!(cond)) {                                          \
      std::cerr << "Assertion failed: at line " <<__LINE__  \
                << " in " <<__FILE__<< std::endl;           \
      PrintStackTrace();                                    \
      abort();                                              \
    }                                                       \
  } while(0)
#else
#define ES_ASSERT(cond)
#endif

#ifndef NDEBUG
#define ES_CHECKPOINT(chk, msg) do {                        \
    if (!(chk)) {                                           \
      std::cerr << "Checkpoint failed: at line " <<__LINE__ \
                << " in " <<__FILE__<< std::endl            \
                << "Message: " << msg << std::endl;         \
      PrintStackTrace();                                    \
      abort();                                              \
    }                                                       \
  } while(0)
#else
#define ES_CHECKPOINT(cond, msg)
#endif

#define ES_NOTIMPLEMENTED(msg) do {                                     \
    std::cerr << "Oops, feature not implemented yet: "<< msg<<" (line " \
              <<__LINE__<< " in " <<__FILE__<<")"<< std::endl;          \
    abort();                                                            \
  } while(0)

#endif//ES_SIMD_DBGUTILS_HH
