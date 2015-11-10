int global_sum;
int global_array[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
int global_cnt;

int glb_sum() __attribute__((__noinline__));

int glb_sum()  {
  int i, sum = 0;
  for (i = 0; i < global_cnt; ++i) {
    sum += global_array[i];
  }
  return sum;
}

int main() {
  global_cnt = 5;
  global_sum = glb_sum();
}
