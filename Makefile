CC      =gcc
CFLAGS ?=
CFLAGS += -std=gnu11 -Wall -Wextra -g

CFLAGS += $(EXTRA_CFLAGS)

ifeq ($(UAF), 1)
CFLAGS += -DUAF
endif

ifeq ($(DOUBLE_FREE), 1)
CFLAGS += -DDOUBLE_FREE
endif

ifeq ($(HEAP_OVERFLOW), 1)
CFLAGS += -DHEAP_OVERFLOW
endif

SRCS=src/main.c src/scenarios/uaf.c src/scenarios/double_free.c src/allocator/malloc_allocator.c src/scenarios/heap_overflow.c
OBJS=$(SRCS:.c=.o)

OUT=out

all: $(OUT)

$(OUT): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(OUT)

.PHONY: all clean
