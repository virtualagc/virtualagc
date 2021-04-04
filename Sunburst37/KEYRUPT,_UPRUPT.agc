### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    KEYRUPT,_UPRUPT.agc
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
## Reference:   pp. 215-218
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-29 HG   Transcribed
##		2017-06-21 RSB	Proofed using octopus/ProoferComments.
##              2021-05-30 ABS  UPCK -> UPOK

## Page 215
                BANK            13
KEYRUPT1        TS              BANKRUPT
                XCH             Q
                TS              QRUPT
                TC              LODSAMPT                # TIME IS SNATCHED IN RUPT FOR NOUN 65.
                CAF             LOW5
                EXTEND
                RAND            MNKEYIN
KEYCOM          TS              RUPTREG4
                CAF             CHRPRIO
                TC              NOVAC
                EBANK=          DSPCOUNT
                2CADR           CHARIN
                CA              RUPTREG4
                INDEX           LOCCTR
                TS              MPAC                    # LEAVE 5 BIT KEY CDE IN MPAC FOR CHARIN
                TC              RESUME

## Page 216
# UPRUPT PROGRAM

UPRUPT          TS              BANKRUPT
                XCH             Q
                TS              QRUPT
                TC              LODSAMPT                # TIME IS SNATCHED IN RUPT FOR NOUN 65.
                CAF             ZERO
                XCH             INLINK
                TS              KEYTEMP1
                CAF             BIT3                    # TURN ON UPACT LIGHT
                EXTEND                                  # (BIT 3 OF CHANNEL 11)
                WOR             DSALMOUT
UPRPT1          CAF             LOW5                    # TEST FOR TRIPLE CHAR REDUNDANCY
                MASK            KEYTEMP1                # LOW5 OF WORD
                XCH             KEYTEMP1                # LOW5 INTO KEYTEMP1
                XCH             SR                      # WHOLE WORD INTO SR
                TS              KEYTEMP2                # ORIGINAL SR INTO KEYTEMP2
                TC              SRGHT5
                MASK            LOW5                    # MID 5
                AD              HI10
                TC              UPTEST
                TC              SRGHT5
                MASK            LOW5                    # HIGH 5
                COM
                TC              UPTEST
UPOK            TC              RESTORSR                # CODE IS GOOD

                CS              ELRCODE                 # IF CODE = ERROR LIGHT RESET, PUT +0
                AD              KEYTEMP1                # INTO BIT1 OF UPLOCK.
                CCS             A                       # IF CODE NOT= ELR, PASS CODE ONLY IF
                TC              TSTUPLOK                # BIT1 OF UPLOCK = 0.
ELRCODE         OCT             22
                TC              TSTUPLOK
                CS              BIT3
                MASK            FLAGWRD1
                TS              FLAGWRD1
                TC              ACCEPTUP
TSTUPLOK        CAF             BIT3
                MASK            FLAGWRD1
                CCS             A
                TC              RESUME                  # BIT1 OF UPLOCK = 1.
ACCEPTUP        XCH             KEYTEMP1                # BIT1 OF UPLOCK = 0.
                TC              KEYCOM

TMFAIL2         TC              RESTORSR                # CODE IS BAD
                CS              BIT3
                MASK            FLAGWRD1
                AD              BIT3
                TS              FLAGWRD1
TMFAIL1         TC              TMALM

                TC              RESUME

## Page 217
RESTORSR        XCH             KEYTEMP2
                DOUBLE
                TS              SR
                TC              Q

TMALM           =               RESUME                  # FOR NOW

SRGHT5          CS              SR

                CS              SR
                CS              SR
                CS              SR
                CS              SR
                CS              A
                TC              Q                       # DELIVERS WORD UNCOMPLEMENTED

UPTEST          AD              KEYTEMP1
                CCS             A
                TC              TMFAIL2
HI10            OCT             77740
                TC              TMFAIL2
                TC              Q

# UPACT IS TURNED OFF BY VBRELDSP, ALSO BY ERROR LIGHT RESET.

## Page 218
# THE RECEPTION OF A BAD CODE BY UPLINK LOCKS OUT FURTHER UPLINK ACTIVITY
# BY PLACING A 1 INTO BIT1 OF UPLOCK. BIT9 (ALONG WITH BIT11) OF TMKEYBUF
# IS SET TO 1 TO SEND AN INDICATION OF THIS SITUATION DOWN THE DOWNLINK.
# THE UPLINK INTERLOCK IS ALLOWED WHEN AN ERROR LIGHT RESET CODE IS SENT
# UP THE UPLINK, OR WHEN A FRESH START IS PERFORMED.
