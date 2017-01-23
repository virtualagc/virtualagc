### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     FRESH_START_AND_RESTART.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        151-159
## Mod history:  2016-09-20 JL   Created.
##               2016-10-04 HG   Added missed IDLEADR
##               2016-10-16 HG   Fix operand T4L``INIT -> T4LINIT
##                                           ENDRSTART -> ENDRSTRT
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 and fixed the errors found.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the private collection of 
## Don Eyles.  The digitization was performed by archive.org.

## Notations on the hardcopy document read, in part:

##       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
##       NOV 10, 1966

##       [Note that this is the date the hardcopy was made, not the
##       date of the program revision or the assembly.]

## The scan images (with suitable reduction in storage size and consequent 
## reduction in image quality) are available online at 
##       https://www.ibiblio.org/apollo.  
## The original high-quality digital images are available at archive.org:
##       https://archive.org/details/aurora00dapg
## Page 151
                BANK            12 
                EBANK=          LST1

SLAP1           INHINT                                  # FRESH START. COMES HERE FROM PINBALL.
                TC              STARTSUB                # SUBROUTINE DOES MOST OF THE WORK.

                CAF             BIT15                   # TURN OFF ALL DSPTAB +11D LAMPS ONLY ON
                TS              DSPTAB          +11D    # REQUESTED FRESH START.

                CAF             ZERO                    # SAME STORY ON ZEROING FAILREG.
                TS              FAILREG

DOFSTART        CAF             ZERO                    # DO A FRESH START,
                TS              SMODE
                TS              MODREG
                TS              AGSWORD                 # ALLOW AGS INITIALIZATION
                TS              UPLOCK                  # FREE UPLINK INTERLOCK

                TS              CDUX                    # ZERO CDUS SO MATRIX COMPUTATION IN T4
                TS              CDUY                    # WONT OVERFLOW.
                TS              CDUZ
                
                TS              PHASE0                  # INITIALIZE PHASE TABLE - NO MISSION
                TS              PHASE1                  # PROGRAMS RUNNING.
                TS              PHASE2
                TS              PHASE3
                TS              PHASE4
                TS              PHASE5
                
                COM
                TS              -PHASE0
                TS              -PHASE1
                TS              -PHASE2
                TS              -PHASE3
                TS              -PHASE4
                TS              -PHASE5
                
                CAF             IM30INIF                # FRESH START IMU INITIALIZATION.
                TS              IMODES30
                
                CAF             BIT10                   # REMOVE IMU FAIL INHIBIT IN 5 SECS.
                TC              WAITLIST
                2CADR           IFAILOK
                EXTEND                                  # SETTING T5RUPT FOR SETIDLER PROGRAM
                DCA             SETADR                  # THE SETIDLER PROGRAM ASSURES 1 SECOND
                DXCH            T5ADR                   # DELAY BEFORE THE DAPIDLER BEGINS.
                
                CAF             OCT04012                # INITIALIZE DAPBOOLS
                TS              DAPBOOLS
## Page 152
                EXTEND                                  # INITIALIZE SWITCHES ONLY ON FRESH START.
                DCA             SWINIT
                DXCH            STATE
                EXTEND
                DCA             SWINIT          +2
                DXCH            STATE           +2
                
ENDRSTRT        CAF             BIT6                    # IF GIMBAL LOCK LAMP IS STILL ON,
                MASK            DSPTAB          +11D    # IMU WAS FOUND IN GIMBAL LOCK IN RESTART
                CCS             A                       # AND LEFT IN COARSE ALIGN. IN THIS CASE
                CS              BIT9                    # SET ISS OPERATE BIT IN IMODES30 TO
                ADS             IMODES30                # OPERATE SO T4 INBIT MONITOR WONT ZERO
                
                RELINT                                  # THE CDUS AS IT DOES IN FRESH START.
                TC              BANKCALL                # DISPLAY MAJOR MODE.
                CADR            DSPMM
                
STARTSW         TCF             DUMMYJOB        +2      # PATCH FOR SIMULATION.

STARTSIM        CAF             BIT14
                TC              FINDVAC
                OCT             77777                   # FATAL IF NOT PATCHED AS ABOVE.
                OCT             77777
                
                TCF             DUMMYJOB        +2      # DONT ZERO NEWJOB

## Page 153
#          COMES HERE FROM LOCATION 4000, GOJAM. RESTART ANY PROGRAMS WHICH MAY HAVE BEEN RUNNING AT THE TIME.

GOPROG          INCR            REDOCTR                 # ADVANCE RESTART COUNTER.

                TC              STARTSUB                # COMMON INITIALIZATION ROUTINE.
                
                CAF             9,6                     # LEAVE PROGRAM ALARM AND GIMBAL LOCK
                MASK            DSPTAB          +11D    # LAMPS INTACT ON RESTART.
                AD              BIT15
                XCH             DSPTAB          +11D
                MASK            BIT6
                CCS             A                       # IF GIMBAL LOCK LAMP WAS ON, LEAVE ISS IN
                CAF             BIT4                    # COARSE ALIGN.
                EXTEND
                WOR             12
                
                EXTEND                                  # SETTING T5RUPT FOR DAPIDLER PROGRAM
                DCA             IDLEADR
                DXCH            T5ADR
                CAF             PRIO37                  # DISPLAY FAILREG AS INDICATION OF RESTART
                TC              NOVAC                   # OR TO DISPLAY ABORT CODE AS ABOVE.
                2CADR           DOALARM
                EXTEND                                  # DONT TRY TO RESTART IF ERROR LIGHT RESET
                READ            15                      # AND MARK REJECT BUTTONS DEPRESSED.
                AD              -ELR
                EXTEND
                BZF                             +2
                TCF             PCLOOP          -1      # VERIFY PHASE TABLE.
                
                CAF             BIT5
                EXTEND
                RAND            16
                AD              -MKREJ
                EXTEND
                BZF             DOFSTART
                
 -1             CAF             NUMGRPS                 # VERIFY PHASE TABLE AGREEMENT.
PCLOOP          TS              MPAC            +5
                DOUBLE
                EXTEND
                INDEX           A
                DCA             -PHASE0                 # COMPLEMENT INTO A - DIRECT INTO L.
                EXTEND
                RXOR            L                       # RESULT MUST BE -0 FOR AGREEMENT.
                CCS             A
                TCF             PTBAD                   # RESTART FAILURE.
                TCF             PTBAD
                TCF             PTBAD
## Page 154
                CCS             MPAC            +5      # PROCESS ALL RESTART GROUPS.
                TCF             PCLOOP
                
                TS              MPAC            +6      # SET TO +0.
                CAF             NUMGRPS                 # SEE IF ANY GROUPS RUNNING.
NXTRST          TS              MPAC            +5
                DOUBLE
                INDEX           A
                CCS             PHASE0
                TCF             PACTIVE                 # PNZ - GROUP ACTIVE.
                TCF             PINACT                  # +0 - GROUP NOT RUNNING.
                
PTERM           TS              MPAC                    # NNZ - TERMINATE REQUEST.
                INDEX           MPAC            +5      # PICK UP RESTART TERMINATE CADR.
                CAF             RTERMCAD
                
PACT2           TS              L
                INCR            MPAC                    # ABS OF PHASE.
                CS              LOW7                    # SEE THAT MAG IS LESS THAN 128.
                MASK            MPAC
                CCS             A
                TCF             PTBAD                   # BAD DATA.
                
                INCR            MPAC            +6      # INDICATE GROUP DEMANDS PRESENT.
                CA              L
                TC              SWCALL                  # MUST RETURN TO SWRETURN.

PINACT          CCS             MPAC            +5      # PROCESS ALL RESTART GROUPS.
                TCF             NXTRST

TSTMPAC6        CCS             MPAC            +6      # IF NO GROUPS ACTIVE THIS REQUEST, DO A
                TCF             DORSTART
                TCF             DOFSTART                # FRESH START
                
PACTIVE         TS              MPAC
                INDEX           MPAC            +5      # SELECT RESTART ACTIVE CADR.
                CAF             RACTCADR
                TCF             PACT2
                
PTBAD           CAF             OCT1107                 # SET ADDITIONAL FAILURE TO SHOW PHASE
                TS              SFAIL                   # TABLE DISAGREEMENT (WILL BE DISPLAYED
                TCF             DOFSTART                # IN R2).
                
OCT1107         OCT             1107                    # ADDITIONAL ALARM CODE.

DORSTART        CAF             IFAILINH                # LEAVE IMUFAILURE INHIBITS INTACT ON
                MASK            IMODES30                # RESTART, RESETTING ALL FAILURE CODES.
                AD              IM30INIR
                TS              IMODES30
## Page 155
                TCF             ENDRSTRT
## Page 156
# INITIALIZATION COMMON TO BOTH FRESH START AND RESTART.

STARTSUB        XCH             Q
                TS              BUF                     # EXEC TEMPS ARE AVAILABLE TO US.
                
                CAF             ZERO                    # ZERO OUTBITS WITHIN 3MS OF RESTART.
                EXTEND
                WRITE           12
                EXTEND
                WRITE           14
                EXTEND
                WRITE           11
                CAF             PRIO34                  # ENABLE INTERRUPTS.
                EXTEND
                WRITE           13
                
                CAF             POSMAX                  # T3 AND T4 OVERFLOW AS SOON AS POSSIBLE.
                TS              TIME5                   # SO DOES T5.
                TS              TIME3                   #   (POSMAX IS PSEUDO INTERRUPT SIGNAL IN
                TS              TIME4                   #   CASE RUPT SIGNALLED BEFORE TS TIME3).
                
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
## Page 157
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
                TS              LMPCMD
                TS              CADRSTOR
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
## Page 158
                TS              DSPLIST         +2
                
                TS              MARKSTAT
                TS              EXTVBACT                # MAKE EXTENDED VERBS AVAILABLE
                TS              IMUCADR
                TS              OPTCADR
                TS              RADCADR
                TS              LGYRO
                TS              DSRUPTSW
                CAF             NOUTCON
                TS              NOUT
                
                CS              ONE                     # NO RADAR DESIGNATION.
                TS              SAMPLIM                 # NO RADAR RUPTS EXPECTED.
                
                CAF             T4LINIT
                TS              T4LOC
                
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
                EBANK=          DNTMGOTO
                
                CAF             LDNTMGO                 # SET UP TM PROGRAM.
                TS              EBANK
                
                CAF             LDNPHAS1
                TS              DNTMGOTO
                
                CAF             NOMTMLST                # SET UP NOMINAL DOWNLINK LIST.
                TS              DNLSTADR
                
                TC              BUF
                
IFAILINH        OCT             35                      # ISS FAILURE INHIBIT BITS.
LDNPHAS1        GENADR          DNPHASE1
LDNTMGO         ECADR           DNTMGOTO
NOMTMLST        GENADR          NOMDNLST
LESCHK          GENADR          SELFCHK
T4LINIT         ADRES           DSKYRSET
## Page 159
VAC1ADRC        ADRES           VAC1USE
LTHVACA         DEC             44

STARTEB         ECADR           LST1
NUMGRPS         EQUALS          FIVE                    # SIX GROUPS CURRENTLY.

# WHERE TO GO ON RESTART IF GROUP ACTIVE:

RACTCADR        CADR            10000                   # AVAILABLE FOR USE-NEXT ONE USED
                CADR            OPTMSTRT                #  RESTARTS DURING OPTM ALIGN CALIBRATION
                CADR            10000
                CADR            10000
                CADR            10000
                CADR            10000

# WHERE TO GO ON RESTART IF TERMINATE REQUESTED.

RTERMCAD        CADR            10000
                CADR            10000
                CADR            10000
                CADR            10000
                CADR            10000
                CADR            10000

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
                OCT             0
                OCT             0

OCT04012        OCTAL           04012                   # INITIAL VALUE OF DAPBOOLS
ENDFRESS        EQUALS
