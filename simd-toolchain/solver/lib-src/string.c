#include <string.h>

void* memmove (void* destination, const void* source, size_t num) {
    int i;
    for (i = 0; i < num; ++i) {
        ((char*)destination)[i] = ((char*)source)[i];
    }
    return destination;
}

void* memcpy  (void* destination, const void* source, size_t num) {
    int i;
    for (i = 0; i < num; ++i) {
        ((char*)destination)[i] = ((char*)source)[i];
    }
    return destination;
}

void* memset  (void* ptr, int value, size_t num) {
    int i;
    for (i = 0; i < num; ++i) { ((char*)ptr)[i] = value; }
    return ptr;
}
