#ifndef ES_SIMD_TARGETMEMORYSEGMENTS_HH
#define ES_SIMD_TARGETMEMORYSEGMENTS_HH

namespace ES_SIMD {

  ///  The generic data memory layout looks like this:
  ///
  ///      +----------+ <- dataStart_
  ///      |   data   |
  ///      +----------+ <- bssStart_
  ///      |    bss   |
  ///      +----------+ <- heapStart_
  ///      |   heap   |
  ///      +----------+
  ///      |   stack  |
  ///      +----------+ <- stackBottom_
  ///
  ///   Note: stackBottom_ points to the last memory entry if it equals to -1
  struct DataMemorySegments {
    int dataStart_;
    int bssStart_;
    int heapStart_;
    int stackBottom_;
    DataMemorySegments() : dataStart_(0), bssStart_(0),
                           heapStart_(0), stackBottom_(-1) {}
  };
}

#endif//ES_SIMD_TARGETMEMORYSEGMENTS_HH
