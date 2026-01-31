set pagination off

define ptrinfo
    printf "Address: %p\n", $arg0
    printf "Size:    %d\n", sizeof(*($arg0))
end

define xmem
    set $ptr   = $arg0
    set $bytes = $arg1

    if ($bytes == 4)
        x/1wx $ptr
    end
    if ($bytes == 8)
        x/1gx $ptr
    end
end

define dumpmem
    set $ptr            = $arg0
    set $bytes_per_line = $arg1
    set $n_before       = $arg2
    set $n_after        = $arg3

    set $ptr = ((char*)$ptr) - ($n_before * $bytes_per_line)

    while ($n_before--)
        xmem $ptr $bytes_per_line
        set $ptr = $ptr + $bytes_per_line
    end

    printf "\n"

    xmem $ptr $bytes_per_line
    set $ptr = $ptr + $bytes_per_line

    printf "\n"

    while ($n_after--)
        xmem $ptr $bytes_per_line
        set $ptr = $ptr + $bytes_per_line
    end
end

define dumpchunk
    set $ptr = $arg0

    set $ptr_prev_size = ((char*)$ptr) - 16
    set $ptr_size = ((char*)$ptr) - 8

    set $size = (*(size_t *)$ptr_size) & ~0x7
    set $prev_size = *(size_t *)$ptr_prev_size

    printf "Chunk start:       %p\n", $ptr_prev_size
    printf "PREV_INUSE:        %d\n", (int)((*$ptr_size) & 0b001)
    printf "IS_MMAPPED:        %d\n", (int)((*$ptr_size) & 0b010)
    printf "NON_MAIN_ARENA:    %d\n", (int)((*$ptr_size) & 0b100)
    printf "Previous size:     %d\n", $prev_size
    printf "Size:              %d\n", $size
    printf "Hex dump:\n"

    set $n = $size / 8
    if ($n > 16)
        set $n = 16
        printf "Hex dump truncated to %d bytes...\n", $n * 8
    end

    set $ptr = (char*)$ptr_prev_size
    while ($n--)
        x/1gx $ptr
        set $ptr = $ptr + 8
    end
end

define heap_overflow_scenario
    break src/scenarios/heap_overflow.c:16
    break src/scenarios/heap_overflow.c:22
    break src/scenarios/heap_overflow.c:27
    run

    printf "=========================================\n"
    printf "Buffers allocated but no data yet:\n"
    printf "=========================================\n"
    printf "Dumping chunk for buffer_1:\n"
    dumpchunk buffer_1
    printf "Dumping chunk for buffer_2:\n"
    dumpchunk buffer_2
    printf "Dumping memory from buffer_2:\n"
    dumpmem buffer_2 8 0 8

    printf "Continuing...\n\n"
    continue

    printf "=========================================\n"
    printf "Buffers loaded with data:\n"
    printf "=========================================\n"
    printf "Dumping chunk for buffer_1:\n"
    dumpchunk buffer_1
    printf "Dumping chunk for buffer_2:\n"
    dumpchunk buffer_2

    printf "Continuing...\n\n"
    continue

    printf "=========================================\n"
    printf "buffer_2 loaded with lots of data:\n"
    printf "=========================================\n"
    printf "Dumping chunk for buffer_2:\n"
    dumpchunk buffer_2

    printf "Continuing...\n\n"
    continue
end
