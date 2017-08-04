### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PIPA_READER.agc
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
## Reference:   pp. 780-783
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-14 HG   Transcribed
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 780

#    SUBROUTINE TO READ PIPA COUNTERS, TRYING TO BE VERY CAREFUL SO THAT IT WILL BE RESTARTABLE.
#    PIPA READINGS ARE STORED IN THE VECTOR DELV. THE HIGH ORDER PART OF EACH COMPONENT CONTAINS THE PIPA READING,

# AND THE LOW ORDER PART HAS -0 AFTER THE PIPAS HAVE BEEN READ. RESTARTS BEGIN AT REPIPASR.
#

#    AT THE END OF THE PIPA READER THE CDUS ARE READ AND STORED AS A
# VECTOR IN CDUTEMP.  THE HIGH ORDER PART OF EACH COMPONENT CONTAINS
# THE CDU READING IN 2S COMP IN THE ORDER CDUX,Y,Z.  THE THRUST
# VECTOR ESTIMATOR IN FINDCDUD REQUIRES THE CDUS BE READ AT PIPTIME.

# CALLING SEQUENCE AND EXIT

#    THE CALLING SEQUENCE TO PIPASR IS

#                                                  EXTEND
#                                                  DCA    PIP2CADR
#                                                  DXCH   Z

# THE RETURN ADDRESS,WHICH IS STORED IN (A,L),IS SAVED IN PIPRETRN. THE RETURN FROM PIPASR IS
#
#                                                  EXTEND
#                                                  DCA    PIPRETRN
#                                                  DXCH   Z

# WHICH RETURNS TO THE LOCATION AFTER THE CALL. ON A RESTART,PIPASR IS CALLED BY REPIPASR.

#

# INPUT

#    INPUT IS THROUGH THE COUNTERS PIPAX, PIPAY, PIPAZ, AND TIME2.


# OUTPUT

#    THE PIPA READINGS ARE OUTPUT THROUGH THE VECTOR DELV. DELTAT, SCALED AT 2(+28)CS, IS COMPUTED FOR AVERAGEG.

# PIPTIME CONTAINS THE NEGATIVE OF THE CURRENT TIME.


# DEBRIS (ERASABLE LOCATIONS DESTROYED BY PROGRAM)

#    TEMX  TEMY  TEMZ  TEMXY  PIPAGE  PIPTIME  PIPAX  PIPAY  PIPAZ

# (ARRIVE IN INTERRUPTED STATE OR INHIBITED AFTER RESTART. EXIT
# THRU ISWRETURN)

                BANK            30

PIPASR          DXCH            PIPRETRN
                CS              ZERO                    # PUT THESE INTO THE IMPOSSIBLE STATE
                TS              TEMX                    # FOR THEIR INITIAL VALUES.

## Page 781
                TS              TEMY
                TS              TEMZ
                CA              ZERO
                TS              DELVX           +1
                TS              DELVY           +1      # PIP COUNTERS MAY NOT HAVE POS ZERO IN
                TS              DELVZ           +1
                TS              PIPAGE                  # ZERO THIS TO INDICATE IN PIPA READING.


# COMPUTE DELTAT FOR AVERAGEG, SAVING -(CURRENT TIME) IN PIPTIME.

REPIP1          EXTEND
                DCA             TIME2                   # CURRENT TIME
                DXCH            PIPTIME

                CS              PIPAX
                TS              TEMXY
                XCH             TEMX                    # PUT NEGZERO INTO PIPACTRS AS READ
                XCH             PIPAX

REPIP1B         TS              DELVX
                TS              DELVX           +1      # DOUBLE SAVE

REPIP2          CS              PIPAY
                TS              TEMXY
                XCH             TEMY
                XCH             PIPAY
REPIP2B         TS              DELVY
                TS              DELVY           +1

REPIP3          CS              PIPAZ                   # REPEAT PROCESS FOR Z PIPA.
                TS              TEMXY                   # SAVE NEG OF PIPA READ

                XCH             TEMZ                    # SAVE HERE AS PICK UP NEGZERO
                XCH             PIPAZ                   # RESETTING PIPA AS READ OUT
REPIP3B         TS              DELVZ                   # AND STORE IN Z.
                TS              DELVZ           +1      # SHOWS THAT IT REALLY MADE IT.

REPIP4          CS              ZERO
                TS              DELVX           +1      # LEAVE THESE AT NEGZERO
                TS              DELVY           +1
                TS              DELVZ           +1
                CA              CDUX                    # READ CDUS INTO CDUTEMP AS A VECTOR

                TS              CDUTEMP
                CA              CDUY                    # THE THRUST ESTIMATION FILTER IN FINDCDUD
                TS              CDUTEMP         +2      # REQUIRES THAT THE CDUS BE READ AT THE
                CA              CDUZ                    # TIME THE PIPAS ARE READ
                TS              CDUTEMP         +4
                CAF             ZERO
                TS              CDUTEMP         +1
                TS              CDUTEMP         +3
                TS              CDUTEMP         +5

## Page 782
                EXTEND

                DCA             PIPRETRN                # RETURN TO LOCATION AFTER CALL
                DXCH            Z

## Page 783

REREADAC        EXTEND
                DCA             DONECAD
                DXCH            PIPRETRN

REPIPASR        CCS             PIPAGE                  # WAS I READING PIPS.

                TCF             PIPASR          +1
                CCS             DELVZ           +1      # PIPAGE = 0  (I WAS READING PIPS.)
                TCF             REPIP4                  # Z WAS READ OK
                TCF             +3                      # Z NOT DONE, CHECK Y.
                TCF             REPIP4
                TCF             REPIP4

                CCS             DELVY           +1      # HAS IT CHANGED FROM ITS +ZERO INIT VALU
                TCF             +3                      # YES, Y DONE.  TRY TO REDO Z.
                TCF             CHKDELVX                # NO, GO LOOK AT X.
                TCF             +1                      # YES

                CCS             TEMZ                    # DOES TEMZ STILL = -0.
                TCF             +4                      # NO-TRY TO RESTORE
                TCF             +3
                TCF             +2
                TCF             REPIP3                  # YES, GO BACK AND READ Z AGAIN.

                CS              TEMXY                   # MUCH MORE LOGIC COULD BE INCORPORATED
                TCF             REPIP3B                 # TO CHECK PIPA CTR FOR SIZE

CHKDELVX        CCS             DELVX           +1      # HAS THIS CHANGED.

                TCF             +3                      # YES
                TCF             CHKTEMX                 # NO
                TCF             +1                      # YES
                CCS             TEMY
                TCF             +4
                TCF             +3
                TCF             +2
                TCF             REPIP2
                CS              TEMXY
                TCF             REPIP2B

CHKTEMX         CCS             TEMX                    # HAS THIS CHANGED.

                TCF             +4                      # YES
                TCF             +3                      # YES
                TCF             +2                      # YES
                TCF             REPIP1                  # NO
                CS              TEMXY
                TCF             REPIP1B

                EBANK=          DVCNTR
DONECAD         2CADR           PIPSDONE
