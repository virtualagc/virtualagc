### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AOSTASK_AND_AOSJOB.agc
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
## Reference:   pp. 569-590
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##		2017-06-09 RSB	Transcribed.
##              2017-06-14 HG   Add missing label STCTR1
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 569
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
## Page 570
#                                         NJ-U     EQUALS NJ+Q +5         AOS) IS SET TO 1.  OTHERWISE, THE VALUE
#                                         NJ+V     EQUALS NJ+Q +6         IS ZERO.  THESE FLAGS PREVENT TWO JETS
#                                         NJ-V     EQUALS NJ+Q +7         FROM BEING REQUESTED TO FIGHT THE AOS.

## Page 571

# AOSTASK IS EXECUTED ONLY DURING POWERED ASCENT.  IF NO LONGER IN POWERED ASCENT, STOP THE CYCLING OF AOSTASK AND
# SET UP VARIABLES FOR COASTING ASCENT.

                BANK            20                              
                EBANK=          AOSQ                            

AOSTASK		CAF		APSGOING			# TEST POWERED ASCENT FLAG:
		MASK		DAPBOOLS			# 0: NOT POWERED ASCENT (ASCENT COAST)
		EXTEND						# 1: POWERED ASCENT
		BZF		COASTASC			# (END CYCLE OF TASKS DURING ASCENT COAST)

# KEEP TRACK OF LENGTH OF BURN FOR DETERMINATION OF WEIGHTING FACTOR K:

	        CAE             KCOEFCTR                        # TEST KCOEFCTR FOR INITIAL PASS.
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
## Page 572
                TS              WFORP                           # WFORP IS IDENTICAL WFORQR EXCEPT FOR THE
                TS              WFORQR                          # INITIALIZATION IN STARTDAP OF DAPIDLER.

                CS              K                               # FORM (.1-.05K) FROM K SCALED AT 1 FOR
                EXTEND                                          # THE TORQUE VECTOR RECONSTRUCTION AND
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

## Page 573
# CALCULATE THE OFFSET ACCELERATIONS FOR THE U,V-AXES:

                CAE             AOSQ                            # FIRST, CALCULATE AOSU:
                AD              AOSR                            
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
                
# SET UP AOS JOB FOR THE NEWEST OFFSET ACCELERATION ESTIMATES:

		CAF		PRIO24				# *** VERIFY PRIORITY. ***
		TC		NOVAC				# SET UP AOSJOB.
		EBANK=		AOSQ
		2CADR		AOSJOB                

# SET ERASABLES FOR NEXT 2 SECOND INTERVAL:

                CAF             TWO                             # INCREMENT BURN DURATION TIMER BY 2 SECS.
                ADS             KCOEFCTR                        

                CAF		ZERO				# INITIALIZE SUMS OF JETRATES.
                TS		SUMRATEQ
                TS		SUMRATER   

# SET UP NEXT WAITLIST AOSTASK FOR 2 SECONDS FROM NOW:

		CAF		2SECSDAP
		TC		VARDELAY			# (STORAGE-SAVING WAITLIST CALL.)
		TCF		AOSTASK				# RETURNS HERE IN TWO SECONDS.
		
## Page 574                            
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

                CAF             0.05				# (.1-.05K) = 0.05
                DOUBLE						# (DOUBLING SAVES CONSTANT STORAGE.)
                TS              .1-.05K                         # SCALED AT 1/2. (VOLATILE STORAGE.)

                CAF             BIT13-14                        # COEFFA = 0.75
                TS              COEFFA                          # SCALED AT 1.   (VOLATILE STORAGE.)

                TCF             COEFFA1                         # GO BEGIN OFFSET ACCELERATION ESTIMATE.

# SHUT-DOWN PROCEDURE AFTER ASCENT COAST DETECTION:

COASTASC	CAF		PRIO24				# *** VERIFY PRIORITY. ***
		TC		NOVAC				# SET UP FINAL AOSJOB FOR THIS APS BURN.
		EBANK=		AOSQ
		2CADR		AOSJOB
		
		TCF		TASKOVER			# END AOSTASK CYCLING FOR THIS APS BURN.

## Page 575
# CONSTANTS FOR AOSTASK:

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

## Page 576
# PROGRAM NAME: WCHANGER          MOD. NO. 0  DATE: DECEMBER 9, 1966

		TCF		TASKOVER

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

                TCF             TASKOVER                        # END THIS TASK.

## Page 577
# INERPOLY COMPUTES IXX, IYY, IZZ, AND, IN DESCENT, L,PVT-CG.
# AFTER THE INERTIAS ARE COMPUTED, THEY ARE USED TO COMPUTE NEW VALUES OF
# 1JACC, 1JACCQ, 1JACCR, 1JACCU, 1JACCV AND 1/2JTSP.
# INERPOLY EXITS BY .... TCF ENDOFJOB


                BANK            26     
                                         
                EBANK=          IXX                             
INERPOLY        CA              BIT2                            
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

STCTR1	        CA              MASS                            # IN KGS (+15)
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

## Page 578
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
                TS              1/2JTSP                        
                CAE             IXX                             
                EXTEND                                          
                DV              1/2JTSP                        
                DOUBLE                                          
                TS              1/2JTSP                         # SCALED BY 1/PI (+8)

                CAF             BIT2                            
                EXTEND                                          
                RAND            30                              
                CCS             A                               # COMPUTE L,PVT-CG IF IN DESCENT
                TCF             DES                             
                TCF             ENDOFJOB      
                                  
DES             CS              ONE                             
                TS              INERCTR                         
                TS              INERCTRX                        
                TCF             STCTR1                          

LRESC 		CA		L,PVT-CG			# SCALED BY (+6)

		DOUBLE
		DOUBLE
		DOUBLE
		TS		L,PVT-CG			# SCALED BY (+3)
		TCF		ENDOFJOB
		
		
		DEC		0.75524				# L
INERCONC	DEC		0.01432				# XD
		DEC		-0.66136			# YD
		DEC		-0.68173			# ZD
		DEC		0.05092				# XA
## Page 579
                DEC             -0.65325			# YA                       
                DEC             -0.59815			# ZA                       
                DEC             -0.67640			# L
INERCONB        DEC             0.17030				# XD
                DEC             0.65955				# YD                       
                DEC             0.63041				# ZD                      
                DEC             0.18033				# XA                        
                DEC             0.20478				# YA                         
                DEC             0.36855				# ZA                        
                DEC             0.20044				# L                         
INERCONA        DEC             0.00676				# XD                        
                DEC             -0.06090			# YD                       
                DEC             -0.04403			# ZD                         
                DEC             -0.00435			# XA                        
                DEC             -0.00170			# YA                        
                DEC             -0.02132			# ZA
                                        
TORKJET         2DEC            0.002428512                     

TORKJET1        2DEC            0.002671365                     

4JTORK          DEC             .62170  

## Page 580                        
# PROGRAM NAME: AOSJOB            MOD. NO. 0   DATE: DECEMBER 2, 1966
# PROGRAM DESIGN BY: RICHARD D. GOSS (MIT/IL)

# IMPLEMENTATION BY: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THE PROGRAM IS AN EXECUTIVE JOB WHICH CALCULATES THE FOLLOWING QUANTITIES FOR THE LM DAP T5RUPT PROGRAMS:
#          1. THE INVERSES OF THE NET ACCELERATIONS ABOUT ALL AXES (Q,R,U,V), IN ALL DIRECTIONS (+/-), AND ALL
#             COMBINATIONS OF JETS (2/4 FOR Q,R AND 1/2 FOR U,V).
#          2. THE INVERSES OF THE MINIMUM ACCELERATIONS FOR THE URGENCY AND TJETLAW COMPUTATION, DURING APS BURNS.
#          3. THE INITIAL INVERSE NET ACCELERATIONS USED FOR THE URGENCY COMPUTATION, DURING APS BURNS.
#          4. THE NJ FLAGS TO REQUIRE MANDATORY JET ACCELERATION DURING APS BURNS.

# CALLING SEQUENCE:               SUBROUTINES CALLED: INVACC.

#					  L -1     CAF    PRIO24
#					  L	   TC	  NOVAC
#					  	   EBANK= AOSQ
#					  L +1     2CADR  AOSJOB
#					  L +2	  (BBCON)
#					  L +3    (RETURN)

# NORMAL EXIT: ENDOFJOB.          ALARM/ABORT EXITS: NONE.

# INPUT: AOSQ,AOSR,AOSU,AOSV,1JACCQ,1JACCR,1JACCU,1JACCV,APSGOING/DAPBOOLS.

# DEBRIS: NONE.

## Page 581
                BANK            20                              
                EBANK=          AOSQ   
                
-.02R/S2	DEC		-.12732				# -.02 RADIANS/SECOND(2) SCALED AT PI/2
ACCFIFTY	DEC		0.30679				# .5(50) SEC(2)/RAD SCALED AT 2(+8)/PI.                         

# SET UP LOOP FOR FOUR AXES (IN THE ORDER: V,U,R,Q):

AOSJOB          CAF             FOUR                            # "JOBAXES" IS USED TO PICK UP ONE OF FOUR
INVLOOP         TS              JOBAXES                         # ADJACENT REGISTERS, ALSO TO COUNT LOOP.

# SET UP "TABPLACE" TO STORE 1/NETACC TABLE:

                EXTEND                                          # TABPLACE = 4(JOBAXES)
                MP              FOUR                            # SINCE THERE ARE FOUR ENTRIES PER AXIS.
                LXCH            TABPLACE                        

#                                                      2
#            2(1JACC   ) + AOS    - 0.02 RADIANS/SECOND  GREATER THAN ZERO
#                   Q,R       Q,R
#         OR                                           2
#               1JACC    + AOS    - 0.02 RADIANS/SECOND  GREATER THAN ZERO
#                    U,V      U,V

                INDEX           JOBAXES                         # THE INDEXED PICK-UP OF JET ACCELERATIONS
                CAE             1JACCQ                          # USES THE FOLLOWING HAPPY COINCIDENCE:
                TS              TEMPACC                         # 1JACCU AND 1JACCV ARE SCALED AT PI/2 AS
                INDEX           JOBAXES                         # ARE AOSU AND AOSV.  1JACCQ AND 1JACCR
                AD              AOSQ                            # ARE SCALED AT PI/4 AND THEREFORE ARE
                TS              TEMPNET                         # EQUIVALENT TO 2(1JACCQ) AND 2(1JACCR)
                AD              -.02R/S2                        # SCALED AT PI/2 AS ARE AOSQ AND AOSR.
                EXTEND                                         	# -.02R/S2 IS -0.02 RADIANS/SECOND(2),PI/2 
                
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

## Page 582
                INDEX           JOBAXES                         # THIS SECTION USES THE INDEXING TRICKS OF
                CS              AOSQ                            # THE FIRST PART (ABOVE), BUT USES THE
                TS              TEMPAOS                         # TEMPORARY LOCATIONS AS FOLLOWS:
                AD              TEMPACC                         # "TEMPAOS" SAVES -AOS FOR THIS AXIS.
                TS              TEMPNET                         # "TEMPACC" HAS THE JET ACCELERATION.
                AD              -.02R/S2                        # "TEMPNET" SAVES (JETACC-AOS) FOR DENOM.
                EXTEND                                          # -.02R/S2 IS -0.02 RADIANS/SECOND(2),PI/2
                BZMF            FIFTY2                          # (BRANCH FOR CONSTANT VALUE OF INVERSE.)

#            1/NET-2    = 1/( 2(1JACC  ) - AOS   )
#                   Q,R             Q,R       Q,R
#        OR
#            1/NET-1    = 1/( 1JACC    - AOS   )
#                   U,V            U,V      U,V

                TC              INVACC                          
FIFTY2R         INDEX           TABPLACE                        
                TS              1/NET-2Q                        # SCALED AT 2(+8)/PI SECONDS(2)/RADIAN.

#            1/NET-4    = 1/( 4(1ACC    - AOS   )
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

## Page 583
#            1/NET+4    = 1/( 4(1ACC    + AOS   )
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
                
                TCF		ENDOFJOB			# END THIS ITERATION OF AOSJOB.             

## Page 584
# IN ASCENT BURN, SO SET UP Q,R-AXES LOOP:

ASCJOB          CAF             ONE                             # SET UP THE TABLE INDICES:
QRJOB           TS              JOBAXES                         
                DOUBLE                                          # AOS TABLE USES "JOBAXES"  (ADJACENT).
                TS              NJPLACE                         # NJ  TABLE USES "NJPLACE"  (ONE APART).
                DOUBLE                                          # NET TABLE USES "TABPLACE" (THREE APART).
                TS              TABPLACE                        

# TEST ABVAL(AOS   ) - 0.02 RADIANS/SECOND(2) GREATER THAN ZERO:
#               Q,R

                INDEX           JOBAXES                         # FORM ABVAL(AOS   ) AND SAVE FOR INVACC.
                CCS             AOSQ                            #               Q,R
                AD              ONE                             
                TCF             +2                              
                AD              ONE                             
                TS              TEMPNET                         
                AD              -.02R/S2                        # -0.02 RADIANS/SECOND(2) AT PI/2.
                EXTEND                                          
                BZMF            FIFTY3                          # (BRANCH FOR CONSTANT VALUE OF INVERSE.)

# CALCULATE 1/AMIN    = 1/ABVAL(AOS   ):
#                 Q,R              Q,R

                TC              INVACC                          # (USE SUBROUTINE FOR INVERSE.)
                
FIFTY3R         INDEX           JOBAXES                         
                TS              1/AMINQ                         # SAVE FOR USE BY URGENCY CALCULATIONS.

# TEST 2(1JACC   ) - ABVAL(AOS   ) - 0.02 RADIANS/SECOND(2) GREATER THAN ZERO:
#             Q,R             Q,R

                CS              TEMPNET                         # "TEMPNET" IS ABVAL(AOSQ,R).
                AD              -.02R/S2                        # -0.02 RADIANS/SECOND(2).
                INDEX           JOBAXES                         
                AD              1JACCQ                          # "1JACCQ,R" SCALED AT PI/4 RAD/SEC(2) ARE
                EXTEND                                          # 2(1JACCQ,R) SCALED AT PI/2 RAD/SEC(2).
                BZMF            OVERRIDE                        

# SET FLAG NOT TO REQUEST MANDATORY FOUR JET OPERATION FOR +Q,+R ROTATION DURING THIS APS BURN (FOR NOW):

                CAF             ZERO                            # NJ = 0 ALLOWS THE URGENCY FUNCTIONS TO
                INDEX           NJPLACE                         # ACTUALLY SELECT 2 JET ROTATION AS THE
                TS              NJ+Q                            # OPTIMAL POLICY.

# TEST SIGN(AOS   ):
#              Q,R

                INDEX           JOBAXES                         # THE SIGN OF AOSQ,R DETERMINES THE RATIO
                
                CAE             AOSQ                            # TO BE COMPUTED AS THE CORRECTION FACTOR
## Page 585
                EXTEND                                          # IN THE URGENCY FUNCTION CALCULATION AND
                BZMF            URGRAT2                         # ALSO SPECIFIES THE CURRECT NJ VALUES.

# FIRST CASE FOR URGENCY RATIO:

URGRAT1         INDEX           TABPLACE                        # CHOOSE THE -2 JET NET ACCELERATION
                CAE             1/NET-2Q                        # INVERSE FOR USE IN URGENCY COMPUTATION.
                INDEX           JOBAXES           
                              
                TS              1/ACCQ                          

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

OVERRIDE        INHINT                                          # PREVENT POSSIBLY EPHEMERAL MANDATORY NJ
                                                                # SETTING FROM AFFECTING JET SELECTION.
                                                                
                CAF		ONE				# NJ = 1 FORCES THE URGENCY FUNCTIONS TO
                INDEX           NJPLACE                         # ACTUALLY SELECT 4 JET ROTATION AS THE
                TS              NJ+Q                            # OPTIMAL POLICY (TO FIGHT HIS AOS).
                                                                
# TEST SIGN(AOS   ):
#              Q,R

                INDEX           JOBAXES                         # THE SIGN OF AOSQ,R DETERMINES THE RATIO
## Page 586
                CAE             AOSQ                            # TO BE COMPUTED AS THE CORRECTION FACTOR
                EXTEND                                          # IN THE URGENCY FUNCTION CALCULATION AND
                BZMF            URGRAT4                         # ALSO SPECIFIES THE CORRECT NJ VALUES.

# THIRD CASE FOR URGENCY RATIO:

URGRAT3         INDEX           TABPLACE                        # CHOOSE THE -4 JET NET ACCELERATION
                CAE             1/NET-4Q                        # INVERSE FOR USE IN URGENCY COMPUTATION.
                INDEX           JOBAXES                         
                TS              1/ACCQ                          

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

                TCF             UVJOB				# GO PROCESS U- AND V-AXIS.

# FOURTH CASE FOR URGENCY RATIO:

URGRAT4         RELINT                                          # SINCE ALL NJS ALREADY SET ARE NOW KNOWN
                                                                # TO BE VALID, ALLOW INTERRUPTS.

                INDEX           TABPLACE                        # CHOOSE THE +4 JET NET ACCELERATION
                
                CAE             1/NET+4Q                        # INVERSE FOR USE IN URGENCY COMPUTATION.
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

## Page 587
NXTNJZER        CAF             ZERO                            # SET NJ      = 0  TO LET THE URGENCY
                INDEX           NJPLACE                         #       -Q,-R      FUNCTIONS SELECT 2 JET
                TS              NJ-Q                            #                  -Q,-R ROTATION

# TEST FOR END OF Q,R-AXES LOOP:

	        CCS             JOBAXES                         # JOBAXES = 1 MEANS GO DO Q-AXIS.
                TCF             QRJOB                           # JOBAXES = 0 MEANS GO DO U,V-AXES.

## Page 588
# AFTER Q,R-AXES COMPLETE, DO U,V-AXES LOOP:

UVJOB           CAF		ONE				# SET UP THE TABLE INDICES:
UJOB		TS		JOBAXES
		DOUBLE						# AOS TABLE USES "JOBAXES" (ADJACENT).
		TS		NJPLACE				# NJ  TABLE USES "NJPLACE" (ONE APART).

# TEST ON ABVAL(AOS   ) - 0.02 RADIANS/SECOND(2) GREATER THAN ZERO:
#		   U,V

#              U,V            U,V

		INDEX		JOBAXES				# CALCULATE ABVAL(AOS   ) SCALED AT PI/2.
		CCS		AOSU				#                    U,V
		AD		ONE
		TCF		+2
		AD		ONE
		TS		TEMPNET				# SVAE ABVAL(AOSU,V) FOR USE BY INVACC.
		AD		-.02R/S2			# -0.02 RADIANS/SECOND(2) SCALED AT PI/2
		EXTEND
		BZMF		FIFTY4				# (BRANCH FOR CONSTANT VALUE OF INVERSE.)
		
		TC		INVACC
FIFTY4R		INDEX		JOBAXES
		TS		1/AMINU				# SCALED AT 2(+8)/PI SECONDS(2)/RADIAN.
		
# TEST ON IJACC    - ABVAL(AOS   ) - 0.02 RADIANS/SECOND(2) GREATER THAN ZERO:
#	       U,V            U,V

		CS		TEMPNET				# -ABVAL(AOSU,V) SCALED AT PI/2 RAD/SEC(2)
		AD		-.02R/S2			# -0.02 RADIANS/SECOND(2) SCALED AT PI/2.
		INDEX		JOBAXES
		AD		1JACCU				# 1 JET U,V-AXIS ACCELERATION AT PI/2.
		EXTEND
		BZMF		RIDEOVER
		
# SET NJ      = 0.
#       +U,+V

		CAF		ZERO				# ALLOW URGENCY FUNCTIONS TO ACTUALLY
		TCF		+3				# SELECT 2 JET OPTIONAL ROTATION.
		
# SET NJ      = 1.
#       +U,+V

RIDEOVER	INHINT						# PREVENT POSSIBLE EPHEMERAL MANDATORY NJ
								# SETTING FROM AFFECTING JET SELECTION.
								
		CAF		ONE				# NJ = 1 FORCES THE URGENCY FUNCTIONS TO
		INDEX		NJPLACE				# ACTUALLY SELECT 2 JET MANDATORY ROTATION	
## Page 589
		TS		NJ+U				# AS OPTIMAL POLICY (TO FIGHT HIGH AOS).

# TEST SIGN(AOS   ):
#	       U,V

		INDEX		JOBAXES				# IF GREATER THAN ZERO, SWITCH NJS.
		CAE		AOSU
		EXTEND						# IF LESS THAN ZERO, SET NJ      = 0.
		
		BZMF		ZERNJNXT			#                          -U,-V
		
		CAF		ZERO				# SET NJ      = NJ      (FROM ABOVE)
		INDEX		NJPLACE				#       -U,-V     +U,+V
		XCH		NJ+U				# AND
		INDEX		NJPLACE				#     NJ      = 0.
		TS		NJ-U				#       +U,+V
		
		RELINT						# ALLOW INTERRUPTS AS SOON AS NJS STABLE.
		
		TCF		VJOBTEST			# GO TO TEST FOR END OF LOOP.
		
ZERNJNXT	RELINT						# ALLOW INTERRUPTS SINCE SETTINGS VALID.

		CAF		ZERO				# SET NJ     = 0.
		INDEX		NJPLACE				#       -U,-V
		TS		NJ-U
		
# TEST FOR END OF UV-AXES LOOP:

VJOBTEST	CCS		JOBAXES				# JOBAXES = 1 MEANS GO DO U-AXIS.
		TCF		UJOB				# JOBAXES = 0 MEANS QUIT
		TCF		ENDOFJOB
		

# THE FOLLOWING BRANCHES SUPPLY CONSTANT VALUES:

FIFTY1          CAF             ACCFIFTY                        
                TCF             FIFTY1R                         

FIFTY2          CAF             ACCFIFTY                        
                TCF             FIFTY2R                         

FIFTY3          CAF             ACCFIFTY                        
                TCF             FIFTY3R                          

FIFTY4		CAF		ACCFIFTY
		TCF		FIFTY4R
## Page 590
# SUBROUTINE NAME: INVACC         MOD. NO. 0  DATE: DECEMBER 3, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS SUBROUTINE IS CALLED BY AOSJOB TO CALCULATE:

#                0.5    WHERE TEMPNET IS SCALED AT PI/2 RADIANS/SECOND(2)
#     C(A) =   -------
#              		AND THE FRACTION IS SCALED AT 2(+8)/PI SEC(2)/RAD.S(2)/RADIAN.

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
