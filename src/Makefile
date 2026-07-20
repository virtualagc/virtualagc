# yaHALMAT2 -- Unix/MSYS2 build. See Makefile.win for a normal Windows
# developer terminal (nmake/cl.exe), which is not driven by this file.

ifeq ($(origin CC),default)
CC := $(shell command -v clang >/dev/null 2>&1 && echo clang || echo gcc)
endif

CFLAGS ?= -std=c99 -Wall -Wextra -g -O0
LDFLAGS ?= -lm

SRCS := main.c loader.c disasm.c opcode_table.c opcode_lookup.c \
        literal.c ebcdic.c interp.c value.c symtab.c
OBJS := $(SRCS:.c=.o)
TARGET := yaHALMAT2

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET)
