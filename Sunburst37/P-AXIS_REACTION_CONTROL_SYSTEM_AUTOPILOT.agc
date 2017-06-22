### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P-AXIS_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc
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
## Reference:   pp. 468-490
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-03 HG   Transcribed
##              2017-06-15 HG   Fix operand EDOTP -> EDOT
##              2017-06-15 MAS  Removed a stray 'A' from an EXTEND.
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 468
                BANK            16
                EBANK=          DT

# THE FOLLOWING T5RUPT ENTRY BEGINS THE PROGRAM WHICH CONTROLS THE P-AXIS ACTION OF THE LEM USING THE RCS JETS.
# THE NOMINAL TIME BETWEEN THE P-AXIS RUPTS IS 100 MS IN ALL NON-IDLING MODES OF THE DAP.

PAXIS           CAF             MS30P                   # RESET TIMER IMMEDIATELY: DT = 30 MS
                TS              TIME5

                LXCH            BANKRUPT                # INTERRUPT LEAD IN (CONTINUED)
                EXTEND
                QXCH            QRUPT

# CHECK TO SEE IF DAP IS STILL IN USE:

                TC              CHEKBITS                # RETURN IS TO I+1 IF DAP SHOULD STAY ON.

# WHILE DAP IS ON, SET UP EITHER A KALMAN FILTER RUPT OR A DUMMY FILTER RUPT BY SETTING UP T5ADR FROM ERASABLE.

                EXTEND                                  # T5ADR IS SET TO EITHER FILTER OR
                DCA             PFILTADR                # DUMMYFIL IN A BLIND MANNER SINCE
                DXCH            T5ADR                   # PFILTADR IS SET UP ELSEWHERE

# DO P AXIS RATE DERIVATION AND CONTROL LAW.
# DERIVE DELTA P.

                CA              ZERO
                TS              ITEMP1
                CAE             TP
                AD              NEGCSP1
                EXTEND
                BZMF            DOTORQUE
                TS              ITEMP1
                CA              CSPAT1P
                TCF             SCALEDTP
DOTORQUE        CA              TP
                EXTEND
                MP              BIT5
                CAE             L
                EXTEND
                MP              16/25
SCALEDTP        TS              TP
                EXTEND
                MP              WFORP
                AD              (1-K)/8
                EXTEND
                MP              TP
                EXTEND
                MP              BIT4
                CA              1JACC

## Page 469
                EXTEND
                MP              L
                EXTEND
                MP              NO.PJETS
                LXCH            JETRATE
                CA              ITEMP1
                TS              TP

                CAE             CDUX
                TS              L
                EXTEND
                MSU             OLDXFORP                # SCALED AT PI
                LXCH            OLDXFORP
                EXTEND
                MP              BIT7
                LXCH            DELTAP                  # SCALE AT PI/2(6)
                CA              CDUY
                TS              L
                EXTEND
                MSU             OLDYFORP                # SCALED AT PI
                LXCH            OLDYFORP
                EXTEND
                MP              BIT7                    # INTO L SCALED AT PI/2(6)
                CA              M11                     # M11 SCALED AT 1
                EXTEND
                MP              L                       # INTO A SCALED AT PI/2(6).
                AD              DELTAP
                EXTEND
                MP              WFORP                   # SCALED AT 2(4)=16, RESULT IN A AT PI/4.
                XCH             OMEGAP                  # W*DELTAP IN OMEGAP LOC. OLD OMEGAP IN A.
                EXTEND
                MP              (1-K)                   # SCALED AT 1

                AD              JETRATE                 # RATE DUE TO JETS TORQUING.
                ADS             OMEGAP                  # PRATE= WFORP*DELTAP+ALPHA*LAST-PRATE+TPF
PAXFILT         TC              PJUMPADR
SKIPPAXS        CA              VISNORMQ
                TS              PJUMPADR
                TCF             RESUME

CHKVISFZ        TC              T6JOBCHK                # CHECK FOR T6 RUPT.

                CAF             VIZPHASE
                MASK            DAPBOOLS
                EXTEND
                BZF             +2
                TCF             PURGENCY                # ATTITUDE STEER DURING VISIBILITY PHASE

                CAF             BIT10                   # BIT10=1 FOR RHC MINIMUM IMPULSE MODE
                MASK            DAPBOOLS
                EXTEND

## Page 470

                BZF             DETENTCK                # BRANCH FOR RATE COMMAND

                CCS             DELAYCTR                # DELAYCTR IS SET TO 3 BY RUPTIO

                TCF             WHICHONE		# LOOK FOR JET TO TURN ON

                TCF             CHEKALL6

                CAF             BIT12                   # PERMIT NEXT RUPT10.DELAYCTR IS NEG
                EXTEND                                  # WHEN PREVIOUS READING OF 31 FOUND
                WOR             13                      # ALL SWITCHES OPEN.
                TCF             JETSOFF

WHICHONE        TS              DELAYCTR                # DECREMENT DELAYCTR

                CAF             BIT3
                EXTEND
                RAND            31
                EXTEND
                BZF             +MINIMP

                CAF             BIT4
                EXTEND
                RAND            31
                EXTEND

                BZF             -MINIMP

                TCF             JETSOFF

+MINIMP         CAF             BIT1
                TCF             +2
-MINIMP         CS              BIT1
 +2             TS              TJETSIGN                # SAVE SIGN OF P-AXIS ROTATION

                CA              PTJMINT6
                TS              DELAYCTR                # AGAIN UNTIL NEXT RUPT

                CAF             NEGMAX                  # RECORD TWO JETS FOR MINIMUM IMPULSE BE-
                TS              NJET                    # FORE SELECTING POLICY

                CAF             PTJMINT6                # SET UP JET TIMES
                TS              TP
                TS              TOFJTCHG
                TCF             PJETSLEC                # AND GO SELECT JET POLICY

CHEKALL6        EXTEND
                READ            31
                COM
                MASK            DAPLOW6
                EXTEND

## Page 471
                BZF             +2

                TCF             JETSOFF
                CS              BIT1                    # PUTTING NEGATIVE NUMBER IN DELAYCTR
                TS              DELAYCTR                # WILL CAUSE RUPT TO BE ENABLED NEXT TIME
                TCF             JETSOFF

DETENTCK        CA              BIT15
                EXTEND
                RAND            31                      # CHECK OUT-OF-DETENT BIT.INVERTED.
                EXTEND
                BZF             RHCMOVED                # BRANCH IF OUT OF DETENT
#........................................................................
                CAF             BIT1                    # IN DETENT.CHECK THE RATE COMMAND BIT
                MASK            DAPBOOLS                # BIT1 OF DAPBOOLS IS RATE COMMAND BIT
                EXTEND
                BZF             PURGENCY                # BRANCH IF NOT IN RATE COMMAND
#........................................................................
                CAF             BIT13                   # CHECK ATTITUDE HOLD BIT

                EXTEND
                RAND            31
                EXTEND
                BZF             JOEY                    # BRANCH IF IN ATTITUDE HOLD
#........................................................................
                CCS             OMEGAP                  # HERE IF IN X-AXIS OVER-RIDE
                TCF             +4
                TCF             RATEDONE
                TCF             +2
                TCF             RATEDONE
                AD              -RATEDB
                EXTEND
                BZMF            RATEDONE
                TCF             JOEY

RATEDONE        CS              BIT1
                MASK            DAPBOOLS
                TS              DAPBOOLS

# READ CDUS INTO CDU DESIRED REGISTERS

                CA              CDUX
                TS              CDUXD

                CA              CDUY
                TS              CDUYD
                CA              CDUZ
                TS              CDUZD

                TCF             JETSOFF

RHCMOVED        CAF             BIT1                    # CHECKING THE RATE COMMAND BIT
                MASK            DAPBOOLS

## Page 472
                EXTEND
                BZF             JUSTOUT

# READ,ZERO, AND ENABLE COUNTERS
# SYSTEM HAS BEEN IN RATE COMMAND FOR AT LEAST THE TIME OF A CAP CHARGE

                CAE             P-RHCCTR                # 1 BIT IN P-RHCCTR WORTH 0.6256 DEG/SEC
                EXTEND
                MP              BIT9
                CA              L
                EXTEND
                MP              0.88975
                TS              PRATECOM                # COMMANDED RATE SCALED AT PI/4

                CAF             ZERO                    # ZERO COUNTERS
                TS              P-RHCCTR
                TS              Q-RHCCTR
                TS              R-RHCCTR
                CA              BITS8,9                 # ENABALE COUNTERS, START READING
                EXTEND
                WOR             13
                TCF             OBEYRATE
#........................................................................
JUSTOUT         INCR            DAPBOOLS                # ALWAYS SETS BIT1 ON RATE COMMAND BIT
                CAF             BIT2
                EXTEND

                RAND            30
                EXTEND
                BZF             +5                      # BRANCH FOR ASCENT CONSTANTS

                CAF             -D2JTLIM                # -1.4 DEG/SEC SCALED AT PI/4
                TS              -2JETLIM
                CAF             -DRATEDB                # -0.4 DEG/SEC SCALED AT PI/4
                TCF             +4

 +5             CAF             -A2JTLIM                # -2.0 DEG/SEC SCALED AT PI/4
                TS              -2JETLIM
                CAF             -ARATEDB                # -1.0 DEG/SEC SCALED AT PI/4
 +4             TS              -RATEDB

                CAF             ZERO                    # ZERO COUNTERS
                TS              P-RHCCTR
                TS              Q-RHCCTR
                TS              R-RHCCTR
                CA              BITS8,9
                EXTEND
                WOR             13
                TCF             JETSOFF
#........................................................................

JOEY            CAF             ZERO

## Page 473
                TS              PRATECOM

# IN THIS SECTION P RATE ERROR IS COMPUTED AND T-JET IS CALCULATED

OBEYRATE        CS              OMEGAP
                AD              PRATECOM
                CCS             A                       # IF POSITIVE, NON-ZERO, STORE POSITIVE
                CAF             BIT1                    # P-AXIS ROTATION

                TCF             +2                      # WILL NOT COME HERE DIRECTLY
                CS              BIT1                    # NEGATIVE, NON-ZERO, STORE NEGATIVE
                TS              TJETSIGN                # P-AXIS ROTATION.  NO NEG ZERO POSSIBLE

OBEYRAPE        CCS             PERROR                  # GET ABVAL OF RATE P-ERROR
                TCF             +4
                TCF             JETSOFF
                TCF             +2
                TCF             JETSOFF
                AD              BIT1
                TS              PRATEDIF                # ABVAL OF RATE ERROR SCALED AT PI/4

                TC              T6JOBCHK                # T6JOBCHK IS IN FIXED-FIXED

                CA              -RATEDB
                AD              PRATEDIF
                EXTEND
                BZMF            JETSOFF                 # RATE ERROR INSIDE DEADBAND

                CAE             PRATEDIF                # START TJET COMPUTATION
                EXTEND
                MP              1/2JTSP                 # 1/2JTACC SCALED AT 2EXP(8)/PI
                EXTEND

                MP              BIT3                    # ENOUGH FOR 4 JETS
                CAE             L
                EXTEND
                MP              25/32                   # A CONTAINS TJFT SCALED AT 2EXP(4)(16/25)
                TS              TP
                TS              TOFJTCHG

                CAE             PRATEDIF                # TEST WHETHER 2 OR 4 JETS TO BE USED BY
                AD              -2JETLIM                # COMPARING DELTA RATE WITH 2 JET LIMIT
                EXTEND
                BZMF            +4                      # IF NEGATIVE, 2 JETS ARE ENOUGH

                CAF             POSMAX                  # POSITIVE, NON-ZERO.  PUT POSMAX IN NJET
                TS              NJET
                TCF             PJETSLEC                # AND GO SELECT GOOD POLICY

                CAF             NEGMAX                  # 2 JETS, PUT NEGMAX IN NJET,
                TS              NJET
                CAE             TP                      # DOUBLE TP,

## Page 474
                DOUBLE
                TS              TP                      # AND GO CHECK MINIMUM IMPULSE

#........................................................................
# CHECK RATE COMMAND ON TIME AGAINST MINIMUM IMPULSE
                TS              TOFJTCHG
                AD              -TJMINT6
                EXTEND                                  #   AS TP. TEST JFT TIME. IS IT GREATER OR
                BZMF            JETSOFF                 # LESS THAN A MINIMUM IMPULSE
#........................................................................

## Page 475
# PROGRAM NAME: PJETSLEC                       DATE: DECEMBER 9, 1966

# MODIFICATION 0 BY JOHN BLISS(ADAMS ASSOCIATES) ROOM 7-286, X183

# LOG SECTION: P-AXIS REACTION CONTROL SYSTEM AUTOPILOT -- FIRST PUT INTO SUNBURST(III) REVISION 29



# FUNCTIONAL DESCRIPTION:

#     THE OBJECT OF PJETSLEC IS TO CHOOSE THE BEST JET POLICY WHOSE NECESSARY JETS HAVE NOT BEEN RECORDED AS
# FAILED IN THE CH6MASK REGISTER.  THE CONDITIONS ON SELECTION ARE THE NUMBER OF JETS REQUESTED(2 OR 4), THE
# SENSE OF P-AXIS ROTATION REQUIRED(+/-), AND ALTERNATING USE OF DIAGONAL FORCE-COUPLED PAIRS OF JETS.

#     PJETSLEC FIRST READS CHANNEL 6 TO SEE IF THE JETS ARE CURRENTLY FIRING.  IF THEY ARE, THE TIME OF JET
# SELECTION COMPUTATION(5 MS.) IS SUBTRACTED FROM TOFJTCHG AND CONTROL GOES DIRECTLY TO TEST THE SENSE OF P-AXIS
# ROTATION.  THE DIAGONAL FORCE-COUPLED PAIRS OF JETS ARE NOT SWITCHED, BECAUSE IT WOULD BE INEFFICIENT TO TURN
# ONE OFF AND THE OTHER ON IN RAPID SUCCESSION.  IF THE JETS ARE OFF, THE MINIMUM IMPULSE DELAY TIME IS ADDED TO

# TOFJTCHG AND THE DIAGONAL JETS ARE SWITCHED TO COMPLY WITH THE ALTERNATION CONDITION.

#     IF THE P-AXIS IS +, REL = 7, IF -, REL = 0,.  NJET IS TESTED NEXT; IF POSMAX, 4 JETS DESIRED, REL = REL +6,
# CTR = 6.  IF NEGMAX, 2 JETS DESIRED, REL = REL + 5, CTR = 5.  IF 4 JETS DESIRED, GO TO POLICY TESTING LOOP
# WITHOUT TESTING TO SEE WHICH DIAGONAL PAIR IS PREFERRED THIS TIME.

#     IF 2 JETS ARE DESIRED, SEE WHETHER NO. 2 PAIR IS PREFERRED.  IF IT IS, TEST IT FIRST AND USE IT IF IT'S OK.
# IF IT HAS FAILED, GO TO THE TEST LOOP TO TEST THE POLICIES IN ORDER.  IF NO. 1 POLICY IS PREFERRED, GO DIRECTLY
# TO THE TEST LOOP.

#     THE TEST LOOP USES REL TO PICK UP THE NEXT POLICY IN PPOLTABL AND CTR TO KEEP TRACK OF THE NUMBER OF
# POLICIES(1-7) TESTED.  WHEN A GOOD POLICY IS FOUND, IT IS WRITTEN INTO CHANNEL 6, OTHERWISE THE NEXT POLICY IS
# TRIED.  IF NO GOOD POLICIES ARE FOUND, CONTROL GOES TO ABORTJET TO TURN OFF THE JETS AND THE DAP.

#     WHEN A GOOD POLICY IS FOUND, WRITEP IS CALLED TO WRITE THE POLICY INTO CHANNEL 6, +/-2/4 IS STORED IN
# NO.PJETS, AND BIT9 IS PUT INTO JTSATCHG TO CAUSE THE P-AXIS JETS TO BE TURNED OFF ON THE NEXT T6RUPT. CONTROL
# THEN TRANSFERS TO TORKVEC.

# CALLING SEQUENCES: NONE                      SUBROUTINES CALLED:

#                                              WRITEP - WRITES C(A). THE
#                                              SELECTED JET POLICY, INTO
#                                              CHANNEL 6


# NORMAL EXIT MODES:                           ALARM OR ABORT EXIT MODES:

#     TCF TORKVEC                                       EXTEND
#                                                       DCA    ABORTADR
#                                                       DTCB

#                                                       EBANK= JTSONNOW

## Page 476
#                                              ABORTADR 2CADR  ABORTJET

#                                              THIS SEQUENCE IS FOLLOWED
#                                              IF NONE OF THE POLICIES IS
#                                              WITHOUT JET FAILURES

# ERASABLE INITIALIZATION REQUIRED

#     TP        =  ) TIME PERIOD OF JET FIRING
#     TOFJTCHG  =  ) AT T6 SCALING, 625 MICROSECONDS PER BIT
#     NJET      =  37777, 40000, DEPENDING ON WHETHER 4 OR 2 JETS DESIRED
#     TJETSIGN  = +/-00001, DEPENDING ON DISIRED SENSE OF P-AXIS ROTATION
#     CH6MASK   =  BITS 1-8 INDICATE WHETHER CORRESPONDING JETS HAVE FAILED - BIT ON IS FAILURE, BIT OFF IS OK.
#     DAPBOOLS,BIT5(AORBSYST) =0/1, DEPENDING UPON WHETHER DIAGONAL 1 OR DIAGONAL 2 WAS PREFERRED DURING LAST PASS

# OUTPUT:

#     CHANNEL 6 - CONTAINS SELECTED JET POLICY UNLESS NONE IS AVAILABLE
#     NO.PJETS  - +/-2/4, SENSE OF P-AXIS ROTATION AND NUMBER OF JETS USED
#                 BY POLICY ACTUALLY SELECTED(MAY NOT = 4 IF 4 JETS RE-
#                 QUESTED BUT ONE OR MORE JETS FAILED)
#     TOFJTCHG  - MODIFIED BY MCOMP OR -14TOMIN DEPENDING ON WHETHER THE
#                 JETS WERE ON WHEN PJETSLEC WAS CALLED
#     DAPBOOLS, BIT5(AORBSYST) = 1/0, IF THE INPUT VALUE WAS 0/1, UNLESS JETS WERE ON WHEN PJETSLEC STARTED.

#     JTSATCHG  - = BIT9, UNLESS NO POLICIES AVAILABLE

#     NJET, TP, TJETSIGN, AND CH6MASK NOT CHANGED BY PJETSLEC

#     REL AND CTR ARE LEFT AT THEIR LAST VALUES WHEN THE GOOD POLICY WAS
#     FOUND

# DEBRIS:

#     REL = ITEMP5
#     CTR = ITEMP6
#     A,L,Q

PJETSLEC        EXTEND                                  # BEGIN JET SELECT ROUTINE BY SEEING WHE-
                READ            6                       # THER THE JETS ARE TURNED ON(CHANNEL 6
                EXTEND                                  # NON-ZERO)
                BZF             +4                      # IF THE JETS AREN'T ON, GET MINIMP DELAY

                CAF             MCOMPT                  # CONTAINS -TIME OF JET SELECTION
                ADS             TOFJTCHG                # ADD IT TO TOFJTCHG(TO REDUCE JET FIRING)
                TCF             TESTSIGN                # SINCE JETS ALREADY ON, DONT SWITCH DIAGS

                CAF             14-TJMIN                # PICK UP MINIMUM IMPULSE DELAY TIME
                ADS             TOFJTCHG                # AND ADD TO TOFJTCHG(TO LENGTHEN FIRING)

## Page 477
                CAF             AORBSYST                # IF JETS NOT ON NOW. START BY
                LXCH            DAPBOOLS                # SWITCHING BIT5 IN DAPBOOLS.
                EXTEND                                  # BIT5 ON - DIAGONAL JETS 15,7 AND 8, 16
                RXOR            L
                TS              DAPBOOLS                # BIT5 OFF - DIAGONAL JETS 4,12 AND 3, 11

TESTSIGN        CAF             ZERO                    # COME HERE DIRECTLY IF JETS ALREADY ON
                TS              REL                     # INITIALIZE ADDRESSING INDEX AT ZERO

                CCS             TJETSIGN                # TEST DIRECTION OF P-AXIS ROTATION(ROLL)
                CAF             SEVEN                   # IF POSITIVE, GET POLICY FROM LOWER SEVEN
                ADS             REL                     # LOCATIONS OF TABLE

                CCS             NJET                    # SET IF 4-JET POLICY IS REQUESTED
                CAF             SIX                     # IT IS, PICK UP 6 FOR REL AND CTR
                TCF             FILCOUNT                # AND GO STORE THEM

                CAF             FIVE                    # 2 JETS ONLY REQUESTED, PICK UP 5, STORE
                ADS             REL                     # IN REL AND CTR
                TS              CTR
                CS              DAPBOOLS                # CHECK BIT5 IN DAPBOOLS TO SEE WHICH PAIR
                MASK            AORBSYST                # OF DIAGONAL JETS SHOULD BE USED NEXT
                CCS             A
                TCF             TESTPOL                 # FIRST PAIR, SO GO TO TESTING LOOP NOW

                EXTEND                                  # SECOND PAIR, DECREMENT REL TO 4 OR 11.
                DIM             REL
                INDEX           REL                     # PICK UP SECOND DIAGONAL PAIR FROM POLICY
                CAF             PPOLTABL
                MASK            CH6MASK                 # TABLE AND COMPARE WITH FAILURE BITS
                EXTEND
                BZF             WRITEPOL                # THE JETS ARE GOOD, GO WRITE IN CHANNEL

                INCR            REL                     # THE JET(S) HAVE FAILED FOR THIS POLICY,
                TCF             TESTPOL                 # RESTORE REL AND DO TEST POLICY LOOP

FILCOUNT        ADS             REL                     # COME HERE TO SET REL AND CTR FOR 4-JET
                TS              CTR                     # POLICY REQUESTED.  ALSO, SET CTR -1 HERE

TESTPOL         INDEX           REL                     # PICK UP NEXT POLICY AS LOCATED RELATIVE
                CAF             PPOLTABL                # TO PPOLTABL BY REL.
                MASK            CH6MASK                 # COMPARE WITH FAILURE BITS
                EXTEND
                BZF             WRITEPOL                # THE JETS ARE GOOD, WRITE IN THE CHANNEL

                EXTEND                                  # THE JET(S) HAVE FAILED FOR THIS POLICY
                DIM             REL                     # DECREMENT THE INDEX.
                CCS             CTR                     # SEE IF ALL POLICIES HAVE BEEN TESTED.
                TCF             TESTPOL         -1      # CTR NOT ZERO, A = CTR -1, DO LOOP AGAIN
                EXTEND                                  # CTR ZERO, ALL ALLOWABLE POLICIES FAILED
                DCA             ABORTADR                # PICK UP 2CADR OF ABORTJET

## Page 478
                DTCB                                    # AND GO THERE

WRITEPOL        INDEX           REL                     # A GOOD POLICY IS FOUND, PICK IT UP AND
                CAF             PPOLTABL
                TC              WRITEP                  # GO WRITE IT IN CHANNEL 6 AND RETURN

                CCS             A                       # THE POLICY IS STILL IN A, TEST NUMBER OF
                CAF             TWO
                TCF             +2                      # JETS(BIT15 ON FOR 4-JET POLICIES) AND
                CAF             FOUR
                EXTEND                                  # MULTIPLY BY TJETSIGN(+/-1) TO GET +/-2,4
                MP              TJETSIGN
                LXCH            NO.PJETS                # IN L, WHICH IS THEN STORED IN NO.PJETS

                CAF             BIT9                    # TURN OFF P-AXIS JETS AFTER T6RUPT
                TS              JTSATCHG

                TCF             TORKVEC                 # RECONSTRUCT P TORQUE VECTOR, THEN JTLST.

                EBANK=          JTSONNOW                # WOULD YOU BELIEVE, EBANK = 6
ABORTADR        2CADR           ABORTJET                # WHERE TO GO WHEN ALL JET POLICIES FAIL
# ................................................................................................................

# TABLE OF P-AXIS JET POLICIES IS ASSEMBLED HERE TO BE ADDRESSED BY RELATIVE INDEX FROM BASE ADDRESS PPOLTABLE

#                                          CHANNEL 6 BITS                 INDEX                            JETS ON

PPOLTABL        OCTAL           00202                   # REL=0    -P NON-FORCE COUPLE 4- 16, 3
                OCTAL           00210                   # REL=1    -P NON-FORCE COUPLE 3- 11, 16
                OCTAL           00050                   # REL=2    -P NON-FORCE COUPLE 2- 8, 11
                OCTAL           00042                   # REL=3    -P NON-FORCE COUPLE 1- 3, 8
                OCTAL           00240                   # REL=4    NUMBER TWO FORCE COUPLE- 8, 16
                OCTAL           00012                   # REL=5    -P 2-JET FORCE COUPLE- 3, 11
                OCTAL           40252                   # REL=6    -P 4-JET POLICY- 3, 8, 11, 16

                OCTAL           00101                   # REL=7    +P NON-FORCE COUPLE 4- 7, 4
                OCTAL           00021                   # REL=8D   +P NON-FORCE COUPLE 3- 12, 7

                OCTAL           00024                   # REL=9D   +P NON-FORCE COUPLE 2- 15, 12
                OCTAL           00104                   # REL=10D  +P NON-FORCE COUPLE 1- 4, 15
                OCTAL           00005                   # REL=11D  NUMBER TWO FORCE COUPLE- 15, 7
                OCTAL           00120                   # REL=12D  +P 2-JET FORCE COUPLE- 4, 12
                OCTAL           40125                   # REL=13D  +P 4-JET POLICY- 4, 15, 12, 7

# ................................................................................................................

JETSOFF         CAF             ZERO
                TS              TP
                TS              TOFJTCHG
                TC              WRITEP                  # TURN ON P JETS USING T6JOB SUBROUTINE

## Page 479

                TCF             RESUME
# P-AXIS URGENCY FUNCTION CALCULATION

# (NOTE -- M13 = 1 IDENTICALLY IMPLIES NULL MULTIPLICATION.)

PURGENCY        CA              CDUY                    # P-ERROR CALCULATION
                EXTEND
                MSU             CDUYD                   # CDU VALUE - ANGLE DESIRED (Y-AXIS)
                EXTEND
                MP              M11                     # (CDUY-CDUYD)M11 SCALED AT PI RADIANS
                XCH             E                       # SAVE FIRST TERM (OF TWO)
                CA              CDUX                    # THIRD COMPONENT
                EXTEND
                MSU             CDUXD                   # CDU VALUE - ANGLE DESIRED (X-AXIS)
#               EXTEND
#               MP              M13
                ADS             E                       # SAVE SUM OF TERMS, NO OVERFLOW EVR

                TS              PERROR                  # SAVE P ERROR FOR DISPLAY

                CAE             DAPBOOLS                # BIT15 = 0 FOR SPS BACK-UP
                EXTEND
                BZMF            NOBACKUP                # DAPBOOLS IS NEVER +0.
                CS              OMEGAPD                 # THIS IS THE P-AXIS RCS BACK-UP CODING
                AD              OMEGAP
                TS              EDOT

                CAF             SLOPEMP

                EXTEND
                MP              E
                AD              EDOT
                EXTEND
                BZMF            PLUSDP

                CAF             NEGDP

GCOMPER         TS              ITEMP3
                CAE             EDOT
                EXTEND
                SQUARE
                EXTEND
                MP              1/2AP

                AD              E
                AD              NEGDP
                EXTEND
                BZMF            UCOAST

                CAE             ITEMP3
                EXTEND

## Page 480
                BZMF            NEGPJET

                CAF             POSP
JETPON          EXTEND
                WRITE           6
                TCF             RESUME

NEGPJET         CAF             NEGP
                TCF             JETPON

PLUSDP          CS              E
                XCH             E
                CS              EDOT
                XCH             EDOT
                CS              NEGDP
                TCF             GCOMPER
UCOAST          CAF             ZERO
                TCF             JETPON
NEGP            OCT             00120
POSP            OCT             00240
NEGDP           DEC             -0.00555
SLOPEMP         EQUALS          POSMAX
1/2AP           DEC             0.217
NOBACKUP        CAF             BIT14
                TS              SIGNTAG                 # INDICATES EDOT POSITIVE FOR TIME BEING
                CS              OMEGAPD

                AD              OMEGAP
                CCS             A
                TCF             SCALEDOT
                TCF             PTJETLAW
                TCF             REFLECT
                TCF             PTJETLAW
REFLECT         TS              EDOT
                CS              BIT14
                TS              SIGNTAG                 # INDICATES EDOT REALLY NEGATIVE
                CS              PERROR
                TS              E
                CAE             EDOT
SCALEDOT        AD              BIT1
                EXTEND
                MP              BIT3
                EXTEND
                BZF             PTJETLAW        -1
                CAF             POSMAX
                TCF             PTJETLAW
                CAE             L
PTJETLAW        TS              EDOT
                EXTEND
                MP              EDOT

                TS              EDOT(2)

## Page 481
                CAF             NEGONE
                TS              TJETSIGN
                CAF             NEGMAX
                TS              NJET                    # INDICATES 2 JETS ONLY FOR TIME BEING
                CAE             EDOT(2)
                EXTEND
                MP              1/2JTSP
                EXTEND

                MP              BIT14
                AD              E
                EXTEND
                SU              DB
                TS              FCT1
                EXTEND
                BZMF            5,6,7,8
                CAE             EDOT
                EXTEND
                MP              1/2JTSP
                TS              TERMA
                COM
                AD              BIT11                   # 1SECOND SCALED AT 16 SECONDS
                EXTEND
                BZMF            MULTIJET
                CS              +1.5CSP
                AD              TERMA
                EXTEND
                BZMF            +3
MAXPTJET        CAF             BIT14
                TCF             FINDSIGN
                CS              FCT1
                AD              MINIMPDB

                EXTEND
                BZMF            PMBR
                CAE             TERMA
                AD              -35AT16
                EXTEND
                BZMF            ZONE4
                AD              38.7AT16
                TCF             SCALTJET
MULTIJET        CAF             POSMAX
                TS              NJET
                TCF             MAXPTJET
5,6,7,8         CAE             EDOT(2)
                EXTEND
                MP              .5ACCMIN
                AD              E
                AD              DB
                AD              DBMINIMP
                EXTEND
                BZMF            +2

## Page 482
ZONE5           TCF             JETSOFF
 +2             CS              RATEMAX
                AD              EDOT
                EXTEND
                BZMF            ZONES6,7
ZONE8           TCF             JETSOFF
ZONES6,7        CAF             BIT1
                TS              TJETSIGN
                CS              EDOT
                EXTEND
                MP              1/2JTSP
                TS              TERMA
                CS              FCT1
                AD              E

                AD              E
                AD              MINIMPDB
PMBR            TS              FCT1                    # FCT1 NOW HOLDS -FCT5 OR -FCT2
                CAE             1/2JTSP
                EXTEND
                MP              BIT14
                AD              .5ACCMIN
                TS              DENOM
                EXTEND
                MP              RATEMAX2
                AD              FCT1
                EXTEND
                BZMF            MISSROOT
                CAE             FCT1
                EXTEND
                DV              DENOM
                EXTEND
                MP              1/2JTSP
                EXTEND
                MP              1/2JTSP
                TS              TERMB
                CS              +1.5CSP
                AD              TERMA

                EXTEND
                SQUARE
                AD              TERMB
                EXTEND
                BZMF            MAXPTJET
                CS              TMINAT16
                AD              TERMA
                EXTEND
                BZMF            LASTTEST
ROOTNEXT        TC              T6JOBCHK
                CS              TERMB
                TC              SPROOT
SUMTJ           AD              TERMA

## Page 483
SCALTJET        DOUBLE
                EXTEND
                MP              25/32
                TCF             FINDSIGN
MISSROOT        CAF             RATEMAX+                # RATEMAX+ = RATEMAX+0.6DEGREES/SECOND
                EXTEND
                MP              1/2JTSP
                TCF             SUMTJ
LASTTEST        CS              TMINAT16
                AD              TERMA
                EXTEND
                SQUARE
                AD              TERMB
                EXTEND
                BZMF            ROOTNEXT
                TCF             JETSOFF
ZONE4           CAE             SIGNTAG
                EXTEND
                BZMF            +3

                CS              .1DPS
                TCF             +2
                CA              .1DPS
                AD              OMEGAPD
                TS              OMEGAP
                CAF             PTJMINT6
FINDSIGN        TS              TP
                CAE             SIGNTAG                 # NEVER ZERO
                EXTEND
                BZMF            +2                      # EQUIVALENT TO BRANCH ON MINUS
                TCF             +3
                CS              TJETSIGN
                TS              TJETSIGN
                CAE             TP                      # LOAD TOFJTCHG
                TS              TOFJTCHG
                TCF             PJETSLEC                # AND GO SELECT GOOD POLICY

# TORQUE VECTOR RECONSTRUCTION FOR THE P-AXIS

TORKVEC         CS              TOFJTCHG
                AD              +1.5CSP                 # USE 150 MS. TO TEST FOR A PAXIS SKIP.
                EXTEND
                BZMF            RESUME                  # TP GREATER THAN 150MS THEN DO NORMAL P.

                CA              PSKIPADR                # SET UP A P AXIS SKIP.
                TS              PJUMPADR                # GOES TO JTLST FROM HERE

## Page 484

# PROGRAM NAME   JTLST

# WRITTEN BY  DICK GRAN ( GAEC - CALL LR-5-1331 AREA CODE 516 )

# THIS PROGRAM IN CONJUNCTION WITH T6-RUPT PROGRAMS ALLOWS JETS TO BE
# TURNED OFF AT THE COMPUTED OFF TIME. THIS TASK IS ACCOMPLISHED BY USING
# A JET LIST WHICH IS SET UP AS FOLLOWS ....

#                 JET OFF TIMES    DESIRED JETS AT THIS TIME

#                   TIME6          T6NEXTJT
#                   T6NEXT         T6NEXTJT +1
#                   T6NEXT +1      T6NEXTJT +2

# THESE LOCATIONS RECEIVE THE JET ON TIMES SCALED AS T6 (.625 MS/BIT). AS
# AN EXAMPLE OF HOW THE PROGRAM WORKS, CONSIDER THE FOLLOWING PROBLEM...
#     50 MS AGO A P AXIS JET COMPUTATION DECIDED JETS 12 AND 15 SHOULD BE
#     ON FOR 120 MS. AFTER 120 MS IT WAS FURTHER DECIDED THAT JETS 12,15
#     16 AND 3  SHOULD BE ON UNTIL THE NEXT P AXIS COMPUTATION (WHICH
#     OCCURS IN 200 MS AFTER THE LAST P AXIS JET COMPUTATION). AT THE
#     CURRENT TIME THE QR AXES COMPUTES THAT JET 2 SHOULD BE ON FOR 65 MS
#     AND JET 9 SHOULD BE ON FOR 72.5 MS. AFTER 72.5 MS NO FURTHER QR JETS
#     SHOULD BE ON. THIS SEQUENCE OF JETS CORRESPONDS TO A +P ROTATION
#     WITH A SIMULTANEOUS +Y AND -Z TRANSLATION AND ALSO A -V (DIAGONAL)
#     ROTATION ABOUT THE Y AND Z AXES . NOTE JET 9 IS ON LONGER THAN JET 2
#     WHICH WOULD BE THE CASE IF THE Q-R JETS HAD BEEN ON BEFORE. IN THIS

#     CASE, THE FOLLOWING SEQUENCE OF EVENTS OCCURRED AT THE P AXIS
#     COMPUTATION .....

#          1) CHANNEL 6 WAS LOADED WITH OCTAL 24 TO TURN ON JETS 12 AND 15

#          2) TIME 6 WAS LOADED WITH 120 MS

#          3) T6NEXT WAS LOADED WITH +0 ( THIS INDICATES THE CONTENTS OF
#              T6NEXT ARE NOT TO BE USED IN THE T6JOB PROGRAM)

#          4) T6NEXTJT WAS LOADED WITH OCTAL 226 TO CAUSE JETS 3,12,15
#              AND 16 TO GO ON WHEN T6 HAS BEEN DECREMENTED TO -0.

#          5) THE T6 CLOCK WAS TURNED ON TO BEGIN COUNTING DOWN TIME 6

#     AT THE QR AXES JET LIST COMPUTATION, THE T6 CLOCK HAS BEEN REDUCED
#     TO 70 MS (120-50) THEREFORE THE FOLLOWING OCCURS ....

#          1) CHANNEL 5 IS LOADED WITH OCTAL 40022 TO TURN ON JETS 2 AND
#              9. ( THIS IS PERFORMED IN THE SECTION CALLED RATE)

#          2) THE BANK IS SWITCHED FROM THE QR BANK TO THE P BANK (WHERE
#              THE JET LIST IS STORED) AS FOLLOWS ....

#                     DCA   JTLSTADR

## Page 485
#                     DTCB             ( IN THE QR AXES ONLY)

#          3) THE DESIRED JET ON TIME FOR JET 2 IS COMPARED WITH T6.

#          4) SINCE T6 IS GREATER THAN THE DESIRED JET ON TIME FOR JET 2,
#              T6 IS CHANGED TO 65 MS AND T6NEXT  IS LOADED WITH 5 MS.
#              ( THE DIFFERENCE BETWEEN JET ON TIME AND T6)

#          5) T6NEXTJT IS CHANGED TO OCTAL 40020 , AND THE FORMER CONTENTS
#              OF T6NEXTJT IS PLACED IN T6NEXTJT +1. THIS CAUSES JET 9 TO
#              REMAIN ON AND JET 2 TO BE TURNED OFF WHEN T6 IS DECREMENTED
#              TO ZERO. IT ALSO ASSIGNS THE P AXIS JET CODE TO THE
#              TIME IN T6NEXT.

#          6) THE CONTENTS OF T6NEXT (5MS) IS COMPARED WITH THE
#              DIFFERENCE BETWEEN THE TWO QR AXIS JET ON TIMES. SINCE HERE
#              THE DIFFERENCE IS 7.5 MS WHICH IS GREATER THAN THE CONTENTS
#              OF T6NEXT (5MS), THE ADDITIONAL QR AXIS RUPT OCCURS AFTER
#              THE RUPT STORED IN T6NEXT. THUS 2.5 MS (7.5 - 5) IS STORED
#              IN T6NEXT +1

#          7) T6NEXTJT +2 IS MADE EQUAL TO THE JETS WHICH ARE TO BE ON
#              AFTER THE 75 MS HAS ELAPSED (IN THE CASE HERE IT IS ZERO)

#     THUS FOR THE EXAMPLE CONSIDERED THE JET LIST IS ....

#          JET TIMES               JET CODES
#    TIME6     = 65MS.      T6NEXTJT    = 40020     SIGN IS NEGATIVE TO
#    T6NEXT    =  5 MS.     T6NEXTJT +1 = 00226        INDICATES Q-R AXIS
#    T6NEXT +1 =2.5 MS.     T6NEXTJT +2=, 40000        JETS,POSITIVE TO
#                                                      INDICATE P JETS.
#    CHANNEL 6 = 00024

#    CHANNEL 5 = 00022   SIGN IS LOST ONCE THE JET CODE IS LOADED

# THIS EXAMPLE AND THE CODING SHOULD ALLOW ONE TO UNDERSTAND THE JET LIST.
#   ONE FURTHER COMMENT IS IN ORDER - IF THE JET ON TIMES EXCEED 150 MS,
#   THE JETS ARE TURNED ON AND THE JET LIST IS NOT ENTERED. IN 100 MS
#   A NEW JET ON TIME IS COMPUTED WHICH WILL RESET THE JETS IF NEEDED.
#   WHEN THE JET ON TIME IS LESS THAN 150MS, THE JET LIST IS LOADED AS
#   DISCUSSED ABOVE AND THE TJET COMPUTATION IS SKIPPED NEXT TIME, THAT IS
#   THE AXIS IS NOT REPEATED AGAIN UNTIL 200 MS HAS ELAPSED. THIS INSURES
#   THAT WHEN A NEW JET TIME IS COMPUTED THE JET LIST WILL NOT HAVE
#   A TIME STORED WHICH CORRESPONDS TO THE AXIS JUST COMPLETED.

JTLST           CCS             TIME6                   #  TEST CURRENT STATE OF T6.
                TCF             T6ONNOW                 #  IF T6 IS + THEN CLOCK IS ON.
                TCF             T6OFFNOW                #  IF T6 IS + ZERO THEN T6 MUST BE OFF
                TCF             T6ONNOW                 #    SINCE ALL DINC S LEAD TO MINUS ZERO.
                TC              T6JOB                   # WE ARE IN THE UNIQUE STATE WHICH SAYS
                TCF             JTLST                   #   A T6 INTERRUPT IS WAITING.DO T6 JOB.

## Page 486
T6OFFNOW        CA              TOFJTCHG
                TS              TIME6                   # WE ARE HERE IF T6 CLOCK IS OFF.
                CA              BIT15
                EXTEND                                  # TURN CLOCK PULSE FOR T6 ON AND LOAD T6.
                WOR             13
                CA              JTSATCHG
                TS              T6NEXTJT
                CA              ZERO
                XCH             ADDTLT6                 # SET UP NEXT T6 INTERRUPT AFTER THE
                TS              T6NEXT                  #   CURRENT ONE IS COMPLETE. ADDTLT6 MAY
                CA              ZERO                    #   BE ZERO IN WHICH CASE NO MORE T6.
                XCH             ADDT6JTS
                TS              T6NEXTJT        +1
                TCF             RESUME

T6ONNOW         CCS             T6NEXT                  # HERE IF T6 IS NOW ON. SEE IF T6NEXT IS
                TCF             T6NXT=+                 #   ZERO OR NOT.
                CS              TOFJTCHG                # T6NEXT IS NEVER NEGATIVE.
                AD              TIME6                   # A CONTAINS T6 - TJET.
                CCS             A                       # TEST SIGN OF A (SAVING THE DIFFERENCE).
                AD              ONE
                TCF             JTSFIRST                # TJET IS LESS THAN T6.
                NOOP                                    # IF DIFFERENCE I SNEGATIVE OR ZERO
                AD              ONE                     #   WE ADD 1 SO ZERO CAN NEVER BE IN LIST.
                TS              T6NEXT
                CA              JTSATCHG
                TS              T6NEXTJT        +1      # BEGIN SETTING UP JETS IN THE JET LIST.
                CA              ZERO
                XCH             ADDTLT6
                TS              T6NEXT          +1
                CA              ZERO
                XCH             ADDT6JTS
                TS              T6NEXTJT        +2
                TCF             RESUME
JTSFIRST        TS              T6NEXT                  # HERE IF TJET IS LESS THAN T6.
                CA              TOFJTCHG
                TS              TIME6                   # SWITCH T6 AND TJET)
                CA              JTSATCHG

                XCH             T6NEXTJT                # BEGIN SWITCHING JET WORDS IN JET LIST.
                TS              T6NEXTJT        +1
                CS              ADDTLT6
                EXTEND
                BZF             RESUME                  # SEE IF AN ADDITIONAL (QR) JET TIME IS
                AD              T6NEXT                  #   REQUIRED.
                CCS             A                       # IF AN ADDITIONAL T6 IS NEEDEN, COMPARE
                AD              ONE                     #   IT WITH THE CONTENTS OF T6NEXT.
                TCF             +11
                NOOP
                AD              ONE
                TS              T6NEXT          +1
                CA              ZERO

## Page 487
                TS              ADDTLT6
                XCH             ADDT6JTS
                TS              T6NEXTJT        +2
                TCF             RESUME
 +11            TS              T6NEXT          +1
                CA              ZERO
                XCH             ADDTLT6
                TS              T6NEXT
                CA              ZERO
                XCH             ADDT6JTS
                XCH             T6NEXTJT        +1
                TS              T6NEXTJT        +2
                TCF             RESUME
T6NXT=+         CS              TOFJTCHG
                AD              TIME6
                AD              T6NEXT
                CCS             A
                AD              ONE
                TCF             +7

                NOOP
                AD              ONE
                TS              T6NEXT          +1
                CA              JTSATCHG
                TS              T6NEXTJT        +2
                TCF             RESUME
 +7             TS              L
                CS              TOFJTCHG
                AD              TIME6
                CCS             A
                AD              ONE
                TCF             JTSB4T6
                NOOP
                AD              ONE
                TS              T6NEXT
                CA              L
                TS              T6NEXT          +1
                CA              JTSATCHG
                TCF             +7
JTSB4T6         XCH             T6NEXT
                TS              T6NEXT          +1
                CA              TOFJTCHG
                TS              TIME6

                CA              JTSATCHG
                XCH             T6NEXTJT
 +7             XCH             T6NEXTJT        +1
                XCH             T6NEXTJT        +2
                TCF             RESUME
# T-JET LAW FIXED CONSTANTS

RATEMAX+        DEC             0.94222

## Page 488
RATEMAX         DEC             0.88889
RATEMAX2        DEC             0.79012

-35AT16         DEC             -0.00219
-5DEG+1         DEC             -.02772                 # -5 DEGREES + CCSBIT SCALED AT PI RADIANS
38.7AT16        DEC             0.00242
TMINAT16        DEC             0.00047
PTJMINT6        DEC             0.00073
.1DPS           DEC             0.00222
+1.5CSP         DEC             +0.01465
MCOMPT          DEC             -0.00049                # -5MS. SCALED AS T6 (P-AXIS COMP TIME).
14-TJMIN        DEC             11
NEGCSP1         DEC             -.00977
MS30P           OCTAL           37775
0.88975         DEC             0.88975
16/25           DEC             0.64000
-DRATEDB        OCTAL           77555                   # -0.4 DEG/SEC SCALED AT PI/4 RADIANS/SEC
-D2JTLIM        OCTAL           77001                   # -1.4 DEG/SEC SCALED AT PI/4
-A2JTLIM        OCTAL           76447                   # -2.0 DEG/SEC SCALED AT PI/4
-ARATEDB        OCTAL           77223                   # -1.0 DEG/SEC SCALED AT PI/4
25/32           DEC             .78125
-TJMINT6        OCTAL           77762                   # -(7.5 MS + 1 BIT) SCALED AS TIME6 CLOCK
DAPLOW6         OCT             00077
BITS8,9         OCTAL           00600
UPM             DEC             -.2                     # TEMPORARY ESTIMATE
CSPAT1P         DEC             0.10000                 # 100 MS AT 1.

PSKIPADR        GENADR          SKIPPAXS
JETLWADR        CADR            TJETLAW



SETIDLE         LXCH            BANKRUPT                # FIRST T5RUPT AFTER FRESH START COMES
                CAF             IDLERADR                # HERE, DAPIDLER IS STARTED IN 1 SECOND.
                TS              T5ADR
                CAF             1SECRUPT
                TS              TIME5
                CAF             WIDEDB
                TS              DB
                TCF             NOQRSM

1SECRUPT        OCTAL           37634                   # 1 SECOND SCALED AS TIME5 (100 PULSES)

# DUMMY FILTER RUPT AFTER P-AXIS RUPT.
                EBANK=          AOSQTERM
DUMMYFIL        CAF             TWENTYMS                # RESET TIMER IMEDIATELY.  DT=20 MS
                TS              TIME5
                LXCH            BANKRUPT                # INTERRUPT LEAD-IN (CONTINUED).

                EXTEND                                  # SET UP QRAXIS RUPT.

                DCA             DFQRAXIS
                DXCH            T5ADR

## Page 489
# INCREMENT AOSTERM IN DESCENT MODE TO IMPROVE RATE DERIVATION DURING QRAXIS CONTROL.

                CAF             BIT2                    # STAGE BIT IS ONE FOR DESCENT.
                EXTEND
                RAND            30                      # READ STAGE BIT
                EXTEND
                BZF             NOQRSM                  # NOT IN DESCENT MODE.     RESUME.


                CAF             BIT14                   # IS THE ENGINE OFF BIT SET.
                EXTEND
                RAND            11                      # READ ENGINE OFF BIT.
                EXTEND
                BZF             DLOOPBGN                # ZERO WHEN ENGINE IS NOT OFF.

                CAF             ZERO                    # YES.  ENGINE IS OFF.
                TS              AOSQTERM
                TS              AOSRTERM
                TCF             NOQRSM                  # RESUME.
DLOOPBGN        CAF             BIT1                    # FIRST THE R-AXIS, THEN THE Q-AXIS.
DLOOP           TS              ITEMP1
                DOUBLE
                TS              ITEMP2
                INDEX           ITEMP1
                CA              PITCHBTS
                EXTEND
                RAND            12                      # IS PITCH(ROLL) GIMBAL MOVING.
                EXTEND
                BZF             DLOOPCHK                # ZERO WHEN GIMBAL IS NOT MOVING.

# FORM ACCDOT*CSP(2)*(1-.5*K) SCALED AT PI/4.  THIS IS THE INCREMENT TO BE ADDED TO THE OFFSET ACCELERATION TERM.

                CAE             (1-K)                   # (1-K)   IS SCALED AT 1.
                EXTEND
                MP              BIT9                    # .5*(1-K) , SCALED AT 2(5).
                AD              BIT9                    # (1.-.5*K) SCALED AT 2(5).
                EXTEND
                MP              CSPSQ                   # CSP(2)*(1.-.5*K) AT 2(5)
                EXTEND
                INDEX           ITEMP2                  # SELECT THE AXIS .
                MP              QACCDOT                 # QACCDOT AT PI/2(7).
                INDEX           ITEMP1
                ADS             AOSQTERM                # ADD INCREMENT SCALED AT PI/4.
DLOOPCHK        CCS             ITEMP1
                TCF             DLOOP                   # R-AXIS DONE.  NOW DO THE Q-AXIS.
                TCF             NOQRSM                  # RESUME.
PITCHBTS        OCT             01400                   # PITCH GIMBAL BITS  (9,10).
                OCT             06000                   # ROLL GIMBAL BITS,  (11,12).
CSPSQ           OCT             00243                   # .01 SCALED AT 1, FOR CSP(2).
TWENTYMS        OCT             37776                   # 20 MS FOR T5.
                EBANK=          QERROR

## Page 490
DFQRAXIS        2CADR           QRAXIS
