#ifndef ES_SIMD_MEMDATASECTION_HH
#define ES_SIMD_MEMDATASECTION_HH

namespace ES_SIMD {
  struct MemDataSection {
    uint32_t start_;      ///< the start word address
    uint32_t width_;      ///< the number of bits in one memory word
    UInt32Vector2D data_; ///< each row is a memory word store in a vector, in
                          ///< which the element order is LITTLE-ENDIAN
    unsigned size() const { return data_.size(); }
    UInt32Vector& operator[](unsigned i) { return data_[i]; }
    const UInt32Vector& operator[](unsigned i) const { return data_[i]; }
    MemDataSection() {}
    MemDataSection(uint32_t start, uint32_t width)
      : start_(start), width_(width) {}
  };// struct MemDataSection
}// namespace ES_SIMD

#endif//ES_SIMD_MEMDATASECTION_HH
