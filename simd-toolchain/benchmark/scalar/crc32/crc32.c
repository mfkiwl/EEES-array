#include <stdint.h>

int POLYNOMIAL = 0x04C11DB7;

//#define POLYNOMIAL          0x04C11DB7;
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
static inline uint32_t
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


uint32_t
crcSlow(unsigned char const message[], int nBytes) {
  uint32_t       remainder = INITIAL_REMAINDER;
  int            byte;
  unsigned char  bit;
  uint32_t       rflx;
  /* Perform modulo-2 division, a byte at a time.  */
  for (byte = 0; byte < nBytes; ++byte) {
    /* Bring the next byte into the remainder. */
    rflx = REFLECT_DATA(message[byte]);
    remainder ^= ((rflx) << (WIDTH - 8));
#ifndef __SOLVER__
    printf("- %d: %x (%u)\n     %x (%u)\n",byte, rflx, rflx, remainder, remainder);
#endif
    /* Perform modulo-2 division, a bit at a time.  */
    for (bit = 8; bit > 0; --bit) {
      /* Try to divide the current data bit. */
      if (remainder & TOPBIT) { remainder = (remainder << 1) ^ POLYNOMIAL; }
      else { remainder = (remainder << 1); }
#ifndef __SOLVER__
      printf("    %d-%d: %x (%u)\n",byte, bit, remainder, remainder);
#endif
    }
#ifndef __SOLVER__
    printf("%d: %x (%u)\n",byte, remainder, remainder);
#endif
  }
  /* The final remainder is the CRC result.  */
  return (REFLECT_REMAINDER(remainder) ^ FINAL_XOR_VALUE);
}   /* crcSlow() */

char msg[] = "0123456789abcdeffedcba98765432100123456789abcdeffedcba98765432100123456789abcdeffedcba98765432100123456789abcdeffedcba9876543210";
uint32_t out;

int main() {
  out = crcSlow(msg, 128);
#ifndef __SOLVER__
  printf("%x\n", out);
#endif
}
