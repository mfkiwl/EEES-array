SET(LIBRARY_OUTPUT_PATH ${SIMD-TOOLCHAIN_BINARY_DIR}/py-binding/solver_sim)

FILE(GLOB PyFiles ${CMAKE_CURRENT_SOURCE_DIR}/*.py)

FOREACH(PyFile ${PyFiles})
  GET_FILENAME_COMPONENT(FN ${PyFile} NAME)
  SET(PyOut ${SIMD-TOOLCHAIN_BINARY_DIR}/py-binding/solver_sim/${FN})
  SET(PyLibOut ${SOLVER_PY_LIB_BUILD_DIR}/solver_sim/${FN})
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

ADD_CUSTOM_TARGET(py_solver_sim DEPENDS ${PyOutFiles} ${PyLibOutFiles})

ADD_LIBRARY(solver_sim SHARED
  solver_sim.cc)

TARGET_LINK_LIBRARIES(solver_sim ${PYTHONLIBS} Target BaselineTarget
  Simulation  BaselineSimProcessor Utils DataTypes)

ADD_CUSTOM_COMMAND(TARGET solver_sim POST_BUILD
  COMMAND ${CMAKE_COMMAND}
  ARGS -E copy $<TARGET_FILE:solver_sim> ${SOLVER_PY_LIB_BUILD_DIR}/solver_sim/
)

ADD_DEPENDENCIES(solver_sim py_solver_sim)

INSTALL(TARGETS solver_sim LIBRARY DESTINATION lib/solver/python/solver_sim)
INSTALL(FILES ${PyOutFiles} DESTINATION lib/solver/python/solver_sim)