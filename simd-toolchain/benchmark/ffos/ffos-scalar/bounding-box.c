#include "ffos.h"

// decide the bonding box (consider the corner cases)
rectangle
get_bounding_box(int center_x, int center_y, int w, int h){
  int box_width = global_cfg.bonding_box_width;
  int box_height = global_cfg.bonding_box_height;
  rectangle box;
  int center_offset_w = box_width  / 2;
  int center_offset_h = box_height / 2;
  box.x_nw = ((center_x - center_offset_w ) < 0) ? \
    0 : (center_x - center_offset_w);
  box.y_nw = ( (center_y - center_offset_h ) < 0 )? \
    0 : (center_y - center_offset_h);
    	
  box.x_se = ( (center_x + center_offset_w ) >= w ) ? \
    (w - 1) : (center_x + center_offset_w);
  box.y_se = ( (center_y + center_offset_h ) >= h ) ? \
    (h - 1) : (center_y + center_offset_h);
    
  return box;
}


#ifndef __SOLVER__
//  simple case: draw the bonding box of detected oled
//  Not part of the processing, just for display
void
draw_bounding_box(unsigned char * data,
                  int w, int h,
                  int * x_point, int * y_point,
                  int num_center_x, int num_center_y){

  int index_x, index_y, i;
  int center_x;  // center x coordinates
  int center_y;  // center y coordinates
  rectangle box; // bonding box 
    
  for(index_x = 0; index_x < num_center_x; index_x++){
    for(index_y = 0; index_y < num_center_y; index_y++){
      // approximate center of oled
      center_x =  x_point[index_x]; 
      center_y =  y_point[index_y];        
            
      data[center_y     * w + center_x]   = 255;
      data[(center_y-1) * w + center_x] = 255;
      data[(center_y+1) * w + center_x] = 255;
      data[center_y     * w + center_x-1] = 255;
      data[center_y     * w + center_x+1] = 255;
      
      box = get_bounding_box(center_x, center_y, w, h);
            
      for( i = box.x_nw; i <= box.x_se; i++ ) {
        data[box.y_nw * w + i] = 255;
        data[box.y_se * w + i] = 255;
      }// end i
      
      for( i = box.y_nw; i <= box.y_se; i++ ) {
        data[i * w + box.x_nw] = 255;
        data[i * w + box.x_se] = 255;
      }// end i
    } // end index_y
  }// end index_x
}

#endif
