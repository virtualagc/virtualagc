### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ALARM_AND_ABORT.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 1378-1382
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-29 TB   Transcribed
##              2016-12-07 HG   Fix P00 -> POO
##              2016-12-11 HG   add missing operation MASK FLGWRD10
##              2016-12-12 HG   add [WORKAROUND] using SBANK=
##		2016-12-26 RSB	Comment-text proofed using ProoferComments
##				and corrected errors found.
##		2017-06-17 MAS	Globally removed all SBANK= workarounds.

## Page 1378
# THE FOLLOWING SUBROUTINE MAY BE CALLED TO DISPLAY A NON-ABORTIVE ALARM CONDITION.  IT MAY BE CALLED
# EITHER IN INTERRUPT OR UNDER EXECUTIVE CONTROL.

# CALLING SEQUENCE IS AS FOLLOWS:
#               TC      ALARM
#               OCT     AAANN           ALARM NO. NN IN GENERAL AREA AAA.
#                                       (RETURNS HERE)

                BLOCK           02                              
                SETLOC          FFTAG7                          
                BANK                                            

                EBANK=          FAILREG                         

                COUNT*          $$/ALARM                        
# ALARM TURNS ON THE PROGRAM ALARM LIGHT, BUT DOES NOT DISPLAY.

ALARM           INHINT                                          

                CA              Q                               
ALARM2          TS              ALMCADR                         
                INDEX           Q                               
                CA              0                               
BORTENT         TS              L                               

PRIOENT         CA              BBANK                           
 +1             EXTEND                                          
                ROR             SUPERBNK                        # ADD SUPER BITS.
                TS              ALMCADR         +1              

LARMENT         CA              Q                               # STORE RETURN FOR ALARM
                TS              ITEMP1                          

CHKFAIL1        CCS             FAILREG                         # IS ANYTHING IN FAILREG
                TCF             CHKFAIL2                        # YES TRY NEXT REG
                CA              L                               
                TS              FAILREG                         
                TCF             PROGLARM                        # TURN ALARM LIGHT ON FOR FIRST ALARM

CHKFAIL2        CCS             FAILREG         +1              
                TCF             PROGLARM                        
                CA              L                               
                TS              FAILREG         +1              

PROGLARM        LXCH            FAILREG         +2              # STORE AS "MOST RECENT" ALARM CODE

                CS              DSPTAB          +11D            # TURN ON PROGRAM ALARM IF OFF
                MASK            OCT40400                        
                ADS             DSPTAB          +11D            

## Page 1379
MULTEXIT        XCH             ITEMP1                          # OBTAIN RETURN ADDRESS IN A
                RELINT                                          
                INDEX           A                               
                TC              1                               

# PRIOLARM DISPLAYS V05N09 VIA PRIODSPR WITH 3 RETURNS TO THE USER FROM THE ASTRONAUT AT CALL LOC +1,+2,+3 AND
# AN IMMEDIATE RETURN TO THE USER AT CALL LOC +4.  EXAMPLE FOLLOWS,
#               CAF     OCTXX           ALARM CODE
#               TC      BANKCALL
#               CADR    PRIOLARM
#               ...     ...
#               ...     ...
#               ...     ...             ASTRONAUT RETURN
#               TC      PHASCHNG        IMMEDIATE RETURN TO USER. RESTART
#               OCT     X.1             PHASE CHANGE FOR PRIO DISPLAY

                BANK            10                              
                SETLOC          DISPLAYS                        
                BANK                                            

                COUNT*          $$/DSPLA                        
PRIOLARM        INHINT                                          # * * * KEEP IN DISPLAY ROUTINES BANK
                TS              L                               # SAVE ALARM CODE

                CA              BUF2                            # 2 CADR OF PRIOLARM USER
                TS              ALMCADR                         
                CA              BUF2            +1              
                TC              PRIOENT         +1              # * LEAVE L ALONE
-2SEC           DEC             -200                            # *** DONT MOVE
                CAF             V05N09                          
                TCF             PRIODSPR                        

                BLOCK           02                              
                SETLOC          FFTAG7                          
                BANK                                            

                COUNT*          $$/ALARM                        
BAILOUT         INHINT                                          
                CA              Q                               
                TS              ALMCADR                         

                INDEX           Q                               
                CAF             0                               
                TC              BORTENT                         
OCT40400        OCT             40400                           

                INHINT                                          
WHIMPER         CA              TWO                             
                AD              Z                               
## Page 1380
                TS              BRUPT                           
                RESUME                                          
                TC              POSTJUMP                        # RESUME SENDS CONTROL HERE
                CADR            ENEMA                           
POODOO          INHINT                                          
                CA              Q                               
ABORT2          TS              ALMCADR                         
                INDEX           Q                               
                CAF             0                               
                TC              BORTENT                         
OCT77770        OCT             77770                           # DON'T MOVE

                CCS             EXTVBACT                        # DO BAILOUT NOT POODOO IF EXT. VB. ACTIVE
                TCF             WHIMPER         -1

                CAF             OCT35                           # 4.35SPOT FOR GOPOODOO
                TS              L                               
                COM                                             
                DXCH            -PHASE4                         
GOPOODOO        INHINT                                          
                TC              BANKCALL                        # RESET STATEFLG, REINTFLG, AND NODOFLAG.
                                                                #   ALSO RNDVZFLG, P25FLAG AND TRACKFLG
                CADR            FLAGS                           
                CA              FLAGWRD7                        # IS SERVICER CURRENTLY IN OPERATION?
                MASK            V37FLBIT                        
                CCS             A                               
                TCF             STRTIDLE                        
                TC              BANKCALL                        # TERMINATE GRPS 1, 3, 5, AND 6
                CADR            V37KLEAN                        
                TC              BANKCALL                        # TERMINATE GRPS 2, 4, 1, 3, 5, AND 6
                CADR            MR.KLEAN                        #       (I.E., GRP 4 LAST)
                TCF             WHIMPER                         
STRTIDLE        CAF             BBSERVDL                        
                TC              SUPERSW                         
                TC              BANKCALL                        # PUT SERVICER INTO ITS "GROUND" STATE
                CADR            SERVIDLE                        # AND PROCEED TO GOTOPOOH.
CCSHOLE         INHINT                                          
                CA              Q                               
                TC              ABORT2                          
OCT21103        OCT             21103                           
CURTAINS        INHINT                                          
                CA              Q                               
                TC              ALARM2                          
OCT217          OCT             00217                           
                TC              ALMCADR                         # RETURN TO USER

BAILOUT1        INHINT                                          
                DXCH            ALMCADR                         
                CAF             ADR40400                        
BOTHABRT        TS              ITEMP1                          

## Page 1381
                INDEX           Q                               
                CAF             0                               
                TS              L                               
                TCF             CHKFAIL1                        

POODOO1         INHINT                                          
                DXCH            ALMCADR                         
                CAF             ADR77770                        
                TCF             BOTHABRT                        

ALARM1          INHINT                                          
                DXCH            ALMCADR                         
ALMNCADR        INHINT                                          
                INDEX           Q                               
                CA              0                               
                TS              L                               
                TCF             LARMENT                         

ADR77770        TCF             OCT77770                        
ADR40400        TCF             OCT40400
DOALARM         EQUALS          ENDOFJOB                        
                EBANK=          DVCNTR                          
BBSERVDL        BBCON           SERVIDLE                        

# CALLING SEQUENCE FOR VARALARM
#               CAF     (ALARM)
#               TC      VARALARM

# VARALARM TURNS ON PROGRAM ALARM LIGHT BUT DOES NOT DISPLAY

VARALARM        INHINT                                          

                TS              L                               # SAVE USERS ALARM CODE

                CA              Q                               # SAVE USERS Q
                TS              ALMCADR                         

                TC              PRIOENT                         
OCT14           OCT             14                              # DONT MOVE

                TC              ALMCADR                         # RETURN TO USER

ABORT           EQUALS          WHIMPER                                                     
                SETLOC          ABTFLGS                         
                BANK                                            
                COUNT*          $$/ALARM                        

FLAGS           CS              STATEBIT                        
                MASK            FLAGWRD3                        
                TS              FLAGWRD3                        
                CS              REINTBIT 
                MASK            FLGWRD10

## Page 1382
                TS              FLGWRD10                        
                CS              NODOBIT                         
                MASK            FLAGWRD2                        
                TS              FLAGWRD2                        
                CS              BITS9+7
FLAGREF1        EQUALS          RNDVZFLG
FLAGREF2        EQUALS          P25FLAG
                MASK            FLAGWRD0
                TS              FLAGWRD0
                CS              TRACKFLG
                MASK            FLAGWRD1
                TS              FLAGWRD1
                TC              Q                               


