#ifndef ES_SIMD_SIMSYNCCHANNEL_HH
#define ES_SIMD_SIMSYNCCHANNEL_HH

#include "DataTypes/EnumFactory.hh"
#include "DataTypes/Object.hh"

#define SYNCCHANNELSTATE_ENUM(DEF, DEFV)         \
  DEF(InSync)                                    \
  DEF(WaitTarget)                                \
  DEF(TargetReady)

namespace ES_SIMD {

  DECLARE_ENUM(SyncChannelState,SYNCCHANNELSTATE_ENUM)

  class SimSyncChannel : NonCopyable {
  public:
    SimSyncChannel(const std::string& name, unsigned id)
      : name_(name), id_(id) {}
    ~SimSyncChannel() {}
    void Reset() { state_ = SyncChannelState::InSync; }

    bool IsSynchronized() const { return state_ == SyncChannelState::InSync; }
    bool Initiate() {
      bool succ = false;
      if (state_ == SyncChannelState::InSync) {
        state_ = SyncChannelState::WaitTarget;
        succ = true;
      } else if (state_ == SyncChannelState::TargetReady) {
        state_ = SyncChannelState::InSync;
        succ = true;
      }
      return succ;
    }
    bool Acknowledge() {
      bool succ = false;
      if (state_ == SyncChannelState::InSync) {
        state_ = SyncChannelState::TargetReady;
        succ = true;
      } else if (state_ == SyncChannelState::WaitTarget) {
        state_ = SyncChannelState::InSync;
        succ = true;
      }
      return succ;
    }
    const std::string& GetName() const { return name_; }
    unsigned GetID() const { return id_; }
    SyncChannelState_t GetState() const { return state_; }
  private:
    std::string name_;
    unsigned id_;
    SyncChannelState_t state_;
  };// class SimSyncChannel

}// namespace ES_SIMD

#endif//ES_SIMD_SIMSYNCCHANNEL_HH
