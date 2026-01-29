#!/bin/bash

CFLAGS=" -std=gnu11 -Wall -Wextra"

make clean
make EXTRA_CFLAGS="$CFLAGS -g -fsanitize=address -fno-omit-frame-pointer -O0"
cp bin/out bin/asan.out

make clean
make EXTRA_CFLAGS="$CFLAGS -g -fno-omit-frame-pointer -O0"
cp bin/out bin/valgrind.out

make clean
make EXTRA_CFLAGS="$CFLAGS -g -fno-omit-frame-pointer -O0"
cp bin/out bin/debug.out

make clean
make EXTRA_CFLAGS="$CFLAGS -O3"
cp bin/out bin/prod.out

make clean
