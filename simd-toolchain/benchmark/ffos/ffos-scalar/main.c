#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ffos.h"

#ifdef __SOLVER__
extern unsigned char input_buffer[8800];
#endif
//==========================
//  The Main Function
//==========================
int
main(){
  int w = 160;
  int h = 55;
#ifndef __SOLVER__
  unsigned char * input_buffer;
#endif
  global_cfg.img_width          = 160;
  global_cfg.img_height         = 55;
  global_cfg.oled_width         = 36;
  global_cfg.oled_height        = 12;
  global_cfg.bonding_box_width  = 36 + 4;
  global_cfg.bonding_box_height = 12 + 4;
  global_cfg.erosion_count      = 3;
  global_cfg.col_threshold      = 5 * 255;
  global_cfg.col_line_threshold = 15;
  global_cfg.row_threshold      = 5 * 255;
  global_cfg.row_line_threshold = 3;
#ifndef __SOLVER__
  input_buffer = read_pgm(&w, &h, "original_3.pgm");
  /* for (int i = 1; i <= w*h; ++i) { */
  /*     printf("%3d, ", input_buffer[i-1]); */
  /*     if ((i % 8) == 0) { printf("\n"); } */
  /* } */
#endif
  
  ffos_process_image(input_buffer, w, h);

#ifndef __SOLVER__
  free(input_buffer);
#endif
  return 0;
}
