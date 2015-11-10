ADD_EXECUTABLE(UtilsTest EXCLUDE_FROM_ALL
  StringUtilsTest.cc
  BitUtilsTest.cc)

TARGET_LINK_LIBRARIES(UtilsTest gtest gtest_main Utils DataTypes pthread)

run_unittest(UtilsTest)