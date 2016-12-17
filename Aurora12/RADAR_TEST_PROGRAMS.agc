### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     RADAR_TEST_PROGRAMS.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        256-257
## Mod history:  2016-09-20 JL   Created.
##               2016-10-18 MAS  Adapted from Sunburst 120.
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 but no errors found.

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

## Page 256
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
## Page 257
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
