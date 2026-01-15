#include <stdio.h>

#include "../include/scenarios.h"

int main() {

#ifdef UAF
    uaf();
#endif

#ifdef DOUBLE_FREE
    double_free();
#endif

#ifdef HEAP_OVERFLOW
    heap_overflow();
#endif

    return 0;
}

