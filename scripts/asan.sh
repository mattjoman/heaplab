#!/bin/bash

# This script compiles a given scenario with asan enabled

case "$1" in
    "uaf")
        ;;
    "double_free")
        ;;
    "heap_overflow")
        ;;
    *)
        echo "Usage: $0 {uaf|double_free|heap_overflow}"
        exit
        ;;
esac

make clean
make "$1" EXTRA_CFLAGS="-fsanitize=address -O0"
./out
