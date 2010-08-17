# Copyright:	None, public domain
# Filename:	Makefile
# Purpose:	For building the Gemini 7/6 Catch-Up and Rendezvous simulation
#		program.
# History:	2010-08-17 RSB	Began.
#
# The source code is a mixed FORTRAN II and IBM 7090/7094 assembly-language
# program.  There is no modern compiler which can compile or run such a 
# thing, not least because no modern computer runs IBM 7090/7094 machine
# code or the underlying operating system.  There is a simulator for the
# IBM 7090/7094 which could be used for this purpose, so I'd like to keep
# the source code unchanged, but still somehow compile it for running 
# natively on more-standard computer systems, so I'd like to keep the 
# original source unchanged.  Therefore, our approach is to:
#
#	1.	Try to dynamically transform the FORTRAN II source files
#		at build time to a form compilable with FORTRAN 66
#		(or more accurately, with the FORTRAN 66 setting in the
#		GNU FORTRAN compiler).  The temporary files are named
#		*.for, whereas the originals are *.f.
#	2.	To replace all of the functions in the IBM 7090/7094 with
#		FORTRAN work-alikes in a new source file (IBMasm.f).

default: MAIN7 BENCH7

.PHONY: clean
clean:
	-rm MAIN7 BENCH7 *.for

MAIN7:	MAIN7.for
	g77 -ff66 -Wall -o $@ $^

BENCH7:	BENCH7.for
	g77 -ff66 -Wall -o $@ $^

# Creates temporary files from *.f named *.for to hold the dynamically
# transformed FORTRAN code.  The transformations performed are as follows:
#	END(etc) -> END
#	READ INPUT TAPE KT%d,%d,etc -> READ (%d,%d) etc
#	WRITE OUTPUT TAPE KT%d,%d,etc -> WRITE (%d,%d) etc
#	READ INPUT TAPE KT%d,%d -> READ (%d,%d)
#	WRITE OUTPUT TAPE KT%d,%d -> WRITE (%d,%d)
%.for: %.f
	sed \
	  -e 's/END[[:space:]]*[(].*[)]/END/' \
	  -e 's/READ[[:space:]]*INPUT[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),\([[:digit:]]*\),/READ (\1,\2) /' \
	  -e 's/WRITE[[:space:]]*OUTPUT[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),\([[:digit:]]*\),/WRITE (\1,\2) /' \
	  -e 's/READ[[:space:]]*INPUT[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),\([[:digit:]]*\)[[:space:]]*/READ (\1,\2)/' \
	  -e 's/WRITE[[:space:]]*OUTPUT[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),\([[:digit:]]*\)[[:space:]]*/WRITE (\1,\2)/' \
	  $^ >$@
