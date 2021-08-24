### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P20-P25.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.
##              2021-05-30 ABS  Replaced use of various descriptive *BIT symbols
##                              with less descriptive BIT* symbols to match
##                              Luminary 69.

## Sundance 302

# RENDEZVOUS NAVIGATION PROGRAM 20
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY  P. VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   THE PURPOSE OF THIS PROGRAM IS TO CONTROL THE RENDEZVOUS RADAR FROM
# STARTUP THROUGH ACQUISITION AND LOCKON TO THE CSM AND TO UPDATE EITHER
# THE LM OR CSM STATE VECTOR (AS SPECIFIED BY THE ASTRONAUT BY DSKY ENTRY)
# ON THE BASIS OF THE RR TRACKING DATA.
# CALLING SEQUENCE -
#
# ASTRONAUT REQUEST THROUGH DSKY V37E20E
# SUBROUTINES CALLED
#   R02BOTH (IMU STATUS CHECK)               FLAGUP
#   GOFLASH (PINBALL-DISPLAY)                FLAGDOWN
#   R23LEM  (MANUAL ACQUISITION)             BANKCALL
#   LS201   (LOS DETERMINATION)              TASKOVER
#   LS202   (RANGE LIMIT TEST)
#   R61LEM  (PREFERRED TRACKING ATTITUDE)
#   R21LEM  (RR DESIGNATE)                   ENDOFJOB
#   R22LEM  (DATA READ)                      GOPERF1
#   R31LEM  (RENDEZVOUS PARAMETER DISPLAY)
#   PRIOLARM (PRIORITY DISPLAY)
# NORMAL EXIT MODES-
#   P20 MAY BE TERMINATED IN TWO WAYS-ASTRONAUT SELECTION OF IDLING
# PROGRAM (P00) BY KEYING V37E00E OR BY KEYING IN V56E
# ALARM OR ABORT EXIT MODES-
#   RANGE GREATER THAN 400 NM DISPLAY
# OUTPUT
#   TRKMKCNT = NO OF RENDEZVOUS TRACKING MARKS TAKEN (COUNTER)
# ERASABLE INITIALIZATION REQUIRED
# FLAGS SET + RESET
#   SRCHOPT,RNDVZFLG,ACMODFLG,VEHUPFLG,UPDATFLG,TRACKFLG,
# DEBRIS
#   CENTRALS-A,Q,L
                SBANK=          LOWSUPER                # FOR LOW 2CADR'S.

                BANK            33
                SETLOC          P20S
                BANK

                EBANK=          LOSCOUNT
                COUNT*          $$/P20
PROG20          TC              2PHSCHNG
                OCT             4
                OCT             05022
                OCT             26000                   # PRIORITY 26
                
                INHINT
                CS              SURFFBIT
                MASK            FLAGWRD8
                TS              FLAGWRD8
                RELINT

                TC              DOWNFLAG                # RESET VEHUPFLG- LM STATE VECTOR
                ADRES           VEHUPFLG                # TO BE UPDATED
PROG20A         TC              BANKCALL
                CADR            R02BOTH
                TC              UPFLAG
                ADRES           UPDATFLG                # SET UPDATE FLAG
                TC              UPFLAG
                ADRES           TRACKFLG                # SET TRACK FLAG
                TC              UPFLAG
                ADRES           RNDVZFLG                # SET RENDEZVOUS FLAG
                TC              DOWNFLAG
                ADRES           SRCHOPTN                # INSURE SEARCH OPTION OFF

                TC              DOWNFLAG                # ALSO MANUAL ACQUISITION FLAG RESET
                ADRES           ACMODFLG
                TC              DOWNFLAG                # TURN OFF R04FLAG TO ENSURE GETTING
                ADRES           R04FLAG                 # ALARM 521 IF CANT READ RADAR
                TC              DOWNFLAG                # ENSURE R25 GIMBAL MONITOR IS ENABLED
                ADRES           NORRMON                 # (RESET NORRMON FLAG)
                TC              INTPRET
                CALL            
                                UPPSV
                EXIT
P20LEM1         TC              PHASCHNG
                OCT             04022
                CAF             ZERO                    # ZERO MARK COUNTER
                TS              MARKCTR
                TC              INTPRET                 # LOS DETERMINATION ROUTINE
                RTB
                                LOADTIME
                STCALL          TDEC1
                                LPS20.1
                CALL
                                LPS20.2                 # TEST RANGE R/UTINE
                EXIT
                INDEX           MPAC
                TC              +1
                TC              P20LEMA                 # NORMAL RETURN WITHIN 400 N M
526ALARM        CAF             ALRM526                 # ERROR EXIT - RANGE > 400 N. MI.
                TC              BANKCALL
                CADR            PRIOLARM
                TC              GOTOV56                 # TERMINATE EXITS P20 VIA V56 CODING
                TC              -4                      # PROC (ILLEGAL
                TC              P20LEM1                 # ENTER RECYCLE
                TC              ENDOFJOB


P20LEMA         TC              PHASCHNG
                OCT             04022
                TC              LUNSFCHK                # CHECK LUNAR SURFACE FLAG (P22 FLAG)
                TC              P20LEMB
                TC              BANKCALL
                CADR            R61LEM                  # PREFERRED TRACKING ATTITUDE ROUTINE
P20LEMB         TC              PHASCHNG
                OCT             05022                   # RESTART AT PRIORITY 10 TO ALLOW V37
                OCT             10000                   # REQUESTED PROGRAM TO RUN FIRST
                CAF             PRIO26                  # RESTORE PRIORITY 26
                TC              PRIOCHNG
P20LEMB7        CAF             BIT2                    # IS RR AUTO MODE DISCRETE PRESENT
                EXTEND
                RAND            CHAN33

                EXTEND
                BZF             P20LEMB3                # YES - DO AUTOMATIC ACQUISITION (R21)

P20LEMB5        CS              OCT24                   # RADAR NOT IN AUTO CHECK IF
                AD              MODREG                  # MAJOR MODE IS 20
                EXTEND
                BZF             P20LEMB6                # BRANCH - YES-OK TO DO PLEASE PERFORM

                CA              FLAGWRD1                # IS THE TRACK FLAG SET
                MASK            TRACKBIT
                EXTEND
                BZF             P20LMWT1                #  BRANCH - NO - WAIT FOR IT TO BE SET
                CAF             ALRM514                 # TRACK FLAG SET-FLASH PRIORITY ALARM 514-
                TC              BANKCALL                # RADAR GOES OUT OF AUTO MODE WHILE IN USE
                CADR            PRIOLARM
                TC              GOTOV56                 # TERMINATE EXITS VIA V56
                TC              P20LEMB7                # PROCEED AND ENTER BOTH GO BACK
                TC              P20LEMB7                # TO CHECK AUTO MODE AGAIN
                TC              ENDOFJOB
P20LEMB6        CAF             OCT201                  # REQUEST RR AUTO MODE SELECTION
                TC              BANKCALL
                CADR            GOPERF1
                TC              GOTOV56                 # TERMINATE EXITS P20 VIA V56 CODING
                TC              P20LEMB                 # PROCEED CHECKS AUTO MODE DISCRETE AGAIN
                TC              LUNSFCHK                # ENTER INDICATES MANUAL ACQUISITION (R23)
                TC              P20LEMB2                # YES - R23 NOT ALLOWED-TURN ON OPR ERROR
                TC              R23LEM                  # NO - DO MANUAL ACQUISITION


P20LEMB1        TC              UPFLAG                  # RETURN FROM R23 - LOCKON ACHIEVED
                ADRES           ACMODFLG                # SET MANUAL FLAG AND GO BACK TO CHECK
                TC              P20LEMB                 # RR AUTO MODE


P20LEMB2        TC              FALTON                  # TURNS ON OPERATOR ERROR LIGHT ON DSKY
                TC              P20LEMB                 # AND GOES BACK TO CHECK AUTO MODE


P20LEMB3        CS              RADMODES                # ARE RR CDUS BEING ZEROED
                MASK            BIT13                   # (BIT 13 RADMODES EQUAL ONE)
                EXTEND
                BZF             P20LEMB4                # BRANCH - YES - WAIT
                CAF             BIT13-14                # IS SEARCH OR MANUAL ACQUISITION FLAG SET
                MASK            FLAGWRD2
                EXTEND
                BZF             P20LEMC                 # ZERO MEANS AUTOMATIC RR ACQUISTION
                TC              DOWNFLAG                # RESET TO AUTO MODE
                ADRES           SRCHOPTN
                TC              DOWNFLAG

                ADRES           ACMODFLG
                TC              P20LEMWT                # WAIT 2.5 SECONDS THEN GO TO RR DATA READ


P20LEMB4        CAF             250DEC
                TC              BANKCALL                # WAIT 2.5 SECONDS WHILE RR CDUS ARE BEING
                CADR            DELAYJOB                # ZEROED-THEN GO BACK AND CHECK AGAIN
                TC              P20LEMB3

P20LEMC         TC              PHASCHNG
                OCT             04022
                CAE             FLAGWRD0                # IS THE RENDEZVOUS FLAG SET
                MASK            RNDVZBIT
                EXTEND
                BZF             ENDOFJOB                # NO - EXIT P20
                CAE             FLAGWRD1                # IS TRACK FLAG SET  (BIT 5 FLAGWORD 1)
                MASK            TRACKBIT
                EXTEND
                BZF             P20LEMD                 # BRANCH-TRACK FLAG NOT ON-WAIT 15 SECONDS
P20LEMF         TC              UPFLAG
                ADRES           LOSCMFLG
                TC              R21LEM


P20LEMWT        CAF             250DEC
                INHINT
                TC              TWIDDLE                 # USE INSTEAD OF WAITLIST SINCE SAME BANK
                ADRES           P20LEMC1                # WAIT 2.5 SECONDS
                CAE             FLAGWRD1                # IS TRACK FLAG SET
                MASK            TRACKBIT
                EXTEND
                BZF             ENDOFJOB                # NO-EXIT WITHOUT DOING 2.7 PHASE CHANGE
P20LMWT1        TC              PHASCHNG
                OCT             40072
                TC              ENDOFJOB


P20LEMC1        CAE             FLAGWRD0                # IS RENDEZVOUS FLAG SET

                MASK            RNDVZBIT
                EXTEND
                BZF             TASKOVER                # NO - EXIT P20/R22
                CAE             FLAGWRD1                # IS TRACK FLAG SET
                MASK            TRACKBIT
                EXTEND
                BZF             P20LEMC2                # NO-DONT SCHEDULE R22 JOB
                CAF             PRIO26                  # YES-SCHEDULE R22 JOB (RR DATA READ)
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           R22LEM
                TC              TASKOVER


P20LEMC2        TC              FIXDELAY                # TRACK FLAG NOT SET ,WAIT 15 SECONDS
                DEC             1500                    # AND CHECK AGAIN

                TC              P20LEMC1

P20LEMD         CAF             1500DEC
                TC              TWIDDLE                 # WAITLIST FOR 15 SECONDS
                ADRES           P20LEMD1
                TC              ENDOFJOB


P20LEMD1        CAE             FLAGWRD1                # IS TRACK FLAG SET
                MASK            TRACKBIT
                CCS             A
                TCF             P20LEMD2                # YES-SCHEDULE DESIGNATE JOB
                TC              FIXDELAY                # NO-WAIT 15 SECONDS
                DEC             1500
                TC              P20LEMD1


P20LEMD2        CAF             PRIO26                  # SCHEDULE JOB TO DO R21
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           P20LEMF                 # START AT PERM. MEMORY INTEGRATION
                TC              TASKOVER


250DEC          DEC             250
ALRM526         OCT             00526
OCT201          OCT             00201
ALRM514         OCT             514
MAXTRIES        DEC             60

UPPSV           STQ             CALL                    # UPDATES PERMANENT STATE VECTORS
                                LS21X                   #  TO PRESENT TIME
                                INTSTALL
                CALL
                                SETIFLGS
                BOF             SET                     # IF W-MATRIX INVALID,DONT INTEGRATE IT
                                RENDWFLG
                                UPPSV1
                                DIM0FLAG                # SET DIMOFLAG TO INTEGRATE W-MATRIX
                BON             SET
                                SURFFLAG                # IF ON LUNAR SURFACE W IS 6X6
                                UPPSV5
                                D6OR9FLG                # OTHERWISE 9X9
UPPSV5          BOF
                                VEHUPFLG
                                UPPSV3
UPPSV1          SET             RTB                     # CSM STATE BEING CORRECTED
                                VINTFLAG
                                LOADTIME
                STCALL          TDEC1                   # INTEGRATE CSM STATE WITH W-MATRIX
                                INTEGRV
                CALL                                    # GROUP 2 PHASE CHANGE
                                GRP2PC                  # TO PROTECT INTEGRATION
                CALL
                                INTSTALL
                DLOAD           CLEAR                   # GET TETCSM TO STORE IN TDEC FOR LM INT.
                                TETCSM
                                VINTFLAG
UPPSV4          CALL                                    # INTEGRATE OTHER VEHICLE
                                SETIFLGS                #  WITHOUT W-MATRIX
                STCALL          TDEC1
                                INTEGRV
                GOTO
                                LS21X


UPPSV3          CLEAR           RTB
                                VINTFLAG
                                LOADTIME
                STCALL          TDEC1                   # INTEGRATE LM STATE WITH W-MATRIX
                                INTEGRV
                CALL
                                GRP2PC
                CALL
                                INTSTALL
                SET             DLOAD
                                VINTFLAG

                                TETLEM                  # GET TETLEM TO STORE IN TDEC FOR CSM INT.
                GOTO
                                UPPSV4


                EBANK=          LOSCOUNT
                COUNT*          $$/P22

PROG22          TC              2PHSCHNG
                OCT             4
                OCT             05022
                OCT             06000

                INHINT
                CS              FLAGWRD8
                MASK            SURFFBIT
                ADS             FLAGWRD8
                RELINT

                TC              UPFLAG
                ADRES           VEHUPFLG

                TC              PROG20A

# PROGRAM DESCRIPTION
# PREFERRED TRACKING ATTITUDE PROGRAM P25
# MOD NO - 3
# BY  P. VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   THE PURPOSE OF THIS PROGRAM IS TO COMPUTE THE PREFERRED TRACKING
# ATTITUDE OF THE LM TO CONTINUOUSLY POINT THE LM TRACKING BEACON AT THE
# CSM AND TO PERFORM THE MANEUVER TO THE PREFERRED TRACKING ATTITUDE AND
# CONTINUOUSLY MAINTAIN THIS ATTITUDE WITHIN PRESCRIBED LIMITS
# CALLING SEQUENCE -
#   ASTRONAUT REQUEST THROUGH DSKY V37E25E
# SUBROUTINES CALLED -
#   BANKCALL                      FLAGUP
#   R02BOTH  (IMU STATUS CHECK)   ENDOFJOB
#   R61LEM   (PREF TRK ATT ROUT)  WAITLIST
#   TASKOVER                      FINDVAC
# NORMAL EXIT MODES  -
#   P25 MAY BE TERMINATED IN TWO WAYS-ASTRONAUT SELECTION OF IDLING
# PROGRAM(P00) BY KEYING V37E00E OR BY KEYING IN V56E
# ALARM OR ABORT EXIT MODES -
#   NONE
# OUTPUT
# ERASABLE INITIALIZATION REQUIRED
# FLAGS SET + RESET
#   TRACKFLG,P25FLAG
# DEBRIS
#   NONE
                EBANK=          LOSCOUNT
                COUNT*          $$/P25
PROG25          TC              2PHSCHNG
                OCT             4                       # MAKE GROUP 4 INACTIVE (VERB 37)
                OCT             05022
                OCT             26000                   # PRIORITY 26

                TC              BANKCALL
                CADR            R02BOTH                 # IMU STATUS CHECK
                TC              UPFLAG
                ADRES           TRACKFLG                # SET TRACK FLAG
                TC              UPFLAG
                ADRES           P25FLAG                 # SET P25FLAG
                TC              BANKCALL
                CADR            R61LEM
P25LEM1         CAF             P25FLBIT
                MASK            STATE                   # IS P25FLAG SET
                EXTEND
                BZF             ENDOFJOB
                CAF             TRACKBIT                # IS TRACKFLAG SET?
                MASK            STATE           +1
                EXTEND
                BZF             P25LMWT1                # NO-SKIP PHASE CHANGE AND WAIT 1 MINUTE
                TC              INTPRET
                RTB
                                LOADTIME
                STCALL          TDEC1
                                LPS20.1
                CALL
                                CDUTRIG
                VLOAD           CALL
                                RRTARGET
                                *SMNB*
                DLOAD           ACOS
                                MPAC            +5
                DSU             BMN
                                30DEGS
                                P25OK
                EXIT

                TC              P25LEM1         -2      # THEN GO CHECK FLAGS
P25LEMWT        TC              PHASCHNG
                OCT             00112
P25LMWT1        CAF             60SCNDS
                INHINT
                TC              TWIDDLE                 # WAIT ONE MINUTE THEN CHECK AGAIN
                ADRES           P25LEM2
                TC              ENDOFJOB
P25LEM2         CAF             PRIO14
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           P25LEM1
                TC              TASKOVER
60SCNDS         DEC             6000
30DEGS          2DEC            .083333333
P25OK           EXIT
                TC              P25LEMWT

# DATA READ ROUTINE 22 (LEM)
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY P VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   TO PROCESS AUTOMATIC RR MARK DATA TO UPDATE THE STATE VECTOR OF EITHER
# LM OR CSM AS DEFINED IN THE RENDEZVOUS NAVIGATION PROGRAM (P20)
# CALLING SEQUENCE -
#          TC     BANKCALL
#          CADR   R22LEM
# SUBROUTINES CALLED -
#   LSR22.1           GOFLASH        WAITLIST
#   LSR22.2           PRIOLARM       BANKCALL
#   LSR22.3           R61LEM
# NORMAL EXIT MODES-
#   R22 WILL CONTINUE TO RECYCLE,UPDATING STATE VECTORS WITH RADAR DATA
# UNTIL P20 CEASES TO OPERATE (RENDEZVOUS FLAG SET TO ZERO) AT WHICH TIME
# R22 WILL TERMINATE SELF.
# ALARM OR ABORT EXIT MODES-
#   PRIORITY ALARM
# PRIORITY ALARM 525 LOS NOT WITHIN 3 DEGREE LIMIT
# OUTPUT
#   SEE OUTPUT FROM LSR22.3
# ERASABLE INITIALIZATION REQUIRED
#   SEE LSR22.1,LSR22.2,LSR22.3
# FLAGS SET + RESET
#   NOANGFLG
# DEBRIS
#   SEE LSR22.1,LSR22.2,LSR22.3
                EBANK=          LRS22.1X
                COUNT*          $$/R22
R22LEM          TC              PHASCHNG
                OCT             00152
                CAF             RNDVZBIT                # IS RENDESVOUS FLAG SET?
                MASK            STATE
                EXTEND
                BZF             ENDOFJOB                # NO-EXIT R22 AND P20
                CAF             TRACKBIT                # IS TRACKFLAG SET?
                MASK            STATE           +1
                EXTEND
                BZF             R22WAIT                 # NO WAIT
R22LEM12        CAF             BIT14                   # IS RR AUTO TRACK ENABLE DISCRETE STILL
                EXTEND                                  # ON (A MONITOR REPOSITION BY R25 CLEARSIT
                RAND            CHAN12
                EXTEND
                BZF             P20LEMA                 # NO - RETURN TO P20
                CAF             BIT2                    # YES
                EXTEND                                  # IS RR AUTO MODE DISCRETE PRESENT
                RAND            CHAN33

                EXTEND
                BZF             +2                      # YES CONTINUE
                TC              P20LEMB5                # NO - SET IT
                CS              RADMODES                # ARE RR CDUS BEING ZEROED
                MASK            BIT13                   # (BIT 13 RADMODES EQUAL ONE)
                EXTEND
                BZF             R22WAIT                 # CDUS BEING ZEROED
                TC              BANKCALL                # YES READ DATA + CALCULATE LOS
                CADR            LRS22.1                 # DATA READ SUBROUTINE
                INDEX           MPAC
                TC              +1
                TC              R22LEM2                 # NORMAL RETURN (GOOD DATA)
                TC              P20LEMC                 # COULD NOT READ RADAR-TRY TO REDESIGNATE
                CAF             ALRM525                 # RR LOS NOT WITHIN 3 DEGREES (ALARM)
                TC              BANKCALL
                CADR            PRIOLARM
                TC              GOTOV56                 # TERMINATE EXITS P20 VIA V56 CODING
                TC              R22LEM1                 # PROC (DISPLAY DELTA THETA)
                TC              -5                      # ENTER (ILLEGAL OPTION)
                TC              ENDOFJOB


R22LEM1         TC              PHASCHNG
                OCT             04022
                CAF             V06N05                  # DISPLAY DELTA THETA
                TC              BANKCALL
                CADR            PRIODSP
                TC              GOTOV56                 # TERMINATE EXITS P20 VIA V56 CODING
                TC              R22LEM2                 # PROC (OK CONTINUE)
                TC              P20LEMC                 # ENTER(RECYCLE)
R22LEM2         TC              PHASCHNG
                OCT             04022
                TC              LUNSFCHK                # CHECK IF ON LUNAR SURFACE (P22FLAG SET)
                TC              R22LEM3                 # YES-BYPASS FLAG CHECKS AND LRS22.2
                CA              FLAGWRD1                # IS TRACK FLAG SET
                MASK            TRACKBIT
                EXTEND
                BZF             R22WAIT                 # NO - WAIT
                TC              BANKCALL                # YES
                CADR            LRS22.2                 # CHECKS RR BORESIGHT WITHIN 30 DEG OF +Z
                INDEX           MPAC
                TC              +1
                TC              R22LEM3                 # NORMAL RETURN(LOS WITHIN 30 OF Z-AXIS)
                TC              BANKCALL
                CADR            R61LEM
                TC              R22WAIT                 # NOT WITHIN 30 DEG OF Z-AXIS
R22LEM3         CS              FLAGWRD1                # SHOULD WE BYPASS STATE VECTOR UPDATE
                MASK            NOUPFBIT                # (IS NO UPDATE FLAG SET?)

                EXTEND
                BZF             R22LEM42                # BRANCH-YES
                CA              FLAGWRD1                # IS UPDATE FLAG SET
                MASK            UPDATBIT
                EXTEND
                BZF             R22WAIT                 # UPDATE FLAG NOT SET
                CAF             PRIO26                  # INSURE HIGH PRIO IN RESTART
                TS              PHSPRDT2

                TC              INTPRET
                GOTO
                                LSR22.3
R22LEM93        EXIT                                    # NORMAL EXIT FROM LSR22.3
                TCF             R22LEM44
R22LEM96        EXIT
                CAF             ZERO                    # SET N49FLAG = ZERO TO INDICATE
                TS              N49FLAG                 # V06 N49 DISPLAY HASNT BEEN ANSWERED
                TC              PHASCHNG
                OCT             04022                   # TO PROTECT DISPLAY
                CAF             PRIO26                  # PROTECT DISPLAY
                TC              PRIOCHNG

                CAF             V06N49NB
                TC              BANKCALL                # EXCESSIVE STATE VECTOR UPDATE - FLASH
                CADR            PRIODSPR                # VERB 06 NOUN 49 R1=DELTA R, R2=DELTA V
                TC              N49TERM                 # TERMINATE - EXIT R22 AND P20
                TC              N49PROC                 # PROCEED - N49FLAG = -1
                TC              N49RECYC                # RECYCLE - N49FLAG = + VALUE
                CAF             PRIO24
                TC              PRIOCHNG
                TC              INTPRET
                STORE           MPAC
                SLOAD           BZE                     # LOOP TO CHECK IF FLAG
                                N49FLAG
                                -3                      # SETTING CHANGED-BRANCH - NO
                BMN             CALL
                                R22LEM7                 # PROCEED
                                GRP2PC                  # PHASE CHANGE AND
                GOTO                                    # GO TO INCORPORATE DATA.
                                ASTOK
                EXIT                                    # DISPLAY ANSWERED BY RECYCLE
R22LEM44        INCR            MARKCTR                 # INCREMENT COUNT OF MARKS INCORPORATED.
R22LEM42        TC              LUNSFCHK                # CHECK IF ON LUNAR SURFACE (P22FLAG SET)
                TC              R22LEM46                # YES - WAIT 2 SECONDS
                
R22LEM45        CAF             45SECNDS
                TC              P20LEMWT +1

R22LEM46        CAF             30SECNDS
                TC              P20LEMWT +1

R22WAIT         CAF             1500DEC
                TC              P20LEMWT        +1

N49TERM         CS              ONE
                TS              N49FLAG
                TC              GOTOV56

N49PROC         CAF             ONE
                TS              N49FLAG
                TC              ENDOFJOB

N49RECYC        CS              ONE
                TS              N49FLAG
                TC              R22LEM

R22LEM7         EXIT
                TC              ENDOFJOB

R22RSTRT        TC              PHASCHNG                # IF A RESTART OCCURS WHILE READING RADAR
                OCT             00152                   # COME HERE TO TAKE A RANGE-RATE READING
                TC              BANKCALL                # WHICH ISNT USED TO PREVENT TAKING A BAD
                CADR            RRRDOT                  # READING AND TRYING TO INCORPORATE THE
                TC              BANKCALL                # BAD DATA
                CADR            RADSTALL                # WAIT FOR READ COMPLETE
                TC              P20LEMC                 # COULD NOT READ RADAR - TRY TO REDESIGNATE
                TC              R22LEM                  # READ SUCCESSFUL - CONTINUE AT R22

ALRM525         OCT             00525
V06N05          VN              00605
V06N49NB        VN              00649
1500DEC         DEC             1500
80DEC           DEC             80
45SECNDS        DEC             4500
30SECNDS        DEC             3000
# LUNSFCHK-CLOSED SUBROUTINE TO CHECK IF ON LUNAR SURFACE (P22FLAG)
#          RETURNS TO CALLER +1 IF P22FLAG SET
#                  TO CALLER +2 IF P22FLAG NOT SET


                COUNT*          $$/P22
LUNSFCHK        CS              FLAGWRD8                # CHECK IF ON LUNAR SURFACE
                MASK            SURFFBIT                # IS SURFFLAG SET?
                EXTEND                                  # BRANCH - P22FLAG SET
                BZF             +2
                INCR            Q                       # NOT SET
                TC              Q                       # RETURN

# RR DESIGNATE ROUTINE (R21LEM)
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY P VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   TO POINT THE RENDEZVOUS RADAR AT THE CSM UNTIL AUTOMATIC ACQUISITION
# OF THE CSM IS ACCOMPLISHED BY THE RADAR. ROUTINE IS CALLED BY P20.
# CALLING SEQUENCE -
#          TC     BANKCALL
#          CADR   R21LEM
# SUBROUTINES CALLED -
#   FINDVAC        FLAGUP           ENDOFJOB        PRIOLARM
#   NOVAC          INTPRET          LPS20.1         PHASCHNG
#   WAITLIST       JOBSLEEP         JOBWAKE         FLAGDOWN
#   TASKOVER       BANKCALL         RADSTALL        RRDESSM
# NORMAL EXIT MODES
#   WHEN LOCK-ON IS ACHIEVED,BRANCH WILL BE TO P20 WHERE R22 (DATA READ
# WILL BE SELECTED OR A NEED FOR A MANEUVER(BRANCH TO P20LEMA)
# ALARM OR ABORT EXIT MODES-
#   PRIORITY ALARM 503 WHEN LOCK-ON HASN:T BEEN ACHIEVED AFTER 30SECS -
# THIS REQUIRES ASTRONAUT INTERFACE- SELECTION OF SEARCH OPTION OF
# ACQUISITION
# OUTPUT
#   SEE LPS20.1,RRDESSM
# ERASABLE INITIALIZATION REQUIRED
#   RRTARGET,RADMODES ARE USED BY LPS20.1 AND RRDESSM
# FLAGS SET + RESET
#   LOSCMFLG      LOKONSW
# DEBRIS
#   SEE LPS20.1,RRDESSM
                EBANK=          LOSCOUNT
                COUNT*          $$/R21
R21LEM          CAF             MAXTRIES                # ALLOW 60 PASSES (APPROX 45 SECS.) TO
                TS              DESCOUNT                # DESIGNATE AND LOCKON
                CS              BIT14                   # REMOVE RR SELF TRACK ENABLE
                EXTEND
                WAND            CHAN12
R21LEM2         CAF             FOUR
                TS              LOSCOUNT
                TC              LUNSFCHK
                TC              +2
                TC              R21LEM1
                CS              RADMODES
                MASK            BIT12
                EXTEND
                BZF             R21LEM1
                CAF             BIT14
                INHINT
                ADS             RADMODES
                CAF             TWO
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           REMODE
                RELINT
                TC              BANKCALL
                CADR            RADSTALL
                TC              +1
R21LEM1         TC              INTPRET
                RTB
                                LOADTIME
                STCALL          TDEC1                   # LOS DETERMINATION ROUTINE
                                LPS20.1
                EXIT
R21LEM3         TC              UPFLAG                  # SET LOKONSW TO RADAR-ON DESIRED
                ADRES           LOKONSW
                TC              INTPRET
                CALL                                    # INPUT (RRTARGET UPDATED BY LPS20.1)
                                RRDESSM                 # DESIGNATE ROUTINE
                EXIT
                TC              R21LEM4                 # LOS NOT IN MODE 2 COVERAGE
                                                        # ON LUNAR SURFACE
                TC              P20LEMA                 # VEHICLE MANEUVER REQUIRED.
                TC              BANKCALL                # NO VEHICLE MANEUVER REQUIRED
                CADR            RADSTALL                # WAIT FOR DESIGNATE COMPLETE - LOCKON OR
                TC              +2                      # BADEND-LOCKON NOT ACHIEVED IN 60 TRIES
                TC              R21END                  # EXIT ROUTINE RETURN TO P20 (LOCK-ON)
R21-503         CAF             ALRM503                 # ISSUE ALARM 503
                TC              BANKCALL
                CADR            PRIOLARM
                TC              GOTOV56                 # TERMINATE EXITS P20 VIA V56 CODING
                TC              R21SRCH                 # PROC
                TC              R21LEM
                TC              ENDOFJOB
R21END          TC              DOWNFLAG
                ADRES           LOSCMFLG                # RESET LOSCMFLG
                TC              P20LEMWT                # EXIT R21 TO PERFORM DATA READ
R21SRCH         TC              PHASCHNG
                OCT             04022
                TC              R24LEM                  # SEARCH ROUTINE
ALRM503         OCT             00503
ALRM527         OCT             527


R21LEM4         CAF             ALRM527                 # ALARM 527-LOS NOT IN MODE 2 COVERAGE
                TC              BANKCALL                # ON LUNAR SURFACE
                CADR            PRIOLARM

                TC              GOTOV56                 # TERMINATE EXITS P20 VIA V56 CODING
                TC              R21LEM1
                TC              -5                      # ENTER
                TC              ENDOFJOB

# MANUAL ACQUISITION ROUTINE R23LEM
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY P VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   TO ACQUIRE THE CSM BY MANUAL OPERATION OF THE RENDEZVOUS RADAR
# CALLING SEQUENCE -
#          TC     R23LEM
# SUBROUTINES CALLED
#   BANKCALL        R61LEM
#   SETMINDB        GOPERF1
# NORMAL EXIT MODES -
#   IN RESPONSE TO THE GOPERF1 ,SELECTION OF ENTER WILL RECYCLE R23
#                              ,SELECTION OF PROC  WILL CONTINUE R23
#                              ,SELECTION OF TERM  WILL TERMINATE R23 +P20
# ALARM OR ABORT EXIT MODES -
#   SEE NORMAL EXIT MODES ABOVE
# OUTPUT
#   N.A.
# ERASABLE INITIALIZATION REQUIRED-
#   ACMODFLG MUST BE SET TO 1 (MANUAL MODE)
                EBANK=          GENRET
                COUNT*          $$/R23
R23LEM          TC              UPFLAG                  # SET NO ANGLE MONITOR FLAG
                ADRES           NORRMON
                INHINT
                TC              IBNKCALL                # SELECT MINIMUM DEADBAND
                CADR            SETMINDB
                RELINT
R23LEM1         CAF             BIT14                   # ENABLE TRACKER
                EXTEND
                WOR             CHAN12
                CAF             OCT205
                TC              BANKCALL
                CADR            GOPERF1
                TC              R23LEM2                 # TERMINATE
                TC              R23LEM11                # PROCEDE
                TC              R23LEM3                 # ENTER- DO ANOTHER MANUVER
R23LEM11        INHINT
                TC              IBNKCALL                # RESTORE DEADBAND TO
                CADR            RESTORDB                # ASTRONAUT SELECTED VALUE
                TC              RRLIMCHK                # YES - CHECK IF ANTENNA IS WITHIN LIMITS
                ADRES           CDUT
                TC              OUTOFLIM                # NOT WITHIN LIMITS
                RELINT
                TC              DOWNFLAG                # CLEAR NO ANGLE MONITOR FLAG
                ADRES           NORRMON
                TC              P20LEMB1                # RADAR IS LOCKED ON CONTINUE IN P20
OUTOFLIM        RELINT

                CAF             OCT501PV
                TC              BANKCALL                # ISSUE ALARM - RR ANTENNA NOT WITHIN
                CADR            PRIOLARM                # LIMITS
                TC              R23LEM2                 # TERMINATE - EXIT R23 TO R00 (GO TO POOH)
                TC              OUTOFLIM        +1      # PROCEED ILLEGAL
                TC              R23LEM3                 # RECYCLE- DO ANOTHER MANUVER
                TC              ENDOFJOB
R23LEM2         TC              DOWNFLAG                # CLEAR NO ANGLE MONITOR FLAG
                ADRES           NORRMON
                TC              GOTOV56                 # AND EXIT VIA V56
R23LEM3         TC              BANKCALL
                CADR            R61LEM
                TC              R23LEM1

OCT501PV        OCT             501
OCT205          OCT             205

# SEARCH ROUTINE R24LEM
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY  P. VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   TO ACQUIRE THE CSM BY A SEARCH PATTERN WHEN THE RENDEZVOUS RADAR HAS
# FAILED TO ACQUIRE THE CSM IN THE AUTOMATIC TRACKING MODE AND TO ALLOW
# THE ASTRONAUT TO CONFIRM THAT REACQUISITION HAS NOT BEEN BY SIDELOBE.
# CALLING SEQUENCE
#          CAF    PRIONN
#          TC     FINDVAC
#          EBANK= DATAGOOD
#          2CADR  R24LEM
# SUBROUTINES CALLED
#   FLAGUP        FLAGDOWN      BANKCALL
#   R61LEM        GOFLASHR      FINDVAC
#   ENDOFJOB      NOVAC         LSR24.1
# NORMAL EXIT MODES-
#   ASTRONAUT RESPONSE TO DISPLAY OF OMEGA AND DATAGOOD.HE CAN EITHER
# REJECT BY TERMINATING (SEARCH OPTION AND RESELECTING P20) OR ACCEPT BY
# PROCEEDING (EXIT ROUTINE AND RETURN TO AUTO MODE IN P20)
# ALARM OR ABORT EXIT MODES-
#   SEE NORMAL EXIT MODES ABOVE
# OUTPUT -
#   SEE OUTPUT FROM LSR24.1 + R61LEM
# ERASABLE INITIALIZATION REQUIRED
#   SEE INPUT FOR LSR24.1
# FLAGS SET + RESET
#   SRCHOPT,ACMODFLG
                EBANK=          DATAGOOD
                COUNT*          $$/R24
R24LEM          TC              UPFLAG
                ADRES           SRCHOPTN                # SET SRCHOPT FLAG
R24LEM1         CAF             ZERO
                TS              DATAGOOD                # ZERO OUT DATA INDICATOR
                TS              OMEGAD                  # ZERO OMEGA DISPLAY REGS
                TS              OMEGAD          +1      # ZERO OMEGA DISPLAY REGS
R24LEM2         TC              PHASCHNG
                OCT             04022
                CAF             V16N80
                TC              BANKCALL
                CADR            PRIODSPR
                TC              GOTOV56
                TC              R24END                  # PROCEED EXIT R24 TO P20LEM1


                TC              R24LEM3                 # RECYCLE - CALL R61 TO MANEUVER S/C

                TC              BANKCALL
                CADR            LRS24.1
R24END          INHINT
                TC              KILLTASK
                CADR            CALLDGCH
                RELINT
                TC              CLRADMOD                # CLEAR BITS 10 & 15 OF RADMODES.
                TC              P20LEM1                 # AND GO TO 400 MI. RANGE CHECK IN P20.

CLRADMOD        CS              BIT10+15
                INHINT
                MASK            RADMODES
                TS              RADMODES
                CS              BIT2                    # DISABLE RR ERROR COUNTERS
                EXTEND
                WAND            CHAN12                  # USER WILL RELINT

                TC              Q

R24LEM3         TC              PHASCHNG
                OCT             04022
                INHINT
                TC              KILLTASK
                CADR            STDESIG                 # KILL WAITLIST FOR NEXT POINT IN PATTERN
                RELINT                                  # HALF SECOND DESIGNATE LOOP
                TC              CLRADMOD
                CS              BIT2
                EXTEND
                WAND            CHAN12
                TC              LUNSFCHK                # CHECK IF ON LUNAR SURFACE
                TC              R24LEM2                 # YES-DONT DO ATTITUDE MANEUVER
                TC              UPFLAG
                ADRES           MANUFLAG
                TC              BANKCALL                # CALL R61 TO DO PREFERRED TRACKING
                CADR            R61LEM                  # ATTITUDE MANEUVER
                TC              DOWNFLAG
                ADRES           MANUFLAG
                TC              R24LEM2                 # AND GO BACK TO PUT UP V16 N80 DISPLAY

BIT10+15        OCT             41000
V16N80          VN              01680

# PREFERRED TRACKING ATTITUDE ROUTINE R61LEM
# PROGRAM DESCRIPTION
# MOD NO : 3                      DATE : 4-11-67
# MOD BY : P VOLANTE  SDC


# FUNCTIONAL DESCRIPTION-
#   TO COMPUTE THE PREFERRED TRACKING ATTITUDE OF THE LM TO ENABLE RR
# TRACKING OF THE CSM AND TO PERFORM THE MANEUVER TO THE PREFERRED
# ATTITUDE.
# CALLING SEQUENCE-
#          TC     BANKCALL
#          CADR   R61LEM
# SUBROUTINES CALLED
#     LPS20.1       VECPOINT
#     KALCMAN3


# NORMAL EXIT MODES-
#   NORMAL RETURN IS TO CALLER + 1
# ALARM OR ABORT EXIT MODES-
#   TERMINATE P20 + R61 BY BRANCHING TO P20END IF BOTH TRACKFLAG +
# RENDEZVOUS FLAG ARE NOT SET.
# OUTPUT -
#   SEE OUTPUT FOR LPS20.1 + ATTITUDE MANEUVER ROUTINE (R60)
# ERASABLE INITIALIZATION REQUIRED
#   GENRET USED TO SAVE Q FOR RETURN
# FLAGS SET + RESET
#   3AXISFLG
# DEBRIS
#   SEE SUBROUTINES
                SETLOC          R61
                BANK
                EBANK=          LOSCOUNT
                COUNT*          $$/R61
R61LEM          TC              MAKECADR
                TS              GENRET
                TC              PHASCHNG
                OCT             04022
R61C+L01        CAF             TRACKBIT                # TRACKFLAG
                MASK            STATE           +1
                EXTEND
                BZF             R61C+L1                 # NOT SET
R61C+L03        TC              INTPRET                 # SET
                VLOAD
                                HIUNITZ
                STORE           SCAXIS                  # TRACK AXIS UNIT VECTOR
                RTB
                                LOADTIME                # PRESENT TIME
                STCALL          TDEC1
                                LPS20.1                 # LOS DETERMINATION + VEH ATTITUDE
                VLOAD
                                RRTARGET
                STORE           POINTVSM                # DIRECTION IN WHICH TRACK AXIS IS TO BE
                CLEAR           EXIT
                                3AXISFLG
                TC              UPFLAG
                ADRES           PDSPFLAG                # SET PRIORITY DISPLAY FLAG
                TC              BANKCALL
                CADR            R60LEM
                TC              PHASCHNG
                OCT             04022
                TC              DOWNFLAG
                ADRES           PDSPFLAG                # RESET PRIORITY DISPLAY FLAG

R61C+L4         CAE             GENRET
                TCF             BANKJUMP                # EXIT R61
R61C+L1         CAF             BIT7+9PV                # IS RENDEZVOUS OR P25FLAG SET
                MASK            STATE
                EXTEND
                BZF             ENDOFJOB                # NO-EXIT ROUTINE AND PROGRAM.
                TC              R61C+L4                 # YES EXIT ROUTINE
BIT7+9PV        OCT             00500

## Sundance 292

                BLOCK           02
                SETLOC          RADARFF
                BANK

                EBANK=          LOSCOUNT
                COUNT*          $$/RRSUB

# THE FOLLOWING SUBROUTINE RETURNS TO CALLER + 2 IF THE ABSOLUTE VALUE OF VALUE OF C(A) IS GREATER THAN THE
# NEGATIVE OF THE NUMBER AT CALLER +1. OTHERWISE IT RETURNS TO CALLER +3. MAY BE CALLED IN RUPT OR UNDER EXEC.

MAGSUB          EXTEND
                BZMF            +2
                TCF             +2
                COM

                INDEX           Q
                AD              0
                EXTEND
                BZMF            +3

                INDEX           Q
                TC              1

                INDEX           Q
                TC              2

# PROGRAM NAME_  RRLIMCHK                                                  ARE IN THE LIMITS OF THE CURRENT MODE.

# FUNCTIONAL DESCRIPTION_
# RRLIMCHK CHECKS RR DESIRED GIMBAL ANGLES TO SEE IF THEY ARE WITHIN
# THE LIMITS OF THE CURRENT MODE. INITIALLY THE DESIRED TRUNNION AND
# SHAFT ANGLES ARE STORED IN ITEMP1 AND ITEMP2. THE CURRENT RR
# ANTENNAE MODE (RADMODES BIT 12) IS CHECKED WHICH IS = 0 FOR
# MODE 1 AND =1 FOR MODE 2.
# MODE 1 - THE TRUNNION ANGLE IS CHECKED AT MAGSUB TO SEE IF IT IS
# BETWEEN -55 AND +55 DEGREES. IF NOT, RETURN TO L +2. IF WITHIN LIMITS,
# THE SHAFT ANGLE IS CHECKED TO SEE IF IT IS BETWEEN -70 AND +59 DEGREES.
# IF NOT, RETURN TO L +2. IF IN LIMITS, RETURN TO L +3.
# MODE 2 - THE SHAFT ANGLE IS CHECKED AT MAGSUB TO SEE IF IT IS
# BETWEEN -139 AND -25 DEGREES. IF NOT, RETURN TO L +2. IF WITHIN
# LIMITS, THE TRUNNION ANGLE IS CHECKED TO SEE IF IT IS BETWEEN +125
# AND -125 (+235) DEGREES. IF NOT, RETURN TO L +2. IF IN LIMITS, RETURN
# TO L +3.

# CALLING SEQUENCE:
# L  TC  RRLIMCHK (WITH INTERRUPT INHIBITED)
# L +1  ADRES  T,S  (DESIRED TRUNNION ANGLE ADDRESS)

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES, MODEA, MODEB (OR DESIRED TRUNNION AND SHAFT
# ANGLES ELSEWHERE IN CONSECUTIVE LOCATIONS - UNSWITCHED ERASABLE OR
# CURRENT EBANK).

# SUBROUTINES CALLED_  MAGSUB

# JOBS OR TASKS INITIATED_  NONE

# ALARMS_  NONE

# EXIT_  L + 2 (EITHER OR BOTH ANGLES NOT WITHIN LIMITS OF CURRENT MODE)
# L + 3 (BOTH ANGLES WITHIN LIMITS OF CURRENT MODE)

RRLIMCHK        EXTEND
                INDEX           Q
                INDEX           0
                DCA             0
                INCR            Q
                DXCH            ITEMP1
                LXCH            Q                       # L(CALLER +2) TO L.

                CAF             BIT12                   # SEE WHICH MODE RR IS IN.
                MASK            RADMODES
                CCS             A
                TCF             MODE2CHK

                CA              ITEMP1                  # MODE 1 IS DEFINED AS

                TC              MAGSUB                  #     1. ABS(T) L 55 DEGS.
                DEC             -.30555                 #     2. ABS(S + 5.5 DEGS) L 64.5 DEGS
                TC              L                       #         (SHAFT LIMITS AT +59, -70 DEGS)

                CAF             5.5DEGS
                AD              ITEMP2                  # S
                TC              MAGSUB
                DEC             -.35833                 # 64.5 DEGS
                TC              L
                TC              RRLIMOK                 # IN LIMITS.

MODE2CHK        CAF             82DEGS                  # MODE 2 IS DEFINED AS
                AD              ITEMP2                  #     1. ABS(T) G 125 DEGS.
                TC              MAGSUB                  #     2. ABS(S + 82 DEGS) L 57 DEGS
                DEC             -.31667                 #         (SHAFT LIMITS AT -25, -139 DEGS)
                TC              L

                CA              ITEMP1
                TC              MAGSUB
                DEC             -.69444                 # 125 DEGS

RRLIMOK         INDEX           L
                TC              L                       # ( = TC 1 )

5.5DEGS         DEC             .03056
82DEGS          DEC             .45556

# PROGRAM NAME_  SETTRKF                                                  . IF EITHER:

# FUNCTIONAL DESCRIPTION_
# SETTRKF UPDATES THE TRACKER FAIL LAMP ON THE DSKY.                      HER THE ALT OR VEL INFORMATION.
# INITIALLY THE LAMP TEST FLAG (IMODES33 BIT 1) IS CHECKED.
# IF A LAMP TEST IS IN PROGRESS, THE PROGRAM EXITS TO L +1.
# IF NO LAMP TEST THE FOLLOWING IS CHECKED SEQUENTIALLY_
# 1) RR CDU:S BEING ZEROED, RR CDU OK, AND RR NOT IN
# AUTO MODE (RADMODES BITS 13, 7, 2).
# 2) LR VEL DATA FAIL AND NO LR POS DATA (RADMODES BITS
# 8,5)
# 3) NO RR DATA (RADMODES BIT 4)
# THE ABSENCE OF ALL THREE SIMULTANEOUSLY IN (1), THE PRESENCE OF BOTH
# IN (2), AND THE PRESENCE OF (3) RESULTS IN EITHER THE TRACKER FAIL
# LAMP (DSPTAB +11D BIT 8) BEING TURNED ON OR LEFT ON. OTHERWISE,
# THE TRACKER FAIL LAMP IS TURNED OFF OR IS LEFT OFF. THEREFORE, THE
# TRACKER FAIL LAMP IS TURNED ON IF_
# A ) RR CDU FAILED WITH RR IN AUTO MODE AND RR CDU:S NOT BEING ZEROED.
# B) N SAMPLES OF LR DATA COULD NOT BE TAKEN IN 2N TRIES WITH
# EITHER THE ALT OR VEL INFORMATION
# C) N SAMPLES OF RR DATA COULD NOT BE OBTAINED FROM 2N TRIES
# WITH EITHER THE AL

# CALLING SEQUENCE:
# L  TC  SETTRKF

# ERASABLE INITIALIZATION REQUIRED: IMODES33, RADMODES, DSPTAB +11D
# SUBROUTINES CALLED_  NONE

# JOBS OR TASKS INITIATED_  NONE

# ALARMS_  TRACKER FAIL LAMP

# EXIT_  L +1 (ALWAYS)                                                    ED.

SETTRKF         CAF             BIT1                    # NO ACTION IF DURING LAMP TEST.
                MASK            IMODES33
                CCS             A
                TC              Q

                CAF             13,7,2                  # SEE IF CDU FAILED.
                MASK            RADMODES
                EXTEND
                BZF             TRKFLON                 # CONDITION 3 ABOVE.

                EXTEND
                READ            CHAN13
                MASK            LOW3
                TS              L
                MASK            BIT3
                EXTEND
                BZF             RRCHECK

                CAF             LOW3
                EXTEND
                RXOR            LCHAN
                CCS             A
                TCF             LRVELCHK

LRALTCHK        CS              RADMODES
                MASK            LRALTBIT
LRCHECK         EXTEND
                BZF             TRKFLON

RRCHECK         CAF             BIT4                    # SEE IF RR DATA FAILED.
                MASK            RADMODES

                CCS             A
TRKFLON         CAF             BIT8
                AD              DSPTAB          +11D    # HALF ADD DESIRED AND PRESENT STATES.
                MASK            BIT8
                EXTEND
                BZF             TCQ                     # NO CHANGE.

FLIP            TS              L
                CA              DSPTAB          +11D    # CANT USE LXCH DSPTAB +11D (RESTART PROB)
                EXTEND
                RXOR            LCHAN
                MASK            POSMAX
                AD              BIT15
                TS              DSPTAB          +11D
                TC              Q

LRVELCHK        CS              RADMODES
                MASK            LRVELBIT
                TCF             LRCHECK

13,7,2          OCT             10102
ENDRMODF        EQUALS

## Sundance 302

# PROGRAM NAME_  RRTURNON

# FUNCTIONAL DESCRIPTION_

# RRTURNON IS THE TURN-ON SEQUENCE WHICH, ALONG WITH
# RRZEROSB, ZEROS THE CDU:S AND DETERMINES THE RR MODE.
# INITIALLY, CONTROL IS TRANSFERRED TO RRZEROSB FOR THE
# ACTUAL TURN-ON SEQUENCE. UPON RETURN THE PROGRAM
# WAITS 1 SECOND BEFORE REMOVING THE TURN-ON FLAG
# (RADMODES BIT1) SO THE REPOSITION ROUTINE WON:T
# INITIATE PROGRAM ALARM 00501. A CHECK IS THEN MADE
# TO SEE IF A PROGRAM IS USING THE RR (STATE BIT 7). IF
# SO, THE PROGRAM EXITS TO ENDRADAR SO THAT THE RR CDU
# FAIL FLAG (RADMODES BIT 7) CAN BE CHECKED BEFORE
# RETURNING TO THE WAITING PROGRAM. IF NOT, THE PROGRAM EXITS
# TO TASKOVER.

# CALLING SEQUENCE: WAITLIST TASK FROM RRAUTCHK IF THE RR POWER ON AUTO
# BIT (CHAN 33 BIT 2) CHANGES TO 0 AND NO PROGRAM WAS USING
# THE RR (STATE BIT 7).

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES, STATE

# SUBROUTINES CALLED_  RRZEROSB, FIXDELAY, TASKOVER, ENDRADAR

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE (SEE RRZEROSB)

# EXIT_  TASKOVER, ENDRADAR (WAITING PROGRAM)

                BANK            24
                SETLOC          P20S1
                BANK

                EBANK=          LOSCOUNT
                COUNT*          $$/RSUB
RRTURNON        TC              RRZEROSB
                TC              FIXDELAY                # WAIT 1 SEC BEFORE REMOVING TURN ON FLAG
                DEC             100                     # SO A MONITOR REPOSITION WONT ALARM.
                CS              BIT1
                MASK            RADMODES
                TS              RADMODES
                TCF             TASKOVER

# PROGRAM NAME_  RRZEROSB

# FUNCTIONAL DESCRIPTION_
# RRZEROSB IS A CLOSED SUBROUTINE TO ZERO THE RR CDU:S,
# DETERMINE THE RR MODE, AND TURNS ON THE TRACKER FAIL
# LAMP IF REQUIRED. INITIALLY THE RR CDU ZERO BIT (CHAN 12
# BIT 1) IS SET. FOLLOWING A 20 MILLISECOND WAIT, THE LGC
# RR CDU COUNTERS (OPTY, OPTX) ARE SET = 0 AFTER
# WHICH THE RR CDU ZERO DISCRETE (CHAN 12 BIT 1) IS
# REMOVED. A 4 SECOND WAIT IS SET TO ALL THE RR CDU:S
# TO REPEAT THE ACTUAL TRUNNION AND SHAFT ANGLES. THE
# RR CDU ZERO FLAG (RADMODES BIT 13) IS REMOVED. THE
# CONTENTS OF OPTY IS THEN CHECKED TO SEE IF THE TRUNNION
# ANGLE IS LESS THAN 90 DEGREES. IF NOT, BIT 12 OF
# RADMODES IS SET = 1 TO INDICATE RR ANTENNA MODE 2.
# IF LESS THAN 90 DEGREES, BIT 12 OF RADMODES IS SET = 0 TO
# INDICATE RR ANTENNA MODE 1. SETTRKF IS THEN CALLED TO
# SEE IF THE TRACKER FAIL LAMP SHOULD BE TURNED ON.

# CALLING SEQUENCE: L  TC  RRZEROSB (FROM RRTURNON AND RRZERO)
# ERASABLE INITIALIZATION REQUIRED:
# RADMODES (BIT 13 SET), DSPTAB +11D

# SUBROUTINES CALLED_  FIXDELAY, MAGSUB, SETTRKF

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  TRACKER FAIL

# EXIT_  L +1 (ALWAYS)

RRZEROSB        EXTEND
                QXCH            RRRET
                CAF             BIT1                    # BIT 13 OF RADMODES MUST BE SET BEFORE
                EXTEND                                  # COMING HERE.
                WOR             CHAN12                  # TURN ON ZERO RR CDU
                TC              FIXDELAY
                DEC             2

                CAF             ZERO
                TS              CDUT
                TS              CDUS
                CS              ONE                     # REMOVE ZEROING BIT.
                EXTEND
                WAND            CHAN12
                TC              FIXDELAY
                DEC             1000                    # RESET FAIL INHIBIT IN 10 SECS - D.281

                CS              BIT13                   # REMOVE ZEROING IN PROCESS BIT.

                MASK            RADMODES
                TS              RADMODES

                CA              CDUT
                TC              MAGSUB
                DEC             -.5
                TCF             +3                      # IF MODE 2.

                CAF             ZERO
                TCF             +2
                CAF             BIT12
                XCH             RADMODES
                MASK            -BIT12
                ADS             RADMODES

                TC              SETTRKF                 # TRACKER LAMP MIGHT GO ON NOW.

                TC              RRRET                   # DONE.

-BIT12          EQUALS          -1/8                    # IN SPROOT

# PROGRAM NAME_  DORREPOS
# FUNCTIONAL DESCRIPTION_
# DORREPOS IS A SEQUENCE OF TASKS TO DRIVE THE RENDEZVOUS RADAR
# TO A SAFE POSITION. INITIALLY SETRRECR IS CALLED WHERE THE RR
# ERROR COUNTERS (CHAN 12 BIT 2) ARE ENABLED AND LASTYCMD
# AND LASTXCMD SET = 0 TO INDICATE THE DIFFERENCE BETWEEN THE
# DESIRED STATE AND PRESENT STATE OF THE COMMANDS. THE RR
# TURN-ON FLAG (RADMODES BIT 1) IS CHECKED AND IF NOT PRESENT,
# PROGRAM ALARM 00501 IS REQUESTED BEFORE CONTINUING. IN EITHER
# CASE, FOLLOWING A 20 MILLISECOND WAIT THE PROGRAM CHECKS THE CURRENT
# RR ANTENNA MODE (RADMODES BIT 12). RRTONLY IS THEN CALLED
# TO DRIVE THE TRUNNION ANGLE TO 0 DEGREES IF IN MODE 1 AND TO 180
# DEGREES IF IN MODE 2. UPON RETURN, THE CURRENT RR ANTENNA
# MODE (RADMODES BIT 12) IS AGAIN CHECKED. RRSONLY IS THEN
# CALLED TO DRIVE THE SHAFT ANGLE TO 0 DEGREES IF IN MODE 1 AND TO
# -90 DEGREES IF IN MODE 2. IF DURING RRTONLY OR RRSONLY A
# REMODE HAS BEEN REQUESTED (RADMODES BIT 14), AND ALWAYS
# FOLLOWING COMPLETION OF RRSONLY, CONTROL IS TRANSFERRED TO
# REPOSRPT. HERE THE REPOSITION FLAG (RADMODES BIT 11) IS
# REMOVED. A CHECK IS THEN MADE ON THE DESIGNATE FLAG (RADMODES
# BIT 10). IF PRESENT, CONTROL IS TRANSFERRED TO BEGDES. IF NOT PRESENT
# INDICATING NO FURTHER ANTENNA CONTROL REQUIRED, THE RR ERROR
# COUNTER BIT (CHAN 12 BIT 2) IS REMOVED AND THE ROUTINE EXITS TO
# TASKOVER.

# CALLING SEQUENCE:
# WAITLIST CALL FROM RRGIMON IF TRUNNION AND SHAFT CDU ANGLES
# NOT WITHIN LIMITS OF CURRENT MODE.

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES

# SUBROUTINES CALLED_
# RRTONLY, RRSONLY, BEGDES (EXIT)

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS-  NONE

# EXIT_  TASKOVER, BEGDES

DORREPOS        TC              SETRRECR                # SET UP RR CDU ERROR COUNTERS.

# ALARM 501 DELETED IN DANCE 279 PER PCR 97.

                TC              FIXDELAY
                DEC             2

                CAF             BIT12                   # MANEUVER TRUNNION ANGLE TO NOMINAL POS.

                MASK            RADMODES
                CCS             A
                CAF             BIT15                   # 0 FOR MODE 1 AND 180 FOR MODE 2.
                TC              RRTONLY

                CAF             BIT12                   # NOW PUT SHAFT IN RIGHT POSITION.
                MASK            RADMODES
                CCS             A
                CS              HALF                    # -90 FOR MODE 2.
                TC              RRSONLY

REPOSRPT        CS              REPOSBIT                # RETURNS HERE FROM RR1AXIS IF REMODE
                                                        # REQUESTED DURING REPOSITION.
                MASK            RADMODES                # REMOVE REPOSITION BIT.
                TS              RADMODES
                MASK            BIT10                   # SEE IF SOMEONE IS WAITING TO DESIGNATE.
                CCS             A
                TCF             BEGDES
                CS              BIT2                    # IF NO FURTHER ANTENNA CONTROL REQUIRED,
                EXTEND                                  # REMOVE ERROR COUNTER ENABLE.
                WAND            CHAN12
                TCF             TASKOVER

SETRRECR        CAF             BIT2                    # SET UP RR ERROR COUNTERS.
                EXTEND
                RAND            CHAN12
                CCS             A                       # DO NOT CLEAR LAST COMMAND IF
                TC              Q                       # ERROR COUNTERS ARE ENABLED.

                TS              LASTYCMD
                TS              LASTXCMD
                CAF             BIT2
                EXTEND
                WOR             CHAN12                  # ENABLE RR CDU ERROR COUNTERS.
                TC              Q

# PROGRAM NAME_  REMODE                                                   IVES SHAFT TO -45, AND FINALLY DRIVES
#
# FUNCTIONAL DESCRIPTION_                                                 S DONE WITH SINGLE AXIS ROTATIONS (SEE
# REMODE IS THE GENERAL REMODING SUBROUTINE. IT DRIVES THE
# TRUNNION ANGLE TO 0 DEGREES IF THE CURRENT MODE IS MODE 1,
# 180 DEGREES FOR MODE 2, THEN DRIVES THE SHAFT ANGLE TO -45
# DEGREES, AND FINALLY DRIVES THE TRUNNION ANGLE TO -130 DEGREES,
# TO PLACE THE RR IN MODE 2, -50 DEGREES FOR MODE 1, BEFORE
# INITIATING 2-AXIS CONTROL. ALL REMODING IS DONE WITH SINGLE
# AXIS ROTATIONS (RR1AXIS). INITIALLY THE RR ANTENNA MODE FLAG
# (RADMODES BIT 12) IS CHECKED. CONTROL IS THEN TRANSFERRED TO
# RRTONLY TO DRIVE THR TRUNNION ANGLE TO 0 DEGREES IF IN MODE 1
# OR 180 DEGREES IF IN MODE 2. RRSONLY IS THEN CALLED TO DRIVE
# THE SHAFT ANGLE TO -45 DEGREES. THE RR ANTENNA MODE FLAG
# (RADMODES BIT 12) IS CHECKED AGAIN. CONTROL IS AGAIN
# TRANSFERRED TO RRTONLY TO DRIVE THE TRUNNION ANGLE TO -130
# DEGREES TO PLACE THE RR IN MODE 2 IF CURRENTLY IN MODE 1 OR TO
# -50 DEGREES IF IN MODE 2 TO PLACE THE RR IN MODE 1. RMODINV
# IS THEN CALLED TO SET RADMODES BIT 12 TO INDICATE THE NEW
# RR ANTENNA MODE. THE REMODE FLAG (RADMODES BIT 14)
# IS REMOVED TO INDICATE THAT REMODING IS COMPLETE. THE PROGRAM
# THEN EXITS TO STDESIG TO BEGIN 2-AXIS CONTROL.

# CALLING SEQUENCE:
# FROM BEGDES WHEN REMODE FLAG (RADMODES BIT 14) IS SET.
# THIS FLAG MAY BE SET IN RRDESSM AND RRDESNB IF RRLIMCHK
# DETERMINES THAT THE DESIRED ANGLES ARE WITHIN THE LIMITS OF THE
# OTHER MODE.

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES

# SUBROUTINES CALLED_
# RRTONLY, RRSONLY, RMODINV (ACTUALLY PART OF)

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE

# EXIT_  STDESIG

REMODE          CAF             BIT12                   # DRIVE TRUNNION TO 0 (180).
                MASK            RADMODES                # (ERROR COUNTER ALREADY ENABLED)
                CCS             A
                CAF             BIT15
                TC              RRTONLY

                CAF             -45DEGSR
                TC              RRSONLY

                CS              RADMODES
                MASK            BIT12
                CCS             A
                CAF             -80DEGSR                # GO TO T = -130 (-50).
                AD              -50DEGSR
                TC              RRTONLY

                TC              RMODINV

                CS              BIT14                   # END OF REMODE.
                MASK            RADMODES
                TS              RADMODES

                CAF             BIT10                   # WAS REMODE CALLED DURING DESIGNATE
                MASK            RADMODES                # (BIT10 RADMODES = 1)
                EXTEND
                BZF             RGOODEND                # NO-RETURN TO CALLER WAITING IN RADSTALL
                TC              STDESIG                 # YES - RETURN TO DESIGNATE
-45DEGSR        =               13,14,15
-50DEGSR        DEC             -.27778
-80DEGSR        DEC             -.44444

RMODINV         LXCH            RADMODES                # INVERT THE MODE STATUS.
                CAF             BIT12
                EXTEND
                RXOR            LCHAN
                TS              RADMODES
                TC              Q

# PROGRAM NAMES_  RRTONLY, RRSONLY

# FUNCTIONAL DESCRIPTION_
# RRTONLY AND RRSONLY ARE SUBROUTINES FOR DOING SINGLE AXIS
# RR MANEUVERS FOR REMODE AND REPOSITION. IT DRIVES TO
# WITHIN 1 DEGREE. INITIALLY, AT RR1AX2, THE REMODE AND REPOSITION
# FLAGS (RADMODES BITS 14, 11) ARE CHECKED. IF BOTH EXIST,
# THE PROGRAM EXITS TO REPOSRPT (SEE DORREPOS). THIS INDICATES
# THAT SOMEONE POSSIBLY REQUESTED A DESIGNATE (RADMODES BIT 10)
# WHICH REQUIRES A REMODE (RADMODES BIT 14) AND THAT A
# REPOSITION IS IN PROGRESS (RADMODES BIT 11). IF NONE
# OR ONLY ONE OF THE FLAGS EXIST, REMODE OR REPOSITION, MAGSUB
# IS CALLED TO SEE IF THE APPROPRIATE ANGLE IS WITHIN 1 DEGREE. IF YES,
# CONTROL RETURNS TO THE CALLING ROUTINE. IF NOT, CONTROL IS
# TRANSFERRED TO RROUT FOR SINGLE AXIS MANEUVERS WITH THE OTHER
# ANGLE SET = 0. FOLLOWING A .5 SECOND WAIT, THE ABOVE PROCEDURE IS
# REPEATED.

# CALLING SEQUENCE: L-1 CAF *ANGLE* (DESIRED ANGLE SCALED PI)
# L  TC  RRTONLY (TRUNNION ONLY)
# RRSONLY (SHAFT ONLY)
# RRTONLY IS CALLED BY PREPOS29;
# RRTONLY AND RRSONLY ARE CALLED BY DORREPOS AND REMODE

# ERASABLE INITIALIZATION REQUIRED:
# C(A) = DESIRED ANGLE, RADMODES

# SUBROUTINES CALLED_
# FIXDELAY, REPOSRPT, MAGSUB, RROUT

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE

# EXIT_  REPOSRPT (REMODE AND REPOSITION FLAGS PRESENT - RADMODES
# BITS 14, 11)
# L+1  (ANGLE WITHIN ONE DEGREE OR RR OUT OF AUTO MODE)

RRTONLY         TS              RDES                    # DESIRED TRUNION ANGLE.
                CAF             ZERO
                TCF             RR1AXIS

RRSONLY         TS              RDES                    # SHAFT COMMANDS ARE UNRESOLVED SINCE THIS
                CAF             ONE                     # ROUTINE ENTERED ONLY WHEN T = 0 OR 180.

RR1AXIS         TS              RRINDEX
                EXTEND
                QXCH            RRRET
                TCF             RR1AX2

NXTRR1AX        TC              FIXDELAY
                DEC             50                      # 2 SAMPLES PER SECOND.

RR1AX2          CS              RADMODES                # IF SOMEONE REQUESTES AS DESIGNATE WHICH
                MASK            PRIO22                  # REQUIRES A REMODE AND A REPOSITION IS IN
                EXTEND                                  # PROGRESS, INTERRUPT IT AND START THE
                BZF             REPOSRPT                # REMODE IMMEDIATELY.

                CA              RDES
                EXTEND
                INDEX           RRINDEX
                MSU             CDUT
                TS              ITEMP1                  # SAVE ERROR SIGNAL.
                EXTEND
                MP              RRSPGAIN                # TRIES TO NULL .7 OF ERROR OVER NEXT .5
                TS              L
                CA              RADMODES
                MASK            BIT2
                XCH             ITEMP1                  # STORE RR-OUT-OF-AUTO-MODE BIT.
                TC              MAGSUB                  # SEE IF WITHIN ONE DEGREE.
                DEC             -.00555                 # SCALED IN HALF-REVS.

                CCS             ITEMP1                  # NO.  IF RR OUT OF AUTO MODE, EXIT.
                TC              RRRET                   # RETURN TO CALLER.

                CCS             RRINDEX                 # COMMAND FOR OTHER AXIS IS ZERO.
                TCF             +2                      # SETTING A TO 0.
                XCH             L
                DXCH            TANG

                TC              RROUT

                TCF             NXTRR1AX                # COME BACK IN .5 SECONDS.

RRSPGAIN        DEC             .59062                  # NULL .7 ERROR IN .5 SEC.

# PROGRAM NAME_  RROUT                                                    RROR COUNTER SCALING. RROUT LIMITS THEM

# FUNCTIONAL DESCRIPTION_
# RROUT RECEIVES RR GYRO COMMANDS IN TANG, TANG +1 IN RR
# ERROR COUNTER SCALING. RROUT THEN LIMITS THEM AND
# GENERATES COMMANDS TO THE CDU TO ADJUST THE ERROR COUNTERS
# TO THE DESIRED VALUES. INITIALLY MAGSUB CHECKS THE MAGNITUDE OF
# THE COMMAND (SHAFT ON 1ST PASS) TO SEE IF IT IS GREATER THAN
# 384 PULSES. IF NOT, CONTROL IS TRANSFERRED TO RROUTLIM TO
# LIMIT THE COMMAND TO +384 OR -384 PULSES. THE DIFFERENCE IS
# THEN CALCULATED BETWEEN THE DESIRED STATE AND THE PRESENT STATE OF
# THE ERROR COUNTER AS RECORDED IN LASTYCMD AND LASTXCMD.
# THE RESULT IS STORED IN OPTXCMD (1ST PASS) AND OPTYCMD (2ND
# PASS). FOLLOWING THE SECOND PASS, FOR THE TRUNNION COMMAND, THE
# OCDUT AND OCDUS ERROR COUNTER DRIVE BITS (CHAN 14 BITS 12, 11)
# ARE SET. THIS PROGRAM THEN EXITS TO THE CALLING PROGRAM.

# CALLING SEQUENCE:
# L TC RROUT (WITH RUPT INHIBITED) RROUT IS CALLED BY
# RRTONLY, RRSONLY, AND DODES

# ERASABLE INITIALIZATION REQUIRED:
# TANG, TANG +1 (DESIRED COMMANDS), LASTYCMD, LASTXCMD
# (1ST PASS = 0), RR ERROR COUNTER ENABLE SET (CHAN 12 BIT 2).
#
# SUBROUTINES CALLED_
# MAGSUB

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE

# EXIT_  L+1 (ALWAYS)                                                     SIRED VALUES. RUPT MUST BE INHIBITED.

RROUT           LXCH            Q                       # SAVE RETURN.
                CAF             ONE                     # LOOP TWICE.
RROUT2          TS              ITEMP2
                INDEX           A
                CA              TANG
                TS              ITEMP1                  # SAVE SIGN OF COMMAND FOR LIMITING.

                TC              MAGSUB                  # SEE IF WITHIN LMITS.
-RRLIMIT        DEC             -384
                TCF             RROUTLIM                # LIMIT COMMAND TO MAG OF 384.

SETRRCTR        CA              ITEMP1                  # COUNT OUT DIFFERENCE BETWEEN DESIRED
                INDEX           ITEMP2                  # STATE AND PRESENT STATE AS RECORDED IN
                XCH             LASTYCMD                # LASTYCMD AND LASTXCMD
                COM

                AD              ITEMP1
                AD              NEG0                    # PREVENT +0 IN OUTCOUNTER
                INDEX           ITEMP2
                TS              CDUTCMD

                CCS             ITEMP2                  # PROCESS BOTH INPUTS.
                TCF             RROUT2

                CAF             PRIO6                   # ENABLE COUNTERS.
                EXTEND
                WOR             CHAN14                  # PUT ON CDU DRIVES S AND T
                TC              L                       # RETURN.

RROUTLIM        CCS             ITEMP1                  # LIMIT COMMAND TO ABS VAL OF 384.
                CS              -RRLIMIT
                TCF             +2
                CA              -RRLIMIT
                TS              ITEMP1
                TCF             SETRRCTR        +1

#          ROUTINE TO ZERO THE RR CDUS AND DETERMINE THE ANTENNA MODE.

RRZERO          CAF             BIT11+1                 # SEE IF MONITOR REPOSITION OR NOT IN AUTO
                MASK            RADMODES                # IF SO, DONT RE-ZERO CDUS.
                CCS             A
                TCF             RADNOOP                 # (IMMEDIATE TASK TO RGOODEND).

                INHINT
                CS              BIT13                   # SET FLAG TO SHOW ZEROING IN PROGRESS.
                MASK            RADMODES
                AD              BIT13
                TS              RADMODES

                CAF             ONE
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           RRZ2

                CS              RADMODES                # SEE IF IN AUTO MODE.
                MASK            BIT2
                CCS             A
                TCF             ROADBACK
                TC              ALARM                   # AUTO DISCRETE NOT PRESENT - TRYING
                OCT             510
ROADBACK        RELINT
                TCF             SWRETURN

RRZ2            TC              RRZEROSB                # COMMON TO TURNON AND RRZERO.
                TCF             ENDRADAR

BIT11+1         OCT             02001

# PROGRAM NAME_  RRDESSM                                                  R (HALF-UNIT) IN RRTARGET. REMODES IF

# FUNCTIONAL DESCRIPTION_
# THIS INTERPRETIVE ROUTINE WILL DESIGNATE, IF DESIRED ANGLES ARE
# WITHIN THE LIMITS OF EITHER MODE, TO A LINE-OF SIGHT (LOS) VECTOR
# (HALF-UNIT) KNOWN WITH RESPECT TO THE STABLE MEMBER PRESENT
# ORIENTATION. INITIALLY THE IMU CDU:S ARE READ AND CONTROL
# TRANSFERRED TO SMNB TO TRANSFORM THE LOS VECTOR FROM STABLE
# MEMBER TO NAVIGATION BASE COORDINATES (SEE STG MEMO -699)
# RRANGLES IS THEN CALLED TO CALCULATE THE RR GIMBAL ANGLES,
# TRUNNION AND SHAFT, FOR BOTH THE PRESENT AND ALTERNATE MODE.
# RRLIMCHK IS CALLED TO SEE IF THE ANGLES CALCULATED FOR THE
# PRESENT MODE ARE WITHIN LIMITS. IF WITHIN LIMITS, THE RETURN
# LOCATION IS INCREMENTED, INASMUCH AS NO VEHICLE MANEUVER IS
# REQUIRED, BEFORE EXITING TO STARTDES. IF NOT WITHIN LIMITS OF THE
# CURRENT MODE, TRYSWS IS CALLED. FOLLOWING INVERTING OF THE RR
# ANTENNA MODE FLAG (RADMODES BIT 12), RRLIMCHK IS CALLED
# TO SEE IF THE ANGLES CALCULATED FOR THE ALTERNATE MODE ARE WITHIN
# LIMITS. IF YES, THE RR ANTENNA MODE FLAG IS AGAIN INVERTED,
# THE REMODE FLAG (RADMODES BIT 14) SET, AND THE RETURN LOCATION
# INCREMENTED, TO INDICATE NO VEHICLE MANEUVER IS REQUIRED, BEFORE
# EXITING TO STARTDES. IF THESE ANGLES ARE NOT WITHIN LIMITS
# OF THE ALTERNATE MODE, THE RR ANTENNA MODE FLAG (RADMODES
# BIT 12) IS INVERTED BEFORE RETURNING DIRECTLY TO THE CALLING PROGRAM
# TO INDICATE THAT A VEHICLE MANEUVER IS REQUIRED.

# CALLING SEQUENCE:
# L  STCALL  RRTARGET  (LOS HALF-UNIT VECTOR IN SM COORDINATES)
# L+1  RRDESSM
# L+2  BASIC  (VEHICLE MANEUVER REQUIRED)
# L+3  BASIC  (NO VEHICLE MANEUVER REQUIRED)

# ERASABLE INITIALIZATION REQUIRED:
# RRTARGET, RADMODES

# SUBROUTINES CALLED_
# READCDUS, SMNB, RRANGLES, RRLIMCHK, TRYSWS (ACTUALLY
# PART OF), RMODINV

# JOBS OR TASKS INITIATED_
#    NONE

# ALARMS_  NONE

# EXIT_  L+2 (NEITHER SET OF ANGLES ARE WITHIN LIMITS OF RELATED MODE)
# STARTDES (DESIGNATE POSSIBLE AT PRESENT VEHICLE ATTITUDE-RETURNS
# TO L+3 FROM STARTDES)                                                   CAN BE DONE IN PRESENT VEH ATTITUDE.

RRDESSM         STQ             CLEAR
                                DESRET
                                RRNBSW
                CALL                                    # COMPUTES SINES AND COSINES, ORDER Y Z X
                                CDUTRIG
                VLOAD           CALL                    # LOAD VECTOR AND CALL TRANSFORMATION
                                RRTARGET
                                *SMNB*

                CALL                                    # GET RR GIMBAL ANGLES IN PRESENT AND
                                RRANGLES                # ALTERNATE MODE.
                EXIT

                INHINT
                TC              RRLIMCHK
                ADRES           MODEA                   # CONFIGURATION FOR CURRENT MODE.
                TC              +3                      # NOT IN CURRENT MODE
OKDESSM         INCR            DESRET                  # INCREMENT SAYS NO VEHICLE MANEUVER REQ.
                TC              STARTDES                # SHOW DESIGNATE REQUIRED
                CS              FLAGWRD8
                MASK            SURFFBIT                # CHECK IF ON LUNAR SURFACE (SURFFLAG=P22F
                EXTEND
                BZF             NORDSTAL                # BRANCH-YES-CANNOT DESIGNATE IN MODE 2
                TC              TRYSWS


LUNDESCH        CS              FLAGWRD8                # OVERFLOW RETURN FROM RRANGLES
                MASK            SURFFBIT                # CHECK IF ON LUNAR SURFACE
                EXTEND
                BZF             NORDSTAL                # BRANCH-YES-RETURN TO CALLER - ALARM 527
                TC              NODESSM                 # NOT ON MOON-CALL FOR ATTITUDE MANEUVER

# PROGRAM NAME_  STARTDES                                                 STORED AS A HALF-UNIT VECTOR IN RRTARGET

# FUNCTIONAL DESCRIPTION_                                                 CKON IS DESIRED. BIT14 OF RADMODES IS
# STARTDES IS ENTERED WHEN WE ARE READY TO BEGIN DESIGNATION.             OR REPOSITION OPERATION. IN THIS
# BIT 14 OF RADMODES IS ALREADY SET IF A REMODE IS REQUIRED.              THE REPOSITION WILL BE INTERRUPTED.
# AT THIS TIME, THE RR ANTENNA MAY BE IN A REPOSITION                     GINS.
# OPERATION. IN THIS CASE, IF A REMODE IS REQUIRED IT MAY HAVE
# ALREADY BEGUN BUT IN ANY CASE THE REPOSITION WILL BE INTERRUPTED.
# OTHERWISE, THE REPOSITION WILL BE COMPLETED BEFORE 2-AXIS
# DESIGNATION BEGINS. INITIALLY DESCOUNT IS SET = 60 TO INDICATE
# THAT 30 SECONDS WILL BE ALLOWED FOR THE RR DATA GOOD INBIT
# (CHAN 33 BIT 4) IF LOCK-ON IS DESIRED (STATE BIT 5). BIT 10
# OF RADMODES IS SET TO SHOW THAT A DESIGNATE IS REQUIRED.
# THE REPOSITION FLAG (RADMODES BIT 11) IS CHECKED. IF SET,
# THE PROGRAM EXITS TO L+3 OF THE CALLING PROGRAM (SEE RRDESSM
# AND RRDESNB). THE PROGRAM WILL BEGIN DESIGNATING TO THE DESIRED
# ANGLES FOLLOWING THE REPOSITION OR REMODE IF ONE WAS
# REQUESTED. IF THE REPOSITION FLAG IS NOT SET, SETRRECR IS CALLED
# WHICH SETS THE RR ERROR COUNTER ENABLE BIT (CHAN 12 BIT 2)
# AND SETS LASTYCMD AND LASTXCMD = 0 TO INDICATE THE
# DIFFERENCE BETWEEN THE PRESENT AND DESIRED STATE OF THE ERROR
# COUNTERS. A 20 MILLISECOND WAITLIST CALL IS SET FOR BEGDES
# AFTER WHICH THE PROGRAM EXITS TO L+3 OF THE CALLING PROGRAM.

# CALLING SEQUENCE:
# FROM RRDESSM AND RRDESNB WHEN ANGLES WITHIN LIMITS.

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES, (SEE DODES)

# SUBROUTINES CALLED_
# SETRRECR, WAITLIST

# JOBS OR TASKS INITIATED_
# BEGDES

# ALARMS_  NONE

# EXIT_  L+3 OF CALLING PROGRAM (SEE RRDESSM)
# L+2 OF CALLING PROGRAM (SEE RRDESNB)

STARTDES        INCR            DESRET
                CS              RADMODES
                MASK            BIT10
                ADS             RADMODES
                MASK            BIT11                   # SEE IF REPOSITION IN PROGRESS.
                CCS             A
                TCF             DESRETRN                # ECTR ALREADY SET UP.

                TC              SETRRECR                # SET UP ERROR COUNTERS.
                CAF             TWO
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           BEGDES

DESRETRN        CA              RADCADR                 # FIRST PASS THRU DESIGNATE
                EXTEND
                BZF             DESRTRN                 # YES   SET EXIT
                TC              ENDOFJOB                # NO
DESRTRN         RELINT
                INCR            DESRET
                CA              DESRET
                TCF             BANKJUMP

NORDSTAL        CAF             ZERO                    # ZERO RADCADR TO WIPE  OUT ANYONE
                TS              RADCADR                 # WAITING IN RADSTALL SINCE WE ARE NOW
                TCF             DESRTRN                 # RETURNING TO P20 AND MAY DO NEW RADSTALL

#          SEE IF RRDESSM CAN BE ACCOMPLISHED AFTER A REMODE.

TRYSWS          TC              RMODINV                 # (NOTE RUPT INHIBIT)
                TC              RRLIMCHK                # TRY DIFFERENT MODE.
                ADRES           MODEB
                TCF             NODESSM                 # VEHICLE MANEUVER REQUIRED.

                TC              RMODINV                 # RESET BIT12
                CAF             BIT14                   # SET FLAG FOR REMODE.
                ADS             RADMODES

                TCF             OKDESSM

NODESSM         TC              RMODINV                 # RE-INVERT MODE AND RETURN
                INCR            DESRET                  # TO CALLER +2
                TCF             NORDSTAL

MAXTRYS         DEC             60

#          DESIGNATE TO SPECIFIC RR GIMBAL ANGLES (INDEPENDENT OF VEHICLE MOTION). ENTER WITH DESIRED ANGLES IN
# TANG AND TANG +1.

RRDESNB         TC              MAKECADR
                TS              DESRET

                CA              MAXTRYS                 # SET TIME LIMIT COUNTER
                TS              DESCOUNT                # FOR DESIGNATE
                INHINT                                  # SEE IF CURRENT MODE OK.
                TC              RRLIMNB                 # DO SPECIAL V41 LIMIT CHECK
                ADRES           TANG
                TCF             TRYSWN                  # SEE IF IN OTHER MODE.

OKDESNB         RELINT
                EXTEND
                DCA             TANG
                DXCH            TANGNB
                TC              INTPRET

                CALL                                    # GET LOS IN NB COORDS.
                                RRNB
                STORE           RRTARGET

                SET             EXIT
                                RRNBSW

                INHINT
                TCF             STARTDES        +1
TRYSWN          TC              RMODINV                 # SEE IF OTHER MODE WILL DO.
                TC              RRLIMNB                 # DO SPECIAL V41 LIMIT CHECK
                ADRES           TANG
                TCF             NODESNB                 # NOT POSSIBLE.

                TC              RMODINV
                CAF             BIT14                   # CALL FOR REMODE.
                ADS             RADMODES
                TCF             OKDESNB

NODESNB         CAF             ONE
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           RDBADEND

                TC              RMODINV                 # REINVERT MODE BIT.
                TC              ALARM                   # BAD INPUT ANGLES.
                OCT             502
                TCF             DESRTRN +1              # AVOID 503 ALARM.

RRLIMNB         INDEX           Q                       # THIS ROUTINE IS IDENTICAL TO RRLIMCHK
                CAF             0                       # EXCEPT THAT THE MODE 1 SHAFT LOWER
                INCR            Q                       # LIMIT IS -85 INSTEAD OF -70 DEGREES
                EXTEND

                INDEX           A                       # READ GIMBAL ANGLES INTO ITEMP STORAGE
                DCA             0
                DXCH            ITEMP1
                LXCH            Q                       # L(CALLER +2) TO L

                CAF             BIT12                   # SEE WHICH MODE RR IS IN
                MASK            RADMODES
                CCS             A
                TCF             MODE2CHK                # MODE 2 CAN USE RRLIMCHK CODING
                CA              ITEMP1
                TC              MAGSUB                  # MODE 1 IS DEFINED AS
                DEC             -.30555                 #   1. ABS(T) L 55 DEGS
                TC              L                       #   2  SHAFT LIMITS AT +59, -85 DEGS

                CA              ITEMP2                  # LOAD SHAFT ANGLE
                EXTEND
                BZMF            NEGSHAFT                # IF NEGATIVE SHAFT ANGLE, ADD 20.5 DEGS
                AD              5.5DEGS
SHAFTLIM        TC              MAGSUB
                DEC             -.35833                 # 64.5 DEGREES
                TC              L                       # NOT IN LIMITS
                TC              RRLIMOK                 # IN LIMITS
NEGSHAFT        AD              20.5DEGS                # MAKE NEGATIVE SHAFT LIMIT -85 DEGREES
                TCF             SHAFTLIM


20.5DEGS        DEC             .11389

# PROGRAM NAME_  BEGDES

# FUNCTIONAL DESCRIPTION_
# BEGDES CHECKS VARIOUS DESIGNATE REQUESTS AND REQUESTS THE
# ACTUAL RR DESIGNATION. INITIALLY A CHECK IS MADE TO SEE IF A
# REMODE (RADMODES BIT 14) IS REQUESTED OR IN PROGRESS. IF SO,
# CONTROL IS TRANSFERRED TO STDESIG AFTER ROUTINE REMODE IS
# EXECUTED. IF NO REMODE, STDESIG IS IMMEDIATELY CALLED WHERE
# FIRST THE REPOSITION FLAG (RADMODES BIT 11) IS CHECKED. IF
# PRESENT, THE DESIGNATE FLAG (RADMODES BIT 10) IS REMOVED
# AFTER WHICH THE PROGRAM EXITS TO RDBADEND. IF THE REPOSITION
# FLAG IS NOT PRESENT, THE CONTINUOUS DESIGNATE FLAG (RADMODES
# BIT 15) IS CHECKED. IF PRESENT, ON EXECUTIVE CALL IS IMMEDIATELY
# MADE FOR DODES AFTER WHICH A .5 SECOND WAIT IS INITIATED BEFORE
# REPEATING AT STDESIG. IF THE RR SEARCH ROUTINE (LRS24.1) IS DESIGNATING
# TO A NEW POINT (NEWPTFLG SET) THE CURRENT DESIGNATE TASK IS TERMINATED.
# IF CONTINUOUS DESIGNATE IS NOT WANTED, THE DESIGNATE FLAG (RADMODES
# BIT 10) IS CHECKED. IF NOT PRESENT, THE PROGRAM EXITS TO ENDRADAR TO
# CHECK RR CDU FAIL BEFORE RETURNING TO THE CALLING PROGRAM. IF DESIGNATE
# IS STILL REQUIRED, DESCOUNT IS CHECKED TO SEE IF THE 30 SECONDS HAS
# EXPIRED BEFORE RECEIVING THE RR DATA GOOD (CHAN 33 BIT 4)
# SIGNAL. IF OUT OF TIME, PROGRAM ALARM 00503 IS REQUESTED, THE
# RR AUTO TRACKER ENABLE AND RR ERROR COUNTER ENABLE
# (CHAN 12 BITS 14,2) BITS REMOVED, AND THE DESIGNATE FLAG
# (RADMODES BIT 10) REMOVED BEFORE EXITING TO RDBADEND. IF
# TIME HAS NOT EXPIRED, DESCOUNT IS DECREMENTED, THE
# EXECUTIVE CALL MADE FOR DODES, AND A .5 SECOND WAIT INITIATED
# BEFORE REPEATING THIS PROCEDURE AT STDESIG.

# CALLING SEQUENCE:
# WAITLIST CALL FROM STARTDES
# TCF BEGDES FROM DORREPOS
# TC STDESIG RETURNING, FROM REMODE

# ERASABLE INITIALIZATION REQUIRED:
# DESCOUNT, RADMODES

# SUBROUTINES CALLED_
# ENDRADAR, FINDVAC

# JOBS OR TASKS INITIATED_  DODES

# ALARMS_  PROGRAM ALARM 00503 (30 SECONDS HAVE EXPIRED) WITH NO RR DATA
# GOOD (CHAN 33 BIT 4) RECEIVED WHEN LOCK-ON (STATE BIT 5) WAS REQUESTED.

# EXIT_  TASKOVER (SEARCH PATTERN DESIGNATING TO NEW POINT)
# ENDRADAR (NO DESIGNATE - RADMODES BIT 10)
# RDBADEND (REPOSITION OR 30 SECONDS EXPIRED)

BEGDES          CS              RADMODES

                MASK            BIT14
                CCS             A
                TC              STDESIG
                TC              REMODE
DESLOOP         TC              FIXDELAY                # 2 SAMPLES PER SECOND.
                DEC             50

STDESIG         CAF             BIT11
                MASK            RADMODES                # SEE IF GIMBAL LIMIT MONITOR HAS FOUND US
                CCS             A                       # OUT OF BOUNDS. IF SO, THIS BIT SHOWS A
                TCF             BADDES                  # REPOSITION TO BE IN PROGRESS.

                CCS             RADMODES                # SEE IF CONTINUOUS DESIGNATE WANTED.
                TCF             +3                      # IF SO, DONT CHECK BIT 10 TO SEE IF IN
                TCF             +2                      # LIMITS BUT GO RIGHT TO FINDVAC ENTRY.
                TCF             MOREDES         +1

                CS              RADMODES                # IF NON-CONTINUOUS, SEE IF END OF
                MASK            BIT10                   # PROBLEM (DATA GOOD IF LOCK-ON WANTED OR
                CCS             A                       # WITHIN LIMITS IF NOT). IF SO, EXIT AFTER
                TCF             ENDRADAR                # CHECKING RR CDU FAIL.

                CAF             LOSCMBIT
                MASK            FLAGWRD2
                EXTEND
                BZF             STDESIG1
                CCS             LOSCOUNT
                TC              STDESIG1        -1

                CAF             PRIO26
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           R21LEM2
                TC              TASKOVER

                TS              LOSCOUNT
STDESIG1        CCS             DESCOUNT                # SEE IF THE TINE LIMIT HAS EXPIRED
                TCF             MOREDES

                CS              B14+B2                  # IF OUT OF TIME, REMOVE ECR ENABLE + TRKR
                EXTEND
                WAND            CHAN12
BADDES          CS              BIT10                   # REMOVE DESIGNATE FLAG.
                MASK            RADMODES
                TS              RADMODES
                TCF             RDBADEND

MOREDES         TS              DESCOUNT
                CAF             PRIO26                  # UPDATE GYRO TORQUE COMMANDS.
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           DODES

                TCF             DESLOOP

B14+B2          OCT             20002

# PROGRAM NAME_  DODES

# FUNCTIONAL DESCRIPTION_
# DODES CALCULATES AND REQUESTS ISSUANCE OF RR GYRO TORQUE
# COMMANDS. INITIALLY THE CURRENT RR CDU ANGLES ARE STORED AND
# THE LOS HALF-UNIT VECTOR TRANSFORMED FROM STABLE MEMBER TO
# NAVIGATION BASE COORDINATES VIA SMNB IF NECESSARY. THE
# SHAFT AND TRUNNION COMMANDS ARE THEN CALCULATED AS FOLLOWS_
# + SHAFT = LOS  . (COS(S), 0, -SIN (S)) (DOT PRODUCT)
# -TRUNNION = LOS  . (SIN (T) SIN (S), COS (T), SIN (T) COS (S) )
# THE SIGN OF THE SHAFT COMMAND IS THEN REVERSED IF IN MODE 2
# (RADMODES BIT 12) BECAUSE A RELAY IN THE RR REVERSES THE
# POLARITY OF THE COMMAND. AT RRSCALUP EACH COMMAND IS
# SCALED AND IF EITHER, OR BOTH, OF THE COMMANDS IS GREATER THAN
# .5 DEGREES, MPAC +1 IS SET POSITIVE. IF A CONTINUOUS DESIGNATE
# (RADMODES BIT 15) IS DESIRED AND THE SEARCH ROUTINE IS NOT OPERATING,
# THE RR AUTO TRACKER ENABLE BIT (CHAN 12 BIT 14) IS CLEARED AND RROUT
# CALLED TO PUT OUT THE COMMANDS PROVIDED NO REPOSITION (RADMODES BIT 11)
# IS IN PROGRESS. IF A CONTINUOUS DESIGNATE AND THE SEARCH ROUTINE IS
# OPERATING (SRCHOPT FLAG SET) THE TRACK ENABLE IS NOT CLEARED. IF NO
# CONTINUOUS DESIGNATE AND BOTH COMMANDS ARE NOT LESS THAN .5 DEGREES AS
# INDICATED BY MPAC +1, THE RR AUTO TRACKER ENABLE BIT (CHAN 12 BIT 14) IS
# CLEARED AND RROUT CALLED TO PUT OUT THE COMMANDS PROVIDED NO REPOSITION
# (RADMODES BIT 11) IS IN PROGRESS. IF BOTH COMMANDS ARE LESS THAN .5
# DEGREES AS INDICATED BY MPAC+1, THE RR AUTO TRACKER ENABLE BIT
# (CHAN 12 BIT 14) IS CLEARED AND RROUT CALLED TO PUT OUT THE
# COMMANDS PROVIDED NO REPOSITION (RADMODES BIT 11) IS IN
# PROGRESS. IF BOTH COMMANDS ARE LESS THAN .5 DEGREES, THE
# LOCK-ON FLAG (STATE BIT 5) IS CHECKED. IF NOT PRESENT, THE
# DESIGNATE FLAG (RADMODES BIT 10) IS CLEARED, THE RR ERROR
# COUNTER ENABLE BIT (CHAN 12 BIT 2) IS CLEARED, AND ENDOFJOB
# CALLED. IF LOCK-ON IS DESIRED, THE RR AUTO TRACKER (CHAN 12
# BIT 14) IS ENABLED FOLLOWED BY A CHECK OF THE RECEIPT OF THE
# RR DATA GOOD (CHAN 33 BIT 4) SIGNAL. IF RR DATA GOOD
# PRESENT, THE DESIGNATE FLAG (RADMODES BIT 10) IS CLEARED,
# THE RR ERROR COUNTER ENABLE BIT (CHAN 12 BIT 2) IS CLEARED,
# AND ENDOFJOB CALLED. IF RR DATA GOOD IS NOT PRESENT, RROUT
# IS CALLED TO PUT OUT THE COMMANDS PROVIDED NO REPOSITION
# (RADMODES BIT 11) IS IN PROGRESS AFTER WHICH THE JOB IS TERMINATED
# VIA ENDOFJOB.

# CALLING SEQUENCE:
# EXECUTIVE CALL EVERY .5 SECONDS FROM BEGDES.

# ERASABLE INITIALIZATION REQUIRED:
# RRTARGET (HALF-UNIT LOS VECTOR IN EITHER SM OR NB COORDINATES),
# LOKONSW (STATE BIT 5), RRNBSW (STATE BIT 6), RADMODES

# SUBROUTINES CALLED_
# READCDUS, SMNB, CDULOGIC, MAGSUB, RROUT

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE

# EXIT_  ENDOFJOB (ALWAYS)

DODES           EXTEND
                DCA             CDUT
                DXCH            TANG

                TC              INTPRET

                SETPD           VLOAD
                                0
                                RRTARGET
                BON             VXSC
                                RRNBSW
                                DONBRD                  # TARGET IN NAV-BASE COORDINATES
                                MLOSV                   # MULTIPLY UNIT LOS BY MAGNITUDE
                VSL1            PDVL
                                LOSVEL
                VXSC            VAD                     # ADD ONE SECOND RELATIVE VELOCITY TO LOS
                                MCTOMS
                UNIT            CALL
                                CDUTRIG
                CALL
                                *SMNB*

DONBRD          STORE           32D
                SLOAD
                                TANG            +1
                RTB             PUSH                    # SHAFT COMMAND = V(32D).(COS(S), 0,
                                CDULOGIC                #      (-SIN(S)).
                SIN             PDDL                    # SIN(S) TO 0 AND COS(S) TO 2.
                COS             PUSH
                DMP             PDDL
                                32D
                                36D
                DMP             BDSU
                                0
                STADR
                STORE           TANG            +1      # SHAFT COMMAND

                SLOAD           RTB
                                TANG
                                CDULOGIC
                PUSH            COS                     # COS(T) TO 4.
                PDDL            SIN
                PUSH            DMP                     # SIN(T) TO 6.
                                2

                SL1             PDDL                    # DEFINE VECTOR U = (SIN(T)SIN(S))
                                4                       #                   (COS(T)      )
                PDDL            DMP                     #                   (SIN(T)COS(S))
                                6
                                0
                SL1             VDEF
                DOT             EXIT                    # DOT U WITH LOS TO GET TRUNNION COMMAND.
                                32D

#          AT THIS POINT WE HAVE A ROTATION VECTOR IN DISH AXES LYING IN THE TS PLANE. CONVERT THIS TO A
# COMMANDED RATE AND ENABLE THE TRACKER IF WE ARE WITHIN .5 DEGREES OF THE TARGET.

                CS              MPAC                    # DOT WAS NEGATIVE OF DESIRED ANGLE.
                EXTEND
                MP              RDESGAIN                # SCALING ON INPUT ANGLE WAS 4 RADIANS.
                TS              TANG                    # TRUNNION COMMAND.
                CS              RADMODES                # A RELAY IN THE RR REVERSES POLARITY OF
                MASK            BIT12                   # THE SHAFT COMMANDS IN MODE 2 SO THAT A
                EXTEND                                  # POSITIVE TORQUE APPLIED TO THE SHAFT
                BZF             +3                      # GYRO CAUSES A POSITIVE CHANGE IN THE
                CA              TANG            +1      # SHAFT ANGLE. COMPENSATE FOR THIS SWITCH
                TCF             +2                      # BY CHANGING THE POLARITY OF OUR COMMAND.
 +3             CS              TANG            +1
                EXTEND
                MP              RDESGAIN                # SCALING ON INPUT ANGLE WAS 4 RADIANS.
                TS              TANG            +1      # SHAFT COMMAND.
                TC              INTPRET

                DLOAD           DMP
                                2                       # COS(S).
                                4                       # COS(T).
                SL1             PDDL                    # Z COMPONENT OF URR.
                DCOMP           PDDL                    # Y COMPONENT = -SIN(T).
                                0                       # SIN(S).
                DMP             SL1
                                4                       # COS(T).
                VDEF            BON                     # FORM URR IN NB AXES.
                                RRNBSW                  # BYPASS NBSM CONVERSION IN VERB 41.
                                +3
                CALL
                                *NBSM*                  # GET URR IN SM AXES.
                DOT             EXIT
                                RRTARGET                # GET COSINE OF ANGLE BETWEEN RR AND LOS.

                EXTEND
                DCS             COS1/2DG
                DAS             MPAC                    # DIFFERENCE OF COSINES, SCALED B-2.
                CCS             MPAC
                CA              ZERO                    # IF COS ERROR BIGGER, ERROR IS SMALLER.
                TCF             +2
                CA              ONE
                TS              MPAC            +1      # ZERO IF RR IS POINTED OK, ONE IF NOT.

#          SEE IF TRACKER SHOULD BE ENABLED OR DISABLED.

                CCS             RADMODES                # IF CONTINUOUS DESIGNATE WANTED, PUT OUT
                TCF             SIGNLCHK                # COMMANDS WITHOUT CHECKING MAGNITUDE OF
                TCF             SIGNLCHK                # ERROR SIGNALS
                TCF             DORROUT
SIGNLCHK        CCS             MPAC            +1      # SEE IF BOTH AXES WERE WITHIN .5 DEGS.
                TCF             DGOODCHK
                CS              STATE                   # IF WITHIN LIMITS AND NO LOCK-ON WANTED,
                MASK            LOKONBIT                # PROBLEM IS FINISHED.
                CCS             A
                TCF             RRDESDUN

                CAF             BIT14                   # ENABLE THE TRACKER.
                EXTEND
                WOR             CHAN12

DGOODCHK        CAF             BIT4                    # SEE IF DATA GOOD RECEIVED YET
                EXTEND
                RAND            CHAN33
                CCS             A
                TCF             DORROUT

RRDESDUN        INHINT
                CS              BIT10                   # WHEN PROBLEM DONE, REMOVE BIT 10 SO NEXT
                MASK            RADMODES                # WAITLIST TASK WE WILL GO TO RGOODEND.
                TS              RADMODES
                RELINT

                TC              DOWNFLAG                # RESET LOSCMFLG TO PREVENT A
                ADRES           LOSCMFLG                # RECOMPUTATION OF LOS AFTER DATA GOOD
                CS              BIT2                    # TURN OFF ENABLE RR ERROR COUNTER
                EXTEND
                WAND            CHAN12
                TCF             ENDOFJOB                # WITH ECTR DISABLED.

DORROUT         TC              INTPRET
                BOFF                                    # IF NOT IN P20/P22 BUT V41,DON'T DO
                                RNDVZFLG                # VELOCITY CORRECTION.
                                NOTP20
                VLOAD           VXSC                    # MULTIPLY UNIT LOS BY MAGNITUDE
                                RRTARGET
                                MLOSV
                VSL1            PUSH
                VLOAD           VXSC                    # ADD .5 SEC. OF VELOCITY
                                LOSVEL                  # TO LOS VECTOR
                                MCTOMS
                VSR1            VAD
                UNIT
                STODL           RRTARGET                # STORE VELOCITY-CORRECTED LOS (UNIT)

                                36D
                STORE           MLOSV                   # AND STORE MAGNITUDE
NOTP20          EXIT
                INHINT
                CS              RADMODES                # PUT OUT COMMAND UNLESS MONITOR
                MASK            BIT11                   # REPOSITION HAS TAKEN OVER.
                CCS             A
                TC              RROUT

                TCF             ENDOFJOB


RDESGAIN        DEC             .53624                  # TRIES TO NULL .5 ERROR IN .5 SEC.
COS1/2DG        2DEC            .999961923      B-2     # COSINE OF 0.5 DEGREES.
MCTOMS          2DEC            100             B-22

# RADAR READ INITIALIZATION

# RADAR DATA ARE READ BY A BANKCALL FOR THE APPROPRIATE LEAD-IN BELOW.

LRALT           TC              INITREAD         -1     # ONE SAMPLE PER READING.
ALLREAD         OCT             17

LRVELZ          TC              INITREAD
                OCT             16

LRVELY          TC              INITREAD
                OCT             15

LRVELX          TC              INITREAD
                OCT             14

RRRDOT          TC              INITREAD        -1
                OCT             12

RRRANGE         TC              INITREAD        -1
                OCT             11

# LRVEL IS THE ENTRY TO THE LR VELOCITY READ ROUTINE WHEN 5 SAMPLES ARE
# WANTED. ENTER WITH C(A)= 0,2,4 FOR LRVELZ,LRVELY,LRVELX RESP.

LRVEL           TS              TIMEHOLD                # STORE VBEAM INDEX HERE MOMEMTARILY
                CAF             FIVE                    # SPECIFY FIVE SAMPLES
                INDEX           TIMEHOLD
                TCF             LRVELZ

 -1             CAF             ONE                     # ENTRY TO TAKE ONLY 1 SAMPLE.
INITREAD        INHINT

                TS              TIMEHOLD                # GET DT OF MIDPOINT OF NOMINAL SAMPLING
                EXTEND                                  # INTERVAL (ASSUMES NO BAD SAMPLES WILL BE
                MP              BIT3                    # ENCOUNTERED).
                DXCH            TIMEHOLD

                CCS             A
                TS              NSAMP
                AD              ONE
#          INSERT FOLLOWING INSTRUCTION TO GET 2N TRIES FOR N SAMPLES.
#                                                  DOUBLE
                TS              SAMPLIM

                CAF             DGBITS                  # READ CURRENT VALUE OF DATA GOOD BITS.
                EXTEND
                RAND            CHAN33
                TS              OLDATAGD

                CS              ALLREAD
                EXTEND
                WAND            CHAN13                  # REMOVE ALL RADAR BITS

                INDEX           Q
                CAF             0
                EXTEND
                WOR             CHAN13                  # SET NEW RADAR BITS

                EXTEND
                DCA             TIME2
                DAS             TIMEHOLD                # TIME OF NOMINAL MIDPOINT.

                CAF             ZERO
                TS              L
                DXCH            SAMPLSUM
                TCF             ROADBACK

DGBITS          OCT             230

# RADAR RUPT READER

# THIS ROUTINE STARTS FROM A RADARUPT. IT READS THE DATA $ LOTS MORE.

                SETLOC          RADARUPT
                BANK

                COUNT*          $$/RRUPT
RADAREAD        EXTEND                                  # MUST SAVE SBANK BECAUSE OF RUPT EXITS
                ROR             SUPERBNK                # VIA TASKOVER (BADEND OR GOODEND.
                TS              BANKRUPT
                EXTEND
                QXCH            QRUPT

                CAF             SEVEN
                EXTEND
                RAND            CHAN13
                TS              DNINDEX
                CA              RNRAD
                INDEX           DNINDEX
                TS              DNRRANGE        -1

ANGLREAD        EXTEND
                DCA             OPTY
                DXCH            OPTYHOLD                # SAVE RAW CDU ANGLES

TRYCOUNT        CCS             SAMPLIM
                TCF             PLENTY
                TCF             NOMORE
                TC              ALARM
                OCT             520
                TC              RESUME

NOMORE          CS              FLAGWRD3                # CHECK R04FLAG.
                MASK            R04FLBIT                # IF 1,R04 IS RUNNING. DO NOT ALARM-
                EXTEND
                BZF             BADRAD

                TC              ALARM                   # P20 WANTS THE ALARM.
                OCT             521
BADRAD          CS              ONE
                TS              SAMPLIM
                TC              RDBADEND        -2
PLENTY          TS              SAMPLIM
                CAF             BIT3
                EXTEND
                RAND            CHAN13                  # TO FIND OUT WHICH RADAR
                EXTEND

                BZF             RENDRAD

LRPOSCHK        CA              RADMODES                # SEE IF LR IN DESIRED POSITION.
                EXTEND
                RXOR            CHAN33
                MASK            BIT6
                EXTEND
                BZF             VELCHK

                TC              ALARM
                OCT             522
                TC              BADRAD

VELCHK          CAF             BIN3                    # = 00003 OCT
                EXTEND
                RXOR            CHAN13                  # RESET ACTIVITY BIT
                MASK            BIN3
                EXTEND
                BZF             LRHEIGHT                # TAKE A LR RANGE READING

                CAF             POSMAX
                MASK            RNRAD
                AD              LVELBIAS
                TS              L
                CAE             RNRAD
                DOUBLE
                MASK            BIT1
                DXCH            ITEMP3

                TC              R77CHECK

                CAF             BIT8                    # DATA GOOD ISNT CHECKED UNTIL AFTER READ-
                TC              DGCHECK                 # ING DATA SO SOME RADAR TESTS WILL WORK
                                                        # INDEPENDENT OF DATA GOOD.

                CCS             NSAMP
                TC              NOEND
GOODRAD         CS              ONE
                TS              SAMPLIM
                CS              ITEMP1                  # WHEN ENOUGH GOOD DATA HAS BEEN GATHERED,
                MASK            RADMODES                # RESET DATA FAIL FLAGS FOR SETTRKF.
                TS              RADMODES
                TC              SETTRKF                 # LAMP MIGHT GO OFF IF DATA JUST GOOD.
                TC              RGOODEND        -2

NOEND           TS              NSAMP
RESAMPLE        CCS             SAMPLIM                 # SEE IF ANY MORE TRIES SHOULD BE MADE.
                TCF             +2
                TCF             DATAFAIL                # N SAMPLES NOT AVAILABLE.
                CAF             BIT4                    # RESET ACTIVITY BIT.
                EXTEND

                WOR             CHAN13                  # RESET ACTIVITY BIT
                TC              RESUME


LRHEIGHT        CAF             BIT5
                TS              ITEMP1                  # (POSITION OF DATA GOOD BIT IN CHAN 33)

                CAF             BIT9
                TC              SCALECHK        -1

RENDRAD         CAF             BIT11                   # MAKE SURE ANTENNA HAS NOT GONE OUT OF
                MASK            RADMODES                # LIMITS.
                CCS             A
                TCF             BADRAD

                CS              RADMODES                # BE SURE RR CDU HASNT FAILED.
                MASK            BIT7
                CCS             A
                TCF             BADRAD

                CAF             BIT4                    # SEE IF DATA HAS BEEN GOOD.
                TS              ITEMP1                  # (POSITION OF DATA GOOD BIT IN CHAN 33)

                CAF             BIT1                    # SEE IF RR RDOT.
                EXTEND
                RAND            CHAN13
                TS              Q                       # FOR LATER TESTING.
                CCS             A
                TCF             +2
                TCF             RADIN                   # NO SCALE CHECK FOR RR RDOT.
                CAF             BIT3
                TS              L

SCALECHK        EXTEND
                RAND            CHAN33                  # SCALE STATUS NOW
                XCH             L
                MASK            RADMODES                # SCALE STATUS BEFORE
                EXTEND
                RXOR            LCHAN                   # SEE IF THEY DIFFER
                CCS             A
                TC              SCALCHNG                # THEY DIFFER

RADIN           CAF             POSMAX
                MASK            RNRAD
                TS              ITEMP4

                CAE             RNRAD
                DOUBLE
                MASK            BIT1
                TS              ITEMP3

                CCS             Q                       # SEE IF RR RDOT.
                TCF             SCALADJ                 # NO, BUT SCALE CHANGING MAY BE NEEDED.

                EXTEND                                  # IF RR RANGE RATE, THROW OUT BIAS.
                DCS             RDOTBIAS
DASAMPL         DAS             ITEMP3
DGCHECK2        TC              R77CHECK
                CA              ITEMP1                  # SEE THAT DATA HAS BEEN GOOD BEFORE AND
                TC              DGCHECK         +1      # AFTER TAKING SAMPLE.
                TC              GOODRAD

SCALCHNG        LXCH            RADMODES
                AD              BIT1
                EXTEND
                RXOR            LCHAN
                TS              RADMODES
                CAF             DGBITS                  # UPDATE LAST VALUE OF DATA GOOD BITS.
                EXTEND
                RAND            CHAN33
                TS              OLDATAGD
                TC              UPFLAG                  # SET RNGSCFLG
                ADRES           RNGSCFLG                # FOR LRS24.1
                TCF             BADRAD

# R77 MUST IGNORE DATA FAILS SO AS NOT TO DISTURB THE ASTRONAUT.

R77CHECK        CA              R77FLBIT
                MASK            FLAGWRD5
                CCS             A
                TC              RGOODEND        -2
                TC              Q

#          THE FOLLOWING ROUTINE INCORPORATES RR RANGE AND LR ALT SCALE INFORMATION AND LEAVES DATA AT LO SCALE.

SCALADJ         CCS             L                       # L HAS SCALE INBIT FOR THIS RADAR.
                TCF             +2                      # ON HIGH SCALE.
                TCF             DGCHECK2

                DXCH            ITEMP3
                DDOUBL
                DDOUBL
                DDOUBL
                DXCH            ITEMP3

                CAF             BIT3                    # SEE IF LR OR RR.
                EXTEND
                RAND            13
                EXTEND                                  # IF RR, NO MORE ACTION REQUIRED.
                BZF             DGCHECK2
                
                CAF             LRRATIO                 # IF LR, CONVERT TO LO SCALING.
                EXTEND
                MP              ITEMP4
                TS              ITEMP4
                CAF             ZERO                    # (SO SUBSEQUENT DAS WILL BE OK)
                XCH             ITEMP3
                EXTEND
                MP              LRRATIO
                TCF             DASAMPL

DGCHECK         TS              ITEMP1                  # UPDATE DATA GOOD BIT IN OLDATAGD AND
                EXTEND                                  # MAKE SURE IT WAS ON BEFORE AND AFTER THE
                RAND            CHAN33                  # SAMPLE WAS TAKEN BEFORE RETURNING. IF
                TS              L                       # NOT, GOES TO RESAMPLE TO TRY AGAIN. IF
                CS              ITEMP1                  # MAX NUMBER OF TRIES HAS BEEN REACHED,
                MASK            OLDATAGD                # THE BIT CORRESPONDING TO THE DATA GOOD
                AD              L                       # WHICH FAILED TO APPEAR IS IN ITEMP1 AND
                XCH             OLDATAGD                # CAN BE USED TO SET RADMODES WHICH VIA
                MASK            ITEMP1                  # SETTRKF SETS THE TRACKER FAIL LAMP.
                AD              L
                CCS             A                       # SHOULD BOTH BE ZERO.
                TC              RESAMPLE
                DXCH            ITEMP3                  # IF DATA GOOD BEFORE AND AFTER, ADD TO
                DAS             SAMPLSUM                # ACCUMULATION.
                TC              Q

DATAFAIL        CS              ITEMP1                  # IN THE ABOVE CASE, SET RADMODES BIT
                MASK            RADMODES                # SHOWING SOME RADAR DATA FAILED.
                AD              ITEMP1
                TS              RADMODES

                DXCH            ITEMP3                  # IF WE HAVE BEEN UNABLE TO GATHER N
                DXCH            SAMPLSUM                # SAMPLES, USE LAST ONE ONLY.

                TC              SETTRKF

                TCF             NOMORE

LRRATIO         DEC             4.9977  B-3
LVELBIAS        DEC             -12288                  # LANDING RADAR BIAS FOR 153.6 KC.
RDOTBIAS        2DEC            17000                   # BIAS COUNT FOR RR RANGE RATE

# THIS ROUTINE CHANGES THE LR POSITION, AND CHECKS THAT IT GOT THERE.

                SETLOC          P20S1
                BANK

                COUNT*          $$/RSUB
LRPOS2          INHINT

                CS              BIT6                    # DESIRED LR POSITION IS NOW 2.
                MASK            RADMODES
                AD              BIT6
                TS              RADMODES
                
                CAF             BIT7
                EXTEND
                RAND            33                      # SEE IF ALREADY THERE.
                EXTEND
                BZF             RADNOOP
                
                CAF             BIT13
                EXTEND
                WOR             CHAN12                  # COMMAND TO POSITION 2
                
                CAF             6SECS                   # START SCANNING FOR INBIT AFTER 7 SECS.
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           LRPOSCAN
                
                TC              ROADBACK

LRPOSNXT        TS              SAMPLIM
                TC              FIXDELAY                # SCAN ONCE PER SECOND 15 TIMES MAX AFTER
                DEC             100                     # INITIAL DELAY OF 7 SECONDS.

                CAF             BIT7                    # SEE IF LR POS2 IS ON
                EXTEND
                RAND            CHAN33
                EXTEND
                BZF             LASTLRDT                # IF THERE, WAIT FINAL SECOND FOR BOUNCE.

                CCS             SAMPLIM                 # SEE IF MAX TIME UP.
                TCF             LRPOSNXT

                CS              BIT13                   # IF TIME UP, DISABLE COMMAND AND ALARM.
                EXTEND
                WAND            CHAN12

                TC              ALARM                   # LR ANTENNA DIDNT MAKE IT.
                OCT             523
                TCF             RDBADEND

RADNOOP         CAF             ONE                     # NO FURTHER ACTION REQUESTED.
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           RGOODEND

                TC              ROADBACK

LASTLRDT        TC              FIXDELAY                # WAIT ONE SECOND AFTER RECEIPT OF INBIT
                DEC             100                     # TO WAIT FOR ANTENNA BOUNCE TO DIE OUT.

                CS              BIT13                   # REMOVE COMMAND
                EXTEND
                WAND            CHAN12
                TCF             RGOODEND

LRPOSCAN        CAF             BIT5                    # SET UP FOR 15 SAMPLES.
                TCF             LRPOSNXT

6SECS           DEC             600

#          SEQUENCES TO TERMINATE RR OPERATIONS.

ENDRADAR        CAF             BIT7                    # PROLOG TO CHECK RR CDU FAIL BEFORE END.
                MASK            RADMODES
                CCS             A
                TCF             RGOODEND
                TCF             RDBADEND
 -2             CS              ZERO                    # RGOODEND WHEN NOT UNDER WAITLIST CONTROL
                TS              RUPTAGN

RGOODEND        CAF             TWO
                TC              POSTJUMP
                CADR            GOODEND

 -2             CS              ZERO                    # RDBADEND WHEN NOT UNDER WAITLIST.
                TS              RUPTAGN
RDBADEND        CAF             TWO
                TC              POSTJUMP
                CADR            BADEND

BIN3            EQUALS          THREE

# PROGRAM NAME_ LPS20.1 VECTOR EXTRAPOLATION AND LOS COMPUTATION
# MOD. NO.  2      BY  J.D. COYNE    SDC    DATE   12-7-66


# FUNCTIONAL DESCRIPTION_

# 1) EXTRAPOLATE THE LEM AND CSM VECTORS IN ACCORDANCE WITH THE TIME REFERED TO IN CALLER + 1.
# 2) COMPUTES THE LOS VECTOR TO THE CSM, CONVERTS IT TO STABLE MEMBER COORDINATES AND STORES IT IN RRTARGET.
# 3) COMPUTES THE MAGNITUDE OF THE LOS VECTOR AND STORES IT IN MLOSV


# CALLING SEQUENCE       CALL
#                               LPS20.1

# SUBROUTINES CALLED_

# LEMPREC,CSMPREC


# NORMAL EXIT_ RETURN TO CALLER + 2


# ERROR EXITS_ NONE


# ALARMS_ NONE


# OUTPUT_

# LOS VECTOR (HALF UNIT) IN SM COORDINATES STORED IN RRTARGET
# MAGNITUDE OF THE LOS VECTOR (METERS SCALED B-29) STORED IN MSLOV
# RRNBSW CLEARED


# INITIALIZED ERASEABLE

# TDEC1 MUST CONTAIN THE TIME FOR EXTRAPOLATION
# SEE ORBITAL INTEGRATION ROUTINE


# DEBRIS_

# MPAC DESTROYED BY THIS ROUTINE

                BANK            23
                SETLOC          P20S1
                BANK

                COUNT*          $$/LPS20

LPS20.1         STQ             CALL
                                LS21X
                                LEMCONIC                # EXTRAPOLATE LEM
                VLOAD
                                RATT
                STOVL           LMPOS                   # SAVE LM POSITION B-29
                                VATT
                STODL           LMVEL                   # SAVE LM VELOCITY B-7
                                TAT
CSMINT          STCALL          TDEC1
                                CSMCONIC                #  EXTRAPOLATE CSM
                VLOAD           VSU                     # COMPUTE RELATIVE VELOCITY V(CSM) - V(LM)
                                VATT
                                LMVEL
                MXV             VSL1
                                REFSMMAT
                STOVL           LOSVEL
                                RATT
                VSU             RTB
                                LMPOS
                                NORMUNX1
                MXV             VSL1
                                REFSMMAT                # CONVERT TO STABLE MEMBER
                STODL           RRTARGET
                                36D                     # SAVE MAGNITUDE OF LOS VECTOR FOR
                SL*
                                0,1
                STORE           MLOSV                   # VELOCITY CORRECTION IN DESIGNATE
                CLRGO
                                RRNBSW
                                LS21X

# PROGRAM NAME_ LPS20.2 400 NM RANGE CHECK
# MOD. NO. 2   BY J.D. COYNE    SDC    DATE  12-7-66


# FUNCTIONAL DESCRIPTION_

# COMPARES THE MAGNITUDE OF THE LOS VECTOR TO 400 NM


# CALLING SEQUENCE       CALL
#                               LPS20.2


# SUBROUTINES CALLED_ NONE


# NORMAL EXIT _ RETURN TO CALLER +1, MPAC EQ 0 (RANGE 400NM OR LESS.)


# ERROR EXITS _ RETURN TO CALLER +1, MPAC EQ 1 (RANGE GREATER THAN 400NM)


# ALARMS_ NONE


# OUTPUT_ NONE


# INITIALIZED ERASEABLE_

# PDL 36D MUST CONTAIN THE MAGNITUDE OF THE VECTOR
# DEBRIS

# MPAC DESTROYED BY THIS ROUTINE

                SETLOC          P20S1
                BANK
                COUNT*          $$/LPS20

LPS20.2         DLOAD           DSU
                                MLOSV                   # MAGNITUDE OF LOS
                                FHNM                    # OVER 400NM  _
                BPL
                                TOFAR
                SLOAD           RVQ
                                ZERO/SP
TOFAR           SLOAD           RVQ
                                ONE/SP
ONE/SP          DEC             1

FHNM            2DEC            740798          B-29    # 400 NAUTICAL MILES IN METERS B-20

# PROGRAM NAME: LRS22.1 (DATA READ SUBROUTINE 1)
# MOD. NO.: 1       BY:  P. VOLANTE  SDC           DATE:  11-15-66


# FUNCTIONAL DESCRIPTION

# 1) READS RENDEZVOUS RADAR RANGE AND RANGE-RATE,TRUNION AND SHAFT ANGLES,THREE CDU VALUES AND TIME. CONVERTS THIS
# DATA AND LEAVES IT FOR THE MEASUREMENT INCORPORATION ROUTINE (LSR22.3). CHECKS FOR THE RR DATA GOOD DISCRETE,FOR
# RR REPOSITION AND RR CDU FAIL

# 2) COMPARES RADAR LOS WITH LOS COMPUTED FROM STATE VECTORS TO SEE IF THEY ARE WITHIN THREE DEGREES


# CALLING SEQUENCE: BANKCALL FOR LRS22.1


# SUBROUTINES CALLED:

#        RRRDOT   LPS20.1
#        RRRANGE  BANKCALL
#        RADSTALL CDULOGIC
#        RRNB     SMNB
# NORMAL EXIT: RETURN TO CALLER+1 WITH MPAC SET TO +0


# ERROR EXITS: RETURN TO CALLER+1 WITH ERROR CODE STORED IN MPAC AS FOLLOWS:

#              00001-ERROR EXIT 1-RR DATA NO GOOD (NO RR DATA GOOD DISCRETE OR RR CDU FAIL OR RR REPOSITION)
#              00002-ERROR EXIT 2-RR LOS NOT WITHIN THREE DEGREES OF LOS COMPUTED FROM STATE VECTORS


# ALARMS:  521-COULD NOT READ RADAR DATA (RR DATA GOOD DISCRETE NOT PRESENT BEFORE AND AFTER READING THE RADAR)
#  (THIS ALARM IS ISSUED BY THE RADAREAD SUBROUTINE WHICH IS ENTERED FROM A RADARUPT)


# OUTPUT: RRLOSVEC- THE RR LINE-OF-SIGHT VECTOR(USED BY LRS22.2)-A HALF-UNIT VECTOR
#         RM- THE RR RANGE READING(TO THE CSM) DP, IN METERS SCALED B-29(USED BY LRS22.2 AND LRS22.3)

#    ALL OF THE FOLLOWING OUTPUTS ARE USED BY LRS22.3:

#         RDOTM- THE RR RANGE-RATE READING,DP, IN METERS PER CENTISECOND, SCALED B-7
#         RRTRUN-RR TRUNION ANGLE,DP,IN REVOLUTIONS,SCALED B0
#         RRSHAFT-RR SHAFT ANGLE,DP,IN REVOLUTIONS,SCALED B0
#         AIG,AMG,AOG-THE CDU ANGLES,THREE SP WORDS
#         MKTIME-THE TIME OF THE RR READING,DP,IN CENTISECONDS


# ERASABLE INITIALIZATION REQUIRED:

#    RNRAD,THE RADAR READ COUNTER FROM WHICH IS OBTAINED:

#     1)RR RANGE SCALED 9.38 FT. PER BIT ON THE LOW SCALE AND 75.04 FT. PER BIT ON THE HIGH SCALE
#     2)RR RANGE RATE,SCALED .6278 FT./SEC. PER BIT

#    THE CDU ANGLES FROM CDUX,CDUY,CDUZ AND TIME1 AND TIME2


# DEBRIS:  LRS22.1X,A,L,Q,PUSHLIST

                BANK            32
                SETLOC          LRS22
                BANK
                COUNT*          $$/LRS22

LRS22.1         TC              MAKECADR
                TS              LRS22.1X
                TC              DOWNFLAG
                ADRES           RNGSCFLG
                INHINT
                CAF             BIT3
                EXTEND                                  # GET RR RANGE SCALE
                RAND            CHAN33                  # FROM CHANNEL 33 BIT 3
                TS              L
                CS              BIT3                    # AND SET IN RADMODES BIT3
                MASK            RADMODES
                AD              L
                TS              RADMODES
                RELINT
READRDOT        TC              BANKCALL
                CADR            RRRDOT                  # READ RANGE-RATE (ONE SAMPLE)
                TC              BANKCALL
                CADR            RADSTALL                # WAIT FOR DATA READ COMPLETION
                TCF             EREXIT1                 # COULD NOT READ RADAR-ERROR EXIT 1

                INHINT                                  # NO INTERRUPTS WHILE READING TIME AND CDU
                EXTEND
                DCA             SAMPLSUM                # SAVE RANGE-RATE READING
                DXCH            RDOTMSAV
                EXTEND
                DCA             CDUY                    # SAVE ICDU ANGLES
                DXCH            AIG
                CA              CDUX
                TS              AOG
                EXTEND
                DCA             TIME2                   #  SAVE TIME
                DXCH            MKTIME                  # SAVE TIME OF CDY READINGS IN MPAC
                EXTEND
                DCA             CDUT                    # SAVE TRUNION AND SHAFT ANGLES FOR RRNB
                DXCH            TANG

                RELINT
                TC              BANKCALL
                CADR            RRRANGE                 # READ RR RANGE (ONE SAMPLE)
                TC              BANKCALL
                CADR            RADSTALL                # WAIT FOR READ COMPLETE
                TC              CHEXERR                 # CHECK FOR ERRORS DURING READ
                TC              INTPRET
                DLOAD           SL
                                RDOTMSAV                # CONVERT RDOT UNITS AND SCALING
                                14D                     # FT./SECOND PER BIT
                DMPR                                    # START WITH READING SCALED B-28, -.6278
                                RDOTCONV                # END WITH METERS/CENTISECOND, B-7
                STODL           RDOTM                   # STORE FOR USE BY LSR22.3
                                TANG
                STORE           TANGNB
                SLOAD           RTB
                                TANG                    # GET TRUNION ANGLE
                                CDULOGIC                # CONVERT TO DP ONES COMP. IN REVOLUTIONS
                STORE           RRTRUN                  # AND SAVE FOR TMI ROUTINE (LSR22.3)
                SLOAD           RTB
                                TANG            +1      # DITTO FOR SHAFT ANGLE
                                CDULOGIC
                STODL           RRSHAFT
                                SAMPLSUM
                DMP             SL2R                    # CONVERT UNITS AND SCALING OF RANGE
                                RANGCONV                # PER BIT, END WITH METERS,SCALED -29
                STCALL          RM
                                RRNB                    # COMPUTE RADAR LOS USING RRNB
                STODL           RRBORSIT                # AND SAVE
                                MKTIME
                STCALL          TDEC1                   # GET STATE VECTOR LOS AT TIME OF CDU READ
                                LPS20.1
                EXIT
                CA              AIG                     # STORE IMU CDU ANGLES AT MARKTIME
                TS              CDUSPOT                 # IN CDUSPOT FOR TRG*SMNB
                CA              AMG
                TS              CDUSPOT         +2
                CA              AOG
                TS              CDUSPOT         +4
                TC              INTPRET
                VLOAD           CALL                    # LOAD VECTOR AND CALL TRANSFORMATION
                                RRTARGET
                                TRG*SMNB                # ROTATE LOS AT MARKTIME FROM SM TO NB.
                DOT                                     # DOT WITH RADAR LOS TO GET ANGLE
                                RRBORSIT
                SL1             ACOS                    # BETWEEN THEM
                STORE           DSPTEM1                 # STORE FOR POSSIBLE DISPLAY
                DSU             BMN                     # IS IT LESS THAN 3 DEGREES
                                THREEDEG
                                NORMEXIT                # YES-NORMAL EXIT


                EXIT                                    # ERROR EXIT 2
                CAF             BIT2                    # SET ERROR CODE
                TS              MPAC
                TCF             OUT22.1

NORMEXIT        EXIT                                    # NORMAL EXIT-SET MPAC EQUAL ZERO
                CAF             ZERO
                TS              MPAC
OUT22.1         CAE             LRS22.1X                # EXIT FROM LRS22.1
                TC              BANKJUMP
CHEXERR         CAE             FLAGWRD5
                MASK            RNGSCBIT
                CCS             A                       # CHECK IF RANGE SCALE CHANGED
                TCF             READRDOT                # YES-TAKE ANOTHER READING

EREXIT1         CA              BIT1                    # SET ERROR CODE
                TS              MPAC
                TC              OUT22.1

RDOTCONV        2DEC            -.0019135344    B7      # CONVERTS RR RDOT READING TO M/CS AT 2(7)
RANGCONV        2DEC            2.859024        B-3     # CONVERTS RR RANGE READING TO M. AT 2(-29
THREEDEG        2DEC            .008333333              # THREE DEGREES,SCALED  REVS,B0
RRLOSVEC        EQUALS          RRTARGET

# PROGRAM NAME - LRS22.2 (DATA READ SUBROUTINE 2)


# MOD. NO. : 1       BY: P VOLANTE  SDC           DATE  4-11-67
#
# FUNCTIONAL DESCRIPTION-

##   (Yes, I know point #1 is missing.  It is missing from the program listing -- RSB 2003)
#    2) CHECKS IF THE RR LOS (I.E. THE RADAR BORESIGHT VECTOR) IS WITHIN 30 DEGREES OF THE LM +Z AXIS


# CALLING SEQUENCE- BANKCALL FOR LRS22.2


# SUBROUTINES CALLED: G+N,AUTO   SETMAXDB
# NORMAL EXIT - RETURN TO CALLER WITH MPAC SET TO +0 (VIA SWRETURN)


# ERROR EXIT - RETURN TO CALLER WITH MPAC SET TO 00001 -RADAR LOS NOT WITHIN 30 DEGREES OF LM +Z AXIS


# ALARMS - NONE                                                            IN THE AUTO MODE


# ERASABLE INITIALIZATION REQUIRED -
#      RRLOSVEC - THE RR LINE-OF-SIGHT VECTOR-A HALF UNIT VECTOR COMPUTED BY LRS22.1
#      RM - RR RANGE, METERS B-29, FROM LRS22.1
#      BIT 14 CHANNEL 31 -INDICATES AUTOPILOT IS IN AUTO MODE


# DEBRIS -  A,L,Q MPAC -PUSHLIST AND PUSHLOC ARE NOT CHANGED BY THIS ROUTINE

                SETLOC          P20S1
                BANK
LRS22.2         TC              MAKECADR
                TS              LRS22.1X
                TC              INTPRET
                                                        # CHECK IF RR LOS IS WITHIN 30 DEG OF
30DEGCHK        DLOAD           ACOS                    # THE SPACECRAFT +Z AXIS
                                RRBORSIT        +4      # BY TAKING ARCCOS OF Z-COMP. OF THE RR
                                                        # LOS VECTOR,A HALF UNIT VECTOR
                                                        # IN NAV BASE AXES)
                DSU             BMN
                                30DEG
                                OKEXIT                  # NORMAL EXIT-WITHIN 30 DEG.
                EXIT                                    # ERROR EXIT-NOT WITHIN 30 DEG.
                CAF             BIT1                    # SET ERROR CODE IN MPAC
                TS              MPAC
                TCF             OUT22.2
OKEXIT          EXIT                                    # NORMAL EXIT-SET MPAC = ZERO

                CAF             ZERO
                TS              MPAC
OUT22.2         CAE             LRS22.1X
                TC              BANKJUMP

30DEG           2DEC            .083333333              # THIRTY DEGREES,SCALED REVS,B0

# PROGRAM NAME - LSR22.3                                                  DATE - 29 MAY 1967
# MOD. NO 3                                                               LOG SECTION - P20-25
# MOD. BY - DANFORTH                                                      ASSEMBLY LEMP20S REV 10

# FUNCTIONAL DESCRIPTION

# THIS ROUTINE COMPUTES THE B-VECTORS AND DELTA Q FOR EACH OF THE QUANTITIES MEASURED BY THE RENDEZVOUS
# RADAR.(RANGE,RANGE RATE,SHAFT AND TRUNNION ANGLES). THE ROUTINE CALLS THE INCORP1 AND INCORP2 ROUTINES
# WHICH COMPUTE THE DEVIATIONS AND CORRECT THE STATE VECTOR.

# CALLING SEQUENCE
# THIS ROUTINE IS PART OF P20 RENDEZVOUS NAVIGATION FOR THE LM COMPUTER O NLY. THE ROUTINE IS ENTERED FROM
# R22LEM  ONLY AND RETURNS DIRECTLY TO R22LEM  FOLLOWING SUCCESSFUL INCORPORATION OF MEASURED DATA. IF THE
# COMPUTED STATE VECTOR DEVIATIONS EXCEED THE MAXIMUM PERMITTED. THE ROUTINE RETURNS TO R22LEM  TO DISPLAY
# THE DEVIATIONS. IF THE ASTRONAUT ACCEPTS THE DATA R22LEM  RETURNS TO    LSR22.3 TO INCORPORATE THE
# DEVIATIONS INTO THE STATE VECTOR. IF THE ASTRONAUT REJECTS THE DEVIATIONS, NO MORE MEASUREMENTS ARE
# PROCESSED FOR THIS MARK,I.E.,R22LEM  GETS THE NEXT MARK.

#
# SUBROUTINES CALLED
#  WLINIT     LGCUPDTE     INTEGRV     INCORP1     ARCTAN
#  GETULC     RARARANG     INCORP2     NBSM        INTSTALL
#
# OUTPUT
#  CORRECTED LM OR CSM STATE VECTOR (PERMANENT)
#  NUMBER OF MARKS INCORPORATED IN MARKCTR
#  MAGNITUDE OF POSITION DEVIATION (FOR DISPLAY) IN R22DISP METERS B-29
#  MAGNITUDE OF VELOCITY DEVIATION (FOR DISPLAY) IN R22DISP +2 M/CSEC B-7
#  UPDATED W-MATRIX
#

# ERASABLE INITIALIZATION REQUIRED
#  LM AND CSM STATE VECTORS
#  W-MATRIX
#  MARK TIME IN MKTIME
#  RADAR RANGE IN RM METERS B-29
#        RANGE RATE IN RDOTM METERS/CSES B-7
#        SHAFT ANGLE IN RRSHAFT REVS.B0
#        TRUNNION ANGLE IN RRTRUN REVS. B0
#  GIMBAL ANGLES  INNER IN AIG
#                 MIDDLE IN AMG
#                 OUTER IN AOG
#  REFSMMAT
#  RENDWFLG
#  NOANGFLG
#  VEHUPFLG

# DEBRIS
#  PUSHLIST--ALL
#  MX, MY, MZ  (VECTORS)

#  ULC,RXZ,SINTHETA,LGRET,RDRET,BVECTOR,W.IND,X78T

                BANK            13
                SETLOC          P20S3
                BANK

                EBANK=          LOSCOUNT
                COUNT*          $$/LSR22
LSR22.3         CALL
                                GRP2PC
                BON             SET
                                SURFFLAG                # ARE WE ON LUNAR SURFACE
                                LSR22.4                 # YES
                                DMENFLG
                BOFF            CALL
                                VEHUPFLG
                                DOLEM
                                INTSTALL
                CLEAR           CALL                    # LM PRECISION INTEGRATION
                                VINTFLAG
                                SETIFLGS
                CALL
                                INTGRCAL
                CALL
                                GRP2PC
                CALL
                                INTSTALL
                CLEAR           BOFF
                                DIM0FLAG
                                RENDWFLG
                                NOTWCSM
                SET             SET                     # CSM WITH W-MATRIX INTEGRATION
                                DIM0FLAG
                                D6OR9FLG
NOTWCSM         SET             CLEAR
                                VINTFLAG
                                INTYPFLG
                SET             CALL
                                STATEFLG
                                INTGRCAL
                GOTO
                                MARKTEST
DOLEM           CALL
                                INTSTALL
                SET             CALL
                                VINTFLAG
                                SETIFLGS
                CALL
                                INTGRCAL

                CALL
                                GRP2PC
                CALL
                                INTSTALL
                CLEAR           BOFF
                                DIM0FLAG
                                RENDWFLG
                                NOTWLEM
                SET             SET                     # LM WITH W-MATRIX INTEGRATION
                                DIM0FLAG
                                D6OR9FLG
NOTWLEM         CLEAR           CLEAR
                                INTYPFLG
                                VINTFLAG
                SET             CALL
                                STATEFLG
                                INTGRCAL
MARKTEST        BON             CALL                    # HAS W-MATRIX BEEN INVALIDATED
                                RENDWFLG                # HAS W-MATRIX BEEN INVALIDATED
                                RANGEBQ
                                WLINIT                  # YES - REINITIALIZE

RANGEBQ         AXT,2           BON                     # CLEAR X2.
                                0
                                LMOONFLG                # IS MOON SPHERE OF INFLUENCE
                                SETX2                   # YES. STORE ZERO IN SCALSHFT REGISTER
                INCR,2
                                2
SETX2           SXA,2           CALL
                                SCALSHFT                # 0-MOON. 2-EARTH
                                GRP2PC
                CALL                                    # BEGIN COMPUTING THE B-VECTORS, DELTAQ
                                GETULC                  # B-VECTORS FOR RANGE
                BON             VCOMP                   # B0, COMP. IF LM BEING CORRECTED
                                VEHUPFLG
                                +1
                STOVL           BVECTOR
                                ZEROVECS
                STORE           BVECTOR         +6      # B1

                STODL           BVECTOR         +12D    # B2
                                36D
                SRR*            BDSU
                                2,2                     # SHIFT FROM EARTH/MOON SPHERE TO B-29
                                RM                      # RM - (MAGNITUDE RCSM-RLM)
                SLR*
                                2,2                     # SHIFT TO EARTH/MOON SPHERE
                STODL           DELTAQ                  # EARTH B-29. MOON B-27
                                36D                     # RLC B-29/B-27
                NORM            DSQ                     # NORMALIZE AND SQUARE
                                X1
                DMP             SR*
                                RANGEVAR                # MULTIPLY BY RANGEVAR(B12) THEN
                                0 -2,1                  # UNNORMALIZE
                SR*             SR*
                                0,1
                                0,2
                SR*             RTB
                                0,2
                                TPMODE
                STORE           VARIANCE                # B-40
                DCOMP           TAD
                                RVARMIN                 #   B-40
                BMN             TLOAD
                                QOK
                                RVARMIN                 #   B-40
                STORE           VARIANCE
QOK             CALL
                                LGCUPDTE

                CALL
                                GRP2PC
                CALL                                    # B-VECTOR,DELTAQ FOR RANGE RATE
                                GETULC
                PDDL            SR*                     # GET RLC SCALED B-29/B-27
                                36D                     # AND SHIFT TO B-23
                                0 -7,2
                STOVL           36D                     # THEN STORE BACK IN 36D
                BON             VCOMP                   # B1, COMP. IF LM BEING CORRECTED
                                VEHUPFLG
                                +1
                VXSC
                                36D                     # B1 = RLC (B-24/B-22)
                STOVL           BVECTOR         +6
                                NUVLEM
                VSR*            VAD
                                6,2                     # SHIFT FOR EARTH/MOON SPHERE
                                VCVLEM                  # EARTH B-7. MOON B-5
                PDVL            VSR*                    # VL TO PD6
                                NUVCSM

                                6,2                     # SHIFT FOR EARTH/MOON SPHERE
                VAD             VSU
                                VCVCSM
                PDVL            DOT                     # VC - VL = VLC TO PD6
                                0
                                6
                PUSH            SRR*                    # RDOT B-8/B-6 TO PD12
                                2,2                     # SHIFT FROM EARTH/MOON SPHERE TO B-8
                DSQ             DMPR                    # RDOT**2 B-16 X RATEVAR B12
                                RATEVAR
                DMPR            DMP
                                36D
                                36D
                VSL4            RTB
                                TPMODE
                STORE           VARIANCE
                DLOAD           DSQ
                                36D
                DMP             RTB
                                VVARMIN
                                TPMODE
                STORE           30D
                DCOMP           TAD
                                VARIANCE
                BPL             TLOAD
                                +3
                                30D
                STORE           VARIANCE
VOK             DLOAD           SR2                     # RDOT(PD12) FROM B-8/B-6
                PDDL            SLR*                    # TO B-10/B-8
                                RDOTM                   # SHIFT TO EARTH/MOON SPHERE
                                0 -1,2                  # B-7 TO B-10/B-8
                DSU
                DMPR
                                36D
                STOVL           DELTAQ                  #   B-33
                                0                       # NOW GET B0
                VXV             VXV                     # (ULC X VLC) X ULC
                BON             VCOMP                   # B0, COMP. IF LM BEING CORRECTED
                                VEHUPFLG
                                +1
                BOVB            VSR*
                                TCDANZIG
                                0 -5,2                  # SCALED B-5
                BOV             GOTO
                                VOK1
                                VOK2
VOK1            VLOAD
                                ZEROVECS
VOK2            STOVL           BVECTOR
                                ZEROVECS
                STCALL          BVECTOR +12D
                                LGCUPDTE

                CALL
                                GRP2PC
                BON             EXIT                    # ARE ANGLES TO BE DONE
                                SURFFLAG
                                RENDEND                 # NO
                EBANK=          AIG
MXMYMZ          CAF             AIGBANK
                TS              BBANK
                CA              AIG                     # YES, COMPUTE  MX, MY, MZ
                TS              CDUSPOT
                CA              AMG
                TS              CDUSPOT         +2
                CA              AOG
                TS              CDUSPOT         +4      # GIMBL ANGLES NOW IN CDUSPOT FOR TRG*NBSM
                TC              INTPRET
                VLOAD           CALL
                                UNITX
                                TRG*NBSM
                VXM             VSL1
                                REFSMMAT
                STOVL           MX
                                UNITY

                CALL
                                *NBSM*
                VXM             VSL1
                                REFSMMAT
                STOVL           MY
                                UNITZ
                CALL
                                *NBSM*
                VXM             VSL1
                                REFSMMAT
SHAFTBQ         STCALL          MZ
                                RADARANG
                CALL
                                GRP2PC
                VLOAD           DOT                     # COMPUTE DELTAQ,B VECTORS FOR SHAFT ANG.
                                ULC
                                MX
                SL1
                STOVL           SINTH                   # 18D
                                ULC
                DOT             SL1
                                MZ
                STCALL          COSTH                   # 16D
                                ARCTAN
                BDSU            DMP
                                RRSHAFT
                                2PI/8
                SL3R            PUSH
                DLOAD           SL3
                                X789
                SRR*            BDSU                    # SHIFT FROM -5/-3 TO B0
                                0,2
                DMP             SRR*
                                RXZ
                                0,1                     # SHIFT TO EARTH/MOON SPHERE
                STOVL           DELTAQ                  # EARTH B-29. MOON B-27
                                ULC
                VXV             VSL1
                                MY
                UNIT
                BOFF            VCOMP                   # B0, COMP. IF CSM BEING CORRECTED
                                VEHUPFLG
                                +1
                STOVL           BVECTOR
                                ZEROVECS
                STORE           BVECTOR         +6
                STODL           BVECTOR         +12D
                                RXZ
                SR*             SRR*                    # SHIFT FROM EARTH/MOON SPHERE TO B-25
                                0 -2,1

                                0,2
                STORE           BVECTOR +12D
                SLOAD
                                SHAFTVAR
                DAD             DMP
                                IMUVAR                  # RAD**2 B12
                                RXZ
                SRR*            DMP
                                0,1                     # SHIFT TO EARTH/MOON SPHERE
                                RXZ
                SR*             SR*
                                0 -2,1
                                0,2
                SR*             RTB
                                0,2
                                TPMODE                  # STORE VARIANCE TRIPLE PRECISION
                STCALL          VARIANCE                # B-40
                                LGCUPDTE

                CALL
                                GRP2PC
TRUNBQ          CALL
                                RADARANG
                CALL
                                GRP2PC
                VLOAD           VXV
                                ULC
                                MY
                VSL1            VXV
                                ULC
                VSL1                                    # (ULC X MY) X ULC
                BOFF            VCOMP                   # B0, COMP. IF CSM BEING CORRECTED
                                VEHUPFLG
                                +1
                STOVL           BVECTOR
                                ZEROVECS
                STORE           BVECTOR         +6
                STODL           BVECTOR         +12D
                                RXZ
                SR*             SRR*                    # SHIFT FROM EARTH/MOON SPHERE TO B-25
                                0 -2,1
                                0,2
                STORE           BVECTOR         +14D
                SLOAD
                                TRUNVAR
                DAD             DMP
                                IMUVAR
                                RXZ
                SRR*            DMP
                                0,1                     # SHIFT TO EARTH/MOON SPHERE

                                RXZ
                SR*             SR*
                                0 -2,1
                                0,2
                SR*             RTB
                                0,2
                                TPMODE                  # STORE VARIANCE TRIPLE PRECISION
                STODL           VARIANCE
                                SINTHETA
                ASIN            BDSU                    # SIN THETA IN PD6
                                RRTRUN
                DMP             SL3R
                                2PI/8
                PDDL            SL3
                                X789            +2
                SRR*            BDSU                    # SHIFT FROM -5/-3 TO B0
                                0,2
                DMP             SRR*
                                RXZ
                                0,1
                STCALL          DELTAQ                  # EARTH B-29. MOON B-27
                                LGCUPDTE
                CALL
                                GRP2PC
RENDEND         GOTO
                                R22LEM93
# FUNCTIONAL DESCRIPTION

# LSR22.4 IS THE ENTRY TO PERFORM LUNAR SURFACE NAVIGATION FOR THE LM
# COMPUTER ONLY. THIS ROUTINE COMPUTES THE B-VECTORS AND DELTA Q FOR RANGE
# AND RANGE RATE MEASURED BY THE RENDEZVOUS RADAR

# SUBROUTINES CALLED
#  INSTALL   LGCUPDTE  INCORP1   RP-TO-R
#  INTEGRV   GETULC    INCORP2

# OUTPUT
#  CORRECTED CSM STATE VECTOR (PERMANENT)
#  NUMBER OF MARKS INCORPORATED IN MARKCTR
#  MAGNITUDE OF POSITION DEVIATION (FOR DISPLAY) IN R22DISP METERS B-29
#  MAGNITUDE OF VELOCITY DEVIATION (FOR DISPLAY) IN R22DISP +2 M/CSEC B-7
#  UPDATED W-MATRIX

# ERASABLE INITIALIZATION REQUIRED
#  LM AND CSM STATE VECTORS
#  W-MATRIX
#  MARK TIME IN MKTIME
#  RADAR RANGE IN RM METERS B-29
#        RANGE RATE IN RDOTM METERS/CSEC B-7
#  VEHUPFLG

LSR22.4         CALL
                                INTSTALL
                SET             CLEAR
                                STATEFLG
                                VINTFLAG                # CALL TO GET LM POS + VEL IN REF COORD.
                CALL
                                INTGRCAL
                CALL
                                GRP2PC
                CLEAR           CALL
                                DMENFLG                 # SET MATRIX SIZE TO 6X6 FOR INCORP
                                INTSTALL
                DLOAD           BHIZ                    # IS THIS FIRST TIME THROUGH
                                MARKCTR
                                INITWMX6                # YES. INITIALIZE 6X6 W-MATRIX
                CLEAR           SET
                                D6OR9FLG
                                DIM0FLAG
                SET             CLEAR
                                VINTFLAG
                                INTYPFLG
                CALL
                                INTGRCAL
                GOTO
                                RANGEBQ

INITWMX6        CALL
                                WLINIT                  # INITIALIZE W-MATRIX
                SET             CALL
                                VINTFLAG
                                SETIFLGS
                CALL
                                INTGRCAL
                GOTO
                                RANGEBQ

# THIS ROUTINE CLEARS RFINAL (DP) AND CALLS INTEGRV

INTGRCAL        STQ             DLOAD
                                IGRET
                                MKTIME
                STCALL          TDEC1
                                INTEGRV
                GOTO
                                IGRET

# THIS ROUTINE INITIALIZES THE W-MATRIX BY ZEROING ALL W THEN SETTING
# DIAGONAL ELEMENTS TO INITIAL STORED VALUES.

                EBANK=          W

WLINIT          EXIT
                CAF             WBANK
                TS              BBANK
                CAF             WSIZE
                TS              W.IND
                CAF             ZERO
                INDEX           W.IND
                TS              W
                CCS             W.IND
                TC              -5
                CAF             AIGBANK                 # RESTORE EBANK 7
                TS              BBANK
                TC              INTPRET
                SLOAD           SR                      # SHIFT TO B-19 SCALE
                                WRENDPOS
                                5
                STORE           W
                STORE           W               +8D
                STORE           W               +16D
                SLOAD
                                WRENDVEL
                STORE           W               +72D
                STORE           W               +80D
                STORE           W               +88D
                SLOAD
                                WSHAFT
                STORE           W               +144D
                SLOAD
                                WTRUN
                STORE           W               +152D
                SET             SSP                     # SET RENDWFLG - W-MATRIX VALID
                                RENDWFLG
                                MARKCTR                 # SET MARK COUNTER EQUAL ZERO
                                0
                RVQ

                EBANK=          W

WBANK           BBCON           WLINIT
                EBANK=          AIG
AIGBANK         BBCON           LSR22.3

# GETULC

# THIS SUBROUTINE COMPUTES THE RELATIVE POSITION VECTOR BETWEEN THE CSM
# AND THE LM, LEAVING THE UNIT VECTOR IN THE PUSHLIST AND MPAC AND THE
# MAGNITUDE IN 36D.

GETULC          SETPD           VLOAD
                                0
                                DELTALEM
                LXA,2
                                SCALSHFT                # LOAD X2 WITH SCALE SHIFT
                VSR*            VAD
                                9D,2                    # SHIFT FOR EARTH/MOON SPHERE
                                RCVLEM
                PDVL            VSR*
                                DELTACSM
                                9D,2                    # SHIFT FOR EARTH/MOON SPHERE
                VAD             VSU
                                RCVCSM
                RTB             PUSH                    # USE NORMUNIT TO PRESERVE ACCURACY
                                NORMUNX1
                STODL           ULC
                                36D
                SL*                                     # ADJUST MAGNITUDE FROM NORMUNIT
                                0,1
                STOVL           36D                     # ULC IN PD0 AND MPAC,RLC IN 36D
                                ULC
                RVQ

                PUSH            RVQ

# RADARANG

# THIS SUBROUTINE COMPUTES SINTHETA = -ULC DOT MY
# RXZ = (SQRT (1-SINTHETA**2))RLC
# OUTPUT
#  ULC IN ULC, PD0
#  RLC IN PD36D
#  SIN THETA IN SINTHETA AND PD6
#  RXZ NORM IN RXZ (N IN X1)
RADARANG        STQ             CALL
                                RDRET
                                GETULC
                VCOMP           DOT
                                MY
                SL1R            PUSH                    # SIN THETA TO PD6
                STORE           SINTHETA
                DSQ             BDSU
                                DP1/4TH                 # 1 - (SIN THETA)**2

                SQRT            DMP
                                36D
                SL1             NORM
                                X1                      # SET SHIFT COUNTER IN X1
                STORE           RXZ
                GOTO                                    # EXIT
                                RDRET
LGCUPDTE        STQ             CALL
                                LGRET
                                INCORP1
                VLOAD           ABVAL
                                DELTAX          +6
                LXA,2           SRR*
                                SCALSHFT                # 0 - MOON.  2 - EARTH
                                2,2                     # SET VEL DISPLAY TO B-7
                STOVL           R22DISP         +2
                                DELTAX
                ABVAL           SRR*
                                2,2                     # SET POS DISPLAY TO B-29
                STORE           R22DISP
                SLOAD           SR
                                RMAX
                                10D
                DSU             BMN
                                R22DISP
                                R22LEM96                # GO DISPLAY
                SLOAD           DSU
                                VMAX
                                R22DISP         +2      # VMAX MINUS VEL. DEVIATION
                BMN
                                R22LEM96                # GO DISPLAY
ASTOK           CALL
                                INCORP2
                GOTO
                                LGRET
IMUVAR          2DEC            E-6     B12             # RAD**2

WSIZE           DEC             161
2PI/8           2DEC            3.141592653     B-2
                EBANK=          LOSCOUNT

# PROGRAM NAME LRS24.1   RR SEARCH ROUTINE
# MOD NO  0        BY  P VOLANTE  SDC          DATE 1-15-67


# FUNCTIONAL DESCRIPTION

# DRIVES THE RENDEZVOUS RADAR IN A HEXAGONAL SEARCH PATTERN ABOUT THE LOS TO THE CSM (COMPUTED FROM THE CSM AND LM
# STATE VECTORS) CHECKING FOR THE DATA GOOD DISCRETE AND MONITORING THE ANGLE BETWEEN THE RADAR BORESIGHT AND THE
# LM +Z AXIS. IF THIS ANGLE EXCEEDS 30 DEGREES THE PREFERRED TRACKING ATTITUDE ROUTINE IS CALLED TO PERFORM AN
# ATTITUDE MANEUVER.


# CALLING SEQUENCE - BANKCALL FOR LRS24.1


# SUBROUTINES CALLED

#       LEMCONIC      R61LEM
#       CSMCONIC      RRDESSM
#       JOBDELAY      FLAGDOWN
#       WAITLIST      FLAGUP
#       RRNB          BANKCALL


# EXIT -  TO ENDOFJOB WHEN THE SEARCH FLAG (SRCHOPT) IS NOT SET


# OUTPUT

#     DATAGOOD (SP)-FOR DISPLAY IN R1- 00000 INDICATES NO LOCKON
#                                      11111 INDICATES LOCKON ACHIEVED
#     OMEGAD   (SP)-FOR DISPLAY IN R2- ANGLE BETWEEN RR BORESIGHT VECTOR AND THE SPACECRAFT +Z AXIS

# ERASABLE INITIALIZATION REQUIRED
#    SEARCH FLAG MUST BE SET
#    LM AND CSM STATE VECTORS AND REFSMMAT MATRIX
# DEBRIS

#    RLMSRCH      UXVECT
#    VXRLM        UYVECT
#    LOSDESRD     NSRCHPNT
#    DATAGOOD     OMEGAD
#    MPAC         PUSHLIST

                COUNT*          $$/LRS24
LRS24.1         CAF             ZERO
                TS              NSRCHPNT                # SET SEARCH PATTERN POINT COUNTER TO ZERO
CHKSRCH         CAF             BIT14                   # ISSUE AUTO TRACK ENABLE TO RADAR
                EXTEND

                WOR             CHAN12
                CAF             SRCHOBIT                # CHECK IF SEARCH STILL REQUESTED
                MASK            FLAGWRD2                # (SRCHOPT FLAG SET)
                EXTEND
                BZF             ENDOFJOB                # NO-TERMINATE JOB

                CAF             MANUFBIT
                MASK            FLAGWRD7
                CCS             A
                TC              ENDOFJOB

                CAF             6SECONDS                # SCHEDULE TASK TO DRIVE RADAR TO NEXT PT.
                INHINT
                TC              WAITLIST                # IN 6 SECONDS
                EBANK=          LOSCOUNT
                2CADR           CALLDGCH
                RELINT
                CS              RADMODES                # IS REMODE IN PROGRESS
                MASK            BIT14                   # (BIT 14 RADMODES = 1)
                EXTEND
                BZF             ENDOFJOB                # YES- WAIT SIX SECONDS
                TC              INTPRET

                RTB
                                LOADTIME
LRS24.11        STCALL          TDEC1
                                LEMCONIC                # EXTRAPOLATE LM STATE VECTOR
                VLOAD
                                RATT
                STOVL           RLMSRCH                 # SAVE LEM POSITION
                                VATT
                STODL           SAVLEMV                 # SAVE LEM VELOCITY
                                TAT
                STCALL          TDEC1                   # EXTRAPOLATE CSM STATE VECTOR
                                CSMCONIC                # EXTRAPOLATE CSM STATE VECTOR
                VLOAD           VSU                     # LOS VECTOR = R(CSM)-R(LM)
                                RATT
                                RLMSRCH
                UNIT
                STOVL           LOSDESRD                # STORE DESIRED LOS
                                VATT                    # COMPUTE UNIT(V(CM) CROSS R(CM))
                UNIT            VXV
                                RATT
                UNIT
                STORE           VXRCM
                VLOAD           VSU
                                VATT
                                SAVLEMV
                MXV             VSL1                    # CONVERT FROM REFERENCE TO STABLE MEMBER
                                REFSMMAT
                STORE           SAVLEMV                 # VLC = V(CSM) - V(LM)
                SLOAD           BZE                     # CHECK IF N=0
                                NSRCHPNT

                                DESGLOS                 # YES-DESIGNATE ALONG LOS
                DSU             BZE                     # IS N=1
                                ONEOCT                  # YES-CALCULATE X AND Y AXES OF
                                CALCXY                  # SEARCH PATTERN COORDINATE SYSTEM
                VLOAD                                   # NO-ROTATE X-Y AXES TO NEXT SEARCH POINT
                                UXVECT
                STOVL           UXVECTPR                # SAVE ORIGINAL X AND Y VECTORS
                                UYVECT                  # UXPRIME = ORIGINAL UX
                STORE           UYVECTPR                # UYPRIME = ORIGINAL UY
                VXSC
                                SIN60DEG                # UX =(COS 60)UXPR +(SIN 60)UYPR
                STOVL           UXVECT
                                UXVECTPR
                VXSC            VAD
                                COS60DEG
                                UXVECT
                UNIT
                STOVL           UXVECT
                                UXVECTPR                # UY=(-SIN 60)UXPR +(COS 60)UYPR
                VXSC
                                SIN60DEG
                STOVL           UYVECT
                                UYVECTPR
                VXSC            VSU
                                COS60DEG
                                UYVECT
                UNIT
                STORE           UYVECT
OFFCALC         VXSC            VAD                     # OFFSET VECTOR = K(UY)
                                OFFSTFAC                # LOS VECTOR + OFFSET VECTOR DEFINES
                                LOSDESRD                # DESIRED POINT IN SEARCH PATTERN
                UNIT            MXV
                                REFSMMAT                # CONVERT TO STABLE MEMBER COORDINATES
                VSL1
CONTDESG        STOVL           RRTARGET
                                SAVLEMV
                STORE           LOSVEL
                EXIT
                INHINT
                TC              KILLTASK                # KILL ANY PRESENTLY WAITLISTED TASK
                CADR            DESLOOP         +2      # WHICH WOULD DESIGNATE TO THE LAST

                CS              FLAGWRD7
                MASK            MANUFBIT
                EXTEND
                BZF             ENDOFJOB
                                                        # POINT IN THE PATTERN
CONTDES2        CS              BIT15
                MASK            RADMODES                # SET BIT 15 OF RADMODES TO INDICATE
                AD              BIT15                   # A CONTINUOUS DESIGNATE WANTED
                TS              RADMODES
                RELINT
                TC              INTPRET

                CALL
                                RRDESSM                 # DESIGNATE RADAR TO RRTARGET VECTOR


                EXIT
                TC              LIMALARM                # LOS NOT IN MODE 2 COVERAGE (P22)
                TC              LIMALARM                # VEHICLE MANEUVER REQUIRED (P20)


                                                        # COMPUTE OMEGA,ANGLE BETWEEN RR LOS AND
                                                        # SPACECRAFT +Z AXIS
                INHINT
OMEGCALC        EXTEND
                DCA             CDUT
                DXCH            TANGNB
                RELINT
                TC              INTPRET
                CALL
                                RRNB
                DLOAD           ACOS                    # OMEGA IS ARCCOSINE OF Z-COMPONENT OF
                                36D                     # VECTOR COMPUTED BY RRNB (LEFT AT 32D)
                STORE           OMEGDISP                # STORE FOR DISPLAY IN R2
                EXIT
                TC              ENDOFJOB

# CALCULATE X AND Y VECTORS FOR SEARCH PATTERN COORDINATE SYSTEM


CALCXY          VLOAD           VXV
                                VXRCM
                                LOSDESRD
                UNIT
                STOVL           UXVECT                  # UX = (VLM X RLM) X LOS
                                LOSDESRD
                VXV             UNIT
                                UXVECT
                STORE           UYVECT                  # UY = LOS X UX
                GOTO
                                OFFCALC


DESGLOS         VLOAD           MXV                     # WHEN N= 0,DESIGNATE ALONG LOS
                                LOSDESRD
                                REFSMMAT                # CONVERT LOS FROM REFERENCE TO SM COORDS
                VSL1            GOTO
                                CONTDESG


CALLDGCH        CAE             FLAGWRD0                # IS RENDEZVOUS FLAG SET
                MASK            RNDVZBIT
                EXTEND
                BZF             TASKOVER                # NO-EXIT R24
                CAF             PRIO25                  # YES-SCHEDULE JOB TO DRIVE RADAR TO NEXT
                TC              FINDVAC                 # POINT IN SEARCH PATTERN
                EBANK=          RLMSRCH
                2CADR           DATGDCHK
                TC              TASKOVER


DATGDCHK        CAF             BIT4
                EXTEND                                  # CHECK IF DATA GOOD DISCRETE PRESENT
                RAND            CHAN33
                EXTEND
                BZF             STORE1S                 # YES- GO TO STORE 11111 FOR DISPLAY IN R1
                CS              SIX
                AD              NSRCHPNT                # IS N GREATER THAN 6
                EXTEND
                BZF             LRS24.1                 # YES - RESET N = 0 AND START AROUND AGAIN
                INCR            NSRCHPNT                # NO-SET N = N+1 AN GO TO
                TCF             CHKSRCH                 # NEXT POINT IN PATTERN


STORE1S         CAF             ALL1S                   # STORE 11111 FOR DISPLAY IN R1
                TS              DATAGOOD

                INHINT
                TC              KILLTASK                # DELETE DESIGNATE TASK FROM
                CADR            DESLOOP         +2      # WAITLIST USING KILLTASK
                TC              ENDOFJOB

LIMALARM        TC              ALARM                   # ISSUE ALARM 527- LOS NOT IN MODE2
                OCT             527                     # COVERAGE IN P22 OR VEHICLE MANEUVER
                INHINT                                  # REQUIRED IN P20
                TC              KILLTASK                # KILL WAITLIST CALL FOR NEXT
                CADR            CALLDGCH                # POINT IN SEARCH PATTERN
                TC              ENDOFJOB


ALL1S           DEC             11111
SIN60DEG        2DEC            .86603
COS60DEG        =               DPHALF                  # (2DEC   .50)
UXVECTPR        EQUALS          12D                     # PREVIOUS
UYVECTPR        EQUALS          18D
RLMUNIT         EQUALS          12D
OFFSTFAC        2DEC            0.05678                 # TANGENT OF 3.25 DEGREES
ONEOCT          OCT             00001                   # ****  NOTE-THESE TWO CONSTANTS MUST ****
3SECONDS        2DEC            300                     # ****  BE IN THIS ORDER BECAUSE      ****
                                                        # ****  ONEOCT NEEDS A LOWER ORDER    ****
                                                        # ****  WORD OF ZEROES                ****
6SECONDS        DEC             600
DEC50           DEC             50
# ********************************
#
# TEST PROGRAM FOR LSR22.3 --- TO BE REMOVED
# ********************************

                BANK            27

                EBANK=          AIG
                COUNT*          $$/RTEST
TEST22.3        CAF             ZERO
                TS              LONG
LOOP22.3        TC              INTPRET
                LXC,2           DLOAD*
                                LONG
                                JOBOVER         +1,2
                STORE           AIG
                DLOAD*
                                JOBOVER         +2,2
                STORE           AMG
                DLOAD*

                                JOBOVER         +4,2
                STORE           MKTIME
                DLOAD*
                                JOBOVER         +6,2
                STORE           RM
                DLOAD*
                                JOBOVER         +8D,2
                STORE           RDOTM
                DLOAD*
                                JOBOVER         +10D,2
                STORE           RRSHAFT
                DLOAD*
                                JOBOVER         +12D,2
                STORE           RRTRUN
                CALL
                                LSR22.3
22.3ENT         EXIT
                CA              LONG
                AD              DEC13T
                TS              LONG
                CCS             LONG            +1
                TC              +2
STOP22.3        CA              A
                TS              LONG            +1
                TC              LOOP22.3
DEC13T          DEC             13

JOBOVER         EQUALS          LRS24.1                 # ****  TEMPORARY DEFINITION ******

# END OF TEST PROGRAM
#  ****************************************
ZERO/SP         EQUALS          HI6ZEROS

## Sundance 292
                BLOCK           02
                SETLOC          FFTAG5
                BANK
                COUNT*          $$/P20
GOTOV56         EXTEND                                  # P20 TERMINATES BY GOTOV56 INSTEAD OF
                DCA             VB56CADR                # GOTOPOOH
                TCF             SUPDXCHZ
                EBANK=          WHOCARES
VB56CADR        2CADR           TRMTRACK

## Sundance 306

# W-MATRIX MONITOR

                BANK            31
                SETLOC          VB45
                BANK
                COUNT*          $$/EXTVB

                EBANK=          WWPOS

V45CALL         TC              UNK7766
                TC              INTPRET
                CALL
                                V45WW
                EXIT
V06N99DS        CAF             V06N99
                TC              BANKCALL
                CADR            GOXDSPFR
                TCF             ENDEXT
                TC              V06N9933
                TC              +4
                CAF             BIT3
                TC              BLANKET
                TC              ENDOFJOB
 +4             TC              UPFLAG
                ADRES           V45FLAG
                TC              V06N99DS

V06N9933        TC              INTPRET
                BON             EXIT
                                V45FLAG
                                +2
                TCF             ENDEXT
                DLOAD           DMP

                                WWPOS
                                1/SQRT3
                SL4             SL1
                STODL           0D
                                WWVEL
                DMP
                                1/SQRT3
                STORE           2D
                BON             LXA,1
                                SURFFLAG
                                V45SURF
                                0D
                SXA,1           LXA,1
                                WRENDPOS
                                2D
                SXA,1           GOTO
                                WRENDVEL
                                V45CLRF
V45SURF         LXA,1           SXA,1
                                0D
                                WRENDPOS
                LXA,1           SXA,1
                                2D
                                WRENDVEL
V45CLRF         CLEAR           EXIT
                                RENDWFLG
                TCF             ENDEXT
V45WW           STQ             BOV
                                S2
                                +1
                CLEAR           CALL
                                V45FLAG
                                INTSTALL
                SSP             DLOAD
                                S1
                DEC             6
                                ZEROVECS
                STORE           WWPOS
                STORE           WWVEL
                AXT,1
                DEC             54
NXPOSVEL        VLOAD*          VSQ
                                W               +54D,1
                DAD
                                WWPOS
                STORE           WWPOS
                VLOAD*          VSQ
                                W               +108D,1
                DAD
                                WWVEL

                STORE           WWVEL
                TIX,1           SQRT
                                NXPOSVEL
                STODL           WWVEL
                                WWPOS
                SQRT
                STORE           WWPOS
                BOV             GOTO
                                +2
                                V45XXX
                DLOAD
                                DPPOSMAX
                STORE           WWPOS
                STORE           WWVEL
V45XXX          LXA,1           SXA,1
                                S2
                                QPRET
                EXIT
                TC              POSTJUMP
                CADR            INTWAKE

V06N99          VN              0699
1/SQRT3         2DEC            0.5773502

# RADMODES BIT DEFINITIONS
REMODBIT        =               BIT14                   # ANTENNA MODE CHANGE REQUESTED FLAG
ANTENBIT        =               BIT12                   # RR ANTENNA MODE FLAG
REPOSBIT        =               BIT11                   # RR REPOSITION TAKING PLACE FLAG
LRVELBIT        =               BIT8                    # LR VELOCITY DATA FAIL FLAG
RCDUFBIT        =               BIT7                    # RR CDU FAIL OCCURRED FLAG
LRALTBIT        =               BIT5                    # LR ALTITUDE DATA FAIL FLAG
AUTOMBIT        =               BIT2                    # RR AUTO MODE DISCRETE FLAG
