### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LOGSUB_ROUTINE.agc
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
## Reference:   p.  864
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-13 HG   Transcribed
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 864
# INPUT....X IN MPAC
# OUTPUT...-LOG(X)/32 IN MPAC


                BANK            32
LOGSUB          NORM            BDSU
                                BUF
                                ALMOST1
                EXIT
                TC              POLY
                DEC             6
                2DEC            .0000000060


                2DEC            -.0312514377

                2DEC            -.0155686771

                2DEC            -.0112502068

                2DEC            -.0018545108

                2DEC            -.0286607906

                2DEC            .0385598563


                2DEC            -.0419361902

                CAF             ZERO
                TS              MPAC            +2
                EXTEND
                DCA             CLOG2/32
                DXCH            MPAC
                DXCH            BUF             +1
                CA              BUF
                TC              SHORTMP

                DXCH            MPAC            +1
                DXCH            MPAC
                DXCH            BUF             +1
                DAS             MPAC
                TC              INTPRET
                DCOMP           RVQ
CLOG2/32        2DEC            .0216608494

ALMOST1         2DEC            .999999999
