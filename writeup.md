# Writeup

Here I give a written explanation of the bugs, undefined behaviour (UB), and
heap misuse in the project scenarios.
Please read in conjunction with the source code.

## UAF (Use After Free)

Use after free is when heap memory is freed by the allocator, but later the
memory is accessed and used.

### Example Output

```
Allocated an int at 0x556fb804e310
With a value of     3
Freed the int at    0x556fb804e310
Value is now        1459322958
Value updated to    4
```

Once the allocated memory is freed, the value at the address becomes some
massive number.
***I think this is some bookkeeping value set by the allocator.***

The allocator did not abort the process, so this bug could propagate before
being noticed.

### ASan Results

ASan errors and aborts as soon as the dangling pointer is dereferenced,
not when the pointer is used.
Below we can see that ASan has detected that my heap int is being accessed
after being freed:

```
==3287==ERROR: AddressSanitizer: heap-use-after-free on address 0x7b382ede0010 at pc 0x556cb57d0a4a bp 0x7ffd2447af00 sp 0x7ffd2447aef0
READ of size 4 at 0x7b382ede0010 thread T0
    #0 0x556cb57d0a49 in uaf src/scenarios/uaf.c:24
    #1 0x556cb57d031c in main src/main.c:16
```

It also produces a full lifetime of the offending heap data (where it was
allocated & where it was freed).

ASan poisons addresses once they are freed, as can be seen in the shadow bytes
below:

```
  0x7b382eddff80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x7b382ede0000: fa fa[fd]fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x7b382ede0080: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
```

Here **[fd]** marks the shadow byte containing the freed bytes.

### Gdb Results

## Double Free

### Example Output

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

### ASan Results

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

## Heap Overflow Gdb Analysis

The `heap_overflow()` function contains several different overflows.
I allocate two buffers, each 2-bytes.
Here is output from the dumpchunk custom gdb command showing the allocated
chunks:

```
Dumping chunk for buffer_1:
Chunk start:       0x555555559300
PREV_INUSE:        1
IS_MMAPPED:        0
NON_MAIN_ARENA:    0
Previous size:     0
Size:              32
Hex dump:
0x555555559300:	0x0000000000000000
0x555555559308:	0x0000000000000021
0x555555559310:	0x0000000000000000
0x555555559318:	0x0000000000000000
```

```
Dumping chunk for buffer_2:
Chunk start:       0x555555559320
PREV_INUSE:        1
IS_MMAPPED:        0
NON_MAIN_ARENA:    0
Previous size:     0
Size:              32
Hex dump:
0x555555559320:	0x0000000000000000
0x555555559328:	0x0000000000000021
0x555555559330:	0x0000000000000000
0x555555559338:	0x0000000000000000
```

For each buffer the glibc allocator has given us a 32-byte chunk (this is the
standard size for small allocations).
The first 8-bytes store the size of the previous chunk.
The next 8-bytes store the size of the current chunk, with the lower 3-bits for
`PREV_INUSE`, `IS_MMAPPED` and `NON_MAIN_ARENA`.
From the value here, we can see that the size is `0x20` (32 bytes), and the
`PREV_INUSE` bit is 1.
The final 16-bytes are for user data (this is where our program pointer
points) - more than enough for the 2-byte buffers.

I use strcpy to write string constants into the two buffers - both are
overflows right off the bat.
`buffer_2` is overflowed by 1 byte since `"BB"` is 3 bytes including the null
character.
`buffer_1` is blatantly overflowed by writing 31 `A`s plus the null character
to make 32 bytes.

```
```

After writing the contents of the buffers to `stdout` I overwrite the contents
of `buffer_2`, this time with 31 `B`s.

After writing the buffers to `stdout` again, I free the buffers.
This is where the glibc allocator realises that it's metadata has been
corrupted, and it aborts.
