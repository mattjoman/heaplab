# Writeup

Here I give a written explanation of the bugs, undefined behaviour (UB), and heap misuse in the project scenarios.
Please read in conjunction with the source code.

## UAF (Use After Free)

Use after free is when heap memory is freed by the allocator, but later the memory is accessed and used.

### Example Output

```
Allocated an int at 0x556fb804e310
With a value of     3
Freed the int at    0x556fb804e310
Value is now        1459322958
Value updated to    4
```

Once the allocated memory is freed, the value at the address becomes some massive number.
***I think this is some bookkeeping value set by the allocator.***

The allocator did not abort the process, so this bug could propagate before being noticed.

### ASan Results

ASan errors and aborts as soon as the dangling pointer is dereferenced, not when the pointer is used.
Below we can see that ASan has detected that my heap int is being accessed after being freed:

```
==3287==ERROR: AddressSanitizer: heap-use-after-free on address 0x7b382ede0010 at pc 0x556cb57d0a4a bp 0x7ffd2447af00 sp 0x7ffd2447aef0
READ of size 4 at 0x7b382ede0010 thread T0
    #0 0x556cb57d0a49 in uaf src/scenarios/uaf.c:24
    #1 0x556cb57d031c in main src/main.c:16
```

It also produces a full lifetime of the offending heap data (where it was allocated & where it was freed).

ASan poisons addresses once they are freed, as can be seen in the shadow bytes below:

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

The allocator detected the double-free and aborted on the second free with a core dump.

### ASan Results

ASan errors and aborts as soon as the double-free is attempted:

```
==3448==ERROR: AddressSanitizer: attempting double-free on 0x7c137bde0010 in thread T0:
    #0 0x7ff37d51f79d in free /usr/src/debug/gcc/gcc/libsanitizer/asan/asan_malloc_linux.cpp:51
    #1 0x55ff84d8ed81 in double_free src/scenarios/double_free.c:23
    #2 0x55ff84d8e36c in main src/main.c:18
```

It provides lifetime info for the offending data including where it was initially freed:

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
This suggests that this is not how it detects double frees (***I assume it keeps track of addresses that have been freed an not reallocated?***).
