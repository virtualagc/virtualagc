### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RCS_FAILURE_MONITOR.agc
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
## Reference:   pp. 535-537
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-31 HG   Transcribed
##              2017-06-15 HG   Fix operand BIT6 -> BIT8
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 535
# FAILURE MONITOR FOR LM RCS JETS (4 TIMES A SECOND).

# *** FAILSW CAPABILITY FOR CHECKOUT ONLY ***

                EBANK=          DT
                BANK            12

RCSMONIT        TCF             RESUME                  # *** TO STOP ENDLESS LOOPS. ***



                TCF             ENDRCSFL                # DO NOTHING IF POSITIVE

                CA              LASTFAIL                # LAST FAILURE CHANNEL VALUE
                EXTEND
                RXOR            32
                MASK            LOW8
                EXTEND
                BZF             NOSTCHG                 # NO STATUS CHANGE, FINISHED

                EXTEND
                DCA             MNTRCS
                DTCB
                EBANK=          DT
MNTRCS          2CADR           RCSMNTR
ENDT4S          EQUALS


                BANK            20
                EBANK=          DT
RCSMNTR         CA              ZERO                    # THERE IS A DIFFERENCE, CLEAR MASKS
                TS              CH5MASK
                TS              CH6MASK

                EXTEND                                  # READ PRESENT FAILURES
                READ            32
                TS              LASTFAIL                # SAVE FOR NEXT PASS

                COM                                     # FAILURES NOW ONES
                EXTEND
                MP              BIT7                    # SHIFT TO TEST LOW 8 BITS
                CA              ZERO

                TS              FAILCTR                 # INITIALIZE COUNTER
                CA              L
                TCF             NXTRCSPR        +1

 -1             AD              BIT1
NXTRCSPR        INCR            FAILCTR
 +1             DOUBLE

## Page 536
                TS              FAILTEMP		# OVERFLOW CHECK
                TCF             NXTRCSPR

                INDEX           FAILCTR
                TC              RCSFJUMP                # GO THROUGH JUMP TABLE

                CCS             FAILTEMP
                TCF             NXTRCSPR        -1      # FINISH EARLY, OR MORE TO DO

                TCF             ENDRCSFL
RCSFJUMP        TCF             FM10/11
                TCF             FM9/12
                TCF             FM13/15
                TCF             FM14/16
                TCF             FM6/7
                TCF             FM1/3
                TCF             FM5/8
                TCF             FM2/4

FM10/11         CA              BIT6
                ADS             CH5MASK
                CA              BIT4
                ADS             CH6MASK
                TC              Q

FM9/12          CA              BIT5

                ADS             CH5MASK
                CA              BIT5
                ADS             CH6MASK
                TC              Q

FM13/15         CA              BIT7
                ADS             CH5MASK
                CA              BIT3
                ADS             CH6MASK
                TC              Q

FM14/16         CA              BIT8
                ADS             CH5MASK
                CA              BIT8
                ADS             CH6MASK
                TC              Q

FM6/7           CA              BIT4
                ADS             CH5MASK
                CA              BIT1
                ADS             CH6MASK
                TC              Q

FM1/3           CA              BIT1

## Page 537
                ADS             CH5MASK
                CA              BIT2
                ADS             CH6MASK
                TC              Q

FM5/8           CA              BIT3
                ADS             CH5MASK
                CA              BIT6

                ADS             CH6MASK
                TC              Q

FM2/4           CA              BIT2
                ADS             CH5MASK
                CA              BIT7
                ADS             CH6MASK
                TC              Q

ENDRCSFL        EQUALS          RESUME
NOSTCHG         EQUALS          RESUME
