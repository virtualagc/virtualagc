### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SXTMARK.agc
## Purpose:     A section of Manche45 revision 2.
##              It is part of the reconstructed source code for the
##              final, flown release of the flight software for the Command
##              Module's (CM) Apollo Guidance Computer (AGC) for Apollo 10.
##              The code has been recreated from a copy of Comanche 055. It
##              has been adapted such that the resulting bugger words
##              exactly match those specified for Manche 45/2 in NASA drawing
##              2021153D, which gives relatively high confidence that the
##              reconstruction is correct.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-12-24 MAS  Created from Comanche 45.

## Page 222
# PROGRAM NAME - SXTMARK					DATE - 5 APRIL 1967
# PROGRAM MODIFIED BY 258/278 PROGRAMMERS			LOG SECTION SXTMARK
# MOD BY - R. MELANSON TO ADD DOCUMENTATION			ASSEMBLY SUNDISK REV. 116
# 
# FUNCTIONAL DESCRIPTION-
#
#	SXTMARK IS CALLED FROM INTERNAL ROUTINES WHICH MAY REQUIRE STAR OR LANDMARK MARKINGS BY THE ASTRONAUT.  IF
#	THE MARK SYSTEM IS NOT IN USE, SXTMARK RESERVES A VAC AREA FOR MARKING AND REQUESTS EXECUTION OF THE MKVB51
#	ROUTINE VIA THE EXECUTIVE JOB PRIORITY LIST.  R21 USES THIS ROUTINE TO DETERMINE IF THE MARK SYSTEM CAN BE
#	USED.  IF YES, SXTMARK RETURNS TO R21 TO PERFORM ITS OWN MARK REQUESTS VIA THE V51 FLASH.
#
# CALLING SEQUENCE-
#
#	CAF	(NO. MARK REQUESTS IN BITS 1-3 OF A)
#	TC	BANKCALL
#	CADR	SXTMARK
#
# NORMAL EXIT MODE-
#
#	SWRETURN
#
# ALARM OR ABORT EXIT MODE-
#
#	ABORT
#
# OUTPUT-
#
#	1)	MARKSTAT CONTAINS MARK VALUE (BITS 14-12) AND VAC AREA ADDRESS
#	2)	QPRET = VAC AREA POINTER VALUE
#	3)	1ST WORD OF RESERVED VAC AREA SET TO +0
#	4)	PRIO32 PLACED IN A REGISTER
#
# ERASABLE INITIALIZATION-
#
#	1)	BITS 1-3 OF A = NO. MARKS REQUESTED
#	2)	BITS 2,3 OF EXTVBACT = 0
#	3)	A VAC AREA MUST BE AVAILABLE (WORD 1 = ADDRESS OF VAC AREA)
#
# DEBRIS-
#
#	A,Q,L,RUPTREG1,MARKSTAT,QPRET,BIT2 OF EXTVBACT

		BANK	13
		SETLOC	SXTMARKE
		BANK
		
		EBANK=	MRKBUF1
		COUNT	07/SXTMK
		
SXTMARK		INHINT
		TS	RUPTREG1		# NUMBER OF MARKS WANTED
		
		CAF	SIX			# BIT2 = MARKING SYSTEM IN USE
		MASK	EXTVBACT		# BIT3 = EXTENDED VERB IN PROGRESS
		CCS	A
		TC	MKABORT			# SET THEREFORE ABORT
## Page 223
		CAF	BIT2			# NOT SET
		ADS	EXTVBACT		# SET IT, RESET IN ENDMARK
		TC	MARKOK			# YES, FIND VAC AREA
		
MKABORT		TC	BAILOUT
		OCT	01211
MARKOK		CCS	VAC1USE			# FIND VAC AREA
		TC	MKVACFND
		CCS	VAC2USE
		TC	MKVACFND
		CCS	VAC3USE
		TC	MKVACFND
		CCS	VAC4USE
		TC	MKVACFND
		CCS	VAC5USE
		TC	MKVACFND
		TC	BAILOUT
		OCT	01207
		
MKVACFND	AD	TWO			# ADDRESS OF VAC AREA
		TS	MARKSTAT
		INDEX	A
		TS	QPRET			# STORE NEXT AVAILABLE MARK SLOT
		
		CAF	ZERO			# SHOW VAC AREA OCCUPIED
		INDEX	MARKSTAT
		TS	0	-1
		
		TC	CHECKMM			# BACKUP MARK ROUTINE USES SXTMARK
		MM	53
		TCF	+2
		TCF	SWRETURN
		TC	CHECKMM
		MM	54
		TCF	+2
		TCF	SWRETURN
		CAF	BIT12			# DESIRED NUMBER OF MARKS IN 12-14
		EXTEND
		MP	RUPTREG1
		XCH	L
		ADS	MARKSTAT
		
		CAF	PRIO32			# ENTER MARK JOB
		TC	NOVAC
		EBANK=	MARKSTAT
		2CADR	MKVB51
		
		RELINT
		TCF	SWRETURN		# SAME AS MODEEXIT
	
## Page 224
# PROGRAM NAME - MKRELEAS					DATE - 5 APRIL 1967
# PROGRAM MODIFIED BY 258/278 PROGRAMMERS			LOG SECTION SXTMARK
# MOD BY - R. MELANSON TO ADD DOCUMENTATION			ASSEMBLY SUNDISK REV. 116
#
# FUNCTIONAL DESCRIPTION-
#
#	MKRELEAS IS EXECUTED BY INTERNAL ROUTINES TO RELEASE THE MARK SYSTEM TO MAKE IT AVAILABLE TO OTHER INTERNAL
#	SYSTEM ROUTINES.  IT ALSO CLEARS THE COARSE OPTICS FLAG BIT AND DISABLES THE OPTICS ERROR COUNTER.
#
# CALLING SEQUENCE-
#
#	TC	BANKCALL
#	CADR	MKRELEAS
#
# NORMAL EXIT MODE-
#
#	SWRETURN
#
# ALARM OR ABORT EXIT MODE-  NONE
#
# OUTPUT-
#
#	1)	BIT9 OPTMODES SET TO 0
#	2)	OPTIND SET TO -1
#	3)	1ST WORD OF VAC AREA SET TO VAC ADDRESS TO SIGNIFY AVAILABILITY.
#	4)	MARKSTAT CLEARED
#	5)	BIT2 CHANNEL 12 SET TO 0
#
# ERASABLE INITIALIZATION-  NONE
#
# DEBRIS-
#
#	A,MARKSTAT,BIT9 OPTMODES,OPTIND,BIT2 CHANNEL 12

MKRELEAS	CAF	ZERO			# SHOW MARK SYSTEM NOW AVAILABLE
		XCH	MARKSTAT
		MASK	LOW9
		CCS	A
		INDEX	A
		TS	0
MKRLEES		INHINT
		CS	BIT9			# COARSE OPTICS RETURN FLAG.
		MASK	OPTMODES
		TS	OPTMODES
		
		CA	NEGONE
		TS	OPTIND			# KILL COARS OPTICS
		
		CS	BIT2			# DISABLE OPTICS ERROR COUNTER
		EXTEND
		WAND	CHAN12
		
		RELINT
		TC	SWRETURN
## Page 225
# PROGRAM NAME - MARKRUPT					DATE - 5 APRIL 1967
# PROGRAM MODIFIED BY 258/278 PROGRAMMERS			LOG SECTION SXTMARK
# MOD BY - R. MELANSON TO ADD DOCUMENTATION			ASSEMBLY SUNDISK REV. 116
#
# FUNCTIONAL DESCRIPTION-
#	MARKRUPT STORES CDUS,OPTICS AND TIME AND TRANSFERS CONTROL TO THE MARKIT,MARK REJECT OR KEYCOM ROUTINES IF
#	BITS IN CHANNEL 16 ARE SET AS REQUIRED.
#
# CALLING SEQUENCE-
#	ROUTINE ENTERED VIA KEYRUPT2 WHEN MARK,MARK REJECT OR DSKY KEYS DEPRESSED BY THE OPERATOR.
#
# NORMAL EXIT MODE-
#	MARKIT, MKREJECT OR POSTJUMP ROUTINES (MARK, MARK REJECT OR DSKY CODE)
#
# ALARM OR ABORT EXIT MODE-
#	ALARM AND RESUME
#
# OUTPUT-
#	RUPTSTOR+5 = CDUT, RUPTSTOR+3 = CDUS, RUPTSTOR+2 = CDUY,
#	RUPTREG3 = CDUZ, RUPTSTOR+6 = CDUX, RUPTSTOR+1 AND SAMPTIME+1 = TIME1,
#	RUPTSTOR AND SAMPTIME = TIME2
#
# ERASABLE INITIALIZATION-
#	CDUT,CDUS,CDUY,CDUZ,CDUX,TIME2,TIME1,CHANNEL 16 BITS 6,7 OR 1-5
#
# DEBRIS-
#	A,QRUPT,RUPTREG3,SAMPTIME,SAMPTIME+1,RUPTSTOR TO RUPTSTOR+6 EXCEPT RUPTSTOR+4 (LOCATION 67)

MARKRUPT	TS	BANKRUPT		# STORE CDUS AND OPTICS NOW
		CA	CDUT
		TS	MKCDUT
		CA	CDUS
		TS	MKCDUS
		CA	CDUY
		TS	MKCDUY
		CA	CDUZ
		TS	MKCDUZ
		CA	CDUX
		TS	MKCDUX
		EXTEND
		DCA	TIME2			# GET TIME
		DXCH	MKT2T1
		EXTEND
		DCA	MKT2T1
		DXCH	SAMPTIME		# RUPT TIME FOR NOUN 65.
		
		XCH	Q
		TS	QRUPT
		
		CAF	BIT6			# SEE IF MARK OR MKREJECT
## Page 226
		EXTEND
		RAND	NAVKEYIN
		CCS	A
		TC	MARKIT			# ITS A MARK
		
		CAF	BIT7			# NOT A MARK, SEE IF MKREJECT
		EXTEND
		RAND	NAVKEYIN
		CCS	A
		TC	MKREJECT		# ITS A MARK REJECT
		
KEYCALL		CAF	OCT37			# NOT MARK OR MKREJECT, SEE IF KEYCODE
		EXTEND
		RAND	NAVKEYIN
		EXTEND
		BZF	+3			# IF NO INBITS
		TC	POSTJUMP
		CADR	KEYCOM			# IT,S A KEY CODE, NOT A MARK.
		
 +3		TC	ALARM			# ALARM IF NO INBITS
		OCT	113
		TC	RESUME
		
## Page 227
# PROGRAM NAME - MARKCONT				DATE - 19 SEPT 1967
# PROGRAM MODIFIED BY 258/278 PROGRAMMERS		LOG SECTION SXTMARK
# MOD BY - R. MELANSON TO ADD DOCUMENTATION		ASSEMBLY SUNDISK REV. 116
#
# FUNCTIONAL DESCRIPTION-
#	MARKCONT IS USED TO PERFORM A SPECIAL MARK FUNCTION FOR R21, TO EXECUTE A SPECIAL DISPLAY OF OPTICS AND TIME OR
#	TO PERFORM A MARK OF A STAR OR LAND SIGHTING BASED UPON FLASHING V-N.
#
# CALLING SEQUENCE-

#	FROM MARKDIF
#
# NORMAL EXIT MODE-
#	TASKOVER
#
# ALARM OR ABORT EXIT MODE-
#	ALARM AND TASKOVER
#
# OUTPUT-
#	1)	FOR R21-
#		EBANK=EBANK7
#		MRKBUF1 TO MRKBUF1+6 = TIME2,TIME1,CDUY,OPTICX,CDUZ,OPTICSY,CDUX OF CURRENT R21 MARK FUNCTION.
#		MRKBUF2 TO MRKBUF2+6 CONTAINS PREVIOUS R21 MARK VALUES.
#	2)	FOR SPECIAL DISPLAY JOB-
#		RUPTREG1 AND MRKBUF1 = CDUS,RUPTREG2 AND MRKBUF1+1 = CDUT.
#		RUPTREG3 AND MRKBUF1+2 = TIME2,RUPTREG4 AND MRKBUF1+3 = TIME1
#	3)	FOR NORMAL MARKING-
#		DECREMENT BITS14-12 OF MARKSTAT BY 1,
#		BIT10 MARKSTAT SET TO 1, INCREMENT QPRET BY 7,
#		STORE TIME2,TIME1,CDUY,CDUS,CDUZ,CDUT AND CDUX IN VAC+1 TO VAC+7
#
# ERASABLE INITIALIZATION-
#	1)	FOR R21-
#		BIT14 OF STATE+2 =1, MRKBUF1 TO MRKBUF1+6, ITEMP1, RUPTREG3,
#		RUPTSTOR TO RUPTSTOR+6 EXCEPT RUPTSTOR+4
#	2)	FOR SPECIAL DISPLAY JOB-
#		BIT14 OF STATE+2 =0, MARKSTAT =+0, RUPTREG1,RUPTREG2,RUPTREG3
#		RUPTREG4,RUPTSTOR,RUPTSTOR+1,RUPTSTOR+3,RUPTSTOR+5,
#		BIT12 OF STATE+5 (V59 FLAG), MRKBUF1 THRU MRKBUF1+3
#	3)	FOR NORMAL MARKING-
#		BIT14 OF STATE+2 =0, MARKSTAT =VAC ADDRESS,A REG,ITEMP1,RUPTREG3,
#		RUPTSTOR TO RUPTSTOR+6 EXCEPT RUPTSTOR+4
#
# DEBRIS-
#	1)	FOR R21-
#		A, ITEMP1, MRKBUF1, MRKBUF2
#	2)	FOR SPECIAL DISPLAY JOB-
#		A,RUPTREG1,RUPTREG2,RUPTREG3,RUPTREG4,MPAC TO MPAC+3
#	3)	FOR NORMAL MARKING-
#		A,MARKSTAT,ITEMP1,QPRET,VAC+1 TO VAC+7 OF VAC AREA IN USE

## Page 228
MARKCONT	CAF	BIT14
		MASK	STATE	+2		# R21 MARK (SPECIAL MARKING FOR R21)
		EXTEND
		BZF	MARKET			# NOT SET THEREFORE REGULAR MARKING
MARKIT1		CAF	SIX			# SPECIAL FOR R21
		TC	GENTRAN			# TRANSFER MRKBUF1 TO MRKBUF2
		ADRES	MRKBUF1
		ADRES	MRKBUF2
		
		CAF	SIX			# TRANSFER CURRENT MARK DATA TO MARKBUF1
		TC	GENTRAN
		ADRES	MKT2T1
		ADRES	MRKBUF1
		
		TCF	TASKOVER
		
MARKET		CCS	MARKSTAT		# SEE IF MARKS CALLED FOR
		TC	MARK2			# COLLECT MARKS
		
		CAF	TWO			# IS MARKING SYSTEM IN USE (BIT2)
		MASK	EXTVBACT
		EXTEND
		BZF	MARKET3			# MARKING NOT CALLED FOR
		CAF	BIT12
		MASK	STATE	+5		# V59FLAG
		EXTEND
		BZF	MARKET3			# IF V59FLAG NOT SET-MARK UNCALLED FOR
		CAF	PRIO5			# CALIBRATION MARK (SET) FOR P23
		TC	NOVAC			# SPECIAL DISPLAY JOB
		EBANK=	MRKBUF1
		2CADR	MARKDISP
		
		CAF	SIX
		TC	GENTRAN			# TRANSFER MARK DATA TO MARKDOWN
		ADRES	MKT2T1
		ADRES	MARKDOWN
		CAF	SIX
		TC	GENTRAN			# TRANSFER MARK DATA TO MRKBUF1 FOR
		ADRES	MKT2T1			# SPECIAL DISPLAY OF SHAFT AND TRUNNION
		ADRES	MRKBUF1			# IF V59 ACTING
		TCF	TASKOVER
MARKET3		TC	ALARM
		OCT	122			# MARKING NOT CALLED FOR
		TCF	TASKOVER
114ALM		TC	ALARM			# MARK NOT WANTED
		OCT	114
		TCF	TASKOVER
		
## Page 229
# STORE MARK DATA IN MKVAC AND INCREMENT POINTER

MARK2		AD	74K			# SEE IF MARKS WANTED-REDUCE MARKS WANTED
		EXTEND
		BZMF	114ALM			# MARK NOT WANTED-ALARM
		TS	MARKSTAT
		COM
		MASK	BIT10			# SET BIT10 TO ENABLE REJECT
		ADS	MARKSTAT
		
		MASK	LOW9
		TS	ITEMP1
		INDEX	A
		XCH	QPRET			# PICK UP MARK SLOT-POINTER
		TS	ITEMP2			# SAVE CURRENT POINTER
		AD	SEVEN			# INCREMENT POINTER
		INDEX	ITEMP1
		TS	QPRET			# STORE ADVANCED POINTER
		
VACSTOR		EXTEND
		DCA	MKT2T1
		INDEX	ITEMP2
		DXCH	0
		CA	MKCDUY
		INDEX	ITEMP2
		TS	2
		CA	MKCDUS
		INDEX	ITEMP2
		TS	3
		CA	MKCDUZ
		INDEX	ITEMP2
		TS	4
		CA	MKCDUT
		INDEX	ITEMP2
		TS	5
		CA	MKCDUX
		INDEX	ITEMP2
		TS	6
		
		CAF	PRIO34			# IF ALL MARKS MADE FLASH VB50
		MASK	MARKSTAT
		EXTEND
		BZF	+2
		TCF	TASKOVER
		CAF	PRIO32
		TC	NOVAC
		EBANK=	MARKSTAT
		2CADR	MKVB50
		
		TCF	TASKOVER
		
## Page 230
# PROGRAM NAME - MKREJECT					DATE - 5 APRIL 1967
# PROGRAM MODIFIED BY 258/278 PROGRAMMERS			LOG SECTION SXTMARK
# MOD BY - R. MELANSON TO ADD DOCUMENTATION			ASSEMBLY SUNDISK REV. 116
#
# FUNCTIONAL DESCRIPTION-
#	ROUTINE ALLOWS OPERATOR TO REJECT MARK MADE PRIOR TO ACCEPTANCE AND ALLOWS A NEW MARK TO BE MADE BY ASTRONAUT
#
# CALLING SEQUENCE-
#	FROM MARKRUPT IF BIT7 OF CHANNEL 16 IS 1.
#
# NORMAL EXIT MODE-
#	RESUME
#
# ALARM OR ABORT EXIT MODE-
#	ALARM AND RESUME
#
# OUTPUT-
#	1)	FOR R21-
#		MRKBUF1 SET TO -1
#	2)	FOR NORMAL MARKING-
#		BIT10 MARKSTAT =0, INCREMENT NO. MARKS BY 1, DECREMENT QPRET BY 7
#
# ERASABLE INITIALIZATION-
#	1)	FOR R21-
#		BIT14 OF STATE+2 SET TO 1
#	2)	FOR NORMAL MARKING-
#		BIT14 OF STATE+2 SET TO 0, MARKSTAT,QPRET
#
# DEBRIS-
#	1)	FOR R21-
#		A,MARKSTAT,EBANK
#	2)	FOR NORMAL MARKING-
#		A,MARKSTAT,ITEMP1,QPRET

MKREJECT	CAF	BIT14
		MASK	STATE	+2		# R21 MARK (SPECIAL MARKING FOR R21)
		EXTEND
		BZF	MRKREJCT		# NOT SET THEREFORE REGULAR REJECT
		CA	NEGONE			# -1 (FOR R22)
		TS	MRKBUF1			# -0 IN TIME IS FLAG TO R22 SIGNIFYING A
		TC	RESUME			# REJECTED MARK
MRKREJCT	CCS	MARKSTAT		# SEE IF MARKS BEING ACCEPTED
		TC	REJECT2
		TC	ALARM			# MARKS NOT BEING ACCEPTED
		OCT	112
		TC	RESUME
		
REJECT2		CS	BIT10			# SEE IF MARK HAD BEEN MADE SINCE LAST
		MASK	MARKSTAT		# REJECT, AND SET BIT10 TO ZERO TO
		XCH	MARKSTAT		# SHOW MARK REJECT
## Page 231
		MASK	BIT10
		CCS	A
		TC	REJECT3
		
		TC	ALARM			# DONT ACCEPT TWO REJECTS TOGETHER
		OCT	110
		TC	RESUME
		
REJECT3		CAF	LOW9			# DECREMENT POINTER TO REJECT MARK
		MASK	MARKSTAT
		TS	ITEMP1
		CS	SEVEN
		INDEX	ITEMP1
		ADS	QPRET			# NEW POINTER
		
		CAF	BIT12			# INCREMENT MARKS WANTED AND IF FIELD
		AD	MARKSTAT		# IS NOW NON-ZERO, CHANGE TO VB51 TO
		XCH	MARKSTAT		# INDICATE MORE MARKS WANTED
		MASK	PRIO34			# INDICATE MORE MARKS WANTED
		CCS	A
		TC	RESUME
		CAF	PRIO32
		TC	NOVAC
		EBANK=	MARKSTAT
		2CADR	MKVB51
		
		TC	RESUME
		
## Page 232
# PROGRAM DESCRIPTION MKVB51 AND MKVB50
#
# AUTHOR-BARNERT DATE-2-15-67 MOD-0
# PURPOSE  FLASH V51N70,V51N43, OR V51 TO REQUEST MARKING,
#	   AND V50N25 R1=16 TO REQUEST TERMINATE MARKING
#
# CALLING SEQUENCE   AS JOB WITHIN SXTMARK
#
# EXIT TO ENDMARK UPON RECEIPT OF V33, V34 CAUSES GOTOPOOH, ENTER
#	   RECYCLES THE DISPLAY
#
# NOTE-	SXTMARK AUTOMATICALLY CHANGES FROM CALLING MKVB51 TO MKVB50 WHEN
#	   SUFFICIENT MARKS HAVE BEEN MADE, AND THE REVERSE WHEN A MARK
#	   REJECT REDUCES THE NUMBER MADE BELOW THAT REQUIRED
#
# SUBROUTINES CALLED- BANKCALL, GOMARK2, GOODEND, ENDMARK, WAITLIST
#
# ALARM OR ABORT MODES - NONE
#
# ERASABLE USED-VERBREG,MARKSTAT,QPRET,DSPTEM1
#
# OUTPUT MARKSTAT = VAC ADDRESS

# QPRET = NO. MARKS

MKVB51		TC	BANKCALL		# CLEAR DISPLAY FOR MARK VERB
		CADR	KLEENEX
		CAF	VB51			# DISPLAY MARK VB51
		TC	BANKCALL
		CADR	GOMARK4
		TCF	TERMSXT			# VB34-TERMINATE
		TCF	ENTANSWR		# V33-PROCEED-MARKING DONE
		TCF	MKVB5X			# ENTER-RECYCLE TO INITIAL MARK DISPLAY
		
TERMSXT		TC	CLEARMRK		# CLEAR MARK ACTIVITY.

		TC	CHECKMM
		MM	03
		TCF	+2
		TC	TERMP03
		TC	POSTJUMP
		CADR	TERM52
		
TERMP03		TC	UPFLAG
		ADRES	TRM03FLG
ENTANSWR	CAF	LOW9			# PUT VAC ADR IN MARKSTAT AND NO. OF
		MASK	MARKSTAT		# MARKS MADE IN QPRET BEFORE LEAVING
		TS	MARKSTAT		# SXTMARK
		COM
		INDEX	MARKSTAT
		AD	QPRET
## Page 233
		EXTEND
		BZMF	JAMIT			# NO MARKS MADE, SHOW IT IN QPRET, R53
		EXTEND				#	WILL PICK IT UP AND RECYCLE
		MP	BIT12			# THIS PUTS NUMBER MARKS-1 IN A
		AD	ONE
JAMIT		INDEX	MARKSTAT		# STORE NO OF MARKS MADE
		TS	QPRET
		INHINT				# SERVICE OPTSTALL INTERFACE WITH
		CAF	FIVE
		TC	WAITLIST
		EBANK=	MARKSTAT
		2CADR	ENDMARKS
		
		TC	ENDMARK			# KNOCKS DOWN MARKING FLAG + DOES ENDOFJOB
		
ENDMARKS	CAF	ONE
		TC	IBNKCALL
		CADR	GOODEND
MKVB5X		CAF	PRIO34
		MASK	MARKSTAT		# RE-DISPLAY VB51 IF MORE MARKS WANTED
		CCS	A			# AND VB50 IF ALL IN
		TCF	MKVB51			
MKVB50		CAF	R1D1			# OCT 16
		TS	DSPTEM1
		CAF	V50N25
		TCF	MKVB51	+3
		
V50N25		VN	5025
VB51		VN	5100
OCT37		=	LOW5

# PROGRAM NAME - MARKIT				DATE - 19 SEPT 1967
#
# CALLING SEQUENCE
#	FROM MARKRUPT IF CHAN 16 BIT 6 = 1
#
# EXIT
#	RESUME
#
# INPUT
#	CDUCHKWD.  ALSO ALL INITIALIZATION FOR MARKCONT
#
# OUTPUT
#	MKT2T1,MKCDUX,MKCDUY,MKCDUZ,MKCDUS,MKCDUT
#
# ALARM EXIT
#	NONE

MARKIT		CCS	CDUCHKWD
		TCF	+3			# DELAY OF CDUCHKWD CS IF PNZ
## Page 234
		TCF	+2
		CAF	ZERO
		AD	ONE			# 10 MS IF NO CHECK
		TC	WAITLIST
		EBANK=	MRKBUF1
		2CADR	MARKDIF
		
		TCF	RESUME
		
		SETLOC	SXTMARK1
		BANK
		
		COUNT	20/SXTMK
		
# PROGRAM NAME - MARKDIF			DATE- 19 SEPT 1967
#
# CALLING SEQUENCE
#	WAITLIST FROM MARKIT
#
# EXIT
#	TASKOVER OT IBNKCALL TO MARKCONT
#
# INPUT
# 	OUTPUT FROM MARKIT, INPUT TO MARKCONT, CDUCHKWD
#
# OUTPUT
#	RUPTSTOR - RUPTSTOR+3, RUPTREG3, RUPTSTOR+5 - RUPTSTOR+6
#
# ALARM EXIT
#	ALARM AND TASKOVER

MARKDIF		CA	CDUCHKWD		# IF DELAY CHECK IS ZERO OR NEG, ACP MARK
		EXTEND
		BZMF	MKACPT
		CS	BIT1
		TS	MKNDX			# SET INDEX -1
		CA	MKCDUX
		TC	DIFCHK			# SEE IF VEHICLE RATE TO MUCH AT MARK
		CA	MKCDUY
		TC	DIFCHK
		CA	MKCDUZ
		TC	DIFCHK
		
MKACPT		TC	IBNKCALL
		CADR	MARKCONT		# MARK DATA OK, WHAT DO WE DO WITH IT
		
DIFCHK		INCR	MKNDX			# INCREMENT INDEX

		EXTEND
		INDEX	MKNDX
## Page 235
		MSU	CDUX			# GET MARK(ICDU) - CURRENT(ICDU)
		CCS	A
		TCF	+4
		TC	Q
		TCF	+2
		TC	Q
		AD	NEG2			# SEE IF DIFFERENCE GREATER THAN 3 BITS
		EXTEND
		BZMF	-3			# NOT GREATER
		
		TC	ALARM			# COUPLED WITH PROGRAM ALARM
		OCT	00121
		
		TCF	TASKOVER		# DO NOT ACCEPT
		

