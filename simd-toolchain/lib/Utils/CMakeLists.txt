ADD_LIBRARY(Utils SHARED
  BitUtils.cc
  CmdUtils.cc
  DbgUtils.cc
  FileUtils.cc
  StringUtils.cc
  Timer.cc
  VerilogMemInit.cc)

TARGET_LINK_LIBRARIES(Utils jsoncpp)

INSTALL(TARGETS Utils LIBRARY DESTINATION lib)