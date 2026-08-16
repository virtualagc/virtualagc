# License:    This program is declared by its author, Ronald Burkey, to be the
#             U.S. Public Domain, and may be freely used, modified, or
#             distributed for any purpose whatever.
# Filename:   Makefile
# Purpose:    Builds ASM101Sa, the C port of the AP-101S assembler, on Linux
#             and macOS with either gcc or clang.
# Contact:    info@sandroid.org
#
# Usage, from the parent directory -- the one holding ASM101S.py:
#     make -C ASM101Sa-src              build ../ASM101Sa
#     make -C ASM101Sa-src CC=clang     build with clang instead of the default
#     make -C ASM101Sa-src DEBUG=1      build unoptimised, with symbols
#     make -C ASM101Sa-src ASAN=1       build with AddressSanitizer and UBSan
#     make -C ASM101Sa-src install      copy it to $(PREFIX)/bin (/usr/local)
#     make -C ASM101Sa-src clean        remove the objects and the executable
#     make -C ASM101Sa-src regenerate   re-derive parser_asm.c and tables.c
#
# Windows is built with Makefile.msvc (nmake, for Visual C++) or Makefile.mingw
# (GNU make, for MinGW-w64/MSYS2/Cygwin); each carries its own usage notes.

# THE EXECUTABLE IS BUILT INTO THE PARENT DIRECTORY, beside ASM101S.py and the
# ASM101S / ASM101S.bat launchers that run it, so that one directory on the PATH
# offers both assemblers.  That is also why this directory is not itself called
# ASM101Sa: a directory and a file of the same name cannot coexist in one
# parent.  On Windows the collision would be hidden by the .exe suffix, so it
# would surprise whoever next built on Linux rather than failing where it was
# introduced.
#
# Override BINDIR to put the executable somewhere else; BINDIR=. restores the
# old behaviour of building it here in the source directory.
ifeq ($(OS),Windows_NT)
EXE ?= ASM101Sa.exe
else
EXE ?= ASM101Sa
endif
BINDIR ?= ..
TARGET  = $(BINDIR)/$(EXE)
PREFIX ?= /usr/local

# -fwrapv IS NOT OPTIONAL.  A symbol's value is a hashcode of up to 28 bits
# shifted left by 36, so it reaches bit 63, and the differences the assembler
# takes between such values rely on wrapping being defined.  Signed overflow is
# undefined behaviour in C, and an optimiser is entitled to assume it cannot
# happen; -fwrapv is what makes the assumption the code actually relies on.
CSTD    = -std=c99
WARN    = -Wall -Wextra -Wno-unused-parameter
COMMON  = $(CSTD) $(WARN) -fwrapv -I.

ifdef DEBUG
OPT     = -O0 -g
else
OPT     = -O2
endif

ifdef ASAN
SANITIZE = -fsanitize=address,undefined -fno-omit-frame-pointer -g
else
SANITIZE =
endif

CFLAGS  += $(COMMON) $(OPT) $(SANITIZE)
LDFLAGS += $(SANITIZE)
LDLIBS  += -lm

SOURCES = \
	asm101s.c \
	dec.c \
	ebcdic.c \
	expressions.c \
	fieldparser.c \
	ibmhex.c \
	model101.c \
	objectwriter.c \
	parser_asm.c \
	pattern.c \
	peg.c \
	pyutil.c \
	readlisting.c \
	tables.c \
	tablesupport.c \
	val.c

OBJECTS = $(SOURCES:.c=.o)

HEADERS = \
	common.h \
	dec.h \
	ebcdic.h \
	expressions.h \
	fieldparser.h \
	ibmhex.h \
	model101.h \
	objectwriter.h \
	parser_asm.h \
	pattern.h \
	peg.h \
	pyutil.h \
	readlisting.h \
	tables.h \
	val.h \
	version.h

.PHONY: all clean install uninstall regenerate check

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) $(LDLIBS)

# Every object depends on every header.  The set is small and the build is
# seconds, so a precise dependency graph would buy nothing but the chance of
# being wrong about it.
$(OBJECTS): $(HEADERS)

clean:
	rm -f $(OBJECTS) $(TARGET) parsedump

install: $(TARGET)
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp $(TARGET) $(DESTDIR)$(PREFIX)/bin/$(EXE)

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(EXE)

# The differential-test harness for the parser:  reads `RULE<TAB>TEXT` pairs and
# writes a canonical rendering of the parse tree, so that its output can be
# diffed against tools/parsedump.py running the real TatSu parser.
parsedump: tools/parsedump.c $(filter-out asm101s.o,$(OBJECTS))
	$(CC) $(CFLAGS) -o $@ tools/parsedump.c \
		$(filter-out asm101s.o,$(OBJECTS)) $(LDLIBS)

# Re-derive the generated sources from the Python assembler.  ASM101S should
# name the directory holding ASM101S.py; this is not part of an ordinary build,
# and the generated files are committed.  The default is the parent, which is
# where the Python assembler now sits.
ASM101S ?= ..

regenerate:
	python3 tools/xlate.py $(ASM101S)/parser_asm.py $(CURDIR)/parser_asm.c
	python3 tools/gentables.py $(ASM101S) $(CURDIR)/tables.c
