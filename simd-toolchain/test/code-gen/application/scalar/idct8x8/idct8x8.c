#define Y(i,j)		Y[8*i+j]
#define X(i,j)		(output[i][j])

/* This version is IEEE compliant using 16-bit arithmetic. */

/* The number of bits coefficients are scaled up before 2-D IDCT: */
#define S_BITS	         3
/* The number of bits in the fractional part of a fixed point constant: */
#define C_BITS		14

#define SCALE(x,n)	((x) << (n))

/* This version is vital in passing overall mean error test. */
#define DESCALE(x, n)	(((x) + (1 << ((n)-1)) - ((x) < 0)) >> (n))

#define ADD(x, y)	((x) + (y))
#define SUB(x, y)	((x) - (y))
#define CMUL(C, x)	(((C) * (x) + (1 << (C_BITS-1))) >> C_BITS)

/* Butterfly: but(a,b,x,y) = rot(sqrt(2),4,a,b,x,y) */
#define but(a,b,x,y)	{ x = SUB(a,b); y = ADD(a,b); }

int fblock[8][8] = {
  {0x46ab, 0x45b7, 0xfcf2, 0x2536, 0x71df, 0xac39, 0xe788, 0xc5b6},
  {0xd43f, 0xd569, 0xecba, 0xf4f2, 0x9137, 0x2eec, 0x4a67, 0x4bb2},
  {0x398d, 0x3984, 0x132f, 0xf5bf, 0xbc83, 0xf5e2, 0x0e27, 0x6a6c},
  {0xefd2, 0xe531, 0xee3a, 0x7c85, 0x6df2, 0xfb0b, 0xd9ad, 0x2abb},
  {0x1df1, 0x66f9, 0xd113, 0x8cab, 0x4dc9, 0x1aa5, 0xf1f8, 0x6a0f},
  {0xeb57, 0x1391, 0x7098, 0x644b, 0x09f3, 0x275f, 0x9b35, 0x4b1d},
  {0x9352, 0x0a4f, 0x5fde, 0x32da, 0xa264, 0xff20, 0x4fd1, 0x2f28},
  {0x6809, 0x851d, 0xaa67, 0x68d9, 0xa738, 0xb467, 0xc8b8, 0x8f2f}};

unsigned int pblock[8][8];

void idct8x8(const int input[8][8],
        unsigned int output[8][8]) __attribute__((noinline));

int main() {
  idct8x8(fblock, pblock);
}

/* Inverse 1-D Discrete Cosine Transform.
   Result Y is scaled up by factor sqrt(8).
   Original Loeffler algorithm.
*/
static inline void
idct_1d(int * restrict Y) {
  int z1[8], z2[8], z3[8];

  /* Stage 1: */
  but(Y[0], Y[4], z1[1], z1[0]);
  /* rot(sqrt(2), 6, Y[2], Y[6], &z1[2], &z1[3]); */
  z1[2] = SUB(CMUL( 8867, Y[2]), CMUL(21407, Y[6]));
  z1[3] = ADD(CMUL(21407, Y[2]), CMUL( 8867, Y[6]));
  but(Y[1], Y[7], z1[4], z1[7]);
  /* z1[5] = CMUL(sqrt(2), Y[3]);
     z1[6] = CMUL(sqrt(2), Y[5]);
  */
  z1[5] = CMUL(23170, Y[3]);
  z1[6] = CMUL(23170, Y[5]);

  /* Stage 2: */
  but(z1[0], z1[3], z2[3], z2[0]);
  but(z1[1], z1[2], z2[2], z2[1]);
  but(z1[4], z1[6], z2[6], z2[4]);
  but(z1[7], z1[5], z2[5], z2[7]);

  /* Stage 3: */
  z3[0] = z2[0];
  z3[1] = z2[1];
  z3[2] = z2[2];
  z3[3] = z2[3];
  /* rot(1, 3, z2[4], z2[7], &z3[4], &z3[7]); */
  z3[4] = SUB(CMUL(13623, z2[4]), CMUL( 9102, z2[7]));
  z3[7] = ADD(CMUL( 9102, z2[4]), CMUL(13623, z2[7]));
  /* rot(1, 1, z2[5], z2[6], &z3[5], &z3[6]); */
  z3[5] = SUB(CMUL(16069, z2[5]), CMUL( 3196, z2[6]));
  z3[6] = ADD(CMUL( 3196, z2[5]), CMUL(16069, z2[6]));

  /* Final stage 4: */
  but(z3[0], z3[7], Y[7], Y[0]);
  but(z3[1], z3[6], Y[6], Y[1]);
  but(z3[2], z3[5], Y[5], Y[2]);
  but(z3[3], z3[4], Y[4], Y[3]);
}

/* Inverse 2-D Discrete Cosine Transform. */
void
idct8x8(const int input[8][8], unsigned int output[8][8]) {
  int Y[64];
  int k,l;

  /* Pass 1: process rows. */
  for (k = 0; k < 8; k++) {

    /* Prescale k-th row: */
    for (l = 0; l < 8; l++)
      Y(k,l) = SCALE(input[k][l], S_BITS);

    /* 1-D IDCT on k-th row: */
    idct_1d(&Y(k,0));
    /* Result Y is scaled up by factor sqrt(8)*2^S_BITS. */
  }

  /* Pass 2: process columns. */
  for (l = 0; l < 8; l++) {
    int Yc[8];

    for (k = 0; k < 8; k++) Yc[k] = Y(k,l);
    /* 1-D IDCT on l-th column: */
    idct_1d(Yc);
    /* Result is once more scaled up by a factor sqrt(8). */
    for (k = 0; k < 8; k++) {
      int r = 128 + DESCALE(Yc[k], S_BITS+3); /* includes level shift */

      /* Clip to 8 bits unsigned: */
      int t0 = (r < 255) ? r : 255;
      r = t0 > 0 ? t0 : 0;
      X(k,l) = r;
    }
  }
}
