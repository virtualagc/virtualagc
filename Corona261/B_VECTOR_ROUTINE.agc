### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	B_VECTOR_ROUTINE.agc
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

U31,6426	EXIT	0		## MNG calls this

		CAF	FFLAG8		## Is flag 8 set?
		MASK	FFFLAGS
		CCS	A
		TC	U31,6525	## Yes, go to U31,6525

		TC	INTPRET		## Flag 8 not set.

		SMOVE	3
		TSLT	DMP
		ABS	LXC,1
		ITC
			SITENUMB	## Transform SITENUMB (+/- 1,2,3) into an index (6,12,18)
			3
			3/4
			MPAC
			EARTHMX		## Construct an earth rotation matrix for TET

		VMOVE*	1
		MXV	VSLT
			LNDMKTAB -6,1	## Load landmark according to above index...
			2		## and rotate it to the current time.
			1		## Result left in PD+4.

		VSRT	2
		VAD	VSU
		UNIT	STZ
			DELTAV		## Build up a reference position vector
			10D
			REFRCV
			4		## Subtract the rotated landmark vector...
			NUMBOPT		##   (NUMBOPT = 0)
		STORE	BVECTOR		## ... make it a unit vector, and store the result as BVECTOR.

		SMOVE	1
		BMN
			SITENUMB
			U31,6512	## Go to U31,6512 if SITENUMB is negative.

		TSLT	1
		BDSU
			30D		## Subtract twice the magnitude of
			1		##   (pos -  rotated landmark vector)  from MEASQ(?)
			MEASQ
		STORE	MEASQ		## ...and save the result as MEASQ(?).

		DMOVE	1
		AXC,1	SXA,1
			U31,7410
			TMMARKER
			NVCODE		## NVCODE = TMMARKER
		STORE	HMAG		## HMAG(?) = U31,7410

U31,6503	VMOVE	0
			ZEROVEC
		STORE	BVECTOR +6	## BVECTOR [3..5] = 0.0

U31,6506	ITC	0		## Call measurement incorporation
			INCORP1

		ITC	0		## Finally, return to MNG for phase 14.
			DOMID14



U31,6512	VMOVE	0		## Comes here from U31,6426 if SITENUMB was negative.
			BVECTOR
		STORE	BVECTOR +6	## Copy BVECTOR[0..2] into BVECTOR[3..5]

		DMOVE	1
		AXC,1	SXA,1
			U31,7412
			TMMARKER
			NVCODE		## NVCODE = TMMARKER
		STORE	HMAG		## HMAG(?) = U31,7412

		ITC	0		## Go to INCORP1 and exit to MNG for phase 14.
			U31,6506



U31,6525	CAF	BITS1-3		## Comes here from U31,6426 if flag 8 was set.
		MASK	SITENUMB
		INDEX	A		## Isolate the bottom 3 bits of SITENUMB.
		TC	+1
		TC	GOENDMID	## 0 -> Exit MNG.
		TC	U31,7020	## 1 -> Go to U31,7020.
		TC	U31,7101	## 2 -> Go to U31,7101.
		TC	U31,7076	## 3 -> Go to U31,7076.
		TC	U31,7170	## 4 -> Go to U31,7170.

		CS	FFFLAGS		## 5 -> continue here.
		MASK	FFLAG13
		CCS	A		## Is flag 13 set?
		TC	U31,6762	## No, go to U31,6762.

		CAF	ONE
		TS	NUMBOPT		## NUMBOPT = 1

		TC	INTPRET
		LXC,1	1
		INCR,1
			MARKSTAT
			-7

		DMOVE*	2
		DMP	TSLT
		ROUND	DSU
			0,1
			SCLTAVMD
			3
			TE
		STORE	TET

		NOLOD	1
		TSLT	DDV
			4
			EARTHTAB +9D
		STORE	GIVENT

		NOLOD	1
		TSLT
			6
		STORE	DT/2

		ITC	0
			U24,7165

		ITC	0
			RECTIFY

		AXT,1	1
		SXA,1	ITC
			+3
			HBRANCH
			CALLKEP

		LXA,1	1
		INCR,1	SXA,1
			FIXLOC
			14D
			PUSHLOC

		UNIT	0
			RCV
		STORE	BVECTOR
		
		DMOVE	0
			30D
		STORE	BETAM
		
		DMOVE	0
			28D
		STORE	SCALEA

		UNIT	3
		VXV	ABVAL
		TSLT	ASIN
		TSRT	ROUND
			RRECT
			BVECTOR
			2
			1

		TSRT	1
		DDV	SQRT
			30D
			4
			BETAM
	
		DSU	0
			DP1/4
			16D

		TSRT	1
		SINE	DMPR
			14D
			1
		STORE	VACZ

		DAD	0
			DP1/4

		TSRT	1
		COS	DMPR
			14D
			1
		STORE	VACX

		RTB	0
			ARCTAN

		DAD	2
		TSRT	COS
		TSLT	BOV
			-
			-
			1
			1
			U31,7012

		ITC	0
			U31,6366	## In lat-long

U31,6671	LXC,1	0		## Lat-long returns here?
			MARKSTAT

		VMOVE	1
		DOT*	TSLT
			BVECTOR
			0,1
			2

		DSQ	1
		DSU	DSU
			14D
			DP1/2
			DP1/2

		ITC	0
			GETPOS

		NOLOD	0
		STORE	DELR

		ITC	0
			GETERAD

		DDV	4
		DAD	SQRT
		DAD	DMPR
		COMP	VXSC*
		VSLT	VAD
			ERADSQ/4
			SCALEA
			-
			-
			LONGDES
			0,1
			2
			RCV
		STORE	LNDMRKV

		ITC	0
			EARTHMX

		VXM	3
		VSLT	VSU
		VXV	UNIT
		COMP
			LNDMRKV
			2
			1
			RCV
			VECTAB
		STORE	0,1

		EXIT	0

		CS	FFLAG13		## Take down flag 13.
		MASK	FFFLAGS
		TS	FFFLAGS

		CS	FFLAG4		## Put up flag 4.
		MASK	FFFLAGS
		AD	FFLAG4
		TS	FFFLAGS

		CS	FFLAG5		## Take down flag 5.
		MASK	FFFLAGS
		TS	FFFLAGS

		TC	BANKCALL	## Off to MNG for phase 12.
		CADR	DOMID12

U31,6762	TC	INTPRET
		DMOVE	1
		AXC,1	SXA,1
			U31,7426
			TMMARKER
			NVCODE
		STORE	VARIANCE

		VMOVE	0
			VECTAB
		STORE	BVECTOR +6

		VSRT	2
		VAD	DOT
		TSRT	COMP
			NUV
			8D
			REFVCV
			VECTAB
			1
		STORE	DELTAQ

		VMOVE	0
			ZEROVEC
		STORE	BVECTOR

		ITC	0
			U31,6506

U31,7012	DMOVE	0
			U31,7452

		ITC	0
			U31,6366	## In lat-long

GOENDMID	TC	BANKCALL
		CADR	ENDMID

U31,7020	CAF	V25N72
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	U31,7020
		TC	U31,7020

		TC	INTPRET
		VMOVE	0
			DELR
		STORE	LNDMRKV

		ITC	0
			ROTLNDMK

		ITC	0
			U31,7344

		ITC	0
			U31,7364

		TSLT	1
		DMPR	DAD
			28D
			2
			SXTVAR
			D1/4096
		STORE	VARIANCE

U31,7047	VXV	1
		VXV	UNIT
			UVL
			STARMEAS
			UVL
		STORE	BVECTOR

		DOT	4
		TSLT	ACOS
		BDSU	TSLT
		DMPR	AXC,1
		SXA,1	DMPR
			UVL
			STARMEAS
			1
			MEASQ
			4
			PI/4.0
			TMMARKER
			NVCODE
			12D
		STORE	MEASQ

		ITC	0
			U31,6503

U31,7076	CAF	ZERO
		TS	MEASQ
		TS	MEASQ +1

U31,7101	TC	INTPRET
		ITC	0
			U31,7344

		RTB	0
			FRESHPD

		VSRT	1
		VAD	UNIT
			TDELTAV
			10D
			RCV

		VXV	0
			0
			STARMEAS

		DSQ	1
		BDSU	SQRT
			U31,7432
			28D

		DMOVE	0
			30D

		VXV	1
		UNIT
			6
			0

		EXIT	0

		CS	U31,7201
		MASK	SITENUMB
		CCS	A
		TC	U31,7142

		TC	INTPRET
		VMOVE	1
		COMP
			-

		EXIT	0

U31,7142	TC	INTPRET
		DSQ	2
		TSLT	DMPR
		DAD
			12D
			2
			SXTVAR
			D1/1024
		STORE	VARIANCE

		DDV	1
		VXSC
			U31,7432
			14D

		DDV	1
		VXSC	BVSU
			12D
			14D
			0
			-
		STORE	UVL

		ITC	0
			U31,7047
	
U31,7170	CS	VB06N75
		TS	NVCODE

		CS	NUMBOPT
		INDEX	MARKSTAT
		AD	QPRET
		EXTEND
		SU	ONE
		CCS	A
		TC	U31,7220
U31,7201	OCT	01000
BIT4-9  	OCT	00770
U31,7203	CAF	V25N72
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	GOENDMID
		TC	U31,7203

		TC	INTPRET

		VMOVE	1
		LXC,1
			DELR
			MARKSTAT
		STORE	VAC +4,1

		EXIT	0

U31,7220	TC	INTPRET
		LXC,1	1
		VMOVE*
			MARKSTAT
			VAC +4,1
		STORE	LNDMRKV

		ITC	0
			ROTLNDMK

		VMOVE	0
			UNITZ
		STORE	STARMEAS

		VMOVE	0
			ZEROVEC
		STORE	BVECTOR +6

U31,7236	ITC	0		## MNG calls this
			U31,7364

		TSLT	1
		DMPR	DAD
			28D
			2
			ALTVAR
			D1/4096
		STORE	VARIANCE

		VXV	1
		UNIT
			UVL
			STARMEAS
		STORE	STARMEAS

		NOLOD	0
		STORE	BVECTOR

		DOT	3
		TSLT	ACOS
		DSU	TSLT
		DMPR	DMPR
			STARMEAS
			VECTAB
			1
			DP1/4
			4
			PI/4.0
			12D
		STORE	DELTAQ

		ITC	0
			INCORP1

		SWITCH	0
			FIRSTFLG

		ITC	0
			DOMID14

ROTLNDMK	ITA	0
			MIDEXIT

		ITC	0
			EARTHMX

		MXV	1
		VSLT
			LNDMRKV
			2
			1
		STORE	ROTLMV

		ITCI	0
			MIDEXIT

EARTHMX		RTB	0		## Construct an earth rotation matrix to time TET.
			ZEROVAC		## Assumes pushloc is 2. Matrix always stored at PD+2.
					## Pushloc is left at 4.
		DMP	2
		TSLT	RTB
		STZ	ROUND
			TET
			WEARTH
			3
			FRESHPD
			OVFIND

		COS	0
			0

		NOLOD	0
		STORE	10D

		SINE	0
			0
		STORE	8D

		NOLOD	1
		COMP
		STORE	4

		DMOVE	0
			DP1/2
		STORE	18D

		ITCQ	0

U31,7344	ITA	0
			MIDEXIT

		EXIT	0

		CAF	BIT4-9		## Transform bits 4-9 of SITENUMB into
		MASK	SITENUMB	## an index for the star (??) table
		CS	A
		EXTEND
		MP	D3/4
		INDEX	FIXLOC
		TS	X1		## X1 = -6, -12, -18, etc...

		TC	INTPRET		## Load the selected vector into STARMEAS
		VMOVE*	0
			U24,7403 -6,1
		STORE	STARMEAS

		ITCI	0
			MIDEXIT

U31,7364	VSRT	2
		VAD	BVSU
		UNIT
			DELTAV		## Calculate current position.
			10D
			REFRCV
			ROTLMV		## Subtract the rotated landmark vector.
		STORE	UVL		## Make unit vector and store in UVL.

		DMOVE	0
			30D
		STORE	12D		## Store magnitude of (ROTLMV - pos) in 12D

		ITCQ	0

PI/4.0		2DEC	.785398164
WEARTH		2DEC	7.0191646 B-3	# REV/WEEK
SXTVAR		2DEC	.04 E-6 B+16
ALTVAR		2DEC	1.521 E-5 B+16
U31,7410	2DEC	2621
U31,7412	2DEC	0.0
		2DEC	0.0
		2DEC	0.0
		2DEC	0.0
D1/1024		2DEC	1.0 B-10
D1/4096		2DEC	1.0 B-12
U31,7426	2DEC	144620

VB06N75		OCT	00675
		OCT	00675

U31,7432	2DEC	.19464615

UNITZ		2DEC	0.0
		2DEC	0.0
		2DEC	0.5

D3/4		2DEC	3.0 B-2

V25N72		OCT	02572
FFLAG13		OCT	10000
FFLAG4		OCT	00010
FFLAG5		OCT	00020
FFLAG8		OCT	00200
BITS1-3		OCT	00007
U31,7452	OCT	37777
		OCT	77777
