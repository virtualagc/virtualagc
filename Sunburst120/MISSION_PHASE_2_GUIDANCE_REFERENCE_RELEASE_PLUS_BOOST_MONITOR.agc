### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MISSION_PHASE_2_GUIDANCE_REFERENCE_RELEASE_PLUS_BOOST_MONITOR.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-23 MAS  Transcribed.
##		2016-10-32 RSB	Typos.
##		2016-12-06 RSB	Comments proofed using octopus/ProoferComments,
##				changes made.
##		2017-06-13 RSB	Fixes identified whilst transcribing SUNBURST 37.

## Page 673
# PROGRAM NAME - MISSION PHASE 2 GUIDANCE REFERENCE RELEASE + BOOST MONITOR.

# MODIFICATION NUMBER - 1         DATE - NOVEMBER 22, 1966                MODIFICATION BY - COVELLI



# FUNCTIONAL DESCRIPTION -

#    THE FUNCTION OF MISSION PHASE 2 IS TO CONTROL THE SEQUENCE OF EVENTS IN THE 206 FLIGHT FROM GUIDANCE
# REFERENCE RELEASE THROUGH LIFTOFF TO THE SIVB BOOSTER SHUTDOWN.

#    AT GUIDANCE REFERENCE RELEASE, THE GRR FLAG IS SET,  PREREAD IS CALLED TO BEGIN COMPUTATION OF POSITION AND
# VELOCITY, AND CALLS ARE MADE FOR DFI T/M CALIBRATION AND LIFTOFF

#    WHEN PRELAUNCH DETECTS THAT THE GRR FLAG IS SET, IT TERMINATES GYROCOMPASSING AND CALLS MP2JOB. MP2JOB
# DISPLAYS 7 IN THE MAJOR MODE AND GOES TO MATRXJOB TO COMPUTE REFSMMAT.

#    AT LIFTOFF, THE LGC CLOCK IS ZEROED, CALLS ARE MADE FOR THE COLD FIRE PURGE AND POST LET JETTISON PROGRAMS.
# THE MAJOR MODE IS CHANGED TO 11.

#    AT POST LET JETTISON, THE DV MONITOR IS ENABLED TO DETECT BOOSTER SHUTDOWN, THE ABORT COMMAND MONITOR AND THE
# TUMBLE MONITOR ARE ENABLED, AND THE MAJOR MODE IS CHANGED TO 12.

#    THE VARIOUS LMP COMMANDS REQUIRED FOR MP2 ARE SCHEDULED BY WAITLIST CALLS.

#    AT DETECTION OF SIVB SHUTDOWN, AN EXECUTIVE CALL IS MADE TO MISSION PHASE 6.



# CALLING SEQUENCE :

#    MISSION PHASE 2 IS BEGUN UPON RECEIPT OF THE GUIDANCE REFERENCE RELEASE SIGNAL (VERB 65 ENTER) VIA UPLINK.



# SUBROUTINES CALLED :

#          PREREAD                1LMP
#          TUMTASK                2LMP
#          NEWMODEX               PHASCHNG
#          FINDVAC                NEWPHASE
#          NOVAC                  DFITMCAL
#          SPVAC                  IBNKCALL
#          WAITLIST
#          LONGCALL



# NORMAL EXIT MODES :
## Page 674
#    EXIT TO MISSION PHASE 6 AT SIVB SHUTDOWN.



# ABORT EXIT MODES :

#    TO MISSION PHASE 3 IF SUBORBITAL ABORT COMMAND RECEIVED VIA UPLINK.
#    TO MISSION PHASE 4 IF CONTINGENCY ORBIT INSERTION COMMAND RECEIVED VIA UPLINK.
#    TO CHARALRM IF EITHER OF THE ABOVE ABORT COMMANDS RECEIVED WHILE ABORT COMMAND MONITOR NOT ENABLED.



# OUTPUT :

#          TGRR          TIME OF GUIDANCE REFERENCE RELEASE
#          TPRELTER      TIME OF GYROCOMPASSING TERMINATION
#          TLIFTOFF      TIME OF LIFTOFF AND LGC CLOCK ZEROING
#          GRR FLAG      BIT2 FLAGWRD1 SET TO INDICATE GRR SIGNAL RECEIVED
#          SERVICER IS GOING AT END OF MISSION PHASE 2
#          MAJOR MODE DISPLAYS



# ERASABLE INITIALIZATION :

#          DT-LIFT       DELTA TIME FROM GRR TO LIFTOFF, SINGLE PRECISION SCALED AT 2(+14) CS.
#          DT-LETJT      DELTA TIME FROM LIFTOFF TO POST LET JETTISON, DOUBLE PRECISION SCALED AT 2(+28) CS.
#          RAVEGON       POSITION AT GRR IN SM CO-ORDINATES, VECTOR SCALED AT 2(+24) M.
#          VAVEGON       VELOCITY AT GRR IN SM CO-ORDINATES, VECTOR SCALED AT 2(+7) M/CS.

# ********  ALL OF THE ERASABLE INITIALIZATION MUST BE DONE DURING THE PRE-LAUNCH ERASABLE LOAD  *****************



# DEBRIS :

#    CENTRALS AND EXECUTIVE WORK AREA.



                BANK            27
                EBANK=          TGRR



GRRPLACE        TC              FLAG1UP
                OCT             2
                TC              ENDOFJOB
MP2TASK         CA              PRIO15
                TC              FINDVAC
## Page 675
                EBANK=          TGRR
                2CADR           MP2JOB

                CA              DT-LIFT
                TC              WAITLIST                        # SET UP CALL TO LIFTOFF PROGRAM
                EBANK=          TGRR
                2CADR           LIFTOFF

                TC              2PHSCHNG
                OCT             00375                           # 5.37 SPOT FOR MP2TASK.
                OCT             00273                           # 3.27 SPOT TO FINISH PRELAUNCH.

                TC              2PHSCHNG
                OCT             40132                           # 2.13 SPOT FOR LIFTOFF.
                OCT             00074                           # 4.7 SPOT FOR MP2JOB.

                CAF             BIT2
                TC              SETRSTRT                        # SET RESTART FLAG

SETPIPDT        CAF             PRIO31                          # TWO SECONDS SCALED AT (CS) X 2(+8)
                TS              1/PIPADT

                CA              AVEGADRS
                TS              DVSELECT

                EXTEND
                DCA             SVEXADRS
                DXCH            AVGEXIT

                EXTEND
                DCA             SVEXADRS
                DXCH            DVMNEXIT

                CA              EBANK5
                TS              EBANK
                CA              EBANK4
                TS              Q
                EBANK=          TEMPTIME
                EXTEND                                          # GET TEMPTIME
                DCA             TEMPTIME
                DXCH            TPRELTER
                EXTEND
                DCA             TPRELTER
                EXTEND
                QXCH            EBANK
                EBANK=          TAVEGON
                DXCH            TAVEGON                         # STORE IN TAVEGON

                EBANK=          TGRR
## Page 676
                EXTEND
                DCA             BBBBBBBB
                DTCB
                EBANK=          DVCNTR
BBBBBBBB        2CADR           BIBIBIAS



MP2JOB          TC              INTPRET
                SSP             DLOAD
                                PHASENUM
                                2
                                TPRELTER
                STORE           TGRR
                STORE           TEVENT                          # FOR DOWNLINK.

## Page 677
# PROGRAM DESCRIPTION- MATRXJOB                                           DATE: 18 JAN 1967
# MOD NO: 2                                                               LOG SECTION- MP 2 GRR + BOOST MONITOR
# MOD BY: MILLER, LICKLY, KERNAN                                          ASSEMBLY: SUNBURST REVISION 79

# FUNCTIONAL DESCRIPTION

#          THIS PROGRAM CONSTRUCTS THE MATRIX WHICH RELATES THE STABLE MEMBER INERTIAL FRAME TO THE REFERENCE
# FRAME (Z NORTH, X ALONG THE VERNAL EQUINOX.)

#          TWO INTERMEDIATE COORDINATE SYSTEMS ARE USED: A LOCAL, EARTH FIXED, VERTICAL, SOUTH, EAST SYSTEM AND AN
# EARTH REFERENCE X, Y, Z SYSTEM.  IN THIS LATTER SYSTEM, THE Z AXIS IS THE EARTH'S ROTATION AXIS, THE X AXIS IS
# NORMAL TO Z IN THE PLANE OF Z AND THE LOCAL VERTICAL, POSITIVE IN THE DIRECTION OF V.  Y IS Z CROSS X.

#          THE FIRST COMPUTATION IS OF AZGR, THE ANGLE BETWEEN THE REFERENCE INERTIAL AND EARTH REFERENCE X-Z
# PLANES (THE Z AXES ARE COINCIDENT).  AZGR IS COMPUTED BY CONVERTING THE TIME FROM THE BEGINNING OF THE EPHEMERIS
# YEAR TO RELEASE (TEPHEM + TPRELTER) TO REVOLUTIONS (DAYS).  THE WHOLE REVS ARE DISCARDED AND THE INITIAL ANGLE
# (AZ0) BETWEEN THE GREENWICH MERIDIAN AND THE REFERENCE X-Z PLANES IS ADDED.  ADDING THE LONGITUDE YIELDS AZGR.

#          THE FOLLOWING COMPUTATIONS ARE THEN PERFORMED.

# LOCAL VERTICAL(ER) = COS(LATITUDE), 0, SIN(LATITUDE)  IN EARTH REFERENCE

# LOCAL VERTICAL(IR) = COS(LAT)COS(AZGR), COS(LAT)SIN(AZGR), SIN(LAT)  IN INERTIAL REFERENCE

# LOCAL EAST(IR) = UNIT(NXV) = -SIN(AZGR), COS(AZGR), 0  IN INERTIAL REFERENCE

# LOCAL SOUTH(IR) = E(IR) X V(IR)

## In the following line, the printout reads "... V. S, F AXES ..."; however,
## the corresponding line in SUNBURST 37 is "... V, S, E AXES ...", which is 
## clearly correct in terms of content.  My assumption is that the SUNBURST 120
## printout is faulty and that SUNBURST 37 is correct. &mdash; RSB
#          THE RELATIONSHIP OF THE STABLE MEMBER AXES TO THE V, S, E AXES IS GIVEN BY ZSMAZ, THE ANGLE FROM NORTH
# TO ZSM, AND TILT, THE ANGLE ABOUT ZSM FROM VERTICAL TO XSM.

# ZSM(IR) = EAST(IR)SIN(ZSMAZ) - SOUTH(IR)COS(ZSMAZ)

# YSM(IR) = (ZSM(IR) X V(IR))COS(TILT) - V(IR)SIN(TILT)

# XSM(IR) = YSM(IR) X ZSM(IR)

#          THESE THREE HALF-UNIT VECTORS, XSM(IR), YSM(IR), AND ZSM(IR) ARE THE SM AXES EXPRESSED IN INERTIAL
# REFERENCE COORDINATES AND THEY FORM REFSMMAT, THE REFERENCE TO STABLE MEMBER MATRIX.

# THE INPUT (PRELAUNCH ERASABLE LOAD) REQUIREMENTS ARE:

# 1) TEPHEM       THE TRIPLE PRECISION TIME IN CENTISECONDS FROM MIDNIGHT JULY 1, OF THE EPHEMERIS YEAR TO
# MIDNIGHT OF THE LAUNCH DAY (SIDEREAL CONVERTED TO MEAN SOLAR.)

#    IT IS ASSUMED THAT DURING THE LAUNCH COUNTDOWN THE LGC CLOCK (TIME2, TIME1) WILL BE ALIGNED TO REFLECT A
# ZERO VALUE AT MIDNIGHT OF THE LAUNCH DAY.  IF NOT, THE DIFFERENCE MUST BE ADDED TO TEPHEM.

# 2) TILT         THE ROTATION OF XSM ABOUT ZSM (RIGHT HAND RULE) FROM VERTICAL IN REVOLUTIONS.

## Page 678
# 3) ZSMAZ        THE ANGLE FROM NORTH TO ZSM IN REVOLUTIONS.

# THE OUTPUTS OF THIS PROGRAM ARE:

# 1) REFSMMAT     THE HALF-UNIT MATRIX WHICH TRANSFORMS FROM REFERENCE INERTIAL TO SM INERTIAL.

# 2) AZGR         THE ANGLE BETWEEN PAD 37 B VERTICAL AND THE REFERENCE X-Z PLANE IN REVOLUTIONS.

# CALLING SEQUENCE : CONTINUATION OF MP2JOB
# NORMAL EXIT MODE-   TC  ENDOFJOB

# ALARM OR ABORT EXITS-  NONE

# DEBRIS-  SPECIALS, CENTRALS AND EXECUTIVE WORK AREA.

MATRXJOB        DLOAD           SR
                                TPRELTER                        # MAKE ALIGN STOP TIME TP.
                                14D
                TAD             RTB
                                TEPHEM                          # TP CS FROM JULY 1 TO LAUNCH DAY.
                                TPMODE                          # SET STORE MODE TO TRIPLE.
                STORE           20D                             # TP CS FROM JULY 1 TO RELEASE.
                SLOAD           NORM
                                20D
                                X1                              # -9 OR -10.
                DMP             RTB
                                WEARTH                          # REVS PER 2(28)CS.
                                SGNAGREE
                SR*             PDDL
                                0               -19D,1          # GETS RID OF WHOLE REVS.
                                21D
                DMP             RTB
                                WEARTH
                                SGNAGREE
                SLR             DAD
                                5                               # DP FRACTION OF A REV.
                DAD             DAD
                                AZ0                             # MERIDIAN ANGLE AT JULY 1.
                                P37BLONG                        # PAD ANGLE TO MERIDIAN.
                STORE           AZGR                            # VERT. AZ. AT RELEASE WRT X-Z INERTIAL.

                SIN
                STODL           REFSMMAT        +6              # SIN(AZGR).
                                AZGR
                COS
                STODL           MPAC            +3              # Y OF EAST IN INERTIAL = COS(AZGR).
                                P37BLAT                         # LOCAL VERTICAL Z IN EARTH REF. SIN(L).
                SIN
                STODL           REFSMMAT        +4              # ALSO LOCAL VERT Z IN REF. INERTIAL.
                                P37BLAT

## Page 679
                COS             SL1                             # SAVES 2 SL'S LATER.
                STORE           20D                             # LOCAL VER. X IN EARTH REF.  COS(L).
                DMP
                                MPAC            +3
                STODL           REFSMMAT                        # X OF VERT IN INERTIAL = COS(L)COS(AZGR).
                                REFSMMAT        +6              # SIN(AZGR).
                DMP
                                20D
                STODL           REFSMMAT        +2              # Y OF VERT IN INERTIAL = COS(L)SIN(AZGR).
                                DPZRO
                STODL           MPAC            +5              # Z OF EAST IN INERTIAL = 0.
                                REFSMMAT        +6              # SIN(AZGR).
                DCOMP           RTB                             # ALSO -X OF EAST IN INERTIAL.
                                VECMODE                         # SET STORE MODE TO VECTOR.
                PUSH            VXV                             # INERTIAL EAST INTO PD.
                                REFSMMAT
                UNIT                                            # INERTIAL SOUTH = UNIT(EXV).
                STODL           REFSMMAT        +12D            # INTO REF +12D  (TEMP).
                                ZSMAZ                           # ZSM WRT NORTH.
                COS             VXSC
                                REFSMMAT        +12D            # SOUTH(IR)COS(ZSMAZ).
                STODL           REFSMMAT        +12D            # INTO REF +12D  (TEMP).
                                ZSMAZ
                SIN             VXSC                            # EAST(IR)SIN(ZSMAZ).
                VSU             UNIT
                                REFSMMAT        +12D            # UNIT(ZSM) IN INERTIAL =
                STORE           REFSMMAT        +12D            # EAST(IR)SIN(ZSMAZ) - SOUTH(IR)COS(ZSMAZ)

                VXV             UNIT
                                REFSMMAT                        # YREFSM(UNTILTED)= Z CROSS VERT = Y1.
                PDDL            COS                             # INTO PD.
                                TILT                            # TILT IS POS ABOUT ZSM FROM UNTILTED YSM.
                VXSC
                PDDL            SIN                             # (Y1)COS(T) INTO PD.
                                TILT
                VXSC            BVSU
                                REFSMMAT
                UNIT
                STORE           REFSMMAT        +6              # YREFSM = (Y1)COS(T) - (VERT)SIN(T).

                VXV             UNIT
                                REFSMMAT        +12D
                STORE           REFSMMAT                        # XREFSM = Y CROSS Z.
                EXIT

                TC              PHASCHNG
                OCT             00004                           # DEACTIVATE GROUP 4

                TC              ENDOFJOB

## Page 680
DFITMCAL        TC              1LMP                            # MUST BE CALLED BY IBNKCALL (OR ISWCALL)
                DEC             236                             #   IN INTERRUPT OR INHIBITED
                CA              12SEC
                TC              WAITLIST                        # CALL DFITMCL1 IN 12 SECONDS
                EBANK=          TGRR
                2CADR           DFITMCL1

                TCF             ISWRETRN

DFITMCL1        TC              2LMP
                DEC             237                             # DFI T/M CALIBRATE OFF
                DEC             198                             # MASTER C+W ALARM RESET - COMMAND
                TC              FIXDELAY
                DEC             200                             # DELAY 2 SECONDS

DFITMCL2        TC              1LMP
                DEC             199                             # MASTER C+W ALARM RESET - COMMAND RESET
                TCF             TASKOVER

LIFTOFF         TC              NEWMODEX                        # DISPLAY MAJOR MODE 11
                OCT             11

                CA              61OCT
                TC              NEWPHASE                        # IMMEDIATE RESTART HERE
                OCT             2

REDO2.61        ZL                                              # THIS SECTION OF CODING ZEROES THE LGC
                CS              HALF                            # CLOCK AND MAKES THE CORRESPONDING
                DOUBLE                                          # CORRECTION TO TBASE5 , SO THAT READACCS
                AD              TIME1                           # IS NOT CALLED TOO SOON. THE NEW TBASE5
                ADS             TBASE5                          # IS OVERFLOW CORRECTED.

                CA              ZERO
                DXCH            TIME2
                DXCH            TLIFTOFF                        # SAVE TIME OF LIFTOFF

                CA              63OCT
                TC              NEWPHASE                        # DO NOT REPEAT THE ABOVE
                OCT             2

REDO2.63        EXTEND
                DCA             DT-LETJT
                TC              LONGCALL
                EBANK=          TGRR
                2CADR           POSTLET

                TC              2PHSCHNG
                OCT             00073                           # RESTART POSTLET LONGCALL GROUP 3
                OCT             25012                           # AND CONTINUE LIFTOFF (SET LONGBASE HERE)
                OCT             77777

## Page 681
                TC              2PHSCHNG
                OCT             2
                OCT             47016                           # PROTECT RCSPURGE.
                DEC             10500
                EBANK=          TGRR
                2CADR           RCSPURGE

                TC              FIXDELAY
                DEC             10500
RCSPURGE        CA              +XJETSON
                EXTEND
                WRITE           5                               # TURN ON +X TRANSLATION

                TCF             TASKOVER


POSTLET         CS              FLAGWRD2                        # ENABLE ABORT COMMAND MONITOR
                MASK            BIT9                            # BIT 9  FLAGWORD 2
                ADS             FLAGWRD2

                TC              NEWMODEX
                OCT             12                              # MAJOR MODE 12

                CA              BIT1
                TC              WAITLIST                        # ENABLE TUMBLE MONITOR
                EBANK=          OMEGA
                2CADR           TUMTASK

                TC              2PHSCHNG
                OCT             00053                           # RESTART TUMTASK GR 3
                OCT             47012
                DEC             1000
                EBANK=          TGRR
                2CADR           MONBOOST

                TC              FIXDELAY
                DEC             1000                            # WAIT 10 SECONDS FOR STAGING + SIVB IGN.

MONBOOST        CA              BOOSTADR                        # MONITOR DELV FOR BOOSTER SHUTDOWN
                TS              DVSELECT

                TC              PHASCHNG
                OCT             47012
                DEC             2100
                EBANK=          TGRR
                2CADR           PURGEOFF

                TC              FIXDELAY
                DEC             2100                            # WAIT 21 SECONDS

## Page 682
PURGEOFF        CA              ZERO
                TC              NEWPHASE
                OCT             6

                CA              ZERO
                EXTEND
                WRITE           6
                EXTEND
                WRITE           5                               # TURN OFF RCS JETS

                TC              1LMP+DT
                DEC             186                             # ECS PRIMARY WATER VALVE OPEN

                DEC             200                             # WAIT 2 SECONDS

WATEROFF        TC              1LMP
                DEC             187                             # ECS PRIMARY WATER VALVE - OPEN RESET
                
                TC              PHASCHNG
                OCT             00002                           # DEACTIVATE GROUP 2

                TCF             TASKOVER                        # END OF MISSION PHASE 2


                
                                                                # DELTA T S AND OTHER CONSTANTS FOR MP2
AVEGADRS        GENADR          AVERAGEG
BOOSTADR        GENADR          BOOSTMON
SVEXADRS        EQUALS          SVEXITAD
12SEC           DEC             1200
WEARTH          2DEC            31.1539787      B-5             # REVOLUTIONS PER 2(28) CENTISECONDS.

+XJETSON        OCT             00252                           # BITS FOR +X TRANSLATION JETS



                                                                # ABORT COMMAND MONITOR - DETECTS
                                                                # SUBORBITAL ABORT AND CONTINGENCY
                                                                # ORBIT INSERTION

SUBABORT        INHINT                                          # SUBORBITAL ABORT - ZERO ABORTNDX TO
                CAF             ZERO                            # SET UP MISSION PHASE 3
                TCF             CONORBIT        +2

CONORBIT        INHINT                                          # CONTINGENCY ORBIT INSERTION - ABORTNDX
                CAF             TWO                             # SET TO 2 TO SET UP MISSION PHASE 4
                TS              L                               # SAVE IN L
                CS              FLAGWRD2                        # CHECK ABORT RECEIVED FLAG TO INSURE THAT

                MASK            BIT10                           # MULTIBLE TRANSMISSIONS DON'T START
## Page 683
                EXTEND                                          # MULTIBLE JOBS.  SINCE MULTIBLE XMISSIONS
                BZF             ENDOFJOB                        # ARE THE RULE, LEAVE WITH NO ALARM.
                CS              FLAGWRD2                        # IS ABORT COMMAND MONITOR ENABLED

                MASK            BIT9
                EXTEND
                BZF             SETABORT                        # YES.

                TC              ALARM                           # ABORT NOT ENABLED, SET ALARM AND EXIT.
                OCT             00300
                TC              ENDOFJOB

SETABORT        INHINT
                CA              EBANK3
                TS              EBANK
                LXCH            ABORTNDX                        # STORE ABORTNDX
                CAF             AVEGADRS
                TS              DVSELECT                        # TURN OFF BOOSTMON
                TC              2PHSCHNG
                OCT             00004
                OCT             00006
                TC              2PHSCHNG
                OCT             00003
                OCT             07022
                OCT             21000
                EBANK=          ABORTNDX
                2CADR           TUMBL3/4

                TC              FLAG2UP
                OCT             01000                           # ABORT RECEIVED FLAG
                TC              POSTJUMP
                CADR            ENEMA                           # WIPE EVERYTHING OUT



TUMBL3/4        INHINT
                CA              BIT1
                TC              WAITLIST                        # RE-ESTABLISH TUMBLE MONITOR
                EBANK=          OMEGA
                2CADR           TUMTASK

                TC              2PHSCHNG
                OCT             00053                           # 3.5 SPOT FOR TUMTASK
                OCT             04022                           # GR 2 FOR ABORT3/4

ABORT3/4        INHINT
                CAF             PRIO27
                TS              NEWPRIO                         # SET UP MP3 OR MP4 VIA SPVAC

                EXTEND
## Page 684
                INDEX           ABORTNDX                        # GET RIGHT 2CADR
                DCA             MP3-4ADR
                TC              SPVAC                           # SET UP ABORT JOB.

                TCF             ENDOFJOB



                EBANK=          TDEC
MP3-4ADR        2CADR           MP03JOB                         # DO NOT CHANGE THE ORDER OF THESE 2 CARDS

                EBANK=          TDEC
                2CADR           MP4JOB                          # THEY ARE IN AN INDEXED TABLE

                EBANK=          TDEC                            # LEFT-OVERS FROM DELETED MISSION PHASE 18
MIDAVEAD        2CADR           MIDTOAVE

                EBANK=          TDEC
SVEXITAD        2CADR           SERVEXIT



61OCT           OCT             61
63OCT           OCT             63

## Page 685
# SET UP & EXECUTE JOB TO ADD VELOCITY CORRECTION TO VN:

                EBANK=          GTSWTLST

LIFTFIXT        CA              PRIO17                          # LESS THAN PRELAUNCH OR NORMLIZE
                TC              FINDVAC
                EBANK=          OLDGT
                2CADR           LIFTFIX

                TC              TASKOVER



LIFTFIX         CS              PIPTIME         +1              # PRELAUNCH BY NOW HAS FOUND THE GRR FLAG
                AD              OLDGT                           # & SUBSEQUENTLY BEEN THRU PREREAD, VIA
                EXTEND                                          # MP2TASK.
                BZMF            +3
                AD              NEG1/2                          # (IF TIME1 OVERFLOWED)
                AD              NEG1/2
                TS              MPAC            +3

                TC              INTPRET

                SLOAD           DDV
                                MPAC            +3
                                -1SEC214                        # MAKE THE TIME-RATIO POSITIVE.
                VXSC            PDVL
                                GDT/2
                                DELV
                VAD             VSL1
                                DELVBUF
                VXSC            VAD
                                KPIP1
                VAD
                                VN
                STORE           VN

                EXIT
                TC              ENDOFJOB



-1SEC214        2DEC            -100            B-14
