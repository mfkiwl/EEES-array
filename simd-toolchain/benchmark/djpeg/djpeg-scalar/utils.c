/*-----------------------------------------*/
/* File : utils.c, utilities for jfif view */
/* Author : Pierre Guerrier, march 1998    */
/*-----------------------------------------*/

#include <stdlib.h>
#include <stdio.h>

#include "jpeg.h"
#include "fio_alt.h"

#ifndef __SOLVER__

/* Prints a data block in frequency space. */
void show_FBlock(FBlock * S) {
  int i, j;
  for (i = 0; i < 8; i++) {
    for (j = 0; j < 8; j++) { ERR("%d ", S->block[i][j]); }
  }
  ERR("\n");
}

/* Prints a data block in pixel space. */
void show_PBlock(PBlock * S) {
  int i, j;
  for (i = 0; i < 8; i++) {
    for (j = 0; j < 8; j++) { ERR("%d  ", S->block[i][j]); }
  }
  ERR("\n");
}

/* Prints the next 800 bits read from file `fi'. */
void bin_dump(FILE * fi) {
  int i;
  for (i = 0; i < 100; i++) {
    unsigned int bitmask;
    int c = FGETC();
    for (bitmask = 0x80; bitmask; bitmask >>= 1) { ERR("\t%1d",!!(c & bitmask));}
    ERR("\n");
  }
}
#endif

/*-------------------------------------------*/
/* core dump generator for forensic analysis */
/*-------------------------------------------*/

void suicide(void) {
#ifdef __SOLVER__
  abort();
#else
  int *P;
  fflush(stdout);
  fflush(stderr);
  P = NULL;
  *P = 1;
#endif
}

/*-------------------------------------------*/

void aborted_stream() {
#ifdef __SOLVER__
  free_structures();
  abort();
#else
  ERR("%ld:\tERROR:\tAbnormal end of decompression process!\n", FTELL());
  ERR("\tINFO:\tTotal skipped bytes %d, total stuffers %d\n", passed, stuffers);
  FCLOSE();
  free_structures();
#ifndef NDEBUG
  suicide();
#endif
#endif
}

/*----------------------------------------------------------*/

/* Returns ceil(N/D). */
int ceil_div(int N, int D) {
  int i = N / D;
  if (N > D * i) { ++i; }
  return i;
}

/* Returns floor(N/D). */
int floor_div(int N, int D) {
  int i = N / D;
  if (N < D * i) { --i;}
  return i;
}

/*----------------------------------------------------------*/

/* For all components reset DC prediction value to 0. */
void reset_prediction(void) {
  int i;
  for (i = 0; i < 3; i++) { comp[i].PRED = 0; }
}

/*---------------------------------------------------------*/

/* Transform JPEG number format into usual 2's-complement format. */
int reformat(unsigned long S, int good) {
  int St;
  if (!good) { return 0; }
  St = 1 << (good - 1);   /* 2^(good-1) */
  if (S < (unsigned long)St) { return (S + 1 + ((-1) << good)); }
  else { return S; }
}

/*----------------------------------------------------------*/

void free_structures(void) {
  //int i;
  //for (i = 0; i < 4; i++)  { if (QTvalid[i]) { free(QTable[i]); } }
  //if (ColorBuffer != NULL) { free(ColorBuffer); }
  //if (FrameBuffer != NULL) { free(FrameBuffer); }
  //if (PBuff != NULL)       { free(PBuff);       }
  //if (FBuff != NULL)       { free(FBuff);       }
  //for (i = 0; MCU_valid[i] != -1; i++) { free(MCU_buff[i]); }
}
