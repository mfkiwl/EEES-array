//#include <stdio.h>

/* Primitive function F.
 * Input is r, subkey array in keys, output is XORed into l.
 * Each round consumes eight 6-bit subkeys, one for
 * each of the 8 S-boxes, 2 longs for each round.
 * Each long contains four 6-bit subkeys, each taking up a byte.
 * The first long contains, from high to low end, the subkeys for
 * S-boxes 1, 3, 5 & 7; the second contains the subkeys for S-boxes
 * 2, 4, 6 & 8 (using the origin-1 S-box numbering in the standard,
 * not the origin-0 numbering used elsewhere in this code)
 * See comments elsewhere about the pre-rotated values of r and Spbox.
 */
#define	F(l,r,key){\
	work = ((r >> 4) | (r << 28)) ^ key[0];\
	l ^= Spbox[6][work & 0x3f];\
	l ^= Spbox[4][(work >> 8) & 0x3f];\
	l ^= Spbox[2][(work >> 16) & 0x3f];\
	l ^= Spbox[0][(work >> 24) & 0x3f];\
	work = r ^ key[1];\
	l ^= Spbox[7][work & 0x3f];\
	l ^= Spbox[5][(work >> 8) & 0x3f];\
	l ^= Spbox[3][(work >> 16) & 0x3f];\
	l ^= Spbox[1][(work >> 24) & 0x3f];\
}


/* Encrypt or decrypt a block of data in ECB mode */
void 
des(unsigned int * restrict ciphertext, unsigned int * restrict plaintext, 
    unsigned int ks[16][2], unsigned int Spbox[8][64], int * restrict p) {
    int n = p[0];
    int c0x0f0f0f0f = p[1], c0x33333333 = p[2], c0xaaaaaaaa=p[3], c0xff00ff=p[4], c0xffff=p[5];
  int i;
  unsigned int left,right,work;
	
	for (i = 0; i < n; i ++) {
	  /* Read input block and place in left/right in big-endian order */
	  left  = plaintext[2*i];
	  right = plaintext[2*i+1];
    
	  /* The convention here is the same as Outerbridge: rotate each
	   * register left by 1 bit, i.e., so that "left" contains permuted
	   * input bits 2, 3, 4, ... 1 and "right" contains 33, 34, 35, ... 32	
	   * (using origin-1 numbering as in the FIPS). This allows us to avoid
	   * one of the two rotates that would otherwise be required in each of
	   * the 16 rounds.
	   */
	  work = ((left >> 4) ^ right) & c0x0f0f0f0f;
	  right ^= work;
	  left ^= work << 4;
	  work = ((left >> 16) ^ right) & c0xffff;
	  right ^= work;
	  left ^= work << 16;
	  work = ((right >> 2) ^ left) & c0x33333333;
	  left ^= work;
	  right ^= (work << 2);
	  work = ((right >> 8) ^ left) & c0xff00ff;
	  left ^= work;
	  right ^= (work << 8);
	  right = (right << 1) | (right >> 31);
	  work = (left ^ right) & c0xaaaaaaaa;
	  left ^= work;
	  right ^= work;
	  left = (left << 1) | (left >> 31);
    
	  /* Now do the 16 rounds */
	  F(left,right,ks[0]);
	  F(right,left,ks[1]);
	  F(left,right,ks[2]);
	  F(right,left,ks[3]);
	  F(left,right,ks[4]);
	  F(right,left,ks[5]);
	  F(left,right,ks[6]);
	  F(right,left,ks[7]);
	  F(left,right,ks[8]);
	  F(right,left,ks[9]);
	  F(left,right,ks[10]);
	  F(right,left,ks[11]);
	  F(left,right,ks[12]);
	  F(right,left,ks[13]);
	  F(left,right,ks[14]);
	  F(right,left,ks[15]);
    
	  /* Inverse permutation, also from Hoey via Outerbridge and Schneier */
	  right = (right << 31) | (right >> 1);
	  work = (left ^ right) & c0xaaaaaaaa;
	  left ^= work;
	  right ^= work;
	  left = (left >> 1) | (left  << 31);
	  work = ((left >> 8) ^ right) & c0xff00ff;
	  right ^= work;
	  left ^= work << 8;
	  work = ((left >> 2) ^ right) & c0x33333333;
	  right ^= work;
	  left ^= work << 2;
	  work = ((right >> 16) ^ left) & c0xffff;
	  left ^= work;
	  right ^= work << 16;
	  work = ((right >> 4) ^ left) & c0x0f0f0f0f;
	  left ^= work;
	  right ^= work << 4;
    
	  /* Put the block back into the user's buffer with final swap */
    ciphertext[2*i]   = right;
	  ciphertext[2*i+1] = left;
  }
}


/*K: 1f08260d1ac2465e P: 6b056e18759f5cca C: ef1bf03e5dfa575a */
