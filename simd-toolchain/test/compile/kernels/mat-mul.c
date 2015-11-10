// ======================================
// 1) Assume N*N matrix only, otherwise, 
//    require extra parameters.
// 2) No initialization for-loop, use
//    'temp' variable instead.
// ======================================

void 
mat_mul(int * restrict c, int * restrict a, int * restrict b, int N) {
    int i, j, k;
    int temp, t0, t1, t2, t3;
    int a0, a1, a2, a3, b0, b1, b2, b3;
    // matrix * matrix
    for(i = 0; i < N; i++) {
        for(j = 0; j < N; j++) {
            temp = 0;
            for(k = 0; k < N/4; k+=4) {
                a0 = a[i*N+k];
                b0 = b[k*N+j];
                t0 = a0*b0;

                a1 = a[i*N+k+1];
                b1 = b[(k+1)*N+j];
                t1 = a1*b1;
                t1 = t0+t1;

                a2 = a[i*N+k+2];
                b2 = b[(k+2)*N+j];
                t2 = a2*b2;
                t2 = t1+t2;

                a3 = a[i*N+k+3];
                b3 = b[(k+3)*N+j];
                t3 = a3*b3;
                t3 = t2+t3;
                temp = t3;
            }       
            c[i*N+j] = temp;
        }
    }
}
