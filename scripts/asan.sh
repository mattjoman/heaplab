#!/bin/bash

case "$1" in
    "uaf")
        make clean
        make EXTRA_CFLAGS="-fsanitize=address -O0" \
            UAF=1
        ;;
    "double_free")
        make clean
        make EXTRA_CFLAGS="-fsanitize=address -O0" \
            DOUBLE_FREE=1
        ;;
    *)
        echo "Usage: $0 {uaf|double_free}"
        exit
        ;;
esac

./out
