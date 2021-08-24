### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P12.agc
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
## Reference:   pp. 838-842
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-28 MAS  Created from Luminary 99.

## Page 838
		BANK	24
		SETLOC	P12
		BANK

		EBANK=	DVCNTR
		COUNT*	$$/P12

P12LM		TC	PHASCHNG
		OCT	04024

		TC	BANKCALL
		CADR	R02BOTH		# CHECK THE STATUS OF THE IMU.
		
		TC	UPFLAG		
		ADRES	MUNFLAG
		
		TC	UPFLAG		# INSURE 4-JET TRANSLATION CAPABILITY.
		ADRES	ACC4-2FL
		
		TC	UPFLAG		# PREVENT R10 FROM ISSUING CROSS-POINTER
		ADRES	R10FLAG		# OUTPUTS.
		
		TC	CLRADMOD	# INITIALIZE RADMODES FOR R29.
		
		TC	DOWNFLAG	# CLEAR RENDEZVOUS FLAG  FOR P22
		ADRES	RNDVZFLG
		
		CAF	THRESH2		# INITIALIZE DVMON
		TS	DVTHRUSH
		CAF	FOUR
		TS	DVCNTR

		CA	ZERO
		TS	TRKMKCNT	# SHOW THAT R29 DOWNLINK DATA ISN'T READY.
		CAF	V06N33A
		TC	BANKCALL	# FLASH TIG
		CADR	GOFLASH
		TCF	GOTOPOOH
		TCF	+2		# PROCEED
		TCF	-5		# ENTER

		TC	PHASCHNG
		OCT	04024

		TC	INTPRET
		CALL			# INITIALIZE WM AND /LAND/
			GUIDINIT
		SET	CALL
			FLPI
			P12INIT
## Page 839
P12LMB		DLOAD
			(TGO)A		# SET TGO TO AN INITIAL NOMINAL VALUE.
		STODL	TGO
			TIG
		STCALL	TDEC1
			LEMPREC		# ROTATE THE STATE VECTORS TO THE
		VLOAD	MXV		# IGNITION TIME.
			VATT
			REFSMMAT
		VSL1
		STOVL	V1S		# COMPUTE V1S = VEL(TIG)*2(-7) M/CS.
			RATT
		MXV	VSL6
			REFSMMAT
		STCALL	R		# COMPUTE R = POS(TIG)*2(-24) M.
			MUNGRAV		# COMPUTE GDT1/2(TIG)*2(-7)M/CS.
		VLOAD	UNIT
			R
		STCALL	UNIT/R/		# COMPUTE UNIT/R/ FOR YCOMP.
			YCOMP
		SR	DCOMP
			5D
		STODL	XRANGE		# INITIALIZE XRANGE FOR NOUN 76.
			VINJNOM
		STODL	ZDOTD
			RDOTDNOM
		STORE	RDOTD
		EXIT

		TC	PHASCHNG
		OCT	04024

NEWLOAD		CAF	V06N76		# FLASH CROSS-RANGE AND APOLUNE VALUES.
		TC	BANKCALL
		CADR	GOFLASH
		TCF	GOTOPOOH
		TCF	+2		# PROCEED
		TCF	NEWLOAD		# ENTER NEW DATA.

		CAF	P12ADRES
		TS	WHICH

		TC	PHASCHNG
		OCT	04024

		TC	INTPRET
		DLOAD	SL
			XRANGE
			5D
		DAD
## Page 840
			Y
		STOVL	YCO
			UNIT/R/
		VXSC	VAD
			49FPS
			V1S
		STORE	V		# V(TIPOVER) = V(IGN) + 57FPS (UNIT/R/)
		DOT	SL1
			UNIT/R/
		STOVL	RDOT		# RDOT * 2(-7)
			UNIT/R/
		VXV	UNIT
			QAXIS
		STORE	ZAXIS1
		SETGO
			FLVR
			ASCENT
P12RET		DLOAD
			ATP		# ATP(2)*2(18)
		DSQ	PDDL
			ATY		# ATY(2)*2(18)
		DSQ	DAD
		BZE	SQRT
			YAWDUN
		SL1	BDDV
			ATY
		ARCSIN
YAWDUN		STOVL	YAW
			UNFC/2
		UNIT	DOT
			UNIT/R/
		SL1	ARCCOS
		DCOMP
		STORE	PITCH
		EXIT
		TC	PHASCHNG
		OCT	04024

		TC	DOWNFLAG
		ADRES	FLPI
		
		INHINT
		TC	IBNKCALL
		CADR	PFLITEDB
		RELINT

		TC	POSTJUMP
		CADR	BURNBABY

P12INIT		DLOAD			# INITIALIZE ENGINE DATA.  USED FOR P12 AND
## Page 841
			(1/DV)A		# P71.
		STORE	1/DV3
		STORE	1/DV2
		STODL	1/DV1
			(AT)A
		STODL	AT
			(TBUP)A
		STODL	TBUP
			ATDECAY
		DCOMP	SL
			11D
		STORE	TTO
		SLOAD	DCOMP
			APSVEX
		SR2
		STORE	VE
		BOFF	RVQ
			FLAP
			COMMINIT
COMMINIT	DLOAD	DAD		# INITIALIZE TARGET DATA.  USED BY P12, P70
			HINJECT		# AND P71 IF IT DOES NOT FOLLOW P70.
			/LAND/
		STODL	RCO
			HI6ZEROS
		STORE	TXO
		STORE	YCO
		STORE	RDOTD
		STOVL	YDOTD
			VRECTCSM
		VXV	MXV
			RRECTCSM
			REFSMMAT
		UNIT
		STORE	QAXIS
		RVQ
P12ADRES	REMADR	P12TABLE

		SETLOC	P12A
		BANK
		COUNT*	$$/P12

GUIDINIT	STQ	SETPD
			TEMPR60
			0D
		VLOAD	PUSH
			UNITZ
		RTB	PUSH
			LOADTIME
		CALL
			RP-TO-R
## Page 842
		MXV	VXSC
			REFSMMAT
			MOONRATE
		STOVL	WM
			RLS
		ABVAL	SL3
		STCALL	/LAND/
			TEMPR60

49FPS		2DEC	.149352 B-6	# EXPECTED RDOT AT TIPOVER
VINJNOM		2DEC	16.7924 B-7	# 5509.5 FPS(APO=30NM WITH RDOT=19.5FPS)
RDOTDNOM	2DEC	.059436 B-7	# 19.5 FPS


