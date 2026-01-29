#include <stdio.h>

#include "../../include/scenarios.h"
#include "../../include/allocator.h"




void proper_usage() {
    heap_allocator_t alloc;
    int *i, *j;

    alloc = get_malloc_allocator();

    i = (int*)alloc.m_alloc(sizeof(int));
    *i = 3;

    printf("%p\n", i);
    printf("%d\n", *i);

    alloc.m_free(i);

    j = (int*)alloc.m_alloc(sizeof(int));
    *j = 3;

    printf("%p\n", i);
    printf("%d\n", *i);

    alloc.m_free(j);

    return;
}
