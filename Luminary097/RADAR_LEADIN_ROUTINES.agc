### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RADAR_LEADIN_ROUTINES.agc
## Purpose:     A section of Luminary revision 97.
##              It is part of the reconstructed source code for the
##              second release of the flight software for the Lunar 
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 11.
##              It was created to fix two incorrect ephemeris constants in
##              Luminary 96, as described by anomaly report LNY-59.
##              The code has been recreated from a copy of Luminary 99
##              revision 001, using asterisks indicating changed lines in
##              the listing and Luminary Memos #83 and #85, which list 
##              changes between Luminary 97 and 98, and 98 and 99. The
##              code has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 97 in NASA drawing
##              2021152D, which gives relatively high confidence that the
##              reconstruction is correct.
## Reference:   pp. 490-491
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-28 MAS  Created from Luminary 99.

## Page 490
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
		TCF	+4
		
		DXCH	SAMPLSUM
		INDEX	RTSTLOC
		DXCH	RSTACK
		
		CS	RTSTLOC		# CYCLE RTSTLOC.
		AD	RTSTMAX
		EXTEND
		
## Page 491		
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
		

