CC      =gcc
CFLAGS ?=
CFLAGS += -std=gnu11 -Wall -Wextra -g

CFLAGS += $(EXTRA_CFLAGS)

ifeq ($(ENABLE_UAF), 1)
CFLAGS += -DENABLE_UAF
endif

ifeq ($(ENABLE_DOUBLE_FREE), 1)
CFLAGS += -DENABLE_DOUBLE_FREE
endif

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
