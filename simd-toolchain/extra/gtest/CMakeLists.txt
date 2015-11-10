########################################################################
# CMake build script for Google Test.
#
# Where Google Test's .h files can be found.
INCLUDE_DIRECTORIES(
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR})

########################################################################
#
# Defines the gtest & gtest_main libraries.  User tests should link
# with one of them.

# Google Test libraries.  We build them using more strict warnings than what
# are used for other targets, to ensure that gtest can be compiled by a user
# aggressive about warnings.
ADD_LIBRARY(gtest src/gtest-all.cc)
ADD_LIBRARY(gtest_main src/gtest_main.cc)
TARGET_LINK_LIBRARIES(gtest_main gtest)

