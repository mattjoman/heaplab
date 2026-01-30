#include <stdio.h>

#include "../../include/scenarios.h"
#include "../../include/allocator.h"




void double_free() {
    heap_allocator_t alloc;
    int *i;

    alloc = get_malloc_allocator();

    i = (int*)alloc.m_alloc(sizeof(int));
    *i = 3;

    printf("Int allocated at %p\n", i);
    printf("With value       %d\n", *i);

    printf("Freeing the memory...\n");
    alloc.m_free(i);

    printf("Freeing the memory again...\n");
    alloc.m_free(i);

    return;
}
