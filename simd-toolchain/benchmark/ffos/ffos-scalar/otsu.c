#include "ffos.h"
#include <stdio.h>
#include <stdlib.h>

/**
 *  otsu algorithm to find threshold of binarization integer version
 *  @param data input image
 *  @param w    the width of input image
 *  @param h    the height of input image
 *  @return     the threshold of binarization
 */
int
otsu_i(unsigned char * data, int w, int h){
  int i, k;
  int T   = 0;        // threshold for binarization
  unsigned long max = 0;      // max sigma value
  unsigned int  sum = 0;
  unsigned int  a_k = 0;
  unsigned int  sum_k = 0;
  unsigned int  pi[256];       // histogram
  unsigned long sigmaB[256];  
  
  // initialization
  for (i = 0; i < 256; i++){
    pi[i]     = 0;
    sigmaB[i] = 0;
  }
  
  /* build histogram */
  for(i = 0; i < h*w; i++){ ++pi[ data[i] ]; }

  for( i = 0; i < 256; i++ ){ sum = sum + i*pi[i]; }
#ifndef __SOLVER__
  printf("otsu: sum=%d\n", sum);
#endif
/* calculate each probability */
  int s  = (w * h);
  for(k = 0; k <256; k++){
    a_k = a_k + pi[k];          // cumulative probability up till class k
    sum_k = sum_k + (k*pi[k]);  // cumulative mean up till class k

    // calculate sigma
    if(((s - a_k) != 0 ) && ( a_k != 0)){
      unsigned int temp_1 = (sum_k << 11) / a_k;
      temp_1 = (s * temp_1) >> 11;
      unsigned int temp_2 = (sum - sum_k) << 11;
      temp_2 = temp_2 / (s - a_k);
      temp_2 = (a_k * temp_2) >> 11;
      sigmaB[k] = ( ( sum - temp_1 ) )  * ( ( temp_2 - sum_k ) );
    } else { sigmaB[k] = 0; }// ((s - a_k) != 0 ) && ( a_k != 0)
/* #ifndef __SOLVER__ */
/*     printf("sigmaB[%d] = %lu (%lx)\n", k, sigmaB[k], sigmaB[k]); */
/* #endif */
  }// end k

  /* maximum of sigmaB */
  for(i = 0; i < 256; i++){
    if(sigmaB[i] > max){
      max = sigmaB[i];
      T = i;
    }
  }// end i
  return T;
}// otsu_i()

