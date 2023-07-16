### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	FRESH_START_AND_RESTART.agc
## Purpose:	A section of Sunrise 45.
##		It is part of the reconstructed source code for the penultimate
##		release of the Block I Command Module system test software. No
##		original listings of this program are available; instead, this
##		file was created via disassembly of dumps of Sunrise core rope
##		memory modules and comparison with the later Block I program
##		Solarium 55.
## Assembler:	yaYUL --block1
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2022-12-09 MAS	Initial reconstructed source.

## Names in this section are largely taken from AGC Information Series Issue 16,
## Progress Control and Fresh Start and Restart.

		BANK	4
#	FRESH START - A KEYBOARD REQUEST TO INITIALIZE THE SYSTEM.

SLAP1		INHINT			# COMES HERE FROM THE PINBALL VERB FAN.
		CAF	ZERO		#  (ZERO FAILREG IN FRESH START ONLY).
		TS	FAILREG
		
		TC	STARTSUB	# SUBROUTINE DOES MOST OF THE WORK.

NOGO		CS	ZERO
		TS	PHASETAB
		TS	PHASETAB +1
		TS	PHASETAB +2
		TS	PHASETAB +3
		TS	BACKPHAS
		TS	BACKPHAS +1
		TS	BACKPHAS +2
		TS	BACKPHAS +3
		CAF	ZERO
		TS	PHASEBAR
		TS	PHASEBAR +1
		TS	PHASEBAR +2
		TS	PHASEBAR +3

		TS	SMODE
		
		CAF	BIT15		# TELL T4RUPT TO TURN OFF ALL C RELAYS.
		TS	DSPTAB +11D
		TS	DSPTAB +12D
		TS	DSPTAB +13D

		TC	ENDFRESH

MAXPROG		EQUALS	ONE
		
# 	WHENEVER A GO SEQUENCE (GOJAM) IS FIRED,  GOPROG  IS CALLED TO RESTART ANY COMPUTER ACTIVITY THAT
# MAY HAVE BEEN GOING ON AT THE TIME. (A NUMBER OF ALARMS SUCH AS PARITY FAILURE OR POWER FAILURE CAUSE GOJAM).
# THE FUNCTION OF GOPROG IS TO INITIALIZE THE COMPUTER SUB-SYSTEM (I.E., NO C RELAYS ARE CHANGED, ETC.) AND
# RESTART ALL MAJOR ROUTINES WHOSE PHASE BITS INDICATE ACTIVITY.

GOPROG		TC	STARTSUB
		
		CAF	THREE  		# PHASE BITS ARE KEPT IN THREE COPIES,
PHASECHK	TS	MPAC		# TWO DIRECT AND ONE COMPLEMENTED. THIS
		INDEX	A		# SECTION MAKES SURE ALL ENTRIES IN EACH
		CS	PHASETAB	# SATISFIES THIS RULE AS AN INDICATION OF
		TS	BUF		# THE GOODNESS OF ERASABLE MEMORY. IF THE
		INDEX	MPAC		# TEST FAILS, DO A FRESH START WITH THE
		CS	BACKPHAS	# MODE LIGHTS SET TO 00 TO TELL THE STORY.
		TS	BUF +1
		COM
		MASK	BUF
		TC	ZEROTEST	# P.(-P) AND (-P).(--P) SHOULD BOTH BE
		INDEX	MPAC		# +0 FOR A LOGICAL MATCH.
		AD	PHASEBAR
		TS	BUF +2
		COM
		MASK	BUF +1
		TC	ZEROTEST
		CS	BUF +2
		MASK	BUF
		TC	ZEROTEST
		CS	BUF
		MASK	BUF +1
		TC	ZEROTEST
		CS	BUF
		MASK	BUF +2
		TC	ZEROTEST
		CS	BUF +1
		MASK	BUF +2
		TC	ZEROTEST
		
ENDVOTE		CCS	MPAC
		TC	PHASECHK
		
GOJUMP		CAF	MAXPROG
		TS	MPAC +1
		
		RELINT			# OPEN THE INTERRUPT GATE SO THAT EACH
		INHINT			# GO DISPATCH HAS 10 MS.
		
		TS	PHASDATA
		TC	REPHASE2
		TC	ONSKIP
		TC	GORETURN
		TC	DEMANDON

		XCH	PHASE
		TS	MPAC
		INDEX	PROG
		CAF	GOCADR
		TC	SWCALL

GORETURN	CCS	MPAC +1
		TC	GOJUMP +1
		
		CAF	ALARMPR		# FIRE UP JOB TO DISPLAY FAILREG
		TC	NOVAC
		CADR	DOALARM
		
ENDFRESH	RELINT
		TC	BANKCALL	# DISPLAY MAJOR MODES.
		CADR	DSPMM
		
		TC	POSTJUMP
		CADR	DUMMYJOB	# THIS REVERTS TO THE IDLING JOB.

DEMANDON	CS	PROG
		INDEX	A
		CAF	BIT1
		AD	MODREG
		TS	MODREG
		TC	Q
		
ZEROTEST	CCS	A
		TC	NOGO		# RESTART FROM GO IMPOSSIBLE.
		TC	Q		# OK SO FAR
		TC	NOGO
		TC	NOGO

#	INITIALIZATION SUBROUTINE, CONTAINING INITIALIZATION COMMON TO BOTH FRESH START (KEYBOARD REQUEST) AND
# RESTART (IN RESPONSE TO A GO SEQUENCE).

STARTSUB	XCH	Q
		TS	BUF		# EXEC TEMPS ARE AVAILABLE TO US.
		
		CAF	POSMAX		# T3 AND T4 OVERFLOW AS SOON AS POSSIBLE.
		TS	TIME3		#   (POSMAX IS PSEUDO INTERRUPT SIGNAL IN
		TS	TIME4		#   CASE RUPT SIGNALLED BEFORE TS TIME3),
		
		CAF	NEG1/2		# INITIALIZE WAITLIST DELTA-TS.
		TS	LST1 +4
		TS	LST1 +3
		TS	LST1 +2
		TS	LST1 +1
		TS	LST1

		CS	ENDTASK		# SET ALL TASKS TO DUMMY TASK.
		TS	LST2 +5
		TS	LST2 +4
		TS	LST2 +3
		TS	LST2 +2
		TS	LST2 +1
		TS	LST2

		CS	ZERO		# MAKE ALL EXECUTIVE REGISTER SETS
		TS	PRIORITY +8D	# AVAILABLE (EXCEPT THIS ONE).
		TS	PRIORITY +16D
		TS	PRIORITY +24D
		TS	PRIORITY +32D
		TS	PRIORITY +40D
		TS	PRIORITY +48D
		TS	PRIORITY +56D

		TS	DSRUPTSW	# -0 GIVES US 40 MS TO GET READY FOR T4.
		TS	CDUIND		# MAKE IMU AND OPTICS AVAILABLE.
		TS	OPTIND


		CAF	VAC1ADRC	# MAKE ALL VAC AREAS AVAILABLE.
		TS	VAC1USE
		AD	LTHVACA
		TS	VAC2USE
		AD	LTHVACA
		TS	VAC3USE
		AD	LTHVACA
		TS	VAC4USE
		AD	LTHVACA
		TS	VAC5USE

		CAF	BIT10		# THIS REGISTER SET BECOMES DUMMY JOB.
		TS	PRIORITY

		CAF	BIT7
		TS	OUT1
		
		CAF	TEN		# TURN OFF ALL DISPLAY SYSTEM RELAYS.
DSPOFF		TS	MPAC
		CS	BIT12
		INDEX	MPAC
		TS	DSPTAB
		CCS	MPAC
		TC	DSPOFF

		TS	DSPCNT		# SKIPS TO HERE WHEN FINISHED WITH C(A)=0.
		TS	NEWJOB
		TS	MODREG
		TS	CADRSTOR
		TS	REQRET
		TS	CLPASS
		TS	DSPLOCK
		TS	MONSAVE		# KILL MONITOR
		TS	MONSAVE1
		TS	GRABLOCK
		TS	VERBREG
		TS	NOUNREG
		TS	DSPLIST
		TS	DSPLIST +1
		TS	DSPLIST +2
		TS	STATE
		TS	STATE +1
		TS	STATE +2
		TS	PWTCADR
		TS	PWTCADR +1
		TS	DESKSET		# NO COMPUTER COMMAND.
		TS	DESOPSET	# (SAME AS IMU).
		TS	IMUCADR		# INITIALIZE MODE-SWITCHING.
		TS	OPTCADR
		TS	OLDERR
		TS	DISPBUF
		TS	IDPLACER
		TS	TMINDEX
		TS	TMKEYBUF
		TS	MARKSTAT	# MAKE MARK SYSTEM AVAILABLE.
		TS	IN0WORD
		TS	OUT1

		CAF	LOW5
		TS	PWTPROG
		TS	PWTPROG +1

		XCH	IN3
		XCH	IN3
		TS	WASKSET
		MASK	LOW7
		XCH	WASKSET
		MASK	OPTMODES
		TS	WASOPSET

		TC	READIN0
		CCS	A
		TC	NOACPT
		TC	NOACPT
		TC	+1
		CS	BIT12
		MASK	WASOPSET
		TS	WASOPSET
		
NOACPT		CAF	SIX		# (MAY NOT GET ANY ENDPULSES BEFORE T4).
		TS	TELCOUNT

		CAF	NOMADR
		TS	DNLSTADR
		
		CAF	NOUTCON
		TS	NOUT
		
		CS	VD1
		TS	DSPCOUNT
		TC	BUF		# DONE.


OPTMODES	OCT	35000
NOMADR		ADRES	DNLST1
NOUTCON		DEC	11

GOCADR		CADR	PRELGO
		CADR	FFGO
		CADR
		CADR

VAC1ADRC	ADRES	VAC1USE
LTHVACA		DEC	44