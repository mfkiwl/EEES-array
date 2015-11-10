#ifndef ES_SIMD_INLINEUTILS_HH
#define ES_SIMD_INLINEUTILS_HH

namespace ES_SIMD {
  /// Integer operations
  static inline bool
  RangeOverlap(int a1, int b1, int a2, int b2) {
    return (a1 == a2) || ((a1 > a2) && (a1 <= b2))
      || ((a1 < a2) && (b1 >= a2));
  }

  static inline bool
  IsPowerOf2(int v) {
    return (v && !(v & (v - 1)));
  }

  static inline int
  CeilDiv(int a, int b) {
    return (a + b - 1) / b;
  }

  static inline unsigned
  CeilDiv(unsigned a, unsigned b) {
    return (a + b - 1u) / b;
  }

  template<typename T>
  bool InIntervalClosed(T v, T lb, T ub) { return (v >= lb) && (v <= ub); }

  template<class T>
  static inline T GetMaxElement(const T* data, const int n) {
    int m = 0;
    for (int i = 1; i < n; ++i) {
      if (data[i] > data[m])
        m = i;
    }
    return data[m];
  }

  template<class T>
  static inline T GetMinElement(const T* data, const int n) {
    int m = 0;
    for (int i = 1; i < n; ++i) {
      if (data[i] < data[m])
        m = i;
    }
    return data[m];
  }
}// namespace ES_SIMD

#endif//ES_SIMD_INLINEUTILS_HH
