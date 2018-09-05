### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	RADAR_LEADIN_ROUTINES.agc
## Purpose:	A section of Luminary 1C, revision 131.
##		It is part of the source code for the Lunar Module's (LM)
##		Apollo Guidance Computer (AGC) for Apollo 13.
##		This file is intended to be a faithful transcription, except
##		that the code format has been changed to conform to the
##		requirements of the yaYUL assembler rather than the 
##		original YUL assembler.
## Reference:	pp. 494-495
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	05/14/03 RSB.	Began transcribing.
##		05/14/05 RSB	Corrected website reference above.
##		2017-01-06 RSB	Page numbers now agree with those on the
##				original harcopy, as opposed to the PDF page
##				numbers in 1701.pdf.
##		2017-02-24 RSB	Proofed comment text using octopus/ProoferComments.
##		2017-03-01 RSB	Fixed a comment-text error found in diff'ing vs Luminary 116.

## Page 494
		BANK	25
		SETLOC	RRLEADIN
		BANK
		
		EBANK=	RSTACK
		
# RADAR SAMPLING LOOP.
		COUNT*	$$/RLEAD
RADSAMP		CCS	RSAMPDT		# TIMES NORMAL ONCE-PER-SECOND SAMPLING.
		TCF	+2
		TCF	TASKOVER	# +0 INSERTED MANUALLY TERMINATES TEST.
		
		TC	WAITLIST
		EBANK=	RSTACK
		2CADR	RADSAMP
		
		CAF	PRIO25
		TC	NOVAC
		EBANK=	RSTACK
		2CADR	DORSAMP
		
		CAF	BIT14		# FOR CYCLIC SAMPLING, RTSTDEX=
		EXTEND			# RTSTLOC/2 + RTSTBASE
		MP	RTSTLOC
		AD	RTSTBASE	# 0 FOR RR, 2 FOR LR.
		TS	RTSTDEX
		TCF	TASKOVER
		
# DO THE ACTUAL RADAR SAMPLE.

DORSAMP		TC	VARADAR		# SELECTS VARIABLE RADAR CHANNEL.
		TC	BANKCALL
		CADR	RADSTALL
		
		INCR	RFAILCNT	# ADVANCE FAIL COUNTER BUT ACCEPT BAD DATA
		
DORSAMP2	INHINT
		CA	FLAGWRD5	# DON'T UPDATE RSTACK IF IN R77.
		MASK	R77FLBIT
		CCS	A
		TCF	R77IN
		
		DXCH	SAMPLSUM
		INDEX	RTSTLOC
		DXCH	RSTACK
		
		CA	RADMODES
		EXTEND
		RXOR	CHAN33
## Page 495
		MASK	BIT6
		EXTEND
		BZF	R77IN
		
		TC	ALARM
		OCT	522
		INCR	RFAILCNT
		
R77IN		CS	RTSTLOC		# CYCLE RTSTLOC
		AD	RTSTMAX
		EXTEND
		BZF	+3
		CA	RTSTLOC
		AD	TWO		# STORAGE IS DP
		TS	RTSTLOC
		TCF	ENDOFJOB	# CONTINUOUS SAMPLING AND 2N TRIES - GONE.
		
# VARIABLE RADAR DATA CALLER FOR ONE MEASUREMENT ONLY.

VARADAR		CAF	ONE		# WILL BE SENT TO RADAR ROUTINE IN A BY
		TS	BUF2		# SWCALL.
		INDEX	RTSTDEX
		CAF	RDRLOCS
		TCF	SWCALL		# NOT TOUCHING Q.
		
RDRLOCS		CADR	RRRANGE		# = 0
		CADR	RRRDOT		# = 1
		CADR	LRVELX		# = 2
		CADR	LRVELY		# = 3
		CADR	LRVELZ		# = 4
		CADR	LRALT		# = 5
		

