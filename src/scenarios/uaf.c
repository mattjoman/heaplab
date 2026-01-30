#include <stdio.h>

#include "../../include/scenarios.h"
#include "../../include/allocator.h"




void uaf() {
    heap_allocator_t alloc;
    int *i;

    alloc = get_malloc_allocator();

    i = (int*)alloc.m_alloc(sizeof(int));
    *i = 3;

    printf("Allocated an int at %p\n", i);
    printf("With a value of     %d\n", *i);

    alloc.m_free(i);

    printf("Freed the int at    %p\n", i);
    printf("Value is now        %d\n", *i);

    *i = 4;

    printf("Value updated to    %d\n", *i);

    return;
}
