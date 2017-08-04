### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    THRUST_MAGNITUDE_FILTER.agc
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
## Reference:   pp. 862-863
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-08 HG   Transcribed
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 862
# PROGRAM NAME - ATMAG

# MODIFICATION BY - BERMAN AND CATTANACH

# FUNCTIONAL DESCRIPTION -

#     THE THRUST MAGNITUDE FILTER CONVERTS ABDELV TO M/CS, INVERTS AND COMBINES IT WITH TWO PRECEDING
# INPUTS TO PRODUCE THE INVERTED EXHAUST VELOCITY, BURN UP TIME, AND ANTICIPATED THRUST ACCELERATION FOR
# THE NEXT TIME INCREMENT.  THRUST MAGNITUDE FILTER IS BYPASSED UNTIL AFTER THE MAIN ENGINE GOES ON.

# CALLING SEQUENCE - ATMAG IS ENTERED BY EXTEND                AND        EXTEND
#                                       DCA     ATMAGAD                   DCA     ATMAG4
#                                       DXCH    AVGEXIT                   DXCH    AVGEXIT
# NORMAL EXIT - FROM ATMAG BY GOTO

#                                   ASCENT

# OUTPUT - INVERTED EXHAUST VELOCITY, BURN UP TIME, AND ANTICIPATED THRUST ACCELERATION

# ERASABLE INITIALIZATION REQUIRED - THIS IS DONE BY PRE-APS PROGRAMS

# DEBRIS - ABDVCONV, 1/DV1, 1/DV2, 1/VE, TBUP, AT.

# ALARM OR ABORT EXIT MODES -

# SUBROUTINES CALLED - NONE

                BANK            32

                EBANK=          TCO                     # EBANK4

ATMAG           TC              INTPRET
                DLOAD           DSU
                                ABDVCONV                # ABDVCONV (PIPA READING CONVERTED TO
                                DVMIN                   # M/CS) IS INVERTED AND SCALED AT 2**-5
                BMN             SLOAD                   # AS INPUT TO FILTER
                                FILTEND
                                BIT6H

                DDV             EXIT
                                ABDVCONV

                DXCH            MPAC
                DXCH            1/DV2
                DXCH            1/DV1
                DXCH            MPAC                    # MPAC=1/DV0*2**-5

                TC              INTPRET
                PUSH            DSU                     # PUSH DOWN 1/DVO			2

                                1/DV2                   # MPAC = (1/DV0-1/DV2)*2**-5
                PUSH            SLR			#					4
                                8D                      # MPAC = (1/DV0-1/DV2)*2**3 = 1/VE*2**4

## Page 863
                STODL           1/VE                    # INVERTED EXHAUST VELOCITY              2

                SR1             DAD                     # MPAC = (1/DV0-1/DV2)*2**-6
                                1/DV1                   # MPAC = (1/DV0+2/DV1-1/DV2)*2**-6
                SR1R            DAD                     # MPAC = (5/DV0+2/DV1-1/DV2)*2**-7       0
                DMP             DMP

                                DP2/3H                  # (5/6DV0+1/3DV1-1/6DV2)*2**-5
                                DTASC1                  # MPAC = (1/DV3*2**-5) * (DELTAT*2**-8) =
                                                        #        DELTAT/DV3*2**-13
                DDV
                                1/VE                    # (TBUP/VE*2**-13)/(1/VE*2**4)=TBUP*2**-17
                STODL           TBUP                    # BURN UP TIME

                                1/DV1                   # MPAC = 2**-5/DV1
                SR1             DSU                     # MPAC = 2**-6/DV1
                                00D                     # MPAC = (-2/DV0+1/DV1)*2**-6
                SR1             DAD                     # MPAC = (-2/DV0+1/DV1)*2**-7
                                1/DV2                   # MPAC = (-2/DV0+1/DV1+4/DV2)*2**-7

                DMP             DMP                     # MPAC = (-2/3DV0+1/3DV1+4/3DV2)*2**-6 =
                                DP2/3H                  #        1/DV3*2**-6
                                DTASC1                  # MPAC = (1/DV3*2**-6)*(DELTAT*2**-8) =
                                                        # DELTA/DV3*2**-14 = 1/AT*2**-14
                BDDV
                                D1/32                   # MPAC = 2**-5/(1/AT*2**-14) = AT*2**9
                STORE           AT                      # ANTICIPATED THRUST ACCELERATION

FILTEND         GOTO
                                ASCENT

BIT6H           OCT             40
DVMIN           2DEC            .03B-5
DTASC1          2DEC            200B-8
