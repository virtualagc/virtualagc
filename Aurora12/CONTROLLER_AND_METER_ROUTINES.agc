### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     CONTROLLER_AND_METER_ROUTINES.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        368-369
## Mod history:  2016-09-20 JL   Created.
##               2016-10-16 HG   Fix label ENDCM5 -> ENDCMS
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

## Page 368

                SETLOC          ENDEXTVS                        
                EBANK=          PCOM                            

RHCNTRL         CAF             BIT15                           
                EXTEND                                          
                RAND            31                              # CHECK PGNCS CONTROL OF S/C
                EXTEND                                          
                BZF             +2                              
                TCF             NORATE                          
                CAF             BIT3                            
                EXTEND                                          
                RAND            31                              # CHECK OUT-OF-DETENT BIT
                CCS             A                               
                TCF             NORATE                          

                CAF             ZERO                            # ZERO COUNTERS
                TS              RHCP                            
                TS              RHCY                            
                TS              RHCR                            
                CAF             BIT8                            # ENABLE COUNTERS
                AD              BIT9                            # START READING INTO COUNTERS
                EXTEND                                          
                WOR             13                              
                CAF             BIT5                            
                TC              WAITLIST                        # COUNTERS FILLED
                2CADR           ATTCONT                         

                TC              TASKOVER                        

ATTCONT         CS              BIT8                            
                EXTEND                                          
                WAND            13                              # RESET COUNTER ENABLE
                CAF             BIT11                           
                EXTEND                                          
                RAND            32                              # CHECK IF IN ATTITUDE HOLD MODE
                EXTEND                                          
                BZF             +2                              
                TC              XAXOVRD                         
                CA              RHCP                            
                EXTEND                                          
                MP              BIT10                           
                CAF             RHCSCALE                        
                EXTEND                                          
                MP              L                               
                TS              PCOM                            
                CA              RHCR                            
                EXTEND                                          
                MP              BIT10                           
                CAF             RHCSCALE                        
                EXTEND                                          

## Page 369

                MP              L                               
                TS              RCOM                            
XAXOVRD         CA              RHCY                            # YAW CHANNEL ONLY IN AUTO MODE
                EXTEND                                          
                MP              BIT10                           
                CAF             RHCSCALE                        
                EXTEND                                          
                MP              L                               
                TS              YCOM                            
                TCF             RHCNTRL                         

NORATE          CAF             ZERO                            # SET RATE COMMANDS TO ZERO
                TS              PCOM                            
                TS              RCOM                            
                TS              YCOM                            
                TC              TASKOVER                        

RHCSCALE        DEC             .44488                          # LEAVES INPUTS SCALED AS PI/4 RAD/SEC.
ENDCMS          EQUALS                                          
