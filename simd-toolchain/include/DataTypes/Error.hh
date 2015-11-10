#ifndef ES_SIMD_ERROR_HH
#define ES_SIMD_ERROR_HH

#include "DataTypes/FileLocation.hh"
#include "DataTypes/EnumFactory.hh"
#include <iostream>

#define ERRORCODE_ENUM(DEF, DEFV) \
  DEFV(Normal, 0)                     \
  DEF(FileIOError)                    \
  DEF(TargetInitError)                \
  DEF(IRParserError)                  \
  DEF(IRParserErrorBegin)             \
  DEF(IRUnknownTokenType)             \
  DEF(IRTypeError)                    \
  DEF(IRSyntaxError)                  \
  DEF(IRUninitFunction)               \
  DEF(IRUninitBasicBlock)             \
  DEF(IRInvalidOpcode)                \
  DEF(IRUndefinedSymbol)              \
  DEF(IRRedefinedSymbol)              \
  DEF(IRIllegalOperand)               \
  DEF(IRIllegalSymbol)                \
  DEF(IRMissingOutput)                \
  DEF(IRMissingInput)                 \
  DEF(IRParserErrorEnd)               \
  DEF(CodeGenError)                   \
  DEF(CodeGenErrorBegin)              \
  DEF(SIRTranslationFailure)          \
  DEF(DDGInitFailure)                 \
  DEF(DDGSchedFailure)                \
  DEF(LinkingFailure)                 \
  DEF(DataNotFit)                     \
  DEF(InstrTimingErr)                 \
  DEF(CodeGenErrorEnd)                \
  DEF(InternalError)

namespace ES_SIMD {
  DECLARE_ENUM(ErrorCode, ERRORCODE_ENUM)

  /// \brief A generic class for code generator error.
  class Error {
    friend std::ostream& operator<<(std::ostream& o, const Error& e);
    ErrorCode_t errorCode_;            ///< Error code.
    std::string            msg_;       ///< Custom message.
    FileLocation           fLoc_;      ///< File location info.
  public:
    Error(ErrorCode_t ec, const std::string& msg) : errorCode_(ec), msg_(msg) {}
    Error(ErrorCode_t ec, const std::string& m, const std::string& file, int ln)
      : errorCode_(ec), msg_(m), fLoc_(file, ln) {}
    Error(ErrorCode_t ec, const std::string& msg, const FileLocation& fLoc)
      : errorCode_(ec), msg_(msg), fLoc_(fLoc) {}
    ~Error() {}

    void Print(std::ostream& o) const;
  };// class ErrorBase
}// namespace ES_SIMD

#endif//ES_SIMD_ERROR_HH
