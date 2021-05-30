### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ALARM_AND_ABORT.agc
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
## Reference:   pp. 300-302
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-01 TVB  Transcribed
##              2017-06-13 HG   Fix operator TCF -> TC
##                              Remove tabs
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.
##              2021-05-30 ABS  Fixed a page marker comment.

## Page 300

                BLOCK   02
BZFHOLE         EQUALS  CCSHOLE

CCSHOLE         INHINT
                CA      Q
                TS      ALMCADR

                TC      ABORT2
                OCT     1103

CURTAINS        INHINT                  # SAVE 2CADR OF USER FOR CURTAINS DISPLAY
                CA      Q               # ***MAY CHANGE FOR NEW ALARM ROUTINE*****
                TS      ALMCADR

                TC      ALARM2
                OCT     00310

JETENTRY        INHINT
                CAF     CURTBB
                XCH     BBANK
                TCF     FORGETIT

                EBANK=  LST1
CURTBB          BBCON   FORGETIT
                BANK    07

LARMLARM        TC      GRABDSP
                TC      ENDOFJOB

DOALARM         TC      GRABWAIT        # DISPLAY FAILREG.
                CAF     FAILDISP
                TC      NVSBWAIT

                TC      EJFREE          # FREE DISPLAY AND END JOB.

FAILDISP        OCT     00550

JETABORT        TC      ALARM
                OCT     00312

                TCF     JETENTRY

# ALARM IS CALLED EITHER IN INTERRUPT OR UNDER EXECUTIVE CONTROL

# CALLING SEQUENCE,

#               TC      ALARM
#               OCT     AAANN           ALARM NO. NN IN GENERAL AREA AAA.

#                                       (RETURNS HERE)

## Page 301

# *** FAILREG AND VN DECISIONS STILL TO BE MADE***
                BLOCK   02
ALARM           INHINT

                CA      Q
                TS      ALMCADR

ALARM2          INDEX   Q

                CA      0
BORTENT         TS      L               # STORE RETURN -1 IN L

                CA      BBANK
                TS      ALMCADR +1

                CA      Q
                TS      RUPTREG4

CHKFAIL1        CCS     FAILREG         # IS ANYTHING IN FAILREG
                TCF     CHKFAIL2        # YES TRY NEXT REG
                LXCH    FAILREG
                TCF     PROGLARM        # TURN ALARM LIGHT ON FOR FIRST ALARM

CHKFAIL2        CCS     FAILREG +1
                TCF     FAIL3
                LXCH    FAILREG +1
                TCF     MULTEXIT

FAIL3           CA      FAILREG +2
                MASK    POSMAX
                CCS     A
                TCF     MULTFAIL

                LXCH    FAILREG +2
                TCF     MULTEXIT

PROGLARM        CS      DSPTAB  +11D
                MASK    OCT40400
                ADS     DSPTAB  +11D

MULTEXIT        CAF     PRIO37
                TC      NOVAC
                EBANK=  FAILREG
                2CADR   LARMLARM

                XCH     RUPTREG4
                RELINT
                INDEX   A
                TC      1

MULTFAIL        CA      L
                AD      BIT15
## Page 302
                XCH     FAILREG +2
                MASK    POSMAX
                TS      FAILREG +1

                TCF     MULTEXIT

                BLOCK   03
ABORT           INHINT
                CA      Q
                TS      ALMCADR

ABORT2          INDEX   Q
                CAF     0
                TC      BORTENT

OCT40400        OCT     40400
WHIMPER         TCF     WHIMPER
