#ifndef __SOLVER__
#include <stdlib.h>
#include <stdio.h>
#include "jpeg.h"

void write_bmp(const char *const file2) {
  FILE *fpBMP;

  int i, j;

  // Header and 3 bytes per pixel
  unsigned long ulBitmapSize = ceil_div(24*x_size, 32)*4*y_size+54; 
  char ucaBitmapSize[4];

  ucaBitmapSize[3] = (ulBitmapSize & 0xFF000000) >> 24;
  ucaBitmapSize[2] = (ulBitmapSize & 0x00FF0000) >> 16;
  ucaBitmapSize[1] = (ulBitmapSize & 0x0000FF00) >> 8;
  ucaBitmapSize[0] = (ulBitmapSize & 0x000000FF);

  /* Create bitmap file */
  fpBMP = fopen(file2, "wb");
  if (fpBMP == 0)
    return;

  /* Write header */
  /* All values are in big endian order (LSB first) */

  // BMP signature + filesize
  fprintf(fpBMP, "%c%c%c%c%c%c%c%c%c%c", 66, 77, ucaBitmapSize[0],
          ucaBitmapSize[1], ucaBitmapSize[2], ucaBitmapSize[3], 0, 0, 0, 0);

  // Image offset, infoheader size, image width
  fprintf(fpBMP, "%c%c%c%c%c%c%c%c%c%c", 54, 0, 0, 0, 40, 0, 0, 0, (x_size & 0x00FF), (x_size & 0xFF00) >> 8);

  // Image height, number of panels, num bits per pixel
  fprintf(fpBMP, "%c%c%c%c%c%c%c%c%c%c", 0, 0, (y_size & 0x00FF), (y_size & 0xFF00) >> 8, 0, 0, 1, 0, 24, 0);

  // Compression type 0, Size of image in bytes 0 because uncompressed
  fprintf(fpBMP, "%c%c%c%c%c%c%c%c%c%c", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  fprintf(fpBMP, "%c%c%c%c%c%c%c%c%c%c", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  fprintf(fpBMP, "%c%c%c%c", 0, 0, 0, 0);

  for (i = y_size - 1; i >= 0; i--) {
    /* in bitmaps the bottom line of the image is at the
       beginning of the file */
    for (j = 0; j < x_size; j++) {
      putc(FrameBuffer[3 * (i * x_size + j) + 0], fpBMP);
      putc(FrameBuffer[3 * (i * x_size + j) + 1], fpBMP);
      putc(FrameBuffer[3 * (i * x_size + j) + 2], fpBMP);
    }
    for (j = 0; j < x_size % 4; j++)
      putc(0, fpBMP);
  }

  fclose(fpBMP);
}

#endif//__SOLVER__
