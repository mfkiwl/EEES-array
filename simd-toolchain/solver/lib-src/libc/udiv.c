#include <stdint.h>

uint32_t
__udivsi3(uint32_t n, uint32_t d) {
  int i;
  uint32_t result = 0;
  int steps = 0;
  if (!d  || !n || (n < d)) { return 0; }

  while ((int)d >= 0) { d <<= 1; ++steps; }
  for (i = 0; i <= steps; ++i) {
    result <<= 1;
    if (n >= d) { ++result; n -= d; }
    d >>= 1;
  }
  return result;
}

uint32_t a  = 32;
uint32_t b  = 16;
uint32_t c;

int main() {
  c =  a / b;
}
