#!/bin/bash

make clean \
&& make EXTRA_CFLAGS="-fsanitize=address" \
&& ./out
