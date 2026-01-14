#!/bin/bash

make clean \
&& make EXTRA_CFLAGS="-fsanitize=address -O0" \
&& ./out
