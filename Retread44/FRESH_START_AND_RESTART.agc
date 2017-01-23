### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    FRESH_START_AND_RESTART.agc
## Purpose:     Part of the source code for Retread 44 (revision 0). It was
##              the very first program for the Block II AGC, created as an
##              extensive rewrite of the Block I program Sunrise.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 124-127
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-13 MAS  Created from Aurora 12 version.
##              2016-12-13 MAS  Transcribed.
## 		2016-12-27 RSB	Proofed comment text using octopus/ProoferComments,
##				and fixed errors found.

## Page 124
## The log section title, FRESH START AND RESTART, is circled in red. Below it is written
## "Program starts here", with an arrow drawn to the SLAP1 line.
                SETLOC          ENDWAITS

SLAP1           INHINT                                  # FRESH START. COMES HERE FROM PINBALL.
                CAF             ZERO                    #  (ZERO FAILREG IN FRESH START ONLY).
                TS              FAILREG
                TS              UPLOCK                  # FREE UPLINK INTERLOCK
                CAF             BIT15                   # TURNS OFF AUTO, HOLD, FREE, NO ATT,
                TS              DSPTAB          +11D    # SPARE, GIMBAL LOCK, SPARE, TRACKER,
                                                        # PROG ALM (BITS 1-9 OF DSPTAB+11D),
                                                        # IN FRESH START ONLY.
                CS              BIT13                   # TURN OFF :TEST ALARM: OUTBIT (CHAN13
                EXTEND                                  # BIT10).  FRESH START ONLY.
                WAND            CHAN13
                CS              BIT4                    # TURN OFF TEMP (FRESH START ONLY)
                EXTEND
                WAND            DSALMOUT
                CAF             STARTEB
                TS              EBANK                   # SET FOR E3
SLAP2           CAF             ZERO
                TS              SMODE
                TC              STARTSUB                # SUBROUTINE DOES MOST OF THE WORK.

                TCF             DUMMYJOB

GOPROG          TC              SLAP2                   # COMES HERE FROM 4050  RESTART.



                EBANK=          LST1
STARTEB         ECADR           LST1
STARTSUB        XCH             Q
                TS              BUF                     # EXEC TEMPS ARE AVAILABLE TO US.
                
                CAF             POSMAX                  # T3 AND T4 OVERFLOW AS SOON AS POSSIBLE.
                TS              TIME3                   #   (POSMAX IS PSEUDO INTERRUPT SIGNAL IN
                TS              TIME4                   #   CASE RUPT SIGNALLED BEFORE TS TIME3).
                
                CAF             NEG1/2                  # INITIALIZE WAITLIST DELTA-TS.
                TS              LST1            +4
                TS              LST1            +3
                TS              LST1            +2
                TS              LST1            +1
                TS              LST1
                
                CS              ENDTASK
                TS              LST2
                TS              LST2            +2
                TS              LST2            +4
                TS              LST2            +6
                TS              LST2            +8D
## Page 125
                TS              LST2            +10D
                CS              ENDTASK         +1
                TS              LST2            +1
                TS              LST2            +3
                TS              LST2            +5
                TS              LST2            +7
                TS              LST2            +9D
                TS              LST2            +11D
                
                CS              ZERO                    # MAKE ALL EXECUTIVE REGISTER SETS
                TS              PRIORITY                # AVAILABLE.
                TS              PRIORITY        +12D
                TS              PRIORITY        +24D
                TS              PRIORITY        +36D
                TS              PRIORITY        +48D
                TS              PRIORITY        +60D
                TS              PRIORITY        +72D
                
                TS              NEWJOB                  # SHOWS NO ACTIVE JOBS.
                
                CAF             VAC1ADRC                # MAKE ALL VAC AREAS AVAILABLE.
                TS              VAC1USE
                AD              LTHVACA
                TS              VAC2USE
                AD              LTHVACA
                TS              VAC3USE
                AD              LTHVACA
                TS              VAC4USE
                AD              LTHVACA
                TS              VAC5USE
                
                CAF             ONE                     # GIVES 110 MS TO GET READY FOR T4.
                TS              DSRUPTSW
                CAF             TEN                     # TURN OFF ALL DISPLAY SYSTEM RELAYS.
DSPOFF          TS              MPAC
                CS              BIT12
                INDEX           MPAC
                TS              DSPTAB
                CCS             MPAC
                TC              DSPOFF
                
                TS              INLINK
                TS              DSPCNT
                TS              MODREG
                TS              CADRSTOR
                TS              REQRET
                TS              CLPASS
                TS              DSPLOCK
                TS              MONSAVE                 # KILL MONITOR
                TS              MONSAVE1
## Page 126
                TS              GRABLOCK
                TS              VERBREG
                TS              NOUNREG
                TS              DSPLIST
                TS              DSPLIST         +1
                TS              DSPLIST         +2
                
## Page 127
                TS              STATE                   # TURN OFF INTERPRETER SWITCHES.
                TS              STATE           +1
                TS              STATE           +2
                TS              STATE           +3
                TS              EXTVBACT                # MAKE EXTENDED VERBS AVAILABLE
                CAF             NOUTCON
                TS              NOUT

                CS              CHAN11C                 # TURN OFF UPLINK ACTIVITY, KEY
                EXTEND                                  # RLSE, V/N FLASH, OPERATOR ERROR
                WAND            DSALMOUT                # IN BOTH FRESH START AND RESTART.
                CAF             LESCHK                  # SELF CHECK GO-TO REGISTER.
                TS              SELFRET
                CS              VD1
                TS              DSPCOUNT
                TC              BUF

CHAN11C         OCT             00164                   # CHAN 11 BITS 3,5,6,7.
                                                        # UPLINK ACTIVITY, KEY RLSE,
                                                        # V/N FLASH, OPERATOR ERROR.
LESCHK          ADRES           SMODECHK
VAC1ADRC        ADRES           VAC1USE
LTHVACA         DEC             44
