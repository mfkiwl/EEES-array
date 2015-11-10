ADD_CUSTOM_TARGET(check)
ADD_DEPENDENCIES(check-all check)

MACRO(run_test_dir name)
  ADD_CUSTOM_TARGET(check-${name})
  ADD_CUSTOM_COMMAND(
    TARGET check-${name}
    DEPENDS ${ES_SIMD_TOOL_LIST}
    COMMENT "Running Test ${name}"
    COMMAND ${PYTHON_EXECUTABLE}
    ${SIMD-TOOLCHAIN_BINARY_DIR}/lib/solver/python/test_driver/test_tool.py
    --tool-path ${SIMD-TOOLCHAIN_BINARY_DIR}/bin
    --solver-root ${SIMD-TOOLCHAIN_BINARY_DIR}/share/solver
    ${SIMD-TOOLCHAIN_SOURCE_DIR}/test/${name} ${ARGN}
    )
  ADD_DEPENDENCIES(check-${name} ${ES_SIMD_TOOL_LIST})
  ADD_DEPENDENCIES(check-${name} solvercc solversim)
  ADD_DEPENDENCIES(check check-${name})
ENDMACRO(run_test_dir name)

run_test_dir(assembly --parallel)
run_test_dir(simulation --parallel)
run_test_dir(code-gen  --parallel)
run_test_dir(runtime  --parallel --test-filename-pattern=*.sir)

ADD_CUSTOM_TARGET(check-rtl)
ADD_DEPENDENCIES(check-all check-rtl)

MACRO(run_test_dir_rtl name)
  ADD_CUSTOM_TARGET(check-${name}-rtl)
  ADD_CUSTOM_COMMAND(
    TARGET check-${name}-rtl
    DEPENDS ${ES_SIMD_TOOL_LIST}
    COMMENT "Running RTL Test ${name}"
    COMMAND ${PYTHON_EXECUTABLE}
    ${SIMD-TOOLCHAIN_BINARY_DIR}/lib/solver/python/test_driver/test_tool.py
    --tool-path ${SIMD-TOOLCHAIN_BINARY_DIR}/bin
    --solver-root ${SIMD-TOOLCHAIN_BINARY_DIR}/share/solver
    --run-rtl --rtl-flow ${RTL_FLOW} --rtl-cc ${RTL_CC} --rtl-sim ${RTL_SIM}
    ${SIMD-TOOLCHAIN_SOURCE_DIR}/test/${name} ${ARGN}
    )
  ADD_DEPENDENCIES(check-${name}-rtl ${ES_SIMD_TOOL_LIST})
  ADD_DEPENDENCIES(check-${name}-rtl solvercc solversim solverrtlgen)
  ADD_DEPENDENCIES(check-rtl check-${name}-rtl)
ENDMACRO(run_test_dir_rtl name)

IF(RTL_FLOW)
  run_test_dir_rtl(simulation --parallel)
  run_test_dir_rtl(code-gen  --parallel)
  run_test_dir_rtl(runtime  --parallel --test-filename-pattern=*.sir)
ENDIF(RTL_FLOW)

ADD_CUSTOM_TARGET(memcheck)

MACRO(run_memcheck_dir name)
  ADD_CUSTOM_TARGET(memcheck-${name})
  ADD_CUSTOM_COMMAND(
    TARGET memcheck-${name}
    DEPENDS ${ES_SIMD_TOOL_LIST}
    COMMENT "Running Test ${name} with memory checker"
    COMMAND ${PYTHON_EXECUTABLE}
    ${SIMD-TOOLCHAIN_BINARY_DIR}/lib/solver/python/test_driver/test_tool.py
    --tool-path ${SIMD-TOOLCHAIN_BINARY_DIR}/bin --memcheck
    --solver-root ${SIMD-TOOLCHAIN_SOURCE_DIR}/solver
    ${SIMD-TOOLCHAIN_SOURCE_DIR}/test/${name} ${ARGN}
    )
  ADD_DEPENDENCIES(memcheck-${name} ${ES_SIMD_TOOL_LIST})
  ADD_DEPENDENCIES(memcheck-${name} solvercc solversim)
  ADD_DEPENDENCIES(memcheck memcheck-${name})
ENDMACRO(run_memcheck_dir name)

FIND_PROGRAM(VALGRIND_EXECUTABLE NAMES valgrind)
IF(VALGRIND_EXECUTABLE)
  run_memcheck_dir(assembly --parallel)
  run_memcheck_dir(simulation --parallel)
  run_memcheck_dir(code-gen  --parallel)
  run_memcheck_dir(runtime  --parallel --test-filename-pattern=*.sir)
ENDIF(VALGRIND_EXECUTABLE)

ADD_CUSTOM_TARGET(check-app)
ADD_CUSTOM_TARGET(check-app-rtl)
ADD_DEPENDENCIES(check-all check-app)
ADD_SUBDIRECTORY(application)

