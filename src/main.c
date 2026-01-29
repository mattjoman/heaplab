#include <stdio.h>
#include <string.h>

#include "../include/scenarios.h"

int main(int argc, char *argv[]) {

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <scenario>\n", argv[0]);
        return 1;
    }

    if (strcmp(argv[1], "proper_usage") == 0) {
        proper_usage();
    } else if (strcmp(argv[1], "uaf") == 0) {
        uaf();
    } else if (strcmp(argv[1], "double_free") == 0) {
        double_free();
    } else if (strcmp(argv[1], "heap_overflow") == 0) {
        heap_overflow();
    } else {
        fprintf(stderr, "Unknown scenario: %s\n", argv[1]);
        return 1;
    }

    return 0;
}

