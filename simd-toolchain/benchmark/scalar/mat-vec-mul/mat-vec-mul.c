// ========================================
// 1) Assume N*N matrix and N*1 vector
//    otherwise, require extra parameters.
// 2) No initialization for-loop, use
//    'temp' variable instead.
// ========================================
#include "in_data.h"

#define SIZE 64

void 
mat_vec_mul(int * c, int * a, int * b, unsigned N) {
    int i, j;
    int temp, t0, t1, t2, t3;
    int a0, a1, a2, a3, b0, b1, b2, b3;
    // matrix * vector
    for(i = 0; i < N; i++) {
        temp = 0;    
        for(j = 0; j < N; j+=4) {
            a0 = a[i*N+j];
            b0 = b[j];
            t0 = a0*b0;
            a1 = a[i*N+j+1];
            b1 = b[j+1];
            t1 = a1*b1;
            //t1 = t0+t1;
            a2 = a[i*N+j+2];
            b2 = b[j+2];
            t2 = a2*b2;
            //t2 = t1+t2;
            a3 = a[i*N+j+3];
            b3 = b[j+3];
            t3 = a3*b3;
            //t3 = t2+t3;
            temp += t0 + t1 + t2 + t3;
        }   
        c[i] = temp;
    }
  
}


int __out[SIZE];

int main() {
    mat_vec_mul(__out, input_array, input_vector, SIZE);
}
