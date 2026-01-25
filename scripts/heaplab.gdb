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

    printf "\n"

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

    printf "\n"
end




#define
#end
