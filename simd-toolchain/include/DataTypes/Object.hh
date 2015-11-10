#ifndef ES_SIMD_OBJECT_HH
#define ES_SIMD_OBJECT_HH

namespace ES_SIMD {
  /// @class NonCopyable
  /// @brief A base class that make sure copy/assignment is not possible by
  /// making the copy constructor and assignment operator private
  class NonCopyable {
  protected:
    NonCopyable() {}
    ~NonCopyable() {}
  private:
    NonCopyable(const NonCopyable&);
    const NonCopyable& operator=(const NonCopyable&);
  };
}// namespace ES_SIMD

#endif//ES_SIMD_OBJECT_HH
