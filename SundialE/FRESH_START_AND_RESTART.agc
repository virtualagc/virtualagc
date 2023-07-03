### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    FRESH_START_AND_RESTART.agc
## Purpose:     A section of Sundial E.
##              It is part of the reconstructed source code for the final
##              release of the Block II Command Module system test software. No
##              original listings of this program are available; instead, this
##              file was created via disassembly of dumps of Sundial core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-22 MAS  Created from Aurora 12.
##              2023-06-30 MAS  Updated for Sundial E.
##              2023-07-03 MAS  Relocated Sundial D patches to T4RUPT PROGRAM.

                BANK    12
                EBANK=  LST1

SLAP1           INHINT                  # FRESH START. COMES HERE FROM PINBALL.
                TC      STARTSUB        # SUBROUTINE DOES MOST OF THE WORK.

                CAF     BIT15           # TURN OFF ALL DSPTAB +11D LAMPS ONLY ON
                TS      DSPTAB +11D     # REQUESTED FRESH START.

                CAF     ZERO            # SAME STORY ON ZEROING FAILREG.
                TS      FAILREG
                TS      SMODE

DOFSTART        CAF     ZERO            # DO A FRESH START,
                TS      MODREG
                TS      UPLOCK          # FREE UPLINK INTERLOCK

                TS      PHASE0          # INITIALIZE PHASE TABLE - NO MISSION
                TS      PHASE1          # PROGRAMS RUNNING.
                TS      PHASE2
                TS      PHASE3
                TS      PHASE4
                TS      PHASE5

                COM
                TS      -PHASE0
                TS      -PHASE1
                TS      -PHASE2
                TS      -PHASE3
                TS      -PHASE4
                TS      -PHASE5

                CAF     IM30INIF        # FRESH START IMU INITIALIZATION.
                TS      IMODES30

                CAF     BIT10           # REMOVE IMU FAIL INHIBIT IN 5 SECS.
                TC      WAITLIST
                2CADR   IFAILOK

                EXTEND                  # LET T5 IDLE.
                DCA     T5IDLER
                DXCH    T5LOC

                EXTEND                  # INITIALIZE SWITCHES ONLY ON FRESH START.
                DCA     SWINIT
                DXCH    STATE
                EXTEND
                DCA     SWINIT +2
                DXCH    STATE +2

ENDRSTRT        CAF     BIT6            # IF GIMBAL LOCK LAMP IS STILL ON,
                MASK    DSPTAB +11D     # IMU WAS FOUND IN GIMBAL LOCK IN RESTART
                CCS     A               # AND LEFT IN COARSE ALIGN. IN THIS CASE
                CS      BIT9            # SET ISS OPERATE BIT IN IMODES30 TO
                ADS     IMODES30        # OPERATE SO T4 INBIT MONITOR WONT ZERO

                RELINT                  # THE CDUS AS IT DOES IN FRESH START.
                TC      BANKCALL        # DISPLAY MAJOR MODE.
                CADR    DSPMM

STARTSW         TCF     DUMMYJOB +2     # PATCH FOR SIMULATION.

STARTSIM        CAF     BIT14
                TC      FINDVAC
                OCT     77777           # FATAL IF NOT PATCHED AS ABOVE.
                OCT     77777

                TCF     DUMMYJOB +2     # DONT ZERO NEWJOB

#          COMES HERE FROM LOCATION 4000, GOJAM. RESTART ANY PROGRAMS WHICH MAY HAVE BEEN RUNNING AT THE TIME.

GOPROG          TC      GOPROG1

                TC      STARTSUB        # COMMON INITIALIZATION ROUTINE.

                CAF     9,6             # LEAVE PROGRAM ALARM AND GIMBAL LOCK
                MASK    DSPTAB +11D     # LAMPS INTACT ON RESTART.
                AD      BIT15
                XCH     DSPTAB +11D
                MASK    BIT6
                CCS     A               # IF GIMBAL LOCK LAMP WAS ON, LEAVE ISS IN
                CAF     BIT4            # COARSE ALIGN.
                EXTEND
                WOR     12

                CAF     PRIO37          # DISPLAY FAILREG AS INDICATION OF RESTART
                TC      NOVAC           # OR TO DISPLAY ABORT CODE AS ABOVE.
                2CADR   DOALARM

                CAF     BIT7            # DOFSTART IF MARK REJECT AND EITHER
                EXTEND                  # ERROR LIGHT RESET BUTTONS ARE DEPRESSED
                RAND    16
                EXTEND
                BZF     PCLOOP -1       # VERIFY PHASE TABLE.

                CS      -ELR
                EXTEND
                RAND    16              # NAV DSKY KEYCODES,MARK,MARK REJECT
                AD      -ELR
                EXTEND
                BZF     DOFSTART

                CS      -ELR
                EXTEND
                RAND    15              # MAIN DSKY KEYCODES
                AD      -ELR
                EXTEND     
                BZF     DOFSTART

 -1             CAF     NUMGRPS         # VERIFY PHASE TABLE AGREEMENT.
PCLOOP          TS      MPAC +5
                DOUBLE
                EXTEND
                INDEX   A
                DCA     -PHASE0         # COMPLEMENT INTO A - DIRECT INTO L.
                EXTEND
                RXOR    L               # RESULT MUST BE -0 FOR AGREEMENT.
                CCS     A
                TCF     PTBAD           # RESTART FAILURE.
                TCF     PTBAD
                TCF     PTBAD
                CCS     MPAC +5         # PROCESS ALL RESTART GROUPS.
                TCF     PCLOOP

                TS      MPAC +6         # SET TO +0.
                CAF     NUMGRPS         # SEE IF ANY GROUPS RUNNING.
NXTRST          TS      MPAC +5
                DOUBLE
                INDEX   A
                CCS     PHASE0
                TCF     PACTIVE         # PNZ - GROUP ACTIVE.
                TCF     PINACT          # +0 - GROUP NOT RUNNING.

PTERM           TS      MPAC            # NNZ - TERMINATE REQUEST.
                INDEX   MPAC +5         # PICK UP RESTART TERMINATE CADR.
                CAF     RTERMCAD

PACT2           TS      L
                INCR    MPAC            # ABS OF PHASE.
                CS      LOW7            # SEE THAT MAG IS LESS THAN 128.
                MASK    MPAC
                CCS     A
                TCF     PTBAD           # BAD DATA.

                INCR    MPAC +6         # INDICATE GROUP DEMANDS PRESENT.
                CA      L
                TC      SWCALL          # MUST RETURN TO SWRETURN.

PINACT          CCS     MPAC +5         # PROCESS ALL RESTART GROUPS.
                TCF     NXTRST

TSTMPAC6        CCS     MPAC +6         # IF NO GROUPS ACTIVE THIS REQUEST, DO A
                TCF     DORSTART
                TCF     DOFSTART        # FRESH START

PACTIVE         TS      MPAC
                INDEX   MPAC +5         # SELECT RESTART ACTIVE CADR.
                CAF     RACTCADR
                TCF     PACT2

PTBAD           CAF     OCT1107         # SET ADDITIONAL FAILURE TO SHOW PHASE
                TS      SFAIL           # TABLE DISAGREEMENT (WILL BE DISPLAYED
                TCF     DOFSTART        # IN R2).

OCT1107         OCT     1107            # ADDITIONAL ALARM CODE.

DORSTART        CAF     IFAILINH        # LEAVE IMUFAILURE INHIBITS INTACT ON
                MASK    IMODES30        # RESTART, RESETTING ALL FAILURE CODES.
                AD      IM30INIR
                TS      IMODES30
                TCF     ENDRSTRT
# INITIALIZATION COMMON TO BOTH FRESH START AND RESTART.

STARTSUB        XCH     Q
                TS      BUF             # EXEC TEMPS ARE AVAILABLE TO US.

                CAF     ZERO            # ZERO OUTBITS WITHIN 3MS OF RESTART.
                EXTEND
                WRITE   12
                EXTEND
                WRITE   14
                EXTEND
                WRITE   11
                TC      STARTSB1
STARTSB2        EXTEND
                WRITE   13

                CAF     POSMAX          # T3 AND T4 OVERFLOW AS SOON AS POSSIBLE.
                TS      TIME5           # SO DOES T5.
                TS      TIME3           #   (POSMAX IS PSEUDO INTERRUPT SIGNAL IN
                TS      TIME4           #   CASE RUPT SIGNALLED BEFORE TS TIME3).

                CAF     STARTEB
                TS      EBANK           # SET FOR E3

                CAF     NEG1/2          # INITIALIZE WAITLIST DELTA-TS.
                TS      LST1 +7
                TS      LST1 +6
                TS      LST1 +5
                TS      LST1  +4
                TS      LST1  +3
                TS      LST1  +2
                TS      LST1  +1
                TS      LST1

                CS      ENDTASK
                TS      LST2
                TS      LST2 +2
                TS      LST2 +4
                TS      LST2 +6
                TS      LST2 +8D
                TS      LST2 +10D
                TS      LST2 +12D
                TS      LST2 +14D
                TS      LST2 +16D
                CS      ENDTASK +1
                TS      LST2 +1
                TS      LST2 +3
                TS      LST2 +5
                TS      LST2 +7
                TS      LST2 +9D
                TS      LST2 +11D
                TS      LST2 +13D
                TS      LST2 +15D
                TS      LST2 +17D

                CS      ZERO            # MAKE ALL EXECUTIVE REGISTER SETS
                TS      PRIORITY        # AVAILABLE.
                TS      PRIORITY +12D
                TS      PRIORITY +24D
                TS      PRIORITY +36D
                TS      PRIORITY +48D
                TS      PRIORITY +60D
                TS      PRIORITY +72D

                TS      DSRUPTSW
                TS      NEWJOB          # SHOWS NO ACTIVE JOBS.

                CAF     VAC1ADRC        # MAKE ALL VAC AREAS AVAILABLE.
                TS      VAC1USE
                AD      LTHVACA
                TS      VAC2USE
                AD      LTHVACA
                TS      VAC3USE
                AD      LTHVACA
                TS      VAC4USE
                AD      LTHVACA
                TS      VAC5USE

                CAF     TEN             # TURN OFF ALL DISPLAY SYSTEM RELAYS.
DSPOFF          TS      MPAC
                CS      BIT12
                INDEX   MPAC
                TS      DSPTAB
                CCS     MPAC
                TC      DSPOFF

                TS      INLINK
                TS      DSPCNT
                TS      CADRSTOR
                TS      REQRET
                TS      CLPASS
                TS      DSPLOCK
                TS      MONSAVE         # KILL MONITOR
                TS      MONSAVE1
                TS      GRABLOCK
                TS      VERBREG
                TS      NOUNREG
                TS      DSPLIST
                TS      DSPLIST +1
                TS      DSPLIST +2

                TS      MARKSTAT
                TS      EXTVBACT        # MAKE EXTENDED VERBS AVAILABLE
                TS      IMUCADR
                TS      OPTCADR
                TS      LGYRO
                CAF     NOUTCON
                TS      NOUT

                CAF     OPTINIT
                TS      OPTMODES

                CAF     NEGONE
                TS      OPTIND          # KILL COARSE OPTICS

                CAF     IM33INIT        # NO PIP OR TM FAILS.
                TS      IMODES33

                CAF     LESCHK          # SELF CHECK GO-TO REGISTER.
                TS      SELFRET
                CS      VD1
                TS      DSPCOUNT
                EBANK=  DNTMGOTO

                CAF     LDNTMGO         # SET UP TM PROGRAM.
                TS      EBANK

                CAF     LDNPHAS1
                TS      DNTMGOTO

                CAF     NOMTMLST        # SET UP NOMINAL DOWNLINK LIST.
                TS      DNLSTADR

                TC      BUF

T5IDLOC         CA      L               # T5RUPT COMES HERE EVERY 163.84 SECS
                TCF     NOQRSM +1       # WHEN NOBODY IS USING IT.
                
T5IDLER         2CADR   T5IDLOC

IFAILINH        OCT     35              # ISS FAILURE INHIBIT BITS.
LDNPHAS1        GENADR  DNPHASE1
LDNTMGO         ECADR   DNTMGOTO
NOMTMLST        GENADR  NOMDNLST
LESCHK          GENADR  SELFCHK
VAC1ADRC        ADRES   VAC1USE
LTHVACA         DEC     44

STARTEB         ECADR   LST1
NUMGRPS         EQUALS  FIVE            # SIX GROUPS CURRENTLY.

# WHERE TO GO ON RESTART IF GROUP ACTIVE:

RACTCADR        CADR    PRELGO          #  RESTARTS DURING PRELAUNCH ALIGNMENT
                CADR    OPTMSTRT        #  RESTARTS DURING OPTM ALIGN CALIBRATION
                CADR    10000
                CADR    10000
                CADR    10000
                CADR    10000

# WHERE TO GO ON RESTART IF TERMINATE REQUESTED.

RTERMCAD        CADR    10000
                CADR    10000
                CADR    10000
                CADR    10000
                CADR    10000
                CADR    10000

-ELR            OCT     -22             # -ERROR LIGHT RESET KEY CODE.
IM30INIF        OCT     37411           # INHIBITS IMU FAIL FOR 5 SEC AND PIP ISSW
IM30INIR        OCT     37400           # LEAVE FAIL INHIBITS ALONE.
IM33INIT        OCT     16000           # NO PIP OR TM FAIL SIGNALS.
9,6             OCT     440             # MASK FOR PROG ALARM AND GIMBAL LOCK.
OPTINIT         OCT     130
SWINIT          OCT     0
                OCT     0
                OCT     0
                OCT     0

ENDFRESS        EQUALS
