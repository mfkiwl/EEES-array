ADD_EXECUTABLE(SIRTest EXCLUDE_FROM_ALL
  SIRExprTest.cc
  SIRFuncTest.cc
  SIRInstrTest.cc
  SIRBBTest.cc)

TARGET_LINK_LIBRARIES(SIRTest gtest gtest_main SIR Utils DataTypes Target pthread)

run_unittest(SIRTest)