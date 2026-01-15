#include <stdio.h>
#include <string.h>

#include "../../include/scenarios.h"
#include "../../include/allocator.h"




void heap_overflow() {
    heap_allocator_t alloc;
    char *buffer;

    alloc = get_malloc_allocator();

    buffer = alloc.m_alloc(8);
    strcpy(buffer, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");

    printf("Buffer: %s\n", buffer);

    return;
}
