SET(ES_SIMD_TOOL_LIST "")

ADD_SUBDIRECTORY(s-as)
GET_DIRECTORY_PROPERTY(ES_SIMD_TOOL_LIST DIRECTORY s-as DEFINITION ES_SIMD_TOOL_LIST)


ADD_SUBDIRECTORY(s-cg)
GET_DIRECTORY_PROPERTY(ES_SIMD_TOOL_LIST DIRECTORY s-cg DEFINITION ES_SIMD_TOOL_LIST)

ADD_SUBDIRECTORY(s-sim)
GET_DIRECTORY_PROPERTY(ES_SIMD_TOOL_LIST DIRECTORY s-sim DEFINITION ES_SIMD_TOOL_LIST)
