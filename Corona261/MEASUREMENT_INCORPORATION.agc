### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	MEASUREMENT_INCORPORATION.agc
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

		BANK	23

INCORP1		LXA,1	1
		SXA,1	MXV
			FIXLOC
			PUSHLOC
			BVECTOR
			W

		MXV	1
		ITA	VAD
			BVECTOR +6
			W +36D
			INCORPEX

		MXV	0
			BVECTOR
			W +18D

		MXV	1
		VAD
			BVECTOR +6
			W +54D

		NOLOD	1
		VSQ	DAD
			VARIANCE

		VSQ	1
		DAD
			0

		NOLOD	4
		DMPR	SQRT
		DAD	TSLC
		INCR,2	SXA,2
		AXT,2	BDDV
			VARIANCE
			12D
			X2
			-2
			NORMGAM
			72D
			DP1/4
		
		TSLC	2
		AST,2	INCR,1
		BDDV
			12D
			X1
			36D
			1
			DELTAQ

INCOR2		VMOVE	1
		VXM*
			0
			W +72D,2

		VMOVE	1
		VXM*	VAD
			6
			W +90D,2

		NOLOD	2
		VXSC	VSLT*
		TIX,2	VSLT
			16D
			0,1
			INCOR3
			2
		STORE	DELVEL

		DSQ	0
			DELVEL

		DSQ	1
		DAD
			DELVEL +2

		DSQ	1
		DAD	SQRT
			DELVEL +4
			-
		STORE	DSPTEM1 +2

		EXIT	0

		TC	BANKCALL
		CADR	U24,7265

INCORP2		STZ	0
			OVFIND
		
		VSLT	1
		VAD	BOV
			DELVEL
			8D
			NUV
			INCORECT
		STORE	NEWNUV

		VSLT	1
		VAD	BOV
			DELR
			10D
			DELTAV
			INCORECT
		STORE	NEWDLTAV

FAZA		AXT,1	2
		AST,1	AXT,2
		VXSC
			36D
			6
			0
			18D
			14D
		STORE	18D

		VXSC	0
			24D
			14D
		STORE	24D

FAZB		COMP*	3
		VXSC	XCHX,2
		VSLT*	XCHX,2
		VAD*
			0,2
			18D
			NORMGAM
			0,2
			NORMGAM
			W +36D,1
		STORE	W +36D,1

		COMP*	3
		VXSC	XCHX,2
		VSLT*	XCHX,2
		INCR,2	VAD*
			0,2
			24D
			NORMGAM
			0,2
			NORMGAM
			-2
			W +72D,1
		STORE	W +72D,1

		TIX,1	0
			FAZB

		ITCI	0
			INCORPEX

INCORECT	VSRT	1
		VAD	VAD
			DELTAV
			10D
			REFRCV
			DELR
		STORE	RRECT

		NOLOD	0
		STORE	RCV

		VSRT	1
		VAD	VAD
			NUV
			8D
			REFVCV
			DELVEL
		STORE	VRECT

		NOLOD	0
		STORE	VCV

		DMOVE	0
			DPZERO
		STORE	TC

		NOLOD	0
		STORE	XKEP

		VMOVE	0
			ZEROVEC
		STORE	TDELTAV

		NOLOD	0
		STORE	TNUV

		ITC	0
			FAZA

INCOR3		NOLOD	0
		STORE	DELR

		NOLOD	1
		ABVAL	TSLT
			1
		STORE	DSPTEM1
		ITC	0
			INCOR2
