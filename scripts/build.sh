#!/bin/bash

CFLAGS="-std=gnu11 -Wall -Wextra"

make clean
make EXTRA_CFLAGS="$CFLAGS -g -fsanitize=address -fno-omit-frame-pointer -O0"
cp build/out build/asan.out

make clean
make EXTRA_CFLAGS="$CFLAGS -g -fno-omit-frame-pointer -O0"
cp build/out build/valgrind.out

make clean
make EXTRA_CFLAGS="$CFLAGS -g -fno-omit-frame-pointer -O0"
cp build/out build/debug.out

make clean
make EXTRA_CFLAGS="$CFLAGS -O3"
cp build/out build/prod.out

make clean
