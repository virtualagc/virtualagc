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

# I have only tried compiling with GNU FORTRAN, so I have no idea what may
# happen with other compilers such as Intel's.  The original GNU FORTRAN
# compiler was "g77", which was replaced in gcc 4.x by "gfortran".  While
# gfortran may be needed for compiling FORTRAN 90, FORTRAN 95, or later,
# it is no substitute at all when compiling FORTRAN 66 code.  In other words,
# it won't work.  It is consequently necessary to install g77, which may no 
# longer be easily available in binary form.  Therefore, it may be necessary
# to compile it yourself.  I would recommend using gcc-3.4.6.
#COMPILER=gfortran -ffixed-form
COMPILER=g77 -ff66

default: MAIN7 BENCH7

.PHONY: clean
clean:
	-rm MAIN7 BENCH7 *.for

MAIN7:	MAIN7.for \
	STATE.for \
	QUANT.for \
	INSERT.for \
	HDA7.for \
	SELFLD.for \
	LDB6.for \
	HDA9.for \
	KEYCN.for \
	KEYS.for \
	MAR.for \
	PRT.for \
	DEV.for \
	STSNLT.for
	${COMPILER} -Wall -o $@ $^

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
	ENB.for \
	DSB.for \
	SKPN.for \
	HDA7.for \
	SELFLD.for \
	MAR.for \
	PRT.for \
	DEV.for \
	GTSNSW.for \
	STSNLT.for \
	ABSF.for
	${COMPILER} -Wall -o $@ $^

# Creates temporary files from *.f named *.for to hold the dynamically
# transformed FORTRAN code.  The transformations performed are as follows:
#	END(etc) -> END
#	READ INPUT TAPE KT%d,%d,etc -> READ (%d,%d) etc
#	WRITE OUTPUT TAPE KT%d,%d,etc -> WRITE (%d,%d) etc
#	READ INPUT TAPE KT%d,%d -> READ (%d,%d)
#	WRITE OUTPUT TAPE KT%d,%d -> WRITE (%d,%d)
#	READ TAPE KT%d,etc -> READ (%d) etc
#	WRITE TAPE KT%d,etc -> WRITE (%d) etc
#	IF(SENSE LIGHT %d)%d,%d -> IF(GTSNLT(%d))%d,%d,%d
#	IF(SENSE SWITCH %d)%d,%d -> IF(GTSNSW(%d))%d,%d,%d
#	SENSE LIGHT %d -> CALL STSNLT(%d)
%.for: %.f
	@sed \
	  -e 's/END[[:space:]]*[(].*[)]/END/' \
	  -e 's/READ[[:space:]]*INPUT[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),\([[:digit:]]*\),/READ (\1,\2) /' \
	  -e 's/WRITE[[:space:]]*OUTPUT[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),\([[:digit:]]*\),/WRITE (\1,\2) /' \
	  -e 's/READ[[:space:]]*INPUT[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),\([[:digit:]]*\)[[:space:]]*/READ (\1,\2)/' \
	  -e 's/WRITE[[:space:]]*OUTPUT[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),\([[:digit:]]*\)[[:space:]]*/WRITE (\1,\2)/' \
	  -e 's/READ[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),/READ (\1) /' \
	  -e 's/WRITE[[:space:]]*TAPE[[:space:]]*KT\([[:digit:]]\),/WRITE (\1) /' \
	  -e 's/IF[[:space:]]*(SENSE[[:space:]]*LIGHT[[:space:]]*\([[:digit:]]*\)[[:space:]]*)[[:space:]]*\([[:digit:]]*\)[[:space:]]*,[[:space:]]*\([[:digit:]]*\)/IF (GTSNLT(\1)) \3,\2,\3/' \
	  -e 's/SENSE[[:space:]]*LIGHT[[:space:]]*\([[:digit:]]*\)/CALL STSNLT(\1)/' \
	  -e 's/IF[[:space:]]*(SENSE[[:space:]]*SWITCH[[:space:]]*\([[:digit:]]*\)[[:space:]]*)[[:space:]]*\([[:digit:]]*\)[[:space:]]*,[[:space:]]*\([[:digit:]]*\)/IF (GTSNSW(\1)) \3,\2,\3/' \
	  $^ >$@
