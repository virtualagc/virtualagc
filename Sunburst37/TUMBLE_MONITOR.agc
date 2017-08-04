### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    TUMBLE_MONITOR.agc
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
## Reference:   pp. 777-779
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-13 HG   Transcribed
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 777
# PROGRAM DETECTS SPIN ABOUT NAV.AXES AND SETS BIT 13 OF FLAGWORD1 ON IF SPIN IS IN EXCESS OF 2.99 DEGREES/SEC .
# NO CONTROL ACTION IS EXERTED . TO DISCONTINUE MONITORING , TURN BIT 14  OF FLAGWORD1 OFF . TO INITIATE MONITOR ,
# SET UP WAITLIST CALL FOR TUMTASK. IT IS ASSUMED THAT THE IMU,S ARE IN   FINE ALIGN .



# NAME=                           DATE=
#   TUMBLE MONITOR                  29 AUGUST 1966

# PROGRAMMER=                     REVISIONS=
#   G.MANSBACH EXT-182              NANSTONE/2
#                                   NANSTONE/7
#                                   NANSTONE/15   10/27/66
#                                   NANSTONE/3    11/12/66
# CALLING SEQUENCE=               SUBROUTINES CALLED=
#          CAF    (DT)              FLAG1UP
#          TC     WAITLIST          FLAG1DOWN
#          EBANK= OMEGA
#          2CADR  TUMTASK

# NORMAL EXIT MODES=              ABORT MODE=
#          TC     TASKOVER          TURN BIT 14 OF FLAGWORD1 OFF
# OUTPUT=
#   SET BIT 13 OF FLAGWORD1 ON/OFF
# DEBRIS=
#   PCDUY,PCDUZ,PCDUX,DCDUY,DCDUZ,OMEGA
                BANK            30
                EBANK=          OMEGA
                                                        # INITIALIZATION ROUTINE FOR TUMBLE
                                                        # MONITOR

TUMTASK         TC              PHASCHNG                # IMMEDIATE RECALL

                OCT             05013                   # *TUMTASK*
                OCT             77777
                TC              FLAG1UP                 # TURN TUMBLE MONITOR ON
                OCT             20000
                TC              RESET
                TC              TASKOVER


TMTSK           CA              BIT14
                MASK            FLAGWRD1                # IS TUMBLE MONITOR STILL NEEDED

                EXTEND
                BZF             EOTUM                   # IT IS NOT.  DISCONTINUE MONITORING

                TC              RESET                   # IT IS.
                                                        # COMPUTE ROTATION RATE ABOUT PILOT AXES
                                                        # USING OUTPUT OF *TRANSFORMATION MATRIX
                                                        # CALCULATION* OF *TRUPT PROGRAM*

                                                        # COMPUTE
                                                        #        * OMEGAX *   *     *   * DCDUY *

## Page 778
                                                        #        * OMEGAY * = * M   * X * DCDUZ *

                                                        #        * OMEGAZ *   *  GP *   *+DCDUX *

                TS              OMEGA                   # COMPUTE OMEGAX
                CA              M11
                TC              EVAL
                CA              M22                     # COMPUTE OMEGAY
                EXTEND
                MP              DCDUZ
                TS              OMEGA
                CA              M21
                TC              EVAL
                CA              M32                     # COMPUTE OMEGAZ

                EXTEND
                MP              DCDUZ
                TS              OMEGA
                CA              M31
                TC              EVAL
                                                        # NO TUMBLE NOTED
                TC              FLAG1DWN                # REMOVE TUMBLE FLAG
                OCT             10000
                TC              TASKOVER
EVAL            EXTEND                                  # COMPLETE OMEGA CALCULATION

                MP              DCDUY
                AD              OMEGA                   # SCALE FACTOR OF PI
                                                        # EVALUATE TUMBLE RATE
                EXTEND                                  # SET ALL VALUES NEG.
                BZMF            +2
                CS              A
                AD              CRIT                    # CAUSE UNDERFLOW IF OMEGA IS GREATER THAN
                OVSK                                    # OR = TO 2.99 DEGREES/SEC
                RETURN                                  # NO TUMBLE . EVALUATE NEXT AXIS

                                                        # EXCESSIVE TUMBLE NOTED ABOUT AN AXIS
                TC              FLAG1UP                 # SET TUMBLE FLAG AND DISCONTINUE CALCS.
                OCT             10000
                TC              TASKOVER
EOTUM           TC              PHASCHNG
                OCT             3
                TC              TASKOVER
1SECTM          DEC             100                     # 1 SECOND
CRIT            OCT             40417                   # NEGMAX + 00417   421 = 2.99 DEGREES


                                                        # RECALL MONITOR IN
                                                        #    1 SECOND
RESET           EXTEND
                QXCH            OMEGA
                CA              1SECTM
                TC              WAITLIST

## Page 779
                EBANK=          OMEGA
                2CADR           TMTSK
                                                        # STORE PRESENT CDU(X,Y,Z) AND
                                                        # COMPUTE DELTA(CDU(X,Y,Z)/SEC =
                                                        # DCDU(X,Y,Z)
                CA              CDUY                    # FOR Y-AXIS

                XCH             PCDUY                   # STORE PRESENT VALUE AND RECOVER PREVIOUS
                EXTEND
                MSU             CDUY
                TS              DCDUY                   # = CDUX(T-1)-CDUX(T)
                CA              CDUZ                    # FOR Z-AXIS
                XCH             PCDUZ
                EXTEND
                MSU             CDUZ
                TS              DCDUZ
                CA              CDUX                    # FOR X-AXIS
                XCH             PCDUX
                EXTEND

                MSU             CDUX
                TC              OMEGA
