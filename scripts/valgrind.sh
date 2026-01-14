#!/bin/bash

make clean \
&& make \
&& valgrind --tool=memcheck ./out
