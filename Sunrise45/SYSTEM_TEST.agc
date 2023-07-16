### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	SYSTEM_TEST.agc
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

## This log section almost entirely contains code that is not present in any
## surviving program listings. It has been written from scratch to match the
## module disassembly, utilizing AGC Information Series Issue 21: System Test
## for label names.

		BANK	30

LGNTEST1	CAF	ONE
		TS	POSITON

		TC	GRABDSP
		TC	PREGBSY

		CAF	LABLAT2
		TS	LATITUDE
		CAF	LABLAT2 +1
		TS	LATITUDE +1

LGNTEST4	CS	ZERO
		TS	CDUIND
		TC	BANKCALL
		CADR	IMUZERO
		TC	DSPLLOAD
		TC	FINDNB2
		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTSDSP
		TC	PUTPOS
		TC	LGNINIT

		CAF	THREE
LGNTEST3	TC	WAITLOP1

		TC	INTPRET
		ITC	0
			EARTHRAS
		ITC	0
			OUTGYRO
		EXIT	0

		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTSDSP

		CCS	COUNTPL
		TC	WAITLOP2

		CAF	ZERO
		TS	XSM +2
		TS	XSM +4
		TS	XSM +8D
		TS	XSM +10D
		TS	XSM +14D
		TS	XSM +16D
		TC	READTIME

		CAF	ZERO
		NDX	PIPINDEX
		AD	PIPAX
		NDX	RESULTCT
		TS	GENPLACE +2

		CAF	ZERO
		NDX	PIPINDEX +1
		AD	PIPAX
		NDX	RESULTCT
		TS	GENPLACE +3

		CS	RUPTSTOR
		NDX	RESULTCT
		TS	GENPLACE
		CS	RUPTSTOR +1
		NDX	RESULTCT
		TS	GENPLACE +1

		RELINT
		CS	RESULTCT
		AD	EIGHT
		CCS	A
		CAF	FOUR
		AD	RESULTCT
		TC	LGNTEST2

		CAF	1000DEC
		TS	COUNTPL
		CAF	ZERO

LGNTEST5	TS	RESULTCT
		TC	TDSPLY
		TC	DISPLAYR
		TC	PIPDSPLY
		TC	DISPLAYR

		XCH	RESULTCT
		AD	ONE
		TS	RESULTCT
		TC	PIPDSPLY
		TC	DISPLAYR

		CS	RESULTCT
		AD	TWO
		CCS	A
		CAF	FOUR
		TC	LGNTEST5

		TC	SYSPATCH

LGNTEST2	TS	RESULTCT
		CAF	FORTY
		TC	LGNTEST3

TDSPLY		XCH	Q
		TS	QPLACE
		TC	INTPRET
		LXC,1	0
			RESULTCT

		DSU*	2
		DMP	TSLT
		RTB
			GENPLACE +4,1
			GENPLACE,1
			DEC0.64
			8D
			SGNAGREE
		STORE	DSPTEM2

		EXIT	0
		TC	QPLACE

PIPDSPLY	INDEX	RESULTCT
		CS	GENPLACE +2
		INDEX	RESULTCT
		AD	GENPLACE +6
		TS	DSPTEM2
		CAF	ZERO
		TS	DSPTEM2 +1
		TC	Q

PIPTEST1	TC	GRABDSP
		TC	PREGBSY
		TC	FINDNB2

		CAF	ONE
PIPTEST2	TS	POSITON
		CAF	LABLAT2
		TS	LATITUDE
		CAF	LABLAT2 +1
		TS	LATITUDE +1

		CS	ZERO
		TS	CDUIND

		TC	BANKCALL
		CADR	IMUZERO

		TC	DSPLLOAD

		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTSDSP

		TC	PUTPOS
		XCH	RESULTCT
		TS	PIPINDEX
		TC	LGNINIT

		CAF	300SEC
PIPTEST4	TC	WAITLOP1
		TC	INTPRET
		RTB	1
		ITC
			READPIPS
			ERECTION
		ITC	0
			EARTHRAS
		ITC	0
			OUTGYRO
		EXIT	0

		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTSDSP

		CCS	COUNTPL
		TC	WAITLOP2

		CAF	ONE
		INDEX	PIPINDEX
		AD	PIPAX
		TS	PIPANO

		TC	CATCHAPP

		XCH	MPAC
		INDEX	RESULTCT
		TS	GENPLACE
		XCH	MPAC +1
		INDEX	RESULTCT
		TS	GENPLACE +1
		XCH	MPAC +2
		INDEX	RESULTCT
		TS	GENPLACE +2

		XCH	PIPANO
		INDEX	RESULTCT
		TS	GENPLACE +3

		CS	RESULTCT
		AD	FOUR
		CCS	A
		CAF	FOUR
		TS	RESULTCT
		TC	PIPTEST3

		CS	GENPLACE +3
		AD	GENPLACE +7
		CCS	A
		AD	ONE
		TC	+3
		COM
		AD	POSMAX
		INDEX	FIXLOC
		TS	4

		TC	INTPRET
		TSU	1
		TSLT	ROUND
			GENPLACE +4
			GENPLACE
			14D

		SMOVE	2
		DMP	DDV
		RTB
			4
			DEC585
			-
			SGNAGREE
		STORE	DSPTEM2

		EXIT	0

		CAF	1000DEC
		AD	POSITON
		TS	COUNTPL
		TC	DISPLAYR

		CAF	ONE
		AD	POSITON
		TC	PIPTEST2

PIPTEST3	CAF	NINE
		TC	PIPTEST4

FINDNB2		XCH	Q
		TS	QPLACE

		CAF	ONE
		TS	DSPTEM1
		CAF	TWO
		TS	DSPTEM1 +1
		CAF	VB04N30
		TC	NVSUB
		TC	PRENVBSY

		CAF	TWO
		TC	BANKCALL
		CADR	SXTMARK
		TC	BANKCALL
		CADR	OPTSTALL
		TC	ENDTSDSP

		TC	INTPRET
		LXC,1	0
			MARKSTAT

		ITC	0
			SXTNB

		VMOVE	1
		INCR,1
			STARM
			-7
		STORE	STARAD

		ITC	0
			SXTNB

		VMOVE	0
			STARM
		STORE	STARAD +6

		VMOVE	0
			SYNSTAR1
		STORE	6

		VMOVE	0
			SYNSTAR2
		STORE	12D

		ITC	0
			AXISGEN

		VMOVE	0
			XDC
		STORE	STARAD

		VMOVE	0
			YDC
		STORE	STARAD +6

		VMOVE	0
			ZDC
		STORE	STARAD +12D

		EXIT	0
		TC	QPLACE

PUTPOS		XCH	Q
		TS	QPLACE

		CAF	MTRXLD
 +3		TS	OVCTR

		CAF	ZERO
		INDEX	OVCTR
		TS	XSM

		CCS	OVCTR
		TC	PUTPOS +3

		INDEX	POSITON
		TC	+1
		TC	ENDTSDSP
		TC	POSITON1
		TC	POSITON2
		TC	POSITON3
		TC	POSITON4
		TC	POSITON5
		TC	POSITON6
		TC	POSITON7
		TC	POSITON8
		TC	POSITON9

POSITON1	CAF	HALF
		TS	XSM
		TS	YSM +2
		TS	ZSM +4
		CAF	TWO
		TS	PIPINDEX
		CAF	ONE
		TS	PIPINDEX +1
		CS	ZERO
		TS	RESULTCT
		TC	PUTPOS2

PUTPOS1		CS	OGC
		CS	A
		TS	THETAD
		CS	MGC
		CS	A
		TS	THETAD +2
		CS	IGC
		CS	A
		TS	THETAD +1
		TC	TASKOVER

PUTPOS2		TC	INTPRET
		ITC	0
			CALCGA
		EXIT	0

		CS	CDUX
		CS	A
		TS	THETAD
		CS	CDUY
		CS	A
		TS	THETAD +1
		CS	CDUZ
		CS	A
		TS	THETAD +2

		CAF	ZERO
		TS	KH
		CAF	SYSTSTKG
		TS	KG

		TC	BANKCALL
		CADR	IMUCOARS

		INHINT
		CAF	0.5SEC
		TC	WAITLIST
		CADR	PUTPOS1
		RELINT

		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTSDSP

		TC	BANKCALL
		CADR	IMUFINE

		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTSDSP

		CS	CDUX
		CS	A
		NDX	MARKSTAT
		TS	6
		CS	CDUY
		CS	A
		NDX	MARKSTAT
		TS	2
		CS	CDUZ
		CS	A
		NDX	MARKSTAT
		TS	4

		CAF	TWO
		AD	MARKSTAT
		NDX	FIXLOC
		TS	S1

		TC	INTPRET
		MXV	1
		VSLT	ITC
			XSM
			STARAD
			1
			NBSM

		NOLOD	0
		STORE	XDC

		MXV	1
		VSLT	ITC
			YSM
			STARAD
			1
			NBSM

		NOLOD	0
		STORE	YDC

		VXV	1
		VSLT
			XDC
			YDC
			1
		STORE	ZDC

		ITC	0
			CALCGTA

		ITC	0
			OUTGYRO

		EXIT	0

		TC	QPLACE

## The following two words are unreachable, but their values
## suggest they may be dead code.
		CADR	MKRELEAS
		TC	QPLACE

CATCHAPP	XCH	Q
		XCH	QPLACE

CATCHAP1	RELINT
		CCS	NEWJOB
		TC	CHANG1
		INHINT

		CS	PIPANO
		INDEX	PIPINDEX
		AD	PIPAX
		AD	ONE
		CCS	A
		TC	TOOFARAP
		LOC	+1
		TC	CATCHAP1

		CAF	BIT6
CATCHAP4	TS	OVCTR
		CS	PIPANO
		INDEX	PIPINDEX
		AD	PIPAX
		CCS	A
		TC	TOOFARAP
		LOC	+1
		TC	CATCHAP5

CATCHAP3	CS	TIME2
		CS	A
		TS	MPAC
		CS	TIME1
		CS	A
		TS	MPAC +1

		CS	IN2
		CS	IN2
		CS	A
		MASK	FINEMASK
		TS	MPAC +2

		CCS	A
		TC	CATCHAP2

		CS	TIME2
		CS	A
		TS	MPAC
		CS	TIME1
		CS	A
		TS	MPAC +1

CATCHAP2	RELINT
		XCH	MPAC +2
		EXTEND
		MP	BIT11
		XCH	LP
		TS	MPAC +2
		TC	QPLACE

CATCHAP5	CCS	OVCTR
		TC	CATCHAP4
		TC	CATCHAP1

TOOFARAP	CAF	ONE
		INDEX	PIPINDEX
		AD	PIPAX
		XCH	PIPANO
		TC	CATCHAP1

WAITLOP1	XCH	Q
		TS	QPLACE

		CS	Q
		TS	COUNTPL
WAITLOP4	CCS	COUNTPL
		TC	+4
		TC	QPLACE
		TC	+2
		TC	WAITLOP4 -1

		INHINT
		CAF	10SEC
		TC	WAITLIST
		CADR	WAITLOP3
		RELINT

		CCS	COUNTPL
		TC	QPLACE
		TC	QPLACE
		NOOP
WAITLOP2	TS	COUNTPL

		CAF	WTLOPCAD
		TC	JOBSLEEP

WTLOPCAD	CADR	WAITLOP4

WAITLOP3	CAF	WTLOPCAD
		TC	JOBWAKE
		TC	TASKOVER

ERECTION	NOLOD	1
		VXM	VSLT
			XSM
			1
		STORE	0

		DMOVE	0
			VAC +2

		COMP	0
			VAC +4

		SMOVE	1
		VDEF
			ZERODP

		NOLOD	1
		VXSC	VSLT
			INTCON
			1

		VSU	3
		BOV	VXSC
		VSLT	VAD
		MXV	VAD
			0
			18D
			ERECTEND
			PROCON
			1
			-
			XSM
			OGC
		STORE	OGC

		VMOVE	0
		STORE	18D

ERECTEND	ITCQ	0

OUTGYRO		AXT,1	1
		AST,1	AXT,2
			6
			2
			0

OUTGYRO1	TSRT*	0
			OGC +6,1
			8D,2
		STORE GYROD +6,1

		TSLT*	1
		BDSU*
			GYROD +6,1
			8D,2
			OGC +6,1
		STORE OGC +6,1

		TIX,1	1
		RTB	ITCQ
			OUTGYRO1
			PULSEIMU

EARTHRAS	RTB	0
			LOADTIME
		STORE	S1

		NOLOD	3
		DSU	TSLT
		VXSC	MXV
		VAD
			30D
			10D
			24D
			XSM
			OGC
		STORE	OGC

		DMOVE	0
			S1
		STORE	30D

		ITCQ	0

LGNINIT		XCH	Q
		TS	QPLACE

		TC	INTPRET
		RTB	0
			ZEROVAC

		DMOVE	0
			ZERODP

		COS	1
		COMP
			LATITUDE

		SIN	1
		VDEF	VXSC
			LATITUDE
			OMEGA/MS
		STORE	24D

		RTB	0
			LOADTIME
		STORE	30D

		EXIT	0

		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTSDSP

		CAF	ZERO
		TS	PIPAX
		TS	PIPAY
		TS	PIPAZ
		TS	RESULTCT

		TC	QPLACE

DSPLLOAD	XCH	Q
		TS	QPLACE

		CS	LATITUDE
		COM
		TS	DSPTEM2
		CS	LATITUDE +1
		COM
		TS	DSPTEM2 +1
		CS	POSITON
		COM
		TS	DSPTEM2 +2

		TC	BANKCALL
		CADR	FLASHON

		CAF	VB06N66
		TC	NVSUB
		TC	PRENVBSY
		TC	ENDIDLE
		TC	ENDTSDSP
		TC	QPLACE
		TC	DSPLLOAD +2

DISPLAYR	XCH	Q
		TS	QPLACE

		XCH	COUNTPL
		TS	DSPTEM2 +2
		AD	ONE
		TS	COUNTPL

		TC	BANKCALL
		CADR	FLASHON

		CAF	VB06N66
		TC	NVSUB
		TC	PRENVBSY
		TC	ENDIDLE
		TC	ENDTSDSP
		TC	QPLACE

ENDTSDSP	TC	FREEDSP
		CS	FOUR
		MASK	MODREG
		TS	MODREG
		TC	BANKCALL
		CADR	DSPMM

		CS	ZERO
		TS	CDUIND

		TC	BANKCALL
		CADR	MKRELEAS

		TC	ENDOFJOB

OMEGA/MS	2DEC	.12169524
LABLAT2		2DEC	.11767824
NINE		DEC	9
MTRXLD		DEC	17
240SEC		DEC	24
300SEC		DEC	30
0.5SEC		DEC	.5 E2
10SEC		DEC	10 E2
1000DEC		EQUALS	10SEC
20SEC		DEC	20 E2
GYPRIO		OCT	23000

## The following words are unreferenced constants.
		2DEC	0.1481
		2DEC	0.5628
		2DEC	0.8519
		2DEC	0.5628

SYNSTAR1	2DEC	0.0
		2DEC	0.5
		2DEC	0.0

SYNSTAR2	2DEC	0.0
		2DEC	0.35355
		2DEC	0.35355

INTCON		2DEC	20 B-5
PROCON		=	INTCON
DEC585		2DEC	5.85 E2 B14
DEC0.64		2DEC	0.64
VB04N30		OCT	00430

POSITON2	CAF	HALF
		TS	YSM +4
		TS	ZSM +2
		CS	A
		TS	XSM
		CAF	ONE
		TS	PIPINDEX
		CAF	TWO
		TS	PIPINDEX +1
		CAF	OPOVF
		TS	RESULTCT
		TC	PUTPOS2

POSITON3	CAF	HALF
		TS	XSM +4
		TS	ZSM +2
		TS	YSM
		CAF	ZERO
		TS	PIPINDEX
		CAF	TWO
		TS	PIPINDEX +1
		CAF	ONE
		TS	RESULTCT
		TC	PUTPOS2

POSITON4	CAF	HALF
		TS	XSM +2
		TS	ZSM +4
		COM
		TS	YSM
		CAF	TWO
		TS	PIPINDEX
		CAF	ZERO
		TS	PIPINDEX +1
		CAF	OPOVF
		AD	ONE
		TS	RESULTCT
		TC	PUTPOS2

POSITON5	CAF	HALF
		TS	YSM +4
		TS	XSM +2
		TS	ZSM
		CAF	ONE
		TS	PIPINDEX
		CAF	ZERO
		TS	PIPINDEX +1
		CAF	TWO
		TS	RESULTCT
		TC	PUTPOS2

POSITON6	CAF	HALF
		TS	XSM +4
		TS	YSM +2
		COM
		TS	ZSM
		CAF	ZERO
		TS	PIPINDEX
		CAF	ONE
		TS	PIPINDEX +1
		CAF	OPOVF
		AD	TWO
		TS	RESULTCT
		TC	PUTPOS2

FINEMASK	OCT	17
SYSTSTKG	DEC	.18
ROOT2/4		2DEC	.353553391

POSITON7	CAF	ROOT2/4
		TS	ZSM
		TS	ZSM +2
		TS	YSM
		COM
		TS	YSM +2
		CAF	ROOT2/4 +1
		TS	ZSM +1
		TS	ZSM +3
		TS	YSM +1
		COM
		TS	YSM +3
		CAF	HALF
		TS	XSM +4
		CAF	ZERO
		TS	PIPINDEX
		TC	PUTPOS2

POSITON8	CAF	ROOT2/4
		TS	XSM
		TS	XSM +2
		TS	ZSM
		COM
		TS	ZSM +2
		CAF	ROOT2/4 +1
		TS	XSM +1
		TS	XSM +3
		TS	ZSM +1
		COM
		TS	ZSM +3
		CAF	HALF
		TS	YSM +4
		CAF	ONE
		TS	PIPINDEX
		TC	PUTPOS2

POSITON9	CAF	ROOT2/4
		TS	YSM
		TS	YSM +2
		TS	XSM
		COM
		TS	XSM +2
		CAF	ROOT2/4 +1
		TS	YSM +1
		TS	YSM +3
		TS	XSM +1
		COM
		TS	XSM +3
		CAF	HALF
		TS	ZSM +4
		CAF	TWO
		TS	PIPINDEX
		TC	PUTPOS2

VB06N66		OCT	00666
FORTY		DEC	40

ENDSYST		EQUALS

		SETLOC	61400

SYSPATCH	TC	BANKCALL
		CADR	MKRELEAS
		TC	LGNTEST4