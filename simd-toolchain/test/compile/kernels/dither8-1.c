
#define MAX_W 64
/*
 * Kernel:
 *      |0  0  0|
 * 1/16*|0  0  7|
 *      |3  5  1|
 */
void 
dither_8_1(unsigned int * restrict out, unsigned int * restrict in, int w, int h)
{
    int i, j, err_idx, med, diff;
    int err_buf[2][MAX_W];
    
    err_idx = 0;
    for (i = 0; i < w; i ++) {
        err_buf[0][i] = 0;
        err_buf[1][i] = 0;
    }
    
    for(i = 0; i < h; i ++){
        for(j = 0; j < w; j ++){
            int oldpix = (int)in[i*w + j];
            int newpix;

            med = oldpix + err_buf[err_idx][j]/16;
            err_buf[err_idx][j] = 0;              /*Clear the buffer*/
            newpix = (med>127)?0xFF:0;
            diff = med - newpix;
            out[i*w+j] = newpix;
            
            if(j > 0){
                err_buf[1 - err_idx][j-1] += (diff*3);
            }
            err_buf[1 - err_idx][j  ] += (diff*5);
            if(j < (w-1)){
                err_buf[err_idx][j+1] += (diff*7);
                err_buf[1 - err_idx][j+1] += (diff*1);
            }
        }

        err_idx = 1 - err_idx;
    }
    
}
