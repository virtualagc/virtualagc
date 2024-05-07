#
#	IBM/360 simulator for both XPL and PASCAL
#
#	Author: Daniel Weaver
#
DIR=ascii
CFLAGS=-Wall

XCOM= -o0ET stdout -i2EL ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp ../ebcdic/FILE15
EDITXPL=-o0 /dev/null -o3 /dev/null editxpl.out

all:	sim360 xpl.out
	cp sim360 ..

sim360: ibm360.o smop.o pascal.o
	$(CC) $(CFLAGS) ibm360.o smop.o pascal.o -lm -o sim360

ibm360.o: ibm360.c
smop.o: smop.c
pascal.o: pascal.c

tags:
	ctags ibm360.c smop.c pascal.c sim.h

# editxpl - file I/O assignments
#  input(0) - Control file
#  input(2) - Source file to be modified
#  output(0) - Listing of control file
#  output(2) - Updated source file
#  output(3) - Listing of updated source file
editxpl.out: sim360
#	./sim360 -i0EL ../ebcdic/FILE19 -f1w+ editxpl.out $(XCOM)
	./sim360 -i0FAT ../port/editxpl.xpl -f1w+ editxpl.out $(XCOM)

xplxref.xpl: sim360 editxpl.out

trim.out: sim360 trim.xpl
	./sim360 -i0FAT trim.xpl -f1w+ trim.out $(XCOM)

ascii:  sim360 trim.out xplxref.xpl .FORCE
	mkdir -p $(DIR)
	./sim360 -i0EL ../ebcdic/FILE01 -o0ET $(DIR)/comments trim.out
	./sim360 -i0EL ../ebcdic/FILE24 -i2EL ../ebcdic/FILE02 -o2ET $(DIR)/omonitor.asm $(EDITXPL)
	./sim360 -i0EL ../ebcdic/FILE25 -i2EL ../ebcdic/FILE03 -o2ET $(DIR)/rmonitor.asm $(EDITXPL)
# FILE04 is jibberish
#	./sim360 -i0EL ../ebcdic/FILE04 -o0ET $(DIR)/user.pascal trim.out
	./sim360 -i0EL ../ebcdic/FILE20 -i2EL ../ebcdic/FILE05 -o2ET xpl.tmp $(EDITXPL)
	./sim360 -i0FAT xpl.tmp -o0ET $(DIR)/pass1.xpl trim.out
	./sim360 -i0EL ../ebcdic/FILE21 -i2EL ../ebcdic/FILE07 -o2ET xpl.tmp $(EDITXPL)
	./sim360 -i0FAT xpl.tmp -o0ET $(DIR)/pass2.xpl trim.out
	./sim360 -i0EL ../ebcdic/FILE22 -i2EL ../ebcdic/FILE09 -o2ET xpl.tmp $(EDITXPL)
	./sim360 -i0FAT xpl.tmp -o0ET $(DIR)/pass3.xpl trim.out
	./sim360 -i0EL ../ebcdic/FILE23 -i2EL ../ebcdic/FILE11 -o2ET xpl.tmp $(EDITXPL)
	./sim360 -i0FAT xpl.tmp -o0ET $(DIR)/pmd.xpl trim.out
	./sim360 -i0EL ../ebcdic/FILE13 -o0ET $(DIR)/benchmarks trim.out
	./sim360 -i0EL ../ebcdic/FILE14 -o0ET $(DIR)/xplsm.asm trim.out
	./sim360 -i0EL ../ebcdic/FILE16 -o0ET $(DIR)/xcom4.xpl trim.out
	./sim360 -i0EL ../ebcdic/FILE17 -o0ET $(DIR)/xplib.xpl trim.out
	./sim360 -i0FAT xplxref.update4 -i2EL ../ebcdic/FILE18 -o0 /dev/null -o2ET xpl.tmp editxpl.out
	./sim360 -i0FAT xpl.tmp -o0ET $(DIR)/xplxref.xpl trim.out
	./sim360 -i0EL ../ebcdic/FILE19 -o0ET $(DIR)/editxpl.xpl trim.out
	rm -f xpl.tmp

test:	sim360 branch diag float pack arith

branch:	branch.xpl sim360
	./sim360 -i0 branch.xpl -f1w+ branch.out -i2ELT ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp ../xpl.out
	./sim360 branch.out

diag:	diag.xpl sim360
	./sim360 -i0 diag.xpl -f1w+ diag.out -i2ELT ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp ../xpl.out
	./sim360 diag.out

float:	float.xpl sim360
	./sim360 -i0 float.xpl -f1w+ float.out -i2ELT ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp ../xpl.out
	./sim360 float.out

pack:	pack.xpl sim360
	./sim360 -i0 pack.xpl -f1w+ pack.out -i2ELT ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp ../xpl.out
	./sim360 pack.out

bugs:	bugs.xpl sim360
	./sim360 -i0 bugs.xpl -f1w+ bugs.out -i2ELT ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp ../xpl.out
	./sim360 bugs.out

arith:	arith.xpl sim360
	./sim360 -i0 arith.xpl -f1w+ arith.out -i2ELT ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp ../xpl.out
	./sim360 -v arith.out

#
#  Convert the EBCDIC XPL compiler to an ASCII XPL compiler
#	This will print garbage on your screen.  Don't Panic.  This is normal.
#
nascii.out: nascii.xpl
	./sim360 -i0FAT nascii.xpl -f1w+ nascii.out $(XCOM)

xpl.out: nascii.out
	./sim360 -i0A ../port/xcom4.xpl -o0E xcom.tmp nascii.out
	./sim360 -i0E xcom.tmp -f1w+ xcom1.out -o0 /dev/null -i2EL ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp ../ebcdic/FILE15
	./sim360 -i0 ../port/xcom4.xpl -f1w+ xcom2.out -i2ELT ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp xcom1.out
	./sim360 -i0 ../port/xcom4.xpl -f1w+ xpl.out -i2ELT ../ebcdic/FILE17 -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp xcom2.out
	cp xpl.out ..

clean:
	rm -f *.o *.out *.tmp *.obj sim360 tags

.FORCE:

