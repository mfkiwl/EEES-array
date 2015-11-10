#include "Utils/BitUtils.hh"
#include "gtest/gtest.h"

using namespace ES_SIMD;

TEST(BitUtilsTest, Basic) {
  EXPECT_FALSE(SignedImmCanFitNBits(2, 2));
  EXPECT_TRUE (SignedImmCanFitNBits(-1, 2));
  EXPECT_TRUE (SignedImmCanFitNBits(1, 2));

  EXPECT_TRUE  (UnsignedImmCanFitNBits(0, 2));
  EXPECT_TRUE  (UnsignedImmCanFitNBits(1, 2));
  EXPECT_TRUE  (UnsignedImmCanFitNBits(2, 2));
  EXPECT_TRUE  (UnsignedImmCanFitNBits(3, 2));
  EXPECT_FALSE (UnsignedImmCanFitNBits(4, 2));
  EXPECT_FALSE (UnsignedImmCanFitNBits(-1, 2));
}// TEST(BitUtilsTest, Basic)

