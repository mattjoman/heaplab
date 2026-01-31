#include <stdio.h>
#include <string.h>

#include "../../include/scenarios.h"
#include "../../include/allocator.h"

void heap_overflow() {
    heap_allocator_t alloc;
    char *buffer_1, *buffer_2;

    alloc = get_malloc_allocator();

    buffer_1 = alloc.m_alloc(2);
    buffer_2 = alloc.m_alloc(2);

    strcpy(buffer_2, "BB");
    strcpy(buffer_1, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");

    printf("buffer_1: %s\n", buffer_1);
    printf("buffer_2: %s\n", buffer_2);

    strcpy(buffer_2, "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");

    printf("buffer_1: %s\n", buffer_1);
    printf("buffer_2: %s\n", buffer_2);

    alloc.m_free(buffer_1);
    alloc.m_free(buffer_2);

    return;
}
