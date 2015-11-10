#ifndef _SOLVER_STDDEF_H_
#define _SOLVER_STDDEF_H_

#undef NULL
#if defined(__cplusplus)
#define NULL (0)
#else
#define NULL ((void *)0)
#endif

typedef unsigned long size_t;

#endif//_SOLVER_STDDEF_H_
