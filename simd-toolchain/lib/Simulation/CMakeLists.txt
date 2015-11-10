ADD_LIBRARY(Simulation SHARED
  CycleAccurateSimulator.cc
  SimCore.cc
  SimMemoryCmd.cc
  SimObjectBase.cc
  SimProcessor.cc
  SimProgramSection.cc
  SimSRAM.cc
  SimSyncChannel.cc)

TARGET_LINK_LIBRARIES(Simulation DataTypes)

INSTALL(TARGETS Simulation LIBRARY DESTINATION lib)
