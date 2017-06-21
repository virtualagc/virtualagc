### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    FRESH_START_AND_RESTART.agc
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
## Reference:   pp. 78-89
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-29 HG   Transcribed
##              2017-06-15 HG   Fix operand  BIT14  -> BIT4
##                              Fix operator TC     -> TS  
##                                           TCF    -> TC 
##                              Fix statements CS    LMPCMD --> MASK LMPCMD
##                                             MASK  BIT15  --> AD   BIT15
##                                             ADS   LMPCMD --> TS   LMPCMD
##                              Fix value IM30INIR  OCT 37000 -> OCT 37400
##		2017-06-21 RSB	Various comment fixes found using 
##				octopus/ProoferComments.

## Page 78
                BANK            01
                EBANK=          LST1

SLAP1           INHINT                                  # FRESH START. COMES HERE FROM PINBALL.
                TC              STARTSUB                # SUBROUTINE DOES MOST OF THE WORK.

STARTSW         TCF             GOON                    # PATCH FOR SIMULATIONS

STARTSIM        CAF             BIT14

                TC              FINDVAC
                EBANK=          ITEMP1
                2CADR           BEGIN206

GOON            CAF             BIT15                   # TURN OFF ALL DSPTAB +11D LAMPS ONLY ON
                TS              DSPTAB          +11D    # REQUESTED FRESH START.

                CAF             ZERO                    # SAME STORY ON ZEROING FAILREG.
                TS              REDOCTR
                TS              FAILREG
                TS              FAILREG         +1
                TS              FAILREG         +2

                EXTEND                                  # INITIALIZE SPECIAL ENEMIZE REGISTER
                DCA             ENJOBCAD
                DXCH            FLUSHREG                # *** REMOVE IF FAKESTRT REMOVED

DOFSTART        CS              ZERO                    # MAKE ALL MTIMER/PHASE PAIRS AVAILABLE.
                TS              MTIMER4
                TS              MTIMER3
                TS              MTIMER2
                TS              MTIMER1

                TS              MPHASE4
                TS              MPHASE3
                TS              MPHASE2
                TS              MPHASE1

# INITIALIZE SWITCH REGISTERS INCLUDING DAPBOOLS

                CS              ONE
                TS              LMPOUTT

                CA              SEVEN
  -6            TS              L
                INDEX           L
                CA              SWINIT
                INDEX           L
                TS              STATE
                CCS             L
                TCF             -6

## Page 79

                TS              CDUX                    # ZERO CDUS SO MATRIX COMPUTATION IN T4
                TS              CDUY                    # WONT OVERFLOW.
                TS              CDUZ

                TS              LMPCMD                  # RESET LMP COMMAND AREA.
                TS              LMPCMD          +1
                TS              LMPCMD          +2
                TS              LMPCMD          +3
                TS              LMPCMD          +4
                TS              LMPCMD          +5
                TS              LMPCMD          +6
                TS              LMPCMD          +7
                TS              LMPIN
                TS              LMPOUT

POOH3           CAF             ZERO
                TS              SMODE
                TS              MODREG
                TS              AGSWORD                 # ALLOW AGS INITIALIZATION.

                TS              PHASE6                  # INITIALIZE PHASE TABLES - NO MISSION
                TS              PHASE1                  # PROGRAMS RUNNING.
                TS              PHASE2
                TS              PHASE3
                TS              PHASE4
                TS              PHASE5

                COM
                TS              -PHASE6
                TS              -PHASE1
                TS              -PHASE2
                TS              -PHASE3
                TS              -PHASE4
                TS              -PHASE5

                CAF             LNORMT4
                TS              T4LOC

                CAF             IM30INIF                # FRESH START IMU INITIALIZATION.
                TS              IMODES30

                CAF             BIT10                   # REMOVE IMU FAIL INHIBIT IN 5 SECS.
                TC              WAITLIST
                EBANK=          LST1
                2CADR           IFAILOK
                EXTEND                                  # SETTING T5RUPT FOR SETIDLER PROGRAM
                DCA             SETADR                  # THE SETIDLER PROGRAM ASSURES 1 SECOND
                DXCH            T5ADR                   # DELAY BEFORE THE DAPIDLER BEGINS.

## Page 80
ENDRSTRT        CAF             BIT6                    # IF GIMBAL LOCK LAMP IS STILL ON,
                MASK            DSPTAB          +11D    # IMU WAS FOUND IN GIMBAL LOCK IN RESTART
                CCS             A                       # AND LEFT IN COARSE ALIGN. IN THIS CASE
                CS              BIT9                    # SET ISS OPERATE BIT IN IMODES30 TO
                ADS             IMODES30                # OPERATE SO T4 INBIT MONITOR WONT ZERO

                RELINT                                  # THE CDUS AS IT DOES IN FRESH START.
                TC              BANKCALL                # DISPLAY MAJOR MODE.
                CADR            DSPMM

                CAF             PRIO30                  # THIS IS USED ONLY FOR SPECIAL ENEMIZE.
                INHINT                                  # $$$ REMOVE IF FULL RESTARTABILITY ***
                TC              FINDVAC
                EBANK=          FLUSHREG
                2CADR           FLUSHLOC
                RELINT
                TCF             DUMMYJOB        +2      # DONT ZERO NEWJOB



FLUSHLOC        EXTEND                                  # GO TO SPECIAL ENEMA LOC FOR ROM
                DCA             FLUSHREG
                DXCH            Z                       # USUALLY THIS WILL BE AN ENDOFJOB

OCT312          OCT             312
                EBANK=          LST1
ENJOBCAD        2CADR           ENDOFJOB

## Page 81
#          COMES HERE FROM LOCATION 4000, GOJAM. RESTART ANY PROGRAMS WHICH MAY HAVE BEEN RUNNING AT THE TIME.

GOPROG          TC              BANKCALL                # * * * SUBJECT TO A HUGE CHANGE * * *
                CADR            FAKESTRT
                INCR            REDOCTR

                CA              ERESTORE
                EXTEND
                BZF             2STARTSB
                CA              SKEEP7
                MASK            HI5
                EXTEND                                  # IF SKEEP7 CONTAINS NONSENSE, DO
                BZF             +2                      # A FRESH START.  THIS ELIMINATES A CHANCE
                TCF             SLAP1                   # OF POSSIBLE COMPUTER LOCKUP.

                EXTEND                                  # RESTORE B(X) AND B(X+1) IF RESTART
                DCA             SKEEP5                  # HAPPENED WHILE SELF-CHECK HAD REPLACED
                NDX             SKEEP7                  # THEM WITH CHECKING WORDS.
                DXCH            0000

2STARTSB        TC              STARTSUB                # COMMON INITIALIZATION ROUTINE

                CAF             9,6                     # LEAVE PROGRAM ALARM AND GIMBAL LOCK
                MASK            DSPTAB          +11D    # LAMPS INTACT ON RESTART.
                AD              BIT15
                XCH             DSPTAB          +11D

                MASK            BIT6
                CCS             A                       # IF GIMBAL LOCK LAMP WAS ON, LEAVE ISS IN
                CAF             BIT4                    # COARSE ALIGN.
                EXTEND
                WOR             12

# DAP ZEROES GODAPGO TO BYPASS STARTUP OF DAP AFTER JETABORT UNTIL GROUND
                EXTEND                                  # SETTING T5RUPT FOR DAPIDLER PROGRAM
                DCA             IDLEADR
                DXCH            T5ADR
                                                        # RESETS GODAPGO.
                CAF             PRIO37                  # DISPLAY FAILREG AS INDICATION OF RESTART
                TC              NOVAC                   # OR TO DISPLAY ABORT CODE AS ABOVE.
                EBANK=          LST1
                2CADR           DOALARM
LIGHTSET        EXTEND                                  # DONT TRY TO RESTART IF ERROR
                READ            15                      # AND MARK REJECT BUTTONS DEPRESSED.
                AD              -ELR
                EXTEND
                BZF             +2
                TCF             +7

                CAF             BIT5

## Page 82
                EXTEND
                RAND            16
                AD              -MKREJ
                EXTEND
                BZF             DOFSTART

                CS              T4LOC                   # SEE IF LMP COMMAND WAS SITTING IN CH 10
                AD              LLMPRS2                 # WHEN RESTART OCCURRED. IF SO, SET BIT 15

                EXTEND                                  # BACK TO ZERO SO THE COMMAND WILL BE
                BZF             LMPRUPT                 # RESENT.

                CCS             LMPOUTT                 # IF NOT, SEE IF UPDATE OF REFERENCE
                AD              ONE                     # POINTER (LMPOUT) WAS IN PROCESS. IF SO,
                TS              LMPOUT                  # LMPOUTT IS NON-NEGATIVE.
                CS              ONE                     # SHOW LMPOUT UPDATED.
                TS              LMPOUTT
                TCF             T4LOCRST

LMPRUPT         CS              BIT15                   # CANT USE ADS HERE SINCE CODING MUST BE
                INDEX           LMPOUT                  # REPEATABLE (RESTART DURING RESTART, ETC)
                MASK            LMPCMD
                AD              BIT15
                INDEX           LMPOUT
                TS              LMPCMD

T4LOCRST        CAF             LNORMT4
                TS              T4LOC

 -1             CAF             NUMGRPS                 # VERIFY PHASE TABLE AGREEMENT.
PCLOOP          TS              MPAC            +5
                DOUBLE

                EXTEND
                INDEX           A
                DCA             -PHASE1                 # COMPLEMENT INTO A, DIRECT INTO L.
                EXTEND
                RXOR            L                       # RESULT MUST BE -0 FOR AGREEMENT.
                CCS             A
                TCF             PTBAD                   # RESTART FAILURE.
                TCF             PTBAD
                TCF             PTBAD

                CCS             MPAC            +5      # PROCESS ALL RESTART GROUPS.
                TCF             PCLOOP

                TS              MPAC            +6      # SET TO +0.
                TC              NXTRST          -1      # * * * BYPASS 77 CHECK FOR NOW
                CA              -PHASE6                 # TEST TO SEE IF IT IS A PLANNED NO RESTAR
                AD              OCT77                   # T RESTART
                CCS             A
                TCF             +4                      # A NORMAL RESTART

## Page 83
OCT77           OCT             77                      # CAN:T GET HERE
                TCF             +2                      # A NORMAL RESTART
                TCF             +1                      # THIS MAY GO TO FORGETIT IF EVER USED

                CAF             NUMGRPS                 # SEE IF ANY GROUPS RUNNING.
NXTRST          TS              MPAC            +5
                DOUBLE
                INDEX           A
                CCS             PHASE1
                TCF             PACTIVE                 # PNZ - GROUP ACTIVE.
                TCF             PINACT                  # +0 - GROUP NOT RUNNING.

PACTIVE         TS              MPAC
                INCR            MPAC                    # ABS OF PHASE.

                INCR            MPAC            +6      # INDICATE GROUP DEMANDS PRESENT.
                CA              RACTCADR                # GO TO RESTARTS AND PROCESS PHASE INFO.
                TC              SWCALL                  # MUST RETURN TO SWRETURN.

PINACT          CCS             MPAC            +5      # PROCESS ALL RESTART GROUPS.
                TCF             NXTRST

TSTMPAC6        CCS             MPAC            +6      # IF NO GROUPS ACTIVE THIS REQUEST, DO A
                TCF             DORSTART
                TCF             DOFSTART                # FRESH START

PTBAD           CAF             OCT1107                 # SET ADDITIONAL FAILURE TO SHOW PHASE
                TS              SFAIL                   # TABLE DISAGREEMENT (WILL BE DISPLAYED
                TCF             DOFSTART                # IN R2).

RACTCADR        CADR            RESTARTS
OCT1107         OCT             1107                    # ADDITIONAL ALARM CODE.

DORSTART        CAF             IFAILINH                # LEAVE IMU FAILURE INHIBITS INTACT ON
                MASK            IMODES30                # RESTART, RESETTING ALL FAILURE CODES.
                AD              IM30INIR
                TS              IMODES30

                TCF             ENDRSTRT

## Page 84
#          INITIALIZATION COMMON TO BOTH FRESH START AND RESTART.
                EBANK=          DNTMGOTO                # DO PORTION OF FRESH START NOT DONE
STARTSUB        CAF             LDNTMGO                 # BY POO.
                TS              EBANK                   # SET UP TM PROGRAM.

                CAF             LDNPHAS1
                TS              DNTMGOTO

STARTSB2        XCH             Q                       # ENTRY FROM POO.
                TS              BUF                     # EXEC TEMPS ARE AVAILABLE TO US.

                CAF             ZERO                    # ZERO OUTBITS WITHIN 3MS OF RESTART.
                EXTEND
                WRITE           12
                EXTEND
                WRITE           14
                EXTEND
                WRITE           11
                TS              ERESTORE                #      ERASCHK RESTORE FLAG

                EXTEND                                  # USE FIRST 8 OF 12 SUPER-BANKS (ADD PROG
                WRITE           7                       # WHEN LAST FOUR ARE NEEDED). PROBABLY V37
                CAF             PRIO34                  # ENABLE INTERRUPTS.
                EXTEND
                WRITE           13

                CAF             POSMAX                  # T3 AND T4 OVERFLOW AS SOON AS POSSIBLE.
                TS              TIME5                   # SO DOES T5.
                TS              TIME3                   #   (POSMAX IS PSEUDO INTERRUPT SIGNAL IN
                TS              TIME4                   #   CASE RUPT SIGNALLED BEFORE TS TIME3).

                EBANK=          LST1
                CAF             STARTEB
                TS              EBANK                   # SET FOR E3

                CAF             NEG1/2                  # INITIALIZE WAITLIST DELTA-TS.
                TS              LST1            +7
                TS              LST1            +6
                TS              LST1            +5
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

## Page 85
                TS              LST2            +8D
                TS              LST2            +10D

                TS              LST2            +12D
                TS              LST2            +14D
                TS              LST2            +16D
                CS              ENDTASK         +1
                TS              LST2            +1
                TS              LST2            +3
                TS              LST2            +5
                TS              LST2            +7
                TS              LST2            +9D
                TS              LST2            +11D
                TS              LST2            +13D
                TS              LST2            +15D
                TS              LST2            +17D

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

                CAF             TEN                     # TURN OFF ALL DISPLAY SYSTEM RELAYS.
                TS              DIDFLG                  # DISPLAY INERTIAL DATA FLAG.
DSPOFF          TS              MPAC
                CS              BIT12
                INDEX           MPAC
                TS              DSPTAB
                CCS             MPAC
                TC              DSPOFF

                TS              INLINK
                TS              DSPCNT

                TS              CADRSTOR

## Page 86
                TS              REQRET
                TS              CLPASS
                TS              DSPLOCK
                TS              MONSAVE                 # KILL MONITOR
                TS              MONSAVE1
                TS              GRABLOCK
                TS              VERBREG
                TS              NOUNREG

                TS              DSPLIST
                TS              DSPLIST         +1
                TS              DSPLIST         +2

                TS              MARKSTAT
                TS              EXTVBACT                # MAKE EXTENDED VERBS AVAILABLE
                TS              IMUCADR
                TS              OPTCADR
                TS              RADCADR
                TS              ATTCADR
                TS              PHASENUM
                TS              LGYRO
                TS              DSRUPTSW
                CAF             NOUTCON
                TS              NOUT

                CS              ONE                     # NO RADAR DESIGNATION.
                TS              SAMPLIM                 # NO RADAR RUPTS EXPECTED.

                CAF             IM33INIT                # NO PIP OR TM FAILS.
                TS              IMODES33

                CAF             BIT6                    # SET LR POS.
                EXTEND
                RAND            33
                AD              RMODINIT
                TS              RADMODES

                CAF             LESCHK                  # SELF CHECK GO-TO REGISTER.
                TS              SELFRET
                CS              VD1
                TS              DSPCOUNT

                CAF             NOMTMLST                # SET UP NOMINAL DOWNLINK LIST.
                TS              DNLSTADR

                TC              BUF

IFAILINH        OCT             35                      # ISS FAILURE INHIBIT BITS.
LDNPHAS1        GENADR          DNPHASE1
LDNTMGO         ECADR           DNTMGOTO
NOMTMLST        GENADR          NOMDNLST

## Page 87
LESCHK          GENADR          SELFCHK
LLMPRS2         GENADR          LMPRESET
VAC1ADRC        ADRES           VAC1USE
LTHVACA         DEC             44

STARTEB         ECADR           LST1
NUMGRPS         EQUALS          FIVE                    # SIX GROUPS CURRENTLY.

#          WHERE TO GO ON RESTART IF TERMINATE REQUESTED.

-ELR            OCT             -22                     # -ERROR LIGHT RESET KEY CODE.
-MKREJ          OCT             -20                     # - MARK REJECT.
IM30INIF        OCT             37411                   # INHIBITS IMU FAIL FOR 5 SEC AND PIP ISSW
IM30INIR        OCT             37400                   # LEAVE FAIL INHIBITS ALONE.

IM33INIT        OCT             16000                   # NO PIP OR TM FAIL SIGNALS.
9,6             OCT             440                     # MASK FOR PROG ALARM AND GIMBAL LOCK.
RMODINIT        OCT             00102

                EBANK=          DT
IDLEADR         2CADR           DAPIDLER
                EBANK=          DT
SETADR          2CADR           SETIDLE

SWINIT          OCT             0
                OCT             0
                OCT             00005
                OCT             44516                   # INIT FOR DAPBOOLS. DB SET IN SETIDLE.
                OCT             0
                OCT             0
                OCT             0
                OCT             0

## Page 88
# PROGRAM TO REVERT TO IDLING MODE (P 00).

# CALLING SEQUENCE:  TC (OR TCF)   POOH     UNDER EXEC (NOT INTERRUPTED).

                BLOCK           02
POOH            TC              POSTJUMP
                CADR            POOH2                   # DO A PARTIAL FRESH START.


                BANK            01

POOH2           INHINT
                TC              STARTSB2                # DOESN'T CLOBBER DOWNLINK.

                TC              FLAG2DWN
                OCT             20                      # TURN OFF MISSION TIMER FLAG

#   ***** HERE WE SHOULD RESET STATE REGISTERS, DEAL WITH DAP, ETC. *****

                CA              LPOOH3                  # PICK UP RETURN FOR MSTART.
                TC              MSTART          -1      # START MISSION TIMERS COUNTING.
                                                        # WE GET A RELINT AT MSTART.


LPOOH3          ADRES           POOH3
                BANK            7

FORGETIT        INHINT                                  # THIS IS ALSO DOV74
                EXTEND
                DCA             KILLCAD
                DXCH            DVMNEXIT

                EXTEND
                DCA             CADAVER
                DXCH            AVGEXIT

                CAF             PINGSMON
                TS              DVSELECT

                TC              ENGINOFF

                CS              BGIMBALS                # TURN OFF TRIM GIMBALS
                EXTEND
                WAND            12

ENEMA           INHINT
                CAF             ZERO                    # MAKE INACTIVE ALL RESTART PHASES
                TS              PHASE1                  # EXCEPT SERVICER

## Page 89
                TS              PHASE2
                TS              PHASE3

                TS              PHASE4
                TS              PHASE6

                COM
                TS              -PHASE1
                TS              -PHASE2
                TS              -PHASE3
                TS              -PHASE4
                TS              -PHASE6

                TS              MPHASE1                 # SET TIMER/PHASE PAIRS TO IDLE STATE
                TS              MPHASE2
                TS              MPHASE3
                TS              MPHASE4
                TS              MTIMER4
                TS              MTIMER3
                TS              MTIMER2
                TS              MTIMER1

# START TASK TO RESET LMP COMMANDS HERE AND OTHER CLEANUP PROBLEMS
                TC              POSTJUMP
                CADR            GOPROG          +3

                EBANK=          LST1
CADAVER         2CADR           SERVEXIT

                EBANK=          LST1
KILLCAD         2CADR           AVEGKILL

PINGSMON        GENADR          PGNCSMON
BGIMBALS        OCT             7400

AVEGKILL        TC              FLAG1DWN                # COMES HERE WHEN ENGINE OFF
                OCT             1
# SERVICER GOES TO POOH AND ENABLES TIMERS AT DEAD END.  ALL PROGRAMS MUSTTURN OFF PIPAS AT END OF MISSION PHASE
                TCF             ENDOFJOB

FAKESTRT        INCR            REDOCTR                 # FAKESTRT ALARM
                TC              ALARM
                OCT             0316

                TCF             FORGETIT

DOV74           EQUALS          FORGETIT
