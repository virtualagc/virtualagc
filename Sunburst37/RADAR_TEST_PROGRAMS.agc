### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RADAR_TEST_PROGRAMS.agc
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
## Reference:   pp. 185-186
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-30 HG   Transcribed
##		2017-06-21 RSB	Proofed using octopus/ProoferComments.

## Page 185
                BANK            10
                EBANK=          RSTKLOC

#          RADAR SAMPLING LOOP.

RADSAMP         CCS             RSAMPDT                 # TIMES NORMAL ONCE-PER-SECOND SAMPLING.
                TCF             +2


                TCF             TASKOVER                # +0 INSERTED MANUALLY TERMINATES TEST.

                TC              WAITLIST
                EBANK=          RSTKLOC
                2CADR           RADSAMP
                CAF             PRIO25
                TC              NOVAC
                EBANK=          RSTKLOC
                2CADR           DORSAMP
                CAF             1/6                     # FOR CYCLIC SAMPLING, RTSTDEX =
                EXTEND                                  # RTSTLOC/6 + RTSTBASE.
                MP              RTSTLOC
                AD              RTSTBASE                # 0 FOR RR, 2 FOR LR.
                TS              RTSTDEX

                TCF             TASKOVER

#          DO THE ACTUAL RADAR SAMPLE.

DORSAMP         TC              VARADAR                 # SELECTS VARIABLE RADAR CHANNEL.
                TC              BANKCALL

                CADR            RADSTALL
                INCR            RFAILCNT                # ADVANCE FAIL COUNTER BUT ACCEPT BAD DATA

DORSAMP2        INHINT                                  # YES - UPDATE TM BUFFER.
                DXCH            SAMPLSUM
                INDEX           RTSTLOC
                DXCH            RSTACK

                DXCH            OPTYHOLD
                INDEX           RSTKLOC
                DXCH            RSTACK          +2

                DXCH            TIMEHOLD
                INDEX           RSTKLOC
                DXCH            RSTACK          +4

                CS              RTSTLOC                 # CYCLE RTSTLOC.
                AD              RTSTMAX
                EXTEND

## Page 186
                BZF             +3
                CA              RTSTLOC
                AD              SIX
                TS              RTSTLOC

                CCS             RSAMPDT                 # SEE IF TIME TO RE-SAMPLE.
                TCF             ENDOFJOB                # NO - WAIT FOR T3 (REGULAR SAMPLING).

                TCF             ENDOFJOB                # TEST TERMINATED.
                TCF             DORSAMP                 # JUMP RIGHT BACK AND GET ANOTHER SAMPLE.

1/6             DEC             .17

#          VARIABLE RADAR DATA CALLER FOR ONE MEASUREMENT ONLY.

VARADAR         CAF             ONE                     # WILL BE SENT TO RADAR ROUTINE IN A BY
                TS              BUF2                    # SWCALL.
                INDEX           RTSTDEX
                CAF             RDRLOCS
                TCF             SWCALL                  # NOT TOUCHING Q.

RDRLOCS         CADR            RRRANGE                 # = 0
                CADR            RRRDOT                  # = 1
                CADR            LRVELX                  # = 2
                CADR            LRVELY                  # = 3
                CADR            LRVELZ                  # = 4
                CADR            LRALT                   # = 5
