# yaHALMAT2 -- Unix/MSYS2 build. See Makefile.win for a normal Windows
# developer terminal (nmake/cl.exe), which is not driven by this file.

ifeq ($(origin CC),default)
CC := $(shell command -v clang >/dev/null 2>&1 && echo clang || echo gcc)
endif

CFLAGS ?= -std=c99 -Wall -Wextra -g -O0
LDFLAGS ?= -lm

# Optional zlib dependency, for decompressing the gzip'd COMMONx.out.bin.gz
# memory images HALSFC produces (needed for CHARACTER literal text -- see
# literal.c). Mirrors the reference yaHALMAT emulator's own Makefile probe
# (../Halmat/emu/Makefile). Falls back to popen("gzip -dc ...") in
# literal.c if zlib isn't found, so the build still works without it.
ZLIB_CHECK := $(shell echo 'int main(){return 0;}' | $(CC) -xc - -lz -o /dev/null 2>/dev/null && echo yes)
ifeq ($(ZLIB_CHECK),yes)
CFLAGS += -DHAVE_ZLIB
LDFLAGS += -lz
endif

SRCS := main.c loader.c disasm.c opcode_table.c opcode_lookup.c \
        literal.c ebcdic.c interp.c value.c symtab.c debug.c
OBJS := $(SRCS:.c=.o)
DEPS := $(SRCS:.c=.d)
TARGET := yaHALMAT2

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDFLAGS)

# -MMD -MP generates a per-.o .d file listing every header it #includes,
# so a change to a shared header (e.g. state.h) triggers a rebuild of
# every .o that includes it, not just the .c files touched directly --
# without this, a struct-size change in a header can silently leave some
# .o files compiled against the old layout while others use the new one,
# corrupting memory at runtime (ABI mismatch between translation units)
# with no compile-time warning at all. Confirmed the hard way this
# session: adding fields to halmat_syt_entry_t/halmat_vac_slot_t in
# state.h without a `make clean` produced exactly this crash.
%.o: %.c
	$(CC) $(CFLAGS) -MMD -MP -c -o $@ $<

-include $(DEPS)

clean:
	rm -f $(OBJS) $(DEPS) $(TARGET)
