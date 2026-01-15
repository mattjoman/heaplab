#include <stdio.h>

#include "../include/scenarios.h"

int main() {

#ifdef ENABLE_UAF
    uaf();
#endif

#ifdef ENABLE_DOUBLE_FREE
    double_free();
#endif

#ifdef ENABLE_HEAP_OVERFLOW
    heap_overflow();
#endif

    return 0;
}

