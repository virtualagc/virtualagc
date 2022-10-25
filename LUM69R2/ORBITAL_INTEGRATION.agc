### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ORBITAL_INTEGRATION.agc
## Purpose:     A section of LUM69 revision 2.
##              It is part of the reconstructed source code for the flown
##              version of the flight software for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 10. The code has
##              been recreated from a copy of Luminary revsion 069, using
##              changes present in Luminary 099 which were described in
##              Luminary memos 75 and 78. The code has been adapted such
##              that the resulting bugger words exactly match those specified
##              for LUM69 revision 2 in NASA drawing 2021152B, which gives
##              relatively high confidence that the reconstruction is correct.
## Reference:   pp. 1223-1243
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.
##              2019-07-27 MAS  Backported R-2 lunar potential model code from
##                              Luminary 099, and positioned it such that the
##                              resulting banksums are correct.
##		2020-12-14 RSB	Tweaked the annotation relevant to the
##				change mentioned above to conform to the
##				style and extent of similar justifying
##				annotations previously added to 
##				Comanche 44 and 51.  For explanatory purposes,
##				however, I found it easier in this file to 
##				dispense with Mike's approach of using Luminary 69
##				as a baseline, and instead to use Luminary 99/1 as
##				a baseline.  There is no difference in the 
##				reconstructed code itself, of course, but the 
##				##-style page-number comments all change over
##				to Luminary 99/1 numbering rather than 
##				Luminary 69 numbering.  Given that it is already
##				known that the page numbers between Luminary 69
##				and Luminary 69/2 shouldn't agree, that seems
##				like a minor price to pay.

## Page 1227

## <b>Reconstruction:</b> As described by 
## <a href="http://www.ibiblio.org/apollo/Documents/LUM75_text.pdf">
## LUMINARY Memo #75"</a>, the entire purpose for creating Luminary 69/2
## was to add the R-2 Lunar Potential Model to Luminary 69.  Manually
## comparing Luminary 69 to Luminary 99/1 (which also incorporates the 
## R-2 model) quickly makes it clear that most of the R-2 implementation
## occurs in the ORBITAL INTEGRATION log section, and that the changes
## within the ORBITAL INTEGRATION log section are extensive.
## <br><br>
## In point of fact, there is much less difference between ORBITAL INTEGRATION
## in Luminary 69/2 and Luminary 99/1 than there is between Luminary 69/2 and
## Luminary 69.  Therefore, to simplify our justifying annotations, in this 
## single log section we use Luminary 99/1 as a baseline rather than Luminary 69.
## We add explanatory annotations only at the differences between the Luminary 69/2
## code and the Luminary 99/1 code.  Page numbers follow Luminary 99/1 rather than
## Luminary 69.
## <br><br>
## Incidentally, that is <i>not</i> the approach originally taken when this log
## section was reconstructed.  Then, Luminary 69 was still used as a baseline.
## So reconstruction is possible using either baseline &mdash; but the Luminary 99/1
## baseline is simply easier to explain on a change-by-change basis.

# DELETE
		BANK	13
		SETLOC	ORBITAL
		BANK
		COUNT*	$$/ORBIT

# DELETE
KEPPREP		LXA,2	SETPD
			PBODY
			0
		DLOAD*	SQRT		# SQRT(MU) (+18 OR +15)		0D	PL 2D
			MUEARTH,2
		PDVL	UNIT		#					PL 8D
			RCV
		PDDL	NORM		# NORM R (+29 OR +27 - N1)	2D	PL 4D
			36D
			X1
		PDVL
		DOT	PDDL		# F*SQRT(MU) (+7 OR +5) 	4D	PL 6D
			VCV
			TAU.		# (+28)
		DSU	NORM
			TC
			S1
		SR1
		DDV	PDDL
			2D
		DMP	PUSH		# FS (+6 +N1-N2) 		6D	PL 8D
			4D
		DSQ	PDDL		# (FS)SQ (+12 +2(N1-N2))	8D	PL 10D
			4D
		DSQ	PDDL*		# SSQ/MU (-2 OR +2(N1-N2))	10D	PL 12D
			MUEARTH,2
		SR3	SR4
		PDVL	VSQ		# PREALIGN MU (+43 OR +37) 	12D	PL 14D
			VCV
		DMP	BDSU		#					PL 12D
			36D
		DDV	DMP		#					PL 10D
			2D		# -(1/R-ALPHA) (+12 +3N1-2N2)
		DMP	SL*
			DP2/3
			0 	-3,1	# 10L(1/R-ALPHA) (+13 +2(N1-N2))
		XSU,1	DAD		# 2(FS)SQ - ETCETRA			PL 8D
			S1		# X1 = N2-N1
		SL*	DSU		# -FS+2(FS)SQ ETC (+6 +N1-N2)		PL 6D
			8D,1
		DMP	DMP
			0D
			4D
		SL*	SL*
## Page 1228
			8D,1
			0,1		# S(-FS(1-2FS)-1/6...) (+17 OR +16)
		DAD	PDDL		#					PL 6D
			XKEP
		DMP	SL*		# S(+17 OR +16)
			0D
			1,1
		BOVB	DAD
			TCDANZIG
		STADR
		STORE	XKEPNEW
		STQ	AXC,1
			KEPRTN
		DEC	10
		BON	AXC,1
			MOONFLAG
			KEPLERN
		DEC	2
		GOTO
			KEPLERN

## Page 1229
FBR3		LXA,1	SSP
			DIFEQCNT
			S1
		DEC	-13
		DLOAD	SR
			DT/2
			9D
		TIX,1	ROUND
			+1
		PUSH	DAD
			TC
		STODL	TAU.
		DAD
			TET
		STCALL	TET
			KEPPREP

## Page 1230
# AGC ROUTINE TO COMPUTE ACCELERATION COMPONENTS.

ACCOMP		LXA,1	LXA,2
			PBODY
			PBODY
		VLOAD
			ZEROVEC
		STOVL	FV
			ALPHAV
		VSL*	VAD
			0 	-7,2
			RCV
		STORE	BETAV
		BOF	XCHX,2
			DIM0FLAG
			+5
			DIFEQCNT
		STORE	VECTAB,2
		XCHX,2
			DIFEQCNT
		VLOAD	UNIT
			ALPHAV
		STODL	ALPHAV
			36D
		STORE	ALPHAM
		CALL
			GAMCOMP
		VLOAD	SXA,1
			BETAV
			S2
		STODL	ALPHAV
			BETAM
		STORE	ALPHAM
		BOF	DLOAD
			MIDFLAG
			OBLATE
			TET
		CALL
			LSPOS
		AXT,2	LXA,1
			2
			S2
		BOF
			MOONFLAG
			+3
		VCOMP	AXT,2
			0
		STORE	BETAV
		STOVL	RPQV
## Page 1231
			2D
		STORE	RPSV
		SLOAD	DSU
			MODREG
			OCT27
		BHIZ	BOF
			+3
			DIM0FLAG
			GETRPSV
		VLOAD	VXSC
			ALPHAV
			ALPHAM
		VSR*	VSU
			1,2
			BETAV
		XCHX,2
			DIFEQCNT
		STORE	VECTAB 	+6,2
		STORE	RQVV
		XCHX,2
			DIFEQCNT
GETRPSV		VLOAD	INCR,1
			RPQV
			4
		CLEAR	BOF
			RPQFLAG
			MOONFLAG
			+5
		VSR	VAD
			9D
			RPSV
		STORE	RPSV
		CALL
			GAMCOMP
		AXT,2	INCR,1
			4
			4
		VLOAD
			RPSV
		STCALL	BETAV
			GAMCOMP
		GOTO
			OBLATE
GAMCOMP		VLOAD	VSR1
			BETAV
		VSQ	SETPD
			0
		NORM	ROUND
			31D
		PDDL	NORM		# NORMED B SQUARED TO PD LIST
## Page 1232		
			ALPHAM		# NORMALIZE (LESS ONE) LENGTH OF ALPHA
			32D		# SAVING NORM SCALE FACTOR IN X1
		SR1	PDVL
			BETAV		# C(PDL+2) = ALMOST NORMED ALPHA
		UNIT
		STODL	BETAV
			36D
		STORE	BETAM
		NORM	BDDV		# FORM NORMALIZED QUOTIENT ALPHAM/BETAM
			33D
		SR1R	PUSH		# C(PDL+2) = ALMOST NORMALIZED RHO.
		DLOAD*
			ASCALE,1
		STORE	S1
		XCHX,2	XAD,2
			S1
			32D
		XSU,2	DLOAD
			33D
			2D
		SR*	XCHX,2
			0 	-1,2
			S1
		PUSH	SR1R		# RHO/4 TO 4D
		PDVL	DOT
			ALPHAV
			BETAV
		SL1R	BDSU		# (RHO/4) - 2(ALPHAV/2.BETAV/2)
		PUSH	DMPR		# TO PDL+6
			4
		SL1
		PUSH	DAD
			DQUARTER
		PUSH	SQRT
		DMPR	PUSH
			10D
		SL1	DAD
			DQUARTER
		PDDL	DAD		# (1/4)+2((Q+1)/4)	TO PD+14D
			10D
			HALFDP
		DMPR	SL1
			8D
		DAD	DDV
			THREE/8
			14D
		DMPR	VXSC
			6
			BETAV		#		-
		PDVL	VSR3		# (G/2)(C(PD+4))B/2 TO PD+16D
## Page 1233
			ALPHAV
		VAD	PUSH		# A12 + C(PD+16D) TO PD+16D
		DLOAD	DMP
			0
			12D
		NORM	ROUND
			30D
		BDDV	DMP*
			2
			MUEARTH,2
		DCOMP	VXSC
		XCHX,2	XAD,2
			S1
			S2
		XSU,2	XSU,2
			30D
			31D
		BOV			# CLEAR OVIND
			+1
		VSR*	XCHX,2
			0	-1,2
			S1
		VAD
			FV
		STORE	FV
		BOV	RVQ		# RETURN IF NO OVERFLOW
			+1
## <b>Reconstruction:</b> At this point in Luminary 99/1, we would find the code sequence<br>
## <pre>
##    GOBAQUE         VLOAD     ABVAL
##                              DELTAV
##                    BZE
##                              INT-ABRT
##                    DLOAD     SR
## </pre>
## That's replaced in Luminary 69/2 by the single instruction following this annotation.
## This particular change is due to a change in Luminary 99/1 that's unrelated to the 
## R-2 model.  Instead, this change is due to
## <a href="http://www.ibiblio.org/apollo/Documents/LUM67_text.pdf">LUMINARY Memo #67,
## "LUMINARY Revisions 70-79"</a>, and in particular to a change incorporated in 
## Luminary 79.  The memo describes this change as "PCR 720 was implemented. (Abort 
## coasting integration when in infinite acceleration overflow loop). This change added 
## the new POODOO code 430".  In particular, the code checks to see if |TDELTAV|=0, and
## then jumps to INT-ABRT (see next annotation), and thus to POODOO if so.
GOBAQUE		DLOAD	SR
			H
			9D
		PUSH	BDSU
			TC
		STODL	TAU.
			TET
		DSU	STADR
		STCALL	TET
			KEPPREP
		CALL
			RECTIFY
		SETGO
			RPQFLAG
			TESTLOOP

## <b>Reconstruction:</b> At this point in Luminary 99/1, we would find the code sequence<br>
## <pre>
##    INT-ABRT        EXIT
##                    TC      POODOO
##                    OCT     00430
## </pre>
## This code provides the end of the code sequence described in the preceding annotation above,
## and as such is simply omitted in Luminary 69/2.

## Page 1234
# THE OBLATE ROUTINE COMPUTES THE ACCELERATION DUE TO OBLATENESS.  IT USES THE UNIT OF THE VEHICLE
# POSITION VECTOR FOUND IN ALPHAV AND THE DISTANCE TO THE CENTER IN ALPHAM.  THIS IS ADDED TO THE SUM OF THE
# DISTURBING ACCELERATIONS IN FV AND THE PROPER DIFEQ STAGE IS CALLED VIA X1.

OBLATE		LXA,2	DLOAD
			PBODY
			ALPHAM
		SETPD	DSU*
			0
			RDE,2
		BPL	BOF		# GET URPV
			NBRANCH
			MOONFLAG
			COSPHIE
		VLOAD	PDDL
			ALPHAV
			TET
		PDDL	CALL
			3/5
			R-TO-RP
		STORE	URPV
		VLOAD	VXV
			504LM
			ZUNIT
		VAD	VXM
			ZUNIT
			MMATRIX
		UNIT			# POSSIBLY UNNECESSARY
COMTERM		STORE	UZ
		DLOAD	DMPR
			COSPHI/2
			3/32
		PDDL	DSQ		# P2/64 TO PD0
			COSPHI/2
		DMPR	DSU
			15/16
			3/64
		PUSH	DMPR		# P3/32 TO PD2
			COSPHI/2
		DMP	SL1R
			7/12
		PDDL	DMPR
			0
			2/3
		BDSU	PUSH		# P4/128 TO PD4
		DMPR	DMPR
			COSPHI/2	# BEGIN COMPUTING P5/1024
			9/16
		PDDL	DMPR
			2
			5/128
## Page 1235
		BDSU
		DMP*
			J4REQ/J3,2
		DDV	DAD		#	       -3
			ALPHAM		# (((P5/256)B 2  /R+P4/32)  /R+P3/8)ALPHAV
			4		#	     4		   3
		DMPR*	DDV
			2J3RE/J2,2
			ALPHAM
		DAD	VXSC
			2
			ALPHAV
		STODL	TVEC
		DMP*	SR1
			J4REQ/J3,2
		DDV	DAD
			ALPHAM		#               -3
		DMPR*	SR3
			2J3RE/J2,2	#    3        4
		DDV	DAD
			ALPHAM
		VXSC	VSL1
			UZ
		BVSU
			TVEC
		STODL	TVEC
			ALPHAM
		NORM	DSQ
			X1
		DSQ	NORM
			S1		#	  4
		PUSH	BDDV*		# NORMED R  TO 0D
			J2REQSQ,2
		VXSC	BOV
			TVEC
			+1		# (RESET OVERFLOW INDICATOR)
		XAD,1	XAD,1
			X1
			X1
		XAD,1	VSL*
			S1
			0 -22D,1
		VAD	BOV
			FV
			GOBAQUE
		STCALL	FV
			QUALITY1	
			
QUALITY3	DSQ			# J22 TERM X R**4 IN 2D, SCALED B61
					# AS VECTOR.
## Page 1236
		PUSH	DMP		# STORE COSPHI**2 SCALED B2 IN 8D
			5/8		# 5 SCALED B3
		PDDL	SR2		# PUT 5 COSPHI**2, D5, IN 8D.  GET
					# COSPHI**2 D2 FROM 8D
		DAD	BDSU		# END UP WITH (1-7 COSPHI**2), B5
			8D		# ADDING COSPHI**2 B4 SAME AS COSPHI**2
					# X 2 D5
			D1/32		# 1 SCALED B5
		DMP	DMP
			URPV		# X COMPONENT
			5/8		# 5 SCALED B3
		VXSC	VSL5		# AFTER SHIFT, SCALED B5
			URPV		# VECTOR, B1.
		PDDL			# VECTOR INTO 8D, 10D, 12D, SCALED B5.
					# GET 5 COSPHI**2 OUT OF 8D
		DSU	DAD
			D1/32		# 1 B5
			8D		# X COMPONENT (SAME AS MULTIPLYING
					# BY UNITX)
		STODL	8D
			URPV		# X COMPONENT
		DMP	DMP
			URPV	+4	# Z COMPONENT
			5/8		# 5 B3 ANSWER B5
		SL1	DAD		# FROM 12D FOR Z COMPONENT (SL1 GIVES 10
					# INSTEAD OF 5 FOR COEFFICIENT)
		PDDL	NORM		# BACK INTO 12D FOR Z COMPONENT.
			ALPHAM		# SCALED B27 FOR MOON
			X2
		PUSH	SLOAD		# STORE IN 14D, DESTROYING URPV
					# X COMPONENT
			E32C31RM
		DDV	VXSC		# IF X2 = 0, DIVISION GIVES B53, VXSC
					# OUT OF 8D B5 GIVES B58
		VSL*	VAD		# SHIFT MAKES B61, FOR ADDITION OF 
					# VECTOR IN 2D
			0	-3,2
		VSL*	V/SC		# OPERAND FROM 0D, B108 FOR X1 = 0
			0	-27D,1	# FOR X1 = 0, MAKES B88, GIVING B-20
					# FOR RESULT.
		PDDL	PDDL
			TET
			5/8		# ANY NON-ZERO CONSTANT
		LXA,2	CALL		# POSITION IN 0D, TIME IN 6D.  X2 LEFT
					# ALONE.
			PBODY
			RP-TO-R
		VAD	BOV		# OVERFLOW INDICATOR RESET IN "RP-TO-R"
			FV
			GOBAQUE
## Page 1237			
		STORE	FV
NBRANCH		SLOAD	LXA,1
			DIFEQCNT
			MPAC
		DMP	CGOTO
			-1/12
			MPAC
			DIFEQTAB
COSPHIE		DLOAD
			ALPHAV 	+4
		STOVL	COSPHI/2
			ZUNIT
		GOTO
			COMTERM
DIFEQTAB	CADR	DIFEQ+0
		CADR	DIFEQ+1
		CADR	DIFEQ+2
TIMESTEP	BOF	VLOAD
			MIDFLAG
			RECTEST
			RCV
		DOT	DMP
			VCV
			DT/2		# (R.V) X (DELTA T)
		BMN
			RECTEST
		BON	BOF
			MOONFLAG
			LUNSPH
			RPQFLAG
			EARSPH
		DLOAD	CALL
			TET
			LSPOS		# RPQV IN MPAC
		STORE	RPQV		# RPQV
		LXA,2
			PBODY
INLUNCHK	BVSU	ABVAL
			RCV
		DSU	BMN
			RSPHERE
			DOSWITCH
RECTEST		VLOAD	ABVAL		# RECTIFY IF
			TDELTAV
		BOV
			CALLRECT
		DSU	BPL		#	1) EITHER TDELTAV OR TNUV EQUALS OR
			3/4		#	   EXCEEDS 3/4 IN MAGNITUDE
			CALLRECT	#
		DAD	SL*		#			OR
## Page 1238
			3/4		#
			0 	-7,2	#	2) ABVAL(TDELTAV) EQUALS OR EXCEEDS
		DDV	DSU		#	   .01(ABVAL(RCV))
			10D
			RECRATIO
		BPL	VLOAD
			CALLRECT
			TNUV
		ABVAL	DSU
			3/4
		BOV
			CALLRECT
		BMN
			INTGRATE
CALLRECT	CALL
			RECTIFY
INTGRATE	VLOAD
			TNUV
		STOVL	ZV
			TDELTAV
		STORE	YV
		CLEAR
			JSWITCH
DIFEQ0		VLOAD	SSP
			YV
			DIFEQCNT
			0
		STODL	ALPHAV
			DPZERO
		STORE	H		# START H AT ZERO.  GOES 0(DELT/2)DELT.
		BON	GOTO
			JSWITCH
			DOW..
			ACCOMP
EARSPH		VLOAD	GOTO
			RPQV
			INLUNCHK
LUNSPH		DLOAD	SR2
			10D
		DSU	BMN
			RSPHERE
			RECTEST
		BOF	DLOAD
			RPQFLAG
			DOSWITCH
			TET
		CALL
			LUNPOS
		VCOMP
		STORE	RPQV
## Page 1239		
DOSWITCH	CALL
			ORIGCHNG
		GOTO
			INTGRATE
ORIGCHNG	STQ	CALL
			ORIGEX
			RECTIFY
		VLOAD	VSL*
			RCV
			0,2
		VSU	VSL*
			RPQV
			2,2
		STORE	RRECT
		STODL	RCV
			TET
		CALL
			LUNVEL
		BOF	VCOMP
			MOONFLAG
			+1
		PDVL	VSL*
			VCV
			0,2
		VSU
		VSL*
			0 	+2,2
		STORE	VRECT
		STORE	VCV
		LXA,2	SXA,2
			ORIGEX
			QPRET
		BON	GOTO
			MOONFLAG
			CLRMOON
			SETMOON
## Page 1240
# THE RECTIFY SUBROUTINE IS CALLED BY THE INTEGRATION PROGRAM AND OCCASIONALLY BY THE MEASUREMENT INCORPORATION
# ROUTINES TO ESTABLISH A NEW CONIC.

RECTIFY		LXA,2	VLOAD
			PBODY
			TDELTAV
		VSL*	VAD
			0 	-7,2
			RCV
		STORE	RRECT
		STOVL	RCV
			TNUV
		VSL*	VAD
			0 	-4,2
			VCV
MINIRECT	STORE	VRECT
		STOVL	VCV
			ZEROVEC
		STORE	TDELTAV
		STODL	TNUV
			ZEROVEC
		STORE	TC
		STORE	XKEP
		RVQ

## Page 1241
# THE THREE DIFEQ ROUTINES - DIFEQ+0, DIFEQ+12, AND DIFEQ+24 - ARE ENTERED TO PROCESS THE CONTRIBUTIONS AT THE
# BEGINNING, MIDDLE, AND END OF THE TIMESTEP, RESPECTIVELY.  THE UPDATING IS DONE BY THE NYSTROM METHOD.

DIFEQ+0		VLOAD	VSR3
			FV
		STCALL	PHIV
			DIFEQCOM
DIFEQ+1		VLOAD	VSR1
			FV
		PUSH	VAD
			PHIV
		STOVL	PSIV
		VSR1	VAD
			PHIV
		STCALL	PHIV
			DIFEQCOM
DIFEQ+2		DLOAD	DMPR
			H
			DP2/3
		PUSH	VXSC
			PHIV
		VSL1	VAD
			ZV
		VXSC	VAD
			H
			YV
		STOVL	YV
			FV
		VSR3	VAD
			PSIV
		VXSC	VSL1
		VAD
			ZV
		STORE	ZV
		BOFF	CALL
			JSWITCH
			ENDSTATE
			GRP2PC
		LXA,2	VLOAD
			COLREG
			ZV
		VSL3			# ADJUST W-POSITION FOR STORAGE
		STORE	W 	+54D,2
		VLOAD
			YV
		VSL3	BOV
			WMATEND
		STORE	W,2

		CALL
			GRP2PC
## Page 1242
		LXA,2	SSP
			COLREG
			S2
			0
		INCR,2	SXA,2
			6
			YV
		TIX,2	CALL
			RELOADSV
			GRP2PC
		LXA,2	SXA,2
			YV
			COLREG

NEXTCOL		CALL
			GRP2PC
		LXA,2	VLOAD*
			COLREG
			W,2
		VSR3			# ADJUST W-POSITION FOR INTEGRATION
		STORE	YV
		VLOAD*	AXT,1
			W 	+54D,2
			0
		VSR3			# ADJUST W-VELOCITY FOR INTEGRATION
		STCALL	ZV
			DIFEQ0

ENDSTATE	BOV	VLOAD
			GOBAQUE
			ZV
		STOVL	TNUV
			YV
		STORE	TDELTAV
		BON	BOFF
			MIDAVFLG
			CKMID2		# CHECK FOR MID2 BEFORE GOING TO TIMEINC
			DIM0FLAG
			TESTLOOP
		EXIT
		TC	PHASCHNG
		OCT	04022		# PHASE 1
		TC	UPFLAG		# PHASE CHANGE HAS OCCURRED BETWEEN
		ADRES	REINTFLG	# INTSTALL AND INTWAKE
		TC	INTPRET
		SSP
			QPRET
			AMOVED
		BON	GOTO
			VINTFLAG
## Page 1243
			ATOPCSM
			ATOPLEM
AMOVED		SET	SSP
			JSWITCH
			COLREG
		DEC	-30
		BOFF	SSP
			D6OR9FLG
			NEXTCOL
			COLREG
		DEC	-48
		GOTO
			NEXTCOL

RELOADSV	DLOAD			# RELOAD TEMPORARY STATE VECTOR
			TDEC		# FROM PERMANENT IN CASE OF
		STCALL	TDEC1
			INTEGRV2	# BY STARTING AT INTEGRV2.
DIFEQCOM	DLOAD	DAD		# INCREMENT H AND DIFEQCNT.
			DT/2
			H
		INCR,1	SXA,1
		DEC	-12
			DIFEQCNT	# DIFEQCNT SET FOR NEXT ENTRY.
		STORE	H
		VXSC	VSR1
			FV
		VAD	VXSC
			ZV
			H
		VAD
			YV
		STORE	ALPHAV
		BON	GOTO
			JSWITCH
			DOW..
			FBR3

WMATEND		CLEAR	CLEAR
			DIM0FLAG	# DONT INTEGRATE W THIS TIME
			ORBWFLAG	# INVALIDATE W
		CLEAR
			RENDWFLG
		SET	EXIT
			STATEFLG	# PICK UP STATE VECTOR UPDATE
		TC	ALARM
		OCT	421
		TC	INTPRET
## Page 1244
		GOTO
			TESTLOOP	# FINISH INTEGRATING STATE VECTOR

## Page 1245
# ORBITAL ROUTINE FOR EXTRAPOLATION OF THE W MATRIX.  IT COMPUTES THE SECOND DERIVATIVE OF EACH COLUMN POSITION
# VECTOR OF THE MATRIX AND CALLS THE NYSTROM INTEGRATION ROUTINES TO SOLVE THE DIFFERENTIAL EQUATIONS.  THE PROGRAM
# USES A TABLE OF VEHICLE POSITION VECTORS COMPUTED DURING THE INTEGRATION OF THE VEHICLES POSITION AND VELOCITY.

DOW..		LXA,2	DLOAD*
			PBODY
			MUEARTH,2
		STCALL	BETAM
			DOW..1
		STORE	FV
		BOF	INCR,1
			MIDFLAG
			NBRANCH
		DEC	-6
		LXC,2	DLOAD*
			PBODY
			MUEARTH -2,2
		STCALL	BETAM
			DOW..1
		BON	VSR6
			MOONFLAG
			+1
		VAD
			FV
		STCALL	FV
			NBRANCH
DOW..1		VLOAD	VSR4
			ALPHAV
		PDVL*	UNIT
			VECTAB,1
		PDVL	VPROJ
			ALPHAV
		VXSC	VSU
			3/4
		PDDL	NORM
			36D
			S2
		PUSH	DSQ
		DMP
		NORM	PDDL
			34D
			BETAM
		SR1	DDV
		VXSC
		LXA,2	XAD,2
			S2
			S2
		XAD,2	XAD,2
			S2
			34D
		VSL*	RVQ
## Page 1246
			0 	-8D,2	

## <b>Reconstruction:</b> In Luminary 99/1 at this point, we would find the following code sequence:<br>
## <pre>
##    # ****************************************************************************************************************
##    # ****************************************************************************************************************
##    SETITCTR        SSP     BOFF        # SET ITERCTR FOR LAMBERT CALLS.  THIS
##                            ITERCTR     # CODING BELONGS IN INITVEL AND IS HERE
##                            20D         # FOR PURPOSES OF A ONE-MODULE
##                            AVEGFLAG    # REMANUFACTURE ONLY.  CODING SHOULD
##                            LAMBERT     # BE MOVED BACK TO INITVEL FOR LUMINARY 1B
##                    SSP     GOTO
##                            ITERCTR
##                            5
##                            LAMBERT
##    # ****************************************************************************************************************
##    # ****************************************************************************************************************
## </pre>
## Also, refer to
## <a href="http://www.ibiblio.org/apollo/Documents/LUM83_text.pdf">LUMINARY Memo #83, "LUMINARY Revision 98"</a>.
## As the function's own comments indicate, this should have been present for the very next memory-module manufacturing release.
## The most-recent manufacturing release at that point was Luminary 97 (in April 1969), and the next one would be Luminary 
## 99 (in May 1969).  (Those release dates are from
## <a href="http://www.ibiblio.org/apollo/Documents/R-700.pdf#page=170">
## <i>MIT's Role in Project Apollo, Final Report</i>, Table 4-II</a>.)  Naively, from the program comments, we'd conclude that
## the code should have been removed by the time of the Luminary 99/1 release.  However, as it turned out, Luminary 99/1 differed 
## from Luminary 99 in a single memory module, indeed in a single memory bank
## &mdash; not the one containing this code &mdash; so by leaving the code in place it meant that a single new memory module needed
## to be manufactured for Luminary 99/1; and the other 5 memory modules for Luminary 99/1 could be recycled from Luminary 99.
## <br><br>
## However interesting that may or may not be, the lesson we need to take away from it is that there would be no reason at
## all for this code to be present in Luminary 69/2.  Hence it has been removed.

		SETLOC	ORBITAL1
		BANK

3/5		2DEC	.6 B-2

THREE/8		2DEC	.375

.3D		2DEC	.3 B-2

3/64		2DEC	3 B-6

DP1/4		2DEC	.25

DQUARTER	EQUALS	DP1/4
POS1/4		EQUALS	DP1/4
3/32		2DEC	3 B-5

15/16		2DEC	15. B-4

3/4		2DEC	3.0 B-2

7/12		2DEC	.5833333333

9/16		2DEC	9 B-4

5/128		2DEC	5 B-7

DPZERO		EQUALS	ZEROVEC
DP2/3		2DEC	.6666666667

2/3		EQUALS	DP2/3
OCT27		OCT	27

## <b>Reconstruction:</b> Although otherwise using Luminary 99/1 as a baseline for the 
## reconstruction of the ORBITAL INTEGRATION log section, we noticed the 
## comment below which appears in Luminary 69 but not in Luminary 99/1.
## It seems reasonable to retain this comment.
# LM504 IS TEMPORARY

## Page 1247
		BANK	13
		SETLOC	ORBITAL2
		BANK
# IT IS VITAL THAT THE FOLLOWING CONSTANTS NOT BE SHUFFLED
		DEC	-11
		DEC	-2
		DEC	-9
		DEC	-6
		DEC	-2
		DEC	-2
		DEC	0
		DEC	-12
		DEC	-9
		DEC	-4
ASCALE		DEC	-7
		DEC	-6
5/8		2DEC	5 B-3

-1/12		2DEC	-.1

RECRATIO	2DEC	.01

RSPHERE		2DEC	64373.76 E3 B-29

RDM		2DEC	16093.44 E3 B-27

RDE		2DEC	80467.20 E3 B-29

RATT		EQUALS 	00
VATT		EQUALS	6D
TAT		EQUALS	12D
RATT1		EQUALS	14D
VATT1		EQUALS	20D
MU(P)		EQUALS	26D
TDEC1		EQUALS	32D
URPV		EQUALS	14D
COSPHI/2	EQUALS	URPV 	+4
UZ		EQUALS	20D
TVEC		EQUALS	26D

## <b>Reconstruction:</b> The two lines of code following this annotation 
## that switch to a different memory bank are found 
## neither in Luminary 99/1 nor in Luminary 69.  However, if the QUALITY1 and QUALITY2
## functions are not relocated to a different memory bank, you can expect memory-bank
## overflows during assembly, memory-bank checksum errors, and so on.  It is reasonable
## to expect that one or both of these functions may be relocated to other memory banks,
## because some other AGC programs incorporating the R-2 memory model do so. Comanche
## 55 (Apollo 11 CM) does so, for example; indeed, it not only switches memory banks, but
## removes the functions to a different log section (though retaining a comment that they
## are a part of the R-2 model).
		SETLOC	MODCHG1
		BANK
QUALITY1	BOF	DLOAD
			MOONFLAG
			NBRANCH
			URPV
		DSQ
QUALITY2	PDDL	DSQ		# SQUARE INTO 2D, B2
			URPV	+2	# Y COMPONENT, B1
		DSU
		DMP	VXSC		# 5(Y**2-X**2)UR
			5/8		# CONSTANT, 5B3
			URPV		# VECTOR.  RESULT MAXIMUM IS 5, SCALING
## Page 1248
					# HERE B6
		VSL3	PDDL		# STORE SCALED B3 IN 2D, 4D, 6D FOR XYZ
			URPV		# X COMPONENT, B1
		SR1	DAD		# 2 X X COMPONENT FOR B3 SCALING
			2D		# ADD TO VECTOR X COMPONENT OF ANSWER,
					# SAME AS MULTIPLYING BY UNITX.  MAX IS 7.
		STODL	2D
			URPV	+2	# Y COMPONENT, B1
		SR1	BDSU		# 2 X Y COMPONENT FOR B3 SCALING
			4D		# SUBTRACT FROM VECTOR Y COMPONENT OF
					# ANSWER, SAME AS MULTIPLYING BY UNITY.
					# MAX IS 7.
		STORE	4D		# 2D HAS VECTOR, B3.
		SLOAD	VXSC		# MULTIPLY COEFFIECIENT TIMES VECTOR IN 2D
			E3J22R2M
		PDDL	RVQ		# J22 TERM X R**4 IN 2D, SCALED B61
			COSPHI/2	# SAME AS URPV +4  Z COMPONENT
			
