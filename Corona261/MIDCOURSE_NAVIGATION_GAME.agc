### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	MIDCOURSE_NAVIGATION_GAME.agc
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

		BANK	24

MIDMANPH	INDEX	MPAC		## Previous (manual) phase arrives in MPAC
		TC	+1
		TC	ENDMID		## 0 -> end immediately
		TC	MIDSETUP	## 1 -> Phases 1-5 go to MIDSETUP
		TC	MIDSETUP	## 2 -> "
		TC	MIDSETUP	## 3 -> "
		TC	MIDSETUP	## 4 -> "
		TC	MIDSETUP	## 5 -> "
		TC	ENDMID		## 6 -> end immediately

		TC	BANKCALL	## 7 -> Call MIDINIT.
		CADR	MIDINIT

MIDINRET	TC	INTPRET
		AXT,1	2
		SXA,1	AXT,1
		SXA,1
			EARTHTAB
			PBODY		## PBODY = EARTHTAB
			U24,6315
			STEPEXIT	## STEPEXIT = U24,6315

		VAD	0
			RINIT		## Hardcoded initial RRECT/RCV
			DELR
		STORE	REFRRECT	## REFRRECT = RINIT + DELR

		NOLOD	0
		STORE	REFRCV		## Also REFRCV.

		VAD	0
			VINIT		## Hardcoded initial VRECT/VCV
			DELVEL
		STORE	REFVRECT	## REFVRECT = VINIT + DELVEL

		NOLOD	0
		STORE	REFVCV		## Also REFVCV.

		EXIT	0

		TC	ENDMID		## Go end job.

MIDSETUP	CS	ONE
		AD	MPAC
		TS	MANPHS-1	## MANPHS-1 = last phase - 1

		TC	BANKCALL
		CADR	MKRELEAS

## Maintain the GRAB flag, and set all other flags
## according to the current phase.
		CAF	MIDGRBFL
		MASK	FFFLAGS
		INDEX	MANPHS-1
		AD	MIDFLTAB
		TS	FFFLAGS

STRTMID2	TC	PHASCHNG	## New jobs come here.
		OCT	01101
		TC	ENDMID
		TC	MIDSTCHK	## If V37 used to start MNG, this will go to the requested phase.

REMID11		CAF	ONE		## If we got to into STRTMID2 via an automatic phase, it falls through here.
		TS	NUMBOPT		## NUMBOPT = 1

		TC	MIDGRAB

		CAF	FFFLAG8		## Is flag 8 set (manual phase 3 only) ?
		MASK	FFFLAGS
		CCS	A
		TC	LOADSITE	## Yes -- go to LOADSITE

		CAF	FFFLAG13	## Is flag 13 set (manual phases 1-4) ?
		MASK	FFFLAGS
		CCS	A
		TC	U24,6174	## Yes -- go to U24,6174

## Neither flag set (manual phase 5 only), fall into LOADLONG

LOADLONG	CAF	VB21N32		## Ask operator to load TDEC... but actually,
		TC	NVSUB		## what the operator enters is treated as degrees.
		TC	PRENVBSY
		TC	DATAWAIT
		TC	ENDMID		## Terminate
		TC	LOADLONG	## Proceed - ask again

		TC	LOADREF		## Copy reference into actual

		TC	INTPRET

		DMPR	0		## Transform TDEC (now in weeks) to degrees. This
			TDEC		## will exactly match what the operator entered,
			168/360		## scaled 360.
		STORE	LONGDES

		ITC	0
			LONGPASS

		DMOVE	0
			TDEC
		STORE	TET

		ITC	0
			DOMID15

168/360		2DEC	.466666667

LOADSITE	CAF	SITEADR		## Request operator to load SITENUMB
		TS	MPAC +2
		CAF	VB21N02
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	ENDMID
		TC	LOADSITE

		CAF	LOW3
		MASK	SITENUMB	## Isolate bottom 3 bits
		INDEX	A
		TC	+1		## Based off of bottom 3 of SITENUMB...
		TC	LOADSITE	## 0 -> No good, enter again.
		TC	U24,6146	## 1 -> U24,6146
		TC	U24,6146	## 2 -> "
		TC	U24,6146	## 3 -> "
		TC	U24,6153	## 4 -> U24,6153
		TC	U24,6143	## 5 -> U24,6143
		TC	LOADSITE	## 6 -> No good, enter again.
		TC	LOADSITE	## 7 -> No good, enter again.

U24,6143	CAF	TWO		## Bottom 3 of SITENUMB = 5...
		TS	NUMBOPT		## NUMBOPT = 2
		TC	DOMID20		## And off to DOMID20

U24,6146	CAF	BITS4-9		## Bottom 3 of SITENUMB = 1,2,3
		MASK	SITENUMB	## Isolate bits 4-9
		CCS	A
		TC	DOMID17		## *Any* set -> DOMID17
		TC	DOMID20		## None set  -> DOMID20

U24,6153	CAF	FIVE		## Bottom 3 of SITENUMB = 4...
		TS	NUMBOPT		## NUMBOPT = 5

		CAF	VB25N72		## Ask operator to load DELTA POSITION
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	ENDMID
		TC	DOMID20		## Proceed -> go to DOMID20

		TC	FFFLGUP		## Enter -> set flags 1 and 10, continue
		OCT	01001

		CAF	V21N32		## Ask operator to load TDEC
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	ENDMID
		TC	DOMID20		## Proceed -> go to DOMID20

		TC	DOMID17		## Enter -> go to DOMID17

U24,6174	CAF	V21N32		## Ask operator to load TDEC
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	ENDMID		## Terminate - exit job
		TC	U24,6174	## Proceed - enter again

DOMID12		TC	PHASCHNG	## Enter: begin phase 12
		OCT	01201
		TC	ENDMID
		TC	MIDSTCHK

		TC	U24,6225

U24,6207	TC	FFFLGDWN
		OCT	04000

REMID12		CS	FFFLAGS		## Coming here from restart. Has bit 7 been set yet?
		MASK	FFFLAG7
		CCS	A
		TC	U24,6225	## No -- Go to the beginning of phase 12.

		CAF	LOW3
		MASK	SITENUMB
		EXTEND
		SU	THREE
		CCS	A
		TC	ENDMID
LOW3		OCT	00007
		TC	U24,6225

U24,6225	CS	FFFLAGS		## Is flag 6 set? (manual phases 3 and 4)
		MASK	FFFLAG6
		CCS	A
		TC	U24,6300	## No. Go to U24,6300

		CAF	FFFLAG4		## Is flag 4 set?
		MASK	FFFLAGS
		CCS	A
		TC	U24,6307	## Yes. Go to U24,6307

		CAF	FFFLAG8		## Is flag 8 set? (manual phase 3)
		MASK	FFFLAGS
		CCS	A
		TC	U24,6250	## Yes. Go to U24,6250

		TC	MIDGRAB

		INHINT
		CAF	PRIO6
		TC	NOVAC
		CADR	U24,6454
		RELINT

		TC	U24,6307

U24,6250	CS	FFFLAGS
		MASK	FFFLAG7
		CCS	A
		TC	U24,6304

		CAF	LOW3
		MASK	SITENUMB
		EXTEND
		SU	THREE
		CCS	A
		TC	U24,6302
FFFLAG13	OCT	10000
		TC	+1
		TC	MIDGRAB

		INHINT
		CAF	PRIO6
		TC	NOVAC
		CADR	U24,6514
		RELINT

		TC	U24,6307

MIDFLTAB	OCT	12000		## Phase 1 -> bits 11 and 13
		OCT	10000		## Phase 2 -> bit 13
		OCT	12240		## Phase 3 -> bits 6, 8, 11, and 13
		OCT	12040		## Phase 4 -> bits 6, 11, and 13
		OCT	00000		## Phase 5 -> nada

U24,6300	CAF	ZERO
		TS	NUMBOPT

U24,6302	TC	FFFLGUP
		OCT	00010

U24,6304	TC	FREEDSP
		TC	FFFLGDWN
		OCT	00001

U24,6307	CAF	FFFLAG5
		MASK	FFFLAGS
		CCS	A
		TC	U24,6611
		TC	LOADREF

		TC	+2

U24,6315	EXIT	0

		CAF	FFFLAG12
		MASK	FFFLAGS
		CCS	A
		TC	U24,6207

		CAF	FFFLAG11
		MASK	FFFLAGS
		CCS	A
		TC	+4

		CAF	ZERO
		TS	WMATFLAG
		TC	U24,6353

		CAF	ONE
		TS	WMATFLAG
		TC	U24,6353

DOMID16		EXIT	0

		TC	PHASCHNG
		OCT	01601
		TC	ENDMID
		TC	MIDSTCHK
		TC	+3

REMID16		TC	FFFLGUP
FFFLAG12	OCT	04000

		TC	SAVEREF

		TC	PHASCHNG
		OCT	01201
		TC	+2
		TC	+1

		TC	INTPRET
		ITCQ	0

U24,6353	TC	INTPRET
		BMN	0
			TDEC
			DOMID15

		STZ	0
			OVFIND

		DSU	1
		TSLT	DDV
			TDEC
			TET
			9D
			EARTHTAB +9D
		STORE	DT/2

		BOV	3
		ABS	DSU
		BMN	DAD
		DSU	BMN
			USEMXDT2
			DT/2
			DT/2MIN
			U24,6606
			DT/2MIN
			DT/2MAX
			TIMESTEP

USEMXDT2	DMOVE	1
		SIGN
			DT/2MAX
			DT/2
		STORE	DT/2

		ITC	0
			TIMESTEP

ENDMID		TC	FREEDSP
		TC	FFFLGDWN
		OCT	00001

		TC	BANKCALL
		CADR	MKRELEAS

		CS	ONE
		TC	NEWPHASE
		OCT	1

		TC	ENDOFJOB

MIDGRAB		XCH	Q
		TS	MIDEXIT

		CAF	MIDGRBFL
		MASK	FFFLAGS
		CCS	A
		TC	MIDEXIT

		TC	GRABDSP
		TC	PREGBSY

		TC	FFFLGUP
MIDGRBFL	OCT	00001

		TC	MIDEXIT

FFFLGUP		INDEX	Q
		CS	0
		MASK	FFFLAGS
		INDEX	Q
		AD	0
		TS	FFFLAGS
		INDEX	Q
		TC	1

FFFLGDWN	INDEX	Q
		CS	0
		MASK	FFFLAGS
		TS	FFFLAGS
		INDEX	Q
		TC	1

U24,6454	CAF	SITEADR
		TS	MPAC +2

		CAF	VB21N02
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	U24,6600
		TC	U24,6603

		CAF	BITS1-14
		MASK	SITENUMB
		EXTEND
		SU	BITS1-2
		CCS	A
		TC	U24,6454
BITS1-2		OCT	00003
		TC	+1

		CCS	SITENUMB
		TC	U24,6505
		TC	U24,6600
		TC	+2
		TC	U24,6600

		CAF	V21N34
		TC	NVSUB
		TC	PRENVBSY
		TC	+4
U24,6505	CAF	VB21N34
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	U24,6600
		TC	U24,6603

		TC	U24,6553

U24,6514	CAF	SITEADR
		TS	MPAC +2
		CAF	VB21N02
		TC	NVSUB
		TC	PRENVBSY
		TC	DATAWAIT
		TC	U24,6600
		TC	U24,6603

		CAF	LOW3
		MASK	SITENUMB
		INDEX	A
		TC	+1
		TC	U24,6514
		TC	U24,6540
		TC	U24,6540
		TC	U24,6540
		TC	U24,6553
		TC	U24,6553
		TC	U24,6514
		TC	U24,6514

U24,6540	CAF	BITS4-9
		MASK	SITENUMB
		CCS	A
		TC	+2
		TC	U24,6514

		EXTEND
		SU	BITS5-9
		CCS	A
		TC	U24,6514
BITS5-9		OCT	00760
		TC	+1

U24,6553	TC	INTPRET

		DSU	2
		ABS	DSU
		BMN
			TDEC
			TET
			DT/2MIN
			U24,6570

		EXIT	0

		TC	FREEDSP

		TC	FFFLGDWN
		OCT	00001

		TC	+2

U24,6570	EXIT	0

		TC	FFFLGUP
FFFLAG4		OCT	00010

		INHINT
		CAF	U24,6617
		TC	JOBWAKE
		RELINT

		TC	ENDOFJOB

U24,6600	TC	FFFLGUP
FFFLAG2		OCT	00002

		TC	U24,6553

U24,6603	TC	FFFLGUP
FFFLAG3		OCT	00004

		TC	U24,6553

U24,6606	EXIT	0

		TC	FFFLGUP
FFFLAG5		OCT	00020

U24,6611	CAF	FFFLAG4
		MASK	FFFLAGS
		CCS	A
		TC	U24,6620

		CAF	U24,6617
		TC	JOBSLEEP
U24,6617	CADR	U24,6620

U24,6620	CAF	FFFLAG6
		MASK	FFFLAGS
		CCS	A
		TC	U24,6627

U24,6624	CAF	ZERO
		TS	NUMBTEMP
		TC	DOMID15 +1

U24,6627	CAF	FFFLAG2
		MASK	FFFLAGS
		CCS	A
		TC	ENDMID

		CAF	FFFLAG3
		MASK	FFFLAGS
		CCS	A
		TC	U24,6624

		CS	FFFLAGS
		MASK	FFFLAG8
		CCS	A
		TC	DOMID13 +1
		TC	U24,6747

DOMID17		TC	PHASCHNG
		OCT	01701
		TC	ENDMID
		TC	MIDSTCHK
REMID17		TC	+1

DOMID20		TC	PHASCHNG
		OCT	02001
		TC	ENDMID
		TC	MIDSTCHK

REMID20		CAF	ZERO		## Prepare to take NUMBOPT marks
		AD	NUMBOPT
		TC	BANKCALL
		CADR	SXTMARK

		TC	BANKCALL
		CADR	OPTSTALL
		TC	ENDMID

		INDEX	MARKSTAT	## Did we take any marks?
		CCS	QPRET
		TC	+2		## Yes, continue with A = (num marks - 1)
		TC	ENDMID		## No, end MNG.

		TS	NUMBOPT		## NUMBOPT = (num marks - 1)
		CCS	A		## Did we take more than one mark?
		TC	GOTMARKS	## Yes, go to GOTMARKS

		CAF	LOW3		## No, only one mark was taken.
		MASK	SITENUMB
		EXTEND
		SU	FOUR
		CCS	A		## Is the last digit of SITENUMB > 4?
		TC	ENDMID		## Yes, end MNG.
FFFLAG6		OCT	00040
		TC	+1		## No, continue into GOTMARKS.

GOTMARKS	TC	INTPRET

		LXC,1	0		## Put the address of the VAC area containing
			MARKSTAT	## the marks into X1

		DMOVE*	1
		DMP	TSLT
			0,1		## Extract the time of the first mark
			SCLTAVMD	## Convert it to weeks
			3
		STORE	TDEC		## ... and save it in TDEC.

		EXIT	0

		CAF	LOW3		## Is SITENUMB > 3?
		MASK	SITENUMB
		EXTEND
		SU	THREE
		CCS	A
		TC	U24,6736	## Yes, go to U24,6736.
FFFLAG11	OCT	02000
		TC	+1		## No, SITENUMB is <= 3.
		TC	INTPRET

		SMOVE*	1
		RTB	RTB
			5,1		## Extract OPTY (trunnion angle) of mark.
			CDULOGIC
			TRUNLOG		## Convert to DP revolutions.
		STORE	MEASQ		## Save as MEASQ (??)

		EXIT	0

		TC	+5

U24,6736	TC	INTPRET
		ITC	0
			U24,7165	## Get unit vector of mark in reference
		EXIT	0

		TC	FFFLGUP		## Put up flag 7
FFFLAG7		OCT	00100

U24,6744	TC	FFFLGDWN	## Take down flag 5
		OCT	00020

		TC	DOMID12

U24,6747	TC	INTPRET
		LXC,1	1
		VMOVE*
			MARKSTAT
			0,1
		STORE	VECTAB

		TEST	1
		SWITCH
			FIRSTFLG
			+2
			FIRSTFLG

DOMID13		EXIT	0

		TC	PHASCHNG
		OCT	01301
		TC	ENDMID
		TC	MIDSTCHK
		TC	U24,7012

REMID13		CAF	ZERO
		TS	NUMBOPT

		CS	FFFLAGS
		MASK	FFFLAG8
		CCS	A
		TC	U24,7012

		CS	FFFLAG13
		MASK	FFFLAGS
		CCS	A
		TC	U24,7012

		CAF	LOW3
		MASK	SITENUMB
		EXTEND
		SU	FOUR
		CCS	A
		TC	ENDMID
FFFLAG8		OCT	00200
		TC	+1

U24,7012	TC	INTPRET

		TEST	1
		ITC
			FIRSTFLG
			U31,6426	## In B-VECTOR
			U31,7236	## In B-VECTOR

DOMID14		EXIT	0

		TC	PHASCHNG
		OCT	01401
		TC	+4
		TC	+3

REMID14		CAF	ZERO
		TS	NUMBOPT

		TC	SAVEREF

		TC	INTPRET
		LXA,1	1
		SXA,1
			NUMBOPT
			NUMBTEMP

		TEST	1
		ITC
			FIRSTFLG
			DOMID15
			DOMID13

DOMID15		EXIT	0		## Change phase to 15.

		TC	PHASCHNG
		OCT	01501
		TC	ENDMID
		TC	MIDSTCHK

		TC	MIDGRAB
		TC	+3

REMID15		CAF	ZERO		## Zero NUMBTEMP on a restart.
		TS	NUMBTEMP

		CS	VB06N33		## Display calculated time
		TS	NVCODE
		TC	MIDDISP

		TC	INTPRET

		RTB	0
			FRESHPD

		DMOVE	1		## Calculate latitude and longitude
		ITC
			TET
			LAT-LONG

		ITC	0		## Calculate azimuth (leaves position in
			CALCAZ		## ALPHAV and velocity in BETAV)

		DMOVE	1		## Display lat, long, az
		RTB
			LAT
			1STO2S
		STORE	THETAD

		DMOVE	1
		RTB
			LONG
			1STO2S
		STORE	THETAD +1

		DMOVE	1
		RTB
			AZ
			1STO2S
		STORE	THETAD +2

		EXIT	0

		CS	VB06N22
		TS	NVCODE
		TC	MIDDISP

		TC	INTPRET		## Display position

		VMOVE	0
			ALPHAV
		STORE	DSPTEM1

		EXIT	0

		CS	VB06N76
		TS	NVCODE
		TC	MIDDISP

		TC	INTPRET		## Display velocity

		VMOVE	0
			BETAV
		STORE	DSPTEM1

		EXIT	0

		CS	VB06N77
		TS	NVCODE
		TC	MIDDISP

		CCS	NUMBTEMP	## Is NUMBTEMP positive?
		TC	+2		## Yes: continue on.
		TC	ENDMID		## No: end MNG.
		TS	NUMBOPT		## NUMBOPT = NUMBTEMP - 1

		INDEX	MARKSTAT
		CS	QPRET
		AD	NUMBTEMP	## A = (total # marks - NUMBTEMP)
		DOUBLE
		DOUBLE
		DOUBLE
		EXTEND
		MP	7/8		## Use A to calucate offset of next mark
		EXTEND
		SU	MARKSTAT	## Calculate full base address of next mark
		INDEX	FIXLOC
		TS	X1		## Store it in X1

		TC	INTPRET

		DMOVE*	1		## Convert time of new mark to weeks
		DMP	TSLT
			0,1
			SCLTAVMD
			3
		STORE	TDEC		## ... and store it in TDEC.

		ITC	0
			U24,7165	## Get unit vector of mark in reference

		EXIT	0

		TC	U24,6744

U24,7165	ITA	0		## Function to get unit vector of mark in reference
			MIDEXIT

		RTB	0
			FRESHPD

		ITC	0		## Transform angles into a star half unit vector in STARM
			SXTNB

		RTB	0
			FRESHPD

		VMOVE	2
		LXC,2	INCR,2
		SXA,2	ITC
			STARM
			X1		## Calculate the base address of the CDU readings
			2		## and store it into S1
			S1
			NBSM		## Transform the STARM half unit vector into SM coordinates

		LXC,1	0		## Reload X1 with the address of the mark VAC area, since
			MARKSTAT	## it got clobbered by NBSM

		NOLOD	1
		VXM	VSLT		## Finally, transform the vector into reference
			REFSMMAT
			1
		STORE	0,1		## and store it into the mark VAC area, overwriting the mark

		ITCI	0
			MIDEXIT

SAVEREF		XCH	Q
		TS	MIDEXIT

		CAF	DEC41
 +3		TS	NORMGAM

		CAF	ZERO
		INDEX	NORMGAM
		AD	RRECT
		INDEX	NORMGAM
		TS	REFRRECT
		CCS	NORMGAM
		TC	SAVEREF +3
		TC	MIDEXIT

LOADREF		XCH	Q
		TS	MIDEXIT

		CAF	DEC41
 +3		TS	NORMGAM

		CAF	ZERO
		INDEX	NORMGAM
		AD	REFRRECT
		INDEX	NORMGAM
		TS	RRECT

		CCS	NORMGAM
		TC	LOADREF +3

		TC	MIDEXIT

MIDDISP		XCH	Q
		TS	DSPRTRN

		CS	NVCODE
		TC	NVSUB
		TC	PRENVBSY
		TC	BANKCALL
		CADR	FLASHON
		TC	ENDIDLE
		TC	ENDMID
		TC	+2
		TC	ENDMID

		CS	-PHASE1
		TS	MPAC
		TC	MIDSTCHK
		TC	DSPRTRN

U24,7265	TC	MIDDISP		## Called from B-Vector

		TC	INTPRET
		ITC	0
			INCORP2

STARTMID	CAF	PRIO5
		TC	FINDVAC
		CADR	STRTMID2

		TC	FFFLGDWN
		OCT	00001

		TC	SWRETURN

MIDSTCHK	CS	EIGHT
		AD	MPAC
		CCS	A
		TC	Q		## If last phase was >8, return to caller
		TC	MIDMANPH	## In all other cases, go to MIDMANPH
		TC	MIDMANPH
		TC	MIDMANPH

MIDGO		CAF	PRIO5
		TC	FINDVAC
		CADR	MIDRSTRT

		TC	SWRETURN

MIDRSTRT	CS	-PHASE1
		TS	MPAC
		TC	MIDSTCHK

		CS	MIDMAXPH
		AD	MPAC
		CCS	A
		TC	ENDMID
MIDMAXPH	OCT	20
		TC	MIDGOFAN
		TC	REMID20

MIDGOFAN	INDEX	A
		TC	+1
		TC	REMID17
		TC	REMID16
		TC	REMID15
		TC	REMID14
		TC	REMID13
		TC	REMID12
		TC	REMID11

7/8		DEC	.875
DEC41		DEC	41
DT/2MIN		2DEC	.000006
DT/2MAX		2DEC	.65027077 B-1	# .075 HOUR MAXIMUM TIME STEP
BITS4-9		OCT	00770
BITS1-14	OCT	37777

SITEADR		ADRES	SITENUMB

VB21N32		OCT	02132
VB21N02		OCT	02102
VB25N72		OCT	02572
V21N32		OCT	02132
VB21N34		OCT	02134
V21N34		OCT	02134
VB06N33		OCT	00633
VB06N22		OCT	00622
VB06N76		OCT	00676
VB06N77		OCT	00677
VB24N57		OCT	02457


LNDMKTAB	2DEC	-2553.22974 B-14
		2DEC	5158.82031 B-14
		2DEC	2734.73669 B-14

		2DEC	-4293.65051 B-14
		2DEC	-4154.07935 B-14
		2DEC	-2217.96826 B-14

		2DEC	6037.67133 B-14
		2DEC	-1812.06616 B-14
		2DEC	-934.95160 B-14

U24,7403	2DEC	.5
		2DEC	0
		2DEC	0

		2DEC	0
		2DEC	.5
		2DEC	0

		2DEC	-.5
		2DEC	0
		2DEC	0

		2DEC	0
		2DEC	-.5
		2DEC	0

RINIT		2DEC	-4139.10016 B-14 # KILOMETERS.
		2DEC	3670.78546 B-14
		2DEC	3531.40400 B-14

VINIT		2DEC	-8.06483108 E-3 B6 # METERS PER SECOND SCALED SQRT(MU).
		2DEC	-9.34873597 E-3 B6
		2DEC	0.264806265 E-3 B6
