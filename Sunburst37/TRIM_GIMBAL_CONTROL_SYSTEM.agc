### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    TRIM_GIMBAL_CONTROL_SYSTEM.agc
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
## Reference:   pp. 554-568
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-07 HG   Transcribed
##              2017-06-15 HG   Fix operand  ACENTRAL -> A2CNTRAL
##                                  operator CS -> CAE
##                                           TC -> INDEX
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 554
                BANK            21
                EBANK=          DT
# CONTROL REACHES THIS POINT UNDER EITHER OF THE FOLLOWING TWO CONDITIONS ONCE THE DESCENT ENGINE AND THE DIGITAL
# AUTOPILOT ARE BOTH ON:
#          A) THE TRIM GIMBAL CONTROL LAW WAS ON DURING THE PREVIOUS Q,R-AXIS TIME5 INTERRUPT (OR THE DAPIDLER
#             INITIALIZATION WAS SET FOR TRIM GIMBAL CONTROL AND THIS IS THE FIRST PASS), OR
#          B) THE Q,R-AXES RCS JET CONTROL LAW ATTITUDE STEERING MODE REDUCED THE ATTITUDE ERROR TO LESS THAN
# 1DEGREE ON EACH AXIS ON ITS LAST TIME5 INTERRUPT.

# THE FOLLOWING T5RUPT ENTRY BEGINS THE TRIM GIMBAL CONTROL LAW.  SINCE IT IS ASSUMED THAT THE LEM WILL REMAIN
# UNDER TRIM GIMBAL CONTROL, A KALMAN FILTER RUPT IS SET UP TO BEGIN 30 MS FROM THE TRIM GIMBAL RUPT.

GTS             CAF             MS30F                   # RESET TIMER IMMEDIATELY: DT = 30 MS
                TS              TIME5

                LXCH            BANKRUPT                # INTERRUPT LEAD IN (CONTINUED)
                EXTEND
                QXCH            QRUPT

                EXTEND
                DCA             POSTPFIL
                DXCH            T5ADR

                TCF             GTSTEST                 # SKIP OVER XFORMS UNTIL REORGANIZATION

GIMBAL          EXTEND                                  # GET D.P. FILTERED CDUY VALUE (ONES COMP)
                DCA             CDUYFIL                 # SCALED AT 2PI RADIANS
                TC              ONETOTWO                # FORM S.P. VALUE IN TWOS COMPLEMENT AT PI
                EXTEND
                MSU             CDUYD                   # FORM Y-AXIS ERROR IN ONES COMPLEMENT
                TS              QDIFF                   # (SAVE IN Q-AXIS ERROR LOC: EFFICIENCY)

                EXTEND                                  # GET D.P. FILTERED CDUZ VALUE (ONES COMP)
                DCA             CDUZFIL                 # SCALED AT 2PI RADIANS
                TC              ONETOTWO                # FORM S.P. VALUE IN TWOS COMPLEMENT AT PI
                EXTEND
                MSU             CDUZD                   # FORM Z-AXIS ERROR IN ONES COMPLEMENT
                TS              RDIFF                   # (SAVE IN R-AXIS ERROR LOC: EFFICIENCY)

# TRANSFORM Y,Z CDU ERRORS TO THE Q,R-AXES.

                EXTEND                                  # GET BOTH Y AND Z CDU ERRORS AT PI RAD
                DCA             QDIFF
                TC              QTRANSF                 # FORM Q-ERROR IN A (SCALED AT PI RAD)
                DXCH            QDIFF                   # STORE Q-ERROR, GET BOTH Y,Z CDU ERRORS
                TC              RTRANSF                 # FORM R-ERROR IN A (SCALED AT PI RAD)
                XCH             RDIFF                   # STORE R-ERROR

# TRANSFORM THE FILTERED Y,Z RATES TO THE Q,R-AXES.
# (THESE MAY BE NEEDED FOR THE RATE DERIVATION FOR THE JETS IF THEY MUST BE USED.)

## Page 555
                CAE             DCDUZFIL                # GET FILTERED Y,Z RATES
                TS              L                       # SCALED AT PI/4 RADIANS/SECOND
                CAE             DCDUYFIL
                TC              QTRANSF                 # FOR Q-AXIS RATE
                TS              OMEGAQ                  # STORED SCALED AT PI/4 RADIANS/SECOND

                CAE             DCDUZFIL                # GET FILTERED Y,Z RATES
                TS              L                       # SCALED AT PI/4 RADIANS/SECOND
                CAE             DCDUYFIL
                TC              RTRANSF                 # FOR R-AXIS RATE
                TS              OMEGAR                  # STORED SCALED AT PI/4 RADIANS/SECOND

# TRANSFORM THE FILTERED Y,Z ACCELERATIONS TO THE Q,R-AXES.
# (THESE MAY BE NEEDED TO CALCULATE TRIM GIMBAL OFF-TIMES IF ATTITUDE ERROR HAS GONE BEYOND TRIM GIMBAL CONTROL.)

                CAE             D2CDUZFL                # GET FILTERED Y,Z ACCELERATIONS
                TS              L                       # SCALED AT PI/8 RADIANS/SECOND(2)
                CAE             D2CDUYFL
                TC              QTRANSF                 # FORM Q-AXIS ACCELERATION

                TS              ALPHAQ                  # STORE AT PI/8 RADIANS/SECOND(2)

                CAE             D2CDUZFL                # GET FILTERED Y,Z ACCELERATIONS
                TS              L                       # SCALED AT PI/8 RADIANS/SECOND(2)
                CAE             D2CDUYFL
                TC              RTRANSF                 # FORM R-AXIS ACCELERATION
                TS              ALPHAR                  # STORE AT PI/8 RADIANS/SECOND(2)

# EXTRAPOLATE THETA AND OMEGA OVER THE 20 MS DELAY BETWEEN THE KALMAN FILTER AND THE TRIM GIMBAL CONTROL.

                CAE             OMEGAQ
                EXTEND
                MP              DTW
                ADS             QDIFF

                CAE             OMEGAR
                EXTEND
                MP              DTW
                ADS             RDIFF

                CAE             ALPHAQ
                EXTEND
                MP              DTA

                ADS             OMEGAQ

                CAE             ALPHAR
                EXTEND
                MP              DTA
                ADS             OMEGAR

                TCF             RESUME

## Page 556

DTW             DEC             .005
DTA             DEC             .0025

# TEST TO SEE IF TRIM GIMBAL CONTROL LAW HAS KEPT BOTH ATTITUDE ERRORS BELOW THE 1 DEGREE BOUNDARY WITH THE REGION
# OF RCS CONTROL LAW DOMINANCE OR IS STILL REDUCING THE ERROR.

GTSTEST         CAF             TRYGIMBL                # VERIFY THAT GTS IS STILL OPERATIVE.
                MASK            DAPBOOLS
                CCS             A
                TCF             RCSCNTRL                # GTS NOT OPERATIVE
                CAF             BIT1
LOOPTEST        TS              QRCNTR
                INDEX           QRCNTR
                CCS             QDIFF                   # SCALED AT PI.
                AD              -TGBND+1                # -2 DEG SCALED AT PI, + 1 BIT.
                TCF             +2
                AD              -TGBND+1
                EXTEND
                BZMF            +2                      # IS ERROR MAG LESS,EQUAL 2 DEG.
                TCF             RCSCNTRL                # NO.   GO TO JETS.
                CA              QRCNTR                  # YES.  TRY RATE MAGNITUDE.
                DOUBLE
                INDEX           A
                CCS             OMEGAQ                  # SCALED AT PI/4.
                AD              -RATBD+1                # -.65 DEC/SEC SCALED AT PI/4  + 1 BIT
                TCF             +2

                AD              -RATBD+1
                EXTEND
                BZMF            +2                      # IS RATE MAG LESS,EQUAL .65 DEG/SEC.
                TCF             RCSCNTRL                # NO.    GO TO JETS.
                CCS             QRCNTR                  # YES.  THIS AXIS IS FINE. ARE BOTH DONE.
                TCF             LOOPTEST                # TRY THE Q AXIS NOW.
                TCF             GTSRAXIS                # USE TRIM GIMBAL CONTROL.
-TGBND+1        OCT             77512                   # -2 DEG SCALED AT PI, + 1 BIT.
-RATBD+1        OCT             77423                   # -.65 DEG/SEC SCALED AT PI/4  + 1 BIT
# ATTITUDE ERROR IS BEYOND TRIM GIMBAL CONTROL LAW RANGE.  SET UP FOR RCS CONTROL LAW (Q,R-AXIS) AND CALCULATE
# TIMES TO TURN OFF THE GIMBAL DRIVES.

RCSCNTRL        CAF             POSTQRFL                # CHANGE LOCATION OF NEXT T5RUPT FROM
                TS              T5ADR                   # FILTER TO FILDUMMY

                EXTEND                                  # SET UP POST P-AXIS T5RUPT TO GO TO
                DCA             QRJPFILT                # DUMMYFIL INSTEAD OF FILTER.  USE 2CADR
                DXCH            PFILTADR                # BECAUSE DUMMYFIL NOW IN BANK 16.

                EXTEND                                  # PREPARE FOR SEQUENCED RESUMPTION OF
                DCA             CDUY                    # Q,R-AXIS RCS CONTROL RATE DERIVATION
                DXCH            OLDYFORQ                # BY PROVIDING OLD CDU READINGS

                EXTEND                                  # MOVE FILTERED AND TRANSFORMED ATTITUDE

## Page 557
                DCA             QDIFF                   # ERRORS INTO ERASABLE FOR Q,R-AXIS RCS
                XCH             RERROR                  # CONTROL; NOTE THAT THE AXES SEEM TO BE
                LXCH            QERROR                  # INTERCHANGED BUT ARE NOT CONFUSED

                CAF             ONE
                TC              WAITLIST
                EBANK=          DT
                2CADR           CHEKDRIV                # DO TGOFF CALCULATION IN WAITLIST TASK

                EXTEND                                  # GO TO Q,R-AXES CONTROL IMMEDIATELY
                DCA             TGENTRY
                DTCB

POSTQRFL        GENADR          FILDUMMY
                EBANK=          AOSQTERM
QRJPFILT        2CADR           DUMMYFIL                # NECESSARY BECAUSE DUMMYFIL IN BANK 16.

                EBANK=          DT
TGENTRY         2CADR           STILLRCS


CHEKDRIV        CAF             ZERO                    # CALCULATE Q-AXIS GIMBAL DRIVE SHUTDOWN T
                TC              TGOFFCAL
                TC              WAITLIST
                EBANK=          DT
                2CADR           OFFGIMQ

                CAF             TWO                     # CALCULATE R-AXIS GIMBAL DRIVE SHUTDOWN T
                TC              TGOFFCAL
                TC              WAITLIST

                EBANK=          DT
                2CADR           OFFGIMR

                TC              WRCHN12                 # SET UP NEW DRIVES AS OF NOW

                TCF             TASKOVER

## Page 558

# THE DRIVE SETTING ALGORITHM
# DEL = SGN(OMEGA.K + SGN(ALPHA)ALPHA(2)/2)    ONLY +1/-1

# NEGUSUM = ERROR.K(2) + DEL((OMEGA.K.DEL + ALPHA(2)/2)(3/2) + (OMEGA.K.DEL + ALPHA(2)/3)ALPHA

# DRIVE = -SGN(NEGUSUM)

-.04266         DEC             -.04266
GTSRAXIS        CAF             TWO                     # SET INDEXER FOR R-AXIS CALCULATIONS
                TS              QRCNTR
                TCF             GTSQAXIS

GOQTRIMG        CAF             ZERO                    # SET INDEXER FOR Q-AXIS CALCULATIONS
                TS              QRCNTR

GTSQAXIS        EXTEND
                INDEX           QRCNTR                  # PICK UP K AND K(2) FOR THIS AXIS
                DCA             KQ
                DXCH            KCENTRAL

                EXTEND
                INDEX           QRCNTR                  # PICK UP OMEGA AND ALPHA FOR THIS AXIS
                DCA             OMEGAQ
                DXCH            WCENTRAL

                CAE             QRCNTR
                EXTEND
                BZF             +3
                CAE             RDIFF
                TCF             +2
                CAE             QDIFF

                EXTEND                                  # RESCALE DIFFERENCE BY MULTIPLYING BY
                MP              BIT7                    # 2(6)
                LXCH            ETHETA

                CAE             KCENTRAL                # TEST ON MAGNITUDE OF ACCDOT
                AD              -.04266

                EXTEND
                BZMF            ACCDOTSM                # BRANCH IF ACCDOT IS SMALL

ACCDOTLG        CAF             BIT14                   # ACCDOT IS COMPARITIVELY LARGE
                TS              SF1                     # SET UP SCALE FACTORS
                CAF             BIT12
WSFTEST         TS              SF2

                CCS             WCENTRAL                # TEST ON MAGNITUDE OF OMEGA
                AD              -.04438
                TCF             +2
                AD              -.04438

## Page 559
                EXTEND
                BZMF            ASFTEST                 # IF SMALL, GO TO ALPHA TEST

                TCF             WLARGE

ACCDOTSM        CAE             KCENTRAL                # RESCALE IF ACCDOT IS SMALL
                EXTEND
                MP              BIT5                    # RESCALE K BY MULTIPLYING BY 2(4)
                LXCH            KCENTRAL
                CAE             KCENTRAL
                EXTEND
                SQUARE
                TS              K2CNTRAL
                CAF             BIT10                   # SET UP VARIABLE SCALE FACTORS
                TS              SF1
                CAF             BIT4
                TCF             WSFTEST                 # GO TEST ON MAGNITUDE OF OMEGA

ASFTEST         CCS             ACENTRAL                # TEST ON MAGNITUDE OF ALPHA

                AD              -.08882
                TCF             +2
                AD              -.08882
                EXTEND
                BZMF            WARESCAL                # IF SMALL, GO TO W,A RESCALING
                TCF             WLARGE                  # IF LARGE, DO SAME AS IF W LARGE

-.04438         DEC             -.04438
-.08882         DEC             -.08882

WARESCAL        CAE             WCENTRAL                # RESCALE OMEGA BY MULTIPLYING BY 2(4)
                EXTEND
                MP              BIT5
                LXCH            WCENTRAL

                CAE             ACENTRAL                # RESCALE ALPHA BY MULTIPLYING BY 2(3)
                EXTEND
                MP              BIT4
                LXCH            ACENTRAL

                TCF             ALGORTHM

WLARGE          CAE             SF1                     # RESCALE VARIABLE SCALE FACTORS

                EXTEND
                MP              BIT13                   # SF1 = SF1*2(-2)
                TS              SF1
                CAE             SF2
                EXTEND
                MP              BIT6                    # SF2 = SF2*2(-9)
                TS              SF2

## Page 560
ALGORTHM        CAE             ETHETA                  # GET RESCALED ERROR THETA
                EXTEND

                MP              K2CNTRAL                # FORM K(2)*THETA IN D.P.
                LXCH            K2THETA
                EXTEND                                  # FORM K(2)*THETA*SF2 IN D.P.
                MP              SF2
                DXCH            K2THETA
                EXTEND
                MP              SF2
                ADS             K2THETA         +1

                CA              WCENTRAL                # GET OMEGA
                EXTEND
                MP              KCENTRAL                # FORM K*OMEGA IN D.P.
                LXCH            OMEGA.K
                EXTEND                                  # FORM OMEGA*K*SF1 IN D.P.
                MP              SF1
                DXCH            OMEGA.K
                EXTEND
                MP              SF1
                ADS             OMEGA.K         +1

                CA              ACENTRAL                # FORM ALPHA(2) IN D.P.
                EXTEND
                SQUARE

                DXCH            A2CNTRAL

                CAE             ACENTRAL                # GET SGN(ALPHA)
                EXTEND
                BZMF            +4
                EXTEND
                DCA             A2CNTRAL
                TCF             +3
                EXTEND
                DCS             A2CNTRAL
                DXCH            FUNCTION                # SAVE AS SGN(ALPHA)ALPHA(2)
                EXTEND
                DCA             OMEGA.K
                DAS             FUNCTION                # FORM FUNCT1

                CCS             FUNCTION                # DEL = SGN(FUNCT1)
                TCF             POSFNCT1
                TCF             +2
                TCF             NEGFNCT1

                CCS             FUNCTION        +1      # USE LOW ORDER WORD SINCE HIGH IS ZERO
POSFNCT1        CAF             TWO
                TCF             +2

NEGFNCT1        CAF             ZERO
                AD              NEG1

## Page 561
                TS              DEL

                CCS             DEL                     # MAKE OMEGA*K REALLY DEL*OMEGA*K
                TCF             FUNCT2                  # (NOTHING NEED BE DONE)
.66667          DEC             .66667
                EXTEND
                DCS             OMEGA.K
                DXCH            OMEGA.K                 # CHANGE SIGN OF OMEGA.K

FUNCT2          EXTEND
                DCA             OMEGA.K
                DXCH            FUNCTION                # DEL*OMEGA*K
                EXTEND
                DCA             A2CNTRAL
                DAS             FUNCTION                # DEL*OMEGA*K + SGN(ALPHA)ALPHA(2)

FUNCT3          CAE             A2CNTRAL                # CALCULATE (2/3)SGN(ALPHA)ALPHA(2)
                EXTEND
                MP              .66667
                DXCH            A2CNTRAL
                XCH             L
                EXTEND
                MP              .66667
                ADS             A2CNTRAL        +1
                TS              L
                TCF             +2
                AD              A2CNTRAL

                DXCH            OMEGA.K                 # DEL*OMEGA*K+
                DAS             A2CNTRAL                # (2/3)SGN(ALPHA)ALPHA(2)=G

                CAE             A2CNTRAL                # G*ALPHA IN D.P.

                EXTEND
                MP              ACENTRAL
                DXCH            A2CNTRAL
                XCH             L
                EXTEND
                MP              ACENTRAL
                ADS             A2CNTRAL        +1
                TS              L
                TCF             +2
                ADS             A2CNTRAL

                DXCH            A2CNTRAL                # FIRST AND THIRD TERMS
                DAS             K2THETA                 # SUMMED IN D.P.

# THE FOLLOWING SECTION CALCULATES .707*DEL*FUNCTION(3/2) AND ADDS IT TO THE OTHER TWO TERMS OF NEGUSUM.

                CCS             FUNCTION                # TEST FOR HIGH ORDER WORD NON-ZERO
                TCF             FMAGTEST                # YES, SEE IF RESCALING IS NECESSARY

## Page 562
                TCF             +2                      # NO, USE LOW ORDER WORD ONLY
.707GTS         DEC             .70711                  # (CCS HOLE USED FOR DATA)
                TC              T6JOBCHK

                CAE             FUNCTION        +1      # USE LOW ORDER WORD ONLY
                TC              SPROOT                  # SQUARE ROOT SUBROUTINE CALL
                EXTEND                                  #         3/2
                MP              FUNCTION        +1      # FUNCTION
                EXTEND                                  # (NEEDS TO BE SHIFTED RIGHT 21 PLACES)
                MP              BIT8
                XCH             L
                CAF             ZERO                    #              3/2
                DXCH            FUNCTION                # SAVE FUNCTION    IN FUNCTION LOCATION
                TCF             DELTEST

SQRESCAL        CAE             FUNCTION                # HIGH ORDER WORD OF FUNCTION NEEDS TO BE
                EXTEND                                  # RESCALED FOR ACCURACY, SO MULTIPLY D.P.
                MP              BIT7                    # VALUE BY 2(6)
                LXCH            FUNCTION
                CAF             ZERO
                XCH             FUNCTION        +1
                EXTEND
                MP              BIT7
                DAS             FUNCTION

                CAF             ZERO                    # SET FLAG TO GO TO RESCALE, AND GO TO DO
                TS              MULTFLAG                # SQUARE ROOT AND FUNCTION(3/2)
                TCF             DOSPROOT		# CALCULATION

DELTEST         CS              POSMAX                  # SET FLAG TO GO TO NEGUSUM
                TS              MULTFLAG
                CCS             DEL                     # GET DEL*.707
                CAF             .707GTS
                TCF             +2
                CS              .707GTS
                TCF             SPDMULT                 # GO TO MULTIPLY ROUTINE

RESHIFT         CAF             POSMAX                  # SET FLAG TO GO TO DELTEST

                TS              MULTFLAG
                CAF             BIT6
                TCF             SPDMULT                 # GOTO MULTIPLY ROUTINE

FMAGTEST        AD              63/64+1                 # IF MAGNITUDE OF HIGH ORDER WORD IS LESS
                OVSK                                    # THAN 1/64 RESCALE WHOLE D.P. WORD
                TCF             SQRESCAL

                CAF             POSMAX
                TS              MULTFLAG

DOSPROOT        CAE             FUNCTION                # USE HIGH ORDER WORD ONLY

## Page 563
                TC              SPROOT                  # SQUARE ROOT SUBROUTINE CALL

SPDMULT         XCH             FUNCTION                # THIS IS AN OPEN SUBROUTINE WHICH USES
                EXTEND                                  # MULTFLAG AS A RETURN SWITCH.
                MP              FUNCTION                # IT MULTIPLIES FUNCTION (D.P.) BY C(A)
                DXCH            FUNCTION                # AND LEAVES THE RESULT IN FUNCTION (D.P.)
                EXTEND                                  # IT IS USED FOR-
                MP              L                       # 1) F(1/2)*F
                ADS             FUNCTION        +1      # 2) (.707*DEL)*F
                TS              L                       # 3) 2(-9)*F
                TCF             +2
                ADS             FUNCTION

                CCS             MULTFLAG                # POSMAX MEANS GO TO DELTEST
                TCF             DELTEST                 # ZERO   MEANS GO TO RESHIFT
                TCF             RESHIFT                 # NEGMAX MEANS GO TO NEGUSUM

NEGUSUM         EXTEND                                  # FORM FINAL SUM FOR NEGUSUM
                DCA             FUNCTION

                DAS             K2THETA

                CCS             K2THETA                 # TEST FOR ZERO HIGH ORDER PART
                TCF             NEGDRIVE
                TCF             +2
                TCF             POSDRIVE

                CCS             K2THETA         +1      # SIGN TEST ON LOW ORDER PART
NEGDRIVE        CAF             TWO
                TCF             +2
POSDRIVE        CAF             ZERO
                AD              NEG1
                INDEX           ITEMP6                  # SET NEGUQ,R TO NEG DRIVE
                TS              NEGUQ

                COM
                EXTEND                                  # SEND BACK JERK TERM
                INDEX           ITEMP6
                MP              ACCDOTQ
                INDEX           ITEMP6
                LXCH            QACCDOT

                CCS             QRCNTR                  # LOOP COUNTER

                TCF             GOQTRIMG

# TRANSFORM JERKS BACK TO GIMBAL AXES.

                CAE             QACCDOT                 # SCALED AT PI/2(7)
                EXTEND
                MP              MR12                    # SCALED AT 2
                TS              Y3DOT

## Page 564
                CAE             RACCDOT                 # SCALED AT PI/2(7)
                EXTEND

                MP              MR13                    # SCALED AT 2
                ADS             Y3DOT
                ADS             Y3DOT                   # SCALED AT PI/2(7)

                CAE             QACCDOT                 # SCALED AT PI/2(7)
                EXTEND
                MP              MR22                    # SCALED AT 1
                TS              Z3DOT
                CAE             RACCDOT                 # SCALED AT PI/2(7)
                EXTEND
                MP              MR23                    # SCALED AT 1
                ADS             Z3DOT                   # SCALED AT PI/2(7)

                TC              WRCHN12                 # SEND GIMBAL DRIVES TO SERVOS
                TCF             RESUME                  # WAIT UNTIL NEXT TRIM GIMBAL RUPT

# WAITLIST TASKS TO SET TRIM GIMBAL TURN OFF BITS.

OFFGIMQ         CAF             ZERO                    # SET Q-AXIS FLAG TO ZERO
                TS              NEGUQ
                TCF             +3
OFFGIMR         CAF             ZERO                    # SET R-AXIS FLAG TO ZERO
                TS              NEGUR

                TC              WRCHN12                 # FLAGS TO CHANNEL BITS
                TCF             TASKOVER

# THE WRCHN12 SUBROUTINE SETS BITS 9,10,11,12 OF CHANNEL 12 ON THE BASIS OF THE CONTENTS OF NEGUQ,NEGUR WHICH ARE
# THE NEGATIVES OF THE TRIM GIMBAL DESIRED DRIVES.

BGIM            OCTAL           07400
CHNL12          EQUALS          ITEMP6

WRCHN12         CS              BGIM                    # SAVE THE REST OF CHANNEL 12 DURING TESTS
                EXTEND
                RAND            12
                TS              CHNL12                  # (TEMPORARY STORAGE)

                CCS             NEGUQ
                CAF             BIT9
                TCF             +2
                CAF             BIT10
                ADS             CHNL12

                CCS             NEGUR
                CAF             BIT11
                TCF             +2

                CAF             BIT12
                ADS             CHNL12                  # (STORED RESULT NOT USED AT PRESENT)

## Page 565
                EXTEND
                WRITE           12

                TC              Q                       # SIMPLE RETURN ALWAYS

# Q,R-TRANSF TRANSFORMS A Y,Z GIMBAL COORDINATE VARIABLE PAIR (IN A,L) TO PILOT COORDINATES (Q/R), RETURNED IN A.
# (THE MATRIX M FROM GIMBAL TO PILOT AXES IS ASSUMED TO BE DONE BY T4RUPT AND SCALED AT +1.)

QRERAS          EQUALS          ITEMP6

QTRANSF         LXCH            QRERAS                  # SAVE Z-AXIS VARIABLE
                EXTEND
                MP              M21                     # (Y-AXIS)*M21
                XCH             QRERAS                  # SAVE, GET Z-AXIS VARIABLE
                EXTEND
                MP              M22                     # (Z-AXIS)*M22
                AD              QRERAS                  # SUM = (Y-AXIS)*M21 + (Z-AXIS)*M22
                TC              Q                       # RETURN WITH SUM IN A

RTRANSF         LXCH            QRERAS                  # SAVE Z-AXIS VARIABLE
                EXTEND
                MP              M31                     # (Y-AXIS)*M31
                XCH             QRERAS                  # SAVE, GET Z-AXIS VARIABLE
                EXTEND
                MP              M32                     # (Z-AXIS)*M32
                AD              QRERAS                  # SUM = (Y-AXIS)*M31 + (Z-AXIS)*M32
                TC              Q                       # RETURN WITH SUM IN A

(2/3)           DEC             0.66667

## Page 566
# SUBROUTINE: TGOFFCAL            MOD. NO. 1  DATE: AUGUST 22, 1966

# PROGRAM DESIGN BY: RICHARD D. GOSS (MIT/IL)

# PROGRAM IMPLEMENTATION BY: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# MODIFIED 30 NOV 66, TO USE ACCDOTQ AND ACCDOTR.              CRAIG WORK
# THIS SUBROUTINE CALCULATES THE TRIM GIMBAL SHUTDOWN TIME FOR EITHER THE Q OR THE R AXIS (DEPENDING ON THE
# CALLING SEQUENCE).  THIS TIME IS SCALED FOR IMMEDIATE USE BY A WAITLIST CALL AS SHOWN IN THE CALLING SEQUENCES.
# IF THE TIME-TO-GO IS MORE THAN TWO MINUTES, IT IS LIMITED TO TWO MINUTES DUE TO THE WAITLIST SPECIFICATION.  IF
# THE TIME-TO-GO IS LESS THAN TEN MILLISECONDS, THE SHUTDOWN IS PERFORMED IMMEDIATELY AND THE WAITLIST CALL IS
# BY-PASSED.

# THESE TIME-TO-GO CALCULATIONS ARE DESIGNED TO DRIVE THE TRIM GIMBAL TO A POSITION WHERE THE DESCENT ENGINE WILL

# CAUSE NO ANGULAR ACCELERATION.  THIS SUBROUTINE IS CALLED ONLY FROM THE WAITLIST TASK CHEKDRIV WHICH IS
# INITIATED ONLY WHEN THE TRIM GIMBAL CONTROL LAW HAS LOST CONTROL OF THE LEM VEHICLE ATTITUDE AND MUST RETURN TO
# THE USE OF REACTION CONTROL SYSTEM JETS.

# CALLING SEQUENCES:

#                     26,1000  3 7657 1            CAF    ZERO            Q-AXIS INDEXER
#                     26,1001  0 $$$$ $            TC     TGOFFCAL        CALL TGOFFCAL (*** REPLACE $$ ***)
#                     26,1002  0 4511 0            TC     WAITLIST        CALL WAITLIST WITH CALCULATED TIME
#                     26,1003   0$$$$ $            2CADR  OFFGIMQ         2CADR OF Q-AXIS SHUTDOWN PROGRAM
#                     26,1004   54006 1

#                     26,1005  3 7657 1            CAF     TWO            R-AXIS INDEXER
#                     26,1006  0 $$$$ $            TC      TGOFFCAL       CALL TGOFFCAL (*** REPLACE $$ ***)
#                     26,1007  0 4511 0            TC      WAITLIST       CALL WAITLIST WITH CALCULATED TIME
#                     26,1010   0$$$$ $            2CADR   OFFGIMR        2CADR OF R-AXIS SHUTDOWN PROGRAM
#                     26,1011   54006 1

# SUBROUTINES CALLED: NONE, BUT WRCHNL12 IS CALLED AFTER BOTH TGOFFCALL CALLS.

# NORMAL EXITS: TO WAITLIST CALL OR BEYOND 2CADR IN CALLING SEQUENCE AS SPECIFIED ABOVE.

# ALARM OR ABORT EXIT MODES: NONE

# INPUT: 1. THE AXIS INDEXER: 0 FOR Q, 2 FOR R (SEE CALLING SEQUENCES)
#        2. THE SIGNED TIME DERIVATIVE OF ACCELERATION (QACCDOT OR RACCDOT) SCALED AT PI/2(7) RAD/SEC(3).
#        3. THE ACCELERATION APPROXIMATION FROM THE DESCENT KALMAN FILTER TRANSFORMED TO PILOT AXES (ALPHAQ OR
# ALPHAR) SCALED AT PI/8 RAD/SEC(2).

#        4. CHANNEL 12 CONTAINS THE GIMBAL DRIVES AND OTHER BITS.
# OUTPUT 5. THE NEGATIVE GIMBAL DRIVE FLAG (NEGUQ AND NEGUR) WHERE A +1 BIT REQUESTS POSITIVE GIMBAL DRIVE
#           (ANGULAR ACCELERATION DECREASING), A -1 BIT REQUESTS NEGATIVE GIMBAL DRIVE (ANG. ACC. INCREASING).
#           A ZERO INDICATES NO DRIVE.
#        6. TIME REQUIRED TO ZERO ACCELERATION, SCALED FOR WAITLIST.

# ERASABLE STORAGE CONFIGURATION (NEEDED BY THE INDEXING METHODS):

## Page 567

#                                         NEGUQ    ERASE   +2             NEGATIVE OF Q-AXIS GIMBAL DRIVE
#                                         (SPWORD) EQUALS NEGUQ +1        ANY S.P. ERASABLE NUMBER, NOW THRSTCMD
#                                         NEGUR    EQUALS NEGUQ +2        NEGATIVE OF R-AXIS GIMBAL DRIVE

#                                         ACCDOTQ  ERASE   +2             Q-JERK TERM SCALED AT PI/2(7) RAD/SEC(3)
#                                         (SPWORD) EQUALS ACCDOTQ +1      ANY S.P. ERASABLE NUMBER  NOW QACCDOT
#                                         ACCDOTR  EQUALS ACCDOTQ +2      R-JERK TERM SCALED AT PI/2(7) RAD/SEC(3)
#                                                                         ACCDOTQ,ACCDOTR ARE MAGNITUDES.
#                                         ALPHAQ   ERASE   +2             Q-AXIS ACCELERATION SCALED AT PI/8 R/S2
#                                         (SPWORD) EQUALS ALPHAQ +1       ANY S.P. ERASABLE NUMBER, NOW OMEGAR
#                                         ALPHAR   EQUALS ALPHAQ +2       R-AXIS ACCELERATION SCALED AT PI/8 R/S2
#                                                                         NOTE: NOW OMEGAP,OMEGAQ PRECEDE ALPHAQ

# DEBRIS: L, Q, ITEMP1, ITEMP2, ITEMP6


TGOFFCAL        TS              QRNDXER                 # Q OR R AXIS INDEXER
                INDEX           QRNDXER                 # GET JERK TERM MAGNITUDE SCALED AT

                CAE             ACCDOTQ                 #      PI/2(7) IN RADIANS/SEC(3).
                EXTEND                                  # UNLESS THETA TRIPLE-DOT MAGNITUDE IS NON
                BZMF            TGOFFNOW                #      -ZERO, SET DRIVE TO ZERO NOW.
                TS              NZACCDOT                # SAVE NON-ZERO DENOMINATOR.
                INDEX           QRNDXER                 # INITIALIZE THE AOSTERM WHICH WILL BE UP-
                CAE             ALPHAQ                  # DATED IN THE DUMMYFIL CALCULATION FOR
                EXTEND                                  # USE IN THE QRAXIS RATE DERIVATION.  SET
                MP              .1-.05K)                # AOSTERM TO ALPHA*CSP*(1-.5*K), WHERE CSP
                XCH             L                       # IS .1 SEC, K IS .5   THEN AOSTERM IS SET
                CCS             QRNDXER                 # TO .075*ALPHA, SCALED AT PI/4,WHILE
                INDEX           A                       # ALPHA IS SCALED AT PI/8( THE CONSTANT IS
                LXCH            AOSQTERM                # SCALED AT 2.
                INDEX           QRNDXER                 # GET ACCELERATION SCALED AT PI/8
                CAE             ALPHAQ                  #      RAD/SEC(2).
                EXTEND                                  # IF ACCELERATION IS ALREADY ZERO, EXIT.
                BZF             TGOFFNOW                # OTHERWISE, PROCEED WITH NON-ZERO ALPHA.
                EXTEND                                  # SET NEGUQ TO THE SIGN OF ALPHA. THEN USE
                BZMF            NEGALPH                 #   THE MAGNITUDE OF ALPHA TO COMPUTE TIME
                TS              ITEMP6
                CAF             BIT1
                TCF             +4
NEGALPH         CS              A
                TS              ITEMP6

                CS              BIT1
                INDEX           QRNDXER                 # STORE THE DRIVE DIRECTION FLAG
                TS              NEGUQ                   # TIME = MAGNITUDE OF (ALPHA/ACCDOT),
                COM                                     # LEAVES THE SIGN OF Q(R)ACCDOT IN A.
                EXTEND                                  # STORE ACCDOT TO REFLECT THE CHANGE IN
                INDEX           QRNDXER                 # GIMBAL DRIVE DIRECTION (POSSIBLE).  THIS
                MP              ACCDOTQ                 # CAN BE ESSENTIAL FOR DUMMYFIL, IN CASE
                INDEX           QRNDXER                 # Q(R)ACCDOT IS NOT INITIALIZED BEFORE

## Page 568
                LXCH            QACCDOT                 # EXECUTING DUMMYFIL.
                CAE             ITEMP6

                EXTEND                                  # MULTIPLY BY 1/16
                MP              BIT11                   # TO CHANGE SCALING TO 2PI RAD/SEC(2)
                EXTEND                                  # ACCDOT SCALED AT PI/2(7) IN DENOMINATOR
                DV              NZACCDOT                # YIELDS TIME SCALED AT 256 SECONDS
                AD              -2MIN256                # COMPARE WITH MAXIMUM 2 MINUTE DELAY OF
                CCS             A                       # WAITLIST ACTION (TIMES AT 256 SECONDS)
                CS              -2MINWL                 # MORE THAN TWO MINUTES, USE 2MINUTES
                TC              Q                       # RETURN WL CALL WITH 2 MIN AT 1BIT=10MS

                AD              ONE                     # (CORRECT FOR CCS BIT)
                EXTEND                                  # CALCULATE DT = ABS(T-2MIN)
                MP              128/164                 # AND RESCALE DT TO WAITLIST SCALING
                DDOUBL
                AD              -2MINWL                 # -T = DT + 2MIN (IN WAITLIST SCALING)
                COM                                     # MAKE T POSITIVE FOR WAITLIST
                EXTEND                                  # MAKE FINAL CHECK TO INSURE T .G. 10 MS
                BZMF            TGOFFNOW                # DO SHUTDOWN NOW (COULD USE BZF)
                TC              Q                       # RETURN TO WAITLIST CALL WITH WL TIME

TGOFFNOW        CAF             ZERO                    # MAKE SURE PLUS ZERO FOR DRIVE FLAG
                INDEX           QRNDXER                 # TURN OFF DRIVE FLAG NOW
                TS              NEGUQ
                INDEX           Q

                TC              3                       # SKIP WAITLIST CALL AND 2CADR



QRNDXER         EQUALS          ITEMP1                  # INDEXER FOR Q OR R AXIS
NZACCDOT        EQUALS          ITEMP2                  # TEMPORARY STORAGE FOR NON-ZERO ACCDOT
-2MINWL         DEC             -12000                  # - 2 MINUTES SCALED FOR WAITLIST
-2MIN256        DEC             -.46875                 # - 2 MINUTES SCALED AT 256
128/164         OCTAL           31000                   # 128/163.84 CONVERTING 256 TO WAITLIST/2
.1-.05K)        OCTAL           01146                   # .0375=.075 SCALED AT 2
