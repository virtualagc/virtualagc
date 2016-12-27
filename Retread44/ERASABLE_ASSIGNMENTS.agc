### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ERASABLE_ASSIGNMENTS.agc
## Purpose:     Part of the source code for Retread 44 (revision 0). It was
##              the very first program for the Block II AGC, created as an
##              extensive rewrite of the Block I program Sunrise.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 5-13
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-13 MAS  Created from Aurora 12 version.
##              2016-12-16 MAS  Transcribed.
## 		2016-12-26 RSB	Proofed comment text using octopus/ProoferComments,
##				and fixed errors found.

## Page 5
## At the top, above the addresses and labels, is written the word OCTAL.

A               EQUALS          0
L               EQUALS          1                               # L AND Q ARE BOTH CHANNELS AND REGISTERS.
Q               EQUALS          2
EBANK           EQUALS          3
FBANK           EQUALS          4
Z               EQUALS          5                               # ADJACENT TO FBANK AND BBANK FOR DXCH Z
BBANK           EQUALS          6                               # (DTCB) AND DXCH FBANK (DTCF).
                                                                # REGISTER 7 IS A ZERO-SOURCE, USED BY ZL.

ARUPT           EQUALS          10                              # INTERRUPT STORAGE.
LRUPT           EQUALS          11
QRUPT           EQUALS          12
ZRUPT           EQUALS          15                              # (13 AND 14 ARE SPARES.)
BANKRUPT        EQUALS          16                              # USUALLY HOLDS FBANK OR BBANK.
BRUPT           EQUALS          17                              # RESUME ADDRESS AS WELL.

CYR             EQUALS          20
SR              EQUALS          21
CYL             EQUALS          22
EDOP            EQUALS          23                              # EDITS INTERPRETIVE OPERATION CODE PAIRS.



TIME2           EQUALS          24
TIME1           EQUALS          25
TIME3           EQUALS          26
TIME4           EQUALS          27
TIME5           EQUALS          30
TIME6           EQUALS          31
CDUX            EQUALS          32
CDUY            EQUALS          33
CDUZ            EQUALS          34
OPTY            EQUALS          35
OPTX            EQUALS          36
PIPAX           EQUALS          37
PIPAY           EQUALS          40
PIPAZ           EQUALS          41
BMAGX           EQUALS          42
BMAGY           EQUALS          43
BMAGZ           EQUALS          44
INLINK          EQUALS          45
RNRAD           EQUALS          46
GYROCTR         EQUALS          47
CDUXCMD         EQUALS          50
CDUYCMD         EQUALS          51
CDUZCMD         EQUALS          52
OPTYCMD         EQUALS          53
OPTXCMD         EQUALS          54
EMSD            EQUALS          55
LEMONM          EQUALS          56
## Page 6
OUTLINK         EQUALS          57
ALTM            EQUALS          60

                SETLOC          67                              # DECODED REGISTER FOR NIGHT-WATCHMAN ALM.
NEWJOB          ERASE

LVSQUARE        EQUALS          34D                             # SQUARE OF VECTOR INPUT TO ABVAL AND UNIT
LV              EQUALS          36D                             # LENGTH OF VECTOR INPUT TO UNIT.
X1              EQUALS          38D                             # INTERPRETIVE SPECIAL REGISTERS RELATIVE
X2              EQUALS          39D                             # TO THE WORK AREA.
S1              EQUALS          40D
S2              EQUALS          41D
QPRET           EQUALS          42D

## Page 7
# GENERAL ERASABLE ASSIGNMENTS.

#          THE FOLLOWING ARE EXECUTIVE TEMPORARIES WHICH MAY BE USED BETWEEN CCS NEWJOB INQUIRIES.

		SETLOC		100

INTB15+         ERASE                                           # REFLECTS 15TH BIT OF INDEXABLE ADDRESSES
DSEXIT          =               INTB15+                         # RETURN FOR DSPIN
EXITEM          =               INTB15+                         # RETURN FOR SCALE FACTOR ROUTINE SELECT
BLANKRET        =               INTB15+                         # RETURN FOR 2BLANK

INTBIT15        ERASE                                           # SIMILAR TO ABOVE.
WRDRET          =               INTBIT15                        # RETURN FOR 5BLANK
WDRET           =               INTBIT15                        # RETURN FOR DSPWD
DECRET          =               INTBIT15                        # RETURN FOR PUTCOM(DEC LOAD)
21/22REG        =               INTBIT15                        # TEMP FOR CHARIN

ADDRWD          ERASE                                           # 12 BIT INTERPRETIVE OPERAND SUB-ADDRESS.
POLISH          ERASE                                           # HOLDS CADR MADE FROM POLISH ADDRESS.
UPDATRET        =               POLISH                          # RETURN FOR UPDATNN, UPDATVB
CHAR            =               POLISH                          # TEMP FOR CHARIN
ERCNT           =               POLISH                          # COUNTER FOR ERROR LIGHT RESET
DECOUNT         =               POLISH                          # COUNTER FOR SCALING AND DISPLAY (DEC)

FIXLOC          ERASE                                           # WORK AREA ADDRESS.

OVFIND          ERASE                                           # SET NON-ZERO ON OVERFLOW.

VBUF            ERASE           +5                              # TEMPORARY STORAGE USED FOR VECTORS.
SGNON           =               VBUF                            # TEMP FOR +,- ON
NOUNTEM         =               VBUF                            # COUNTER FOR MIXNOUN FETCH
DISTEM          =               VBUF                            # COUNTER FOR OCTAL DISPLAY VERBS
DECTEM          =               VBUF                            # COUNTER FOR FETCH (DEC DISPLAY VERBS)

SGNOFF          =               VBUF            +1              # TEMP FOR +,- ON
NVTEMP          =               VBUF            +1              # TEMP FOR NVSUB
SFTEMP1         =               VBUF            +1              # STORAGE FOR SF CONST HI PART(=SFTEMP2-1)

CODE            =               VBUF            +2              # FOR DSPIN
SFTEMP2         =               VBUF            +2              # STORAGE FOR SF CONST LO PART(=SFTEMP1+1)

MIXTEMP         =               VBUF            +3              # FOR MIXNOUN DATA
SIGNRET         =               VBUF            +3              # RETURN FOR +,- ON

# ALSO MIXTEMP+1 = VBUF+4, MIXTEMP+2 = VBUF+5.

BUF             ERASE           +2                              # TEMPORARY SCALAR STORAGE.
BUF2            ERASE           +1
INDEXLOC        EQUALS          BUF                             # CONTAINS ADDRESS OF SPECIFIED INDEX.
SWWORD          EQUALS          BUF                             # ADDRESS OF SWITCH WORD.
## Page 8
SWBIT           EQUALS          BUF             +1              # SWITCH BIT WITHIN SWITCH WORD.
MPTEMP          ERASE                                           # TEMPORARY USED IN MULTIPLY AND SHIFT.
DOTINC          ERASE                                           # COMPONENT INCREMENT FOR DOT SUBROUTINE.
DVSIGN          EQUALS          DOTINC                          # DETERMINES SIGN OF DDV RESULT.
ESCAPE          EQUALS          DOTINC                          # USED IN ARCSIN/ARCCOS.
ENTRET          =               DOTINC                          # EXIT FROM ENTER

DOTRET          ERASE                                           # RETURN FROM DOT SUBROUTINE.
DVNORMCT        EQUALS          DOTRET                          # DIVIDEND NORMALIZATION COUNT IN DDV.
ESCAPE2         EQUALS          DOTRET                          # ALTERNATE ARCSIN/ARCCOS SWITCH.
WDCNT           =               DOTRET                          # CHAR COUNTER FOR DSPWD
INREL           =               DOTRET                          # INPUT BUFFER SELECTOR ( X,Y,Z, REG )

MATINC          ERASE                                           # VECTOR INCREMENT IN MXV AND VXM.
MAXDVSW         EQUALS          MATINC                          # +0 IF DP QUOTIENT IS NEAR ONE - ELSE -1.
POLYCNT         EQUALS          MATINC                          # POLYNOMIAL LOOP COUNTER
DSPMMTEM        =               MATINC                          # DSPCOUNT SAVE FOR DSPMM
MIXBR           =               MATINC                          # INDICATOR FOR MIXED OR NORMAL NOUN

TEM1            ERASE                                           # EXEC TEMP
POLYRET         =               TEM1
DSREL           =               TEM1                            # REL ADDRESS FOR DSPIN

TEM2            ERASE                                           # EXEC TEMP
DSMAG           =               TEM2                            # MAGNITUDE STORE FOR DSPIN
IDADDTEM        =               TEM2                            # MIXNOUN INDIRECT ADDRESS STORAGE

TEM3            ERASE                                           # EXEC TEMP
COUNT           =               TEM3                            # FOR DSPIN

TEM4            ERASE                                           # EXEC TEMP
LSTPTR          =               TEM4                            # LIST POINTER FOR GRABUSY
RELRET          =               TEM4                            # RETURN FOR RELDSP
FREERET         =               TEM4                            # RETURN FOR FREEDSP

TEM5            ERASE                                           # EXEC TEMP
NOUNADD         =               TEM5                            # TEMP STORAGE FOR NOUN ADDRESS

NNADTEM         ERASE                                           # TEMP FOR NOUN ADDRESS TABLE ENTRY
NNTYPTEM        ERASE                                           # TEMP FOR NOUN TYPE TABLE ENTRY
IDAD1TEM        ERASE                                           # TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
                                                                # MUST = IDAD2TEM-1, = IDAD3TEM-2.
IDAD2TEM        ERASE                                           # TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
                                                                # MUST = IDAD1TEM+1, = IDAD3TEM-1.
IDAD3TEM        ERASE                                           # TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
                                                                # MUST = IDAD1TEM+2, = IDAD2TEM+1.
RUTMXTEM        ERASE                                           # TEMP FOR SF ROUT TABLE ENTRY(MIXNN ONLY)



#          STORAGE USED BY THE EXECUTIVE.

## Page 9
MPAC            ERASE           +6                              # MULTI-PURPOSE ACCUMULATOR.
MODE            ERASE                                           # +1 FOR TP, +0 FOR DP, OR -1 FOR VECTOR.
LOC             ERASE                                           # LOCATION ASSOCIATED WITH JOB.
BANKSET         ERASE                                           # USUALLY CONTAINS BBANK SETTING.
PUSHLOC         ERASE                                           # WORD OF PACKED INTERPRETIVE PARAMETERS.
PRIORITY        ERASE                                           # PRIORITY OF PRESENT JOB AND WORK AREA.

                ERASE           +71D                            # SEVEN SETS OF 12 REGISTERS EACH.

VAC1USE         ERASE
VAC1            ERASE           +42D
VAC2USE         ERASE
VAC2            ERASE           +42D
VAC3USE         ERASE
VAC3            ERASE           +42D
VAC4USE         ERASE
VAC4            ERASE           +42D
VAC5USE         ERASE
VAC5            ERASE           +42D

#          INTERPRETIVE SWITCH RESERVATIONS.

STATE		ERASE		+3				# 60 SWITCHES PRESENTLY.

#          THE FOLLOWING SET COMPRISES THE INTERRUPT TEMPORARY STORAGE POOL.

WAITEXIT	ERASE
KEYTEMP1	=		WAITEXIT			# TEMP FOR KEYRUPT, UPRUPT
DSRUPTEM	=		WAITEXIT			# TEMP FOR DSPOUT

WAITBANK	ERASE
EXECTEM1	ERASE
EXECTEM2	ERASE
WAITADR		ERASE
WAITTEMP	ERASE

NEWPRIO		ERASE						# EXECUTIVE RESERVATIONS (TEMP ONLY).
NEWLOC		ERASE		+1
LOCCTR		ERASE

#          WAITLIST REPEAT FLAG:

RUPTAGN		ERASE
KEYTEMP2	=		RUPTAGN				# TEMP FOR KEYRUPT, UPRUPT

## Page 10
# THE FOLLOWING REGISTERS ARE RESERVED FOR PINBALL



# RESERVED FOR PINBALL EXECUTIVE ACTION

DSPCOUNT        ERASE                                           # DISPLAY POSITION INDICATOR
DECBRNCH        ERASE                                           # +DEC, - DEC, OCT INDICATOR
VERBREG         ERASE                                           # VERB CODE
NOUNREG         ERASE                                           # NOUN CODE
XREG            ERASE                                           # R1 INPUT BUFFER
YREG            ERASE                                           # R2 INPUT BUFFER
ZREG            ERASE                                           # R3 INPUT BUFFER
XREGLP          ERASE                                           # LO PART OF XREG (FOR DEC CONV ONLY)
YREGLP          ERASE                                           # LO PART OF YREG (FOR DEC CONV ONLY)
ZREGLP          ERASE                                           # LO PART OF ZREG (FOR DEC CONV ONLY)
MODREG          ERASE                                           # MODE CODE
DSPLOCK         ERASE                                           # KEYBOARD/SUBROUTINE CALL INTERLOCK
REQRET          ERASE                                           # RETURN REGISTER FOR LOAD
LOADSTAT        ERASE                                           # STATUS INDICATOR FOR LOADTST
CLPASS          ERASE                                           # PASS INDICATOR CLEAR
NOUT            ERASE                                           # ACTIVITY COUNTER FOR DSPTAB
NOUNCADR        ERASE                                           # MACHINE CADR FOR NOUN
MONSAVE         ERASE                                           # N/V CODE FOR MONITOR. (= MONSAVE1-1)
MONSAVE1        ERASE                                           # NOUNCADR FOR MONITOR(MATBS) =MONSAVE+1
DSPTAB          ERASE           +11D                            # 0-10D, DISPLAY PANEL BUFF. 11D, C/S LTS.
CADRSTOR        ERASE                                           # ENDIDLE STORAGE
GRABLOCK        ERASE                                           # INTERNAL INTERLOCK FOR DISPLAY SYSTEM 
NVQTEM          ERASE                                           # NVSUB STORAGE FOR CALLING ADDRESS
                                                                # MUST = NVBNKTEM-1
NVBNKTEM        ERASE                                           # NVSUB STORAGE FOR CALLING BANK
                                                                # MUST = NVQTEM+1
DSPLIST         ERASE           +2                              # WAITING LIST FOR DSP SYST INTERNAL USE
EXTVBACT        ERASE                                           # EXTENDED VERB ACTIVITY INTERLOCK
DSPTEM1         ERASE           +2                              # BUFFER STORAGE AREA 1 (MOSTLY FOR TIME)
DSPTEM2         ERASE           +2                              # BUFFER STORAGE AREA 2 (MOSTLY FOR DEG)
# END OF ERASABLES RESERVED FOR PINBALL EXECUTIVE ACTION



# RESERVED FOR PINBALL INTERRUPT ACTION

DSPCNT          ERASE                                           # COUNTER FOR DSPOUT
UPLOCK          ERASE                                           # BIT1 = UPLINK INTERLOCK (ACTIVATED BY
                                                                # RECEPTION OF A BAD MESSAGE IN UPLINK)
# END OF ERASABLES RESERVED FOR PINBALL INTERRUPT ACTION

## Page 11
# TEMPORARY PHONY ASSIGNMENTS TO KEEP PINBALL FROM HAVING BAD ASSEMBLIES

THETAD          ERASE           +2
FAILREG		ERASE
TDEC		ERASE		+1
TET		ERASE		+1
MEASQ		ERASE		+1
ROLL		ERASE		+2
LANDMARK	ERASE		+5
GBIASX		ERASE		+2
ADIAX		ERASE		+2
ADSRAX		ERASE		+2
DESOPTX		ERASE		+1
SAMPTIME	ERASE		+1
DELVX           ERASE           +5
PBIASX		ERASE
PIPASCFX	ERASE
PBIASY		ERASE
PIPASCFY	ERASE
PBIASZ		ERASE
PIPASCFZ	ERASE
		SETLOC		1000
DELR		ERASE		+5
DELVEL		ERASE		+5
MEASMODE	ERASE
DELTAQ		ERASE		+1
WASKSET		ERASE
# END OF PHONY ASSIGNMENTS

## Page 12

# ASSIGNMENTS FOR T4RUPT PROGRAM
DSRUPTSW        ERASE
OLDERR		ERASE
WASOPSET	ERASE
# END OF T4RUPT ASSIGNMENTS



# ASSIGNMENTS FOR DOWNRUPT

DISPBUF		ERASE
TMKEYBUF	ERASE
# END OF DOWNRUPT ASSIGNMENTS



# ASSIGNMENTS FOR SELF CHECK

# ADDRESSES TO BE USED FOR INDEX INSTRUCTION WITHOUT EXTRACODES
NDX+0		ERASE
NDX+MAX		ERASE
NDXKEEP1	ERASE
NDXKEEP2	ERASE
NDXKEEP3	ERASE
NDXSELF1	ERASE
NDXSELF2	ERASE

KEEP1		ERASE
KEEP2		ERASE
KEEP3		ERASE
KEEP4		ERASE
KEEP5		ERASE
KEEP6		ERASE
KEEP7		ERASE

SELFRET		ERASE
SFAIL		ERASE
ERCOUNT		ERASE
SCOUNT		ERASE
SMODE		ERASE

# END OF SELF CHECK ASSIGNMENTS



# WAITLIST TASK LISTS:

                SETLOC          1400

## Page 13
LST1            ERASE           +4                              # DELTA TS.
LST2            ERASE           +11D                            # 2CADR TASK ADDRESSES.
