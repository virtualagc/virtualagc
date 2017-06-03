### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    206_SERVICER_ROUTINES.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-16 MAS  Began transcription.
##              2016-10-17 MAS  Completed transcribing/disassembling/reconstructing. There are gaps in
##                              comments, but instruction-wise it should be pretty close.
##		2016-12-06 RSB	Comments proofed using octopus/ProoferComments,
##				changes made, though the general quality of the printout in this
##				section makes this a less-convincing procedure than it would normally
##				be.
##              2017-06-03 MAS  Pulled in corrections from the Shepatin 0 / Sunburst 37 transcription.

## Page 815
# **SERVICER ROUTINES**
#       MOD NO. 00      MODIFICATION BY A. KOSMALA      NOV. 1966
#       MOD NO.  1      MODIFICATION BY D. LICKLY       JAN 1967
#   *FUNCTIONAL DESCRIPTION*

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
# SUBROUTINE, AND  AVERAGEG DOES THE NAVIGATION.  THE AVERAGE G ROUTINE UPDATES RN, VN, AND GDT/2 VECTORS, USING
# THE SUBROUTINE CALCRVG.  CONTROL IS THEN TRANSFERRED TO THE MONITOR SPECIFIED BY DVSELECT.  DVSELECT IS SET BY
# THE BOOST PHASE TO BOOSTMON, AND BY THE ENGINEON ROUTINE TO THE PGNCSMON.  USERS STARTING SERVICER BEFORE THE
# ENGINE IS ON SHOULD INSURE BYPASSING DVMON INITIALLY BY SETTING DVSELECT TO THE GENADR OF AVERAGE G.

#     THE BOOST MONITOR (BOOSTMON) CHECKS DELV AGAINST THRSHLD+, THE THRESHOLD ACCELERATION FOR THE BOOST PHASE.
# IF DELV IS BELOW THRESHOLD, INDICATING TERMINATION OF BOOST, MISSION PHASE 6 IS SCHEDULED AS A JOB, DVSELECT
# IS ALTERED TO BYPASS BOOSTMON AND PROCEED DIRECTLY TO AVERAGE G.

#     THE PGNCS MONITOR (PGNCSMON) COMPARES ACTUAL THRUST TO THE THRESHOLD VALUE FOR THE +X ACCELERATION
# (100 CM/SEC).  IF THRUST IS FOUND BELOW THIS VALUE FOR 3 CYCLES (I.E., 4 TO 6 SECONDS) AS DETERMINED BY DVCNTR,
# AND THE ENGINE FLAG IS REMOVED, (INDICATING THAT THE ENGINE HAS BEEN TURNED OFF) CONTROL IS BRANCHED TO THE
# LOCATION SPECIFIED BY DVMNEXIT, PREVIOUSLY SET BY THE USERS PROGRAM.  DVSELECT IS ALTERED TO BYPASS PNGCSMON IN
# SUBSEQUENT PASSES.  IF, HOWEVER, THE ENGINE FLAG IS STILL ON AT THIS TIME, CONTROL IS TRANSFERRED TO ENGNFAIL.
# THIS SENDS ALARM CODE 1405 AND KILLS THAT MISSION PHASE.  ANY TIME THE THRUST IS LESS THAN THE THRESHOLD VALUE,
# THE STEERING IS DETACHED (NO EXIT VIA AVEGEXIT) AND EXIT IS MADE THRU SERVEXIT.

#     THE NORMAL EXIT IS THRU AVEGEXIT, WHICH MUST HAVE BEEN SET BY THE USER. THE FINAL EXIT, SET INTO AVEGEXIT BY
# READACCS WHEN IT  FINDS THE AVERAGE G FLAG DOWN, SETS UP FREE FALL GYRO COMPENSATION, SETS THE DRIFT FLAG ON,
# PERFORMS AVETOMID ROUTINE, AND TRANSFERS CONTROL TO POOH, THUS CLEARING  ALL ACTIVITY UNTIL A NEW MISSION
# PHASE IS DUE.

# ***** WARNING TO USERS *****

# THE USER MUST SET DVMNEXIT TO THE 2CADR OF A JOB TO BE PERFORMED WHEN ENGINE SHUTDOWN IS DETECTED BY SERVICER.
# IN GENERAL, THE AVERAGE G FLAG WILL BE TURNED OFF BY THE USER AT THAT TIME, ALLOWING JUST ONE MORE PASS THROUGH
# AVERAGE G.  ALL ACTIVITY OF THE USERS MISSION PHASE MUST HAVE BEEN COMPLETED BEFORE THIS LAST PASS THROUGH
# AVERAGE G, DUE TO THE PERFORMANCE OF POOH AS DESCRIBED ABOVE.

#     AVGEXIT MUST BE SET BY THE USER TO THE 2CADR OF THE JOB (E.G., STEERING) TO BE PERFORMED AFTER EACH PASS
# THROUGH AVERAGE G.  IF NO OTHER JOB IS TO BE DONE, AVEGEXIT SHOULD BE SET TO SERVEXIT.

## Page 816
#     USER MUST INITIALIZE DVSELECT TO THE GENADR OF AVERAGE G UNLESS THE ENGINEON ROUTINE HAS BEEN PERFORMED
# BEFORE THE START OF SERVICER.

#     USERS (EXCEPT FOR BOOST PHASE) MUST PERFORM MTDTOAVE ROUTINE BEFORE STARTING PREREAD.

# CALLING SEQUENCE IS NORMAL WAITLIST CALL FOR PREREAD.  (READACCS WILL START TWO SECONDS LATER.)


# SUBROUTINES CALLED

# LASTBIAS  PIPASR  FLAG1UP  FLAG2DWN  NORMLIZE  READACCS  SERVICER  1/PIPA  MASSMON  AVERAGE G  CALCRVG
# PHASCHNG  AVETOMID  POOH FORGETIT


# NORMAL EXIT MODES .. AVEGEXIT, DVMNEXIT, TASKOVER, ENDOFJOB.

# ALARM CODE 205 GIVEN IF RUNAWAY PIP.  PROGRAM THEN CONTINUES IN NORMAL SEQUENCE.
# ALARM CODE 1405 GIVEN IF ENGINE FAILURE IS DETECTED.  PROGRAM THEN TERMINATES THE MISSION PHASE. (TO FORGETIT)


#     ERASABLE INITIALIZATION REQUIRED

#                MASS .. INITIALIZED IN ERASABLE LOAD
#                RAVEGON AND VAVEGON .. INITIALIZED IN ERASABLE LOAD - UPDATED BEFORE EACH CALL FOR PREREAD.


# OUTPUT

# DELV(6)  RN(6)  VN(6)  GDT/2(6)  CDUTEMP(6)  MASS(2)  DELAREA(2)  PIPTIME(2)  OLDBT1(1)


# DEBRIS

#      CENTRALS ... A, L, Q

#      OTHER .... DVCNTR, ITEMP1, ITEMP2, RN1(6), VN1(6), GDT1/2(6), DAREATMP(2), MASSTEMP(2), PIPAGE, TEMX,

#                 TEMY, TEMZ, TEMXY, PIPCTR


#    *** THRUST MISSION CONTROL IS RESTART PROTECTED AND USES RESTART GROUP 5. *** 

## Page 817
                BANK            30
                EBANK=          DVCNTR
# *************************************             **************************************************************

PREREAD         TC              PHASCHNG
                OCT             07015
                OCT             77777

                EBANK=          DVCNTR
                2CADR           BIBIBIAS                        # SKIP LASTBIAS AFTER RESTART

                CAF             PRIO32
                TC              NOVAC
                EBANK=          NBDX
                2CADR           LASTBIAS                        # DO LAST GYRO COMPENSATION IN FREE FALL

BIBIBIAS        TC              PIPASR                          # CLEAR + READ PIPS LAST TIME IN FREE FALL

                TC              FLAG1UP                         # SET AVEG FLAG
                OCT             1

                CA              STARTDVC                        # * PLEASE DONT MOVE-DVCNTR SHOULD BE
## The following line was not printed, and has been disassembled from the octal listing. Unfortunately, we
## may never know why CA STARTDVC should not be moved.
                TS              DVCNTR

                TC              FLAG2DWN                        # KNOCK DOWN DRIFT FLAG
                OCT             40000

                CAF             EBANK4
                TS              EBANK
                EBANK=          AXIS                            # CORCT IS DEAD, LONG LIVE AXIS

                CAF             BIT14                           # INITIALIZE AXIS TO (0.5,0,0)
                TS              AXIS                            # FOR FINDCDUD
                CAF             ZERO
                TS              AXIS            +1
                TS              AXIS            +2
                TS              AXIS            +3
                TS              AXIS            +4
                TS              AXIS            +5

                CAF             TWO                             # DIRECT REREADAC TO READACCS IN CASE
                TS              PIPAGE                          # OF A RESTART

                CAF             PRIO21                          # SET UP TO DO NORMLIZE REQUIRED PRIOR
                TC              FINDVAC                         # TO FIRST ENTRY TO AVERAGE G.
                EBANK=          RAVEGON
                2CADR           NORMLIZE

## The following line was not printed, and has been disassembled from the octal listing. In its place comes the
## page header for page 818, which shares the same physical page as 817.
                CAF             200DEC
## Page 818
                TC              WAITLIST
                EBANK=          DVCNTR
                2CADR           READACCS

## The following line was not printed, and has been disassembled from the octal listing.
                TC              PHASCHNG
                OCT             40025
## The following line was not printed, and has been disassembled from the octal listing.
                TCF             TASKOVER

## Page 819
# *************************************   READACCS   *************************************************************
                EBANK=          NEGXDV
READACCS        CS              T5ADR                   # TO PREVENT LOST DOWNRUPTS, ADJUST THE
                AD              FILTAD                  # RELATIVE PHASING BETWEEN READACCS AND
                EXTEND                                  # DAP FOR MINIMUM INTERFERENCE. THESE
                BZF             WASFILT                 # TESTS ARE NECESSARY ONLY WHEN THE TRIM
                                                        # GIMBAL IS BEING USED, BUT IT TAKES TOO
                CS              T5ADR                   # LONG TO CHECK FOR THIS SITUATION TO BE
                AD              GTSAD                   # WORTH IT.
                EXTEND
                BZF             SLIPONE
                TCF             PIPREAD

WASFILT         CS              TIME5
                AD              POSMAX
                EXTEND
                BZF             SLIPONE

PIPREAD         TC              PIPASR

PIPSDONE        EXTEND                                  # SUPER HIGH-SPEED PHASE CHANGE TO
                DCA             5.31SET                 # MINIMIZE THE TIME SPENT IN THE READACCS
                DXCH            -PHASE5                 # TASK.

REDO5.31        CAF             TWO                     # SHOW PIPS HAVE BEEN READ FOR REREADAC.
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

                EXTEND                                  # HIGH SPEED PHASE CHANGE.
                DCA             5.6SET                  # 5.6 FOR REREADAC TASK & SERVICER JOB.
                DXCH            -PHASE5
                CS              TIME1                   # SET TBASE.
                TS              TBASE5

                TCF             TASKOVER                # END PREVIOUS READACCS WAITLIST TASK

## Page 820
                EBANK=          BMEMORY
PIP2CADR        2CADR           PIPASR
## The printer skipped a line here, but only failed to print the second word of the 2CADR.

AVEGOUT         CA              AVOUTADR
                TS              DVSELECT
                TCF             MAKESERV

SLIPONE         CS              ONE                     # RESCHEDULE DAP EVENT TO OCCUR 10 MS
                ADS             TIME5                   # FARTHER INTO THE FUTURE.
## The following line wasn't printed. It was instead disassembled from the octal listing and symbol table.
                TCF             PIPREAD

## The following two lines were printed on top of each other. The line after them wasn't printed at all.
## They were teased apart, reconstructed, and put in the right places with help from the octal listing 
## and the symbol table.
AVOUTADR        GENADR          AVGEND
FILTAD          GENADR          FILTER
GTSAD           GENADR          GTS
## End of reconstructed lines.

5.31SET         2OCT            7774600031

5.6SET          2OCT            7777100006

## Page 821

# DO SAVEM AND RESTOREM LATER IF NORMAL RESTARTS SHOULD EVER RETURN

SERVICER        CAF             TWO
PIPCHECK        TS              PIPCTR

                DOUBLE
                INDEX           A
## The next 10 lines were printed on only 2. I'm not sure the exact distribution, but it seems likely that they
## were split evenly between the two. They were disassembled from the octal section, with help from the symbol
## table. For the first line, I have chosen DELVX rather than DELV to match SERVICER207 in Colossus 237.
## Fragments of comments were also printed on the second line. They read:
## "   O UE    T [DP] [P.]      M"
## where characters in brackets were printed on top of each other. In place of the original comments, I have 
## transplanted comments from the SERVICER207 section of Colossus 237, which closely mirrors this. They roughly
## align with the the above string, and so are likely close to correct.
                CCS             DELVX
                TC              +2
                TC              PIPLOOP

                AD              -MAXDELV                        # DO PIPA-SATURATION TEST BEFORE
                EXTEND
                BZMF            PIPLOOP                         # COMPENSATION.

                TC              ALARM
                OCT             00205                           # SATURATED-PIPA ALARM  ***CHANGE LATER
                TCF             +3

PIPLOOP         CCS             PIPCTR
## End of disassembled lines.
                TCF             PIPCHECK

                TC              PHASCHNG                        # RESTART REREADAC + SERVICER
                OCT             16035
                OCT             20000
                EBANK=          BMEMORY
                2CADR           GOMASS

                TC              BANKCALL                        # PIPA COMPENSATION CALL
                CADR            1/PIPA

GOMASS          TC              INTPRET
                VLOAD           ABVAL
                                DELV
                STCALL          ABDELV
                                MASSMON
                CALL
## The following line wasn't printed. It was disassembled from the octal listing and symbol table.
                                CALCRVG
                EXIT
## In the right margin is written in green marker "engineon  pg 480".

                TC              PHASCHNG
                OCT             10035

COPYCYCL        INHINT
                CAF             EIGHT
                TS              ITEMP1
## Page 822
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
                DXCH            STATIME                 # STATE VECTOR TIME FOR DOWNLINK.

                CAF             BIT4                    #  SIVBGONE BIT
                MASK            FLAGWRD1
                EXTEND
                BZF             CHGPHASE

                CAF             PRIO34
                TC              NOVAC
                EBANK=          DT
                2BCADR          1/ACCS

CHGPHASE        TC              PHASCHNG
                OCT             10035

                TC              DVSELECT
## An arrow is drawn in green marker from the above instruction down to BIT2 lon the PGNCSMON line below.


AGSMON          EQUALS          AVERAGEG

-MAXDELV        DEC             -6398                   # 3200 PULSES/SEC FOR 2 SEC.  CCS TAKES 1.

# **************************************************MAINTAIN THE ORDER OF THE CONSTANTS BETWEEN THE ASTERISKS.
PLUSXDVA        DEC             400                     # 200 CM/SEC(2)= ASCENT THRESHOLD
200DEC          DEC             200
PLUSXDVD        DEC             45                      # 22.5 CM/SEC SQ = DESCENT THRESHHOLD.
# **************************************************

PGNCSMON        CAF             BIT2                    # CHECK CHANNEL 30 TO SEE IF STAGING HAS
## The following line wasn't printed. It has been taken from Sunburst 37/Shepatin 0.
                EXTEND                                  # OCCURRED.  IF BIT2 IS ON WE ARE UNSTAGED

## There is a completely empty page in the listing here. Instructions continue on the next page, with no
## page break header from Yul.
                RAND            30                      # AND DESCENT PLUSXDV IS USED -- OTHERWISE
                INDEX           A                       # THE ASCENT PLUSXDV IS EMPLOYED.

## Page 823
## The next six lines were printed on only two (or maybe three, the header is also garbled). They have
## been disassembled from the octal listing and symbol table. A few comment fragments made it through
## on the last garbled line. They read:
## " HRUS   IS  K   R S    H  DV M  I  R"
## A single-word comment was pulled in from Sunburst 37/Shepatin 0. Given other context, the above
## letters are likely part of something like "THRUST IS OK -- RESET <something> DV MONITOR"
                CS              PLUSXDVA
                AD              ABDELV                  # ACCELERATION
                EXTEND
                BZMF            THRUSTLO
                CA              SETDVCNT
                TS              DVCNTR
## End of disassembled lines.

AVERAGEG        TC              PHASCHNG
## The following line was not printed. It was taken from the octal listing, and follows other PHASCHG
## calling patterns.
                OCT             10035
                EXTEND
                DCA             AVGEXIT
                DXCH            Z                       # AVERAGEG EXIT


## The following three instructions are circled in green marker, with a small checkmark drawn next to DVCNTR.
THRUSTLO        CCS             DVCNTR
                TCF             SERVEXIT        -1      # NO STEERING IF NO THRUST.
NODV            CA              FLAGWRD1
                MASK            BIT5
## The following line was not printed. It was disassembled from the octal listing.
                CCS             A
                TCF             ENGNFAIL                # YES.  GIVE FAIL ALARM.
                TC              PHASCHNG                # NO.  GO OUT THRU DVMNEXIT.
                OCT             10035

## The following two instructions have a box drawn around them in green marker.
                CAF             AVEGADDR                # REMOVE DV MONITOR.
                TS              DVSELECT

DVEXIT          EXTEND                                  # BRANCH TO SELECTED LOCATION
                DCA             DVMNEXIT
                DXCH            Z

BOOSTMON        CS              ABDELV                  # COMPARE ABDELV TO THRSHLD+ TO DETECT
                AD              THRSHLD+                # BOOSTER SHUTDOWN
                EXTEND
                BZMF            AVERAGEG

                INHINT                                  # SHUTDOWN HAS OCCURRED
                CAF             PRIO20
                TC              NOVAC                   # SET UP MISSION PHASE 6 JOB
                EBANK=          BMEMORY
                2CADR           MP6JOB			# NO VAC AREA NEEDED

                TC              PHASCHNG
## The following line was not printed. It was taken from the octal listing and matches other PHASCHNG calls.
                OCT             07022
                OCT             20000
                EBANK=          BMEMORY
                2CADR           MP6JOB
## The printer missed a line here, but it only contained the second word of the 2CADR.

## Page 824
## This page header comes toward the bottom of the previous physical page, and the "824" is underlined in 
## green marker.
                TC              PHASCHNG
                OCT             10035

## The following two instructions have a green bracket drawn around the operands.
DVMNKILL        CAF             AVEGADDR                # REMOVE DV MONITOR FROM SERVICER
                TS              DVSELECT

AVEGADDR        TC              AVERAGEG

THRSHLD+        DEC             980                     # BOOSTER SHUTDOWN AT 1/2 G OVER 2 SECS

## An arrow is drawn to "ALARM" in the line below. This would have been the alarm seen during the flight, so it
## is likely that this listing was used for debugging the problem.
ENGNFAIL        TC              ALARM
                OCT             1405                    # DVALARM.  ENGINE ON BUT NO THRUST.

                TC              POSTJUMP
                CADR            FORGETIT                # SHUTDOWN.
## There is a physical page break here. The instruction below also has a green check mark next to it.
 -1             TS              DVCNTR
SERVEXIT        TC              PHASCHNG
                OCT             00035

                TCF             ENDOFJOB

## Page 825
# ***** GIMBL MONITOR - USED PRIOR TO PGNCSMON IN DPS BURNS **************

                EBANK=          ABDELV
GIMBLMON        CA              SLOSHCTR                # FIRST CONDITION FOR USE OF TRIM GIMBAL-
                EXTEND                                  #     THAT SLOSH HAS NOT BUILT UP TO THE
                BZF             GIMBLOFF                #     POINT THAT THE GIMBAL IS NOT USEFUL
                EXTEND
                DIM             SLOSHCTR

                CS              GTHRSHLD                # SECOND CONDITION FOR USE OF TRIM GIMBAL-
                AD              ABDELV                  #     THAT DPS THRUST HAS ATTAINED A FAIR
                EXTEND                                  #     DEGREE OF STABILITY
## The following line was not printed. It was disassembled from the octal listing.
                BZMF            GIMBLOFF

                CS              FLAGWRD2                # THIRD CONDITION FOR USE OF TRIM GIMBAL-
                MASK            BIT4                    #     THAT THROTTLING IS NOT NOW UNDERWAY.
                EXTEND                                  #     THIS FLAG IS SET WHEN THROTTLING IS
                BZF             PGNCSMON                #     BEGUN AND RESET WHEN IT IS OVER.

                CA              BIT10                   # FOURTH CONDITION FOR USE OF TRIM GIMBAL-
                EXTEND                                  #     THAT GIMBAL HAS NOT FAILED
                RAND            32
                EXTEND
## The following line was not printed. It was disassembled from the octal listing.
                BZF             GIMBLOFF

GIMBLON         INHINT                                  # IF WE GET THIS FAR IT IS OK TO TURN ON
                CS              USEQRJTS                # THE GLORIOUS TRIM GIMBAL
                MASK            DAPBOOLS
                TS              DAPBOOLS
                RELINT
## The following line was not printed. It was disassembled from the octal listing.
                TCF             PGNCSMON

GIMBLOFF        INHINT                                  # IT IS NECESSARY FOR SOME REASON TO
                CS              DAPBOOLS                # TURN OFF THE TRIM GIMBAL
                MASK            USEQRJTS
## The following four lines, as well as the header of the next page, were all printed on top of each other. They
## were disassembled from the octal listing and symbol table. The comment on GTHRSHLD is barely legible, and I
## may have gotten the number wrong.
                ADS             DAPBOOLS
                RELINT
                TCF             PGNCSMON

GTHRSHLD        DEC             60                      # APPROXIMATELY 60 LBS THRUST

## Page 826
## The following two lines were printed on top of each other. The first is a line comment which didn't quite
## make it through. I've done my best to pick it out from behind the other characters.<br>
## <pre>
##     ROO   IN       O    RMINA    R ADACES AND AV RAGE G
## </pre>
                EBANK=          DVTOTAL
AVGEND          CA              PIPTIME         +1      # FINAL AVERAGE G EXIT
## The following line was not printed. It was instead taken from a picture of SHEPATIN rev 0 provided by Don Eyles,
## and confirmed to match the octal listing.
                TS              OLDBT1                  # SET UP FREE FALL GYRO COMPENSATION

                TC              FLAG2UP                 # SET DRIFT FLAG
                OCT             40000

                EXTEND
                DCA             AVEMIDAD                # TRANSFER STATE VECTOR VIA AVETOMID
                DXCH            Z

                TC              PHASCHNG
                OCT             04025                   # POOH WILL TURN OFF PHASE5

## The following line was not printed. It was instead disassembled from the octal listing.
                CA              BIT6
                MASK            FLAGWRD1                # FLAG IS UP BUT RATHER TO ENDOF JOB
                EXTEND
                BZF             POOH
                TC              PHASCHNG                # MAKE GROUP 5 INACTIVE
                OCT             5

                TC              FLAG1DWN                # NOT MORE THAN ONE USE OF THIS FLAG.
                OCT             00040

                TCF             ENDOFJOB

                EBANK=          AVMIDRTN
AVEMIDAD        2CADR           AVETOMID

## Page 827
#    NORMLIZE PERFORMS THE INITIALIZATION REQUIRED PRIOR TO THE FIRST ENTRY TO AVERAGEG, AND SCALES RN SO THAT IT
# HAS 1 LEADING BINARY ZERO. IN MOST MISSIONS, RN WILL BE SCALED AT 2(+29), BUT IN THE 206 MISSION, RN WILL BE
# SCALED AT 2(+24)M.  TIME OF RN,VN IS IN STATIME FOR DWNLINK


                EBANK=          RAVEGON
NORMLIZE        INHINT
                CAF             ELEVEN                  # INITIALIZE INDEX-DEC 11
                TS              RUPTREG1
## The following six instructions were printed on two lines. They were instead disassembled from the octal listing
## and symbol table. A single letter of a comment made it through: "       V       ". They have since been
## confirmed to match Shepatin 0 / Sunburst 37, and the comment has been restored.
                INDEX           RUPTREG1
                CA              RAVEGON
                INDEX           RUPTREG1
                TS              RN                      # STORE RN, VN
                CCS             RUPTREG1
                TCF             NORMLIZE        +2
## End of disassembled instructions.

                EXTEND
## The following five lines were all printed on one. They have been disassembled from the octal listing. Part of
## a comment made it through: "S A    IM  F R DWNLINK". The full comment has been restored from Shepatin 0 /
## Sunburst 37.
                DCA             TAVEGON
                DXCH            STATIME                 # STATE TIME FOR DWNLINK
                RELINT
                TC              INTPRET
                VLOAD           CALL
## End of disassembled instructions.
                                RN                      # LOAD RN VEC FOR CALCGRAV
                                CALCGRAV                # INITIALIZE UNITR RMAG GDT1
                STORE           GDT/2
## The following two lines, as well as the header for the next page, were all printed on the same line. The
## instructions have been disassembled from the octal listing.
                EXIT
                TCF             ENDOFJOB
                
## Page 828
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
## The following line was not printed. It was pulled from Shepatin 0 / Sunburst 37.
#    RIGNITION IN RN*2(+24)M
#    VIGNITION IN VN*2(+7)M/CS
#    GDT/2 AT IGNITION IN GDT/2*2(+7)M/CS
#    UNIT RIGNITION IN UNITR *2(+1)M
#    RMAG AT 2(+24)M

VPATCHER        STQ             EXIT
                                TEMX
                INHINT
                CAF             EBANK4
                XCH             EBANK
                TS              RUPTREG2
                CAF             ELEVEN                  # INITIALIZE INDEX TO DEC 11
VPATLOOP        TS              RUPTREG1
                INDEX           RUPTREG1
## There is a page break here.
                CA              RIGNTION
                INDEX           RUPTREG1
                TS              RN                      # STORE RN,VN
                CCS             RUPTREG1
## The following two lines were printed on top of each other.
                TCF             VPATLOOP
                EXTEND
                DCA             TIGNTION
                DXCH            STATIME                 # STATE TIME FOR DWNLINK
                CA              RUPTREG2
                TS              EBANK
                RELINT
                TC              INTPRET
                VLOAD           CALL
## There is a blank page here, with the letters "MTF" written on it. This page marks the end of the printer
## problems, and probably corresponds to a change of paper.
## Page 829
                                RN                      # LOAD RN VEC FOR CALCGRAV
                                CALCGRAV

                STCALL          GDT/2
                                TEMX

## Page 830
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

FLAG2DWN        INDEX           Q                       # RESET FLAG 2 SUBROUTINE
                CS              0
                INHINT
## Page 831
                MASK            FLAGWRD2
                TS              FLAGWRD2
                RELINT
                TCF             Q+1

GMBLMNAD        GENADR          GIMBLMON

PGNSCADR        GENADR          PGNCSMON

BURNDB          DEC             0.00556                 # 1 DEGREE DEADBAND SCALED AT PI RADIANS
NARROWDB        DEC             0.00167                 # .3 DEGREE DEADBAND SCALED AT PI RADIANS
WIDEDB          DEC             0.02778                 # 5 DEGREE DEADBAND SCALED AT PI RADIANS
