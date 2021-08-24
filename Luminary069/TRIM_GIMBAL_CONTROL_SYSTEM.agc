### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    TRIM_GIMBAL_CONTROL_SYSTEM.agc
## Purpose:     The main source file for Luminary revision 069.
##              It is part of the source code for the original release
##              of the flight software for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 10. The actual flown
##              version was Luminary 69 revision 2, which included a
##              newer lunar gravity model and only affected module 2.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 1467-1478
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-13 MAS  Created from Luminary 99.
##              2016-12-18 MAS  Updated from comment-proofed Luminary 99 version.
##              2016-12-29 RRB  Updated for Luminary 69.
##              2017-01-21 HG   Fix operand BIT 12 -> BIT12
##                                          NEGSUM -> NEGUSUM
##              2017-01-23 Fix operator TC -> TCF
##		2017-01-28 RSB	Proofed comment text using octopus/prooferComments
##				and fixed errors found.
##              2021-05-30 ABS  GTSGO+DN -> GTSGO+ON
##                              MAXISHIFT -> MAXISHFT
##                              MINISHIFT -> MINISHFT

## Page 1467
                BANK    21
                EBANK=  QDIFF
                SETLOC  DAPS4
                BANK

                COUNT*  $$/DAPGT

# CONTROL REACHES THIS POINT UNDER EITHER OF THE FOLLOWING TWO CONDITIONS ONCE THE DESCENT ENGINE AND THE DIGITAL
# AUTOPILOT ARE BOTH ON:
#       A) THE TRIM GIMBAL CONTROL LAW WAS ON DURING THE PREVIOUS Q,R-AXIS TIME5 INTERRUPT (OR THE DAPIDLER
#          INITIALIZATION WAS SET FOR TRIM GIMBAL CONTROL AND THIS IS THE FIRST PASS), OR
#       B) THE Q,R-AXES RCS AUTOPILOT DETERMINED THAT THE VEHICLE WAS ENTERING (OR HAD JUST ENTERED) A COAST
#          ZONE WITH A SMALL OFFSET ANGULAR ACCELERATION.
# GTS IS THE ENTRY TO THE GIMBAL TRIM SYSTEM FOR CONTROLLING ATTITUDE ERRORS AND RATES AS WELL AS ACCELERATIONS.

GTS             CAF     NEGONE          # MAKE THE NEXT PASS THROUGH THE DAP BE
                TS      COTROLER        #       THROUGH RCS CONTROL,
                CAF     FOUR            #       AND ENSURE THAT IT IS NOT A SKIP.
                TS      SKIPU
                TS      SKIPV

                CAF     TWO
                TS      INGTS           # SET INDICATOR OF GTS CONTROL POSITIVE.
                TS      QGIMTIMR        # SET TIMERS TO 200 MSEC TO AVOID BOTH
                TS      RGIMTIMR        # RUNAWAY AND INTERFERENCE BY NULLING.

# THE DRIVE SETTING ALGORITHM
#
#       DEL = SGN(OMEGA*K + ALPHA*ABS(ALPHA)/2).
#
#       NEGUSUM = ERROR.K(2) + DEL(OMEGA.K.DEL + ALPHA(2)/2)(3/2) + ALPHA(OMEGA.K.DEL + ALPHA(2)/3)
#
#       DRIVE = -SGN(NEGUSUM)

                CA      SR              # SAVE THE SR.  SHIFT IT LEFT TO CORRECT
                AD      A               # FOR THE RIGHT SHIFT DUE TO EDITING.
                TS      SAVESR

GTSGO+ON        CAF     TWO             # SET INDEXER FOR R-AXIS CALCULATIONS.
                TS      QRCNTR
                CA      AOSR
                EXTEND
                MP      BIT3
                CA      EDOTR
                TCF     GTSQAXIS

GOQTRIMG        CAF     ZERO            # SET INDEXER FOR Q-AXIS CALCULATIONS
                TS      QRCNTR
## Page 1468
                CA      AOSQ
                EXTEND
                MP      BIT3
                CA      EDOTQ
GTSQAXIS        DXCH    WCENTRAL
                EXTEND
                INDEX   QRCNTR          # PICK UP K AND K(2) FOR THIS AXIS
                DCA     KQ
                DXCH    KCENTRAL

                INDEX   QRCNTR          # QDIFF, RDIFF ARE STORED IN D.P.
                CAE     QDIFF

ALGORTHM        EXTEND                  # Q(R)DIFF IS THETA (ERROR) SCALED AT PI.
                MP      K2CNTRAL        # FORM K(2)*THETA IN D.P.
                LXCH    K2THETA
                EXTEND                  # FORM K(2)*THETA*SF2 IN D.P.
                MP      BIT9
                DXCH    K2THETA
                EXTEND
                MP      BIT9
                ADS     K2THETA +1

                CAE     WCENTRAL        # GET OMEGA
                EXTEND
                MP      KCENTRAL        # FORM K*OMEGA IN D.P.
                LXCH    OMEGA.K
                EXTEND                  # FORM OMEGA*K*SF1 IN D.P.
                MP      BIT12
                DXCH    OMEGA.K
                EXTEND
                MP      BIT12
                ADS     OMEGA.K +1

                CAE     ACENTRAL        # FORM ALPHA(2)/2 IN D.P.
                EXTEND
                SQUARE
                DXCH    A2CNTRAL

                CAE     ACENTRAL        # GET ALPHA*ABS(ALPHA)/2, IF ALPHA GREATER
                                        # THAN 0. OTHERWISE TAKE NEGATIVE OF ABOVE
                EXTEND
                BZMF    +4
                EXTEND
                DCA     A2CNTRAL
                TCF     +3
                EXTEND
                DCS     A2CNTRAL
                DXCH    FUNCTION        # SAVE AS SGN(ALPHA)*ALPHA(2)/2
## Page 1469
                EXTEND
                DCA     OMEGA.K
                DAS     FUNCTION        # FORM FUNCT1

                CCS     FUNCTION        # DEL = +1 FOR FUNCT1 GREATER THAN ZERO.
                TCF     POSFNCT1        # OTHERWISE DEL = -1
                TCF     +2
                TCF     NEGFNCT1

                CCS     FUNCTION +1     # USE LOW ORDER WORD SINCE HIGH IS ZERO
POSFNCT1        CAF     BIT1
                TCF     +2
NEGFNCT1        CS      BIT1
                TS      DEL

                CCS     DEL             # MAKE OMEGA*K REALLY DEL*OMEGA*K
                TCF     FUNCT2          # (NOTHING NEED BE DONE)
                TCF     FUNCT2
                EXTEND
                DCS     OMEGA.K
                DXCH    OMEGA.K         # CHANGE SIGN OF OMEGA*K

FUNCT2          EXTEND
                DCA     OMEGA.K
                DXCH    FUNCTION        # DEL*OMEGA*K
                EXTEND
                DCA     A2CNTRAL
                DAS     FUNCTION        # DEL*OMEGA*K + ALPHA(2)/2
FUNCT3          CAE     A2CNTRAL        # CALCULATE (2/3)*ALPHA(2)/2 = ALPHA(2)/3
                EXTEND
                MP      .66667
                DXCH    A2CNTRAL
                XCH     L
                EXTEND
                MP      .66667
                ADS     A2CNTRAL +1
                TS      L
                TCF      +2
                ADS     A2CNTRAL
                DXCH    OMEGA.K		# DEL*OMEGA*K + ALPHA(2)/3 = G
                DAS     A2CNTRAL
                CAE     A2CNTRAL        # G*ALPHA IN D.P.
                EXTEND
                MP      ACENTRAL
                DXCH    A2CNTRAL
                XCH     L
                EXTEND
                MP      ACENTRAL
                ADS     A2CNTRAL +1
                TS      L
## Page 1470
                TCF     +2
                ADS     A2CNTRAL

                DXCH    A2CNTRAL        # FIRST AND THIRD TERMS
                DAS     K2THETA         # SUMMED IN D.P.

                TCF     RSTOFGTS

.66667          DEC     .66667

                BANK    16
                EBANK=  NEGUQ
                SETLOC  DAPS1
                BANK

# THE WRCHN12 SUBROUTINE SETS BITS 9,10,11,12 OF CHANNEL 12 ON THE BASIS OF THE CONTENTS OF NEGUQ,NEGUR WHICH ARE
# THE NEGATIVES OF THE DESIRED ACCELERATION CHANGES.  ACDT+C12 SETS Q(R)ACCDOT TO REFLECT THE NEW DRIVES.
#
# WARNING:  ACDT+C12 AND WRCHN12 MUST BE CALLED WITH INTERRUPT INHIBITED.

BGIM            OCTAL   07400
CHNL12          EQUALS  ITEMP6
ACDT+C12        CS      NEGUQ
                EXTEND                  # GIMBAL DRIVE REQUESTS.
                MP      ACCDOTQ
                LXCH    QACCDOT
                CS      NEGUR
                EXTEND
                MP      ACCDOTR
                LXCH    RACCDOT

                CCS     NEGUQ
                CAF     BIT10
                TCF     +2
                CAF     BIT9
                TS      CHNL12

                CCS     NEGUR
                CAF     BIT12
                TCF     +2
                CAF     BIT11
                ADS     CHNL12          # (STORED RESULT NOT USED AT PRESENT)

                CS      BGIM
                EXTEND
                RAND    CHAN12
                AD      CHNL12
                EXTEND
                WRITE   CHAN12
## Page 1471
                CS      CALLGMBL        # TURN OFF REQUEST FOR ACDT+C12 EXECUTION.
                MASK    RCSFLAGS
                TS      RCSFLAGS

                TC      Q               # RETURN TO CALLER.

                BANK    21
                EBANK=  QDIFF
                SETLOC  DAPS4
                BANK

## Page 1472
# SUBROUTINE TIMEGMBL:  MOD 0, OCTOBER 1967, CRAIG WORK
#
# TIMEGMBL COMPUTES THE DRIVE TIME NEEDED FOR THE TRIM GIMBAL TO POSITION THE DESCENT ENGINE NOZZLE SO AS TO NULL
# THE OFFSET ANGULAR ACCELERATION ABOUT THE Q (OR R) AXIS.  INSTEAD OF USING AOSQ(R), TIMEGMBL USES .4*AOSQ(R),
# SCALED AT PI/8.                         FOR EACH AXIS, THE DRIVE TIME IS COMPUTED AS ABS(ALPHA/ACCDOT).  A ZERO
# ALPHA OR ACCDOT OR A ZERO QUOTIENT TURNS OFF THE GIMBAL DRIVE IMMEDIATELY.  OTHERWISE, THE GIMBAL IS TURNED ON
# DRIVING IN THE CORRECT DIRECTION. THE Q(R)GIMTIMR IS SET TO TERMINATE THE DRIVE AND Q(R)ACCDOT
# IS STORED TO REFLECT THE NEW ACCELERATION DERIVATIVE.  NEGUQ(R) WILL CONTAIN +1,+0,-1 FOR A Q(R)ACCDOT VALUE
# WHICH IS NEGATIVE, ZERO, OR POSITIVE.
#
# INPUTS:       AOSQ,AOSR, SCALED AT P1/2, AND ACCDOTQ, ACCDOTR AT PI/2(7).     PI/2(7).
#
# OUTPUTS:      NEW GIMBAL DRIVE BITS IN CHANNEL 12,NEGUQ,NEGUR,QACCDOT AND RACCDOT, THE LAST SCALED AT PI/2(7).
#               Q(R)GIMTIMR WILL BE SET TO TIME AND TERMINATE GIMBAL DRIVE(S)
#
# DEBRIS:       A,L,Q, ITEMPS 2,3,6, RUPTREG2 AND ACDT+C12 DEBRIS.
#
# EXITS:        VIA TC Q.
#
# ALARMS, ABORTS, :  NONE
#
# SUBROUTINES:  ACDT+C12, IBNKCALL
#
# WARNING:      THIS SUBROUTINE WRITES INTO CHANNEL 12 AND USES THE ITEMPS.  THEREFORE IT MAY ONLY BE CALLED WITH
# INTERRUPT INHIBITED.
#
# ERASABLE STORAGE CONFIGURATION (NEEDED BY THE INDEXING METHODS):
#       NEGUQ           ERASE   +2              NEGATIVE OF Q-AXIS GIMBAL DRIVE
#       (SPWORD)        EQUALS  NEGUQ +1        ANY S.P. ERASABLE NUMBER, NOW THRSTCMD
#       NEGUR           EQUALS  NEGUQ +2        NEGATIVE OF R-AXIS GIMBAL DRIVE
#
#       ACCDOTQ         ERASE   +2              Q-JERK TERM SCALED AT PI/2(7) RAD/SEC(3)
#       (SPWORD)        EQUALS  ACCDOTQ +1      ANY S.P. ERASABLE NUMBER NOW QACCDOT
#       ACCDOTR         EQUALS  ACCDOTQ +2      R-JERK TERM SCALED AT PI/2(7) RAD/SEC(3)
#                                               ACCDOTQ, ACCDOTR ARE MAGNITUDES.
#       AOSQ            ERASE   +4              Q-AXIS ACC., D.P. AT PI/2 R/SEC(2)
#       AOSR            EQUALS  AOSQ +2         R-AXIS ACCELERATION SCALED AT PI/2 R/S2

QRNDXER         EQUALS  ITEMP6
OCT23146        OCTAL   23146                   # DECIMAL .6
NZACCDOT        EQUALS  ITEMP3

TIMEGMBL        CAF     ONE                     # INITIALIZE ALLOWGTS.
                TS      ALLOWGTS

                CAF     TWO                     # SET UP LOOP FOR R AXIS.
                LXCH    Q                       # SAVE RETURN ADDRESS.
                LXCH    RUPTREG2
## Page 1473
                TCF     +2
TIMQGMBL        CAF     ZERO                    # NOW DO THE Q-AXIS
                TS      QRNDXER
                INDEX   QRNDXER
                CA      ACCDOTQ                 # ACCDOT IS PRESUMED TO BE AT PI/2(7).
                EXTEND
                BZMF    TGOFFNOW                # IS ACCDOT LESS THAN OR EQUAL TO 0?
                TS      NZACCDOT                # NO.  STORE NON-ZERO, POSITIVE ACCDOT.

ALPHATRY        INDEX   QRNDXER
                CS      AOSQ
                EXTEND
                BZF     TGOFFNOW                # IS ALPHA ZERO?

                TS      Q                       # SAVE A COPY OF -AOS.
                EXTEND                          # NO.  RESCALE FOR TIMEGMBL USE.
                MP      OCT23146                # OCTAL 23146 IS DECIMAL .6
                AD      Q                       # -1.6*AOS AT PI/2 = -.4*AOS AT PI/8.
                TS      L                       # WAS THERE OVERFLOW?
                TCF     SETNEGU                 # NO.  COMPUTE DRIVE TIME.

                CS      A                       # RECOVER  -SGN(AOS) IN THE A REGISTER.
                INDEX   QRNDXER                 # YES.  START DRIVE WITHOUT WAITLIST.
                XCH     NEGUQ
                TCF     NOTALLOW                # KNOCK DOWN THE ALLOWGTS FLAG.

SETNEGU         EXTEND
                BZMF    POSALPH

                COM
                TS      ITEMP2                  # STORE -ABS(.4*AOS) SCALED AT PI/8.
                CS      BIT1
                TCF     POSALPH +2
POSALPH         TS      ITEMP2                  # STORE -ABS(.4*AOS) SCALED AT PI/8.
                CA      BIT1
 +2             INDEX   QRNDXER                 # SGN(AOS) INTO NEGU
                TS      NEGUQ                   # STORE SGN(APLHA) AS NEGU

                CA      NZACCDOT
                EXTEND
                MP      BIT12                   # 2*ACCDOT, SCALED AT PI/8.
                AD      ITEMP2                  # -ABS(ALPHA) + 2*ACCDOT, AT PI/8.
                EXTEND
                BZMF    NOTALLOW                # IS DRIVE TIME MORE THAN TWO SECONDS?
                CS      ITEMP2                  # NO.  COMPUTE DRIVE TIME.
                EXTEND                          # ABS(ALPHA) AT PI/8.
                MP      OCT00240                # DECIMAL 10/1024
                EXTEND                          # QUOTIENT IS DRIVE TIME AT WAITLIST.
                DV      NZACCDOT                # ABS(ALPHA)/ACCDOT AT 2(14)/100
## Page 1474
                EXTEND
                BZF     TGOFFNOW                # DRIVE TIME MUST BE GREATER THAN ZERO.

                TCF     DRIVEON

TGOFFNOW        CAF     ZERO                    # TURN OFF GIMBAL NOW.
                INDEX   QRNDXER
                TS      NEGUQ

                TCF     DONEYET

NOTALLOW        CAF     OCT31
                INDEX   QRNDXER
                TS      QGIMTIMR
                CAF     ZERO                    # DRIVE TIME IS MORE THAN 2 SECONDS, SO
                TS      ALLOWGTS                # DO NOT PERMIT FURTHER GTS ATTITUDE-RATE
                                                # CONTROL UNTIL AOSTASK APPROVES.
                TCF     DONEYET                 # NO WAITLIST CALL IS MADE.

DRIVEON         INDEX   QRNDXER
                TS      QGIMTIMR                # CHOOSE Q OR R AXIS.

DONEYET         CCS     QRNDXER
                TCF     TIMQGMBL

                DXCH    RUPTREG3                # PROTECT IBNKCALL ERASABLES.  ACDT+C12
                DXCH    ITEMP2                  # LEAVES ITEMPS2,3 ALONE.

                TC      IBNKCALL                # TURN OF CHANNEL BITS, SET Q(R)ACCDOTS.
                CADR    ACDT+C12

                DXCH    ITEMP2                  # RESTORE ERASABLES FOR IBNKCALL.
                DXCH    RUPTREG3

                TC      RUPTREG2                # RETURN TO CALLER.

OCT00240        OCTAL   00240                   # DECIMAL 10/1024

## Page 1475
# THE FOLLOWING SECTION IS A CONTINUATION OF THE TRIM GIMBAL CONTROL FROM THE LAST GTS ENTRY.  THE QUANTITY NEGUSUM
# IS COMPUTED FOR EACH AXIS (Q,R), .707*DEL*FUNCTION(3/2) + K2THETA = NEGUSUM.  NEW DRIVES ARE ENTERED TO CH 12.

RSTOFGTS        CCS     FUNCTION
                TCF     GOODARG         # FUNCTION IS POSITIVE.  GET 3/2 POWER.
                TCF     +2              # HIGH ORDER WORD IS ZERO.  TRY THE LOWER.
                TCF     ZEROOT          # NEGATIVE.  USE ZERO FOR 3/2 POWER.

                CS      FUNCTION +1     # IF ARG IS LESS THAN 2(-18), THEN THE 3/2
                AD      BIT11           # POWER IS LESS THAN 2(-27).  USE ZERO.
                EXTEND
                BZMF    ZEROHIGH        # BRANCH IF ARG NOT LESS THAN 2(-18).

ZEROOT          EXTEND
                DCA     ZERO
                TCF     NEGUSUM

ZEROHIGH        CA      FOURTEEN        # ARG LESS THAN 2(-14) MEANS 3/2 POWER
                                        # WILL BE LESS THAN 2(-21).
                TS      SHFTFLAG

                CA      TWO
                TS      ININDEX         # INITIALIZE THE SHIFT LOOP.
                
                			# COLLECT THE 14 MOST SIGNIFICANT BITS OF
                XCH     FUNCTION +1	# THE 28 INTO THE HIGH ORDER WORD.
                XCH     FUNCTION
                TCF     SCALLOOP
GOODARG         CA      TWELVE
                TS      ININDEX         # INITIALIZE THE SHIFT LOOP.
                CA      ZERO            # THERE ARE SIGNIFICANT BITS IN THE HIGH
                TS      SHFTFLAG        # ORDER WORD, SO SET SHFTFLAG TO ZERO.

                TCF     SCALLOOP

SCALSTRT        CA      FUNCTION
                TCF     SCALDONE

MULBUSH         CA      NEG2            # IF ARG IS NOT LESS THAN 1/4, INDEX IS
                ADS     ININDEX         # ZERO, INDICATING NO SHIFT NEEDED.
                EXTEND                  # BRANCH IF ARG IS NOT LESS THAN 1/4.
                BZMF    SCALSTRT        # OTHERWISE COMPARE ARG WITH A REFERENCE
                                        # WHICH IS 4 TIMES LARGER THAN THE LAST.
SCALLOOP        CS      FUNCTION
                INDEX   ININDEX
                AD      BIT15           # REFERENCE MAGNITUDE LESS OR EQUAL TO 1/4
                EXTEND
                BZMF    MULBUSH         # IF ARG IS NOT LESS THAN REFERENCE, GO
                                        # AROUND THE MULBERRY BUSH ONCE MORE.
                INDEX   ININDEX
## Page 1476
                CA      BIT15           # THIS IS THE SCALE MAGNITUDE
                XCH     Q               # 2**(-ININDEX) IS THE SHIFT DIVISOR.
                EXTEND                  # RESCALE ARGUMENT.
                DCA     FUNCTION
                EXTEND
                DV      Q
                TS      FUNCTION        # ININDEX AND SHFTFLAG PRESERVE INFO FOR
                                        # RESCALING AFTER ROOT PROCESS.
SCALDONE        EXTEND                  # AFTER 3/2 POWER IS TAKEN, SCALE FACTOR
                MP      BIT13           # OF SQRT(1/2) WILL BE NEEDED, SO FACTOR
                TS      HALFARG         # OF 1/2 IS INCLUDED NOW, BEFORE SQRT.

                CA      STARTER         # INITIAL GUESS FOR SQRT ALGORITHM.
                TC      ROOTCYCL
                TC      ROOTCYCL
                TC      ROOTCYCL

                EXTEND                  # SQRT(1/2)*SQRT(ARG) IN A.
                MP      FUNCTION        # SQRT(1/2)*ARG*SQRT(ARG) IN A,L.
                DXCH    FUNCTION

DOSHIFT         CA      SHFTFLAG        # HOW MANY SHIFT BITS ARE THERE?
                AD      ININDEX         # 2**(-ININDEX) WAS SHIFT DIVISOR.
                TS      SR
                AD      SR		# THIS MANY SHIFTS ARE REQUIRED.
SAVESHFT        TS      Q               # Q BOUNDS ARE ZERO AND 24 (DECIMAL).
                EXTEND
                BZMF    SUMNEGU         # BRANCH IF SHIFTING IS UNNECESSARY.

                CS      FOURTEEN
                AD      Q
                EXTEND                  # Q = 0(MOD 3), SO A REG IS NON-ZERO.
                BZMF    MINISHFT        # BRANCH IF SMALL SHIFT SUFFICES.

MAXISHFT        TS      Q               # 14 BIT SHIFT RIGHT NOW.
                CA      ZERO
                XCH     FUNCTION
                TS      FUNCTION +1

MINISHFT        INDEX   Q               # C(Q) ARE GREATER THAN ZERO.
                CA      BIT15
                TS      Q               # 2**(-Q) WILL BE SHIFT MULTIPLIER.
                EXTEND
                MP      FUNCTION +1
                XCH     L
                CA      ZERO
                DXCH    FUNCTION        # LOWER WORD SHIFTED NOW.
                EXTEND
                BZMF    SUMNEGU         # BRANCH IF UPPER WORD WAS ZERO.
## Page 1477
                EXTEND                  # SHIFT UPPER WORD.
                MP      Q
                DAS     FUNCTION        # NO OVERFLOW POSSIBLE.

SUMNEGU         CS      DEL             # INCLUDE DEL FACTOR IN PRODUCT TERM.
                EXTEND
                BZMF    SUMTERMS

                EXTEND                  # DEL FACTOR IS MINUS ONE.
                DCS     FUNCTION
                TCF     NEGUSUM  -1     # NOW ADD IN THE K2THETA TERM.

SUMTERMS        EXTEND
                BZF     NEGUSUM         # BRANCH IF DEL IS ZERO.

                EXTEND                  # DEL FACTOR IS +1.
                DCA     FUNCTION
                DAS     K2THETA         # NOW ADD IN THE K2THETA TERM.
NEGUSUM         CCS     K2THETA         # TEST SIGN OF HIGH ORDER PART.
                TCF     NEGDRIVE
                TCF     +2
                TCF     POSDRIVE

                CCS     K2THETA +1      # SIGN TEST FOR LOW ORDER PART.
NEGDRIVE        CA      BIT1
                TCF     +2              # STOP GIMBAL DRIVE FOR A ZERO NEGUSUM.
POSDRIVE        CS      BIT1
                TS      L               # SAVE FOR DRIVE REVERSAL TEST.
                INDEX   QRCNTR
                XCH     NEGUQ

                EXTEND
                MP      L               # MULTIPLY OLD NEGU AND NEW NEGU.
                CCS     L
                TCF     LOUPE           # NON-ZERO GIMBAL DRIVE BEING CONTINUED.

                TCF     ZEROLOUP        # NO REVERSAL PROBLEM HERE.

                TCF     REVERSAL        # NON-ZERO GIMBAL DRIVE BEING REVERSED.
                TCF     ZEROLOUP        # NO REVERSAL PROBLEM HERE.

REVERSAL        INDEX   QRCNTR          # A ZERO-DRIVE PAUSE IS NEEDED HERE.  ZERO
                TS      QACCDOT         # IS IN A REGISTER FROM CCS ON (-1).
                INDEX   QRCNTR
                CS      GMBLBITA
                EXTEND
                WAND    CHAN12

ZEROLOUP        CS      RCSFLAGS        # SET UP REQUEST FOR ACDT+C12 CALL.
                MASK    CALLGMBL
## Page 1478
                ADS     RCSFLAGS

LOUPE           CCS     QRCNTR          # HAVE BOTH AXES BEEN PROCESSED?
                TCF     GOQTRIMG        # NO.  DO Q AXIS NEXT.

                CA      SAVESR          # RESTORE THE SR
                TS      SR

GOCLOSE         EXTEND                  # TERMINATE THE JASK.
                DCA     CLOSEADR
                DTCB

                EBANK=  AOSQ
CLOSEADR        2CADR   CLOSEOUT        # TERMINATE THE JASK.

TWELVE          EQUALS  OCT14
GMBLBITA        OCTAL   01400           # INDEXED WRT GMBLBITB   DO NOT MOVE ******
STARTER         DEC     .53033          # INITIAL VALUE FOR SQRT ALGORITHM.
GMBLBITB        OCTAL   06000           # INDEXED WRT GMBLBITA   DO NOT MOVE ******

# SUBROUTINE ROOTCYCL:  BY CRAIG WORK,3 APRIL 68
#
# ROOTCYCL IS A SUBROUTINE WHICH EXECUTES ONE NEWTON SQUARE ROOT ALGORITHM ITERATION.  THE INITIAL GUESS AT THE
# SQUARE ROOT IS PRESUMED TO BE IN THE A REGISTER AND ONE-HALF THE SQUARE IS TAKEN FROM HALFARG.  THE NEW APPROXI-
# MATION TO THE SQUARE ROOT IS RETURNED IN THE A REGISTER.  DEBRIS:  A,L,SR,SCRATCH.   ROOTCYCL IS CALLED FROM
# LOCATION (LOC) BY A TC ROOTCYCL, AND RETURNS (TC Q) TO LOC +1.
#
# WARNING:  IF THE INITIAL GUESS IS NOT GREATER THAN THE SQUARE, DIVIDE OR ADD OVERFLOW IS A REAL POSSIBILITY.

ROOTCYCL        TS      SCRATCH         # STORE X
                TS      SR              # X/2 NOW IN SR
                CA      HALFARG         # ARG/2 IN THE A REG
                ZL                      # PREPARE FOR DIVISION
                EXTEND
                DV      SCRATCH         # (ARG/X)/2
                AD      SR              # (X + ARG/X)/2 IN THE A REG
                TC      Q


