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

ASan errors and aborts as soon as the dangling pointer is dereferenced, not
when the pointer is used.
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

### Allocate memory for two buffers

I allocate two buffers, each 2-bytes.
Here is output from the `dumpchunk` custom gdb command showing the allocated
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
0x555555559308:	0x0000000000000021 <<-- size plus PREV_INUSE bit
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
0x555555559328:	0x0000000000000021 <<-- chunk size plus PREV_INUSE
0x555555559330:	0x0000000000000000
0x555555559338:	0x0000000000000000
```

For each buffer the glibc allocator has given us a 32-byte chunk (this is the
minimum chunk size for the glibc allocator on x86-64).

The first 8-bytes store the size of the previous chunk (meaningless unless
`PREV_INUSE` is 1).
The next 8-bytes store the size of the current chunk, with the lower 3-bits for
`PREV_INUSE`, `IS_MMAPPED` and `NON_MAIN_ARENA`.
From the value here, we can see that the size is `0x20` (32-bytes), and the
`PREV_INUSE` bit is 1.

The rest is for user data (the user pointer returned by malloc points to the
first address right after the 16-bytes of chunk metadata).
In this case the user areas are each 16-bytes.
At the moment this is all zero.

### The top chunk

Below is a hex dump of memory starting from `buffer_2`, extending past the end
of its chunk:

```
Dumping memory from buffer_2:

0x555555559330:	0x0000000000000000

0x555555559338:	0x0000000000000000
0x555555559340:	0x0000000000000000 <<-- top chunk previous size
0x555555559348:	0x0000000000020cc1 <<-- top chunk size plus metadata bits
0x555555559350:	0x0000000000000000
0x555555559358:	0x0000000000000000
0x555555559360:	0x0000000000000000
0x555555559368:	0x0000000000000000
0x555555559370:	0x0000000000000000
```

We can see, right after `buffer_2`'s chunk, is a value `0x20cc1`.
This is the size & extra bits for the allocator's **top chunk**.

### Write to the buffers

I use strcpy to write string constants into the two buffers - both are
overflows right off the bat.

`buffer_2` is an **off-by-one** overflow since `"BB"` is 3 bytes including the
null character.
In this case, the null character overflows into more user-memory in the same
chunk so it will not have any effect.
In situations with differently-sized chunks, or a different allocator, it could
corrupt chunk metadata.

`buffer_1` is blatantly overflowed by writing 31 `A`s plus the null character
to make 32 bytes.
See the `dumpchunk` output below:

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
0x555555559310:	0x4141414141414141
0x555555559318:	0x4141414141414141
```

We can see that `buffer_1`'s 2-byte size has been completely overflowed.
Not only the buffer, but also the other 14-bytes of the chunk's user-section
have been filled with 'A's (`0x41`).

The data I wrote to `buffer_1` actually overflowed the buffer entirely and
overwrote the 16-bytes of chunk metadata for `buffer_2`'s chunk.

Here is the current state of `buffer_2`'s chunk:

```
Dumping chunk for buffer_2:
Chunk start:       0x555555559320
PREV_INUSE:        1
IS_MMAPPED:        0
NON_MAIN_ARENA:    0
Previous size:     1094795585
Size:              1094795584      <<-- chunk now looks huge!
Hex dump:
Hex dump truncated to 128 bytes...
0x555555559320:	0x4141414141414141 <<-- previous size (now corrupted)
0x555555559328:	0x0041414141414141 <<-- chunk size / extra bits (corrupted)
0x555555559330:	0x0000000000004242
0x555555559338:	0x0000000000000000
0x555555559340:	0x0000000000000000
0x555555559348:	0x0000000000000411
0x555555559350:	0x325f726566667562
0x555555559358:	0x4141410a4242203a
0x555555559360:	0x4141414141414141
0x555555559368:	0x4141414141414141
0x555555559370:	0x4141414141414141
0x555555559378:	0x0000000000000a41
0x555555559380:	0x0000000000000000
0x555555559388:	0x0000000000000000
0x555555559390:	0x0000000000000000
0x555555559398:	0x0000000000000000
```

The user-data for `buffer_2` (the two `0x42`s and one overflowed `0x0` at
`0x555555559330`) are still in-tact.

We can see that the chunk metadata has been overwritten by the data I wrote to
`buffer_1`.
The chunk size is now enormous (the `dumpchunk` command truncates the hex dump
as it is very long).

The allocator relies on the chunk size to locate the next chunk in memory.
Corrupting this means the allocator can no longer correctly walk the heap.

Because the chunk is now massive, the allocator will think addresses way past
the end of the chunk are actually within the chunk.

In this case, the next chunk is the **top chunk**.
We can now overflow from `buffer_2` into top chunk metadata.

### Corrupting top chunk metadata

Now I write a string of 31 'B's plus one `0x0` (32-bytes) to `buffer_2`,
overwriting what was there previously.
See the `dumpchunk` output below:

```
Dumping chunk for buffer_2:
Chunk start:       0x555555559320
PREV_INUSE:        1
IS_MMAPPED:        0
NON_MAIN_ARENA:    0
Previous size:     1094795585
Size:              1094795584
Hex dump:
Hex dump truncated to 128 bytes...
0x555555559320:	0x4141414141414141
0x555555559328:	0x0041414141414141
0x555555559330:	0x4242424242424242
0x555555559338:	0x4242424242424242
0x555555559340:	0x4242424242424242
0x555555559348:	0x0042424242424242
0x555555559350:	0x325f726566667562
0x555555559358:	0x424242424242203a
0x555555559360:	0x4242424242424242
0x555555559368:	0x4242424242424242
0x555555559370:	0x4242424242424242
0x555555559378:	0x0000000000000a42
0x555555559380:	0x0000000000000000
0x555555559388:	0x0000000000000000
0x555555559390:	0x0000000000000000
0x555555559398:	0x0000000000000000
```

The value at address `0x555555559348` (the top chunk size) has now been
overwritten.
The top chunk is now compromised.

Interestingly the program continues execution.

The allocator code does not get invoked when the user writes to heap memory,
so it cannot check the validity of metadata until the user calls an allocator
function like `malloc` or `free`.

When I free my buffers, the allocator aborts, citing "double free or
corruption".
