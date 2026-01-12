CC=gcc
CFLAGS=-O2 -Wall -Wextra -std=gnu11 -g

SRCS=src/main.c src/scenarios/uaf.c src/scenarios/double_free.c src/allocator/malloc_allocator.c
OBJS=$(SRCS:.c=.o)

OUT=out

all: $(OUT)

$(OUT): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

%.0: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(OUT)

.PHONY: all clean
