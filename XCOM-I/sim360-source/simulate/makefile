#
#	IBM/360 simulator for both XPL and HAL/S compiler
#
#	Author: Daniel Weaver
#
CFLAGS=-Wall

all:	sim360
	cp sim360 ..

sim360: system.o ibm360.o smop.o debug.o
	$(CC) $(CFLAGS) system.o ibm360.o smop.o debug.o -lm -o sim360

system.o: system.c
ibm360.o: ibm360.c
debug.o: debug.c
smop.o: smop.c

tags:
	ctags system.c ibm360.c smop.c debug.c sim.h

save:	.FORCE
	tar -cf `date "+save/%m%d%Hsim.tar"` makefile *.c *.h

clean:
	-rm -f *.o *.out *.tmp *.obj sim360 sim360.exe tags

.FORCE:

