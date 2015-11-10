#ifndef ES_SIMD_BITUTILS_HH
#define ES_SIMD_BITUTILS_HH

#include <vector>
#include <stdint.h>
///
/// Bit operation utilities
/// Check this page when something new is needed:
/// http://graphics.stanford.edu/~seander/bithacks.html
///

namespace ES_SIMD {
  static inline int
  HighestBitSet(int32_t i) {
    return 31 - __builtin_clz(i);
  }
  /// \brief Test if a signed integer can fit in n bits.
  /// \param imm The immediate to be tested.
  /// \param n The number of bits.
  /// \return true if imm can be represented in n-bit 2's complement,
  ///         otherwise false.
  /// \see UnsignedImmCanFitNBits() SignExtendNBitImm()
  static inline bool
  SignedImmCanFitNBits(int imm, int n) {
    unsigned int mask = ~((1U<<(n-1)) - 1);
    unsigned int up = imm & mask;
    return ((up == mask) || (up == 0)) && (n != 0);
  }// SignedIMMCanFit()

  /// \brief Test if an unsigned integer can fit in n bits.
  /// \param imm The immediate to be tested.
  /// \param n The number of bits.
  /// \return true if imm can be represented in n-bit, otherwise false.
  /// \see SignedImmCanFitNBits()
  static inline bool
  UnsignedImmCanFitNBits(unsigned imm, int n) {
    return imm < (1<<n);
  }// SignedIMMCanFit()

  /// \brief Sign extend a n-bit immediate
  /// \param imm The immediate to be extended.
  /// \param n The number of bits.
  /// \return The sign-extended value.
  static inline int
  SignExtendNBitImm(int imm, int n) {
    const int mask = 1U<<(n-1);
    return ((imm ^ mask) - mask);
  }// SignedExtendNBitImm()

  /// \brief Get the maximum value of an n-bit unsigned integer.
  /// \param n The number of bits.
  /// \return The maximum value of an n-bit unsigned integer.
  /// \see MaxSImmNBits()
  /// \see MinSImmNBits()
  static inline int
  MaxUImmNBits(int n) {
    return (int)((1U << n) - 1);
  }// MaxUImmNBits

  /// \brief Get the maximum value of an n-bit signed integer.
  /// \param n The number of bits.
  /// \return The maximum value of an n-bit signed integer in 2' complement.
  /// \see MaxUImmNBits()
  /// \see MinSImmNBits()
  static inline int
  MaxSImmNBits(int n) {
    return (int)((1U << (n-1)) - 1);
  }// MaxSImmNBits

  /// \brief Get the minimum value of an n-bit signed integer.
  /// \param n The number of bits.
  /// \return The minimum value of an n-bit signed integer in 2' complement.
  /// \see MaxUImmNBits()
  /// \see MaxSImmNBits()
  static inline int
  MinSImmNBits(int n) {
    return -1 - (int)((1U << (n-1)) - 1);
  }// MinSImmNBits

  /// \brief Insert bits into a 32-bit integer.
  ///
  /// This function insert bits to [msb, lsb] of word.
  /// \param bits The bits to be inserted.
  /// \param word The target word.
  /// \param lsb  The least significant bit to insert.
  /// \param msb  The most significant bit to insert.
  /// \return The result 32-bit integer.
  /// \see ExtractBitsFromWord()
  /// \see ExtractBitFromWord()
  /// \see ExtractBitsFromIntVector()
  /// \see InsertBitsToIntVector()
  static inline uint32_t
  InsertBitsToWord(uint32_t bits, uint32_t word, unsigned lsb, unsigned msb) {
    uint32_t mask = (~0U) << (msb+1);
    mask = mask | ~((~0U) << lsb);
    return (word & mask) | ((bits<<lsb) & ~mask);
  }// InsertBitsToWord()
  /// \brief Extract bits from a 32-bit integer.
  ///
  /// This function extracts values of bits [msb, lsb] of word.
  /// \param word The target word.
  /// \param lsb  The least significant bit to extract.
  /// \param msb  The most significant bit to extract.
  /// \return The bit value of [msb, lsb].
  /// \see InsertBitsToWord()
  /// \see ExtractBitFromWord()
  /// \see ExtractBitsFromIntVector()
  /// \see InsertBitsToIntVector()
  static inline uint32_t
  ExtractBitsFromWord(uint32_t word, unsigned lsb, unsigned msb) {
    uint32_t mask = (~0U) << (msb+1);
    return (word & ~mask) >> lsb;
  }
  /// \brief Extract one bit from a 32-bit integer.
  ///
  /// This function extracts value of one bit in word.
  /// \param word The target word.
  /// \param b  The bit index.
  /// \return The bit value.
  /// \see ExtractBitsFromWord()
  /// \see ExtractBitsFromIntVector()
  /// \see InsertBitsToIntVector()
  static inline uint32_t
  ExtractBitFromWord(uint32_t word, unsigned b) {
    return (word >> b) & 0x1;
  }
  /// \brief Insert bits into a long bit-vector.
  ///
  /// This function insert bits into [msb, lsb] of word. The long bit
  /// vector is assume to represented by a vector of 32-bit integers.
  /// \param bits The bit value.
  /// \param lsb  The least significant bit to insert.
  /// \param msb  The most significant bit to insert.
  /// \param vec  The target word vector.
  /// \see InsertBitsToWord()
  /// \see ExtractBitFromWord()
  /// \see ExtractBitsFromIntVector()
  /// \see InsertBitsToIntVector()
  void InsertBitsToIntVector(uint32_t bits, unsigned lsb, unsigned msb,
                             std::vector<uint32_t>& vec);
  /// \brief Extract bits from a long bit-vector.
  ///
  /// This function extracts values of bits [msb, lsb] of word. The long bit
  /// vector is assume to represented by a vector of 32-bit integers.
  /// \param lsb  The least significant bit to extract.
  /// \param msb  The most significant bit to extract.
  /// \param vec The target word vector.
  /// \return The bit value of [msb, lsb].
  /// \see ExtractBitsFromWord()
  /// \see ExtractBitFromWord()
  /// \see InsertBitsToWord()
  /// \see InsertBitsToIntVector()
  uint32_t ExtractBitsFromIntVector(unsigned lsb, unsigned msb,
                                    const std::vector<uint32_t>& vec);
}// namespace ES_SIMD

#endif//ES_SIMD_BITUTILS_HH
