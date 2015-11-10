// ========================================
// 1) Assume N*N matrix and N*1 vector
//    otherwise, require extra parameters.
// 2) No initialization for-loop, use
//    'temp' variable instead.
// ========================================

int I_A[9] = {60605, 36916, 34331, 64920, 24541, 22177, 28036, 48287, 18731};
int I_B[3] = {25106, 24776, 42806};
int C[9];

void mat_vec_mul(int * restrict c, int * restrict a, int * restrict b,
        int N) __attribute__((noinline));

int main() {
  mat_vec_mul(C, I_A, I_B, 3);
}

void 
mat_vec_mul(int * restrict c, int * restrict a, int * restrict b, int N) {
  int i, j, temp, ta, tb;
  // matrix * vector
  for(i = 0; i < N; i++) {
    temp = 0;    
    for(j = 0; j < N; j++) {
      ta = a[i*N+j];
      tb = b[j];
      temp += ta * tb;
    }   
    c[i] = temp;
  }
}
