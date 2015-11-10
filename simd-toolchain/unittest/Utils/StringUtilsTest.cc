#include "Utils/StringUtils.hh"
#include "gtest/gtest.h"

using namespace ES_SIMD;

TEST(ImmediateReaderTest, Basic) {
  ImmediateReader immRd;
  EXPECT_FALSE(immRd.error_);
  EXPECT_EQ   (1  , immRd.GetIntImmediate("1"));
  EXPECT_EQ   (1  , immRd.GetIntImmediate("0x1"));
  EXPECT_EQ   (10 , immRd.GetIntImmediate("0xA"));
  EXPECT_EQ   (10 , immRd.GetIntImmediate("0xa"));
  EXPECT_EQ   (170, immRd.GetIntImmediate("0xaA"));
  EXPECT_EQ   (0  , immRd.GetIntImmediate("0xZ"));
  EXPECT_TRUE (immRd.error_);
  EXPECT_EQ   (1  , immRd.GetIntImmediate("01"));
  EXPECT_FALSE(immRd.error_);
  EXPECT_EQ   (0  , immRd.GetIntImmediate("0 1"));
  EXPECT_TRUE (immRd.error_);
  EXPECT_EQ   (0  , immRd.GetIntImmediate(" 01"));
  EXPECT_TRUE (immRd.error_);
  EXPECT_EQ   (0  , immRd.GetIntImmediate("01 "));
  EXPECT_TRUE (immRd.error_);
  EXPECT_EQ   (0  , immRd.GetIntImmediate("0x"));
  EXPECT_TRUE (immRd.error_);
  EXPECT_EQ   (1  , immRd.GetIntImmediate("01"));
  EXPECT_FALSE(immRd.error_);
  EXPECT_EQ   (0  , immRd.GetIntImmediate("0X1"));
  EXPECT_TRUE (immRd.error_);
}// TEST(ImmediateReaderTest, Basic)

TEST(ParseEscapedStringTest, Basic) {
  std::vector<int> data;
  ASSERT_TRUE(ParseEscapedString("\\000", data));
  ASSERT_EQ(data.size(), 1U);
  EXPECT_EQ(data[0], 0);
  ASSERT_TRUE(ParseEscapedString("\\021\\033", data));
  ASSERT_EQ(data.size(), 2U);
  EXPECT_EQ(data[0], 17);
  EXPECT_EQ(data[1], 27);

  ASSERT_TRUE(ParseEscapedString("\\b\\f\\n\\r\\t\\\"\\'\\\\" , data));
  ASSERT_EQ(data.size(), 8U);
  EXPECT_EQ(data[0], '\b');
  EXPECT_EQ(data[1], '\f');
  EXPECT_EQ(data[2], '\n');
  EXPECT_EQ(data[3], '\r');
  EXPECT_EQ(data[4], '\t');
  EXPECT_EQ(data[5], '\"');
  EXPECT_EQ(data[6], '\'');
  EXPECT_EQ(data[7], '\\');

  ASSERT_TRUE(ParseEscapedString("\\000BsEf", data));
  ASSERT_EQ(data.size(), 5U);
  EXPECT_EQ(data[0], 0);
  EXPECT_EQ(data[1], 'B');
  EXPECT_EQ(data[2], 's');
  EXPECT_EQ(data[3], 'E');
  EXPECT_EQ(data[4], 'f');

  EXPECT_TRUE(ParseEscapedString("\\097" , data));
  ASSERT_EQ(data.size(), 3U);
  EXPECT_EQ(data[0], 0);
  EXPECT_EQ(data[1], '9');
  EXPECT_EQ(data[2], '7');

  // Invalid oct literal
  EXPECT_FALSE(ParseEscapedString("\\97" ,   data));
  // Invalid escape sequence
  EXPECT_FALSE(ParseEscapedString("\\zBs" , data));
}

