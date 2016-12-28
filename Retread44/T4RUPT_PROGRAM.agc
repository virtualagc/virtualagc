### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    T4RUPT_PROGRAM.agc
## Purpose:     Part of the source code for Retread 44 (revision 0). It was
##              the very first program for the Block II AGC, created as an
##              extensive rewrite of the Block I program Sunrise.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 128-130
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-13 MAS  Created from Aurora 12 version.
##              2016-12-18 MAS  Transcribed, then fixed typos.
## 		2016-12-27 RSB	Proofed comment text using octopus/ProoferComments,
##				but no errors found.

## Page 128
T4RUPT          TS              BANKRUPT
                XCH             Q
                TS              QRUPT
                CAF             ZERO
                EXTEND
                WRITE           OUT0
                CCS             DSRUPTSW
                TC              SPECRUPT                # ZERO OUT0 10 MS AFTER REGULAR T4RUPT.
                TC              T4RUPTA

SPECRUPT        CAF             ZERO
                TS              DSRUPTSW
                CAF             110MRUPT                # RE ESTABLISH 120 MS PERIOD
                TS              TIME4
                TC              RESUME
120MRUPT        OCT             37764
110MRUPT        OCT             37765



# RELTAB IS A PACKED TABLE. RELAYWORD CODE IN UPPER 4 BITS, RELAY CODE
# IN LOWER 5 BITS.

                SETLOC          ENDWAITF                # IN F/F

RELTAB          OCT             04025
                OCT             10003
                OCT             14031
                OCT             20033
                OCT             24017
                OCT             30036
                OCT             34034
                OCT             40023
                OCT             44035
                OCT             50037
                OCT             54000
RELTAB11        OCT             60000



ENDT4FF         EQUALS



                SETLOC          110MRUPT        +1      # IN BANK

T4RUPTA         CAF             120MRUPT
                TS              TIME4
CDRVE           CCS             DSPTAB          +11D
                TC              DSPOUT
## Page 129
                TC              DSPOUT
                XCH             DSPTAB          +11D
                MASK            LOW11
                TS              DSPTAB          +11D
                AD              RELTAB11
                TC              DSPLAYC

## Page 130
# DSPOUT PROGRAM. PUTS OUT DISPLAYS.

DSPOUT          CCS             NOUT                    # ENTERED IN INTERRUPTED STATE AT END OF
                TC              +2                      #                         DSRUPT
                TC              LVDSRUPT
                TS              NOUT
                CS              ZERO
                TS              DSRUPTEM                # SET TO -0 FOR 1ST PASS THRU DSPTAB
                XCH             DSPCNT
                AD              NEG0                    # TO PREVENT +0
                TS              DSPCNT
DSPSCAN         INDEX           DSPCNT
                CCS             DSPTAB
                CCS             DSPCNT                  # IF DSPTAB ENTRY +, SKIP
                TC              DSPSCAN         -2      # IF DSPCNT +, AGAIN
                TC              DSPLAY                  # IF DSPTAB ENTRY -, DISPLAY
TABLNTH         OCT             12                      # DEC 10   LENGTH OF DSPTAB
                CCS             DSRUPTEM                # IF DSRUPTEM=+0,2ND PASS THRU DSPTAB
                LOC             +1                      # (DSPCNT=0). +0 INTO NOUT, RESUME
                TS              NOUT
                TC              LVDSRUPT
                TS              DSRUPTEM                # IF DSRUPTEM=-0,1ST PASS THRU DSPTAB
                CAF             TABLNTH                 # (DSPCNT=0). +0 INTO DSRUPTEM. PASS AGAIN
                TC              DSPSCAN         -1

DSPLAY          AD              ONE
                INDEX           DSPCNT
                TS              DSPTAB                  # REPLACE POSITIVELY
                MASK            LOW11                   # REMOVE BITS 12 TO 15
                TS              DSRUPTEM
                CAF             HI5
                INDEX           DSPCNT
                MASK            RELTAB                  # PICK UP BITS 12 TO 15 OF RELTAB ENTRY
                AD              DSRUPTEM
DSPLAYC         EXTEND
                WRITE           OUT0
                TS              DISPBUF                 # THIS WILL BE SENT DOWN NEXT TM CYCLE.

                CAF             10MSRUPT                # SET T4 TO INTERRUPT IN 10 MS.
                TS              TIME4
                CAF             ONE
                TS              DSRUPTSW                # SET FOR SPECRUPT

                TC              LVDSRUPT

LVDSRUPT        EQUALS          RESUME
10MSRUPT        =               POSMAX
