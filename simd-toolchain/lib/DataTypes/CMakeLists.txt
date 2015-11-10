ADD_LIBRARY(DataTypes SHARED
  Error.cc
  ContainerTypes.cc
  SIRDataType.cc
  SIROpcode.cc
  TargetOpcode.cc
  )

TARGET_LINK_LIBRARIES(DataTypes Utils)

INSTALL(TARGETS DataTypes LIBRARY DESTINATION lib)

