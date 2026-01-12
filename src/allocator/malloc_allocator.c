#include <stdlib.h>

#include "../../include/allocator.h"




heap_allocator_t get_malloc_allocator() {
    heap_allocator_t alloc;

    alloc.name = "malloc";
    alloc.m_alloc = *malloc;
    alloc.m_free = *free;

    return alloc;
}
