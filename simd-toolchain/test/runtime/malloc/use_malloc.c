#include <stdlib.h>

int* a[3];

int main() {
  int i;
  a[0] = malloc(8*sizeof(int));
  a[1] = malloc(8*sizeof(int));
  a[2] = malloc(4*sizeof(int));
}
