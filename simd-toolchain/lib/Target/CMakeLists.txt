ADD_LIBRARY(Target SHARED
  TargetASMParser.cc
  TargetBasicInfo.cc
  TargetBinaryProgram.cc
  TargetInstruction.cc
  TargetInstructionPacket.cc
  TargetOperand.cc
  TargetCodeGenEngine.cc
  DataDependencyGraph.cc
  BottomUpSchedule.cc
  PromoteLongImm.cc
  RegAlloc.cc
  InterferenceGraph.cc
  TargetModuleData.cc
  TargetFuncData.cc
  TargetBlockData.cc
  TargetInstrData.cc
  TargetIssuePacket.cc
  TargetFuncRegAllocInfo.cc
  TargetRegisterFile.cc
  TargetOperationInfo.cc
  TargetDataLayout.cc
  DDGSubTree.cc
)

TARGET_LINK_LIBRARIES(Target SIR)

INSTALL(TARGETS Target LIBRARY DESTINATION lib)

SUBDIRS(Baseline)
