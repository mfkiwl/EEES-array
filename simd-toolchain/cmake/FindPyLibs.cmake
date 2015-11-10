# - Try to find Python library. The built-in module tend to find
# the wrong version when there are multiple version. This will define
#
#  PYTHONLIBS_FOUND - system has Python library
#  PYHTON_INCLUDE_PATH - the Python include directories
#  PYTHON_LIBRARIES - link these to use Python library


IF(PYTHONINTERP_FOUND)
  SET(PYCONFIG ${PYTHON_EXECUTABLE}-config)
  EXEC_PROGRAM(${PYCONFIG} ARGS --includes OUTPUT_VARIABLE PYINCS)
  STRING(REPLACE " " ";" PYINCS_LIST ${PYINCS})
  FOREACH(I ${PYINCS_LIST})
    IF("${I}" MATCHES "^-I")
      STRING(REGEX REPLACE "^-I(.*)" "\\1" PYTHON_INCLUDE_PATH "${I}")
    ENDIF("${I}" MATCHES "^-I")
  ENDFOREACH(I)

  EXEC_PROGRAM(${PYCONFIG} ARGS --libs OUTPUT_VARIABLE PYLIBS)
  STRING(REPLACE " " ";" PYLIBS_LIST ${PYLIBS})
  FOREACH(L ${PYLIBS_LIST})
    IF("${L}" MATCHES "^-lpython")
      SET(PYTHONLIBS_FOUND TRUE)
      STRING(REGEX REPLACE "^-l(.*)" "\\1" PYTHON_LIBRARIES "${L}")
    ENDIF("${L}" MATCHES "^-lpython")
  ENDFOREACH(L)

  EXEC_PROGRAM(${PYCONFIG} ARGS --prefix OUTPUT_VARIABLE PYPREFIX)

IF (PYTHONLIBS_FOUND)
  MESSAGE(STATUS "Found Python library: ${PYTHON_LIBRARIES}")
  MESSAGE(STATUS "Python library include path: ${PYTHON_INCLUDE_PATH}")
ELSE (PYTHONLIBS_FOUND)
  MESSAGE(STATUS "Could not find Python library")
ENDIF (PYTHONLIBS_FOUND)

ENDIF(PYTHONINTERP_FOUND)
