int hist[256];
int input[10] = {0x9, 0x10, 0xd, 0x48, 0x65, 0x83, 0x4c, 0xcb, 0x71, 0x6a};

void histogram256(int* restrict hist_out,
        int* restrict img, int img_size) __attribute__((noinline));

int main() {
    histogram256(hist, input, 10);
}

void 
histogram256(int* restrict hist_out, int* restrict img, int img_size) {
    int i;
    for ( i = 0; i < 256; i ++) {
        hist_out[i] = 0;
    }

    for ( i = 0; i < img_size; i ++) {
        hist_out[img[i]] ++;
    }
}
