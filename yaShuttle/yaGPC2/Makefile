# yaGPC2 — C port of `gpc run` (AP-101 GPC batch simulator)
#
# This Makefile targets GNU Make on Linux, macOS, or Windows-under-MSYS2
# (any POSIX-ish shell). Native Windows (cmd.exe/PowerShell, no MSYS2)
# uses NMakefile instead (`nmake /f NMakefile`), which defaults to MSVC's
# cl.exe — see that file's header comment.

# Compiler selection: default to clang, falling back to gcc if clang
# isn't on PATH — but only when the caller hasn't already chosen a
# compiler (`make CC=gcc`, a CC= environment variable, etc). GNU Make's
# own built-in default for CC is the literal string "cc"; $(origin CC)
# reports "default" only when nothing else set it, so this leaves any
# explicit choice alone.
ifeq ($(origin CC),default)
  CC := $(shell command -v clang 2>/dev/null)
  ifeq ($(strip $(CC)),)
    CC := gcc
  endif
endif

# yaGpcIntegration.h -- the shared, byte-for-byte contract between yaGPC2
# and yaHALMAT2 -- lives one directory up in the shared yaGpcIntegration/
# hub (single copy, not a per-repo duplicate anymore), so every compile
# needs this on its include path. Quote-form #include "yaGpcIntegration.h"
# already searches the including file's own directory first, then falls
# through to -I paths -- since no local copy exists in src/ anymore, every
# such #include resolves here.
INTEGRATION_DIR := ../yaGpcIntegration

CSTD    := -std=c11
WARN    := -Wall -Wextra
OPT     := -O2 -g
CFLAGS  ?= $(CSTD) $(WARN) $(OPT) -I$(INTEGRATION_DIR)
LDFLAGS ?=
LDLIBS  := -lm
AR      ?= ar

# Optional POSIX real-time timer support, for run.c's --pacing=signal
# alternative to --pacing=burst's default polling-based pacing (mirrors
# yaHALMAT2's own interp_run_signal()/HAVE_POSIX_TIMERS probe in its own
# Makefile, byte-for-byte). Not every POSIX-ish target reliably has
# timer_create()/timer_settime() -- notably, real per-process interval
# timers via this exact API have historically been unreliable/absent on
# some BSD-family systems, including macOS -- so probe for it rather
# than assuming. Tries linking with no extra library first (modern glibc
# needs none), then falls back to -lrt (older glibc required it for
# timer_create()). Without this, --pacing=signal fails loudly at runtime
# with a clear message instead of silently degrading or crashing -- see
# run.c's HAVE_POSIX_TIMERS-gated stub.
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
LDLIBS += $(POSIX_TIMER_LIBS)
endif

# POSIX threads, probed the same way and for the same reason: the bus
# bridge puts its outbound sends on a thread of their own, because a
# 511-halfword display fill is 511 separate multicast datagrams at about
# 8 us each and doing them on the emulation thread does not fit inside
# the 10.7 ms the display's own bus program allows.  Only bcenet_transport.c
# uses it, only under --bce-network; without pthreads it falls back to
# pumping the queue inline exactly as before.
PTHREAD_CHECK := $(shell printf '#include <pthread.h>\nstatic void *f(void *p){return p;}\nint main(void){pthread_t th;pthread_mutex_t m;pthread_mutex_init(&m,(void*)0);pthread_create(&th,(void*)0,f,(void*)0);pthread_join(th,(void*)0);pthread_mutex_destroy(&m);return 0;}\n' | $(CC) -std=c99 -D_POSIX_C_SOURCE=200809L -xc - -pthread -o /dev/null 2>/dev/null && echo yes)
ifeq ($(PTHREAD_CHECK),yes)
CFLAGS  += -DHAVE_PTHREADS -pthread
LDLIBS  += -pthread
endif

SRC_DIR   := src
BUILD_DIR := build
BIN       := yaGPC2
LIB       := libyaGPC2.a

SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRCS))
DEPS := $(OBJS:.o=.d)

# Everything except main.o (which defines the CLI's own main() and would
# clash with an integrator's own) -- the embedding surface (src/gpcops.c
# and everything it pulls in transitively) plus every emulator internal
# it needs, archived as one linkable unit so an integrator embedding
# yaGPC2 links -lyaGPC2 + #include "yaGpcIntegration.h" and is done,
# rather than having to separately enumerate the object list themselves
# (which is exactly what GPCOPS_TEST_DEPS used to do below, by hand, for
# this Makefile's own test/example binaries -- see LIB_OBJS' own use
# there now instead).
LIB_OBJS := $(filter-out $(BUILD_DIR)/main.o,$(OBJS))

.PHONY: all clean test paced-example

all: $(BIN) $(LIB)

$(BIN): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

$(LIB): $(LIB_OBJS)
	$(AR) rcs $@ $(LIB_OBJS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c -o $@ $<

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

-include $(DEPS)

TEST_BIN_DIR := $(BUILD_DIR)/test

UNIT_TESTS := test_packedbits test_strfmt test_ebcdic test_q31 test_regmem test_mcm_membus test_floatIBM test_cpu_ea test_cpu_instr_decode test_cpu_instr_exec test_iop_bce_exec test_iop_msc_exec test_instr_tostr test_iop_exec_processors test_iop_discretes test_gpcops test_schedule

test: all $(addprefix $(TEST_BIN_DIR)/,$(UNIT_TESTS)) $(TEST_BIN_DIR)/example_gpcops_paced_run
	./test/run_all.sh
	./test/test_debugger.sh
	./test/test_scheduler.sh
	./test/test_io_read.sh
	./test/test_random.sh
	./test/test_rtl.sh
	@for t in $(UNIT_TESTS); do $(TEST_BIN_DIR)/$$t || exit 1; done
	$(TEST_BIN_DIR)/example_gpcops_paced_run

$(TEST_BIN_DIR):
	mkdir -p $(TEST_BIN_DIR)

$(TEST_BIN_DIR)/test_packedbits: test/test_packedbits.c src/util.c src/util.h test/packedbits_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_packedbits.c src/util.c $(LDLIBS)

$(TEST_BIN_DIR)/test_strfmt: test/test_strfmt.c src/strfmt.c src/strfmt.h test/strfmt_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_strfmt.c src/strfmt.c $(LDLIBS)

$(TEST_BIN_DIR)/test_ebcdic: test/test_ebcdic.c src/ebcdic.c src/ebcdic.h test/ebcdic_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_ebcdic.c src/ebcdic.c $(LDLIBS)

$(TEST_BIN_DIR)/test_q31: test/test_q31.c src/q31.c src/q31.h test/q31_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_q31.c src/q31.c $(LDLIBS)

$(TEST_BIN_DIR)/test_regmem: test/test_regmem.c src/regmem.c src/regmem.h src/util.c test/regmem_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_regmem.c src/regmem.c src/util.c $(LDLIBS)

$(TEST_BIN_DIR)/test_mcm_membus: test/test_mcm_membus.c src/mcm.c src/mcm.h src/membus.c src/membus.h test/mcm_membus_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_mcm_membus.c src/mcm.c src/membus.c $(LDLIBS)

$(TEST_BIN_DIR)/test_floatIBM: test/test_floatIBM.c src/floatIBM.c src/floatIBM.h test/floatIBM_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_floatIBM.c src/floatIBM.c $(LDLIBS)

IOP_DEPS := src/iop.c src/iop_bce_instr.c src/iop_msc_instr.c

$(TEST_BIN_DIR)/test_cpu_ea: test/test_cpu_ea.c src/cpu.c src/cpu.h src/regmem.c src/mcm.c src/membus.c src/util.c src/timing.c $(IOP_DEPS) test/cpu_ea_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_cpu_ea.c src/cpu.c src/regmem.c src/mcm.c src/membus.c src/util.c src/timing.c $(IOP_DEPS) $(LDLIBS)

CPU_INSTR_DEPS := src/cpu_instr.c src/cpu.c src/regmem.c src/mcm.c src/membus.c src/util.c src/floatIBM.c src/q31.c src/strfmt.c src/timing.c $(IOP_DEPS)

$(TEST_BIN_DIR)/test_cpu_instr_decode: test/test_cpu_instr_decode.c $(CPU_INSTR_DEPS) src/cpu_instr.h test/cpu_instr_decode_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_cpu_instr_decode.c $(CPU_INSTR_DEPS) $(LDLIBS)

$(TEST_BIN_DIR)/test_cpu_instr_exec: test/test_cpu_instr_exec.c $(CPU_INSTR_DEPS) src/cpu_instr.h test/cpu_instr_exec_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_cpu_instr_exec.c $(CPU_INSTR_DEPS) $(LDLIBS)

IOP_TEST_DEPS := src/iop.c src/iop_bce_instr.c src/iop_msc_instr.c src/regmem.c src/mcm.c src/membus.c src/util.c src/cpu.c src/floatIBM.c src/q31.c src/timing.c

$(TEST_BIN_DIR)/test_iop_bce_exec: test/test_iop_bce_exec.c $(IOP_TEST_DEPS) src/iop.h test/iop_bce_exec_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_iop_bce_exec.c $(IOP_TEST_DEPS) $(LDLIBS)

$(TEST_BIN_DIR)/test_iop_msc_exec: test/test_iop_msc_exec.c $(IOP_TEST_DEPS) src/iop.h test/iop_msc_exec_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_iop_msc_exec.c $(IOP_TEST_DEPS) $(LDLIBS)

$(TEST_BIN_DIR)/test_instr_tostr: test/test_instr_tostr.c $(CPU_INSTR_DEPS) src/cpu_instr.h test/instr_tostr_fixtures.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_instr_tostr.c $(CPU_INSTR_DEPS) $(LDLIBS)

$(TEST_BIN_DIR)/test_iop_exec_processors: test/test_iop_exec_processors.c $(IOP_TEST_DEPS) src/iop.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_iop_exec_processors.c $(IOP_TEST_DEPS) $(LDLIBS)

$(TEST_BIN_DIR)/test_iop_discretes: test/test_iop_discretes.c $(IOP_TEST_DEPS) src/iop.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_iop_discretes.c $(IOP_TEST_DEPS) $(LDLIBS)

# Both link against $(LIB) itself, not the raw source list -- deliberately,
# since that's exactly what a real integrator would do, and it doubles as
# a live check that $(LIB) is actually self-sufficient (no missing object
# silently papered over by falling back to source).
$(TEST_BIN_DIR)/test_gpcops: test/test_gpcops.c $(LIB) $(INTEGRATION_DIR)/yaGpcIntegration.h test/fixtures/hello.fcm | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_gpcops.c $(LIB) $(LDLIBS)

# Tier-1 hand-assembled scheduler-mechanics tests (src/schedule.h/.c) --
# see test/test_schedule.c's own header comment. No fixture files: every
# program is hand-assembled directly into MCM by the test itself.
$(TEST_BIN_DIR)/test_schedule: test/test_schedule.c $(LIB) $(INTEGRATION_DIR)/yaGpcIntegration.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/test_schedule.c $(LIB) $(LDLIBS)

# Helper for test/bcenet_smoke.sh (manual, network-dependent -- not part
# of the `test` target's own UNIT_TESTS list or recipe). Links directly
# against src/bcenet_transport.c, not $(LIB), since that's the one file
# it actually exercises.
$(TEST_BIN_DIR)/bcenet_recv_check: test/bcenet_recv_check.c src/bcenet_transport.c src/bcenet_transport.h | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/bcenet_recv_check.c src/bcenet_transport.c $(LDLIBS)

# Not a unit test -- a runnable example of GpcOps-only usage (see its own
# header comment), and per its own header comment now the demonstration
# of exactly how an integrator would build against $(LIB): compiled --
# and, in the `test` target above, run -- on every `make test`, catching
# drift against both yaGpcIntegration.h and $(LIB)'s own completeness.
$(TEST_BIN_DIR)/example_gpcops_paced_run: test/example_gpcops_paced_run.c $(LIB) $(INTEGRATION_DIR)/yaGpcIntegration.h test/fixtures/hello.fcm | $(TEST_BIN_DIR)
	$(CC) $(CFLAGS) -o $@ test/example_gpcops_paced_run.c $(LIB) $(LDLIBS)

# Shorthand for `make build/test/example_gpcops_paced_run` -- builds just
# the library and this one example, without any of the other 14 unit
# test binaries or run_all.sh/test_debugger.sh (those only run as part
# of the `test` target's own recipe, never pulled in as a prerequisite
# here).
paced-example: $(TEST_BIN_DIR)/example_gpcops_paced_run

clean:
	rm -rf $(BUILD_DIR) $(BIN) $(LIB)
