CC      =gcc
CFLAGS ?=
CFLAGS += $(EXTRA_CFLAGS)

SRCS=src/main.c \
		 src/scenarios/proper_usage.c \
		 src/scenarios/uaf.c \
		 src/scenarios/double_free.c \
		 src/allocator/malloc_allocator.c \
		 src/scenarios/heap_overflow.c
OBJS=$(SRCS:.c=.o)
OUT=bin/out

all: $(OUT)

$(OUT): $(OBJS)
	mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(OUT)

# ---------------------------
# Mark phony targets
# ---------------------------

.PHONY: all clean
