# - Try to find Lemon
# Once done, this will define
#
#  LEMON_FOUND - system has Lemon
#  LEMON_INCLUDE_DIR - the Lemon include directories
#  LEMON_LIBRARY_DIR - link these to use Lemon

# Find the include directory
FIND_PATH(LEMON_INCLUDE_DIR NAMES lemon/list_graph.h
  PATHS /usr/include /usr/local/include ${CMAKE_INCLUDE_PATH}
  ${CMAKE_PREFIX_PATH}/include $ENV{LEMONDIR}/include)

# Find the library itself
FIND_LIBRARY(LEMON_LIBRARY_DIR NAMES emon PATHS /usr/lib /usr/local/lib
  ${CMAKE_LIBRARY_PATH} ${CMAKE_PREFIX_PATH}/lib $ENV{LEMONDIR}/lib)

# handle the QUIETLY and REQUIRED arguments and set LLVM_FOUND to TRUE if
# all listed variables are TRUE
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LEMON DEFAULT_MSG LEMON_INCLUDE_DIR
  LEMON_LIBRARY_DIR)
