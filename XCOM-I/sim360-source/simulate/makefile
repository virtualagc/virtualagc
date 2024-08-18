#
#	IBM/360 simulator for both XPL and HAL/S compiler
#
#	Author: Daniel Weaver
#
# History:	2024-08-18 RSB	Modified to account for Linux/Mac gcc/clang,
#				vs Linux Mingw cross compiler, 
#				vs Windows w/MSYS2, vs Windows w/Visual Studio.

# For a Windows w/Visual Studio compile, requires separate installation of
# the following utilities:
#	GNU make	(for all targets)
#	tar		(for target `save`)
#	ctags		(for target `tags`)

CFLAGS=-Wall

ifeq ($(strip $(CC)),)
	# Default compiler if not overriden by environment variable is gcc.
	# The problem letting it default to `cc` is that we can't use it to
	# detect which platform we're on, and there aren't any good ways to
	# reliably detect that otherwise.  (Could require rethinking!)
	CC = gcc
endif
ifeq ($(CC), cl)
        # Here for Visual Studio command-line compiler `cl`.
        OUT = /Fe:
        LIBS =
        EXT = 
        RDYNAMIC = 
        CP = copy
        RM = del /F
else ifeq ($(findstring mingw,$(CC)),mingw)
        # Here for cross-compiling from Linux to Windows with Mingw.
        OUT = -o
        LIBS = -lm
        EXT = .exe
        RDYNAMIC =
        CP = cp
        RM = rm -f
else
	# Here for gcc/clang on native Linux/Mac or MSYS2 on Windows.
        OUT = -o
        LIBS = -lm
        EXT = 
        RDYNAMIC = -rdynamic
        CP = cp
        RM = rm -f
endif

all:	sim360$(EXE)
	$(CP) sim360$(EXE) ..

sim360$(EXE): system.o ibm360.o smop.o debug.o
	$(CC) $(CFLAGS) system.o ibm360.o smop.o debug.o $(LIBS) \
		$(RDYNAMIC) $(OUT) sim360$(EXT)

%.o: %.c
	$(CC) $(CFLAGS) -c $(OUT) $@ $^

tags:
	ctags system.c ibm360.c smop.c debug.c sim.h

save:	.FORCE
	tar -cf `date "+save/%m%d%Hsim.tar"` makefile *.c *.h

clean:
	-$(RM) *.o *.out *.tmp *.obj sim360 sim360.exe tags

.FORCE:

