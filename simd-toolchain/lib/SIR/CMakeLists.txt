ADD_LIBRARY(SIR SHARED
  SIRValue.cc
  SIRModule.cc
  SIRFunction.cc
  SIRDataObject.cc
  SIRKernel.cc
  SIRLoop.cc
  SIRBasicBlock.cc
  SIRInstruction.cc
  SIRConstant.cc
  SIRRegister.cc
  SIRParser.cc
  SIRExpr.cc
  SIRMemLocation.cc
  Pass.cc
)

TARGET_LINK_LIBRARIES(SIR Utils DataTypes)

INSTALL(TARGETS SIR LIBRARY DESTINATION lib)
