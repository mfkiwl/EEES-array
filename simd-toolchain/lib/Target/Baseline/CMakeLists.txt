ADD_LIBRARY(BaselineTarget SHARED
  BaselineBasicInfo.cc
  BaselineBinaryProgram.cc
  BaselineInstruction.cc
  BaselineInstrFormat.cc)

TARGET_LINK_LIBRARIES(BaselineTarget Target)
INSTALL(TARGETS BaselineTarget LIBRARY DESTINATION lib)

ADD_SUBDIRECTORY(ASMParser)
ADD_SUBDIRECTORY(CodeGenEngine)
ADD_SUBDIRECTORY(SimProcessor)

