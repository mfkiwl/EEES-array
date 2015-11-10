/*-------------------------------------------*/
/* ITU-R version for color conversion:	     */
/*  u -= 128                                 */
/*  v -= 128                                 */
/*  r = y		    +1.402	v                */
/*  g = y -0.34414u	-0.71414v	             */
/*  b = y +1.772  u			                 */
/* Approximations: 1.402 # 7/5 = 1.400	     */
/*		.71414 # 357/500 = 0.714             */
/*		.34414 # 43/125	= 0.344	             */
/*		1.772  = 443/250	                 */
/*-------------------------------------------*/
/* Approximations: 1.402 # 359/256 = 1.40234 */
/*		.71414 # 183/256 = 0.71484           */
/*		.34414 # 11/32 = 0.34375             */
/*		1.772 # 227/128 = 1.7734             */
/*-------------------------------------------*/

unsigned int yuv[24] = {0xc7, 0xd6, 0xf7, 0x70, 0xae, 0xe8, 0xab, 0x36,
                        0x24, 0x60, 0x7a, 0x28, 0x8b, 0xdb, 0x8,  0xbe,
                        0xfc, 0xa,  0x59, 0x32, 0x2f, 0x50, 0x21, 0x71};
unsigned int rgb[24];

void yuv2rgb_mod(unsigned int * restrict out,
        unsigned int * restrict in, int n) __attribute__((noinline));

int main () {
  yuv2rgb_mod(rgb, yuv, 8);
}

void
yuv2rgb_mod(unsigned int * restrict out, unsigned int * restrict in, int n) {
    unsigned int *yi, *cbi, *cri, *ro, *go, *bo;
    int i, y, cb, cr, r, g, b;
    
    yi  = in;
    cbi = in + n;
    cri = in + 2 * n;
    ro = out;
    go = out + n;
    bo = out + 2 * n;
    for(i = 0; i < n; i ++) {
        y  = yi[i];
        cb = cbi[i] - 128;
        cr = cri[i] - 128;
        r = y + ((359 * cr) >> 8);
        g = y - ((11  * cb) >> 5) - ((183 * cr) >> 8);
        b = y + ((227 * cb) >> 7);
        int tmp0 = (r < 255 ) ? r : 255;
        ro[i] = (tmp0 > 0) ? tmp0 : 0;

        int tmp1 = (g < 255 ) ? g : 255;
        go[i] = (tmp1 > 0) ? tmp1 : 0;

        int tmp2 = (b < 255 ) ? b : 255;
        bo[i] = (tmp2 > 0) ? tmp2 : 0;
    }
}
