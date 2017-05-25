### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     MISSION_PHASE_13-APS2.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-29 MAS  Transcribed
##		 2016-10-31 RSB	 Typos.
##		 2016-11-01 RSB	 More typos.
##		 2016-12-06 RSB	 Comments proofed using octopus/ProoferComments,
##				 changes made.

## Page 754
# MISSION PHASE 13 EXERCISES THE ASCENT GUIDANCE EQUATIONS OF PROG 46
# THE PREREAD TASK IS SET TO OCCUR IN 140 SECS AT TIG-30 AND AVETOMID DONE
# THE PRE-APS2 PROG 34 IS EXECUTED AND KALCMANU JOB IS STARTED
# THE ENGINEON TASK IS STARTED AT TIG-30 AND IGN IS AT 170 SECS AFTER
# START OF MP13
# THE ASCENT GUIDANCE EQUATIONS START BETWEEN TIG+1 AND +2 SECS
# THE ASC FEED TEST STARTS AT TIG+9 AND TERMINATES 365 SECS LATER

                BANK            27
                EBANK=          AMEMORY

MP13JOB         TC              FLAG1DWN
                OCT             04000                           # KNOCK DOWN RESTART FLAG

                EXTEND
                DCA             TIME2                           # PICK UP CURRENT TIME
                DXCH            TDEC
                TC              NEWMODEX                        # SET MODE
                OCT             34

                ZL                                              # SET TDEC TO TIME AT TIG-30
                CAF             140SECS                         # TIME TO TIGN-30
                XCH             L
                DAS             TDEC                            # TDEC =TIGN-30 FOR MIDTOAVE

                CAF             140SECS
                INHINT
                TC              WAITLIST                        # SET TASK FOR TIGN-30
                EBANK=          TDEC
                2CADR           TIG13-30

                EXTEND
                DCA             TDEC
                DXCH            TIGN
                EXTEND
                DCA             30SECS13
                DAS             TIGN                            # DISPLAY TIGN FOR DOWNLINK.

                RELINT

                EXTEND
                DCA             MIDAVEAD                        # DO MIDTOAVE COMPUTATION
                DXCH            Z

                EXTEND
                DCA             PREAP2AD                        # DO PRE-APS2 TO GET DESIRED ATTITUDE
                DXCH            Z                               # STORES VECTORS POINTVSM AND SCAXIS

                TC              INTPRET
                SSP             SET
## Page 755
                                RATEINDX                        # SET KALCMANU FOR ANGULAR RATE OF 5DEG/S
                                4
                                33D
                EXIT

                CAF             PRIO16                          # SET UP ATTITUDE MANEUVER JOB.
                INHINT
                TC              FINDVAC
                EBANK=          MIS
                2CADR           VECPOINT

                CAF             BIT1
                INHINT
                TC              WAITLIST                        # SET UP DFI T/M CALIBRATE TASK
                EBANK=          TDEC
                2CADR           DFICAL                          # DFICAL REQUIRES 14 SECS AND ENDS ITSELF

                TC              BANKCALL                        # PUT MP13 TO SLEEP-KALCMANU WILL WAKE
                CADR            ATTSTALL
                TC              CURTAINS                        # BAD END RETURN FROM KALCMANU

                TC              ENDOFJOB                        # WAIT FOR TIG-30 TASK TO INTERUPT

TIG13-30        CAF             BIT1                            # SET PREREAD FOR NOW
                TC              WAITLIST
                EBANK=          DVTOTAL
                2CADR           PREREAD

                TC              PHASCHNG                        # PREREAD RESTART PROTECTION
                OCT             00335

                CAF             BIT11                           # SEE IF ATTITUDE MANEUVER DONE
                MASK            FLAGWRD2
                CCS             A
                TCF             CURTJOB                         # NO-SET UP CURTAINS JOB

                TC              NEWMODEX
                OCT             46                              # SET MODE TO PROG46

                CAF             AVEG13AD                        # GENADR OF AVEG IN DVSELECT
                TS              DVSELECT

                EXTEND
                DCA             SVEX13AD                        # 2CADR SERVEXIT IN AVEGEXIT
                DXCH            AVGEXIT

                EXTEND
                DCA             MP13TMAD
                DXCH            DVMNEXIT                        # SET MP RETURN FOR ENGINE SHUT DOWN

## Page 756
                TC              IBNKCALL
                CADR            ENGINOF1

                TC              1LMP+DT
                DEC             134                             # ENGINE SELECT-APS ARM
                DEC             1750                            # DELAY 17.5 SECS

                TC              IBNKCALL
                CADR            ULLAGE                          # COMMAND 4 JET ULLAGE-ON

                TC              FIXDELAY
                DEC             1250                            # DELAY 12.5 SECS TO IGNITION

TIG13           TC              IBNKCALL
                CADR            APSENGON

                TC              FIXDELAY
                DEC             50                              # DELAY .5 SECS

                TC              IBNKCALL
                CADR            NOULLAGE                        # ULLAGE JETS OFF AT TIG + .5

# NOW THAT THE ENGINE IS ON AND ULLAGE IS OFF, SET UP DUMMY MP 13 & PUT RESTARTABILITY FLAG UP:

                TC              2PHSCHNG
                OCT             00313                           # 3.31 SPOT IS DUMMY13 TASK.
                OCT             2                               # GROUP 2 OFF.

                CAF             BIT13
                TC              SETRSTRT                        # SET RESTART FLAG

                TC              FIXDELAY
                DEC             250                             # DELAY 2.5 SECS AND START GUIDANCE
                EXTEND
                DCA             ATMAGAD
                DXCH            AVGEXIT                         # SET AVEG LOOP TO THRUST MAGNITUDE FILTER

                TC              FIXDELAY
                DEC             600                             # START FEED TEST ROUTINE
                TC              FEEDTEST                        # START FEED TEST ROUTINE

                EXTEND
                DCA             342SECS
                TC              LONGCALL
                EBANK=          TDEC
                2CADR           MP13+544

TCGP2OFF        TCF             GRP2OFF

MP13+544        TC              FEEDREST                        # DO FEED TEST RESET ROUTINE

## Page 757
GRP2OFF         CS              ZERO
                ZL
                DXCH            -PHASE2

                TC              TASKOVER                        # WAIT FOR GUIDANCE TO DO ENGINE OFF

MP13TERM        CAF             BIT1                            # SET MP13 TERMINAL TASKS
                INHINT
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           MP13OUT

                TC              POSTJUMP
                CADR            SERVEXIT

MP13OUT         TC              IBNKCALL                        # DEADBAND SELECT - MAX
                CADR            SETMAXDB

                TC              FEEDREST                        # DO THIS IN CASE OF EARLY ENG SHUT DOWN

                TC              FIXDELAY
                DEC             100                             # DELAY 1 SEC

                TC              1LMP
                DEC             135                             # APS ARM OFF

                TC              FIXDELAY
                DEC             2900                            # DELAY 29 SECS TO KILL AVEG

                TC              FLAG1DWN                        # KILL AVE G
                OCT             1

                TC              TASKOVER                        # MISSION PHASE 13 COMPLETE

1SEC13          DEC             100
2SECS13         DEC             200
12SECS13        DEC             1200
30SECS13        2DEC            3000

140SECS         DEC             14000
342SECS         2DEC            34200                           # 342 SECONDS

AVEG13AD        GENADR          AVERAGEG
                EBANK=          TDEC
PREAP2AD        2CADR           PREAPS2

                EBANK=          TDEC
MP13TMAD        2CADR           MP13TERM

                EBANK=          TDEC
## Page 758
ATMAGAD         2CADR           ATMAG

                EBANK=          DVTOTAL
SVEX13AD        2CADR           SERVEXIT

## Page 759
CURTJOB         CAF             PRIO37                          # SET UP JOB TO GO TO CURTAINS
                TC              NOVAC
                EBANK=          SFAIL
                2CADR           CURTAINS

                TC              TASKOVER

DFICAL          TC              1LMP+DT                         # LMP COMMAND
                DEC             236                             # DFI T/M CALIBRATE - ON
                DEC             1200                            # DELAY 12 SECS

                TC              2LMP+DT                         # LMP COMMANDS
                DEC             237                             # DFI T/M CALIBRATE - OFF
                DEC             198                             # MASTER C+W ALARM RESET - COMMAND
                DEC             200                             # DELAY 2.0 SECONDS

                TC              1LMP                            # LMP COMMAND
                DEC             199                             # MASTER C+W ALARM RESET - COMMAND RESET
                TC              TASKOVER                        # TERMINATE DFI CALIBRATE TASK

## Page 760
FEEDTEST        EXTEND
                QXCH            MPRETRN
                TC              FLAG2UP                         # SET ASC FEED TEST FLAG
                OCT             200

                TC              1LMP+DT                         # TIME T
                DEC             126                             # RCS ASCENT FEED VALVE - ARM
                DEC             100                             # DELAY 1 SEC

                TC              2LMP+DT                         # T+1
                DEC             60                              # RCS ASCENT FEED VALVES8 SYS A-OPEN
                DEC             172                             # RCS MAIN S/O VALVES SYS A-CLOSE
                DEC             200                             # DELAY FOR 2 SECS

                TC              2LMP+DT                         # T+3
                DEC             61                              # RCS ASCENT FEED VALVES SYS A-OPEN RESET
                DEC             173                             # RCS MAIN S/O VALVES SYS A-CLOSE RESET
                DEC             800                             # DELAY FOR 8 SECS

                TC              2LMP+DT                         # T+11
                DEC             62                              # RCS ASCENT FEED VALVES SYS B-OPEN
                DEC             174                             # RCS MAIN S/O VALVES SYS B -CLOSE
                DEC             200                             # DELAY FOR 2 SECS

                TC              2LMP+DT                         # T+13
                DEC             63                              # RCS ASCENT FEED VALVES SYS B-OPEN RESET
                DEC             175                             # RCS MAIN S/O VALVES SYS B-CLOSE RESET
                DEC             800                             # DELAY 8 SECS

                TC              1LMP+DT                         # T+21
                DEC             252                             # RCS MANIFOLD CROSSFEED VALVES-OPEN
                DEC             200                             # DELAY FOR 2 SECS

                TC              1LMP                            # T+23
                DEC             253                             # RCS MANIFOLD CROSSFEED VALVES-OPEN RESET

                TC              MPRETRN

## Page 761
FEEDREST        CS              FLAGWRD2                        # CHECK FEED TEST FLAG
                MASK            BIT8
                CCS             A
                TC              Q                               # FLAG DOWN-NO RESET

                EXTEND                                          # FLAG UP - DO FEED TEST RESET
                QXCH            MPRETRN

                TC              FLAG2DWN                        # FEED TEST FLAG DOWN
                OCT             200

                TC              1LMP+DT                         # TIME T
                DEC             254                             # RCS MANIFOLD CROSSFEED VALVES -CLOSE
                DEC             100                             # DELAY 1 SEC

                TC              2LMP+DT                         # T+1
                DEC             188                             # RCS MAIN S/O VALVES SYS A-OPEN
                DEC             76                              # RCS ASCENT FEED VALVES SYS A-CLOSE
                DEC             100                             # DELAY 1 SECS

                TC              1LMP+DT                         # T+2
                DEC             255                             # RCS MANIFOLD CROSSFEED VALVES-CLOSE RESE
                DEC             100                             # DELAY 1 SEC

                TC              2LMP+DT                         # T+3
                DEC             189                             # RCS MAIN S/O VALVES SYS A-OPEN RESET
                DEC             77                              # RCS ASCENT FEED VALVES SYS A-CLOSE RESET
                DEC             800                             # DELAY 8 SECS

                TC              2LMP+DT                         # T+11
                DEC             190                             # RCS MAIN S/O VALVES SYS B-OPEN
                DEC             78                              # RCS ASCENT FEED VALVES SYS B-CLOSE
                DEC             100                             # DELAY 1 SEC

                TC              1LMP+DT                         # T+12
                DEC             127                             # RCS ASCENT FEED VALVE-SAFE
                DEC             100                             # DELAY 1 SEC

                TC              2LMP                            # T+13
                DEC             191                             # RCS MAIN S/O VALVES SYS B-OPEN RESET
                DEC             79                              # RCS ASCENT FEED VALVES SYS B-CLOSE RESET

                TC              MPRETRN                         # RETURN TO MISSION PROGRAM

## Page 762
# COME HERE IF WE GET A RESTART AFTER THE ENGINE IS ON & ULLAGE IS OFF.  SET UP SERVICER SWITCHES TO CAUSE THE
# BURN TO CONTINUE UNTIL PROPELLANT DEPLETION (UNLESS INTERRUPTED BY ENGINE FAILURE OR V74).  EXIT TO POOH AFTER
# SHUTDOWN IS DETECTED.

                EBANK=          TTGO

DUMMY13         EXTEND
                DCA             SVEX13AD
                DXCH            AVGEXIT

                CAF             TCGP2OFF                        # TO FINISH FEED TEST OR RESET (WHICH ARE
                TS              MPRETRN                         #     IN GROUP 2)

                EXTEND
                DCA             D13TRMAD
                DXCH            DVMNEXIT

                TC              FLAG1DWN                        # TO GET SERVICER TO RETURN THRU DVMNEXIT
                OCT             00020                           # WHATEVER CAUSES SHUTDOWN.

                CA              PGNSCADR
                TS              DVSELECT                        # (SHOULD BE THERE ALREADY.)

                TC              NEWMODEX                        # DISPLAY PROGRAM 47.
                OCT             47

                CA              POSMAX                          # DISPLAY LARGE TIME TO GO FOR DOWNLINK.
                TS              TTGO
                TS              TTGO            +1

                TC              TASKOVER

                EBANK=          TTGO
D13TRMAD        2CADR           DMY13TRM


DMY13TRM        TC              PHASCHNG
                OCT             40333                           # 3.33 IS TRMDMY13 TASK.
                INHINT
                CA              25SEC                           # INSURE THAT FEED ROUTINES ARE FINISHED.
                TC              WAITLIST
                EBANK=          TTGO
                2CADR           TRMDMY13

                TC              ENDOFJOB

TRMDMY13        TC              IBNKCALL
                CADR            ENGINOFF

                TC              1LMP
## Page 763
                DEC             135                             # ENGINE SELECT - ASCENT ARM OFF*

                TC              2PHSCHNG
                OCT             00003
                OCT             05012
                OCT             77777

                TC              FEEDREST

                TC              FLAG1DWN                        # AVERAGE G OFF & EXIT VIA POOH.
                OCT             00001

                TC              TASKOVER

25SEC           DEC             2500
