#ifndef ES_SIMD_SIMDEFS_HH
#define ES_SIMD_SIMDEFS_HH

#include "DataTypes/BasicTypes.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/EnumFactory.hh"

#define SIMERRORCODE_ENUM(DEF, DEFV) \
  DEF(Timeout)                       \
  DEF(InvalidConfig)                 \
  DEF(InvalidInitialization)         \
  DEF(InvalidInstrAddr)              \
  DEF(UndefinedInstr)                \
  DEF(InvalidRegID)                  \
  DEF(InvalidInstruction)            \
  DEF(InvalidMemAddr)                \
  DEF(InvalidInPort)                 \
  DEF(InvalidOutPort)                \
  DEF(InvalidOpcode)                 \
  DEF(UninitMemRead)                 \
  DEF(IllegalOperand)                \
  DEF(IllegalCommunication)          \
  DEF(RFWritePortConflict)           \
  DEF(RFReadPortConflict)            \
  DEF(InvalidMemPortAccess)          \
  DEF(UnsupportedOperation)

namespace ES_SIMD {
  static const unsigned RESET_VALUE   = 0xCCCCCCCC;
  static const unsigned UNINIT_VALUE  = 0xCCCCCCCC;
  static const unsigned PROGRAM_ENTRY = 0;

  DECLARE_ENUM(SimErrorCode, SIMERRORCODE_ENUM)

  class SimObjectBase;

  class SimulationError {
  public:
    SimulationError(uint64_t t, const SimObjectBase* obj, SimErrorCode_t e,
                    const std::string& m)
      : timeStamp_(t), obj_(obj), code_(e), msg_(m) {}
    unsigned GetTimeStamp() const { return timeStamp_; }
    const SimObjectBase* GetErrorObject() const { return obj_; }
    SimErrorCode_t GetErrorCode() const { return code_; }
    const std::string& GetMessage() const { return msg_; }
    friend std::ostream& operator<<(
      std::ostream& out, const SimulationError &t);
  private:
    uint64_t timeStamp_;
    const SimObjectBase* obj_;
    SimErrorCode_t code_;
    std::string msg_;
  };// class SimulationError

  template <typename T>
  struct ExeResultValue {
    unsigned fu_;
    unsigned stage_;
    unsigned delay_;
    unsigned contextID_;
    T value_;
    ExeResultValue() {}
    ExeResultValue(unsigned fu, unsigned lat, unsigned stage, unsigned cid,
                   T value)
      :fu_(fu), stage_(stage), delay_(lat), contextID_(cid), value_(value) {}
    bool Finished() const { return delay_ == 0; }
  };// struct ExeResultValue

  template <typename T>
  struct ExeVectorResultValue {
    unsigned fu_;
    unsigned stage_;
    unsigned delay_;
    unsigned contextID_;
    std::vector<T> value_;
    BitVector      predicate_;
    ExeVectorResultValue() {}
    ExeVectorResultValue(unsigned fu, unsigned lat, unsigned stage, unsigned r,
                         const std::vector<T>& value,const BitVector& predicate)
      :fu_(fu), stage_(stage), delay_(lat), contextID_(r),
       value_(value), predicate_(predicate) {}
    bool Finished() const { return delay_ == 0; }
  };// struct ExeResultValue

  struct FlagVectorResult {
    unsigned delay_;
    unsigned flagID_;
    BitVector value_;
    BitVector predicate_;
    FlagVectorResult() {}
    FlagVectorResult(unsigned d, unsigned f, const BitVector& val,
                     const BitVector& predicate)
      : delay_(d), flagID_(f), value_(val), predicate_(predicate) {}
  };// struct FlagVectorResult
}// namespace ES_SIMD

#endif//ES_SIMD_SIMDEFS_HH
