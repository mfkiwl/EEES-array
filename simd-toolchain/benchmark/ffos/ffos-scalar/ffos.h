#ifndef _FFOS_H
#define _FFOS_H

//**********************
//  Macro Definition
//**********************
#define OLED_WIDTH   36              // width of the OLED
#define OLED_HEIGHT  12              // height of the OLED

#define OFFSET_BONDING_WIDTH     4   // width of bonding box - width of oled
#define OFFSET_BONDING_HEIGHT    4   // height of bonding box - height of oled

// width and height of bonding box
#define BONDING_BOX_WIDTH    (OLED_WIDTH  + OFFSET_BONDING_WIDTH)   
#define BONDING_BOX_HEIGHT   (OLED_HEIGHT + OFFSET_BONDING_HEIGHT)

#define EROSION_COUNT            3       // number of erosions

// threshold for the column vector: = number of points x 255
#define TR_COLUMN_VECTOR         5*255

// threshold to detect an interesting line segment,
// depends on the pratical situation
#define TR_COLUMN_LINE_LENGTH    15                     

// threshold for the row vector: = number of points x 255
#define TR_ROW_VECTOR            5*255

// threshold to detect an interesting line segment,
// depends on the pratical situation
#define TR_ROW_LINE_LENGTH       3

typedef struct {
    int x_nw;
    int y_nw;
    int x_se;
    int y_se;
} rectangle;

typedef struct {
  int img_width;
  int img_height;
  int oled_width;
  int oled_height;
  int bonding_box_width;
  int bonding_box_height;
  int erosion_count;
  int col_threshold;
  int col_line_threshold;
  int row_threshold;
  int row_line_threshold;
  int otsu_threshold;
  int num_x;
  int num_y;
  int cog_x_c;
  int cog_y_c;
} ffos_cfg_t;

extern ffos_cfg_t global_cfg;

//**********************
//  Functions
//**********************
int  otsu_i(unsigned char * data, int w, int h);
void erode(unsigned char * data, int w, int h);
void ffos_process_image(unsigned char * data, int w, int h);
int  calculate_x_position(unsigned char * pbuf, int * x_point, 
                          int w, int h);
int  calculate_y_position(unsigned char * pbuf, int * y_point, 
                          int w, int h);
void center_of_gravity_i(int * cog_x, int * cog_y, 
                         unsigned char * data, int w, 
                         rectangle* box);
rectangle get_bounding_box(int center_x, int center_y, int w, int h);

#ifndef __SOLVER__
void draw_bounding_box(unsigned char * data,
                       int w, int h,
                       int * x_point, int * y_point,
                       int num_center_x, int num_center_y);
void write_pgm(unsigned char * data, int w, int h,
               const char * filename);
unsigned char * read_pgm(int *w, int *h, const char * filename);
#endif

#endif //_FFOS_H

