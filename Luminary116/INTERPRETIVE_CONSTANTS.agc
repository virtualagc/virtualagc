### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERPRETIVE_CONSTANTS.agc
## Purpose:     A section of Luminary revision 116.
##              It is part of the source code for the Lunar Module's (LM) 
##              Apollo Guidance Computer (AGC) for Apollo 12.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 1092-1093
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-01-22 MAS  Created from Luminary 99.
##              2017-01-30 RRB  Updated for Luminary 116.
##		2017-03-13 RSB	Proofed comment text via 3-way diff vs
##				Luminary 99 and 131 ... no problems found.
##              2021-05-30 ABS  DFC-6 -> DEC-6, DFC-12 -> DEC-12

## Page 1092
                SETLOC          INTPRET1                        
                BANK                                            

                COUNT*          $$/ICONS                        
DP1/4TH         2DEC            .25                             

UNITZ           2DEC            0                               

UNITY           2DEC            0                               

UNITX           2DEC            .5                              

ZEROVECS        2DEC            0                               

                2DEC            0                               

                2DEC            0                               

DPHALF          =               UNITX                           
DPPOSMAX        OCT             37777                           
                OCT             37777                           

## Page 1093
# INTERPRETIVE CONSTANTS IN THE OTHER HALF-MEMORY

                SETLOC          INTPRET2                        
                BANK                                            

                COUNT*          $$/ICONS                        
ZUNIT           2DEC            0                               

YUNIT           2DEC            0                               

XUNIT           2DEC            .5                              

ZEROVEC         2DEC            0                               

                2DEC            0                               

                2DEC            0                               

                OCT             77777                           # -0,-6,-12 MUST REMAIN IN THIS ORDER
DEC-6           DEC             -6                              
DEC-12          DEC             -12                             
LODPMAX         2OCT            3777737777                      # THESE TWO CONSTANTS MUST REMAIN

LODPMAX1        2OCT            3777737777                      # ADJACENT AND THE SAME FOR INTEGRATION

ZERODP          =               ZEROVEC                         
HALFDP          =               XUNIT                           


