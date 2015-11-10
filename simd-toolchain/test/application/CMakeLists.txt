MACRO(run_test_app name)
  ADD_CUSTOM_TARGET(check-app-${name})
  ADD_CUSTOM_COMMAND(
    TARGET check-app-${name}
    DEPENDS ${ES_SIMD_TOOL_LIST}
    COMMENT "Running Application Test ${name}"
    COMMAND ${PYTHON_EXECUTABLE}
    ${SIMD-TOOLCHAIN_BINARY_DIR}/lib/solver/python/test_driver/test_tool.py
    --tool-path ${SIMD-TOOLCHAIN_BINARY_DIR}/bin
    --solver-root ${SIMD-TOOLCHAIN_BINARY_DIR}/share/solver
    --test-filename-pattern=*.sir
    ${SIMD-TOOLCHAIN_SOURCE_DIR}/test/application/${name} ${ARGN}
    )
  ADD_DEPENDENCIES(check-app-${name} ${ES_SIMD_TOOL_LIST})
  ADD_DEPENDENCIES(check-app-${name} solvercc solversim)
  ADD_DEPENDENCIES(check-app check-app-${name})
ENDMACRO(run_test_app name)

run_test_app(ffos --parallel)
run_test_app(djpeg --parallel)

MACRO(run_test_app_rtl name)
  ADD_CUSTOM_TARGET(check-app-rtl-${name})
  ADD_CUSTOM_COMMAND(
    TARGET check-app-rtl-${name}
    DEPENDS ${ES_SIMD_TOOL_LIST}
    COMMENT "Running RTL Test ${name}"
    COMMAND ${PYTHON_EXECUTABLE}
    ${SIMD-TOOLCHAIN_BINARY_DIR}/lib/solver/python/test_driver/test_tool.py
    --tool-path ${SIMD-TOOLCHAIN_BINARY_DIR}/bin
    --solver-root ${SIMD-TOOLCHAIN_BINARY_DIR}/share/solver
    --run-rtl --rtl-flow ${RTL_FLOW}
    --test-filename-pattern=*.sir
    ${SIMD-TOOLCHAIN_SOURCE_DIR}/test/application/${name} ${ARGN}
    )
  ADD_DEPENDENCIES(check-app-rtl-${name} ${ES_SIMD_TOOL_LIST})
  ADD_DEPENDENCIES(check-app-rtl-${name} solvercc solversim solverrtlgen)
  ADD_DEPENDENCIES(check-app-rtl check-app-rtl-${name})
ENDMACRO(run_test_app_rtl name)

IF(RTL_FLOW)
  run_test_app_rtl(djpeg --parallel)
  run_test_app_rtl(ffos --parallel)
ENDIF(RTL_FLOW)
