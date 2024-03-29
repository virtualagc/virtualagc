### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	DOCKED_DAP_JET_SELECTION.agc
## Purpose:	A section of Skylark revision 048.
##		It is part of the source code for the Apollo Guidance Computer (AGC)
##		for Skylab-2, Skylab-3, Skylab-4, and ASTP. No original listings of
##		this software are available; instead, this file was created via
##		disassembly of dumps of the core rope modules actually flown on
##		Skylab-2. Access to these modules was provided by the New Mexico
##		Museum of Space History.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2024-02-18 MAS  Created.
##		2024-03-04 MAS  Finished filling out.

## This log section is entirely new in Skylark. Comments have been adapted
## from Artemis 72 or Luminary 210, where appropriate. Likewise, names
## have been obtained from the Programmed Guidance Equations for Skylark 48,
## copied from Luminary 210, or given modern names (which have been marked).

		SETLOC	DKDAPS
		BANK
		EBANK=	DAPDATR3

		COUNT*	$$/DKDAP

DKJSLECT	LXCH	BANKRUPT	# INTERRUPT LEAD IN (CONTINUED)
		
		CA	60MS
		TS	TIME5

		EXTEND
		QXCH	QRUPT

		CCS	DAPZRUPT	# IF DAPZRUPT POSITIVE, DAP (JASK) IS
		TC	BAILOUT		# STILL IN PROGRESS AND A RESTART IS
		OCT	32000		# CALLED FOR.  IT IS NEVER ZERO

		DXCH	ARUPT
		DXCH	DAPARUPT
		CA	SUPERJOB	# SETTING UP THE SUPERJOB
		XCH	BRUPT
		LXCH	QRUPT
		DXCH	DAPBQRPT
		CA	SUPERADR
		DXCH	ZRUPT
		DXCH	DAPZRUPT
		TCF	NOQBRSM +1	# RELINT (JUST IN CASE) AND RESUME, IN THE
					# 	FORM OF A JASK, AT SUPERJOB.

SUPERADR	GENADR	SUPERJOB +1

SUPERJOB	CAF	BIT14
		TC	C31BTCHK
		TCF	YZFREE

INHIBCHK	CCS	INHIBIT
		TCF	BURBLE
		TCF	NOBYPASS
		TCF	NOBYPASS
		TCF	NOBYPASS

YZCHECK		INDEX	SPNDX
		CA	TAUZ
		EXTEND
		BZF	SPNDXCK
		TCF	FORCE

YZFREE		CCS	INHIBIT
		TCF	BURBLE
		TCF	+3
		TCF	NOBYPASS
		TCF	NOBYPASS

		EXTEND
		READ	CHAN31
		COM
		TS	T5TEMP

		EXTEND
		MP	BIT7
		MASK	THREE
		INDEX	A
		CAF	200MST6 -1
		TS	TAUY

		CA	T5TEMP
		EXTEND
		MP	BIT5
		MASK	THREE
		INDEX	A
		CAF	200MST6 -1
		TS	TAUZ

NOBYPASS	XCH	7
		TS	TRCOMPAC
		TS	TRCOMPBD
		TS	5PT
		TS	5YWT
		TS	61PT
		TS	61YWT
		TS	62PT
		TS	62YWT
		TS	DELFLG

P/YWCOMP	CAF	ONE
		TS	SPNDX
		DOUBLE
		TS	DPNDX

		INDEX	SPNDX
		CA	TAU1
		EXTEND
		BZF	YZCHECK

		CS	DAPDATR3
		INDEX	SPNDX
		MASK	PCK
		EXTEND
		BZF	FORCE

COUPLE		INDEX	SPNDX
		CCS	TAU1
		XCH	7
		TC	+2
		CAF	ONE
		AD	DPNDX
		INDEX	A
		CAF	+PITCHTC
		INDEX	SPNDX
		TS	5PW

		MASK	CH5FAIL
		EXTEND
		BZF	GOODA

		CS	DAPDATR3
		INDEX	SPNDX
		MASK	PCK
		EXTEND
		BZF	P/YWALRM

FORCE		INDEX	SPNDX
		CCS	TAUZ
		XCH	7
		TC	+2
		CAF	ONE
		AD	DPNDX
		INDEX	A
		CAF	+ZFORCE
		INDEX	SPNDX
		TS	62PW

		MASK	CH6FAIL
		EXTEND
		BZF	GOODB

		CS	CH6FAIL
		INDEX	SPNDX
		MASK	62PW
		EXTEND
		BZF	BADC

		INDEX	SPNDX
		TS	61PW

		INDEX	DPNDX
		MASK	+ROLLBD
		EXTEND
		BZF	NEGRDIST

		INDEX	SPNDX
		CCS	TAUZ
		TC	DELFLGUP
		TCF	+2
		AD	ONE
		INDEX	SPNDX
		TS	61PT
		COM
		TCF	TRCOMP

NEGRDIST	INDEX	SPNDX
		CAF	BIT6
		ADS	DELFLG

		INDEX	SPNDX
		CCS	TAUZ
		AD	ONE
		TCF	+2
		TC	DELFLGUP

		INDEX	SPNDX
		TS	61PT

TRCOMP		TS	T5TEMP
		EXTEND
		INDEX	SPNDX
		MP	ALPHAP
		TS	T5TEMP2

		CA	DELFLG
		INDEX	SPNDX
		MASK	BIT8
		EXTEND
		BZF	+3
		CS	T5TEMP2
		TCF	+2
		CA	T5TEMP2
		AD	T5TEMP
		INDEX	SPNDX
		ADS	TRCOMPAC

		INDEX	SPNDX
		CS	TAU1
		EXTEND
		BZMF	+4

		INDEX	SPNDX
		CAF	BIT4
		ADS	DELFLG

		TCF	SPNDXCK

## The name of the following function is a guess.
DELFLGUP	AD	ONE
		XCH	DELFLG
		INDEX	SPNDX
		AD	BIT8
		XCH	DELFLG
		TC	Q

GOODA		INDEX	SPNDX
		CS	TAU1
		EXTEND
		MP	HALF
		CCS	A
		TCF	NEGTAU
		TCF	+2
## The names of the following two labels are guesses.
POSTAU		AD	ONE
		INDEX	SPNDX
		TS	5PT
		TC	SPNDXCK

NEGTAU		XCH	DELFLG
		INDEX	SPNDX
		AD	BIT12
		XCH	DELFLG
		TCF	POSTAU

GOODB		INDEX	SPNDX
		CA	TAUZ
		TS	T5TEMP

		EXTEND
		MP	HALF
		CCS	A
		AD	ONE
		TC	+2
		AD	ONE
		INDEX	SPNDX
		TS	62PT
		
		INDEX	SPNDX
		CS	TAU1
		EXTEND
		BZMF	+6

		INDEX	SPNDX
		CAF	BIT12
		INDEX	SPNDX
		AD	BIT4
		ADS	DELFLG

		INDEX	SPNDX
		CA	TAUZ
		EXTEND
		BZMF	+4

		INDEX	SPNDX
		CAF	BIT10
		ADS	DELFLG

		CS	SPNDX
		XCH	T5TEMP
		EXTEND
		INDEX	SPNDX
		MP	ALPHAP
		INDEX	T5TEMP
		ADS	TRCOMPBD
		TC	SPNDXCK

BADC		INDEX	SPNDX
		TS	62PT
		
		CS	DAPDATR3
		INDEX	SPNDX
		MASK	PCK
		EXTEND
		BZF	COUPLE

P/YWALRM	CA	FLAGWRD3
		MASK	500**BIT
		CCS	A
		TCF	SPNDXCK

		TC	ALARM
		OCT	500

		TC	UPFLAG
		ADRES	500**FLG

SPNDXCK		CCS	SPNDX
		TCF	P/YWCOMP +1

ROLLCOMP	CS	TRCOMPAC
		EXTEND
		BZMF	TCOMPAC-

TCOMPAC+	CA	TRCOMPBD
		EXTEND
		BZMF	RPREFCK

		AD	TRCOMPAC
		EXTEND
		BZMF	RC1

RC3		TS	TRCOMPBD
		XCH	7
		TS	TRCOMPAC
		TCF	RPREFCK

TCOMPAC-	CA	TRCOMPBD
		EXTEND
		BZMF	+2
		TCF	RPREFCK

		AD	TRCOMPAC
		EXTEND
		BZMF	RC3

RC1		TS	TRCOMPAC
		XCH	7
		TS	TRCOMPBD

RPREFCK		CA	DAPDATR3
		MASK	BIT13
		CCS	A
		CAF	ONE
		TS	SPNDX

		CA	TAU
		EXTEND
		BZF	COMBINE

		TC	ROLLMATH
		TC	ROLLMATH

COMBINE		TC	MERGMATH
		TC	MERGMATH

		DOUBLE
		TS	DPNDX

		CS	SPNDX
		INDEX	A
		CA	TRCOMPBD
		AD	TAU
		TC	CPLMATH
		TS	T5TEMP2

		EXTEND
		BZF	PASS2

		XCH	7
		INDEX	SPNDX
		TS	62PT

		CA	TAU
		TS	T5TEMP2

		CS	SPNDX
		INDEX	A
		CA	TRCOMPBD
		EXTEND
		BZF	PASS2

		TC	ROLLALRM

PASS2		CCS	SPNDX
		TC	+2
		CAF	ONE
		TS	SPNDX
		DOUBLE
		TS	DPNDX

		CS	SPNDX
		INDEX	A
		CA	TRCOMPBD
		ADS	T5TEMP2
		TC	CPLMATH

		EXTEND
		BZF	+5

		XCH	7
		INDEX	SPNDX
		TS	62PT
		TC	ROLLALRM

## The names of the next two labels are guesses.
		CAF	FIVE
MINTCHK		TS	SPNDX
		INDEX	SPNDX
		CS	5PT
		EXTEND
		BZF	NEXTTIME

		AD	14MS
		EXTEND
		BZMF	NEXTTIME

		CA	14MS
		INDEX	SPNDX
		TS	5PT

NEXTTIME	CCS	SPNDX
		TCF	MINTCHK

		TCF	BURBLE

ROLLALRM	EXTEND
		QXCH	T5TEMP

		CA	FLAGWRD3
		MASK	501**BIT
		CCS	A
		TC	T5TEMP

		TC	ALARM
		OCT	501

		TC	UPFLAG
		ADRES	501**FLG

		TC	T5TEMP

ROLLMATH	CCS	SPNDX
		TCF	+2
		CAF	ONE
		TS	SPNDX

		INDEX	SPNDX
		CCS	TRCOMPAC
		TCF	PLUSCOMP
		TCF	ROLLOUT
		TCF	MINUSCOMP
		TCF	ROLLOUT

PLUSCOMP	CA	TAU
		EXTEND
		BZMF	+2
		TCF	ROLLOUT

		INDEX	SPNDX
		ADS	TRCOMPAC
		EXTEND
		BZMF	UPDATTAU
		TCF	ZEROTAU

MINUSCOMP	CA	TAU
		EXTEND
		BZMF	ROLLOUT

		INDEX	SPNDX
		ADS	TRCOMPAC
		EXTEND
		BZMF	ZEROTAU

## The names of the next three labels are guesses.
UPDATTAU	TS	TAU
		XCH	7
		INDEX	SPNDX
		TS	TRCOMPAC
		TCF	ROLLOUT

ZEROTAU		XCH	7
		TS	TAU
ROLLOUT		TC	Q


MERGMATH	INDEX	SPNDX
		CA	62PT
		EXTEND
		BZF	TAGB

		CA	SPNDX
		DOUBLE
		TS	DPNDX

		CCS	SPNDX
		CS	ONE
		TS	T5TEMP

		INDEX	T5TEMP
		CCS	TRCOMPBD
		TCF	SIDE+
		TCF	TESTTAU
		TCF	SIDE-

TESTTAU		CS	FOUR
		XCH	T5TEMP
		COM
		MASK	T5TEMP
		EXTEND
		BZF	TAGB

		CCS	TAU
		TCF	SIDE+
		TCF	TAGB
		TCF	SIDE-

## The name of the following label is a guess.
TAGB		CCS	SPNDX
		TCF	+2
		CAF	ONE
		TS	SPNDX
		TC	Q

SIDE+		AD	ONE
		TS	T5TEMP2

		INDEX	SPNDX
		CA	TAUZ
		EXTEND
		BZMF	+5

		CS	DELFLG
		INDEX	SPNDX
		MASK	BIT8
		ADS	DELFLG

		INDEX	DPNDX
		CA	+ROLLBD
		INDEX	SPNDX
		MASK	62PW
		INDEX	SPNDX
		TS	61PW

		INDEX	SPNDX
		CA	62PT
		DOUBLE
		EXTEND
		SU	T5TEMP2
		EXTEND
		BZMF	TAGD -1

TAGC		EXTEND
		MP	HALF
		INDEX	SPNDX
		TS	62PT

		XCH	7
		INDEX	T5TEMP
		TS	TRCOMPBD

		CA	T5TEMP2
		INDEX	SPNDX
		ADS	61PT
		TCF	TESTTAU

		COM
TAGD		INDEX	T5TEMP
		TS	TRCOMPBD

		XCH	7
		INDEX	SPNDX
		XCH	62PT

		DOUBLE
		INDEX	SPNDX
		ADS	61PT

		TCF	TAGB

SIDE-		AD	ONE
		TS	T5TEMP2

		CS	DELFLG
		INDEX	SPNDX
		MASK	BIT6
		ADS	DELFLG

		INDEX	SPNDX
		CS	TAUZ
		EXTEND
		BZMF	+5

		CS	DELFLG
		INDEX	SPNDX
		MASK	BIT8
		ADS	DELFLG

		INDEX	DPNDX
		CA	-ROLLBD
		INDEX	SPNDX
		MASK	62PW
		INDEX	SPNDX
		TS	61PW

		INDEX	SPNDX
		CA	62PT
		DOUBLE
		EXTEND
		SU	T5TEMP2
		EXTEND
		BZMF	TAGD
		TCF	TAGC

CPLMATH		EXTEND
		MP	HALF
		CCS	A
		TCF	CPL+
		TC	Q
		TCF	CPL-
		TC	Q

CPL+		AD	ONE
		INDEX	SPNDX
		TS	62PT

		INDEX	SPNDX
		CS	BIT10
		MASK	DELFLG
		TS	DELFLG

TAGE		INDEX	SPNDX
		CA	BIT14
		ADS	DELFLG

		INDEX	DPNDX
		CA	+ROLLBD
		INDEX	SPNDX
		TS	62PW

		MASK	CH6FAIL
		TC	Q

CPL-		AD	ONE
		INDEX	SPNDX
		TS	62PT
		
		CS	DELFLG
		INDEX	SPNDX
		MASK	BIT10
		ADS	DELFLG

		INCR	DPNDX
		TCF	TAGE

14MS		=	DEC23

+PITCHTC	OCT	00005
		OCT	00012
		OCT	00120
		OCT	00240

+ROLLBD		=	+PITCHTC
-ROLLBD		=	+PITCHTC +1
+ROLLAC		=	+PITCHTC +2
-ROLLAC		=	+PITCHTC +3

+XAC		OCT	00011
		OCT	00006
		OCT	00220
		OCT	00140

+ZFORCE		=	+XAC

PCK		OCT	00010
		OCT	00001

1/160		DEC	0.00625
60MS		OCT	37772
100MST6		DEC	160

## The name of the following label is a guess.
NOXTRANS	TS	5AXW
		TS	5BXW
		TCF	GOCYCLE -1

BURBLE		XCH	7
		TS	DFT
		TS	DFT1
		TS	DFT2

		EXTEND
		READ	CHAN31
		COM
		EXTEND
		MP	BIT9
		MASK	THREE
		EXTEND
		BZF	NOXTRANS
		TS	SPNDX

		CS	FIVE
		TS	ATTKALMN

		CA	DAPDATR3
		MASK	BIT10
		EXTEND
		BZF	+6

		CAF	ZERO
		TS	5PT

		CS	CH5FAIL
		INDEX	SPNDX
		MASK	+XAC -1
		TS	5AXW

		CA	DAPDATR3
		MASK	BIT7
		EXTEND
		BZF	+6

		CAF	ZERO
		TS	5YWT

		CS	CH5FAIL
		INDEX	SPNDX
		MASK	+XAC +1
		TS	5BXW

		CAF	ONE
GOCYCLE		TS	SPNDX
		
		XCH	7
		TS	TLEFT

		CA	100MST6
		TS	TT
		EXTEND
		INDEX	SPNDX
		SU	61PT
		EXTEND
		BZMF	LONG61PT

		TS	TLEFT
		COM
		AD	100MST6
		TS	TT

		EXTEND
		BZF	NO61PT

LONG61PT	CA	TT
		TS	T5TEMP

		INDEX	SPNDX
		CAF	BIT8
		MASK	DELFLG
		EXTEND
		BZF	+3
		CS	T5TEMP
		TCF	+2
		CA	T5TEMP
		EXTEND
		INDEX	SPNDX
		MP	ALPHAP
		ADS	T5TEMP

		INDEX	SPNDX
		CAF	BIT6
		MASK	DELFLG
		EXTEND
		BZF	+3
		CS	T5TEMP
		TCF	+2
		CA	T5TEMP
		ADS	DFT

		INDEX	SPNDX
		CAF	BIT4
		MASK	DELFLG
		EXTEND
		BZF	+3
		CS	TT
		TCF	+2
		CA	TT
		INDEX	SPNDX
		ADS	DFT1

NO61PT		CA	TLEFT
		TS	TT
		EXTEND
		INDEX	SPNDX
		SU	62PT
		EXTEND
		BZMF	LONG62PT

		COM
		AD	TLEFT
		TS	TT

		EXTEND
		BZF	NO62PT

LONG62PT	CA	TT
		DOUBLE
		TS	T5TEMP

		CS	DELFLG
		INDEX	SPNDX
		MASK	BIT14
		EXTEND
		BZF	ROLLCPL

		CA	T5TEMP
		EXTEND
		INDEX	SPNDX
		MP	ALPHAP
		TS	T5TEMP

		CA	TT
		DOUBLE
		TS	T5TEMP2
		TC	LONGDFT

ROLLCPL		INDEX	SPNDX
		CAF	BIT10
		MASK	DELFLG
		EXTEND
		BZF	+3
		CS	T5TEMP
		TCF	+2
		CA	T5TEMP
		ADS	DFT

NO62PT		CAF	100MST6
		TS	TT
		EXTEND
		INDEX	SPNDX
		SU	5PT
		EXTEND
		BZMF	LONG5PT

		COM
		AD	100MST6
		TS	TT

		EXTEND
		BZF	NO5PT

LONG5PT		CA	TT
		EXTEND
		INDEX	SPNDX
		MP	ECP

		CCS	A
		AD	ONE
		TCF	+2
		AD	ONE
		TS	T5TEMP2

		CS	DELFLG
		INDEX	SPNDX
		MASK	BIT2
		EXTEND
		BZF	+2
		CA	T5TEMP2
		ADS	T5TEMP2
		TC	LONGDFT

NO5PT		CCS	SPNDX
		TCF	GOCYCLE

		CCS	INHIBIT
		TCF	JETSON
		TCF	INHIBCMP
		TCF	INHIBCMP

INHIBCMP	CA	61PT
		AD	62PT
		TS	L

		CA	61YWT
		AD	62YWT
		EXTEND
		SU	L
		EXTEND
		BZMF	USEPT
		AD	L

ZONK		EXTEND
		BZF	+4
		EXTEND
		MP	1/160
		AD	ONE
		TS	INHIBIT

		TC	SETUPT6
		TC	TIMING
		TCF	NOTIMING

## The name of the following label is a guess.
USEPT		CA	L
		TCF	ZONK


JETSON		TS	INHIBIT

		CA	5WORD
		MASK	BIT14
		EXTEND
		BZF	NOTIMING

		CS	BIT14
		MASK	5WORD
		XCH	5WORD
		TC	SETUPT6

NOTIMING	CS	ZERO
		TS	T5PHASE

		EXTEND
		DCA	RCS2CDR
		DXCH	T5LOC

		CA	ADRRUPT
		TC	MAKERUPT

ADRRUPT		ADRES	ENDJASK

ENDJASK		DXCH	DAPARUPT
		DXCH	ARUPT
		DXCH	DAPBQRPT
		XCH	BRUPT
		LXCH	Q
		CAF	NEGMAX		# NEGATIVE DAPZRUPT SIGNALS JASK IS OVER.
		DXCH	DAPZRUPT
		DXCH	ZRUPT
		TCF	NOQRSM

		EBANK=	KMPAC
RCS2CDR		2CADR	RCSATT

## The name of the following function is a guess.
LONGDFT		INDEX	SPNDX
		CAF	BIT12
		MASK	DELFLG
		EXTEND
		BZF	+3
		CS	T5TEMP2
		TCF	+2
		CA	T5TEMP2
		INDEX	SPNDX
		ADS	DFT1
		TC	Q

TIMING		INHINT
		EXTEND
		QXCH	T5TEMP

		XCH	7
		TS	5WORD
		TS	6WORD

		CA	TIMEHOLD
		TS	NEXT6INT

		CAF	ONE
T6LOOP		TS	SPNDX
		INDEX	SPNDX
		CS	5PT
		EXTEND
		BZF	NO5TIME
		TC	SETNEXT6

		INDEX	SPNDX
		CA	5PW
		ADS	5WORD
		TCF	TEST61PT

## The name of the following function is a guess.
SETNEXT6	AD	NEXT6INT
		EXTEND
		BZMF	+3
		COM
		ADS	NEXT6INT
		TC	Q

NO5TIME		INDEX	SPNDX
		CA	5AXW
		ADS	5WORD

TEST61PT	INDEX	SPNDX
		CS	61PT
		EXTEND
		BZF	NO61TIME
		TC	SETNEXT6

		INDEX	SPNDX
		CA	61PW
		ADS	6WORD
		TC	COUNTDWN

NO61TIME	INDEX	SPNDX
		CS	62PT
		EXTEND
		BZF	COUNTDWN
		TC	SETNEXT6

		INDEX	SPNDX
		CA	62PW
		ADS	6WORD

COUNTDWN	CCS	SPNDX
		TCF	T6LOOP

		RELINT
		TC	T5TEMP

TIMEUPDT	CAF	ONE
		TS	SPNDX

		INDEX	SPNDX
		CS	5PT
		AD	NEXT6INT
		EXTEND
		BZMF	+2
		TCF	61PTCHK

		COM
		INDEX	SPNDX
		TS	5PT

61PTCHK		INDEX	SPNDX
		CS	61PT
		AD	NEXT6INT
		EXTEND
		BZMF	61PTSET

		INDEX	SPNDX
		CS	62PT
		AD	NEXT6INT
		EXTEND
		BZMF	+2
		TCF	GOROUND

		COM
		INDEX	SPNDX
		TS	62PT
		TCF	GOROUND

## The name of the following label is a guess.
61PTSET		COM
		INDEX	SPNDX
		TS	61PT

GOROUND		CCS	SPNDX
		TCF	TIMEUPDT +1

		CS	NEXT6INT
		ADS	TIMEHOLD
		EXTEND
		BZMF	+2
		TCF	TIMING

		CAF	100MST6
		TS	TIMEHOLD
		TCF	TIMING

DKT6		CA	DAPZRUPT
		EXTEND
		BZMF	+5

		CS	5WORD
		MASK	BIT14
		ADS	5WORD
		TCF	RESUME

		CA	5WORD
		EXTEND
		WRITE	PYJETS

		CA	6WORD
		EXTEND
		WRITE	ROLLJETS

		CA	NEXT6INT
		TS	TIME6

		TC	C13STALL
		CAF	BIT15
		EXTEND
		WOR	CHAN13

		TC	TIMEUPDT
		TCF	RESUME

SETUPT6		CAF	14MS
		INHINT
		TS	TIME6

		EXTEND
		QXCH	RUPTREG1
		TC	C13STALL
		EXTEND
		QXCH	RUPTREG1
		CAF	BIT15
		EXTEND
		WOR	CHAN13

		CA	100MST6
		TS	TIMEHOLD

		RELINT
		TC	Q
	
		SETLOC	FFTAG12
		BANK
		COUNT*	$$/DKDAP

		DEC	0
200MST6		DEC	320
		DEC	-320
		DEC	0
50MST6		DEC	80
		DEC	-80
		DEC	0
