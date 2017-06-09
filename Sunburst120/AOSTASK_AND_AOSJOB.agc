### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AOSTASK_AND_AOSJOB.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-19 MAS  Transcribed.
## 		2016-10-30 RSB	Typos.
##		2016-12-06 RSB	Comment-proofing with octopus/ProoferComments,
##				changes made.
##		2017-06-09 RSB	Made corrections identified while transcribing
##				SUNBURST 37.

## Page 605
# PROGRAM NAME: AOSTASK           MOD. NO. 1  DATE: NOVEMBER 20, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS "WAITLIST TASK" IS EXECUTED EVERY 2 SECONDS DURING ASCENT (APS) BURNS.  IT ESTIMATES THE ACCELERATION DUE
# TO THE ENGINE OFF-SET.  TO USE THESE ESTIMATES, IT ALSO CALCULATES TERMS TO ADD INTO THE LM DAP RATE DERIVATION
# AND WEIGHTING FACTORS FOR THE ESTIMATE OF AOS AND FOR THE RATE DERIVATION.  FINALLY, IT ALSO SETS UP "AOSJOB"
# THROUGH THE EXECUTIVE TO CALCULATE FUMCTIONS OF THE AOS.

# CALLING SEQUENCE:

#                                         L -1     CAF    2SECSDAP
#                                         L        TC     WAITLIST
#                                                  EBANK= AOSQ
#                                         L +1, +2 2CADR  AOSTASK
#                                         L +3    (RETURN)

# NORMAL EXIT MODE: "TASKOVER"    ALARM/ABORT MODE: NONE.

# INPUT  APSGOING/DAPBOOLS
#        AOSQ,AOSR
#        COEFCTR
#        OLDWFORQ,OLDWFORR
#        SUMRATEQ,SUMRATER
#        OMEGAQ,OMEGAR

## In the following line, the printout appears to say AOSJ rather
## than AOSU, however I think it is clear from comparison with the 
## printout of SUNBURST 37, and from the fact that AOSJ is not 
## actually a symbol appearing elsewhere in the program, that 
## it is a smudged form of AOSU. &mdash; RSB
# OUTPUT AOSQ,AOSR,AOSU,AOSV
#        AOSQTERM,AOSRTERM
#        SUMRATEQ,SUMRATER
#        KCOEFCTR

# DEBRIS: A,L,ITEMP1,ITEMP2.

# THE FOLLOWING LM DAP ERASABLES ARE ZEROED IN THE STARTDAP SECTION OF THE DAPIDLER PROGRAM AND THE COASTASC
# SECTION OF THE AOSTASK.  THE ORDER MUST BE PRESERVED FOR THE INDEXING METHODS WHICH ARE EMPLOYED IN THOSE
# SECTIONS AND ELSEWHERE.

#                                         AOSQ     ERASE   +3             ASCENT OFFSET ACCELERATION ESTIMATES:
#                                         AOSR     EQUALS AOSQ +1         ESTIMATED EVERY 2 SECONDS BY AOSTASK.
#                                         AOSU     EQUALS AOSQ +2         U,V-AXES ACCS FORMED BY VECTOR ADDITION.
#                                         AOSV     EQUALS AOSQ +3         SCALED AT PI/2 RADIANS/SECOND(2).

#                                         AOSQTERM ERASE   +1             (.1-.05K)AOS
#                                         AOSRTERM EQUALS AOSQTERM +1     SCALED AT PI/4 RADIANS/SECOND.

#                                         NJ+Q     ERASE   +7             2 JET OVER-RIDE FLAGS:
#                                         NJ-Q     EQUALS NJ+Q +1         WHENEVER THE OFFSET ACCELERATION ABOUT
#                                         NJ+R     EQUALS NJ+Q +2         AN AXIS IS SO HIGH THAT 2 JETS COULD NOT
#                                         NJ-R     EQUALS NJ+Q +3         CONTROL ATTITUDE SUCCESSFULLY, THEN NJ
#                                         NJ+U     EQUALS NJ+Q +4         FOR THAT AXIS (IN THE DIRECTION OPPOSING
## Page 606
#                                         NJ-U     EQUALS NJ+Q +5         AOS) IS SET TO 1.  OTHERWISE, THE VALUE
#                                         NJ+V     EQUALS NJ+Q +6         IS ZERO.  THESE FLAGS PREVENT TWO JETS
#                                         NJ-V     EQUALS NJ+Q +7         FROM BEING REQUESTED TO FIGHT THE AOS.

## Page 607

# AOSTASK IS EXECUTED ONLY DURING POWERED ASCENT.  IF NO LONGER IN POWERED ASCENT, STOP THE CYCLING OF AOSTASK AND
# SET UP VARIABLES FOR COASTING ASCENT.

                BANK            20                              
                EBANK=          AOSQ                            

# KEEP TRACK OF LENGTH OF BURN FOR DETERMINATION OF WEIGHTING FACTOR K:

AOSTASK         CAE             KCOEFCTR                        # TEST KCOEFCTR FOR INITIAL PASS
                EXTEND                                          
                BZF             ZEROCOEF                        # GO TO DISCONTINUITY SECTION FOR COEFFA.

                AD              DEC-399                         # TEST KCOEFCTR FOR CONSTANT RANGE WHICH
                EXTEND                                          # OCCURS WHEN DURATION OF BURN IS EQUAL TO
                BZMF            +2                              # OR GREATER THAN 400 SECONDS.  (SINCE
                TCF             KONENOW                         # KCOEFCTR IS EVEN, 399 IS THE BREAK PT.)

# FORM WEIGHTING FACTOR FOR ASCENT OFFSET ACCELERATION FILTER:  COEFFA = 0.00125(T) + 0.25

                CAF             0.00125                         # COEFFA = 0.00125(T) + 0.25
                EXTEND                                          
                MP              KCOEFCTR                        # KCOEFCTR = T SCALED AT 2(+14)
                CAF             BIT13                           # (BIT13 = 1/4 = 0.25 SCALED AT 1.)
                AD              L                               
COEFFAST        TS              COEFFA                          # (VOLATILE STORAGE.)                  

# FORM WEIGHTING FACTOR FOR RATE DERIVATION: K = 0.0014(T) + 0.44

                CAF             0.0014                          # K = 0.0014(T) + 0.44
                EXTEND                                          
                MP              KCOEFCTR                        # KCOEFCTR = T SCALED AT 2(+14)
                CAF             0.44                            
                AD              L                               
                TS              K                               # (VOLATILE STORAGE.)
                COM                                             
                AD              POSMAX                          # (1 BIT ERROR DOES DOES NOT COMPOUND.)
                TS              (1-K)                           # (1-K) SCALED AT 1.

                EXTEND                                          
                MP              BIT12                           
                TS              (1-K)/8                         # (1-K)/8 IS (1-K) SCALED AT 8.

                CAE             K                               # WFORP = WFORQR = K/DT = K/.1 = 10K
                EXTEND                                          # SCALED AT 16/SECOND.
                MP              0.625                           # (CHANGES SCALE FACTOR FROM 1 TO 16/SEC.)
                TS              WFORP                           # WFORP IS IDENTICAL WFORQR EXCEPT FOR THE
                TS              WFORQR                          # INITIALIZATION IN STARTDAP OF DAPIDLER.

                CS              K                               # FORM (.1-.05K) FROM K SCALED AT 1 FOR
                EXTEND                                          # THE TORQUE VECTOR RECONSTRUCTION AND
## Page 608
                MP              0.05                            # ALSO FORM (.1-.05K) SCALED AT 1/2 FOR
                AD              0.1                             # THE OFFSET ACCELERATION TERM IN THE RATE
                DOUBLE                                          # EBANK6 FOR USE IN T5RUPT WHILE THE
                TS              .1-.05K                         # LATTER IS VOLATILE AND USED IN THIS TASK

# BEGIN ESTIMATE OF OFFSET ACCELERATION FOR Q,R-AXES:

COEFFA1         CAE             COEFFA                          # FORM COEFFA(AOSQ):
                EXTEND                                          
                MP              AOSQ                            # FIRST TERM OF NEW AOSQ ESTIMATE:
                TS              AOSQ                            # SCALED AT PI/2 RADIANS/SECOND(2).

                CAE             COEFFA                          # FORM COEFFA(AOSR):
                EXTEND                                          
                MP              AOSR                            # FIRST TERM OF NEW AOSR ESTIMATE:
                TS              AOSR                            # SCALED AT PI/2 RADIANS/SECOMD(2).

                CS              COEFFA                          # FORM .5(1-COEFFA) SCALED AT 2 FROM THE
                EXTEND                                          # COEFFA SCALED AT 1.  COEFFA IS NOW THE
                MP              BIT13                           # SAME AS 2(COEFFA) SCALED AT 2, SO MUST
                AD              BIT13                           # MULTIPLY BY 1/4 TO GET .5(COEFFA). THEN,
                TS              .5-.5COF                        # ADD 1/4 AS 1/2 SCALED AT 2 FOR RESULT.

# FINISH OFFSET ACCELERATION ESTIMATES:

# AOS  = COEFFA (AOS   ) + .5(1-COEFFA )(OMEGA -OMEGA   -SUMRATE )
#    T        T     T-2               T       T      T-2        T

                CS              OMEGAQ                          # SAVE PRESENT -OMEGAQ FOR NEXT PASS AND
                XCH             OLDWFORQ                        # PICK UP -(LAST OMEGAQ) FROM OLDWFORQ.
                EXTEND                                          
                SU              SUMRATEQ                        # FORM: W - OLDW - SUMRATE = SUM (Q-AXIS).
                AD              OMEGAQ                          # SCALED AT PI/4 RADIANS/SECOND.
                EXTEND                                          
                MP              .5-.5COF                        # AOSQ = COEFFA(AOSQ)+.5(1-COEFFA)(SUMQ)
                ADS             AOSQ                            # SCALED AT PI/2 RADIANS/SECOND(2).

                CS              OMEGAR                          # SAVE PRESENT -OMEGAQ FOR NEXT PASS AND
                XCH             OLDWFORR                        # PICK UP -(LAST OMEGAR) FROM OLDWFORR.
                EXTEND                                          
                SU              SUMRATER                        # FORM: W - OLDW - SUMRATE = SUM (R-AXIS).
                AD              OMEGAR                          # SCALED AT PI/4 RADIANS/SECOND.
                EXTEND                                          
                MP              .5-.5COF                        # AOSR = COEFFA(AOSR)+.5(1-COEFFA)(SUMR)
                ADS             AOSR                            # SCALED AT PI/2 RADIANS/SECOND(2).

# CALCULATE THE OFFSET ACCELERATIONS FOR THE U,V-AXES:

                CAE             AOSQ                            # FIRST, CALCULATE AOSU:
                AD              AOSR                            
## Page 609
                EXTEND                                          
                MP              0.70711                          
                TS              AOSU                            # SCALED AT PI/2 RADIANS/SECOND(2).

                CS              AOSQ                            # THEN, CALCULATE AOSV:
                AD              AOSR                            
                EXTEND                                          
                MP              0.70711                          
                TS              AOSV                            # SCALED AT PI/2 RADIANS/SECOND(2).

# FORM TERMS FOR RATE DERIVATION:

                CAE             .1-.05K                         # FORM Q-AXIS RATE DERIVATION TERM:
                EXTEND                                          
                MP              AOSQ                            # AOSQTERM = (.1-.05K)AOSQ
                TS              AOSQTERM                        # SCALED AT PI/4 RADIANS/SECOND.

                CAE             .1-.05K                         # FORM R-AXIS RATE DERIVATION TERM:
                EXTEND                                          
                MP              AOSR                            # AOSRTERM = (.1-.05K)AOSR
                TS              AOSRTERM                        # SCALED AT PI/4 RADIANS/SECOND.

# SET ERASABLES FOR NEXT 2 SECOND INTERVAL:

                CAF             TWO                             # INCREMENT BURN DURATION TIMER BY 2 SECS.
                ADS             KCOEFCTR                        

                EXTEND                                          # SET UP SUMRATES
                DCS             SAVRATEQ                        
                DXCH            SUMRATEQ                        

                TCF             NOQRSM                          
# SPECIAL DISCONTINUITY SECTION FOR COEFFA ON FIRST PASS:

ZEROCOEF        CAF             TWO                             # INITIALIZE BURN DURATION TIMER TO TWO
                TS              KCOEFCTR                        # SECONDS FOR THE DERIVATION OF K.

                CAF             ZERO                            # FOR THE FIRST PASS, SET COEFFA TO ZERO
                TCF             COEFFAST                        # SINCE AOS ESTIMATES ARE NOW USELESS.

# SPECIAL K AND COEFFA SETTINGS FOR BURNS LASTING 400 SECONDS OR MORE:

KONENOW         EXTEND                                          # K=1, SO 1-K AT EITHER SCALING IS ZERO.
                DCA             DPZEROX                         # (1-K)   SCALED AT 1.
                DXCH            (1-K)                           # (1-K)/8 SCALED AT 8.

                CAF             0.625                           # WFORP = WFORQR = K/DT = K/.1 = 10K = 10
                TS              WFORP                           # SCALED AT 16/SECOND.
                TS              WFORQR                          

## Page 610
                CAF             0.1                             # (.1-.05K) = 0.05 SINCE K = 1.
                TS              .1-.05K                         # SCALED AT 1/2. (VOLATILE STORAGE.)

                CAF             BIT13-14                        # COEFFA = 0.75
                TS              COEFFA                          # SCALED AT 1.   (VOLATILE STORAGE.)

                TCF             COEFFA1                         # GO BEGIN OFFSET ACCELERATION ESTIMATE.

# CONSTANTS FOR AOSTASK:

                OCT             0                               # TO PRESERVE LOCATION OF 1/ACCS.
0.00125         DEC             0.00125                         
0.0014          DEC             0.0014                          
0.00444         DEC             0.00444                         
0.05            DEC             0.05                            
0.1             DEC             0.1                             
0.3125          DEC             0.3125                          
0.44            DEC             0.44                            
0.625           DEC             0.625                           
0.70711         DEC             0.70711                         
DEC-399         DEC             -399                            
DPZEROX         2DEC            0                               

2SECSDAP        DEC             200                             
(1-K)S          DEC             0.5                             
                DEC             0.0625                          

## Page 611
# PROGRAM NAME: WCHANGER          MOD. NO. 0  DATE: DECEMBER 9, 1966

# THIS PROGRAM IS A WAITLIST TASK WHICH IS INITIATED FROM THE STARTDAP SECTION OF DAPIDLER.  IT IS EXECUTED
# BETWEEN THE FIRST Q,R-AXES T5RUPT AND THE SECOND P-AXIS T5RUPT (I.E. 180 MS AFTER STARTDAP).  THE PURPOSE OF
# WCHANGER IS TO RESET THE VARIABLE K (IN ALL ITS FORMS) FOR THE RATE DERIVATION FROM 1 TO 0.5.  (IT ALSO SETS THE
# NOMINAL LM DAP DT TO 100 MS.)

# CALLING SEQUENCE (FROM STARTDAP):

#                                         L -1     CAF    180MS
#                                         L        TC     WAITLIST
#                                                  EBANK= WFORQR
#                                         L +1     2CADR  WCHANGER
#                                         L +2    (BBCON)
#                                         L +3    (RETURN)

# SUBROUTINES CALLED: WCHANGE.    NORMAL EXIT: TASKOVER.

# INPUT: NONE.                    ALARM/ABORT EXITS: NONE.

# OUTPUT: WFORP,WFORQR,(1-K),(1-K)/8.

WCHANGER        TC              IBNKCALL                        # (WAITLIST TASK IS IN T3RUPT.)
                FCADR           WCHANGE                         # SUBROUTINE DOES SETTING TO SAVE SPACE.
# WE RETURN FROM WCHANGE WITH RANDOM EBANK, BUT WHO CARES.
                TCF             TASKOVER                        # END THIS TASK.

## Page 612
# INERPOLY COMPUTES IXX, IYY, IZZ, AND IN DESCENT, L,PVT-CG, ACCDOTQ, ACCDOTR,KQ,KQ2, KRDAP, KR2..
# AFTER THE INERTIAS ARE COMPUTED, THEY ARE USED TO COMPUTE NEW VALUES OF
# 1JACC, 1JACCQ, 1JACCR, 1JACCU, 1JACCV AND 1/2JTSP.
# INERPOLY EXITS BY .... TCF ENDOFJOB


                BANK            26                              
                EBANK=          IXX                             
1/ACCS          CA              BIT2                            
                EXTEND                                          
                RAND            30                              
                CCS             A                               # CHOOSES ASCENT OR DESCENT COEF
                CS              THREE                           
                AD              SIX                             
                TS              INERCTRX                        

                CAF             TWO                             
STCTR           TS              INERCTR                         # J=2,1,0 FOR IZZ,IYY,IXX

                EXTEND                                          
                DIM             INERCTRX                        # JX=5,4,3 OR 2,1,0 FOR Z,Y,X COEF

STCTR1          CA              MASS                            # IN KGS (+15)
                EXTEND                                          
                INDEX           INERCTRX                        
                MP              INERCONC                        
                INDEX           INERCTRX                        
                AD              INERCONB                        
                EXTEND                                          
                MP              MASS                            
                INDEX           INERCTRX                        
                AD              INERCONA                        
                INDEX           INERCTR                         
                TS              IXX                             # I(J)=(C(JX)MASS+B(JX))MASS+A(JX)  (+18)
                                                                # I(-1)=L,PVT-CG  (+6)

                CCS             INERCTR                         # COUNTER 2,1,0,-1
                TCF             STCTR                           
                TCF             COMMEQS                         
                TCF             LRESC                           

COMMEQS         EXTEND                                          
                DCA             TORKJET                         # 500 FT-LBS. (+16) PI
                EXTEND                                          
                DV              IXX                             
                TS              1JACC                           # SCALED BY PI/4

                EXTEND                                          
                DCA             TORKJET1                        # 550 FT-LBS. (+16) PI

## Page 613
                EXTEND                                          
                DV              IYY                             
                TS              1JACCQ                          # SCALED BY PI/4

                EXTEND                                          
                DCA             TORKJET1                        # 550 FT-LBS. (+16) PI
                EXTEND                                          
                DV              IZZ                             
                TS              1JACCR                          # SCALED BY PI/4

                AD              1JACCQ                          
                EXTEND                                          
                MP              0.35356                         # .70711 SCALED BY (+1)
                TS              1JACCU                          
                TS              1JACCV                          # SCALED BY PI/4

                CAF             4JTORK                          
                TS              TEMPINER                        
                CAE             IXX                             
                ZL                                              
                EXTEND                                          
                DV              TEMPINER                        
                DOUBLE                                          
                TS              1/2JTSP                         # SCALED BY 1/PI (+8)

                CAF             BIT2                            
                EXTEND                                          
                RAND            30                              
                CCS             A                               # COMPUTE L,PVT-CG IF IN DESCENT
                TCF             DES                             
                TCF             CONT1/AC                        
DES             CS              ONE                             
                TS              INERCTR                         
                TS              INERCTRX                        
                TCF             STCTR1                          

LRESC           CA              TEMPINER                        # SCALED AT (+6)
                EXTEND                                          
                MP              BIT4                            
                LXCH            L,PVT-CG                        # SCALED AT 2(+3)

                CA              GFACT                           
                TS              MPAC                            # FOR DIVISION LATER

# THIS SECTION COMPUTES THE RATE OF CHANGE OF ACCELERATION DUE TO THE ROTATION OF THE GIMBALS.  THE EQUATION IMPLE
# MENTED IN BOTH THE Y-X PLANE AND THE Z-X PLANE IS --  D(ALPHA)/DT = TL/I*D(DELTA)/DT , WHERE
#      T = ENGINE THRUST FORCE
#      L = PIVOT TO CG DISTANCE OF ENGINE
#      I = MOMENT OF INERTIA

## Page 614
                EBANK=          ABDELV                          
                CA              EBANK5                          # CHANGE EBANK TO GET ABDELV
                LXCH            A                               # THIS IS NECESSARY TO PRESERVE A WHILE
                LXCH            EBANK                           # SWITCHING EBANKS

                CAE             ABDELV                          # SCALED AT 2(13) CM/SEC(2)
                LXCH            EBANK                           # RESTORE EBANK LEAVING A UNHARMED

                EBANK=          IXX                             

                EXTEND                                          
                MP              MASS                            # SCALED AT 2(15) KG.
                EXTEND                                          
                DV              MPAC                            # CONTAINS GFACT
# MASS IS DIVIDED BY ACCELERATION OF GRAVITY IN ORDER TO MATCH THE UNITS OF IXX,IYY,IZZ, WHICH ARE SLUG-FT(2).
# THE RATIO OF ACCELERATION FROM PIPAS TO ACCELERATION OF GRAVITY IS THE SAME IN METRIC OR ENGINEERING UNITS, SO
# THAT IS UNCONVERTED.  2.20462 CONVERTS KG. TO LB.  NOW T IS IN A SCALED AT 2(14).

                EXTEND                                          
                MP              DELDOT26                        # .2 DEG/SEC AT PI/64 RADIANS/SECOND
                EXTEND                                          
                MP              L,PVT-CG                        # SCALED AT 8 FEET.
                INHINT                                          
                DXCH            MPAC                            # SINCE THIS IS A JOB, MPAC IS AVAILABLE
                EXTEND                                          
                DCA             MPAC                            
                EXTEND                                          
                DV              IZZ                             # SCALED AT 2(18) SLUG-FT(2)
                TS              ACCDOTR                         # SCALED AT PI/2(7)
                EXTEND                                          
                DCA             MPAC                            
                EXTEND                                          
                DV              IYY                             # SCALED AT 2(18) SLUG-FT(2)
                TS              ACCDOTQ                         # SCALED AT PI/2(7)
                EXTEND                                          
                MP              DGBF                            # .3ACCDOTQ SCALED AT PI/2(8)
                TS              KQ                              
                EXTEND                                          
                SQUARE                                          
                TS              KQ2                             # KQ(2)

                CAE             ACCDOTR                         # .3ACCDOTR AT PI/2(8)
                EXTEND                                          
                MP              DGBF                            
                TS              KRDAP                           
                EXTEND                                          
                SQUARE                                          
                TS              KR2                             

                EXTEND                                          # NOW COMPUTE QACCDOT, RACCDOT, THE SIGNED
## Page 615
                READ            12                              # JERK TERMS.  STORE CHANNEL 12, WITH GIM
                TS              MPAC            +1              # BAL DRIVE BITS 9 THROUGH 12.  SET LOOP
                CAF             BIT2                            # INDEX TO COMPUTE RACCDOT, THEN QACCDOT.
                TCF             LOOP3                           
                CAF             ZERO                            # ACCDOTQ AND ACCDOTR ARE NOT NEGATIVE,
LOOP3           TS              MPAC                            # BECAUSE THEY ARE MAGNITUDES
                CA              MPAC            +1              
                INDEX           MPAC                            # MASK CHANNEL IMAGE FOR ANY GIMBAL MOTION
                MASK            GIMBLBTS                        
                EXTEND                                          
                BZF             ZACCDOT                         # IF NONE, Q(R)ACCDOT IS ZERO.
                CA              MPAC            +1              
                INDEX           MPAC                            # GIMBAL IS MOVING.  IS ROTATION POSITIVE.
                MASK            GIMBLBTS        +1              
                EXTEND                                          
                BZF             FRSTZERO                        # IF NOT POSITIVE, BRANCH
                INDEX           MPAC                            # POSITIVE ROTATION, NEGATIVE Q(R)ACCDOT.
                CS              ACCDOTQ                         
                TCF             STACCDOT                        
FRSTZERO        INDEX           MPAC                            # NEGATIVE ROTATION, POSITIVE Q(R)ACCDOT.
                CA              ACCDOTQ                         
                TCF             STACCDOT                        
ZACCDOT         CAF             ZERO                            
STACCDOT        INDEX           MPAC                            
                TS              QACCDOT                         # STORE Q(R)ACCDOT, COMPLEMENTED.
                CCS             MPAC                            
                TCF             LOOP3           -1              # NOW DO QACCDOT.
                TCF             +5                              # LOOP COMPLETED.  RELINT IS SAFE NOW.
GIMBLBTS        OCTAL           01400                           
                OCTAL           00400                           # BECAUSE OF TRIM GIMBAL POLARITY CHANGE,
                OCTAL           06000                           # THESE BIT VALUES CAUSE Q(R)ACCDOT TO BE
                OCTAL           02000                           # GENERATED WITH INVERTED SIGN.

                RELINT                                          

CONT1/AC        EXTEND                                          
                DCA             CONTCADR                        
                DTCF                                            
                DEC             0.99191                         
INERCONC        DEC             -.00071                         
                DEC             -.78952                         
                DEC             -.79009                         
                DEC             0.00249                         
                DEC             -.61154                         
                DEC             -.60892                         
                DEC             -.79812                         
INERCONB        DEC             0.17497                         
                DEC             0.69605                         
                DEC             0.65726                         
                DEC             0.18347                         
## Page 616
                DEC             0.15660                         
                DEC             0.33662                         
                DEC             0.20239                         
INERCONA        DEC             0.00064                         
                DEC             -.06778                         
                DEC             -.04904                         
                DEC             -.00192                         
                DEC             0.00211                         
                DEC             -.01324                         
TORKJET         2DEC            0.002428512                     

TORKJET1        2DEC            0.002671365                     

4JTORK          DEC             .62170                          
DGBF            DEC             0.6                             # .3 SCALED AT 1/2
0.35356         DEC             0.35356                         # 0.70711 SCALED AT +1



CONTCADR        2FCADR          1/ACCONT                        

GFACT           OCTAL           00674                           # 979.24/2.20462 SCALED AT 2(14)
DELDOT26        DEC             .07111                          # 0.2 DEG/SEC SCALED AT PI/64 RAD/SEC

## Page 617
# PROGRAM NAME: 1/ACCONT          MOD. NO. 2  DATE: JANUARY 9, 1967
# PROGRAM DESIGN BY: RICHARD D. GOSS (MIT/IL)

# IMPLEMENTATION BY: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# LAST MODIFICATION BY: JONATHAN D. ADDELSTON
# THIS PROGRAM IS PART OF AN EXECUTIVE JOB AND CALCULATES:

#          1. THE INVERSES OF THE NET ACCELERATIONS ABOUT ALL AXES (Q,R,U,V), IN ALL DIRECTIONS (+/-), AND ALL
#             COMBINATIONS OF JETS (2/4 FOR Q,R AND 1/2 FOR U,V).
#          2. THE INVERSES OF THE MINIMUM ACCELERATIONS FOR THE URGENCY AND TJETLAW COMPUTATION, DURING APS BURNS.
#          3. THE INITIAL INVERSE NET ACCELERATIONS USED FOR THE URGENCY COMPUTATION, DURING APS BURNS.
#          4. THE NJ FLAGS TO REQUIRE MANDATORY JET ACCELERATION DURING APS BURNS.

# SUBROUTINES CALLED: INVACC.

# CALLING SEQUENCE: CONTROL IS TRANSFERRED HERE FROM 1/ACCS SECTION.

# NORMAL EXIT: ENDOFJOB.          ALARM/ABORT EXITS: NONE.

# INPUT: AOSQ,AOSR,AOSU,AOSV,1JACCQ,1JACCR,1JACCU,1JACCV,APSGOING/DAPBOOLS.

# DEBRIS: NONE.

## Page 618
                BANK            20                              
                EBANK=          AOSQ                            

# SET UP LOOP FOR FOUR AXES (IN THE ORDER: V,U,R,Q):

1/ACCONT        CAF             THREE                           # JOBAXES IS USED TO PICK UP ONE OF FOUR.
INVLOOP         TS              JOBAXES                         # ADJACENT REGISTERS, ALSO TO COUNT LOOP.

# SET UP "TABPLACE" TO STORE 1/NETACC TABLE:

                EXTEND                                          # TABPLACE = 4(JOBAXES)
                MP              FOUR                            # SINCE THERE ARE FOUR ENTRIES PER AXIS.
                LXCH            TABPLACE                        

#                                                      2
#            2(1JACC   ) + AOS    - 0.02 RADIANS/SECOND  GREATER THAN ZERO
#                   Q,R       Q,R
#        OR                                            2
#              1JACC     + AOS    - 0.02 RADIANS/SECOND  GREATER THAN ZERO
#                   U,V       U,V

                INDEX           JOBAXES                         # THE INDEXED PICK-UP OF JET ACCELERATIONS
                CAE             1JACCQ                          # USES THE FOLLOWING HAPPY COINCIDENCE:
                TS              TEMPACC                         # 1JACCU AND 1JACCV ARE SCALED AT PI/2 AS
                INDEX           JOBAXES                         # ARE AOSU AND AOSV.  1JACCQ AND 1JACCR
                AD              AOSQ                            # ARE SCALED AT PI/4 AND THEREFORE ARE
                TS              TEMPNET                         # EQUIVALENT TO 2(1JACCQ) AND 2(1JACCR)
                AD              -.02R/S2                        # SCALED AT PI/2, AS ARE AOSQ AND AOSR.
                EXTEND                                          
                BZMF            FIFTY1                          # (BRANCH FOR CONSTANT VALUE OF INVERSE.)

#            1/NET+2    = 1/( 2(1JACC   ) + AOS   )
#                   Q,R              Q,R       Q,R
#        OR
#            1/NET+1    = 1/(   1JACC    + AOS   )
#                   U,V              U,V      U,V

                TC              INVACC                          
FIFTY1R         INDEX           TABPLACE                        
                TS              1/NET+2Q                        # SCALED AT 2(+8)/PI SECONDS(2)/RADIAN.

#                                                      2
#            2(1JACC   ) - AOS    - 0.02 RADIANS/SECOND  GREATER THAN ZERO
#                   Q,R       Q,R
#        OR                                            2
#              1JACC     - AOS    - 0.02 RADIANS/SECOND  GREATER THAN ZERO
#                   U,V       U,V

                INDEX           JOBAXES                         # THIS SECTION USES THE INDEXING TRICKS OF
                CS              AOSQ                            # THE FIRST PART (ABOVE), BUT USES THE
## Page 619
                TS              TEMPAOS                         # TEMPORARY LOCATIONS AS FOLLOWS:
                AD              TEMPACC                         # "TEMPAOS" SAVES -AOS FOR THIS AXIS.
                TS              TEMPNET                         # "TEMPACC" HAS THE JET ACCELERATION.
                AD              -.02R/S2                        # C(TEMPNET) ARE (JETACC-AOS) FOR DENOM.
                EXTEND                                          
                BZMF            FIFTY2                          # (BRANCH FOR CONSTANT VALUE OF INVERSE.)

#            1/NET-2    = 1/( 2(1JACC   ) - AOS   )
#                   Q,R              Q,R       Q,R
#        OR
#            1/NET-1    = 1/(   1JACC      - AOS   )
#                   U,V              U,V        U,V

                TC              INVACC                          
FIFTY2R         INDEX           TABPLACE                        
                TS              1/NET-2Q                        # SCALED AT 2(+8)/PI SECONDS(2)/RADIAN.

#            1/NET-4    = 1/( 4(1JACC   ) - AOS   )
#                   Q,R              Q,R       Q,R
#        OR
#            1/NET-2    = 1/( 2(1JACC   ) - AOS   )
#                   U,V              U,V       U,V

                CAE             TEMPACC                         # FIRST, FROM 2(1JACCQ,R) FORM 4(1JACCQ,R)
                DOUBLE                                          # OR FROM 1JACCU,V FORM 2(1JACCU,V) AND
                TS              TEMPACC                         # SAVE FOR NEXT INVERSE CALCULATION.
                AD              TEMPAOS                         # THEN, COMPUTE EITHER 4(1JACCQ,R)-AOSQ,R
                TS              TEMPNET                         # OR 2(1JACCU,V)-AOSU,V SCALED AT PI/2.

                TC              INVACC                          
                INDEX           TABPLACE                        
                TS              1/NET-4Q                        # SCALED AT 2(+8)/PI SECONDS(2)/RADIAN.

#            1/NET+4    = 1/( 4(1JACC   ) + AOS   )
#                   Q,R              Q,R       Q,R
#        OR
#            1/NET+2    = 1/( 2(1JACC   ) + AOS   )
#                   U,V              U,V       U,V

                CS              TEMPAOS                         # FIRST, COMPUTE EITHER 4(1JACCQ,R)+AOSQ,R
                AD              TEMPACC                         # OR 2(1JACCU,V)+AOSU,V AND SAVE FOR THE
                TS              TEMPNET                         # DIVISION (SCALED AT PI/2 RADIANS/SECOND)

                TC              INVACC                          
                INDEX           TABPLACE                        
                TS              1/NET+4Q                        # SCALED AT 2(+8)/PI RADIANS(2)/SECOND.

# TEST FOR END OF LOOP:

                CCS             JOBAXES                         # IF "JOBAXES" PNZ, CONTINUE.
## Page 620
                TCF             INVLOOP                         # IF "JOBAXES" ZERO, STOP.

# TEST FOR ASCENT PROPULSION SYSTEM BURN:

                CAF             APSGOING                        # IF LM IS IN COAST OR IN A DESCENT BURN,
                MASK            DAPBOOLS                        # THEN THE AOSJOB IS TRIVIAL FROM HERE
                CCS             A                               # AND THIS TEST REDUCES THE COMPUTATION
                TCF             ASCJOB                          # TIME IN THOSE CASES.

# FILL IN DESCENT BURN OR COAST VALUES QUICKLY:

                CAE             1/NET+2Q                        # FOR Q-AXIS URGENCY.
                TS              1/ACCQ                          
                CAE             1/NET+2R                        # FOR R-AXIS URGENCY.
                TS              1/ACCR                          

                INHINT                                          
POPNONJ         CS              DAPBOOLS                        # SET BIT TO INDICATE DATA GOOD.
                MASK            DATAGOOD                        
                ADS             DAPBOOLS                        
                TCF             ENDOFJOB                        # END THIS ITERATION OF AOSJOB.

## Page 621
# IN ASCENT BURN, SO SET UP Q,R-AXES LOOP:

ASCJOB          CAF             THREE                           # SET UP THE TABLE INDICES:
QRJOB           TS              JOBAXES                         
                DOUBLE                                          # AOS TABLE USES "JOBAXES"  (ADJACENT).
                TS              NJPLACE                         # NJ  TABLE USES "NJPLACE"  (ONE APART).
                DOUBLE                                          # NET TABLE USES "TABPLACE" (THREE APART).
                TS              TABPLACE                        

#                                         2
# TEST ABVAL(AOS   ) - 0.02 RADIANS/SECOND  GREATER THAN ZERO:
#               Q,R

                INDEX           JOBAXES                         # FORM ABVAL(AOS   ) AND SAVE FOR INVACC.
                CCS             AOSQ                            #               Q,R
                AD              ONE                             
                TCF             +2                              
                AD              ONE                             
                TS              TEMPNET                         
                AD              -.02R/S2                        # -0.02 RADIANS/SECOND(2) AT PI/2
                EXTEND                                          
                BZMF            FIFTY3                          # (BRANCH FOR CONSTANT VALUE OF INVERSE.)

# CALCULATE 1/AMIN    = 1/ABVAL(AOS   ):
#                 Q,R              Q,R

                TC              INVACC                          # (USE SUBROUTINE FOR INVERSE.)
FIFTY3R         INDEX           JOBAXES                         
                TS              1/AMINQ                         # SAVE FOR USE BY URGENCY CALCULATIONS.

                CS              JOBAXES                         # 2 - C(JOBAXES) CAUSES A BRANCH ONLY WHEN
                AD              TWO                             # C(JOBAXES) = 3 OR 2, I.E. WHEN DOING
                EXTEND                                          # U- OR V-AXIS PASS OF LOOP ONLY SET UP
                BZMF            UVNEXT                          # 1/AMINU OR 1/AMINV, RESPECTIVELY.

#                                                       2
# TEST 2(1JACC   ) - ABVAL(AOS   ) - 0.06 RADIANS/SECOND  GREATER THAN ZERO:
#             Q,R             Q,R

                CS              TEMPNET                         # "TEMPNET" IS ABVAL(AOSQ,R).
                INDEX           JOBAXES                         # SAVE -ABVAL(AOSQ,R) FOR USE IN THE
                TS              ABVLAOSQ                        # U,V-AXIS NJ COMPUTATION BELOW.
                AD              -.06R/S2                        # -0.06 RADIANS/SECOND(2) SCALED AT PI/2.
                INDEX           JOBAXES                         
                AD              1JACCQ                          # "1JACCQ,R" SCALED AT PI/4 RAD/SEC(2) ARE
                EXTEND                                          # 2(1JACCQ,R) SCALED AT PI/2 RAD/SEC(2).
                BZMF            OVERRIDE                        

# SET FLAG NOT TO REQUEST MANDATORY FOUR JET OPERATION FOR +Q,+R ROTATION DURING THIS APS BURN (FOR NOW):
## Page 622
                CAF             ZERO                            # NJ = 0 ALLOWS THE URGENCY FUNCTIONS TO
                INDEX           NJPLACE                         # ACTUALLY SELECT 2 JET ROTATION AS THE
                TS              NJ+Q                            # OPTIMAL POLICY.

# TEST SIGN(AOS   ):
#              Q,R

                INDEX           JOBAXES                         # THE SIGN OF AOSQ,R DETERMINES THE RATIO
                CAE             AOSQ                            # TO BE COMPUTED AS THE CORRECTION FACTOR
                EXTEND                                          # IN THE URGENCY FUNCTION CALCULATION AND
                BZMF            URGRAT2                         # ALSO SPECIFIES THE CURRECT NJ VALUES.

# FIRST CASE FOR URGENCY RATIO:

URGRAT1         INDEX           TABPLACE                        # CHOOSE THE -2 JET NET ACCELERATION
                CAE             1/NET-2Q                        # INVERSE FOR USE IN URGENCY COMPUTATION.
                INDEX           JOBAXES                         
                TS              1/ACCQ                          

                ZL                                              # PREVENT OVERFLOW FOR SMALL AOSQS
                INDEX           TABPLACE                        
                CAE             1/NET+2Q                        #         1/NET+2Q,R
                EXTEND                                          # RATIO = ----------
                INDEX           TABPLACE                        #         1/NET-2Q,R
                DV              1/NET-2Q                        
                INDEX           JOBAXES                         
                TS              URGRATQ                         

                TCF             SWITNJS                         # GO TO SET NJS.

# SECOND CASE FOR URGENCY RATIO:

URGRAT2         INDEX           TABPLACE                        # CHOOSE THE +2 JET NET ACCELERATION
                CAE             1/NET+2Q                        # INVERSE FOR USE IN URGENCY COMPUTATION.
                ZL                                              # PREVENT OVERFLOW ON ZERO BZMF BRANCH.
                INDEX           JOBAXES                         
                TS              1/ACCQ                          

                INDEX           TABPLACE                        
                CAE             1/NET-2Q                        #         1/NET-2Q,R
                EXTEND                                          # RATIO = ----------
                INDEX           TABPLACE                        #         1/NET+2Q,R
                DV              1/NET+2Q                        
                INDEX           JOBAXES                         
                TS              URGRATQ                         

                TCF             NXTNJZER                        # GO TO SET NJS.

# SET FLAG TO INDICATE MANDATORY USE OF FOUR JETS TO FIGHT THE OFFSET ACCELERATION:
## Page 623
OVERRIDE        CAF             ONE                             # (THIS SHOULD BE DONE BEFORE THE INHINT.)

                INHINT                                          # PREVENT POSSIBLY EPHEMERAL MANDATORY NJ
                                                                # SETTING FROM AFFECTING JET SELECTION.
                INDEX           NJPLACE                         # NJ = 1 FORCES THE URGENCY FUNCTIONS TO
                TS              NJ+Q                            # ACTUALLY SELECT 4 JET ROTATION AS THE
                                                                # OPTIMAL POLICY (TO FIGHT THE AOS).

# TEST SIGN(AOS   ):
#              Q,R

                INDEX           JOBAXES                         # THE SIGN OF AOSQ,R DETERMINES THE RATIO
                CAE             AOSQ                            # TO BE COMPUTED AS THE CORRECTION FACTOR
                EXTEND                                          # IN THE URGENCY FUNCTION CALCULATION AND
                BZMF            URGRAT4                         # ALSO SPECIFIES THE CORRECT NJ VALUES.

# THIRD CASE FOR URGENCY RATIO:

URGRAT3         INDEX           TABPLACE                        # CHOOSE THE -4 JET NET ACCELERATION
                CAE             1/NET-4Q                        # INVERSE FOR USE IN URGENCY COMPUTATION.
                INDEX           JOBAXES                         
                TS              1/ACCQ                          

                ZL                                              
                INDEX           TABPLACE                        
                CAE             1/NET+2Q                        #         1/NET+2Q,R
                EXTEND                                          # RATIO = ----------
                INDEX           TABPLACE                        #         1/NET-4Q,R
                DV              1/NET-4Q                        
                INDEX           JOBAXES                         
                TS              URGRATQ                         

# RESET VALUES OF NJS FOR Q,R-AXIS:

SWITNJS         CAF             ZERO                            # SET NJ      = NJ      (FROM ABOVE)
                INDEX           NJPLACE                         #       -Q,-R     +Q,+R
                XCH             NJ+Q                            # AND
                INDEX           NJPLACE                         #     NJ      = 0.
                TS              NJ-Q                            #       +Q,+R

                RELINT                                          # SINCE NJS NOW VALID, ALLOW INTERRUPTS.

                TCF             UVNEXT                          # GO TEST FOR ENTRY TO U,V-AXES LOGIC.

# FOURTH CASE FOR URGENCY RATIO:

URGRAT4         RELINT                                          # SINCE ALL NJS ALREADY SET ARE NOW KNOWN
                                                                # TO BE VALID, ALLOW INTERRUPTS.

                INDEX           TABPLACE                        # CHOOSE THE +4 JET NET ACCELERATION
## Page 624
                CAE             1/NET+4Q                        # INVERSE FOR USE IN URGENCY COMPUTATION.
                ZL                                              # -------------------------------------
                INDEX           JOBAXES                         
                TS              1/ACCQ                          

                INDEX           TABPLACE                        
                CAE             1/NET-2Q                        #         1/NET-2Q,R
                EXTEND                                          # RATIO = ----------
                INDEX           TABPLACE                        #         1/NET+4Q,R
                DV              1/NET+4Q                        
                INDEX           JOBAXES                         
                TS              URGRATQ                         

# SET NJ FOR NEGATIVE ROTATIONS:

NXTNJZER        CAF             ZERO                            # SET NJ      = 0  TO LET THE URGENCY
                INDEX           NJPLACE                         #       -Q,-R      FUNCTIONS SELECT 2 JET
                TS              NJ-Q                            #                  -Q,-R ROTATION

# TEST FOR END OF Q,R-AXES LOOP:

UVNEXT          CCS             JOBAXES                         # JOBAXES = 1 MEANS GO DO Q-AXIS.
                TCF             QRJOB                           # JOBAXES = 0 MEANS GO DO U,V-AXES.

## Page 625
# AFTER Q,R-AXES COMPLETE, DO U,V-AXES LOGIC:
UVJOB           INHINT                                          # PREVENT POSSIBLY EPHEMERAL OPTIONAL NJ
                                                                # SETTING FROM AFFECTING JET SELECTION.
                TS              NJ+U                            # FIRST, ARBITRARILY SET THE U,V-AXIS NJS
                TS              NJ-U                            # TO THE ZERO (OPTIONAL) VALUE UNTIL THE
                TS              NJ+V                            # TESTS ON AOS ARE MADE BELOW.  (ZERO IS
                TS              NJ-V                            # IN A FROM THE PRECEDING  "CCS JOBAXES".)

#                                                2
# TEST 1JACCQ - ABVAL(AOSQ) - 0.06 RADIANS/SECOND  GREATER THAN ZERO:

                CAE             1JACCQ                          # 1JACCQ SCALED AT PI/4 RADIANS/SECOND(2)
                EXTEND                                          # MULTIPLYING BY ONE-HALF CHANGES SCALING
                MP              BIT14                           # TO PI/2 RADIANS/SECOND(2) AS AOSQ.
                AD              -.06R/S2                        # -0.06 RADIANS/SECOND(2) SCALED AT PI/2.
                AD              ABVLAOSQ                        # ABVLAOSQ IS -ABVAL(AOSQ) AT PI/2.
                EXTEND                                          
                BZMF            POPNJ1                          # (BRANCH TO TEST ON SIGN(AOSQ).)

#                                                2
# TEST 1JACCR - ABVAL(AOSR) - 0.06 RADIANS/SECOND  GREATER THAN ZERO:

POPNJ4          CAE             1JACCR                          # 1JACCR SCALED AT PI/4 RADIANS/SECOND(2).
                EXTEND                                          # MULTIPLYING BY ONE-HALF CHANGES SCALING
                MP              BIT14                           # TO PI02 RADIANS/SECOND(2) AS AOSR.
                AD              -.06R/S2                        # -0.06 RADIANS/SECOND(2) AT PI/2.
                AD              ABVLAOSR                        # ABVLAOSR IS -BAVAL(AOSR) AT PI/2.
                EXTEND                                          
                BZMF            POPNJ2                          # (BRANCH TO TEST ON SIGN(AOSR).)

                TCF             POPNONJ                         # GO SET DATA GOOD BIT.



POPNJ1          CCS             AOSQ                            # SINCE MAGNITUDE OF AOSQ LARGE, NONZERO.
                TCF             POPNJ3                          
                TC              CCSHOLE                         
                TS              NJ+U                            # SET NJS FOR LARGE NEGATIVE AOSQ.
                TS              NJ-V                            
                TCF             POPNJ4                          # GO CHECK MAGNITUDE OF AOSR.

POPNJ3          TS              NJ-U                            # SET NJS FOR LARGE POSITIVE AOSQ.
                TS              NJ+V                            
                TCF             POPNJ4                          # GO CHECK MAGNITUDE OF AOSR.

POPNJ2          CCS             AOSR                            # SINCE MAGNITUDE OF AOSR LARGE, NONZERO.
                TCF             POPNJ5                          
ACCFIFTY        DEC             0.30679                         # .5(50) SEC(2)/RAD SCALED AT 2(+8)/PI.
## Page 626
                TS              NJ+U                            # SET NJS FOR LARGE NEGATIVE AOSR.
                TS              NJ+V                            
                TCF             POPNONJ                         # END NICELY.

POPNJ5          TS              NJ-U                            # SET NJS FOR LARGE POSITIVE AOSR.
                TS              NJ-V                            
                TCF             POPNONJ                         # END NICELY.

-.02R/S2        DEC             -.01273                         # -0.02 RADIANS/SECOND(2) AT PI/2

# THE FOLLOWING BRANCHES SUPPLY CONSTANT VALUES:

FIFTY1          CAF             ACCFIFTY                        
                TCF             FIFTY1R                         

FIFTY2          CAF             ACCFIFTY                        
                TCF             FIFTY2R                         

FIFTY3          CAF             ACCFIFTY                        
                TCF             FIFTY3R                          

## Page 627
# SUBROUTINE NAME: INVACC         MOD. NO. 0  DATE: DECEMBER 3, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS SUBROUTINE IS CALLED BY AOSJOB TO CALCULATE:

#                0.5       WHERE TEMPNET IS SCALED AT PI/2 RADIANS/SECOND(2)
#     C(A) =   -------
#              TEMPNET     AND THE FRACTION IS SCALED AT 2(+8)/PI SEC(2)/RAD.

# THIS SIMPLE COMPUTATION WAS SUBROUTINIZED DUE TO ITS FREQUENT USE.

# CALLING SEQUENCE: TC  INVACC

# SUBROUTINES CALLED: NONE.       NORMAL EXIT MODE: ONE INSTRUCTION AFTER CALL.

# ALARM OR ABORT EXIT MODES: NONE.

# INPUT: TEMPNET SCALED AT PI/2 RADIANS/SECONDS(2).

# OUTPUT: C(A) SCALED AT 2(+8)/PI SECONDS(2)/RADIAN.

# DEBRIS: L,Q.

INVACC          CAF             BIT7                            # BIT7 IS USED AS THE NUMERATOR 0.5 SINCE
                ZL                                              
                EXTEND                                          # "TEMPNET" IS SCALED AT PI/2 AND THE
                DV              TEMPNET                         
                TC              Q                               # INVERSE IS SCALED AT 2(+8)/PI.

## Page 628
# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

# FROM DPSENGON: SET FLAGS FOR CRITICAL GTS ENTRIES.

SETCNTR         TS              DVSELECT                        # SET SWITCH TO GO TO GIMBLMON

                EXTEND                                          
                DCA             GETADR                          # SPACE FOR NEW CODING IN BANK 17
                DXCH            Z                               

                EBANK=          TRIMCNTR                        
GETADR          2CADR           GETCNTR                         

# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************
