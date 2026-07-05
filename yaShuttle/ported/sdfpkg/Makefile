# Makefile for sdfpkg -- HAL/S Symbol Data File (SDF) access library
#
# Supports Linux, macOS, and MSYS2/MinGW on Windows.
# Supports both gcc and clang; override with:
#
#   make CC=clang
#   make CC=gcc
#
# If CC is not set on the command line, we auto-detect clang vs gcc
# from whatever 'cc' resolves to, defaulting to gcc if 'cc' is absent.
#
# Targets:
#   all          build libsdfpkg.a, sdfcheck, and sdf_convert
#   test         build and run the unit tests (test_sdfpkg and test_sdf_write)
#   clean        remove build artifacts

# ====================================================================
# Compiler selection
# ====================================================================

# Allow 'make CC=clang' or 'make CC=gcc' to override.
# Default: try clang, fall back to gcc.
ifeq ($(origin CC), default)
  CC := $(or $(shell command -v clang 2>/dev/null),gcc)
endif

# ====================================================================
# Platform detection
# ====================================================================

UNAME_S := $(shell uname -s 2>/dev/null || echo Windows)

ifeq ($(UNAME_S), Darwin)
  # macOS: POSIX APIs available without feature-test macros.
  # -Wno-gnu-zero-variadic-macro-arguments suppresses a Clang pedantic
  # warning about the ##__VA_ARGS__ extension used in the test framework.
  PLATFORM_CFLAGS  = -Wno-gnu-zero-variadic-macro-arguments
  PLATFORM_LDFLAGS =
else ifeq ($(findstring MINGW, $(UNAME_S)), MINGW)
  # MSYS2 / MinGW-w64
  PLATFORM_CFLAGS  = -D_WIN32_WINNT=0x0601
  PLATFORM_LDFLAGS =
else ifeq ($(findstring MSYS, $(UNAME_S)), MSYS)
  # MSYS2 MSYS environment
  PLATFORM_CFLAGS  = -D_WIN32_WINNT=0x0601
  PLATFORM_LDFLAGS =
else
  # Linux (default)
  PLATFORM_CFLAGS  =
  PLATFORM_LDFLAGS =
endif

# ====================================================================
# Flags
# ====================================================================

CFLAGS  = -std=c11 -Wall -Wextra -Wpedantic \
           -Wno-unused-parameter \
           -g -O2 \
           -I include \
           $(PLATFORM_CFLAGS)

AR      = ar
ARFLAGS = rcs

# ====================================================================
# Sources (all in the same directory as this Makefile)
# ====================================================================

LIB_SRCS = \
    sdf_util.c    \
    sdf_io.c      \
    sdf_locate.c  \
    sdf_pagmod.c  \
    sdf_select.c  \
    sdfpkg.c      \
    sdf_write.c   \
    monitor14.c

LIB_OBJS      = $(LIB_SRCS:.c=.o)
LIB           = libsdfpkg.a
SDFCHECK      = sdfcheck
CONVERT       = sdf_convert
TEST_BIN      = test_sdfpkg
TEST_WRITE    = test_sdf_write
ALLDEP_SRCS   = $(LIB_SRCS) sdfcheck.c sdf_convert.c \
                test_sdfpkg.c test_sdf_write.c monitor14.c

# On Windows (MSYS2/MinGW) executables have the .exe extension.
# $(EXE) is appended to each binary target automatically by MinGW's
# make, but we declare it explicitly for clarity.
ifeq ($(findstring MINGW, $(UNAME_S)), MINGW)
  EXE = .exe
else ifeq ($(findstring MSYS, $(UNAME_S)), MSYS)
  EXE = .exe
else
  EXE =
endif

# ====================================================================
# Rules
# ====================================================================

.PHONY: all clean test

all: $(LIB) $(SDFCHECK)$(EXE) $(CONVERT)$(EXE)

$(LIB): $(LIB_OBJS)
	$(AR) $(ARFLAGS) $@ $^
	@rm -f $(LIB_OBJS) $(LIB_SRCS:.c=.d)
	@echo "Built $@"

$(SDFCHECK)$(EXE): sdfcheck.o $(LIB)
	$(CC) $(CFLAGS) $(PLATFORM_LDFLAGS) -o $@ $^
	@rm -f sdfcheck.o sdfcheck.d
	@echo "Built $@"

$(CONVERT)$(EXE): sdf_convert.o
	$(CC) $(CFLAGS) $(PLATFORM_LDFLAGS) -o $@ $^
	@rm -f sdf_convert.o sdf_convert.d
	@echo "Built $@"

$(TEST_BIN)$(EXE): test_sdfpkg.o $(LIB)
	$(CC) $(CFLAGS) $(PLATFORM_LDFLAGS) -o $@ $^
	@rm -f test_sdfpkg.o test_sdfpkg.d
	@echo "Built $@"

$(TEST_WRITE)$(EXE): test_sdf_write.o $(LIB)
	$(CC) $(CFLAGS) $(PLATFORM_LDFLAGS) -o $@ $^
	@rm -f test_sdf_write.o test_sdf_write.d
	@echo "Built $@"

test: $(TEST_BIN)$(EXE) $(TEST_WRITE)$(EXE)
	@echo "--- Running test_sdfpkg ---"
	./$(TEST_BIN)$(EXE)
	@echo "--- Running test_sdf_write ---"
	./$(TEST_WRITE)$(EXE)

# Compile each .c file and generate a dependency fragment as a side effect.
%.o: %.c
	$(CC) $(CFLAGS) -MMD -MF $*.d -c -o $@ $<

clean:
	rm -f $(LIB_OBJS) sdfcheck.o sdf_convert.o \
	      test_sdfpkg.o test_sdf_write.o
	rm -f $(LIB) $(SDFCHECK)$(EXE) $(CONVERT)$(EXE) \
	      $(TEST_BIN)$(EXE) $(TEST_WRITE)$(EXE)
	rm -f *.d

# Include generated dependency files if they exist.
-include $(ALLDEP_SRCS:.c=.d)
