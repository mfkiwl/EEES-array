#include <stdint.h>


int     POLYNOMIAL = 0x04C11DB7;
#define INITIAL_REMAINDER   0xFFFFFFFF
#define FINAL_XOR_VALUE     0xFFFFFFFF
#define REFLECT_DATA        TRUE
#define REFLECT_REMAINDER   TRUE
#define CHECK_VALUE         0xCBF43926

/*
 * Derive parameters from the standard-specific parameters in crc.h.
 */
#define WIDTH    (8 * sizeof(uint32_t))
#define TOPBIT   (1 << (WIDTH - 1))

#if (REFLECT_DATA == TRUE)
#undef  REFLECT_DATA
#define REFLECT_DATA(X)         (reflect((X), 8))
#else
#undef  REFLECT_DATA
#define REFLECT_DATA(X)         (X)
#endif

#if (REFLECT_REMAINDER == TRUE)
#undef  REFLECT_REMAINDER
#define REFLECT_REMAINDER(X)    (reflect((X), WIDTH))
#else
#undef  REFLECT_REMAINDER
#define REFLECT_REMAINDER(X)    (X)
#endif


/*********************************************************************
 *
 * Function:    reflect()
 * 
 * Description: Reorder the bits of a binary sequence, by reflecting
 *              them about the middle position.
 *
 * Notes:       No checking is done that nBits <= 32.
 *
 * Returns:     The reflection of the original data.
 *
 *********************************************************************/
static uint32_t
reflect(uint32_t data, int nBits) {
  uint32_t reflection = 0;
  int  bit;
  /* Reflect the data about the center bit. */
  for (bit = 0; bit < nBits; ++bit) {
    /* If the LSB bit is set, set the reflection of it.  */
    if (data & 0x01) { reflection |= (1 << ((nBits - 1) - bit)); }
    data = (data >> 1);
  }
  return reflection;
}   /* reflect() */


uint32_t  zcrcTable[256];


/*********************************************************************
 *
 * Function:    crcInit()
 * 
 * Description: Populate the partial CRC lookup table.
 *
 * Notes:       This function must be rerun any time the CRC standard
 *              is changed.  If desired, it can be run "offline" and
 *              the table results stored in an embedded system's ROM.
 *
 * Returns:     None defined.
 *
 *********************************************************************/
void crcInit(void) {
  uint32_t       remainder;
  int            dividend;
  unsigned char  bit;
  /* Compute the remainder of each possible dividend.  */
  for (dividend = 0; dividend < 256; ++dividend) {
    /* Start with the dividend followed by zeros. */
    remainder = dividend << (WIDTH - 8);
    /* Perform modulo-2 division, a bit at a time. */
    for (bit = 8; bit > 0; --bit) {
      /* Try to divide the current data bit. */         
      if (remainder & TOPBIT) { remainder = (remainder << 1) ^ POLYNOMIAL; }
      else                    { remainder = (remainder << 1); }
    }
    /* Store the result into the table.  */
    zcrcTable[dividend] = remainder;
  }
}/* crcInit() */

uint32_t
crcFast(unsigned char const message[], int nBytes) {
  uint32_t  remainder = INITIAL_REMAINDER;
  int       data;
  int       byte;
  int       idx;
  /*  Divide the message by the polynomial, a byte at a time.  */
  for (byte = 0; byte < nBytes; ++byte) {
    data = REFLECT_DATA(message[byte]) ^ (remainder >> (WIDTH - 8));
    idx = data&0xFF;
#ifndef __SOLVER__
    printf("T[%d]=%x (%u)\n", idx,  zcrcTable[idx], zcrcTable[idx]);
#endif
    remainder = zcrcTable[idx] ^ (remainder << 8);
  }
  /* The final remainder is the CRC. */
  return (REFLECT_REMAINDER(remainder) ^ FINAL_XOR_VALUE);
}/* crcFast() */

char msg[] = "abcdef";
int out;

int
main() {
  crcInit();
  out = crcFast(msg, 6);
#ifndef __SOLVER__
  printf("out=%x (%u)\n", out, out);
#endif
}
