AUX_SOURCE_DIRECTORY(. S-AS_SRC_LIST)

llvm_map_components_to_libraries(S_AS_LLVM_LIBRARIES support)

add_es_simd_tool(s-as ${S-AS_SRC_LIST} Target BaselineTarget BaselineASMParser
  Utils DataTypes ${S_AS_LLVM_LIBRARIES})

INSTALL(TARGETS s-as RUNTIME DESTINATION bin)
