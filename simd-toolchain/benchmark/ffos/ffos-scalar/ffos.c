#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ffos.h"


ffos_cfg_t global_cfg;

static void 
binarization(unsigned char * bin_img, unsigned char * img,
             int threshold, int w, int h) {
  int i;
  for(i = 0; i < w*h; i++){ bin_img[i] = (img[i] >= threshold) ? 0xFF : 0; }
}// binarization()

//==========================
//  Process Function
//==========================
void
ffos_process_image (unsigned char *data, int w, int h) {
  int threshold = otsu_i(data, w, h);
  global_cfg.otsu_threshold = threshold;
#ifndef __SOLVER__
  printf("otsu threshold: %d\n",threshold);
#endif
  // temporary data after image processing
  unsigned char * _temp = malloc(w * h * sizeof(unsigned char));
  unsigned char * pbuf  = malloc(w * h * sizeof(unsigned char));
  int erosion_count = global_cfg.erosion_count;
  memcpy(_temp, data, w * h * sizeof(unsigned char));
  binarization(pbuf, data, threshold, w, h);
  // erosion on the binary image
  for(int count = 1; count <= erosion_count; count++){
#ifndef __SOLVER__
    printf("erosion count = %d\n", count);
#endif
    erode(pbuf, w, h);
  }// end count
  // for temporary debug
#ifndef __SOLVER__
  write_pgm(pbuf, w, h, "erosion.pgm");
#endif

  int * x_point      = malloc(w*sizeof(int));
  int * y_point      = malloc(h*sizeof(int));
  int   num_center_x = calculate_x_position(pbuf, x_point, w, h);
  int   num_center_y = calculate_y_position(pbuf, y_point, w, h);
  global_cfg.num_x = num_center_x;
  global_cfg.num_y = num_center_y;
#ifndef __SOLVER__
  draw_bounding_box(_temp, w, h, x_point, y_point, num_center_x, num_center_y);
  // for temporary debug
  write_pgm((unsigned char *)_temp, w, h, "BondBox.pgm");
#endif
  //  localize the middle detected oled
  // firstly, locate the center oled (more complex methods can be used!)
    
  // coordinate of the middle led
  int index_center_x = num_center_x/2; 
  int index_center_y = num_center_y/2; 
  // approximate center of oled
  int   center_x = x_point[index_center_x];
  int   center_y = y_point[index_center_y];
  // decide the bonding box (consider the corner cases)
  rectangle box = get_bounding_box(center_x, center_y, w, h);

  int cog_x_i, cog_y_i;
  center_of_gravity_i(&cog_x_i, &cog_y_i, data, w, &box);
  global_cfg.cog_x_c = cog_x_i;
  global_cfg.cog_y_c = cog_y_i;

    
  free(x_point);
  free(y_point); 
  free(pbuf   );
  free(_temp  );
#ifndef __SOLVER__
  //Processing finished, print the results
  printf("==========================\n");
  printf("detected x positions = %d \n", num_center_x);
  printf("detected y positions = %d \n", num_center_y);
  printf("detected OLED = %d\n", num_center_x * num_center_y);
  if( (num_center_x == 0) || (num_center_y == 0) ){
    printf("WARNING: no OLED detected!!!\n");
  }
  printf("==========================\n");
    
  printf("index_center_x = %d\n", index_center_x);
  printf("index_center_y = %d\n", index_center_y);
  printf("num_center_x = %d\n", num_center_x);
  printf("num_center_y = %d\n", num_center_y);
  printf("==========================\n");
  printf("==========================\n");
  printf("Bonding Box of Center OLED\n");
  printf("(y_NW ,x_NW) = (%d, %d)\n", box.y_nw, box.x_nw);
  printf("(y_SE ,x_SE) = (%d, %d)\n", box.y_se, box.x_se);
  printf("==========================\n");
  printf("Calculated (moment) x, y position of the middle OLED\n");
  printf("x position of center OLED = %d (INT)\n", cog_x_i);
  printf("y position of center OLED = %d (INT)\n", cog_y_i);
  printf("==========================\n");
#endif
} // end process_image()


