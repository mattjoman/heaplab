#include <stdio.h>

#include "../../include/scenarios.h"
#include "../../include/allocator.h"




void double_free() {
    heap_allocator_t alloc;
    int *i;

    alloc = get_malloc_allocator();

    i = (int*)alloc.m_alloc(sizeof(int));
    *i = 3;

    printf("%p\n", i);
    printf("%d\n", *i);

    alloc.m_free(i);

    alloc.m_free(i);

    return;
}
