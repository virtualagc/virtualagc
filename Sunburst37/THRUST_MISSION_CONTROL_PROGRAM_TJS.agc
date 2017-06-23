### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    THRUST_MISSION_CONTROL_PROGRAM_TJS.agc
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
## Reference:   pp. 763-776
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-03 MAS  Transcribed.
##              2017-06-08 HG   Fix operand SETDVCNT -> DVSELECT
##                              Remove non existent section
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 763
# **SERVICER ROUTINES**

#       MOD NO. 00      MODIFICATION BY A. KOSMALA      NOV. 1966



#   *FUNCTIONAL DESCRIPTION*

#     THE THRUST MISSION CONTROL PROGRAM TJS IS USED BY ALL MISSION PHASES WHICH INCLUDE A BURN.

#     THE NORMAL ENTRY TO THE THRUST MISSION CONTROL PROGRAM IS THROUGH PREREAD.  PREREAD SCHEDULES THE JOB
# LASTBIAS.  BOOST PHASE ENTERS THE PREREAD ROUTINE AT BIBIBIAS, BYPASSING THE LASTBIAS JOB.  PIPS ARE CLEARED,
# AVERAGE G FLAG IS SET, DRIFT FLAG IS UNSET.  DV MONITOR AND FINDCUD ARE INITIALIZED, THE JOB NORMLIZE IS
# SCHEDULED, AND A WAITLIST CALL IS MADE TO START READACCS IN TWO SECONDS.

#     NORMLIZE PERFORMS THE SCALING AND INITIALIZATION REQUIRED PRIOR TO THE FIRST ENTRY TO AVERAGE G.

#     IN THE READACCS SECTION, THE ACCELEROMETERS ARE READ BY THE PIPASR SUBROUTINE.  IF THE AVERAGE G FLAG IS
# SET, READACCS IS CALLED TO RECYCLE IN TWO SECONDS.  IF THE AVERAGE G FLAG IS DOWN, AVERAGE G EXIT (AVEGEXIT)

# IS SET FOR THE FINAL PASS, AND READACCS IS NOT CALLED AGAIN.  IN EITHER CASE, THE SERVICER JOB IS ESTABLISHED.

#     THE SERVICER ROUTINE CHECKS FOR RUNAWAY PIPS (DELV GREATER THAN 3200 PULSES/SEC FOR 2 SEC) AND SENDS
# ALARM CODE 205 IF BAD PIP IS FOUND.  PIPS ARE COMPENSATED IN 1/PIPA SUBROUTINE, MASS IS UPDATED BY MASSMON
# SUBROUTINE, AND CONTROL IS TRANSFERRED TO THE MONITOR SPECIFIED BY DVSELECT.   DVSELECT IS SET BY THE BOOST
# PHASE TO BOOSTMON, AND BY THE ENGINEON ROUTINE TO PGNCSMON.  USERS STARTING SERVICER BEFORE THE ENGINE IS
# TURNED ON SHOULD INSURE BYPASSING DVMON INITIALLY BY SETTING DVSELECT TO THE GENADR OF AVERAGE G.

#     THE BOOST MONITOR (BOOSTMON) CHECKS DELV AGAINST THRSHLD+, THE THRESHOLD ACCELERATION FOR THE BOOST PHASE.
# IF DELV IS BELOW THRESHOLD, INDICATING TERMINATION OF BOOST, MISSION PHASE 6 IS SCHEDULED AS A JOB, DVSELECT

# IS ALTERED TO BYPASS BOOSTMON AND PROCEED DIRECTLY TO AVERAGE G.

#     THE PGNCS MONITOR (PGNCSMON) COMPARES ACTUAL THRUST TO THE THRESHOLD VALUE FOR THE +X ACCELERATION
# (100 CM/SEC).  IF THRUST IS FOUND BELOW THIS VALUE FOR TWO CYCLES (I.E., FOUR SECONDS) AS DETERMINED BY DVCNTR,
# A JOB IS SCHEDULED TO BRANCH TO THE LOCATION SPECIFIED BY DVMNEXIT, PREVIOUSLY SET BY THE USERS PROGRAM.
# DVSELECT IS ALTERED TO BYPASS PGNCSMON, AND CONTROL IS TRANSFERRED TO AVERAGE G.

#     THE AVERAGE G ROUTINE UPDATES RN, VN, AND GDT/2 VECTORS, USING THE SUBROUTINE CALCRVG.  THE NORMAL EXIT IS
# THROUGH AVEGEXIT, WHICH MUST PREVIOUSLY HAVE BEEN SET BY THE USER.  THE  FINAL EXIT, SET INTO AVEGEXIT BY
# READACCS WHEN IT  FINDS THE AVERAGE G FLAG DOWN, SETS UP FREE FALL GYRO COMPENSATION, SETS THE DRIFT FLAG ON,
# PERFORMS AVETOMID ROUTINE, AND TRANSFERS CONTROL TO POOH, THUS CLEARING  ALL ACTIVITY UNTIL A NEW MISSION
# PHASE IS DUE.


# ***** WARNING TO USERS *****

# THE USER MUST SET DVMNEXIT TO THE 2CADR OF A JOB TO BE PERFORMED WHEN ENGINE SHUTDOWN IS DETECTED BY SERVICER.
# IN GENERAL, THE AVERAGE G FLAG WILL BE TURNED OFF BY THE USER AT THAT TIME, ALLOWING JUST ONE MORE PASS THROUGH
# AVERAGE G.  ALL ACTIVITY OF THE USERS MISSION PHASE MUST HAVE BEEN COMPLETED BEFORE THIS LAST PASS THROUGH
# AVERAGE G, DUE TO THE PERFORMANCE OF POOH AS DESCRIBED ABOVE.

#     AVGEXIT MUST BE SET BY THE USER TO THE 2CADR OF THE JOB (E.G., STEERING) TO BE PERFORMED AFTER EACH PASS
## Page 764
# THROUGH AVERAGE G.  IF NO OTHER JOB IS TO BE DONE, AVEGEXIT SHOULD BE SET TO SERVEXIT.


#     USER MUST INITIALIZE DVSELECT TO THE GENADR OF AVERAGE G UNLESS THE ENGINEON ROUTINE HAS BEEN PERFORMED
# BEFORE THE START OF SERVICER.

#     USERS (EXCEPT FOR BOOST PHASE) MUST PERFORM MTDTOAVE ROUTINE BEFORE STARTING PREREAD.



# CALLING SEQUENCE IS NORMAL WAITLIST CALL FOR PREREAD.  (READACCS WILL START TWO SECONDS LATER.)

## Page 765
# SUBROUTINES CALLED

# LASTBIAS  PIPASR  FLAG1UP  FLAG2DWN  NORMLIZE  READACCS  SERVICER  1/PIPA  MASSMON  AVERAGE G  CALCRVG
# PHASCHNG  AVETOMID  POOH



# NORMAL EXIT MODES .. AVEGEXIT, DVMNEXIT, TASKOVER, ENDOFJOB.


# ALARM CODE 205 GIVEN IF RUNAWAY PIP.  PROGRAM THEN CONTINUES IN NORMAL SEQUENCE.



#     ERASABLE INITIALIZATION REQUIRED

#                MASS .. INITIALIZED IN ERASABLE LOAD
#                RAVEGON AND VAVEGON .. INITIALIZED IN ERASABLE LOAD - UPDATED BEFORE EACH CALL FOR PREREAD.



# OUTPUT

# DELV(6)  RN(6)  VN(6)  GDT/2(6)  CDUTEMP(6)  MASS(2)  DELAREA(2)  PIPTIME(2)  OLDBT1(1)



# DEBRIS

#      CENTRALS ... A, L, Q

#      OTHER .... DVCNTR, ITEMP1, ITEMP2, RN1(6), VN1(6), GDT1/2(6), DAREATMP(2), MASSTEMP(2), PIPAGE, TEMX,

#                 TEMY, TEMZ, TEMXY, PIPCTR


#     *** THRUST MISSION CONTROL IS RESTART PROTECTED AND USES RESTART GROUP 5. *** 



                BANK            30
                EBANK=          DVCNTR
# *************************************   PREREAD   **************************************************************

PREREAD         TC              PHASCHNG
                OCT             07015
                OCT             77777

                EBANK=          DVCNTR
## Page 766
                2CADR           BIBIBIAS                # SKIP LASTBIAS AFTER RESTART


                CAF             PRIO32
                TC              NOVAC
                EBANK=          NBDX
                2CADR           LASTBIAS                # DO LAST GYRO COMPENSATION IN FREE FALL

BIBIBIAS        EXTEND
                DCA             PIP2CADR                # CLEAR + READ PIPS LAST TIME IN FREE FALL
                DXCH            Z

                TC              FLAG1UP                 # SET AVEG FLAG
                OCT             1


                TC              FLAG2DWN                # KNOCK DOWN DRIFT FLAG
                OCT             40000

                CAF             ONE                     # INITIALIZE DV MONITOR
                TS              DVCNTR
                CAF             EBANK4
                TS              EBANK
                EBANK=          AXIS                    # CORCT IS DEAD, LONG LIVE AXIS

                CAF             BIT14                   # INITIALIZE AXIS TO (0.5,0,0)
                TS              AXIS                    # FOR FINDCDUD
                CAF             ZERO
                TS              AXIS            +1
                TS              AXIS            +2
                TS              AXIS            +3
                TS              AXIS            +4
                TS              AXIS            +5

                CAF             PRIO21                  # SET UP TO DO NORMLIZE REQUIRED PRIOR
                TC              FINDVAC                 # TO FIRST ENTRY TO AVERAGE G.
                EBANK=          RAVEGON
                2CADR           NORMLIZE


                CAF             200DEC
                TC              WAITLIST
                EBANK=          DVCNTR
                2CADR           READACCS

                TC              PHASCHNG
                OCT             40025

                TCF             TASKOVER

## Page 767
# *************************************   READACCS   *************************************************************
                EBANK=          NEGXDV
READACCS        EXTEND
                DCA             PIP2CADR
                DXCH            Z                       # CALL PIPASR
                CCS             PHASE5                  # LAST PASS CHECK

                TCF             +2
                TCF             TASKOVER
                CS              PHASE5                  # THESE 4 INSTRUCTIONS ONLY IN FOR
                AD              FIVE                    # FAKESTART.  REMOVE IF REAL RESTARTS
                EXTEND                                  # RETURN.
                BZF             TASKOVER

PIPSDONE        TC              PHASCHNG
                OCT             05015
                OCT             77777

                CAF             TWO                     # SHOW PIPS HAVE BEEN READ FOR REREADAC

                TS              PIPAGE

CHEKAVEG        CS              FLAGWRD1
                MASK            BIT1
                CCS             A                       # IF AVEG FLAG DOWN SET FINAL EXIT AVEG
                TC              AVEGOUT

                CAF             200DEC                  # READ PIPS AT 2 SECOND INTERVALS
                TC              WAITLIST
                EBANK=          BMEMORY

                2CADR           READACCS

MAKESERV        CAF             PRIO20                  # ESTABLISH SERVICER ROUTINE
                TC              FINDVAC
                EBANK=          BMEMORY
                2CADR           SERVICER

                TC              PHASCHNG                # RESTART SERVICER AND READACCS
                OCT             40065                   # SEE RESTART TABLES

                TCF             TASKOVER                # END PREVIOUS READACCS WAITLIST TASK


                EBANK=          BMEMORY
PIP2CADR        2CADR           PIPASR

AVEGOUT         EXTEND
                DCA             AVOUTCAD
                DXCH            AVGEXIT
                TCF             MAKESERV

                EBANK=          BMEMORY
AVOUTCAD        2CADR           AVGEND

## Page 768
# *************************************   SERVICER   *************************************************************
# 


# DO SAVEM AND RESTOREM LATER IF NORMAL RESTARTS SHOULD EVER RETURN

SERVICER        CAF             TWO
PIPCHECK        TS              PIPCTR

                DOUBLE
                INDEX           A
                CCS             DELVX
                TC              +2

                TC              PIPLOOP

                AD              -MAXDELV                # DO PIPA-SATURATION TEST BEFORE
                EXTEND
                BZMF            PIPLOOP                 # COMPENSATION.

                TC              ALARM
                OCT             00205                   # SATURATED-PIPA ALARM
                TC              AVERAGEG

PIPLOOP         CCS             PIPCTR
                TCF             PIPCHECK


                TC              PHASCHNG                # RESTART REREADAC + SERVICER
                OCT             16035
                OCT             20000
                EBANK=          BMEMORY
                2CADR           GOMASS

                TC              BANKCALL                # PIPA COMPENSATION CALL
                CADR            1/PIPA

GOMASS          TC              INTPRET
                VLOAD           ABVAL
                                DELV
                STCALL          ABDELV
                                MASSMON

                EXIT
                TC              DVSELECT
AGSMON          EQUALS          AVERAGEG

-MAXDELV        DEC             -6398                   # 3200 PULSES/SEC FOR 2 SEC.  CCS TAKES 1.
PLUSXDVA        DEC             90                      # 90 CM/SEC = ASCENT THRESHOLD
200DEC          DEC             200


PLUSXDVD        DEC             50                      # 50 CM/SEC = DESCENT THRESHOLD
PGNCSMON        CAF             BIT2                    # CHECK CHANNEL 30 TO SEE IF STAGING HAS
## Page 769
                EXTEND                                  # OCCURRED.  IF BIT2 IS ON WE ARE UNSTAGED
                RAND            30                      # AND DESCENT PLUSXDV IS USED -- OTHERWISE
                INDEX           A                       # THE ASCENT PLUSXDV IS EMPLOYED.
                CS              PLUSXDVA
                AD              ABDELV                  # ACCELERATION
                EXTEND
                BZMF            THRUSTLO


RESETDV         CAF             ONE
                TS              DVCNTR                  # THRUST OK. RESET DV MONITOR AND
                TCF             AVERAGEG                # BRANCH TO AVERAGEG

THRUSTLO        CA              DVCNTR
                EXTEND
                BZMF            NODV
                TC              PHASCHNG
                OCT             12035
                EBANK=          DVCNTR

                2CADR           AVERAGEG

                EXTEND
                DIM             DVCNTR
                TCF             AVERAGEG

NODV            CAF             PRIO30                  # SET UP HIGH PRIO FINDVAC TO DVEXIT
                INHINT
                TC              FINDVAC
                EBANK=          DVCNTR
                2CADR           DVEXIT


                TCF             DVMNKILL        -1      # AND REMOVE DV MONITOR

DVEXIT          EXTEND                                  # BRANCH TO SELECTED LOCATION
                DCA             DVMNEXIT
                DXCH            Z

BOOSTMON        CS              ABDELV                  # COMPARE ABDELV TO THRSHLD+ TO DETECT
                AD              THRSHLD+                # BOOSTER SHUTDOWN
                EXTEND
                BZMF            RESETDV

                INHINT                                  # SHUTDOWN HAS OCCURRED
                CAF             PRIO20
                TC              NOVAC                   # SET UP MISSION PHASE 6 JOB
                EBANK=          BMEMORY
                2CADR           MP6JOB                  # NO VAC AREA NEEDED

 -1             RELINT
DVMNKILL        CAF             AVEGADDR                # REMOVE DV MONITOR FROM SERVICER
                TS              DVSELECT

## Page 770
AVEGADDR        TC              AVERAGEG

THRSHLD+        2DEC            0.                      # TEMPORARY **************** PLEASE PATCH


# *********************************   FLAG SUBROUTINES   *********************************************************

                BLOCK           03
#    THE FLAG SUBROUTINES ARE USED TO SET OR RESET FLAGS (BITS) IN FLAGWRD1 AND FLAGWRD2. THE BIT(S) TO BE SET OR
# RESET IS(ARE) INDICATED BY THE OCTAL NUMBER FOLLOWING THE TC CALL. THE CALLING SEQUENCES ARE -

#                                                  TC     FLAG1UP         SET BIT(S) IN FLAGWRD1 CORRESPONDING TO

#                                                  OCT    XXXXX           THE 1 BITS IN NUMBER XXXXX.

#                                                  TC     FLAG1DWN        RESET BIT(S) IN FLAGWRD1 CORRESPONDING
#                                                  OCT    XXXXX           TO THE 1 BITS IN NUMBER XXXXX.

# THE CALLING SEQUENCES FOR FLAGWRD2 ARE SIMILAR.

#    NOTE THAT FLAGWRD1 AND FLAGWRD2 CORRESPOND TO INTERPRETIVE SWITCHES 15D THROUGH 44D.

#          FLAGWORD BITS ARE DEFINED IN LOG SECTION "ERASABLE ASSIGNMENTS"

FLAG1UP         INHINT                                  # SET FLAG 1 SUBROUTINE
                CS              FLAGWRD1
                INDEX           Q
                MASK            0
                ADS             FLAGWRD1

                RELINT
                TCF             Q+1

FLAG2UP         INHINT                                  # SET FLAG 2 SUBROUTINE
                CS              FLAGWRD2
                INDEX           Q

                MASK            0
                ADS             FLAGWRD2

                RELINT
                TCF             Q+1

FLAG1DWN        INDEX           Q                       # RESET FLAG 1 SUBROUTINE
                CS              0
                INHINT
                MASK            FLAGWRD1

                TS              FLAGWRD1
                RELINT
                TCF             Q+1

## Page 771
FLAG2DWN        INDEX           Q                       # RESET FLAG 2 SUBROUTINE
                CS              0
                INHINT
                MASK            FLAGWRD2
                TS              FLAGWRD2
                RELINT

                TCF             Q+1

                EBANK=          TDEC
# ******************************************ENGINE ON-OFF ROUTINES**********************************************

# ALL BLOCK 2 COMPUTERS HAVE THE ENGINE-ON AND ENGINE-OFF DISCRETES IN BITS 13 AND 14 RESPECTIVELY OF CHANNEL 11.
# IF LEM DESCENT ENGINE SEES A 1,1 CONDITION (BOTH OUTPUT TRANSISTORS CONDUCTING) OR A 0,0 CONDITION (BOTH OUTPUT
# TRANSISTORS NON-CONDUCTING) THEY WILL IGNORE THE SIGNAL AND REMAIN IN THE STATE THEY WERE PREVIOUSLY IN. THIS
# ALLOWS THE COMPUTER TO ZERO ALL THE OUTPUT BITS DURING A RESTART AND NOT SHUT THE ENGINE OFF. THERE IS NO TIME
# LIMIT AS TO HOW LONG AN IMPROPER STATE (1,1) OR (0,0) CAN LAST WITH DESCENT ENGINE.

# THE LEM ASCENT ENGINE WILL BE TURNED ON BY AN ERRONEOUS 1,1 CONDITION WHICH LASTS LONGER THAN 1 MILLISECOND,

# THEREFORE THE LGC MUST BE PROGRAMMED TO SET THE BITS TO THE PROPER STATE WITHIN 0.5 MILLISECOND FOLLOWING
# RECOVERY FROM A RESTART

# ENGINE ON AND OFF COMMANDS ARE NOTED IN THE EVENT REGISTERS FOR
# DOWNLINK.  IF IT IS DESIRED TO SIMPLY ENSURE ENGINE OFF PRIOR TO AN
# ENGINE ARM COMMAND, ENGINEOF1 SHOULD BE USED SO THAT EVENT IS NOT
# ENTERED IN DOWNLINK.

ENGINEON        EXTEND
                DCA             TIME2                   # ENG ON EVENT NOTED IN DOWNLINK

                DXCH            TEVENT

                CA              PGNSCADR                # SET DVMONITOR TO EXPECT THRUST
                TS              DVSELECT

                CS              PRIO30                  # ENGINE ON BIT13.  ENGINE OFF BIT14
                EXTEND                                 
                RAND            11
                AD              BIT13
                EXTEND
                WRITE           11
                TC              Q
                

                
                
PGNSCADR        GENADR          PGNCSMON

ENGINOFF        EXTEND
                DCA             TIME2                   # NOTE ENGINE OFF EVENT TO DOWNLINK
                DXCH            TEVENT

ENGINOF1        CS              PRIOR30                 # NO DWNLINK HERE
## Page 772
                EXTEND
                RAND            11

                AD              BIT14
                EXTEND
                WRITE           11
                TC              Q                       # RETURN
                
PRIOR30         EQUALS          PRIO30

QTEMP           EQUALS          TEMX

                BANK            30

#



                EBANK=          DVTOTAL
AVERAGEG        TC              INTPRET
                CALL
                                CALCRVG
                EXIT

                TC              PHASCHNG
                OCT             10035

COPYCYCL        INHINT
                CAF             EIGHT
                TS              ITEMP1
                DOUBLE
                TS              ITEMP2
                EXTEND
                INDEX           ITEMP2
                DCA             RN1
                INDEX           ITEMP2

                DXCH            RN
                CCS             ITEMP1
                TCF             COPYCYCL        +2
                EXTEND
                DCA             DAREATMP
                DXCH            DELAREA
                EXTEND
                DCA             MASSTEMP
                DXCH            MASS
                EXTEND
                DCA             PIPTIME
                DXCH            STATIME                 # STATE VECTOR TIME FOR DWNLINK

                RELINT

                TC              PHASCHNG
                OCT             10035

## Page 773
                EXTEND
                DCA             AVGEXIT
                DXCH            Z                       # AVERAGEG EXIT

AVGEND          CA              PIPTIME         +1      # FINAL AVERAGE G EXIT
                TS              OLDBT1                  # SET UP FREE FALL GYRO COMPENSATION

                TC              FLAG2UP                 # SET DRIFT FLAG

                OCT             40000

                EXTEND
                DCA             AVEMIDAD                # TRANSFER STATE VECTOR VIA AVETOMID
                DXCH            Z

                TC              PHASCHNG
                OCT             55                      # *** MEANS INACTIVE ONLY FOR FAKESTRT

                CS              FOUR

                AD              PHASENUM
                EXTEND
                BZF             ENDOFJOB

                TCF             POOH

SERVEXIT        TC              PHASCHNG
                OCT             00035

                TCF             ENDOFJOB

                EBANK=          AVMIDRTN

AVEMIDAD        2CADR           AVETOMID

## Page 774
#    NORMLIZE PERFORMS THE INITIALIZATION REQUIRED PRIOR TO THE FIRST ENTRY TO AVERAGEG, AND SCALES RN SO THAT IT

# HAS 1 LEADING BINARY ZERO. IN MOST MISSIONS, RN WILL BE SCALED AT 2(+29), BUT IN THE 206 MISSION, RN WILL BE
# SCALED AT 2(+24)M.  TIME OF RN,VN IS IN STATIME FOR DWNLINK


                EBANK=          RAVEGON
NORMLIZE        INHINT
                EBANK=          TDEC
                CAF             EBANK4
                XCH             EBANK
                TS              RUPTREG2
                CAF             ELEVEN                  # INITIALIZE INDEX-DEC 11

                TS              RUPTREG1
                INDEX           RUPTREG1
                CA              RAVEGON
                INDEX           RUPTREG1
                TS              RN                      # STORE RN, VN
                CCS             RUPTREG1
                TCF             NORMLIZE        +2
                EXTEND
                DCA             TAVEGON
                DXCH            STATIME                 # STATE TIME FOR DWNLINK

                CA              RUPTREG2
                TS              EBANK
                RELINT
                TC              INTPRET
                CALL
                                CALCGRAV                # INITIALIZE UNITR RMAG GDT1
                STORE           GDT/2

                EXIT
                TCF             ENDOFJOB

## Page 775
#    VPATCHER IS AN ADAPTATION OF NORMLIZE WHICH IS CALLED AFTER MIDTOAVE HAS BEEN PERFORMED AND PRIOR TO
# PREBURN PROGRAMS THAT REQUIRE IGNITION STATE POSITION, VELOCITY, AND GRAVITY VECTORS IN REGISTERS RN,VN, AND
# GDT/2.  THE REGISTERS ARE RE-INITIALIZED BY NORMLIZE WHEN PREREAD CALLEDRED BY NORMLIZE WHEN PREREAD IS CALLED


# NAME=               DATE=
#    VPATCHER            20 OCTOBER 1966
# PROGRAMMER          SUBROUTINES CALLED
#    SCHULENBERG         CALCGRAV

# CALLING SEQUENCE
#    IF IN BASIC   L-1 TC      INTPRET
#                  L   CALL    VPATCHER
#                  L+1 EXIT
# NORMAL EXIT
#    AT L+1 OF CALLING SEQUENCE
# DEBRIS
#    RN, VN, GDT/2, UNITR, RMAG

# OUTPUT
#    RIGNITION IN RN*2(+24)M
#    VIGNITION IN VN*2(+7)M/CS
#    GDT/2 AT IGNITION IN GDT/2*2(+7)M/CS
#    UNIT RIGNITION IN UNITR *2(+1)M
#    RMAG AT 2(+24)M

VPATCHER        STQ
                                QTEMP
                EXIT
                INHINT
                EBANK=          TDEC
                CAF             EBANK4
                XCH             EBANK
                TS              RUPTREG2
                CAF             ELEVEN                  # INITIALIZE INDEX TO DEC 11
VPATLOOP        TS              RUPTREG1
                INDEX           RUPTREG1
                CA              RIGNTION
                INDEX           RUPTREG1
                TS              RN                      # STORE RN,VN

                CCS             RUPTREG1
                TCF             VPATLOOP
                EXTEND
                DCA             TIGN
                DXCH            STATIME                 # STATE TIME FOR DWNLINK
                CA              RUPTREG2
                TS              EBANK
                RELINT
                TC              INTPRET
## Page 776
                CALL
                                CALCGRAV

                STORE           GDT/2

                GOTO
                                QTEMP
