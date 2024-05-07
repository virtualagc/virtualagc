#
#	Makefile for MTS FORMAT converter written in XPL.
#
XPLDIR=../../xpl
CFLAGS= -I$(XPLDIR)
XPL=$(XPLDIR)/xpl
LDLIBS=$(XPLDIR)/libxpl.a
MATFLAGS=-tc

TARGETS=memo11.html memo51.html memo52.html manual.html index.html

LISTTARGET=text.html

%.c:	%.xpl
	$(XPL) $< -o $@

%.html:	%.wf
	./fcon $(MATFLAGS) $< -o $@

%.html:	%.pl
	./flist $< -o $@

all:	$(TARGETS) $(LISTTARGET)

fcon:	fcon.o
fcon.o: fcon.c
fcon.c:	fcon.xpl

flist:	flist.o
flist.o: flist.c
flist.c: flist.xpl

memo11.html: fcon memo11.wf
memo51.html: fcon memo51.wf
memo52.html: fcon memo52.wf
manual.html: fcon manual.wf
index.html: fcon index.wf

xref:
	xxref -PZ fcon.xpl

#    EBCDIC is more of a suggestion than a standard.  The square brackets
# have been moved around a few times and it's difficult for a program to
# figure out how to correctly translate the characters to ASCII.  You can 
# use the -x option of the FLIST program to correct the problem on a file
# by file basis.  Example:
#      flist "-x5D=]" text.pl -o text.html

text.html: flist text.pl

clean:
	rm -f *.o *.xh *.c *.tmp tags fcon flist $(LISTTARGET)

.FORCE:

