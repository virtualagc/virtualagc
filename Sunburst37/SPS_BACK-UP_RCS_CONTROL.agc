### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SPS_BACK-UP_RCS_CONTROL.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-09-30 MAS  Transcribed.
##		2016-10-31 RSB	Typos.
##		2016-12-06 RSB	Comment-proofing with octopus/ProoferComments.

## Page 629
                BANK            21
                EBANK=          DT

SPSRCS          CS              OMEGAQD
                AD              OMEGAQ
                TS              EDOTQ                           #  EDOT = OMEGAQ - OMEGAQD

                AD              ER
                EXTEND                                          # F = 1/4 E + EDOT
                BZMF            PLUSD                           # DQ NEGATIVE FOR POSITIVE F

                CAF             NEGD                            # STORE DIRECTION TO THRUST IN ITEMP3

GCOMPUTE        TS              ITEMP3
                CAE             EDOTQ
                EXTEND
                MP              ACONST                          # ACONST = 2**(-11) X SQRT(1/2A X PI/1024)
                CCS             A
                TCF             LIMSQQ
                TCF             +2
                TCF             LIMSQQ
                LXCH            A                               # A = 2**(3) X SQRT(1/2A X PI/1024)
LIMRETQ         EXTEND
                SQUARE
                TS              ITEMP2                          # ITEMP2 = (1/2A) EDOT**2

                AD              ER
                AD              NEGD                            # DB IS SPECIFIED BY NEGD IN SPS MODE

                EXTEND
                BZMF            UZERO

                CAE             EDOTQ                           # G WAS POSITIVE, NOW TEST EDOT

                EXTEND
                BZMF            ULOW

                AD              ITEMP2                          # EDOT WAS POSITIVE, CALCULATE HIGH U CASE
                AD              ER
                TS              URGENCYQ

                TCF             RCALC

LIMSQQ          CAF             POSMAX
                TCF             LIMRETQ
LIMSQR          CAF             POSMAX
                TCF             LIMRETR
ULOW            AD              ER                              # EDOT WAS NEGATIVE, CALCULATE LOW U CASE
                TS              URGENCYQ
## Page 630
                TCF             RCALC

PLUSD           CS              ER
                XCH             ER
                CS              EDOTQ
                XCH             EDOTQ
                CS              NEGD
                TCF             GCOMPUTE

UZERO           CAF             ZERO                            # G = 0, NO URGENCY
                TS              URGENCYQ

RCALC           CS              OMEGARD                         # REPEAT CALCULATIONS FOR R-AXIS
                AD              OMEGAR
                TS              EDOTR

                AD              E                               # F = 1/4 E + EDOT
                EXTEND
                BZMF            PLUSDR

                CAF             NEGD

GCOMPUTR        TS              ITEMP4
                CAE             EDOTR
                EXTEND
                MP              ACONST                          # ACONST = 2**(-11) X SQRT(1/2A X PI/1024)
                CCS             A
                TCF             LIMSQR
                TCF             +2
                TCF             LIMSQR
                LXCH            A                               # A = 2**(3) X SQRT(1/2A X PI/1024)
LIMRETR         EXTEND
                SQUARE
                TS              ITEMP2

                AD              E
                AD              NEGD

                EXTEND
                BZMF            UZEROR

                CAE             EDOTR

                EXTEND
                BZMF            ULOWR

                AD              ITEMP2                          # EDOT WAS POSITIVE, CALCULATE HIGH U CASE
                AD              E
                TS              URGENCYR
## Page 631
                TCF             URGRECT
ULOWR           AD              E                               # EDOT WAS NEGATIVE, CALCULATE LOW U CASE
                TS              URGENCYR

                TCF             URGRECT
PLUSDR          CS              E
                XCH             E
                CS              EDOTR
                XCH             EDOTR
                CS              NEGD
                TCF             GCOMPUTR

UZEROR          CAF             ZERO
                TS              URGENCYR

URGRECT         CCS             ITEMP4                          # DR = ITEMP4, NON-ZERO
                CS              URGENCYR                        # DR POS = POSR JETS = URGENCY NEG
                TS              URGENCYR                        # URGENCYR NEGATIVE

                CCS             ITEMP3                          # DQ = ITEMP3, NON-ZERO
                CS              URGENCYQ                        # DQ POS = POSR JETS = NEGATIVE URGENCY
                TS              URGENCYQ

                CAF             RESADR                          # RESADR = JETSON AFTER POLICY LOCATION
                TS              TJETADR

                CAF             NEG1/2                          # SET URGLIMIT = NEGMAX FOR ONLY
                TS              URGLIMIT                        #          2 JET RESPONSE
                TS              NJ-U                            # SET JETS FOR NO OFFSET CORRECTION
                TS              NJ+U
                TS              NJ-V
                TS              NJ+V

                EXTEND
                DCA             URGAXADR
                DTCB

                EBANK=          OMEGAQ
URGAXADR        2CADR           URGPLANE

ACONST          OCTAL           00016
NEGD            DEC             -0.0111
RESADR          REMADR          JETSON                          # JETSON IS IN Q,R TJETLAW

## Page 632
# THE TRYGTS CODING IS AN EXTENSION OF THE Q,R-AXES REACTION CONTROL SYSTEM AUTOPILOT.  TRYGTS CALLS UPON THE GTS
# CODING WHENEVER Q,R-AXIS CONTROL FINDS ITSELF ENTERING A COAST REGION WITH JETS OFF.

                EBANK=          DT
TRYGTS          CAF             USEQRJTS                        # IS JET USE MANDATORY.
                MASK            DAPBOOLS
                CCS             A
                TCF             RESUME                          # YES.  RESUME.

                EXTEND                                          # NO.  CALL IN GTS, IF POSSIBLE.
                READ            12
                MASK            BGIM21                          # ARE GIMBALS STILL DRIVING.
                CCS             A
                TCF             RESUME                          # GIMBALS STILL DRIVING.  TRY AGAIN LATER.

GOTOGTS         CS              THREE                           # GIMBALS STOPPED.  RESET TIME5 COUNTER
                ADS             TIME5                           # FROM 20 MS TO 50 MS.
                EXTEND                                          # NEXT T5RUPT IN 50 MS IS PAXIS.
                DCA             PAX/FILT
                DXCH            T5ADR

INSRT21A        TCF             TESTCNTR                        # DETERMINE WHAT TO PUT IN PASSCTR.
LOADCNTR        TS              PASSCTR                         # NMBR PASSES REQUIRED TO WARM UP FILTER
                EXTEND
                DCA             RATEINAD                        # NEXT T5RUPT AFTER NEXT PAXIS IS RATEINIT
                DXCH            PFILTADR                        # CONTROL FLOW SWITCH CELL FOR PAXIS RUPT.
                TCF             RESUME

BGIM21          OCT             07400                           # TRIM GIMBAL BITS IN CHANNEL 12 ARE 9-12.
                EBANK=          DT
RATEINAD        2CADR           RATEINIT                        # RATE INITIALIZATION FOR KALMAN FILTER.

## Page 633
RATEINIT        CAF             FILTMS50                        # RESET TIMER IMMEDIATELY  DT = 50 MS.
                TS              TIME5

                LXCH            BANKRUPT                        # INTERRUPT LEAD-IN (CONTINUED)
                EXTEND
                QXCH            QRUPT

                EXTEND                                          # FILTINIT WILL BE NEXT T5RUPT, IN 50 MS.
                DCA             FILINADR
                DXCH            T5ADR

                CA              BACKHOME                        # ESTABLISH RETURN SWITCH FROM THE PROCESS
                TS              STEERADR                        # OF READING CDUY,Z AND TIMER.  TO BE USED
                TCF             FILSTART        +1              # IN FILTINIT FOR RATE INITIALIZATION

BACKHOME        GENADR          BACKHOME        +1

                LXCH            DAPTIME                         # RETURN HERE TO STORE DATA JUST DESCRIBED
                EXTEND
                DCA             STORCDUY                        # IN 2S COMPLEMENT, SCALED AT PI
                DXCH            HOLDCDUY                        # HOLD FOR RATE DERIVATION
                TCF             RESUME

                EBANK=          DT
FILINADR        2CADR           FILTINIT

FILTMS50        OCT             37773                           # 50 MS CONSTANT FOR TIME5

HOMAGAIN        GENADR          HOMAGAIN        +1
                CA              BIT1                            # SET UP RATE CALCULATION LOOP, Z AXIS 1ST
HOMELOOP        TS              QRCNTR
                DOUBLE
                TS              KCENTRAL
                INDEX           QRCNTR
                CA              STORCDUY                        # 2S COMPLEMENT AT PI
                EXTEND
                INDEX           QRCNTR
                MSU             HOLDCDUY                        # DIFFERENCE IN 1S COMPLEMENT, AT PI
                EXTEND
                MP              BIT6                            # DIFFERENCE IN L, AT PI/2(5)
                XCH             L                               # ZERO L, PREPARE FOR DIVISION BY DT
                EXTEND
                DV              DT                              # DT IS AT 1/8, SO RATE IS AT PI/4
                INDEX           KCENTRAL
                DXCH            DCDUYFIL                        # STORE S.P. INITIAL RATE ESTIMATE
                CCS             QRCNTR                          # ARE BOTH RATES DONE YET.
                TCF             HOMELOOP                        # NO.   NOW DO Y AXIS
                CA              ORDINARY                        # YES.   SET SWITCH FOR NORMAL OPERATION
## Page 634
                TS              STEERAD2
                TCF             FILFIRST        +1
ORDINARY        GENADR          PAX/FILT        -2

CLEARCH5        CAF             ZERO                            # TURN OFF Q,R-AXES RCS JETS.
                EXTEND
                WRITE           5
                CAF             HOMAGAIN                        # SET UP TO PREVENT FILTERING DURING THE
                TS              STEERAD2                        # INITIALIZATION.
                TCF             FILSTART        +1              # T6JOBCHK NOT NEEDED.  CHANNEL 5 ZEROED.

COUNTDWN        DXCH            PFRPTLST                        # FINISH CYCLING POST RUPT LIST.

                CCS             PASSCTR                         # DECREMENT PASSCTR.
                TS              PASSCTR
                TCF             FILSTART

TIMEDONE        TS              DT                              # DT STORED.  SCALED AT 1/8.
                TC              STEERAD2                        # BYPASS FILTERING DURING INITIALIZATION.
                TCF             PAX/FILT        -2

USUALXIT        CA              GOQADR
                TS              SLECTLAW                        # SET LOOP EXIT FOR SIMPLE CONTROL OR NOT.
                TCF             GTSQAXIS

TESTPCTR        CCS             PASSCTR                         # EITHER ZERO (+) , OR POSITIVE
                TCF             SIMPCTRL                        # USE SIMPLE CONTROL - NULLIFY ALPHA.
                TCF             RCSCNTRL                        # TO TO Q,R JETS.

GOQADR          GENADR          GOQTRIMG
SIMPQADR        GENADR          SIMPQTRG

SIMPCTRL        CA              SIMPQADR                        # SET UP 2ND PASS THROUGH CONTROL LOOP.
                TS              SLECTLAW
                CAF             TWO                             # SET UP INDEX FOR 1ST PASS THROUGH SIM
                TCF             SIMPLOOP                        # PLE CONTROL LAW.  (R-AXIS)
SIMPQTRG        CAF             ZERO                            # SET INDEX FOR Q-AXIS
SIMPLOOP        TS              QRCNTR
                INDEX           QRCNTR
                CCS             ALPHAQ                          # CHOOSE DRIVE TO NULL ALPHA
                CA              BIT1
                TCF             POSDRIVE
                CS              BIT1
                TCF             POSDRIVE                        # DRIVE BITS GO TO THE CHANNEL

## Page 635
# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

# FROM GTS: WHEN TRIMCNTR ACTIVE,  DO SIMPCTRL IF THE FILTER IS NOT WARM
#           AND DO A TGOFF DRIVE IF IT IS.

CHKCNTR         CCS             SIMPCNTR                        # CHOOSE SIMPCTRL OR NORMAL GTS CONTROL.
                TCF             TESTPCTR                        # SIMPCTRL UNTIL PASSCTR IS ZERO,THEN EXIT
                TCF             NORMCTRL                        # NORMAL GTS CONTROL.
                TC              CCSHOLE
                TC              CCSHOLE

NORMCTRL        CAF             BIT1                            # RETURN TO NORMAL GTS CONTROL.
                TCF             INSERT21        +1

# FROM CHEKDRIV: ALLOW TGOFFCAL DRIVES AND DISABLE SPECIAL GTS INDICATORS

WARMFILT        TC              TGOFFCAL                        # (A= 0, INDEX FOR Q-AXIS IN TGOFFCAL)
                CAF             NEGMAX                          # RETURN HERE FOR NO Q DRIVE.
                TS              ITEMP3                          # RETURN HERE WITH TIME IN A (DECASECONDS)

                CAF             TWO                             # INDEX FOR R-AXIS.
                TC              TGOFFCAL
                CAF             NEGMAX                          # RETURN HERE FOR NO R DRIVE.
                TS              L                               # RETURN HERE WITH TIME IN A (DECASECONDS)
                CAE             ITEMP3
                DXCH            QGIMTIMR                        # SET TIMERS SIMULTANEOUSLY FOR RESTART
                                                                #   PROTECTION.
                TC              WRCHN12                         # START DRIVES

                CCS             TRIMCNTR                        # DEACTIVATE TRIMCNTR IF IT HAS REACHED -0
                TCF             +5
                TC              CCSHOLE
                TCF             +3
                CAF             NEGMAX
                TS              TRIMCNTR
 +5             CAF             ZERO                            # DEACTIVATE GTSMNITR NOW THAT TGOFFCAL
                TS              GTSMNITR                        #   HAS BEEN DONE
                TCF             TASKOVER

# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

CHKSUM21        OCT             37777
