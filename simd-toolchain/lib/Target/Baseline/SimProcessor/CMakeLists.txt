ADD_LIBRARY(BaselineSimProcessor SHARED
  BaselineSimProcessor.cc)

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR}/.. 
  ${CMAKE_CURRENT_SOURCE_DIR}/.. )

TARGET_LINK_LIBRARIES(BaselineSimProcessor BaselineTarget Simulation)

INSTALL(TARGETS BaselineSimProcessor LIBRARY DESTINATION lib)

