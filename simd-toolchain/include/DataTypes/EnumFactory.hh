#ifndef ES_SIMD_ENUMFACTORY_HH
#define ES_SIMD_ENUMFACTORY_HH

#include <iostream>
#include <cstring>

// expansion macro for enum value definition
#define ENUM_ITEM(name) name,
#define ENUM_VALUE(name,assign) name=assign,

// expansion macro for enum to string conversion
#define ENUM_ITEM_CASE(name) case name: return #name;
#define ENUM_VALUE_CASE(name,assign) case name: return #name;

// expansion macro for string to enum conversion
#define ENUM_ITEM_STRCMP(name) if (!strcmp(str,#name)) return name;
#define ENUM_VALUE_STRCMP(name,assign) if (!strcmp(str,#name)) return name;

/// declare the access function and define enum values
#define DECLARE_ENUM(EnumType,ENUM_DEF)                           \
  namespace EnumType {                                            \
    enum EnumType##_type {                                        \
      ENUM_DEF(ENUM_ITEM, ENUM_VALUE)                             \
        EnumType##End                                             \
        };                                                        \
    const char *GetString(EnumType::EnumType##_type dummy);       \
  }                                                               \
  typedef EnumType::EnumType##_type EnumType##_t;                 \
  const char *GetEnumType##String(EnumType##_t dummy);            \
  EnumType##_t GetValue##EnumType(const char *str);               \
  std::ostream& operator<<(std::ostream& out,                     \
                           const EnumType##_t& d);
    
/// define the access function names
#define DEFINE_ENUM(NS,EnumType,ENUM_DEF)                             \
  const char* NS::EnumType::GetString(EnumType##_t value) {           \
    using namespace EnumType;                                         \
    switch(value) {                                                   \
      ENUM_DEF(ENUM_ITEM_CASE, ENUM_VALUE_CASE)                       \
    default: return "Unknown";                                        \
    }                                                                 \
  }                                                                   \
  const char* NS::GetEnumType##String(EnumType##_t value) {           \
    using namespace EnumType;                                         \
    switch(value) {                                                   \
      ENUM_DEF(ENUM_ITEM_CASE, ENUM_VALUE_CASE)                       \
    default: return "Unknown";                                        \
    }                                                                 \
  }                                                                   \
  EnumType##_t NS::GetValue##EnumType(const char *str) {              \
    using namespace EnumType;                                         \
    ENUM_DEF(ENUM_ITEM_STRCMP, ENUM_VALUE_STRCMP)                     \
      return EnumType##End;                                           \
  }                                                                   \
  std::ostream& NS::operator<<(std::ostream& out,                     \
                               const EnumType##_t& f) {               \
    return out << EnumType::GetString(f);                             \
  }                                                                   \

/// define the access function names for global namespace
#define DEFINE_ENUM_GLOBAL(EnumType,ENUM_DEF)                   \
  const char* GetString(EnumType##_t value) {                   \
    using namespace EnumType;                                   \
    switch(value) {                                             \
      ENUM_DEF(ENUM_CASE)                                       \
    default: return "Unknown";                                  \
    }                                                           \
  }                                                             \
  EnumType##_t GetValue##EnumType(const char *str) {  \
    using namespace EnumType;                                   \
    ENUM_DEF(ENUM_STRCMP)                                       \
      return EnumType##End;                                     \
  }                                                             \
  std::ostream& operator<<(std::ostream& out,                   \
                           const EnumType##_t& f) {             \
    return out << GetString(f);                                 \
  }                                                             \

#endif//ES_SIMD_ENUMFACTORY_HH
