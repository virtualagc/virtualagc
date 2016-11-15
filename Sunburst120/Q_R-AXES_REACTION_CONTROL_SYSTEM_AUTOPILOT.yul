### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	Q_R-AXES_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc
## Purpose:	A module for revision 0 of BURST120 (Sunburst). It 
##		is part of the source code for the Lunar Module's
##		(LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2016-09-30 RSB	Created draft version.
##		2016-10-30 RSB	Transcribed through page 537.
##		2016-10-31 RSB	Transcribed.  Boo!
##		2016-10-31 RSB	Typos.
##		2016-11-01 RSB	More typos.
##		2016-11-02 RSB	More typos.
                                                                                
P0001   Q,R-AXES REACTION CONTROL SYSTEM AUTOPILOT                              
## Page 519
 0002            BANK   17                                                      
R0003   THE FOLLOWING T5RUPT ENTRY BEGINS THE PROGRAM WHICH CONTROLS THE Q,R-AXIS ACTION OF THE LEM USING THE RCS JETS.
R0004   THE NOMINAL TIME BETWEEN THE Q,R-AXIS RUPTS IS 100 MS (UNLESS THE TRIM GIMBAL CONTROL SYSTEM IS USED, IN WHICH
R0005   CASE THIS PROGRAM IS IDLE).                                             
                                                                                
 0006            EBANK= DT                                                      
 0007   NULLFILT 2CADR  FILDUMMY                                                
                                                                                
 0008   QRAXIS   CAF    MS20QR          RESET TIME IMMEDIATELY - DT = 20 MS     
 0009            TS     TIME5                                                   
                                                                                
 0010            LXCH   BANKRUPT        INTERRUPT LEAD IN (CONTINUED)           
 0011            EXTEND                                                         
 0012            QXCH   QRUPT                                                   
                                                                                
R0013   SET UP DUMMY KALMAN FILTER T5RUPT.  (THIS MAY BE RESET TO THE KALMAN FILTER INITIALIZATION PASS, IF THE TRIM
R0014   GIMBAL CONTROL SYSTEM SHOULD BE USED.)                                  
                                                                                
 0015            EXTEND                                                         
 0016            DCA    NULLFILT                                                
                                                                                
R0017   START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*****************
                                                                                
 0018   INSERT17 TCF    TRMCHECK        ARE EXTRAORDINARY GTS ENTRIES NEEDED?   
R0019   **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****************
                                                                                
R0020   CALCULATE LEM BODY RATES FOR Q AND R AXES:                              
                                                                                
R0021   THIS COMPUTATION IS VALID FOR BOTH ASCENT ADN DESCENT SINCE THE OFFSET ACCELERATION TERM IS INCLUDED ALWAYS,
R0022   BUT HAS VALUE ZERO IN DESCENT, AND SINCE THE WEIGHTING FACTORS ARE IN ERASABLE AND DISTINCT.
                                                                                
R0023   FIRST, CONSTRUCT Y AND Z CDU INCREMENTS:                                
                                                                                
 0024   BODYRATE CAE    CDUY            2:S COMPLEMENT MEASUREMENT SCALED AT PI 
 0025            TS     L               (SAVE FOR UPDATING OF OLDYFORQ)         
 0026            EXTEND                 FORM INCREMENT IN CDUY FOR LAST 100 MS  
 0027            MSU    OLDYFORQ        (100 MS OLD CDUY SAVED FROM LAST PASS)  
 0028            LXCH   OLDYFORQ        UPDATE OLDYFORQ WITH NEW CDUY VALUE     
 0029            TS     ITEMP1          SAVE 1:S COMPLEMENT VALUE TEMPORARILY   
 0030            CAE    CDUZ            2'S COMPLEMENT MEASUREMENT SCALED AT PI 
 0031            TS     L               (SAVE FOR UPDATING OF OLDZFORQ)         
 0032            EXTEND                 FORM INCREMENT IN CDUZ FOR LAST 100 MS  
 0033            MSU    OLDZFORQ        (100 MS OLD CDUZ SAVED FROM LAST PASS)  
 0034            LXCH   OLDZFORQ        UPDATE OLDZFORQ WITH NEW CDUZ VALUE     
 0035            TS     ITEMP2          SAVE 1'S COMPLEMENT VALUE TEMPORARILY   
                                                                                
## Page 520
R0036   SECOND TRANSFORM CPU INCREMENTS TO BODY-ANGLE INCREMENTS:               
                                                                                
 0037            CAE    M31             MATRIX*VECTOR(WITH x COMPONENT ZERO)    
 0038            EXTEND                                                         
 0039            MP     ITEMP1          M31 * ITEMP1 = M31 * DELTA CDUY         
 0040            DXCH   ITEMP4                                                  
 0041            CAE    M32             M32 * ITEMP2 = M32 * DELTA CDUZ         
 0042            EXTEND                                                         
 0043            MP     ITEMP2          DELTAR = M31*(DEL CDUY) + M32*(DEL CDUZ)
 0044            DAS    ITEMP4          DOUBLE PRECISION R BODY ANGLE INCREMENT 
                                                                                
 0045            CAF    BIT9                                                    
 0046            TS     Q                                                       
 0047            EXTEND                                                         
 0048            DCA    ITEMP4                                                  
 0049            EXTEND                                                         
 0050            DV     Q               RESCALE TO PI/64 AND                    
 0051            TS     ITEMP4          STORE AS SINGLE PRECISION               
 0052            CAE    M21             MATRIX*VECTOR(WITH X COMPONENT ZERO)    
 0053            EXTEND                 CLOBBERS ITEMP2=DEL CDUZ, FOR EFFICIENCY
 0054            MP     ITEMP1          M21 * ITEMP1 = M21 * DELTA CDUY         
 0055            DXCH   ITEMP2          M22 * ITEMP2 = M22 * DELTA CDUZ         
 0056            EXTEND                                                         
 0057            MP     M22             DELTAQ = M21*(DEL CDUY) + M22*(DEL CDUZ)
 0058            DAS    ITEMP2          DOUBLE PRECISION Q-BODY-ANGLE INCREMENT 
 0059            EXTEND                                                         
 0060            DCA    ITEMP2                                                  
 0061            EXTEND                                                         
 0062            DV     Q               RESCALE TO PI/64                        
R0063   FINALLY, DERIVE Q AND R BODY ANGULAR RATES:                             
                                                                                
 0064            EXTEND                 WFORQR IS K/(NOMINAL DT) SCALED AT 16   
 0065            MP     WFORQR          FORM WEIGHTED VALUE OF MEASURED DATA    
 0066            XCH    OMEGAQ          SAVE AND BEGIN TO WEIGHT VALUE OF OLD W 
 0067            EXTEND                 (1-K) IS SCALED AT 1 FOR EFFICIENT CALC 
 0068            MP     (1-K)           (K CHANGES EVERY 2 SECS IN ASCENT)      
 0069            AD     JETRATEQ        WEIGHTED TERM DUE TO JET ACCELERATION   
 0070            AD     AOSQTERM        TERM DUE TO ASCENT OFFSET ACCELERATION  
 0071            ADS    OMEGAQ          TOTAL RATE ESTIMATE SCALED AT PI/4      
                                                                                
 0072            CAE    ITEMP4          GET DELTAR                              
 0073            EXTEND                 WFORQR IS K/(NOMINAL DT) SCALED AT 16   
 0074            MP     WFORQR          FORM WEIGHTED VALUE OF MEASURED DATA    
 0075            XCH    OMEGAR          SAVE AND BEGIN TO WEIGHT VALUE OF OLD W 
 0076            EXTEND                 (1-K) IS SCALED AT 1 FOR EFFICIENT CALC 
 0077            MP     (1-K)           (K CHANGES EVERY 2 SECS IN ASCENT)      
 0078            AD     JETRATER        WEIGHTED TERM DUE TO JET ACCELERATION   
 0079            AD     AOSRTERM        TERM DUE TO ASCENT OFFSET ACCELERATION  
 0080            ADS    OMEGAR          TOTAL RATE ESTIMATE SCALED AT PI/4      
                                                                                
## Page 521
 0081            TC     QJUMPADR                                                
 0082   SKIPQRAX CA     NORMQADR                                                
 0083            TS     QJUMPADR        DO NOT JUMP NEXT TIME.                  
 0084            TCF    CHKGIMBL        CHKGIMBL ATTEMPTS TO USE GTS.           
                                                                                
 0085   NORMQADR GENADR NORMALQ                                                 
 0086   NORMALQ  TCF    ATTSTEER        NO RHC INPUTS IN 206.                   
                                                                                
R0087   START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*****************
                                                                                
 0088   TRMCHECK DXCH   T5ADR           SET UP NEXT T5RUPT ADDRESS.             
                                                                                
R0089   **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****************
                                                                                
R0090   CHECK IF TRIMCNTR HAS BEEN COUNTED DOWN TO ZERO, INDICATING THAT 20.0 SECONDS HAVE PASSED SINCE DPS ON AND
R0091   CONTROL SHOULD BE TRANSFERRED TO GTS.  THEN SEE IF A RECENT ENGINE-ON REQUIRES AN EARLY GTS ENTRY.
                                                                                
 0092            CCS    TRIMCNTR        IS GTS NEEDED PRIOR TO THROTTLE-UP?     
 0093            TCF    CHKMNITR          NOT YET, BUT CHECK IF FIRST GTS DONE. 
 0094            TC     CCSHOLE           ILLEGAL VALUE OF TRIMCNTR.            
 0095            TCF    INSERT17 +1       NOT ACTIVE, RETURN TO RCS CONTROL     
 0096   OKAYGTS  CAF    USEQRJTS          YES, IS GIMBAL SYSTEM USABLE?         
 0097            MASK   DAPBOOLS                                                
 0098            EXTEND                                                         
 0099            BZF    GOGIMBAL        USABLE.  GO TO GTS.                     
 0100            TCF    INSERT17 +1     NOT USABLE.  GO ON WITH RCS CONTROL.    
                                                                                
 0101   CHKMNITR CCS    GTSMNITR        IS AN IMMEDIATE (FIRST) GTS CALLED FOR? 
 0102            TCF    OKAYGTS           YES, CHECK IF GIMBAL SYSTEM USABLE.   
 0103            TCF    INSERT17 +1       NO, RETURN TO RCS CONTROL.            
 0104   GOGIMBAL CS     THREE           RESET TIME5 COUTNER FROM 20 TO 50 MSEC. 
 0105            ADS    TIME5                                                   
                                                                                
 0106            CS     BGIM24          TURN OFF GIMBALS FOR BETTER FILTERING.  
 0107            EXTEND                                                         
 0108            WAND   12                                                      
                                                                                
 0109            CS     BIT1            DEACTIVATE GIMBAL DRIVE TIMERS          
 0110            TS     QGIMTIMR                                                
 0111            TS     RGIMTIMR                                                
                                                                                
 0112            CAF    ZERO                                                    
 0113            EXTEND                                                         
 0114            WRITE  5               TURN OFF ALL Q,R AXIS JETS.             
                                                                                
 0115            EXTEND                                                         
 0116            DCA    ADRGOGTS                                                
 0117            DTCB                                                           
 0118            EBANK= DT                                                      
 0119   ADRGOGTS 2CADR  GOTOGTS +2      TIME5 COUNTER WAS ALREADY ADVANCED.     
                                                                                
R0120   *** THE FOLLOWING NEW CODING IS NOT BEING USED   ***                    
## Page 522
R0121   LEFT IN PLACE AS FILLER)))MAY BE WRITTEN OVER                           
                                                                                
 0122            TC     CCSHOLE         FILLER                                  
 0123            TC     CCSHOLE         FILLER                                  
 0124            TC     CCSHOLE         FILLER                                  
 0125            TC     CCSHOLE         FILLER                                  
 0126            TC     CCSHOLE         FILLER                                  
 0127            TC     CCSHOLE         FILLER                                  
 0128            TC     CCSHOLE         FILLER                                  
 0129            TC     CCSHOLE         FILLER                                  
 0130            TC     CCSHOLE         FILLER                                  
 0131            EBANK= NEGUR                                                   
 0132   RGIMADR  2CADR  OFFGIMR                                                 
                                                                                
 0133   GETCNTR  CAE    FORCETRM        LOAD TRIMCNTR TO FORCE TRIM JUST BEFORE 
 0134            TS     TRIMCNTR        THE THROTTLE-UP.                        
 0135            CAF    BIT1            ENABLE MONITOR TO CALL GTS AS SOON AS   
 0136            TS     GTSMNITR        POSSIBLE.                               
                                                                                
 0137            CAE    SIMPINIT        INITIALIZE SIMPCNTR. DECISECONDS.       
 0138            TS     SIMPCNTR                                                
                                                                                
 0139            EXTEND                 RETURN TO ORIGINAL CODING               
 0140            DCA    INSRTADR                                                
 0141            DTCB                                                           
                                                                                
 0142            TC     CCSHOLE         THIS IS A FILLER                        
 0143            EBANK= PERROR                                                  
 0144   INSRTADR 2CADR  INSERT20 +1                                             
                                                                                
 0145   17INSRT  CS     /TEMP1/         COMPARE Q WITH THE GENADR OF SWRETURN   
 0146            AD     SWRETADR        TO SEE IF ENGINOFF WAS CALLED VIA       
 0147            EXTEND                 BANKCALL OR IBNKCALL.                   
 0148            BZF    17INSRTB        *BANKCALL - DO NOT DELAY*               
                                                                                
 0149            EXTEND                 *IBNKCALL - CHECK FURTHER*              
 0150            READ   30                                                      
 0151            COM                    SEE IF ENGINE IN QUESTION IS APS OR DPS.
 0152            MASK   BIT2                                                    
 0153            EXTEND                                                         
 0154            BZF    17INSRTB        *DPS ENGINE - DO NOT DELAY*             
                                                                                
 0155            CS     MODREG          *APS ENGINE - CHECK FURTHER*            
 0156            AD     MP3MMODE                                                
 0157            EXTEND                 SEE IF THIS IS THE MP 3 SHORT APS BURN. 
 0158            BZF    17INSRTB        *IT IS - DO NOT DELAY*                  
                                                                                
 0159            CS     DVMNEXIT        *IT IS NOT - CHECK FOR A FORGET2 ENTRY* 
 0160            AD     KILLAVEG                                                
 0161            EXTEND                                                         
## Page 523
 0162            BZF    17INSRTD        GENADRS MATCH - CHECK THE BBCONS.       
                                                                                
 0163   17INSRTE EXTEND                                                         
 0164            DCS    /TEMP3/                                                 
 0165            DXCH   RUPTREG3        PUT MINUS (ENGINEON TIME) IN RUPTREGS   
 0166            DXCH   /TEMP5/         AND SAVE FORMER CONTENTS FOR ISWRETRN.  
                                                                                
 0167            EXTEND                 BLEND IN THE CURRENT TIME.              
 0168            DCA    TIME2                                                   
 0169            DAS    RUPTREG3                                                
                                                                                
 0170            CAF    HALF            FORCE SIGN AGREEMENT.                   
 0171            DOUBLE                                                         
 0172            AD     RUPTREG4                                                
 0173            TS     RUPTREG4                                                
 0174            CAF    ZERO                                                    
 0175            AD     NEGONE                                                  
 0176            ADS    RUPTREG3                                                
                                                                                
 0177            CA     RUPTREG3        SEE IF BURN HAS BEEN LONGER THAN        
 0178            EXTEND                 163.84 SECONDS.                         
 0179            BZF    17INSRTC        *LESS THAN 163.84 SECONDS*              
                                                                                
 0180   17INSRTA EXTEND                 *MORE THAN 163.84 SECONDS*              
 0181            DCA    /TEMP5/                                                 
 0182            DXCH   RUPTREG3        RESTORE RUPTREGS FOR ISWRETRN.          
                                                                                
 0183   17INSRTF CAF    NEGMAX          SET TMINAPS NEGATIVE TO INACTIVATE      
 0184            TS     TMINAPS         THE ENGINOFF DELAY LOGIC                
                                                                                
 0185   17INSRTB CA     /TEMP2/         RESTORE CALLERS EBANK.                  
 0186            TS     EBANK                                                   
 0187            TC     POSTJUMP        RETURN TO THE ENGINOFF SEQUENCE.        
 0188            CADR   ENGINOFF +1                                             
                                                                                
 0189   17INSRTC CS     RUPTREG4        CHECK LENGTH OF BURN AGAINST TMINAPS.   
 0190            AD     TMINAPS                                                 
 0191            EXTEND                                                         
 0192            BZMF   17INSRTA        BURN IS LONG ENOUTH - DO THE ENGINOFF.  
                                                                                
 0193            TC     WAITLIST        SUSPEND CURRENT MISSION PHASE AND SET   
 0194            EBANK= TMINAPS         WAITLIST FOR RESUMPTION AT THE PROPER   
 0195            2CADR  17INSRTA        TIME.                                   
                                                                                
 0196            TC     TASKOVER                                                
                                                                                
 0197   17INSRTD CS     DVMNEXIT +1                                             
 0198            AD     KILLAVEG +1                                             
 0199            EXTEND                                                         
 0200            BZF    17INSRTF        BBCONS MATCH - DO NOT DELAY             
## Page 524
 0201            TCF    17INSRTE                                                
                                                                                
 0202   SWRETADR GENADR SWRETURN                                                
                                                                                
 0203   MP3MMODE OCT    00071           MAJOR MODE OF MISSION PHASE 3.          
                                                                                
 0204            EBANK= LST1                                                    
 0205   KILLAVEG 2CADR  AVEGKILL                                                
                                                                                
R0206   FOLLOWING CODING LEFT IN PLACE TO KEEP ADDRESSES CONSTANT.              
                                                                                
R0207   **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****************
                                                                                
 0208   NOQJETS  TC     CCSHOLE         LABEL PREVENTS ASSEMBLER CUSSES.        
 0209            TCF    XTRANS                                                  
 0210            TCF    R-,CHKDB                                                
 0211            TCF    XTRANS                                                  
                                                                                
 0212   NEGQEROR AD     -RATEDB                                                 
 0213            EXTEND                                                         
 0214            BZMF   NOQJETS                                                 
                                                                                
 0215            CCS    RRATEDIF                                                
 0216            TCF    R+Q-CHKR                                                
 0217            TCF    Q-NORJTS                                                
 0218            TCF    R-Q-CHKR                                                
                                                                                
 0219   Q-NORJTS CS     QRATEDIF                                                
 0220            TS     RATEDIF                                                 
 0221            AD     -2JETLIM                                                
 0222            EXTEND                                                         
 0223            BZMF   2JETS+Q                                                 
 0224            TCF    4JETS+Q                                                 
                                                                                
 0225   R+Q-CHKR AD     -RATEDB                                                 
 0226            EXTEND                                                         
 0227            BZMF   Q-NORJTS                                                
 0228            TC     EDOTVGEN                                                
 0229            TCF    2-V.RATE                                                
                                                                                
 0230   R-Q-CHKR AD     -RATEDB                                                 
 0231            EXTEND                                                         
 0232            BZMF   Q-NORJTS                                                
 0233            TC     EDOTUGEN                                                
 0234            EXTEND                                                         
 0235            SU     RRATEDIF                                                
 0236            TCF    2+U.RATE                                                
                                                                                
 0237   POSQEROR AD     -RATEDB                                                 
 0238            EXTEND                                                         
## Page 525
 0239            BZMF   NOQJETS                                                 
                                                                                
 0240            CCS    RRATEDIF                                                
 0241            TCF    R+Q+CHKR                                                
 0242            TCF    Q+NORJTS                                                
 0243            TCF    R-Q+CHKR                                                
                                                                                
 0244   Q+NORJTS CA     QRATEDIF                                                
 0245            TS     RATEDIF                                                 
 0246            AD     -2JETLIM                                                
 0247            EXTEND                                                         
 0248            BZMF   2JETS-Q                                                 
 0249            TCF    4JETS-Q                                                 
                                                                                
 0250   R+Q+CHKR AD     -RATEDB                                                 
 0251            EXTEND                                                         
 0252            BZMF   Q+NORJTS                                                
 0253            TC     EDOTUGEN                                                
 0254            TCF    2-U.RATE                                                
                                                                                
 0255   R-Q+CHKR AD     -RATEDB                                                 
 0256            EXTEND                                                         
 0257            BZMF   Q+NORJTS                                                
 0258            TC     EDOTVGEN                                                
 0259            TCF    2+V.RATE                                                
                                                                                
 0260   R+,CHKDB AD     -RATEDB                                                 
 0261            EXTEND                                                         
 0262            BZMF   XTRANS                                                  
 0263            CA     RRATEDIF                                                
 0264            TS     RATEDIF                                                 
 0265            AD     -2JETLIM                                                
 0266            EXTEND                                                         
 0267            BZMF   2JETS-R                                                 
 0268            TCF    4JETS-R                                                 
                                                                                
 0269   R-,CHKDB AD     -RATEDB                                                 
 0270            EXTEND                                                         
 0271            BZMF   XTRANS                                                  
 0272            CS     RRATEDIF                                                
 0273            TS     RATEDIF                                                 
 0274            AD     -2JETLIM                                                
 0275            EXTEND                                                         
 0276            BZMF   2JETS+R                                                 
 0277            TCF    4JETS+R                                                 
                                                                                
 0278   RTJETIME CCS    RATEDIF         SCALED AT PI/4 RADIANS/SECOND           
 0279            AD     ONE                                                     
 0280            TCF    +2                                                      
 0281            AD     ONE             ABS(RATEDIF)                            
## Page 526
 0282            EXTEND                                                         
 0283            MP     1/NJETAC        SCALED AT 2(8)/PI SECONDS(2)/RADIANS    
 0284            EXTEND                                                         
 0285            MP     BIT4            SCALED AT 2(3) SECONDS                  
 0286            CAE    L                                                       
 0287            EXTEND                                                         
 0288            MP     25/32.QR        TJET NOW PROPERLY SCALED IN A           
 0289            TS     TQR             AT 2(4)16/25 SECONDS                    
 0290            TCF    MNIMPTST                                                
                                                                                
                                                                                
## Page 527
R0291   DAP SECTION: XTRANS            MOD. NO. 3  DATE: JANUARY 6, 1967.       
                                                                                
R0292   AUTHOR: JOHN S. BLISS (ADAMS ASSOCIATES)                                
                                                                                
R0293   MODIFICATION BY: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)               
                                                                                
R0294   X-AXIS TRANSLATION LOGIC (IN THE ABSENSE OF Q,R-AXIS ROTATION) IS INITIATED IN THE "XTRANS" SECTION.
                                                                                
R0295   XTRANS FIRST SETS ADDTLT6 AND ADDT6JTS TO ZERO FOR USE BY "JTLST" AND "T6JOB" WHEN THEY ARE CALLED.  IT THEN
R0296   CHECKS FOR PLUS OR MINUS X TRANSLATION REQUESTS FROM THE ASTRONAUT'S STICK.  IF NONE IS REQUESTED IN THAT WAY,
R0297   THE ULLAGE BIT OF DAPBOOLS IS CHECKED.  (NOTE THAT THE ORDER OF THE TESTS ALLOWS THE ASTRONAUT TO OVERRIDE THE
R0298   INTERNAL ULLAGE REQUEST.)  IF NO TRANSLATION IS REQUESTED, ALL Q,R-AXIS JETS ARE TURNED OFF AND THE INTERRUPT
R0299   IS TERMINATED.                                                          
                                                                                
R0300   CALLING SEQUENCE: NONE          SUBROUTINES CALLED: WRITEQR             
                                                                                
R0301   NORMAL EXIT: 1.  IF NO TRANSLATION, RESUME.                             
R0302                2.  IF TRANSLATION OR ULLAGE, +/-XTRAN                     
                                                                                
R0303   ALARM/ABORT MODE: NONE.                                                 
                                                                                
R0304   INPUT:  ULLAGER/DAPBOOLS,BITS7,8/CHANNEL 31.                            
                                                                                
R0305   OUTPUT: C(ANYTRANS) = NEGMAX FOR +X TRANSLATION.                        
R0306           C(ANYTRANS) = POSMAX FOR -X TRANSLATION.                        
R0307           C(TRANSNOW) = C(TRANSAVE) = +0.                                 
R0308           C(TRANONLY) = PNZ                                               
R0309   C(ADDTLT6), C(ADDT6JTS), C(TQR), C(TOFJTCHG) = 0.                       
                                                                                
R0310           C(CHANNEL 5) = 0 IF NO X-TRANSLATION REQUESTED                  
                                                                                
R0311   DEBRIS: A, L, Q                                                         
                                                                                
                                                                                
 0312   XTRANS   CAF    ZERO            PICK UP ZERO AND INITIALIZE             
 0313            TS     ADDTLT6                                                 
 0314            TS     ADDT6JTS                                                
 0315            TS     TOFJTCHG                                                
 0316            TS     TQR             A ZERO OF JET TIME FOR THE TORQUE VECTOR
                                                                                
 0317            CAF    BIT7            IS PLUS X TRANSLATION DESIRED           
 0318            EXTEND                                                         
 0319            RAND   31              CHANNEL 31 BITS INVERTED                
 0320            EXTEND                                                         
 0321            BZF    +XORULGE        YES, +X                                 
                                                                                
 0322            CAF    BIT8            NO, IS MINUS X TRANSLATION DESIRED      
 0323            EXTEND                                                         
 0324            RAND   31              CHANNEL 31 BITS INVERTED                
## Page 528
 0325            EXTEND                                                         
 0326            BZF    -XTRANS         YES, -X                                 
                                                                                
 0327            CAF    BIT6            NO, IS ULLAGE(+X TRANSLATION) DESIRED   
 0328            MASK   DAPBOOLS                                                
 0329            CCS    A                                                       
 0330            TCF    +XORULGE        YES, ULLAGE                             
                                                                                
 0331            CAF    ZERO            SINCE NEITHER ROTATION NOR TRANSLATION  
 0332            TC     WRITEQR         ARE NEEDED, TURN OFF ALL Q,R-AXES JETS. 
 0333            TCF    RESUME                                                  
                                                                                
 0334   +XORULGE CAF    NEGMAX          PLUS TRANSLATION OR ULLAGE DESIRED:     
 0335            TCF    +2              LOAD NEGMAX IN A AND SKIP NEXT OPCODE TO
                                                                                
 0336   -XTRANS  CAF    POSMAX          -X TRANSLATION DESIRED, A = POSMAX, AND 
 0337            TS     ANYTRANS        LOAD ANYTRANS WITH A(NEG/POS MAX)       
                                                                                
 0338            CAF    ZERO            INITIALIZE TRANSNOW AND TRANSAVE WITH   
 0339            TS     TRANSNOW        ZERO FOR USE IN THE JET POLICY SELECTION
 0340            TS     TRANSAVE        PROGRAM.                                
                                                                                
 0341            EXTEND                 SET UP 2CADR FOR TRANSFER TO +/-XTRAN.  
 0342            DCA    JTPOLADR                                                
 0343            TS     TRANONLY        STORE POSITIVE, NON-ZERO S-REGISTER IN  
 0344            DTCB                   TRANONLY.  AFTER +/-XTRAN, GO TO JTLST. 
                                                                                
 0345            EBANK= JTSONNOW                                                
 0346   JTPOLADR 2CADR  +/-XTRAN        TRANSLATION ONLY ENTRY TO JET POLICY    
                                                                                
                                                                                
## Page 529
R0347   ALL Q,R AXES TQR COMPUTATIONS TERMINATE IN THIS PROGRAM WHICH PERFORMS A SERIES OF TESTS TO DETERMINE THE TRUE
R0348     TIME THE JETS SHOULD BE ON. THESE TESTS ARE AS FOLLOWS ...            
                                                                                
R0349        1.  TEST THE ON TIME AGAINST THE 7.5 MS  ELECTRICAL COMMAND (MIN).IF THE ON TIME IS LESS THAN THE MINIMUM
R0350            WE BUG OUT TO XTRAN,WHERE X TRANSLATION IS DONE(IF NEEDED).    
                                                                                
R0351        2.  TEST THE ON TIME AGAINST 150 MS, IF TQR IS GREATER THAN 150MS ,THEN THE NEXT QR AXIS IS DONE IN 100 MS.
R0352            IF TQR IS LESS THAN 150 MS, THEN THE NEXT QR AXIS IS DONE IN 200 MS. THAT IS A QR AXIS SKIP IS DONE.
                                                                                
R0353        3.  WHEN TQR IS LESS THAN 150 MS  THE PROGRAM GOES TO THE JET LIST PROGRAM WHERE THE T6 CLOCK IS SET UP.
                                                                                
R0354        4.  BEFORE GOING TO THE JET LIST THE COMPUTED TIME HAS EITHER 7.5 MS  ADDED OR 5MS  SUBTRACTED-THE EXACT
R0355            OPERATION BEING DECIDED BY WHETHER THE JETS WHICH ARE TO GO ON ARE OFF OR ARE ON RESPECTIVELY.
                                                                                
R0356        5.  IF SOME OF THE JETS WHICH ARE TO GO ON ARE NOW ON AND SOME ARE OFF, THEN A ******* COMPUTATION CALLED
R0357            NOTRANS DECIDES WHICH JETS GO OFF AT TQR AND WHICH GO OFF AT TQR+6.5MS. THIS 6.5 MS. IS STORED IN
R0358            ADDTLT6. ADDTLT6 IS SET TO ZERO OTHERWISE.                     
                                                                                
 0359   NORMRETN TS     TQR                                                     
                                                                                
                                                                                
 0360   MNIMPTST CS     TQR             TEST FOR TQR GREATER THAN MIN. IMPULSE. 
 0361            AD     +T6TJMIN                                                
 0362            EXTEND                   CORRECT BRANCH.                       
 0363            BZMF   TQRGTTMI        BRANCH FOR TQR = OR GREATER THAN MINIMP.
 0364            TCF    XTRANS          SEE IF TRANSLATION IS DESIRED .         
 0365   TQRGTTMI CAE    TQR             HERE JETS ON FOR LONGER THAN GRUMANN    
 0366            TS     TOFJTCHG        MINIMUM IMPULSE SPECIFICATIONS.         
 0367            AD     -1.5CSP                                                 
 0368            EXTEND                                                         
 0369            BZMF   DOQRSKIP                                                
 0370            CAE    JTSONNOW                                                
 0371            TC     WRITEQR                                                 
 0372            TCF    RESUME                                                  
                                                                                
 0373   SKIPQRAD GENADR SKIPQRAX                                                
R0374   CHANGE JET ON AND OFF BITS TO ACCOUNT FOR THE PRESENT STATE OF THE      
R0375     CHANNEL. THE CHANGES ACCOUNT FOR PURE ROTATION ONLY- NOT TRANSLATION. 
 0376   DOQRSKIP CA     JTSONNOW                                                
 0377            EXTEND                                                         
 0378            RAND   5               MASK THE CHANNEL WITH THE DESIRED STATE.
 0379   FROMROOT EXTEND                 ENTER HERE FROM DORUTDUM (IN K.E. BANK) 
 0380            BZF    NOQRON          A IS ZERO IF NO JETS TO GO ON ARE ON.   
 0381            AD     BIT15           MAKE DIFFERENCE CORRESPOND TO A QR JET. 
 0382            EXTEND                                                         
 0383            SU     JTSONNOW        RESULT IS COMPLEMENT OF JET BITS WHICH  
 0384            TS     L                 ARE TO BE ON FOR 6.5MS MORE THAN CALC.
 0385            EXTEND                                                         
 0386            BZF    JTSAREON        A=0,THUS ALL JETS TO GO ON ARE NOW ON.  
## Page 530
 0387   TRSLTMN2 CAE    JTSATCHG                                                
 0388            MASK   POSMAX          REMOVE BIT15 FROM JSATCHG               
 0389            EXTEND                                                         
 0390            BZF    NOTRANS         IF JFSTACHG = 0 THEN NO TRANSLATION NOW.
 0391            CA     14-TQRMN                                                
 0392            ADS    TOFJTCHG        INSURE T GREATER THAN 14 MS.            
 0393            TCF    TOJTLST                                                 
 0394   NOTRANS  CS     L                                                       
 0395            AD     BIT15           MAKE JET BITS CORRESPOND TO QR AXIS.    
 0396            XCH    JTSATCHG        JTSONNOW - L = JETS ON AT TOFJTCHG.     
 0397            TS     ADDT6JTS        JTS ON AT TOFJTCHG +ONDELAY.            
 0398            CA     14-TQRMN                                                
 0399            TS     ADDTLT6                                                 
 0400            TCF    TOJTLST                                                 
 0401   NOQRON   CA     14-TQRMN                                                
 0402            ADS    TOFJTCHG                                                
 0403            TCF    TOJTLST -2                                              
 0404   JTSAREON CAE    JTSATCHG                                                
 0405            MASK   POSMAX                                                  
 0406            EXTEND                                                         
 0407            BZF    +2                                                      
 0408            TCF    TOJTLST -2                                              
 0409            CAF    MCOMPTQR                                                
 0410            ADS    TOFJTCHG                                                
 0411            EXTEND                 TEST FOR COMPUTATION OF NEGATIVE OR ZERO
 0412            BZMF   QUICKOFF        TOFJTCHG, IF SO, MAKE -0.               
 0413    -2      CAF    ZERO                                                    
 0414            TS     ADDTLT6                                                 
 0415   TOJTLST  CA     SKIPQRAD                                                
 0416            TS     QJUMPADR                                                
 0417            CAE    JTSONNOW        TURN ON JETS TO GO ON NOW (EVEN IF ALL  
 0418            TC     WRITEQR         ARE ALREADY ON), AFTER TESTING FOR RISE.
 0419            EXTEND                                                         
 0420            DCA    JTLSTADR                                                
 0421            DTCB                                                           
                                                                                
 0422   QUICKOFF CS     TOFJTCHG        SET TOFJTCHG TO -0 IN SHORTEST WAY.     
 0423            TCF    NOQRON +1                                               
                                                                                
 0424   -1.5CSP  DEC    -0.01465                                                
 0425   +T6TJMIN DEC    +.00073                                                 
 0426   25/32.QR DEC    0.78125                                                 
 0427   MS20QR   OCTAL  37776                                                   
 0428   MS30QR   OCTAL  37775                                                   
 0429   MS50QR   OCTAL  37773                                                   
 0430   16/32400 DEC    0.00049                                                 
 0431   BIT8,9   OCTAL  00600                                                   
 0432   MCOMPTQR DEC    -16             -10 MS SCALED AS TIME6.                 
 0433   14-TQRMN DEC    11                                                      
R0434   START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*********************
## Page 531
 0435   MINTADR  GENADR CCSHOLE                                                 
R0436   **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*********************
 0437   -.88975  DEC    -.88975                                                 
 0438   (1-K),QR DEC    0.50000         K = 1/2                                 
 0439   (1-KQ)/8 DEC    0.06250                                                 
 0440   -90MS    DEC    -.00879                                                 
 0441   +90MS    DEC    0.00879                                                 
 0442   NEGCSP2  DEC    -.00977                                                 
 0443   ALL+XJTS OCTAL  40252                                                   
 0444   2,10-OUT OCTAL  00201                                                   
 0445   +X,A     OCTAL  40042                                                   
 0446   +X,B     OCTAL  40210                                                   
 0447   1,9-OUT  OCTAL  00104                                                   
 0448   -X,A     OCTAL  40104                                                   
 0449   -X,B     OCTAL  40021                                                   
 0450            EBANK= JTSONNOW                                                
 0451   JTLSTADR 2CADR  JTLST                                                   
                                                                                
 0452   RTJETADR GENADR RTJETIME                                                
                                                                                
                                                                                
## Page 532
R0453   Q,R-AXES ATTITUDE STEERING CALCULATIONS:                                
                                                                                
R0454   (EXECUTED WHEN LGC IS IN AUTOMATIC SCSMODE OR IF SCSMODE IS ATTITUDE HOLD AND THE ROTATIONAL HAND CONTROLLER IS
R0455   NEITHER OUT OF DETENT NOR IS THE RATE COMMAND BIT SET IN DAPBOOLS)      
                                                                                
 0456   CHKGIMBL EXTEND                                                         
 0457            DCA    TRYGTSAD        TRYGTS ATTEMPTS GTS CONTROL             
 0458            DXCH   Z                                                       
 0459            TC     CCSHOLE                                                 
                                                                                
 0460   BGIM24   OCTAL  07400                                                   
 0461   DESCADR  GENADR TJETLAW                                                 
                                                                                
 0462            EBANK= DT                                                      
 0463   TRYGTSAD 2CADR  TRYGTS          TRYGTS ATTEMPS GTS CONTROL.             
                                                                                
                                                                                
## Page 533
R0464   "ATTSTEER" IS THE NOMINAL ENTRY POINT FOR THE REACTION CONTROL SYSTEM ATTITUDE STEERING
                                                                                
 0465   ATTSTEER EQUALS QERRCALC                                                
 0466   QERRCALC CAE    CDUY            Q-ERROR CALCULATION                     
 0467            EXTEND                                                         
 0468            MSU    CDUYD           CDU ANGLE - ANGLE DESIRED (Y-AXIS)      
 0469            TS     ITEMP1          SAVE FOR RERRCALC                       
 0470            EXTEND                                                         
 0471            MP     M21             (CDUY-CDUYD)*M21 SCALED AT PI RADIANS   
 0472            XCH    ER              SAVE FIRST TERM (OF TWO) IN OPP.AXIS REG
 0473            CAE    CDUZ            SECOND TERM CALCULATION:                
 0474            EXTEND                                                         
 0475            MSU    CDUZD           CDU ANGLE -ANGLE DESIRED (Z-AXIS)       
 0476            TS     ITEMP2          SAVE FOR RERRCALC                       
 0477            EXTEND                                                         
 0478            MP     M22             (CDUZ-CDUZD)*M22 SCALED AT PI RADIANS   
 0479            ADS    ER              SAVE SUM OF TERMS, NO OVERFLOW EVER     
 0480            TS     QERROR          SAVE QERROR FOR EIGHT-BALL DISPLAY      
                                                                                
 0481   RERRCALC CAE    ITEMP1          R-ERROR CALCULATION:                    
 0482            EXTEND                 CDU ANGLE -ANGLE DESIRED (Y-AXIS)       
 0483            MP     M31             (CDUY-CDUYD)*M31 SCALED AT PI RADIANS   
 0484            XCH    E               SAVE FIRST TERM (OF TWO) IN OPP.AXIS REG
 0485            CAE    ITEMP2          SECOND TERM CALCULATION:                
 0486            EXTEND                 CDU ANGLE -ANGLE DESIRED (Z-AXIS)       
 0487            MP     M32             (CDUZ-CDUZD)*M32 SCALED AT PI RADIANS   
 0488            ADS    E               SAVE SUM OF TERMS, NO OVERFLOW EVER     
 0489            TS     RERROR          SAVE R-ERROR FOR EIGHT-BALL DISPLAY     
                                                                                
 0490            TCF    STILLRCS                                                
                                                                                
R0491   THIS CODING IS ENTERED FROM BURGZERO, WHEN BOTH URGENCIES ARE ZERO.  EXITS TO GTS IF POSSIBLE, XTRANS OTHERWISE
                                                                                
 0492   GIMBLTRY CAF    USEQRJTS        IS JET USAGE MANDATORY.                 
 0493            MASK   DAPBOOLS                                                
 0494            CCS    A                                                       
 0495            TCF    XTRANS          YES.  GO TO XTRANS.                     
                                                                                
 0496            EXTEND                 ARE GIMBALS DRIVING?                    
 0497            READ   12                                                      
 0498            MASK   BGIM24          BITS 9,10,11,12 ARE GIMBAL DRIVE BITS.  
 0499            CCS    A                                                       
 0500            TCF    XTRANS          YES.  DRIVING.  GO TO XTRANS.           
                                                                                
 0501            EXTEND                 NO.   CHECK JETS.                       
 0502            READ   5               ARE ANY Q,R JETS ON NOW.                
A0503                                   (CAN ONLY BE ROTATION JETS.)            
 0504            EXTEND                                                         
 0505            BZF    XTRANS          NO.   GO TO XTRANS.                     
                                                                                
## Page 534
 0506            CAF    ZERO            YES.  TURN ON JETS.                     
 0507            EXTEND                                                         
 0508            WRITE  5                                                       
                                                                                
 0509            EXTEND                 NO.   GO TO GTS.                        
 0510            DCA    GOGTSADR                                                
 0511            DXCH   Z                                                       
                                                                                
 0512            EBANK= DT                                                      
 0513   GOGTSADR 2CADR  GOTOGTS                                                 
                                                                                
R0514   REMAINING CODING (HERE TO STILLRCS) STAYS IN TO KEEP ADDRESSES CONSTANT.
                                                                                
 0515            TC     CCSHOLE         FILLER.                                 
 0516            TCF    STILLRCS        NO.      SO USE RCS.                    
 0517            INDEX  QRCNTR          YES.     TRY THE ERROR MAGNITUDE.       
 0518            CCS    QDIFF           IS ERROR SMALL ENOUGH FOR GTS.          
 0519            AD     -XBND+1         -1.4 DEG SCALED AT PI    + 1 BIT        
 0520            TCF    +2                                                      
 0521            AD     -XBND+1                                                 
 0522            EXTEND                                                         
 0523            BZMF   +2              IS ERROR LESS,EQUAL 1.4 DEG.            
 0524            TCF    STILLRCS        NO.      USE RCS CONTROL.               
 0525            CCS    QRCNTR          THIS AXIS IS FINE.   ARE BOTH DONE.     
 0526            TC     CCSHOLE         REMOVE REFERENCE TO ELIMINATED SYMBOL.  
 0527            TC     CCSHOLE         FILLER.                                 
 0528   -RATLM+1 OCT    77512           -.5 DEG/SEC SCALED AT PI/4  + 1 BIT     
 0529   -XBND+1  OCT    77601           -1.4 DEG SCALED AT PI, + 1 BIT.         
R0530   "STILLRCS" IS THE ENTRY POINT TO RCS ATTITUDE STERRING WHENEVER IT IS FOUND THAT THE TRIM GIMBAL CONTROL
R0531   SYSTEM SHOULD NOT BE USED;                                              
                                                                                
## Page 535
R0532   Q,R-AXES RCS URGENCY FUNCTION LOGIC:                                    
                                                                                
 0533   STILLRCS CCS    DAPBOOLS        BRANCH TO SPS-BACKUP RCS CONTROL LOGIC. 
 0534            TCF    SPSBAKUP        WHEN BIT15/DAPBOOLS = 0.                
 0535            NOOP                                                           
 0536            CAF    DESCADR         SET JET SELECT LOGIC RETURN ADDRESS TO  
 0537            TS     TJETADR         Q,R-AXIS TJETLAW CALCULATION            
                                                                                
 0538            TC     T6JOBCHK        CHECK T6 CLOCK RUPT BEFORE SUBROUTINE   
                                                                                
R0539   CALCULATE THE RATE ERRORS SCALED AT PI/4 RADIANS/SECOND(2):             
                                                                                
 0540            CS     OMEGAQD                                                 
 0541            AD     OMEGAQ          EDOTQ = OMEGAQ - OMEGAQD                
 0542            TS     EDOTQ                                                   
                                                                                
 0543            CS     OMEGARD                                                 
 0544            AD     OMEGAR          EDOTR = OMEGAR - OMEGARD                
 0545            TS     EDOTR                                                   
                                                                                
## Page 536
R0546   Q,R-AXES URGENCY FUNCTION LOOP:                                         
                                                                                
R0547   SET UP LOOP TO DO R-AXIS, THEN Q-AXIS:                                  
                                                                                
 0548            CAF    ONE             1: REFERS TO R-AXIS VARIABLES.          
 0549            TS     AXISCNTR        0: REFERS TO Q-AXIS VARIABLES.          
                                                                                
R0550   PICK UP EDOT AND RESCALE FROM PI/4 TO PI/16 RADIANS/SECOND:             
                                                                                
 0551   URGLOOP  INDEX  AXISCNTR        ERROR RATES ARE PRE-CALCULATED BY RATE  
 0552            CAE    EDOTQ           DERIVATION SCALED AT PI/4 RADIANS/SECOND
 0553            EXTEND                 MULTIPLYING BY FOUR (BIT3) LEAVES EDOT  
 0554            MP     FOUR            AS C(L) IF EDOT LESS THAN 11.25 DEG/SEC.
 0555            EXTEND                                                         
 0556            BZF    +2              IF C(A) NON-ZERO, THEN EDOT GREATER THAN
 0557            TCF    EDOTMAX         11.25 DEG/SEC IN MAGNITUDE, SO LIMIT IT.
                                                                                
 0558            CCS    L               INSURE NON-ZERO EDOT:                   
 0559            AD     TWO             C(L) PNZ REMAINS UNCHANGED.             
 0560            TCF    +2              C(L) NNZ REMAINS UNCHANGED.             
 0561            COM                    C(L)  +0 BECOMES 77776.                 
 0562            AD     NEG1            C(L)  -0 BECOMES 77776.                 
 0563   EDOTSTOR TS     EDOT            SAVE NON-ZERO EDOT SCALED AT PI/16.     
                                                                                
 0564            EXTEND                 CALCULATE (EDOT)(EDOT):                 
 0565            SQUARE                                                         
 0566            TS     EDOT(2)         SCALED AT PI(2)/2(+8) RAD(2)/SEC(2).    
                                                                                
 0567            EXTEND                  0.5               +8       2           
 0568            INDEX  AXISCNTR        ------  SCALED AT 2  /PI SEC /RAD.      
 0569            MP     1/ACCQ          ACCQ,R                                  
 0570            EXTEND                 DEADBAND = 5.0 OR 1.0 OR 0.3 DEGREES    
 0571            SU     DB              SCALED AT PI RADIANS.                   
 0572            TS     FPQR            0.5(1/ACC)EDOT(2)-DB SCALED AT PI RADS. 
                                                                                
 0573            CAE    EDOT(2)         SCALED AT PI(2)/2(8) RAD(2)/SEC(2).     
 0574            EXTEND                                                         
 0575            INDEX  AXISCNTR                                                
 0576            MP     1/AMINQ         .5(1/ACCMIN) AT 2(8)/PI SEC(2)/RAD.     
 0577            AD     DB              DEADBAND SCALED AT PI RADIANS.          
 0578            TS     FPQRMIN         .5(1/ACCMIN)EDOT(2)+DB SCALED AT PI RAD.
                                                                                
 0579            CCS    EDOT            EDOT TEST ON SIGN (NON-ZERO):           
 0580            CAE    E               ATTITUDE ERROR FOR THIS AXIS            
 0581            TCF    +2              SCALED AT PI RADIANS.                   
 0582            TCF    EDOTNEG                                                 
 0583            ADS    FPQR            E+0.5(1/ACC)EDOT(2)-DB SCALED AT PI RAD.
                                                                                
 0584   FTEST    CCS    EDOT            EDOT GUARANTEED NOT +0 OR -0.           
 0585            CCS    FPQR            FPQR GUARANTEED NOT +0.                 
## Page 537
 0586            TCF    QUICKURG        EDOT.G.+0, FPQR.G.+0.                   
 0587            CCS    FPQR            EDOT.L.-0.                              
 0588            TCF    FMINCALC        EDOT.L.-0,FPQR.G.+0/EDOT.G.+0,FPQR.L.-0.
 0589            TCF    FMINCALC        EDOT.G.+0,FPQR.E.-0 (FROM FIRST CCS).   
 0590            TCF    QUICKURG        EDOT.L.-0,FPQR.L.-0.                    
                                                                                
 0591   QUICKURG CAE    EDOT            EDOT.L.-0,FPQR.E.-0 (FROM 2ND CCS).     
 0592            EXTEND                 SCALE FROM PI/16 TO PI RADIANS/SECOND   
 0593            MP     BIT11           TO HAVE SAME SCALING AS FPQR AFTER THE  
 0594            AD     FPQR            IMPLICIT MULT. OF FPQR BY 1/SEC.        
 0595            TCF    URGMULT         THIS URGENCY = (1/ACC)(FPQR+EDOT).      
                                                                                
 0596   EDOTMAX  CCS    A               GURANTEED NOT +0 OR -0.                 
 0597            CAF    POSMAX                                                  
 0598            TCF    EDOTSTOR        SET EDOT TO SIGNED MAXIMUM.             
 0599            CS     POSMAX                                                  
 0600            TCF    EDOTSTOR        SCALED AT PI/16 RADIANS/SECOND.         
                                                                                
 0601   EDOTNEG  CS     FPQR            SCALED AT PI RADIANS                    
 0602            AD     E               ATTITUDE ERROR FOR THIS AXIS            
 0603            TS     FPQR            E-0.5(1/ACC)EDOT(2)+DB SCALED AT PI RAD.
 0604            TCF    FTEST                                                   
                                                                                
 0605   FMINCALC CCS    FPQR            NECESSARY RETEST ON FPQR;               
 0606            CS     FPQRMIN                                                 
 0607            TCF    +2              E-0.5(1/ACCMIN)EDOT(2)-DB               
 0608            CAE    FPQRMIN                                                 
 0609            AD     E               E+0.5(1/ACCMIN)EDOT(2)+DB               
 0610            TS     FPQRMIN         SCALED AT PI RADIANS.                   
                                                                                
 0611            CCS    EDOT            EDOT    GUARANTEED NOT +0 OR -0.        
 0612            CCS    FPQRMIN         FPQRMIN GUARANTEED NOT +0 (CALL IT F).  
 0613            TCF    ZEROURG         EDOT.G.+0, F.G.+0.                      
 0614            CCS    FPQRMIN         EDOT.L.-0.                              
 0615            TCF    NORMURG         EDOT.L.-0, F.G.+0 / EDOT.G.+0, F.L.-0.  
 0616            TCF    NORMURG         EDOT.G.+0, F.E.-0 (FROM FIRST CCS).     
 0617            TCF    ZEROURG         EDOT.L.-0, F.L.-0.                      
 0618   ZEROURG  EXTEND                 EDOT.L.-0, F.E.-0 (FROM 2ND CCS).       
 0619            DCA    DPZEROY         THIS URGENCY IS ZERO.                   
 0620            DXCH   URGENCYQ                                                
 0621            TCF    MOREURG         TEST FOR NEXT AXIS                      
                                                                                
 0622   NORMURG  CAE    FPQRMIN         THIS URGENCY IS FPQRMIN(1/ACC).         
 0623   URGMULT  EXTEND                                                         
 0624            INDEX  AXISCNTR                                                
 0625            MP     1/ACCQ                                                  
 0626            DXCH   URGENCYQ        SAVE D.P. SCALED AT 2(+9).              
                                                                                
 0627   MOREURG  CCS    AXISCNTR        TEST FOR END OF LOOP                    
 0628            TCF    +2              CONTINUE.                               
                                                                                
## Page 538
 0629            TCF    URGSCALQ        FINISHED.                               
                                                                                
 0630            TS     AXISCNTR        Q-AXIS                                  
                                                                                
 0631            EXTEND                                                         
 0632            DCA    URGENCYQ        SET URGENCYR                            
 0633            DXCH   URGENCYR                                                
                                                                                
 0634            DXCH   E               SET ER,EDOT(2)R                         
 0635            DXCH   ER                                                      
 0636            TS     EQ              SET EQ                                  
 0637            CAE    EDOT                                                    
 0638            TS     EDOT(R)         SET EDOT(R).                            
                                                                                
 0639            TCF    URGLOOP         CONTINUE.                               
                                                                                
R0640   SUFFICIENT TEST FOR URGENCY RESCALING:                                  
                                                                                
 0641   URGSCALR CCS    URGENCYR        IF ABVAL(URGENCYR) LESS THAN SCALE BOUND
 0642            AD     SCALEBND                                                
 0643            TCF    +2              THEN BOTH URGENCIES CAN BE RESCALED FROM
 0644            AD     SCALEBND                                                
 0645            EXTEND                 2(+9) TO 2(+4) SECONDS.                 
 0646            BZMF   URGSCALE                                                
 0647            TCF    URGLIMS                                                 
                                                                                
R0648   RESCALE BOTH URGENCIES FROM 2(+9) TO 2(+4) SECONDS:                     
                                                                                
 0649   URGSCALE CAE    URGENCYQ        SHIFT D.P. URGENCYQ LEFT 5-PLACES TO    
 0650            EXTEND                 FORM S.P. URGENCYQ NOW SCALED AT 16 SECS
 0651            MP     BIT6                                                    
 0652            LXCH   URGENCYQ                                                
 0653            CAE    URGENCYQ +1                                             
 0654            EXTEND                                                         
 0655            MP     BIT6                                                    
 0656            ADS    URGENCYQ                                                
                                                                                
 0657            CAE    URGENCYR        SHIFT D.P. URGENCYR LEFT 5-PLACES TO    
 0658            EXTEND                 FORM S.P. URGENCYR NOW SCALED AT 16 SECS
 0659            MP     BIT6                                                    
 0660            LXCH   URGENCYR                                                
 0661            CAE    URGENCYR +1                                             
 0662            EXTEND                                                         
 0663            MP     BIT6                                                    
 0664            ADS    URGENCYR                                                
                                                                                
 0665            CAE    URGLM2          SET URGENCY LIMIT FOR 2(+4) SCALING.    
 0666            TCF    URGFUDGE                                                
                                                                                
 0667   SCALEBND OCTAL  77400            -8 SECONDS SCALED AT 2(+9).            
## Page 539
 0668   DPZEROY  2DEC   0                                                       
                                                                                
R0669   NECESSARY TEST FOR URGENCY RESCALING:                                   
                                                                                
 0670   URGSCALQ CCS    URGENCYQ        IF ABVAL(URGENCYQ) LESS THAN SCALE BOUND
 0671            AD     SCALEBND                                                
 0672            TCF    +2              THEN TEST URGENCYR FOR RESCALABLE       
 0673            AD     SCALEBND                                                
 0674            EXTEND                 MAGNITUDE.                              
 0675            BZMF   URGSCALR                                                
                                                                                
 0676   URGLIMS  CAE    URGLM1          SET URGENCY LIMIT FOR 2(+9) SCALING.    
 0677   URGFUDGE TS     URGLIMIT                                                
                                                                                
R0678   USE URGENCY FUNCTION CORRECTION FACTOR WHEN NECESSARY:                  
                                                                                
 0679            CCS    AOSQ            IF C(AOSQ) ZERO OR IF(URGENCYQ) ZERO,   
 0680            CS     URGENCYQ        THEN IT IS CLEARLY UNNECESSARY TO FUDGE.
 0681            TCF    +2              WHILE MAKING THIS TEST, WE CALCULATE    
 0682            CAE    URGENCYQ        -SIGN(AOSQ)(URGENCYQ) WHICH IF POSITIVE 
 0683            EXTEND                 INDICATES THAT WE ARE TRYING TO FIGHT   
 0684            BZMF   URGFUDG1        THE EFFECT OF AOSQ, SO WE DO NOT FUDGE. 
                                                                                
 0685            CAE    URGRATQ         HERE WE KNOW THAT AOSQ WILL ACTUALLY    
 0686            EXTEND                 HELP THE RCS JETS MANEUVER FOR THIS AXIS
 0687            MP     URGENCYQ        FOR THIS CSP, MULTIPLYING BY URGRATQ    
 0688            TS     URGENCYQ        REDUCES URGENCYQ APPROPRIATELY ENOUGH.  
                                                                                
 0689   URGFUDG1 CCS    AOSR            HERE WE DO THE SAME LOGIC FOR THE R-AXIS
 0690            CS     URGENCYR        COMPUTATIONS AS WE DID FOR THE Q-AXIS AT
 0691            TCF    +2              URGFUDGE.  RATHER THAN REPEAT THE ABOVE 
 0692            CAE    URGENCYR        COMMENTS, WE PROVIDE A BIT OF FURTHER   
 0693            EXTEND                 EXPLANATION; FIRST, ONLY A S.P. URGENCY 
 0694            BZMF   URGPLANE        IS SAVED IF WE DO THE FUDGE, SINCE ONLY 
                                                                                
 0695            CAE    URGRATR         S.P. URGENCIES ARE REFERENCED BELOW AND 
 0696            EXTEND                 NO D.P. ACCURACY IS NEEDED.  SECOND, BY 
 0697            MP     URGENCYR        BY MULTIPLYING BY THE FUDGE RATIO DURING
 0698            TS     URGENCYR        APS BURNS, WE PREVENT SOME RCS FIRINGS  
A0699                                   WHICH WOULD OVER-CORRECT DU TO THE AOS. 
                                                                                
 0700   URGPLANE CAE    URGENCYQ        BEGIN URGENCY-PLANE COMPUTATIONS:       
 0701            EXTEND                                                         
 0702            BZF    BURGZERO        TEST FOR BOTH URGENCIES ZERO            
                                                                                
 0703            EXTEND                                                         
 0704            MP     -TAN22.5                                                
 0705            AD     URGENCYR                                                
 0706            EXTEND                                                         
 0707            MP     COS22.5                                                 
## Page 540
 0708            TS     TERMA           UR.COS(22.5)-UQ.SIN(22.5)               
                                                                                
 0709            CS     URGENCYR                                                
 0710            EXTEND                                                         
 0711            MP     -TAN22.5                                                
 0712            AD     URGENCYQ                                                
 0713            EXTEND                                                         
 0714            MP     COS22.5                                                 
 0715            TS     TERMB           UR.SIN(22.5)+UQ.COS(22.5)               
                                                                                
 0716   A+B/A-B  AD     TERMA                                                   
 0717            TS     A+B                                                     
 0718   A-B/ONLY CS     TERMB                                                   
 0719            AD     TERMA                                                   
 0720            TS     A-B                                                     
                                                                                
R0721   AXIS AND MODE SELECTION                                                 
                                                                                
 0722            CAE    TERMB           B URGENCY TEST                          
 0723            EXTEND                                                         
 0724            BZMF   NEGBURG                                                 
                                                                                
 0725   POSBURG  CAE    TERMA           A URGENCY TEST                          
 0726            EXTEND                                                         
 0727            BZMF   NETAPOSB                                                
                                                                                
 0728   POSAPOSB CAE    A-B                                                     
 0729            EXTEND                                                         
 0730            BZMF   MINUSU          NEGATIVE U-AXIS SELECTED                
                                                                                
 0731   2/4JET-R CAE    1/AMINR                                                 
 0732            TS     .5ACCMNE                                                
 0733            EXTEND                                                         
 0734            DCA    ER                                                      
 0735            DXCH   E                                                       
 0736            CAE    EDOT(R)                                                 
 0737            TS     EDOT                                                    
 0738            CAE    URGLIMIT                                                
 0739            AD     URGENCYR                                                
 0740            EXTEND                                                         
 0741            BZMF   2JETS-R                                                 
                                                                                
 0742   4JETS-R  CS     ONE                                                     
 0743            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0744   2JETS-R  CCS    NJ-R                                                    
 0745            TCF    4JETS-R                                                 
 0746            CS     TWO                                                     
 0747            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
## Page 541
 0748   MINUSU   CAE    1/AMINU                                                 
 0749            TS     .5ACCMNE                                                
 0750            CAE    URGENCYQ                                                
 0751            AD     URGENCYR                                                
 0752            AD     URGLIMIT                                                
 0753            EXTEND                                                         
 0754            BZMF   2JETS-U                                                 
                                                                                
 0755   2JETSM-U TC     UXFORM                                                  
 0756   2-U.RATE CAF    THREE                                                   
 0757            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0758   2JETS-U  CCS    NJ-U                                                    
 0759            TCF    2JETSM-U                                                
 0760            TC     UXFORM                                                  
 0761            CAF    TWO                                                     
 0762            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0763   NETAPOSB CAE    A+B                                                     
 0764            EXTEND                                                         
 0765            BZMF   PLUSV                                                   
                                                                                
 0766   2/4JET-Q CAE    1/AMINQ                                                 
 0767            TS     .5ACCMNE                                                
 0768            CAE    URGLIMIT                                                
 0769            AD     URGENCYQ                                                
 0770            EXTEND                                                         
 0771            BZMF   2JETS-Q                                                 
                                                                                
 0772   4JETS-Q  CS     FIVE                                                    
 0773            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0774   2JETS-Q  CCS    NJ-Q                                                    
 0775            TCF    4JETS-Q                                                 
 0776            CS     SIX                                                     
 0777            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0778   PLUSV    CAE    1/AMINV                                                 
 0779            TS     .5ACCMNE                                                
 0780            CS     URGENCYR                                                
 0781            AD     URGENCYQ                                                
 0782            AD     URGLIMIT                                                
 0783            EXTEND                                                         
 0784            BZMF   2JETS+V                                                 
                                                                                
 0785   2JETSM+V TC     VXFORM                                                  
 0786   2+V.RATE CAF    FIVE                                                    
 0787            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0788   2JETS+V  CCS    NJ+V                                                    
## Page 542
 0789            TCF    2JETSM+V                                                
 0790            TC     VXFORM                                                  
 0791            CAF    FOUR                                                    
 0792            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0793   BURGZERO CAE    URGENCYR        TEST FOR SECOND URGENCY ALSO ZERO       
 0794            EXTEND                                                         
 0795            BZF    GIMBLTRY        BOTH URGENCIES ZERO.  TRY THE GTS.      
                                                                                
 0796            EXTEND                 TIME SAVING A+B CALCULATION             
 0797            MP     SIN22.5                                                 
 0798            TS     TERMB           US.SIN(22.5)                            
 0799            CAE    URGENCYR                                                
 0800            EXTEND                                                         
 0801            MP     COS22.5                                                 
 0802            TS     TERMA           UR.COS(22.5)                            
 0803            TCF    A-B/ONLY                                                
                                                                                
 0804   COS22.5  DEC    0.92388         COSINE OF 22.5 DEGREES                  
 0805   SIN22.5  DEC    0.38268         SINE OF 22.5 DEGREES                    
 0806   -TAN22.5 DEC    -.41421         NEGATIVE OF TANGENT OF 22.5 DEGREES     
                                                                                
 0807   NEGBURG  CAE    TERMA           A URGENCY TEST                          
 0808            EXTEND                                                         
 0809            BZMF   NEGANEGB                                                
                                                                                
 0810   POSANEGB CAE    A+B                                                     
 0811            EXTEND                                                         
 0812            BZMF   2/4JET+Q                                                
                                                                                
 0813   MINUSV   CAE    1/AMINV                                                 
 0814            TS     .5ACCMNE                                                
 0815            CS     URGENCYQ                                                
 0816            AD     URGENCYR                                                
 0817            AD     URGLIMIT                                                
 0818            EXTEND                                                         
 0819            BZMF   2JETS-V                                                 
                                                                                
 0820   2JETSM-V TC     VXFORM                                                  
 0821   2-V.RATE CAF    SEVEN                                                   
 0822            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0823   2JETS-V  CCS    NJ-V                                                    
 0824            TCF    2JETSM-V                                                
 0825            TC     VXFORM                                                  
 0826            CAF    SIX                                                     
 0827            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0828   NEGANEGB CAE    A-B                                                     
 0829            EXTEND                                                         
## Page 543
 0830            BZMF   2/4JET+R                                                
                                                                                
 0831   PLUSU    CAE    1/AMINU                                                 
 0832            TS     .5ACCMNE                                                
 0833            CS     URGLIMIT                                                
 0834            AD     URGENCYQ                                                
 0835            AD     URGENCYR                                                
 0836            EXTEND                                                         
 0837            BZMF   2JETSM+U                                                
                                                                                
 0838   2JETS+U  CCS    NJ+U                                                    
 0839            TCF    2JETSM+U                                                
 0840            TC     UXFORM                                                  
 0841            CAF    ZERO                                                    
 0842            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0843   2JETSM+U TC     UXFORM                                                  
 0844   2+U.RATE CAF    ONE                                                     
 0845            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0846   2/4JET+R CAE    1/AMINR                                                 
 0847            TS     .5ACCMNE                                                
 0848            EXTEND                                                         
 0849            DCA    ER                                                      
 0850            DXCH   E                                                       
 0851            CAE    EDOT(R)                                                 
 0852            TS     EDOT                                                    
 0853            CS     URGENCYR                                                
 0854            AD     URGLIMIT                                                
 0855            EXTEND                                                         
 0856            BZMF   2JETS+R                                                 
                                                                                
 0857   4JETS+R  CS     THREE                                                   
 0858            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0859   2JETS+R  CCS    NJ+R                                                    
 0860            TCF    4JETS+R                                                 
 0861            CS     FOUR                                                    
 0862            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
 0863   2/4JET+Q CAE    1/AMINQ                                                 
 0864            TS     .5ACCMNE                                                
 0865            CS     URGENCYQ                                                
 0866            AD     URGLIMIT                                                
 0867            EXTEND                                                         
 0868            BZMF   2JETS+Q                                                 
                                                                                
 0869   4JETS+Q  CS     SEVEN                                                   
 0870            TCF    POLTYPE         GO FIND BEST POLICY                     
                                                                                
## Page 544
 0871   2JETS+Q  CCS    NJ+Q                                                    
 0872            TCF    4JETS+Q                                                 
 0873            CS     EIGHT                                                   
                                                                                
R0874   GENERALIZED CALLING SEQUENCE FOR ALL Q,R-AXES ROTATIONS (FROM BANK 17): 
                                                                                
 0875   POLTYPE  TS     NETACNDX        SAVE INDEX INDICATING AXIS, DIRECTION,  
 0876            EXTEND                 AND NUMBER OF JETS REQUESTED (THIS SPEC-
 0877            DCA    POLADR          IFIES THE "OPTIMAL" POLICY.  TRANSFER   
 0878            DTCB                   ACROSS BANKS TO POLICY SELECTION ROUTINE
                                                                                
 0879            EBANK= JTSONNOW                                                
 0880   POLADR   2CADR  POLTYPEP        2CADR OF JET POLICY SELECT ROUINTE.     
                                                                                
                                                                                
## Page 545
R0881   SUBROUTINES UXFORM AND VXFORM CALCULATE NEEDED VALUES FOR T-JET LAW     
R0882   (THEY GO OFF TO REDUCE RATE, IF NECESSARY, AND THEN DO NOT RETURN)      
                                                                                
 0883   VXFORM   CAE    1/2JETSV        GET INVERSE OF V-JET ACCELERATION       
 0884            TS     1/NJETAC                                                
 0885            CS     EQ              COMPLEMENT FOR TRANSFORMATION           
 0886            TS     EQ                                                      
 0887            CS     EDOTQ                                                   
 0888            TCF    UVXFORM +1                                              
 0889   UXFORM   CAE    1/2JETSU        SET INVERSE OF U-JET ACCELERATION       
 0890            TS     1/NJETAC                                                
                                                                                
 0891   UVXFORM  CAE    EDOTQ           TRANSFORM ANGULAR RATE TO U/V-AXIS      
 0892            AD     EDOTR                                                   
 0893            EXTEND                                                         
 0894            MP     .707                                                    
 0895            TS     EDOT            SAVE FOR REDUCEUV                       
 0896            EXTEND                                                         
 0897            MP     BIT3                                                    
 0898            EXTEND                                                         
 0899            BZF    UVEDOT          BRANCH IF RESCALING SUCCESSFUL.         
                                                                                
 0900            CCS    A               LIMIT EDOT TO +/- 11.25 DEG/SEC.        
 0901            CAF    POSMAX                                                  
 0902            TCF    UVEDOT1                                                 
 0903            CS     POSMAX                                                  
 0904            TCF    UVEDOT1                                                 
                                                                                
 0905   UVEDOT   CAE    L                                                       
 0906   UVEDOT1  TS     EDOT            RATE ERROR SCALED AT PI/16.             
 0907            EXTEND                                                         
 0908            SQUARE                                                         
 0909            TS     EDOT(2)         SAVE RATE SQUARED SCALED AT PI(2)/2(8)  
                                                                                
 0910            CAE    EQ              TRANSFORM ANGULAR ERROR TO U/V-AXIS     
 0911            AD     ER                                                      
 0912            EXTEND                                                         
 0913            MP     .707                                                    
 0914            TS     E                                                       
                                                                                
 0915            TC     Q                                                       
                                                                                
 0916   -1.5CSPQ DEC    -.00938                                                 
 0917   +TJMINT6 DEC    +.00073                                                 
 0918   -TJMIN16 DEC    -.00097                                                 
 0919   -TJMINQR EQUALS -TJMIN16                                                
 0920   38.7MAT4 DEC    0.00242                                                 
 0921   -MS35AT4 DEC    -.00219         35MS SCALED AT 4                        
## Page 546
 0922   MAXRATE  DEC    0.88889         10 DEGREES/SECOND SCALED AT PI/16       
 0923   MAXRATE2 DEC    0.79012         100 DEG(2)/SEC(2) SCALED AT PI(2)/2(8)  
 0924   .6DEG/SC DEC    0.05333         6/10 DEGREES/SECOND SCALED AT PI/16     
 0925   25/32QR  DEC    0.78125                                                 
                                                                                
                                                                                
## Page 547
R0926   THESE TWO SUBROUTINES TRANSFORM EDOTQ,EDOTR INTO THE U/V-AXIS (RESPECTIVELY) FOR THE RATE COMMAND MODE (ONLY).
R0927   VALUE IS STORED IN EDOTGEN SCALED AT PI/4 RADIANS/SECOND.               
                                                                                
 0928            BANK   17                                                      
                                                                                
 0929   EDOTUGEN CAE    1/2JETSU        FOR U-AXIS TRANSFORMATION               
 0930            TS     1/NJETAC                                                
 0931            CAE    EDOTQ                                                   
 0932            TCF    +4                                                      
 0933   EDOTVGEN CAE    1/2JETSV        FOR V-AXIS TRANSFORMATION               
 0934            TS     1/NJETAC                                                
 0935            CS     EDOTQ                                                   
 0936            AD     EDOTR                                                   
 0937            EXTEND                                                         
 0938            MP     .707                                                    
 0939            TS     RATEDIF                                                 
 0940            TC     Q                                                       
                                                                                
                                                                                
 0941   .707     DEC    0.70711         SQRT(1/2)                               
                                                                                
 0942   SPSBAKUP EXTEND                                                         
 0943            DCA    SPSRCSAD                                                
 0944            DXCH   Z                                                       
 0945            EBANK= DT                                                      
 0946   SPSRCSAD 2CADR  SPSRCS                                                  
                                                                                
                                                                                
## Page 548
R0947   *********TJETLAW*********************************************************************************
                                                                                
 0948   TJETLAW  CS     EDOT            TEST EDOT SIGN                          
 0949            EXTEND                                                         
 0950            BZMF   +4                                                      
 0951            TS     EDOT            SIGNS OF E AND EDOT CHANGED IF EDOT NEG 
 0952            CS     E               TO CONSIDER FUNCTIONS IN UPPER HALF OF  
 0953            TS     E               THE E,EDOT PHASE PLANE                  
                                                                                
 0954            CAE    EDOT(2)         SCALED AT PI(2)/2(8) RAD(2)/SEC(2)      
 0955            EXTEND                 (1/NJETAC HAS BEEN SET FOR N JETS)      
 0956            MP     1/NETACC        IMPLICIT FACTOR OF (1/2).               
 0957            AD     E               SCALED AT PI RADIANS (ERROR)            
 0958            EXTEND                                                         
 0959            SU     DB              SCALED AT PI RADIANS (DEADBAND)         
 0960            TS     HDAP            E + .5EDOT(2)/NJETACC - DB              
                                                                                
 0961            EXTEND                                                         
 0962            BZMF   NEGHDAP                                                 
                                                                                
 0963            CAE    EDOT            SCALED AT PI/16 RAD/SEC (RATE)          
 0964            EXTEND                                                         
 0965            MP     1/NETACC        SCALED AT 2(+8)/PI SEC(2)/RAD: (ACC) (-1)
 0966            DDOUBL                                                         
 0967            TS     TERMA                                                   
                                                                                
 0968            AD     -1.5CSPQ        (EDOT/NETACC)-1.5CSP SCALED AT 16 SECS. 
 0969            EXTEND                                                         
 0970            BZMF   +3                                                      
                                                                                
 0971   MAXTJET  CAF    BIT14           (1/2) IS LIKE POSMAX AT THIS SCALING    
 0972            TCF    NORMRETN        (OVERFLOW IS THUS PREVENTED)            
                                                                                
 0973            CS     HDAP            -DBMINIMP + E + EDOT(2)/NJETACC - DB    
 0974            AD     MINIMPDB        SCALED AT PI RADIANS                    
 0975            EXTEND                                                         
 0976            BZMF   MAINBRCH                                                
                                                                                
 0977            CAE    TERMA           EDOT/NJETACC - .5TJMIN SCALED AT 16 SECS
 0978            AD     -MS35AT4                                                
 0979            EXTEND                 COMPARE TIME-GO-GET-ZERO-RATE WITH 35MS.
 0980            BZMF   INZONE4                                                 
                                                                                
 0981            AD     38.7MAT4        TIME-TO-GET-ZERO-RATE + 1/2 MINIMP.     
 0982            TCF    TJETSCAL                                                
                                                                                
 0983   INZONE4  CCS    EDOT            IF EDOT IS EITHER 00001, 00000, 77777,  
 0984            EXTEND                 OR 77776 (IN OCTAL), THEN THIS CODING   
 0985            BZF    XTRANS          CAUSES A BRANCH TO XTRANS, NO ROTATION  
 0986            EXTEND                 JETS ARE FIRED. *** NOTE: IF THE EXTEND 
## Page 549
 0987            BZF    XTRANS          CODE IS SKIPPED, BZF EXECUTES LIKE TCF. 
                                                                                
                                                                                
 0988            CAE    NO.QJETS        IF NO Q-AXIS JETS THEN MUST HAVE R-AXIS.
 0989            EXTEND                                                         
 0990            BZF    ROTRAXIS                                                
                                                                                
 0991            CAE    OMEGAQD         WITH Q-AXIS JETS, ZERO THE RATE ERROR.  
 0992            TS     OMEGAQ                                                  
                                                                                
 0993            CAE    NO.RJETS        IF NO R-AXIS JETS, THEN Q-AXIS JETS WERE
 0994            EXTEND                 ALREADY FOUND.                          
 0995            BZF    DOTJMIN                                                 
                                                                                
 0996   ROTRAXIS CAE    OMEGARD         WITH R-AXIS JETS, ZERO THE RATE ERROR.  
 0997            TS     OMEGAR                                                  
                                                                                
 0998   DOTJMIN  CAF    +TJMINT6        USE MINIMUM IMPULSE DT FOR TQR.         
 0999            TCF    NORMRETN                                                
                                                                                
 1000   NEGHDAP  CAE    EDOT(2)         SCALED AT PI(2)/2(8) RAD(2)/SEC(2)      
 1001            EXTEND                                                         
 1002            MP     .5ACCMNE        .5(1/ACCMIN) AT 2(8)/PI SEC(2)/RAD.     
 1003            AD     E               ATTITUDE ERROR SCALED AT PI RADIANS     
 1004            AD     DB              DEADBANDS (2) SCALED AT PI RADIANS.     
 1005            AD     DBMINIMP        (DURING APS BURNS DBMINIMP = 0.)        
 1006            EXTEND                                                         
 1007            BZMF   +2                                                      
 1008            TCF    XTRANS          NO ROTATION JETS NEEDED.                
                                                                                
 1009    +2      CS     MAXRATE         10 DEG/SEC SCALED AT PI/16 RAD/SEC      
 1010            AD     EDOT            EDOT-MAXRATE SCALED AT PI/16 RAD/SEC.   
 1011            EXTEND                                                         
 1012            BZMF   +2                                                      
 1013            TCF    XTRANS                                                  
                                                                                
 1014    +2      CS     EDOT            RATE ERROR SCALED AT PI/16 RAD/SEC.     
 1015            EXTEND                 (LIMITED TO +/- 11.25 DEG/SEC.)         
 1016            MP     1/NETACC        SCALED AT 2(+8)/PI SEC(2)/RAD; (ACC):-1)
 1017            DDOUBL                 SCALED AT 2(+4) SECONDS.                
 1018            TS     TERMA                                                   
                                                                                
 1019            CS     HDAP            - E + .5EDOT(2)/NJETACC + DB            
 1020            AD     E                                                       
 1021            AD     E               TWICE ERROR NEGATES E OF HDAP(OLD)      
 1022            AD     MINIMPDB                                                
 1023   MAINBRCH TS     HDAP            -HDAP(OLD) + 2E + DBMINIMP AT PI RADS   
                                                                                
 1024            CAE    1/NETACC        .5(1/NETACC+1/ACCMIN) SCALED AT 2(8)/PI.
## Page 550
 1025            ADS    .5ACCMNE        .5ACCMNE NOW HOLDS DENOM.               
                                                                                
 1026            EXTEND                 DENOM(MAXRATE(2)).HDAP AT PI RADIANS.   
 1027            MP     MAXRATE2                                                
 1028            AD     HDAP                                                    
 1029            EXTEND                                                         
 1030            BZMF   NOROOT                                                  
                                                                                
 1031            CAE    1/NETACC        SAVE (1/NETACC)(2)                      
 1032            DOUBLE                                                         
 1033            EXTEND                                                         
 1034            SQUARE                                                         
 1035            DXCH   INVACCSQ                                                
                                                                                
 1036            CAE    HDAP            (HDAP)/(DENOM)                          
 1037            ZL                                                             
 1038            EXTEND                                                         
 1039            DV     .5ACCMNE                                                
 1040            TS     QUOTTEMP                                                
                                                                                
 1041            EXTEND                 +(HDAP/DENOM)(1/NETACC)(2) AT 2(8) SECS.
 1042            MP     INVACCSQ +1                                             
 1043            TS     INVACCSQ +1                                             
 1044            CAF    ZERO                                                    
 1045            XCH    INVACCSQ                                                
 1046            EXTEND                                                         
 1047            MP     QUOTTEMP                                                
 1048            DAS    INVACCSQ                                                
                                                                                
 1049            EXTEND                 SAVE COPY OF ABOVE D.P. VALUE           
 1050            DCA    INVACCSQ                                                
 1051            DXCH   TERMB                                                   
                                                                                
 1052            CAF    -1.5CSPQ        (1.5CSP-EDOT/NETACC) AT 16 SECS.        
 1053            AD     TERMA                                                   
 1054            EXTEND                                                         
 1055            SQUARE                 (1.5CSP-EDOT/NETACC)(2) AT 256 SECS.    
 1056            DAS    INVACCSQ        (1.5CSP-EDOT/NETACC)(2) - TERMB         
                                                                                
 1057            CAE    INVACCSQ        CHECK HIGH ORDER PART, IF NON-ZERO.     
 1058            EXTEND                                                         
 1059            BZF    ONLYTST1                                                
 1060            TCF    ONLYTST1 +1                                             
                                                                                
 1061   ONLYTST1 CAE    INVACCSQ +1     USE LOW ORDER PART, SINCE HIGH PART 0.  
 1062            EXTEND                                                         
 1063            BZMF   MAXTJET                                                 
                                                                                
 1064            CAF    -TJMIN16        -EDOT/NETACC-TJMIN SCALED AT 16.        
 1065            AD     TERMA                                                   
## Page 551
 1066            EXTEND                                                         
 1067            BZMF   MAYNOJET                                                
                                                                                
 1068   PREROOT  CAF    AFTRUTAD        THIS WILL CAUSE SQUARE ROOT TO BE TAKEN 
 1069            TS     T5ADR           ON THE NEXT T5RUPT.                     
 1070            EXTEND                                                         
 1071            READ   5                                                       
 1072            TS     CH5TEMP                                                 
 1073   JETSON   CAE    JTSONNOW        TURN ON JETS AND END RUPT               
 1074            TC     WRITEQR                                                 
 1075            TCF    RESUME                                                  
                                                                                
 1076   AFTRUTAD GENADR DORUTDUM                                                
 1077   NOROOT   CAF    MAXRATE                                                 
 1078            AD     .6DEG/SC        MAXRATE+DEL SCALED AT PI/16 RAD/SEC.    
 1079            EXTEND                                                         
 1080            MP     1/NETACC        (MAXRATE+DEL)/NETACC                    
 1081            DDOUBL                 SCALED AT 2(+4) SECONDS.                
 1082   TJSUM    AD     TERMA                                                   
 1083   TJETSCAL DOUBLE                 NOW SCALED AT 2(+3) SECONDS.            
 1084            EXTEND                                                         
 1085            MP     25/32QR         SCALED TO 16/25 2(+4) SECONDS AS TIME6. 
 1086            TCF    NORMRETN                                                
                                                                                
 1087   MAYNOJET EXTEND                 RE-INITIALIZE C(INVACCSQ,D.P.)          
 1088            DCA    TERMB           SINCE CLOBBERED ABOVE.                  
 1089            DXCH   INVACCSQ                                                
                                                                                
 1090            CAF    -TJMIN16                                                
 1091            AD     TERMA           TERMA-TJMIN SCALED AT 2(+4) SECONDS.    
 1092            EXTEND                                                         
 1093            SQUARE                 SCALED AT 2(+8) SECONDS.                
 1094            DAS    INVACCSQ        FORM D.P. SUM.                          
                                                                                
 1095            CAE    INVACCSQ        CHECK HIGH ORDER PART IF NON-ZERO.      
 1096            EXTEND                                                         
 1097            BZF    ONLYTST2                                                
 1098            TCF    ONLYTST2 +1                                             
                                                                                
 1099   ONLYTST2 CAE    INVACCSQ +1     USE LOW ORDER PART, SINCE HIGH PART 0.  
 1100            EXTEND                                                         
 1101            BZMF   PREROOT                                                 
 1102            TCF    DOTJMIN         FIRE FOR MINIMUM IMPULSE.               
 1103   CHKSUM17 OCT    37777                                                   
                                                                                
                                                                                
## Page 552
R1104   SUBROUTINE NAME: DAPSQRT        MOD. NO. 0  DATE: DECEMBER 28, 1966     
                                                                                
R1105   AUTHOR: JONATHAN D. ADDLESTON (ADAMS ASSOCIATES)                        
                                                                                
R1106   DAPSQRT IS A SUBROUTINE WHICH PERFORMS THE NECESSARY AND APPROPRIATE INTERFACE FUNCTIONS BETWEEN THE LM DAP AND
R1107   THE PRESENT SPROOT SUBROUTINE IN MASTER.  DAPSQRT EXPECTS A DOUBLE PRECISION ARGUMENT IN C(A,L) AND WILL SHIFT
R1108   THAT QUANTITY SIX OR FOUR BITS TO THE LEFT TO FORM A MORE ACCURAGE SINGLE PRECISION ARGUMENT FOR SPROOT (AND
R1109   THEN SHIFT THE SINGLE PRECISION RESULT OF SPROOT THREE OR TWO BITS TO THE RIGHT IN ORDER TO MAINTAIN SCALING
R1110   CONSISTENCY).  DAPSQRT ALSO PERFORMS THE HERETOFORE NEGLECTED FUNCTION OF SAVING AND RESTORING THE CONTENTS OF
R1111   THE SR (SHIFT-RIGHT) REGISTER WHICH MUST BE DONE BY ALL USERS OF SPROOT IN INTERRUPT.
                                                                                
R1112   NOTE: IF ORIGINAL C(A) = 0, THEN THE SQUARE ROOT SINGLE PRECISION ARGUMENT IS C(L), AND THE RESULT FROM SPROOT
R1113   IS SHIFTED LEFT SEVEN BITS.                                             
                                                                                
R1114   CALLING SEQUENCE:                                                       
                                                                                
R1115                                           L        TC     IBNKCALL        CALL IS ALWAYS FROM ANOTHER BANK.
R1116                                           L +1     CADR   DAPSQRT         ENTER ROUTINE WITH C(A,L) = D.P. ARG.
R1117                                           L +2     (RETURN)               C(A) = BEST VALUE OF SQUARE ROOT.
                                                                                
R1118   ALARM/ABORT MODE: NONE.                                                 
                                                                                
R1119   SUBROUTINES CALLED: SPROOT AND T6JOBCHK.                                
                                                                                
R1120   NORMAL EXIT MODE: RETURN TO L +2.                                       
                                                                                
R1121   OUTPUT: C(A) AT RETURN TO CALLER IS THE BEST SINGLE PRECISION SQUARE ROOT OF THE GIVEN DOUBLE PRECISION ARGUMENT
                                                                                
R1122   ERASABLE INITIALIZATION REQUIRED: DOUBLE PRECISION ARGUMENT AS C(A,L).  
                                                                                
R1123   DEBRIS: ITEMP4, ITEMP5, ITEMP6 AND A,L,Q.                               
                                                                                
                                                                                
 1124            BANK   26                                                      
 1125            EBANK= FUNCTION                                                
                                                                                
R1126   SRTEMP        ERASE                                   SCRATCH CELLS FOR DAPSQRT
R1127   SQRTTEMP      ERASE                                   SCRATCH CELLS FOR DAPSQRT
R1128   SQRTTEMQ      ERASE                                   SCRATCH CELLS FOR DAPSQRT
                                                                                
 1129   DAPSQRT  TS     SQRTTEMP        SAVE C(A) PART OF DOUBLE PRECISION ARG. 
                                                                                
 1130            EXTEND                 SAVE C(Q) FOR RETURN TO LM DAP CALLER.  
 1131            QXCH   SQRTTEMQ                                                
                                                                                
 1132            CAE    SR              SAVE C(SR) SINCE ALL INTERRUPT PROGRAMS 
 1133            DOUBLE                 USING SPROOT MUST DO SO.                
 1134            TS     SRTEMP                                                  
## Page 553
 1135            TC     T6JOBCHK        CHECK TIME6-RUPT BEFORE SPROOT.         
                                                                                
 1136            CAE    SQRTTEMP        RESTORE D.P. ARG. TO C(A,L), AND THEN   
 1137            EXTEND                 CHECK FOR C(A) = +0.  IF SO, TAKE THE   
 1138            BZF    DAPSQRT3        SQUARE ROOT OF C(L) AND POST-SHIFT.     
                                                                                
 1139            MASK   DAPHIGH7        IF THIS MASK PRODUCES A WORD OF ZEROS,  
 1140            EXTEND                 C(D.P.ARG) WILL BE SHIFTED LEFT 6 BITS  
 1141            BZF    SQRTSL6         WITHOUT OVERFLOWING BEFORE USING SPROOT.
                                                                                
 1142            MASK   DAPHIGH5        IF THIS MASK PRODUCES A WORD OF ZEROS,  
 1143            EXTEND                 C(D.P.ARG) WILL BE SHIFTED LEFT 4 BITS  
 1144            BZF    SQRTSL4         WITHOUT OVERFLOWING BEFORE USING SPROOT.
                                                                                
 1145            CAE    SQRTTEMP        GET UNSHIFTED S.P. ARGUMENT FOR SPROOT. 
                                                                                
 1146            TC     SPROOT          CALL SUBROUTINE IN FIXED-FIXED.         
                                                                                
 1147   DAPSQRT1 LXCH   SRTEMP          RESTORE C(SR).                          
 1148            LXCH   SR                                                      
                                                                                
 1149            TC     SQRTTEMQ        RETURN WITH SQUARE ROOT AS C(A).        
                                                                                
 1150   SQRTSL6  CAF    BIT9            SET UP TO SHIFT D.P. ARG. LEFT 6 BITS   
 1151            TS     Q                                                       
 1152            CAF    BIT12           AND TO SHIFT SPROOT ANS. RIGHT 3 BITS.  
 1153            TCF    DAPSQRT2                                                
                                                                                
 1154   SQRTSL4  CAF    BIT11           SET UP AND SHIFT D.P. ARG. LEFT 4 BITS  
 1155            TS     Q                                                       
 1156            CAF    BIT13           AND TO SHIFT SPROOT ANS. RIGHT 2 BITS.  
 1157   DAPSQRT2 XCH    SQRTTEMP        (RECONSTRUCT D.P. ARGUMENT.)            
                                                                                
 1158            EXTEND                 VARIABLE LEFT SHIFT (4 OR 6 BITS).      
 1159            DV     Q               (MAC HAS DIFFEQ, LM DAP HAS DV Q - PUN?)
 1160   DAPROOT  TC     SPROOT          CALL SUBROUTINE IN FIXED-FIXED          
 1161            EXTEND                 VARIABLE RIGHT SHIFT (2 OR 3 BITS).     
 1162            MP     SQRTTEMP                                                
                                                                                
 1163            TCF    DAPSQRT1        RETURN SEQUENCE.                        
                                                                                
 1164   DAPSQRT3 CAF    BIT8            SET UP TO SHIFT SPROOT ANS. RIGHT 7 BITS
 1165            TS     SQRTTEMP                                                
 1166            CAE    L               USE C(L) AS SPROOT ARGUMENT.            
 1167            TCF    DAPROOT                                                 
                                                                                
 1168   DAPHIGH7 OCTAL  77400                                                   
 1169   DAPHIGH5 OCTAL  76000                                                   
                                                                                
