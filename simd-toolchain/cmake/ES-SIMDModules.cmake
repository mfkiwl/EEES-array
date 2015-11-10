MACRO(add_es_simd_tool name src_list)
  ADD_EXECUTABLE(${name} ${src_list})
  TARGET_LINK_LIBRARIES(${name} ${ARGN})
  TARGET_LINK_LIBRARIES(${name} ${es_simd_system_libs})
  LIST(APPEND ES_SIMD_TOOL_LIST ${name})
ENDMACRO(add_es_simd_tool name)

FUNCTION(find_python_module module)
	STRING(TOUPPER ${module} module_upper)
	IF(NOT PY_${module_upper})
		IF(ARGC GREATER 1 AND ARGV1 STREQUAL "REQUIRED")
			SET(${module}_FIND_REQUIRED TRUE)
		ENDIF(ARGC GREATER 1 AND ARGV1 STREQUAL "REQUIRED")
		# A module's location is usually a directory, but for binary modules
		# it's a .so file.
		EXECUTE_PROCESS(COMMAND "${PYTHON_EXECUTABLE}" "-c" 
			"import re, ${module}; print re.compile('/__init__.py.*').sub('',${module}.__file__)"
			RESULT_VARIABLE _${module}_status 
			OUTPUT_VARIABLE _${module}_location
			ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
		IF(NOT _${module}_status)
			SET(PY_${module_upper} ${_${module}_location} CACHE STRING 
				"Location of Python module ${module}")
		ENDIF(NOT _${module}_status)
	ENDIF(NOT PY_${module_upper})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(PY_${module} DEFAULT_MSG PY_${module_upper})
ENDFUNCTION(find_python_module)
