#ifndef _SOLVER_STDINT_H_
#define _SOLVER_STDINT_H_

/* Exact types.  */
/* Signed.  */
typedef signed char             int8_t;
typedef short int               int16_t;
typedef int                     int32_t;
typedef long long int           int64_t;


/* Unsigned.  */
typedef unsigned char           uint8_t;
typedef unsigned short int      uint16_t;
typedef unsigned int            uint32_t;
typedef unsigned long long int  uint64_t;

/* Small types.  */
/* Signed.  */
typedef signed char             int_least8_t;
typedef short int               int_least16_t;
typedef int                     int_least32_t;
typedef long long int           int_least64_t;


/* Unsigned.  */
typedef unsigned char           uint_least8_t;
typedef unsigned short int      uint_least16_t;
typedef unsigned int            uint_least32_t;
typedef unsigned long long int  uint_least64_t;

/* Fast types.  */
/* Signed.  */
typedef int                     int_fast8_t;
typedef int                     int_fast16_t;
typedef int                     int_fast32_t;
typedef long long int           int_fast64_t;

/* Unsigned.  */
typedef unsigned int            uint_fast8_t;
typedef unsigned int            uint_fast16_t;
typedef unsigned int            uint_fast32_t;
typedef unsigned long long int  uint_fast64_t;

typedef long int                intptr_t;
typedef unsigned int            uintptr_t;

typedef long long int           intmax_t;
typedef unsigned long long int  uintmax_t;

#if !defined __cplusplus || defined __STDC_LIMIT_MACROS

#define CHAR_BIT               (8)

/* Minimum of signed integral types.  */
#define INT8_MIN               (-128)
#define INT16_MIN              (-32767-1)
#define INT32_MIN              (-2147483647-1)
#define INT64_MIN              (-9223372036854775807LL-1)
/* Maximum of signed integral types.  */
#define INT8_MAX               (127)
#define INT16_MAX              (32767)
#define INT32_MAX              (2147483647)
#define INT64_MAX              (9223372036854775807LL)

/* Maximum of unsigned integral types.  */
#define UINT8_MAX              (255)
#define UINT16_MAX             (65535)
#define UINT32_MAX             (4294967295U)
#define UINT64_MAX             (18446744073709551615ULL)


/* Minimum of signed integral types having a minimum size.  */
#define INT_LEAST8_MIN         INT8_MIN
#define INT_LEAST16_MIN        INT16_MIN
#define INT_LEAST32_MIN        INT32_MIN
#define INT_LEAST64_MIN        INT64_MIN
/* Maximum of signed integral types having a minimum size.  */
#define INT_LEAST8_MAX         INT8_MAX
#define INT_LEAST16_MAX        INT16_MAX
#define INT_LEAST32_MAX        INT32_MAX
#define INT_LEAST64_MAX        INT64_MAX

/* Maximum of unsigned integral types having a minimum size.  */
#define UINT_LEAST8_MAX        UINT8_MAX
#define UINT_LEAST16_MAX       UINT16_MAX
#define UINT_LEAST32_MAX       UINT32_MAX
#define UINT_LEAST64_MAX       UINT64_MAX

#define INT_FAST8_MIN         INT32_MIN
#define INT_FAST16_MIN        INT32_MIN
#define INT_FAST32_MIN        INT32_MIN
#define INT_FAST64_MIN        INT64_MIN
/* Maximum of fast signed integral types having a minimum size.  */
#define INT_FAST8_MAX         INT32_MAX
#define INT_FAST16_MAX        INT32_MAX
#define INT_FAST32_MAX        INT32_MAX
#define INT_FAST64_MAX        INT64_MAX

/* Maximum of fast unsigned integral types having a minimum size.  */
#define UINT_FAST8_MAX        UINT32_MAX
#define UINT_FAST16_MAX       UINT32_MAX
#define UINT_FAST32_MAX       UINT32_MAX
#define UINT_FAST64_MAX       UINT64_MAX

#define INTPTR_MIN            INT32_MIN
#define INTPTR_MAX            INT32_MAX
#define UINTPTR_MAX           UINT32_MAX

# define INTMAX_MIN           INT64_MIN
# define INTMAX_MAX           INT64_MAX
# define UINTMAX_MAX          UINT64_MAX

#endif/* !defined __cplusplus || defined __STDC_LIMIT_MACROS */

#if !defined __cplusplus || defined __STDC_CONSTANT_MACROS

/* Signed.  */
#define INT8_C(c)      c
#define INT16_C(c)     c
#define INT32_C(c)     c
#define INT64_C(c)    c ## LL

/* Unsigned.  */
#define UINT8_C(c)     c
#define UINT16_C(c)    c
#define UINT32_C(c)    c ## U

#define UINT64_C(c)   c ## ULL

/* Maximal type.  */
#define INTMAX_C(c)   c ## LL
#define UINTMAX_C(c)  c ## ULL

#endif/* !defined __cplusplus || defined __STDC_CONSTANT_MACROS */

#endif/* _SOLVER_STDINT_H_ */
