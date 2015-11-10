SET(S-CG_SRC_LIST s-cg.cc)

llvm_map_components_to_libraries(S_CG_LLVM_LIBRARIES support)

add_es_simd_tool(s-cg ${S-CG_SRC_LIST} Program Target BaselineTarget BaselineCodeGenEngine
  SIR Transform Utils DataTypes ${S_CG_LLVM_LIBRARIES})

INSTALL(TARGETS s-cg RUNTIME DESTINATION bin)
