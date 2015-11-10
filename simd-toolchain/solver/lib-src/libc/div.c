#include <stdint.h>
#ifndef __SOLVER__
#include <limits.h>
#include <stdio.h>
#endif

#ifndef __SOLVER__
int32_t
my_sdiv(int32_t a, int32_t b)
#else
int32_t
__divsi3(int32_t a, int32_t b)
#endif
{
    const int bits_in_word_m1 = (int)(sizeof(int32_t) * CHAR_BIT) - 1;
    int32_t s_a = a >> bits_in_word_m1;           /* s_a = a < 0 ? -1 : 0 */
    int32_t s_b = b >> bits_in_word_m1;           /* s_b = b < 0 ? -1 : 0 */
    a = (a ^ s_a) - s_a;                         /* negate if s_a == -1 */
    b = (b ^ s_b) - s_b;                         /* negate if s_b == -1 */
    s_a ^= s_b;                                  /* sign of quotient */
    /* Without unsigned division instruction, this calls __udivsi3  */
#ifndef __SOLVER__
    printf("a=%d, b=%d, s_a=%d, s_b=%d\n", a, b, s_a, s_b);
#endif
    return ((uint32_t)a/(uint32_t)b ^ s_a) - s_a;/* negate if s_a == -1 */
}

int a = 33;
int b = -2;
int c;

int main() {
  c = a / b;
#ifndef  __SOLVER__
  printf("c=%d, __divsi3=%d\n", c, my_sdiv(a, b));
#endif
}
