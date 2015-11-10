ADD_CUSTOM_TARGET(benchmark)

MACRO(run_bench_dir name)
  ADD_CUSTOM_TARGET(bench-${name})
  ADD_CUSTOM_COMMAND(
    TARGET bench-${name}
    DEPENDS ${ES_SIMD_TOOL_LIST}
    COMMENT "Running Benchmark ${name}"
    COMMAND ${PYTHON_EXECUTABLE}
    ${SIMD-TOOLCHAIN_BINARY_DIR}/lib/solver/python/test_driver/bench_tool.py
    --solver-path ${SIMD-TOOLCHAIN_BINARY_DIR}/bin
    --solver-target-root ${SIMD-TOOLCHAIN_BINARY_DIR}/share/solver
    --arch-dir ${SIMD-TOOLCHAIN_SOURCE_DIR}/solver/arch
    ${SIMD-TOOLCHAIN_SOURCE_DIR}/benchmark/${name} ${ARGN}
    )
  ADD_DEPENDENCIES(benchmark bench-${name})
  ADD_DEPENDENCIES(bench-${name} ${ES_SIMD_TOOL_LIST})
  ADD_DEPENDENCIES(bench-${name} solvercc solversim)
ENDMACRO(run_bench_dir name)

run_bench_dir(scalar)
run_bench_dir(ffos)
run_bench_dir(djpeg)

ADD_CUSTOM_TARGET(compare)

MACRO(cmp_bench_dir name)
  ADD_CUSTOM_TARGET(cmp-bench-${name})
  ADD_CUSTOM_COMMAND(
    TARGET cmp-bench-${name}
    DEPENDS ${ES_SIMD_TOOL_LIST}
    COMMENT "Comparing stat for benchmark set ${name}"
    COMMAND ${PYTHON_EXECUTABLE}
    ${SIMD-TOOLCHAIN_BINARY_DIR}/lib/solver/python/test_driver/bench_cmp.py
    --arch-dir ${SIMD-TOOLCHAIN_SOURCE_DIR}/solver/arch
    ${SIMD-TOOLCHAIN_SOURCE_DIR}/benchmark/${name} ${ARGN}
    )
  ADD_DEPENDENCIES(compare cmp-bench-${name})
  ADD_DEPENDENCIES(cmp-bench-${name} ${ES_SIMD_TOOL_LIST})
  ADD_DEPENDENCIES(cmp-bench-${name} solvercc solversim)
ENDMACRO(cmp_bench_dir name)

cmp_bench_dir(scalar)
cmp_bench_dir(ffos)
cmp_bench_dir(djpeg)
