# ODYSSEY-AGC build.  Self-contained: it does NOT modify the upstream yaAGC
# Makefile or CMakeLists, so the normal VirtualAGC build is untouched.
#
#   make                      build build/odyssey-agc
#   make roms YAYUL=/path/to/yaYUL   assemble the AGC test ROMs
#   make test YAYUL=/path/to/yaYUL   run unit, integration and state-isolation tests
#   make asan                 same tests under AddressSanitizer + UBSan
#   make clean
#
# yaYUL is not built here.  Build it with the upstream CMake (see README.md) or
# put an existing yaYUL on PATH.
#
# The upstream engine sources (agc_engine.c, agc_engine_init.c, rfopen.c) are
# compiled with -w because they emit warnings under modern compilers.  Note that
# agc_engine.c/.h and agc_engine_init.c carry the milestone-4 state-isolation
# change; see docs/UPSTREAM-CHANGES.md.  ODYSSEY code is built with -Wall -Wextra.

CC      ?= gcc
UP      := ..
BUILD   ?= build
SAN     ?=
CFLAGS  ?= -O2 -g
ODYFLAGS := -std=gnu99 -Wall -Wextra -I$(UP) -I. $(SAN)
UPFLAGS  := -std=gnu99 -w -I$(UP) $(SAN)

ODY_SRCS := odyssey_engine.c odyssey_io.c odyssey_audio.c
UP_SRCS  := $(UP)/agc_engine.c $(UP)/agc_engine_init.c $(UP)/rfopen.c

ODY_OBJS := $(patsubst %.c,$(BUILD)/%.o,$(ODY_SRCS))
UP_OBJS  := $(patsubst $(UP)/%.c,$(BUILD)/up_%.o,$(UP_SRCS))

.PHONY: all roms test asan clean
all: $(BUILD)/odyssey-agc $(BUILD)/test_unit

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: %.c | $(BUILD)
	$(CC) $(CFLAGS) $(ODYFLAGS) -c $< -o $@

$(BUILD)/up_%.o: $(UP)/%.c | $(BUILD)
	$(CC) $(CFLAGS) $(UPFLAGS) -c $< -o $@

$(BUILD)/odyssey_main.o: odyssey_main.c | $(BUILD)
	$(CC) $(CFLAGS) $(ODYFLAGS) -c $< -o $@

$(BUILD)/odyssey-agc: $(BUILD)/odyssey_main.o $(ODY_OBJS) $(UP_OBJS)
	$(CC) $(SAN) -o $@ $^ -lm

$(BUILD)/test_unit.o: tests/test_unit.c | $(BUILD)
	$(CC) $(CFLAGS) $(ODYFLAGS) -c $< -o $@

$(BUILD)/test_unit: $(BUILD)/test_unit.o $(ODY_OBJS) $(UP_OBJS)
	$(CC) $(SAN) -o $@ $^ -lm

roms:
	YAYUL="$(YAYUL)" BUILD="$(BUILD)" tools/build_roms.sh

test: all roms
	BUILD="$(BUILD)" tests/run_tests.sh
	BUILD="$(BUILD)" SAN="$(SAN)" tests/run_isolation_tests.sh

asan:
	$(MAKE) BUILD=build-asan SAN="-fsanitize=address,undefined -fno-omit-frame-pointer" YAYUL="$(YAYUL)" test

clean:
	rm -rf build build-asan
