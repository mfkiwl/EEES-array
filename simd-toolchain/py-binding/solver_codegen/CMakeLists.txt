SET(LIBRARY_OUTPUT_PATH ${SIMD-TOOLCHAIN_BINARY_DIR}/py-binding/solver_codegen)

FILE(GLOB PyFiles ${CMAKE_CURRENT_SOURCE_DIR}/*.py)

FOREACH(PyFile ${PyFiles})
  GET_FILENAME_COMPONENT(FN ${PyFile} NAME)
  SET(PyOut ${SIMD-TOOLCHAIN_BINARY_DIR}/py-binding/solver_codegen/${FN})
  SET(PyLibOut ${SOLVER_PY_LIB_BUILD_DIR}/solver_codegen/${FN})
  ADD_CUSTOM_COMMAND(
    OUTPUT  ${PyOut}
    COMMAND ${CMAKE_COMMAND}
    ARGS -E copy_if_different  ${PyFile} ${PyOut}
    DEPENDS ${PyFile})
  ADD_CUSTOM_COMMAND(
    OUTPUT  ${PyLibOut}
    COMMAND ${CMAKE_COMMAND}
    ARGS -E copy_if_different  ${PyFile} ${PyLibOut}
    DEPENDS ${PyFile})
  LIST(APPEND PyOutFiles ${PyOut})
  LIST(APPEND PyLibOutFiles ${PyLibOut})
ENDFOREACH()

ADD_CUSTOM_TARGET(py_solver_codegen DEPENDS ${PyOutFiles} ${PyLibOutFiles})

ADD_LIBRARY(solver_codegen SHARED
  solver_codegen.cc)

TARGET_LINK_LIBRARIES(solver_codegen ${PYTHONLIBS} SIR Transform Program
  Target BaselineTarget BaselineCodeGenEngine Utils DataTypes)

ADD_CUSTOM_COMMAND(TARGET solver_codegen POST_BUILD
  COMMAND ${CMAKE_COMMAND}
  ARGS -E copy $<TARGET_FILE:solver_codegen> ${SOLVER_PY_LIB_BUILD_DIR}/solver_codegen/
)

ADD_DEPENDENCIES(solver_codegen py_solver_codegen)

INSTALL(TARGETS solver_codegen LIBRARY DESTINATION lib/solver/python/solver_codegen)
INSTALL(FILES ${PyOutFiles} DESTINATION lib/solver/python/solver_codegen)