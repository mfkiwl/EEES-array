#ifndef _SOLVER_STDIO_H_
#define _SOLVER_STDIO_H_

#include <stddef.h>

typedef unsigned int FILE;

#ifndef EOF
#define EOF (-1)
#endif

#define SEEK_SET        0       /* Seek from beginning of file.  */
#define SEEK_CUR        1       /* Seek from current position.  */
#define SEEK_END        2       /* Seek from end of file.  */

#endif//_SOLVER_STDIO_H_
