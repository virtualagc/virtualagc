### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	LATITUDE-LONGITUDE_SUBROUTINES.agc
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

		BANK	31

LONGPASS	ITA	0
			STEPEXIT	## STEPEXIT = return to MNG

		ITC	0
			RECTIFY

		ITC	0
			KEPLER

## After KEPLER, the pushdown list contains the following:
## PD +0: unit(RRECT)
## PD +6: |RRECT|
## PD +8D: A4 = (|RRECT| * |VRECT|**2 - 1/4) * 4   this is "c_2" in the GSOP
##             --------------------------------
##                           mu
## PD +10D: ALPHA = (1/4 - (A4 / 4)) / |RRECT|	   also alpha in the GSOP
## PD +12D: A1 = (RRECT . VRECT)                   this is "c_1" in the GSOP
##              ---------------
##                 sqrt(mu)

		VXV	1
		AXT,2	UNIT
			UNITZ
			RRECT
			10D		## X2 = 10, setting up for 10 iterations
		STORE	UNE		## UNE = UNITZ x RRECT

		VXV	1
		AST,2	UNIT
			UNITZ
			UNE
			1		## S2 = 1, also setting up for 10 iterations
		STORE	UNP		## UNP = UNITZ x UNE

		DMOVE	1
		ITC
			TET
			LAT-LONG	## Get LAT and LONG at current state vector time

		NOLOD	1
		BDSU	DDV
			LONGDES
			15/16
		STORE	DLONG		## DLONG = (LONGDES - LONG)*16/15

		ITC	0
			ORBPARM		## Calculate HMAG, ALPHAM, COTGAM

HOPALONG	COS	1
		VXSC
			DLONG
			UNE		## PD +14D = UNE * cos(DLONG)

		SIN	1
		VXSC	VAD
			DLONG
			UNP		## PD +14D = UNE*cos(DLONG) + UNP*sin(DLONG)

		VXV	1
		VXV	UNIT
			VRECT
			RRECT		## PD +14D = unit((VRECT x RRECT) x (PD+14D))

		UNIT	2
		VSLT	DOT
		DAD	SQRT
			RRECT
			1
			-
			DP1/2		## PD +14D = sqrt((unit(RRECT) . (PD+14D)) + 1/2)

HOP1		DSQ	2		## Expects to find scalar in PD+14D
		BDSU	DAD
		SQRT
			14D
			DP1/2
			DP1/2		## PD +16D = sqrt(1 - (PD+14)**2)

		NOLOD	1
		DMPR
			ALPHAM
		STORE	VACZ		## VACZ = (PD+16D) * ALPHAM
		
		DMPR	1
		BDSU	DMPR
			COTGAM
			-
			-
			HMAG
		STORE	VACX		## VACX = HMAG * ((PD+14D) - (cot(gamma) * (PD+16D)))

		RTB	0
			ARCTAN		## PD +14D = atan2(VACZ, VACX)

		ITC	0
			PASSTIME	## Get time of flight T in PD +18D, position, and velocity

		LXA,1	1
		INCR,1	SXA,1
			FIXLOC
			14D
			PUSHLOC		## Reset PD indicator to 14D

		DMP	2
		TSRT	ROUND
		DAD
			18D
			EARTHTAB +9D
			4
			TE
		STORE	TDEC		## TDEC = TE + T * EARTHTAB

		EXIT	0

		CS	FFFLAGS		## Is flag 13 set?
		MASK	FFLAG13
		CCS	A
		TC	+4		## No: call skip next call

		TC	INTPRET		## Flag 13 is set. Call the thing in B-VECTOR
		ITC	0
			U31,6671	## In B-VECTOR

		TC	INTPRET		## Call LAT-LONG for newly found position
		ITC	0
			LAT-LONG

		NOLOD	1
		BDSU	DDV
			LONGDES
			15/16		## PD +14D = (LONGDES - LONG)*16/15

		NOLOD	2
		ABS	DSU
		BMN	TIX,2		## Is abs(PD+14D) < 3e-5?
			EPSILONG
			PASSOUT		## Yes. Skip next call.
			NEXTHOP		## Go to U31,6153 if not done iterating.

PASSOUT		STZ	0		## Result is within bounds. Set NUMBTEMP to 0.
			NUMBTEMP

		ITCI	0
			STEPEXIT	## Return to caller of LONGPASS

NEXTHOP		DAD	0		## Result was not within bounds.
			DLONG
		STORE	DLONG		## DLONG = DLONG + (PD+14D)  -- popping off of PD

		ITC	0
			HOPALONG	## Next iteration.

PASSTIME	NOLOD	2
		DMPR	DMPR
		DDV
			6
			PI/4.0
			ALPHAM
		STORE	XKEP		## XKEP = (MPAC * |RRECT| * PI/4.0) / ALPHAM

		ITA	0		## Makes GETRANDV return to caller of PASSTIME
			HBRANCH

		ITC	0		## Calculate time of flight
			KTIMEN+1

		ITC	0		## Get position and velocity at new X
			GETRANDV

LAT-LONG	NOLOD	0
		STORE	LONG		## LONG = TET

		ITA	0
			INCORPEX

		STZ	0
			OVFIND		## OVFIND = 0

		ITC	0		## Returns with RCV + TDELTAV in MPAC
			GETPOS

		NOLOD	0
		STORE	ALPHAV		## ALPHAV = RCV + TDELTAV

		DSQ	0
			ALPHAV		## PD +0 = ALPHAV[0]**2

		DSQ	2
		DAD	SQRT
		DMPR
			ALPHAV +2
			-		## Pops off of PD
			B2/A2
		STORE	VACX		## VACX = sqrt(ALPHAV[1]**2 + ALPHAV[0]**2) * B2/A2

		DMOVE	0
			ALPHAV +4
		STORE	VACZ		## VACZ = ALPHAV[2]

		RTB	0
			ARCTAN
		STORE	LAT		## LAT = atan2(VACZ,VACX)

		DSU	2
		DMP	TSLT
		STZ	ROUND
			LONG
			1/100
			WEARTH
			3
			OVFIND		## OVFIND = 0
		STORE	BETAV		## BETAV[0] = (TET - 1/100)*WEARTH*8

		COS	0
			BETAV
		STORE	BETAV +4	## BETAV[2] = cos(BETAV[0])

		SIN	0
			BETAV
		STORE	ALPHAV +4	## ALPHAV[2] = sin(BETAV[0])

		DMPR	0
			ALPHAV
			BETAV +4	## PD +0 = ALPHAV[0] * BETAV[2]

		DMPR	1
		DAD
			ALPHAV +2
			ALPHAV +4
		STORE	VACX		## VACX = (ALPHAV[1] * ALPHAV[2]) + (ALPHAV[0] * BETAV[2])
					## ...popping off of PD list
		DMPR	0
			ALPHAV
			ALPHAV +4	## PD +0 = ALPHAV[0] * ALPHAV[2]

		DMPR	1
		DSU
			ALPHAV +2
			BETAV +4
		STORE	VACZ		## VACZ = (ALPHAV[1] * BETAV[2]) - (ALPHAV[0] * ALPHAV[2])
					## ...popping off of PD list
		RTB	0
			ARCTAN
		STORE	LONG		## LONG = atan2(VACZ, VACX)

		ITCI	0
			INCORPEX

CALCAZ		ITA	0
			MIDEXIT

		ITC	0
			GETPOS

		NOLOD	0
		STORE	ALPHAV

		ITC	0
			GETVEL

		NOLOD	0
		STORE	BETAV

		RTB	0
			FRESHPD

		VXV	1
		VXV	UNIT
			ALPHAV
			UNITZ
			ALPHAV

		VXV	3
		VXV	UNIT
		DOT	TSLT
		ACOS
			ALPHAV
			BETAV
			ALPHAV
			-
			1
		STORE	AZ
		
		ITCI	0
			MIDEXIT

GETPOS		VSRT	1
		VAD	ITCQ
			TDELTAV
			10D
			RCV

GETVEL		VSRT	1
		VAD	ITCQ
			TNUV
			8D
			VCV

GETERAD		ITA	0
			MIDEXIT

		ABVAL	4
		TSLT	BDDV
		DSQ	TSRT
		BDSU	DMPR
		BDSU	BDDV
			ALPHAV
			1
			ALPHAV +4
			1
			DP1/2
			EE
			DP1/2
			B2XSC
		STORE	ERADSQ/4

		NOLOD	1
		SQRT
		STORE	ERAD/2

		ITCI	0
			MIDEXIT

U31,6366	ITC	0		## B-Vector calls this
			ORBPARM

		ITC	0
			HOP1

ORBPARM		VXV	1
		ABVAL	TSLT
			RRECT
			VRECT
			1
		STORE	HMAG		## HMAG = |RRECT x VRECT|

		SQRT	1
		DMP
			10D		## ALPHAM = SQRT(ALPHA) * |RRECT|
			6
		STORE	ALPHAM

		DOT	1
		DDV
			RRECT		##    (RRECT . VRECT)
			VRECT		##    ---------------
			HMAG		##    |RRECT x VRECT|
		STORE	COTGAM		## COTGAM = cot(gamma)

		ITCQ	0

EE		2DEC	6.69342279 E-3
B2XSC		2DEC	0.01881677
B2/A2		2DEC	0.993306577
EPSILONG	2DEC	.3 E-4
1/100		2DEC	.01
