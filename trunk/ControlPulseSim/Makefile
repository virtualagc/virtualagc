# Filename:	Makefile
# Purpose:	Builds the ControlPulseSim program.
# Mod history:	2009-03-06 RSB	Wrote
#		2009-03-12 RSB	Added the 'clean' target.

.PHONY: default
default: ControlPulseSim

.PHONY: all-archs
all-archs: ControlPulseSim ControlPulseSim.exe ControlPulseSim-macosx

ControlPulseSim: ControlPulseSim.c
	gcc -o $@ $^

ControlPulseSim.exe: ControlPulseSim.c
	i386-mingw32-gcc -o $@ $^

ControlPulseSim-macosx: ControlPulseSim.c
	powerpc-apple-darwin9-gcc -arch ppc -arch i386 -o $@ $^

.PHONY: clean
clean:
	-rm -f ControlPulseSim *.exe *-macosx *.o *~ *.bak

