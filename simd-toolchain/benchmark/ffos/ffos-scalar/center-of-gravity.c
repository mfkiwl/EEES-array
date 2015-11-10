#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ffos.h"

void 
center_of_gravity_i(int * cog_x, int * cog_y, unsigned char * data, int w,
                    rectangle* box) {
  int i, j;
  int x_start=box->x_nw, x_end=box->x_se, y_start=box->y_nw, y_end=box->y_se;
  // get spatial moment from greyscale oled image (not binary!)	
  int sum = 0;
  int CoG_x = 0;
  int CoG_y = 0;
    
  for( i = y_start; i <= y_end; i++ ){
    int row_addr = i * w;
        
    for ( j = x_start; j <= x_end; j++){
      int addr = row_addr + j;
      int pix  = data[addr];
      sum += pix;
      CoG_x = CoG_x + pix * j;
      CoG_y = CoG_y + pix * i;
    } // end j 
  } // end i

  *cog_x = (CoG_x + (sum>>1)) / sum;
  *cog_y = (CoG_y + (sum>>1)) / sum;
}

int
calculate_x_position(unsigned char * pbuf, int * x_point, 
                     int w, int h) {
  int i, j;
  int * width_array  = malloc(w * sizeof(int));// column vector

  // generate the column vector  
  for(i = 0; i < w; i++) {
    width_array[i] = 0;
  
    for(j = 0; j < h; j++){
      width_array[i] = width_array[i] + pbuf[j * w + i];
    }// end j
        
    if( width_array[i] <= TR_COLUMN_VECTOR ){
      width_array[i] = 0;
    }else{
      width_array[i] = 1;
    }
  }// end i
  
  // post-processing
  // Note: only a simple post-processing is applied here, and
  // the result for a still image is good. If necessary, more
  // steps can be added
  int start = 0;         // flag: indicate a start of a line segment
  //int point_count = 0; // length of a line segment
  int x_start, x_end;    // start and end x coordinates of a line segment
  int index = 0;         // 
  int num_center_x = 0;  // number of detected oled center x coordinates

  x_start = 0; // avoid warning
    
  for(i = 0; i < w; i++) {
    // start of a line segment
    if( (width_array[i] == 1) && (start == 0) ) {
      start = 1;     
      x_start = i;
    }else if( (width_array[i] == 0) && (start == 1) ){
      start = 0;
      x_end = i;
            
      if( (x_end - x_start) > TR_COLUMN_LINE_LENGTH) {
        // an intersting line segment
        num_center_x++;
        x_point[index] = (x_end + x_start)/2;
#ifndef __SOLVER__
        printf("x_point[%d] = %d\n",index, x_point[index]);
#endif
        index++;
      }
    }
      
  } // end i

  free(width_array);
  return num_center_x;
    
}// calculate_x_position()

int
calculate_y_position(unsigned char * pbuf, int * y_point, 
                     int w, int h){
  int * height_array = malloc(h*sizeof(int));// row vector
    
  // generate the row vector
  for(int height = 0; height < h; height++) {
    height_array[height] = 0;

    for(int width = 0; width < w; width++){
      height_array[height] = height_array[height]
        + pbuf[height*w+width];
    }// end width

    if( height_array[height] < TR_ROW_VECTOR )
      height_array[height] = 0;
    else
      height_array[height] = 1;
  } // end height

    // post-processing 
    // Note: only a simple post-processing is applied here, and 
    // the result for a still image is good. If necessary, more
    // steps can be added)
  int start = 0;
  int y_start, y_end;
  int index = 0;
  int num_center_y = 0;  // number of detected oled center y coordinates
  y_start = 0;  // avoid warning
  for(int height = 0; height < h; height++) {
    if( (height_array[height] == 1) && (start == 0) ) {
      // start of a line segment
      start = 1;
      y_start = height;
    }
    else if( (height_array[height] == 0) && (start == 1) ) {
      start = 0;
      y_end = height;
  
      if( (y_end - y_start) > TR_ROW_LINE_LENGTH) {       
        // an intersting line segment
        num_center_y++;
        y_point[index] = (y_end + y_start)/2;
        // printf("y_point[%d] = %d\n",index, y_point[index]);
        index++;
      }
    }  
  } // end height

  free(height_array);
  return num_center_y;

}// calculate_x_position()
