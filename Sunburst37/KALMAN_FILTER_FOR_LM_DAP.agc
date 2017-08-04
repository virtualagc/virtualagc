### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    KALMAN_FILTER_FOR_LM_DAP.agc
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
## Reference:   pp. 541-553
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-05 HG   Transcribed
##              2017-06-07 HG   Remove illegal EXTEND
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 541
# THE FOLLOWING T5RUPT ENTRY BEGINS THE PROGRAM WHICH INITIALIZES THE KALMAN FILTER AND SETS UP A P-AXIS RUPT TO
# OCCUR 20 MS FROM ITS BEGINNING.

                EBANK=          DT
                BANK            21
FILTINIT        CAF             MS20F                   # RESET TIMER IMMEDIATELY: DT = 20 MS
                TS              TIME5


                LXCH            BANKRUPT                # INTERRUPT LEAD IN (CONTINUED)
                EXTEND
                QXCH            QRUPT

                EXTEND                                  # SET UP FOR P-AXIS RUPT
                DCA             PAX/FILT
                DXCH            T5ADR

                CAF             FIRSTADR                # SET UP TO AVOID DT CALCULATION DURING
                TS              STEERADR                # KALMAN FILTER INITIALIZATION PASS

                TCF             FILSTART

FIRSTADR        GENADR          FILFIRST

# THE FOLLOWING T5RUPT ENTRY BEGINS THE KALMAN FILTER PROGRAM.  THIS SECTION ALSO SETS UP A T5RUPT TO OCCUR 20 MS
# FROM ITS BEGINNING AND SETS IT TO GO TO THE LOCATION AT THE TOP OF THE POST FILTER RUPT LIST.

MOSTPASS        GENADR          DTCALC                  # WORD IN FILTPASS FOR THESE PASSES

FILTER          CAF             MS20F                   # RESET TIMER IMMEDIATELY: DT = 20 MS
                TS              TIME5

                LXCH            BANKRUPT                # INTERRUPT LEAD IN (CONTINUED)
                EXTEND
                QXCH            QRUPT

                TC              DISPDRIV                # DRIVE ICDU BITS IF NECESSARY.

                EXTEND                                  # SET RUPT ADDRESS TO TOP OF
                DCA             PFRPTLST                # POST FILTER RUPT LIST
                DXCH            T5ADR

                DXCH            PFRPTLST                # ROTATE 2CADR'S IN POST FILTER RUPT LIST
                DXCH            PFRPTLST        +6
                DXCH            PFRPTLST        +4
                DXCH            PFRPTLST        +2
                DXCH            PFRPTLST

# BEGIN THE KALMAN FILTER BY READING CDU ANGLES AND TIME.

FILSTART        TC              T6JOBCHK                # CHECK T6 CLOCK FOR P-AXIS ACTIVITY

## Page 542

                EXTEND
                DCA             CDUY                    # STORE CDUY AND CDUZ AT PI AND IN 2,S COM
                DXCH            STORCDUY
                EXTEND                                  # BEGIN READING THE CLOCK TO GET TIME
                READ            4                       #   INCREMENT.
                TS              L
                EXTEND
                RXOR            4                       # CHECK TO SEE IF CH 4 WAS IN TRANSITION
                EXTEND                                  #   WHEN IT WAS FIRST READ.
                BZF             +4                      # BRANCH IF TIME WAS THE SAME IN 2 READS.
                EXTEND
                READ            4
                TS              L                       # THIS TIME READ ALWAYS GIVES GOOD NO.
                TC              STEERADR                # SKIP DTCALC DURING INITIAL PASS

DTCALC          CS              L
                AD              DAPTIME                 # A CONTAINS THE TIME DIFFERENCE (DT)
                LXCH            DAPTIME                 #   SINCE THE LAST FILTER.
                EXTEND
                BZMF            +3
                AD              NEG1/2                  # THIS IS ADDING -1.0 TO -DT AND ACCOUNTS
                AD              NEG1/2                  # FOR AN OVERFLOW INTO CHANNEL 5

# SCALING OF DELTA T FOR KALMAN FILTER IS 1/8 SECOND.

                EXTEND                                  # TIME NOW SCALED AT 5.12 SECONDS
                MP              BIT7                    # FIRST RESCALE TO 5.12/64
                CS              .64
                EXTEND                                  # THEN RESCALE TO 5.12/(64*.64) OR
                MP              L                       # 5.12/40.96 WHICH IS THE SAME AS
                TS              DT                      # DT SCALED AT 1/8

# SET UP FILTER WEIGHTING VECTOR FOR THIS FILTER PASS.

                CCS             WPOINTER                # TEST FOR WEIGHTING VECTOR STEADY-STATE
                TCF             MOVEWGTS                # POINTER NOT YET ZERO (MULTIPLE OF THREE)
                EBANK=          DT
PAX/FILT        2CADR           PAXIS                   # (ROOM FOR 2CADR IN CCS HOLES)

                TCF             FLTZAXIS                # STEADY-STATE ALREADY, NO UPDATING AGAIN

MOVEWGTS        CS              THREE                   # SET UP POINTER FOR THIS PASS
                ADS             WPOINTER                # (NEVER GETS BELOW ZERO HERE)

                EXTEND                                  # WPOINTER IS INDEX = 87 FIRST TIME HERE
                INDEX           WPOINTER                # AND IS DECREASED BY 3 EVERY FILTER PASS
                DCA             WVECTOR                 # UNTIL THE STEADY-STATE IS REACHED.
                DXCH            W0                      # MOVE IN NEW W0,W1
                INDEX           WPOINTER
                CAF             WVECTOR         +2

## Page 543
                TS              W2                      # MOVE IN NEW W2

FLTZAXIS        CAF             TWO                     # SET UP INDEXER FOR D.P. PICKUP AND TO
                TS              QRCNTR                  # INDICATE Z-AXIS FILTER PASS

                TCF             FLTYAXIS

GOYFILTR        CAF             ZERO                    # SET INDEXER FOR Y-AXIS
                TS              QRCNTR

                TC              T6JOBCHK                # CHECK T6 CLOCK FOR P-AXIS ACTIVITY

FLTYAXIS        INDEX           QRCNTR
                DXCH            CDUYFIL                 # THETA IS D.P. SCALED AT 2 PI RADIANS
                DXCH            CDU
                INDEX           QRCNTR                  #   .
                DXCH            DCDUYFIL                # THETA IS D.P. SCALED AT PI/4 RAD/SEC
                DXCH            CDUDOT
                INDEX           QRCNTR                  #  ..                                 2

                DXCH            D2CDUYFL                # THETA IS D.P. SCALED AT PI/8 RAD/SEC
                DXCH            CDU2DOT
                INDEX           QRCNTR                  #  ...                        7       3
                CAE             Y3DOT                   # THETA IS S.P. SCALED AT PI/2 RAD/SEC
                XCH             CDU3DOT

# NOTE THAT THE FILTERED VARIABLES ARE READ DESTRUCTIVELY FOR SPEED AND EFFICIENCY AND THAT Y3DOT IS NOT UPDATED,
# SO IT MUST BE READ NON-DESTRUCTIVELY BUT NEED NOT BE RESTORED AFTER EACH KALMAN FILTER PASS.

## Page 544
# INTEGRATION EXTRAPOLATION EQUATIONS:

KLMNFLTR        CAE             CDU2DOT                 # A SCALED AT PI/8 (USE S.P.)
                EXTEND
                MP              DT                      # ADT SCALED AT PI/64 OR .5ADT AT PI/128
                EXTEND
                MP              BIT10                   # RESCALE BY RIGHT SHIFT 5
                AD              CDUDOT                  # W + .5ADT SCALED AT PI/4
                EXTEND
                MP              DT                      # (W + .5ADT)DT SCALED AT PI/32
                EXTEND
                MP              BIT9                    # RESCALE BY RIGHT SHIFT 6 (KEEP D.P.)
                DAS             CDU                     # CDU = CDU + (W + .5ADT)DT SCALED AT 2PI

                CAE             CDU3DOT                 # ADOT SCALED AT PI/2(7)
                EXTEND
                MP              DT                      # .5ADOTDT SCALED AT PI/2(11)
                TS              ITEMP5                  # (SAVE FOR ALPHA INTEGRATION)
                EXTEND
                MP              BIT7                    # RESCALE BY RIGHT SHIFT 8
                AD              CDU2DOT                 # A + .5ADOTDT SCALED AT PI/8
                EXTEND
                MP              DT                      # (A + .5ADOTDT)DT SCALED AT PI/64
                EXTEND
                MP              BIT11                   # RESCALE BY RIGHT SHIFT 4 (KEEP D.P.)
                DAS             CDUDOT                  # W = W + (A + .5ADOTDT)DT SCALED AT PI/4

                CAE             ITEMP5                  # ADOTDT SCALED AT PI/2(10) (FROM ABOVE)
                EXTEND
                MP              BIT8                    # RESCALE BY RIGHT SHIFT 7 (KEEP D.P.)
                DAS             CDU2DOT                 # A = A + ADOTDT SCALED AT PI/8

## Page 545

# WEIGHTING VECTOR ADJUSTMENT EQUATIONS:

                EXTEND                                  # CONVERT CDU INTEGRATED VALUE FROM DOUBLE
                DCA             CDU                     # PRECISION SCALED AT 2PI IN ONES COMPLE-
                TC              ONETOTWO                # MENT TO SINGLE PRECISION SCALED AT PI
                CAE             STORCDUZ                # IN TWOS COMPLEMENT, THEN DIFFERENCE WITH
                EXTEND                                  # STORED CDU REGISTER READING TO GET A
                MSU             ITEMP5                  # SINGLE PRECISION ONES COMPLEMENT RESULT

                TS              DPDIFF                  # SCALED AT PI RADIANS (UPPER HALF)

                CS              CDU             +1      # CREATE LOW ORDER WORD OF D.P. DIFFERENCE
                DOUBLE                                  # ONES COMPLEMENT SCALED AT PI RADIANS AND
                XCH             DPDIFF          +1      # USE S.P. RESULT ABOVE AS HIGH ORDER WORD

                EXTEND                                  # RESCALE DPDIFF TO PI
                DCA             DPDIFF
                DDOUBL
                LXCH            ITEMP5                  # SAVE LOW ORDER WORD FOR D.P. MULTIPLY
                EXTEND
                MP              W0                      # CDU = CDU + DPDIFF (D.P.) * W0 (S.P.)
                DAS             CDU
                CAE             ITEMP5                  # W0 IS SCALED AT 2
                EXTEND                                  # DPDIFF IS RESCALED TO PI
                MP              W0                      # W0*DPDIFF IS SCALED AT 2PI (AS CDU)
                ADS             CDU             +1
                TS              L
                TCF             +2
                ADS             CDU

                CAE             DPDIFF                  # RESCALE DPDIFF TO PI/128
                EXTEND

                MP              BIT9                    # DPDIFF (D.P.) * 256
                LXCH            ITEMP5
                CAE             DPDIFF          +1
                EXTEND
                MP              BIT9
                AD              ITEMP5
                LXCH            ITEMP5

                EXTEND                                  #  .     .
                MP              W1                      # CDU = CDU + DPDIFF (D.P.) * W1 (S.P.)
                DAS             CDUDOT
                CAE             ITEMP5                  # W1 IS SCALED AT 32
                EXTEND                                  # DPDIFF IS RESCALED TO PI/128
                MP              W1                      # W1*DPDIFF IS SCALED AT PI/4 (AS CDUDOT)
                ADS             CDUDOT          +1
                TS              L
                TCF             +2
                ADS             CDUDOT

## Page 546
                CAE             DPDIFF                  # RESCALE DPDIFF TO PI/64
                EXTEND
                MP              BIT8                    # DPDIFF (D.P.) * 128
                LXCH            ITEMP5
                CAE             DPDIFF          +1
                EXTEND
                MP              BIT8
                AD              ITEMP5
                LXCH            ITEMP5

                EXTEND                                  #  ..    ..
                MP              W2                      # CDU = CDU + DPDIFF (D.P.) * W2 (S.P.)
                DAS             CDU2DOT
                CAE             ITEMP5                  # W2 IS SCALED AT 8

                EXTEND
                MP              W2                      # W2*DPDIFF IS SCALED AT PI/8 (AS CDU2DOT)
                ADS             CDU2DOT         +1
                TS              L
                TCF             +2
                ADS             CDU2DOT

# RESTORE VARIABLES AND TEST FOR COMPLETION OR ADDITIONAL AXIS.

FILTAXIS        DXCH            CDU
                INDEX           QRCNTR                  # THETA IS D.P. SCALED AT 2 PI RADIANS
                DXCH            CDUYFIL
                DXCH            CDUDOT                  #   .
                INDEX           QRCNTR                  # THETA IS D.P. SCALED AT PI/4 RAD/SEC
                DXCH            DCDUYFIL
                DXCH            CDU2DOT                 #  ..                                 2
                INDEX           QRCNTR                  # THETA IS D.P. SCALED AT PI/8 RAD/SEC
                DXCH            D2CDUYFL

                XCH             STORCDUY                # INTERCHANGE CDU READINGS
                XCH             STORCDUZ
                XCH             STORCDUY

                CCS             ITEMP6                  # ITEMP6 IS AXIS INDEXER
                TCF             GOYFILTR                # IF 2, Y-AXIS STILL TO GO

                CS              T5ADR                   # IF THE TRIM GIMBAL CONTROL RUPT IS NEXT,
                AD              GTS2CADR                # DO THE Q,R-AXIS STATE TRANSFORMATIONS
                EXTEND                                  # AND THE 20 MS STATE EXTRAPOLATION
                BZF             GIMBAL
                TCF             RESUME                  # OTHERWISE, RESUME

# SUBROUTINE FOR FILTER WHICH TAKES 1 COMPLEMENT NUMBER INTO A 2 COMP.

ONETOTWO        DDOUBL                                  # SEE RTB OP CODES IN BANK 15 FOR NOTES ON
                CCS             A                       #   THIS COMPUTATION.

## Page 547
                AD              ONE
                TCF             +2
                COM
                TS              ITEMP5
                TCF             +4
                INDEX           A
                CAF             LIMITS
                ADS             ITEMP5
                TC              Q                       # RETURN

# THIS PROGRAM INITIALIZES THE KALMAN FILTER PROGRAM.

FILFIRST        LXCH            DAPTIME                 # INITIALIZE TIME.
                CAF             POINT=90                # INITIALIZE THE WEIGHTING VECTOR POINTER
                TS              WPOINTER
                CAF             MOSTPASS                # SET UP FOR NEXT PASSES
                TS              STEERADR
                EXTEND                                  # SET UP POST FILTER RUPT LIST
                DCA             DGTSFADR

                DXCH            PFRPTLST
                EXTEND
                DCA             PAX/FILT
                DXCH            PFRPTLST        +2
                EXTEND
                DCA             PAX/FILT
                DXCH            PFRPTLST        +6
                EXTEND
                DCA             GTS2CADR
                DXCH            PFRPTLST        +4
                EXTEND                                  # CHANGE POST P FILTER TO FILTER
                DCA             POSTPFIL
                DXCH            PFILTADR

                CAE             STORCDUY
                EXTEND
                MP              BIT14
                DXCH            CDUYFIL                 # INITIALIZE THE STATE VECTOR TO CDU VALUE
                CAE             STORCDUZ
                EXTEND
                MP              BIT14
                DXCH            CDUZFIL
                CA              ZERO

                TS              DCDUYFIL
                TS              DCDUYFIL        +1      # INITIALIZE THE DERIVATIVES OF THE STATE
                TS              DCDUZFIL
                TS              DCDUZFIL        +1
                TS              D2CDUYFL
                TS              D2CDUYFL        +1
                TS              D2CDUZFL
                TS              D2CDUZFL        +1

## Page 548
                TS              Y3DOT
                TS              Z3DOT

                TS              NEGUQ
                TS              NEGUR
                TCF             RESUME



.64             DEC             0.64000
BIT12-13        OCTAL           14000
POINT=90        DEC             90                      # POINTER INITIALIZED ONE GROUP PAST END
MS20F           OCTAL           37776
MS30F           OCTAL           37775
                EBANK=          DT
DGTSFADR        2CADR           DGTS

PAXISADR        GENADR          PAXIS
                EBANK=          DT
GTS2CADR        2CADR           GTS

                EBANK=          DT
POSTPFIL        2CADR           FILTER

## Page 549
# THE KALMAN FILTER WEIGHTINF VECTORS ARE LISTED IN THE FOLLOWING TABLE ALONG WITH THE TIME FROM THE LAST FILTER
# INITIALIZATION FOR WHICH THEY ARE TO BE USED.  (THE VECTORS ARE STORED IN ORDERED TRIPLES (W0,W1,W2) IN
# DESCENDING ORDER IN TIME WITH THE STEADY STATE VALUES AT THE TOP.)

# THE COMPONENTS ARE SCALED AS FOLLOWS:
#          W0 : SCALED AT  2
#          W1 : SCALED AT 32
#          W2 : SCALED AT  8

WVECTOR         DEC             0.18608                 # W0 FROM RELATIVE TIME 1.5 SECS OR MORE
                DEC             0.02696                 # W1 FROM RELATIVE TIME 1.5 SECS OR MORE
                DEC             0.17105                 # W2 FROM RELATIVE TIME 1.5 SECS OR MORE
                DEC             0.14358                 # W0 AT RELATIVE TIME : 1.45 SECONDS
                DEC             0.02890                 # W1 AT RELATIVE TIME : 1.45 SECONDS
                DEC             0.17727                 # W2 AT RELATIVE TIME : 1.45 SECONDS
                DEC             0.14565                 # W0 AT RELATIVE TIME : 1.40 SECONDS
                DEC             0.02959                 # W1 AT RELATIVE TIME : 1.40 SECONDS
                DEC             0.18129                 # W2 AT RELATIVE TIME : 1.40 SECONDS
                DEC             0.14809                 # W0 AT RELATIVE TIME : 1.35 SECONDS
                DEC             0.30479                 # W1 AT RELATIVE TIME : 1.35 SECONDS
                DEC             0.18678                 # W2 AT RELATIVE TIME : 1.35 SECONDS
                DEC             0.15090                 # W0 AT RELATIVE TIME : 1.30 SECONDS
                DEC             0.03154                 # W1 AT RELATIVE TIME : 1.30 SECONDS
                DEC             0.19403                 # W2 AT RELATIVE TIME : 1.30 SECONDS
                DEC             0.15409                 # W0 AT RELATIVE TIME : 1.25 SECONDS
                DEC             0.03283                 # W1 AT RELATIVE TIME : 1.25 SECONDS
                DEC             0.20340                 # W2 AT RELATIVE TIME : 1.25 SECONDS
                DEC             0.15767                 # W0 AT RELATIVE TIME : 1.20 SECONDS
                DEC             0.03437                 # W1 AT RELATIVE TIME : 1.20 SECONDS
                DEC             0.21525                 # W2 AT RELATIVE TIME : 1.20 SECONDS
                DEC             0.16163                 # W0 AT RELATIVE TIME : 1.15 SECONDS
                DEC             0.03616                 # W1 AT RELATIVE TIME : 1.15 SECONDS

                DEC             0.23000                 # W2 AT RELATIVE TIME : 1.15 SECONDS
                DEC             0.16595                 # W0 AT RELATIVE TIME : 1.10 SECONDS
                DEC             0.03824                 # W1 AT RELATIVE TIME : 1.10 SECONDS
                DEC             0.24814                 # W2 AT RELATIVE TIME : 1.10 SECONDS
                DEC             0.17063                 # W0 AT RELATIVE TIME : 1.05 SECONDS
                DEC             0.04062                 # W1 AT RELATIVE TIME : 1.05 SECONDS
                DEC             0.27018                 # W2 AT RELATIVE TIME : 1.05 SECONDS
                DEC             0.17560                 # W0 AT RELATIVE TIME : 1.00 SECONDS
                DEC             0.04332                 # W1 AT RELATIVE TIME : 1.00 SECONDS
                DEC             0.29668                 # W2 AT RELATIVE TIME : 1.00 SECONDS
                DEC             0.18080                 # W0 AT RELATIVE TIME : 0.95 SECONDS
                DEC             0.04634                 # W1 AT RELATIVE TIME : 0.95 SECONDS
                DEC             0.32824                 # W2 AT RELATIVE TIME : 0.95 SECONDS
                DEC             0.18614                 # W0 AT RELATIVE TIME : 0.90 SECONDS
                DEC             0.04968                 # W1 AT RELATIVE TIME : 0.90 SECONDS
                DEC             0.36531                 # W2 AT RELATIVE TIME : 0.90 SECONDS
                DEC             0.19147                 # W0 AT RELATIVE TIME : 0.85 SECONDS
                DEC             0.05328                 # W1 AT RELATIVE TIME : 0.85 SECONDS

## Page 550
                DEC             0.40821                 # W2 AT RELATIVE TIME : 0.85 SECONDS
                DEC             0.19659                 # W0 AT RELATIVE TIME : 0.80 SECONDS
                DEC             0.05707                 # W1 AT RELATIVE TIME : 0.80 SECONDS
                DEC             0.45721                 # W2 AT RELATIVE TIME : 0.80 SECONDS
                DEC             0.20122                 # W0 AT RELATIVE TIME : 0.75 SECONDS
                DEC             0.06089                 # W1 AT RELATIVE TIME : 0.75 SECONDS
                DEC             0.50999                 # W2 AT RELATIVE TIME : 0.75 SECONDS
                DEC             0.20505                 # W0 AT RELATIVE TIME : 0.70 SECONDS
                DEC             0.06451                 # W1 AT RELATIVE TIME : 0.70 SECONDS
                DEC             0.56522                 # W2 AT RELATIVE TIME : 0.70 SECONDS
                DEC             0.20775                 # W0 AT RELATIVE TIME : 0.65 SECONDS
                DEC             0.06759                 # W1 AT RELATIVE TIME : 0.65 SECONDS
                DEC             0.61768                 # W2 AT RELATIVE TIME : 0.65 SECONDS
                DEC             0.20912                 # W0 AT RELATIVE TIME : 0.60 SECONDS

                DEC             0.06972                 # W1 AT RELATIVE TIME : 0.60 SECONDS
                DEC             0.65979                 # W2 AT RELATIVE TIME : 0.60 SECONDS
                DEC             0.20934                 # W0 AT RELATIVE TIME : 0.55 SECONDS
                DEC             0.07062                 # W1 AT RELATIVE TIME : 0.55 SECONDS
                DEC             0.68165                 # W2 AT RELATIVE TIME : 0.55 SECONDS
                DEC             0.20919                 # W0 AT RELATIVE TIME : 0.50 SECONDS
                DEC             0.07028                 # W1 AT RELATIVE TIME : 0.50 SECONDS
                DEC             0.67330                 # W2 AT RELATIVE TIME : 0.50 SECONDS
                DEC             0.21020                 # W0 AT RELATIVE TIME : 0.45 SECONDS
                DEC             0.06931                 # W1 AT RELATIVE TIME : 0.45 SECONDS
                DEC             0.62883                 # W2 AT RELATIVE TIME : 0.45 SECONDS
                DEC             0.21441                 # W0 AT RELATIVE TIME : 0.40 SECONDS
                DEC             0.06908                 # W1 AT RELATIVE TIME : 0.40 SECONDS
                DEC             0.55030                 # W2 AT RELATIVE TIME : 0.40 SECONDS
                DEC             0.22391                 # W0 AT RELATIVE TIME : 0.35 SECONDS
                DEC             0.07162                 # W1 AT RELATIVE TIME : 0.35 SECONDS
                DEC             0.44810                 # W2 AT RELATIVE TIME : 0.35 SECONDS
                DEC             0.24049                 # W0 AT RELATIVE TIME : 0.30 SECONDS
                DEC             0.07956                 # W1 AT RELATIVE TIME : 0.30 SECONDS
                DEC             0.33713                 # W2 AT RELATIVE TIME : 0.30 SECONDS
                DEC             0.26566                 # W0 AT RELATIVE TIME : 0.25 SECONDS
                DEC             0.09646                 # W1 AT RELATIVE TIME : 0.25 SECONDS
                DEC             0.23140                 # W2 AT RELATIVE TIME : 0.25 SECONDS

                DEC             0.30123                 # W0 AT RELATIVE TIME : 0.20 SECONDS
                DEC             0.12841                 # W1 AT RELATIVE TIME : 0.20 SECONDS
                DEC             0.14087                 # W2 AT RELATIVE TIME : 0.20 SECONDS
                DEC             0.34996                 # W0 AT RELATIVE TIME : 0.15 SECONDS
                DEC             0.18850                 # W1 AT RELATIVE TIME : 0.15 SECONDS
                DEC             0.07101                 # W2 AT RELATIVE TIME : 0.15 SECONDS
                DEC             0.41554                 # W0 AT RELATIVE TIME : 0.10 SECONDS
                DEC             0.31141                 # W1 AT RELATIVE TIME : 0.10 SECONDS
                DEC             0.02408                 # W2 AT RELATIVE TIME : 0.10 SECONDS
                DEC             0.49561                 # W0 AT RELATIVE TIME : 0.05 SECONDS
                DEC             0.61404                 # W1 AT RELATIVE TIME : 0.05 SECONDS
                DEC             0.00006                 # W2 AT RELATIVE TIME : 0.05 SECONDS

## Page 551
# DUMMY TRIM GIMBAL RUPT:

DGTS            CAF             MS30F                   # RESET TIMER IMMEDIATELY: DT = 30 MS
                TS              TIME5

                EXTEND                                  # SET UP FILTER RUPT

                DCA             POSTPFIL
                DXCH            T5ADR

                LXCH            BANKRUPT                # INTERRUPT LEAD IN (CONTINUED)
                EXTEND
                QXCH            QRUPT

                TC              DISPDRIV                # DRIVE ICDU BITS IF NECESSARY.

                TCF             RESUME

                EBANK=          DT

                BANK            20

# DUMMY FILTER RUPT AFTER Q,R-AXES RUPT:

MS20120         OCTAL           37776
                EBANK=          TQR
PAXBNK20        2CADR           PAXIS

FILDUMMY        CAF             MS20120                 # RESET TIMER IMMEDIATELY: DT = 20 MS
                TS              TIME5

                LXCH            BANKRUPT                # INTERRUPT LEAD IN (CONTINUED)
                EXTEND                                  # SAVE THE LAST Q ON ALL T5RUPT LEAD IN'S
                QXCH            QRUPT

                EXTEND                                  # SET UP PAXIS RUPT
                DCA             PAXBNK20
                DXCH            T5ADR

                CS              TQR
                AD              CSPINKF
                EXTEND
                BZMF            FULLCSP

                CA              TQR
                EXTEND
                MP              BIT5
                CAE             L
                EXTEND
                MP              16/25KF
                TS              TQR
                TC              JETTSUB
                CAF             ZERO

## Page 552
                TS              TQR
                TCF             RESUME

FULLCSP         COM
                TS              ITEMP2
                CA              CSPAT1
                TS              TQR
                TC              JETTSUB
                CAE             ITEMP2
                TS              TQR
                TCF             RESUME

JETTSUB         EXTEND
                MP              NO.QJETS
                CAE             L
                EXTEND
                MP              1JACCQ
                TS              JETRATEQ
                ADS             SUMRATEQ
                CAE             TQR
                EXTEND
                MP              NO.RJETS
                CAE             L
                EXTEND
                MP              1JACCR
                TS              JETRATER

                ADS             SUMRATER
                CAE             WFORQR
                EXTEND
                MP              TQR
                AD              (1-K)/8
                EXTEND
                MP              BIT4
                LXCH            ITEMP1
                CAE             JETRATEQ
                EXTEND
                MP              ITEMP1
                TS              JETRATEQ
                CAE             JETRATER
                EXTEND
                MP              ITEMP1
                TS              JETRATER
                TC              Q
16/25KF         DEC             0.64000
CSPAT1          DEC             0.10000
CSPINKF         DEC             0.00977

## Page 553
# SUBROUTINE: DISPDRIV            MOD. NO. 0  DATE: NOVEMBER 14, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS SUBROUTINE SETS THE ICDU DRIVE BITS EVERY OTHER TIME IT IS CALLED.  IT ALWAYS CHANGES THE VALUE OF
# "DISPLACT" TO INDICATE THE PASSING OF 100 MS, SINCE THIS FLAG IS TESTED BY "EIGHTBAL" IN THE P-AXIS T5RUPT.
# THE ICDU IS DRIVEN ONLY 30 MS AFTER "EIGHTBAL" ENABLED IT.

# CALLING SEQUENCES (FROM "DUMMYFIL" AND "FILTER"):

#                                         L        TC     DISPDRIV        (MUST BE FROM SAME BANK)
#                                         L +1    (RETURN)

# SUBROUTINES CALLED: NONE.       NORMAL EXIT: BY TC Q  TO L +1 .

# ALARM/ABORT MODES: NONE.        INPUT: PRESENT VALUE IN  DISPLACT ,

# OUTPUT: OPPOSITE VALUE OF "DISPLACT" AND ICDU BITS (WHEN NECESSARY).

# DEBRIS: A,Q.



                EBANK=          DT
                BANK            21
DISPDRIV        CCS             DISPLACT                # TEST PHASE OF  EIGHTBAL .
                TCF             +5                      # (NO DRIVING ON THIS PASS.) RESET FLAG.

                CAF             OCT70000                # SET ICDU DRIVE BITS.
                EXTEND
                WOR             14

                CAF             ONE                     # RESET FLAG.
                TS              DISPLACT

                TC              Q                       # RETURN

OCT70000        OCTAL           70000                   # ICDU DRIVE BITS OF CHANNEL 14.
