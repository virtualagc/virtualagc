# yaGpcIntegration/samples/Makefile -- builds the shared, emulator-
# agnostic sample programs against the libraries the parent Makefile
# already copied into ..  Run `make` from the parent directory (or
# `make -C samples` / plain `make` here after `make libs` up there) --
# not meant to be useful standalone before that copy step has happened.

INTEGRATION_DIR := ..

ifeq ($(origin CC),default)
  CC := $(shell command -v clang 2>/dev/null)
  ifeq ($(strip $(CC)),)
    CC := gcc
  endif
endif

CFLAGS ?= -std=c11 -Wall -Wextra -O2 -g -I$(INTEGRATION_DIR)

# libyaHALMAT2.a has its own optional transitive dependencies, detected
# and linked into yaHALMAT2's own binary automatically by its Makefile
# (see that file's own ZLIB_CHECK/POSIX_TIMER_CHECK) -- but a static
# library doesn't carry that link requirement with it, so any separate
# consumer (this one included) has to independently supply the same
# libs if the .a was actually built with them. Probed the same way here,
# for the same reason. Harmless (never referenced, so never linked in)
# if libyaHALMAT2.a happens not to need one of these on a given machine.
ZLIB_CHECK := $(shell echo 'int main(){return 0;}' | $(CC) -xc - -lz -o /dev/null 2>/dev/null && echo yes)
HALMAT2_EXTRA_LIBS :=
ifeq ($(ZLIB_CHECK),yes)
  HALMAT2_EXTRA_LIBS += -lz
endif
POSIX_TIMER_CHECK := $(shell printf '#include <signal.h>\n#include <time.h>\nint main(void){timer_t t;struct sigevent sev;sev.sigev_notify=SIGEV_SIGNAL;sev.sigev_signo=SIGRTMIN;sev.sigev_value.sival_ptr=&t;timer_create(CLOCK_MONOTONIC,&sev,&t);return 0;}\n' | $(CC) -std=c99 -D_POSIX_C_SOURCE=200809L -xc - -lrt -o /dev/null 2>/dev/null && echo yes)
ifeq ($(POSIX_TIMER_CHECK),yes)
  HALMAT2_EXTRA_LIBS += -lrt
endif

LDLIBS := -lm $(HALMAT2_EXTRA_LIBS)

LIBS := $(INTEGRATION_DIR)/libyaGPC2.a $(INTEGRATION_DIR)/libyaHALMAT2.a
HEADER := $(INTEGRATION_DIR)/yaGpcIntegration.h

.PHONY: all clean

all: paced_run multi_gpc_demo

paced_run: paced_run.c $(LIBS) $(HEADER)
	$(CC) $(CFLAGS) -o $@ paced_run.c $(LIBS) $(LDLIBS)

multi_gpc_demo: multi_gpc_demo.c $(LIBS) $(HEADER)
	$(CC) $(CFLAGS) -o $@ multi_gpc_demo.c $(LIBS) $(LDLIBS)

clean:
	rm -f paced_run multi_gpc_demo
