#ifndef ALLOCATOR_H
#define ALLOCATOR_H

#include <stddef.h>




/* Allocation flags for experiments */
typedef enum {
    HEAP_ALLOC_NONE      = 0,
    HEAP_ALLOC_ZERO      = 1 << 0, // calloc-like
    HEAP_ALLOC_MMAP_HINT = 1 << 1, // force large alloc
    HEAP_ALLOC_NO_TCACHE = 1 << 2, // if supported
} heap_alloc_flags_t;




typedef struct heap_allocator heap_allocator_t;




/* Allocator instance */
struct heap_allocator {
    const char* name;
    void*       state;   // allocator-specific (e.g. glibc info)
    //heap_allocator_ops_t ops;

    void* (*m_alloc)(size_t size);
    void  (*m_free)(void* ptr);
    void* (*m_realloc)(void* ptr, size_t size);
    void* (*m_alloc_aligned)(size_t size, size_t align);
};




heap_allocator_t get_malloc_allocator();




#endif
