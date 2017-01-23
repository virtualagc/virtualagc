### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     P-AXIS_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        542-556
## Mod history:  2016-09-20 JL   Created.
##               2016-10-02 MAS  Began.
##               2016-10-03 MAS  Completed.
##               2016-10-04 HG   add missed instruction TS TOFJTCHG
##                               comment code look alike
##                               JSATCHG -> JTSATCHG
##               2016-10-15 HG   Fix operand BITS13-14 -> BIT13-14
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 and fixed the errors found.

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

## Page 542
                BANK            23
                EBANK=          DT

# THE FOLLOWING SECTION DRIVES THE ATTITUDE ERROR NEEDLES IN THE "EIGHT-BALL" DISPLAY:

EIGHTBAL        LXCH            DAPBOOLS                        # ATTITUDE ERRORS DISPLAYED EVERY
                CAF             BIT7                            # OTHER DAP CYCLE (.2 SECS)
                EXTEND                                          # CHANGE STATE OF FLAG
                RXOR            L
                TS              DAPBOOLS                        # FLAG WORD RESTORE
                MASK            BIT7
                EXTEND                                          # ZERO AS NEW STATE MEANS
                BZF             PAXFILT                         # NO DISPLAY THIS CYCLE

ATERDSPY        CAF             TWO                             # INIT. INDEX WORD
                TS              ITEMP1
                INDEX           A
## The above two instructions have a line drawn by them, with handwritten notes "CA   TS T5M".
                CCS             PERROR                          # LOOK AT CURRENT ATT ERROR
                TCF             ERLIMCHK                        # HAVE E VALUE GET MAGNITUDE
                TCF             ZERR                            # ZERO VALUE
                TCF             ERLIMCHK                        # GET MAGNITUDE
ZERR            INDEX           ITEMP1
                CS              PERROR
                INDEX           ITEMP1
                XCH             LASTPER                         # SAVE CURRENT E, LOAD LAST E (NEG)
                INDEX           ITEMP1
                AD              PERROR                          # GET DIFF E(N-2) - E(N)
## "INDEX ITEMP1" and "PERROR" above are crossed out. Next to them the word "TEMP" is written in.
                EXTEND
                MP              BIT13                           # SHIFT RIGHT 2
                INDEX           ITEMP1
                TS              CDUXCMD                         # STORE CMD E VALUE
                CCS             ITEMP1
                TCF             ATERDSPY        +1              # GET NEXT E

                CA              OCT70000                        # ICDU DRIVE BITS 13,14,15
                EXTEND
                WOR             14                              # DRIVE AWAY
                TCF             PAXFILT                         # ATT ERROR DISPLAY DONE FOR THIS CYCLE
## The above four instructions are circled. "OCT70000" is scratched out, and "BIT16" is written by it.
## "14" is also crossed out, with "12" written by it. 14, however, was the correct channel, so why
## it's crossed out like this is a mystery.

ERLIMCHK        AD              BIT1                            # HAVE MAG OF E, SEE IF GREATER THAN
                COM                                             #   5 DEGREES
                AD              5DEGS
## The above three instructions are circled, and "AD-5+1" is written by them
                EXTEND
                BZMF            BIGATER                         # ERROR GREATER THAN 5 DEGS, DSPY 5 DEGS
                TCF             ZERR                            # E LESS THAN 5 DEGS, NORMAL PROCED
## "BIGATER" and "TCF ZERR" above are circled, with "ZERR" written next to them.

BIGATER         INDEX           ITEMP1
## The above instruction is circled.
                CCS             PERROR                          # GET SIGN OF BIG ERROR
                CA              5DEGS
                TCF             +2                              # CANT BE ZERO HERE
## Page 543
                CS              5DEGS
                INDEX           ITEMP1
                TS              PERROR                          # SET BIG ERROR TO 5DEGS
                TCF             ZERR

# END OF ATTITUDE ERROR NEEDLE DRIVER.  (SHOULD GO IN-LINE SOMETIME.)


# THE FOLLOWING T5RUPT ENTRY BEGINS THE PROGRAM WHICH CONTROLS THE P-AXIS ACTION OF THE LEM USING THE RCS JETS.
# THE NOMINAL TIME BETWEEN THE P-AXIS RUPTS IS 100 MS IN ALL NON-IDLING MODES OF THE DAP.

PAXIS           CAF             MS30P                           # RESET TIMER IMMEDIATELY: DT = 30 MS
                TS              TIME5

                LXCH            BANKRUPT                        # INTERRUPT LEAD IN (CONTINUED)
                EXTEND                                          
                QXCH            QRUPT                           

# CHECK TO SEE IF DAP IS STILL IN USE:

                EXTEND                                          # IF BOTH BITS 13 AND 14 OF CHANNEL 31 ARE
                READ            31                              # EQUAL TO 1, THEN THE SCS MODE SWITCH IS
                COM                                             # IN THE OFF POSITION.  ACTUALLY, THE TEST
                MASK            BIT13-14                        # IS MADE ON BOTH THE ATTITUDE HOLD AND
                EXTEND                                          # AUTOMATIC MODE BITS.
                BZF             GOIDLE

# WHILE DAP IS ON, SET UP EITHER A KALMAN FILTER RUPT OR A DUMMY FILTER RUPT BY SETTING UP T5ADR FROM ERASABLE.

                EXTEND                                          # T5ADR IS SET TO EITHER FILTER OR
                DCA             PFILTADR                        # DUMMYFIL IN A BLIND MANNER SINCE
                DXCH            T5ADR                           # PFILTADR IS SET UP ELSEWHERE

# DO P AXIS RATE DERIVATION AND CONTROL LAW.
# DERIVE DELTA P.

FILT/PAX        CAE             CDUX
                TS              L
                EXTEND
                MSU             OLDXFORP                        # SCALED AT PI
                LXCH            OLDXFORP
                EXTEND
                MP              BIT7
                LXCH            DELTAP                          # SCALE AT PI/2(6)
                CA              CDUY
                TS              L
                EXTEND
                MSU             OLDYFORP                        # SCALED AT PI
                LXCH            OLDYFORP
## Page 544
                EXTEND
                MP              BIT7                            # INTO L SCALED AT PI/2(6)
                CA              M11                             # M11 SCALED AT 1
                EXTEND
                MP              L                               # INTO A SCALED AT PI/2(6).
                AD              DELTAP
                EXTEND
                MP              WFORP                           # SCALED AT 2(4)=16, RESULT IN A AT PI/4.
                XCH             OMEGAP                          # W*DELTAP IN OMEGAP LOC. OLD OMEGAP IN A.
                EXTEND
                MP              ONE-K                           # SCALED AT 1.
## "ONE-K" is circled on the above line in red.
                AD              JETRATE                         # RATE DUE TO JETS TORQUING.
                ADS             OMEGAP                          # PRATE= WFORP*DELTAP+ALPHA*LAST-PRATE+TPF
                TC              T6JOBCHK                        # T6JOBCHK IS IN FIXED-FIXED

# ***** KALCMANU-DAP AND "RATE-HOLD"-DAP INTERFACE *****

# THE FOLLOWING SECTION IS EXECUTED EVERY 100 MS (10 TIMES A SECOND) WITHIN THE P-AXIS REACTION CONTROL SYSTEM
# AUTOPILOT (WHENEVER THE DAP IS IN OPERATION).

                CAF             TWO                             # SET UP LOOP TO DO Z,Y,X CDU AXES:
KALCLOOP        TS              QRCNTR

                INDEX           QRCNTR                          # KALCMANU AND RATE-HOLD USE THIS SECTION
                CAE             CDUXD                           # TO PERFORM THEIR INDEPENDENT FUNCTIONS:
                EXTEND                                          # BOTH PROCEDURES SET UP THE DELCUD'S
                INDEX           QRCNTR                          # TO HAVE THE NEGATIVE VALUE OF THE
                MSU             DELCDUX                         # DESIRED CDU CHANGE FOR EACH 100 MS CSP
                CCS             A                               # DURING THE MANEUVER (OR MODE).  EACH IS
                AD              ONE                             # STORED AT PI RADIANS IN 2'S COMPLEMENT.
                TCF             +2                              # SINCE THE MODULAR SUBTRACT YIELDS THE
                COM                                             # NEW CDUD VALUE IN 1'S COMPLEMENT, THE
                INDEX           QRCNTR                          # CCS SECTION IS NEEDED FOR 1'S TO 2'S
                TS              CDUXD                           # CONVERSION OF DESIRED CDU ANGLES.

                CCS             QRCNTR                          # (THIS MAKES THE LOOP DO ALL THREE AXES
                TCF             KALCLOOP                        # IN THE ORDER Z, Y, X.)


                TCF             EIGHTBAL

PAXFILT         TC              PJUMPADR
SKIPPAXS        CA              VISFZADR
                TS              PJUMPADR
                CA              ZERO
                TS              JETRATE
                CA              TP
                AD              NEGCSP1
                CCS             A
## Page 545
                TC              PTORQUE
                TCF             RESUME
                TC              PTORQUE
                CS              JETRATE
                ADS             OMEGAP
                CA              ZERO
                TS              JETRATE
                TCF             RESUME
(1-K)/8P        OCTAL           20000
## The above line is crossed out in red.
PTORQUE         AD              ONE
                EXTEND
                MP              BIT5
                CA              L
                EXTEND
                MP              16/25
                TS              TP
                CA              WFORP
## There is an "E" written in red after "CA" above, indicating that it should be changed to "CAE".
                AD              (1-K)/8P
## The "P" in "(1-K)/8P" is circled.
                EXTEND
                MP              TP
                EXTEND
                MP              BIT4
                CA              1JACC
                EXTEND
                MP              L
                EXTEND
                MP              NO.PJETS
                LXCH            JETRATE
                TC              Q
CHKVISFZ        CAF             BIT9                            # VISIBILITY PHASE BIT
                MASK            DAPBOOLS
                EXTEND
                BZF             +2
                TCF             PURGENCY                        # ATTITUDE STEER DURING VISIBILITY PHASE

                CAF             BIT10                           # BIT10=1 FOR RHC MINIMUM IMPULSE MODE
                MASK            DAPBOOLS
                EXTEND
                BZF             DETENTCK                        # BRANCH FOR RATE COMMAND

                CAE             DELAYCTR                        # SET BY RUPT10 TO TWO
                EXTEND
                BZF             BITSGONE                        # CHECK FOR ALL SWITCHES OPEN

                CS              -TJMINT6
                TS              TOFJTCHG

                TS              TP                              # FOR RATE DERIVATION
                CA              BIT3
                EXTEND
## Page 546
                RAND            31
                EXTEND
                BZF             +MINIMP

                CA              BIT4
                EXTEND
                RAND            31
                EXTEND
                BZF             -MINIMP

                CCS             DELAYCTR                        # DELAYCTR ALWAYS PNZ HERE
                TS              DELAYCTR
                EXTEND
                BZF             PLETRUPT
                TCF             JETSOFF

+MINIMP         CAF             BIT1
                TCF             +2
-MINIMP         CS              BIT1
 +2             TS              TPSIG
                CAF             ZERO
                TS              DELAYCTR
                TCF             2PJETS

BITSGONE        EXTEND                                          # ARE SWITCHES ALL OPEN
                READ            31
                COM
                MASK            DAPLOW6
                EXTEND
                BZF             +2
                TCF             JETSOFF
                
                CAF             BIT4                            # BIT4 OF DAPBOOLS ZERO IF PREVIOUS
                MASK            DAPBOOLS                        # READING OF 31 FOUND ALL SWITCHES OPEN
                EXTEND
                BZF             PLETRUPT

                CS              BIT4
                MASK            DAPBOOLS
                TS              DAPBOOLS
                TCF             JETSOFF

PLETRUPT        CAF             BIT4
                ADS             DAPBOOLS
                CAF             BIT12
                EXTEND
                WOR             13
                TCF             JETSOFF
DETENTCK        CA              BIT15
                EXTEND
## Page 547
                RAND            31                              # CHECK OUT-OF-DETENT BIT.INVERTED.
                EXTEND
                BZF             RHCMOVED                        # BRANCH IF OUT OF DETENT
# ........................................................................ 
                CAF             BIT1                            # IN DETENT.CHECK THE RATE COMMAND BIT
                MASK            DAPBOOLS                        # BIT1 OF DAPBOOLS IS RATE COMMAND BIT
                EXTEND                                          
                BZF             PURGENCY                        # BRANCH IF NOT IN RATE COMMAND
# ........................................................................ 
                CAF             BIT13                           # CHECK ATTITUDE HOLD BIT
                EXTEND
                RAND            31
                EXTEND
                BZF             JOEY                            # BRANCH IF IN ATTITUDE HOLD
# ........................................................................ 
                CCS             OMEGAP                          # HERE IF IN Y-AXIS OVER-RIDE
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

RHCMOVED        CAF             BIT1                            # CHECKING THE RATE COMMAND BIT
                MASK            DAPBOOLS                        
                EXTEND                                          
                BZF             JUSTOUT

# READ,ZERO, AND ENABLE COUNTERS
# SYSTEM HAS BEEN IN RATE COMMAND FOR AT LEAST THE TIME OF A CAP CHARGE

                CAE             P-RHCCTR                        # 1 BIT IN P-RHCCTR WORTH 0.6256 DEG/SEC
                EXTEND
## Page 548
                MP              BIT9
                CA              L
                EXTEND
                MP              0.88975
                TS              PRATECOM                        # COMMANDED RATE SCALED AT PI/4

                CAF             ZERO                            # ZERO COUNTERS
                TS              P-RHCCTR
                TS              Q-RHCCTR
                TS              R-RHCCTR
                CA              BITS8,9                         # ENABALE COUNTERS, START READING
                EXTEND
                WOR             13
                TCF             OBEYRATE
# ........................................................................ 
JUSTOUT         INCR            DAPBOOLS                        # ALWAYS SETS BIT1 ON RATE COMMAND BIT
                CAF             BIT2
                EXTEND
                RAND            30
                EXTEND
                BZF             +5                              # BRANCH FOR ASCENT CONSTANTS

                CAF             -D2JTLIM                        # -1.4 DEG/SEC SCALED AT PI/4
                TS              -2JETLIM
                CAF             -DRATEDB                        # -0.4 DEG/SEC SCALED AT PI/4
                TCF             +4

 +5             CAF             -A2JTLIM                        # -2.0 DEG/SEC SCALED AT PI/4
                TS              -2JETLIM
                CAF             -ARATEDB                        # -1.0 DEG/SEC SCALED AT PI/4
 +4             TS              -RATEDB

                CAF             ZERO                            # ZERO COUNTERS
                TS              P-RHCCTR
                TS              Q-RHCCTR
                TS              R-RHCCTR
                CA              BITS8,9
                EXTEND
                WOR             13
                TCF             JETSOFF
# ........................................................................ 
JOEY            CAF             ZERO
                TS              PRATECOM

# IN THIS SECTION P RATE ERROR IS COMPUTED AND T-JET IS CALCULATED

OBEYRATE        CS              OMEGAP
                AD              PRATECOM
                TS              TPSIG                           # SIGN STORAGE TO TELL DIRECTION OF ROT.
OBEYRAPE        CCS             A                               # GET ABVAL OF RATE P-ERROR
## Page 549
                TCF             +4
                TCF             JETSOFF
                TCF             +2
                TCF             JETSOFF
                AD              BIT1
                TS              PRATEDIF                        # ABVAL OF RATE ERROR SCALED AT PI/4

                TC              T6JOBCHK                        # T6JOBCHK IS IN FIXED-FIXED

                CA              -RATEDB
                AD              PRATEDIF
                EXTEND
                BZMF            JETSOFF                         # RATE ERROR INSIDE DEADBAND

                CS              PRATEDIF
                EXTEND
                SU              -2JETLIM
                EXTEND
                BZMF            RCM4JETS

                CA              PRATEDIF                        # 2 JETS ENOUGH.COMPUTE TJET
                EXTEND
                MP              1/2JTSP                         # 1/2JTACC SCALED AT 2EXP(8)/PI
                EXTEND
                MP              BIT4
                CA              L
                EXTEND
                MP              25/32                           # A CONTAINS TJET SCALED AT 2EXP(4)(16/25)
                TS              TP

# ........................................................................ 
# CHECK RATE COMMAND ON TIME AGAINST MINIMUM IMPULSE
                TS              TOFJTCHG
                AD              -TJMINT6
                EXTEND                                          #   AS TP. TEST JET TIME. IS IT GREATER OR
                BZMF            JETSOFF                         # LESS THAN A MINIMUM IMPULSE
# ........................................................................ 
#              2-JET JET SELECT LOGIC
# READ CHANNEL 6 TO SEE WHAT THE CURRENT STATE OF THE P JETS IS AND
#     CORRECT THE JET TIME FOR THE PROPER AMOUNT OF TIME .
2PJETS          EXTEND                                          # WHAT IS THE CURRENT STATE OF THE P JETS.
                READ            6
                EXTEND
                BZF             PJETSNOT
                CA              MCOMPT                          # - COMPUTATION TIME FOR THE PAXIS
                ADS             TOFJTCHG                        # ALTER JET OFF TIME PER STATE OF CH 6.
                TCF             TESTSIGN
PJETSNOT        CA              14-TJMIN                        # TOTAL DELAY FOR A MIN IMP TO FULL ON.
                ADS             TOFJTCHG                        # ALTER JET OFF TIME PER STATE OF CH 6.
# ........................................................................ 
## Page 550
# SET UP THE ALTERNATING P SELECT BIT IN DAPBOOLS.
ALTPSELT        CA              BIT5                            # COMPLEMENT BIT5 OF DAPBOOLS
                LXCH            DAPBOOLS
                EXTEND
                RXOR            L
                TS              DAPBOOLS
TESTSIGN        CCS             TPSIG
                CA              BIT5
                TCF             +2
                TCF             NEGTP

                MASK            DAPBOOLS                        # IN THE DAP BOOLS WORD.
                EXTEND
                BZF             ALTPOS1
ALTPOS2         CA              POSPJET1
                TC              WRITEJTS        +2
                CA              BIT9                            #   NOW. ZERO AT CHG.(WRITE LOW8 IN CH.6).
                TS              JTSATCHG                        # STATE OF P AXIS JETS AFTER THE T6 RUPT.
                TCF             P+2JET
ALTPOS1         CA              POSPJET0
                TC              WRITEJTS        +2
                CA              BIT9                            #   NOW. ZERO AT CHG.(WRITE LOW8 IN CH.6).
                TS              JTSATCHG                        # JTSONNOW CONTAINS BITS WRITTEN INTO CH 6
                TCF             P+2JET
# ........................................................................ 
# TEST DAPBOOLS TO DETERMINE WHICH JET PAIR TO USE FOR P AXIS ROTATION.
NEGTP           CA              BIT5
                MASK            DAPBOOLS                        # IN THE DAP BOOLS WORD.
                EXTEND
                BZF             ALTNEG1
ALTNEG2         CA              NEGPJET1
                TC              WRITEJTS        +2
                CA              BIT9                            #   NOW. ZERO AT CHG.(WRITE LOW8 IN CH.6).
                TS              JTSATCHG                        # STATE OF P AXIS JETS AFTER THE T6 RUPT.
                TCF             P-2JET
ALTNEG1         CA              NEGPJET0
                TC              WRITEJTS        +2
                CA              BIT9                            #   NOW. ZERO AT CHG.(WRITE LOW8 IN CH.6).
                TS              JTSATCHG                        # STATE OF P AXIS JETS AFTER THE T6 RUPT.
                TCF             P-2JET
RCM4JETS        CA              PRATEDIF
                EXTEND
                MP              1/2JTSP
                EXTEND
                MP              BIT3
                CA              L
                EXTEND
                MP              25/32                           # A NOW CONTAINS TJET SCALED AT 2EXP(4)(16
                TS              TP                              # /25).

## Page 551
# ........................................................................ 
# IN THIS SECTION DO THE P AXIS  JET SELECT LOGIC FOR 4 JETS
4PJETS          TS              TOFJTCHG                        # TOFJTCHG WILL BE MODIFIED AND WILL = T6.
                CS              TPSIG
                EXTEND
                BZMF            POS4P
                EXTEND
                READ            6
                EXTEND
                BZF             +4
                CA              MCOMPT
                ADS             TOFJTCHG                        # ALTER JET OFF TIME PER STATE OF CH 6.
                TCF             +3
 +4             CAF             14-TJMIN
                ADS             TOFJTCHG                        # ALTER JET OFF TIME PER STATE OF CH 6.
                CA              4NEGPJET
                TC              WRITEJTS        +2
                CA              BIT9                            # THE LOW 8 BITS ONLY GET WRITTEN INTO CH.
                TS              JTSATCHG                        # STATE OF P AXIS JETS AFTER THE T6 RUPT.
                CS              FOUR
                TCF             RATE
POS4P           EXTEND
                READ            6
                EXTEND
                BZF             +4
                CA              MCOMPT
                ADS             TOFJTCHG                        # ALTER JET OFF TIME PER STATE OF CH 6.
                TCF             +3
 +4             CA              14-TJMIN                        # TOTAL DELAY FOR A MIN IMP TO FULL ON.
                ADS             TOFJTCHG                        # ALTER JET OFF TIME PER STATE OF CH 6.
                CA              4POSPJET
                TC              WRITEJTS        +2
                CA              BIT9                            #   NOW. ZERO AT CHG.(WRITE LOW8 IN CH.6).
                TS              JTSATCHG                        # STATE OF P AXIS JETS AFTER THE T6 RUPT.
                CA              FOUR
                TCF             RATE
JETSOFF         CAF             ZERO
                TS              JETRATE
                TS              TOFJTCHG
                TC              WRITEJTS        +2
                TCF             RESUME
# P-AXIS URGENCY FUNCTION CALCULATION

# (NOTE -- M13 = 1 IDENTICALLY IMPLIES NULL MULITPLICATION.)

PURGENCY        CA              CDUY                            # P-ERROR CALCULATION
                EXTEND
                MSU             CDUYD                           # CDU VALUE - ANGLE DESIRED (Y-AXIS)
                EXTEND
                MP              M11                             # (CDUY-CDUYD)M11 SCALED AT PI RADIANS
## Page 552
                XCH             E                               # SAVE FIRST TERM (OF TWO)
                CA              CDUX                            # THIRD COMPONENT
                EXTEND
                MSU             CDUXD                           # CDU VALUE - ANGLE DESIRED (X-AXIS)
#               EXTEND
#               MP              M13
                ADS             E                               # SAVE SUM OF TERMS, NO OVERFLOW EVR

                TS              PERROR                          # SAVE P ERR FOR DISPLAY
                CAE             1/2JTSP                         # SET-UP FOR URGENCY SUBROUTINE
                TS              1/NJETAC

                TC              T6JOBCHK                        # CHECK T6 CLOCK HERE, BEFORE URGROUTN

                CS              OMEGAPD
                AD              OMEGAP
                TS              EDOTP
                TC              IBNKCALL                        # *** SUBROUTINE CALL *** (TAKES 24 MCTS)
                CADR            URGROUTN                        # (RETURN TAKES 10 MCTS)
                
                EXTEND                                          # IF URGENCY = 0, FIRE NO JETS
                BZF             JETSOFF                         # (FOR EFFICIENCY ONLY)

                CCS             A                               # URGENCY FUNCTION IS IN A, GET ABVAL
                AD              UPM
                TCF             +2
                AD              UPM
                EXTEND
                BZMF            2JETSP
                CA              POSMAX
                TS              NJET                            # INDICATE 4 JETS
                CA              1/2JTSP
                EXTEND
                MP              BIT14                           # USE 1/4JETSP
                TS              1/NJETAC
                TCF             T-JETLAW
## The above 23 instructions (everything from "CAE 1/2JTSP" down to here) have a box drawn around them
## in red. Between comments on the write is written in "Dick Gran says: Use no urg. fcn. on PAXIS, use
## TJETLAW only! 1. How do we determine direction? 2. How do we use TPSIG?".

2JETSP          CS              POSMAX
                TS              NJET                            # INDICATE 2 JETS
T-JETLAW        TC              T6JOBCHK                        # CHECK T6 CLOCK RUPT BEFORE SUBROUTINE

                CAF             JETLWADR                        # TJETLAW CALLING SEQUENCE
                TC              ISWCALL
                TCF             JETSOFF
                TS              TP

                CCS             NJET
                CA              TP
                TCF             4PJETS
                CA              TP
## Page 553
                TS              TOFJTCHG
                TCF             2PJETS

# TORQUE VECTOR RECONSTRUCTION FOR THE P-AXIS

P+2JET          CA              TWO
                TCF             RATE
P-2JET          CS              TWO
RATE            TS              NO.PJETS                        # STORE NO. OF P JETS FOR USE LATER.
                CA              100MSPTQ                        # TORQUE FROM A 100 MS JET PULSE SET BY
                EXTEND                                          #   AOS TASK EVERY 2 SECONDS.
## The above two lines of comments have a box drawn around them in red.
                MP              1JACC
                EXTEND
                MP              NO.PJETS
                LXCH            JETRATE                         # STORE JET RATE FOR OMEGAP COMPUTATION.
                CS              TOFJTCHG
                AD              +1.5CSP                         # USE 150 MS. TO TEST FOR A PAXIS SKIP.
                EXTEND
                BZMF            RESUME                          # TP GREATER THAN 150MS THEN DO NORMAL P.
                CA              PSKIPADR                        # SET UP A P AXIS SKIP.
                TS              PJUMPADR
JTLST           CCS             TIME6                           #  TEST CURRENT STATE OF T6.
                TCF             T6ONNOW                         #  IF T6 IS + THEN CLOCK IS ON.
                TCF             T6OFFNOW                        #  IF T6 IS + ZERO THEN T6 MUST BE OFF
                TCF             T6ONNOW                         #    SINCE ALL DINC S LEAD TO MINUS ZERO.
                TC              T6JOB                           # WE ARE IN THE UNIQUE STATE WHICH SAYS
                TCF             JTLST                           #   A T6 INTERRUPT IS WAITING.DO T6 JOB.
T6OFFNOW        CA              TOFJTCHG
                TS              TIME6                           # WE ARE HERE IF T6 CLOCK IS OFF.
                CA              BIT15
                EXTEND                                          # TURN CLOCK PULSE FOR T6 ON AND LOAD T6.
                WOR             13
                CA              JTSATCHG
                TS              T6NEXTJT
                CA              ZERO
                XCH             ADDTLT6                         # SET UP NEXT T6 INTERRUPT AFTER THE
                TS              T6NEXT                          #   CURRENT ONE IS COMPLETE. ADDTLT6 MAY

                CA              ZERO                            #   BE ZERO IN WHICH CASE NO MORE T6.
                XCH             ADDT6JTS
                TS              T6NEXTJT        +1
                TCF             RESUME
T6ONNOW         CCS             T6NEXT                          # HERE IF T6 IS NOW ON. SEE IF T6NEXT IS
                TCF             T6NXT=+                         #   ZERO OR NOT.
                CS              TOFJTCHG                        # T6NEXT IS NEVER NEGATIVE.
                AD              TIME6                           # A CONTAINS T6 - TJET.
                CCS             A                               # TEST SIGN OF A (SAVING THE DIFFERENCE).
                AD              ONE
                TCF             JTSFIRST                        # TJET IS LESS THAN T6.
                NOOP                                            # IF DIFFERENCE I SNEGATIVE OR ZERO
## Page 554
                AD              ONE                             #   WE ADD 1 SO ZERO CAN NEVER BE IN LIST.
                TS              T6NEXT
                CA              JTSATCHG
                TS              T6NEXTJT        +1              # BEGIN SETTING UP JETS IN THE JET LIST.
                CA              ZERO
                XCH             ADDTLT6
                TS              T6NEXT          +1
                CA              ZERO
                XCH             ADDT6JTS
                TS              T6NEXTJT        +2
                TCF             RESUME
JTSFIRST        TS              T6NEXT                          # HERE IF TJET IS LESS THAN T6.
                CA              TOFJTCHG
                TS              TIME6                           # SWITCH T6 AND TJET)
                CA              JTSATCHG
                XCH             T6NEXTJT                        # BEGIN SWITCHING JET WORDS IN JET LIST.
                TS              T6NEXTJT        +1
                CS              ADDTLT6
                EXTEND
                BZF             RESUME                          # SEE IF AN ADDITIONAL (QR) JET TIME IS
                AD              T6NEXT                          #   REQUIRED.
## There is a line here saying "*      DELETE THROUGH 04993", indicating a change from the last revision.
                CCS             A                               # IF AN ADDITIONAL T6 IS NEEDEN, COMPARE
                AD              ONE                             #   IT WITH THE CONTENTS OF T6NEXT.
                TCF             +11
                NOOP
                AD              ONE
                TS              T6NEXT          +1
                CA              ZERO
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
## Page 555
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

+1.5CSP         DEC             +0.01465
ONE-K           DEC             0.50000
MCOMPT          DEC             -0.00049                        # -5 MS. SCALED AS T6 (P-AXIS COMP TIME).
14-TJMIN        DEC             11
NEGCSP1         DEC             -.00977
MS30P           OCTAL           37775
0.88975         DEC             0.88975
16/25           DEC             0.64000
-DRATEDB        OCTAL           77555                           # -0.4 DEG/SEC SCALED AT PI/4 RADIANS/SEC
-D2JTLIM        OCTAL           77001                           # -1.4 DEG/SEC SCALED AT PI/4
-A2JTLIM        OCTAL           76447                           # -2.0 DEG/SEC SCALED AT PI/4
-ARATEDB        OCTAL           77223                           # -1.0 DEG/SEC SCALED AT PI/4
25/32           DEC             .78125
-TJMINT6        DEC             -.00073
DAPLOW6         OCT             00077
4POSPJET        OCTAL           125
4NEGPJET        OCTAL           252
NEGPJET0        OCTAL           12
NEGPJET1        OCTAL           240
POSPJET0        OCTAL           120
POSPJET1        EQUALS          FIVE
BITS8,9         OCTAL           00600
## Page 556
UPM             DEC             -.2                             # TEMPORARY ESTIMATE
PSKIPADR        GENADR          SKIPPAXS
JETLWADR        CADR            TJETLAW



SETIDLE         LXCH            BANKRUPT                        # FIRST T5RUPT AFTER FRESH START COMES
                CAF             IDLERADR                        # HERE, DAPIDLER IS STARTED IN 1 SECOND.
                TS              T5ADR
                CAF             1SECRUPT
                TS              TIME5
                TCF             NOQRSM

1SECRUPT        OCTAL           37634                           # 1 SECOND SCALED AS TIME5 (100 PULSES)

GOIDLE          EXTEND                                          # COME HERE TO SHUT DOWN DAP
                DCA             GOIDLADR
                DXCH            T5ADR                           # SET UP RUPT TO GO IDLE AT DAPIDLER

                CAF             ZERO                            # CLEAR ALL JETS
                EXTEND
                WRITE           5
                EXTEND
                WRITE           6

                CS              BGIM23                          # STOP THE TRIM GIMBAL DRIVES
                EXTEND
                WAND            12

                TCF             RESUME

BGIM23          OCTAL           07400

## Below the address column is the calculation "3635 - 3140 = 475", seemingly calculating 
## words used after the end of this section.
