### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ERASABLE_ASSIGNMENTS.agc
## Purpose:     A section of Sunburst revision 37, or Shepatin revision 0.
##              It is part of an early development version of the software
##              for Apollo Guidance Computer (AGC) on the unmanned Lunar
##              Module (LM) flight Apollo 5. Sunburst 37 was the program
##              upon which Don Eyles's offline development program Shepatin
##              was based; the listing herein transcribed was actually for
##              the equivalent revision 0 of Shepatin.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 10-52
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-28 HG   Transcribed
##              2017-05-30 HG   Add missing variable RUPTSTOR
##              2017-06-08 HG   Fix label NEWTIME -> NEWMTIME
##                                        ABDCONV -> ABDVCONV
##		2017-06-21 RSB	A few comments corrected using 
##				octopus/ProoferComments.
##              2021-05-30 ABS  Added missing BODYFLAG definition.

## Page 10

A               EQUALS          0
L               EQUALS          1                       # L AND Q ARE BOTH CHANNELS AND REGISTERS.
Q               EQUALS          2
EBANK           EQUALS          3
FBANK           EQUALS          4
Z               EQUALS          5                       # ADJACENT TO FBANK AND BBANK FOR DXCH Z
BBANK           EQUALS          6                       # (DTCB) AND DXCH FBANK (DTCF).
                                                        # REGISTER 7 IS A ZERO-SOURCE. USED BY ZL.

ARUPT           EQUALS          10                      # INTERRUPT STORAGE.
LRUPT           EQUALS          11
QRUPT           EQUALS          12
SAMPTIME        EQUALS          13                      # SAMPLED TIME 1 & 2.
ZRUPT           EQUALS          15                      # (13 AND 14 ARE SPARES.)
BANKRUPT        EQUALS          16                      # USUALLY HOLDS FBANK OR BBANK.
BRUPT           EQUALS          17                      # RESUME ADDRESS AS WELL.

CYR             EQUALS          20
SR              EQUALS          21
CYL             EQUALS          22
EDOP            EQUALS          23                      # EDITS INTERPRETIVE OPERATION CODE PAIRS.

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
RHCP            EQUALS          42
BMAGY           EQUALS          43
RHCY            EQUALS          43
BMAGZ           EQUALS          44
RHCR            EQUALS          44
INLINK          EQUALS          45
RNRAD           EQUALS          46
GYROCTR         EQUALS          47
GYROCMD         EQUALS          47
CDUXCMD         EQUALS          50
CDUYCMD         EQUALS          51


## Page 11
CDUZCMD         EQUALS          52
OPTYCMD         EQUALS          53
OPTXCMD         EQUALS          54
EMSD            EQUALS          55
THRUST          EQUALS          55
LEMONM          EQUALS          56
OUTLINK         EQUALS          57
ALTM            EQUALS          60

# VAC-RELATIVE INTERPRETER ASSIGNMENTS:

LVSQUARE        EQUALS          34D                     # SQUARE OF VECTOR INPUT TO ABVAL AND UNIT
LV              EQUALS          36D                     # LENGTH OF VECTOR INPUT TO UNIT.
X1              EQUALS          38D                     # INTERPRETIVE SPECIAL REGISTERS RELATIVE
X2              EQUALS          39D                     # TO THE WORK AREA.
S1              EQUALS          40D
S2              EQUALS          41D
QPRET           EQUALS          42D


## Page 12
# GENERAL ERASABLE ASSIGNMENTS.

                SETLOC          61

#          THE FOLLOWING SET COMPRISES THE INTERRUPT TEMPORARY STORAGE POOL.

#          ANY OF THESE MAY BE USED AS TEMPORARIES DURING INTERRUPT OR WITH INTERRUPT INHIBITED. THE ITEMP SERIES
# IS USED DURING CALLS TO THE EXECUTIVE AND WAITLIST - THE RUPTREGS ARE NOT.

ITEMP1          ERASE
WAITEXIT        EQUALS          ITEMP1
EXECTEM1        EQUALS          ITEMP1

ITEMP2          ERASE
WAITBANK        EQUALS          ITEMP2
EXECTEM2        EQUALS          ITEMP2

ITEMP3          ERASE
RUPTSTOR        EQUALS          ITEMP3
WAITADR         EQUALS          ITEMP3
NEWPRIO         EQUALS          ITEMP3

ITEMP4          ERASE
LOCCTR          EQUALS          ITEMP4
WAITTEMP        EQUALS          ITEMP4

ITEMP5          ERASE
NEWLOC          EQUALS          ITEMP5

ITEMP6          ERASE
# NEWLOC+1      EQUALS  ITEMP6          DP ADDRESS.

                SETLOC          67                      # NEWJOB MUST BE IN LOCATION 67.
NEWJOB          ERASE                                   #        ----

RUPTREG1        ERASE
RUPTREG2        ERASE
RUPTREG3        ERASE
RUPTREG4        ERASE
KEYTEMP1        EQUALS          RUPTREG4
DSRUPTEM        EQUALS          RUPTREG4


## Page 13
#          FLAG & SWITCH RESERVATIONS.

STATE           ERASE           +7                      # 120 SWITCHES

FLAGWRD1        EQUALS          STATE           +1
FLAGWRD2        EQUALS          STATE           +2
DAPBOOLS        EQUALS          STATE           +3
FLAGWRD4        EQUALS          STATE           +4

#          INTERPRETIVE SWITCH BIT ASSIGNMENTS:

WMATFLAG        EQUALS          0
JSWITCH         EQUALS          1
MIDFLAG         EQUALS          2
MOONFLAG        EQUALS          3
NBSMBIT         EQUALS          4
COAROFIN        EQUALS          5
BODYFLAG        EQUALS          6
IMUSE           EQUALS          7
RRUSE           EQUALS          8D
RRNBSW          EQUALS          9D
LOKONSW         EQUALS          10D
CONVSW          EQUALS          60D
DONESW          EQUALS          61D
ITERSW          EQUALS          62D
GUESSW          EQUALS          63D
PIESW           EQUALS          64D
MOONSW          EQUALS          65D
ESCPSW          EQUALS          MOONSW                  # INCICATE ELLIPTICAL ORBIT FLAG (=0)
SMANGLSW        EQUALS          MOONSW                  # VARIABLE SCALING SWITCH (=0)

# NOTE THAT FLAGWRD1 AND FLAGWRD2 CORRESPOND TO INTERPRETIVE SWITCHES 15D THROUGH 44D.  DAPBOOLS AND
#     FLAGWRD4 CORRESPOND TO INTERPRETIVE SWITCHES 45D THROUGH 74D.

#                                         FLAGWORD USAGE  * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#                                                  BIT    INTPR. SWITCH   USAGE
#                                                  ---    -------------   -----

#                                         FLAGWRD1  1                 29  AVERAGE G FLAG
#                                                   2                 28  GUIDANCE REFERENCE RELEASE FLAG
#                                                 3 - 7          27 - 23  NOT USED AT PRESENT
#                                                   8                 22  GIMBAL LOCK FLAG
#                                                 9 - 12         21 - 18  NOT USED AT PRESENT
#                                                  13                 17  EXCESSIVE TUMBLE FLAG
#                                                  14                 16  TUMBLE MONITOR FLAG
#                                                  15                 15  NOT USED AT PRESENT

#                                         FLAGWRD2  1                 44  RCS COLD SOAK INHIBIT FLAG
#                                                   2                 43  DPS COLD SOAK INHIBIT FLAG

## Page 14
#                                                     3                 42  RCS TESTING INHIBIT FLAG
#                                                     4                 41  NOT USED AT PRESENT
#                                                     5                 40  TIMERS ENABLED FLAG
#                                                     6                 39  V33 TERMINATION OF UPDATE PROGRAM FLAG
#                                                     7                 38  ORBITAL INTEGRATION INTEGRATING FLAG
#                                                     8                 37  ACS FEED TEST FLAG
#                                                     9                 36  ABORT COMMAND MONITOR ENABLED FLAG
#                                                    10                 35  ABORT STAGE FLAG
#                                                    11                 34  KALCMANU ATTITUDE COMPLETE FLAG
#                                                    12                 33  NO FINAL YAW
#                                                    13                 32  UPDATE PROCESS FLAG
#                                                    14                 31  GIMBAL LOCK FLAG
#                                                    15                 30  DRIFT FLAG

#                                          DAPBOOLS 1 - 15         45 - 59  DEFINED IN LOG SECTION "DAP INTERFACE
#                                                                           SUBROUTINES".

#                                          FLAGWRD4 1 - 9          74 - 66  NOT USED AT PRESENT
#                                                    10                 65  OUTSIDE MOONSPHERE (LOCKED AT 0) FLAG
#                                                    11                 64  LAMBERT QUADRANT FLAG
#                                                    12                 63  ITERATOR INITIALIZATION FLAG
#                                                    13                 62  LAMBERT ITERATOR FLAG
#                                                    14                 61  LAMBERT ROUTINE COMPLETION FLAG
#                                                    15                 60  LAMBERT ROUTINE CONVERGENCE FLAG

## Page 15

#          THE FOLLOWING ARE EXECUTIVE TEMPORARIES WHICH MAY BE USED BETWEEN CCS NEWJOB INQUIRIES.

INTB15+         ERASE                                   # REFLECTS 15TH BIT OF INDEXABLE ADDRESSES
DSEXIT          =               INTB15+                 # RETURN FOR DSPIN
EXITEM          =               INTB15+                 # RETURN FOR SCALE FACTOR ROUTINE SELECT
BLANKRET        =               INTB15+                 # RETURN FOR 2BLANK

INTBIT15        ERASE                                   # SIMILAR TO ABOVE.
WRDRET          =               INTBIT15                # RETURN FOR 5BLANK
WDRET           =               INTBIT15                # RETURN FOR DSPWD
DECRET          =               INTBIT15                # RETURN FOR PUTCOM(DEC LOAD)
21/22REG        =               INTBIT15                # TEMP FOR CHARIN

#          THE REGISTERS BETWEEN ADDRWD AND PRIORITY MUST STAY IN THE FOLLOWING ORDER FOR INTERPRETIVE TRACE.

ADDRWD          ERASE                                   # 12 BIT INTERPRETIVE OPERAND SUB_ADDRESS.

POLISH          ERASE                                   # HOLDS CADR MADE FROM POLISH ADDRESS.
UPDATRET        =               POLISH                  # RETURN FOR UPDATNN, UPDATVB
CHAR            =               POLISH                  # TEMP FOR CHARIN
ERCNT           =               POLISH                  # COUNTER FOR ERROR LIGHT RESET
DECOUNT         =               POLISH                  # COUNTER FOR SCALING AND DISPLAY (DEC)
PWRPTR          =               POLISH                  # ROOTPSRS PWR TABL POINTER

FIXLOC          ERASE                                   # WORK AREA ADDRESS.

OVFIND          ERASE                                   # SET NON-ZERO ON OVERFLOW.

VBUF            ERASE           +5                      # TEMPORARY STORAGE USED FOR VECTORS.
SGNON           =               VBUF                    # TEMP FOR +,- ON
NOUNTEM         =               VBUF                    # COUNTER FOR MIXNOUN FETCH
DISTEM          =               VBUF                    # COUNTER FOR OCTAL DISPLAY VERBS
DECTEM          =               VBUF                    # COUNTER FOR FETCH (DEC DISPLAY VERBS)

SGNOFF          =               VBUF            +1      # TEMP FOR +,- ON
NVTEMP          =               VBUF            +1      # TEMP FOR NVSUB
SFTEMP1         =               VBUF            +1      # STORAGE FOR SF CONST HI PART(=SFTEMP2-1)

CODE            =               VBUF            +2      # FOR DSPIN
SFTEMP2         =               VBUF            +2      # STORAGE FOR SF CONST LO PART(=SFTEMP1+1)
DXCRIT          =               VBUF            +2      # ROOTPSRS CRITERION FOR ENDING ITERS HI

MIXTEMP         =               VBUF            +3      # FOR MIXNOUN DATA
# ALSO MIXTEMP+1 = VBUF+4, MIXTEMP+2 = VBUF+5.
SIGNRET         =               VBUF            +3      # RETURN FOR +,- ON
DXCRIT+1        =               VBUF            +3      # ROOTPSRS CRITERION FOR ENDING ITERS LO

ROOTPS          =               VBUF            +4      # ROOTPSRS ROOT HI ORDER

ROOTPS+1        =               VBUF            +5      # ROOTPSRS ROOT LO ORDER

## Page 16
BUF             ERASE           +2                      # TEMPORARY SCALAR STORAGE.
INDEXLOC        EQUALS          BUF                     # CONTAINS ADDRESS OF SPECIFIED INDEX.
SWWORD          EQUALS          BUF                     # ADDRESS OF SWITCH WORD.

SWBIT           EQUALS          BUF             +1      # SWITCH BIT WITHIN SWITCH WORD.

RETROOT         =               BUF             +2      # ROOTPSRS RETURN ADDRESS OF USER

BUF2            ERASE           +1

MPTEMP          ERASE                                   # TEMPORARY USED IN MULTIPLY AND SHIFT
DMPNTEMP        =               MPTEMP                  # DMPNSUB TEMPORARY

DOTINC          ERASE                                   # COMPONENT INCREMENT FOR DOT SUBROUTINE.
DVSIGN          EQUALS          DOTINC                  # DETERMINES SIGN OF DDV RESULT.
ESCAPE          EQUALS          DOTINC                  # USED IN ARCSIN/ARCCOS.
ENTRET          =               DOTINC                  # EXIT FROM ENTER

DOTRET          ERASE                                   # RETURN FROM DOT SUBROUTINE.
DVNORMCT        EQUALS          DOTRET                  # DIVIDEND NORMALIZATION COUNT IN DDV.
ESCAPE2         EQUALS          DOTRET                  # ALTERNATE ARCSIN/ARCCOS SWITCH.
WDCNT           =               DOTRET                  # CHAR COUNTER FOR DSPWD
INREL           =               DOTRET                  # INPUT BUFFER SELECTOR ( X,Y,Z, REG )

MATINC          ERASE                                   # VECTOR INCREMENT IN MXV AND VXM.
MAXDVSW         EQUALS          MATINC                  # +0 IF DP QUOTIENT IS NEAR ONE - ELSE -1.
POLYCNT         EQUALS          MATINC                  # POLYNOMIAL LOOP COUNTER
DSPMMTEM        =               MATINC                  # DSPCOUNT SAVE FOR DSPMM
MIXBR           =               MATINC                  # INDICATOR FOR MIXED OR NORMAL NOUN
PWRCNT          =               MATINC                  # ROOTPSRS DER TABL LOOP COUNTER

TEM1            ERASE                                   # EXEC TEMP
POLYRET         =               TEM1
DSREL           =               TEM1                    # REL ADDRESS FOR DSPIN
DERPTR          =               TEM1                    # ROOTPSRS DER TABL POINTER

#          THE FOLLOWING 10 REGISTERS ARE USED FOR TEMPORARY STORAGE OF THE DERIVATIVE COEFFICIENT TABLE OF
# SUBROUTINE ROOTPSRS.  THEY MUST REMAIN WITHOUT INTERFERENCE WITH ITS SUBROUTINES WHICH ARE POWRSERS (POLY),
# DMPSUB, DMPNSUB, SHORTMP, DDV/BDDV, ABS, AND USPRCADR.

TEM2            ERASE                                   # EXEC TEMP
DSMAG           =               TEM2                    # MAGNITUDE STORE FOR DSPIN
IDADDTEM        =               TEM2                    # MIXNOUN INDIRECT ADDRESS STORAGE
DERCOF-8        =               MPAC            -12     # ROOTPSRS DER COF N-4 HI ORDER

TEM3            ERASE                                   # EXEC TEMP
COUNT           =               TEM3                    # FOR DSPIN
DERCOF-7        =               MPAC            -11     # ROOTPSRS DER COF N-4 LO ORDER

TEM4            ERASE                                   # EXEC TEMP

## Page 17
LSTPTR          =               TEM4                    # LIST POINTER FOR GRABUSY
RELRET          =               TEM4                    # RETURN FOR RELDSP
FREERET         =               TEM4                    # RETURN FOR FREEDSP
DERCOF-6        =               MPAC            -10     # ROOTPSRS DER COF N-3 HI ORDER

TEM5            ERASE                                   # EXEC TEMP
NOUNADD         =               TEM5                    # TEMP STORAGE FOR NOUN ADDRESS
DERCOF-5        =               MPAC            -7      # ROOTPSRS DER COF N-3 LO ORDER

NNADTEM         ERASE                                   # TEMP FOR NOUN ADDRESS TABLE ENTRY
DERCOF-4        =               MPAC            -6      # ROOTPSRS DER COF N-2 HI ORDER

NNTYPTEM        ERASE                                   # TEMP FOR NOUN TYPE TABLE ENTRY
DERCOF-3        =               MPAC            -5      # ROOTPSRS DER COF N-2 LO ORDER

IDAD1TEM        ERASE                                   # TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
                                                        # MUST = IDAD2TEM-1, = IDAD3TEM-2.
DERCOF-2        =               MPAC            -4      # ROOTPSRS DER COF N-1 HI ORDER

IDAD2TEM        ERASE                                   # TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
                                                        # MUST = IDAD1TEM+1, = IDAD3TEM-1.
DERCOF-1        =               MPAC            -3      # ROOTPSRS DER COF N-1 LO ORDER

IDAD3TEM        ERASE                                   # TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
                                                        # MUST = IDAD1TEM+2, = IDAD2TEM+1.
DERCOFN         =               MPAC            -2      # ROOTPSRS DER COF N   HI ORDER

RUTMXTEM        ERASE                                   # TEMP FOR SF ROUT TABLE ENTRY(MIXNN ONLY)
DERCOF+1        =               MPAC            -1      # ROOTPSRS DER COF N   LO ORDER

#          STORAGE USED BY THE EXECUTIVE.

MPAC            ERASE           +6                      # MULTI-PURPOSE ACCUMULATOR.
MODE            ERASE                                   # +1 FOR TP, +0 FOR DP, OR -1 FOR VECTOR.
LOC             ERASE                                   # LOCATION ASSOCIATED WITH JOB.
BANKSET         ERASE                                   # USUALLY CONTAINS BBANK SETTING.
PUSHLOC         ERASE                                   # WORD OF PACKED INTERPRETIVE PARAMETERS.
PRIORITY        ERASE                                   # PRIORITY OF PRESENT JOB AND WORK AREA.

                ERASE           +71D                    # SEVEN SETS OF 12 REGISTERS EACH.

## Page 18
# THE FOLLOWING REGISTERS ARE RESERVED FOR PINBALL



# RESERVED FOR PINBALL EXECUTIVE ACTION

DSPCOUNT        ERASE                                   # DISPLAY POSITION INDICATOR
DECBRNCH        ERASE                                   # +DEC, -DEC, OCT INDICATOR
VERBREG         ERASE                                   # VERB CODE
NOUNREG         ERASE                                   # NOUN CODE
XREG            ERASE                                   # R1 INPUT BUFFER
YREG            ERASE                                   # R2 INPUT BUFFER
ZREG            ERASE                                   # R3 INPUT BUFFER
XREGLP          ERASE                                   # LO PART OF XREG (FOR DEC CONV ONLY)
YREGLP          ERASE                                   # LO PART OF YREG (FOR DEC CONV ONLY)
ZREGLP          ERASE                                   # LO PART OF ZREG (FOR DEC CONV ONLY)
MODREG          ERASE                                   # MODE CODE
DSPLOCK         ERASE                                   # KEYBOARD/SUBROUTINE CALL INTERLOCK
REQRET          ERASE                                   # RETURN REGISTER FOR LOAD
LOADSTAT        ERASE                                   # STATUS INDICATOR FOR LOADTST
CLPASS          ERASE                                   # PASS INDICATOR CLEAR
NOUT            ERASE                                   # ACTIVITY COUNTER FOR DSPTAB
NOUNCADR        ERASE                                   # MACHINE CADR FOR NOUN
MONSAVE         ERASE                                   # N/V CODE FOR MONITOR. (= MONSAVE1-1)
MONSAVE1        ERASE                                   # NOUNCADR FOR MONITOR(MATBS) =MONSAVE +1
DSPTAB          ERASE           +11D                    # 0-10D, DISPLAY PANEL BUFF. 11D, C/S LTS.
CADRSTOR        ERASE                                   # ENDIDLE STORAGE
GRABLOCK        ERASE                                   # INTERNAL INTERLOCK FOR DISPLAY SYSTEM
NVQTEM          ERASE                                   # NVSUB STORAGE FOR CALLING ADDRESS
                                                        # MUST = NVBNKTEM-1
NVBNKTEM        ERASE                                   # NVSUB STORAGE FOR CALLING BANK
                                                        # MUST = NVQTEM+1
DSPLIST         ERASE           +2                      # WAITING LIST FOR DSP SYST INTERNAL USE
EXTVBACT        ERASE                                   # EXTENDED VERB ACTIVITY INTERLOCK
DSPTEM1         ERASE           +2                      # BUFFER STORAGE AREA 1 (MOSTLY FOR TIME)
DSPTEM2         ERASE           +2                      # BUFFER STORAGE AREA 2 (MOSTLY FOR DEG)
# END OF ERASABLES RESERVED FOR PINBALL EXECUTIVE ACTION



# RESERVED FOR PINBALL INTERRUPT ACTION

DSPCNT          ERASE                                   # COUNTER FOR DSPOUT
                                                        # RECEPTION OF A BAD MESSAGE IN UPLINK)
## RSB 2016 &mdash; Yes, the line above has no opening (.
# END OF ERASABLES RESERVED FOR PINBALL INTERRUPT ACTION

## Page 19
# ASSIGNMENTS FOR T4RUPT PROGRAM

T4LOC           ERASE
DSRUPTSW        ERASE
DIDFLG          ERASE
ALT             ERASE           +1
ALTRATE         ERASE
FINALT          ERASE           +1                      # (MAY NOT BE REQUIRED FOR FLIGHTS).
LGYRO           ERASE
FORVEL          ERASE
LATVEL          ERASE
LASTYCMD        ERASE
LASTXCMD        ERASE

ALTSAVE         ERASE           +1
# END OF T4RUPT ASSIGNMENTS



IMODES30        ERASE
IMODES33        ERASE
MODECADR        ERASE           +3
IMUCADR         EQUALS          MODECADR
AOTCADR         EQUALS          MODECADR        +1
OPTCADR         EQUALS          AOTCADR
RADCADR         EQUALS          MODECADR        +2
ATTCADR         EQUALS          MODECADR        +3

MARKSTAT        ERASE
XYMARK          ERASE
FLUSHREG        ERASE           +1                      # ***TEMPORARY FOR SPECIAL FAKESTRT ENEMA
                SETLOC          400

## Page 20
# TEMPORARY PHONY ASSIGNMENTS TO KEEP PINBALL FROM HAVING BAD ASSEMBLIES

THETAD          ERASE           +2
DELVX           ERASE           +5
# END OF PHONY ASSIGNMENTS


#          DOWNLINK LIST ADDRESS.
DNLSTADR        ERASE

# AGS DUMMY ID WORD
AGSWORD         ERASE
# RADAR ERASABLE

RADMODES        ERASE
SAMPLIM         ERASE
SAMPLSUM        ERASE           +1
SAMPSUM         EQUALS          SAMPLSUM
OPTYHOLD        ERASE           +1
TIMEHOLD        ERASE           +1
RRTARGET        EQUALS          SAMPLSUM                # HALF UNIT VECTOR IN SM OR NB AXES.
TANG            ERASE           +1                      # DESIRED TRUNNION AND SHAFT ANGLES.
MODEA           EQUALS          TANG
MODEB           ERASE           +1                      # DODES CLOBBERS TANG +2.
NSAMP           EQUALS          MODEB
DESRET          ERASE
OLDATAGD        EQUALS          DESRET                  # USED IN DATA READING ROUTINES.
DESCOUNT        ERASE
# END OF RADAR ERASABLE ASSIGNMENTS

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

PHASENUM        ERASE

# KALCMANU-DAP INTERFACE:

CDUXD           ERASE           +2                      # CDU DESIRED REGISTERS:
CDUYD           EQUALS          CDUXD           +1      # SCALED AT PI RADIANS (180 DEGREES)
CDUZD           EQUALS          CDUXD           +2      # (STORED IN 2' COMPLEMENT)

## Page 21

DELCDUX         ERASE           +2                      # NEGATIVE OF DESIRED 100MS CDU INCREMENT:
DELCDUY         EQUALS          DELCDUX         +1      # SCALED AT PI RADIANS (180 DEGREES)
DELCDUZ         EQUALS          DELCDUX         +2      # (STORED IN 2' COMPLEMENT)

OMEGAPD         ERASE           +2                      # ATTITUDE MANEUVER DESIRED RATES
OMEGAQD         EQUALS          OMEGAPD         +1      # (NOT EXPLICITLY REFERENCED IN GTS CNTRL)
OMEGARD         EQUALS          OMEGAPD         +2      # SCALED AT PI/4 RADIANS/SECOND

                SETLOC          1000
T5ADR           ERASE           +1                      # GENADR OF NEXT LM DAP T5RUPT. * 2CADR *
                                                        # BBCON  OF NXT LM DAP T5RUPT. * 2CADR *

T6NEXT          ERASE           +1                      # LIST OF TIME6 DT-S FOR JET LIST PROGRAM

T6NEXTJT        ERASE           +2                      # LIST OF JET POLICIES FOR JTLST PROGRAM

DELAYCTR        ERASE                                   # COUNTER FOR MINIMUM IMPULSE USE OF RHC

## Page 22
# ERASABLE ASSIGNMENTS FOR AVERAGE G INTEGRATOR:

RN              ERASE           +5
VN              ERASE           +5
GDT/2           ERASE           +5
UNITR           ERASE           +5
UNITW           ERASE           +5
RMAG            ERASE           +1

DELV            EQUALS          DELVX
RN1             ERASE           +5
VN1             ERASE           +5
GDT1/2          ERASE           +5
AVGEXIT         ERASE           +1
AVGOUTF         ERASE           +1
DVMNEXIT        =               AVGOUTF
# WAITLIST REPEAT FLAG:

RUPTAGN         ERASE
KEYTEMP2        =               RUPTAGN                 # TEMP FOR KEYRUPT, UPRUPT

# PHASE TABLE AND RESTART COUNTER.

## Page 23
# THE FOLLOWING ARE TO LOCATED IN UNSWITCHED ERRASSIBLE

# TBASE(I) ARE USED IN WAITLIST RESTARTS
# PHSPRDT(I) ARE USED TO STORE EITHER PRIORITY OR DELTA TIME FOR VARIABLE RESTARTS
# PHASE(I) AND -PHASE(I) ARE USED TO STORE THE PHASE INFORMATION AND PHASE INFORMATION COMPLEMENTED FOR EACH OF TH
# GROUPS

-PHASE1         ERASE
PHASE1          ERASE
-PHASE2         ERASE
PHASE2          ERASE
-PHASE3         ERASE
PHASE3          ERASE
-PHASE4         ERASE
PHASE4          ERASE
-PHASE5         ERASE
PHASE5          ERASE
-PHASE6         ERASE
PHASE6          ERASE

TBASE1          ERASE
PHSPRDT1        ERASE
TBASE2          ERASE
PHSPRDT2        ERASE
TBASE3          ERASE
PHSPRDT3        ERASE
TBASE4          ERASE
PHSPRDT4        ERASE
TBASE5          ERASE
PHSPRDT5        ERASE
TBASE6          ERASE
PHSPRDT6        ERASE

# ERASABLE FOR SINGLE PRECISION SUBROUTINES.

HALFY           ERASE
ROOTRET         ERASE
SQRARG          ERASE

TEMK            EQUALS          HALFY
SQ              EQUALS          ROOTRET

#          ERASABLE ASSIGNMETNS FOR LMP ROUTINES

LMPCMD          ERASE           +7                      # CIRCULAR BUFFER OF LAST 8 COMMANDS.
LMPIN           ERASE                                   # POINTS TO NEXT AVAILABLE INPUT SLOT.
LMPOUT          ERASE                                   # POINTS TO NEXT OUTPUT LOCATION IN BUFFER
LMPOUTT         ERASE                                   # INTERRIM STORAGE FOR THE ABOVE.
LMPRET          ERASE                                   # 2CADR RETURN ADDRESS FOR SUBROUTINES.
LMPBBANK        ERASE
SAVDT           ERASE

## Page 24
LONGCADR        ERASE           +1                      # UNSWITCHED ERASABLE FOR LONGCALC
LONGTIME        ERASE           +1

CMEMORY         ERASE           +10D

TEMX            EQUALS          CMEMORY
TEMY            EQUALS          CMEMORY         +1D
TEMZ            EQUALS          CMEMORY         +2D
TEMXY           EQUALS          CMEMORY         +3D
PIPAGE          EQUALS          CMEMORY         +4D


TEMTPREL        EQUALS          TEMX                    # DP TEMP FOR GYROCOMP TERMINATE TIME. MP2

1/PIPADT        EQUALS          CMEMORY         +7D
OLDBT1          EQUALS          1/PIPADT
# SERVICER RESTARTS

STORASE         EQUALS          CMEMORY         +5D
RTSPLOSH        EQUALS          CMEMORY         +6D
#   STORAGE FOR FOR MISSION TIMER/PHASE REGISTER PAIRS.

MTIMER4         ERASE
MTIMER3         ERASE
MTIMER2         ERASE
MTIMER1         ERASE
MPHASE4         ERASE
MPHASE3         ERASE
MPHASE2         ERASE
MPHASE1         ERASE
MTIMER4T        ERASE           +3                      # RESTART STORAGE AREAS FOR THE ABOVE.
MPHASE4T        ERASE           +3
MDUETEMP        ERASE
NEWMTIME        ERASE                                   # T1 AT MAINTENANCE TASK AFTER NEXT.
NEWTIMET        ERASE                                   # RESTART STORAGE FOR THE ABOVE.
MINH            ERASE
STATECTR        ERASE                                   # TIMER FOR INTERNAL STATE VECTOR UPDATES.

UPPHASE         ERASE                                   # NEW PHASE AS SENT UP THE UPLINK.
UPDT            ERASE                                   # NEW DT AS SENT UP THE UPLINK.
UPINDEX         ERASE                                   # INDEX OF TIMER MODIFIED BY UPLINK.
UPGET           ERASE           +1                      # GET FOR UPLINK REQUEST.

MRETURN         ERASE                                   # RETURN REGISTER.

# PMEMORY ASSIGNMENTS

PMEMORY         ERASE           +89D
REFRRECT        EQUALS          PMEMORY         +00D    # STATE VECTORS FOR ORBITAL INTEGRATION

## Page 25
REFVRECT        EQUALS          PMEMORY         +06D
DELTAV          EQUALS          PMEMORY         +12D    # STATE DEVIATIONS

NUV             EQUALS          PMEMORY         +18D
REFRCV          EQUALS          PMEMORY         +24D
REFVCV          EQUALS          PMEMORY         +30D
REFTC           =               REFTCV
REFTCV          EQUALS          PMEMORY         +36D
TE              EQUALS          PMEMORY         +38D    # TET,TIME CORRESPONDING TO LEM STATE
REFXKEP         EQUALS          PMEMORY         +40D    # ROOT TO KEPLER EQUATIONS
REFSMMAT        EQUALS          PMEMORY         +42D    # TRANSFORMATION MATRIX BETWEEN SM AND REF
PIPRETRN        EQUALS          PMEMORY         +60D
PIPTIME         EQUALS          PMEMORY         +62D
DVSELECT        EQUALS          PMEMORY         +64D
MASS            EQUALS          PMEMORY         +72D
CDUTEMP         EQUALS          PMEMORY         +80D    # VECTOR USED IN FINDCDUD

/ACF/           EQUALS          PMEMORY         +74D
/AF/            EQUALS          PMEMORY         +76D
PCNTF           EQUALS          PMEMORY         +75D
STATIME         EQUALS          PMEMORY         +78D    # DP DOWNLINK TIME-DONT VIOLATE THESE REGS
ALMCADR         EQUALS          PMEMORY         +80D    # DP
# ASSIGNMENTS RESERVED EXCLUSIVELY FOR SELF-CHECK
SELFERAS        ERASE           1355 - 1377

ERESTORE        =               1355
SELFRET         =               1356
SMODE           =               1357
REDOCTR         =               1360                    # KEEPS TRACK OF RESTARTS
SFAIL           =               1361                    # SFAIL,ERCOUNT,FAILREG(S) USED BY NOUN 31
ERCOUNT         =               1362                    #                        FOR ALARMS.
FAILREG         =               1363                    # FAILREG,+1,+2 USED BY NOUN 50 FOR ALARMS
SCOUNT          =               1366
SKEEP1          =               1371
SKEEP2          =               1372
SKEEP3          =               1373
SKEEP4          =               1374
SKEEP5          =               1375
SKEEP6          =               1376
SKEEP7          =               1377

# WAITLIST TASK LISTS

                SETLOC          1400

LST1            ERASE           +7                      # DELTA T'S.
LST2            ERASE           +17D                    # 2CADR TASK ADDRESSES.

LONGBASE        ERASE           +1                      # ERASABLE FOR LONGCALL
LONGEXIT        ERASE           +1

## Page 26
#          IMU COMPENSATION PARAMETERS:

PBIASX          ERASE                                   # PIPA BIAS AND PIPA SCALE FACTOR TERMS
PIPABIAS        =               PBIASX                  #     INTERMIXED.
PIPASCFX        ERASE
PIPASCF         =               PIPASCFX
PBIASY          ERASE
PIPASCFY        ERASE

PBIASZ          ERASE
PIPASCFZ        ERASE

NBDX            ERASE                                   # GYRO BIAS DRIFTS
GBIASX          =               NBDX
NBDY            ERASE
NBDZ            ERASE

ADIAX           ERASE                                   # ACCELERATION SENSITIVE DRIFT ALONG THE
ADIAY           ERASE                                   #     INPUT AXIS
ADIAZ           ERASE

ADSRAX          ERASE                                   # ACCELERATION SENSITIVE DRIFT ALONG THE
ADSRAY          ERASE                                   #     SPIN REFERENCE AXIS
ADSRAZ          ERASE

GCOMP           ERASE           +5                      # CONTAINS COMPENSATING TORQUES

GCOMPSW         ERASE
COMMAND         EQUALS          GCOMP
CDUIND          EQUALS          GCOMP    +3

#          STORAGE FOR RR TASKS.

RRRET           ERASE
RDES            ERASE
RRINDEX         ERASE

# AOT CALIBRATIONS IN AZIMUTH AND ELEVATION AT DETENTS
AOTAZ           ERASE           +2
AOTEL           ERASE           +2
#          ASSIGNMENTS FOR PRESENTLY UNUSED NOUNS.
AZANG           EQUALS                                  # DELETE WHEN OPTICAL TRACKER NOUNS GONE.
ELANG           EQUALS
DESLOTSY        EQUALS
DESLOTSX        EQUALS

ROLL            ERASE           +2
LANDMARK        ERASE           +5

# THE FOLLOWING REGS ARE USED BY THE STANDBY VERBS

## Page 27

TIMESAV         ERASE           +1
SCALSAV         ERASE           +1
TIMAR           ERASE           +1
TIMEDIFF        ERASE           +1

# THE FOLLOWING MAY BE PLACED IN SWITCHED ERRASSIBLE

# PHSNAME(I) AND PHSBB(I) STORE THE 2CADR FOR VARIABLE RESTARTS FOR EACH OF THE GROUPS
PHSNAME1        ERASE
PHSBB1          ERASE
PHSNAME2        ERASE
PHSBB2          ERASE
PHSNAME3        ERASE
PHSBB3          ERASE

PHSNAME4        ERASE
PHSBB4          ERASE
PHSNAME5        ERASE
PHSBB5          ERASE
PHSNAME6        ERASE
PHSBB6          ERASE

BCDU            ERASE           +2
MIS             ERASE           +17D
MFS             ERASE           +17D
TMIS            ERASE           +17D
TMFI            EQUALS          TMIS
COF             ERASE           +5
CPHI            ERASE
CTHETA          ERASE
CPSI            ERASE
MFI             EQUALS          MFS
COFSKEW         ERASE           +5
AM              ERASE           +1
MFISYM          EQUALS          TMIS
CAM             ERASE           +1
C2SQP           EQUALS          K2
C2SQM           EQUALS          K2              +2

C2PP            EQUALS          K2              +4
C2MP            EQUALS          K3
C1PP            EQUALS          K3              +2
C1MP            EQUALS          K3              +4
P21             EQUALS          K1
D21             EQUALS          K1              +2
G21             EQUALS          K1              +4
RAD             ERASE           +1
RSQ             ERASE           +1
E1              EQUALS          MFS
E2              EQUALS          MFS             +6
IG              EQUALS          COFSKEW
OGF             EQUALS          TMIS            +12D

## Page 28
K1              EQUALS          TMIS
K2              EQUALS          TMIS            +6
K3              EQUALS          TMIS            +12D
KEL             EQUALS          MFS
RATEINDX        ERASE
SPNDX           ERASE
MYNDX           ERASE
BRATE           EQUALS          COFSKEW
TM              EQUALS          CAM
NCDU            EQUALS          TMIS
NEXTIME         EQUALS          TMIS            +3
DELDCDU         EQUALS          DELCDUX
DELDCDU1        EQUALS          DELCDUY
DELDCDU2        EQUALS          DELCDUZ
TTEMP           EQUALS          TMIS            +4
POINTVSM        ERASE           +5
SCAXIS          ERASE           +5
RTN             ERASE
TAG5            ERASE
TF              ERASE           +1

COGAVAIL        ERASE           +1
SPLOC           ERASE           +2
UNR1            ERASE           +5
R0VEC           ERASE           +5
V0VEC           ERASE           +5
UNNORM          ERASE           +5
INDEP           ERASE           +1
TWEEKIT         ERASE           +1
DEPVAR          ERASE           +1
PREVDEP         ERASE           +1
DELDEP          ERASE           +1
DELINDEP        ERASE           +1
MININDEP        EQUALS          22D
MAXINDEP        EQUALS          26D
# RESTRTCS-RESTRTCS +77D IS USED FOR RESTART PROTECTION DURING PRELAUNCH

RESTRTCS        =               1600

                                                        # ERASABLE FOR MISSION PHASE TWO
TGRR            ERASE           +1                      #  TIME OF GUIDANCE REFERENCE RELEASE
TLIFTOFF        ERASE           +1                      #  TIME OF LIFTOFF
TPRELTER        ERASE           +1                      #  TIME OF GYROCOMPASSING TERMINATION
SAVEDT          ERASE           +1                      #  TEMPORARY FOR MP 2

DT-LIFT         ERASE           +1                      #  DT FROM GRR TO LIFTOFF
DT-DFITM        ERASE                                   #  DT FROM GRR TO DFI T/M CALIBRATION
ABORTNDX        EQUALS          DT-DFITM
DT-LETJT        ERASE           +1                      #  DT FROM LIFTOFF TO POST-LET JETTISON
AZGR            ERASE           +1                      #  PAD 37B VERTICAL TO REF X-Z PLANE.
TILT            ERASE           +1                      #  Y ABOUT Z IN REVS.
ZSMAZ           ERASE           +1                      #  Z FROM NORTH IN REVS.

## Page 29
TEPHEM          ERASE           +2                      # TP CS FROM 00:00:00 JULY 1 TO 00:00:00
                                                        # OF LAUNCH DAY.
MP6TO7          ERASE                                   # ERASABLE FOR MP6
MP8TO9          ERASE                                   # ERASABLE FOR MISSION PHASE 8

## Page 30
# ERASABLE ASSIGNMENTS FOR EBANK 4



                SETLOC          2000

AMEMORY         ERASE           +150D
#          THE FOLLOWING A MEMORY LOCATIONS ARE USED BY MID-COURSE NAVIGATION

# CAUTION: ORBITAL INTEGRATION REGISTERS RAVEGON, VAVEGON AND SECOND DPS GUIDANCE REGISTERS TPIP, TTF/4,
# TTF/4TMP, TULLG ARE ALL IN USE SIMULTANEOUSLY AND MUST NOT CONFLICT.

RRECT           EQUALS          AMEMORY         +000D
RIGNTION        EQUALS          AMEMORY         +000D
VRECT           EQUALS          AMEMORY         +006D
VIGNTION        EQUALS          AMEMORY         +006D
TDELTAV         EQUALS          AMEMORY         +012D
NEWDLTAV        EQUALS          AMEMORY         +012D
TNUV            EQUALS          AMEMORY         +018D
NEWNUV          EQUALS          AMEMORY         +018D
RCV             EQUALS          AMEMORY         +024D
FOUNDR          EQUALS          AMEMORY         +024D
VCV             EQUALS          AMEMORY         +030D
FOUNDV          EQUALS          AMEMORY         +030D
TC              EQUALS          AMEMORY         +036D
TET             EQUALS          AMEMORY         +038D
XKEP            EQUALS          AMEMORY         +040D
ALPHAV          EQUALS          AMEMORY         +042D
DELR            EQUALS          AMEMORY         +042D
BETAV           EQUALS          AMEMORY         +048D
DELVEL          EQUALS          AMEMORY         +048D
PHIV            EQUALS          AMEMORY         +054D

BVECTOR         EQUALS          AMEMORY         +054D
PSIV            EQUALS          AMEMORY         +060D
FV              EQUALS          AMEMORY         +066D

VECTAB          EQUALS          AMEMORY         +072D

TAVEGON         EQUALS          AMEMORY         +072D
TRESUME         EQUALS          AMEMORY         +074D
RAVEGON         EQUALS          AMEMORY         +076D   # SEE CAUTION ABOVE
VAVEGON         EQUALS          AMEMORY         +082D   # SEE CAUTION ABOVE
RIG-2SEC        EQUALS          AMEMORY         +088D
ALPHAM          EQUALS          AMEMORY         +108D
BETAM           EQUALS          AMEMORY         +110D
TAU             EQUALS          AMEMORY         +112D
GIVENT          EQUALS          AMEMORY         +112D
DT/2            EQUALS          AMEMORY         +114D
H               EQUALS          AMEMORY         +116D
TDEC            EQUALS          AMEMORY         +118D

## Page 31
FBRANCH         EQUALS          AMEMORY         +120D
HBRANCH         EQUALS          AMEMORY         +121D
GMODE           EQUALS          AMEMORY         +122D
QREADY          EQUALS          AMEMORY         +123D
MEASQ           EQUALS          AMEMORY         +124D
DELTAQ          EQUALS          AMEMORY         +126D

MEASMODE        EQUALS          AMEMORY         +128D
NVCODE          EQUALS          AMEMORY         +129D
MIDEXIT         EQUALS          AMEMORY         +130D
DSPRTRN         EQUALS          AMEMORY         +130D
INCORPEX        EQUALS          AMEMORY         +131D
STEPEXIT        EQUALS          AMEMORY         +132D
DIFEQCNT        EQUALS          AMEMORY         +133D

NORMGAM         EQUALS          AMEMORY         +133D
SCALEA          EQUALS          AMEMORY         +134D
SCALEB          EQUALS          AMEMORY         +135D
YV              EQUALS          AMEMORY         +139D
ZV              EQUALS          AMEMORY         +145D

## Page 32
# VARIABLES FOR SECOND DPS GUIDANCE

# CAUTION: ORBITAL INTEGRATION REGISTERS RAVEGON, VAVEGON AND SECOND DPS GUIDANCE REGISTERS TPIP, TTF/4,
# TTF/4TMP, TULLG ARE ALL IN USE SIMULTANEOUSLY AND MUST NOT CONFLICT.

# 2DPS PRESENTLY RECEIVES CERTAIN VARIABLES FROM THE ORBITAL INTEGRATION PROGRAM IN REGISTERS USED IN COMMON BY
# THE TWO PROGRAMS. THESE VARIABLES ARE TET, RIGNTION, VIGNTION. 2DPS CAREFULLY TRANSFERS THESE VARIABLES TO
# REGISTERS OF PROGRAM CALCRVG BEFORE WRITING INTO THE REGISTERS IN WHICH THESE VARIABLES ARRIVE.

# SOME TIME SHARING OF 2DPS REGISTERS BY 2DPS VARIABLES HAS BEEN ARRANGED. MORE IS POSSIBLE.
# BUT IT BECOMES INCREASINGLY DIFFICULT TO PROVE RESTARTABILITY.

E2DPS           =               AMEMORY

# CONTROL VARIABLES

NDX2DPS         =               E2DPS
NDXBR           =               NDX2DPS         +1
FLPASS0         =               NDXBR           +1
COUNTFC         =               FLPASS0         +1
COUNTFCT        =               COUNTFC         +1

# ADDRESS VARIABLES

AVGXTEMP        =               COUNTFCT        +1
RETNTLZ         =               AVGXTEMP        +1
RETXIGN1        =               RETNTLZ         +1
RETTHRT         =               RETXIGN1        +1

# COORDINATE FRAME VECTORS AND MATRICES

CLT/2           =               RETTHRT         +1

# TABLES

TABLTTF         =               CLT/2           +22

# STATE VARIABLES

PIPTIMET        =               TABLTTF         +11
TPIP            =               PIPTIMET        +2      # SEE CAUTION ABOVE
TPIPOLD         =               TPIP            +2
TTF/4           =               TPIPOLD         +2      # SEE CAUTION ABOVE

TTF/4TMP        =               TTF/4           +2      # SEE CAUTION ABOVE
TULLG           =               TTF/4TMP        +2      # SEE CAUTION ABOVE
R               =               TULLG           +2
RLENGTH         =               R               +6
V               =               RLENGTH         +2
VL              =               V               +6
RP2             =               VL              +6

## Page 33
MAP2            =               RP2             +2
RC              =               MAP2            +2

RS              =               RC              +2
RTEMP           =               RS
VS              =               RS              +6
VTEMP           =               VS
CRS2            =               VS              +6
SRS2            =               CRS2            +2
TRS2            =               SRS2            +2
ASPRT           =               TRS2            +2

# AFC CALCULATION VARIABLES, QUADRATIC AND LINEAR

ACS             =               ASPRT           +6
AFCS            =               ACS             +6
AFC             =               AFCS            +6
/AFC/           =               AFC             +6
/AFC/OLD        =               /AFC/           +2
UNAFC/2         =               /AFC/OLD        +2
UNAFC/20        =               UNAFC/2         +6
ALINS           =               UNAFC/20        +6
GDUMPRES        =               ALINS
JLINS           =               ALINS           +6
GDOTM1          =               JLINS

# ASSIGNMENTS WITHIN THE WORK AREA

PDUM            =               6
RDUM            =               10
VDUM            =               16
ADUM            =               40                      # ONLY ADUM CAN USE THE AREA DESTROYED BY
JDUM            =               24                      # TAKING THE UNIT OF RDUM IN SUBR GDUMCL.
GDUM            =               32                      # PLACE GDUM TO PRESERVE /RDUM/ FOR OTHERS

#          COMPLETES SECOND DPS ERASABLES (EXCEPT FOR CPT6/2 WHICH IS ASSIGNED ELSEWHERE)

## Page 34
# ERASABLES FOR ASCENT GUIDANCE



# ERASABLES FOR PREAPS2

PAXIS1          EQUALS          AMEMORY                 # VECTOR
QAXIS           EQUALS          AMEMORY         +6D     # VECTOR

SAXIS           EQUALS          AMEMORY         +12D    # VECTOR
AT              EQUALS          AMEMORY         +18D    # DP    *  DO       *
1/VE            EQUALS          AMEMORY         +20D    # DP    *  NOT      *
TBUP            EQUALS          AMEMORY         +22D    # DP    *  CHANGE    *
ATMEAS          EQUALS          AMEMORY         +24D    # (4)   *  THE      *
KR              EQUALS          AMEMORY         +28D    # DP    *  ORDER    *
KR1             EQUALS          AMEMORY         +30D    # DP    *  OF       *
RDOTD           EQUALS          AMEMORY         +32D    # DP    *  THESE    *
YDOTD           EQUALS          AMEMORY         +34D    # DP    *  LOCATIONS*
ZDOTD           EQUALS          AMEMORY         +36D    # DP    *************
RRETURN         EQUALS          AMEMORY         +38D    # DP
ASCRET          EQUALS          AMEMORY         +40D    # SP



# ERASABLES FOR ASCENT

LAMPRIO         EQUALS          AMEMORY         +41D    # SP
TCO             EQUALS          AMEMORY         +42D    # DP
TREF            EQUALS          AMEMORY         +44D    # DP
UT              EQUALS          AMEMORY         +46D    # VECTOR
YCONS           EQUALS          AMEMORY         +52D    # DP
YDOT            EQUALS          AMEMORY         +54D    # DP

LAXIS           EQUALS          AMEMORY         +56D    # VECTOR
ZAXIS           EQUALS          AMEMORY         +62D    # VECTOR
ZDOT            EQUALS          AMEMORY         +68D    # DP
TIME            EQUALS          AMEMORY         +70D    # DP
GEFF            EQUALS          AMEMORY         +72D    # DP
PCONS           EQUALS          AMEMORY         +74D    # DP

# ***  THE REGISTERS AMEMORY +76D THRU AMEMORY +87D CONTAIN RAVEGON AND VAVEGON, AND MUST NOT BE USED BY THE
# ASCENT EQUATIONS. *********

PRATE           EQUALS          AMEMORY         +88D    # DP
H1              EQUALS          AMEMORY         +90D    # VECTOR
RCOV            EQUALS          AMEMORY         +96D    # VECTOR
RDOT            EQUALS          AMEMORY         +102D   # DP
RY              EQUALS          AMEMORY         +104D   # DP
URCO            EQUALS          AMEMORY         +106D   # VECTOR

## Page 35
# ERASABLES FOR THRUST MAGNITUDE FILTER

1/DV1           EQUALS          AMEMORY         +112D   # DP
1/DV2           EQUALS          AMEMORY         +114D   # DP
ABDVCONV        EQUALS          AMEMORY         +116D   # DP
TFL             EQUALS          AMEMORY         +118D   # DP



# SWITCHES USED BY ASCENT GUIDANCE
HC              EQUALS          59D
PASS            EQUALS          58D
DIRECT          EQUALS          57D

## Page 36
# ERASABLES USED IN ORBITAL INTEGRATION

PBODY           ERASE                                   # USED IN ORBITAL INTEGRATION
W               EQUALS          PBODY           +1      # UNUSED IN 206, BUT REFERRED TO BY
                                                        # ORBITAL INTEGRATION

AVMIDRTN        ERASE           +1                      # RETURN ADDRESS FROM AVETOMID OR MIDTOAVE



# THE FOLLOWING ARE USED BY FINDCDUD

AXISD           ERASE           +5                      # VECTOR
AXIS            ERASE           +5                      # VECTOR
COSCDU          ERASE           +5                      # VECTOR
SINCDU          ERASE           +5                      # VECTOR
RETSAVE         EQUALS          X2                      # SAVE QPRET IN UNUSED X2



# ERASABLES FOR MISSION PHASES 7,9,11,13

# MISSION PHASE 7

DT2TEMP         ERASE
DT2TEMPD        ERASE           +1

# MISSION PHASE 9

SHJUMP1         EQUALS          DT2TEMP
TDI             ERASE           +1
TTHRUST         EQUALS          DT2TEMPD
TIGN            ERASE           +1
UNITVG          ERASE           +5

# MISSION PHASES 11 AND 13

MPRETRN         EQUALS          DT2TEMP
DT11TEMP        EQUALS          DT2TEMPD

## Page 37
# ERASABLE STORAGE FOR UPDATES  -  NON SHARABLE

STBUFF          ERASE           +15
STCOUNT         ERASE
UPOLDMOD        ERASE
UPTEMP          ERASE
UPTEMP1         ERASE
UPVERB          ERASE
COMPNUMB        ERASE



# ERASABLE STORAGE FOR DOWNLINK  -  LIMITED SHARING POSSIBLE

TEVENT          ERASE           +1                      # TIME OF GRR,LIFTOFF,ENGINE ON/OFF
VDVECT          ERASE           +5                      # VELOCITY DESIRED
VGVECT          ERASE           +5                      # VELOCITY TO BE GAINED
RD              ERASE           +5                      # POSITION DESIRED
TTGO            ERASE           +1                      # TIME TO GO IN CENTISECONDS.

TGO             EQUALS          TTGO                    # TEMPORY DEFINITION, TO BE MOVED.

# EBANK 4 NON SHARABLE ERASABLE LOAD STORAGE

E4LOAD          ERASE           2351 - 2377


MPDTO8          EQUALS          E4LOAD          +1      # DELTA TIME FROM MP7 TO MP8

MP9-11DT        EQUALS          E4LOAD          +1      # DELTA TIME FROM MP9 TO MP11

MP11TO13        EQUALS          E4LOAD          +2      # DELTA TIME FROM MP11 TO MP13

RP              EQUALS          E4LOAD          +3      # DP TARGET PARAMETER FOR DPS1 BURN

CPT6/2          EQUALS          E4LOAD          +5      # VECTOR TARGET PARAMETER FOR DPS2 BURN

R1VEC           EQUALS          E4LOAD          +13     # VECTOR TARGET PARAMETER FOR APS2 BURN

TINT            EQUALS          E4LOAD          +21     # DP TARGET PARAMETER FOR APS2 BURN

RCO             EQUALS          E4LOAD          +23     # DP TARGET PARAMETER FOR APS2 BURN

#                                        E4LOAD +25 THRU E4LOAD +27 ARE STILL AVAILABLE

## Page 38
# ERASABLES FOR MASS UPDATE (A PART OF AVERAGE G) AND THROTTLE CONTROL

# INITIAL VALUES FOR MASS

MASSES          =               SAVERASE        +26D
LEMMASS1        =               MASSES                  # MASS OF LEM JUST AFTER SIVB SEPARATION
LEMMASS2        =               MASSES          +2      # MASS OF LEM JUST AFTER DPS SEPARATION

# ERASABLES FOR MASS UPDATE ROUTINE

EVEX            =               SAVERASE        +30D
VEXDEX          =               EVEX
PREFORCE        =               EVEX            +1
VEXNOM          =               EVEX            +3
DELAREA         =               EVEX            +5
AREARATE        =               EVEX            +7
NEGVEX          =               EVEX            +11
DAREATMP        =               EVEX            +13
MASSTEMP        =               EVEX            +15

# ERASABLES FOR THROTTLE CONTROL

ETHROT          =               SAVERASE        +41D
FOLD            =               ETHROT
FCOLD           =               ETHROT          +2
FC              =               ETHROT          +3
PIF             =               ETHROT          +5
RTNHOLD         =               ETHROT          +7

## Page 39
#

#  THE FOLLOWING ERASABLE REGISTERS ARE USED BY THE  ENTRY AND INITIALIZATION JOB OF THE FCS TEST FOR LEM.

FCSCNTR         EQUALS          AMEMORY         +000D

#   THE FOLLOWING ERASABLE REGISTERS ARE USED BY THE JETSET TASK.

# (OPTIMUM PRELAUNCH A C USES JETSTEP-JETSTEP +77D FOR RESTART PROOF)

XJBUF           EQUALS          AMEMORY         +001D
YZJBUF          EQUALS          AMEMORY         +002D
JFBUF           EQUALS          AMEMORY         +003D

FCNTR           EQUALS          AMEMORY         +004D
THBUF           EQUALS          AMEMORY         +005D
OFFTMBUF        EQUALS          AMEMORY         +006D
JETSTEP         EQUALS          AMEMORY         +007D
NTIMES          EQUALS          AMEMORY         +008D
NEXTTIME        EQUALS          AMEMORY         +016D
JETONTM         EQUALS          AMEMORY         +024D
XJETS           EQUALS          AMEMORY         +032D
YZJETS          EQUALS          AMEMORY         +040D
JETOFFTM        EQUALS          AMEMORY         +048D

#     THE FOLLOWING ERASABLE REGISTERS ARE USED BY THE ENGINE ON-OFF TASK.

ENGSTEP         EQUALS          AMEMORY         +056D
CYLTIMES        EQUALS          AMEMORY         +057D
NEXTCYLT        EQUALS          AMEMORY         +060D
ONTIME          EQUALS          AMEMORY         +063D
OFFTIME         EQUALS          AMEMORY         +066D
OFFTIMER        EQUALS          AMEMORY         +069D

#    THE FOLLOWING ERASABLE REGISTERS ARE USED BY THE TRIM TASK.

TRIMSTEP        EQUALS          AMEMORY         +072D

NUMTIMES        EQUALS          AMEMORY         +073D
STEPDLYT        EQUALS          AMEMORY         +085D
TRIMONT         EQUALS          AMEMORY         +097D
TRIMOFFT        EQUALS          AMEMORY         +109D
TRIMIND         EQUALS          AMEMORY         +121D

#    THE FOLLOWING ERASABLE REGISTERS ARE USED BY THE THROTTLE TASK.

THRTSTEP        EQUALS          AMEMORY         +133D
DOTIMES         EQUALS          AMEMORY         +134D
DELAY           EQUALS          AMEMORY         +140D
THR1TIME        EQUALS          AMEMORY         +146D
THCOMM1         EQUALS          AMEMORY         +152D

## Page 40
THCOMM2         EQUALS          AMEMORY         +158D

#  THE FOLLOWING ERASABLE REGISTERS ARE USED BY THE INTERFACE LOOK TASK.

30BUF1          EQUALS          AMEMORY         +164D
30BUF0          EQUALS          AMEMORY         +168D
QUITLOOK        EQUALS          AMEMORY         +172D
CHCNTR          EQUALS          AMEMORY         +173D

                SETLOC          2400
# THE FOLLOWING ERASABLE LOCATIONS ARE UTILIZED BY THE IN-FLIGHT ALIGNMENT ROUTINES

XSM             ERASE           +17D
YSM             =               XSM             +6
ZSM             =               XSM             +12D
XDC             ERASE           +17D
YDC             =               XDC             +6
ZDC             =               XDC             +12D
XNB             =               XDC
YNB             =               XDC             +6

ZNB             =               XDC             +12D
STARAD          ERASE           +17D
STAR            ERASE           +5
SAC             ERASE           +1
PAC             ERASE           +1
OGC             ERASE           +1
IGC             ERASE           +1
MGC             ERASE           +1
ZPRIME          =               22D
PDA             =               22D
COSTH           =               16D
SINTH           =               18D
THETA           =               20D
STARM           =               32D



# THE FOLLOWING ERASABLE LOCATIONS ARE UTILIZED BY THE SYSTEM TESTS

AZIMUTH         ERASE           +1
LATITUDE        ERASE           +1

EROPTN          ERASE
ERVECTOR        ERASE           +5
GYROD           ERASE           +5
LENGTHOT        ERASE
LOSVEC          ERASE           +5
NBPOS           ERASE
NDXCTR          ERASE
PIPANO          ERASE

## Page 41
PIPINDEX        ERASE
PIPNDX          ERASE           +1

POSITON         ERASE
QPLAC           ERASE
QPLACE          ERASE
QPLACES         ERASE
RUN             ERASE
STOREPL         ERASE
SOUTHDR         ERASE
TAZEL1          ERASE           +5
TEMPTIME        ERASE           +1
TESTNO          ERASE
TMARK           ERASE           +1
SHAFTA          ERASE
TRUNA           ERASE
GENPL           ERASE           +134D

CDUTIMEI        =               GENPL
CDUTIMEF        =               GENPL           +2
CDUDANG         =               GENPL           +4
CDUREADF        =               GENPL           +5
CDUREADI        =               GENPL           +6
CDULIMIT        =               GENPL           +7

TEMPADD         =               GENPL           +4
TEMP            =               GENPL           +5
NOBITS          =               GENPL           +6
CHAN            =               GENPL           +7

LOS1            =               GENPL           +8D
LOS2            =               GENPL           +14D

CALCDIR         EQUALS          GENPL           +20D
CDUFLAG         EQUALS          GENPL           +21D
GYTOBETQ        EQUALS          GENPL           +22D
OPTNREG         EQUALS          GENPL           +23D
SAVE            EQUALS          GENPL           +24D    # THREE CONSEC LOC
SFCONST1        EQUALS          GENPL           +27D
TIMER           EQUALS          GENPL           +28D

DATAPL          EQUALS          GENPL           +30D
RDSP            EQUALS          GENPL                   # FIX LATER    POSSIBLY KEEP1
MASKREG         EQUALS          GENPL           +64D
CDUNDX          EQUALS          GENPL           +66D
RESULTCT        EQUALS          GENPL           +67D
COUNTPL         EQUALS          GENPL           +70D

CDUANG          EQUALS          GENPL           +71D
AINLA           =               GENPL                   # 110 DEC OR 156 OCT LOCATIONS

## Page 42
WANGO           EQUALS          AINLA                   # VERT ERATE
WANGI           EQUALS          AINLA           +2D     # HORIZONTAL ERATE
WANGT           EQUALS          AINLA           +4D     # T
TORQNDX         =               WANGT
DRIFTT          EQUALS          AINLA           +6D
ALX1S           EQUALS          AINLA           +8D
CMPX1           EQUALS          AINLA           +9D     # IND
ALK             EQUALS          AINLA           +10D    # GAINS
VLAUNS          EQUALS          AINLA           +22D
THETAX          =               VLAUNS
WPLATO          EQUALS          AINLA           +24D
INTY            EQUALS          AINLA           +28D    # SOUTH PIP INTE
ANGZ            EQUALS          AINLA           +30D    # EAST AXIS
INTZ            EQUALS          AINLA           +32D    # EAST PIP I
ANGY            EQUALS          AINLA           +34D    # SOUTH
THETAN          =               INTY
ANGX            EQUALS          AINLA           +36D    # VE
DRIFTO          EQUALS          AINLA           +38D    # VERT
DRIFTI          EQUALS          AINLA           +40D    # SOU
VLAUN           EQUALS          AINLA           +44D
FILDELV         =               VLAUN
ACCWD           EQUALS          AINLA           +46D
INTVEC          =               ACCWD
POSNV           EQUALS          AINLA           +52D
DPIPAY          EQUALS          AINLA           +54D    # SOUTH
DPIPAZ          EQUALS          AINLA           +58D    # NORTH PIP INCREMENT
ALTIM           EQUALS          AINLA           +60D
ALTIMS          EQUALS          AINLA           +61D    #  INDEX
ALDK            EQUALS          AINLA           +62D    #  TIME CONSTAN
DELM            EQUALS          AINLA           +76D
WPLATI          EQUALS          AINLA           +84D
GEOSAVED        EQUALS          AINLA           +86D

PREMTRXC        EQUALS          AINLA           +87D
PRELMTRX        EQUALS          AINLA           +88D
TRANSM1         =               PRELMTRX
GEOCOMPS        EQUALS          AINLA           +106D
GTSOPNDZ        EQUALS          AINLA           +107D
1SECXT          EQUALS          AINLA           +108D
GTSWTLST        EQUALS          AINLA           +109D
ERECTIME        EQUALS          AINLA           +110D
GEOMTRX         EQUALS          AINLA           +111D
ERCOMP          EQUALS          AINLA           +129D
ZERONDX         EQUALS          AINLA           +135D



BMEMORY         EQUALS          GENPL
DELVY           EQUALS          DELVX           +2
DELVZ           EQUALS          DELVX           +4

## Page 43
#          TUMBLE MONITOR

PCDUX           EQUALS          E
PCDUY           EQUALS          EDOT(2)
PCDUZ           EQUALS          ER
DCDUY           EQUALS          OMEGAQ
DCDUZ           EQUALS          OMEGAR
OMEGA           EQUALS          EDOTP
                SETLOC          3400

#          DOWNLINK STORAGE.

LDATALST        ERASE
DNTMGOTO        ERASE

TMINDEX         ERASE
DNQ             ERASE                                   # RETURN ADDRESS OF DOWNLINK SUBROUTINES
DNTMBUFF        ERASE           +21D                    # SNAPSHOT BUFFER.

#          RADAR TEST STORAGE.

RTSTDEX         ERASE
RTSTMAX         ERASE                                   # 66 FOR HI SPEED, 6 FOR LOW SPEED RR,
                                                        # AND 18 FOR LOW SPEED LR.
RTSTBASE        ERASE                                   # USED FOR CYCLIC SAMPLING.
RTSTLOC         ERASE                                   # GOES 0(6)RTSTMAX
RSTKLOC         EQUALS          RTSTLOC
RSAMPDT         ERASE                                   # PNZ FOR CYCLIC SAMPLING, -1 FOR HI SPEED
                                                        # INSERT +0 HERE MANUALLY TO TERMINATE TST
RFAILCNT        ERASE
RSTACK          ERASE           +71D                    # BUFFERS FOR RADAR TESTING.

# AGS INITIALIZATION
AGSBUF          ERASE           +27D
#          STORAGE FOR INBIT SCANNER.

LAST30          ERASE           +2                      # LAST SAMPLED INBITS.
MSGCNT          ERASE

# THE COMPTORK REGISTERS ARE REDUNDANT WITH THETAN FOR DOWNLINK PURPOSES.

COMPTORK        ERASE           +5                      # V, S, E GYROCOMPASS GYRO TORQUES.

#            BMEMORY USED FOR CONSECUTIVE ASSIGNMENTS FOR SERVICER RESTART
SAVERASE        EQUALS          2506
DVTOTAL         EQUALS          SAVERASE        +000D
DVCNTR          EQUALS          SAVERASE        +003D
PIPCTR          EQUALS          SAVERASE        +004D
VR              EQUALS          SAVERASE        +005D
VGCNTR          EQUALS          SAVERASE        +012D
ERRORSUM        EQUALS          SAVERASE        +013D

## Page 44
DIFFANG         EQUALS          SAVERASE        +019D
STREXIT         EQUALS          SAVERASE        +021D


ABDELV          EQUALS          SAVERASE        +022D
SWITCH          EQUALS          SAVERASE        +24D
NEGXDV          EQUALS          SAVERASE        +25D

## Page 45
# DIGITAL AUTOPILOT ERASABLE TAKES UP EBANK 6:

# THESE TWO ARE GOING TO MOVE WHEN KALCMANU COMES INTO SUNBURST:

                SETLOC          3000

# AXIS TRANSFORMATION MATRIX - PILOT TO GIMBAL AXES:

MR12            ERASE                                   # SCALED AT 2   THESE FOUR P-G MATRIX ELE-
MR22            ERASE                                   # SCALED AT 1   MENTS ARE IN THIS ORDER TO
MR13            ERASE                                   # SCALED AT 2   COMPUTE RATE HOLD DELCDUS
MR23            ERASE                                   # SCALED AT 1   WITH AN INDEXED LOOP

# AXIS TRANSFORMATION MATRIX - GIMBAL TO PILOT AXES:

M11             ERASE                                   # SCALED AT 1
M21             ERASE                                   # SCALED AT 1
M31             ERASE
M22             EQUALS          MR22                    # SCALED AT 1
M32             EQUALS          MR23                    # SCALED AT 1

# ANGLE MEASUREMENTS.

EDOT            ERASE           +1                      # ERROR IN ANGULAR RATE:
EDOT(R)         EQUALS          EDOT            +1      # SCALED DOWN TO PI/16 RADIANS/SECOND

E               ERASE           +1                      # ANGLE ERROR SCALED AT PI RADIANS
EDOT(2)         EQUALS          E               +1      # ERROR RATE SQUARED SCALED AT PI(2)/16
EQ              EQUALS          E                       # THIS PAIR OF NAMES IS USED TO REFER TO
EDOT(2)Q        EQUALS          EDOT(2)                 # THE ABOVE ERASABLES AS Q-AXIS DATA
ER              ERASE           +1                      # THIS PAIR OF NAMES REFERS TO LOCATIONS
EDOT(2)R        EQUALS          ER              +1      # FOR THE R-AXIS DATA: INTERCHANGES WITH Q

DB              ERASE                                   # ANGLE DEADBAND SCALED AT PI RADIANS

OMEGAP          ERASE           +4                      # BODY-AXIS ROT. RATES SCALED AT PI/4 AND
OMEGAQ          EQUALS          OMEGAP          +1      # BODY-AXIS ACCELERATIONS SCALED AT PI/8
ALPHAQ          EQUALS          OMEGAP          +2      # (IN DESCENT) OR PI/2 (IN ASCENT)
OMEGAR          EQUALS          OMEGAP          +3      # THESE W,A PAIRS ARE NEEDED, ALPHAP HAS
ALPHAR          EQUALS          OMEGAP          +4      # NO USE IN THE DIGITAL AUTOPILOT

EDOTP           ERASE           +2                      # ERRORS IN ANGULAR RATE:
EDOTQ           EQUALS          EDOTP           +1      # EDOT = 3MEGA - OMEGA(DESIRED)
EDOTR           EQUALS          EDOTP           +2      # SCALED AT PI/4 RADIANS/SECOND

QRATEDIF        EQUALS          EDOTQ                   # ALTERNATIVE NAMES:
RRATEDIF        EQUALS          EDOTR                   # DELETE WHEN NO. OF REFERENCES = 0

OLDXFORP        ERASE           +3                      # STORED CDU READINGS FOR P AND Q,R RATE
OLDYFORP        EQUALS          OLDXFORP        +1      # DERIVATIONS: SCALED AT PI RADIANS (2'S)

## Page 46
OLDYFORQ        EQUALS          OLDXFORP        +2      # (THERE MUST BE TWO REGISTERS FOR CDUY
OLDZFORQ        EQUALS          OLDXFORP        +3      # SINCE P AND Q,R ARE NOT IN PHASE)

# RHC INPUTS SCALED AT PI/4 RAD/SEC.

PCOM            ERASE
RCOM            ERASE
YCOM            ERASE

# RHC COUNTER REGISTERS.

P-RHCCTR        EQUALS          43
Q-RHCCTR        EQUALS          42
R-RHCCTR        EQUALS          44

# OTHER VARIABLES.

TJETSIGN        ERASE                                   # =+/-BIT1 TO SHOW SIGN OF P-AXIS ROTATION
PRATECOM        ERASE
EDOTGEN         ERASE
RATEDIF         ERASE
1/2JTSP         ERASE
FPQR            ERASE
MINRA           ERASE
MINRASQ         ERASE
HDAP            ERASE
FCT1            EQUALS          HDAP
U               ERASE
DENOM           ERASE
RATIO           ERASE
L,PVT-CG        ERASE
IXX             ERASE

IYY             ERASE
IZZ             ERASE
4JETTORK        ERASE
JETTORK4        ERASE
COSMG           ERASE
DELTAP          EQUALS          ITEMP2
FPQRMIN         ERASE
NJET            ERASE
PRATEDIF        ERASE
LASTPER         ERASE                                   # THESE 6 REG USED FOR ATT ERR DISPLAY
LASTQER         ERASE
LASTRER         ERASE
PERROR          ERASE
QERROR          ERASE
RERROR          ERASE

# JET STATE CHANGE VARIABLES- TIME (TOFJTCHG),JET BITS WRITTEN NOW
#   (JTSONNOW), AND JET BITS WRITTEN AT T6 RUPT (JTSATCHG).

## Page 47
JTSONNOW        ERASE
JTSATCHG        ERASE
ADDT6JTS        ERASE
ADDTLT6         ERASE
TOFJTCHG        ERASE

-RATEDB         ERASE
-2JETLIM        ERASE

# RCS FAILURE MONITOR ERASABLE . PROGRAM ON T4RUPT 4 TIMES/SECOND

# *** FAILSW CAPABILITY FOR CHECKOUT ONLY ***

FAILSW          ERASE                                   # IF POSITIVE NO RCSMONIT, OTHERWISE 0

LASTFAIL        ERASE                                   # LAST FAILURE CHANNEL RECORD, -0 INITIAL
CH5MASK         ERASE                                   # MASKS FOR TURNING ON P/Q,R JETS
CH6MASK         ERASE                                   # IN OUTPUT CHANNELS 5 AND 6
FAILCTR         EQUALS          ITEMP1                  # BIT POSITION COUNTER (INTERNAL)
FAILTEMP        EQUALS          ITEMP2                  # TEMPORARY RECORD OF FAILED BITS

# Q,R AXIS ERASABLES

DELQ            EQUALS          ITEMP2
DELTAR          EQUALS          ITEMP3
URGENCYQ        ERASE           +1
URGENCYR        ERASE           +1
URGLIMIT        =               ITEMP6
A+B             ERASE
A-B             ERASE
TERMA           ERASE
TERMB           ERASE
DISPLACT        ERASE                                   # FLAG FOR EIGHTBALL ATT. ERROR DISPLAY.

POLTEST         ERASE

## Page 48
# TRIM GIMBAL CONTROL LAW ERASABLES:

# THE FOLLOWING ASSIGNMENTS OF RUPTREGS AND ITEMPS HAS BEEN MADE IN AN EFFORT TO OPTIMIZE USE OF ERASABLES:

K2THETA         EQUALS          RUPTREG1                # D.P. K(2)THETA AND "NEGUSUM"
ETHETA          EQUALS          RUPTREG2                # S.P. ERROR ANGLE SCALED AT PI/64 RADIANS
A2CNTRAL        EQUALS          RUPTREG3                # D.P. ALPHA(2) SCALED AT PI(2)/64 R/S(2)
SF1             EQUALS          RUPTREG3                # S.P. VARIABLE SCALE FACTORS WHICH ARE
SF2             EQUALS          RUPTREG4                # S.P. - REALLY SINGLE BITS (OR ZERO)
OMEGA.K         EQUALS          ITEMP1                  # D.P. OMEGA*K SUPERCEDES K AND K(2)
KCENTRAL        EQUALS          ITEMP1                  # S.P. K FROM KQ OR KR FIRST AT PI/2(8)
K2CNTRAL        EQUALS          ITEMP2                  # S.P. K(2) FROM Q OR R 1ST AT PI(2)/2(16)
WCENTRAL        EQUALS          ITEMP3                  # S.P. OMEGA SCALED AT PI/4 RADIANS/SECOND
ACENTRAL        EQUALS          ITEMP4                  # S.P. ALPHA SCALED AT PI/8 RAD/SEC(2)
DEL             EQUALS          ITEMP5                  # S.P. SGN(FUNCTION)
QRCNTR          EQUALS          ITEMP6                  # S.P. COUNTER: Q,Y=0, R,Z=2

# THE ABOVE QUANTITIES ARE ONLY NEEDED ON A VERY TEMPORARY BASIS AND HAVE BEEN PROVEN TO BE NON-CONFLICTING.

TJSR            ERASE
MULTFLAG        ERASE                                   # INDICATOR FOR SPDPMULT ROUTINE

FUNCTION        ERASE           +1                      # D.P. WORD FOR DRIVE FUNCTIONS

NEGUQ           ERASE           +2                      # NEGATIVE OF Q-AXIS GIMBAL DRIVE
THRSTCMD        EQUALS          NEGUQ           +1      # THRUST COMMAND AT 16384 LBS (SEPARATOR)
NEGUR           EQUALS          NEGUQ           +2      # NEGATIVE OF R-AXIS GIMBAL DRIVE

KQ              ERASE           +3                      # .3ACCDOTQ SCALED AT PI/2(8)
KQ2             EQUALS          KQ              +1      # KQ2 = KQ*KQ
KRDAP           EQUALS          KQ              +2      # .3 ACCDOTR SCALED AT PI/2(8)
KR2             EQUALS          KQ              +3      # KR2 = KR*KR

ACCDOTQ         ERASE           +3                      # Q-JERK SCALED AT PI/2(7) UNSIGNED
QACCDOT         EQUALS          ACCDOTQ         +1      # Q-JERK SCALED AT PI/2(7) SIGNED
ACCDOTR         EQUALS          ACCDOTQ         +2      # R-JERK SCALED AT PI/2(7) UNSIGNED
RACCDOT         EQUALS          ACCDOTQ         +3      # R-JERK SCALED AT PI/2(7) SIGNED

QDIFF           EQUALS          QERROR                  # ATTITUDE ERRORS:
RDIFF           EQUALS          RERROR                  # SCALED AT PI RADIANS

TIMEOFFQ        ERASE                                   # TIMES TO GO UNTIL TRIM GIMBAL TURN-OFF,
TIMEOFFR        ERASE                                   # ZERO MEANS NO ACTION, SCALED AS WAITLIST

## Page 49
# KALMAN FILTER ERASABLES.

STORCDUY        ERASE                                   # THIS S.P. PAIR IS USED TO SAVE CDUY,Z
STORCDUZ        ERASE                                   # FOR THE GTS RUPT

CDU             EQUALS          RUPTREG3                # RUPTREG3,4 USED AS D.P. WORD FOR CDU
                                                        # VALUE WITHIN FILTER IS COMP AT 2PI RAD

CDUDOT          EQUALS          ITEMP1                  # ITEMP1,2 USED AS D.P. WORD FOR CDUDOT
                                                        # VALUE WITHIN FILTER SCALED AT PI/4

CDU2DOT         EQUALS          ITEMP3                  # ITEMP3,4 USED AS D.P. WORD FOR CDU2DOT
                                                        # VALUE WITHIN FILTER SCALED AT PI/8

DT              ERASE                                   # TIME ELAPSED SCALED AT 1/8: NOMINAL=50MS
DAPTIME         ERASE                                   # USED TO RECORD LAST TIME FROM CHANNEL 4

STEERADR        ERASE                                   # DTCALC SWITCH IN FILTER INITIALIZATION

DPDIFF          ERASE           +1                      # D.P. WEIGHTING VECTOR FACTOR AT PI
WPOINTER        ERASE                                   # POINTER TO WEIGHTING VECTOR TABLE
W0              ERASE           +2                      # THETA WEIGHT
W1              EQUALS          W0              +1      # OMEGA WEIGHT
W2              EQUALS          W1              +1      # ALPHA WEIGHT

CDUYFIL         ERASE           +1                      # Y-AXIS D.P. FILTERED THETA AT 2PI

CDUZFIL         ERASE           +1                      # Z-AXIS D.P. FILTERED THETA AT 2PI
DCDUYFIL        ERASE           +1                      # Y-AXIS D.P. FILTERED OMEGA AT PI/4
DCDUZFIL        ERASE           +1                      # Z-AXIS D.P. FILTERED OMEGA AT PI/4
D2CDUYFL        ERASE           +1                      # Y-AXIS D.P. FILTERED ALPHA AT PI/8
D2CDUZFL        ERASE           +1                      # Z-AXIS D.P. FILTERED ALPHA AT PI/8
Y3DOT           ERASE                                   # Y-AXIS S.P. JERK AT PI/2(7)
CDU3DOT         ERASE                                   #                   LOOP REGISTER (SPACER)
Z3DOT           ERASE                                   # Z-AXIS S.P. JERK AT PI/2(7)

PFILTADR        ERASE           +1                      # 2CADR FOR FILTER RUPT 30 MS AFTER P-AXIS
PFRPTLST        ERASE           +7                      # POST FILTER RUPT LIST
# TORQUE VECTOR RECONSTRUCTION VARIABLES:

JETRATE         ERASE           +2                      # WEIGHTED RATES DUE TO JETS APPLIED IN
JETRATEQ        EQUALS          JETRATE         +1      # THE LAST CONTROL SAMPLE PERIOD OF 100 MS
JETRATER        EQUALS          JETRATE         +2      # SCALED AT PI/4 RADIANS/SECOND

NO.QJETS        ERASE           +1                      # NUMBER OF Q AND R JETS THAT ARE GIVEN
NO.RJETS        EQUALS          NO.QJETS        +1      # BY THE JET SELECT LOGIC

TP              ERASE           +1                      # TIME CALCULATED BY TJETLAW FOR P, QR
TQR             EQUALS          TP              +1      # SCALED AS TIME6, THEN TQR RESCALED TO 1

1JACC           ERASE           +4                      # ACCELERATIONS DUE TO 1 JET TORQUING

## Page 50
1JACCQ          EQUALS          1JACC           +1      # SCALED AT PI/4 RADIANS/SECOND
1JACCR          EQUALS          1JACC           +2
1JACCU          EQUALS          1JACC           +3      # FOR U,V-AXES THE SCALE FACTOR IS  DIFF:
1JACCV          EQUALS          1JACC           +4      # SCALED AT PI/2 RADIANS/SECOND (FOR ASC)

INERCTR         ERASE
INERCTRX        ERASE
# ASCENT VARIABLES:

SUMRATEQ        ERASE           +1                      # SUM OF UN-WEIGHTED JETRATE TERMS
SUMRATER        EQUALS          SUMRATEQ        +1      # SCALED AT PI/4 RADIANS/SECOND

OLDWFORQ        ERASE           +1                      # OMEGA VALUE 2 SECONDS AGO
OLDWFORR        EQUALS          OLDWFORQ        +1      # SCALED AT PI/4 RADIANS/SECOND

DBMINIMP        ERASE           +1                      # MINIMUM IMPULSE DEADBANDS (EQUAL IN DESC
MINIMPDB        EQUALS          DBMINIMP        +1      # AT .3 DEG, 0,-DB RESPECTIVELY FOR ASC)
                                                        # SCALED AT PI RADIANS

.5ACCMNE        ERASE           +4                      # (1/2)(1/ACCMIN) WHICH IS THE INVERSE OF
.5ACCMNQ        EQUALS          .5ACCMNE        +1      # THE MINIMUM ACCELERATION (A CONSTANT FOR
.5ACCMNR        EQUALS          .5ACCMNE        +2      # DESCENT AND A VARIABLE FOR ASCENT DAP)
.5ACCMNU        EQUALS          .5ACCMNE        +3      # SCALED AT 2(+8)/PI
.5ACCMNV        EQUALS          .5ACCMNE        +4      # IN UNITS OF SECONDS(2)/RADIAN

WFORP           ERASE           +1                      # W = K/(NOMINAL DT)
WFORQR          EQUALS          WFORP           +1      # SCALED AT 16

(1-K)           ERASE           +1                      # 1-K SCALED AT 1
(1-K)/8         EQUALS          (1-K)           +1      # 1-K SCALED AT 8

1/NJTSQ         ERASE           +3                      # 1/NJETACC FOR EACH AXIS

1/NJTSR         EQUALS          1/NJTSQ         +1      # FOR DESCENT THIS IS ALWAYS 1/2JTS
1/NJTSU         EQUALS          1/NJTSQ         +2      # FOR ASCENT WITH HIGH OFFSET: 1/4JTS
1/NJTSV         EQUALS          1/NJTSQ         +3      # SCALED AT 2(8)/PI SEC(2)/RAD

KCOEFCTR        ERASE                                   # COUNTER FOR ASCENT DAP



DLCDUIDX        ERASE                                   # SAVE RATE INDEX, = 1, 0
PJUMPADR        ERASE
QJUMPADR        ERASE
100MSPTQ        ERASE
QR.1ST0Q        =               100MSPTQ
NO.PJETS        ERASE


# THE FOLLOWING LM DAP ERASABLES ARE ZEROED IN THE STARTDAP SECTION OF THE DAPIDLER PROGRAM AND THE COASTASC

## Page 51
# SECTION OF THE AOSTASK.  THE ORDER MUST BE PRESERVED FOR THE INDEXING METHODS WHICH ARE EMPLOYED IN THOSE
# SECTIONS AND ELSEWHERE.

AOSQ            ERASE           +3                      # ASCENT OFFSET ACCELERATION ESTIMATES:
AOSR            EQUALS          AOSQ            +1      # ESTIMATED EVERY 2 SECONDS BY AOSTASK.
AOSU            EQUALS          AOSQ            +2      # U,V-AXES ACCS FORMED BY VECTOR ADDITION.
AOSV            EQUALS          AOSQ            +3      # SCALED AT PI/2 RADIANS/SECOND(2).

AOSQTERM        ERASE           +1                      # (.1-.05K)AOS
AOSRTERM        EQUALS          AOSQTERM        +1      # SCALED AT PI/4 RADIANS/SECOND.

NJ+Q            ERASE           +7                      # 2 JET OVER-RIDE FLAGS:
NJ-Q            EQUALS          NJ+Q            +1      # WHENEVER THE OFFSET ACCELERATION ABOUT
NJ+R            EQUALS          NJ+Q            +2      # AN AXIS IS SO HIGH THAT 2 JETS COULD NOT

NJ-R            EQUALS          NJ+Q            +3      # CONTROL ATTITUDE SUCCESSFULLY, THEN NJ
NJ+U            EQUALS          NJ+Q            +4      # FOR THAT AXIS (IN THE DIRECTION OPPOSING
NJ-U            EQUALS          NJ+Q            +5      # AOS) IS SET TO 1.  OTHERWISE, THE VALUE
NJ+V            EQUALS          NJ+Q            +6      # IS ZERO.  THESE FLAGS PREVENT TWO JETS
NJ-V            EQUALS          NJ+Q            +7      # FROM BEING REQUESTED TO FIGHT THE AOS.

1/NET+2Q        ERASE           +15D
1/NET+4Q        EQUALS          1/NET+2Q        +1
1/NET-2Q        EQUALS          1/NET+2Q        +2
1/NET-4Q        EQUALS          1/NET+2Q        +3
1/NET+2R        EQUALS          1/NET+2Q        +4
1/NET+4R        EQUALS          1/NET+2Q        +5
1/NET-2R        EQUALS          1/NET+2Q        +6
1/NET-4R        EQUALS          1/NET+2Q        +7
1/NET+1U        EQUALS          1/NET+2Q        +8D
1/NET+2U        EQUALS          1/NET+2Q        +9D
1/NET-1U        EQUALS          1/NET+2Q        +10D
1/NET-2U        EQUALS          1/NET+2Q        +11D
1/NET+1V        EQUALS          1/NET+2Q        +12D
1/NET+2V        EQUALS          1/NET+2Q        +13D
1/NET-1V        EQUALS          1/NET+2Q        +14D
1/NET-2V        EQUALS          1/NET+2Q        +15D
SIGNTAG         ERASE

1/NETACS        EQUALS          1/NET+1U

1/ACCQ          ERASE           +1                      # INVERSE NET ACCELERATIONS FOR URGENCY.
1/ACCR          EQUALS          1/ACCQ          +1      # SCALED AT 2(+8)/PI SECONDS(2)/RADIAN.

1/AMINQ         ERASE           +1                      # INVERSE MIN ACCELERATIONS FOR URGENCY.
1/AMINR         EQUALS          1/AMINQ         +1      # SCALED AT 2(+8)/PI SECONDS(2)/RADIAN.

1/AMINU         ERASE
1/AMINV         ERASE

URGRATQ         ERASE           +1                      # URGENCY FUNCTION CORRECTION FACTOR RATIO
URGRATR         EQUALS          URGRATQ         +1      # SCALED AT 1.

## Page 52
# ITEMP AND RUPTREG ASSIGNMENTS IN LM DAP:

# FOR EIGHTBAL SECTION:

AXISCNTR        EQUALS          ITEMP1                  # LOOPCTR AND VARIABLE INDEXER.
TEMPERR         EQUALS          ITEMP2                  # TEMPORARY STORAGE FOR BOUNDED ERROR.

# FOR P-AXIS PROGRAM:

REL             EQUALS          ITEMP5                  # TABLE INDEX USED BY P JET SELECT ROUTINE
CTR             EQUALS          ITEMP6                  # TABLE ENTRY COUNTER USED BY P JET SELECT

# FOR POLTYPEP PROGRAM:

TRANONLY        EQUALS          RUPTREG1                # FLAG FOR PURE TRANSLATION REQUESTS
ANYTRANS        EQUALS          RUPTREG2                # FLAG TO INDICATE DIRECTION OF TRAN..
TRANSNOW        EQUALS          RUPTREG3                # FLAG TO INDICATE TRANS. W/ ROT. POSSIBLE
TRANSAVE        EQUALS          RUPTREG4                # FLAG AND HOLDER FOR SAVED TRANS. POLICY
NETACNDX        EQUALS          ITEMP1                  # INDEX TO INDICATE AXIS, NO., AND DIRECT.

TJETADR         EQUALS          ITEMP2                  # GENADR OF RETURN TO TJETLAW
POLRELOC        EQUALS          ITEMP3                  # POLICY TABLE INDEX (RELATIVE ADDRESS)
LOOPCTR         EQUALS          ITEMP4                  # NUMBER OF ALTERNATE POLICIES.
THISPOLY        EQUALS          ITEMP5                  # STORED POLICY TO ELIMINATE INDEXING.
1/NETACC        EQUALS          ITEMP6                  # INV. NET ACC. FOR TJETLAW.

1/NJETAC        =               1/NETACC

1/2JTSQ         =               1/NET+2Q
1/2JTSR         =               1/NET+2R
1/2JETSU        =               1/NET+2U
1/2JETSV        =               1/NET+2V



# FOR AOSTASK PROGRAM:

K               EQUALS          ITEMP1
.1-.05K         EQUALS          ITEMP1
COEFFA          EQUALS          ITEMP2
.5-.5COF        EQUALS          ITEMP2

# MPAC DESIGNATIONS FOR AOSJOB:

JOBAXES         EQUALS          MPAC                    # ADJACENT ENTRY INDEXER.
NJPLACE         EQUALS          MPAC            +1      # ONE APART ENTRY INDEXER.
TABPLACE        EQUALS          MPAC            +2      # THREE APART ENTRY INDEXER.
TEMPAOS         EQUALS          MPAC            +3      # - AOS TEMPORARY STORAGE (SCALED AT PI/2)
TEMPACC         EQUALS          MPAC            +4      # JET ACCELERATION TEMP.  (SCALED AT PI/2)
TEMPNET         EQUALS          MPAC            +5      # NET ACCELERATION TEMP.  (SCALED AT PI/2)
