#include <stdio.h>

#include "../../include/scenarios.h"
#include "../../include/allocator.h"




void uaf() {
    heap_allocator_t alloc;
    int *i;

    alloc = get_malloc_allocator();
    printf("Hello from uaf\n");

    i = (int*)alloc.m_alloc(sizeof(int));
    *i = 3;

    printf("%p\n", i);
    printf("%d\n", *i);

    alloc.m_free(i);

    printf("%p\n", i);
    printf("%d\n", *i);

    return;
}
