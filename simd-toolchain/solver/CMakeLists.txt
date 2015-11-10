INSTALL(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/arch    DESTINATION share/solver)
INSTALL(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/html    DESTINATION share/solver)
INSTALL(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rtl     DESTINATION share/solver)
INSTALL(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include DESTINATION share/solver/usr)
INSTALL(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lib     DESTINATION share/solver/usr)


SET(SOLVER_ARCH_PREFIX ${SIMD-TOOLCHAIN_BINARY_DIR}/share/solver)
ADD_CUSTOM_TARGET(solver-arch-files)
ADD_CUSTOM_TARGET(solver-rtl-src)

ADD_CUSTOM_COMMAND(
  TARGET solver-arch-files
  COMMAND ${PYTHON_EXECUTABLE}
  ARGS ${SIMD-TOOLCHAIN_SOURCE_DIR}/scripts/python/utils/sys_utils.py
  copy-if-newer ${CMAKE_CURRENT_SOURCE_DIR}/arch  ${SOLVER_ARCH_PREFIX}
  )

ADD_CUSTOM_COMMAND(
  TARGET solver-rtl-src
  COMMAND ${PYTHON_EXECUTABLE}
  ARGS ${SIMD-TOOLCHAIN_SOURCE_DIR}/scripts/python/utils/sys_utils.py
  copy-if-newer ${CMAKE_CURRENT_SOURCE_DIR}/rtl  ${SOLVER_ARCH_PREFIX}
  )

SET(SOLVER_BUILD_PREFIX ${SIMD-TOOLCHAIN_BINARY_DIR}/share/solver/usr)
ADD_CUSTOM_TARGET(solver-inc)
ADD_CUSTOM_TARGET(solver-lib)
ADD_CUSTOM_TARGET(solver-html)

ADD_CUSTOM_COMMAND(
  TARGET solver-inc
  COMMAND ${PYTHON_EXECUTABLE}
  ARGS ${SIMD-TOOLCHAIN_SOURCE_DIR}/scripts/python/utils/sys_utils.py
  copy-if-newer ${CMAKE_CURRENT_SOURCE_DIR}/include  ${SOLVER_BUILD_PREFIX}
  )

ADD_CUSTOM_COMMAND(
  TARGET solver-lib
  COMMAND ${PYTHON_EXECUTABLE}
  ARGS ${SIMD-TOOLCHAIN_SOURCE_DIR}/scripts/python/utils/sys_utils.py
  copy-if-newer ${CMAKE_CURRENT_SOURCE_DIR}/lib  ${SOLVER_BUILD_PREFIX}
  )

ADD_CUSTOM_COMMAND(
  TARGET solver-html
  COMMAND ${PYTHON_EXECUTABLE}
  ARGS ${SIMD-TOOLCHAIN_SOURCE_DIR}/scripts/python/utils/sys_utils.py
  copy-if-newer ${CMAKE_CURRENT_SOURCE_DIR}/html  ${SOLVER_ARCH_PREFIX}
  )

ADD_DEPENDENCIES(solvercc solver-inc solver-lib)
ADD_DEPENDENCIES(solversim solver-arch-files)
ADD_DEPENDENCIES(solverrtlgen solver-arch-files solver-rtl-src)
ADD_DEPENDENCIES(solverreadbin solver-html)
