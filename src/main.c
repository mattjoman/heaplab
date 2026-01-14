#include <stdio.h>

#include "../include/scenarios.h"

int main() {

#ifdef ENABLE_UAF
    uaf();
#endif

#ifdef ENABLE_DOUBLE_FREE
    double_free();
#endif

}

