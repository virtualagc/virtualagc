### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    THROTTLE_CONTROL.agc
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
## Reference:   pp. 795-801
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-09 HG   Transcribed
##              2017-06-15 HG   Fix operator DXCH -> DAS
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 795
                BANK            30
                EBANK=          ETHROT


#   INPUTS TO THROTTLE CONTROL ARE /A/ AND /AFC/, ACCELERATIONS PRESENT

# AND DESIRED, SCALED IN UNITS OF 2(-5) M/CS/CS, AND MASS IN UNITS OF
# 2(15) KILOGRAMS.
#   THIS PROGRAM CAUSES THE THROTTLE TO RESPOND TO ACCELERATION COMMANDS
# IN THE MANNER DESCRIBED BY FIGURE 5.3-5 OF THE FLIGHT 206 GSOP.

                                                        # ***************
                                                        # * SUBROUTINES *
                                                        # ***************

                                                        # THIS SUBROUTINE MULTIPLIES ACCELERATION
                                                        # (ARRIVING IN A AND L) BY MASS AND LEAVES
                                                        # FORCE (THRUST) IN A AND L, SCALED AT

                                                        # ABOUT 3.3 POUNDS PER BIT.
MASSMULT        EXTEND
                QXCH            BUF                     # PRESERVING RETURN ADDRESS
                DXCH            MPAC
                TC              DMP                     # LEAVES ODDLY SCALED FORCE IN MPAC
                ADRES           MASS
                TC              DMP                     # LEAVES PROPERLY SCALED FORCE IN MPAC
                ADRES           SCALEFAC
                DXCH            MPAC            +1      # LOADING FORCE INTO A AND L
                TC              BUF

## Page 796
                                                        # ***********

                                                        # * ENTRIES *
                                                        # ***********

                                                        # THIS ENTRY SETS UP A JOB WHICH WILL
                                                        # DELIVER A SPECIFIED FRACTION OF MAXIMUM
                                                        # THRUST.   THIS FRACTION ARRIVES (SP) IN
                                                        # REGISTER PCNTF.

PCNTFMAX        DXCH            RTNHOLD                 # RETAINING 2CADR FOR RETURN TO USER
                CAF             PRIO25

                INHINT
                TC              NOVAC
                EBANK=          ETHROT
                2CADR           PCNTJOB

                RELINT
                TCF             AWAY

                                                        # NORMAL ENTRY FROM GUIDANCE EQUATIONS:
#                                         THE JOB SET UP HERE DELIVERS A THRUST
                                                        # CORRESPONDING TO THE DESIRED MAGNITUDE
                                                        # OF THRUST-ACCELERATION.   THIS VALUE

                                                        # ARRIVES (DP) IN /ACF/.

THROTCON        DXCH            RTNHOLD                 # RETAINING 2CADR FOR RETURN TO USER
                CAF             PRIO30
                INHINT
                TC              NOVAC
                EBANK=          ETHROT
                2CADR           ACCLJOB

                RELINT

                                                        # THIS RETURN IS COMMON TO BOTH ENTRIES.

AWAY            DXCH            RTNHOLD
                DTCB

## Page 797
                                                        # ***************
                                                        # * COMPUTATION *
                                                        # ***************

PCNTJOB         TC              PHASCHNG
                OCT             04024                   # ?


                EXTEND
                DCS             -FMAX
                DXCH            MPAC
                CA              PCNTF
                TC              SHORTMP
                DXCH            MPAC                    # LOADING
                DXCH            FC                      # STORING
                TCF             FOLDCALC



ACCLJOB         =               FCCALC

FCCALC          TC              PHASCHNG
                OCT             04024                   # ?

                EXTEND
                DCA             /ACF/
                TC              MASSMULT
                DXCH            FC                      # FC = MASS /ACF/, SCALED



FOLDCALC        EXTEND
                DCA             /AF/
                TC              MASSMULT
                DXCH            FOLD                    # FOLD = MASS /AF/, SCALED



                                                        # AFTER FIRST ZEROING PIF, THIS ROUTINE
                                                        # CHECKS THE ENGINE-OFF BIT.  IF THE
                                                        # ENGINE PROVES TO BE OFF FCOLD IS SET TO

                                                        # 10 PERCENT FMAX, AND, SINCE /AF/ DOES
                                                        # NOT REFLECT THE 10 PERCENT SETTING OF
                                                        # THE HAND THROTTLE, -10 PERCENT FMAX
                                                        # IS ADDED INTO PIF.

NEXTNEXT        CA              ZERO
                TS              PIF
                TS              PIF             +1
                CA              BIT14

## Page 798
                EXTEND

                RAND            11
                EXTEND
                BZF             WHERETO                 # BRANCH HERE IF ENGINE IS ON
                CS              -.1FMAX
                TS              FCOLD                   # SETTING FCOLD
                CA              -.1FMAX
                TS              PIF                     # SETTING PIF

## Page 799

                                                        # ************
                                                        # * DECISION *
                                                        # ************

WHERETO         CA              FC

                AD              -.1FMAX
                EXTEND
                BZMF            TIPTOE                  # BRANCH IF FC < OR = 10 PERCENT FMAX
                CA              FC
                AD              -.52FMAX
                EXTEND
                BZMF            DOPIF                   # BRANCH IF FC < 52 PERCENT
                CS              FC
                AD              .58FMAX
                EXTEND
                BZMF            FLATOUT                 # BRANCH IF FC > OR = 58 PERCENT FMAX,
                CA              FCOLD                   #   OTHERWISE, TEST FCOLD

                AD              -FMAX
                EXTEND
                BZMF            DOPIF                   # BRANCH IF FCOLD < OR = 100 PERCENT FMAX,
                                                        #  OTHERWISE (IN WHICH CASE FCOLD=HIGHT)
                                                        #  PROCEED TO FLATOUT

## Page 800
                                                        # *************

                                                        # * EXECUTION *
                                                        # *************

FLATOUT         CA              2FMAX
                TS              FC
                TCF             DOPIF

TIPTOE          EXTEND
                DCS             -.1FMAX
                DXCH            FC

DOPIF           TC              PHASCHNG
                OCT             04024                   # ?

                EXTEND
                DCA             FC
                TS              FCOLD                   # HISTORY
                DAS             PIF                     # OKAY SINCE PIF PREVIOUSLY WAS ZEROED
                EXTEND
                DCS             FOLD
                DAS             PIF                     # PIF = FC - FOLD + PRESETTING (IF ANY)
                CA              PIF


DOIT            TS              THRUST
                CAF             BIT4
                EXTEND
                WOR             14                      # AND THE ENGINE DOES THE REST...

                TC              PHASCHNG
                OCT             04024                   # GROUP NUMBER NOT FINALIZED

                TCF             ENDOFJOB

## Page 801
                                                        # *************
                                                        # * CONSTANTS *
                                                        # *************

                                                        # CONSTANTS FOR DECISION

2FMAX           DEC             +6400           B-14    # 200% FMAX


-FMAX           2DEC            +3200           B-14    # 100 % FMAX, NEGATIVE

.58FMAX         DEC             +1856           B-14    #  58 % FMAX

-.52FMAX        DEC             -1662           B-14    # JUST UNDER 52 % FMAX, NEGATIVE

-.1FMAX         2DEC            -320            B-14    #  10 % FMAX. NEGATIVE

SCALEFAC        2DEC            46.835424       B-14    # ABOUT 10000/(3 16 4.4482)  B-14
