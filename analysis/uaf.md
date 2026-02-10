# Use After Free

This analysis corresponds to the code in `/src/scenarios/uaf.c`.

Use after free is when heap memory is freed by the allocator, but later the
memory is accessed and used.

## Example Output

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

## ASan Analysis

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
