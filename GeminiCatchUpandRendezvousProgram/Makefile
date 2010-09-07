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
# original source unchanged.  Therefore, our approach for compiling
# the FORTRAN II/assembly source is to:
#
#	1.	Dynamically transform the FORTRAN II source files
#		at build time to a form compilable with FORTRAN 66/77/90/etc.
#		The temporary files are named *.for, whereas the originals
#		(unchanged by the process) are named *.f.
#	2.	To replace all of the functions in the IBM 7090/7094 with
#		FORTRAN work-alikes in a new source file (ASM.f).  The original
#		assembly source files (*.s) are simply ignored.
#	3.	Provide function/subprogram workarounds for the SENSE LIGHT
#		and SENSE SWITCH features (SENSE.f).
#	4.	Provide replacements for the now-missing FORTRAN II
#		intrinsic functions (INTRINSIC.f).

# Uncomment as appropriate.
DEBUG=-g -O0
#DEBUG=-O2

# If you use g77, then the CLOCKF function I've supplied in INTRINSIC.f
# doesn't work ... for me, anyhow.
COMPILER=gfortran -ffixed-form -fno-automatic ${DEBUG}
#COMPILER=g77 -ff66 -Wall -fno-automatic ${DEBUG}

default: MAIN7 BENCH7

.PHONY: clean
clean:
	-rm MAIN7 BENCH7 *.for *.o

MAIN7:	MAIN7.for \
	STATE.for \
	QUANT.for \
	INSERT.for \
	INTRINSIC.f \
	ASM.o \
	SENSE.o \
	TCTRL.o \
	MEDP3.o
	${COMPILER} -o $@ $^

BENCH7:	BENCH7.for \
	QUANT.for \
	GEXECB.for \
	GONOGO.for \
	AGE.for \
	ASCENT.for \
	RNDZ.for \
	GEXEC.for \
	GANG.for \
	ERRANG.for \
	IDS.for \
	ISZS.for \
	REENT.for \
	ALIGNP.for \
	TDPRED.for \
	WAIT5.for \
	INTRINSIC.f \
	ASM.o \
	SENSE.o
	${COMPILER} -o $@ $^

# Compiles any C-language functions I needed to port assembly code.
%.o:	%.c
	gcc ${DEBUG} -Wall -c -o $@ $^

# Creates temporary files from *.f named *.for to hold the dynamically
# transformed FORTRAN code.  The transformations performed are as follows:
#	END(etc) -> END
#	READ INPUT TAPE KT%d,%d,etc -> READ (KT%d,%d) etc
#	WRITE OUTPUT TAPE KT%d,%d,etc -> WRITE (KT%d,%d) etc
#	READ INPUT TAPE KT%d,%d -> READ (KT%d,%d)
#	WRITE OUTPUT TAPE KT%d,%d -> WRITE (KT%d,%d)
#	READ TAPE KT%d,etc -> READ (KT%d) etc
#	WRITE TAPE KT%d,etc -> WRITE (KT%d) etc
#	IF(SENSE LIGHT %d)%d,%d -> IF(GTSNLT(%d))%d,%d,%d
#	IF(SENSE SWITCH %d)%d,%d -> IF(GTSNSW(%d))%d,%d,%d
#	SENSE LIGHT %d -> CALL STSNLT(%d)
#	PAUSE etc -> WRITE (*,*) etc \n READ (*,'()')
# I guess this approach could be continued to get a complete dynamic
# translation of FORTRAN II, though I see little need to do so for my
# own purposes.
%.for: %.f
	@sed \
	  -e 's/END[[:space:]]*[(].*[)]/END/' \
	  -e 's/READ[[:space:]]*INPUT[[:space:]]*TAPE[[:space:]]*\(KT[[:digit:]]\),\([[:digit:]]*\),/READ (\1,\2) /' \
	  -e 's/WRITE[[:space:]]*OUTPUT[[:space:]]*TAPE[[:space:]]*\(KT[[:digit:]]\),\([[:digit:]]*\),/WRITE (\1,\2) /' \
	  -e 's/READ[[:space:]]*INPUT[[:space:]]*TAPE[[:space:]]*\(KT[[:digit:]]\),\([[:digit:]]*\)[[:space:]]*/READ (\1,\2)/' \
	  -e 's/WRITE[[:space:]]*OUTPUT[[:space:]]*TAPE[[:space:]]*\(KT[[:digit:]]\),\([[:digit:]]*\)[[:space:]]*/WRITE (\1,\2)/' \
	  -e 's/READ[[:space:]]*TAPE[[:space:]]*\(KT[[:digit:]]\),/READ (\1) /' \
	  -e 's/WRITE[[:space:]]*TAPE[[:space:]]*\(KT[[:digit:]]\),/WRITE (\1) /' \
	  -e 's/IF[[:space:]]*(SENSE[[:space:]]*LIGHT[[:space:]]*\([[:digit:]]*\)[[:space:]]*)[[:space:]]*\([[:digit:]]*\)[[:space:]]*,[[:space:]]*\([[:digit:]]*\)/IF (GTSNLT(\1)) \3,\2,\3/' \
	  -e 's/SENSE[[:space:]]*LIGHT[[:space:]]*\([[:digit:]]*\)/CALL STSNLT(\1)/' \
	  -e 's/IF[[:space:]]*(SENSE[[:space:]]*SWITCH[[:space:]]*\([[:digit:]]*\)[[:space:]]*)[[:space:]]*\([[:digit:]]*\)[[:space:]]*,[[:space:]]*\([[:digit:]]*\)/IF (GTSNSW(\1)) \3,\2,\3/' \
	  -e "s/PAUSE\(.*\)/WRITE (*,*) \1\n      READ (\*,'()')/" \
	  $^ >$@
