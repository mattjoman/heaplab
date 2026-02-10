# Double Free

This analysis corresponds to the code in `src/scenarios/double_free.c`.

## Example Output

```
Int allocated at 0x55a880da8310
With value       3
Freeing the memory...
Freeing the memory again...
free(): double free detected in tcache 2
Aborted                    (core dumped) bin/debug.out double_free
```

The allocator detected the double-free and aborted on the second free with a
core dump.

## ASan Analysis

ASan errors and aborts as soon as the double-free is attempted:

```
==3448==ERROR: AddressSanitizer: attempting double-free on 0x7c137bde0010 in thread T0:
    #0 0x7ff37d51f79d in free /usr/src/debug/gcc/gcc/libsanitizer/asan/asan_malloc_linux.cpp:51
    #1 0x55ff84d8ed81 in double_free src/scenarios/double_free.c:23
    #2 0x55ff84d8e36c in main src/main.c:18
```

It provides lifetime info for the offending data including where it was
initially freed:

```
freed by thread T0 here:
    #0 0x7ff37d51f79d in free /usr/src/debug/gcc/gcc/libsanitizer/asan/asan_malloc_linux.cpp:51
    #1 0x55ff84d8ed4a in double_free src/scenarios/double_free.c:21
```

And where it was originally allocated:

```
previously allocated by thread T0 here:
    #0 0x7ff37d520cb5 in malloc /usr/src/debug/gcc/gcc/libsanitizer/asan/asan_malloc_linux.cpp:67
    #1 0x55ff84d8ec4e in double_free src/scenarios/double_free.c:15
```

Interestingly it gives no data on poisoned bytes.
This suggests that this is not how it detects double frees (***I assume it
keeps track of addresses that have been freed an not reallocated?***).
