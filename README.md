# HeapLab

## Notes

- Don't implement `src/inspect/glibc.c`
    - This will require reverse-engineering some of glibc
    - Version drift will cause inspection code to break
    - Consider implementing heap inspection for my custom allocator when finished
