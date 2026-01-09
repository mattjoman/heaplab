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




/* Allocator vtable */
typedef struct {
    void* (*alloc)(heap_allocator_t*, size_t size, heap_alloc_flags_t flags);
    void  (*free)(heap_allocator_t*, void* ptr);
    void* (*realloc)(heap_allocator_t*, void* ptr, size_t size);
    void* (*alloc_aligned)(heap_allocator_t*, size_t size, size_t align);

    /* Optional hooks */
    void  (*dump_state)(heap_allocator_t*);
    void  (*set_option)(heap_allocator_t*, const char* key, long value);
} heap_allocator_ops_t;




/* Allocator instance */
struct heap_allocator {
    const char* name;
    void*       state;   // allocator-specific (e.g. glibc info)
    heap_allocator_ops_t ops;
};




#endif
