### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SINGLE_PRECISION_SUBROUTINES.agc
## Purpose:     A section of Luminary revision 116.
##              It is part of the source code for the Lunar Module's (LM) 
##              Apollo Guidance Computer (AGC) for Apollo 12.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   p.  1094
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-01-22 MAS  Created from Luminary 99.
##              2017-01-27 RRB  Updated for Luminary 116.
##		2017-03-14 RSB	Proofed comment text via 3-way diff vs
##				Luminary 99 and 131 ... no problems found.

## Page 1094
                BLOCK           02                              

# SINGLE PRECISION SINE AND COSINE

                COUNT*          $$/INTER                        
SPCOS           AD              HALF                            # ARGUMENTS SCALED AT PI
SPSIN           TS              TEMK                            
                TCF             SPT                             
                CS              TEMK                            
SPT             DOUBLE                                          
                TS              TEMK                            
                TCF             POLLEY                          
                XCH             TEMK                            
                INDEX           TEMK                            
                AD              LIMITS                          
                COM                                             
                AD              TEMK                            
                TS              TEMK                            
                TCF             POLLEY                          
                TCF             ARG90                           
POLLEY          EXTEND                                          
                MP              TEMK                            
                TS              SQ                              
                EXTEND                                          
                MP              C5/2                            
                AD              C3/2                            
                EXTEND                                          
                MP              SQ                              
                AD              C1/2                            
                EXTEND                                          
                MP              TEMK                            
                DDOUBL                                          
                TS              TEMK                            
                TC              Q                               
ARG90           INDEX           A                               
                CS              LIMITS                          
                TC              Q                               # RESULT SCALED AT 1


