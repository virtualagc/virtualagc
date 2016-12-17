### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     DIGITAL_AUTOPILOT_ERASABLE.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        535-541
## Mod history:  2016-09-20 JL   Created.
##               2016-09-30 MAS  Began.
##               2016-10-01 MAS  Completed transcription.
##               2016-10-04 HG   Capitalize SETLOC`
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 but no errors found.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the private collection of 
## Don Eyles.  The digitization was performed by archive.org.

## Notations on the hardcopy document read, in part:

##       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
##       NOV 10, 1966

##       [Note that this is the date the hardcopy was made, not the
##       date of the program revision or the assembly.]

## The scan images (with suitable reduction in storage size and consequent 
## reduction in image quality) are available online at 
##       https://www.ibiblio.org/apollo.  
## The original high-quality digital images are available at archive.org:
##       https://archive.org/details/aurora00dapg

## Page 535
                SETLOC          3000

# AXIS TRANSFORMATION MATRIX - PILOT TO GIMBAL AXES:

MR12            ERASE                                           # SCALED AT 2   THESE FOUR P-G MATRIX ELE-
MR22            ERASE                                           # SCALED AT 1   MENTS ARE IN THIS ORDER TO
MR13            ERASE                                           # SCALED AT 2   COMPUTE RATE HOLD DELCDUS
MR23            ERASE                                           # SCALED AT 1   WITH AN INDEXED LOOP
# AXIS TRANSFORMATION MATRIX - GIMBAL TO PILOT AXES:

M11             ERASE                                           # SCALED AT 1
M21             ERASE                                           # SCALED AT 1
M31             ERASE                                           
M22             EQUALS          MR22                            # SCALED AT 1
M32             EQUALS          MR23                            # SCALED AT 1
# ANGLE MEASUREMENTS.

EDOT            ERASE           +1                              # ERROR IN ANGULAR RATE:
EDOT(R)         EQUALS          EDOT            +1              # SCALED DOWN TO PI/16 RADIANS/SECOND

E               ERASE           +1                              # ANGLE ERROR SCALED AT PI RADIANS
EDOT(2)         EQUALS          E               +1              # ERROR RATE SQUARED SCALED AT PI(2)/16
EQ              EQUALS          E                               # THIS PAIR OF NAMES IS USED TO REFER TO
EDOT(2)Q        EQUALS          EDOT(2)                         # THE ABOVE ERASABLES AS Q-AXIS DATA
ER              ERASE           +1                              # THIS PAIR OF NAMES REFERS TO LOCATIONS
EDOT(2)R        EQUALS          ER              +1              # FOR THE R-AXIS DATA: INTERCHANGES WITH Q

DB              ERASE                                           # ANGLE DEADBAND SCALED AT PI RADIANS

OMEGAP          ERASE           +4                              # BODY-AXIS ROT. RATES SCALED AT PI/4 AND
OMEGAQ          EQUALS          OMEGAP          +1              # BODY-AXIS ACCELERATIONS SCALED AT PI/8
ALPHAQ          EQUALS          OMEGAP          +2              # (IN DESCENT) OR PI/2 (IN ASCENT)
OMEGAR          EQUALS          OMEGAP          +3              # THESE W,A PAIRS ARE NEEDED, ALPHAP HAS
ALPHAR          EQUALS          OMEGAP          +4              # NO USE IN THE DIGITAL AUTOPILOT

EDOTP           ERASE           +2                              # ERRORS IN ANGULAR RATE:
EDOTQ           EQUALS          EDOTP           +1              # EDOT = 3MEGA - OMEGA(DESIRED)
EDOTR           EQUALS          EDOTP           +2              # SCALED AT PI/4 RADIANS/SECOND

QRATEDIF        EQUALS          EDOTQ                           # ALTERNATIVE NAMES:
RRATEDIF        EQUALS          EDOTR                           # DELETE WHEN NO. OF REFERENCES = 0

OMEGAPD         ERASE           +2                              # DESIRED VEHICLE RATES DETERMINED BY THE
OMEGAQD         EQUALS          OMEGAPD         +1              # "OUTER LOOP" USED TO CALCULATE EDOT
OMEGARD         EQUALS          OMEGAPD         +2              # SCALED AT PI/4 RADIANS/SECOND

OLDXFORP        ERASE           +3                              # STORED CDU READINGS FOR P AND Q,R RATE
OLDYFORP        EQUALS          OLDXFORP        +1              # DERIVATIONS: SCALED AT PI RADIANS (2'S)
OLDYFORQ        EQUALS          OLDXFORP        +2              # (THERE MUST BE TWO REGISTERS FOR CDUY
OLDZFORQ        EQUALS          OLDXFORP        +3              # SINCE P AND Q,R ARE NOT IN PHASE)

## Page 536
# RHC INPUTS SCALED AT PI/4 RAD/SEC.

PCOM            ERASE
RCOM            ERASE
YCOM            ERASE

# RHC COUNTER REGISTERS.

P-RHCCTR        EQUALS          43
Q-RHCCTR        EQUALS          42
R-RHCCTR        EQUALS          44

# OTHER VARIABLES.

TPSIG           ERASE
PRATECOM        ERASE
EDOTGEN         ERASE
RATEDIF         ERASE
1/2JTSP         ERASE
1/2JTSQ         ERASE
1/2JTSR         ERASE
1/2JETSU        ERASE
1/2JETSV        ERASE
FPQR            ERASE
MINRA           ERASE
MINRASQ         ERASE
HDAP            ERASE
U               ERASE
DENOM           ERASE
RATIO           ERASE
TJSR            ERASE
IXX             ERASE
IYY             ERASE
IZZ             ERASE
4JETTORK        ERASE
JETTORK4        ERASE
COSMG           ERASE
DELTAP          EQUALS          ITEMP2
FPQRMIN         ERASE
NJET            ERASE
1/NJETAC        ERASE
PRATEDIF        ERASE
LASTPER         ERASE                                   # THESE 6 REG USED FOR ATT ERR DISPLAY
LASTQER         ERASE
LASTRER         ERASE
PERROR          ERASE
QERROR          ERASE
RERROR          ERASE

# JET STATE CHANGE VARIABLES- TIME (TOFJTCHG),JET BITS WRITTEN NOW
## Page 537
# (JTSONNOW), AND JET BITS WRITTEN AT T6 RUPT (JTSATCHG).

JTSONNOW        ERASE
JTSATCHG        ERASE
ADDT6JTS        ERASE
ADDTLT6         ERASE
TOFJTCHG        ERASE

-RATEDB         ERASE
-2JETLIM        ERASE

# RCS FAILURE MONITOR ERASABLE - PROGRAM ON T4RUPT 4 TIMES/SECOND

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
TJETADR         ERASE
URGENCYQ        ERASE
URGENCYR        ERASE
A+B             ERASE
A-B             ERASE
TERMA           ERASE
TERMB           ERASE
POLRELOC        ERASE
LOOPCTR         ERASE
POLTEST         ERASE

## Page 538
# TRIM GIMBAL CONTROL LAW ERASABLES:

# THE FOLLOWING ASSIGNMENTS OF RUPTREGS AND ITEMPS HAS BEEN MADE IN AN EFFORT TO OPTIMIZE USE OF ERASABLES:

K2THETA         EQUALS          RUPTREG1                        # D.P. K(2)THETA AND "NEGUSUM"
ETHETA          EQUALS          RUPTREG2                        # S.P. ERROR ANGLE SCALED AT PI/64 RADIANS
A2CNTRAL        EQUALS          RUPTREG3                        # D.P. ALPHA(2) SCALED AT PI(2)/64 R/S(2)
SF1             EQUALS          RUPTREG3                        # S.P. VARIABLE SCALE FACTORS WHICH ARE
SF2             EQUALS          RUPTREG4                        # S.P. - REALLY SINGLE BITS (OR ZERO)
OMEGA.K         EQUALS          ITEMP1                          # D.P. OMEGA*K SUPERCEDES K AND K(2)
KCENTRAL        EQUALS          ITEMP1                          # S.P. K FROM KQ OR KR FIRST AT PI/2(8)
K2CNTRAL        EQUALS          ITEMP2                          # S.P. K(2) FROM Q OR R 1ST AT PI(2)/2(16)
WCENTRAL        EQUALS          ITEMP3                          # S.P. OMEGA SCALED AT PI/4 RADIANS/SECOND
ACENTRAL        EQUALS          ITEMP4                          # S.P. ALPHA SCALED AT PI/8 RAD/SEC(2)
DEL             EQUALS          ITEMP5                          # S.P. SGN(FUNCTION)
QRCNTR          EQUALS          ITEMP6                          # S.P. COUNTER: Q,Y=0, R,Z=2

# THE ABOVE QUANTITIES ARE ONLY NEEDED ON A VERY TEMPORARY BASIS AND HAVE BEEN PROVEN TO BE NON-CONFLICTING.

L,PVT-CG        ERASE                                           # TRIM GIMBAL PIVOT TO CG DIST AT 8 FEET

MULTFLAG        ERASE                                           # INDICATOR FOR SPDPMULT ROUTINE

FUNCTION        ERASE           +1                              # D.P. WORD FOR DRIVE FUNCTIONS

NEGUQ           ERASE           +2                              # NEGATIVE OF Q-AXIS GIMBAL DRIVE
THRSTCMD        EQUALS          NEGUQ           +1              # THRUST COMMAND AT 16384 LBS (SEPARATOR)
NEGUR           EQUALS          NEGUQ           +2              # NEGATIVE OF R-AXIS GIMBAL DRIVE

KQ              ERASE           +3                              # .3ACCDOTQ SCALED AT PI/2(8)
KQ2             EQUALS          KQ              +1              # KQ2 = KQ*KQ
KR              EQUALS          KQ              +2              # .3ACCDOTR SCALED AT PI/2(8)
KR2             EQUALS          KQ              +3              # KR2 = KR*KR

ACCDOTQ         ERASE           +3                              # Q-JERK SCALED AT PI/2(7) UNSIGNED
QACCDOT         EQUALS          ACCDOTQ         +1              # Q-JERK SCALED AT PI/2(7) SIGNED
ACCDOTR         EQUALS          ACCDOTQ         +2              # R-JERK SCALED AT PI/2(7) UNSIGNED
RACCDOT         EQUALS          ACCDOTQ         +3              # R-JERK SCALED AT PI/2(7) SIGNED

QDIFF           EQUALS          QERROR                          # ATTITUDE ERRORS:
RDIFF           EQUALS          RERROR                          # SCALED AT PI RADIANS

TIMEOFFQ        ERASE                                           # TIMES TO GO UNTIL TRIM GIMBAL TURN-OFF.
TIMEOFFR        ERASE                                           # ZERO MEANS NO ACTION, SCALED AS WAITLIST

## Page 539
# KALMAN FILTER ERASABLES.

STORCDUY        ERASE                                           # THIS S.P. PAIR IS USED TO SAVE CDUY,Z
STORCDUZ        ERASE                                           # FOR THE GTS RUPT

CDU             EQUALS          RUPTREG3                        # RUPTREG3,4 USED AS D.P. WORD FOR CDU
                                                                # VALUE WITHIN FILTER 1S COMP AT 2PI RAD

CDUDOT          EQUALS          ITEMP1                          # ITEMP1,2 USED AS D.P. WORD FOR CDUDOT
                                                                # VALUE WITHIN FILTER SCALED AT PI/4

CDU2DOT         EQUALS          ITEMP3                          # ITEMP3,4 USED AS D.P. WORD FOR CDU2DOT
                                                                # VALUE WITHIN FILTER SCALED AT PI/8

DT              ERASE                                           # TIME ELAPSED SCALED AT 1/8: NOMINAL=50MS
DAPTIME         ERASE                                           # USED TO RECORD LAST TIME FROM CHANNEL 4

STEERADR        ERASE                                           # DTCALC SWITCH IN FILTER INITIALIZATION

DPDIFF          ERASE           +1                              # D.P. WEIGHTING VECTOR FACTOR AT P1
WPOINTER        ERASE                                           # POINTER TO WEIGHTING VECTOR TABLE
W0              ERASE           +2                              # THETA WEIGHT
W1              EQUALS          W0              +1              # OMEGA WEIGHT
W2              EQUALS          W1              +1              # ALPHA WEIGHT

CDUYFIL         ERASE           +1                              # Y-AXIS D.P. FILTERED THETA AT 2PI
CDUZFIL         ERASE           +1                              # Z-AXIS D.P. FILTERED THETA AT 2PI
DCDUYFIL        ERASE           +1                              # Y-AXIS D.P. FILTERED OMEGA AT PI/4
DCDUZFIL        ERASE           +1                              # Z-AXIS D.P. FILTERED OMEGA AT PI/4
D2CDUYFL        ERASE           +1                              # Y-AXIS D.P. FILTERED ALPHA AT PI/8
D2CDUZFL        ERASE           +1                              # Z-AXIS D.P. FILTERED ALPHA AT PI/8
Y3DOT           ERASE                                           # Y-AXIS S.P. JERK AT PI/2(7)
CDU3DOT         ERASE                                           #                   LOOP REGISTER (SPACER)
Z3DOT           ERASE                                           # Z-AXIS S.P. JERK AT PI/2(7)

PFILTADR        ERASE           +1                              # 2CADR FOR FILTER RUPT 30 MS AFTER P-AXIS
PFRPTLST        ERASE           +7                              # POST FILTER RUPT LIST
PJUMPADR        ERASE
QJUMPADR        ERASE
# TORQUE VECTOR RECONSTRUCTION VARIABLES:

## There is a line here saying "*      DELETE". Presumably this indicates a change from the last revision.
JETRATE         ERASE           +2                              # WEIGHTED RATES DUE TO JETS APPLIED IN
JETRATEQ        EQUALS          JETRATE         +1              # THE LAST CONTROL SAMPLE PERIOD OF 100 MS
JETRATER        EQUALS          JETRATE         +2              # SCALED AT PI/4 RADIANS/SECOND

NO.QJETS        ERASE           +1                              # NUMBER OF Q AND R JETS THAT ARE GIVEN
NO.RJETS        EQUALS          NO.QJETS        +1              # BY THE JET SELECT LOGIC

100MSPTQ        ERASE

## Page 540
QR.1STOQ        ERASE
NO.PJETS        ERASE
TP              ERASE           +1                              # TIME CALCULATED BY TJETLAW FOR P, QR
TQR             EQUALS          TP              +1              # SCALED AS TIME6, THEN TQR RESCALED TO 1

1JACC           ERASE           +4                              # ACCELERATIONS DUE TO 1 JET TORQUING
1JACCQ          EQUALS          1JACC           +1              # SCALED AT PI/4 RADIANS/SECOND
1JACCR          EQUALS          1JACC           +2
1JACCU          EQUALS          1JACC           +3              # FOR U,V-AXES THE SCALE FACTOR IS  DIFF:
1JACCV          EQUALS          1JACC           +4              # SCALED AT PI/2 RADIANS/SECOND (FOR ASC)

# ASCENT VARIABLES:

AOSQ            ERASE           +3                              # ASCENT OFFSET ACCELERATIONS
AOSR            EQUALS          AOSQ            +1              # ESTIMATED EVERY 2 SECONDS BY AOSTASK
AOSU            EQUALS          AOSQ            +2              # U,V-ACCS ARE FORMED BY VECTOR ADDITION
AOSV            EQUALS          AOSQ            +3              # SCALED AT PI/2 RADIANS/SECOND
## The above line has "(2)" written after "radians/second" in pen.

ABVLAOSQ        EQUALS          ITEMP3                          # ASCENT OFFSET ACCELERATIONS (ABVAL)
ABVLAOSR        EQUALS          ABVLAOSQ        +1              # SCALED AT PI/2 RADIANS/SECOND(2)
ABVLAOSU        EQUALS          ABVLAOSQ        +2
ABVLAOSV        EQUALS          ABVLAOSQ        +3

SUMRATEQ        ERASE           +1                              # SUM OF UN-WEIGHTED JETRATE TERMS
SUMRATER        EQUALS          SUMRATEQ        +1              # SCALED AT PI/4 RADIANS/SECOND

AOSQTERM        ERASE           +1                              # (.1-.05K)AOS
AOSRTERM        EQUALS          AOSQTERM        +1              # SCALED AT PI/4 RADIANS/SECOND

OLDWFORQ        ERASE           +1                              # OMEGA VALUE 2 SECONDS AGO
OLDWFORR        EQUALS          OLDWFORQ        +1              # SCALED AT PI/4 RADIANS/SECOND

DBMINIMP        ERASE           +1                              # MINIMUM IMPULSE DEADBANDS (EQUAL IN DESC
MINIMPDB        EQUALS          DBMINIMP        +1              # AT .3 DEG, 0,-DB RESPECTIVELY FOR ASC)
                                                                # SCALED AT PI RADIANS

.5ACCMNE        ERASE           +4                              # (1/2)(1/ACCMIN) WHICH IS THE INVERSE OF
.5ACCMNQ        EQUALS          .5ACCMNE        +1              # THE MINIMUM ACCELERATION (A CONSTANT FOR
.5ACCMNR        EQUALS          .5ACCMNE        +2              # DESCENT AND A VARIABLE FOR ASCENT DAP)
.5ACCMNU        EQUALS          .5ACCMNE        +3              # SCALED AT 2(.8)/PI
.5ACCMNV        EQUALS          .5ACCMNE        +4              # IN UNITS OF SECONDS(2)/RADIAN

WFORP           ERASE           +1                              # W = K/(NOMINAL DT)
WFORQR          EQUALS          WFORP           +1              # SCALED AT 16

(1-K)QR         ERASE           +1                              # 1-K SCALED AT 1
(1-K)/8         EQUALS          (1-K)QR         +1              # 1-K SCALED AT 8

1/NJTSQ         ERASE           +3                              # 1/NJETACC FOR EACH AXIS
1/NJTSR         EQUALS          1/NJTSQ         +1              # FOR DESCENT THIS IS ALWAYS 1/2JTS
## Page 541
1/NJTSU         EQUALS          1/NJTSQ         +2              # FOR ASCENT WITH HIGH OFFSET: 1/4JTS
1/NJTSV         EQUALS          1/NJTSQ         +3              # SCALED AT 2(8)/PI SEC(2)/RAD

QMANDACC        ERASE           +3                              # ASCENT FLAGS
RMANDACC        EQUALS          QMANDACC        +1              # 0: INDICATES NO OVER-RIDE OF 2 JETS
UMANDACC        EQUALS          QMANDACC        +2              # 1: INDICATES USE 4 INSTEAD OF 2 JETS
VMANDACC        EQUALS          QMANDACC        +3              # (ALWAYS ZERO FOR DESCENT)

KCOEFCTR        ERASE                                           # COUNTER FOR ASCENT DAP


# THE SAVE RATE INDEX AND THE THREE DELCDUS ARE LOCATED HERE TEMPORARILY, AWAITING MORE LOGICAL PLACEMENT WHEN THE
# DAP IS ASSEMBLED INTO SUNBURST

DLCDUIDX        ERASE                                           # SAVE RATE INDEX, = 1, 0
DELCDUX         ERASE
DELCDUY         ERASE                                           # DELCDUS ARE SCALED AT P1, LIKE THE CDUS
DELCDUZ         ERASE
