### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    UPDATE_PROGRAM_PART_1_OF_2.agc
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
## Reference:   pp. 303-304
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-29 HG   Transcribed
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 303
                BANK            11
                EBANK=          STBUFF
# THE UPDATE PROGRAM PROCESSES COMMANDS AND DATA INSERTIONS REQUESTED BY THE GROUND VIA UPLINK
# THE PROGRAM IS INITIATED BY UPLINK ENTRY OF VERBS 60,61,64-76

#     INPUT
# ENTRY           DESCRIPTION OF DATA
#  V64EIEXXXXXE   DOUBLE PRECISION GROUND ELAPSED TIMEIN CSEC (OCTAL)
#   XXXXXE
#  V65E           SET GUIDANCE REFERENCE RELEASE DISCRETE
#  V66E           INITIATE THE LGC DFI TLM CALIBRATE ROUTINE
#  V67EXXXE       ENTER A THREE DIGIT OCTAL NUMBER REPRESENTING THE
#                  8-BIT COMMAND TO BE SENT TO THE LMP
#  V70EIETTTTTE   TIMER I IS SET TO TTTTT (OCTAL,SEC) UNLESS
#                  TTTTT=+0 OR -0 WHEN THE TIMER IS SET TO -0 OR
#                  TTTTT .LT. -0 WHICH STARTS MISSION PHASE
#  V71EIEPPE      MISSION PHASE REGISTER I IS SET TO PP (OCTAL)
#  V72EIEPPETTTTTE    SAME AS V70,V71
#  V73EIE         CHANGE THE STATE (ENABLE OR INHIBIT) OF DPS COLD SOAK

#                  DISCRETE (I=1), OR RCS COLD SOAK DISCRETE (I=2).
#  V74E           STOP MISSION TIMERS
#  V75E1EXXXXXE... FOR DPS1, ENTER MSB,LSB OF R(P)
#  V75E2EXXXXXE... FOR DPS2, ENTER MSB,LSB OF CPT(6),CPT(7),CPT(8). THE
#                  DESIRED VALUE X 0.5 SHOULD BE ENTERED
#  V75E3EXXXXXE... FOR APS2,ENTER MSB,LSB OF RCSM(TA)0, RCSM(TA)1,
#                  RCSM(TA)2,TA,RD,TIME IN CSEC X 2(28)
#                  POSITION IN METERS X 2(-24)
#  V75E4EXXXXXE... FOR APS3, ENTER ALL BUT RD ABOVE
#  V76EXXXXXE...  STATE VECTOR MSB,LSB OF X,Y,Z,XVEL,YVEL,ZVEL,TIME.
#                  TIME IN CSEC X 2(28)
#                  POSITION IN METERS X 2(-24) X 0.512
#                  VELOCITY IN METERS/CSEC X 2(-7) X0.64876819
65UPDAT         TC              POSTJUMP
                CADR            GRRPLACE
74UPDAT         TC              POSTJUMP
                CADR            DOV74
66UPDAT         INHINT
                TC              IBNKCALL
                CADR            DFITMCAL
                TCF             ENDOFJOB

73UPDAT         CA              OCT73

                TC              67UPDAT         +1
67UPDAT         CA              OCT67
                TS              MPAC
                CA              ONE
                TC              76UPDAT         +3
70UPDAT         CA              OCT70
                TC              71UPDAT         +1
71UPDAT         CA              OCT71

## Page 304
                TS              MPAC
                CA              TWO

                TC              76UPDAT         +3
64UPDAT         CA              11OCT64
                TC              72UPDAT         +1
72UPDAT         CA              OCT72
                TS              MPAC
                CA              THREE
                TC              76UPDAT         +3
76UPDAT         CA              OCT76
                TS              MPAC
                CA              11OCT16
                TS              MPAC            +1
                TC              75UPDAT         +2
75UPDAT         CA              11OCT75
                TS              MPAC
                CA              FLAGWRD2                # TEST IF TIMERS ENABLED
                MASK            BIT5
                EXTEND
                BZF             XACTALM                 #  NO, RETURN
                TC              BANKCALL
                CADR            UPPART2
OCT73           OCT             00073
OCT67           OCT             00067
OCT70           OCT             00070

OCT71           OCT             00071
11OCT64         OCT             00064
OCT72           OCT             00072
OCT76           OCT             00076
11OCT16         OCT             16
11OCT75         OCT             00075
