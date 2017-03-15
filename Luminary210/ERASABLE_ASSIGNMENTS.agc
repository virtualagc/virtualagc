### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ERASABLE_ASSIGNMENTS.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 92-160
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-19 HG   Transcribed
##              2016-11-25 HG   Fix operand MARKCNTR -> WHATMARK
##                                          ASBC0    -> ABSC0 
##                                          ARPFGZ   -> ABRFGZ    
##                                  label   HCASCLAD -> HCALCLAD   
##                                          NETTOTKP -> NEGTORKP 
##                                          RBRRGZ   -> RBRFGZ 
##              2016-11-26 HG   Fix label   REULTCT  -> RESULTCT  
##              2016-11-28 HG   Fix operand SAMPLIN  -> SAMPLIM
##              2016-11-29 HG   fix label   DVCNTRL  -> DVCNTR1
##              2016-12-02 HG   fix operand FLPASSO  -> FLPASS0
##              2016-12-07 HG   fix operand QAXIZ    -> QAXIS  adn mofidier +2 -> +6, fixes ZAXIS1
##                                  label   1/DVO    -> 1/DV0
##                                          ACSAVE   -> ASCSAVE
##                                          DSPFLAG  -> DSPLG
##                              add missing definition for label ZV
##              2016-12-11 HG   Fix operand modification VVECT(X,Y,Z) + 1 -> VVECT(X,Y,Z)+ 2
##		2016-12-22 RSB	Proofed comment text with octopus/ProoferComments
##				and fixed all errors found.
##		2017-03-11 MAS	Corrected errors found during transcription of Luminary 116.
##		2017-03-13 RSB	Comment-text fixes noted in proofing Luminary 116.
##		2017-03-15 RSB	Comment-text fixes identified in 5-way
##				side-by-side diff of Luminary 69/99/116/131/210.

## Page 92
# CONVENTIONS AND NOTATIONS UTILIZED FOR ERASABLE ASSIGNMENTS.

#          EQUALS IS USED IN TWO WAYS.  IT IS OFTEN USED TO CHAIN A GROUP
#                 OF ASSIGNMENTS SO THAT THE GROUP MAY BE MOVED WITH THE
#                 CHANGING OF ONLY ONE CARD.  EXAMPLE.

#                                         X        EQUALS  START
#                                         Y        EQUALS  X       +SIZE.X
#                                         Z        EQUALS  Y       +SIZE.Y

#                 (X, Y, AND Z ARE CONSECUTIVE AND BEGIN AT START.        )
#                 (SIZE.X AND SIZE.Y ARE THE RESPECTIVE SIZES OF X AND Y,
#                  USUALLY NUMERIC,  IE. 1, 2, 6, 18D ETC.               )

#          EQUALS  OFTEN IMPLIES THE SHARING OF REGISTERS (DIFFERENT NAMES
#                  AND DIFFERENT DATA).  EXAMPLE.

#                                          X       EQUALS  Y


#          = MEANS THAT MULTIPLE NAMES HAVE BEEN GIVEN TO THE SAME DATA.
#                 (THIS IS LOGICAL EQUIVALENCE, NOT SHARING)  EXAMPLE.

#                                          X       =       Y

#          THE SIZE AND UTILIZATION OF AN ERASABLE ARE OFTEN INCLUDED IN
#          THE COMMENTS IN THE FOLLOWING FORM.  M(SIZE)N.

#                 M  REFERS TO THE MOBILITY OF THE ASSIGNMENT.
#                       B       MEANS THAT THE SYMBOL IS REFERENCED BY BASIC
#                               INSTRUCTIONS AND THUS IS E-BANK SENSITIVE.
#                       I       MEANS THAT THE SYMBOL IS REFERENCED ONLY BY
#                               INTERPRETIVE INSTRUCTIONS, AND IS THUS E-BANK
#                               INSENSITIVE AND MAY APPEAR IN ANY E-BANK.

#                 SIZE    IS THE NUMBER OF REGISTERS INCLUDED BY THE SYMBOL.

#                 N INDICATES THE NATURE OF PERMANENCE OF THE CONTENTS.
#                      PL  MEANS THAT THE CONTENTS ARE PAD LOADED.
#                      DSP MEANS THAT THE REGISTER IS USED FOR A DISPLAY.
#                      PRM MEANS THAT THE REGISTER IS PERMANENT, IE. IT
#                          IS USED DURING THE ENTIRE MISSION FOR ONE
#                          PURPOSE AND CANNOT BE SHARED.
#                      TMP MEANS THAT THE REGISTER IS USED TEMPORARILY OR
#                          IS A SCRATCH REGISTER FOR THE ROUTINE TO WHICH
#                          IT IS ASSIGNED.  THAT IS, IT NEED NOT BE SET
#                          PRIOR TO INVOCATION OF THE ROUTINE NOR DOES IT
#                          CONTAIN USEFUL OUTPUT TO ANOTHER ROUTINE.  THUS

## Page 93
#                          IT MAY BE SHARED WITHANY OTHER ROUTINE WHICH
#                          IS NOT ACTIVE IN PARALLEL.
#                      IN  MEANS INPUT TO THE ROUTINE AND IT IS PROBABLY
#                          TEMPORARY FOR A HIGHER-LEVEL ROUTINE/PROGRAM.
#                      OUT MEANS OUTPUT FROM THE ROUTINE, PROBABLY
#                          TEMPORARY FOR A HIGHER-LEVEL ROUTINE/PROGRAM.

## Page 94
#          SPECIAL REGISTERS.

A               EQUALS          0
L               EQUALS          1                       # L AND Q ARE BOTH CHANNELS AND REGISTERS.
Q               EQUALS          2
EBANK           EQUALS          3
FBANK           EQUALS          4
Z               EQUALS          5                       # ADJACENT TO FBANK AND BBANK FOR DXCH Z
BBANK           EQUALS          6                       # (DTCB) AND DXCH FBANK (DTCF).
                                                        # REGISTER 7 IS A ZERO-SOURCE, USED BY ZL.

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
CDUT            EQUALS          35                      # REND RADAR TRUNNION CDU
CDUS            EQUALS          36                      # REND RADAR SHAFT CDU
PIPAX           EQUALS          37
PIPAY           EQUALS          40
PIPAZ           EQUALS          41
Q-RHCCTR        EQUALS          42                      # RHC COUNTER REGISTERS
P-RHCCTR        EQUALS          43
R-RHCCTR        EQUALS          44
INLINK          EQUALS          45
RNRAD           EQUALS          46
GYROCMD         EQUALS          47
CDUXCMD         EQUALS          50
CDUYCMD         EQUALS          51
CDUZCMD         EQUALS          52
CDUTCMD         EQUALS          53                      # RADAR TRUNNION COMMAND
CDUSCMD         EQUALS          54                      # RADAR SHAFT COMMAND

## Page 95
THRUST          EQUALS          55
LEMONM          EQUALS          56
OUTLINK         EQUALS          57
ALTM            EQUALS          60

#          INTERPRETIVE REGISTERS ADDRESSED RELATIVE TO VAC AREA.

LVSQUARE        EQUALS          34D                     # SQUARE OF VECTOR INPUT TO ABVAL AND UNIT
LV              EQUALS          36D                     # LENGTH OF VECTOR INPUT TO UNIT.
X1              EQUALS          38D                     # INTERPRETIVE SPECIAL REGISTERS RELATIVE
X2              EQUALS          39D                     # TO THE WORK AREA.
S1              EQUALS          40D
S2              EQUALS          41D
QPRET           EQUALS          42D

# INPUT/OUTPUT CHANNELS

#                               *** CHANNEL ZERO IS TO BE USED IN AN INDEXED OPERATION ONLY. ***
LCHAN           EQUALS          L
QCHAN           EQUALS          Q
HISCALAR        EQUALS          3
LOSCALAR        EQUALS          4
CHAN5           EQUALS          5
CHAN6           EQUALS          6
SUPERBNK        EQUALS          7                       # SUPER-BANK.
OUT0            EQUALS          10
DSALMOUT        EQUALS          11
CHAN12          EQUALS          12
CHAN13          EQUALS          13
CHAN14          EQUALS          14
MNKEYIN         EQUALS          15
NAVKEYIN        EQUALS          16
CHAN30          EQUALS          30
CHAN31          EQUALS          31
CHAN32          EQUALS          32
CHAN33          EQUALS          33
DNTM1           EQUALS          34
DNTM2           EQUALS          35
CHAN76          EQUALS          76
CHAN77          EQUALS          77
# END OF CHANNEL ASSIGNMENTS

## Page 96
# INTERPRETIVE SWITCH BIT ASSIGNMENTS

#             **  FLAGWORDS AND BITS NOW ASSIGNED AND DEFINED IN THEIR OWN LOG SECTION.  **

## Page 97
# GENERAL ERASABLE ASSIGNMENTS.

                SETLOC          61
#          INTERRUPT TEMPORARY STORAGE POOL.                         (11D)

#            (ITEMP1 THROUGH RUPTREG4)

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
#NEWLOC+1        EQUALS          ITEMP6                  DP ADDRESS.

                SETLOC          67
NEWJOB          ERASE                                   # MUST BE AT LOC 67 DUE TO WIRING.


RUPTREG1        ERASE
RUPTREG2        ERASE
RUPTREG3        ERASE
RUPTREG4        ERASE
KEYTEMP1        EQUALS          RUPTREG4
DSRUPTEM        EQUALS          RUPTREG4

# FLAGWORD RESERVATIONS.                                           (16D)

STATE           ERASE           +15D                    # FLAGWORD REGISTERS.

# P25 RADAR STORAGE.  (MAY BE UNSHARED IN E7)  (TEMP OVERLAY)  (2D)  OVERLAYS FLGWRD 14 & 15

## Page 98
LASTYCMD        EQUALS          STATE           +14D    # B(1)PRM       THESE ARE CALLED BY T4RUPT
LASTXCMD        EQUALS          LASTYCMD        +1      # B(1)PRM       THEY MUST BE CONTIGUOUS, Y FIRST



# EXEC TEMPORARIES WHICH MAY BE USED BETWEEN CCS NEWJOBS.  (32D) (INTB15+ THROUGH RUPTMXTM)
INTB15+         ERASE                                   # REFLECTS 15TH BIT OF INDEXABLE ADDRESSES
DSEXIT          =               INTB15+                 # RETURN FOR DSPIN
EXITEM          =               INTB15+                 # RETURN FOR SCALE FACTOR ROUTINE SELECT
INTBIT15        ERASE                                   # SIMILAR TO ABOVE.
WDRET           =               INTBIT15                # RETURN FOR DSPWD
DECRET          =               INTBIT15                # RETURN FOR PUTCOM(DEC LOAD)
21/22REG        =               INTBIT15                # TEMP FOR CHARIN

# THE REGISTERS BETWEEN ADDRWD AND PRIORITY MUST STAY IN THE FOLLOWING ORDER FOR INTERPRETIVE TRACE.

ADDRWD          ERASE                                   # 12 BIT INTERPRETIVE OPERAND SUB-ADDRESS.
POLISH          ERASE                                   # HOLDS CADR MADE FROM POLISH ADDRESS.
UPDATRET        =               POLISH                  # RETURN FOR UPDATNN, UPDATVB
CHAR            =               POLISH                  # TEMP FOR CHARIN
ERCNT           =               POLISH                  # COUNTER FOR ERROR LIGHT RESET
DECOUNT         =               POLISH                  # COUNTER FOR SCALING AND DISPLAY (DEC)

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
HITEMIN         =               VBUF            +1      # TEMP FOR LOAD OF HRS, MIN, SEC
                                                        #          MUST = LOTEMIN-1.
CODE            =               VBUF            +2      # FOR DSPIN
SFTEMP2         =               VBUF            +2      # STORAGE FOR SF CONST LO PART(=SFTEMP1+1)
LOTEMIN         =               VBUF            +2      # TEMP FOR LOAD OF HRS, MIN, SEC
                                                        #          MUST = HITEMIN+1.
MIXTEMP         =               VBUF            +3      # FOR MIXNOUN DATA
# ALSO MIXTEMP+1 = VBUF+4, MIXTEMP+2 = VBUF+5.

BUF             ERASE           +2                      # TEMPORARY SCALAR STORAGE.
BUF2            ERASE           +1
INDEXLOC        EQUALS          BUF                     # CONTAINS ADDRESS OF SPECIFIED INDEX.
SWWORD          EQUALS          BUF                     # ADDRESS OF SWITCH WORD.
SWBIT           EQUALS          BUF             +1      # SWITCH BIT WITHIN SWITCH WORD.
MPTEMP          ERASE                                   # TEMPORARY USED IN MULTIPLY AND SHIFT.

## Page 99
DMPNTEMP        =               MPTEMP                  # DMPSUB TEMPORARY
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

TEM1            ERASE                                   # EXEC TEMP
POLYRET         =               TEM1
DSREL           =               TEM1                    # REL ADDRESS FOR DSPIN

TEM2            ERASE                                   # EXEC TEMP
DSMAG           =               TEM2                    # MAGNITUDE STORE FOR DSPIN
TEM3            ERASE                                   # EXEC TEMP
COUNT           =               TEM3                    # FOR DSPIN

TEM4            ERASE                                   # EXEC TEMP
RELRET          =               TEM4                    # RETURN FOR RELDSP
DSPWDRET        =               TEM4                    # RETURN FOR DSPSIGN
SEPSCRET        =               TEM4                    # RETURN FOR SEPSEC
SEPMNRET        =               TEM4                    # RETURN FOR SEPMIN

TEM5            ERASE                                   # EXEC TEMP
NOUNADD         =               TEM5                    # TEMP STORAGE FOR NOUN ADDRESS

NNADTEM         ERASE                                   # TEMP FOR NOUN ADDRESS TABLE ENTRY
NNTYPTEM        ERASE                                   # TEMP FOR NOUN TYPE TABLE ENTRY
IDAD1TEM        ERASE                                   # TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
                                                        # MUST = IDAD2TEM-1, = IDAD3TEM-2.
IDAD2TEM        ERASE                                   # TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
                                                        # MUST = IDAD1TEM+1, = IDAD3TEM-1.
IDAD3TEM        ERASE                                   # TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
                                                        # MUST = IDAD1TEM+2, = IDAD2TEM+1.
RUTMXTEM        ERASE                                   # TEMP FOR SF ROUT TABLE ENTRY(MIXNN ONLY)

# AX*SR*T STORAGE.                                      (6D)

DEXDEX          EQUALS          TEM2                    # B(1)TMP
DEX1            EQUALS          TEM3                    # B(1)TMP

## Page 100
DEX2            EQUALS          TEM4                    # B(1)TMP
RTNSAVER        EQUALS          TEM5                    # B(1)TMP
TERM1TMP        EQUALS          MPAC            +3      # B(2)TMP

DEXI            =               DEX1

#          THE FOLLOWING 10 REGISTERS ARE USED FOR TEMPORARY STORAGE OF THE DERIVATIVE COEFFICIENT TABLE OF
# SUBROUTINE ROOTPSRS.   THEY MUST REMAIN WITHOUT INTERFERENCE WITH ITS SUBROUTINES WHICH ARE POWRSERS (POLY),
# DMPSUB, DMPNSUB, SHORTMP, DDV/BDDV, ABS, AND USPRCADR.

DERCOF-8        =               MPAC            -12     # ROOTPSRS DER COF N-4 HI ORDER
DERCOF-7        =               MPAC            -11     # ROOTPSRS DER COF N-4 LO ORDER
DERCOF-6        =               MPAC            -10     # ROOTPSRS DER COF N-3 HI ORDER
DERCOF-5        =               MPAC            -7      # ROOTPSRS DER COF N-3 LO ORDER
DERCOF-4        =               MPAC            -6      # ROOTPSRS DER COF N-2 HI ORDER
DERCOF-3        =               MPAC            -5      # ROOTPSRS DER COF N-2 LO ORDER
DERCOF-2        =               MPAC            -4      # ROOTPSRS DER COF N-1 HI ORDER
DERCOF-1        =               MPAC            -3      # ROOTPSRS DER COF N-1 LO ORDER
DERCOFN         =               MPAC            -2      # ROOTPSRS DER COF N HI ORDER
DERCOF+1        =               MPAC            -1      # ROOTPSRS DER COF N LO ORDER

PWRPTR          =               POLISH                  # ROOTPSRS POWER TABLE POINTER
DXCRIT          =               VBUF            +2      # ROOTPSRS CRITERION FOR ENDING ITERS HI
DXCRIT+1        =               VBUF            +3      # ROOTPSRS CRITERION FOR ENDING ITERS LO
ROOTPS          =               VBUF            +4      # ROOTPSRS ROOT HI ORDER
ROOTPS+1        =               VBUF            +5      # ROOTPSRS ROOT LO ORDER
RETROOT         =               BUF             +2      # ROOTPSRS RETURN ADDRESS OF USER
PWRCNT          =               MATINC                  # ROOTPSRS DER TABLE LOOP COUNTER
DERPTR          =               TEM1                    # ROOTPSRS DER TABLE POINTER

## Page 101
# DYNAMICALLY ALLOCATED CORE SETS FOR JOBS.      	(84D)

MPAC            ERASE           +6                      # MULTI-PURPOSE ACCUMULATOR.
MODE            ERASE                                   # +1 FOR TP, +0 FOR DP, OR -1 FOR VECTOR.
LOC             ERASE                                   # LOCATION ASSOCIATED WITH JOB.
BANKSET         ERASE                                   # USUALLY CONTAINS BBANK SETTING.
PUSHLOC         ERASE                                   # WORD OF PACKED INTERPRETIVE PARAMETERS.
PRIORITY        ERASE                                   # PRIORITY OF PRESENT JOB AND WORK AREA.

                ERASE           +83D                    # EIGHT SETS OF 12 REGISTERS EACH

# INCORP STORAGE:  R22 (N29)    (SHARES WITH FOLLOWING SECTION)         (4D)

R22DISP         EQUALS          TIME2SAV                # I(4) N49 DISPLAY OF DELTA R AND DELTA V

# STANDBY VERB ERASABLES                                		(4D)

TIME2SAV        ERASE           +1
SCALSAVE        ERASE           +1

#          HARDWARE RESTART COUNTER                                 (1D)

REDOCTR         ERASE                                   # CONTAINS NUMBER OF RESTARTS

#  UNSHARED STORAGE FOR DESIRED GIMBAL ANGLES                       (3D)

THETAD          ERASE           +2
CPHI            =               THETAD                  # O     DESIRED GIMBAL ANGLES
CTHETA          =               THETAD          +1      # I     FOR
CPSI            =               THETAD          +2      # M     MANEUVER.

#  STORAGE FOR DELTAV/S                                              (6D)

DELV            ERASE           +5
DELVX           =               DELV
DELVY           =               DELV            +2
DELVZ           =               DELV            +4

# WAITLIST REPEAT FLAG                          (1D)

RUPTAGN         ERASE
KEYTEMP2        =               RUPTAGN                 # TEMP FOR KEYRUPT, UPRUPT

# DOWNLINK STORAGE.                             (27D)

## Page 102
DNTMERAS        ERASE           +26D                    # B(27D)PRM ERASABLES USED BY DOWN-
                                                        #  TELEMETRY PROGRAM -- CANNOT BE SHARED.

DNLSTCOD        EQUALS          DNTMERAS                # B(1)PRM  CODE SPECIFYING WHICH DOWNLIST
                                                        #        WILL BE SELECTED FOR TRANSMISSION
CTLIST          EQUALS          DNLSTCOD        +1      # B(1)PRM  POINTER TO CURRENT LOCATION OF
                                                        #          THE CONTROL LIST.
DNTMGOTO        EQUALS          CTLIST          +1      # B(1)PRM  POINTER TO LOCATION WHERE DNTM
                                                        #  PROCESSING WILL RESUME NEXT DOWNRUPT.
DNECADR         EQUALS          DNTMGOTO        +1      # B(1)PRM  HOLDS CONTENTS OF CURRENT
                                                        #       CONTROL LIST LOCATION.
TMINDEX         EQUALS          DNECADR                 # B(1)  INDEX FOR LOADING SNAPSHOT BUFFER.
DUMPLOC         EQUALS          DNECADR                 # B(1)  BITS 1-11 CONTAIN ECADR OF AGC DP
                                                        #  WORD BEING DUMPED BY V74 ERASABLE DUMP.
                                                        #       BITS 12-15 CONTAIN COUNT OF
                                                        #  COMPLETE DUMPS ALREADY SENT.
SUBLIST         EQUALS          DNECADR         +1      # B(1)PRM  POINTER TO CURRENT SUBLIST LOC.
DNTMBUFF        EQUALS          SUBLIST         +1      # B(22)PRM DOWNLINK SNAPSHOT BUFFER


#          UNSWITCHED FOR DISPLAY INTERFACE ROUTINES.    (6D)

NVWORD          ERASE
MARKNV          ERASE
NVSAVE          ERASE                                   # PURPOSES)
CADRFLSH        ERASE
CADRMARK        ERASE
TEMPFLSH        ERASE
#

#          CHANNEL BIT FAILURE PROTECTION WORD - PAD LOADED AS ZERO    (1D)

CHANBKUP        ERASE                                   # B(1)PRM


#          ALARM CODE REGISTERS                                        (3D)

FAILREG         ERASE                           +2      # B(3)PRM  3  ALARM CODE REGISTERS

#          VAC AREAS. -BE CAREFUL OF PLACEMENT-          (220D)

VAC1USE         ERASE
VAC1            ERASE           +42D
VAC2USE         ERASE
VAC2            ERASE           +42D
VAC3USE         ERASE
VAC3            ERASE           +42D
VAC4USE         ERASE
VAC4            ERASE           +42D

## Page 103
VAC5USE         ERASE
VAC5            ERASE           +42D


#          TEMPORARIES USED BY RESTARTS ROUTINE

GOLOC           EQUALS          VAC5            +20D    # B(4)


#          R59 - STAR ACQUISITION ROUTINE                (1D)

POSCODE         ERASE                                   # B(1)TMP DETENT POSITION CNTR IN R59

#          CALCSMSC                                     (12D)

STARALGN        ERASE           +11D
SINCDU          =               STARALGN
COSCDU          =               STARALGN        +6

SINCDUX         =               SINCDU          +4
SINCDUY         =               SINCDU
SINCDUZ         =               SINCDU          +2
COSCDUX         =               COSCDU          +4
COSCDUY         =               COSCDU
COSCDUZ         =               COSCDU          +2


#          PHASE TABLE AND RESTART COUNTERS.              (12D)

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

#          A**SR*T STORAGE.                              (6D)

CDUSPOT         ERASE           +5                      # B(6)

CDUSPOTY        =               CDUSPOT
CDUSPOTZ        =               CDUSPOT         +2

## Page 104
CDUSPOTX        =               CDUSPOT         +4


#          VERB 37 STORAGE.                              (2D)

MINDEX          ERASE                                   # B(1)TMP INDEX FOR MAJOR MODE
MMNUMBER        ERASE                                   # B(1)TMP MAJOR MODE REQUESTED BY V37


#          PINBALL INTERRUPT ACTION.                     (1D)

DSPCNT          ERASE                                   # B(1)PRM COUNTER FOR DSPOUT.


#          PINBALL EXECUTIVE ACTION                      (44D)

DSPCOUNT        ERASE                                   # DISPLAY POSITION INDICATOR.
DECBRNCH        ERASE                                   # +DEC, - DEC, OCT INDICATOR
VERBREG         ERASE                                   # VERB CODE
NOUNREG         ERASE                                   # NOUN CODE
XREG            ERASE                                   # R1 INPUT BUFFER
YREG            ERASE                                   # R2 INPUT BUFFER
ZREG            ERASE                                   # R3 INPUT BUFFER
XREGLP          ERASE                                   # LO PART OF XREG (FOR DEC CONV ONLY)
YREGLP          ERASE                                   # LO PART OF YREG (FOR DEC CONV ONLY)
HITEMOUT        =               YREGLP                  # TEMP FOR DISPLAY OF HRS, MIN, SEC
                                                        #          MUST = LOTEMOUT-1.
ZREGLP          ERASE                                   # LO PART OF ZREG (FOR DEC CONV ONLY)
LOTEMOUT        =               ZREGLP                  # TEMP FOR DISPLAY OF HRS, MIN, SEC
                                                        #          MUST = HITEMOUT+1.
MODREG          ERASE                                   # MODE CODE
DSPLOCK         ERASE                                   # KEYBOARD/SUBROUTINE CALL INTERLOCK
REQRET          ERASE                                   # RETURN REGISTER FOR LOAD
LOADSTAT        ERASE                                   # STATUS INDICATOR FOR LOADTST
CLPASS          ERASE                                   # PASS INDICATOR CLEAR
NOUT            ERASE                                   # ACTIVITY COUNTER FOR DSPTAB
NOUNCADR        ERASE                                   # MACHINE CADR FOR NOUN
MONSAVE         ERASE                                   # N/V CODE FOR MONITOR. (= MONSAVE1-1)
MONSAVE1        ERASE                                   # NOUNCADR FOR MONITOR(MATBS) =MONSAVE+1
MONSAVE2        ERASE                                   # NVMONOPT OPTIONS
DSPTAB          ERASE           +11D                    # 0-10D, DISPLAY PANEL BUFF. 11D, C/S LTS.
NVQTEM          ERASE                                   # NVSUB STORAGE FOR CALLING ADDRESS
                                                        # MUST = NVBNKTEM-1
NVBNKTEM        ERASE                                   # NVSUB STORAGE FOR CALLING BANK
                                                        # MUST = NVQTEM+1
VERBSAVE        ERASE                                   # NEEDED FOR RECYCLE
CADRSTOR        ERASE                                   # ENDIDLE STORAGE
DSPLIST         ERASE                                   # WAITING REG FOR DSP SYST INTERNAL USE
EXTVBACT        ERASE                                   # EXTENDED VERB ACTIVITY INTERLOCK
DSPTEM1         ERASE           +2                      # BUFFER STORAGE AREA 1 (MOSTLY FOR TIME)

## Page 105
DSPTEM2         ERASE           +2                      # BUFFER STORAGE AREA 2 (MOSTLY FOR DEG)

DSPTEMX         EQUALS          DSPTEM2         +1      # B(2) S-S DISPLAY BUFFER FOR EXT. VERBS
NORMTEM1        EQUALS          DSPTEM1                 # B(3)DSP NORMAL DISPLAY REGISTERS.



#          DISPLAY FOR EXTENDED VERBS (V82, R04(V62), V41(N72) )       (2D)

OPTIONX         EQUALS          DSPTEMX                 # (2) EXTENDED VERB OPTION CODE

#          TBASES AND PHSPRDT S.                         (12D)

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


PIPCTR          =               PHSPRDT2                # USED TO COUNT DOWN R10 CYLCES.  USED IN
                                                        # CONJUNCTION WITH TBASE2, SO THIS
                                                        # LOCATION IS FUNCTIONALLY =.  SEE R10,R11


#          UNSWITCHED FOR DISPLAY INTERFACE ROUTINES.    (5D)

NVWORD1         ERASE                                   # B(1) * USED DURING POWERED FLIGHT ONLY *

EBANKSAV        ERASE
DSPFLG          =               EBANKSAV
MARKFLAG        ERASE
EBANKTEM        ERASE
MARK2PAC        ERASE
#


#          CODE WORD FOR AGS RENDEZVOUS DOWNLIST XFER OF RADAR DATA      (1D)

AGSCODE         ERASE                                   # B(1) DO NOT SHARE.

## Page 106
#          IMU COMPENSATION UNSWITCHED ERASABLE.         (1D)

1/PIPADT        ERASE

#          TEMPORARIES FOR SPCOS AND SPSIN               (2D)

TEMK            ERASE                                   # (1)
SQ              ERASE                                   # (1)
#

#     **** RADAR ****					(13D)

SAMPLIM         ERASE                                   # B(1)      LR    R12,P60S,R04,R77
RADUSE          EQUALS          SAMPLIM                 # B(1)PRM   BOTH  P20,P22,R12,R04
SAMPLSUM        ERASE           +3                      # B(2),I(2) BOTH
RRTARGET        EQUALS          SAMPLSUM                # I(6)      RR  P20,P22,R04,V41

TIMEHOLD        ERASE           +1                      # B(2)      BOTH
TANG            ERASE           +1                      # B(2),I    RR
MODEA           EQUALS          TANG                    # B(2),I    RR

MODEB           ERASE           +1                      # B(2),I    RR
NSAMP           EQUALS          MODEB                   # B(1)      BOTH

DESRET          ERASE                                   # B(1),I    RR
OLDATAGD        EQUALS          DESRET                  # B(1)      BOTH

DESCOUNT        ERASE                                   # B(1)      RR
#


#          ******   P22  ******                         (6D)

RSUBC           EQUALS          RRTARGET                # I(6)S-S  CSM POSITION VECTOR

## Page 107
#          UNSWITCHED FOR ORBIT INTEGRATION.             (21D)

TDEC            ERASE           +20D                    # I(2)
COLREG          EQUALS          TDEC            +2      # I(1)
LAT             EQUALS          COLREG          +1      # I(2)
LONG            EQUALS          LAT             +2      # I(2)
ALT             EQUALS          LONG            +2      # I(2)
YV              EQUALS          ALT             +2      # I(6)
ZV              EQUALS          YV              +6      # I(6) 
#

#          MISCELLANEOUS UNSWITCHED.                     (20D)

P40/RET         ERASE                                   # (WILL BE PUT IN E6 WHEN THERE IS ROOM)
GENRET          ERASE                                   # B(1)  R61 RETURN CADR.
OPTION1         ERASE                                   # B(1)   NOUN 06 USES THIS
OPTION2         ERASE                                   # B(1)   NOUN 06 USES THIS
OPTION3         ERASE                                   # B(1)  NOUN 06 USES THIS
LONGCADR        ERASE           +1                      # B(2)  LONGCALL REGISTER
LONGBASE        ERASE           +1
LONGTIME        ERASE           +1                      # B(2)    LONGCALL REGISTER
CDUTEMPX        ERASE                                   # B(1)TMP
CDUTEMPY        ERASE                                   # B(1)TMP
CDUTEMPZ        ERASE                                   # B(1)TMP
PIPATMPX        ERASE                                   # B(1)TMP
PIPATMPY        ERASE                                   # B(1)TMP
PIPATMPZ        ERASE                                   # B(1)TMP

DISPDEX         ERASE                                   # B(1)
TEMPR60         ERASE                                   # B(1)
PRIOTIME        ERASE                                   # B(1)

#          P27 (UPDATE PROGRAM ) STORAGE.                (26D)

UPVERBSV        ERASE                                   # B(1) UPDATE VERB ATTEMPTED.
UPTEMP          ERASE           +24D                    # B(1)TMP SCRATCH
# RETAIN THE ORDER OF COMPNUMB THRU UPBUFF +19D FOR DOWNLINK PURPOSES.
COMPNUMB        EQUALS          UPTEMP          +1      # B(1)TMP NUMBER OF ITEMS TO BE UPLINKED
UPOLDMOD        EQUALS          COMPNUMB        +1      # B(1)TMP INTERRUPTED PROGRAM MM
UPVERB          EQUALS          UPOLDMOD        +1      # B(1)TMP VERB NUMBER
UPCOUNT         EQUALS          UPVERB          +1      # B(1)TMP UPBUFF INDEX
UPBUFF          EQUALS          UPCOUNT         +1      # B(20D)
#


#          TEMPORARY FOR RESTART PROTECTION IN SERVICER  (2D)

DVTEMP          EQUALS          UPBUFF                  # B(2) TEMP. SAVE DVTOTAL FOR RESTARTS.

## Page 108
# SPECIAL DEFINITION FOR SYSTEM TEST ERASABLE PGMS.	(2D)

EBUF2           EQUALS          UPTEMP                  # B(2) FOR EXCLUSIVE USE OF SYSTEM TEST


#          PERM STATE VECTORS FOR BOOST AND DOWNLINK-WHOLE MISSION- (14D)

RN              ERASE           +5                      # B(6)PRM
VN              ERASE           +5                      # B(6)PRM
PIPTIME         ERASE           +1                      # B(2)PRM  (MUST BE FOLLOWED BY GDT/2)


#          SERVICER   -MUST FOLLOW PIPTIME-             (18D)

GDT/2           ERASE           +17D                    # B(6)TMP  ** MUST FOLLOW PIPTIME **
MASS            EQUALS          GDT/2           +6      # B(2)
WEIGHT/G        =               MASS
ABDELV          EQUALS          MASS            +2      # (1)
PGUIDE          EQUALS          ABDELV          +1      # (2)
DVTHRUSH        EQUALS          PGUIDE          +2      # (1)
AVEGEXIT        EQUALS          DVTHRUSH        +1      #  (2)
AVGEXIT         =               AVEGEXIT
TEMX            EQUALS          AVEGEXIT        +2      #  (1)
TEMY            EQUALS          TEMX            +1      #  (1)
TEMZ            EQUALS          TEMY            +1      #  (1)
PIPAGE          EQUALS          TEMZ            +1      # B(1)
#



#          ALIGNMENT					(7D)

AOTCODE         EQUALS          GDT/2                   # B(1)TMP DOWNLINKED -- STAR CODE
STARCODE        =               AOTCODE                 # B(1)TMP DSP N70,N71
XCOUNT          =               AOTCODE         +1      # B(1)TMP DSP N70,N71   X MARK COUNTER
YCOUNT          =               AOTCODE         +2      # B(1)TMP DSP N70,N71   Y MARK COUNTER

CURSOR          EQUALS          AOTCODE         +3      # B(1)TMP DOWNLNK -- STAR MEASUREMENT QTY
SPIRAL          EQUALS          CURSOR          +1      # B(1)TMP DOWNLNK -- STAR MEASUREMENT QTY
SITIME          EQUALS          SPIRAL                  # B(2)TMP TIME USED IN LANDING SITE COMP


#          S34/35.5  TEMPORARY     (2)

TMPDV           EQUALS          GDT/2                   # B(2) TMP SAVE FOR DVLVC


#          USED FOR SUMMATION OF UPRUPT DURING PRELAUNCH & SYS TEST LEADIN(3D)

UPSUM           EQUALS          ABDELV			# (3)

## Page 109
#           P 76  DISPLAY     N84                        (6D)
DELVOV          EQUALS          UPSUM           +3      # I(6)


#          P76 - P77 STORAGE                              (1D)

OPTFLAG         EQUALS          GDT/2                   # B(1)TMP  FLAG FOR P76 OR P77


#          PERMANENT LEM DAP STORAGE.                     (5D)

CH5MASK         ERASE                                   # B(1)PRM
CH6MASK         ERASE                                   # B(1)PRM JET FAILURE MASK.
SPNDX           ERASE                                   # B(1)
T5ADR           ERASE           +1                      # GENADR OF NEXT LM DAP T5RUPT. * 2CADR *
                                                        # BBCON  OF NEXT LM DAP T5RUPT.   2CADR

#          DISPLAY INTERFACE RESTART PROTECTION STORAGE   (1D)

RESTREG         ERASE                                   # B(1)PRM


#          ERASABLES FOR RADAR READ PROTECTION (C13STALL)        (4D)

C13QSAV         ERASE                                   # B(1) QSAVE FOR C13STALL USERS.
C13FSAV         ERASE                                   # B(1) FBANK SAVE FOR C13STALL.
RADTIME         ERASE                                   # B(1) NEG. TIME OF SCALAR READ.
RADDEL          ERASE                                   # B(1) DELTA TIME FROM SCALAR READ TO T5.


#          RADAREAD STORAGE                             (2D)

TTOTIG          ERASE           +1                      # B(2) LATEST ESTIMATE OF TIME TO IGNITION

#          RCS FAILURE MONITOR STORAGE                   (1)
PVALVEST        ERASE                                   # B(1)PRM


#          KALCMANU/DAP INTERFACE.                       (3D)

DELPEROR        ERASE                                   # B(1)PRM COMMAND LAGS.
DELQEROR        ERASE                                   # B(1)PRM
DELREROR        ERASE                                   # B(1)PRM

#          MODE SWITCHING ERASABLE.                      (9D)

## Page 110
#    RETAIN THE ORDER OF IMODES30 AND IMODES33 FOR DOWNLINK PURPOSES.
IMODES30        ERASE                                   # B(1)
IMODES33        ERASE
MODECADR        ERASE           +2                      # B(3)PRM
IMUCADR         EQUALS          MODECADR
OPTCADR         EQUALS          MODECADR        +1
RADCADR         EQUALS          MODECADR        +2
ATTCADR         ERASE           +2                      # B(3)PRM
ATTPRIO         =               ATTCADR         +2
MARKSTAT        ERASE

#          T4RUPT ERASABLE.                              (2D)

DSRUPTSW        ERASE
LGYRO           ERASE                                   # (1)

#          RENDEZVOUS RADAR TASK STORAGE                  (3D)

RRRET           ERASE           +2D                     # B(1)TMP       P20'S, PERHAPS R29 & R12
RDES            EQUALS          RRRET           +1      # B(1)TMP
RRINDEX         EQUALS          RDES            +1      # B(1)TMP
#



#          MEASUREMENT INCORPORATION                     (4D)

WIXA            ERASE                                   # B(1)
WIXB            ERASE                                   # B(1)
ZIXA            ERASE                                   # B(1)
ZIXB            ERASE                                   # B(1)

#          LANDING RADAR PADLOAD                          (1D)

LRWH1           EQUALS          WIXA                    # B(1) P.L.  P64 LR WEIGHTING FUNCTION
#



#          AGS DOWNLINK ID CODE FOR RESTART PURPOSES      (1D)

AGSWORD         ERASE

#          SOME MISCELLANEOUS UNSWITCHED.                 (6D)

RATEINDX        ERASE                                   # (1) USED BY KALCMANU
DELAYLOC        ERASE           +2
LEMMASS         ERASE                                   # KEEP CONTIGUOUS W. CSMMASS  (1) EACH
CSMMASS         ERASE

#          LESS IS MORE.

## Page 111

#          RENDEZVOUS AND LANDING RADAR DOWNLINK STORAGE.     (7D)

#                 (NORMALLY USED DURING P20, BUT MAY ALSO)
#                 (BE REQUIRED FOR THE V62 SPURIOUS TEST.)

#                    (PLEASE KEEP IN THIS ORDER)

DNRRANGE        ERASE           +6                      # B(1) TMP
DNRRDOT         EQUALS          DNRRANGE        +1      # B(1)TMP
DNINDEX         EQUALS          DNRRDOT         +1      # B(1)TMP
DNLRVELX        EQUALS          DNINDEX         +1      # B(1)TMP
DNLRVELY        EQUALS          DNLRVELX        +1      # B(1)TMP
DNLRVELZ        EQUALS          DNLRVELY        +1      # B(1)TMP
DNLRALT         EQUALS          DNLRVELZ        +1      # B(1) TMP

#          RADAR -- RR AND LR                             (1D)

RADBITS         EQUALS          DNINDEX                 # B(1)PRM   SHOWS TYPE OF RADAR READ


#          INCORPORATION UNSWITCHED.                      (2D)

W.IND           EQUALS          PIPAGE                  # B(1) TMP -- INDEX IN CLOSED LOOP


#          SUBROUTINE BALLANGS OF R60.                    (1D)

BALLEXIT        ERASE                                   # B(1) SAVE LOCATION FOR BALLINGS SUBR EXIT


#          SOME LEM DAP STORAGE.                         (4D)

DAPDATR1        ERASE                                   # B(1)DSP DAP CONFIG.
TEVENT          ERASE           +1                      # B(2)DSP
DB              ERASE                                   # B(1) PRM DEAD BAND
DBVAL1          =               DB                      # B(1) PRM
#


#      NOUN 87 USED IN R52 AUTO OPTICS                    (2D)

AZ              ERASE           +1D                     # B(1) AZ AND EL MUST BE CONTIGUOUS
EL              EQUALS          AZ              +1D     # B(1)


#          P63, P64, P65, P66, AND P67.                  (1D)

WCHPHASE        ERASE                                   # B(1)

## Page 112

#          PADLOADS FOR R2 LUNAR POTENTIAL MODEL.        (2D)

E3J22R2M        ERASE                                   # I(1)
E32C31RM        ERASE                                   # I(1)
#



#          ERASABLES FOR TRUNNION AND SHAFT COMMANDS     (2D)

TRUNNCMD        ERASE                                   # *** THESE TWO ERASABLES ***
SHAFTCMD        ERASE                                   # *** MUST BE IN ORDER ***


#          R22 OF P20                                    (1D)
WHCHREAD        ERASE                                   # B(1)TMP MEASUREMENT BEING PROCESSED.

#          LANDING PADLOAD                               (1D)

ELBIAS          EQUALS          WHCHREAD                # B(1) PL LPD ELEVATION BIAS. PI RADIANS.

#          P66 PADLOAD                                    (1D)

TOOFEW          ERASE                                   # B(1) TOO FEW THROTTLINGS PER OMISSION:
                                                        #  ONE LESS THAN NO. THROTTLES REQUIRED
                                                        #   BETWEEN SKIPPED THROTTLES
                                                        #     1466 ALARM IF THROTTLINGS <= TOOFEW
#          TLOSS INDICATORS FOR DOWNLINK                 (2D)

SERVDURN        ERASE                                   # B(1)  AT SERVOUT: TIME1 - PIPTIME +1
DUMLOOPS        ERASE                                   # B(1)  LOOP COUNTER IN DUMMYJOB AT ADVAN


#         SELF-CHECK ASSIGNMENTS.                       (17D)

#                                 (DO NOT MOVE, S-C IS ADDRESS SENSITIVE)

SELFERAS        ERASE           1357 - 1377             # *** MUST NOT BE MOVED ***
SFAIL           EQUALS          SELFERAS                # B(1)
ERESTORE        EQUALS          SFAIL           +1      # B(1)
SELFRET         EQUALS          ERESTORE        +1      # B(1)    RETURN
SMODE           EQUALS          SELFRET         +1      # B(1)
ALMCADR         EQUALS          SMODE           +1      # B(2)   ALARM-ABORT USER'S 2CADR
ERCOUNT         EQUALS          ALMCADR         +2      # B(1)
SCOUNT          EQUALS          ERCOUNT         +1      # B(3)
SKEEP1          EQUALS          SCOUNT          +3      # B(1)
SKEEP2          EQUALS          SKEEP1          +1      # B(1)
SKEEP3          EQUALS          SKEEP2          +1      # B(1)
SKEEP4          EQUALS          SKEEP3          +1      # B(1)

## Page 113
SKEEP5          EQUALS          SKEEP4          +1      # B(1)
SKEEP6          EQUALS          SKEEP5          +1      # B(1)
SKEEP7          EQUALS          SKEEP6          +1      # B(1)

## Page 114
#          EBANK-3 ASSIGNMENTS

                SETLOC          1400

#          WAITLIST TASK LISTS.                          (26D)

LST1            ERASE           +7                      # B(8D)PRM  DELTA T S.
LST2            ERASE           +17D                    # B(18D)PRM TASK 2CADR ADDRESSES.

#          RESTART STORAGE.                              (2D)

RSBBQ           ERASE           +1                      # B(2)PRM SAVE BB AND Q FOR RESTARTS.


#          MORE LONGCALL STORAGE.(MUST BE IN LST1 S BANK.      (2D)

LONGEXIT        ERASE           +1                      # B(2)TMP MAY BE SELDOM OVERLAYED.


#          PHASE-CHANGE LISTS PART II.                   (12D)

PHSNAME1        ERASE                                   # B(1)PRM
PHSBB1          ERASE                                   # B(1)PRM
PHSNAME2        ERASE                                   # B(1)PRM
PHSBB2          ERASE                                   # B(1)PRM
PHSNAME3        ERASE                                   # B(1)PRM
PHSBB3          ERASE                                   # B(1)PRM
PHSNAME4        ERASE                                   # B(1)PRM
PHSBB4          ERASE                                   # B(1)PRM
PHSNAME5        ERASE                                   # B(1)PRM
PHSBB5          ERASE                                   # B(1)PRM
PHSNAME6        ERASE                                   # B(1)PRM
PHSBB6          ERASE                                   # B(1)PRM

#          IMU COMPENSATION PARAMETERS.                  (22D)

PBIASX          ERASE                                   # B(1) PIPA BIAS, PIPA SCALE FACTR TERMS
PIPABIAS        =               PBIASX                  # INTERMIXED.
PIPASCFX        ERASE
PIPASCF         =               PIPASCFX
PBIASY          ERASE
PIPASCFY        ERASE
PBIASZ          ERASE
PIPASCFZ        ERASE

NBDX            ERASE                                   # GYRO BIAS DRIFTS
NBDY            ERASE
NBDZ            ERASE

## Page 115
ADIAX           ERASE                                   # ACCELERATION SENSITIVE DRIFT ALONG THE
ADIAY           ERASE                                   #     INPUT AXIS
ADIAZ           ERASE

ADSRAX          ERASE                                   # ACCELERATION SENSITIVE DRIFT ALONG THE
ADSRAY          ERASE                                   #     SPIN REFERENCE AXIS
ADSRAZ          ERASE

GCOMP           ERASE           +5                      # CONTAINS COMPENSATING TORQUES

COMMAND         EQUALS          GCOMP
CDUIND          EQUALS          GCOMP            +3

GCOMPSW         ERASE



#          STATE VECTORS FOR ORBIT INTEGRATION.          (44D)

#                                 (DIFEQCNT THRU XKEP MUST BE IN SAME
#                                   EBANK AS RRECTCSM, RRECTLEM ETC
#                                   BECAUSE THE COPY-CYCLES (ATOPCSM,
#                                   PTOACSM ETC) ARE EXECUTED IN BASIC.
#                                     ALL OTHER REFERENCES TO THIS GROUP
#                                   ARE BY INTERPRETIVE INSTRUCTIONS.)
#

DIFEQCNT        ERASE           +43D                    # B(1)
#               (UPSVFLAG...XKEP MUST BE KEPT IN ORDER)

UPSVFLAG        EQUALS          DIFEQCNT        +1      # B(1)
RRECT           EQUALS          UPSVFLAG        +1      # B(6)
VRECT           EQUALS          RRECT           +6      # B(6)
TET             EQUALS          VRECT           +6      # B(2)
TDELTAV         EQUALS          TET             +2      # B(6)
TNUV            EQUALS          TDELTAV         +6      # B(6)
RCV             EQUALS          TNUV            +6      # B(6)
VCV             EQUALS          RCV             +6      # B(6)
TC              EQUALS          VCV             +6      # B(2)
XKEP            EQUALS          TC              +2      # B(2)

#          CONIC ROUTINES STORAGE                         (2D)

XPREV           EQUALS          XKEP                    # I(2)TMP


#          PERMANENT STATE VECTORS AND TIMES.            (97D)

#          (DO NOT OVERLAY WITH ANYTHING AFTER BOOST)

## Page 116
#          (RRECTCSM ...XKEPCSM MUST BE KEPT IN THIS ORDER)

RRECTCSM        ERASE           +5                      # B(6)PRM CSM VARIABLES.
RRECTOTH        =               RRECTCSM
VRECTCSM        ERASE           +5                      # B(6)PRM
TETCSM          ERASE           +1                      # B(2)PRM
TETOTHER        =               TETCSM
DELTACSM        ERASE           +5                      # B(6)PRM
NUVCSM          ERASE           +5                      # B(6)PRM
RCVCSM          ERASE           +5                      # B(6)PRM
VCVCSM          ERASE           +5                      # B(6)PRM
TCCSM           ERASE           +1                      # B(2)PRM
XKEPCSM         ERASE           +1                      # B(2)PRM

#          (RRECTLEM ...XKEPLEM MUST BE KEPT IN THIS ORDER)

RRECTLEM        ERASE           +5                      # B(6)PRM LEM VARIABLES
RRECTHIS        =               RRECTLEM
VRECTLEM        ERASE           +5                      # B(6)PRM
TETLEM          ERASE           +1                      # B(2)PRM
TETTHIS         =               TETLEM
DELTALEM        ERASE           +5                      # B(6)PRM
NUVLEM          ERASE           +5                      # B(6)PRM
RCVLEM          ERASE           +5                      # B(6)PRM
VCVLEM          ERASE           +5                      # B(6)PRM
TCLEM           ERASE           +1                      # B(2)PRM
XKEPLEM         ERASE           +1                      # B(2)PRM

X789            ERASE           +5
TEPHEM          ERASE           +2
-AYO            ERASE           +1
AXO             ERASE           +1


#          STATE VECTORS FOR DOWNLINK.                   (12D)

R-OTHER         ERASE           +5                      # B(6)PRM POS VECT (OTHER VECH) FOR DNLINK
V-OTHER         ERASE           +5                      # B(6)PRM VEL VECT (OTHER VECH) FOR DNLINK

T-OTHER         =               TETCSM                  #             TIME (OTHER VECH) FOR DNLINK


#          SERVICER FOR LUNAR ASCENT AND DESCENT         (12D)

R(CSM)          EQUALS          R-OTHER                 # I(6) FOR UPDATE OF CM STATE VECS BY LM.
V(CSM)          EQUALS          V-OTHER                 # I(6)


#          REFSMMAT.                                     (18D)

## Page 117
REFSMMAT        ERASE           +17D                    # I(18D)PRM

#          ACTIVE VEHICLE CENTANG.  MUST BE DISPLAYED ANYTIME (ALMOST.)  (2D)

ACTCENT         ERASE           +1                      # I(2) S-S CENTRAL ANGLE BETWEEN ACTIVE
                                                        #  VEHICLE AT TPI TIG AND TARGET VECTOR.

#       **** USED IN CONICSEX (PLAN INERT ORIENT) ****

TIMSUBO         EQUALS          TEPHEM                  # CSEC B-42 (TRIPLE PRECISION)


#          LPS20.1 STORAGE     -ALL ARE PRM-             (9D)

LS21X           ERASE                                   # I(1)
LOSVEL          ERASE           +5                      # I(6)
MLOSV           ERASE           +1                      # I(2) MAGNITUDE OF LOS, METERS B-29


#      ***** P22  *****  (OVERLAYS LPS 20.1 STORAGE)     (6D)
VSUBC           EQUALS          LOSVEL                  # I(6)S-S  CSM VELOCITY VECTOR

#          PADLOADED ERASABLES FOR P20/P22               (6D)

RANGEVAR        ERASE           +1                      # I(2) RR RANGE ERROR VARIANCE
RATEVAR         ERASE           +1                      # I(2) RR RANGE-RATE ERROR VARIANCE
RVARMIN         ERASE                                   # I(1) MINIMUM RANGE ERROR VARIANCE
VVARMIN         ERASE                                   # I(1) MINIMUM RANGE-RATE ERROR VARIANCE


#          P32-P33 STORAGE                               (2D)

TCDH            ERASE           +1                      # I(2) T2 CDH TIME IN CS. (ALSO DOWNLINKED

#          TIME SAVE FOR P20 AGS DOWNLIST                (2D)

OLDAGS          ERASE           +1                      # I(2)

## Page 118
#          EBANK-4 ASSIGNMENTS

                SETLOC          2000

# E4 IS, FOR THE MOST PART RESERVED FOR PAD LOADED AND UNSHARABLE ERASE.

#          P20 STORAGE. -PAD LOADED-                     (6D)

WRENDPOS        ERASE                                   # B(1)PL                            KM*2(-7)
WRENDVEL        ERASE                                   # B(1)PL                      KM(-1/2)*2(11)
WSHAFT          ERASE                                   # B(1)PL                            KM*2(-7)
WTRUN           ERASE                                   # B(1)PL                            KM*2(-7)
RMAX            ERASE                                   # B(1)PL                       METERS*2(-19)
VMAX            ERASE                                   # B(1)PL                        M/CSEC*2(-7)

#          LUNAR SURFACE NAVIGATION -- PAD LOADED --      (2D)

WSURFPOS        ERASE                                   # B(1)PL
WSURFVEL        ERASE                                   # B(1)PL


#          P22 STORAGE. -PAD LOADED-                      (2D)

SHAFTVAR        ERASE                                   # B(1)PL			RAD SQ*2(12)
TRUNVAR         ERASE                                   # B(1)PL			RAD SQ*2(10)

#          CONISEX STORAGE.-PAD LOADED-                   (6D)

504LM           ERASE           +5                      # I(6)MOON LIBRATION VECTOR


# STORAGE FOR RLS AND TLAND - PAD LOADS - ORDER IS RETAINED FOR UPLINK. (8D)

RLS             ERASE           +5                      # I(6) LANDING SITE VECTOR - MOON REF.
TLAND           ERASE           +1                      # B(2) NOMINAL LANDING TIME.

#          INTEGRATION STORAGE.                          (94D)

PBODY           ERASE           +93D                    # I(1)
ALPHAV          EQUALS          PBODY           +1      # I(6)
BETAV           EQUALS          ALPHAV          +6      # I(6)
PHIV            EQUALS          BETAV           +6      # I(6)
PSIV            EQUALS          PHIV            +6      # I(6)
FV              EQUALS          PSIV            +6      # I(6)    PERTURBING ACCELERATIONS
ALPHAM          EQUALS          FV              +6      # I(2)
BETAM           EQUALS          ALPHAM          +2      # I(2)
TAU.            EQUALS          BETAM           +2      # I(2)

## Page 119
DT/2            EQUALS          TAU.            +2      # I(2)
H               EQUALS          DT/2            +2      # I(2)
IRETURN         EQUALS          H               +2      # I(1)
NORMGAM         EQUALS          IRETURN         +1      # I(1)
RPQV            EQUALS          NORMGAM         +1
ORIGEX          EQUALS          RPQV            +6      # I(1)
KEPRTN          EQUALS          ORIGEX                  # I(1)
RPSV            EQUALS          ORIGEX          +1      # I(6)
XKEPNEW         EQUALS          RPSV            +6      # I(2)
VECTAB          EQUALS          XKEPNEW         +2      # I(36D)


#          R04 - R77 FAIL COUNTER                        (1D)

RFAILCNT        ERASE                                   # B(1)


#          SERVICER STORAGE   (USED BY ALL POWERED FLIGHT PROGS.)  (18D)

XNBPIP          EQUALS          VECTAB          +12D    # I(6)
YNBPIP          EQUALS          XNBPIP          +6      # I(6)
ZNBPIP          EQUALS          YNBPIP          +6      # I(6)


#          SOME VERB 82 STORAGE                          (4D)

HAPOX           EQUALS          RPSV                    # I(2)
HPERX           EQUALS          HAPOX           +2      # I(2)

#          V82 STORAGE                                   (6D)

VONE'           EQUALS          VECTAB          +30D    # I(6)TMP  NORMAL VELOCITY VONE /SQRT. MU


#         R31 (V83) STORAGE. -SHARES WITH INTEGRATION STORAGE-      (26D)

BASETHV         EQUALS          RPQV                    # I(6)     BASE VEL VECTOR THIS VEH


BASETIME        EQUALS          RPSV                    # I(2)   TIME ASSOC WITH BASE VECTORS
BASEOTV         EQUALS          YLEM                    # I(6)    BASE VELOC VECTOR OTHER VEH


BASEOTP         EQUALS          VECTAB          +6      # I(6)     BASE POS VECTOR OTHER VEH

BASETHP         EQUALS          VECTAB          +30D    # I(6)     BASE POS VECTOR THIS VEH

## Page 120
#          KEPLER STORAGE. (KEPLER IS CALLED BY PRECISION INTEGRATION AND (2D)
#          CONICS)

EPSILONT        ERASE           +1                      # I(2)


#          R36 STORAGE  (N90)                             (6D)
YLEM            ERASE           +5                      # I(2)
YDOTLEM         EQUALS          YLEM            +2      # I(2)
PHILEM          EQUALS          YDOTLEM         +2      # I(2)


#          VERB 83 STORAGE.                              (18D)

RONE            ERASE           +17D                    # I(6)
VONE            EQUALS          RONE            +6      # I(6)TMP VECTOR STORAGE.  (SCRATCH)


RANGE           EQUALS          VONE            +6      # I(2)
RRATE           EQUALS          RANGE           +2      # I(2)
RTHETA          EQUALS          RRATE           +2      # I(2)


#          VERB 67 STORAGE                               (6D)

WWPOS           EQUALS          YLEM                    # B(2)   NOUN 99  (V67)
WWVEL           EQUALS          WWPOS           +2      # B(2)   NOUN 99  (V67)
WWBIAS          EQUALS          WWVEL           +2      # B(2)   NOUN 99  (V67)

#


#          V82 STORAGE. (CANNOT OVERLAY RONE OR VONE)    (5D)

V82FLAGS        EQUALS          VECTAB          +6      #  (1) FOR V82 BITS.
TFF             EQUALS          V82FLAGS        +1      # I(2)
-TPER           EQUALS          TFF             +2      # I(2)

#          MORE V82 STORAGE.  (CANNOT OVERLAY RONE OR VONE) (6D)

HPERMIN         EQUALS          YLEM                    # I(2)   SET TO 300K FT OR 35K FT SR30.1
RPADTEM         EQUALS          HPERMIN         +2      # I(2) PAD OR LANDING RADIUS FOR SR30.1
TSTART82        EQUALS          RPADTEM         +2      # I(2) TEMP TIME STORAGE FOR V82.


#          ALIGNMENT PLANETARY-INERTIAL TRANSFORMATION STORAGE.       (18D)

## Page 121
#               UNSHARED WHILE LM ON LUNAR SURFACE.

GSAV            ERASE           +17D                    # I(6)
YNBSAV          EQUALS          GSAV            +6      # I(6)
ZNBSAV          EQUALS          YNBSAV          +6      # I(6)


#          KALCMANU STORAGE. CAN OVERLAY GSAV.           (18D)

MFS             EQUALS          GSAV                    # I(18)
MFI             EQUALS          MFS                     # I
KEL             EQUALS          MFS                     # I(18)

#          P32-P35, P72-P75 STORAGE.                     (40D)

T1TOT2          ERASE           +1                      #  (2)     TIME FROM CSI TO CDH
T2TOT3          ERASE           +1                      #  (2)
ELEV            ERASE           +1                      #  (2)
UP1             ERASE           +5                      #  (6)
DELVEET1        ERASE           +5                      # I(6)     DV CSI IN REF
DELVEET2        ERASE           +5                      # I(6)     DV CSH IN REF
RACT1           ERASE           +5                      #  (6)     POS VEC OF ACTIVE AT CSI TIME
RACT2           ERASE           +5                      #  (6)     POS VEC OF ACTIVE AT CDH TIME
RTSR1/MU        ERASE           +1                      #  (2)     SQ ROOT 1/MU STORAGE
RTMU            ERASE           +1                      #  (2)     MU STORAGE


#          (THE FOLLOWING ERASABLES OVERLAY PORTIONS OF THE PREVIOUS SECTION)

+MGA            EQUALS          T1TOT2                  #  (2) S-S + MID GIM ANGL TO DELVEET3


UNRM            EQUALS          UP1                     # I(6) S-S


DVLOS           EQUALS          RACT1                   # I(6) S-S DELTA VELOCITY,LOS COORD-DISPLA
ULOS            EQUALS          RACT2                   # I(6) S-S UNIT LINE OF SIGHT VECTOR


NOMTPI          EQUALS          RTSR1/MU                # (2) S-S NOMINAL TPI TIME FOR RECYCLE


#          SOME P30 STORAGE.                             (4D)

HAPO            EQUALS          RTSR1/MU                # I(2)
HPER            EQUALS          HAPO            +2      # I(2)

## Page 122
#          THE FOLLOWING ARE ERASABLE LOADS DURING A PERFORMANCE TEST.

TRANSM1         EQUALS          WRENDPOS                # E4,1400
ALFDK           EQUALS          TRANSM1         +18D


# ******* THE FOLLOWING SECTIONS OVERLAY V83 AND DISPLAY STORAGE *******


#          V47(R47)AGS INITIALIZATION PROGRAM STORAGE.  (OVERLAYS V83) (14D)

AGSBUFF         EQUALS          YLEM                    # B(14)
AGSBUFFE        EQUALS          AGSBUFF         +13D    # ENDMARK


#          R36 OUT-OF-PLANE RENDEZVOUS DISPLAY STORAGE.  (OVERLAYS V83)  (12D)

RPASS36         EQUALS          RONE                    # I(6) S-S
UNP36           EQUALS          RPASS36         +6      # I(6) S-S


#          S-BAND ANTENNA GIMBAL ANGLES. DISPLAYED BY R05(V64). (OVERLAYS V83)        (10D)
#

ALPHASB         EQUALS          YLEM                    # B(2)  DSP NOUN 51 PITCH ANGLE
BETASB          EQUALS          ALPHASB         +2      # B(2)DSP NOUN 51. YAW ANGLE.
RLM             EQUALS          BETASB          +2      # I(6)S    S/C POSITION VECTOR.

#          **** USED IN S-BAND ANTENNA FOR LM ****        (4D)

PITCHANG        EQUALS          ALPHASB                 # I(2) PITCH/ANTENNA GIMBAL ANGLE REQUIRED
YAWANG          EQUALS          BETASB                  # I(2) YAW  /TO POINT LM STEERABLE ANTENNA
                                                        #           /TOWARD CENTER OF EARTH
#          NOUN 56 DATA - COMPUTED AND DISPLAYED BY VERB 85. (4)

RR-AZ           EQUALS          PITCHANG                # I(2) ANGLE BETWEEN LOS AND X-Z PLANE.
RR-ELEV         EQUALS          RR-AZ           +2      # I(2) ANGLE BETWEEN LOS AND Y-Z PLANE.

#          R04(V62) RADAR TEST STORAGE.                  (8D)
#

RSTACK          EQUALS          YLEM                    # B(8) BUFFER FOR R04 NOUNS
#


#          INITVEL STORAGE.  ALSO USED BY P31,P34,P35,P74,P75,P10,P11,MIDGIM,S40.1 AND S40.9. (18D)

#                  (POSSIBLY RINIT & VINIT CAN OVERLAY DELVEET1 & 2 ABOVE)
RINIT           ERASE           +5                      # I(6) ACTIVE VEHICLE POSITION
VINIT           ERASE           +5                      # I(6) ACTIVE VEHICLE VELOCITY

## Page 123
VIPRIME         ERASE           +5                      # I(6) NEW VEL REQUIRED AT INITIAL RADIUS.

#  BALLANGS-AUTOMATIC MANEUVER -- R60,(N18              (3D)

FDAIX           ERASE                                   # I(1)
FDAIY           ERASE                                   # I(1)
FDAIZ           ERASE                                   # I(1)


#          P34-P35 STORAGE.  DOWNLINKED.                 (2D)

DELVTPF         ERASE           +1                      # I(2) DELTA V FOR TPF


#          LPS20.1 STORAGE.  CALLED BY R65.              (12D)

LMPOS           ERASE           +5                      # I(6)TEMP. STORAGE FOR LM POS. VECTOR.
LMVEL           ERASE           +5                      # I(6)TEMP. STORAGE FOR LM VEL. VECTOR.

# INITVEL STORAGE.  ALSO USED BY P31,34,35,74,75,S40.1 AND DOWNLINKED.  (6D)

DELVEET3        ERASE           +5                      # I(6) DELTA V IN INERTIAL COORDINATES.


#          SOME R04(V63)-R77 STORAGE.                    (5D)

RTSTDEX         ERASE                                   # B(1)
RTSTMAX         ERASE                                   # B(1)
RTSTBASE        ERASE                                   # B(1)
RTSTLOC         ERASE                                   # B(1)
RSAMPDT         ERASE                                   # B(1)


#          SECOND DPS GUIDANCE  (LUNAR LANDING) (OVERLAYS KALCMANU & P57) (6D)

ANGTERM         =               GSAV                    # I(6)     GUIDANCE
#

#

#          ASCENT GUIDANCE FOR LUNAR LANDING             (54D)

AT              EQUALS          UP1             +2      # I(2)TMP ENGINE DATA -- THRUST ACC*2 (9)
VE              EQUALS          AT              +2      # I(2)TMP  EXHAUST VELOCITY * 2(7)M/CS.
TTO             EQUALS          VE              +2      # I(2)TMP  TAILOFF TIME * 2(17)CS.
TBUP            EQUALS          TTO             +2      # I(2)TMP  (M/MDOT) * 2(17)CS.
RDOTD           EQUALS          TBUP            +2      # I(2)TMP  TARGET VELOCITY COMPONENTS
YDOTD           EQUALS          RDOTD           +2      # I(2)TMP SCALING IS 2(7)M/CS.
ZDOTD           EQUALS          YDOTD           +2      # I(2)TMP

## Page 124
/R/MAG          EQUALS          ZDOTD           +2      # I(2)TMP
LAXIS           EQUALS          /R/MAG          +2      # I(6)TMP


YDOT            =               LAXIS           +6      # I(2)TMP VEL. NORMAL TO REF. PLANE*2(-7)
ZDOT            EQUALS          YDOT            +2      # I(2)TMP  DOWN RANGE VEL *2(-7).
GEFF            EQUALS          ZDOT            +2      # I(2)TMP  EFFECTIVE GRAVITY

#    THESE TWO GROUPS OF ASCENT GUIDANCE ARE SPLIT BY THE ASCENT-DESCENT SERVICER SECTION FOLLOWING THIS SECTION

Y               EQUALS          /LAND/          +2      # I(2)TMP  OUT-OF-PLANE DIST *2(24)M
DRDOT           EQUALS          Y               +2      # I(2)TMP  RDOTD - RDOT
DYDOT           EQUALS          DRDOT           +2      # I(2)TMP  YDOTD - YDOT
DZDOT           EQUALS          DYDOT           +2      # I(2)TMP  ZDOTD - ZDOT
PCONS           EQUALS          DZDOT           +2      # I(2)TMP  CONSTANT IN ATR EQUATION
YCONS           EQUALS          PCONS           +2      # I(2)TMP  CONSTANT IN ATY EQUATION
PRATE           EQUALS          YCONS           +2      # I(2)TMP  RATE COEFF. IN ATR EQUATION
YRATE           EQUALS          PRATE           +2      # I(2)TMP  RATE COEFF. IN ATY EQUATION
ATY             EQUALS          YRATE           +2      # I(2)TMP  OUT-OF-PLANE THRUST COMP.*2(9)
ATR             EQUALS          ATY             +2      # I(2)TMP  RADIAL THRUST COMP.* 2(9)
ATP             EQUALS          ATR             +2      # I(2)TMP  DOWN-RANGE THRUST COMP
YAW             EQUALS          ATP             +2      # I(2)TMP
PITCH           EQUALS          YAW             +2      # I(2)RMP


#          SERVICER FOR LUNAR ASCENT AND DESCENT         (14D)

G(CSM)          EQUALS          GEFF            +2      # I(6) FOR UPDATE OF COMMAND MODULE STATE
#R(CSM)          EQUALS          R-OTHER                      VECTORS BY LEM; ANALOGS OF GDT/2,
#V(CSM)          EQUALS          V-OTHER                      R, AND V, RESPECTIVELY OF THE CSM
WM              EQUALS          G(CSM)          +6      # I(6) TMP - LUNAR ROTATION VECTOR (SM)
/LAND/          EQUALS          WM              +6      # B(2) LUNAR RADIUS AT LANDING SITE
#

#          NOTE:  R(CSM) AND V(CSM) DEFINED IN E3.
#          NOUN 26 ERASABLES      (UNSHARED)             (3D)

N26/PRI         EQUALS          RSAMPDT         +1      # B(1)  PRIO/DELAY
N26/2CAD        EQUALS          N26/PRI         +1      # B(1)  JOB/TASK 2CADR

## Page 125
#          EBANK-5 ASSIGNMENTS

                SETLOC          2400

#          W-MATRIX. ESSENTIALLY UNSHARABLE.            (162D)

W               ERASE           +161D
ENDW            EQUALS          W               +162D



# ******* OVERLAY NUMBER 1 IN EBANK 5 *******


#         W-MATRIX OVERLAY: PADLOADS -- LANDING, ABORTS               (122D)
VELBIAS         EQUALS          W                       # I(2) PL BIAS VALUE FOR VELOCITY.
                                                        # REASONABILITY TEST, 2(6) M/CS
# PLEASE PRESERVE THE ORDER OF RBRFGX THROUGH TCGIAPPR.
RBRFGX          EQUALS          VELBIAS         +2      # I(2)  POSITION TARGETS
RAPFGX          EQUALS          RBRFGX          +2      # I(2)
RBRFGZ          EQUALS          RAPFGX          +2      # I(2)
RAPFGZ          EQUALS          RBRFGZ          +2      # I(2)
VBRFGX          EQUALS          RAPFGZ          +2      # I(2)  VELOCITY TARGETS
VAPFGX          EQUALS          VBRFGX          +2      # I(2)
VBRFGZ          EQUALS          VAPFGX          +2      # I(2)
VAPFGZ          EQUALS          VBRFGZ          +2      # I(2)
ABRFGX          EQUALS          VAPFGZ          +2      # I(2)  ACCELERATION TARGETS
AAPFGX          EQUALS          ABRFGX          +2      # I(2)
ABRFGZ          EQUALS          AAPFGX          +2      # I(2)
AAPFGZ          EQUALS          ABRFGZ          +2      # I(2)
VBRFG*          EQUALS          AAPFGZ          +2      # I(2)  SCALED TARGETS FOR TTF/8CL
VAPFG*          EQUALS          VBRFG*          +2      # I(2)
ABRFG*          EQUALS          VAPFG*          +2      # I(2)
AAPFG*          EQUALS          ABRFG*          +2      # I(2)
JBRFG*          EQUALS          AAPFG*          +2      # I(2)
JAPFG*          EQUALS          JBRFG*          +2      # I(2)
#                     * SEE PARAMETER TABLE IN LUNAR LANDING GUIDANCE EQUATIONS FOR
#                                   INDIRECT ADDRESSING INTO ABOVE AREA.

GAINBRAK        EQUALS          JAPFG*          +2      # I(2)  GAINS FOR GUIDANCE FRAME ERECTION
GAINAPPR        EQUALS          GAINBRAK        +2      # I(2)
TCGFBRAK        EQUALS          GAINAPPR        +2      # I(2)  TIME CRITERIA FOR GUIDANCE FRAME
TCGIBRAK        EQUALS          TCGFBRAK        +1      # I(1)
TCGFAPPR        EQUALS          TCGIBRAK        +1      # I(1)
TCGIAPPR        EQUALS          TCGFAPPR        +1      # I(1)
VIGN            EQUALS          TCGIAPPR        +1      # I(2)  DESIRED SPEED FOR PDI
RIGNX           EQUALS          VIGN            +2      # I(2)  DESIRED 'ALTITUDE' FOR IGNITION
RIGNZ           EQUALS          RIGNX           +2      # I(2)  DESIRED GROUND RANGE FOR IGNITION
KIGNX/B4        EQUALS          RIGNZ           +2      # I(2)

## Page 126
KIGNY/B8        EQUALS          KIGNX/B4        +2      # I(2)
KIGNV/B4        EQUALS          KIGNY/B8        +2      # I(2)
LOWCRIT         EQUALS          KIGNV/B4        +2      # B(1) (HIGHCRIT MUST FOLLOW LOWCRIT)
HIGHCRIT        EQUALS          LOWCRIT         +1      # B(1)
TAUHZ           EQUALS          HIGHCRIT        +1      # P66 HORIZONTAL
QHZ             EQUALS          TAUHZ           +1      #     VELOCITY NULLING
AHZLIM          EQUALS          QHZ             +1      #       CONSTANTS
2LATE466        EQUALS          AHZLIM          +1      # I(2) MIN ELAPSED TIME SINCE PIPTIME ERE
                                                        # A P66(2 R/D) WILL BE OMITTED
DELQFIX         EQUALS          2LATE466        +4      # I(2)  LR ALT. DATA REASONABILITY PARAM

#               ** NOTE: 6 ERASABLES HERE IN THIS "LANDING/ABORTS" OVERLAY ARE FREE
#                        THEY SHARE ONLY WITH W-MATRIX AND SYSTEM TEST ERASABLES    **

LRVMAX          EQUALS          DELQFIX         +6      # B(1)   LR VEL WEIGHTING FUNCTIONS
LRVF            EQUALS          LRVMAX          +1      # B(1)   LR VEL WEIGHTING FUNCTIONS
LRWVZ           EQUALS          LRVF            +1      # B(1)   LR VEL WEIGH ING FUNCTIONS
LRWVY           EQUALS          LRWVZ           +1      # B(1)   LR VEL WEIGH ING FUNCTIONS
LRWVX           EQUALS          LRWVY           +1      # B(1)   LR VEL WEIGH ING FUNCTIONS
LRWVFZ		EQUALS		LRWVX		+1	# B(1)	 LR VEL WEIGH ING FUNCTIONS
LRWVFY          EQUALS          LRWVFZ          +1      # B(1)   LR VEL WEIG  ING FUNC IONS
LRWVFX          EQUALS          LRWVFY          +1      # B(1)   LR VEL WEIG  ING FUNC IONS
LRWVFF          EQUALS          LRWVFX          +1      # B(1)   LR VEL WEIG  ING FUNC IONS

ABSC0           EQUALS          LRWVFF          +1      # B(1)  ABSCISSAE DEFINING TERRAIN MODEL
ABSC1           EQUALS          ABSC0           +1      # B(1)
ABSC2           EQUALS          ABSC1           +1      # B(1)
ABSC3           EQUALS          ABSC2           +1      # B(1)
ABSC4           EQUALS          ABSC3           +1      # B(1)
SLOPE0          EQUALS          ABSC4           +1      # B(1)  SLOPES DEFINING TERRAIN MODEL
SLOPE1          EQUALS          SLOPE0          +1      # B(1)
SLOPE2          EQUALS          SLOPE1          +1      # B(1)
SLOPE3          EQUALS          SLOPE2          +1      # B(1)
SLOPE4          EQUALS          SLOPE3          +1      # B(1)

ABVEL*          EQUALS          BUF                     # B(1)   LR TEMP
VSELECT*        EQUALS          BUF             +1      # B(1)   LR TEMP

RODSCALE        EQUALS          SLOPE4          +1      # I(2) CLICK SCALE FACTOR FOR R.O.D.
TAUROD          EQUALS          RODSCALE        +1      # I(2) TIME CONSTANT FOR R.O.D.
LAG/TAU         EQUALS          TAUROD          +2      # I(2) LAG TIME DIVIDED BY TAUROD (P66)
MINFORCE        EQUALS          LAG/TAU         +2      # I(2) MINIMUM FORCE P66 WILL COMMAND.
MAXFORCE        EQUALS          MINFORCE        +2      # I(2) MAXIMUM FORCE P66 WILL COMMAND.
J1PARM          EQUALS          MAXFORCE        +2      # I(2) PARAMETER SET # 1:
K1PARM          EQUALS          J1PARM          +2      # I(2)    ABORT ORBIT SEMI-MAJOR AXIS COMP
J2PARM          EQUALS          K1PARM          +2      # I(2) PARAMETER SET # 2:
K2PARM          EQUALS          J2PARM          +2      # I(2)    ABORT ORBIT SEMI-MAJOR AXIS COMP
THETCRIT        EQUALS          K2PARM          +2      # I(2) CENTRAL ANGLE SWITCHING CRITERION.
RAMIN           EQUALS          THETCRIT        +2      # I(2) MINIMUM ALLOWABLE APOLUNE.
YLIM            EQUALS          RAMIN           +2      # I(2) MAXIMUM CROSS-RANGE DIST. IN ABORTS

## Page 127
ABTRDOT         EQUALS          YLIM            +2      # I(2) DESIRED RADIAL VEL. FOR ABORTS.
COSTHET1        EQUALS          ABTRDOT         +2      # I(2) COS OF CONE 1 ANGLE FOR ABORTS
COSTHET2        EQUALS          COSTHET1        +2      # I(2) COS OF CONE 2 ANGLE FOR ABORTS.


#          SOME VARIABLES FOR SECOND DPS GUIDANCE       (38D)

CG              EQUALS          COSTHET2        +2      # I(18D) GUIDANCE
RANGEDSP        EQUALS          CG              +18D    # B(2) DISPLAY
OUTOFPLN        EQUALS          RANGEDSP                # *** OUTOFPLN CAN OVERLAY RANGEDSP ***
VBIAS           EQUALS          OUTOFPLN        +2      # I(6) PIPA BIAS EQUIV VELOCITY VECTOR
RGU             EQUALS          VBIAS           +6      # I(6) UNSHARED POSITION, GUIDANCE COORDS
DLAND           EQUALS          RGU             +6      # B(6) PL LANDING SITE CORRECTION,SM FRAME
DLANDX          EQUALS          DLAND
DLANDY          EQUALS          DLAND           +2
DLANDZ          EQUALS          DLAND           +4

#               OVERLAYS OF THE BLOCK ABOVE (ASCENT AND DESCENT)

JPARM           EQUALS          CG                      # I(2) JPARM WILL EQUAL J1PARM OR J2PARM
KPARM           EQUALS          JPARM           +2      # I(2) KPARM WILL EQUAL K1PARM OR K2PARM
RP              EQUALS          KPARM           +2      # I(2) PREDICTED BURNOUT RADIUS-M*2(-24)
QAXIS           EQUALS          RP              +2      # I(6) ASCENT CROSSRANGE HALF-UNIT VECTOR
ZAXIS1          EQUALS          QAXIS           +6      # I(6) ASCENT DOWNRANGE HALF-UNIT VECTOR
L*WCR*T         =               BUF
H*GHCR*T        =               BUF             +1


#          Q-SAVE REGISTER FOR ASCENT                    (1D)

ASCSAVE         EQUALS          DLAND           +6      # I(1)TMP ASCENT Q-SAVE


#          ALIGNMENT/SYSTEST/CALCSMSC COMMON STORAGE.    (36D)

XSM             EQUALS          ENDW                    # B(6)
YSM             EQUALS          XSM             +6      # B(6)
ZSM             EQUALS          YSM             +6      # B(6)

XDC             EQUALS          ZSM             +6      # B(6)
YDC             EQUALS          XDC             +6      # B(6)
ZDC             EQUALS          YDC             +6      # B(6)

XNB             =               XDC
YNB             =               YDC
ZNB             =               ZDC

#          MORE OVERLAYS TO ALIGNMENT/SYSTEST (THESE ARE P52)    (6D)

## Page 128

LANDLAT         EQUALS          STARAD                  # (2) LATITUDE, LONGITUDE
LANDLONG        EQUALS          LANDLAT         +2      # (2)     AND ALTITUDE
LANDALT         EQUALS          LANDLONG        +2      # (2)     OF LANDING SITE


#          ALIGNMENT/SYSTEST COMMON STORAGE.             (31D)

STARAD          EQUALS          ZDC             +6      # I(18D)TMP
STAR            EQUALS          STARAD          +18D    # I(6)
GCTR            EQUALS          STAR            +6      # B(1)
OGC             EQUALS          GCTR            +1      # I(2)
IGC             EQUALS          OGC             +2      # I(2)
MGC             EQUALS          IGC             +2      # I(2)

#          P57 ALIGNMENT (OVERLAY OF ALIGNMENT/SYSTEST COMMON STORAGE)   (12D)

GACC            =               STARAD                  # (6) SS
GOUT            =               STARAD          +6      # (6) SS


#          OVERLAYS WITHIN ALIGNMENT/SYSTEST COMMON STORAGE      (24D)

VEARTH          EQUALS          STARAD                  # (6)TMP
VSUN            EQUALS          VEARTH          +6      # (6)TMP
VMOON           EQUALS          VSUN            +6      # (6)TMP
SAX             EQUALS          VMOON           +6      # (6)TMP


#          P50'S,R50'S Q STORES.                         (2D)

QMIN            EQUALS          MGC             +2      # B(1)TMP
QMAJ            EQUALS          QMIN            +1      # B(1)TMP


#       **** USED IN P50S **** (SCATTERED OVERLAYS)      (18D)
CULTRIX         EQUALS          VEARTH                  # VEARTH, VSUN, VMOON


#          ALIGNMENT STORAGE.                            (23D)

OGCT            EQUALS          QMAJ            +1      # I(6)
BESTI           EQUALS          OGCT            +6      # I(1)
BESTJ           EQUALS          BESTI           +1
STARIND         EQUALS          BESTJ           +1
# RETAIN THE ORDER OF STARSAV1 TO STARSAV2 +5 FOR DOWNLINK PURPOSES.
STARSAV1        EQUALS          STARIND         +1      # I(6)
STARSAV2        EQUALS          STARSAV1        +6      # I(6)
TALIGN          EQUALS          STARSAV2        +6      # B(2) TIME OF IMU ALIGNMENT  (DOWNLINKED)

## Page 129
#          P32-35 + SERVICER                             (2D)

RTX1            EQUALS          TALIGN          +2      # I(1) X1  -2 EARTH, -10 MOON
RTX2            EQUALS          RTX1            +1      # I(1) X2  0 EARTH, 2 MOON

ZPRIME          =               22D
COSTH           =               16D
SINTH           =               18D
THETA           =               20D

## Page 130
# ******* OVERLAY NUMBER 2 IN EBANK 5 *******

#         CONICS ROUTINE STORAGE.                       (85D)

DELX            EQUALS          ENDW                    # I(2)TMP
DELT            EQUALS          DELX            +2      # I(2)TMP
URRECT          EQUALS          DELT            +2      # I(6)TMP
RCNORM          EQUALS          34D                     # I(2) TMP
#         NOTE: RCNORM (ABOVE) IS DEFINED IN VAC AREA

R1VEC           EQUALS          URRECT          +6      # I(6) TMP
R2VEC           EQUALS          R1VEC           +6      # I(6)TMP
TDESIRED        EQUALS          R2VEC           +6      # I(2)TMP
GEOMSGN         EQUALS          TDESIRED        +2      # I(1)TMP
UN              EQUALS          GEOMSGN         +1      # I(6)TMP
VTARGTAG        EQUALS          UN              +6      # I(1)TMP
VTARGET         EQUALS          VTARGTAG        +1      # I(6)TMP
RTNLAMB         EQUALS          VTARGET         +6      # I(1)TMP
U2              EQUALS          RTNLAMB         +1      # I(6)TMP
MAGVEC2         EQUALS          U2              +6      # I(2)TMP
UR1             EQUALS          MAGVEC2         +2      # I(6)TMP
SNTH            EQUALS          UR1             +6      # I(2)TMP
CSTH            EQUALS          SNTH            +2      # I(2)TMP
1-CSTH          EQUALS          CSTH            +2      # I(2)TMP
CSTH-RHO        EQUALS          1-CSTH          +2      # I(2)TMP
P               EQUALS          CSTH-RHO        +2      # I(2)TMP
R1A             EQUALS          P               +2      # I(2)TMP
RVEC            EQUALS          R1VEC                   # I(6)TMP
VVEC            EQUALS          R1A             +2      # I(6)TMP
RTNTT           EQUALS          RTNLAMB                 # I(1)TMP
ECC             EQUALS          VVEC            +6      # I(2)TMP
RTNTR           EQUALS          RTNLAMB                 # I(1)TMP
RTNAPSE         EQUALS          RTNLAMB                 # I(1)TMP
R2              EQUALS          MAGVEC2                 # I(2)TMP
RTNPRM          EQUALS          ECC             +2      # I(1)TMP
SGNRDOT         EQUALS          RTNPRM          +1      # I(1)TMP
RDESIRED        EQUALS          SGNRDOT         +1      # I(2)TMP
DELDEP          EQUALS          RDESIRED        +2      # I(2)TMP
DEPREV          EQUALS          DELDEP          +2      # I(2)TMP
TERRLAMB        EQUALS          DELDEP                  # I(2)TMP
TPREV           EQUALS          DEPREV                  # I(2)TMP
EPSILONL        EQUALS          DEPREV          +2      # I(2)TMP
COGA            EQUALS          EPSILONL        +2      # I(2)  COTAN OF INITIAL FLIGHT PATH ANGLE.
INDEP           EQUALS          COGA                    #       USED BY SUBROUTINE'ITERATOR'.

## Page 131
# ******* OVERLAY NUMBER 3 IN EBANK 5 *******


#         INCORP STORAGE.                               (18D)

ZI              EQUALS          ENDW                    # I(18)TMP

#         INCORP/L SR22.3 STORAGE.                      (21D)

DELTAX          EQUALS          ZI              +18D    # I(18)
VARIANCE        EQUALS          DELTAX          +18D    # I(3)

#         MEASUREMENT INCORPORATION -R22- STORAGE.      (49D)

GRP2SVQ         EQUALS          VARIANCE        +3      # I(1)TMP QSAVE FOR RESTARTS
OMEGAM1         EQUALS          GRP2SVQ         +1      # I(6)
OMEGAM2         EQUALS          OMEGAM1         +6      # I(6)
OMEGAM3         EQUALS          OMEGAM2         +6      # I(6)
HOLDW           EQUALS          OMEGAM3         +6      # I(18)

TRIPA           EQUALS          DELTAX                  # I(3)TMP
TEMPVAR         EQUALS          TRIPA           +3      # I(3)TMP



# INCORPORATION/INTEGRATION Q STORAGE.          (1D)

EGRESS          EQUALS          COGA            +2      # I(1)

## Page 132
#         SYSTEM TEST ERASABLES.  CAN OVERLAY W MATRIX. (127D)

# ******* OVERLAY NUMBER 0 IN EBANK 5 *******

AZIMUTH         EQUALS          W                       # 2
LATITUDE        EQUALS          AZIMUTH         +2      # 2
ERVECTOR        EQUALS          LATITUDE        +2      # 6
LENGTHOT        EQUALS          ERVECTOR        +6      # 1
LOSVEC          EQUALS          LENGTHOT        +1      # 6
NDXCTR          EQUALS          LOSVEC          +1      # 1
PIPINDEX        EQUALS          NDXCTR          +1      # 1
POSITON         EQUALS          PIPINDEX        +1      # 1
QPLACE          EQUALS          POSITON         +1      # 1
QPLACES         EQUALS          QPLACE          +1      # 1
SOUTHDR         EQUALS          QPLACES         +1      # 7
TEMPTIME        EQUALS          SOUTHDR         +7      # 2
TMARK           EQUALS          TEMPTIME        +2      # 2
GENPL           EQUALS          TMARK           +2
TEMPADD         =               GENPL           +4
TEMP            =               GENPL           +5
NOBITS          =               GENPL           +6
CHAN            =               GENPL           +7

LOS1            =               GENPL           +8D
LOS2            =               GENPL           +14D

DATAPL          EQUALS          GENPL           +30D
RESULTCT        EQUALS          GENPL           +67D
AINLA           =               GENPL                   # 110 DE  OR 156 OCT LOCATIONS

WANGO           EQUALS          AINLA                   # VERT E ATE
WANGI           EQUALS          AINLA           +2D     # HORIZO TAL ERATE
WANGT           EQUALS          AINLA           +4D     # T
TORQNDX         =               WANGT
DRIFTT          EQUALS          AINLA           +6D
ALX1S           EQUALS          AINLA           +8D
CMPX1           EQUALS          AINLA           +9D     # IND
ALK             EQUALS          AINLA           +10D    # GAINS
VLAUNS          EQUALS          AINLA           +22D
WPLATO          EQUALS          AINLA           +24D
INTY            EQUALS          AINLA           +28D    # SOUTH  IP INTE
ANGZ            EQUALS          AINLA           +30D    # EAST A IS
INTZ            EQUALS          AINLA           +32D    # EAST P P I
ANGY            EQUALS          AINLA           +34D    # SOUTH
ANGX            EQUALS          AINLA           +36D    # VE
DRIFTO          EQUALS          AINLA           +38D    # VERT
DRIFTI          EQUALS          AINLA           +40D    # SOU
VLAUN           EQUALS          AINLA           +44D
ACCWD           EQUALS          AINLA           +46D

## Page 133
POSNV           EQUALS          AINLA           +52D
DPIPAY          EQUALS          AINLA           +54D    # SOUTH
DPIPAZ          EQUALS          AINLA           +58D    # NORTH  IP INCREMENT
ALTIM           EQUALS          AINLA           +60D
ALTIMS          EQUALS          AINLA           +61D    #  INDEX
ALDK            EQUALS          AINLA           +62D    #  TIME  ONSTAN
DELM            EQUALS          AINLA           +76D
WPLATI          EQUALS          AINLA           +84D
GEOCOMPS        EQUALS          AINLA           +86D
ERCOMP          EQUALS          AINLA           +87D
ZERONDX         EQUALS          AINLA           +93D

THETAN          =               ALK             +4
FILDELV         EQUALS          THETAN          +6      #  AGS ALIGNMENT STORAGE
INTVEC          EQUALS          FILDELV         +2
1SECXT          =               AINLA           +94D
ASECXT          =               AINLA           +95D
PERFDLAY        EQUALS          AINLA           +96D    # B(2) DELAY TIME BEF. START DRIFT MEASURE
OVFLOWCK        EQUALS          AINLA           +98D    # (1) SET MEANS OVERFLOW IN IMU PERF TEST
                                                        #     AND CAUSES TERMINATION


END-E5          EQUALS          2777                    # END OF EBANK 5

## Page 134
#          EBANK-6 ASSIGNMENTS.

                SETLOC          3000

#          DAP PAD-LOADED DATA.                          (10D)

#   ALL OF THE FOLLOWING EXCEPT PITTIME AND ROLLTIME ARE INITIALIZED IN FRESH START TO PERMIT IMMEDIATE USE OF DAP

HIASCENT        ERASE                                   # (1) MASS AFTER STAGING, SCALE AT B16 KG.
ROLLTIME        ERASE                                   # (1) TIME TO TRIM Z GIMBAL IN R03, CSEC.
PITTIME         ERASE                                   # (1) TIME TO TRIM Y GIMBAL IN R03, CSEC.
DKTRAP          ERASE                                   # (1) DAP STATE            (POSSIBLE 77001
DKOMEGAN        ERASE                                   # (1)   ESTIMATOR PARA-      (VALUES 00012
DKKAOSN         ERASE                                   # (1)      METERS FOR THE           00074
LMTRAP          ERASE                                   # (1)         DOCKED AND            77001
LMOMEGAN        ERASE                                   # (1)            LEM-ALONE CASES    00000
LMKAOSN         ERASE                                   # (1)               RESPECTIVELY    00074
DKDB            ERASE                                   # (1) WIDTH OF DEADBAND FOR DOCKED RCS
                                                        #     AUTOPILOT (DB=1.4DEG IN FRESH START)
                                                        #     DEADBAND = PI/DKDB RAD.

#  PADLOADS FOR INITIALIZATION OF DAP BIAS ACCELERATION (AT P12 IGNITION)   (2D)

IGNAOSQ         ERASE                                   # B(1)PL
IGNAOSR         ERASE                                   # B(1)PL


#  AXIS TRANSFORMATION MATRIX - GIMBAL TO PILOT AXES:    (5D)

M11             ERASE                                   # SCALED AT 1
M21             ERASE                                   # SCALED AT 1
M31             ERASE
M22             ERASE                                   # SCALED AT 1.
M32             ERASE                                   # SCALED AT 1.

#  ANGLE MEASUREMENTS.                                    (31D)

OMEGAP          ERASE           +4                      # BODY-AXIS ROT. RATES SCALED AT PI/4 AND
OMEGAQ          EQUALS          OMEGAP          +1      # BODY-AXIS ACCELERATIONS SCALED AT PI/8
OMEGAR          EQUALS          OMEGAP          +2
#     RETAIN THE ORDER OF ALPHAQ AND ALPHAR FOR DOWNLINK PURPOSES.
ALPHAQ          EQUALS          OMEGAP          +3
ALPHAR          EQUALS          OMEGAP          +4
OMEGAU          ERASE           +1
OMEGAV          =               OMEGAU          +1

TRAPEDP         ERASE           +5
TRAPEDQ         =               TRAPEDP         +1
TRAPEDR         =               TRAPEDP         +2
NPTRAPS         =               TRAPEDP         +3

## Page 135
NQTRAPS         =               TRAPEDP         +4
NRTRAPS         =               TRAPEDP         +5
EDOTP           =               EDOT
EDOTQ           ERASE           +1
EDOTR           =               EDOTQ           +1      #  MANY SHARING NAMES
QRATEDIF        EQUALS          EDOTQ                   # ALTERNATIVE NAMES:
RRATEDIF        EQUALS          EDOTR                   # DELETE WHEN NO. OF REFERENCES = 0

URATEDIF        EQUALS          OMEGAU
VRATEDIF        EQUALS          OMEGAV
OLDXFORP        ERASE           +2                      # STORED CDU READINGS FOR STATE
OLDYFORP        EQUALS          OLDXFORP        +1      # DERIVATIONS: SCALED AT PI RADIANS (2'S)
OLDZFORQ        EQUALS          OLDXFORP        +2
# RATE-COMMAND AND MINIMUM IMPULSE MODES

CH31TEMP        ERASE
STIKSENS        ERASE
TCP             ERASE
DXERROR         ERASE           +5
DYERROR         EQUALS          DXERROR         +2
DZERROR         EQUALS          DXERROR         +4
PLAST           ERASE
QLAST           ERASE
RLAST           ERASE
TCQR            ERASE

# OTHER VARIABLES.                              (5D)

OLDPMIN         ERASE                                    # THESE THREE USED IN MIN IMPULSE MODE.
OLDQRMIN        ERASE
TEMP31          EQUALS          DAPTEMP1

SAVEHAND        ERASE           +1
PERROR          ERASE
QERROR          EQUALS          DYERROR
RERROR          EQUALS          DZERROR

# JET STATE CHANGE VARIABLES- TIME (TOFJTCHG),JET BITS WRITTEN NOW   (10D)
#   (JTSONNOW), AND JET BITS WRITTEN AT T6 RUPT (JTSATCHG).

NXT6ADR         ERASE
T6NEXT          ERASE           +1
T6FURTHA        ERASE           +1
NEXTP           ERASE           +2
NEXTU           =               NEXTP           +1
NEXTV           =               NEXTP           +2
-2JETLIM        ERASE           +1                      # RATE COMMAND 4-JET RATE DIFFERENCE LIMIT
-RATEDB         EQUALS          -2JETLIM        +1      # AND RATE DEADBAND FOR ASCENT OR DESCENT

TARGETDB        EQUALS          -RATEDB                 # MAN. CONTROL TARGET DB COMPLEMENT.

#       *** Q,R AXIS ERASABLES ***                        (3)

## Page 136
PBIT            EQUALS          BIT10
QRBIT           EQUALS          BIT11
UERROR          EQUALS          DAPTREG5                # U,V-AXES ATT ERROR FOR RCS CONTROL LAWS
VERROR          =               UERROR          +1
RETJADR         ERASE
TEMPNUM         EQUALS          DAPTEMP4
NUMBERT         EQUALS          DAPTEMP5
ROTINDEX        EQUALS          DAPTEMP6
ROTEMP1         EQUALS          DAPTEMP1
ROTEMP2         EQUALS          DAPTEMP2
POLYTEMP        EQUALS          DAPTEMP3
SENSETYP        ERASE
ABSTJ           EQUALS          DAPTEMP1                # ABS VALUE OF JET-FIRING TIME
ABSEDOTP        EQUALS          DAPTEMP1

## Page 137
# TRIM GIMBAL CONTROL LAW ERASABLES:                     (11D)

GTSTEMPS        EQUALS          DAPTEMP1                # GTS IS PART OF THE JASK.
SHFTFLAG        EQUALS          GTSTEMPS        +2      # COUNT BITS FOR GTSQRT SHIFTING.
ININDEX         EQUALS          GTSTEMPS        +5      # INDEX FOR SHIFT LOOP IN GTSQRT.

SAVESR          EQUALS          AXISCTR                 # CANNOT BE A DAPTEMP - GTS USES THEM ALL.

SCRATCH         EQUALS          GTSTEMPS        +7      # ROOTCYCL ERASABLE
HALFARG         EQUALS          GTSTEMPS        +8D     # ROOTCYCL ERASABLE.

K2THETA         EQUALS          GTSTEMPS                # D.P., K*ERROR,  NEGUSUM
KCENTRAL        EQUALS          GTSTEMPS        +2      # S.P., K FROM KQ OR KRDAP, AT PI/2(8)
K2CNTRAL        EQUALS          GTSTEMPS        +3      # D.P., GTS SCRATCH CELLS.
WCENTRAL        EQUALS          GTSTEMPS        +4      # S.P., OMEGA, AT PI/4 RAD/SEC
ACENTRAL        EQUALS          GTSTEMPS        +5      # S.P., ALPHA, AT PI/4 RAD/SEC(2)
DEL             EQUALS          GTSTEMPS        +6      # S.P., SGN FUNCTION VALUE.
A2CNTRAL        EQUALS          GTSTEMPS        +7      # D.P., GTS SCRATCH CELLS.
QRCNTR          EQUALS          GTSTEMPS        +9D     # S.P.,INDEX FOR GTS LOOP THROUGH Q,R AXES
FUNCTION        EQUALS          GTSTEMPS        +10D    # D.P.,ARGUMENT FOR GRSQRT,SCRATCH FOR GTS

NEGUQ           ERASE           +2                      # NEGATIVE OF Q-AXIS GIMBAL DRIVE
#                               NEGUQ           +1          DEFINED AND USED ELSEWHERE
NEGUR           EQUALS          NEGUQ           +2      # NEGATIVE OF R-AXIS GIMBAL DRIVE

KQ              ERASE           +2                      # S.P.,JERK TERM FOR GTS, AT PI/2(8)
AXISCTR         EQUALS          KQ              +1
KRDAP           EQUALS          KQ              +2      # .3 ACCDOTR SCALED AT PI/2(8)

ACCDOTQ         ERASE           +3                      # Q-JERK SCALED AT PI/2(7) UNSIGNED
QACCDOT         EQUALS          ACCDOTQ         +1      # Q-JERK SCALED AT PI/2(7) SIGNED
ACCDOTR         EQUALS          ACCDOTQ         +2      # R-JERK SCALED AT PI/2(7) UNSIGNED
RACCDOT         EQUALS          ACCDOTQ         +3      # R-JERK SCALED AT PI/2(7) SIGNED

QDIFF           EQUALS          QERROR                  # ATTITUDE ERRORS:
RDIFF           EQUALS          RERROR                  # SCALED AT PI RADIANS




# TORQUE VECTOR RECONSTRUCTION VARIABLES:       (17D)

JETRATE         EQUALS          DAPTREG1
JETRATEQ        EQUALS          JETRATE         +1      # THE LAST CONTROL SAMPLE PERIOD OF 100 MS
JETRATER        EQUALS          JETRATE         +2      # SCALED AT PI/4 RADIANS/SECOND

DOWNTORK        ERASE           +5                      # ACCUMULATED JET TORQUE COMMANDED ABOUT
POSTORKP        EQUALS          DOWNTORK                #   +,-P, +,-U, +,-V RESPECTIVELY.
NEGTORKP        EQUALS          DOWNTORK        +1      #
POSTORKU        EQUALS          DOWNTORK        +2      #   NOT INITIALIZED; PERMITTED TO OVERFLOW

## Page 138
NEGTORKU        EQUALS          DOWNTORK        +3      # SCALED AT 32 JET-SEC, OR ABOUT 2.0 JET-
POSTORKV        EQUALS          DOWNTORK        +4      #     MSEC PER BIT.
NEGTORKV        EQUALS          DOWNTORK        +5

NO.PJETS        ERASE           +2
NO.UJETS        =               NO.PJETS        +1
NO.VJETS        =               NO.UJETS        +1
TJP             ERASE           +2
TJU             =               TJP             +1
TJV             =               TJP             +2

L,PVT-CG        ERASE
1JACC           ERASE           +3
1JACCQ          EQUALS          1JACC           +1      # SCALED AT PI/4 RADIANS/SECOND
1JACCR          EQUALS          1JACC           +2
1JACCU          EQUALS          1JACC           +3      # FOR U,V-AXES THE SCALE FACTOR IS  DIFF:
                                                        # SCALED AT PI/2 RADIANS/SECOND (FOR ASC)
# ASCENT VARIABLES:                                       (10D)


SKIPU           ERASE           +1
SKIPV           =               SKIPU           +1
# THE FOLLOWING LM DAP ERASABLES ARE ZEROED IN THE STARTDAP SECTION OF THE DAPIDLER PROGRAM AND THE COASTASC
# SECTION OF THE AOSTASK.  THE ORDER MUST BE PRESERVED FOR THE INDEXING METHODS WHICH ARE EMPLOYED IN THOSE
# SECTIONS AND ELSEWHERE.

AOSQ            ERASE           +5                      # OFFSET ACC. ESTIMATES, UPDATED IN D.P.,
AOSR            EQUALS          AOSQ            +2      # AND SCALED AT PI/2.
AOSU            EQUALS          AOSQ            +4      # UV-AXES OFFSET ACC. FROMED BY VECTOR
AOSV            EQUALS          AOSQ            +5      # ADDITION OF Q,R.  AT PI/2 RAD/SEC(2).

AOSQTERM        ERASE           +1                      # (.1-.05K)AOS
AOSRTERM        EQUALS          AOSQTERM        +1      # SCALED AT PI/4 RADIANS/SECOND.

# FOR TJET LAW SUBROUTINE:                              (TEMPS ONLY)

#NUMBERT        EQUALS          DAPTEMP5                DEFINED IN QRAXIS.
EDOTSQ          EQUALS          DAPTEMP1
ROTSENSE        EQUALS          DAPTEMP2
FIREFCT         EQUALS          DAPTEMP3                # LOOKED AT BY PAXIS.
TTOAXIS         EQUALS          DAPTEMP4
ADRSDIF2        EQUALS          DAPTEMP6
HOLDQ           EQUALS          DAPTREG1
ADRSDIF1        EQUALS          DAPTREG2
HH              EQUALS          DAPTREG3                # DOUBLE PRECISION
# HH +1         EQUALS          DAPTREG4
E               EQUALS          DAPTREG6                # TIME SHARE WITH VERROR
EDOT            EQUALS          OMEGAV

# INPUT TO TJET LAW (PERMANENT ERASABLES).              (48D)

## Page 139
TJETU           =               TJU                     # EQUATE NAMES.  INDEXED BY -1, 0, +1.
BLOCKTOP        ERASE           +47D
#               * SEE AOSTASK AND AOSJOB LOG SECTION FOR ERASABLE DEFINITIONS
#                                        IN THIS AREA.

1/ANET1         =               BLOCKTOP        +16D    # THESE 8 PARAMETERS ARE SET UP BY 1/ACCS
1/ANET2         =               1/ANET1         +1      # FOR MINIMUM JETS ABOUT THE U-AXIS WHEN
1/ACOAST        =               1/ANET1         +4      # EDOT IS POSITIVE.  TJETLAW INDEXES BY
ACCFCTZ1        =               1/ANET1         +6      # ADRSDIFF FROM THESE REGISTERS TO PICK UP
ACCFCTZ5        =               1/ANET1         +7      # PARAMETERS FOR THE PROPER AXIS, NUMBER
FIREDB          =               1/ANET1         +10D    # OF JETS AND SIGN OF EDOT.  THERE ARE 48
COASTDB         =               1/ANET1         +12D    # REGISTERS IN ALL IN THIS BLOCK.
AXISDIST        =               1/ANET1         +14D    # FOUR NOT REFERENCED (P-AXIS) ARE FILLED
                                                        #   IN BY THE FOLLOWING:
ACCSWU          =               BLOCKTOP                # SET BY 1/ACCS TO SHOW WHETHER MAXIMUM
ACCSWV          =               ACCSWU          +1      # JETS ARE REQUIRED BECAUSE OF AOS.
FLAT            =               BLOCKTOP        +6      # WIDTH OF MINIMUM IMPULSE ZONE.
ZONE3LIM        =               BLOCKTOP        +7      # HEIGHT OF MINIMUM IMPULSE ZONE (AT 4 SEC)

COEFFQ          ERASE           +1                      # COEFFQ AND COEFFR ARE USED IN ROT-TOUV
COEFFR          EQUALS          COEFFQ          +1      # TO RESOLVE Q,R COMPONENTS INTO U,V COMP.

# VARIABLES FOR GTS-QRAXIS CONTROL EXCHANGE.              (4)

ALLOWGTS        EQUALS          NEGUQ           +1      # INSERT INTO UNUSED LOCATION
COTROLER        ERASE                                   # INDICATES WHICH CONTROL SYSTEM TO USE.
QGIMTIMR        ERASE           +2                      # Q-GIMBAL DRIVE ITMER, DECISECONDS.
INGTS           EQUALS          QGIMTIMR        +1      # INDICATOR OF CURRENT GTS CONTROL.
RGIMTIMR        EQUALS          QGIMTIMR        +2      # R-GIMBAL DRIVE TIMER, DECISECONDS.

# PLEASE RETAIN THE ORDER OF CDUXD THRU CDUZD FOR DOWNLINK PURPOSES.

#          KALCMANU:DAP INTERFACE.                        (9D)

CDUXD           ERASE           +2                      # CDU DESIRED REGISTERS:
CDUYD           EQUALS          CDUXD           +1      # SCALED AT PI RADIANS (180 DEGREES)
CDUZD           EQUALS          CDUXD           +2      # (STORE IN 2S COMPLEMENT)

DELCDUX         ERASE           +2                      # NEGATIVE OF DESIRED 100MS CDU INCREMENT:
DELCDUY         EQUALS          DELCDUX         +1      # SCALED AT PI RADIANS (180 DEGREES)
DELCDUZ         EQUALS          DELCDUX         +2      # (STORE IN 2S COMPLEMENT)

#    RETAIN THE ORDER OF OMEGAPD TO OMEGARD FOR DOWNLINK PURPOSES.

OMEGAPD         ERASE           +2                      # ATTITUDE MANEUVER DESIRED RATES:
OMEGAQD         EQUALS          OMEGAPD         +1      # (NOT EXPLICITLY REFERENCED IN GTS CNTRL)
OMEGARD         EQUALS          OMEGAPD         +2      # SCALED AT PI/4 RADIANS/SECOND

# KALCMANU STORAGE.                             (24D)

## Page 140
MIS             ERASE           +23D                    # I(18D)
COF             EQUALS          MIS             +18D    # I(6)


# KALCMANU STORAGE.                                     (33D)

BCDU            ERASE           +30D                    # B(3)
KSPNDX          EQUALS          BCDU            +3      # B(1)
KDPNDX          EQUALS          KSPNDX          +1      # B(1)

TMIS            EQUALS          KDPNDX          +1      # I(18) MUST BE IN SAME BANK AS RCS DAP
COFSKEW         EQUALS          TMIS            +18D    # I(6)  MUST BE IN SAME BANK AS RCS DAP
CAM             EQUALS          COFSKEW         +6      # I(2)  MUST BE IN SAME BANK AS RCS DAP

AM              ERASE           +1                      # I(2) THIS WAS ONCE IN E5 OVERLAYING OGC

# FIRST-ORDER OVERLAYS IN KALCMANU                      (25D)

MFISYM          EQUALS          TMIS                    # I
TMFI            EQUALS          TMIS                    # I
NCDU            EQUALS          TMIS                    # B
NEXTIME         EQUALS          TMIS            +3      # B
TTEMP           EQUALS          TMIS            +4      # B
BRATE           EQUALS          COFSKEW                 # B
TM              EQUALS          CAM                     # B

# SECOND-ORDER OVERLAYS IN KALCMANU             (?)

VECQTEMP        =               COFSKEW

DCDU            =               CDUXD
DELDCDU         =               DELCDUX
DELDCDU1        =               DELCDUY
DELDCDU2        =               DELCDUZ


# *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  * 

# STORAGE FOR FINDCDUW

#          OVERLAYING KALCMANU STORAGE:                  (26D)

ECDUW           EQUALS          MIS
ECDUWUSR        EQUALS          ECDUW                   # B(1)TMP
QCDUWUSR        EQUALS          ECDUWUSR        +1      # I(1)TMP
NDXCDUW         EQUALS          QCDUWUSR        +1      # B(1)TMP
FLAGOODW        EQUALS          NDXCDUW         +1      # B(1)TMP
UNFC/2          EQUALS          FLAGOODW        +1      # I(6)IN

## Page 141
UNWC/2          EQUALS          UNFC/2          +6      # I(6)IN
UNFV/2          EQUALS          UNWC/2          +6      # I(6) S-S
UNFVX/2         =               UNFV/2
UNFVY/2         =               UNFV/2          +2
UNFVZ/2         =               UNFV/2          +4
-DELGMB         EQUALS          UNFV/2          +6      # B(3)TMP
OGABIAS         EQUALS          -DELGMB         +3      # B(1)IN

#          DEFINED IN THE WORK AREA:                     (18D)

UNX/2           =               0
UNY/2           =               6
UNZ/2           =               14

# END OF FINDCDUW ERASABLES

# *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  * 

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

# STORAGE FOR P57

#          OVERLAYING KALCMANU AND FINDCDUW STORAGE:     (12D)

VEC1            EQUALS          MIS                     # I(6)TMP
VEC2            EQUALS          VEC1            +6      # I(6)TMP

# END OF P57 ERASABLES

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

# THE FOLLOWING ARE THE DAP REPLACEMENTS FOR THE ITEMPS AND RUPTREGS,NEEDED BECAUSE DAP IS NOW A TOB,JASK,JAB,TOSK
# ... ANYWAY, THE DAP CAN NOW BE INTERRUPTED.                              (18D)

DAPTEMP1        ERASE           +17D
DAPTEMP2        EQUALS          DAPTEMP1        +1
DAPTEMP3        EQUALS          DAPTEMP1        +2
DAPTEMP4        EQUALS          DAPTEMP1        +3
DAPTEMP5        EQUALS          DAPTEMP1        +4
DAPTEMP6        EQUALS          DAPTEMP1        +5
DAPTREG1        EQUALS          DAPTEMP1        +6
OLDSENSE        EQUALS          DAPTREG1                # B(1)TMP RCS JET CONTROL
DAPTREG2        EQUALS          DAPTEMP1        +7
DAPTREG3        EQUALS          DAPTEMP1        +8D
DAPTREG4        EQUALS          DAPTEMP1        +9D
DAPTREG5        EQUALS          DAPTEMP1        +10D
DAPTREG6        EQUALS          DAPTEMP1        +11D

DAPARUPT        EQUALS          DAPTEMP1        +12D
DAPLRUPT        EQUALS          DAPARUPT        +1

## Page 142
DAPBQRPT        EQUALS          DAPARUPT        +2
DAPZRUPT        EQUALS          DAPARUPT        +4

                                                        # (DAPZRUPT IS ALSO JASK-IN-PROGRESS FLAG)


#          NEEDLER(ATTITUDE ERROR EIGHT BALL DISPLAY) STORAGE.   (6D)

T5TEMP          EQUALS          ITEMP1
DINDX           EQUALS          ITEMP3
AK              ERASE           +2                      # NEEDLER ATTITUDE INPUTS, SCALED AT 180
AK1             EQUALS          AK              +1      # DEGREES.  P,Q,R AXES IN AK,AK1,AK2.
AK2             EQUALS          AK              +2

EDRIVEX         ERASE           +2                      # NEEDLER DISPLAY REGS AT 1800 DEGREES.
EDRIVEY         EQUALS          EDRIVEX         +1      # SO THAT 384 BITS REPRESENT 42 3/16 DEG.
EDRIVEZ         EQUALS          EDRIVEX         +2

#          DOCKED JET INHIBITION COUNTERS                (3D)

PJETCTR         ERASE           +2
UJETCTR         EQUALS          PJETCTR         +1
VJETCTR         EQUALS          PJETCTR         +2

# V47 (R47) AGS INITIALIZATION STORAGE -PAD LOADED.      (2D)

AGSK            ERASE           +1			# I(2) PL

# WINDOW BIAS PADLOAD					 (1D)

AZBIAS          ERASE                                   # B(1) PL LPD AZIMUTH BIAS, UNITS - PI RAD

#          DAP PERMANENT STORAGE                         (1D)

RCSFLAGS        ERASE                                   # AUTOPILOT FLAG WORD
                                                        # BIT ASSIGNMENTS:
                                                        #  1) ALTERYZ SWITCH (ZEROOR1)
                                                        #  2) NEEDLER SWITCH
                                                        #  3) NEEDLER SWITCH
                                                        #  4) NEEDLER SWITCH
                                                        #  5) NEEDLER SWITCH
                                                        #  9) JUST-IN-DETENT SWITCH
                                                        # 10) PBIT - MANUAL CONTROL SWITCH
                                                        # 11) QRBIT- MANUAL CONTROL SWITCH
                                                        # 12) PSKIP CONTROL (PJUMPADR)
                                                        # 13) 1/ACCJOB CONTROL (ACCSET)

## Page 143
END-E6          EQUALS           AZBIAS         +1      # NEXT AVAILABLE LOC IN E6.

## Page 144
#                 EBANK-7 ASSIGNMENTS

                SETLOC          3400

#          P35 CONSTANTS.        - PAD LOADED -        (4D)

ATIGINC         ERASE           +1                      # B(2)PL        *MUST BE AT 1400 FOR SYSTEMSTEST
PTIGINC         ERASE           +1                      # B(2)PL


#          AOTMARK STORAGE.      - PAD LOADED -        (12D)

AOTAZ           ERASE           +5                      # B(6)PL
AOTEL           ERASE           +5                      # B(6)PL

#          LANDING RADAR.        - PAD LOADED -        (3D)

LRHMAX          ERASE                                   # B(1)
LRWH            ERASE                                   # B(1)


#          THROTTLE STORAGE.     - PAD LOADED -        (1D)

ZOOMTIME        ERASE                                   # B(1)PL TIME OF DPS THROTTLE-UP COMMAND

#          P63 AND P64 CONSTANTS. - PAD LOADED -       (4D)

TENDBRAK        ERASE                                   # B(1) LANDING PHASE SWITCHING CRITERION
TENDAPPR        ERASE                                   # B(1) LANDING PHASE SWITCHING CRITERION
DELTTFAP        ERASE                                   # B(1) INCREMENT ADDED TO TTF/8 WHEN
                                                        #       SWITCHING FROM P63 TO P64
LEADTIME        ERASE                                   # B(1) TIME INCREMENT SPECIFYING HOW MUCH
                                                        #       GUIDANCE IS PROJECTED FORWARD.

#          LANDING RADAR         - PAD LOADED -        (2D)

RPCRTIME        ERASE                                   # B(1) REPOSITIONING CRITERION  (TIME)
RPCRTQSW        ERASE                                   # B(1) REPOSITIONING CRITERION (ANGLE)

#          ASTEER                - PAD LOADED -        (2D)

TNEWA           ERASE           +1                      # I(2)PL LAMBERT CYCLE PERIOD

#          P22 STORAGE - OVERLAYS LANDING PADLOADS -   (5D)

## Page 145
REPOSCNT        EQUALS          TENDBRAK                # B(1)TMP  COUNTS NUMBER OF PASSES THROUGH
                                                        #          REPOSITION ROUTINE.
REPOSTM         EQUALS          REPOSCNT        +1      # I(2)TMP  PRESENT TIME PLUS INCREMENTS OF
                                                        #          TEN SECONDS.
DELTATM         EQUALS          REPOSTM         +2      # I(2)TMP  TIME INTERVAL FOR RUNNING
                                                        #          DESIGNATE TASK.

# *** RETAIN THE ORDER OF DELVSLV, TIG, RTARG, DELLT4 FOR UPDATE. ***


#          P40S, P32-P35 P72-P75 STORAGE                 (6D)

DELVLVC         ERASE           +5                      # I(6) DELTA VELOCITY - LOCAL VERTICAL COO
DELVSLV         =               DELVLVC                 # (TEMP STORAGE OF SAME VECTOR)   -RDINATE
#


#          P30-P40 INTERFACE UNSHARED.                   (2D)

# ******* NOTE:  TIG IS USED BY ALL POWERED FLIGHT PROGRAMS        *******
# *******              INCLUDING P12, ABORTS, AND LUNAR LANDING.  ********

TIG             ERASE           +1                      # B(2)


#          INITVEL STORAGE:  USED BY P34,35,74,75, P40-42  (8D)

RTARG           ERASE           +5                      # I(6) TARGET VECTOR
DELLT4          ERASE           +1                      # I(2) TIME DIFFERENCE


#          LANDING RADAR - R12   (OVERLAY)               (2D)

HLROFF          EQUALS          DELLT4                  # B(1),I(2) TMP  NO LANDING RADAR UPDATES
                                                        #                 BELOW THIS ALTITUDE.


#          CLOKTASK, BURNBABY                            (3D)

TTOGO           ERASE           +1                      # B(2)
WHICH           ERASE                                   # B(1)


#          *** R21 ***                                   (1D)

LOSCOUNT        ERASE                                   # B(1)

#          L SR22.3 (RNDEZVOUS NAVIGATION) AND

## Page 146
#          LANDING RADAR -- VELUPDAT (SERVICER), P63, AND R12.   (4D)

# ***** NOTE: AOG, AMG, AND AIG ARE USED BY LANDING RADAR AS WELL AS RR.
# *****       R12DL STORES CDUS THERE FOR DOWNLINKING ON DESCENT/ASCENT DL
# *****       MOREOVER, TRKMKCNT SHARES WITH VSELECT, ALSO SET UP BY R12DL
# *****           (DOWNLINKED ON THE DESCENT/ASCENT LIST AS THE
# *****             LOW ORDER PART OF AOG TELEMETRY WORD)
# *****                AND USED IN SERVICER, P63 RESTART, AND R12READ.

#    RETAIN THE ORDER OF AIG TO TRKMKCNT FOR DOWNLINK PURPOSES.

AIG             ERASE                                   # B(1)OUT  GIMGAL ANGLES
AMG             ERASE                                   # B(1)OUT  (MUST BE
AOG             ERASE                                   # B(1)OUT   CONSECUTIVE)

TRKMKCNT        ERASE                                   # B(1)TMP  TEMPORARY MARK STORAGE.
MARKCTR         =               TRKMKCNT


VSELECT         EQUALS          TRKMKCNT                # B(1)  X,Y OR Z LR BEAM ASSOC WITH VMEAS.


#          P32-P35, P72-P75 STORAGE.  -PERMANENT-         (6)

NORMEX          ERASE                                   # B(1) PRM SAVE FOR Q
QSAVED          ERASE                                   # B(1) PRM SAVE FOR Q
RTRN            ERASE                                   # B(1) PRM SAVE FOR Q
NN              ERASE           +1                      # B(2)
SUBEXIT         ERASE                                   # B(1) PRM SAVE Q


E7OVERLA        EQUALS                                  # START OF E7 OVERLAYS.
WHOCARES        EQUALS          E7OVERLA                # DUMMY FOR EBANK INSENSITIVE 2CADRS

#          LUNAR LANDING OVERLAYS                        (6D)

/AFC/           EQUALS          NORMEX                  # B(2)TMP    THROTTLE
FCODD           EQUALS          /AFC/           +2      # B(2)TMP    THROTTLE
FP              EQUALS          FCODD           +2      # B(2)TMP    THROTTLE

## Page 147
# *******  OVERLAY NUMBER 0 IN EBANK 7  *******
#

# RENDEZVOUS GUIDANCE STORAGE -P32....P35-             (89D)

TSTRT           EQUALS          DELDV                   # MIDCOURSE START TIME
TDEC2           EQUALS          DELVCSI                 # TEMP STORAGE FOR INTEGRATION TIME INPUT
KT              EQUALS          DELVTPI                 # TEMP STORAGE FOR MIDCOURSE DELTA TIME
VACT1           ERASE           +5D                     # VELOCITY VECTOR OF ACTIVE  AT CSI TIME
RPASS1          ERASE           +5D                     # POSITION VECTOR OF PASSIVE AT CSI TIME
VPASS1          ERASE           +5D                     # VELOCITY VECTOR OF PASSIVE AT CSI TIME
VACT2           ERASE           +5D                     # VELOCITY VECTOR OF ACTIVE  AT CDH TIME
RPASS2          ERASE           +5D                     # POSITION VECTOR OF PASSIVE AT CDH TIME
VPASS2          ERASE           +5D                     # VELOCITY VECTOR OF PASSIVE AT CDH TIME
RACT3           ERASE           +5D                     # POSITION VECTOR OF ACTIVE  AT TPI TIME
VACT3           ERASE           +5D                     # VELOCITY VECTOR OF ACTIVE  AT TPI TIME
RPASS3          ERASE           +5D                     # POSITION VECTOR OF PASSIVE AT TPI TIME
VPASS3          ERASE           +5D                     # VELOCITY VECTOR OF PASSIVE AT TPI TIME
VACT4           ERASE           +5D                     # VELOCITY VECTOR OF ACTIVE  AT INTERCEPT
UNVEC           EQUALS          VACT3                   # CDHMVR UNIT VECTOR TEMP STORAGE.
DELVCSI         ERASE           +1D                     # THRUST VALUE AT CSI
DELVTPI         ERASE           +1D                     # THRUST VALUE AT TPI OR MID
DIFFALT         ERASE           +1D                     # ALT DIFFERENCE AT CDH
POSTCSI         ERASE           +1                      # PERIGEE ALTITUDE AFTER CSI MANEUVER
POSTCDH         ERASE           +1                      # PERIGEE ALTITUDE AFTER CDH MANEUVER
POSTTPI         ERASE           +1                      # PERIGEE ALTITUDE AFTER TPI MANEUVER
LOOPCT          EQUALS          POSTTPI                 # CSI NEWTON ITERATION COUNTER
HAFPA1          EQUALS          POSTCDH                 # HALF PERIOD
GAMPREV         ERASE           +1                      # PREVIOUS GAMMA
DVPREV          EQUALS          DELVTPI                 # PREVIOUS DELVCSI
DELDV           ERASE           +1D
CSIALRM         ERASE           +1                      # FIRST SOLUTION ALARM
VERBNOUN        ERASE
TITER           EQUALS          CSIALRM                 # ITERATION COUNTER
RDOTV           ERASE           +1
VAPREC          EQUALS          VPASS1                  # I(6) S-S PREC VEC FOR NOM TPI TIME(ACT V
RAPREC          EQUALS          RPASS1                  # I(6) S-S PREC VEC FOR NOM TPI TIME(ACT V
VPPREC          EQUALS          VPASS2                  # I(6) S-S PREC VEC FOR NOM TPI TIME(PASS
RPPREC          EQUALS          RPASS2                  # I(6) S-S PREC VEC FOR NOM TPI TIME(PASS
DELEL           EQUALS          DELVTPI                 # I(2) S-S
SECMAX          EQUALS          DELVCSI                 # I(2) S-S MAX STOP SIZE FOR ROUTINE
DELTEEO         EQUALS          POSTTPI                 # I(2) S-S BACK VALUES OF DELTA TIME
CENTANG         ERASE           +1                      # I(2) S-S CENTRAL ANGLE COVERED (TPI-TPF)



#          SOME P47 STORAGE                              (6D)

## Page 148
DELVIMU         ERASE           +5                      # I(6)DSP N83 FOR P47 DELTA V IN BODY COOR


#          P34-35-40-41-42 INTERFACE                     (2D)

TPASS4          ERASE           +1                      # INTERCEPT TIME
#

#          P30-P40-41-42 COMMON STORAGE                  (1D)

QTEMP           ERASE                                   # I(1)TMP COMMON RETURN SAVE REGISTER.



#          P32,33,34 STORAGE.                            (6D)

TCSI            ERASE           +1                      # B(2)TMP CSI TIME IN CENTISECONDS
TTPI            ERASE           +1                      # B(2)TMP TPI TIME IN CENTISECONDS
TTPIO           ERASE           +1                      # B(2)TMP TTPI STORAGE FOR RECYCLE


#          P30,P40 INTERFACE.                            (20D)

RTIG            ERASE           +19D                    # I(6)TMP
VTIG            EQUALS          RTIG            +6      # I(6)TMP
DELVSIN         EQUALS          VTIG            +6      # I(6)TMP
DELVSAB         EQUALS          DELVSIN         +6      # I(2)TMP
VGDISP          =               DELVSAB


#          P40-P42 TEMPORARY                              (1D)

QTEMP1          ERASE                                   # I(1)TMP HOLDS RETURN.
#


#          R52 TEMPORARY				  (1D)

SAVQR52         EQUALS          QTEMP1


#          INITVEL STORAGE.  (IN OVERLAY 0 AND OVERLAY 1.        (2D)
#                 (CALLS LAMBERT, CONIC SUBROUTINES)

VTPRIME         EQUALS          VACT4                   # TOTAL VELOCITY AT DESIRED RADIUS
ITCTR           EQUALS          RDOTV                   # ITERATION COUNTER
COZY4           ERASE           +1                      # COS OF ANGLE WHEN ROTATION STARTS
INTIME          EQUALS          GAMPREV                 # TIME OF RINIT

## Page 149
#          PERIAPO STORAGE. (2D)			(2D)

XXXALT          ERASE           +1                      # RADIUS TO LAUNCH PAD OR LANDING SIGHT

#          S40.1 STORAGE.                                (12D)

UT              ERASE           +11D                    # I(6) THRUST DIRECTION
VGTIG           EQUALS          UT              +6      # I(6)OUT
VGPREV          =               VGTIG
# ASTEER STORAGE.                               (22D)

VG              ERASE           +21D                    # I(6)
RMAG            EQUALS          VG              +6      # I(2)
MUASTEER        EQUALS          RMAG            +2      # I(2)
MU/A            EQUALS          MUASTEER        +2      # I(2)
RTMAG           EQUALS          MU/A            +2      # I(2)
R1C             EQUALS          RTMAG           +2      # I(6)
SS              EQUALS          R1C             +6      # I(2)

#          ASTEER                                         (11D)

IC              =               DELVSIN                 # I(6) CHORD VECTOR:  RTARG VEC - POS VEC
TIGSAVE         =               P21TIME                 # I(2) USED TO DETERMINE WHEN YOU
TIGSAVEP        =               SCAXIS                  # I(2)  WANT TO DO ASTEER NEXT
MUSCALE         =               SCAXIS          +2      # I(1) HOLDS INDEX VALUE


#          P40 STORAGE.                                  (8D)

#               F, MDOT, AND TDECAY MUST BE CONTIGUOUS FOR VLOAD.
F               ERASE           +5                      # I(2)TMP THRUST MAG 10**4 NEWTONS (B-7)
MDOT            EQUALS          F               +2      # I(2)TMP MASS CHNG RATE, KG/CS AT 2**3.
TDECAY          EQUALS          MDOT            +2      # I(2)IN  DELTA-T TAILOFF, (2**28)CS.
VEX             ERASE           +1                      # I(2) EXHAUST VELOCITY FOR TGO COMPUTAT'N


#         MIDTOAV1(2) STORAGE.  (CALLED BY P40,P41,P42)         (1D)

IRETURN1        ERASE                                   # B(1)     RETURN FROM MIDTOAV1 AND 2

## Page 150
# ******* OVERLAY NUMBER 1 IN EBANK 7  *******


#         INITVEL (CALLED BY P34,35,38,39,10,11,S40.9,S40.1)    (6D)

RTARG1          EQUALS          VACT1                   # I(6)S TEMP STORAGE OF RTARG
#

#         P35-P40 INTERFACE.                              (6D)

VPASS4          EQUALS          VPASS1                  # I(6)TMP VELOCITY OF PASSIVE AT INTERCEPT


#          LAT-LONG TEMPORARIES.  CAN OVERLAY WITH S40.1         (3D)

ERADM           EQUALS          UT                      # I(2)
INCORPEX        EQUALS          ERADM           +2      # I(1)

#          LRS24.1 STORAGE.  (CAN SHARE WITH P30'S)      (40D)

RLMSRCH         EQUALS          INCORPEX        +1      # I(6) TMP LM POSITION VECTOR
VXRCM           EQUALS          RLMSRCH         +6      # I(6)    CM V X R VECTOR
LOSDESRD        EQUALS          VXRCM           +6      # I(6)    DESIRED LOS VECTOR
UXVECT          EQUALS          LOSDESRD        +6      # I(6)    X-AXIS SRCH PATTERN COORDS
UYVECT          EQUALS          UXVECT          +6      # I(6)    Y-AXIS SRCH PATTERN COORDS
DATAGOOD        EQUALS          UYVECT          +6      # B(1)DSP FOR R1 - ALL 1-S WHEN LOCKON
OMEGDISP        EQUALS          DATAGOOD        +1      # B(2)    ANGLE OMEGA DISPLAYED IN R2
OMEGAD          =               OMEGDISP                #         PINBALL DEFINITION.
NSRCHPNT        EQUALS          OMEGDISP        +2      # B(1)TMP SEARCH PATTERN POINT COUNTER.
SAVLEMV         EQUALS          NSRCHPNT        +1      # I(6) S-S SAVES LOSVEL

## Page 151
# ******* OVERLAY NUMBER 2 IN EBANK 7 *******
#


#          INCORP STORAGE IN E7.                         (47D)

TX789           EQUALS          E7OVERLA                # I(6)
GAMMA           EQUALS          TX789           +6      # I(3)
OMEGA           EQUALS          GAMMA           +3      # I(18)
BVECTOR         EQUALS          OMEGA           +18D    # I(18)
DELTAQ          EQUALS          BVECTOR         +18D    # I(2)
#          AOTMARK STORAGE                               (3D)

WHATMARK        EQUALS          DELTAQ          +2      # B(1)TMP  SIGHTING TECHNIQUE DETERMINATOR
XYMARK          EQUALS          WHATMARK        +1      # B(1)TMP  MARK IDENTIFICATION REGISTER
MKDEX           EQUALS          XYMARK          +1      # B(1)TMP INDEX FOR AOTMARK
#

#          P50S. AOTMARK                                  (14D)

XPLANE          EQUALS          BVECTOR                 # I(6)TMP MARK PLANE
YPLANE          EQUALS          XPLANE          +6      # I(6)TMP MARK PLANE
XMKCNTR         EQUALS          P21TIME                 # B(1)  X SIGHTING MK CNTR
YMKCNTR         EQUALS          P21TIME         +1      # B(1)  Y SIGHTING MK CNTR


#         PLANET STORAGE.                               (8D)

PLANVEC         EQUALS          MKDEX           +1      # (6) REFER VECTOR OF PLANET
TSIGHT          EQUALS          PLANVEC         +6      # (2) TIME OF MARK OR EST TIME OF MARK
#


#          AOTMARK STORAGE                               (15D)

THETEST         EQUALS          TSIGHT          +2      # I(2)TMP  STAR VECTOR COMPUTATION TMP
ESTER1          EQUALS          THETEST         +2      # I(2)TMP  STAR VECTOR COMPUTATION TMP
ESTER2          EQUALS          ESTER1          +2      # I(2)TMP  STAR VECTOR COMPUTATION TMP
DELTHET         EQUALS          ESTER2          +2      # I(2)TMP  STAR VECTOR COMPUTATION TMP
NOMKCNT         EQUALS          DELTHET         +2      # B(1)TMP  MARK SET REJECT CTR
BODY            EQUALS          NOMKCNT         +1      # I(6)TMP STAR VEC IN NAV BASE COOR
#          LRS22.3 STORAGE. (CAN SHARE WITH P30'S AND OVERLAY LRS24.1  (30D).

LGRET           EQUALS          RLMSRCH                 # I(1)TMP
RDRET           EQUALS          LGRET                   # B(1) TEMP RETURN.
IGRET           EQUALS          LGRET                   # B(1) TEMP RETURN.
MX              EQUALS          RDRET           +1      # I(6)
MY              EQUALS          MX              +6      # I(6)
MZ              EQUALS          MY              +6      # I(6)
SCALSHFT        EQUALS          MZ              +6      # B(1) SCALE SHIFT FOR EARTH/MOON

## Page 152
RXZ             EQUALS          SCALSHFT        +1      # I(2)
ULC             EQUALS          RXZ             +2      # I(6)
SINTHETA        EQUALS          ULC             +6      # I(2)

# ***** IN OVERLAY ONE *****

#     R22 / NOUN 49 DISPLAY

N49FLAG         EQUALS          RDOTMSAV                # B(1)S    FLAG INDICATING V0649 RESPONSE


#     LRS22.1 STORAGE.  (MUST NOT SHARE WITH P30'S)         (13D)

#     (OUTPUTS ARE TO LRS22.3)

RRTRUN          EQUALS          SINTHETA        +2      # B(2)OUT  RR TRUNION ANGLE
RRSHAFT         EQUALS          RRTRUN          +2      # B(2)OUT RR SHAFT ANGLE
LRS22.1X        EQUALS          RRSHAFT         +2      # B(1)TMP
RRBORSIT        EQUALS          LRS22.1X        +1      # I(6) TMP RADAR BORESIGHT VECTOR.
RDOTMSAV        EQUALS          RRBORSIT        +6      # B(2) S    RR RANGE-RATE(FPS)


#     LRS22.1 (SAME AS PREVIOUS SECTION) ALSO DOWNLINK FOR RR (R29)(10D) CANNOT SHARE WITH L.A.D.

#     NOTE: MKTIME IS USED BY LANDING AS WELL AS REND RADAR.

RDOTM           EQUALS          RDOTMSAV        +2      # B(2)OUT  RANGE-RATE READING
TANGNB          EQUALS          RDOTM           +2      # B(2)TMP  RR GIMBAL ANGLES
#     RETAIN THE ORDER OF MKTIME TO RM FOR DOWNLINK PURPOSES
MKTIME          EQUALS          TANGNB          +2      # B(2) TIME OF RADAR READING (RR AND LR)
RM              EQUALS          MKTIME          +2      # I(2)OUT RANGE READING
RANGRDOT        EQUALS          RM              +2      # B(2) DOWNLINKED RAW RANGE AND RRATE

#     LANDING OVERLAY                               (1D)

THRDISP         EQUALS          RDOTM                   # B(1) PERCENT OF FTP I 10,500 LBS.


GTCTIME         EQUALS          TANGNB                  # B(2)  STATE VECTOR TIME CORRESPONDING
                                                        #   TO FP -- GUIDANCE THRUST COMMAND

#     R61LEM - PREFERRED TRACKING ATTITUDE ROUTINE  **IN OVERLAY ONE*
#              (CALLED BY P20,R22LEM,LSR22.3)            (1D)

R65CNTR         EQUALS          RRBORSIT        +5      # B(1)SS  COUNT NUMBER OF TIMES PREFERRED
                                                        #         TRACKING ROUTINE IS TO CYCLE

#     P21 STORAGE                                   (2D)

## Page 153
P21TIME         EQUALS          RANGRDOT        +2      # I(2)TMP


#     INPUTS TO VECPOINT. CALLED BY R60-65 (ATTITUDE MANEUVERS)         (12D)
SCAXIS          EQUALS          P21TIME         +2      # I(6)
POINTVSM        EQUALS          SCAXIS          +6      # I(6)

## Page 154

# *******  OVERLAY NUMBER 3 IN EBANK 7  *******



#          SERVICER STORAGE                              (6D)

ABVEL           EQUALS          E7OVERLA                # B(2) DISPLAY
HDOTDISP        EQUALS          ABVEL           +2      # B(2) DISPLAY
TTFDISP         EQUALS          HDOTDISP        +2      # B(2) DISPLAY


#          ASCENT GUIDANCE FOR LUNAR LANDING             (2D)

RDOT            EQUALS          HDOTDISP                # I(2)


#          BURN PROG STORAGE.                            (2D)

SAVET-30        EQUALS          TTFDISP         +2      # B(2)TMP TIG-30 RESTART


#          SERVICER STORAGE.                             (69D)

VGBODY          EQUALS          SAVET-30        +2      # B(6)OUT SET.BY S41.1 VG LEM, SC.COORDS
DELVCTL         =               VGBODY
DVTOTAL         EQUALS          VGBODY          +6      # B(2) DISPLAY NOUN
GOBLTIME        EQUALS          DVTOTAL         +2      # B(2) NOMINAL TIG FOR CALC. OF GOBLATE.
ABDVCONV        EQUALS          GOBLTIME        +2      # I(2)
DVCNTR          EQUALS          ABDVCONV        +2      # B(1)
TGO             EQUALS          DVCNTR          +1      # B(2)
R               EQUALS          TGO             +2      # I(6)
UNITGOBL        EQUALS          R                       # I(6)
V               EQUALS          R               +6
DELVREF         EQUALS          V                       # I(6)
HCALC           EQUALS          DELVREF         +6      # B(2)    LR
UNIT/R/         EQUALS          HCALC           +2      # I(6)
#          (THE FOLLOWING SERVICER ERASABLES CAN BE SHARED WITH SECOND DPS GUIDANCE STORAGE)

RN1             EQUALS          UNIT/R/         +6      # B(6)
VN1             EQUALS          RN1             +6      # I(6)                      ( IN ORDER )
PIPTIME1        EQUALS          VN1             +6      # B(2)                      (    FOR   )
GDT1/2          EQUALS          PIPTIME1        +2      # I(6)                      (   COPY   )
MASS1           EQUALS          GDT1/2          +6      # I(2)                      (   CYCLE  )
DVCNTR1         EQUALS          MASS1                   # B(1)TMP  RESTART REG FOR DVCNTR
R1S             EQUALS          MASS1           +2      # I(6)
V1S             EQUALS          R1S             +6      # I(6)


#          P71 RESTART PROTECTION                        (2D)

## Page 155
TGO1            EQUALS          VGBODY                  # B(2)TMP


#          ALIGNMENT/S40.2.3 COMMON STORAGE.             (18D)

XSMD            EQUALS          V1S             +6      # I(6)
YSMD            EQUALS          XSMD            +6      # I(6)
ZSMD            EQUALS          YSMD            +6      # I(6)

XSCREF          =               XSMD
YSCREF          =               YSMD
ZSCREF          =               ZSMD

END-ALIG        EQUALS          ZSMD            +6      # NEXT AVAIL ERASABLE AFTER ALIGN/S40.2,3


#          **** P22 ****                                (34D)

RSUBL           EQUALS          END-ALIG                # I(6)S-S  LM POSITION VECTOR
UCSM            EQUALS          RSUBL           +6      # I(6)S-S  VECTOR U
NEWVEL          EQUALS          UCSM            +6      # I(6)S-S  TERMINAL VELOCITY VECTOR
NEWPOS          EQUALS          NEWVEL          +6      # I(6)S-S  TERMINAL POSITION VECTOR
LNCHTM          EQUALS          NEWPOS          +6      # I(2)S-S  EST. LAUNCH TIME FOR LEM
TRANSTM         EQUALS          LNCHTM          +2      # I(2)S-S TRANSFER TIME
NCSMVEL         EQUALS          TRANSTM         +2      # I(6)S-S NEW CSM VELOCITY
#

#          ***** P21 *****                              (18D)

P21ORIG         =               DISPDEX
P21BASER        EQUALS          RLMSRCH                 # I(6)TMP
P21BASEV        EQUALS          P21BASER        +6      # I(6)TMP
P21VEL          EQUALS          P21BASEV        +6      # I(2)TMP  *** NOUN 91 ***
P21GAM          EQUALS          P21VEL          +2      # I(2)TMP  *** NOUN 91 ***
P21ALT          EQUALS          P21GAM          +2      # I(2)TMP  *** NOUN 91 ***

## Page 156
# *******  OVERLAY NUMBER 4 IN EBANK 7  *******
#

# VARIABLES FOR SECOND DPS GUIDANCE (THE LUNAR LANDING)         (80D)

# THESE ERASABLES MAY BE SHARED WITH CARE

OURTEMPS        =               RN1                     # OVERLAY LAST PART OF SERVICER
LANDTEMP        =               OURTEMPS                # B(6)     GUIDANCE
TTF/8TMP        =               LANDTEMP        +6      # B(2)    GUIDANCE
ELINCR          =               TTF/8TMP        +2      # B(2)    GUIDANCE
AZINCR          =               ELINCR          +2      # B(2)    GUIDANCE
KEEP-2          =               AZINCR          +2      # B(2)    TO PREVENT PIPTIME1 OVERLAY
TABLTTF         =               KEEP-2          +2      # B(2)    GUIDANCE
TPIPOLD         =               TABLTTF         +9D     # B(2)    GUIDANCE
E2DPS           EQUALS          OURPERMS



# THESE ERASABLES MUST NOT OVERLAY GOBLTIME OR SERVICER

PIFPSET         =               XSMD                    # B(1)    THROTTLE
RTNHOLD         =               PIFPSET         +1      # B(1)    THROTTLE
FWEIGHT         =               RTNHOLD         +1      # B(2)    THROTTLE
PIF             =               FWEIGHT         +2      # B(2)   THROTTLE
PSEUDO55        =               PIF             +2      # B(1)   THROTTLE DOWNLINK
FC              =               PSEUDO55        +1      # B(2)    THROTTLE
TTHROT          =               FC              +2      # B(1)    THROTTLE
FCOLD           =               TTHROT          +1      # B(1)    THROTTLE



# THESE ERASABLES SHOULD NOT BE SHARED DURING P63, P64, P65, P66, P67

OURPERMS        =               FCOLD           +1      # MUSTN'T OVERLAY OURTEMPS OR SERVICER
WCHPHOLD        =               OURPERMS                # B(1)    GUIDANCE
511CTR          =               WCHPHOLD        +1      # B(1) R12 - CONTROLS 511 ALARM
FLPASS0         =               511CTR          +1      # B(1) GUIDANCE
CNTTHROT        EQUALS          FLPASS0                 # B(1) CNT THROTS BETWEEN OMISSIONS OF P66
TPIP            =               FLPASS0         +1      # B(2)
VGU             =               TPIP            +2      # B(6)    GUIDANCE
LAND            =               VGU             +6      # B(6)    GUIDANCE    CONTIGUOUS
TTF/8           =               LAND            +6      # B(2)    GUIDANCE    CONTIGUOUS
AZINCR1         =               TTF/8           +2      # B(1)    REDESIGNATOR
ELINCR1         =               AZINCR1         +1      # B(1)    REDESIGNATOR
ZERLINA         =               ELINCR1         +1      # B(1)    REDESIGNATOR
ELVIRA          =               ZERLINA         +1      # B(1)    REDESIGNATOR
LRPOS           =               ELVIRA          +1      # B(1)    LAST LR ANTENNA POSITION

#                               ** NOTE: GAP OF 1 SP LOCATION HERE IN THIS P63 THRU P66 OVERLAY **

## Page 157
VMEAS           =               LRPOS           +2      # B(2) LR VELOCITY READ BY BEAM X, Y OR Z.
HMEAS           =               VMEAS           +2      # B(2)    LR
VN2             =               HMEAS           +2      # B(6)    LR
GNUR            =               VN2                     # B(6)     LR
GNUV            =               VN2                     # B(6)     LR
DELTAH          =               VN2             +6      # B(2)    DISPLAY
FUNNYDSP        =               DELTAH          +2      # B(2)    DISPLAY
EOURPERM        EQUALS          FUNNYDSP        +2      # NEXT AVAILABLE ERASABLE AFTER OURPERMS
OVFRET          EQUALS          LOSCOUNT                # B(1) RETURN FROM DESCENT OVERFLOW SUBRO



# (ERASABLES WHICH OVERLAY THE ABOVE BLOCK)

VDGVERT         =               AZINCR1                 # B(2)  DESIRED VERTICAL VELOCITY - P66
NIGNLOOP        =               ZERLINA                 # B(1)   IGNALG
NGUIDSUB        =               ELVIRA                  # B(1)   IGNALG
TREDES          =               FUNNYDSP                # B(1)    DISPLAY
LOOKANGL        =               FUNNYDSP        +1      # B(1)    DISPLAY
#

# THE END OF THE LUNAR LANDING ERASABLES
#


#          R12 (FOR LUNAR LANDING)                       (6D)

LRLCTR          EQUALS          EOURPERM                # B(1) LR DATA TEST
LRRCTR          EQUALS          LRLCTR          +1      # B(1)
LRMCTR          EQUALS          LRRCTR          +1      # B(1)
LRSCTR          EQUALS          LRMCTR          +1      # B(1)
STILBADH        EQUALS          LRSCTR          +1      # B(1)
STILBADV        EQUALS          STILBADH +1             # B(1)
#


#          LANDING ANALOGS DISPLAY STORAGE.              (32D)

G-VBIASX        =               STILBADV        +1      # B(1)    ACC DUE TO GRAVITY AND PIPA BIAS
G-VBIASY        =               G-VBIASX        +1      # B(1)    ACC DUE TO GRAVITY AND PIPA BIAS
G-VBIASZ        =               G-VBIASY        +1      # B(1)    ACC DUE TO GRAVITY AND PIPA BIAS
VSURFACE        =               G-VBIASZ        +1      # B(6)    LUNAR SURFACE VELOCITY
HCALCLAD        =               VSURFACE        +6      # B(2)    ALTITUDE IN UNITS OF 2(15) M
HDOTLAD         =               HCALCLAD        +2      # B(2)    ALTRATE IN UNITS OF 2(5) M/CS
DALTRATE        =               HDOTLAD         +2      # B(1)    DALTRATE UNITS OF 2(-9) M/CS/CS
RUNITX          =               DALTRATE        +1      # B(1)    X-COMPONENT OF UNIT/R/ FULL-SIZE
RUNITY          =               RUNITX          +1      # B(1)    Y-COMPONENT OF UNIT/R/ FULL-SIZE
RUNITZ          =               RUNITY          +1      # B(1)    Z-COMPONENT OF UNIT/R/ FULL-SIZE
DT              =               RUNITZ          +1      # B(1)    TIME SINCE LAST PIPTIME
VVECTX          =               DT              +1      # B(2)    X-COMPONENT OF SM REL. VELOCITY

## Page 158
VVECTY          =               VVECTX          +2      # B(2)    Y-COMPONENT OF SM REL. VELOCITY
VVECTZ          =               VVECTY          +2      # B(2)    Z-COMPONENT OF SM REL. VELOCITY
ALTRATE         =               VVECTZ          +2      # B(2)    ALTRATE IN UNITS OF 2(5) M/CS
ALTITUDE        =               ALTRATE         +2      # B(2)    ALTITUDE IN UNITS OF 2(15) M
LATVMETR        =               ALTITUDE        +2      # B(1)    LATERAL VELOCITY METER INDICATOR
FORVMETR        =               LATVMETR        +1      # B(1)    FORWARD VELOCITY METER INDICATOR
FORVEL          =               FORVMETR        +1      # B(2)    FORWARD VELOCITY FOR DSKY (N60)
PIPCTR1         =               VVECTY                  # B(1)    TEMPORARY FOR PIPCTR


ALTRTEMP        =               ITEMP3                  # B(2)    ALTITUDE-RATE TEMPORARY
ALTTEMP         =               ITEMP3                  # B(2)    ALTITUDE TEMPORARY
VHY             =               ITEMP3                  # B(2)    VELOCITY ALONG UHYP (I.E. SM-Y)
VHZ             =               ITEMP5                  # B(2)    VELOCITY ALONG UHZP
FORVTEMP        =               RUPTREG1                # B(2)    FORWARD VELOCITY TEMPORARY
LATVEL          =               RUPTREG3                # B(2)    LATERAL VELOCITY TEMPORARY



#          DOWNLINK QTY -- GOOD THROUGHOUT LANDING -- LOADED IN SERVICER (2D)

TRUDELH         EQUALS          FORVEL          +2      # I(2)DNLK  TRUE DELTA H FOR DOWNLINK,
                                                        #     LOADED BEFORE ENTERING TERRAIN MODEL


# P66 ERASABLES (HORIZONTAL VELOCITY NULLING GUIDANCE)
VHZC            EQUALS          DELVLVC                 # B(6) VELOCITY HORIZONTAL COMMAND
#


#          P66 ERASABLES (R.O.D.)                         (1D)

RODCOUNT        EQUALS          R65CNTR         +1      # B(1)    ROD CLICK COUNTER
#

#          P66 ERASABLES (R.O.D.)                        (14D)

# **** NOTE: OLDPIPAX,Y,Z AND DELVROD MUST BE KEPT ADJACENT AND IN THAT ORDER FOR P66 INITIALIZATIONS ****

RODSCAL1        EQUALS          RM                     # B(1)
LASTTPIP        EQUALS          RODSCAL1        +1     # I(2)
THISTPIP        EQUALS          LASTTPIP        +2     # B(2)
OLDPIPAX        EQUALS          THISTPIP        +2     # B(1)
OLDPIPAY        EQUALS          OLDPIPAX        +1     # B(1)
OLDPIPAZ        EQUALS          OLDPIPAY        +1     # B(1)
DELVROD         EQUALS          OLDPIPAZ        +1     # B(6)
#


#          TERRAIN MODEL TEMPORARY -- LOADED IN SERVICER        (2D)

## Page 159
TEMDELH         EQUALS          DELVROD                 # I(2)TMP  STORES TRUE DELTAH IN TER. MOD.


# NOUN 63 COMPONENT                             (2D)
HCALC1          EQUALS          DELVROD         +6      # I(2)
#

# LANDING RADAR DOWNLINK				(2D)
HMEASDL         EQUALS          HCALC1          +2      # B(2)
#

## Page 160
# *******  OVERLAY NUMBER 5 IN EBANK 7  *******
#



#          ASCENT GUIDANCE ERASABLES.                    (21D)

RCO             EQUALS          END-ALIG                # I(2)TMP TARGET RADIUS AND OUT-OF-PLANE
YCO             EQUALS          RCO             +2      # I(2)TMP DISTANCE, SCALED AT 2(24).
1/DV1           EQUALS          YCO             +2      # B(2)TMP ATMAG
1/DV2           EQUALS          1/DV1           +2      # B(2)TMP ATMAG
1/DV3           EQUALS          1/DV2           +2      # B(2)TMP ATMAG
XRANGE          EQUALS          1/DV3           +2      # B(2)TMP
ENGOFFDT        EQUALS          XRANGE          +2      # B(1)TMP
VGVECT          EQUALS          ENGOFFDT        +1      # I(6)OUT VELOCITY-TO-BE-GAINED
TXO             EQUALS          VGVECT          +6      # I(2)TMP TIME AT WHICH X-AXIS OVERRIDE
                                                        # IS ALLOWED.

1/DV0           EQUALS          MASS1                   # B(2)TMP  ATMAG TEMPORARY


# END OF THE ASCENT GUIDANCE ERASABLES.

END-E7          EQUALS          3777                    # ** LAST LOCATION USED IN E7 **
