#ifndef _SOLVER_STDLIB_H_
#define _SOLVER_STDLIB_H_

#include <stddef.h>

#define EXIT_SUCCESS 0

/*
  Memory management functions
 */
extern void* malloc  (size_t size);
extern void* calloc  (size_t num, size_t size);
extern void* realloc (void* ptr, size_t size);

extern void  free (void* p);

/*
  System functions
 */
extern void  abort ();
extern void  exit  (int);

extern int abs(int);

#endif//_SOLVER_STDLIB_H_
