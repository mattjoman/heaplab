CC      =gcc
CFLAGS ?=
CFLAGS += -std=gnu11 -Wall -Wextra -g

CFLAGS += $(EXTRA_CFLAGS)

SRCS=src/main.c \
		 src/scenarios/proper_usage.c \
		 src/scenarios/uaf.c \
		 src/scenarios/double_free.c \
		 src/allocator/malloc_allocator.c \
		 src/scenarios/heap_overflow.c
OBJS=$(SRCS:.c=.o)
OUT=build/out

all: $(OUT)

$(OUT): $(OBJS)
	mkdir -p build/
	$(CC) $(CFLAGS) -o $@ $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(OUT)

# ---------------------------
# Mark phony targets
# ---------------------------

.PHONY: all clean uaf double_free heap_overflow
