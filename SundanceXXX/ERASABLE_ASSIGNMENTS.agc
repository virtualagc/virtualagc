### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ERASABLE_ASSIGNMENTS.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.
##              2020-07-27 MAS  Corrected VVARMIN to be double-precision
##                              instead of triple-precision.
##              2021-05-30 ABS  TTPIO -> TTPI0

## This log section assembles such that the addresses of all erasables match
## their locations for Sundance 306, to the best of our knowledge. The order
## of definitions, and especially the comments, may not reflect the original
## listing.

# CONVENTIONS AND NOTATIONS UTILIZED FOR ERASABLE ASSIGNMENTS.

#          EQUALS IS USED IN TWO WAYS.  IT IS OFTEN USED TO CHAIN A GROUP
#                 OF ASSIGNMENTS SO THAT THE GROUP MAY BE MOVED WITH THE
#                 CHANGING OF ONLY ONE CARD.  EXAMPLE.

#                                         X        EQUALS  START
#                                         Y        EQUALS  X       +SIZE.X
#                                         Z        EQUALS  Y       +SIZE.Y

#                 (X, Y, AND Z ARE CONSECUTIVE AND BEGIN AT START.       )
#                 (SIZE.X AND SIZE.Y ARE THE RESPECTIVE SIZES OF X AND Y,
#                  USUALLY NUMERIC,  IE. 1, 2, 6, 18D ETC.                )

#          EQUALS OFTEN IMPLIES THE SHARING OF REGISTERS (DIFFERENT NAMES
#                 AND DIFFERENT DATA).  EXAMPLE.

#                                         X        EQUALS Y

#          = MEANS THAT MULTIPLE NAMES HAVE BEEN GIVEN TO THE SAME DATA.
#                 (THIS IS LOGICAL EQUIVALENCE, NOT SHARING)  EXAMPLE.

#                                         X        =      Y

#          THE SIZE AND UTILIZATION OF AN ERASABLE ARE OFTEN INCLUDED IN
#          THE COMMENTS IN THE FOLLOWING FORM.  M(SIZE)N.

#                 M REFERS TO THE MOBILITY OF THE ASSIGNMENT.
#                      B   MEANS THAT THE SYMBOL IS REFERENCED BY BASIC
#                          INSTRUCTIONS AND THUS IS E-BANK SENSITIVE.
#                      I   MEANS THAT THE SYMBOL IS REFERENCED ONLY BY
#                          INTERPRETIVE INSTRUCTIONS, AND IS THUS E-BANK
#                          INSENSITIVE AND MAY APPEAR IN ANY E-BANK.

#                 SIZE IS THE NUMBER OF REGISTERS INCLUDED BY THE SYMBOL.

#                 N INDICATES THE NATURE OR PERMANENCE OF THE CONTENTS.
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

#                          IT MAY BE SHARED WITHANY OTHER ROUTINE WHICH
#                          IS NOT ACTIVE IN PARALLEL.
#                     IN   MEANS INPUT TO THE ROUTINE AND IT IS PROBABLY
#                          TEMPORARY FOR A HIGHER-LEVEL ROUTINE/PROGRAM.
#                     OUT  MEANS OUTPUT FROM THE ROUTINE, PROBABLY
#                          TEMPORARY FOR A HIGHER-LEVEL ROUTINE/PROGRAM.

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
OPTY            EQUALS          35
CDUS            EQUALS          36                      # REND RADAR SHAFT CDU
OPTX            EQUALS          36
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
# END OF CHANNEL ASSIGNMENTS

#          FLAGWORDS


# FLAGWRD0      STATE +0        (000-014)
# FLAGWRD1      STATE +1        (015-029)
# FLAGWRD2      STATE +2        (030-044)
# FLAGWRD3      STATE +3        (045-059)
# FLAGWRD4      STATE +4        (060-074)
# FLAGWRD5      STATE +5        (075-089)
# FLAGWRD6      STATE +6        (090-104)
# FLAGWRD7      STATE +7        (105-119)
# FLAGWRD8      STATE +8D       (120-134)
# FLAGWRD9      STATE +9D       (135-149)
#

#          SORTED LIST OF
#          INTERPITIVE SWITCH BIT ASSIGNMENTS

# INTERPRETIVE SWITCH BIT ASSIGNMENTS
#
# FLAGWORD        DEC. NUMBER     BIT AND FLAG         BIT NAME

# ACMODFLG        032             BIT 13 FLAG 2        ACMODBIT
# APSESW          130             BIT 5  FLAG 8        APSESBIT
# APSFLAG         018             BIT 12 FLAG 1        APSFLBIT
# ASTNFLAG        108             BIT 12 FLAG 7        ASTNBIT
# ATTFLAG         104             BIT 1  FLAG 6        ATTFLBIT
# ASCNTFLG        103             BIT 2  FLAG 6        ASCNTBIT
# AUTMANSW        045             BIT 15 FLAG 3        AUTMNBIT
# AVEGFLAG        115             BIT 5  FLAG 7        AVEGFBIT
# AVEMIDSW        149             BIT 1  FLAG 9        AVEMDBIT
# AVFLAG          040             BIT 5  FLAG 2        AVFLBIT
# B29FLAG         013             BIT 2  FLAG 0        B29FLBIT
# CALCMAN2        043             BIT 2  FLAG 2        CALC2BIT
# CALCMAN3        042             BIT 3  FLAG 2        CALC3BIT
# CMOONFLG        123             BIT 12 FLAG 8        CMOONBIT
# COGAFLAG        131             BIT 4  FLAG 8        COGAFBIT
# COMPUTER        082             BIT 8  FLAG 5        COMPTBIT
# CPHIFLAG        000             BIT 15 FLAG 0        CPHIBIT
# CULTFLAG        053             BIT 7  FLAG 3        CULTBIT
# CYCLESW         035             BIT 10 FLAG 2        CYCLEBIT
# DIMOFLAG        059             BIT 1  FLAG 3        DIMOBIT
# DMENFLG         081             BIT 9  FLAG 5        DMENFBIT
# DRIFTFLG        030             BIT 15 FLAG 2        DRFTBIT
# DSKYFLAG        075             BIT 15 FLAG 5        DSKYFBIT
# D6OR9FLG        058             BIT 2  FLAG 3        D6OR9BIT
# ENGONFLG        083             BIT 7  FLAG 5        ENGONBIT
# ERADFLAG        017             BIT 13 FLAG 1        ERADFBIT
# ETPIFLAG        038             BIT 7  FLAG 2        ETPIBIT         EQUIVALENT FLAG NAME:  OPTNSW
# FINALFLG        039             BIT 6  FLAG 2        FINALBIT
# FIRSTFLG        094             BIT 11 FLAG 6        FIRSTBIT
# FLAP            142             BIT 8  FLAG 9        FLAPBIT
# FLIC            143             BIT 7  FLAG 9        FLICBIT
# FLPC            138             BIT 12 FLAG 9        FLPCBIT
# FLPI            139             BIT 11 FLAG 9        FLPIBIT
# FLP70           137             BIT 13 FLAG 9        FLP70BIT
# FLRCS           149             BIT 10 FLAG 9        FLRCSBIT
# FLUNDISP        125             BIT 10 FLAG 8        FLUNDBIT
# FLVR            136             BIT 14 FLAG 9        FLVRBIT
# FLZONE0         144             BIT 6  FLAG 9        FLZONBIT
# FREEFLAG        012             BIT 3  FLAG 0        FREEFBIT
# GIMBFLG         026             BIT 4  FLAG 1        GIMBFBIT
# GLOKFAIL        046             BIT 14 FLAG 3        GLOKFBIT
# GMBDRVSW        095             BIT 10 FLAG 6        GMBDRBIT
# GUESSW          028             BIT 2  FLAG 1        GUESSBIT
# IDLEFLAG        113             BIT 7  FLAG 7        IDLEFBIT
# IGNFLAG         107             BIT 13 FLAG 7        IGNFLBIT
# IMPULSW         036             BIT 9  FLAG 2        IMPULBIT
# IMUSE           007             BIT 8  FLAG 0        IMUSEBIT
# INFINFLG        128             BIT 7  FLAG 8        INFINBIT
# INTFLG2         076             BIT 14 FLAG 5        INTF2BIT
# INTYPFLG        056             BIT 4  FLAG 3        INTYPBIT
# ITSWICH         105             BIT 15 FLAG 7        ITSWBIT
# JSWITCH         001             BIT 14 FLAG 0        JSWCHBIT
# KFLAG           014             BIT 1  FLAG 0        KBIT
# KILLROSE        100             BIT 5  FLAG 6        KILLRBIT
# LETABORT        141             BIT 9  FLAG 9        LETABBIT
# LMOONFLG        124             BIT 11 FLAG 8        LMOONBIT
# LOKONSW         010             BIT 5  FLAG 0        LOKONBIT
# LOSCMFLG        033             BIT 12 FLAG 2        LOSCMBIT
# LUNAFLAG        048             BIT 12 FLAG 3        LUNABIT
# MANUFLAG        106             BIT 14 FLAG 7        MANUFBIT
# MGLVFLAG        088             BIT 2  FLAG 5        MGLVFBIT
# MIDAVFLG        148             BIT 2  FLAG 9        MIDAVBIT
# MIDFLAG         002             BIT 13 FLAG 0        MIDFLBIT
# MID1FLAG        147             BIT 3  FLAG 9        MID1BIT
# MKOVFLAG        072             BIT 3  FLAG 4        MKOVBIT
# MOONFLAG        003             BIT 12 FLAG 0        MOONBIT
# MRKIDFLG        060             BIT 15 FLAG 4        MRKIDBIT
# MRKNVFLG        066             BIT 9  FLAG 4        MRKNVBIT
# MRUPTFLG        070             BIT 5 FLAG 4         MRUPTBIT
# MUNFLAG         097             BIT 8 FLAG 6         MUNFLBIT
# MWAITFLG        064             BIT 11 FLAG 4        MWAITBIT
# NEEDLFLG        011             BIT 4  FLAG 0        NEEDLBIT
# NEWIFLG         122             BIT 13  FLAG 8       NEWIBIT
# NJETSFLG        015             BIT 15 FLAG          NJETSBIT
# NODOFLAG        044             BIT 1  FLAG 2        NODOBIT
# NORMSW          110             BIT 10 FLAG 7        NORMSBIT
# NORRMON         086             BIT 4  FLAG 5        NORRMBIT
# NOTHROTL        078             BIT 12 FLAG 5        NOTHRBIT
# NOUPFLAG        024             BIT 6  FLAG 1        NOUPFBIT
# NRMNVFLG        067             BIT 8  FLAG 4        NRMNVBIT
# NRMIDFLG        062             BIT 13 FLAG 4        NRMIDBIT
# NRUPTFLG        071             BIT 4  FLAG 4        NRUPTBIT
# NTARGFLG        102             BIT 3  FLAG 6        NTARGBIT
# NWAITFLG        065             BIT 10 FLAG 4        NWAITBIT
# OPTNSW          038             BIT 7  FLAG 2        OPTNBIT         EQUIVALENT FLAG NAME:  ETPIFLAG
# ORBWFLAG        054             BIT 6  FLAG 3        ORBWFBIT
# ORDERSW         129             BIT 6  FLAG 8        ORDERBIT
# PDSPFLAG        063             BIT 12 FLAG 4        PDSPFBIT
# PFRATFLG        041             BIT 4  FLAG 2        PFRATBIT
# PINBRFLG        069             BIT 6  FLAG 4        PINBRBIT
# PRECIFLG        052             BIT 8  FLAG 3        PRECIBIT
# PRIODFLG        061             BIT 14 FLAG 1        PRIODBIT
# PRONVFLG        068             BIT 7  FLAG 4        PRONVBIT
# P25FLAG         006             BIT 9  FLAG 0        P25FLBIT
# P39/79SW        126             BIT 9  FLAG 8        P39SWBIT
# QUITFLAG        145             BIT 5  FLAG 9        QUITBIT
# REDFLAG         099             BIT 6  FLAG 6        REDFLBIT
# REFSMFLG        047             BIT 13 FLAG 3        REFSMBIT
# RENDWFLG        089             BIT 1  FLAG 5        RENDWBIT
# RNDVZFLG        008             BIT 7  FLAG 0        RNDVZBIT
# RNGSCFLG        080             BIT 10 FLAG 5        RNGSCBIT
# RPQFLAG         120             BIT 15 FLAG 8        RPQFLBIT
# RRNBSW          009             BIT 6 FLAG 0         RRNBBIT
# RVSW            111             BIT 9  FLAG 7        RVSWBIT
# R04FLAG         051             BIT 9  FLAG 3        R04FLBIT
# R32FLAG         121             BIT 14 FLAG 8        R32FLBIT
# R77FLAG         079             BIT 11 FLAG 5        R77FLBIT
# SLOPESW         027             BIT 3  FLAG 1        SLOPEBIT
# SNUFFER         077             BIT 13 FLAG 5        SNUFFBIT
# SOLNSW          087             BIT 3  FLAG 5        SOLNSBIT
# SRCHOPTN        031             BIT 14 FLAG 2        SRCHOBIT
# STATEFLG        055             BIT 5  FLAG 3        STATEBIT
# STEERSW         034             BIT 11 FLAG 2        STEERBIT
# SURFFLAG        127             BIT 8  FLAG 8        SURFFBIT
# SWANDISP        109             BIT 11 FLAG 7        SWANDBIT
# S32.1F1         090             BIT 15 FLAG 6        S32BIT1
# S32.1F2         092             BIT 14 FLAG 6        S32BIT2
# S32.1F3A        092             BIT 13 FLAG 6        S32BIT3A
# S32.1S3B        093             BIT 12 FLAG 6        S32BIT3B
# TFFSW           119             BIT 1  FLAG 7        TFFSWBIT
# TRACKFLG        025             BIT 5  FLAG 1        TRACKBIT
# UPDATFLG        023             BIT 7  FLAG 1        UPDATBIT
# UPLOCKFL        116             BIT 4  FLAG 7        UPLOCBIT
# VEHUPFLG        022             BIT 8  FLAG 1        VEHUPBIT
# VERIFLAG        117             BIT 3  FLAG 7        VERIFBIT
# VFLAG           050             BIT 10 FLAG 3        VFLAGBIT
# VINHFLG         004             BIT 11 FLAG 0        VINHFBIT
# VINTFLAG        057             BIT 3  FLAG 3        VINTFBIT
# VORIDEFL        005             BIT 10 FLAG 0        VORIDBIT
# V37FLAG         114             BIT 6  FLAG 7        V37FLBIT
# V45FLAG         112             BIT 8  FLAG 7        V45FLBIT
# XDELVFLG        037             BIT 8  FLAG 2        XDELVBIT
# XDSPFLAG        074             BIT 1  FLAG 4        XDSPBIT
# LTCPFLG         096             BIT 9  FLAG 6        LTCPFBIT
# 3AXISFLG        084             BIT 6 FLAG 5         3AXISBIT
# 360SW           134             BIT 1 FLAG  8        360SWBIT
#
#           ASSIGNMENT AND DESCRIPTION OF FLAGWORDS

FLAGWRD0        =               STATE           +0      # (000-014)

                                                        # (SET)              (RESET)

# BIT 15 FLAG 0 (S)
CPHIFLAG        =               000D                    # OUTPUT OF CALCGA IS OUTPUT OF CALCGA IS
CPHIBIT         =               BIT15                   # CPHIX               THETAD
#

# BIT 14 FLAG 0 (S)
JSWITCH         =               001D                    # INTEGRATION OF W    INTEGRATION OF STATE
JSWCHBIT        =               BIT14                   # MATRIX              VECTOR
#

# BIT 13 FLAG 0 (S)
MIDFLAG         =               002D                    # INTEGRATION WITH    INTEGRATION WITHOUT
                                                        # SECONDARY BODY AND  SOLAR PERTURBATIONS
MIDFLBIT        =               BIT13                   # SOLAR PERTURBATIONS

# BIT 12 FLAG 0 (L)
MOONFLAG        =               003D                    # MOON IS SPHERE OF   EARTH IS SPHERE OF
MOONBIT         =               BIT12                   # INFLUENCE           INFLUENCE

# BIT 11 FLAG 0
VINHFLG         =               004D                    # LANDING RADAR VEL   LANDING RADAR VEL
VINHFBIT        =               BIT11                   # UPDATES INHIBITED   UPDATES PERMITTED
#

# BIT 10 FLAG 0
VORIDEFL        =               005D                    # LANDING RADAR VEL   LANDING RADAR VEL
VORIDBIT        =               BIT10                   # OVERRIDE ACTIVE     NOT OVERRIDDEN
#

# BIT 9 FLAG 0  (S)
P25FLAG         =               006D                    # P25 OPERATING       P25 NOT OPERATING
P25FLBIT        =               BIT9
#

# BIT 8 FLAG 0  (S)
IMUSE           =               007D                    # IMU IN USE          IMU NOT IN USE
IMUSEBIT        =               BIT8
#

# BIT 7 FLAG 0  (S)
RNDVZFLG        =               008D                    # P20 RUNNING (RADAR  P20 NOT RUNNING
RNDVZBIT        =               BIT7                    # IN USE)
#

# BIT 6 FLAG 0  (S)
RRNBSW          =               009D                    # RADAR TARGET IN     RADAR TARGET IN
RRNBBIT         =               BIT6                    # NB COORDINATES      SM COORDINATES
#

# BIT 5 FLAG 0  (S)
LOKONSW         =               010D                    # RADAR LOCK-ON       RADAR LOCK-ON NOT
LOKONBIT        =               BIT5                    # DESIRED             DESIRED
#

# BIT 4 FLAG 0  (S)
NEEDLFLG        =               011D                    # TOTAL ATTITUDE      A/P FOLLOWING
NEEDLBIT        =               BIT4                    # ERROR DISPLAYED     ERROR DISPLAYED
#

# BIT 3 FLAG 0
FREEFLAG        =               012D                    # (USED BY P51-53 TEMP IN MANY DIFFERENT
                                                        # ROUTINES & BY LUNAR + SOLAR EPHEMERIDES)
FREEFBIT        =               BIT3
#

# BIT 2 FLAG 0
B29FLAG         =               013D                    # MOON IS CENTRAL     EARTH IS CENTRAL
B29FLBIT        =               BIT2                    # BODY                BODY
#

# BIT 1 FLAG 0  (L)
KFLAG           =               014D                    # SEARCH SECTOR MORE  SEARCH SECTOR LESS
                                                        # THAN 180 DEGREES    THAN 180 DEGREES
KBIT            =               BIT1

#
FLAGWRD1        =               STATE           +1      # (015-029)

                                                        #  (SET)              (RESET)

# BIT 15 FLAG 1 (S)
NJETSFLG        =               015D                    #  TWO JET RCS BURN    FOUR JET RCS BURN
NJETSBIT        =               BIT15
#

# BIT 14 FLAG 1
#               =               016D
#               =               BIT14
#

# BIT 13 FLAG 1 (S)
ERADFLAG        =               017D                    # COMPUTE REARTH       USE CONSTANT REARTH
ERADFBIT        =               BIT13                   # FISCHER ELLIPSOID    PAD RADIUS
#

# BIT 12 FLAG 1
APSFLAG         =               018D                    # ASCENT STAGE         DESCENT STAGE
APSFLBIT        =               BIT12


# BIT 11 FLAG 1
#               =               019D

# BIT 10 FLAG 1
#               =               020D
#               =               BIT10

# BIT 9 FLAG 1
#               =               021D
#               =               BIT9

# BIT 8 FLAG 1  (S)
VEHUPFLG        =               022D                    # CSM STATE VECTOR     LEM STATE VECTOR
VEHUPBIT        =               BIT8                    # BEING UPDATED        BEING UPDATED
#

# BIT 7 FLAG 1  (S)
UPDATFLG        =               023D                    # UPDATING BY MARKS    UPDATING BY MARKS
UPDATBIT        =               BIT7                    # ALLOWED              NOT ALLOWED
#

# BIT 6 FLAG 1  (S)

NOUPFLAG        =               024D                    # NEITHER CSM         EITHER STATE
                                                        # NOR LM STATE VECTOR VECTOR MAY BE
NOUPFBIT        =               BIT6                    # MAY BE UPDATED      UPDATED
#

# BIT 5 FLAG 1  (S)
TRACKFLG        =               025D                    # TRACKING ALLOWED    TRACKING NOT ALLOWED
TRACKBIT        =               BIT5

# BIT 4 FLAG 1
GIMBFLG         =               026D                    # USING TRIM GIMBAL   NOT USING TRIM
GIMBFBIT        =               BIT4                    #                     GIMBAL
#

# BIT 3 FLAG 1  (S)
SLOPESW         =               027D                    # ITERATE WITH BIAS   ITERATE WITH REGULAR
                                                        # METHOD IN ITERATOR  FALSI METHOD IN
SLOPEBIT        =               BIT3                    #                     ITERATOR
#

# BIT 2 FLAG 1  (S)
GUESSW          =               028D                    # NO STARTING VALUE   STARTING VALUE FOR
GUESSBIT        =               BIT2                    # FOR ITERATION       ITERATION EXISTS
#

# BIT 1 FLAG 1
HINHFLG         =               029D                    # LR HEIGHT UPDATES   LR HEIGHT UPDATES
HINHFBIT        =               BIT1                    # INHIBITED           PERMITTED
#

FLAGWRD2        =               STATE           +2      # (030-044)

                                                        # (SET)               (RESET)

# BIT 15 FLAG 2 (S)
DRIFTFLG        =               030D                    # T3RUPT CALLS GYRO   T3RUPT DOES NO GYRO
DRFTBIT         =               BIT15                   # COMPENSATION        COMPENSATION
#

# BIT 14 FLAG 2 (S)
SRCHOPTN        =               031D                    # RADAR IN AUTOMATIC  RADAR NOT IN AUTO-
SRCHOBIT        =               BIT14                   # SEARCH OPTION(R24)  MATIC SEARCH OPTION
#

# BIT 13 FLAG 2 (S)
ACMODFLG        =               032D                    # MANUAL ACQUISITION  AUTO ACQUISITION
ACMODBIT        =               BIT13                   # BY RENDESVOUS RADAR BY RENDESVOUS RADAR
#

# BIT 12 FLAG 2 (S)

LOSCMFLG        =               033D                    # LINE OF SIGHT BEING LINE OF SIGHT NOT
                                                        # COMPUTED (R21)      BEING COMPUTED
LOSCMBIT        =               BIT12
                                                        # IN R29 (L): RR GYRO IN R29 (L): RR GYRO
                                                        # CMD LOOP RUNNING    CMD LOOP OFF

# BIT 11 FLAG 2 (S)
STEERSW         =               034D                    # SUFFICIENT THRUST   INSUFFICIENT THRUST
STEERBIT        =               BIT11                   # IS PRESENT          IS PRESENT
#

# BIT 10 FLAG 2 (S)
CYCLESW         =               035D                    # LAMBERT VG CALCU-   LAMBERT CALCULATION
CYCLEBIT        =               BIT10                   # LATION TO BE DONE   OMITTED
#

# BIT 9 FLAG 2 (S)
IMPULSW         =               036D                    # MINIMUM IMPULSE     STEERING BURN (NO
                                                        # BURN (CUTOFF TIME   CUTOFF TIME YET
IMPULBIT        =               BIT9                    # SPECIFIED)          AVAILABLE)
#

# BIT 8 FLAG 2 (S)
XDELVFLG        =               037D                    # EXTERNAL DELTAV VG  LAMBERT (AIMPOINT)
XDELVBIT        =               BIT8                    # COMPUTATION         VG COMPUTATION
#

# BIT 7 FLAG 2 (S)
ETPIFLAG        =               038D                    # ELEVATION ANGLE     TPI TIME SUPPLIED
                                                        # SUPPLIED FOR        FOR P34,74 TO COMPUT
ETPIBIT         =               BIT7                    # P34,74              ELEVATION
#

# BIT 7 FLAG 2 (L)
OPTNSW          =               ETPIFLAG                # SOI PHASE OF P38/78  SOR PHASE OF P38/78
OPTNBIT         =               BIT7
#

# BIT 6 FLAG 2 (S)
FINALFLG        =               039D                    # LAST PASS THROUGH   INTERIM PASS THROUGH
                                                        # RENDEZVOUS PROGRAM  RENDEZVOUS PROGRAM
FINALBIT        =               BIT6                    # COMPUTATIONS        COMPUTATIONS
#

# BIT 5 FLAG 2 (S)
AVFLAG          =               040D                    # LEM IS ACTIVE       CSM IS ACTIVE
AVFLBIT         =               BIT5                    # VEHICLE             VEHICLE
#

# BIT 4 FLAG 2 (S)

PFRATFLG        =               041D                    # PREFERRED ATTITUDE  PREFERRED ATTITUDE
PFRATBIT        =               BIT4                    # COMPUTED            NOT COMPUTED
#

# BIT 3 FLAG 2 (S)
CALCMAN3        =               042D                    # NO FINAL ROLL       FINAL ROLL IS
CALC3BIT        =               BIT3                    #                     NECESSARY
#

# BIT 2 FLAG 2 (S)
CALCMAN2        =               043D                    # PERFORM MANEUVER    BYPASS STARTING
CALC2BIT        =               BIT2                    # STARTING PROCEDURE  PROCEDURE
#

# BIT 1 FLAG 2 (S)
NODOFLAG        =               044D                    # V37 NOT PERMITTED   V37 PERMITTED
NODOBIT         =               BIT1
#

FLAGWRD3        =               STATE           +3      # (045-059)

                                                        # (SET)               (RESET)

# BIT 15 FLAG 3
AUTMANSW        =               045D                    # MANUAL MANEUVER     AUTOMATIC MANEUVER
AUTMNBIT        =               BIT15                   # DESIRED             DESIRED
#

# BIT 14 FLAG 3 (S)
GLOKFAIL        =               046D                    # GIMBAL LOCK HAS     NOT IN GIMBAL LOCK
GLOKFBIT        =               BIT14                   # OCCURRED
#

# BIT 13 FLAG 3
REFSMFLG        =               047D                    # REFSMMAT GOOD       REFSMMAT NO GOOD
REFSMBIT        =               BIT13
#

# BIT 12 FLAG 3 (S)
LUNAFLAG        =               048D                    # LUNAR LAT-LONG      EARTH LAT-LONG
LUNABIT         =               BIT12
#

# BIT 11 FLAG 3
#               =               049D
#               =               BIT11
#

# BIT 10 FLAG 3 (S)
VFLAG           =               050D                    # LESS THAN TWO STARS TWO STARS IN FIELD
VFLAGBIT        =               BIT10                   # IN FIELD OF VIEW    OF VIEW

#

# BIT 9 FLAG 3  (S)
R04FLAG         =               051D                    # ALARM 521           ALARM 521 ALLOWED
                                                        # SUPPRESSED
R04FLBIT        =               BIT9
#

# BIT 8 FLAG 3  (S)
PRECIFLG        =               052D                    # NORMAL INTEGRATION  ENGAGES 4-TIME STEP
                                                        # IN POO              (POO) LOGIC IN INTE-
PRECIBIT        =               BIT8                    #                     GRATION
#

# BIT 7 FLAG 3  (S)
CULTFLAG        =               053D                    # STAR OCCULTED       STAR NOT OCCULTED
CULTBIT         =               BIT7
#

# BIT 6 FLAG 3  (S)
ORBWFLAG        =               054D                    # W MATRIX VALID FOR  W MATRIX INVALID FOR
ORBWFBIT        =               BIT6                    # ORBITAL NAVIGATION  ORBITAL NAVIGATION
#

# BIT 5 FLAG 3  (S)
STATEFLG        =               055D                    # PERMANENT STATE     PERMANENT STATE
STATEBIT        =               BIT5                    # VECTOR UPDATED      VECTOR NOT UPDATED
#

# BIT 4 FLAG 3  (S)
INTYPFLG        =               056D                    # CONIC INTEGRATION   ENCKE INTEGRATION
INTYPBIT        =               BIT4
#

# BIT 3 FLAG 3  (S)
VINTFLAG        =               057D                    # CSM STATE VECTOR    LEM STATE VECTOR
VINTFBIT        =               BIT3                    # BEING INTEGRATED    BEING INTEGRATED
#

# BIT 2 FLAG 3 (S)
D6OR9FLG        =               058D                    # DIMENSION OF W IS 9 DIMENSION OF W IS 6
D6OR9BIT        =               BIT2                    # FOR INTEGRATION     FOR INTEGRATION
#

# BIT 1 FLAG 3  (S)

DIM0FLAG        =               059D                    # W MATRIX IS TO BE   W MATRIX IS NOT TO
DIM0BIT         =               BIT1                    # USED                BE USED
#

FLAGWRD4        =               STATE           +4      # (060-074)

                                                        # (SET)               (RESET)

# BIT 15 FLAG 4 (S)
MRKIDFLG        =               060D                    # MARK DISPLAY IN     NO MARK DISPLAY IN
MRKIDBIT        =               BIT15                   # ENDIDLE             ENDIDLE
#

# BIT 14 FLAG 4 (S)
PRIODFLG        =               061D                    # PRIORITY DISPLAY IN NO PRIORITY DISPLAY
PRIODBIT        =               BIT14                   # ENDIDLE             IN ENDIDLE
#

# BIT 13 FLAG 4 (S)
NRMIDFLG        =               062D                    # NORMAL DISPLAY IN   NO NORMAL DISPLAY
NRMIDBIT        =               BIT13                   # ENDIDLE             IN ENDIDLE
#

# BIT 12 FLAG 4 (S)
PDSPFLAG        =               063D                    # P20 SETS SO AS TO   LEAVE AS NORMAL DISP
                                                        # TURN A NORMAL DIS-
PDSPFBIT        =               BIT12                   # PLAY INTO A PRIORITY
                                                        # DISPLAY IN R60
#

# BIT 11 FLAG 4 (S)
MWAITFLG        =               064D                    # HIGHER PRIORITY      NO HIGHER PRIORITY
                                                        # DISPLAY OPERATING    DISPLAY OPERATING
MWAITBIT        =               BIT11                   # WHEN MARK DISPLAY    WHEN MARK DISPLAY
                                                        # INITIATED            INITIATED

# BIT 10 FLAG 4 (S)
NWAITFLG        =               065D                    # HIGHER PRIORITY      NO HIGHER PRIORITY
                                                        # DISPLAY OPERATING    DISPLAY OPERATING
NWAITBIT        =               BIT10                   # WHEN NORMAL          WHEN NORMAL DISPLAY
                                                        # DISPLAY INITIATED    INITIATED

# BIT 9 FLAG 4  (S)
MRKNVFLG        =               066D                    # ASTRONAUT USING      ASTRONAUT NOT USING
                                                        # KEYBOARD WHEN MARK   KEYBOARD WHEN MARK
MRKNVBIT        =               BIT9                    # DISPLAY INITIATED    DISPLAY INITIATED
#

# BIT 8 FLAG 4  (S)
NRMNVFLG        =               067D                    # ASTRONAUT USING      ASTRONAUT NOT USING

                                                        # KEYBOARD WHEN        KEYBOARD WHEN
NRMNVBIT        =               BIT8                    # NORMAL DISPLAY       NORMAL DISPLAY
                                                        # INITIATED            INITIATED

# BIT 7 FLAG 4  (S)
PRONVFLG        =               068D                    # ASTRONAUT USING      ASTRONAUT NOT USING
                                                        # KEYBOARD WHEN        KEYBOARD WHEN
PRONVBIT        =               BIT7                    # PRIORITY DISPLAY     PRIORITY DISPLAY
                                                        # INITIATED            INITIATED

# BIT 6 FLAG 4  (S)
PINBRFLG        =               069D                    # ASTRONAUT HAS        ASTRONAUT HAS NOT
                                                        # INTERFERED WITH      INTERFERED WITH
PINBRBIT        =               BIT6                    # EXISTING DISPLAY     EXISTING DISPLAY
#

# BIT 5 FLAG 4  (S)
MRUPTFLG        =               070D                    # MARK DISPLAY         MARK DISPLAY NOT
                                                        # INTERRUPTED BY       INTERRUPTED BY
MRUPTBIT        =               BIT5                    # PRIORITY DISPLAY     PRIORITY DISPLAY
#

# BIT 4 FLAG 4  (S)
NRUPTFLG        =               071D                    # NORMAL DISPLAY       NORMAL DISPLAY NOT
                                                        # INTERRUPTED BY       INTERRUPTED BY
NRUPTBIT        =               BIT4                    # PRIORITY OR MARK     PRIORITY OR MARK
                                                        # DISPLAY              DISPLAY

# BIT 3 FLAG 4  (S)
MKOVFLAG        =               072D                    # MARK DISPLAY OVER    NO MARK DISPLAY OVER
MKOVBIT         =               BIT3                    # NORMAL               NORMAL
#

# BIT 2 FLAG 4
#               =               073D

#

# BIT 1 FLAG 4  (S)
XDSPFLAG        =               074D                    # MARK DISPLAY NOT     NO SPECIAL MARK
XDSPBIT         =               BIT1                    # TO BE INTERRUPTED    INFORMATION
#

FLAGWRD5        =               STATE           +5      # (075-089)
                                                        # (SET)                (RESET)

# BIT 15 FLAG 5 (S)
DSKYFLAG        =               075D                    # DISPLAYS SENT TO     NO DISPLAYS TO DSKY
DSKYFBIT        =               BIT15                   # DSKY
#

# BIT 14 FLAG 5
INTFLG2         =               076D                    # ORBITAL INTEGRATION ORBITAL INTEGRATION
                                                        # PROGRAM PACKAGE IN  PROGRAM PACKAGE NOT
INTF2BIT        =               BIT14                   # USE                 IN USE
#

# BIT 13 FLAG 5 (S,L)
SNUFFER         =               077D                    # U,V JETS DISABLED   U,V JETS ENABLED
                                                        # DURING DPS          DURING DPS
SNUFFBIT        =               BIT13                   # BURNS (V65)         BURNS (V75)
#

# BIT 12 FLAG 5 (S)
NOTHROTL        =               078D                    # INHIBIT FULL        PERMIT FULL THROTTLE
NOTHRBIT        =               BIT12                   # THROTTLE
#

# BIT 11 FLAG 5 (S,L)
R77FLAG         =               079D                    # R77 IS ON,         R77 IS NOT ON.
                                                        # SUPPRESS ALL RADAR
                                                        # ALARMS AND TRACKER
R77FLBIT        =               BIT11                   # FAILS
#

# BIT 10 FLAG 5 (S)
RNGSCFLG        =               080D                    # SCALE CHANGE HAS    NO SCALE CHANGE HAS
                                                        # OCCURRED DURING     OCCURRED DURING
RNGSCBIT        =               BIT10                   # RR READING          RR READING
#

# BIT 9 FLAG 5  (S)
DMENFLG         =               081D                    # DIMENSION OF W IS 9 DIMENSION OF W IS 6
DMENFBIT        =               BIT9                    # FOR INCORPORATION   FOR INCORPORATION
#

# BIT 8 FLAG 5  (S)
COMPUTER        =               082D                    # COMPUTER IS CMC     COMPUTER IS LGC
COMPTBIT        =               BIT8
#

# BIT 7 FLAG 5  (S)
ENGONFLG        =               083D                    # ENGINE TURNED ON    ENGINE TURNED OFF
ENGONBIT        =               BIT7
#

# BIT 6 FLAG 5  (S)
3AXISFLG        =               084D                    # MANEUVER SPECIFIED  MANEUVER SPECIFIED
                                                        # BY THREE AXES       BY ONE AXIS; R60
3AXISBIT        =               BIT6                    #                     CALLS VECPOINT.
#

# BIT 5 FLAG 5
#               =               085D
#

# BIT 4 FLAG 5  (S)
NORRMON         =               086D                    # BYPASS RR GIMBAL    PERFORM
NORRMBIT        =               BIT4                    # MONITOR             RR GIMBAL MONITOR
#

# BIT 3 FLAG 5  (S)
SOLNSW          =               087D                    # LAMBERT DOES NOT    LAMBERT CONVERGES OR
                                                        # CONVERGE,OR TIME-RADTIME-RADIUS NON
SOLNSBIT        =               BIT3                    # NEARLY CIRCULAR     CIRCULAR
#

# BIT 2 FLAG 5  (S)
MGLVFLAG        =               088D                    # LOCAL VERTICAL      MIDDLE GIMBAL ANGLE
                                                        # COORDINATES         COMPUTED
MGLVFBIT        =               BIT2                    # COMPUTED

# BIT 1 FLAG 5  (S)
RENDWFLG        =               089D                    # W MATRIX VALID      W MATRIX INVALID
                                                        # FOR RENDEZVOUS      FOR RENDEZVOUS
RENDWBIT        =               BIT1                    # NAVIGATION          NAVIGATION
#

FLAGWRD6        =               STATE           +6      # (090-104)

                                                        # (SET)               (RESET)

# BIT 15 FLAG 6 (S)
S32.1F1         =               090D                    # DELTA V AT CSI TIME  DVT1 LESS THEN MAX
S32BIT1         =               BIT15                   # ONE EXCEEDS MAX
#

# BIT 14 FLAG 6 (S)
S32.1F2         =               091D                    # FIRST PASS OF       REITERATION OF
S32BIT2         =               BIT14                   # NEWTON ITERATION    NEWTON
#

# BIT 13 FLAG 6 (S)
S32.1F3A        =               092D                    # BIT 13 AND BIT 12 FUNCTION AS AN ORDERED
S32BIT3A        =               BIT13                   # PAIR (13,12) INDICATING THE POSSIBLE OC-
                                                        # CURRANCE OF 2NEWTON ITERATIONS FOR S32.1
                                                        # IN THE PROGRAM IN THE FOLLOWING ORDER:
# BIT 12 FLAG 6                                           (0,1) (I.E.BIT 13 RESET,BIT 12 SET)
S32.1F3B        =               093D                    #      = FIRST NEWTON ITERATION BEING DONE
S32BIT3B        =               BIT12                   # (0,0)= FIRST PASS OF SECOND NEWT.ITERAT.
                                                        # (1,1)= 50 FT/SEC STAGE OF SEC. NEWT.ITER

                                                        # (1,0)= REMAINDER OF SECOND NEWTON ITERA.
#

# BIT 11 FLAG 6 (S)
FIRSTFLG        =               094D                    # SUCCEEDING PASS     FIRST PASS THRU
FIRSTBIT        =               BIT11                   # THRU S40.9          S40.9
#

# BIT 10 FLAG 6 (S)
GMBDRVSW        =               095D                    # TRIMGIMB OVER       TRIMGIMB NOT OVER
GMBDRBIT        =               BIT10                   #
#

# BIT 9 FLAG 6
LTCPFLG         =               096D                    # LAUNCH TIME         LAUNCH TIME DIRECT
LTCPFBIT        =               BIT9                    # CONCENTRIC FLIGHT   TRANSFER
                                                        # PLAN
#

# BIT 8 FLAG 6  (S)
MUNFLAG         =               097D                    # SERVICER CALLS      SERVICER CALLS
MUNFLBIT        =               BIT8                    # MUNRVG              CALCRVG
#

# BIT 7 FLAG 6
#               =               098D
#               =               BIT7
#

# BIT 6 FLAG 6  (L)
REDFLAG         =               099D                    # LANDING SITE        LANDING SITE
                                                        # REDESIGNATION       REDESIGNATION NOT
REDFLBIT        =               BIT6                    # PERMITTED           PERMITTED
#

# BIT 5 FLAG 6
KILLROSE        =               100D                    # R11 COMMANDED       R11 NOT COMMANDED
KILLRBIT        =               BIT5                    # TO EXIT             TO EXIT

# BIT 4 FLAG 6
#               =               101D

# BIT 3 FLAG 6  (S)
NTARGFLG        =               102D                    # ASTRONAUT DID       ASTRONAUT DID NOT
                                                        # OVERWRITE DELTA     OVERWRITE DELTA
NTARGBIT        =               BIT3                    # VELOCITY AT TPI     VELOCITY
                                                        # OR TPM (P34,35)

# BIT 2 FLAG 6
ASCNTFLG        =               103D                    # ASCENT TIME HAS     ASCENT TIME HAS NOT
ASCNTBIT        =               BIT2                    # BEEN CALCULATED     BEEN CALCULATED

# BIT 1 FLAG 6  (L)
ATTFLAG         =               104D                    # LEM ATTITUDE EXISTS NO LEM ATTITUDE
                                                        # IN MOON-FIXED       AVAILABLE IN MOON-
ATTFLBIT        =               BIT1                    # COORDINATES         FIXED COORDINATES
#

FLAGWRD7        =               STATE           +7      # (105-119)

                                                        # (SET)               (RESET)

# BIT 15 FLAG 7 (S)
ITSWICH         =               105D                    # P34;TPI TIME TO BE  TPI HAS BEEN
ITSWBIT         =               BIT15                   # COMPUTED            COMPUTED
#

# BIT 14 FLAG 7 (S)
MANUFLAG        =               106D                    # ATTITUDE MANEUVER   NO ATTITUDE MANEUVER
                                                        # GOING DURING RR     DURING RR SEARCH
MANUFBIT        =               BIT14                   # SEARCH
#

# BIT 13 FLAG 7 (S)
IGNFLAG         =               107D                    # TIG HAS ARRIVED     TIG HAS NOT ARRIVED
IGNFLBIT        =               BIT13                   #
#

# BIT 12 FLAG 7 (S)
ASTNFLAG        =               108D                    # ASTRONAUT HAS       ASTRONAUT HAS NOT
ASTNBIT         =               BIT12                   # OKAYED IGNITION     OKAYED IGNITION
#

# BIT 11 FLAG 7 (L)
SWANDISP        =               109D                    # LANDING ANALOG      LANDING ANALOG
SWANDBIT        =               BIT11                   # DISPLAYS ENABLED    DISPLAYS SUPPRESSED
#

# BIT 10 FLAG 7 (S)
NORMSW          =               110D                    # UNIT NORMAL INPUT   LAMBERT COMPUTES ITS
NORMSBIT        =               BIT10                   # TO LAMBERT          OWN UNIT NORMAL
#

# BIT 9 FLAG 7  (S)
RVSW            =               111D                    # DO NOT COMPUTE      COMPUTE FINAL STATE
                                                        # FINAL STATE VECTOR  VECTOR IN TIME-THETA
RVSWBIT         =               BIT9                    # IN TIME-THETA
#

# BIT 8 FLAG 7  (S)
V45FLAG         =               112D                    # ASTRONAUT OVERWRITE  ASTRONAUT DOES NOT
                                                        # W-MATRIX INITIAL    OVERWRITE W-MATRIX
V45FLBIT        =               BIT8                    # VALUES              INITIAL VALUES
#

# BIT 7 FLAG 7  (S)
IDLEFLAG        =               113D                    # NO DV MONITOR       CONNECT DV MONITOR
IDLEFBIT        =               BIT7                    #
#

# BIT 6 FLAG 7  (S)
V37FLAG         =               114D                    # AVERAGEG (SERVICER) AVERAGEG (SERVICER)
V37FLBIT        =               BIT6                    # RUNNING             OFF
#

# BIT 5 FLAG 7  (S)
AVEGFLAG        =               115D                    # AVERAGEG (SERVICER) AVERAGEG (SERVICER)
AVEGFBIT        =               BIT5                    # DESIRED             NOT DESIRED
#

# BIT 4 FLAG 7  (S)
UPLOCKFL        =               116D                    # K-KBAR-K FAIL       NO K-KBAR-K FAIL
UPLOCBIT        =               BIT4
#

# BIT 3 FLAG 7  (S)
VERIFLAG        =               117D                    # CHANGED WHEN V33E OCCURS AT END OF P27
VERIFBIT        =               BIT3
#

# BIT 2 FLAG 7
#               =               118D
#               =               BIT2
#

# BIT 1 FLAG 7  (S)
TFFSW           =               119D                    # CALCULATE TPERIGEE  CALCULATE TFF
TFFSWBIT        =               BIT1                    #
#

FLAGWRD8        =               STATE           +8D     # (120-134)

                                                        # (SET)               (RESET)

# BIT 15 FLAG 8 (S)

RPQFLAG         =               120D                    # RPQ NOT COMPUTED    RPQ COMPUTED
                                                        # (RPQ = VECTOR BE-
RPQFLBIT        =               BIT15                   # TWEEN SECONDARY BODY
                                                        # AND PRIMARY BODY
#

# BIT 14 FLAG 8
R32FLAG         =               121D                    # R32 IS RUNNING      R32 IS NOT RUNNING
R32FLBIT        =               BIT14
#

# BIT 13 FLAG 8 (S)
NEWIFLG         =               122D                    # FIRST PASS THROUGH  SUCCEEDING ITERATION
NEWIBIT         =               BIT13                   # INTEGRATION         OF INTEGRATION
#

# BIT 12 FLAG 8
CMOONFLG        =               123D                    # PERMANENT CSM STATE PERMANENT CSM STATE
CMOONBIT        =               BIT12                   # IN LUNAR SPHERE     IN EARTH SPHERE
#

# BIT 11 FLAG 8
LMOONFLG        =               124D                    # PERMANENT LM STATE  PERMANENT LM STATE
LMOONBIT        =               BIT11                   # IN LUNAR SPHERE     IN EARTH SPHERE
#

# BIT 10 FLAG 8 (L)
FLUNDISP        =               125D                    # CURRENT GUIDANCE    CURRENT GUIDANCE
FLUNDBIT        =               BIT10                   # DISPLAYS INHIBITED  DISPLAYS PERMITTED
#

# BIT 9 FLAG 8  (L)
P39/79SW        =               126D                    # P39/79 OPERATING    P38/P78 OPERATING
P39SWBIT        =               BIT9
#

# BIT 8 FLAG 8
SURFFLAG        =               127D                    # LM ON LUNAR SURFACE LM NOT ON LUNAR
SURFFBIT        =               BIT8                    #                     SURFACE
#

# BIT 7 FLAG 8  (S)
INFINFLG        =               128D                    # NO CONIC SOLUTION   CONIC SOLUTION
                                                        # (CLOSURE THROUGH    EXISTS
INFINBIT        =               BIT7                    # INFINITY REQUIRED)
#

# BIT 6 FLAG 8  (S)
ORDERSW         =               129D                    # ITERATOR USES 2ND   ITERATOR USES 1ST
ORDERBIT        =               BIT6                    # ORDER MINIMUM MODE  ORDER STANDARD MODE

#

# BIT 5 FLAG 8  (S)
APSESW          =               130D                    # RDESIRED OUTSIDE    RDESIRED INSIDE
                                                        # PERICENTER-APOCENTERPERICENTER-APOCENTER
APSESBIT        =               BIT5                    # RANGE IN TIME-RADI  RANGE IN TIME-RADIUS
#

# BIT 4 FLAG 8  (S)
COGAFLAG        =               131D                    # NO CONIC SOLUTION - CONIC SOLUTION
                                                        # TOO CLOSE TO RECTI- EXISTS(COGA DOES NOT
COGAFBIT        =               BIT4                    # LINEAR(COGA OVRFLWS) OVERFLOW)
#

# BIT 3 FLAG 8
#               =               132D

# BIT 2 FLAG 8
#               =               133D
#               =               BIT2
#

# BIT 1 FLAG 8  (S)
360SW           =               134D                    # TRANSFER ANGLE NEAR TRANSFER ANGLE NOT
360SWBIT        =               BIT1                    # 360 DEGREES         NEAR 360 DEGREES
#

FLAGWRD9        =               STATE           +9D     # (135-149)

                                                        # (SET)               (RESET)
#

# BIT 15 FLAG 9
ENGOFFSW        =               135D
ENGOFBIT        =               BIT15

# BIT 14 FLAG 9 (L)
FLVR            =               136D                    # VERTICAL RISE       NON-VERTICAL RISE
FLVRBIT         =               BIT14                   # (ASCENT GUIDANCE)
#

# BIT 13 FLAG 9
FLP70           =               137D                    # P70 HAS BEEN CALLED  P70 HAS NOT BEEN
FLP70BIT        =               BIT13                   #                      CALLED
#

# BIT 12 FLAG 9 (L)
FLPC            =               138D                    # NO POSITION CONTROL  POSITION CONTROL
FLPCBIT         =               BIT12                   # (ASCENT GUIDANCE)
#


# BIT 11 FLAG 9 (L)
FLPI            =               139D                    # PRE-IGNITION PHASE   REGULAR GUIDANCE
FLPIBIT         =               BIT11                   # (ASCENT GUIDANCE)
#

# BIT 10 FLAG 9 (L)
FLRCS           =               140D                    # RCS INJECTION MODE   MAIN ENGINE MODE
FLRCSBIT        =               BIT10                   # (ASCENT GUIDANCE)
#

# BIT 9 FLAG 9  (L)
LETABORT        =               141D                    # ABORT PROGRAMS       ABORT PROGRAMS
LETABBIT        =               BIT9                    # ARE ENABLED          ARE NOT ENABLED
#

# BIT 8 FLAG 9  (L)
FLAP            =               142D                    # APS CONTINUED ABORT   APS ABORT IS NOT A
                                                        # AFTER DPS STAGING    CONTINUATION
FLAPBIT         =               BIT8                    # (ASCENT GUIDANCE)
#

# BIT 7 FLAG 9  (L)
FLIC            =               143D                    # INITIAL COMPUTATION  NOT INITIAL COMP
FLICBIT         =               BIT7                    # CYCLE FOR ABORTS     CYCLE FOR ABORTS

# BIT 6 FLAG 9  (L)
FLZONE0         =               144D                    # EARLY ABORT          LATE ABORT
FLZONBIT        =               BIT6                    # TFI . 50 SECS.       TFI > 50 SECS.
                                                        # P70 --> P40
                                                        # P71 --> P42

# BIT 5 FLAG 9  (S)
QUITFLAG        =               145D                    # DISCONTINUE INTEGR.  CONTINUE INTEGRATION
QUITBIT         =               BIT5                    #
#

# BIT 4 FLAG 9
R31FLAG         =               146D
R31FLBIT        =               BIT4
#

# BIT 3 FLAG 9  (L)
MID1FLAG        =               147D                    # INTEGRATE TO TDEC    INTEGRATE TO THE
MID1FBIT        =               BIT3                    #                      THEN-PRESENT TIME
#

# BIT 2 FLAG 9  (L)
MIDAVFLG        =               148D                    # INTEGRATION ENTERED  INTEGRATION WAS
                                                        # FROM ONE OF MIDTOAV  NOT ENTERED VIA
MIDAVBIT        =               BIT2                    # PORTALS              MIDTOAV
#

# BIT 1 FLAG 9  (S)
AVEMIDSW        =               149D                    # AVETOMID CALLING    NO AVETOMID W INTEGR
                                                        # FOR W.MATRIX INTEGR ALLOW SET UP RM,VN.
AVEMDBIT        =               BIT1                    # DONT WRITE OVER RN, PIPTIME
                                                        # VN,PIPTIME

#
# GENERAL ERASABLE ASSIGNMENTS.

                SETLOC          61
#          INTERRUPT TEMPORARY STORAGE POOL.                              (11D)

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
# NEWLOC+1      EQUALS  ITEMP6          DP ADDRESS.

                SETLOC          67
NEWJOB          ERASE                                   # MUST BE AT LOC 67 DUE TO WIRING.

RUPTREG1        ERASE
RUPTREG2        ERASE
RUPTREG3        ERASE
RUPTREG4        ERASE
KEYTEMP1        EQUALS          RUPTREG4
DSRUPTEM        EQUALS          RUPTREG4

#          FLAGWORD RESERVATIONS.                (13D)

STATE           ERASE           +12D                    # FLAGWORD REGISTERS.


#          RENDEZVOUS RADAR TASK STORAGE                                (3D)

RRRET           ERASE           +2D                     # B(1)TMP  P20'S, PERHAPS R29 & R12
RDES            EQUALS          RRRET           +1      # B(1)TMP
RRINDEX         EQUALS          RDES            +1      # B(1)TMP
#


#          EXEC TEMPORARIES WHICH MAY BE USED BETWEEN CCS NEWJOBS. (32D) (INTB15+ THROUGH RUPTMXTM)
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
SIGNRET         =               VBUF            +3      # RETURN FOR +,- ON

# ALSO MIXTEMP+1 = VBUF+4, MIXTEMP+2 = VBUF+5.

BUF             ERASE           +2                      # TEMPORARY SCALAR STORAGE.
BUF2            ERASE           +1
INDEXLOC        EQUALS          BUF                     # CONTAINS ADDRESS OF SPECIFIED INDEX.
SWWORD          EQUALS          BUF                     # ADDRESS OF SWITCH WORD.
SWBIT           EQUALS          BUF             +1      # SWITCH BIT WITHIN SWITCH WORD.
MPTEMP          ERASE                                   # TEMPORARY USED IN MULTIPLY AND SHIFT.
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
IDADDTEM        =               TEM2                    # MIXNOUN INDIRECT ADDRESS STORAGE

TEM3            ERASE                                   # EXEC TEMP
COUNT           =               TEM3                    # FOR DSPIN

TEM4            ERASE                                   # EXEC TEMP
LSTPTR          =               TEM4                    # LIST POINTER FOR GRABUSY
RELRET          =               TEM4                    # RETURN FOR RELDSP
FREERET         =               TEM4                    # RETURN FOR FREEDSP
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

IDAD3TEM        ERASE                                   # TEMP FOR INDIR ADRESS TABLE ENTRY (MIXNN)
                                                        # MUST = IDAD1TEM+2, = IDAD2TEM+1.
RUTMXTEM        ERASE                                   # TEMP FOR SF ROUT TABLE ENTRY (MIXNN ONLY)

#          AX*SR*T STORAGE.                      (6D)
DEXDEX          EQUALS          TEM2                    # B(1)TMP
DEX1            EQUALS          TEM3                    # B(1)TMP
DEX2            EQUALS          TEM4                    # B(1)TMP
RTNSAVER        EQUALS          TEM5                    # B(1)TMP
TERM1TMP        EQUALS          BUF2                    # B(2)TMP

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

#          DYNAMICALLY ALLOCATED CORE SETS FOR JOBS.                    (84D)

MPAC            ERASE           +6                      # MULTI-PURPOSE ACCUMULATOR.
MODE            ERASE                                   # +1 FOR TP, +0 FOR DP, OR -1 FOR VECTOR.
LOC             ERASE                                   # LOCATION ASSOCIATED WITH JOB.
BANKSET         ERASE                                   # USUALLY CONTAINS BBANK SETTING.
PUSHLOC         ERASE                                   # WORD OF PACKED INTERPRETIVE PARAMETERS.
PRIORITY        ERASE                                   # PRIORITY OF PRESENT JOB AND WORK AREA.

                ERASE           +71D                    # SEVEN SETS OF 12 REGISTERS EACH.

# P27  (UPDATE PROGRAM ) STORAGE.                                       (26D)

UPVERBSV        ERASE                                   # B(1) UPDATE VERB ATTEMPTED.
UPTEMP          ERASE           +24D                    # B(1)TMP SCRATCH
INTWAK1Q        EQUALS          UPTEMP                  #     (BORROWS UPTEMP REGISTERS)
# RETAIN THE ORDER OF COMPNUMB THRU UPBUFF +19D FOR DOWNLINK PURPOSES.
COMPNUMB        EQUALS          UPTEMP          +1      # B(1)TMP NUMBER OF ITEMS TO BE UPLINKED
UPOLDMOD        EQUALS          COMPNUMB        +1      # B(1)TMP INTERRUPTED PROGRAM MM
UPVERB          EQUALS          UPOLDMOD        +1      # B(1)TMP VERB NUMBER
UPCOUNT         EQUALS          UPVERB          +1      # B(1)TMP UPBUFF INDEX
UPBUFF          EQUALS          UPCOUNT         +1      # B(20D)
#

#          DOWNLINK STORAGE.                                            (28D)

DNLSTADR        EQUALS          DNLSTCOD

DNLSTCOD        ERASE                                   # B(1)PRM DOWNLIINK LIST CODE
DUMPCNT         ERASE                                   # B(1)
LDATALST        ERASE           +25D                    # (26D)
DNTMGOTO        EQUALS          LDATALST        +1      # B(1)
TMINDEX         EQUALS          DNTMGOTO        +1      # B(1)
DUMPLOC         EQUALS          TMINDEX                 # CONTAINS ECADR OF AGC DP WORD BEING DUMP
                                                        # ED AND COUNT OF COMPLETE DUMPS ALREADY S
                                                        # ENT.
DNQ             EQUALS          TMINDEX         +1      # B(1)
DNTMBUFF        EQUALS          DNQ             +1      # B(22)PRM DOWNLINK SNAPSHOT BUFFER

#          UNSWITCHED FOR DISPLAY INTERFACE ROUTINES.                   (10D) FIVE MORE IN EBANK 2

RESTREG         ERASE                                   # B(1)PRM FOR DISPLAY RESTARTS
NVWORD          ERASE
MARKNV          ERASE
NVSAVE          ERASE
#                 (RETAIN THE ORDER OF CADRFLSH TO FAILREG +2 FOR DOWNLINK PURPOSES)
CADRFLSH        ERASE
CADRMARK        ERASE
TEMPFLSH        ERASE
FAILREG         ERASE           +2                      # B(3)PRM 3 ALARM CODE REGISTERS


#          VAC AREAS. -BE CAREFUL OF PLACEMENT-                         (220D)

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

#          WAITLIST REPEAT FLAG.                                        (1D)

RUPTAGN         ERASE
KEYTEMP2        =               RUPTAGN                 # TEMP FOR KEYRUPT, UPRUPT
#


#          STARALIGN ERASABLES.                                         (13D)

STARCODE        ERASE                                   # (1)
AOTCODE         =               STARCODE
STARALGN        ERASE           +11D
SINCDU          =               STARALGN
COSCDU          =               STARALGN        +6

SINCDUX         =               SINCDU          +4
SINCDUY         =               SINCDU
SINCDUZ         =               SINCDU          +2
COSCDUX         =               COSCDU          +4
COSCDUY         =               COSCDU
COSCDUZ         =               COSCDU          +2


#          PHASE TABLE AND RESTART COUNTERS.                            (12D)

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

#          A**SR*T STORAGE.                                             (6D)

CDUSPOT         ERASE           +5                      # B(6)

CDUSPOTY        =               CDUSPOT
CDUSPOTZ        =               CDUSPOT         +2
CDUSPOTX        =               CDUSPOT         +4

# INTSTALL-ERASTALL FLAG    (1D)
RASFLAG         ERASE

#          VERB 37 STORAGE.                                             (2D)

MINDEX          ERASE                                   # B(1)TMP INDEX FOR MAJOR MODE
MMNUMBER        ERASE                                   # B(1)TMP MAJOR MODE REQUESTED BY V37

# PINBALL INTERRUPT ACTION.                                             (1D)

DSPCNT          ERASE                                   # B(1)PRM COUNTER FOR DSPOUT.

# PINBALL EXECUTIVE ACTION                                              (44D)

DSPCOUNT        ERASE                                   # DISPLAY POSITION INDICATOR.
DECBRNCH        ERASE                                   # +DEC, -DEC, OCT INDICATOR
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
MONSAVE1        ERASE                                   # NOUNCADR FOR MONITOR(MATBS) =MONSAVE +1
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
DSPTEM2         ERASE           +2                      # BUFFER STORAGE AREA 2 (MOSTLY FOR DEG)

DSPTEMX         EQUALS          DSPTEM2         +1      # B(2) S-S DISPLAY BUFFER FOR EXT. VERBS
NORMTEM1        EQUALS          DSPTEM1                 # B(3)DSP NORMAL DISPLAY REGISTERS.
#

# INCORP STORAGE: R22 (N29)    (SHARES WITH PREVIOUS SECTION)         (4D)

R22DISP         EQUALS          DSPTEM1                 # I(4) N49 DISPLAY OF DELTA R AND DELTA V
#

#          TBASES AND PHSPRDT S.                                        (12D)

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

#          UNSWITCHED FOR DISPLAY INTERFACE ROUTINES.                   (6D)

EBANKSAV        ERASE
MARKEBAN        ERASE
EBANKTEM        ERASE
MARK2PAC        ERASE
R1SAVE          ERASE


#          IMU COMPENSATION UNSWITCHED ERASABLE.                        (1D)

1/PIPADT        ERASE
#

#          SINGLE PRECISION SUBROUTINE TEMPORARIES.                     (2D)

#                                                              SPSIN, SPCOS, SPROOT VARIABLES.
#                                                              DO NOT SHARE. THESE ARE USED BY DAPS IN INTERRUPT
#                                                              AND CURRENTLY ARE NOT PROTECTED. IF OTHER USERS
#                                                              MATERIALIZE, THEN THIS CAN BE CHANGED.

HALFY           ERASE
ROOTRET         ERASE
SQRARG          ERASE
TEMK            EQUALS          HALFY
SQ              EQUALS          ROOTRET
#

#          UNSWITCHED RADAR ERASABLE                                    (13D)

RADMODES        ERASE
DAPBOOLS        ERASE
SAMPLIM         ERASE
SAMPLSUM        ERASE           +1
OPTYHOLD        ERASE           +1
TIMEHOLD        ERASE           +1
RRTARGET        EQUALS          SAMPLSUM                # HALF U IT VECTOR IN SM OR NB AXES.
TANG            ERASE           +1                      # DESIRE TRUNNION AND SHAFT ANGLES.
MODEA           EQUALS          TANG
MODEB           ERASE           +1                      # DODES LOBBERS TANG +2.
NSAMP           EQUALS          MODEB
DESRET          ERASE
OLDATAGD        EQUALS          DESRET                  # USED I  DATA READING ROUTINES.
DESCOUNT        ERASE

#          ******   P22   ******                                        (6D)

RSUBC           EQUALS          RRTARGET                # I(6)S-S  CSM POSITION VECTOR

#          UNSWITCHED FOR ORBIT INTEGRATION.                            (21D)

TDEC            ERASE           +20D                    # I(2)
COLREG          EQUALS          TDEC            +2      # I(1)
LAT             EQUALS          COLREG          +1      # I(2)
LONG            EQUALS          LAT             +2      # I(2)
ALT             EQUALS          LONG            +2      # I(2)
YV              EQUALS          ALT             +2      # I(6)
ZV              EQUALS          YV              +6      # I(6)
#

#          MISCELLANEOUS UNSWITCHED.                                    (20D)

UNUSED2         ERASE           +5

P40/RET         ERASE                                   # (WILL BE PUT IN E6 WHEN THERE IS ROOM)
GENRET          ERASE                                   # B(1)  R61 RETURN CADR.
OPTION1         ERASE                                   # B(1)   NOUN 06 USES THIS
OPTION2         ERASE                                   # B(1)   NOUN 06 USES THIS
OPTION3         ERASE                                   # B(1)  NOUN 06 USES THIS
LONGCADR        ERASE           +1                      # B(2)  LONGCALL REGISTER
LONGBASE        ERASE           +1
LONGTIME        ERASE           +1                      # B(2)    LONGCALL REGISTER
NVWORD1         ERASE
CDUTEMPX        ERASE                                   # B(1)TMP
CDUTEMPY        ERASE                                   # B(1)TMP
CDUTEMPZ        ERASE                                   # B(1)TMP
PIPATMPX        ERASE                                   # B(1)TMP
PIPATMPY        ERASE                                   # B(1)TMP
PIPATMPZ        ERASE                                   # B(1)TMP

DISPDEX         ERASE                                   # B(1)
TEMPR60         ERASE                                   # B(1)
PRIOTIME        ERASE                                   # B(1)

UNUSED5         ERASE


# STANDBY VERB ERASABLES.  REDOCTR BEFORE THETADS.                      (14D)

TIME2SAV        ERASE           +1
SCALSAVE        ERASE           +1
REDOCTR         ERASE                                   # CONTAINS NUMBER OF RESTARTS
THETAD          ERASE           +2
CPHI            =               THETAD                  # O   DESIRED GIMBAL ANGLES
CTHETA          =               THETAD          +1      # I   FOR
CPSI            =               THETAD          +2      # M   MANEUVER.
DELV            ERASE           +5
DELVX           =               DELV
DELVY           =               DELV            +2
DELVZ           =               DELV            +4
#

#          SPECIAL DEFINITION FOR SYSTEM TEST ERASABLE PGMS.            (2D)

EBUF2           EQUALS          UPTEMP                  # B(2) FOR EXCLUSIVE USE OF SYSTEM TEST
#

#          PERM STATE VECTORS FOR BOOST AND DOWNLINK-WHOLE MISSION-     (14D)

RN              ERASE           +5                      # B(6)PRM
VN              ERASE           +5                      # B(6)PRM
PIPTIME         ERASE           +1                      # B(2)PRM  (MUST BE FOLLOWED BY GDT/2)


#          SERVICER   -MUST FOLLOW PIPTIME-                             (22D)

GDT/2           ERASE           +22D                    # B(6)TMP (MUST FOLLOW PIPTIME)
MASS            EQUALS          GDT/2           +6      # B(2)
WEIGHT/G        =               MASS
ABDELV          EQUALS          MASS            +2      # ALCMANU STORAGE)
/AF/            EQUALS          ABDELV          +2      # (6)
DVTHRSH1        EQUALS          /AF/            +2      # (1)
DVTHRUSH        =               TIME2SAV
AUXFLAG         =               DVTHRUSH        +1
AVEGEXIT        EQUALS          DVTHRSH1        +1      #  (2)
AVGEXIT         =               AVEGEXIT
TEMX            EQUALS          AVEGEXIT        +2      #  (1)
TEMY            EQUALS          TEMX            +1      #  (1)
TEMZ            EQUALS          TEMY            +1      #  (1)
PIPCTR          EQUALS          TEMZ            +1      # B(1)
STOPDVC         EQUALS          PIPCTR          +1      # B(1)
PIPAGE          EQUALS          STOPDVC         +1      # B(1)
OUTROUTE        EQUALS          PIPAGE          +1      # B(1)
LRSTAT          EQUALS          OUTROUTE        +1      # B(1)

#

#          PERMANENT LEM DAP STORAGE.                                   (12D)

CH5MASK         ERASE                                   # B(1)PRM
CH6MASK         ERASE                                   # B(1)PRM JET FAILURE MASK.
DTHETASM        ERASE           +5                      #  (6)
SPNDX           ERASE                                   # B(1)
RCSFLAGS        ERASE                                   # AUTOPILOT FLAG WORD
                                                        # BIT ASSIGNMENTS:
                                                        #  1) ALTERYZ SWITCH  (ZEROOR1)
                                                        #  2) NEEDLER SWITCH
                                                        #  3) NEEDLER SWITCH
                                                        #  4) NEEDLER SWITCH
                                                        #  5) NEEDLER SWITCH
                                                        #  9) JUST-IN-DETENT SWITCH
                                                        # 10) PBIT - MANUAL CONTROL SWITCH
                                                        # 11) QRBIT - MANUAL CONTROL SWITCH
                                                        # 12) PSKIP CONTROL (PJUMPADR)
                                                        # 13) 1/ACCJOB CONTROL (ACCSET)
T5ADR           ERASE           +1                      # GENADR OF NEXT LM DAP T5RUPT. * 2CADR *
                                                        # BBCON  OF NEXT LM DAP T5RUPT.   2CADR


#          RCS FAILURE MONITOR STORAGE.                                  (1)

PVALVEST        ERASE                                   # B(1)PRM


#          KALCMANU/DAP INTERFACE.                                      (3D)

DELPEROR        ERASE                                   # B(1)PRM COMMAND LAGS.
DELQEROR        ERASE                                   # B(1)PRM
DELREROR        ERASE                                   # B(1)PRM


#          MODE SWITCHING ERASABLE.                                     (9D)

#     RETAIN THE ORDER OF IMODES30 AND IMODES33 FOR DOWNLINK PURPOSES.
IMODES30        ERASE                                   # B(1)
IMODES33        ERASE
MODECADR        ERASE           +2                      # B(3)PRM
IMUCADR         EQUALS          MODECADR
OPTCADR         EQUALS          MODECADR        +1
RADCADR         EQUALS          MODECADR        +2
ATTCADR         ERASE           +2                      # B(3)PRM
ATTPRIO         =               ATTCADR         +2
MARKSTAT        ERASE

#          T4RUPT ERASABLE.                                             (2D)

DSRUPTSW        ERASE
DIDFLG          ERASE                                   # (1)
FINALT          ERASE           +1                      # (MAY NOT BE REQUIRED FOR FLIGHTS).
LGYRO           ERASE                                   # (1)

#          P25 RADAR STORAGE.                                           (2D)

LASTYCMD        ERASE           +1                      # B(1)PRM  THESE ARE CALLED BY T4RUPT
LASTXCMD        EQUALS          LASTYCMD        +1      # B(1)PRM  THEY MUST BE CONTIGUOUS,Y FIRST
#


#          MEASINC                                                      (4D)

WIXA            ERASE                                   # B(1)
WIXB            ERASE                                   # B(1)
ZIXA            ERASE                                   # B(1)
ZIXB            ERASE                                   # B(1)

#          AGS DUMMY ID WORD.                                           (1D)

AGSWORD         ERASE

#          SOME MISCELLANEOUS UNSWITCHED.                               (6D)


RATEINDX        ERASE                                   #  (1)    USED BY KALCMANU
DELAYLOC        ERASE           +2
LEMMASS         ERASE                                   # KEEP CONTIGUOUS W.  CSMMASS  (1)EACH
CSMMASS         ERASE

# LESS IS MORE.

#          RENDEZVOUS AND LANDING RADAR DOWNLINK STORAGE.               (7D)

#                 (NORMALLY USED DURING P20, BUT MAY ALSO)
#                 (BE REQUIRED FOR THE V62 SPURIOUS TEST.)

#                                 (PLEASE KEEP IN THIS ORDER)

DNRRANGE        ERASE           +6                      # B(1) TMP
DNRRDOT         EQUALS          DNRRANGE        +1      # B(1)TMP
DNINDEX         EQUALS          DNRRDOT         +1      # B(1)TMP
DNLRVELX        EQUALS          DNINDEX         +1      # B(1)TMP
DNLRVELY        EQUALS          DNLRVELX        +1      # B(1)TMP
DNLRVELZ        EQUALS          DNLRVELY        +1      # B(1)TMP
DNLRALT         EQUALS          DNLRVELZ        +1      # B(1) TMP

#          INCORPORATION UNSWITCHED.                                    (1D)

W.IND           EQUALS          PIPCTR                  # B(1)


#          SUBROUTINE BALLANGS OF R60.                                  (1D)

BALLEXIT        ERASE                                   # B(1)SAVE LOCATION FOR BALLINGS SUBR EXIT

#          CRS61.1 STORAGE. -USED IN R63 (VERB 89)-                       (5D)

CPHIX           ERASE           +2                      # B(3)DSP NOUN 96 CALCULATED BY CRS61.1
#

#          NOUN 87                                                      (2D)

AZ              EQUALS          CPHIX                   # B(1)  AZ AND EL MUST BE CONTIGUOUS
EL              EQUALS          AZ              +1D     # B(1)
#


#          NOUN 29                                                      (1D)
LRFLAGS         ERASE


#          SOME LEM DAP STORAGE.                         (4D)

DAPDATR1        ERASE                                   # B(1)DSP DAP CONFIG.
TEVENT          ERASE           +1                      # B(2)DSP
DB              ERASE                                   # B(1)TMP DEAD BAND.
#

END-UE          EQUALS                                  # NEXT UNUSED UE ADDRESS


#          SELF-CHECK ASSIGNMENTS.                                      (17D)

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
SKEEP5          EQUALS          SKEEP4          +1      # B(1)
SKEEP6          EQUALS          SKEEP5          +1      # B(1)
SKEEP7          EQUALS          SKEEP6          +1      # B(1)

#                 EBANK-3 ASSIGNMENTS

                SETLOC          1400

#          WAITLIST TASK LISTS.                                         (26D)

LST1            ERASE           +7                      # B(8D)PRM DELTA T S.
LST2            ERASE           +17D                    # B(18D)PRM TASK 2CADR ADDRESSES.


#          RESTART STORAGE.                                             (2D)

RSBBQ           ERASE           +1                      # B(2)PRM SAVE BB AND Q FOR RESTARTS.

#          MORE LONGCALL STORAGE.(MUST BE IN LST1 S BANK.               (2D)

LONGEXIT        ERASE           +1                      # B(2)TMP MAY BE SELDOM OVERLAYED.


#          PHASE-CHANGE LISTS PART II.                                  (12D)

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


#          IMU COMPENSATION PARAMETERS.                                 (22D)

PBIASX          ERASE                                   # B(1)   PIPA BIAS, PIPA SCALE FACTR TERMS
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

COMMAND         EQUALS          GCOMP
CDUIND          EQUALS          GCOMP           +3


GCOMPSW         ERASE

#          STATE VECTORS FOR ORBIT INTEGRATION.                         (44D)

#                                 (DIFEQCNT THRU XKEP MUST BE IN SAME
#                                   EBANK AS RRECTCSM, RRECTLEM ETC
#                                   BECAUSE THE COPY-CYCLES (ATOPCSM,
#                                   PTOACSM ETC) ARE EXECUTED IN BASIC.
#                                     ALL OTHER REFERENCES TO THIS GROUP
#                                   ARE BY INTERPRETIVE INSTRUCTIONS.)

DIFEQCNT        ERASE           +43D                    # B(1)
#                                 (UPSVFLAG...XKEP MUST BE KEPT IN ORDER)

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

#          PERMANENT STATE VECTORS AND TIMES.                           (99D)

#          (DO NOT OVERLAY WITH ANYTHING AFTER BOOST)

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
AZO             ERASE           +1
UNITW           ERASE           +5
-AYO            EQUALS          UNITW                   #  (2)
AXO             EQUALS          UNITW           +2      #  (2)
#


#          STATE VECTORS FOR DOWNLINK.                                  (12D)

R-OTHER         ERASE           +5                      # B(6)PRM POS VECT (OTHER VECH) FOR DNLINK
V-OTHER         ERASE           +5                      # B(6)PRM VEL VECT (OTHER VECH) FOR DNLINK

T-OTHER         =               TETCSM                  #             TIME (OTHER VECH) FOR DNLINK

#          REFSMMAT.                                                    (18D)

REFSMMAT        ERASE           +17D                    # I(18D)PRM

#          UNIT R.
UNITR           ERASE           +7D


#          ACTIVE VEHICLE CENTANG.  MUST BE DISPLAYED ANYTIME (ALMOST.)  (2D)

ACTCENT         ERASE           +1                      # I(2) S-S CENTRAL ANGLE BETWEEN ACTIVE
                                                        #  VEHICLE AT TPI TIG AND TARGET VECTOR.

#          **** USED IN CONICSEX (PLAN INERT ORIENT) ****

TIMSUBO         EQUALS          TEPHEM                  # CSEC B-42 (TRIPLE PRECISION)
#

#      ***** P22  *****  (OVERLAYS LPS 20.1 STORAGE)                    (6D)
VSUBC           EQUALS          LOSVEL                  # I(6) S-S  CSM VELOCITY VECTOR
#

#          INITVEL STORAGE. ALSO USED BY P34,35,74,75,10,11 OTHERS      (8D)

RTARG           ERASE           +5                      # I(6) TARGET VECTOR
#

END-E3          EQUALS                                  # NEXT UNUSED E3 ADDRESS

#                 EBANK-4 ASSIGNMENTS

                SETLOC          2000

# E4 IS, FOR THE MOST PART RESERVED FOR PAD LOADED AND UNSHARABLE ERASE.

AMEMORY         EQUALS

#          P20 STORAGE. -PAD LOADED-                                    (6D)

WRENDPOS        ERASE                                   # B(1)PL                          KM*2(-7)
WRENDVEL        ERASE                                   # B(1)PL                    KM(-1/2)*2(11)
WSHAFT          ERASE                                   # B(1)PL                          KM*2(-7)
WTRUN           ERASE                                   # B(1)PL                          KM*2(-7)
RMAX            ERASE                                   # B(1)PL                     METERS*2(-19)
VMAX            ERASE                                   # B(1)PL                      M/CSEC*2(-7)

#          P22 STORAGE. -PAD LOADED-                                    (2D)

SHAFTVAR        ERASE                                   # B(1)PL                      RAD SQ*2(12)
TRUNVAR         ERASE                                   # B(1)PL                      RAD SQ*2(10)


#          CONISEX STORAGE.-PAD LOADED-                                 (6D)

504LM           ERASE           +5                      # I(6)MOON LIBRATION VECTOR

#          V47(R47) AGS INITIALIZATION STORAGE. -PAD LOADED-            (2D)

AGSK            ERASE           +1


#          LUNAR LANDING STORAGE. -PAD LOADED-                          (6D)

TLAND           ERASE           +1                      # I(2)  NOMINAL TIME OF LANDING
/LAND/          ERASE           +1                      # B(2) LUNAR RADIUS AT LANDING SITE
RLS             ERASE           +5                      # I(6) LANDING SITE VECTOR -MOON REF
#

#          INTEGRATION STORAGE.                                         (102D)

PBODY           ERASE           +101D                   # I(1)

ALPHAV          EQUALS          PBODY           +1      # I(6)
BETAV           EQUALS          ALPHAV          +6      # I(6)
PHIV            EQUALS          BETAV           +6      # I(6)
PSIV            EQUALS          PHIV            +6      # I(6)
FV              EQUALS          PSIV            +6      # I(6)    PERTURBING ACCELERATIONS
ALPHAM          EQUALS          FV              +6      # I(2)
BETAM           EQUALS          ALPHAM          +2      # I(2)
TAU.            EQUALS          BETAM           +2      # I(2)
DT/2            EQUALS          TAU.            +2      # I(2)
H               EQUALS          DT/2            +2      # I(2)
GMODE           EQUALS          H               +2      # I(1)
IRETURN         EQUALS          GMODE           +1      # I(1)
NORMGAM         EQUALS          IRETURN         +1      # I(1)
RPQV            EQUALS          NORMGAM         +1
ORIGEX          EQUALS          RPQV            +6      # I(1)
KEPRTN          EQUALS          ORIGEX                  # I(1)
RQVV            EQUALS          ORIGEX          +1      # I(6)
RPSV            EQUALS          RQVV            +6      # I(6)
XKEPNEW         EQUALS          RPSV            +6      # I(2)
VECTAB          EQUALS          XKEPNEW         +2      # I(36D)
VECTABND        EQUALS          VECTAB          +35D    # END MARK
#


#          THESE PROBABLY CAN SHARE MID-COURSE VARIABLES.               (6D)

VACX            EQUALS          VECTAB          +6      # I(2)
VACY            EQUALS          VACX            +2      # I(2)
VACZ            EQUALS          VACY            +2      # I(2)

#          SERVICER STORAGE  (USED BY ALL POWERED FLIGHT PROGS.)        (18D)

XNBPIP          EQUALS          VECTAB          +12D    # I(6)
YNBPIP          EQUALS          XNBPIP          +6      # I(6)
ZNBPIP          EQUALS          YNBPIP          +6      # I(6)
#

#          SOME VERB 82 STORAGE                                         (4D)

HAPOX           EQUALS          RQVV            +4      # I(2)
HPERX           EQUALS          HAPOX           +2      # I(2)
#

#          V82 STORAGE                                                  (6D)

VONE'           EQUALS          VECTAB          +30D    # I(6)TMP  NORMAL VELOCITY VONE /SQRT. MU

#          R31(V83) STORAGE. -SHARES WITH INTEGRATION STORAGE-          (28D)

BASETHV         EQUALS          RPQV                    # I(6)     BASE VEL VECTOR THIS VEH
#

BASETIME        EQUALS          RQVV                    # I(2)     TIME ASSOC WITH BASE VECS
ORIG            EQUALS          RQVV            +2      # I(1)     =0 FOR EARTH =2 FOR MOON
STATEXIT        EQUALS          RQVV            +3      # I(1)     STQ ADDRESS FOR STATEXTP
BASEOTV         EQUALS          RQVV            +4      # I(6)     BASE VEL VECTOR OTHER VEH
#

BASEOTP         EQUALS          VECTAB          +6      # I(6)     BASE POS VECTOR OTHER VEH
#

BASETHP         EQUALS          VECTAB          +30D    # I(6)     BASE POS VECTOR THIS VEH
#


#          KEPLER STORAGE. (KEPLER IS CALLED BY PRECISION INTEGRATION AND (6D)
#          CONICS)

XMODULO         ERASE           +5                      # I(2)
TMODULO         EQUALS          XMODULO         +2      # I(2)
EPSILONT        EQUALS          TMODULO         +2      # I(2)


#          VERB 83 STORAGE.                                             (18D)

RANGE           ERASE           +17D                    # I(2)DSP NOUN 54 DISTANCE TO OPTICAL SUBJ
RRATE           EQUALS          RANGE           +2      # I(2)DSP NOUN 54 RATE OF APPROACH.
RTHETA          EQUALS          RRATE           +2      # I(2)DSP NOUN 54.
RONE            EQUALS          RTHETA          +2      # I(6)TMP VECTOR STORAGE.  (SCRATCH)
VONE            EQUALS          RONE            +6      # I(6)TMP VECTOR STORAGE.  (SCRATCH)


WWPOS           =               RANGE                   # NOUN 99 (V45)
WWVEL           =               RRATE                   # NOUN 99 (V45)
#          V82 STORAGE. (CANNOT OVERLAY RONE OR VONE)                   (11D) TWO SEPARATE LOCATIONS

V82FLAGS        EQUALS          VECTAB          +6      #  (1) FOR V82 BITS.
TFF             EQUALS          V82FLAGS        +1      # I(2)
-TPER           EQUALS          TFF             +2      # I(2)
#

HPERMIN         EQUALS          RANGE                   # I(2) SET TO 300KFT OR 35KFT FOR SR30.1
RPADTEM         EQUALS          HPERMIN         +2      # I(2) PAD OR LANDING RADIUS FOR SR30.1
TSTART82        EQUALS          RPADTEM         +2      # I(2) TEMP TIME STORAGE FOR V82.
#


#          VARIOUS DISPLAY REGISTERS                                    (6D)     NOUN 84; P76

DELVOV          ERASE           +5D                     # (6)
#

#          ALIGNMENT PLANETARY-INERTIAL TRANSFORMATION STORAGE.         (18D)

#                 UNSHARED WHILE LM ON LUNAR SURFACE.

GSAV            ERASE           +17D                    # I(6)
YNBSAV          EQUALS          GSAV            +6      # I(6)
ZNBSAV          EQUALS          YNBSAV          +6      # I(6)
STARVSAV        EQUALS          ZNBSAV          +6      # I(6)
#


#          KALCMANU STORAGE. CAN OVERLAY GSAV.                          (18D)

MFS             EQUALS          GSAV                    # I(18)
MFI             EQUALS          MFS                     # I
KEL             EQUALS          MFS                     # I(18)
E01             EQUALS          MFS                     # I(6)
E02             EQUALS          E01             +6      # I(6)

#          LR VEL BEAM VECTORS.                                         (26D)
#
#          CAN OVERLAY GSAV WITH CARE, USED DURING POWERED DESCENT ONLY.

VZBEAMNB        EQUALS          GSAV                    # I(6) LR VELOCITY BEAMS IN NB COORDS.
VYBEAMNB        EQUALS          VZBEAMNB        +6      # I(6)
VXBEAMNB        EQUALS          VYBEAMNB        +6      # I(6) PRESERVE Z,Y,X ORDER.


LRVTIME         =               VXBEAMNB        +6      # B(2)     LR
LRXCDU          =               LRVTIME         +2      # B(1)     LR
LRYCDU          =               LRXCDU          +1      # B(1)     LR
LRZCDU          =               LRYCDU          +1      # B(1)     LR
PIPTEM          =               LRZCDU          +1      # B(3)     LR
#

#          P32-P35, P72-P75 STORAGE.                                    (40D)

T1TOT2          ERASE           +1                      #  (2)     TIME FROM CSI TO CDH
T2TOT3          ERASE           +1                      #  (2)
ELEV            ERASE           +1                      #  (2)
DELVLVC         ERASE           +5                      # I(6) DELTA VELOCITY - LOCAL VERTICAL COO
DELVSLV         =               DELVLVC                 # (TEMP STORAGE OF SAME VECTOR)   -RDINATE
UP1             ERASE           +5                      #  (6)
DELVEET1        ERASE           +5                      # I(6)     DV CSI IN REF
DELVEET2        ERASE           +5                      # I(6)     DV CSH IN REF
RACT1           ERASE           +5                      #  (6)     POS VEC OF ACTIVE AT CSI TIME
RACT2           ERASE           +5                      #  (6)     POS VEC OF ACTIVE AT CDH TIME
RTX1            ERASE                                   # I(1) X1  -2 FOR EARTH, -10 FOR MOON
RTX2            ERASE                                   # I(1) X2 FOR SHIFT-EARTH 0, MOON 2
RTSR1/MU        ERASE           +1                      # (2)      SQ ROOT 1/MU STORAGE
RTMU            ERASE           +1                      # (2)      MU STORAGE
#


#          (THE FOLLOWING ERASABLES OVERLAY PORTIONS OF THE PREVIOUS SECTION)

+MGA            EQUALS          T1TOT2                  #  (2) S-S + MID GIM ANGL TO DELVEET3
#

UNRM            EQUALS          UP1                     # I(6) S-S
#

DVLOS           EQUALS          RACT1                   # I(6) S-S DELTA VELOCITY,LOS COORD-DISPLA
ULOS            EQUALS          RACT2                   # I(6) S-S UNIT LINE OF SIGHT VECTOR
#

NOMTPI          EQUALS          RTSR1/MU                # (2) S-S NOMINAL TPI TIME FOR RECYCLE


#          SOME P30 STORAGE.                                            (4D)

HAPO            EQUALS          T1TOT2                  # I(2)
HPER            EQUALS          HAPO            +2      # I(2)
#


#          SOME P38-P39,P78-79 STORAGE.                                 (6D)

DELTAR          EQUALS          DVLOS                   # I(2)
DELTTIME        EQUALS          DELTAR          +2      # I(2) TIME REPRESENTATION OF DELTAR
TARGTIME        EQUALS          DELTTIME        +2      # I(2) TINT MINUS DELTTIME

TINTSOI         EQUALS          DELTAR                  # I(2) TIME OF INTERCEPT FOR SOI PHASE
#


#          THE FOLLOWING ARE ERASABLE LOADS DURING A PERFORMANCE TEST.

TRANSM1         =               WRENDPOS                # E4,1400
ALFDK           =               /LAND/


# ******* THE FOLLOWING SECTIONS OVERLAY V83 AND DISPLAY STORAGE *******


#          V47(R47)AGS INITIALIZATION PROGRAM STORAGE. (OVERLAYS V83)   (14D)

AGSBUFF         EQUALS          RANGE                   # B(14D)
AGSBUFFE        EQUALS          AGSBUFF         +13D    # ENDMARK


#          R36 OUT-OF-PLANE RENDEZVOUS DISPLAY STORAGE. (OVERLAYS V83)  (12D)

RPASS36         EQUALS          RONE                    # I(6) S-S
UNP36           EQUALS          RPASS36         +6      # I(6) S-S


#          S-BAND ANTENNA GIMBAL ANGLES. DISPLAYED BY R05(V64).(OVERLAYS V83) (10D)
#                (OPERATES DURING P00 ONLY)

ALPHASB         EQUALS          RANGE                   # B(2)DSP NOUN 51.  PITCH ANGLE.
BETASB          EQUALS          ALPHASB         +2      # B(2)DSP NOUN 51.  YAW ANGLE.
RLM             EQUALS          BETASB          +2      # I(6)S S/C POSITION VECTOR.

#          **** USED IN S-BAND ANTENNA FOR LM ****

YAWANG          EQUALS          BETASB
PITCHANG        EQUALS          ALPHASB


#          NOUN 56 DATA - COMPUTED AND DISPLAYED BY VERB 85.            (4)

RR-AZ           EQUALS          PITCHANG                # I(2) ANGLE BETWEEN LOS AND X-Z PLANE.
RR-ELEV         EQUALS          RR-AZ           +2      # I(2) ANGLE BETWEEN LOS AND Y-Z PLANE.

#          R04(V62) RADAR TEST STORAGE.                         (8D)
#          R04 IS RESTRICTED TO P00.

RSTACK          EQUALS          RANGE                   # B(8) BUFFER FOR R04 NOUNS.
#


#          INITVEL STORAGE.  ALSO USED BY P31,P34,P35,P74,P75,P10,P11,MIDGIM,S40.1 AND S40.9. (18D)

#                  (POSSIBLY RINIT & VINIT CAN OVERLAY DELVEET1 & 2 ABOVE)

RINIT           ERASE           +5                      # I(6) ACTIVE VEHICLE POSITION
VINIT           ERASE           +5                      # I(6) ACTIVE VEHICLE VELOCITY
DELLT4          ERASE           +1                      # I(2) TIME DIFFERENCE
VIPRIME         ERASE           +5                      # I(6) NEW VEL REQUIRED AT INITIAL RADIUS.

#          PADLOADED ERASABLES FOR P20/P22                              (6D)

RANGEVAR        ERASE           +1                      # I(2) RR RANGE ERROR VARIANCE
RATEVAR         ERASE           +1                      # I(2) RR RANGE-RATE ERROR VARIANCE
RVARMIN         ERASE           +2                      # I(3) MINIMUM RANGE ERROR VARIANCE
VVARMIN         ERASE           +1                      # I(2) MINIMUM RANGE-RATE ERROR VARIANCE
#

#
#          SOME R04(V62)-R77 RADAR TEST STORAGE                         (6D)

RTSTDEX         EQUALS          HAPOX                   # (1)
RTSTMAX         =               RTSTDEX         +1      # (1)
RTSTBASE        =               RTSTMAX         +1      # (1)
RTSTLOC         =               RTSTBASE        +1      # (1)
RSTKLOC         =               RTSTLOC
RSAMPDT         =               RTSTLOC         +1      # (1)
RFAILCNT        =               RSAMPDT         +1      # (1)
#

#         LPS20.1 STORAGE 

# (12D)


LMPOS           EQUALS          SAMPLSUM                # I(6)TEMP.  STORAGE FOR LM POS. VECTOR.
LMVEL           EQUALS          LOSVEL                  # I(6)TEMP.  STORAGE FOR LM VEL. VECTOR.
#

END-E4          EQUALS                                  # FIRST UNUSED LOCATION IN E4

#          EBANK-5 ASSIGNMENTS

                SETLOC          2400

#          W-MATRIX. ESSENTIALLY UNSHARABLE.            (162D)

W               ERASE           +161D
ENDW            EQUALS          W               +162D

#

# *******  OVERLAY NUMBER 1 IN EBANK 5  *******

#          SOME VARIABLES FOR SECOND DPS GUIDANCE                       (34D)

CG              =               W                       # I(18D) GUIDANCE
RANGEDSP        =               CG              +18D    # B(2)     DISPLAY
DELTAH          =               RANGEDSP        +2      # B(2)    DISPLAY
OUTOFPLN        =               DELTAH          +2      # B(2)    DISPLAY

#          ALIGNMENT/SYSTEST/CALCSMSC COMMON STORAGE.                   (36D)

XSM             EQUALS          ENDW                    # B(6)
YSM             EQUALS          XSM             +6      # B(6)
ZSM             EQUALS          YSM             +6      # B(6)

XDC             EQUALS          ZSM             +6      # B(6)
YDC             EQUALS          XDC             +6      # B(6)
ZDC             EQUALS          YDC             +6      # B(6)

XNB             =               XDC
YNB             =               YDC
ZNB             =               ZDC

#          OVERLAYS WITHIN ALIGNMENT/SYSTEST/CALCSMSC COMMON STORAGE.   (4D)

-COSB           EQUALS          XSM             +2      # (2)TMP
SINB            EQUALS          -COSB           +2      # (2)TMP

#          ALIGNMENT/SYSTEST COMMON STORAGE.                    (31D)

STARAD          EQUALS          ZDC             +6      # I(18D)TMP
STAR            EQUALS          STARAD          +18D    # I(6)
GCTR            EQUALS          STAR            +6      # B(1)
OGC             EQUALS          GCTR            +1      # I(2)
IGC             EQUALS          OGC             +2      # I(2)
MGC             EQUALS          IGC             +2      # I(2)

#          P57 ALIGNMENT (OVERLAY OF ALIGNMENT/SYSTEST COMMON STORAGE)  (12D)

GACC            =               STARAD                  #  (6) SS
GOUT            =               STARAD          +6      #  (6) SS
#

#          OVERLAYS WITHIN ALIGNMENT/SYSTEST COMMON STORAGE             (24D)

VEARTH          EQUALS          STARAD                  #  (6)TMP
VSUN            EQUALS          VEARTH          +6      #  (6)TMP
VMOON           EQUALS          VSUN            +6      #  (6)TMP
SAX             EQUALS          VMOON           +6      #  (6)TMP


#          P50'S,R50'S Q STORES.                                        (2D)

QMIN            EQUALS          MGC             +2      # B(1)TMP
QMAJ            EQUALS          QMIN            +1      # B(1)TMP
#

#        **** USED IN P50S ****   (SCATTERED OVERLAYS)
XSCI            EQUALS          STARAD
YSCI            EQUALS          XSCI            +6
ZSCI            EQUALS          YSCI
CULTRIX         EQUALS          VEARTH                  # VEARTH, VSUN, VMOON
VEC1            EQUALS          STARAD          +12D
VEC2            EQUALS          STAR
#


#          ALIGNMENT STORAGE.                                           (23D)

OGCT            EQUALS          QMAJ            +1      # I(6)
BESTI           EQUALS          OGCT            +6      # I(1)
BESTJ           EQUALS          BESTI           +1
STARIND         EQUALS          BESTJ           +1
#    RETAIN THE ORDER OF STARSAV1 TO STARSAV2 +5 FOR DOWNLINK PURPOSES.
STARSAV1        EQUALS          STARIND         +1      # I(6)
STARSAV2        EQUALS          STARSAV1        +6      # I(6)
TALIGN          EQUALS          STARSAV2        +6      # B(2) TIME OF IMU ALIGNMENT  (DOWNLINKED)
#               VEL/C     EQUALS  STARSAV2  +6            I(6)TMP  (NOT USED IN LEM)


ZPRIME          =               22D
PDA             =               22D
COSTH           =               16D
SINTH           =               18D
THETA           =               20D
STARM           =               32D

# *******  OVERLAY NUMBER 2 IN EBANK 5  *******


#          CONICS ROUTINE STORAGE.                       (85D)

DELX            EQUALS          ENDW                    # I(2)TMP
DELT            EQUALS          DELX            +2      # I(2)TMP
URRECT          EQUALS          DELT            +2      # I(6)TMP
RCNORM          EQUALS          34D                     # I(2) TMP
XPREV           EQUALS          XKEP                    # I(2)TMP
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
COGA            EQUALS          EPSILONL        +2      # I(2) COTAN OF INITIAL FLIGHT PATH ANGLE.
INDEP           EQUALS          COGA                    #      USED BY SUBROUTINE'ITERATOR'.

# *******  OVERLAY NUMBER 3 IN EBANK 5  *******

#          INCORP STORAGE.                               (18D)

ZI              EQUALS          ENDW                    # I(18)TMP

#          INCORP/L SR22.3 STORAGE.                                     (21D)

DELTAX          EQUALS          ZI              +18D    # I(18)
VARIANCE        EQUALS          DELTAX          +18D    # I(3)

#          MEASUREMENT INCORPORATION -R22- STORAGE.                     (49D)

GRP2SVQ         EQUALS          VARIANCE        +3      # I(1)TMP QSAVE FOR RESTARTS
OMEGAM1         EQUALS          GRP2SVQ         +1      # I(6)
OMEGAM2         EQUALS          OMEGAM1         +6      # I(6)
OMEGAM3         EQUALS          OMEGAM2         +6      # I(6)
HOLDW           EQUALS          OMEGAM3         +6      # I(18)
TDPOS           EQUALS          HOLDW           +18D    # I(6)
TDVEL           EQUALS          TDPOS           +6      # I(6)
#

TRIPA           EQUALS          DELTAX                  # I(3)TMP
TEMPVAR         EQUALS          TRIPA           +3      # I(3)TMP

#


#          INCORPORATION/INTEGRATION Q STORAGE.                         (1D)

EGRESS          EQUALS          TDVEL            +6     # I(1)
#


#          P30/P31 STORAGE.                                             (1D) AND ONE OVERLAY

P30EXIT         EQUALS          EGRESS          +1      # B(1)TMP
#

ORIGIN          EQUALS          P30EXIT                 # I(1)TMP  INDEX DURING INITVEL
#

#          SYSTEM TEST ERASABLES.  CAN OVERLAY W MATRIX. (127D)

# *******  OVERLAY NUMBER 0 IN EBANK 5  *******


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
SAVE            EQUALS          GENPL           +24D    # THREE  ONSEC LOC
SFCONST1        EQUALS          GENPL           +27D
TIMER           EQUALS          GENPL           +28D

DATAPL          EQUALS          GENPL           +30D
RDSP            EQUALS          GENPL                   # FIX LA ER   POSSIBLY KEEP1
MASKREG         EQUALS          GENPL           +64D
CDUNDX          EQUALS          GENPL           +66D
RESULTCT        EQUALS          GENPL           +67D
COUNTPL         EQUALS          GENPL           +70D

CDUANG          EQUALS          GENPL           +71D

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
#

END-E5          EQUALS          STARSAV2        +6      # *** FIRST FREE LOCATION IN E5***

#          EBANK-6 ASSIGNMENTS.

                SETLOC          3000

#          DAP    PAD-LOADED    DATA.                          (10D)

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

# AXIS TRANSFORMATION MATRIX - GIMBAL TO PILOT AXES:                    (5D)

M11             ERASE                                   # SCALED AT 1
M21             ERASE                                   # SCALED AT 1
M31             ERASE
M22             ERASE                                   # SCALED AT 1.
M32             ERASE                                   # SCALED AT 1.

# ANGLE MEASUREMENTS.                                                   (31D)

OMEGAP          ERASE           +4                      # BODY-AXIS ROT. RATES SCALED AT PI/4 AND
OMEGAQ          EQUALS          OMEGAP          +1      # BODY-AXIS ACCELERATIONS SCALED AT PI/8
OMEGAR          EQUALS          OMEGAP          +2
#    RETAIN THE ORDER OF ALPHAQ AND ALPHAR FOR DOWNLINK PURPOSES.
ALPHAQ          EQUALS          OMEGAP          +3
ALPHAR          EQUALS          OMEGAP          +4
OMEGAU          ERASE           +1
OMEGAV          =               OMEGAU          +1

TRAPEDP         ERASE           +5
TRAPEDQ         =               TRAPEDP         +1
TRAPEDR         =               TRAPEDP         +2
NPTRAPS         =               TRAPEDP         +3
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

SUMRATEQ        ERASE           +1                      # SUM OF UN-WEIGHTED JETRATE TERMS
SUMRATER        EQUALS          SUMRATEQ +1             # SCALED AT PI/4 RADIANS/SECOND

# OTHER VARIABLES.                                                      (5D)

OLDPMIN         ERASE                                   # THESE THREE USED IN MIN IMPULSE MODE.
OLDQRMIN        ERASE
TEMP31          EQUALS          DAPTEMP1

SAVEHAND        ERASE           +1
1/2JTSP         ERASE
PERROR          ERASE
QERROR          ERASE
RERROR          ERASE
# JET STATE CHANGE VARIABLES- TIME (TOFJTCHG),JET BITS WRITTEN NOW      (10D)
#   (JTSONNOW), AND JET BITS WRITTEN AT T6 RUPT (JTSATCHG).

NXT6ADR         ERASE
T6NEXT          ERASE           +1
T6FURTHA        ERASE           +1
NEXTP           ERASE           +2
NEXTU           =               NEXTP           +1
NEXTV           =               NEXTP           +2
-2JETLIM        ERASE           +1                      # RATE COMMAND 4-JET RATE DIFFERENCE LIMIT
-RATEDB         EQUALS          -2JETLIM        +1      # AND RATE DEADBAND FOR ASCENT OR DESCENT
ZEROOR1         ERASE

TARGETDB        EQUALS          -RATEDB                 # MAN. CONTROL TARGET DB COMPLEMENT.

#     *** Q,R AXIS ERASABLES ***                                        (3)

PBIT            EQUALS          BIT10
QRBIT           EQUALS          BIT11
UERROR          ERASE           +1                      # U,V-AXES ATT ERROR FOR RCS CONTROL LAWS
VERROR          =               UERROR          +1
RETJADR         ERASE

TEMPNUM         EQUALS          DAPTEMP4
NUMBERT         EQUALS          DAPTEMP5
ROTINDEX        EQUALS          DAPTEMP6
ROTEMP1         EQUALS          DAPTEMP1
ROTEMP2         EQUALS          DAPTEMP2
AXISCTR         ERASE
POLYTEMP        EQUALS          DAPTEMP3
SENSETYP        ERASE
ABSTJ           EQUALS          DAPTEMP1                # ABS VALUE OF JET-FIRING TIME
ABSEDOTP        EQUALS          DAPTEMP1
ANYTRANS        EQUALS          DAPTEMP1

DPSBURN         EQUALS          DAPTREG4                # USED WITH SNUFFBIT.  VERY TEMPORARY.

# TRIM GIMBAL CONTROL LAW ERASABLES:                            (11D)

GTSTEMPS        EQUALS          DAPTEMP1                # GTS IS PART OF THE JASK.
SHFTFLAG        EQUALS          GTSTEMPS        +2      # COUNT HIGH ORDER ZERO BITS FOR SHIFTING.

ININDEX         EQUALS          GTSTEMPS        +3      # INDEX FOR SHIFT LOOP.

SAVESR          EQUALS          AXISCTR                 # CANNOT BE A DAPTEMP - GTS USES THEM ALL.

SCRATCH         EQUALS          GTSTEMPS        +5      # ERASABLE FOR ROOTCYCL
HALFARG         EQUALS          GTSTEMPS        +6

K2THETA         EQUALS          GTSTEMPS                # D.P. K(2)THETA AND NEGUSUM
A2CNTRAL        EQUALS          GTSTEMPS        +2      # D.P. ALPHA(2), AT PI(2)/164 RAD/SEC(2)
KCENTRAL        EQUALS          GTSTEMPS        +4      # S.P. K FROM KQ OR KR, AT PI/2(8)
OMEGA.K         EQUALS          KCENTRAL                # D.P. OMEGA*K   OVERLAYS K AND K(2)
K2CNTRAL        EQUALS          GTSTEMPS        +5      # S.P. K(2) FROM Q OR R, AT PI(2)/2(16)
WCENTRAL        EQUALS          GTSTEMPS        +6      # S.P. OMEGA, AT PI/4 RAD/SEC
ACENTRAL        EQUALS          GTSTEMPS        +7      # S.P. ALPHA, AT PI/8 RAD/SEC(2)
DEL             EQUALS          GTSTEMPS        +8D     # S.P. SGN FUNCTION VALUE

QRCNTR          EQUALS          GTSTEMPS        +9D     # INDEX FOR GTS LOOP THROUGH Q,R AXES.

FUNCTION        ERASE           +1                      # D.P. WORD FOR DRIVE FUNCTION

SCRATCHX        ERASE           +2                      # SCRATCH AREA FOR DVOVSUB ROUTINE.
SCRATCHY        EQUALS          SCRATCHX        +1
SCRATCHZ        EQUALS          SCRATCHX        +2

NEGUQ           ERASE           +2                      # NEGATIVE OF Q-AXIS GIMBAL DRIVE
#                               NEGUQ +1               DEFINED AND USED ELSEWHERE
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

#


# TORQUE VECTOR RECONSTRUCTION VARIABLES:                               (18D)

JETRATE         EQUALS          DAPTREG1
JETRATEQ        EQUALS          JETRATE         +1      # THE LAST CONTROL SAMPLE PERIOD OF 100 MS
JETRATER        EQUALS          JETRATE         +2      # SCALED AT PI/4 RADIANS/SECOND


NO.PJETS        ERASE           +2
NO.UJETS        =               NO.PJETS        +1
NO.VJETS        =               NO.UJETS        +1
TJP             ERASE           +2
TJU             =               TJP             +1
TJV             =               TJP             +2

L,PVT-CG        ERASE
1JACC           ERASE           +4                      # ACCELERATIONS DUE TO 1 JET TORQUING
1JACCQ          EQUALS          1JACC           +1      # SCALED AT PI/4 RADIANS/SECOND
1JACCR          EQUALS          1JACC           +2
1JACCU          EQUALS          1JACC           +3      # FOR U,V-AXES THE SCALE FACTOR IS  DIFF:
1JACCV          EQUALS          1JACC           +4      # SCALED AT PI/2 RADIANS/SECOND (FOR ASC)

PJUMPADR        ERASE

# ASCENT VARIABLES:                                                     (10D)

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

# FOR TJET LAW SUBROUTINE:                                              (TEMPS ONLY)

#NUMBERT        EQUALS          DAPTEMP5                  DEFINED IN QRAXIS.
EDOTSQ          EQUALS          DAPTEMP1
ROTSENSE        EQUALS          DAPTEMP2
FIREFCT         EQUALS          DAPTEMP3                # LOOKED AT BY PAXIS.
TTOAXIS         EQUALS          DAPTEMP4
ADRSDIF2        EQUALS          DAPTEMP6
HOLDQ           EQUALS          DAPTREG1
ADRSDIF1        EQUALS          DAPTREG2
HH              EQUALS          DAPTREG3                # DOUBLE PRECISION

# HH +1         EQUALS          DAPTREG4
E               ERASE           +1
EDOT            EQUALS          E               +1

# INPUT TO TJET LAW (PERMANENT ERASABLES).                              (48D)

TJETU           =               TJU                     # EQUATE NAMES.  INDEXED BY -1, 0, +1.
BLOCKTOP        ERASE           +47D
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
ZONE3LIM        =               BLOCKTOP        +7      # HEIGHT OF MINIMUM IMPULSE ZONE(AT 4 SEC)

#

# VARIABLES FOR GTS-QRAXIS CONTROL EXCHANGE.                            (4)

ALLOWGTS        ERASE                                   # INSERT INTO UNUSED LOCATION
COTROLER        ERASE                                   # INDICATES WHICH CONTROL SYSTEM TO USE.
QGIMTIMR        ERASE           +2                      # Q-GIMBAL DRIVE ITMER, DECISECONDS.
INGTS           EQUALS          QGIMTIMR        +1      # INDICATOR OF CURRENT GTS CONTROL.
RGIMTIMR        EQUALS          QGIMTIMR        +2      # R-GIMBAL DRIVE TIMER, DECISECONDS.

# PLEASE RETAIN THE ORDER OF CDUXD THRU CDUZD FOR DOWNLINK PURPOSES.

#          KALCMANU:DAP INTERFACE.                                      (9D)

ACCSET          ERASE                                   # INDICATES 1/ACCS HAS BEEN SET UP
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

# KALCMANU STORAGE.                                                     (24D)

MIS             ERASE           +23D                    # I(18D)
COF             EQUALS          MIS             +18D    # I(6)


#          KALCMANU STORAGE.                                             (33D)

BCDU            ERASE           +30D                    # B(3)
KSPNDX          EQUALS          BCDU            +3      # B(1)
KDPNDX          EQUALS          KSPNDX          +1      # B(1)

TMIS            EQUALS          KDPNDX          +1      # I(18) MUST BE IN SAME BANK AS RCS DAP
COFSKEW         EQUALS          TMIS            +18D    # I(6)  MUST BE IN SAME BANK AS RCS DAP
CAM             EQUALS          COFSKEW         +6      # I(2)  MUST BE IN SAME BANK AS RCS DAP


AM              ERASE           +1                      # I(2) THIS WAS ONCE IN E5 OVERLAYING OGC
#

# FIRST-ORDER OVERLAYS IN KALCMANU                                      (25D)

KV1             EQUALS          TMIS                    # I(6)
MFISYM          EQUALS          TMIS                    # I
TMFI            EQUALS          TMIS                    # I
NCDU            EQUALS          TMIS                    # B
NEXTIME         EQUALS          TMIS            +3      # B
TTEMP           EQUALS          TMIS            +4      # B
KV2             EQUALS          TMIS            +6      # I(6)
BIASTEMP        EQUALS          TMIS            +6      # B
KV3             EQUALS          TMIS            +12D    # I(6)
OGF             EQUALS          TMIS            +12D    # I

BRATE           EQUALS          COFSKEW                 # B
IG              EQUALS          COFSKEW                 # I

TM              EQUALS          CAM                     # B

# SECOND-ORDER OVERLAYS IN KALCMANU                                     (24D)

K1              =               KV1
K2              =               KV2
K3              =               KV3
P21             EQUALS          KV1                     # I(2)
D21             EQUALS          KV1             +2      # I(2)
G21             EQUALS          KV1             +4      # I(2)
C2SQP           EQUALS          KV2                     # I(2)
C2SQM           EQUALS          KV2             +2      # I(2)
C2PP            EQUALS          KV2             +4      # I(2)
C2MP            EQUALS          KV3                     # I(2)
C1PP            EQUALS          KV3             +2      # I(2)
C1MP            EQUALS          KV3             +4      # I(2)

VECQTEMP        =               COFSKEW

DCDU            =               CDUXD
DELDCDU         =               DELCDUX
DELDCDU1        =               DELCDUY
DELDCDU2        =               DELCDUZ


# *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *

# STORAGE FOR FINDCDUW

#          OVERLAYING KALCMANU STORAGE:                                 (26D)

ECDUW           EQUALS          MIS
ECDUWUSR        EQUALS          ECDUW                   # B(1)TMP
QCDUWUSR        EQUALS          ECDUWUSR        +1      # I(1)TMP
NDXCDUW         EQUALS          QCDUWUSR        +1      # B(1)TMP
FLAGOODW        EQUALS          NDXCDUW         +1      # B(1)TMP
UNFC/2          EQUALS          FLAGOODW        +1      # I(6)IN
UNWC/2          EQUALS          UNFC/2          +6      # I(6)IN
UNFV/2          EQUALS          UNWC/2          +6      # I(6) S-S
UNFVX/2         =               UNFV/2
UNFVY/2         =               UNFV/2          +2
UNFVZ/2         =               UNFV/2          +4
-DELGMB         EQUALS          UNFV/2          +6      # B(3)TMP
#
#          DEFINED IN THE WORK AREA:                                    (18D)

UNX/2           =               0
UNY/2           =               6
UNZ/2           =               14
#
# END OF FINDCDUW ERASABLES

# *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *

# THE FOLLOWING ARE THE DAP REPLACEMENTS FOR THE ITEMPS AND RUPTREGS,NEEDED BECAUSE DAP IS NOW A TOB,JASK,JAB,TOSK
# ...ANYWAY, THE DAP CAN NOW BE INTERRUPTED.                            (16D)

DAPTEMP1        ERASE           +15D
DAPTEMP2        EQUALS          DAPTEMP1        +1
DAPTEMP3        EQUALS          DAPTEMP1        +2
DAPTEMP4        EQUALS          DAPTEMP1        +3
DAPTEMP5        EQUALS          DAPTEMP1        +4
DAPTEMP6        EQUALS          DAPTEMP1        +5
DAPTREG1        EQUALS          DAPTEMP1        +6
DAPTREG2        EQUALS          DAPTEMP1        +7
DAPTREG3        EQUALS          DAPTEMP1        +8D

DAPTREG4        EQUALS          DAPTEMP1        +9D
DAPTREG5        EQUALS          DAPTEMP1        +10D
DAPTREG6        EQUALS          DAPTEMP1        +11D

DAPARUPT        EQUALS          DAPTEMP1        +10D
DAPLRUPT        EQUALS          DAPARUPT        +1
DAPBQRPT        EQUALS          DAPARUPT        +2
DAPZRUPT        EQUALS          DAPARUPT        +4

                                                        # (DAPZRUPT IS ALSO JASK-IN-PROGRESS FLAG)
#


#          NEEDLER(ATTITUDE ERROR EIGHT BALL DISPLAY) STORAGE.          (6D)

T5TEMP          EQUALS          ITEMP1
DINDX           EQUALS          ITEMP3
AK              ERASE           +2                      # NEEDLER ATTITUDE INPUTS, SCALED AT 180
AK1             EQUALS          AK              +1      # DEGREES.  P,Q,R AXES IN AK,AK1,AK2.
AK2             EQUALS          AK              +2

EDRIVEX         ERASE           +2                      # NEEDLER DISPLAY REGS AT 1800 DEGREES.
EDRIVEY         EQUALS          EDRIVEX         +1      # SO THAT 384 BITS REPRESENT 42 3/16 DEG.
EDRIVEZ         EQUALS          EDRIVEX         +2


#          INITVEL STORAGE.  ALSO USED BY P31,P34,P35,P74,P75,S40.1 AND DOWNLINKED. (6D)

DELVEET3        ERASE           +5                      # I(6)     DELTA V IN INERTIAL


#          P32-P33 STORAGE.                                             (2)

TCDH            ERASE           +1                      #  I(2) T2 CDH TIME IN C.S. ALSO DWNLINKED
#

END-E6          EQUALS          RTX2                    # LAST LOCATION USED IN E6.

#                 EBANK-7 ASSIGNMENTS

                SETLOC          3400


#          P35 CONSTANTS.         -PAD LOADED-                          (4D)

ATIGINC         ERASE           +1                      # B(2)PL  *MUST BE AT 1400 FOR SYSTEMSTEST
PTIGINC         ERASE           +1                      # B(2)PL


#          AOTMARK STORAGE.       -PAD LOADED-                          (6D)

AOTAZ           ERASE           +2                      # B(3)PL
AOTEL           ERASE           +2                      # B(3)PL


#          LANDING RADAR.         -PAD LOADED-                          (10D)

LRALPHA         ERASE           +4                      # B(1)    POS1 X ROTATION      * MUST *
LRBETA1         EQUALS          LRALPHA         +1      # B(1)    POS1 Y ROTATION    *  BE  *
LRALPHA2        EQUALS          LRBETA1         +1      # B(1)    POS2 X ROTATION    *  IN  *
LRBETA2         EQUALS          LRALPHA2        +1      # B(1)    POS2 Y ROTATION    * ORDER *
HANGLE          EQUALS          LRBETA2         +1      # B(1)

#          THROTTLE STORAGE.      -PAD LOADED-                          (1D)

PIF             ERASE                                   # B(2)   THROTTLE
ZOOMTDP         ERASE           +1
ZOOMTIME        EQUALS          ZOOMTDP         +1      # B(1)PL TIME OF DPS THROTTLE-UP COMMAND

#          LANDING RADAR      -PAD LOADED-                              (2D)

#          P30-P40 INTERFACE UNSHARED.                   (2D)

TIG(AS)         ERASE           +1                      # B(2)
TIG             ERASE           +1                      # B(2)

#          P30-P40 INTERFACE UNSHARED.                                  (3D)

TTOGO           ERASE           +1                      # B(2)
TFI             EQUALS          TTOGO
WHICH           ERASE                                   # B(1)
#

#          LPS20.1 STORAGE     -ALL ARE PRM -                           (9D)

LS21X           ERASE                                   # I(1)
UNUSED8         ERASE
LOSCOUNT        ERASE                                   # B(1)
LOSVEL          ERASE           +5                      # I(6)
MLOSV           ERASE           +1                      # I(2) MAGNITUDE OF LOS, METERS B-29
#


#          L SR22.3 (RENDEZVOUS NAVIGATION) STORAGE.                    (4D)

#    RETAIN THE ORDER OF AIG TO TRKMKCNT FOR DOWNLINK PURPOSES.
AIG             ERASE                                   # B(1)OUT  GIMGAL ANGLES
AMG             ERASE                                   # B(1)OUT  (MUST BE
AOG             ERASE                                   # B(1)OUT   CONSECUTIVE)

TRKMKCNT        ERASE                                   # B(1)TMP  TEMPORARY MARK STORAGE.
MARKCTR         =               TRKMKCNT


#          P32-P35, P72-P75 STORAGE.  -PERMANENT-                       (6)

NORMEX          ERASE                                   # B(1) PRM SAVE FOR Q
QSAVED          ERASE                                   # B(1) PRM SAVE FOR Q
RTRN            ERASE                                   # B(1) PRM SAVE FOR Q
NN              ERASE           +1                      # B(2)
SUBEXIT         ERASE                                   # B(1) PRM SAVE Q


E7OVERLA        EQUALS                                  #          START OF E7 OVERLAYS

WHOCARES        EQUALS          E7OVERLA                # A DUMMY FOR E-BANK INSENSITIVE 2CADRS.

# *******  OVERLAY NUMBER 0 IN EBANK 7  *******
#


# RENDEZVOUS GUIDANCE STORAGE -P32....P35-                              (89D)

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
DELDV           ERASE           +1D
DELVMID         EQUALS          DELVTPI
DIFFALT         ERASE           +1D                     # ALT DIFFERENCE AT CDH
POSTCSI         ERASE           +1                      # PERIGEE ALTITUDE AFTER CSI MANEUVER
POSTCDH         ERASE           +1                      # PERIGEE ALTITUDE AFTER CDH MANEUVER
POSTTPI         ERASE           +1                      # PERIGEE ALTITUDE AFTER TPI MANEUVER
LOOPCT          EQUALS          POSTTPI                 # CSI NEWTON ITERATION COUNTER
HAFPA1          EQUALS          POSTCDH                 # HALF PERIOD
GAMPREV         ERASE           +1                      # PREVIOUS GAMMA
DVPREV          EQUALS          DELVTPI                 # PREVIOUS DELVCSI
CSIALRM         ERASE           +1                      # FIRST SOLUTION ALARM
VERBNOUN        ERASE
TITER           EQUALS          CSIALRM                 # ITERATION COUNTER
RDOTV           ERASE           +1
VAPREC          EQUALS          VPASS1                  # I(6) S-S PREC VEC FOR NOM TPI TIME(ACT V
RAPREC          EQUALS          RPASS1                  # I(6) S-S PREC VEC FOR NOM TPI TIME(ACT V
VPPREC          EQUALS          VPASS2                  # I(6) S-S PREC VEC FOR NOM TPI TIME(PASS
RPPREC          EQUALS          RPASS2                  # I(6) S-S PREC VEC FOR NOM TPI TIME(PASS
DELEL           EQUALS          DELVTPI                 # I(2) S-S
DELTEE          EQUALS          DELDV                   # I(2)S-S
SECMAX          EQUALS          DELVCSI                 # I(2) S-S MAX STOP SIZE FOR ROUTINE
DELTEEO         EQUALS          POSTTPI                 # I(2) S-S BACK VALUES OF DELTA TIME
CENTANG         ERASE           +1                      # I(2) S-S CENTRAL ANGLE COVERED(TPI-TPF)

#         P34-P35 STORAGE.  DOWNLINKED.

# (2D)

DELVTPF         EQUALS          DELDV                   # I(2) DELTA V FOR TPF

#          SOME P47 STORAGE                                             (6D)

DELVIMU         ERASE           +5                      # I(6)DSP NOUN 83 FOR P47 DELTA V (IMU)
#

#          P30-P40 COMMON STORAGE.                                      (3D)

TPASS4          ERASE           +1                      # INTERCEPT TIME
QTEMP           ERASE                                   # I(1)TMP COMMON RETURN SAVE REGISTER.



#          P32,33,34 STORAGE.                                            (6D)

TCSI            ERASE           +1                      # B(2) TMP CSI TIME IN CENTISECONDS
TTPI            ERASE           +1                      # B(2) TMP TPI TIME IN CENTISECONDS
TTPI0           ERASE           +1                      # B(2) TMP TTPI STORAGE FOR RECYCLE


#          P30,P40 INTERFACE.                                            (21D)

RTIG            ERASE           +19D                    # I(6)TMP
VTIG            EQUALS          RTIG            +6      # I(6)TMP
DELVSIN         EQUALS          VTIG            +6      # I(6)TMP
DELVSAB         EQUALS          DELVSIN         +6      # I(2)TMP
VGDISP          =               DELVSAB


QTEMP1          ERASE                                   # I(1)TMP HOLDS RETURN.
RGEXIT          EQUALS          QTEMP1                  # SAVE Q
SAVQR52         EQUALS          QTEMP1


#          INITVEL STORAGE.  (IN OVERLAY 0 AND OVERLAY 1.                (2D)
#                 (CALLS LAMBERT, CONIC SUBROUTINES)

VTPRIME         EQUALS          VACT4                   # TOTAL VELOCITY AT DESIRED RADIUS
ITCTR           EQUALS          RDOTV                   # ITERATION COUNTER
COZY4           ERASE           +1                      # COS OF ANGLE WHEN ROTATION STARTS
X1INPUT         EQUALS          DELDV                   # X1 TEMP STORAGE
INTIME          EQUALS          GAMPREV                 # TIME OF RINIT
#


#          PERIAPO STORAGE. (2D)                                 (2D)

XXXALT          ERASE           +1                      # RADIUS TO LAUNCH PAD OR LANDING SIGHT

END-IN/M        EQUALS          XXXALT          +2      # NEXT AVAIL ERASABLE AFTER INITVEL/MIDGIM

#          S40.1 STORAGE.                                               (19D)

BDT             ERASE           +18D                    # I(6) IN
UT              EQUALS          BDT             +6      # I(6)OUT THRUST DIRECTION
VGTIG           EQUALS          UT              +6      # I(6)OUT
VGPREV          =               VGTIG
#         S40.9 STORAGE.                                                (16D)

VG              ERASE           +15D                    # I(6)TMP
VRPREV          EQUALS          VG              +6      # I(6)TMP
TNIT            EQUALS          VRPREV          +6      # I(2)TMP TIME SIMCE LAST CALL TO S40.9
TNITPREV        EQUALS          TNIT            +2      # I(2)TMP PREVIOUS INIT.


#         P40 STORAGE.                                                  (6D)

#              F,MDOT,AND TDECAY MUST BE CONTIGUOUS FOR VLOAD.
F               ERASE           +5                      # I(2)TMP  S40.1 GENERATES THIS FOR S40.3
MDOT            EQUALS          F               +2      # I(2)TMP MASS CHNG RATE, KG/CS AT 2**3.
TDECAY          EQUALS          MDOT            +2      # I(2)IN  DELTA-T TAILOFF, (2**28)CS.
#


#          MIDTOAV1(2) STORAGE.  (CALLED BY P40,P41,P42)                (1D)

IRETURN1        ERASE                                   # B(1)     RETURN FROM MIDTOAV1 AND 2


# ******* OVERLAY  NUMBER 1 IN EBANK 7  *******
#


#          P35-P40 INTERFACE.                                           (6D)

VPASS4          EQUALS          VPASS1                  # I(6)TMP VELOCITY OF PASSIVE AT INTERCEPT


#          INITVEL OVERLAYS RENDESVOUS GUIDANCE (LISTED IN OVERLAY O)

#          SOME P38-39,P78-79 STORAGE.                                  (2D)

TINT            EQUALS          TPASS4                  # I(2) TIME OF INTERCEPT
#

#          LAT - LONG TEMPORARIES. CAN OVERLAY WITH S40.1               (3D)

ERADM           EQUALS          BDT                     # I(2)
INCORPEX        EQUALS          ERADM           +2      # I(1)


#          LRS24.1 STORAGE. (CAN SHARE WITH P30'S)                      (40D)

RLMSRCH         EQUALS          INCORPEX        +1      # I(6) TMP LM POSITION VECTOR
VXRCM           EQUALS          RLMSRCH         +6      # I(6)    CM V X R VECTOR
LOSDESRD        EQUALS          VXRCM           +6      # I(6)    DESIRED LOS VECTOR
UXVECT          EQUALS          LOSDESRD        +6      # I(6)    X-AXIS SRCH PATTERN COORDS
UYVECT          EQUALS          UXVECT          +6      # I(6)    Y-AXIS SRCH PATTERN COORDS
DATAGOOD        EQUALS          UYVECT          +6      # B(1)DSP FOR R1 - ALL 1-S WHEN LOCKON
OMEGDISP        EQUALS          DATAGOOD        +1      # B(2)    ANGLE OMEGA DISPLAYED IN R2
OMEGAD          =               OMEGDISP                #         PINBALL DEFINITION.
NSRCHPNT        EQUALS          OMEGDISP        +2      # B(1)TMP SEARCH PATTERN POINT COUNTER.
SAVLEMV         EQUALS          NSRCHPNT        +1      # I(6)S-S SAVES LOSVEL


#

# ******* OVERLAY NUMBER 2 IN EBANK 7  *******
#


#          INCORP STORAGE IN E7.                                        (47D)

TX789           EQUALS          E7OVERLA                # I(6)
GAMMA           EQUALS          TX789           +6      # I(3)
OMEGA           EQUALS          GAMMA           +3      # I(18)
BVECTOR         EQUALS          OMEGA           +18D    # I(18)
DELTAQ          EQUALS          BVECTOR         +18D    # I(2)
#          AOTMARK STORAGE                                              (3D)

MARKCNTR        EQUALS          DELTAQ          +2      # I(1)
XYMARK          EQUALS          MARKCNTR        +1      # B(1)
MKDEX           EQUALS          XYMARK          +1      # B(1)TMP INDEX FOR AOTMARK
#

#          PLANET STORAGE.                                              (8D)

PLANVEC         EQUALS          MKDEX           +1      # (6) REFER VECTOR OF PLANET
TSIGHT          EQUALS          PLANVEC         +6      # (2) TIME OF MARK OR EST TIME OF MARK
#


#          LRS22.3 STORAGE. (CAN SHARE WITH P30'S AND OVERLAY LRS24.1   (30D).

LGRET           EQUALS          INCORPEX        +1      # I(1) TMP
RDRET           EQUALS          LGRET                   # B(1)  TEMP RETURN.
IGRET           EQUALS          RDRET                   # B(1)  TEMP RETURN.
MX              EQUALS          RDRET           +1      # I(6)
MY              EQUALS          MX              +6      # I(6)
MZ              EQUALS          MY              +6      # I(6)
E0              EQUALS          MX                      # I(2)
E1              EQUALS          MX              +2      # I(2)
E2              EQUALS          MX              +4      # I(2)
E3              EQUALS          E2              +2      # I(2)
SCALSHFT        EQUALS          MZ              +6      # B(1) SCALE SHIFT FOR EARTH/MOON
RXZ             EQUALS          SCALSHFT        +1      # I(2)
ULC             EQUALS          RXZ             +2      # I(6)
SINTHETA        EQUALS          ULC             +6      # I(2)

#     ***** IN OVERLAY ONE *****

N49FLAG         EQUALS          LRS22.1X                # B(1)S    FLAG INDICATING V0649 RESPONSE
#

#          LRS22.1 STORAGE. (MUST NOT SHARE WITH P30'S)                 (13D)

#          (OUTPUTS ARE TO LRS22.3)

RDOTM           EQUALS          SINTHETA        +2      # B(2)OUT  RANGE-RATE READING
RRTRUN          EQUALS          RDOTM           +2      # B(2)OUT  RR TRUNION ANGLE
RRSHAFT         EQUALS          RRTRUN          +2      # B(2)OUT RRSHAFT ANGLE
#          RETAIN THE ORDER OF MKTIME TO RM FOR DOWNLINK PURPOSES
MKTIME          EQUALS          RRSHAFT         +2      # B(2)OUT  TIME OF RR READING
RM              EQUALS          MKTIME          +2      # I(2)OUT  RANGE READING
LRS22.1X        EQUALS          RM              +2      # B(1)TMP
RRBORSIT        EQUALS          LRS22.1X        +1      # I(6) TMP RADAR BORESIGHT VECTOR.
RDOTMSAV        EQUALS          RRBORSIT        +6      # B(2) S    RR RANGE-RATE(FPS)
#

#          LRS22.1  (SAME AS PREVIOUS SECTION) ALSO DOWNLINK FOR RR  (R29)(8D) CANNOT SHARE WITH L.A.D.

TANGNB          EQUALS          RDOTMSAV        +2      # B(2)TMP  RR GIMBAL ANGLES
#

#

#          P21 STORAGE                                                  (2D)

P21TIME         EQUALS          TANGNB          +2     # I(2)TMP
#

#          KALCMANU, VECPOINT STORAGE.  CALLED BY R63, R61, R65.         (12D)

SCAXIS          EQUALS          /AF/
POINTVSM        EQUALS          SCAXIS          +6      # I(6)
#

# *******  OVERLAY NUMBER 3 IN EBANK 7  *******
#

#          BURN PROG STORAGE.                                           (2D)

SAVET-30        EQUALS          E7OVERLA                # B(2)TMP TIG-30 RESTART
#

#          CROSS-PRODUCT STEERING ACTUAL                                (6D)
UASTEER         EQUALS          SAVET-30        +2
UDSTEER         EQUALS          LASTLADW        +3
S40EXIT         =               UDSTEER         +6
VGBODY          =               S40EXIT         +1      # B(6)OUT SET.BY S41.1 VG LEM, SC.COORDS
DELVCTL         =               VGBODY

#          SERVICER STORAGE.                                            (69D)

DVTOTAL         EQUALS          UASTEER         +6      # B(2) DISPLAY NOUN
ABDVCONV        EQUALS          DVTOTAL         +2      # I(2)
DVCNTR          EQUALS          ABDVCONV        +2      # B(1)
TGO             EQUALS          DVCNTR          +1      # B(2)
R               EQUALS          TGO             +2      # I(6)
UNITGOBL        EQUALS          R                       # I(6)
V               EQUALS          R               +6
DELVREF         EQUALS          V                       # I(6)
HCALC           EQUALS          DELVREF         +6      # B(2)     LR

ABVELINT        EQUALS          HCALC           +2      # B(2)
ABVEL           EQUALS          ABVELINT        +2      # B(2) DISPLAY
HDOTDISP        EQUALS          ABVEL           +2      # B(2) DISPLAY
TTFDISP         EQUALS          HDOTDISP        +2      # B(2) DISPLAY
#

UNIT/R/         EQUALS          TTFDISP         +2      # I(6)
#          (THE FOLLOWING SERVICER ERASABLES CAN BE SHARED WITH SECOND DPS GUIDANCE STORAGE)

RN1             EQUALS          UNIT/R/         +6      # B(6)
VN1             EQUALS          RN1             +6      # I(6)                      (IN ORDER  )
PIPTIME1        EQUALS          VN1             +6      # B(2)                      (   FOR    )
GDT1/2          EQUALS          PIPTIME1        +2      # I(6)                      (  COPY    )
MASS1           EQUALS          GDT1/2          +6      # I(2)                      (  CYCLE   )
R1S             EQUALS          MASS1           +2      # I(6)
V1S             EQUALS          R1S             +6      # I(6)

#          ALIGNMENT/S40.2.3 COMMON STORAGE.                            (18D)

XSMD            EQUALS          V1S             +6      # I(6)
YSMD            EQUALS          XSMD            +6      # I(6)
ZSMD            EQUALS          YSMD            +6      # I(6)

XSCREF          =               XSMD
YSCREF          =               YSMD

ZSCREF          =               ZSMD

END-ALIG        EQUALS          ZSMD            +6      # NEXT AVAIL ERASABLE AFTER ALIGN/S40.2,3

# *******  OVERLAY NUMBER 4 IN EBANK 7  *******
#

#          AUTO-OPTICS STORAGE.  -R52-                                  (1)

XNB1            =               WHOCARES                # THESE WHOCARES THINGS ARE REFERENCED.
YNB1            =               WHOCARES                # BUT NOT USED IN SUNDANCE
ZNB1            =               WHOCARES
#

# VARIABLES FOR SECOND DPS GUIDANCE (THE LUNAR LANDING)                 (84D)

# THESE ERASABLES MAY BE SHARED WITH CARE

OURTEMPS        =               RN1                     # OVERLAY LAST PART OF SERVICER
RGU             =               OURTEMPS                # I(6)    GUIDANCE
LANDTEMP        =               OURTEMPS        +7      # B(6)     GUIDANCE
TTF/8TMP        =               LANDTEMP        +6      # B(2)    GUIDANCE
TABLTTF         =               TTF/8TMP        +2      # B(2)    GUIDANCE
FCODD           =               TABLTTF                 # B(2)    THROTTLE
FP              =               FCODD           +2      # B(2)    THROTTLE
TPIPOLD         =               TABLTTF         +9D     # B(2)    GUIDANCE
AZINCR          =               TPIPOLD         +2      # B(2)    GUIDANCE
ELINCR          =               AZINCR          +2      # B(2)    GUIDANCE
KEEP-2          =               ELINCR          +2      # B(2)    TO PREVENT PIPTIME1 OVERLAY
/AFC/           =               TPIPOLD         +6      # B(2)    GUIDANCE AND  THROTTLE
ANGTERM         =               /AFC/           +2      # I(6) GUIDANCE
GOBLTIME        =               ANGTERM         +2      # B(2) NOMINAL TIG FOR CALC. OF GOBLATE.
#

E2DPS           EQUALS          OURPERMS
#


# THESE ERASABLES MUST NOT OVERLAY GOBLTIME OR SERVICER
PIFPSET         =               GOBLTIME        +4      # B(1)    THROTTLE
RTNHOLD         =               PIFPSET         +1      # B(1)    THROTTLE
FWEIGHT         =               RTNHOLD         +1      # B(2)    THROTTLE
PSEUDO55        =               FWEIGHT         +2      # B(1)   THROTTLE DOWNLINK
TTHROT          =               PSEUDO55        +1      # B(1)    THROTTLE
#


# THESE ERASABLES SHOULD NOT BE SHARED DURING P63, P64, P65, P66, P67

WCHPHOLD        =               VN1                     # B(1)    GUIDANCE

OURPERMS        =               TTHROT          +2      # MUSTN'T OVERLAY OURTEMPS OR SERVICER
WCHPHASE        =               OURPERMS                # B(1)    GUIDANCE
FLPASS0         =               WCHPHASE        +1      # B(1)    GUIDANCE
TARGTDEX        =               FLPASS0         +1      # B(1)    GUIDANCE
TPIP            =               TARGTDEX        +1      # B(2)
VGU             =               TPIP            +2      # B(6)    GUIDANCE
WM              =               VGU             +6      # I(6) TMP - LUNAR ROTATION VECTOR (SM)
LAND            =               WM              +6      # B(6)    GUIDANCE    CONTIGUOUS
TTF/8           =               LAND            +6      # B(2)    GUIDANCE     CONTIGUOUS
ACG             =               TTF/8           +2      # I(6) GUIDANCE
JLING           =               ACG             +6      # I(6) GUIDANCE
ELINCR1         =               JLING           +6      # B(1)    GUIDANCE
AZINCR1         =               ELINCR1         +1      # B(1)     GUIDANCE
ZERLINA         =               AZINCR1         +1      # B(1)     GUIDANCE
ELVIRA          =               ZERLINA         +1      # B(1)     GUIDANCE
FCOLD           =               ELVIRA          +1      # B(1)    THROTTLE
LRADRET         =               FCOLD           +1      # B(1)    LR
VSELECT         =               LRADRET         +1      # B(1)    LR
HBEAMNB         =               VSELECT         +1      # I(6) LANDING RADAR
VMEAS           =               HBEAMNB         +6      # B(2)    LR
HMEAS           =               VMEAS           +2      # B(2)    LR
VN2             =               HMEAS           +2      # B(6)    LR
GNUR            =               VN2                     # B(6)     LR
GNUV            =               VN2                     # B(6)     LR
LRADRET1        =               VN2                     # B(1)     LR
FUNNYDSP        =               VN2             +6      # B(2)    DISPLAY
VHORIZ          =               FUNNYDSP        +2      # I(2) DISPLAY
EOURPERM        EQUALS          VHORIZ          +2      # NEXT AVAILABLE ERASABLE AFTER OURPERMS
#

# (ERASABLES WHICH OVERLAY THE ABOVE BLOCK)

VDGVERT         =               ELINCR1                 # B(2)    P65,66
NIGNLOOP        =               ZERLINA                 # B(1)    IGNALG
NGUIDSUB        =               ELVIRA                  # B(1)    IGNALG
RODCOUNT        =               ZERLINA                 # B(1)    P66
WCHVERT         =               ELVIRA                  # B(1)    P65,66,67
FUELNEED        =               FUNNYDSP                # B(1)    DISPLAY
TREDES          =               FUNNYDSP                # B(1)    DISPLAY
LOOKANGL        =               FUNNYDSP        +1      # B(1)    DISPLAY
#

# ERASABLES CONVENIENTLY DEFINABLE IN THE WORK AREA

PROJ            =               18D                     # I(2)    GUIDANCE
UNLRB/2         =               20D                     # I(6)    GUIDANCE (DURING P64 ONLY)
UNLR/2          =               20D                     # I(6)    GUIDANCE
#

# THE END OF THE LUNAR LANDING ERASABLES
#


#          R12    (FOR LUNAR LANDING)                                   (6D)

LRLCTR          EQUALS          MPAC            +2      # B(1) LR DATA TEST
LRRCTR          EQUALS          MPAC            +2      # B(1)
LRMCTR          EQUALS          MPAC            +2      # B(1)
LRSCTR          EQUALS          MPAC            +2      # B(1)
#


#          LANDING ANALOGS DISPLAY STORAGE.                             (40D)

UHYP            EQUALS          RXZ                     # B(6)PRM SM UNIT VECTOR
UHZP            EQUALS          UHYP            +6      # B(6)PRM SM UNIT VECTOR
VHY             EQUALS          UHZP            +6      # B(1)PRM VHY=VMP.UHYP   (AN ORDER)
VHZ             EQUALS          VHY             +1      # B(1)PRM VHZ=VMP.UHZP   (-ED PAIR)
DELVS           EQUALS          VHZ             +1      # B(6)PRM DELVS = WMXR
VVECT           EQUALS          DELVS           +6      # B(3)PRM UPDATED S.P. VELOCITY VECTOR
ALTBITS         EQUALS          VVECT           +3      # B(2)PRM ALTITUDE IN BIT UNITS, 2.34FT/BT
RUNIT           EQUALS          ALTBITS         +2      # B(3)PRM SM HALF-UNIT R VECTOR
LATVMETR        EQUALS          RUNIT           +6      # B(1)PRM LATVEL MONITOR METER  (AN ORDER)
FORVMETR        EQUALS          LATVMETR        +1      # B(1)PRM FORVEL MONITOR METER  (-ED PAIR)
ALTRATE         EQUALS          FORVMETR        +1      # B(1)PRM ALTITUDE RATE IN BIT UNITS
LATVEL          EQUALS          ALTRATE         +1      # B(1)PRM LATERAL VELOCITY   (AN ORDER)
FORVEL          EQUALS          LATVEL          +1      # B(1)PRM FORWARD VELOCITY   (-ED PAIR)
TRAKLATV        EQUALS          FORVEL          +1      # B(1)PRM MONITOR FLG 4 LATVEL  (AN ORDER)
TRAKFWDV        EQUALS          TRAKLATV        +1      # B(1)PRM MONIT. FLAG FOR FORVEL (ED PAIR)
ALTSAVE         EQUALS          TRAKFWDV        +1      # B(2)PRM ALTITUDE IN BIT UNITS
LADQSAVE        EQUALS          ALTSAVE         +2      # B(1)PRM SAVE Q IN LANDISP
DALTRATE        EQUALS          LADQSAVE        +1      # B(1)PRM ALTITUDE RATE ERROR CORRECTION
DT              EQUALS          DALTRATE        +1      # B(1)PRM TIME 1 MINUS (PIPTIME +1)
LASTLADW        EQUALS          DT                      # ONLY A TAG TO SIGNIFY LAST L.A.D. WORD
#

# *******  OVERLAY NUMBER 5 IN EBANK 7  *******
#


#          ASCENT GUIDANCE ERASABLES.                                   (23D)

RCO             EQUALS          END-ALIG                # I(2)TMP  TARGET RADIUS AND OUT-OF-PLANE
YCO             EQUALS          RCO             +2      # I(2)TMP  DISTANCE, SCALED AT 2(24).
RDOTD           EQUALS          YCO             +2      # I(2)TMP  TARGET VELOCITY COMPONENTS
YDOTD           EQUALS          RDOTD           +2      # I(2)TMP SCALING IS 2(7)M/CS.
ZDOTD           EQUALS          YDOTD           +2      # I(2)TMP
XRANGE          EQUALS          ZDOTD           +2      # B(2)TMP
APO             EQUALS          XRANGE          +2      # B(2)TMP  APOLUNE ALTITUDE DESIRED - M.
                                                        #          SCALED AT 2(2().
AT              EQUALS          APO             +2      # I(2)TMP  ENGINE DATA -- THRUST ACC.*2(9)
VE              EQUALS          AT              +2      # I(2)TMP  EXHAUST VELOCITY * 2(7)M/CS.
TTO             EQUALS          VE              +2      # I(2)TMP  TAILOFF TIME * 2(17)CS.
TBUP            EQUALS          TTO             +2      # I(2)TMP  (M/MDOT) * 2(17)CS.
1/DV1           EQUALS          TBUP            +2      # B(2)TMP  ATMAG
1/DV2           EQUALS          1/DV1           +2      # B(2)TMP  ATMAG
1/DV3           EQUALS          1/DV2           +2      # B(2)TMP  ATMAG
QAXIS           EQUALS          1/DV3           +2      # B(6)
/R/MAG          EQUALS          QAXIS           +6      # I(2)TMP
LAXIS           EQUALS          /R/MAG          +2      # I(6)TMP
ZAXIS1          EQUALS          LAXIS           +6      # I(6)TMP  SYSTEM (R,L,Z).
RDOT            EQUALS          ZAXIS1          +6      # I(2)TMP  RADIAL RATE *2 (-7).
YDOT            EQUALS          RDOT            +2      # I(2)TMP  VEL. NORMAL TO REF. PLANE*2(-7)
ZDOT            EQUALS          YDOT            +2      # I(2)TMP  DOWN RANGE VEL *2(-7).
GEFF            EQUALS          ZDOT            +2      # I(2)TMP  EFFECTIVE GRAVITY
Y               EQUALS          GEFF            +2      # I(2)TMP  OUT-OF-PLANE DIST *2(24)M
DRDOT           EQUALS          Y               +2      # I(2)TMP  RDOTD - RDOT
DYDOT           EQUALS          DRDOT           +2      # I(2)TMP  YDOTD - YDOT
DZDOT           EQUALS          DYDOT           +2      # I(2)TMP  ZDOTD - ZDOT
PCONS           EQUALS          DZDOT           +2      # I(2)TMP  CONSTANT IN ATR EQUATION
YCONS           EQUALS          PCONS           +2      # I(2)TMP  CONSTANT IN ATY EQUATION
PRATE           EQUALS          YCONS           +2      # I(2)TMP  RATE COEFF. IN ATR EQUATION
YRATE           EQUALS          PRATE           +2      # I(2)TMP  RATE COEFF. IN ATY EQUATION
ATY             EQUALS          YRATE           +6      # I(2)TMP  OUT-OF-PLANE THRUST COMP.*2(9)
ATR             EQUALS          ATY             +2      # I(2)TMP  RADIAL THRUST COMP.*2(9)
ATP             EQUALS          ATR             +2      # I(2)TMP  DOWN-RANGE THRUST COMP
YAW             EQUALS          ATP             +2      # I(2)TMP
PITCH           EQUALS          YAW             +2      # I(2)RMP
ENGOFFDT        EQUALS          PITCH           +2      # B(1)TMP PROTECTION OFENGOFF1 CALL
VGVECT          EQUALS          ENGOFFDT        +1      # I(6)OUT  VELOCITY-TO-BE-GAINED
TXO             EQUALS          VGVECT          +6      # I(2)TMP  TIME AT WHICH X-AXIS OVERRIDE

# END OF THE ASCENT GUIDANCE ERASABLES.

# P10-P11 ERASABLES.
P1XTMIN         EQUALS          TTOGO
P1XITCNT        EQUALS          INCORPEX        +1
RCSMINT         =               P1XITCNT        +1
P1XDELTT        =               RCSMINT         +6
TCSITPF         =               P1XDELTT        +2
RLSBRCS         =               TCSITPF         +2
RLEMT2          =               RLSBRCS         +6
VCSMINT         =               RLEMT2          +2
INJANGLE        =               VCSMINT         +6
INJALT          =               INJANGLE        +2
P1XVVER         =               INJALT          +2
P1XVHOR         =               P1XVVER         +2
RP1XROT         =               P1XVHOR         +2
VP1XROT         =               RP1XROT         +6
P1XMAX          =               VP1XROT         +6
TPITIME         =               P1XMAX          +2
INJTIME         =               TPITIME         +2
CDHDELH         =               INJTIME         +2
ULVEC           =               CDHDELH         +2
P1XDT           =               ULVEC           +6
TPIANGLE        =               P1XDT           +2
UNVEC2          =               TPIANGLE        +2
P11VTPF         =               UNVEC2          +6

#          VARIOUS DISPLAY REGISTERS.  BALLANGS                         (3D)

FDAIX           EQUALS          VGBODY          +3      # I(1)
FDAIY           =               FDAIX           +1      # I(1)
FDAIZ           =               FDAIY           +1      # I(1)


# THE FOLLOWING CARDS KEEP THE ASSEMBLER HAPPY UNTIL THE SYMBOLS ARE DELETED FROM THE PINBALL NOUN TABLES.

CPHIXATT        EQUALS          SPARE

CURSOR          EQUALS          END-E7.0
SPIRAL          EQUALS          END-E7.0
POSCODE         EQUALS          END-E7.0

LANDLAT         EQUALS          END-E7.0
LANDLONG        EQUALS          END-E7.0
LANDALT         EQUALS          END-E7.0

END-E7.0        EQUALS          IRETURN1        +1      # FIRST UNUSED LOCATION IN E7 OVERLAY 0
END-E7.1        EQUALS          N49FLAG         +1      # FIRST UNUSED LOCATION IN E7 OVERLAY 1
END-E7.2        EQUALS          P21TIME         +2      # FIRST UNUSED LOCATION IN E7 OVERLAY 2
END-E7.3        EQUALS          P11VTPF         +2      # FIRST UNUSED LOCATION IN E7 OVERLAY 3
END-E7.4        EQUALS          FDAIZ           +1      # FIRST UNUSED LOCATION IN E7 OVERLAY 4
END-E7.5        EQUALS          TXO             +2      # FIRST UNUSED LOCATION IN E7 OVERLAY 5
END-E7          EQUALS          3777                    # **LAST LOCATION USED IN E7 **
