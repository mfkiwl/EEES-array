#include <stdio.h>

#include "fio_alt.h"
#include "jpeg.h"

#ifndef __SOLVER__
/* input  File stream pointer   */
FILE *fi;
#endif

unsigned int input_buffer[JPGBUFFER_SIZE / sizeof(int)];
int vld_count;

unsigned int FGETC() {
#ifndef __SOLVER__
  int i = 3 - vld_count % 4;
#else
  int i = 3- vld_count % 4;
#endif
  unsigned int c
    = ((input_buffer[vld_count / 4] << (8 * i)) >> 24) & 0x00ff;
  vld_count++;
  return c;
}

int FSEEK(int offset, int start) {
  vld_count += offset + (start - start);    /* Just to use start... */
  return 0;
}

long FTELL() { return vld_count; }

int FOPEN(char* file, char* mode) {
#ifndef __SOLVER__
  fi = fopen(file, mode);
  if (fi == NULL) { MSG("unable to open the file %s\n", file); return 0; }
  fread(input_buffer, 1, JPGBUFFER_SIZE, fi);
  fclose(fi);
  fi = fopen(file, mode);
#endif
  vld_count = 0;
  return 1;
}

void FCLOSE() {}
