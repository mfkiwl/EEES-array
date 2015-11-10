#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* real declaration of global variables here */
/* see jpeg.h for more info			*/

#include "jpeg.h"
#include "fio_alt.h"

/* descriptors for 3 components */
cd_t comp[3];
/* decoded DCT blocks buffer */
PBlock *MCU_buff[10];
/* components of above MCU blocks */
int MCU_valid[10];

/* quantization tables */
PBlock *QTable[4];
int QTvalid[4];

/* Video frame size     */
int x_size, y_size;
/* down-rounded Video frame size (integer MCU) */
int rx_size, ry_size;
/* MCU size in pixels   */
int MCU_sx, MCU_sy;
/* picture size in units of MCUs */
int mx_size, my_size;
/* number of components 1,3 */
int n_comp;

/* MCU after color conversion */
unsigned char *ColorBuffer;
/* complete final RGB image */
unsigned char FrameBuffer[2304];
/* unsigned char *FrameBuffer; */
/* scratch frequency buffer */
FBlock *FBuff;
/* scratch pixel buffer */
PBlock *PBuff;
/* frame started ? current component ? */
int in_frame, curcomp;
/* current position in MCU unit */
int MCU_row, MCU_column;

/* stuff bytes in entropy coded segments */
int stuffers = 0;
/* bytes passed when searching markers */
int passed = 0;

int JpegToBmp();

int main() {
  
  JpegToBmp();
#ifndef __SOLVER__
  write_bmp("surfer.bmp");
  MSG("x_size=%d, y_size=%d, n_comp=%d\n", x_size, y_size, n_comp);
  MSG("MCU_sx=%d, MCU_sy=%d\n", MCU_sx, MCU_sy);
  MSG("mx_size=%d, my_size=%d, rx_size=%d, ry_size=%d\n",
      mx_size, my_size, rx_size, ry_size);
  MSG("stuffers=%d, passed=%d, vld_count=%d\n", stuffers, passed, vld_count);
#endif
#ifdef FRAMEBUFFER_LOG
  for (int i = 0; i < x_siz*y_size*n_comp; ++i) { ERR("%u ", FrameBuffer[i]); }
  ERR("\n");
#endif
  free_structures();
}

/*-----------------------------------------------------------------*/
/*		MAIN		MAIN		MAIN		   */
/*-----------------------------------------------------------------*/

int JpegToBmp() {
  unsigned int aux, mark;
  int n_restarts, restart_interval, leftover;	/* RST check */
  int i, j;
  if (!FOPEN("surfer.jpg", "rb")) { return -1; }
  /* First find the SOI marker: */
  aux = get_next_MK();
  if (aux != SOI_MK) { aborted_stream(); }

  MSG("%ld:\tINFO:\tFound the SOI marker!\n", FTELL());
  in_frame = 0;
  restart_interval = 0;
  for (i = 0; i < 4; i++) { QTvalid[i] = 0; }

  /* Now process segments as they appear: */
  do {
    mark = get_next_MK();

    switch (mark) {
    case SOF_MK:
      MSG("%ld:\tINFO:\tFound the SOF marker!\n", FTELL());
      in_frame = 1;
      get_size();	/* header size, don't care */

      /* load basic image parameters */
      FGETC();	/* precision, 8bit, don't care */
      y_size = get_size();
      x_size = get_size();
      MSG("\tINFO:\tImage size is %d by %d\n", x_size, y_size);

      n_comp = FGETC();	/* # of components */
#if VERBOSE 
      ERR("\tINFO:\t");
      switch (n_comp) {
      case 1 : ERR("Monochrome"); break;
      case 3 : ERR("Color");      break;
      default: ERR("Not a");      break;
      }
      ERR(" JPEG image!\n");
#endif
      for (i = 0; i < n_comp; i++) {
        /* component specifiers */
        comp[i].CID = FGETC();
        aux = FGETC();
        comp[i].HS = first_quad(aux);
        comp[i].VS = second_quad(aux);
        comp[i].QT = FGETC();
      }
#if VERBOSE
      if (n_comp > 1)
        MSG("\tINFO:\tColor format is %d:%d:%d, H=%d\n",
            comp[0].HS * comp[0].VS, comp[1].HS * comp[1].VS,
            comp[2].HS * comp[2].VS, comp[1].HS);
#endif

      if (init_MCU() == -1) { aborted_stream(); }

      /* dimension scan buffer for YUV->RGB conversion */
      /* FrameBuffer = (unsigned char *)malloc((size_t) x_size * y_size * n_comp); */
      ColorBuffer = (unsigned char *)malloc((size_t) MCU_sx * MCU_sy * n_comp);
      FBuff = (FBlock *) malloc(sizeof(FBlock));
      PBuff = (PBlock *) malloc(sizeof(PBlock));

      if ((ColorBuffer == NULL) || (FBuff == NULL) || (PBuff == NULL)) {
        ERR("\tERROR:\tCould not allocate pixel storage!\n");
        exit(1);
      }
      break;

    case DHT_MK:
      MSG("%ld:\tINFO:\tDefining Huffman Tables\n", FTELL());
      if (load_huff_tables() == -1)
        aborted_stream();
      break;

    case DQT_MK:
      MSG("%ld:\tINFO:\tDefining Quantization Tables\n", FTELL());
      if (load_quant_tables() == -1)
        aborted_stream();
      break;

    case DRI_MK:
      get_size();	/* skip size */
      restart_interval = get_size();
      MSG("%ld:\tINFO:\tDefining Restart Interval %d\n", FTELL(),
          restart_interval);
      break;

    case SOS_MK:	/* lots of things to do here */
      MSG("%ld:\tINFO:\tFound the SOS marker!\n", FTELL());
      get_size();	/* don't care */
      aux = FGETC();
      if (aux != (unsigned int)n_comp) {
        ERR("\tERROR:\tBad component interleaving!\n");
        aborted_stream();
      }

      for (i = 0; i < n_comp; i++) {
        aux = FGETC();
        if (aux != comp[i].CID) {
          ERR("\tERROR:\tBad Component Order!\n");
          aborted_stream();
        }
        aux = FGETC();
        comp[i].DC_HT = first_quad(aux);
        comp[i].AC_HT = second_quad(aux);
      }
      get_size();
      FGETC();	/* skip things */

      MCU_column = 0;
      MCU_row = 0;
      clear_bits();
      reset_prediction();

      /* main MCU processing loop here */
      if (restart_interval) {
        n_restarts = ceil_div(mx_size * my_size, restart_interval) - 1;
        leftover = mx_size * my_size - n_restarts * restart_interval;
        /* final interval may be incomplete */

        for (i = 0; i < n_restarts; i++) {
          for (j = 0; j < restart_interval; j++) { process_MCU(); }
          /* proc till all EOB met */
          aux = get_next_MK();
          if (!RST_MK(aux)) {
            ERR("%ld:\tERROR:\tLost Sync after interval!\n", FTELL());
            aborted_stream();
          } else { MSG("%ld:\tINFO:\tFound Restart Marker\n", FTELL()); }
          reset_prediction();
          clear_bits();
        }	/* intra-interval loop */
      } else
        leftover = mx_size * my_size;
      /* process till end of row without restarts */
      for (i = 0; i < leftover; i++) { process_MCU(); }
      in_frame = 0;
      break;
    case EOI_MK:
      MSG("%ld:\tINFO:\tFound the EOI marker!\n", FTELL());
      if (in_frame) { aborted_stream(); }
      MSG("\tINFO:\tTotal skipped bytes %d, total stuffers %d\n", passed,
          stuffers);
      FCLOSE();

#ifdef COMP_LOG
      for (int i = 0; i < n_comp; ++i) {
        unsigned char* p = (unsigned char*)&comp[i];
        for (int j = 0; j < sizeof(cd_t); ++j) { ERR("%u ", p[j]); }
        ERR("\n");
      }
#endif
      return 0;
      break;

    case COM_MK:
      MSG("%ld:\tINFO:\tSkipping comments\n", FTELL());
      skip_segment();
      break;

    case EOF:
      MSG("%ld:\tERROR:\tRan out of input data!\n", FTELL());
      aborted_stream();
    default:
      if ((mark & MK_MSK) == APP_MK) {
        MSG("%ld:\tINFO:\tSkipping application data\n", FTELL());
        skip_segment();
        break;
      }
      if (RST_MK(mark)) { reset_prediction(); break; }
      /* if all else has failed ... */
      ERR("%ld:\tWARNING:\tLost Sync outside scan, %d!\n", FTELL(), mark);
      aborted_stream();
      break;
    }		/* end switch */
  } while (1);

  return 0;
}// JpegToBmp()
