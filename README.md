# HeapLab

## Requirements

- Glibc debuginfo (for valgrind) -- not available on arch without some pain
- Valgrind
- GCC, Make

## Usage

- `scripts/asan.sh` to build & execute asan tests

## Notes

- Don't implement `src/inspect/glibc.c`
    - This will require reverse-engineering some of glibc
    - Version drift will cause inspection code to break
    - Consider implementing heap inspection for my custom allocator when finished
- Builds:
    - Main build (with debugging enabled)
    - Asan build (with debugging & -fsanitize=address)
- Add scenarios:
    - `uaf_reuse.c`
    - `uaf_read.c`
    - `uaf_write.c`
- Run on debian for valgrind memcheck
