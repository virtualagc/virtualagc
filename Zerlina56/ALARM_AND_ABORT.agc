### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ALARM_AND_ABORT.agc
## Purpose:     A log section of Zerlina 56, the final revision of
##              Don Eyles's offline development program for the variable 
##              guidance period servicer. It also includes a new P66 with LPD 
##              (Landing Point Designator) capability, based on an idea of John 
##              Young's. Neither of these advanced features were actually flown,
##              but Zerlina was also the birthplace of other big improvements to
##              Luminary including the terrain model and new (Luminary 1E)
##              analog display programs. Zerlina was branched off of Luminary 145,
##              and revision 56 includes all changes up to and including Luminary
##              183. It is therefore quite close to the Apollo 14 program,
##              Luminary 178, where not modified with new features.
## Reference:   pp. 1369-1373
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-07-28 MAS  Created from Luminary 210.
##              2017-08-23 MAS  Updated for Zerlina 56.
##              2017-08-24 MAS  Removed an extra CS BITS9+7 instruction.

## Page 1369
#          THE FOLLOWING SUBROUTINE MAY BE CALLED TO DISPLAY A NON-ABORTIVE ALARM CONDITION. IT MAY BE CALLED
# EITHER IN INTERRUPT OR UNDER EXECUTIVE CONTROL.

#          CALLING SEQUENCE IS AS FOLLOWS:

#          TC     ALARM
#          OCT    AAANN           ALARM NO. NN IN GENERAL AREA AAA.
#                                 (RETURNS HERE)

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

## Page 1370
MULTEXIT        XCH             ITEMP1                          # OBTAIN RETURN ADDRESS IN A
                RELINT                                          
                INDEX           A                               
                TC              1                               

# PRIOLARM DISPLAYS V05N09 VIA PRIODSPR WITH 3 RETURNS TO THE USER FROM THE ASTRONAUT AT CALL LOC +1,+2,+3 AND
# AN IMMEDIATE RETURN TO THE USER AT CALL LOC +4. EXAMPLE FOLLOWS,
#                                                  CAF    OCTXX           ALARM CODE
#                                                  TC     BANKCALL
#                                                  CADR   PRIOLARM

#                                                  ...    ...
#                                                  ...    ...
#                                                  ...    ...             ASTRONAUT RETURN
#                                                  TC     PHASCHNG        IMMEDIATE RETURN TO USER. RESTART
#                                                  OCT    X.1             PHASE CHANGE FOR PRIO DISPLAY

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
## Page 1371
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

                CAF             OCT35                           # 4.35SPOT FOR GOPOODOO
                TS              L                               
                COM                                             
                DXCH            -PHASE4                         
GOPOODOO        INHINT                                          
                TC              BANKCALL                        # RESET STATEFLG, REINTFLG, AND NODOFLAG.
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
                INDEX           Q                               
                CAF             0                               
                TS              L                               
                TCF             CHKFAIL1                        

## Page 1372
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

#                                                  CAF    (ALARM)
#                                                  TC     VARALARM

# VARALARM TURNS ON PROGRAM ALARM LIGHT BUT DOES NOT DISPLAY
VARALARM        INHINT                                          

                TS              L                               # SAVE USERS ALARM CODE

                CA              Q                               # SAVE USERS Q
                TS              ALMCADR                         

                TC              PRIOENT                         
OCT14           OCT             14                              # DONT MOVE

                TC              ALMCADR                         # RETURN TO USER

ABORT           EQUALS          WHIMPER                                                     
                BANK            13
                SETLOC          ABTFLGS                         
                BANK                                            
                COUNT*          $$/ALARM                        

FLAGS           CS              STATEBIT                        
                MASK            FLAGWRD3                        
                TS              FLAGWRD3                        
                CS              REINTBIT 
                MASK            FLGWRD10
                TS              FLGWRD10                        
                CS              NODOBIT                         
                MASK            FLAGWRD2                        
## Page 1373
                TS              FLAGWRD2                        
                TC              Q                               
