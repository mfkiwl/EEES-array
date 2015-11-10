#ifndef ES_SIMD_TARGETSPILLSLOT_HH
#define ES_SIMD_TARGETSPILLSLOT_HH

namespace ES_SIMD {
  class TargetSpillSlot {
    int index_;
    int value_;
    int size_;
    int stackAddr_;
  public:
    void SetIndex(int i) { index_ = i; }
    void SetValue(int v) { value_ = v; }
    void SetSize(int s)  { size_ = s;  }
    void SetStackAddr(int addr) { stackAddr_ = addr; }

    int Index()     const { return index_;     }
    int Value()     const { return value_;     }
    int Size()      const { return size_;      }
    int StackAddr() const { return stackAddr_; }
  };// class TargetSpillSlot
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETSPILLSLOT_HH
