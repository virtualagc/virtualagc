### FILE="Main.annotation"
## Copyright:   	Public domain.
## Filename:    KALMAN_FILTER_FOR_LM_DAP.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-17 MAS  Began.
##              2016-10-18 MAS  Completed adaptation from Aurora 12 / transcription.
##		2016-10-31 RSB	Typos
##		2016-12-06 RSB	Comment-proofing via octopus/ProoferComments; changes
##				were made.

## Page 574
# THE FOLLOWING T5RUPT ENTRY BEGINS THE PROGRAM WHICH INITIALIZES THE KALMAN FILTER AND SETS UP A P-AXIS RUPT TO
# OCCUR 20 MS FROM ITS BEGINNING.

                EBANK=          DT
                BANK            21                              
FILTINIT        CAF             MS30F                           # RESET TIMER IMMEDIATELY -   DT = 30 MS
                TS              TIME5                           

                LXCH            BANKRUPT                        # INTERRUPT LEAD IN (CONTINUED)
                EXTEND                                          
                QXCH            QRUPT                           

                EXTEND                                          # SET UP FOR P-AXIS RUPT
                DCA             PAX/FILT                        
                DXCH            T5ADR                           

                CAF             MOSTPASS                        # SET UP TO PERMIT DT CALCULATION DURING
                TS              STEERADR                        # KALMAN FILTER INITIALIZATION PASS.

                TCF             CLEARCH5                        # TURN OFF Q,R-AXES RCS JETS.

FIRSTADR        GENADR          FILFIRST                        

# THE FOLLOWING T5RUPT ENTRY BEGINS THE KALMAN FILTER PROGRAM.  THIS SECTION ALSO SETS UP A T5RUPT TO OCCUR 20 MS
# FROM ITS BEGINNING AND SETS IT TO GO TO THE LOCATION AT THE TOP OF THE POST FILTER RUPT LIST.

MOSTPASS        GENADR          DTCALC                          # WORD IN FILTPASS FOR THESE PASSES

FILTER          CAF             MS30F                           # RESET TIMER IMMEDIATELY -   DT = 30 MS
                TS              TIME5                           

                LXCH            BANKRUPT                        # INTERRUPT LEAD IN (CONTINUED)
                EXTEND                                          
                QXCH            QRUPT                           

                EXTEND                                          # SET RUPT ADDRESS TO TOP OF
                DCA             PFRPTLST                        # POST FILTER RUPT LIST
                DXCH            T5ADR                           

                CS              T5ADR                           # IF THE TRIM GIMBAL CONTROL RUPT IS NEXT,
                AD              GTS2CADR                        # REDUCE THE LENGTH OF THIS TIME5 RUPT.
                EXTEND
                BZF             +2
                TCF             +3
                CAF             MS20F                           # RESET TIMER IMMEDIATELY - DT = 20MS
                TS              TIME5

                DXCH            PFRPTLST                        # ROTATE 2CADR'S IN POST FILTER RUPT LIST
                DXCH            PFRPTLST        +6              
                DXCH            PFRPTLST        +4              
## Page 575
                DXCH            PFRPTLST        +2              
                TCF             COUNTDWN                        # DECREMENT PASSCTR

# BEGIN THE KALMAN FILTER BY READING CDU ANGLES AND TIME.

FILSTART        TC              T6JOBCHK                        # CHECK T6 CLOCK FOR P-AXIS ACTIVITY

                EXTEND                                          
                DCA             CDUY                            # STORE CDUY AND CDUZ AT PI AND IN 2,S COM
                DXCH            STORCDUY                        
                EXTEND                                          # BEGIN READING THE CLOCK TO GET TIME
                READ            4                               #   INCREMENT.
                TS              L                               
                EXTEND                                          
                RXOR            4                               # CHECK TO SEE IF CH 4 WAS IN TRANSITION
                EXTEND                                          #   WHEN IT WAS FIRST READ.
                BZF             +4                              # BRANCH IF TIME WAS THE SAME IN 2 READS.
                EXTEND                                          
                READ            4                               
                TS              L                               # THIS TIME READ ALWAYS GIVES GOOD NO.
                TC              STEERADR                        # SKIP DTCALC DURING INITIAL PASS

DTCALC          CS              L                               
                AD              DAPTIME                         # A CONTAINS THE TIME DIFFERENCE (DT)
                LXCH            DAPTIME                         #   SINCE THE LAST FILTER.
                EXTEND                                          
                BZMF            +3                              
                AD              NEG1/2                          # THIS IS ADDING -1.0 TO -DT AND ACCOUNTS
                AD              NEG1/2                          # FOR AN OVERFLOW INTO CHANNEL 5

# SCALING OF DELTA T FOR KALMAN FILTER IS 1/8 SECOND.

                EXTEND                                          # TIME NOW SCALED AT 5.12 SECONDS
                MP              BIT7                            # FIRST RESCALE TO 5.12/64
                CS              .64                             
                EXTEND                                          # THEN RESCALE TO 5.12/(64*.64) OR
                MP              L                               # 5.12/40.96 WHICH IS THE SAME AS
                TCF             TIMEDONE                        # DT SCALED AT 1/8.  JUMP VIA STEERAD2.
# SET UP FILTER WEIGHTING VECTOR FOR THIS FILTER PASS.

                CCS             WPOINTER                        # TEST FOR WEIGHTING VECTOR STEADY-STATE
                TCF             MOVEWGTS                        # POINTER NOT YET ZERO (MULTIPLE OF THREE)
                EBANK=          DT
PAX/FILT        2CADR           PAXIS                           # (ROOM FOR 2CADR IN CCS HOLES)

                TCF             FLTZAXIS                        # STEADY-STATE ALREADY, NO UPDATING AGAIN

MOVEWGTS        CS              THREE                           # SET UP POINTER FOR THIS PASS
                ADS             WPOINTER                        # (NEVER GETS BELOW ZERO HERE)
## Page 576
                EXTEND                                          # WPOINTER IS INDEX = 87 FIRST TIME HERE
                INDEX           WPOINTER                        # AND IS DECREASED BY 3 EVERY FILTER PASS
                DCA             WVECTOR                         # UNTIL THE STEADY-STATE IS REACHED.
                DXCH            W0                              # MOVE IN NEW W0,W1
                INDEX           WPOINTER                        
                CAF             WVECTOR         +2              
                TS              W2                              # MOVE IN NEW W2

FLTZAXIS        CAF             TWO                             # SET UP INDEXER FOR D.P. PICKUP AND TO
                TS              QRCNTR                          # INDICATE Z-AXIS FILTER PASS

                TCF             FLTYAXIS                        

GOYFILTR        CAF             ZERO                            # SET INDEXER FOR Y-AXIS
                TS              QRCNTR                          

                TC              T6JOBCHK                        # CHECK T6 CLOCK FOR P-AXIS ACTIVITY

FLTYAXIS        INDEX           QRCNTR                          
                DXCH            CDUYFIL                         # THETA IS D.P. SCALED AT 2 PI RADIANS
                DXCH            CDU                             
                INDEX           QRCNTR                          #   .
                DXCH            DCDUYFIL                        # THETA IS D.P. SCALED AT PI/4 RAD/SEC
                DXCH            CDUDOT                          
                INDEX           QRCNTR                          #  ..                                 2
                DXCH            D2CDUYFL                        # THETA IS D.P. SCALED AT PI/8 RAD/SEC
                DXCH            CDU2DOT                         
                INDEX           QRCNTR                          #  ...                        7       3
                CAE             Y3DOT                           # THETA IS S.P. SCALED AT PI/2 RAD/SEC
                XCH             CDU3DOT                         

# NOTE THAT THE FILTERED VARIABLES ARE READ DESTRUCTIVELY FOR SPEED AND EFFICIENCY AND THAT Y3DOT IS NOT UPDATED,
# SO IT MUST BE READ NON-DESTRUCTIVELY BUT NEED NOT BE RESTORED AFTER EACH KALMAN FILTER PASS.

## Page 577
# INTEGRATION EXTRAPOLATION EQUATIONS:

KLMNFLTR        CAE             CDU2DOT                         # A SCALED AT PI/8 (USE S.P.)
                EXTEND                                          
                MP              DT                              # ADT SCALED AT PI/64 OR .5ADT AT PI/128
                EXTEND                                          
                MP              BIT10                           # RESCALE BY RIGHT SHIFT 5
                AD              CDUDOT                          # W + .5ADT SCALED AT PI/4
                EXTEND                                          
                MP              DT                              # (W + .5ADT)DT SCALED AT PI/32
                EXTEND                                          
                MP              BIT9                            # RESCALE BY RIGHT SHIFT 6 (KEEP D.P.)
                DAS             CDU                             # CDU = CDU + (W + .5ADT)DT SCALED AT 2PI

                CAE             CDU3DOT                         # ADOT SCALED AT PI/2(7)
                EXTEND                                          
                MP              DT                              # .5ADOTDT SCALED AT PI/2(11)
                TS              ITEMP5                          # (SAVE FOR ALPHA INTEGRATION)
                EXTEND                                          
                MP              BIT7                            # RESCALE BY RIGHT SHIFT 8
                AD              CDU2DOT                         # A + .5ADOTDT SCALED AT PI/8
                EXTEND                                          
                MP              DT                              # (A + .5ADOTDT)DT SCALED AT PI/64
                EXTEND                                          
                MP              BIT11                           # RESCALE BY RIGHT SHIFT 4 (KEEP D.P.)
                DAS             CDUDOT                          # W = W + (A + .5ADOTDT)DT SCALED AT PI/4

                CAE             ITEMP5                          # ADOTDT SCALED AT PI/2(10) (FROM ABOVE)
                EXTEND                                          
                MP              BIT8                            # RESCALE BY RIGHT SHIFT 7 (KEEP D.P.)
                DAS             CDU2DOT                         # A = A + ADOTDT SCALED AT PI/8

## Page 578

# WEIGHTING VECTOR ADJUSTMENT EQUATIONS:

                EXTEND                                          # CONVERT CDU INTEGRATED VALUE FROM DOUBLE
                DCA             CDU                             # PRECISION SCALED AT 2PI IN ONES COMPLE-
                TC              ONETOTWO                        # MENT TO SINGLE PRECISION SCALED AT PI
                CCS             QRCNTR
                INDEX           A                               # IN TWOS COMPLEMENT, THEN DIFFERENCE WITH
                CAE             STORCDUY
                EXTEND                                          # STORED CDU REGISTER READING TO GET A
                MSU             ITEMP5                          # SINGLE PRECISION ONES COMPLEMENT RESULT
                TS              DPDIFF                          # SCALED AT PI RADIANS (UPPER HALF)

                CS              CDU             +1              # CREATE LOW ORDER WORD OF D.P. DIFFERENCE
                DOUBLE                                          # ONES COMPLEMENT SCALED AT PI RADIANS AND
                XCH             DPDIFF          +1              # USE S.P. RESULT ABOVE AS HIGH ORDER WORD

                EXTEND                                          # DPDIFF IS D.P. AT PI
                DCA             DPDIFF                          
                LXCH            ITEMP5                          # SAVE LOW ORDER WORD FOR D.P. MULTIPLY
                EXTEND                                          
                MP              W0                              # CDU = CDU + DPDIFF (D.P.) * W0 (S.P.)
                DAS             CDU                             
                CAE             ITEMP5                          # W0 IS SCALED AT 2
                EXTEND                                          # DPDIFF IS RESCALED TO PI
                MP              W0                              # W0*DPDIFF IS SCALED AT 2PI (AS CDU)
                ADS             CDU             +1       
                TS              L                               
                TCF             +2                              
                ADS             CDU                             

                CAE             DPDIFF                          # RESCALE DPDIFF TO PI/128
                EXTEND                                          
                MP              BIT8                            # DPDIFF (D.P.) * 128
                LXCH            ITEMP5                          
                CAE             DPDIFF          +1              
                EXTEND                                          
                MP              BIT8                            
                AD              ITEMP5                          
                LXCH            ITEMP5                          

                EXTEND                                          #  .     .
                MP              W1                              # CDU = CDU + DPDIFF (D.P.) * W1 (S.P.)
                DAS             CDUDOT                          
                CAE             ITEMP5                          # W1 IS SCALED AT 32
                EXTEND                                          # DPDIFF IS RESCALED TO PI/128
                MP              W1                              # W1*DPDIFF IS SCALED AT PI/4 (AS CDUDOT)
                ADS             CDUDOT          +1              
                TS              L                               
                TCF             +2                              
                ADS             CDUDOT                          

## Page 579
                CAE             DPDIFF                          # RESCALE DPDIFF TO PI/64
                EXTEND                                          
                MP              BIT7                            # DPDIFF (D.P.) * 64
                LXCH            ITEMP5                          
                CAE             DPDIFF          +1              
                EXTEND                                          
                MP              BIT7                            
                AD              ITEMP5                          
                LXCH            ITEMP5                          

                EXTEND                                          #  ..    ..
                MP              W2                              # CDU = CDU + DPDIFF (D.P.) * W2 (S.P.)
                DAS             CDU2DOT                         
                CAE             ITEMP5                          # W2 IS SCALED AT 8
                EXTEND                                          
                MP              W2                              # W2*DPDIFF IS SCALED AT PI/8 (AS CDU2DOT)
                ADS             CDU2DOT         +1              
                TS              L                               
                TCF             +2                              
                ADS             CDU2DOT                         

# RESTORE VARIABLES AND TEST FOR COMPLETION OR ADDITIONAL AXIS.

FILTAXIS        DXCH            CDU                             
                INDEX           QRCNTR                          # THETA IS D.P. SCALED AT 2 PI RADIANS
                DXCH            CDUYFIL                         
                DXCH            CDUDOT                          #   .
                INDEX           QRCNTR                          # THETA IS D.P. SCALED AT PI/4 RAD/SEC
                DXCH            DCDUYFIL                        
                DXCH            CDU2DOT                         #  ..                                 2
                INDEX           QRCNTR                          # THETA IS D.P. SCALED AT PI/8 RAD/SEC
                DXCH            D2CDUYFL                        

                CCS             QRCNTR
                TCF             GOYFILTR                        # IF 2, Y-AXIS STILL TO GO

                CS              T5ADR                           # IF THE TRIM GIMBAL CONTROL RUPT IS NEXT,
                AD              GTS2CADR                        # DO THE Q,R-AXIS STATE TRANSFORMATIONS
                EXTEND                                          # AND THE 20 MS STATE EXTRAPOLATION
                BZF             GIMBAL                          
                TCF             RESUME                          # OTHERWISE, RESUME

# SUBROUTINE FOR FILTER WHICH TAKES 1 COMPLEMENT NUMBER INTO A 2 COMP.

ONETOTWO        DDOUBL                                          # SEE RTB OP CODES IN BANK 15 FOR NOTES ON
                CCS             A                               #   THIS COMPUTATION.
                AD              ONE                             
                TCF             +2                              
                COM                                             
                TS              ITEMP5                          
## Page 580
                TCF             +4                              
                INDEX           A                               
                CAF             LIMITS                          
                ADS             ITEMP5                          
                TC              Q                               # RETURN

# THIS PROGRAM INITIALIZES THE KALMAN FILTER PROGRAM.

FILFIRST        LXCH            DAPTIME                         # INITIALIZE TIME.
                CAF             POINT=90                        # INITIALIZE THE WEIGHTING VECTOR POINTER
                TS              WPOINTER                        
                CAF             MOSTPASS                        # SET UP FOR NEXT PASSES
                TS              STEERADR                        
                EXTEND                                          # SET UP POST FILTER RUPT LIST
                DCA             DGTSFADR                        
                DXCH            PFRPTLST                        
                EXTEND                                          
                DCA             PAX/FILT                        
                DXCH            PFRPTLST        +2              
                EXTEND                                          
                DCA             PAX/FILT                        
                DXCH            PFRPTLST        +6              
                EXTEND                                          
                DCA             GTS2CADR                        
                DXCH            PFRPTLST        +4              
                EXTEND                                          # CHANGE POST P FILTER TO FILTER
                DCA             POSTPFIL                        
                DXCH            PFILTADR                        

                CAE             STORCDUY                        
                EXTEND                                          
                MP              BIT14                           
                DXCH            CDUYFIL                         # INITIALIZE THE STATE VECTOR TO CDU VALUE
                CAE             STORCDUZ                        
                EXTEND                                          
                MP              BIT14                           
                DXCH            CDUZFIL                         
                CA              ZERO                            
                TCF             +4                              # RATES INITIALIZED BY RATEINIT.
                TS              DCDUYFIL        +1              
                TS              DCDUZFIL                        
                TS              DCDUZFIL        +1              
                TS              D2CDUYFL                        
                TS              D2CDUYFL        +1              
                TS              D2CDUZFL                        
                TS              D2CDUZFL        +1              
                TS              Y3DOT                           
                TS              Z3DOT                           
                TS              NEGUQ                           
                TS              NEGUR                           
## Page 581
                TS              QACDOTMP                        # INITIALIZE TEMPORARY STORAGE FOR QACCDOT
                TS              RACDOTMP                        # AND RACCDOT VALUES COMING FROM GTS.
                TCF             RESUME                          



.64             DEC             0.64000                         
BIT12-13        OCTAL           14000                           
POINT=90        DEC             90                              # POINTER INITIALIZED ONE GROUP PAST END
MS20F           OCTAL           37776                           
MS30F           OCTAL           37775                           
                EBANK=          DT
DGTSFADR        2CADR           DGTS                            

PAXISADR        GENADR          PAXIS                           
                EBANK=          DT
GTS2CADR        2CADR           GTS                             

                EBANK=          DT
POSTPFIL        2CADR           FILTER                          

## Page 582
# THE KALMAN FILTER WEIGHTINF VECTORS ARE LISTED IN THE FOLLOWING TABLE ALONG WITH THE TIME FROM THE LAST FILTER
# INITIALIZATION FOR WHICH THEY ARE TO BE USED.  (THE VECTORS ARE STORED IN ORDERED TRIPLES (W0,W1,W2) IN
# DESCENDING ORDER IN TIME WITH THE STEADY STATE VALUES AT THE TOP.)

# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

# WEIGHTING VECTOR SET :   07/28/67     9:07

# THE COMPONENTS ARE SCALED AS FOLLOWS:
#          W0 : SCALED AT  2
#          W1 : SCALED AT 32
#          W2 : SCALED AT  8

WVECTOR         DEC             0.07679                         # W0 AT RELATIVE TIME : 1.50 SECS. OR MORE
                DEC             0.00799                         # W1 AT RELATIVE TIME : 1.50 SECS. OR MORE
                DEC             0.02665                         # W2 AT RELATIVE TIME : 1.50 SECS. OR MORE
                DEC             0.13072                         # W0 AT RELATIVE TIME : 1.45 SECONDS
                DEC             0.02213                         # W1 AT RELATIVE TIME : 1.45 SECONDS
                DEC             0.10086                         # W2 AT RELATIVE TIME : 1.45 SECONDS
                DEC             0.13435                         # W0 AT RELATIVE TIME : 1.40 SECONDS
                DEC             0.02350                         # W1 AT RELATIVE TIME : 1.40 SECONDS
                DEC             0.11054                         # W2 AT RELATIVE TIME : 1.40 SECONDS
                DEC             0.13816                         # W0 AT RELATIVE TIME : 1.35 SECONDS
                DEC             0.02499                         # W1 AT RELATIVE TIME : 1.35 SECONDS
                DEC             0.12154                         # W2 AT RELATIVE TIME : 1.35 SECONDS
                DEC             0.14215                         # W0 AT RELATIVE TIME : 1.30 SECONDS
                DEC             0.02662                         # W1 AT RELATIVE TIME : 1.30 SECONDS
                DEC             0.13403                         # W2 AT RELATIVE TIME : 1.30 SECONDS
                DEC             0.14632                         # W0 AT RELATIVE TIME : 1.25 SECONDS
                DEC             0.02841                         # W1 AT RELATIVE TIME : 1.25 SECONDS
                DEC             0.14826                         # W2 AT RELATIVE TIME : 1.25 SECONDS
                DEC             0.15066                         # W0 AT RELATIVE TIME : 1.20 SECONDS
                DEC             0.03035                         # W1 AT RELATIVE TIME : 1.20 SECONDS
                DEC             0.16446                         # W2 AT RELATIVE TIME : 1.20 SECONDS
                DEC             0.15516                         # W0 AT RELATIVE TIME : 1.15 SECONDS
                DEC             0.03247                         # W1 AT RELATIVE TIME : 1.15 SECONDS
                DEC             0.18293                         # W2 AT RELATIVE TIME : 1.15 SECONDS
                DEC             0.15980                         # W0 AT RELATIVE TIME : 1.10 SECONDS
                DEC             0.03477                         # W1 AT RELATIVE TIME : 1.10 SECONDS
                DEC             0.20395                         # W2 AT RELATIVE TIME : 1.10 SECONDS
                DEC             0.16452                         # W0 AT RELATIVE TIME : 1.05 SECONDS
                DEC             0.03726                         # W1 AT RELATIVE TIME : 1.05 SECONDS
                DEC             0.22781                         # W2 AT RELATIVE TIME : 1.05 SECONDS
                DEC             0.16926                         # W0 AT RELATIVE TIME : 1.00 SECONDS
                DEC             0.03991                         # W1 AT RELATIVE TIME : 1.00 SECONDS
                DEC             0.25475                         # W2 AT RELATIVE TIME : 1.00 SECONDS
                DEC             0.17393                         # W0 AT RELATIVE TIME : 0.95 SECONDS
                DEC             0.04272                         # W1 AT RELATIVE TIME : 0.95 SECONDS
                DEC             0.28488                         # W2 AT RELATIVE TIME : 0.95 SECONDS
                DEC             0.17839                         # W0 AT RELATIVE TIME : 0.90 SECONDS
## Page 583
                DEC             0.04562                         # W1 AT RELATIVE TIME : 0.90 SECONDS
                DEC             0.31809                         # W2 AT RELATIVE TIME : 0.90 SECONDS
                DEC             0.18247                         # W0 AT RELATIVE TIME : 0.85 SECONDS
                DEC             0.04853                         # W1 AT RELATIVE TIME : 0.85 SECONDS
                DEC             0.35383                         # W2 AT RELATIVE TIME : 0.85 SECONDS
                DEC             0.18597                         # W0 AT RELATIVE TIME : 0.80 SECONDS
                DEC             0.05132                         # W1 AT RELATIVE TIME : 0.80 SECONDS
                DEC             0.39087                         # W2 AT RELATIVE TIME : 0.80 SECONDS
                DEC             0.18867                         # W0 AT RELATIVE TIME : 0.75 SECONDS
                DEC             0.05380                         # W1 AT RELATIVE TIME : 0.75 SECONDS
                DEC             0.42701                         # W2 AT RELATIVE TIME : 0.75 SECONDS
                DEC             0.19040                         # W0 AT RELATIVE TIME : 0.70 SECONDS
                DEC             0.05576                         # W1 AT RELATIVE TIME : 0.70 SECONDS
                DEC             0.45880                         # W2 AT RELATIVE TIME : 0.70 SECONDS
                DEC             0.19117                         # W0 AT RELATIVE TIME : 0.65 SECONDS
                DEC             0.05698                         # W1 AT RELATIVE TIME : 0.65 SECONDS
                DEC             0.48160                         # W2 AT RELATIVE TIME : 0.65 SECONDS
                DEC             0.19127                         # W0 AT RELATIVE TIME : 0.60 SECONDS
                DEC             0.05736                         # W1 AT RELATIVE TIME : 0.60 SECONDS
                DEC             0.49013                         # W2 AT RELATIVE TIME : 0.60 SECONDS
                DEC             0.19142                         # W0 AT RELATIVE TIME : 0.55 SECONDS
                DEC             0.05702                         # W1 AT RELATIVE TIME : 0.55 SECONDS
                DEC             0.47984                         # W2 AT RELATIVE TIME : 0.55 SECONDS
                DEC             0.19273                         # W0 AT RELATIVE TIME : 0.50 SECONDS
                DEC             0.05644                         # W1 AT RELATIVE TIME : 0.50 SECONDS
                DEC             0.44869                         # W2 AT RELATIVE TIME : 0.50 SECONDS
                DEC             0.19660                         # W0 AT RELATIVE TIME : 0.45 SECONDS
                DEC             0.05649                         # W1 AT RELATIVE TIME : 0.45 SECONDS
                DEC             0.39845                         # W2 AT RELATIVE TIME : 0.45 SECONDS
                DEC             0.20443                         # W0 AT RELATIVE TIME : 0.40 SECONDS
                DEC             0.05837                         # W1 AT RELATIVE TIME : 0.40 SECONDS
                DEC             0.33458                         # W2 AT RELATIVE TIME : 0.40 SECONDS
                DEC             0.21746                         # W0 AT RELATIVE TIME : 0.35 SECONDS
                DEC             0.06360                         # W1 AT RELATIVE TIME : 0.35 SECONDS
                DEC             0.26452                         # W2 AT RELATIVE TIME : 0.35 SECONDS
                DEC             0.23678                         # W0 AT RELATIVE TIME : 0.30 SECONDS
                DEC             0.07419                         # W1 AT RELATIVE TIME : 0.30 SECONDS
                DEC             0.19555                         # W2 AT RELATIVE TIME : 0.30 SECONDS
                DEC             0.26366                         # W0 AT RELATIVE TIME : 0.25 SECONDS
                DEC             0.09322                         # W1 AT RELATIVE TIME : 0.25 SECONDS
                DEC             0.13332                         # W2 AT RELATIVE TIME : 0.25 SECONDS
                DEC             0.29988                         # W0 AT RELATIVE TIME : 0.20 SECONDS
                DEC             0.12645                         # W1 AT RELATIVE TIME : 0.20 SECONDS
                DEC             0.08144                         # W2 AT RELATIVE TIME : 0.20 SECONDS
                DEC             0.34809                         # W0 AT RELATIVE TIME : 0.15 SECONDS
                DEC             0.18652                         # W1 AT RELATIVE TIME : 0.15 SECONDS
                DEC             0.04182                         # W2 AT RELATIVE TIME : 0.15 SECONDS
                DEC             0.41088                         # W0 AT RELATIVE TIME : 0.10 SECONDS
                DEC             0.30542                         # W1 AT RELATIVE TIME : 0.10 SECONDS
                DEC             0.01526                         # W2 AT RELATIVE TIME : 0.10 SECONDS
## Page 584
                DEC             0.47825                         # W0 AT RELATIVE TIME : 0.05 SECONDS
                DEC             0.57064                         # W1 AT RELATIVE TIME : 0.05 SECONDS
                DEC             0.00174                         # W2 AT RELATIVE TIME : 0.05 SECONDS
# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

## Page 585
# DUMMY TRIM GIMBAL RUPT:

DGTS            CAF             MS20F                           # RESET TIMER IMMEDIATELY -   DT = 20 MS
                TS              TIME5                           
                LXCH            BANKRUPT                        # INTERRUPT LEAD IN (CONTINUED)
                EXTEND
                QXCH            QRUPT

                EXTEND                                          # SET UP FILTER RUPT
                DCA             POSTPFIL                        
                DXCH            T5ADR                           

                CS              RACDOTMP                        # STORE NEW VALUES OF QACCDOT, RACCDOT NOW
                TS              RACCDOT                         # THAT 100 MS HAVE PASSED.  (REMEMBER THAT
                CS              QACDOTMP                        # THESE ARE STORED COMPLEMENTED.)
                TS              QACCDOT
                TCF             RESUME

                EBANK=          DT
                BANK            20

# DUMMY FILTER RUPT AFTER Q,R-AXES RUPT:

MS30120         OCTAL           37775
                EBANK=          TQR
PAXBNK20        2CADR           PAXIS

FILDUMMY        CAF             MS30120                         # RESET TIMER IMMEDIATELY - DT= 30 MS
                TS              TIME5                           

                LXCH            BANKRUPT                        # INTERRUPT LEAD IN (CONTINUED)
                EXTEND                                          # SAVE THE LAST Q ON ALL T5RUPT LEAD IN'S
                QXCH            QRUPT

                EXTEND                                          # SET UP PAXIS RUPT
                DCA             PAXBNK20
                DXCH            T5ADR                           

                TC              TORQUEVK
                TCF             RESUME                          

# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

# CODING FOR RATE HOLD MODE WRITTEN OVER.

# FROM ENGINOF1.  MAKE SURE FLAGS FOR EXTRAORDINARY GTS ARE DOWN.

RESETCTR        CA              EBANK6                          # SAVE CALLERS EBANK.
                XCH             EBANK
                TS              ITEMP6                          # SAVE L IN CASE THIS WAS 1STENGOF.
## Page 586
                CAF             NEGMAX
                TS              TRIMCNTR
                CAF             ZERO
                TS              GTSMNITR

                CA              ITEMP6                          # RESTORE CALLERS EBANK.
                TS              EBANK

                TC              Q                               # RETURN TO CALLER OF ENGINOFF OR ENGINOF1

# FROM APSENGON - STORE IGNITION TIME FOR THE ENGINOFF DELAY LOGIC.

20INSRTA        TS              DVSELECT                        # STORE PGNSCADR IN DVSELECT

                EXTEND
                DCA             TIME2                           # STORE CURRENT TIME IN /TEMP3/
                DXCH            /TEMP3/
                TCF             20INSRT         +1

# FROM ENGINOFF - PREPARE FOR TRANSFER TO THE ENGINOFF DELAY LOGIC.

20INSRTB        EXTEND                                          # SAVE Q FOR AN INDEFINITE TIME - IT
                QXCH            /TEMP1/                         # POINTS TO SWRETURN OR ISWRETRN.
                CAF             EBANK6
                XCH             EBANK                           # GO TO EBANK 6 AND STORE CALLERS EBANK.
                TS              /TEMP2/

                CA              TMINAPS                         # IF TMINAPS IS NEGATIVE OR ZERO DO NOT
                EXTEND                                          # DELAY THE ENGINOFF CALL.
                BZMF            20INSRTC

                TC              POSTJUMP                        # *TMINAPS OK. JUMP TO THE DELAY LOGIC*
                CADR            17INSRT

20INSRTC        CA              /TEMP2/                         # RESTORE EBANK AND RETURN TO ENGINOFF.
                TS              EBANK
                TCF             ENGINOFF        +1

# FOLLOWING CODING LEFT IN PLACE TO PRESERVE RELATIVE ADDRESSES.

                TS              DELCDUX                         # IF 0, DONE DELCDUY AND ZERO DELCDUX.



 +5             TC              TORQUEVK
                TCF             RESUME
                TC              CCSHOLE

# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

## Page 587
# THIS SUBROUTINE COMPUTES JET TORQUE CONTRIBUTION TO RATE


TORQUEVK        CS              TQR                             # TQR IS SCALED THE SAME AS TIME 6
                AD              CSPINKF
                EXTEND
                BZMF            FULLCSP
                CA              TQR
                EXTEND
                MP              BIT5
                CAE             L
                EXTEND
                MP              16/25KF
                TS              TQR
                EXTEND
                QXCH            ITEMP6
                TC              JETTSUB
                CAF             ZERO
                TS              TQR
                TC              ITEMP6                          # RETURN TO TORQUEVK CALLER
FULLCSP         COM                                             # WE COME HERE WHEN TQR GREATER THAN .1SEC
                TS              ITEMP2
                CA              CSPAT1                          # CSP (.1 SEC) SCALED AT 1.
                TS              TQR                             # TEMPORARY, LATER TQR:.1=TQR
                EXTEND
                QXCH            ITEMP6
                TC              JETTSUB
                CAE             ITEMP2
                TS              TQR
                TC              ITEMP6                          # RETURN TO TORQUEVK CALLER.

# A SUBROUTINE WHICH,GIVEN TQR SCALED AT 1, FINDS JETRATE AND SUMRATE.

JETTSUB         EXTEND
                MP              NO.QJETS
                CAE             L
                EXTEND
                MP              1JACCQ
                TS              JETRATEQ                        # TEMP STORE OF ACC*NJETS*TQR FOR Q AXIS.
                ADS             SUMRATEQ                        # SUMRATE =SUMRATE+ACC*NJETS*TQR, WHICH IS
                CAE             TQR                             #   THE ACCUMULATED JET FIRING ACC. OVER
                EXTEND                                          #   A TWO SECOND INTERVAL.
                MP              NO.RJETS                        # SAME AS ABOVE FOR R AXIS THIS TIME.
                CAE             L
                EXTEND
                MP              1JACCR
                TS              JETRATER
                ADS             SUMRATER

## Page 588
                CCS             AOSCOUNT                        # TEST TO SEE IF AOSTASK IS COMING UP:
                TCF             WATERATE                        # NO, SKIP.

                CS              JETRATEQ                        # REMOVE THE MOST RECENT JETRATES FROM THE
                TS              SAVRATEQ                        # SUMRATES AND SET UP INITIALIZATION OF
                ADS             SUMRATEQ                        # THE SUMRATES FOR THE NEXT 2 SECOND
                CS              JETRATER                        # INTERVAL.  (SAVED AS NEGATIVES.)
                TS              SAVRATER
                ADS             SUMRATER

WATERATE        CAE             WFORQR                          # WFORQR IS SCALED AT 16 BUT THE ALGORITHM
                EXTEND                                          #   USES W/2 THUS THE SCALING IS 8 HERE.
                MP              TQR
                AD              (1-K)/8                         # THE ALGORITHM IMPLEMENTED IS....
                EXTEND                                          #   JETRATE = TQR*NJET*ACC*(1-K+N*TQR/2)
                MP              BIT4                            #   FOR THE Q AND R AXES RESPECTIVELY.
                LXCH            ITEMP1                          # THE FINAL SCALING OF JETRATE  IS PI/4.
                CAE             JETRATEQ
                EXTEND
                MP              ITEMP1
                TS              JETRATEQ
                CAE             JETRATER
                EXTEND
                MP              ITEMP1
                TS              JETRATER
                TC              Q
100MSCAL        DEC             0.025
16/25KF         DEC             0.64000
CSPAT1          DEC             0.10000
-DELAYT         DEC             -19                             # -11.875 MS SCALED AS TIME6.
CSPINKF         DEC             0.00977

## Page 589
# THIS T5RUPT TAKES THE SQUARE ROOT AND CALLS TORQUEVK
DORUTDUM        CAF             MS30120                         # FILDUMMY ENTRY EVERY TIME WE DO SQ. ROOT
                TS              TIME5
                LXCH            BANKRUPT
                EXTEND
                QXCH            QRUPT

                EXTEND
                DCA             PAXBNK20
                DXCH            T5ADR

                EXTEND
                DCS             TERMB
                TC              IBNKCALL
                CADR            DAPSQRT
                AD              TERMA
                DOUBLE                                          # RESCALE TO T6 SCALING
                EXTEND
                MP              25/32KF
                TS              TQR
                AD              -DELAYT                         # TQR SHOULD HOLD THE COMPLETE ON-TIME.
                TS              TOFJTCHG
                TC              TORQUEVK

                CAE             CH5TEMP
                MASK            JTSONNOW
                TC              POSTJUMP
                CADR            FROMROOT

25/32KF         DEC             0.78125

## Page 590
# SUBROUTINE: DISPDRIV            MOD. NO. 0  DATE: NOVEMBER 14, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS SUBROUTINE SETS THE ICDU DRIVE BITS EVERY OTHER TIME IT IS CALLED.  IT ALWAYS CHANGES THE VALUE OF
# "DISPLACT" TO INDICATE THE PASSING OF 100 MS, SINCE THIS FLAG IS TESTED BY "EIGHTBAL" IN THE P-AXIS T5RUPT.
# THE ICDU IS DRIVEN ONLY 30 MS AFTER "EIGHTBAL" ENABLED IT.

# CALLING SEQUENCES (FROM "DUMMYFIL" AND "FILTER"):

#                                         L        TC     DISPDRIV        (MUST BE FROM SAME BANK)
#                                         L +1    (RETURN)

# SUBROUTINES CALLED: NONE.       NORMAL EXIT: BY TC Q  TO L +1 .

# ALARM/ABORT MODES: NONE.        INPUT: PRESENT VALUE IN  DISPLACT ,

# OUTPUT: OPPOSITE VALUE OF "DISPLACT" AND ICDU BITS (WHEN NECESSARY).

# DEBRIS: A,Q.



                EBANK=          DT
                BANK            21
DISPDRIV        CCS             DISPLACT                        # TEST PHASE OF  EIGHTBAL .
                TCF             +5                              # (NO DRIVING ON THIS PASS.) RESET FLAG.

                CAF             OCT70000                        # SET ICDU DRIVE BITS.
                EXTEND
                WOR             14

                CAF             ONE                             # RESET FLAG.
                TS              DISPLACT

                TC              Q                               # RETURN

OCT70000        OCTAL           70000                           # ICDU DRIVE BITS OF CHANNEL 14.
