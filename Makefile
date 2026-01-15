CC      =gcc
CFLAGS ?=
CFLAGS += -std=gnu11 -Wall -Wextra -g

CFLAGS += $(EXTRA_CFLAGS)

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


# ---------------------------
# Scenario targets
# ---------------------------

uaf: CFLAGS += -DUAF
uaf: all

double_free: CFLAGS += -DDOUBLE_FREE
double_free: all

heap_overflow: CFLAGS += -DHEAP_OVERFLOW
heap_overflow: all


# ---------------------------
# Mark phony targets
# ---------------------------

.PHONY: all clean uaf double_free heap_overflow
