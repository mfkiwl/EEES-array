#ifndef ES_SIMD_LOGUTILS_HH
#define ES_SIMD_LOGUTILS_HH

#define ES_LOG(lstream, msg) do {               \
    lstream << msg;                             \
  } while(0);


#define ES_LOG_P(cond, lstream, msg) do {       \
    if (cond) {                                 \
      lstream << msg;                           \
    }                                           \
  } while(0);

#define ES_WARNING_MSG(lstream, msg) do {       \
    lstream <<"[WARNING]: "<< msg;              \
  } while(0);

#define ES_ERROR_MSG(lstream, msg) do {         \
    lstream <<"[ERROR]: "<< msg;                \
  } while(0);

#define ES_WARNING_MSG_T(lstream, ty, msg) do { \
    lstream <<"["<< ty <<" WARNING]: "<< msg;   \
  } while(0);

#define ES_ERROR_MSG_T(lstream, ty, msg) do {   \
    lstream <<"["<< ty <<" ERROR]: "<< msg;     \
  } while(0);


#endif//ES_SIMD_LOGUTILS_HH
