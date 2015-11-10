ADD_LIBRARY(BaselineCodeGenEngine SHARED
  BaselineCodeGenEngine.cc
  BaselineBUSelector.cc
  BaselineBypassSelector.cc
  BaselineInstrData.cc
  BaselineSIRTranslation.cc
  BaselineBypass.cc
  BaselineRegAlloc.cc
  BaselineSpiller.cc
  BaselineJointPointAnalysis.cc
  BaselineBlockData.cc
  BaselineFuncData.cc
  BaselineModuleData.cc
  BaselineInitCodeEmitter.cc
  BaselineKernelBuilder.cc
  BaselinePostRATransform.cc
  BaselineCallerSavedRegs.cc
  BaselineCommunication.cc
  BaselineDataLayout.cc
  BaselineKernelExpressions.cc
  BaselineSchedule.cc)

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR}/..
  ${CMAKE_CURRENT_SOURCE_DIR}/.. )

TARGET_LINK_LIBRARIES(BaselineCodeGenEngine BaselineTarget)

INSTALL(TARGETS BaselineCodeGenEngine LIBRARY DESTINATION lib)
