#ifndef ES_SIMD_SIMMEMORYCMD_HH
#define ES_SIMD_SIMMEMORYCMD_HH

#include "DataTypes/EnumFactory.hh"
#include "Simulation/SimObjectBase.hh"

#define MEMORYCOMMANDTYPE_ENUM(DEF, DEFV)  \
  DEF(Read8)                               \
  DEF(Read8SExt)                           \
  DEF(Read16)                              \
  DEF(Read16SExt)                          \
  DEF(Read32)                              \
  DEF(Write8)                              \
  DEF(Write16)                             \
  DEF(Write32)

#define SIMMEMCMDSTATE_ENUM(DEF, DEFV)     \
  DEF(Init)                                \
  DEF(WaitingMem)                          \
  DEF(Finished)

namespace ES_SIMD {

  DECLARE_ENUM(MemoryCommandType,MEMORYCOMMANDTYPE_ENUM)
  DECLARE_ENUM(SimMemCmdState,SIMMEMCMDSTATE_ENUM)

  static inline bool IsMemReadCmd(MemoryCommandType_t t) {
    return (t>= MemoryCommandType::Read8) && (t <= MemoryCommandType::Read32);
  }
  static inline bool IsMemWriteCmd(MemoryCommandType_t t) {
    return (t>= MemoryCommandType::Write8) && (t <= MemoryCommandType::Write32);
  }
  class SimMemoryCommand {
  public:
    friend std::ostream& operator<<(std::ostream& o, const SimMemoryCommand& t);
    SimMemoryCommand()
      : type_(MemoryCommandType::MemoryCommandTypeEnd),
        address_(0), byteEnable_(0xF), dest_(0), delay_(0),
        value_(0), state_(SimMemCmdState::Init) {}
    SimMemoryCommand(MemoryCommandType_t type, unsigned addr, unsigned delay)
      : type_(type),address_(addr), byteEnable_(0xF), delay_(delay),
        value_(0), state_(SimMemCmdState::Init) {}
    SimMemoryCommand(MemoryCommandType_t type, unsigned addr, uint32_t value,
                     unsigned delay)
      : type_(type), address_(addr), byteEnable_(0xF), dest_(0), delay_(delay),
        value_(value), state_(SimMemCmdState::Init) {}
    ~SimMemoryCommand() {}

    bool IsLoad() const {
      return (type_ >= MemoryCommandType::Read8)
        && (type_ <= MemoryCommandType::Read32);
    }
    MemoryCommandType_t& Type() { return type_; }
    const MemoryCommandType_t& Type() const { return type_; }
    unsigned& Address() { return address_; }
    const unsigned& Address() const { return address_; }
    unsigned& ByteEnable() { return byteEnable_; }
    const unsigned& ByteEnable() const { return byteEnable_; }
    unsigned& Delay() { return delay_; }
    const unsigned& Delay() const { return delay_; }
    unsigned& Destination() { return dest_; }
    const unsigned& Destination() const { return dest_; }
    uint32_t& Value() { return value_; }
    const uint32_t& Value() const { return value_; }
    SimMemCmdState_t& State() { return state_; }
    const SimMemCmdState_t& State() const { return state_; }
    bool Finished() const { return state_ == SimMemCmdState::Finished; }
  private:
    MemoryCommandType_t type_;
    unsigned address_;
    unsigned byteEnable_;
    unsigned dest_;
    unsigned delay_;
    uint32_t value_;
    SimMemCmdState_t state_;
  };// class SimMemoryCommand

  template <typename T>
  class SimVectorMemoryCommand {
  public:
    SimVectorMemoryCommand()
      : type_(MemoryCommandType::MemoryCommandTypeEnd),
        address_(0), dest_(0), delay_(0), state_(SimMemCmdState::Init) {}
    SimVectorMemoryCommand(MemoryCommandType_t type, unsigned addr,
                           unsigned delay, const BitVector& predicate)
      : type_(type),address_(addr),delay_(delay),state_(SimMemCmdState::Init),
        predicate_(predicate) {}
    SimVectorMemoryCommand(MemoryCommandType_t type, unsigned addr,
                           const std::vector<T>& value,
                           unsigned delay, const BitVector& predicate)
      : type_(type), address_(addr), dest_(0), delay_(delay), value_(value),
        state_(SimMemCmdState::Init), predicate_(predicate) {}
    ~SimVectorMemoryCommand() {}

    bool IsLoad() const {
      return (type_ >= MemoryCommandType::Read8)
        && (type_ <= MemoryCommandType::Read32);
    }
    MemoryCommandType_t& Type() { return type_; }
    const MemoryCommandType_t& Type() const { return type_; }
    unsigned&       Address()       { return address_; }
    const unsigned& Address() const { return address_; }
    std::vector<unsigned>&       VectorAddress()      { return vectorAddress_; }
    const std::vector<unsigned>& VectorAddress() const{ return vectorAddress_; }
    std::vector<unsigned>&       VectorBE()       { return vectorBE_; }
    const std::vector<unsigned>& VectorBE() const { return vectorBE_; }
    unsigned&       Delay()       { return delay_; }
    const unsigned& Delay() const { return delay_; }
    unsigned&       Destination()       { return dest_;      }
    const unsigned& Destination() const { return dest_;      }
    std::vector<T>&       Value()       { return value_;     }
    const std::vector<T>& Value() const { return value_;     }
    BitVector&       Predicate()        { return predicate_; }
    const BitVector& Predicate()  const { return predicate_; }
    SimMemCmdState_t& State() { return state_; }
    const SimMemCmdState_t& State() const { return state_; }
    bool Finished() const { return state_ == SimMemCmdState::Finished; }
  private:
    MemoryCommandType_t type_;
    unsigned address_;
    std::vector<unsigned> vectorAddress_;
    std::vector<unsigned> vectorBE_;
    unsigned dest_;
    unsigned delay_;
    std::vector<T> value_;
    BitVector      predicate_;
    SimMemCmdState_t state_;
  };// class SimVectorMemoryCommand

  template <typename T>
  std::ostream& operator<<(std::ostream& o, SimVectorMemoryCommand<T> const& t) {
    o << MemoryCommandType::GetString(t.Type()) <<", A="<< t.VectorAddress()
      <<", dat="<< t.Value()<<", lat="<< t.Delay();
    if (t.IsLoad())
      o <<", dst="<< t.Destination();
    return o;
  }
}// namespace ES_SIMD

#endif//ES_SIMD_SIMMEMORYCMD_HH


