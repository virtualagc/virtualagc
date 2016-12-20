### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     THROTTLE_CONTROL.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-30 MAS  Transcribed.
##		 2016-11-02 RSB	 Typo.
##		 2016-12-06 RSB	 Comment-proofing via octopus/ProoferComments;
##				 changes were made.

## Page 849
#       THROTTLE CONTROL CAN BE USED IN EITHER OF TWO MODES: IN "PERCENTAGE MODE" (WHEN A CERTAIN FRACTION OF
# MAXIMUM THRUST IS DESIRED) AND IN "ACCELERATION MODE"  (WHEN THE THRUST DESIRED IS THAT CORRESPONDING TO A
# SPECIFIED ACCELERATION).

#                  PERCENTAGE MODE                                               ACCELERATION MODE

#       THE FRACTION OF MAXIMUM THRUST (NOMINALLY                     DESIRED ACCELERATION, IN DOUBLE PRECISION,
# 10500 POUNDS) DESIRED, IN SINGLE PRECISION, IS                IN UNITS OF 2(-5) M/CS/CS, IS PLACED IN /ACF/.
# PLACED IN PCNTF.   ENTRY IS VIA A DTCB AN THE                 ENTRY IS VIA A DTCB ON THE 2CADR OF THROTCON.
# 2CADR OF PCNTFMAX.   THE ROUTINE BEGINNING AT                 THE ROUTINE BEGINNING AT THROTCON SETS UP A JOB -
# PCNTFMAX SETS UP A JOB - PCNTJOB - AND RETURNS                ACCLJOB - AND RETURNS TO THE USER (AT THE
# TO THE USER (AT THE INSTRUCTION IMMEDIATELY                   INSTRUCTION FOLLOWING THE DTCB).
# FOLLOWING THE DTCB).
#                                                                    ACCLJOB, AFTER A RESTART PROTECT,
#       PCNTJOB, AFTER A RESTART PROTECT,                       COMPUTES DESIRED ACCELERATION, FC = /ACF/ MASS,
# TURNS OFF THE TRIM GIMBAL, SETS UP A WAITLIST                SCALED AT ABOUT 2.7 POUNDS PER BIT.
# TASK (DESCRIBED LOCALLY), COMPUTES THRUST DESIRED,
# FC = PCNTF FMAX, SCALED AT ABOUT 2.7 POUNDS PER BIT,                (NOTE THAT IN THE ACCELERATION MODE THE TRIM
# AND TCF'S AROUND THE COMMENCEMENT OF ACCLJOB TO               GIMBAL IS NOT TURNED OFF; IT IS ASSUMED TO BE OFF
# FOLDCALC.                                                    BY THE TIME THROTTLE CHANGES ARE COMMANDED.

#       FOLDCALC BEGINS BY COMPUTING PRESENT THRUST,  FOLD = MASS /AF/,  SCALED AS IS FC.   NEXT, SINCE /AF/ IS
# MERELY AN "AVERAGE" OF THE THROTTLE LEVELS OF THE PRECEEDING PIPA INTERVAL, FOLD IS WEIGHTED BY FWEIGHT, A
# FUNCTION OF THE PRECEEDING THROTTLE COMMAND (DESCRIBED LOCALLY).   TO PRECLUDE A SPURIOUS WEIGHTING THAT WOULD
# OTHERWISE OCCUR, FWEIGHT IS ZEROED 1.95 SECONDS AFTER EVERY PERCENTAGE MODE THROTTLING.

#       NEXT, TO COMPENSATE FOR THE DIFFERENTIAL BETWEEN BITS FOR MAXIMUM THRUST AND BITS FOR FULL THROTTLE, THE
# NUMBER  FOLD - FODD IS COMPUTED AND SET INTO PIFPSET WHENEVER FCOLD INDICATES THE THROTTLE IS AT MAXIMUM.
# SINCE PIFPSET IS USED, RATHER THAN PIF, PIF STILL REFLECTS ACCURATELY THE ACTUAL THRUST CHANGE AND FWEIGHT IS
# COMPUTED PROPERLY.

#       NEXT COMES IS-IT-ON.   HERE THE ENGINE-OFF BIT (14 OF CHANNEL 11) IS QUERIED; IF THE ENGINE IS OFF
# FCOLD, THE SINGLE PRECISION HISTORY REGISTER, IS SET TO 10% FMAX AND PIFPSET, A PRESETTING ADDED TO PIF AT
# THE LAST MOMENT, IS SET TO -10% FMAX TO COMPENSATE FOR THE ASSUMED SETTING OF THE MANUAL THROTTLE.

#       THE SERIES OF DECISIONS BEGINNING AT WHERETO CAUSES THE THROTTLE TO REACT TO USERS' DESIRES IN THE
# MANNER DESCRIBED BY FIGURE 5.3-5 OF THE FLIGHT 206 GSOP.   WHERETO PROCEEDS (OR BRANCHES) TO FLATOUT (IF THE
# THROTTLE LEVEL ASKED FOR IS IN THE FORBIDDEN REGION) OR TO DOPIF.   FLATOUT RESETS FC TO 94% FMAX, SETS FEXTRA
# (A BOOST GIVEN TO THE THROTTLE TO KEEP IT JAMMED AGAINST ITS STOPS) INTO PIFPSET, AND PROCEEDS TO DOPIF.

#       DOPIF, AFTER A "TYPE C" RESTART PROTECT (NECESSITATED BY THE FACT THAT FCOLD AND PIF, USED EARLIER, ARE
# ABOUT TO BE MODIFIED), SETS FCOLD = FC, COMPUTES PIF (PULSE INCREMENT FOR ACCELERATION) = FC - FOLD, AND, AS
# IT PROCEEDS TO DOIT, HAS THIS NUMBER PLUS PIFPSET IN A & L.

#       DOIT DOES IT.   IT TS'S INTO THRUST, THE CHANNEL (55) LEADING TO DECA, THE THROTTLE-AGC INTERFACE
# CIRCUIT, AND SETS BIT 4 IN CHANNEL 11, THE SIGNAL FOR THRUST TO BE COUNTED DOWN (AT 3200 PPS).   FINALLY,
# FWEIGHT = F(PIF) IS COMPUTED FOR USE NEXT PASS.

#       AFTER ANOTHER RESTART PROTECT A TCF ENDOFJOB ENDS THROTTLE CONTROL.

## Page 850
                BANK            30
                EBANK=          ETHROT



                                                                # ***************
                                                                # * SUBROUTINES *
                                                                # ***************

                                                                # THIS SUBROUTINE MULTIPLIES ACCELERATION
                                                                # (ARRIVING IN A AND L) BY MASS AND LEAVES
                                                                # FORCE (THRUST) IN A & L, SCALED AT ABOUT
                                                                # 2.7 POUNDS PER BIT.

MASSMULT        EXTEND
                QXCH            BUF                             # PRESERVING RETURN ADDRESS
                DXCH            MPAC
                TC              DMP                             # LEAVES ODDLY SCALED FORCE IN MPAC
                ADRES           MASS
                TC              DMP                             # LEAVES PROPERLY SCALED FORCE IN MPAC
                ADRES           SCALEFAC
                DXCH            MPAC            +1              # LOADING FORCE INTO A AND L
                TC              BUF                             # IN WHICH Q WAS STORED



                                                                # THIS TASK WILL BE EXECUTED 1.95 SECONDS
                                                                #   AFTER PERCENTAGE MODE THROTTLING.

PCNTOVER        CS              ZERO
                TS              FWEIGHT                         #   SCHEME WILL WORK PROPERLY NEXT PASS
                TS              FWEIGHT         +1
                ZL                                              # -0 STILL IN A
                DXCH            -PHASE1
                TCF             TASKOVER



## The character used for separation below, and throughout the rest of this section, was actually a small
## box, similar to the unicode white square (U+25A1). All occurrences have been replaced with the ASCII =.
# ========================================================================
THROTDT         DEC             +195
PGUID           DEC             +200
# ========================================================================

## Page 851
                                                                # ***********
                                                                # * ENTRIES *
                                                                # ***********

                                                                # THIS ENTRY SETS UP A JOB WHICH WILL
                                                                # DELIVER A SPECIFIED FRACTION OF MAXIMUM
                                                                # THRUST.   THIS FRACTION ARRIVES (SP) IN
                                                                # REGISTER PCNTF.

PCNTFMAX        DXCH            RTNHOLD                         # RETAINING 2CADR FOR RETURN TO USER
                CAF             PRIO25
                INHINT
                TC              NOVAC
                EBANK=          ETHROT
                2CADR           PCNTJOB

                RELINT
                TCF             AWAY

                                                                # NORMAL ENTRY FROM GUIDANCE EQUATIONS:
                                                                # THE JOB SET UP HERE DELIVERS A THRUST
                                                                # CORRESPONDING TO THE DESIRED MAGNITUDE
                                                                # OF THRUST-ACCELERATION.   THIS VALUE
                                                                # ARRIVES (DP) IN /ACF/, SCALED IN UNITS
                                                                # OF 2(-5) M/CS/CS.

THROTCON        DXCH            RTNHOLD                         # RETAINING 2CADR FOR RETURN TO USER
                CAF             PRIO30
                INHINT
                TC              NOVAC
                EBANK=          ETHROT
                2CADR           ACCLJOB

                RELINT


                                                                # THIS RETURN IS COMMON TO BOTH ENTRIES.

AWAY            DXCH            RTNHOLD
                DTCB

## Page 852
                                                                # ***************
                                                                # * COMPUTATION *
                                                                # ***************

PCNTJOB         INHINT                                          # SINCE THROTTLING IS ABOUT TO COMMENCE.

                CAF             THROTDT                         # SET UP A TASK TO ZERO FWEIGHT IN 2 SECS
                TC              WAITLIST
                EBANK=          ETHROT
                2CADR           PCNTOVER

                TC              2PHSCHNG
                OCT             40031                           # 1.3 SPOT FOR PCNTOVER
                OCT             05024
                OCT             25000

                EXTEND
                DCS             -FMAX
                DXCH            MPAC
                CA              PCNTF
                TC              SHORTMP
                DXCH            MPAC                            # LOADING
                DXCH            FC                              # STORING

                CA              ZERO                            # ZEROING FWEIGHT SINCE IT'S UNKNOWN
                TS              FWEIGHT
                TS              FWEIGHT         +1
                TCF             FOLDCALC


## In the following line, and the corresponding line a few lines below it,
## it's unclear what the characters printed are supposed to be.  In the
## hardcopy, they appear as small rectangular boxes.
# ########################################################################
SCALEFAC        2DEC            +51.946987      B-14            # QUASI-NEWTONS TO PULSE UNITS

2.PG.FRT        DEC             12800                           # TWICE PGUID TIME PULSE RATE
-LOCRIT         DEC             -2019                           # THE LOWER MID-SCALE CRITERION
FEXTRA          =               -LOCRIT
+FLOW           DEC             +438                            # MINIMUM ATTAINABLE THRUST
# ########################################################################

ACCLJOB         TC              PHASCHNG
                OCT             05024
                OCT             30000

                EXTEND
                DCA             /ACF/
                TC              MASSMULT
                DXCH            FC                              # FC = MASS /ACF/, SCALED

## Page 853
FOLDCALC        EXTEND
                DCA             /AF/
                TC              MASSMULT
                DXCH            FOLD                            # FOLD = MASS /AF/, SCALED

                EXTEND
                DCA             FWEIGHT                         # WEIGHTING FOLD BY FWEIGHT
                DAS             FOLD                            #   AS COMPUTED LAST PASS

                                                                # IF THE THROTTLE IS AT MAXIMUM, THE
                                                                # QUANTITY  -(FODD-FOLD)  IS COMPUTED AND
                                                                # PUT INTO PIFPSET TO COMPENSATE FOR THE
                                                                # DIFFERENCE BETWEEN THE NUMBER OF BITS
                                                                # (I.E. PULSES) CORRESPONDING TO 100%
                                                                # THROTTLE (FODD) AND THE NUMBER CORRES-
                                                                # PONDING TO ACTUAL THRUST (FOLD).   THIS
                                                                # COMPENSATION IS NEEDED IF THE THROTTLE
                                                                # RETURNS TO THE THROTTLEABLE REGION THIS
                                                                # PASS.   IF IT DOES NOT, PIFPSET IS RESET
                                                                # IN FLATOUT.

FCOMPSET        CS              ZERO
                TS              PIFPSET
                CS              +HICRIT
                AD              FCOLD
                EXTEND
                BZMF            IS-IT-ON                        # BRANCH IF FCOLD < HICRIT, OTHERWISE
                CS              +FODD                           #   COMPUTE THE COMPENSATION NUMBER
                AD              FOLD
                TS              PIFPSET



                                                                # THIS ROUTINE CHECKS THE ENGINE-OFF BIT.
                                                                # IF THE ENGINE IS OFF, FCOLD IS SET TO
                                                                # 10 PERCENT FMAX, AND, SINCE /AF/ DOES
                                                                # NOT REFLECT THE SETTING OF THE MANUAL
                                                                # THROTTLE, THAT SETTING (AROUND 12%) IS
                                                                # PLACED NEGATIVELY IN PIFPSET.

IS-IT-ON        CS              FLAGWRD1
                MASK            ENGINBIT
                EXTEND
                BZF             WHERETO                         # BRANCH HERE IF ENGINE IS ON
                CA              +FLOW
                TS              FCOLD                           # SETTING FCOLD
                CS              +FLOW
                TS              PIFPSET

## Page 854
                                                                # ************
                                                                # * DECISION *
                                                                # ************

                                                                # THIS LOGIC DETERMINES THROTTLING IN THE
                                                                # REGION 10% - 94%.   THE MANUAL THROTTLE,
                                                                # SET TO MINIMUM BY MISSION PHASE PROGRMS,
                                                                # PROVIDES THE LOWER BOUND; A STOP IN THE
                                                                # ENGINE ITSELF PROVIDES THE UPPER.



WHERETO         CA              FC
                AD              -LOCRIT
                EXTEND
                BZMF            DOPIF                           # BRANCH IF FC < LOCRIT
                CS              FC
                AD              +HICRIT
                EXTEND
                BZMF            FLATOUT                         # BRANCH IF FC > OR = HICRIT
                CS              +HICRIT
                AD              FCOLD
                EXTEND
                BZMF            DOPIF                           # BRANCH IF FCOLD < OR = HICRIT,
                                                                #   OTHERWISE PROCEED TO FLATOUT

## Page 855
                                                                # *************
                                                                # * EXECUTION *
                                                                # *************

FLATOUT         EXTEND
                DCA             +FHIGH
                DXCH            FC
                CS              FEXTRA
                TS              PIFPSET

DOPIF           TC              PHASCHNG
                OCT             04024                           # ?

                EXTEND
                DCA             FC
                TS              FCOLD                           # HISTORY
                DXCH            PIF
                EXTEND
                DCS             FOLD
                DAS             PIF                             # PIF = FC - FOLD
                TC              DAPLOGIC

DAPLRETN        CA              PIF
                AD              PIFPSET                         # ADD IN PIFPSET, NOT CHANGING PIF

DOIT            TS              THRUST
                TC              PHASCHNG
                OCT             04024

                CAF             BIT4
                EXTEND
                WOR             14                              # AND THE ENGINE DOES THE REST...
## What we show as a percent-sign below ("WOULD THAT IT WERE%") was really a 1/2 symbol (&frac12;) 
## in the original hardcopy.
                                                                # SINCE /AF/ IS NOT AN INSTANTANEOUS
                                                                # ACCELERATION (WOULD THAT IT WERE%) BUT
                                                                # RATHER AN "AVERAGE" OF THE ACCELERATION
                                                                # LEVELS OF THE LAST PIPA INTERVAL, AND
                                                                # SINCE FOLD IS COMPUTED DIRECTLY FROM
                                                                # /AF/, FOLD IN ORDER TO CORRESPOND TO THE
                                                                # ACTUAL THRUST LEVEL AT THE END OF THE
                                                                # INTERVAL MUST BE WEIGHTED BY

                                                                #            PIF PPROCES     PIF /PIF/
                                                                #  FWEIGHT = ----------- + ------------- ,
                                                                #               PGUID      2 PGUID FRATE

                                                                # WHERE PPROCES IS THE TIME BETWEEN PIPA
                                                                # READING AND THE START OF THROTTLING,
                                                                # PGUID IS THE GUIDANCE PERIOD (2 SECONDS)
## Page 856
                                                                # AND FRATE IS THE THROTTLING RATE (SOME
                                                                # 3200 UNITS PER SECOND).   HERE FWEIGHT
                                                                # IS COMPUTED FOR USE NEXT PASS.

                EXTEND
                DCA             TIME2
                DXCH            MPAC
                EXTEND
                DCS             PIPTIME
                DAS             MPAC
                CA              PGUID
                XCH             MPAC            +1
                MASK            POSMAX                          # IN CASE THAT LOUSY SIGN BIT IS SET
                EXTEND
                DV              MPAC            +1              # WHICH CONTAINS PGUID
                EXTEND
                MP              PIF
                DXCH            FWEIGHT                         # FWEIGHT = (PPROCES/PGUID)PIF, SO FAR...

                CA              2.PG.FRT
                XCH             MPAC                            # TO BE USED AS A DIVISOR LATER
                CCS             PIF
                AD              ONE
                TCF             +2
                AD              ONE
                EXTEND                                          # AT THIS POINT HAVE /PIF/ IN A
                MP              PIF
                EXTEND
                DV              MPAC                            # WHICH CONTAINS 2.PG.FRT
                LXCH            7
                DAS             FWEIGHT

                TC              PHASCHNG
                OCT             00004
                TCF             ENDOFJOB

## Page 857
                                                                # *************
                                                                # * CONSTANTS *
                                                                # *************

                                                                # CONSTANTS FOR DECISION

+FODD           DEC             +3866           B-14            # THIS MUCH SATURATES THROTTLE

-FMAX           2DEC            -3882           B-14            # NOMINAL MAX THRUST IN BIT UNITS

+FHIGH          2DEC            +3648           B-14            # MAX ATTAINABLE THRUST, UNERODED

+HICRIT         DEC             +2252           B-14            # THE HIGHER MID-SCALE CRITERION

## In the following line, and the corresponding line a few lines below it,
## it's unclear what the characters printed are supposed to be.  In the
## hardcopy, they appear as small rectangular boxes.
# ########################################################################
# SINCE BETWEEN REVISION 113 AND 114 IT WAS NECESSARY TO PRESERVE THE
# LOCATIONS IN MEMORY OF LABELS ADDRESSED FROM OTHER BANKS (SINCE THE ROPE
# IS ALREADY UNDER CONSTRUCTION) CERTAIN CONSTANTS WERE REMOVED FROM THIS
# SECTION FOR USE AS FILLER ELSEWHERE.   THESE ARE -LOCRIT, +FLOW,
# SCALEFAC, FEXTRA, THROTDT, PGUID, AND 2.PG.FRT.
# ########################################################################



                                                                # IF THE TRIM GIMBAL IS TURNED OFF BY
                                                                # THE THROTTLE, THIS TASK WILL REENABLE IT
                                                                # ABOUT 2 SECONDS LATER.

THROTOVR        TC              FLAG2DWN
                OCT             00010
                CS              ZERO
                ZL
                DXCH            -PHASE1
                TCF             TASKOVER



DAPLOGIC        CA              PIF
                EXTEND
                BZMF            +2
                COM

                AD              HITHRESH
                EXTEND
                BZMF            JETSET                          # BRANCH IF /PIF/ > OR = HITHRESH

                CA              FOLD
                DOUBLE
                TS              BUF

## Page 858
                CA              FC
                EXTEND
                DV              BUF                             # WHERE TWICE FOLD WAS STORED
                TS              BUF
                CA              EBANK6
                TS              EBANK
                EBANK=          D2CDUYFL
                CA              BUF
                EXTEND
                MP              D2CDUYFL
                DOUBLE
                XCH             D2CDUYFL
                CA              BUF
                EXTEND
                MP              D2CDUZFL
                DOUBLE
                XCH             D2CDUZFL

                CA              EBANK5
                TS              EBANK
                EBANK=          ETHROT
                TCF             DAPLRETN



JETSET          INHINT
                CS              DAPBOOLS                        # INHIBIT USE OF TRIM GIMBAL
                MASK            USEQRJTS
                ADS             DAPBOOLS

                CA              THROTDT                         # SET UP TASK TO REMOVE THE INHIBITION
                TC              WAITLIST                        #   CREATED BELOW
                EBANK=          ETHROT
                2CADR           THROTOVR

                TC              FLAG2UP                         # INHIBIT THE GIMBLMON FROM REACTIVATING
                OCT             00010                           #   THE GIMBAL

                TC              PHASCHNG
                OCT             47011
                DEC             195
                EBANK=          ETHROT
                2CADR           THROTOVR

                TCF             DAPLRETN



HITHRESH        DEC             +194                            # ABOUT 5 % OF NOMINAL MAXIMUM THRUST
