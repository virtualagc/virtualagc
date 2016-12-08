### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     AOSTASK.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        0630-0634
## Mod history:  2016-09-20 JL   Created.
##               2016-09-22 OH	 Initial Transcription
##               2016-10-05 HG   Add missing   TS ITEMP1
##                               Add missing page 634.
##                               use new formatting
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

## Page 0630
                BANK            25
                EBANK=          AOSQ

AOSTASK         CAF             BIT8                    # TEST POWERED ASCENT FLAG (BIT8/DAPBOOLS)
                MASK            DAPBOOLS                # 0- NOT POWERED ASCENT
                EXTEND                                  # 1- POWERED ASCENT
                BZF             COASTASC                # END CYCLE OF TASKS DURING ASCENT COAST
                                        
                CAE             KCOEFCTR                # TEST KCOEFCTR FOR INITIAL PASS
                EXTEND                                  
                BZF             ZEROCOEF                # DISCONTINUITY SECTION FOR COEFFA
                                        
                AD              DEC-399                 # TEST KCOEFCTR FOR CONSTANT RANGE
                EXTEND                                  # ON BOTH K AND COEFFA
                BZMF            +2                      
                TCF             KONENOW                 
                                        
                CAF             0.00125                 # COEFFA = 0.00125(T) + 0.25
                EXTEND                                  
                MP              KCOEFCTR                
                CAF             BIT13                   
                AD              L                       
COEFFA          TS              ITEMP2                  
                                        
                CAF             0.0014                  # K = 0.0014(T) + 0.44
                EXTEND                                  
                MP              KCOEFCTR                
                CAF             0.44                    
                AD              L                       
                TS              ITEMP1                  
                COM                                     # (1-K),QR SCALED AT 1
                AD              POSMAX                  # (1 BIT ERROR DOES NOT COMPOUND)
                TS              (1-K)QR                 
                                        
                EXTEND                                  # (1-K)/8 IS (1-K) SCALED AT 8
                MP              BIT12                   
                TS              (1-K)/8                 
                                        
                CAE             ITEMP1                  # WFORQR = K/DT SCALED AT 16
                EXTEND                                  
                MP              10AT16WL                # DT = .1 SECS
                TS              WFORQR                  
                                        
                CS              ITEMP1                  # FORM (.1-.05K) FROM K SCALED AT 1
                EXTEND                                  # WHICH IS USED AS IS BUT SINCE THESUM
                MP              .05AT.5                 # IS TO BE SCALED AT 1/2, THE TWO
                AD              .1AT.5                  # CONSTANTS REFLECT THAT SCALE FACTOR
                TS              ITEMP1                  
                                        
COEFFA1         CAE             ITEMP2                  # FORM COEFFA(AOSQ)
                EXTEND                          

## Page 0631

                MP              AOSQ
                TS              AOSQ                    # FIRST TERM OF NEW AOSQ, SCALED AT PI/2
                
                CAE             ITEMP2                  # FORM COEFFA(AOSR)
                EXTEND          
                MP              AOSR    
                TS              AOSR                    # FIRST TERM OF NEW AOSR, SCALED AT PI/2

## Next 5 lines were marked with a pencil as if they are highlighted
                CS              ITEMP2                  # FORM .5(1-COEFFA) SCALED AT 2
                EXTEND                                  # FROM COEFFA SCALED AT 1 WHICH IS THE
                MP              BIT13                   # SAME AS 2(COEFFA) SCALED AT 2
                AD              BIT13                   # SO MULTIPLY BY 1/4 TO GET .5(COEFFA)
                TS              ITEMP2                  # AND 1/4 IS 1/2 WHEN SCALED AT 2
## End marked lines             
                
                CS              OMEGAQ                  # SAVE PRESENT OMEGAQ FOR NEXT PASS
                XCH             OLDWFORQ                # GET -(LAST OMEGAQ)
                EXTEND          
                SU              SUMRATEQ                # FORM- W - W(OLD) - SUMRATE = SUM
                AD              OMEGAQ                  # SCALED AT PI/4 RADIANS/SECOND
                EXTEND          
                MP              ITEMP2                  # AOSQ = COEFFA(AOSQ)+.5(1-COEFFA)(SUM)
                ADS             AOSQ                    # SCALED AT PI/2 RADIANS/SECOND(2)
                
                CS              OMEGAR                  # SAVE PRESENT OMEGAQ FOR NEXT PASS
                XCH             OLDWFORR                # GET -(LAST OMEGAR)
                EXTEND          
                SU              SUMRATER                # FORM- W - W(OLD) - SUMRATE = SUM
                AD              OMEGAR                  # SCALED AT PI/4 RADIANS/SECOND
                EXTEND          
                MP              ITEMP2                  # AOSR = COEFFA(AOSR)+.5(1-COEFFA)(SUM)
                ADS             AOSR                    # SCALED AT PI/2 RADIANS/SECOND(2)
                
                CAE             ITEMP1  
                EXTEND                                  # FORM TERM FOR RATE DERIVATION
                MP              AOSQ                    # (.1-.05K)AOSQ
                TS              AOSQTERM                # SCALED AT PI/4 RADIANS/SECOND
                
                CAE             ITEMP1  
                EXTEND                                  # FORM TERM FOR RATE DERIVATION
                MP              AOSR                    # (.1-.05K)AOSR
                TS              AOSRTERM                # SCALED AT PI/4 RADIANS/SECOND
                
                CAE             AOSQ                    # FORM AOS FOR U-AXIS
                AD              AOSR    
                EXTEND          
                MP              .707WL  
                TS              AOSU                    # SCALED AT PI/2 RADIANS/SECOND(2)
                
                CS              AOSQ                    # FORM AOS FOR V-AXIS
                AD              AOSR    
        
## Page 0632
                EXTEND
                MP              .707WL
                TS              AOSV                    # SCALED AT PI/2 RADIANS/SECOND(2)
                
                CAF             THREE                   # SET UP LOOP FOR Q,R,U,V-AXES
                TS              AXISCNTR        
                
ALLAXES         INDEX           AXISCNTR        
                CCS             AOSQ                    # FORM ABSOLUTE VALUE OF AOS
                AD              ONE     
                TCF              +2     
                AD              ONE     
                INDEX           AXISCNTR                # SAVE IN ITEMP REGISTER (3-6)
                TS              ABVLAOSQ                # SCALED AT PI/2 RADIANS/SECOND(2)
                AD              -.02R/S2                # -.02 RADIANS/SECOND(2) SCALED AT PI/2
                EXTEND          
                BZMF            CONSTMIN                # USE 1/(.02) SEC(2)/RAD AS 1/AMIN
                AD              +.02R/S2        
                TS              ITEMP2  
                CAF             BIT7    
                ZL                                      # SCALE FACTOR FOR .5ACCMIN.
                EXTEND          
                DV              ITEMP2  
ACCMINVL        INDEX           AXISCNTR        
                TS              .5ACCMNQ                # SCALED AT 2(+8)/PI
                
                CAF             -.02R/S2                # CALCULATE ONE OF THE FOLLOWING (4) SUMS:
                EXTEND                                  # 2JETAC(Q,R)-ABAOS(Q,R)-.02RAD/SEC(2) OR
                INDEX           AXISCNTR                # 1JETAC(U,V)-ABAOS(1,V)-.02RAD/SEC(2)
                SU              ABVLAOSQ                # EACH SUM HAS EACH TERM SCALED AT PI/2
                INDEX           AXISCNTR                # THE "OUTER LOOP" IS DEFINED TO CALCULATE
                AD              1JACCQ                  # THE VALUES 1JACCQ, 1JACCR SCALED AT PI/4
                EXTEND                                  # AND 1JACCU, 1JACCV SCALED AT PI/2 WHERE
                BZMF            DEMANDAC                # 1JACCU = 2(.707)(1JACCQ+1JACCR) AND
                CAF             ZERO                    # 1JACCV = 2(.707)(1JACCQ+1JACCR)
                INDEX           AXISCNTR                # WHERE THE CALCULATIONS USE THE FACT THAT
                TS              QMANDACC                # 1JACC(Q,R) AT PI/4 = 2JACC(Q,R) AT PI/2
                INDEX           AXISCNTR                # MANDACC(Q,R)=1 MEANS USE 4 JETS, 0 FOR 2
                CAE             1/2JTSQ                 # MANDACC(U,V)=1 MEANS USE 2 JETS, 0 FOR 1
                EXTEND          
                MP              BIT14   
AXISLOOP        INDEX           AXISCNTR                # SET UP 1/NJTSX TO 1/2JTSX FOR URGENCY
                TS              1/NJTSQ                 # (DOES NOT COUNT FOR U,V-AXES)
                
                CCS             AXISCNTR                # DECREMENT LOOP COUNTER AND TEST FOR END
                TCF              +2     
                TCF             NEXTCALL                # FINISHED LOOP
                
                TS              AXISCNTR        
                TCF             ALLAXES                 # CONTINUE LOOP
                
## Page 0633             
CONSTMIN        CAF             AMINCNST                # 1/AMIN = 1/(.02) SEC(2)/RAD AT 2(8)/PI
                TCF             ACCMINVL        
                
DEMANDAC        CAF             POSMAX                  # SET MANDATORY HIGH ACCELERATION FLAG TO
                INDEX           AXISCNTR                # OVER-RIDE 2 JET DECISION FOR Q,R-AXES OR
                TS              QMANDACC                # 2 JET OPTIONAL DECISION FOR U,V-AXES
                INDEX           AXISCNTR                # FORM 1/4JTSX VALUE FOR USE IN URGENCY
                CAE             1/2JTSQ                 # FROM 1/2JTSX
                EXTEND                                  # (DOES NOT COUNT FOR U,V-AXES)
                MP              BIT13   
                TCF             AXISLOOP        
                
ZEROCOEF        CAF             TWO                     # INITIALIZE TIME SETTING
                TS              KCOEFCTR        
                CAF             ZERO    
                TCF             COEFFA  
                
KONENOW         CAF             ZERO                    # K=1, SO 1-K AT EITHER SCALING IS ZERO
                ZL                                      # EXTEND, DCA DPZERO IS FASTER BUT WASTES
                DXCH            (1-K)QR                 # STORAGE IN SWITCHED FIXED UNLESS IN FF
                CAF             10AT16WL                # WFORQR = K/DT = 10K = 10
                TS              WFORQR                  # SCALED AT 16
                CAF             .05AT.5                 # SAVE (.1-.05K) SCALED AT 1/2
                TS              ITEMP1                  # FOR AOSTERMS
                CAF             .75                     # SET COEFFA = .75
                TS              ITEMP2  
                TCF             COEFFA1 
NEXTCALL        CAF             2SECSAOS                # SET UP WAITLIST CALL FOR TWO SECS
                TC              WAITLIST        
                2CADR           AOSTASK 
                
                CAF             TWO                     # INCREMENT TIME COUNTER
                ADS             KCOEFCTR        
                CAF             ZERO                    # ZERO SUMMED RATES
                TS              SUMRATEQ        
                TS              SUMRATER
                TCF             TASKOVER
        
COASTASC        CAF             0.3125WL
## Next line has red markup pointing to: WFORQR <--- WFORP
                TS              WFORQR
                EXTEND
                DCA             (1-K)S
                DXCH            (1-K)QR
## Next 4 lines circled in red also some faint markup pointing to ??
## as if something is wrong or not clear what the code is doing
                CAF             BIT3
                MASK            DAPBOOLS
                AD              BIT3
                TS              DAPBOOLS
                CAF             0.30680
                TS              .5ACCMNE
                TS              .5ACCMNQ
                
## Page 634     
                TS              .5ACCMNR
                TS              .5ACCMNU
                TS              .5ACCMNV
                EXTEND
                DCA             1/2JTSQ
                DXCH            1/NJTSQ
                EXTEND
                DCA             1/2JETSU
                DXCH            1/NJTSU
## Note: the next three instructions are bracketed with a black pencil mark to the left of the instruction parameter
                CAF             0.00167A
                TS              MINIMPDB
                TS              DBMINIMP
                CAF             ZERO
                TS              AOSQ
                TS              AOSR
                TS              AOSQTERM
                TS              AOSRTERM
                TS              QMANDACC
                TS              RMANDACC
                TS              UMANDACC
                TS              VMANDACC
                TCF             TASKOVER
                
AXISCNTR        EQUALS          ITEMP1
DEC-399         DEC             -399                    # BOUND FOR CONSTANT RANGE: T.GE.400 SECS.
0.0012          DEC             0.0012
0.52            DEC             0.52
DEC-160         DEC             -160
0.0024          DEC             0.0024
0.366           DEC             0.366
.05AT.5         DEC             0.1
.1AT.5          DEC             0.2
.707WL          DEC             0.70711                 ## Note: the following appears handrwiten
-.02R/S2        DEC             -.01273                 ## in red ink in the comments column
.04R/S2         DEC             0.02546                 ## WCHANGER  CAF  0.3/25WL
0.30680         DEC             0.30680                 ## TS        WFORP
10AT16WL        DEC             0.625                   ## TS        WFORQR        
.75             DEC             0.75                    ## EXTEND
AMINCNST        EQUALS          0.30680                 ## DCA       (1-K)S
2SECSAOS        DEC             200                     ## DXCH      (1-K)QR
0.3125WL        DEC             0.3125
0.00167A        DEC             0.00167
0.00125         DEC             0.00125
0.0014          DEC             0.0014
0.44            DEC             0.44
+.02R/S2        DEC             0.01273
(1-K)S          DEC             0.5
                DEC             0.0625
                



