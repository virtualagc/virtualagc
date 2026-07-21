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

# Optional POSIX real-time timer support, for interp_run_signal()'s
# --pacing=signal alternative (interp.c) to interp_run_burst()'s default
# polling-based pacing. Not every POSIX-ish target reliably has
# timer_create()/timer_settime() -- notably, real per-process interval
# timers via this exact API have historically been unreliable/absent on
# some BSD-family systems, including macOS, despite this file's own
# header comment listing Mac as a supported target -- so probe for it
# rather than assuming. Tries linking with no extra library first (modern
# glibc needs none), then falls back to -lrt (older glibc required it for
# timer_create()). Without this, --pacing=signal fails loudly at runtime
# with a clear message instead of silently degrading or crashing -- see
# interp.c's HAVE_POSIX_TIMERS-gated stub.
POSIX_TIMER_CHECK := $(shell printf '#include <signal.h>\n#include <time.h>\nint main(void){timer_t t;struct sigevent sev;sev.sigev_notify=SIGEV_SIGNAL;sev.sigev_signo=SIGRTMIN;sev.sigev_value.sival_ptr=&t;timer_create(CLOCK_MONOTONIC,&sev,&t);struct itimerspec its={{0,0},{0,0}};timer_settime(t,0,&its,(void*)0);struct sigaction sa;sa.sa_handler=(void(*)(int))0;sigemptyset(&sa.sa_mask);sa.sa_flags=0;sigaction(SIGRTMIN,&sa,(void*)0);sigset_t set;sigemptyset(&set);sigsuspend(&set);return 0;}\n' | $(CC) -std=c99 -D_POSIX_C_SOURCE=200809L -xc - -o /dev/null 2>/dev/null && echo yes)
POSIX_TIMER_LIBS :=
ifneq ($(POSIX_TIMER_CHECK),yes)
POSIX_TIMER_CHECK := $(shell printf '#include <signal.h>\n#include <time.h>\nint main(void){timer_t t;struct sigevent sev;sev.sigev_notify=SIGEV_SIGNAL;sev.sigev_signo=SIGRTMIN;sev.sigev_value.sival_ptr=&t;timer_create(CLOCK_MONOTONIC,&sev,&t);struct itimerspec its={{0,0},{0,0}};timer_settime(t,0,&its,(void*)0);struct sigaction sa;sa.sa_handler=(void(*)(int))0;sigemptyset(&sa.sa_mask);sa.sa_flags=0;sigaction(SIGRTMIN,&sa,(void*)0);sigset_t set;sigemptyset(&set);sigsuspend(&set);return 0;}\n' | $(CC) -std=c99 -D_POSIX_C_SOURCE=200809L -xc - -lrt -o /dev/null 2>/dev/null && echo yes)
ifeq ($(POSIX_TIMER_CHECK),yes)
POSIX_TIMER_LIBS := -lrt
endif
endif
ifeq ($(POSIX_TIMER_CHECK),yes)
CFLAGS += -DHAVE_POSIX_TIMERS
LDFLAGS += $(POSIX_TIMER_LIBS)
endif

SRCS := main.c loader.c disasm.c opcode_table.c opcode_lookup.c \
        literal.c ebcdic.c interp.c value.c symtab.c debug.c srcmap.c \
        container.c
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
