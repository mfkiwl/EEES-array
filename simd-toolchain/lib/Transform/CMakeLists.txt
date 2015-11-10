ADD_LIBRARY(Transform SHARED
  SIRCallSiteProcessing.cc
  SplitSIRCallBlock.cc
  SIRSimplfyBranch.cc
  SIRFunctionLayout.cc
  DeadFunctionElimination.cc
  SIRFinalize.cc
  SIRLocalOpt.cc
)

TARGET_LINK_LIBRARIES(Transform SIR)

INSTALL(TARGETS Transform LIBRARY DESTINATION lib)
