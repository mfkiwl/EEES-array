#include <stdio.h>
#include <stdlib.h>
#include "ffos.h"

// start of erosion
void
erode(unsigned char * data, int w, int h){
    int i, j;
    
//	int Kernel[3][3];
//	if (Kernel_Type == 0) {
//		Kernel[0][0] = 1;  Kernel[0][1] = 1;  Kernel[0][2] = 1;
//		Kernel[1][0] = 1;  Kernel[1][1] = 1;  Kernel[1][2] = 1;
//		Kernel[2][0] = 1;  Kernel[2][1] = 1;  Kernel[2][2] = 1;		
//	}
//	else {
//		Kernel[0][0] = 0;  Kernel[0][1] = 1;	Kernel[0][2] = 0;
//		Kernel[1][0] = 1;	 Kernel[1][1] = 1;  Kernel[1][2] = 1;
//		Kernel[2][0] = 0;  Kernel[2][1] = 1;  Kernel[2][2] = 0;		
//	}
	
    // erosion: for efficiency/simplicity reason,
    // the border pixels are not processed
    // (which can be dealt later.)
#ifndef __SOLVER__
    printf("Kernel_Type = %d\n", Kernel_Type);
#endif
    // As input image and output image share the same memory space,
    // we need a temporary buffer
    unsigned char *Temp[2];
    Temp[0] = malloc(w*sizeof(unsigned char));
    Temp[1] = malloc(w*sizeof(unsigned char));
    
    int index = 0;

    for(i = 1; i < h-1; i++) {
      for(j = 1; j < w-1; j++) {
        if (i > 2) { data[(i-2)*w+j] = Temp[index][j]; }
        Temp[index][j] = (data[(i-1)*w+j]  && data[i*w+j-1]         \
                          && data[(i  )*w+j]  && data[i*w+j+1]      \
                          && data[(i+1)*w+j]) ? 255 : 0;
      }
      index = (index + 1) % 2;
    }
    for (j = 1; j < w-1; j++) { data[((h-1)-2)*w+j] = Temp[index][j]; }
    index = (index + 1) % 2;
    for (j = 1; j < w-1; j++)  { data[((h-1)-1)*w+j] = Temp[index][j]; }
    free(Temp[0]);
    free(Temp[1]);
}// end erode()
