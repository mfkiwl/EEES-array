AUX_SOURCE_DIRECTORY(. S-SIM_SRC_LIST)

llvm_map_components_to_libraries(S_SIM_LLVM_LIBRARIES support)

add_es_simd_tool(s-sim ${S-SIM_SRC_LIST} Target BaselineTarget Simulation
  BaselineSimProcessor Utils DataTypes ${S_SIM_LLVM_LIBRARIES})

INSTALL(TARGETS s-sim RUNTIME DESTINATION bin)
