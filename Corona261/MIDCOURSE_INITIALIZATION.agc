### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	MIDCOURSE_INITIALIZATION.agc
## Purpose:	A section of Corona revision 261.
##		It is part of the source code for the Apollo Guidance Computer
##		(AGC) for AS-202. No original listings of this software are
##		available; instead, this file was created via disassembly of
##		the core rope modules actually flown on the mission.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2023-06-19 MAS  Created.

## MAS 2023: This log section is a part of the MIDCOURSE NAVIGATION GAME, which
## appears to be a very early implementation of P22, P29, and possibly some other
## navigation programs. It was deleted in Solarium, and its documentation that
## mentions it is nearly nonexistent outside of some MIT status reports (from
## which the name of this log section is taken). Reverse-engineering it is a work
## in progress; all labels and comments are modern guesses. Double-# comments
## are annotations to aid in reverse engineering. Any labels that have not yet
## been given modern names are given placeholders with the pattern UBB,SSSS,
## where BB,SSSS is the full bank and address of the label.

		BANK	13

MIDINIT		TC	GRABDSP
		TC	PREGBSY

## Zero everything between DELTAV and DELVEL +5
		CS	LDELTAV
		AD	LDELVEL5

ZEROLOP		TS	WORDIDX
		CAF	ZERO
		INDEX	WORDIDX
		TS	DELTAV
		CCS	WORDIDX
		TC	ZEROLOP

## Set SXT-ON flag in WASOPSET
		CAF	BIT13
		TS	WASOPSET

## Clear MIDFLAG and MOONFLAG
		CS	MINITMSK
		MASK	STATE
		TS	STATE

## Ask user to load DELR
		CAF	VN2572
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	BACK2MID
		TC	+1

## Ask user to load DELVEL
		CAF	VN2573
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	BACK2MID
		TC	+1

## Initialize REFSMMAT to hardcoded initial values
		CAF	DEC17
RFSMLOOP	TS	WORDIDX
		INDEX	WORDIDX
		CAF	INITRFSM
		INDEX	WORDIDX
		TS	REFSMMAT
		CCS	WORDIDX
		TC	RFSMLOOP

## Initialize TE and TET with hardcoded initial value
		CAF	INITTET
		TS	TE
		TS	TET
		CAF	INITTET +1
		TS	TE +1
		TS	TET +1

## Initialize scales with initial values
		CAF	DEC18
		TS	SCALEDT
		CAF	FOUR
		TS	SCALDELT
		CAF	DEC14
		TS	SCALER

## Initialize W to hardcoded initial values
		CAF	DEC71
WLOOP		TS	WORDIDX
		INDEX	WORDIDX
		CAF	INITW
		INDEX	WORDIDX
		TS	W
		CCS	WORDIDX
		TC	WLOOP

## Back to MNG when done. TERMINATE on the load VERBs sends you straight back.
BACK2MID	TC	BANKCALL
		CADR	MIDINRET

LDELTAV		ADRES	DELTAV
LDELVEL5	ADRES	DELVEL +5
DEC17		DEC	17
DEC14		DEC	14
DEC18		DEC	18
DEC71		DEC	71
MINITMSK	OCT	30000
VN2572		OCT	02572
VN2573		OCT	02573
INITTET		2DEC	.077494159

INITW		2DEC	.125
		2DEC	0
		2DEC	0

		2DEC	0
		2DEC	.125
		2DEC	0

		2DEC	0
		2DEC	0
		2DEC	.125

		2DEC	0
		2DEC	0
		2DEC	0

		2DEC	0
		2DEC	0
		2DEC	0

		2DEC	0
		2DEC	0
		2DEC	0

		2DEC	0
		2DEC	0
		2DEC	0

		2DEC	0
		2DEC	0
		2DEC	0

		2DEC	0
		2DEC	0
		2DEC	0

		2DEC	.051901456
		2DEC	0
		2DEC	0

		2DEC	0
		2DEC	.051901456
		2DEC	0

		2DEC	0
		2DEC	0
		2DEC	.051901456

INITRFSM	2DEC	-.326527826
		2DEC	-.378503058
		2DEC	.010724388

		2DEC	-.209651023
		2DEC	.168924633
		2DEC	-.421320442

		2DEC	.315318927
		2DEC	-.279642455
		2DEC	-.269024294
