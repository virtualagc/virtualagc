### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     RCS_FAILURE_MONITOR.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        0635-0638
## Mod history:  2016-09-20 JL   Created.
##               2016-09-21 OH   Initial Transcription
##               2016-10-08 HG   fix BANK 20 -> BANK 12  (p.0635)
##               2016-10-16 HG   add missed label RCSMNTR
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

## Page 0635

                BANK    12

## Page 0636
# FAILURE MONITOR FOR LEM RCS JETS (4 TIMES/SECOND)
#
# *** FAILSW CAPABILITY FOR CHECKOUT ONLY ***

RCSMONIT        CCS     FAILSW
                TCF     ENDRCSFL        # DO NOTHING IF POSITIVE

                CA      LASTFAIL        # LAST FAILURE CHANNEL VALUE        
                EXTEND
                RXOR    32
                MASK    LOW8
                EXTEND
                BZF     NOSTCHG         # NO STATUS CHANGE, FINISHED

                EXTEND
                DCA     MNTRCS
                DTCB
MNTRCS          2CADR   RCSMNTR

ENDT4S          EQUALS



                BANK    25
RCSMNTR         CA      ZERO            # THERE IS A DIFFERENCE, CLEAR MASKS
                TS      CH5MASK
                TS      CH6MASK

                EXTEND                  # READ PRESENT FAILURES
                READ    32
                TS      LASTFAIL        # SAVE FOR NEXT PASS

                COM                     # FAILURES NOW ONES
                EXTEND
                MP      BIT7            # SHIFT TO TEST LOW 8 BITS
                CA      ZERO
                TS      FAILCTR         # INITIALIZE COUNTER
                CA      L
                TCF     NXTRCSPR +1

 -1             AD      BIT1
NXTRCSPR        INCR    FAILCTR
 +1             DOUBLE
                TS      FAILTEMP        # OVERFLOW CHECK
                TCF     NXTRCSPR

                INDEX   FAILCTR
                TC      RCSFJUMP        # GO THROUGH JUMP TABLE

                CCS     FAILTEMP
## Page 0637

                TCF     NXTRCSPR -1     # FINISH EARLY, OR MORE TO DO
                TCF     ENDRCSFL
RCSFJUMP        TCF     FM10/11
                TCF     FM9/12
                TCF     FM13/15
                TCF     FM14/16
                TCF     FM6/7
                TCF     FM1/3
                TCF     FM5/8
                TCF     FM2/4

FM10/11         CA      BIT6
                ADS     CH5MASK
                CA      BIT4
                ADS     CH6MASK
                TC      Q

FM9/12          CA      BIT5
                ADS     CH5MASK
                CA      BIT5
                ADS     CH6MASK
                TC      Q
                
FM13/15         CA      BIT7
                ADS     CH5MASK
                CA      BIT3
                ADS     CH6MASK
                TC      Q
                
FM14/16         CA      BIT8
                ADS     CH5MASK
                CA      BIT8
                ADS     CH6MASK
                TC      Q

FM6/7           CA      BIT4
                ADS     CH5MASK
                CA      BIT1
                ADS     CH6MASK
                TC      Q

FM1/3           CA      BIT1
                ADS     CH5MASK
                CA      BIT2
                ADS     CH6MASK
                TC      Q

FM5/8           CA      BIT3
                ADS     CH5MASK
## Page 0638
                CA      BIT6
                ADS     CH6MASK
                TC      Q

FM2/4           CA      BIT2
                ADS     CH5MASK
                CA      BIT7
                ADS     CH6MASK
                TC      Q

ENDRCSFL        EQUALS  RESUME
NOSTCHG         EQUALS  RESUME
