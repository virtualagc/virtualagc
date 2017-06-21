### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INPUT_OUTPUT_CHANNELS.agc
## Purpose:     A section of Sunburst revision 37, or Shepatin revision 0.
##              It is part of an early development version of the software
##              for Apollo Guidance Computer (AGC) on the unmanned Lunar
##              Module (LM) flight Apollo 5. Sunburst 37 was the program
##              upon which Don Eyles's offline development program Shepatin
##              was based; the listing herein transcribed was actually for
##              the equivalent revision 0 of Shepatin.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   p.  53
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-27 HG   Transcribed
##		2017-06-21 RSB	Proofed using octopus/ProoferComments.


## Page 53
HISCALAR        EQUALS  	3
LOSCALAR        EQUALS  	4

SUPERBNK        EQUALS  	7               	# SUPER-BANK.
OUT0            EQUALS  	10
DSALMOUT        EQUALS  	11
CHAN12          EQUALS  	12
CHAN13          EQUALS  	13
CHAN14          EQUALS  	14
MNKEYIN         EQUALS  	15
NAVKEYIN        EQUALS  	16
CHAN33          EQUALS  	33
DNTM1           EQUALS  	34
DNTM2           EQUALS  	35
# END OF CHANNEL ASSIGNMENTS
