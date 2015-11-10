ADD_LIBRARY(Program SHARED
  ProcessingDriver.cc
  SIRModuleVerifier.cc
)

TARGET_LINK_LIBRARIES(Program SIR Transform Target)

INSTALL(TARGETS Program LIBRARY DESTINATION lib)

