INCLUDE_DIRECTORIES(${SIMD-TOOLCHAIN_SOURCE_DIR}/extra/gtest/include)

ADD_CUSTOM_TARGET(unittest)

MACRO(run_unittest name)
  ADD_CUSTOM_TARGET(run-${name} ${name} ${ARGN}
  DEPENDS ${name}
  COMMENT "Running Unit Test ${name}")
  ADD_DEPENDENCIES(unittest run-${name})
ENDMACRO(run_unittest name)


SUBDIRS(SIR Utils)
