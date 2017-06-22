### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ASCENT_INERTIA_UPDATER.agc
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
## Reference:   pp. 538-540
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-05 HG   Transcribed
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 538
                BANK            26
                EBANK=          DT
IXXTASK         TC              JACCESTP

                TC              ASCENGON

                EXTEND
                DIM             IXX
                CAF             IXXTIME
                TC              WAITLIST
                EBANK=          DT
                2CADR           IXXTASK

                TCF             TASKOVER

IYYTASK         TC              JACCESTQ

                TC              ASCENGON

                EXTEND
                DIM             IYY
                CAF             IYYTIME
                TC              WAITLIST
                EBANK=          DT
                2CADR           IYYTASK

                TCF             TASKOVER

IZZTASK         TC              JACCESTR

                TC              ASCENGON

                EXTEND
                DIM             IZZ
                CAF             IZZTIME
                TC              WAITLIST
                EBANK=          DT
                2CADR           IZZTASK


                TCF             TASKOVER

IXXTIME         DEC             200
IYYTIME         DEC             1300
IZZTIME         DEC             180

ASCENGON        CAF             BIT8
                MASK            DAPBOOLS
                CCS             A
                TC              Q
                TCF             TASKOVER

## Page 539
JACCESTP        CAE             IXX
                ZL
                EXTEND
                DV              4JETTORK
                DOUBLE
                TS              1/2JTSP

                CAF             JETTORK
                ZL
                EXTEND
                DV              IXX
                TS              1JACC

                TC              Q

JACCESTQ        CAE             IYY
                ZL
                EXTEND
                DV              JETTORK4
                EXTEND                                  # INCLUDE INVISIBLE FACTOR OF (1/2).

                MP              BIT14
                TS              1/NET+4Q
                TS              1/NET-4Q


                DOUBLE
                TS              1/NET+2Q
                TS              1/NET-2Q

                CAF             JETTORK1
                ZL
                EXTEND
                DV              IYY
                TS              1JACCQ

                TC              Q
JACCESTR        CAE             IZZ
                ZL
                EXTEND
                DV              JETTORK4
                EXTEND                                  # INCLUDE INVISIBLE FACTOR OF (1/2).
                MP              BIT14
                TS              1/NET+4R
                TS              1/NET-4R

                DOUBLE
                TS              1/NET+2R
                TS              1/NET-2R

                CAF             JETTORK1
                ZL

## Page 540
                EXTEND
                DV              IZZ

                TS              1JACCR

COMMONQR        CAE             1/2JTSQ
                AD              1/2JTSR
                EXTEND
                MP              .707BK26
                TS              1/2JETSU                        # TEMP

                CAE             1/2JTSQ
                EXTEND
                MP              1/2JTSR
                EXTEND
                DV              1/2JETSU                        # TEMP
                TS              1/NET+2U
                TS              1/NET-2U
                TS              1/NET+2V
                TS              1/NET-2V

                DOUBLE
                TS              1/NET+1U
                TS              1/NET-1U
                TS              1/NET+1V
                TS              1/NET-1V

                TC              Q

.707BK26        DEC             0.70711
JETTORK         DEC             0.00243                         # 500 FT LBS. SCALED AT PI*2(+16)
JETTORK1        DEC             0.00267                         # 550 FT LBS. SCALED AT PI*2(+16)
0.35356         DEC             0.35356
