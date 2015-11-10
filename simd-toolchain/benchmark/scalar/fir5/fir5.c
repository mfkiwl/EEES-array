
int output[32];

void fir5(int* restrict out, int* restrict in,
        int* restrict coeff, int n) __attribute__((noinline)) ;

int samples[] = {0x42cd, 0x769d, 0xe50d, 0x9e48, 0x6665, 0x7e83, 0xdd4c, 0x66cb,
                 0x9e71, 0x116a, 0xe390, 0x6152, 0x42cd, 0x769d, 0xe50d, 0x9e48,
                 0x42cd, 0x769d, 0xe50d, 0x9e48, 0x6665, 0x7e83, 0xdd4c, 0x66cb,
                 0x42cd, 0x769d, 0xe50d, 0x9e48, 0x6665, 0x7e83, 0xdd4c, 0x66cb,
                 0x6665, 0x7e83, 0xdd4c, 0x66cb,};

int coef[] = {0xc41, 0x475, 0x8e0, 0xecd, 0xd59 };

int main() {
  fir5(output, samples, coef, 32);
}

void 
fir5(int* restrict out, int* restrict in, int* restrict coeff, int n) {
    int i;
    int c0, c1, c2, c3, c4;
    c0 = coeff[0];
    c1 = coeff[1];
    c2 = coeff[2];
    c3 = coeff[3];
    c4 = coeff[4];
    for (i = 0; i < n; i ++) {
        out[i] = in[i + 0]*c0 + in[i + 1]*c1 + in[i + 2]*c2
            + in[i + 3]*c3 + in[i + 4]*c4;
    }
}

