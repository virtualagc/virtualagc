### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    TRIM_GIMBAL_CNTROL_SYSTEM.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-18 MAS  Began.
##              2016-10-19 MAS  Completed transcription.
##		2016-10-31 RSB	 Typos
##		2016-12-06 RSB	Comment-proofing with octopus/ProoferComments,
##				changes made.

## Page 591
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

GTS             CAF             MS30F                           # RESET TIMER IMMEDIATELY: DT = 30 MS
                TS              TIME5                           

                LXCH            BANKRUPT                        # INTERRUPT LEAD IN (CONTINUED)
                EXTEND                                          
                QXCH            QRUPT                           

                EXTEND                                          
                DCA             POSTPFIL                        
                DXCH            T5ADR                           

                TCF             GTSTEST                         # SKIP OVER XFORMS UNTIL REORGANIZATION

GIMBAL          EXTEND                                          # GET D.P. FILTERED CDUY VALUE (ONES COMP)
                DCA             CDUYFIL                         # SCALED AT 2PI RADIANS
                TC              ONETOTWO                        # FORM S.P. VALUE IN TWOS COMPLEMENT AT PI
                EXTEND                                          
                MSU             CDUYD                           # FORM Y-AXIS ERROR IN ONES COMPLEMENT
                TS              QDIFF                           # (SAVE IN Q-AXIS ERROR LOC: EFFICIENCY)

                EXTEND                                          # GET D.P. FILTERED CDUZ VALUE (ONES COMP)
                DCA             CDUZFIL                         # SCALED AT 2PI RADIANS
                TC              ONETOTWO                        # FORM S.P. VALUE IN TWOS COMPLEMENT AT PI
                EXTEND                                          
                MSU             CDUZD                           # FORM Z-AXIS ERROR IN ONES COMPLEMENT
                TS              RDIFF                           # (SAVE IN R-AXIS ERROR LOC: EFFICIENCY)

# TRANSFORM Y,Z CDU ERRORS TO THE Q,R-AXES.

                EXTEND                                          # GET BOTH Y AND Z CDU ERRORS AT PI RAD
                DCA             QDIFF                           
                TC              QTRANSF                         # FORM Q-ERROR IN A (SCALED AT PI RAD)
                DXCH            QDIFF                           # STORE Q-ERROR, GET BOTH Y,Z CDU ERRORS
                TC              RTRANSF                         # FORM R-ERROR IN A (SCALED AT PI RAD)
                XCH             RDIFF                           # STORE R-ERROR

# TRANSFORM THE FILTERED Y,Z RATES TO THE Q,R-AXES.
# (THESE MAY BE NEEDED FOR THE RATE DERIVATION FOR THE JETS IF THEY MUST BE USED.)

## Page 592
                CAE             DCDUZFIL                        # GET FILTERED Y,Z RATES
                TS              L                               # SCALED AT PI/4 RADIANS/SECOND
                CAE             DCDUYFIL                        
                TC              QTRANSF                         # FOR Q-AXIS RATE
                TS              OMEGAQ                          # STORED SCALED AT PI/4 RADIANS/SECOND

                CAE             DCDUZFIL                        # GET FILTERED Y,Z RATES
                TS              L                               # SCALED AT PI/4 RADIANS/SECOND
                CAE             DCDUYFIL                        
                TC              RTRANSF                         # FOR R-AXIS RATE
                TS              OMEGAR                          # STORED SCALED AT PI/4 RADIANS/SECOND

# TRANSFORM THE FILTERED Y,Z ACCELERATIONS TO THE Q,R-AXES.
# (THESE MAY BE NEEDED TO CALCULATE TRIM GIMBAL OFF-TIMES IF ATTITUDE ERROR HAS GONE BEYOND TRIM GIMBAL CONTROL.)

                CAE             D2CDUZFL                        # GET FILTERED Y,Z ACCELERATIONS
                TS              L                               # SCALED AT PI/8 RADIANS/SECOND(2)
                CAE             D2CDUYFL                        
                TC              QTRANSF                         # FORM Q-AXIS ACCELERATION
                TS              ALPHAQ                          # STORE AT PI/8 RADIANS/SECOND(2)

                CAE             D2CDUZFL                        # GET FILTERED Y,Z ACCELERATIONS
                TS              L                               # SCALED AT PI/8 RADIANS/SECOND(2)
                CAE             D2CDUYFL                        
                TC              RTRANSF                         # FORM R-AXIS ACCELERATION
                TS              ALPHAR                          # STORE AT PI/8 RADIANS/SECOND(2)

# EXTRAPOLATE THETA AND OMEGA OVER 100 MS PLUS THE 20 MS DELAY BETWEEN THE KALMAN FILTER AND TRIM GIMBAL 
#  CONTROL, REFLECTING MECHANICAL LAG.

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

## Page 593
                TCF             RESUME                          

DTW             OCT             00754                           # 120 MS SCALED AT 4
DTA             OCT             01727                           # 120 MS SCALED AT 2
# TEST TO SEE IF TRIM GIMBAL CONTROL LAW HAS KEPT BOTH ATTITUDE ERRORS BELOW THE 1 DEGREE BOUNDARY WITH THE REGION
# OF RCS CONTROL LAW DOMINANCE OR IS STILL REDUCING THE ERROR.

GTSTEST         CAF             TRYGIMBL                        # VERIFY THAT GTS IS STILL OPERATIVE.
                MASK            DAPBOOLS                        
                CCS             A                               
                TCF             RCSCNTRL                        # GTS NOT OPERATIVE
# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

INSERT21        TCF             CHKCNTR                         # GO CHECK TRIMCNTR (AT END OF BANK 21).

# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

LOOPTEST        TS              QRCNTR                          
                INDEX           QRCNTR                          
                CCS             QDIFF                           # SCALED AT PI.
                AD              -TGBND+1                        # -2 DEG SCALED AT PI, + 1 BIT.
                TCF             +2                              
                AD              -TGBND+1                        
                EXTEND                                          
                BZMF            +2                              # IS ERROR MAG LESS,EQUAL 2 DEG.
                TCF             TESTPCTR                        # NO.  MAY CONTINUE,THOUGH.
                CA              QRCNTR                          # YES.  TRY RATE MAGNITUDE.
                DOUBLE                                          
                INDEX           A                               

# THIS TEST BYPASSES THE TEST IN WSFTEST.  CHECK WSFTEST IF BOUND CHANGES.

                CCS             OMEGAQ                          # SCALED AT PI/4.
                AD              -RATBD+1                        # -.65 DEC/SEC SCALED AT PI/4  + 1 BIT
                TCF             +2                              
                AD              -RATBD+1                        
                EXTEND                                          
                BZMF            +2                              # IS RATE MAG LESS,EQUAL .65 DEG/SEC.
                TCF             TESTPCTR                        # NO.  MAY CONTINUE,THOUGH.
                CCS             QRCNTR                          # YES.  THIS AXIS IS FINE. ARE BOTH DONE.
                TCF             LOOPTEST                        # TRY THE Q AXIS NOW.
                TCF             GTSRAXIS                        # USE TRIM GIMBAL CONTROL.
-TGBND+1        OCT             77512                           # -2 DEG SCALED AT PI, + 1 BIT.
-RATBD+1        OCT             77423                           # -.65 DEG/SEC SCALED AT PI/4  + 1 BIT
# ATTITUDE ERROR IS BEYOND TRIM GIMBAL CONTROL LAW RANGE.  SET UP FOR RCS CONTROL LAW (Q,R-AXIS) AND CALCULATE
# TIMES TO TURN OFF THE GIMBAL DRIVES.

RCSCNTRL        EXTEND                                          # CHANGE LOCATION OF NEXT T5RUPT FROM FIL-
                DCA             POSTQRFL                        # TER TO FILDUMMY.  AHEM, DON'T FORGET
                DXCH            T5ADR                           # THAT FILDUMMY MOVED TO BANK20, DICK GOSS

## Page 594
                EXTEND                                          # SET UP POST P-AXIS T5RUPT TO GO TO
                DCA             QRJPFILT                        # DUMMYFIL INSTEAD OF FILTER.  USE 2CADR
                DXCH            PFILTADR                        # BECAUSE DUMMYFIL NOW IN BANK 16.

                EXTEND                                          # PREPARE FOR SEQUENCED RESUMPTION OF
                DCA             CDUY                            # Q,R-AXIS RCS CONTROL RATE DERIVATION
                DXCH            OLDYFORQ                        # BY PROVIDING OLD CDU READINGS

                EXTEND                                          # MOVE FILTERED AND TRANSFORMED ATTITUDE
                DCA             QDIFF                           # ERRORS INTO ERASABLE FOR Q,R-AXIS RCS
                XCH             ER                              # CONTROL URGENCY CALCULATIONS.
                LXCH            E                               

                CAF             ONE                             
                TC              WAITLIST                        
                EBANK=          DT
                2CADR           CHEKDRIV                        # DO TGOFF CALCULATION IN WAITLIST TASK

                EXTEND                                          # GO TO Q,R-AXES CONTROL IMMEDIATELY
                DCA             TGENTRY                         
                DTCB                                            

                EBANK=          JTSONNOW                        # NO, SURELY YOU JEST, NOT EBANK 6, AGAIN?
POSTQRFL        2CADR           FILDUMMY                        # WATCH OUT FOR BANK SWITCHING D. GOSS

                EBANK=          AOSQTERM
QRJPFILT        2CADR           DUMMYFIL                        # NECESSARY BECAUSE DUMMYFIL IN BANK 16.

                EBANK=          DT
TGENTRY         2CADR           STILLRCS                        


# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

CHEKDRIV        CCS             PASSCTR                         # ENOUGH FILTER PASSES FOR DRIVE DONE?
                TCF             COLDFILT                        #   NO.  JUST STOP DRIVES.
                TCF             WARMFILT                        #   YES.  CALCULATE TIMES (END OF BANK).

COLDFILT        CAF             ZERO                            # FILTER NOT WARM YET. TURN OFF DRIVES.
                TS              NEGUQ
                TS              NEGUR
                TS              QACCDOT
                TS              RACCDOT
                TC              WRCHN12
                TCF             TASKOVER                        

                TC              CCSHOLE                         # FILLER (TO PRESERVE ADDRESSES)
                TC              CCSHOLE                         # FILLER (TO PRESERVE ADDRESSES)
# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

## Page 595
# THE DRIVE SETTING ALGORITHM
# DEL = SGN(OMEGA.K + SGN(ALPHA)ALPHA(2)/2)    ONLY +1/-1

# NEGUSUM = ERROR.K(2) + DEL(OMEGA.K.DEL + ALPHA(2)/2)(3/2) + ALPHA(OMEGA.K.DEL + ALPHA(2)/3)

# DRIVE = -SGN(NEGUSUM)

-.04266         DEC             -.04266                         
GTSRAXIS        CAF             TWO                             # SET INDEXER FOR R-AXIS CALCULATIONS
                TS              QRCNTR                          
                TCF             USUALXIT                        

GOQTRIMG        CAF             ZERO                            # SET INDEXER FOR Q-AXIS CALCULATIONS
                TS              QRCNTR                          

GTSQAXIS        EXTEND                                          
                INDEX           QRCNTR                          # PICK UP K AND K(2) FOR THIS AXIS
                DCA             KQ                              
                DXCH            KCENTRAL                        

                EXTEND                                          
                INDEX           QRCNTR                          # PICK UP OMEGA AND ALPHA FOR THIS AXIS
                DCA             OMEGAQ                          
                DXCH            WCENTRAL                        

                CCS             QRCNTR                          # RDIFF IS STORED IMMEDIATELY FOLLOWING
                INDEX           A                               # QDIFF, WITH NO SEPARATING CELL.
                CAE             QDIFF                           

# QDIFF IS LESS,EQUAL 2 DEG. AND IS SCALED AT 180 DEG.  RESCALE AT 180/64 DEG. = 2 + 13/16 DEG. = PI/64 RADIANS.

                EXTEND                                          # RESCALE DIFFERENCE BY MULTIPLYING BY
                MP              BIT7                            # 2(6)
                LXCH            ETHETA                          

                CAE             KCENTRAL                        # TEST ON MAGNITUDE OF ACCDOT
                AD              -.04266                         
                EXTEND                                          
                BZMF            ACCDOTSM                        # BRANCH IF ACCDOT IS SMALL

ACCDOTLG        CAF             BIT14                           # ACCDOT IS COMPARITIVELY LARGE
                TS              SF1                             # SET UP SCALE FACTORS
                CAF             BIT12                           
WSFTEST         TS              SF2                             

# LOOPTEST CODING BYPASSES THE OMEGA MAGNITUDE TEST, BUT A CHANGE IN THE TEST BOUNDS COULD REQUIRE ITS USE AGAIN.

#                 CCS             WCENTRAL                      TEST ON MAGNITUDE OF OMEGA
#                 AD              -.04438                         
#                 TCF             +2                              
## Page 596
#                 AD              -.04438                         
#                 EXTEND                                          
#                 BZMF            ASFTEST                       IF SMALL, GO TO ALPHA TEST
#                 TCF             WLARGE                          
                TCF             ASFTEST                         # OMEGA IS ALWAYS BOUNDED BY .65 DEG/SEC.
ACCDOTSM        CAE             KCENTRAL                        # RESCALE IF ACCDOT IS SMALL
                EXTEND                                          
                MP              BIT5                            # RESCALE K BY MULTIPLYING BY 2(4)
                LXCH            KCENTRAL                        
                CAE             KCENTRAL                        
                EXTEND                                          
                SQUARE                                          
                TS              K2CNTRAL                        
                CAF             BIT10                           # SET UP VARIABLE SCALE FACTORS
                TS              SF1                             
                CAF             BIT4                            
                TCF             WSFTEST                         # GO TEST ON MAGNITUDE OF OMEGA

ASFTEST         CCS             ACENTRAL                        # TEST ON MAGNITUDE OF ALPHA
                AD              -.08882                         
                TCF             +2                              
                AD              -.08882                         
                EXTEND                                          
                BZMF            WARESCAL                        # IF SMALL, GO TO W,A RESCALING
                TCF             WLARGE                          # IF LARGE, DO SAME AS IF W LARGE

# -.04438         DEC             -.04438                         
-.08882         DEC             -.08882                         

WARESCAL        CAE             WCENTRAL                        # RESCALE OMEGA BY MULTIPLYING BY 2(4)
                EXTEND                                          
                MP              BIT5                            
                LXCH            WCENTRAL                        

                CAE             ACENTRAL                        # RESCALE ALPHA BY MULTIPLYING BY 2(3)
                EXTEND                                          
                MP              BIT4                            
                LXCH            ACENTRAL                        

                TCF             ALGORTHM                        

WLARGE          CAE             SF1                             # RESCALE VARIABLE SCALE FACTORS
                EXTEND                                          
                MP              BIT13                           # SF1 = SF1*2(-2)
                TS              SF1                             
                CAE             SF2                             
                EXTEND                                          
                MP              BIT6                            # SF2 = SF2*2(-9)
                TS              SF2                             

## Page 597
ALGORTHM        CAE             ETHETA                          # GET RESCALED ERROR THETA
                EXTEND                                          
                MP              K2CNTRAL                        # FORM K(2)*THETA IN D.P.
                EXTEND
                MP              SF2                             # CALCULATE AND STORE
                TS              K2THETA                         # K(2)*THETA*SF2 IN K2THETA

                CA              WCENTRAL                        # CALCULATE AND STORE
                EXTEND                                          # K*OMEGA*SF1 IN OMEGA.K
                MP              KCENTRAL
                EXTEND
                MP              SF1                             
                TS              OMEGA.K                         

                CA              ACENTRAL
                EXTEND                                          # BY REDESIGNATION OF THE SCALE FACTOR,
                MP              A                               # THIS PRODUCT BECOMES ALPHA(2)/2
                TS              A2CNTRAL                        # INSTEAD OF  ALPHA(2)

                CCS             ACENTRAL
                CA              A2CNTRAL
                TCF             +2
                CS              A2CNTRAL                        # NOW THE A REGISTER CONTAINS
                AD              OMEGA.K                         # K*OMEGA + ALPHA*ABS(ALPHA)/2

                CCS             A
                CA              BIT1                            # DEL = SIGNUM(A) , (ZERO WHEN A IS ZERO),
                TCF             +2                              # PLUS ONE OR MINUS ONE OTHERWISE.
                CS              BIT1
                TS              DEL

                CCS             DEL
                CA              OMEGA.K
                TCF             +2
                CS              OMEGA.K                         # DEL*OMEGA.K REPLACES OMEGA.K
                TS              OMEGA.K

                AD              A2CNTRAL                        # DEL*OMEGA.K + ALPHA(2)/2
                XCH             FUNCTION                        # STORED IN FUNCTION

                CA              A2CNTRAL
                EXTEND                                          # CALCULATE ALPHA(2)/3
                MP              .66667                          
                AD              OMEGA.K
                EXTEND
                MP              ACENTRAL                        # K(2)*THETA+ALPHA*(DEL*OMEG.K+ALPHA(2)/3)
                ADS             K2THETA                         # FIRST AND SECOND TERMS SUMMED HERE.

# THE FOLLOWING SECTION CALCULATES .707*DEL*FUNCTION(3/2) AND ADDS IT TO THE OTHER TWO TERMS OF NEGUSUM.

## Page 598
                CA              SR                              # CALL SEQUENCE FOR SPROOT REQUIRES THAT
                AD              A                               # SR BE PRESERVED BY THE CALLER.
                XCH             STORCDUY                        # THE KALMAN FILTER STORES INTO THE CELL
                CA              FUNCTION                        # STORCDUY BEFORE USING IT OTHERWISE.
                TC              SPROOT
                LXCH            STORCDUY
                LXCH            SR

                EXTEND
                MP              FUNCTION
                XCH             STORCDUY
                CCS             DEL
                CA              .707GTS                         # THIS CELL CONTAINS SQUARE ROOT OF 1/2
                TCF             +2                              
                CS              .707GTS                         
                EXTEND
                MP              STORCDUY
                AD              K2THETA                         # NEGUSUM IS COMPLETE.

                CCS             A                               # SIGNUM(NEGUSUM) IS NEGATIVE OF THE SIGN
                CA              BIT1                            # WHICH WILL BE ATTACHED TO THE NEW VALUE
                TCF             POSDRIVE                        # OF Q(R)ACCDOT.
                CS              BIT1

POSDRIVE        INDEX           QRCNTR                          # SIGN OF NEW Q(R)ACCDOT OPPOSES THIS SIGN
                TS              NEGUQ

                COM                                             
                EXTEND                                          # SEND BACK JERK TERM
                INDEX           ITEMP6                          
                MP              ACCDOTQ                         
                INDEX           ITEMP6                          
                LXCH            QACDOTMP                        # STORE FOR 100 MS, THEN RELEASE TO FILTER
                CCS             QRCNTR                          # LOOP COUNTER
                TC              SLECTLAW                        # 2ND PASS.  (FOR Q-AXIS)
# TRANSFORM JERKS BACK TO GIMBAL AXES.

                CS              QACCDOT                         # SCALED AT PI/2(7), AND COMPLEMENTED.
                EXTEND                                          
                MP              MR12                            # SCALED AT 2
                TS              Y3DOT                           
                CS              RACCDOT                         # SCALED AT PI/2(7), AND COMPLEMENTED.
                EXTEND                                          
                MP              MR13                            # SCALED AT 2
                ADS             Y3DOT                           
                ADS             Y3DOT                           # SCALED AT PI/2(7)

                CS              QACCDOT                         # SCALED AT PI/2(7), AND COMPLEMENTED.
                EXTEND                                          
                MP              MR22                            # SCALED AT 1
## Page 599
                TS              Z3DOT                           
                CS              RACCDOT                         # SCALED AT PI/2(7), AND COMPLEMENTED.
                EXTEND                                          
                MP              MR23                            # SCALED AT 1
                ADS             Z3DOT                           # SCALED AT PI/2(7)

                TC              WRCHN12                         # SEND GIMBAL DRIVES TO SERVOS
                TCF             RESUME                          # WAIT UNTIL NEXT TRIM GIMBAL RUPT

# WAITLIST TASKS TO SET TRIM GIMBAL TURN OFF BITS.

OFFGIMQ         CAF             ZERO                            # SET Q-AXIS FLAG TO ZERO
                TS              NEGUQ                           
                TCF             +3                              
OFFGIMR         CAF             ZERO                            # SET R-AXIS FLAG TO ZERO
                TS              NEGUR                           
                TC              WRCHN12                         # FLAGS TO CHANNEL BITS
                TCF             TASKOVER                        

# THE WRCHN12 SUBROUTINE SETS BITS 9,10,11,12 OF CHANNEL 12 ON THE BASIS OF THE CONTENTS OF NEGUQ,NEGUR WHICH ARE
# THE NEGATIVES OF THE TRIM GIMBAL DESIRED DRIVES.

BGIM            OCTAL           07400                           
CHNL12          EQUALS          ITEMP6                          

WRCHN12         CCS             NEGUQ                           
                CAF             BIT10                           
                TCF             +2                              
                CAF             BIT9                            
                TS              CHNL12                          

                CCS             NEGUR                           
                CAF             BIT12                           
                TCF             +2                              
                CAF             BIT11                           
                ADS             CHNL12                          # (STORED RESULT NOT USED AT PRESENT)

                CS              BGIM
                EXTEND
                WAND            12
                CA              CHNL12
                EXTEND
                WOR             12

                TC              Q                               # SIMPLE RETURN ALWAYS

# Q,R-TRANSF TRANSFORMS A Y,Z GIMBAL COORDINATE VARIABLE PAIR (IN A,L) TO PILOT COORDINATES (Q/R), RETURNED IN A.
# (THE MATRIX M FROM GIMBAL TO PILOT AXES IS ASSUMED TO BE DONE BY T4RUPT AND SCALED AT +1.)

QRERAS          EQUALS          ITEMP6                          

## Page 600
QTRANSF         LXCH            QRERAS                          # SAVE Z-AXIS VARIABLE
                EXTEND                                          
                MP              M21                             # (Y-AXIS)*M21
                XCH             QRERAS                          # SAVE, GET Z-AXIS VARIABLE
                EXTEND                                          
                MP              M22                             # (Z-AXIS)*M22
                AD              QRERAS                          # SUM = (Y-AXIS)*M21 + (Z-AXIS)*M22
                TC              Q                               # RETURN WITH SUM IN A

RTRANSF         LXCH            QRERAS                          # SAVE Z-AXIS VARIABLE
                EXTEND                                          
                MP              M31                             # (Y-AXIS)*M31
                XCH             QRERAS                          # SAVE, GET Z-AXIS VARIABLE
                EXTEND                                          
                MP              M32                             # (Z-AXIS)*M32
                AD              QRERAS                          # SUM = (Y-AXIS)*M31 + (Z-AXIS)*M32
                TC              Q                               # RETURN WITH SUM IN A

.66667          DEC             .66667
.707GTS         DEC             0.70711
(2/3)           DEC             0.66667                         

## Page 601
# SUBROUTINE: TGOFFCAL            MOD. NO. 1  DATE: AUGUST 22, 1966

# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

# PROGRAM DESIGN BY: RICHARD D. GOSS (MIT/IL)

# PROGRAM IMPLEMENTATION BY: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# MODIFIED 30 NOV 66, TO USE ACCDOTQ AND ACCDOTR.              CRAIG WORK
# MODIFIED AUGUST '67 TO CHANGE CALLING SEQUENCE AND MAKE MAXTIME ERASABLE          PETER WEISSMAN

# THIS SUBROUTINE CALCULATES THE TRIM GIMBAL SHUTDOWN TIME FOR EITHER THE Q OR THE R AXIS (DEPENDING ON THE
# CALLING SEQUENCE).  THIS TIME IS SCALED FOR IMMEDIATE USE BY A WAITLIST CALL AS SHOWN IN THE CALLING SEQUENCES.
# IF THE TIME-TO-GO IS MORE THAN 'DRIVELIM', IT IS LIMITED TO 'MAXTIME'. IF
# THE TIME-TO-GO IS LESS THAN TEN MILLISECONDS, THE SHUTDOWN IS PERFORMED IMMEDIATELY AND THE WAITLIST CALL IS
# BY-PASSED.

# THESE TIME-TO-GO CALCULATIONS ARE DESIGNED TO DRIVE THE TRIM GIMBAL TO A POSITION WHERE THE DESCENT ENGINE WILL
# CAUSE NO ANGULAR ACCELERATION.  THIS SUBROUTINE IS CALLED ONLY FROM THE WAITLIST TASK CHEKDRIV WHICH IS
# INITIATED ONLY WHEN THE TRIM GIMBAL CONTROL LAW HAS LOST CONTROL OF THE LEM VEHICLE ATTITUDE AND MUST RETURN TO
# THE USE OF REACTION CONTROL SYSTEM JETS.

# CALLING SEQUENCES:

#                                                  CAF     ZERO           INDEX FOR Q-AXIS.
#                                                  TC      TGOFFCAL
#                                                  CAF     NEGMAX         RETURN HERE FOR NO Q DRIVE.
#                                                  TS      (QTIME)        RETURN HERE WITH TIME IN A (DECASECONDS)

#                                                  CAF     TWO            INDEX FOR R-AXIS.
#                                                  TC      TGOFFCAL
#                                                  CAF     NEGMAX         RETURN HERE FOR NO R DRIVE.
#                                                  TS      (RTIME)        RETURN HERE WITH TIME IN A (DECASECONDS)

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
#        6. TIME REQUIRED TO ZERO OFFSET, SCALED FOR Q(R)GIMTIMR.

## Page 602
# ERASABLE STORAGE CONFIGURATION (NEEDED BY THE INDEXING METHODS):

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


TGOFFCAL        TS              QRNDXER                         # Q OR R AXIS INDEXER
                INDEX           QRNDXER                         # GET JERK TERM MAGNITUDE SCALED AT
                CAE             ACCDOTQ                         #      PI/2(7) IN RADIANS/SEC(3).
                EXTEND                                          # UNLESS THETA TRIPLE-DOT MAGNITUDE IS NON
                BZMF            TGOFFNOW                        #      -ZERO, SET DRIVE TO ZERO NOW.
                TS              NZACCDOT                        # SAVE NON-ZERO DENOMINATOR.
                INDEX           QRNDXER                         # INITIALIZE THE AOSTERM WHICH WILL BE UP-
                CAE             ALPHAQ                          # DATED IN THE DUMMYFIL CALCULATION FOR
                EXTEND                                          # USE IN THE QRAXIS RATE DERIVATION.  SET
                MP              .1-.05K)                        # AOSTERM TO ALPHA*CSP*(1-.5*K), WHERE CSP
                XCH             L                               # IS .1 SEC, K IS .5   THEN AOSTERM IS SET
                CCS             QRNDXER                         # TO .075*ALPHA, SCALED AT PI/4,WHILE
                INDEX           A                               # ALPHA IS SCALED AT PI/8( THE CONSTANT IS
                LXCH            AOSQTERM                        # SCALED AT 2.
                INDEX           QRNDXER                         # GET ACCELERATION SCALED AT PI/8
                CAE             ALPHAQ                          #      RAD/SEC(2).
                EXTEND                                          # IF ACCELERATION IS ALREADY ZERO, EXIT.
                BZF             TGOFFNOW                        # OTHERWISE, PROCEED WITH NON-ZERO ALPHA.
                EXTEND                                          # SET NEGUQ TO THE SIGN OF ALPHA. THEN USE
                BZMF            NEGALPH                         #   THE MAGNITUDE OF ALPHA TO COMPUTE TIME
                TS              ITEMP6
                CAF             BIT1
                TCF             +4
NEGALPH         CS              A
                TS              ITEMP6
                CS              BIT1
                INDEX           QRNDXER                         # STORE THE DRIVE DIRECTION FLAG
                TS              NEGUQ                           # TIME = MAGNITUDE OF (ALPHA/ACCDOT),
                                                                # MINUS THE SIGN OF Q(R)ACCDOT LEFT IN A.
                EXTEND                                          # STORE ACCDOT TO REFLECT THE CHANGE IN
                INDEX           QRNDXER                         # GIMBAL DRIVE DIRECTION (POSSIBLE).  THIS
## Page 603
                MP              ACCDOTQ                         # CAN BE ESSENTIAL FOR DUMMYFIL, IN CASE
                INDEX           QRNDXER                         # Q(R)ACCDOT IS NOT INITIALIZED BEFORE
                LXCH            QACCDOT                         # EXECUTING DUMMYFIL.
                CAE             NZACCDOT                        # WILL ALPHA/ACCDOT EXCEED MAX DRIVE TIME?
                EXTEND
                MP              DRIVELIM                        # MAX DRIVE TIME AT 16 SEC (ERASABLE LOAD)
                EXTEND
                SU              ITEMP6                          # 15*ACCDOT - ABS(ALPHA) AT PI/8
                EXTEND
                BZMF            USEMAX                          # LARGE T.  USE MAX DRIVE TIME INSTEAD.

                CAE             ITEMP6                          # DRIVE  IME = ABS(ALPHA/ACCDOT)
                EXTEND                                          # RESCALE QUOTIENT TO TIMER(ERASABLE LOAD)
                INDEX           QRNDXER
                MP              DRIVFACQ                        # (10 SCALED AT 2(10)) X (DAMPING FACTOR)
                EXTEND
                DV              NZACCDOT

ZEROTEST        EXTEND                                          # BE SURE WAITLIST TIME IS GREATER THAN 0.
                BZMF            TGOFFNOW

                TCF             +2                              # IT IS, RETURN.

USEMAX          CAE             MAXTIME                         # USE MAXIMUM DRIVE TIME.
 +2             INDEX           Q                               # RETURN TO Q+1 WITH TIME IN A.
                TC              1

TGOFFNOW        CAF             ZERO                            # MAKE SURE PLUS ZERO FOR DRIVE FLAG
                INDEX           QRNDXER                         # TURN OFF DRIVE FLAG NOW
                TS              NEGUQ                           
                TC              Q                               # RETURN TO Q ( WITHOUT A DRIVE TIME).

                TC              CCSHOLE                         #   (FILLER)

# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

QRNDXER         EQUALS          ITEMP1                          # INDEXER FOR Q OR R AXIS
NZACCDOT        EQUALS          ITEMP2                          # TEMPORARY STORAGE FOR NON-ZERO ACCDOT
-2MINWL         DEC             -12000                          # - 2 MINUTES SCALED FOR WAITLIST
-2MIN256        DEC             -.46875                         # - 2 MINUTES SCALED AT 256
128/164         OCTAL           31000                           # 128/163.84 CONVERTING 256 TO WAITLIST/2
.1-.05K)        OCTAL           01146                           # .0375=.075 SCALED AT 2
# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

TESTCNTR        CCS             SIMPCNTR                        # USE BIGBOX FOR PASSCTR INITIALIZATION
                TCF             BIGLOAD                         # UNTIL SIMPCNTR IS +0. THEN USE COUNTBOX.

                CAE             COUNTBOX
                TCF             LOADCNTR
## Page 604
BIGLOAD         CAE             BIGBOX
                TCF             LOADCNTR

# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

# THE NEXT FIVE CELLS ARE LEFT IN FOR SPACING.

                ADS             FUNCTION        +1              # MULTIPLIER AS C(A).  MULTIPLY THESE AND
                TS              L                               # USE ONLY HIGH ORDER PART OF PRODUCT.
                TCF             +2                              # ADD S.P. LOW PRODUCT TO LOW PART OF HIGH
                ADS             FUNCTION                        # PRODUCT.  CHECK OVERFLOW, CARRY, AND
                TC              Q                               # RETURN.
