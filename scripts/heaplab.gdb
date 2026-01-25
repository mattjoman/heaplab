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

    set $prev_inuse = (int)((*$ptr_size) & 0b001)
    set $is_mmapped = (int)((*$ptr_size) & 0b010)
    set $non_main_arena = (int)((*$ptr_size) & 0b100)

    set $size = (long)(*$ptr_size) & ~0x7
    set $prev_size = (long)(*$ptr_prev_size)

    printf "Chunk start:       %p\n", $ptr_prev_size
    printf "PREV_INUSE:        %d\n", $prev_inuse
    printf "IS_MMAPPED:        %d\n", $is_mmapped
    printf "NON_MAIN_ARENA:    %d\n", $non_main_arena
    printf "Previous size:     %d\n", $prev_size
    printf "Size:              %d\n", $size
    printf "Hex dump:\n"

    set $n = $size / 8
    set $ptr = (char*)$ptr_prev_size
    while ($n--)
        x/1gx $ptr
        set $ptr = $ptr + 8
    end
end
