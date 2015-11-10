#include <stdlib.h>

int* a[4];

int main() {
  int i;
  a[0] = malloc(8*sizeof(int));
  a[1] = malloc(8*sizeof(int));
  free(a[0]);
  a[2] = malloc(4*sizeof(int));
  free(a[1]);
  free(a[2]);
  a[3] = malloc(16*sizeof(int));
  free(a[3]);
}
