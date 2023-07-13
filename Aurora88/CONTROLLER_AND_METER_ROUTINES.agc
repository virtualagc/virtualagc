### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    CONTROLLER_AND_METER_ROUTINES.agc
## Purpose:     A section of Aurora 88.
##              It is part of the reconstructed source code for the final
##              release of the Lunar Module system test software. No original
##              listings of this program are available; instead, this file
##              was created via disassembly of dumps of Aurora 88 core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-30 MAS  Created from Aurora 12.
##              2023-07-12 MAS  Updated for Aurora 88.


                SETLOC  ENDEXTVS
                EBANK=  PCOM

RHCNTRL         CAF     BIT10
                EXTEND
                RAND    30              # CHECK PGNCS CONTROL OF S/C
                EXTEND
                BZF     +2
                TCF     NORATE
                CAF     BIT15
                EXTEND
                RAND    31              # CHECK OUT-OF-DETENT BIT
                CCS     A
                TCF     NORATE

                CAF     ZERO            # ZERO COUNTERS
                TS      RHCP
                TS      RHCY
                TS      RHCR
                CAF     BIT8            # ENABLE COUNTERS
                AD      BIT9            # START READING INTO COUNTERS
                EXTEND
                WOR     13
                CAF     BIT5
                TC      WAITLIST        # COUNTERS FILLED
                2CADR   ATTCONT

                TC      TASKOVER

ATTCONT         CS      BIT8
                EXTEND
                WAND    13              # RESET COUNTER ENABLE
                CAF     BIT13
                EXTEND
                RAND    31              # CHECK IF IN ATTITUDE HOLD MODE
                EXTEND
                BZF     +2
                TC      XAXOVRD
                CA      RHCP
                EXTEND
                MP      BIT10
                CAF     RHCSCALE
                EXTEND
                MP      L
                TS      PCOM
                CA      RHCR
                EXTEND
                MP      BIT10
                CAF     RHCSCALE
                EXTEND


                MP      L
                TS      RCOM
XAXOVRD         CA      RHCY            # YAW CHANNEL ONLY IN AUTO MODE
                EXTEND
                MP      BIT10
                CAF     RHCSCALE
                EXTEND
                MP      L
                TS      YCOM
                TCF     RHCNTRL

NORATE          CAF     ZERO            # SET RATE COMMANDS TO ZERO
                TS      PCOM
                TS      RCOM
                TS      YCOM
                TC      TASKOVER

RHCSCALE        DEC     .44488          # LEAVES INPUTS SCALED AS PI/4 RAD/SEC.

## MAS 2023: The following chunks of code (down to ENDCMS) were added as patches
## between Aurora 85 and Aurora 88. They were placed here at the end of the bank
## so as to not change addresses of existing symbols.

# VB 60 PREPARE FOR STANDBY OPERATION

# ROUTINE WRITTEN FOR TEST ROPES ONLY*** MUST BE UPDATED TO INCLUDE
#                                 FLIGHT REQUIREMENTS FOR FLIGHT OPERATION

                EBANK=  LST1

PRESTAND        CAF     EBANK3          # COMES HERE FROM LST2FAN
                XCH     EBANK           # SET UP EBANK FOR BANK 3
                INHINT
                CA      TIME1
                TS      TIMESAV         # THIS ROUTINE WILL LOOK AT TIME1 UNTIL
                CAF     OKT30           #  TIME1 IS INCREMENTED, THEN IT WILL
LONGER          TS      TIMAR           # SNATCH THE MISSION TIME REGS AND STORE
                CS      TIMESAV         # THEM IN TIMESAV FOR LATER ISE IN ARITH.
                AD      TIME1           # OPERATIONS WHICH SHOULD FIND THE
                EXTEND                  # STANDING DIFFERENCE BETWEEN THE SCALAR
                BZF     CHKTIME         # AND THE TIME1-TIME2S REGS.

                EXTEND
                DCA     TIME2           # READ AND STORE THE DP TIME AND GO
                DXCH    TIMESAV         # READ THE SCALAR USING THE EXISTING PROG
                TCF     CATCHFIN        # FINETIME.

CHKTIME         CCS     TIMAR           # MUST WATCH THE TIME SPENT IN INHINT OR
                TC      LONGER          # THE COPS MIGHT CATCH US.
                RELINT
                CCS     NEWJOB
                TC      CHANG1
                TC      LONGER -1       # GO BACK AND LOOK AGAIN

CATCHFIN        TC      FINETIME        # WILL READ CHANNELS 3 AND 4 AND RETURN
                DXCH    SCALSAV         # WITH 3 IN A AND 4 IN L..
                RELINT
                CS      BIT4
                MASK    IMODES30        # INHIBIT THE IMU FAIL LIGHT.
                AD      BIT4
                TS      IMODES30

                CAF     BIT4            # SET ALL CHAN 12 BITS EXCEPT C/A TO ZERO.
                EXTEND                  # THIS IS NECESSARY SO THAT THE GIMBALS DO
                WAND    12              # NOT DRIFT INTO GIMBALLOCK IF THE SYSTEM

                CAF     BIT4            # SHOULD BE IN OPERATE AT THE TIME STBY
                EXTEND                  # WAS STARTED.  THIS SECTION WILL MAKE
                WOR     12              # SURE THE IMU IS IN C/A.....

                CAF     BIT11           # WHEN BIT 11 IS PRESENT IN CHANNEL 13 THE
                EXTEND                  # DSKY PB. CAN THEN ENERGIZE THE STANDBY
                WOR     13              # RELAY IN THE CGC PWR SUPPLIES....
                TC      ENDOFJOB        # GO TO DUMMY JOB UNTIL YOU DIE...

#  VB 61 RECOVER FROM STANDBY OPERATION

# ROUTINE WRITTEN FOR TEST ROPES ONLY**** MUST BE UPDATED TO INCLUDE
#                 FLIGHT REQUIREMENTS FOR FLIGHT OPERATIONS SEQUENCES....

POSTAND         CAF     EBANK3          # COMES HERE FROM LST2FAN
                XCH     EBANK           # SET UP EBANK FOR BANK 3
                TC      FINETIME
                DXCH    TIMAR           # READ THE SCALAR AND SEE IF IT OVERFLOW-
                RELINT                  # ED WHILE THE CGC WAS IN STBY, IF SO
                CAE     TIMAR           # THE OVERFLOW MUST BE ADDED OR IT WILL
                EXTEND                  # SEEM THAT THE REALATIVITY THEORY WORKS
                SU      SCALSAV         # BETTER THAN IT SHOULD...
                EXTEND
                BZMF    ADDTIME         # IF ITS NEG. IT MUST HAVE OV:FLWD..

                TC      INTPRET
                DLOAD   DSU             # IF IT DID NOT OV-FLW. FIND OUT HOW LONG
                        TIMAR           # THE CGC WAS IN STBY BY SUBTRACTING THE
                        SCALSAV         # SCALAR AT THE START OF STBY FROM THE
                SRR     RTB             # SCALAR AT THE END OF STBY AND THEN ADD
                        5               # THE DIFFERENCE TO THE TIME EXISTING
                        SGNAGREE        # WHEN THE SCALAR WAS READ AT STBY ENTRY**
                DAD
                        TIMESAV
                STORE   TIMAR
                EXIT

CORCTTIM        EXTEND
                DCA     TIMAR           # THIS IS THE CORRECTED TIME TO BE READ
                DXCH    TIME2           # INTO TIME1 AND TIME2 REGS. ADDR 24-25

                CS      BIT11
                EXTEND                  # DISABLE THE DSKY STBY PUSHBUTTON.
                WAND    13
                TC      ENDOFJOB

ADDTIME         EXTEND
                DCA     DPOSMAX         # IF THE SCALAR OVERFLOWED, FIND OUT HOW
                DXCH    TIMEDIFF        # MUCH TIME REMAINED WHEN READ THE FIRST
                TC      INTPRET         # TIME AND THEN ADD THE PRESENT READING-
                DLOAD   DSU             # WHICH WILL BE THE TOTAL TIME SPENT IN
                        TIMEDIFF        # STANDBY, TO WHICH THE TIME AT STBY
                        SCALSAV         # MAY BE ADDED TO FIND THE PRESENT TIME
                DAD     SRR             # CORRECT TO 10 MSEC..
                        TIMAR           # **** THE TIME IN STANDBY MODE MUST NOT
                        5               # EXCEED 23 HOURS IF TIME IS TO BE
                DAD                     # CORRECTLY COMPUTED BY THIS ROUTINE.*****
                        TIMESAV
                STORE   TIMAR
                EXIT
                TC      CORCTTIM

EBANK3          OCT     01400           # CONST USED TO SET EBANK REG FOR BANK 3


TESTNV          OCT     2101
LQPL            ECADR   QPLACE

TSELECT1        AD      QPLACE
                EXTEND
                BZMF    +3
                TC      FALTON
                TC      REDO
                TC      TSELECT +2
                NOOP

ENDCMS          EQUALS
