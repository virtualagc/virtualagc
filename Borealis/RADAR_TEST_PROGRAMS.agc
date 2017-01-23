### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RADAR_TEST_PROGRAMS.agc
## Purpose:     This program is designed to extensively test the Apollo Guidance Computer
##              (specifically the LM instantiation of it). It is built on top of a heavily
##              stripped-down Aurora 12, with all code ostensibly added by the DAP Group
##              removed. Instead Borealis expands upon the tests provided by Aurora,
##              including corrected tests from Retread 44 and tests from Ron Burkey's
##              Validation.
## Assembler:   yaYUL
## Contact:     Mike Stewart <mastewar1@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-20 MAS  Created from Aurora 12 (with much DAP stuff removed).

                SETLOC          ENDRMODS
                EBANK=          RSTKLOC                         

# RADAR SAMPLING LOOP.

RADSAMP         CCS             RSAMPDT                         # TIMES NORMAL ONCE-PER-SECOND SAMPLING.
                TCF             +2                              

                TCF             TASKOVER                        # +0 INSERTED MANUALLY TERMINATES TEST.

                TC              WAITLIST                        
                2CADR           RADSAMP                         

                CAF             PRIO25                          
                TC              NOVAC                           
                2CADR           DORSAMP                         

                CAF             1/6                             # FOR CYCLIC SAMPLING, RTSTDEX =
                EXTEND                                          # RTSTLOC/6 + RTSTBASE.
                MP              RTSTLOC                         
                AD              RTSTBASE                        # 0 FOR RR, 2 FOR LR.
                TS              RTSTDEX                         

                TCF             TASKOVER                        

# DO THE ACTUAL RADAR SAMPLE.

DORSAMP         TC              VARADAR                         # SELECTS VARIABLE RADAR CHANNEL.
                TC              BANKCALL                        
                CADR            RADSTALL                        
                INCR            RFAILCNT                        # ADVANCE FAIL COUNTER BUT ACCEPT BAD DATA

DORSAMP2        INHINT                                          # YES - UPDATE TM BUFFER.
                DXCH            SAMPLSUM                        
                INDEX           RSTKLOC                         
                DXCH            RSTACK                          

                DXCH            OPTYHOLD                        
                INDEX           RSTKLOC                         
                DXCH            RSTACK          +2              

                DXCH            TIMEHOLD                        
                INDEX           RSTKLOC                         
                DXCH            RSTACK          +4              

                CS              RTSTLOC                         # CYCLE RTSTLOC.
                AD              RTSTMAX                         
                EXTEND                                          
                BZF             +3                              
                CA              RSTKLOC                         
                AD              SIX                             
                TS              RSTKLOC                         

                CCS             RSAMPDT                         # SEE IF TIME TO RE-SAMPLE.
                TCF             ENDOFJOB                        # NO - WAIT FOR T3 (REGULAR SAMPLING).

                TCF             ENDOFJOB                        # TEST TERMINATED.
                TCF             DORSAMP                         # JUMP RIGHT BACK AND GET ANOTHER SAMPLE.

1/6             DEC             .17                             

# VARIABLE RADAR DATA CALLER FOR ONE MEASUREMENT ONLY.

VARADAR         CAF             ONE                             # WILL BE SENT TO RADAR ROUTINE IN A BY
                TS              BUF2                            # SWCALL.
                INDEX           RTSTDEX                         
                CAF             RDRLOCS                         
                TCF             SWCALL                          # NOT TOUCHING Q.

RDRLOCS         CADR            RRRANGE                         # =0
                CADR            RRRDOT                          # =1
                CADR            LRVELX                          # =2
                CADR            LRVELY                          # =3
                CADR            LRVELZ                          # =4
                CADR            LRALT                           # =5

ENDRTSTS        EQUALS
