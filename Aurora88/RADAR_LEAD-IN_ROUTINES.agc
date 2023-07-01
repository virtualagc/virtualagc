### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RADAR_LEAD-IN_ROUTINES.agc
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


                SETLOC  ENDIMODF
                EBANK=  RRRET

#          THE FOLLOWING SUBROUTINE RETURNS TO CALLER + 2 IF THE ABSOLUTE VALUE OF C(A) IS GREATER THAN THE
# NEGATIVE OF THE NUMBER AT CALLER +1. OTHERWISE IT RETURNS TO CALLER +3. MAY BE CALLED IN RUPT OR UNDER EXEC.

MAGSUB          EXTEND
                BZMF    +2
                TCF     +2
                COM

                INDEX   Q
                AD      0
                EXTEND
                BZMF    +3              # ABS(A) G CONST
                INDEX   Q
                TC      1               # ABS(A) LEQ CONST

MAGLESS         INDEX   Q
                TC      2

#          THE FOLLOWING SUBROUTINE CHECKS RR GIMBAL ANGLES TO SEE IF THEY ARE IN THE LIMITS OF THE CURRENT MODE.
# CALLING SEQUENCE IS AS FOLLOWS:

#                                                  TC     RRLIMCHK        (WITH INTERRUPT INHIBITED).
#                                                  ADRES  T,S             (IN UNSWITCHED E OR CURRENT EBANK).

#          RETURN IS TO CALLER +2 IF NOT IN LIMITS AND TO CALLER +3 IF SO.

RRLIMCHK        INDEX   Q               # READ GIMBAL ANGLES INTO ITEMP STORAGE.
                CAF     0
                INCR    Q
                EXTEND
                INDEX   A
                DCA     0
                DXCH    ITEMP1
                LXCH    Q               # L(CALLER +2) TO L.

                CAF     BIT12           # SEE WHICH MODE RR IS IN.
                MASK    RADMODES
                CCS     A
                TCF     MODE2CHK

                CA      ITEMP1          # MODE 1 IS DEFINED AS
                TC      MAGSUB          #     1. ABS(T) L 70 DEGS.
                DEC     -.38885         #     2. ABS(S + 5 DEGS) L 65 DEGS
                TC      L               #         (SHAFT LIMITS AT +59, -70 DEGS)

                CAF     5DEGS
                AD      ITEMP2          # S
                TC      MAGSUB
                DEC     -.36108         # 65 DEGS
                TC      L
                TC      RRLIMOK         # IN LIMITS.

MODE2CHK        CAF     82.5DEGS        # MODE 2 IS DEFINED AS
                AD      ITEMP2          #     1. ABS(T) G 110 DEGS
                TC      MAGSUB          #     2. ABS(S + 82.5 DEGS) L 57.5 DEGS
                DEC     -.31946         #         (SHAFT LIMITS AT -25, -139 DEGS)
                TC      L

                CA      ITEMP1
                TC      MAGSUB
                DEC     -.61111         # 110 DEGS

RRLIMOK         INDEX   L
                TC      L               # ( = TC 1)

5DEGS           DEC     .02777          # SCALED IN HALF-REVOLUTIONS.
82.5DEGS        DEC     .45831

#          THE FOLLOWING ROUTINE UPDATES THE TRACKER FAIL LAMP ON THE DSKY, IF EITHER:

#          1. N SAMPLES OF RR DATA COULD NOT BE OBTAINED FROM 2N TRIES
#          2. N SAMPLES OF LR DATA COULD NOT BE TAKEN IN 2N TRIES WITH EITHER THE ALT OR VEL INFORMATION.
#          3. RR CDU FAILED WITH RR IN AUTO MODE AND RR CDU NOT BEING ZEROED.

SETTRKF         CAF     BIT1            # NO ACTION IF DURING LAMP TEST.
                MASK    IMODES33
                CCS     A
                TC      Q

                CAF     13,7,2          # SEE IF CDU FAILED.
                MASK    RADMODES
                EXTEND
                BZF     TRKFLON         # CONDITION 3 ABOVE.

                CS      RADMODES        # SEE IF LR FAILED.
                MASK    8,5
                EXTEND
                BZF     TRKFLON         # CONDITION 2 ABOVE.

                CAF     BIT4            # SEE IF RR DATA FAILED.
                MASK    RADMODES
                CCS     A
TRKFLON         CAF     BIT8
                AD      DSPTAB +11D     # HALF ADD DESIRED AND PRESENT STATES.
                MASK    BIT8
                EXTEND
                BZF     TCQ             # NO CHANGE.

                TS      L               # INVERT BIT 8 AND SET BIT 15.
                CA      DSPTAB +11D     # CANT USE LXCH DSPTAB +11D (RESTART PROB)
                EXTEND
                RXOR    L
                MASK    POSMAX
                AD      BIT15
                TS      DSPTAB +11D
                TC      Q

13,7,2          OCT     10102
8,5             OCT     00220

ENDRMODF        EQUALS

#          TURNON SEQUENCE TO ZERO THE CDUS AND DETERMINE THE RR MODE.

                BANK    10

RRTURNON        TC      RRZEROSB
                TC      FIXDELAY        # WAIT 1 SEC BEFORE REMOVING TURN ON FLAG
                DEC     100             # SO A MONITOR REPOSITION WONT ALARM.
                CS      BIT1
                MASK    RADMODES
                TS      RADMODES
                CS      STATE           # SEE IF SOMEONE IS WAITING TO USE THE RR.
                MASK    RRUSEFLG
                CCS     A
                TCF     TASKOVER

                TCF     ENDRADAR        # CHECK RR CDU FAIL BEFORE EXIT.

#          CLOSED SUBROUTINE TO ZERO THE RR CDUS.

RRZEROSB        EXTEND
                QXCH    RRRET
                CAF     BIT1            # BIT 13 OF RADMODES MUST BE SET BEFORE
                EXTEND                  # COMING HERE.
                WOR     12
                TC      FIXDELAY
                DEC     2

                CAF     ZERO
                TS      OPTY
                TS      OPTX
                CS      ONE             # REMOVE ZEROING BIT.
                EXTEND
                WAND    12
                TC      FIXDELAY
                DEC     400

                CS      BIT13           # REMOVE ZEROING IN PROCESS BIT.
                MASK    RADMODES
                TS      RADMODES

                CA      OPTY
                TC      MAGSUB
                DEC     -.5
                TCF     +3              # IF MODE 2.

                CAF     ZERO
                TCF     +2
                CAF     BIT12
                XCH     RADMODES
                MASK    -BIT12
                ADS     RADMODES

                TC      SETTRKF         # TRACKER LAMP MIGHT GO ON NOW.

                TC      RRRET           # DONE.

-BIT12          EQUALS  -1/8            # IN SPROOT

#          SEQUENCE OF TASKS TO DRIVE THE RR TO A SAFE POSITION.

DORREPOS        TC      SETRRECR        # SET UP RR CDU ERROR COUNTERS.

                CAF     BIT1            # DO AN ALARM UNLESS RR JUST TURNED ON.
                MASK    RADMODES
                CCS     A
                TCF     +3

                TC      ALARM
                OCT     501
                TC      FIXDELAY
                DEC     2

                CAF     BIT12           # MANEUVER TRUNNION ANGLE TO NOMINAL POS.
                MASK    RADMODES
                CCS     A
                CAF     BIT15           # 0 FOR MODE 1 AND 180 FOR MODE 2.
                TC      RRTONLY

                CAF     BIT12           # NOW PUT SHAFT IN RIGHT POSITION.
                MASK    RADMODES
                CCS     A
                CS      HALF            # -90 FOR MODE 2.
                TC      RRSONLY

REPOSRPT        CS      BIT11           # RETURNS HERE FROM RR1AXIS IF REMODE
                                        # REQUESTED DURING REPOSITION.
                MASK    RADMODES        # REMOVE REPOSITION BIT.
                TS      RADMODES
                MASK    BIT10           # SEE IF SOMEONE IS WAITING TO DESIGNATE.
                CCS     A
                TCF     BEGDES
                CS      BIT2            # IF NO FURTHER ANTENNA CONTROL REQUIRED,
                EXTEND                  # REMOVE ERROR COUNTER ENABLE.
                WAND    12
                TCF     TASKOVER

SETRRECR        CAF     BIT2            # SET UP RR ERROR COUNTERS.
                EXTEND
                WOR     12

                CAF     ZERO
                TS      LASTYCMD
                TS      LASTXCMD
                TC      Q

#          GENERAL REMODING SUBROUTINE. DRIVES TRUNION TO 0 (180), THEN DRIVES SHAFT TO -45, AND FINALLY DRIVES
# TRUNNION TO -130 (-50) BEFORE INITIATING 2-AXIS CONTROL. ALL RE-MODING IONE WITH SINGLE AXIS ROTATIONS (RR1AXIS)
REMODE          CAF     BIT12           # DRIVE TRUNNION TO 0 (180).
                MASK    RADMODES        # (ERROR COUNTER ALREADY ENABLED)
                CCS     A
                CAF     BIT15
                TC      RRTONLY

                CAF     -45DEGSR
                TC      RRSONLY

                CS      RADMODES
                MASK    BIT12
                CCS     A
                CAF     -60DEGSR        # GO TO T = -130 (-50).
                AD      -60DEGSR
                TC      RRTONLY

                TC      RMODINV

                CS      BIT14           # END OF REMODE.
                MASK    RADMODES
                TS      RADMODES

                TC      STDESIG         # BEGIN 2-AXIS CONTROL.

-45DEGSR        OCT     70000
-60DEGSR        OCT     65252

RMODINV         LXCH    RADMODES        # INVERT THE MODE STATUS.
                CAF     BIT12
                EXTEND
                RXOR    L
                TS      RADMODES
                TC      Q

#          SUBROUTINES FOR DOING SINGLE AXIS RR MANEUVERS FOR REMODE AND REPOSITION. DRIVES TO WITHIN 1 DEGREE.

RRTONLY         TS      RDES            # DESIRED TRUNION ANGLE.
                CAF     ZERO
                TCF     RR1AXIS

RRSONLY         TS      RDES            # SHAFT COMMANDS ARE UNRESOLVED SINCE THIS
                CAF     ONE             # ROUTINE ENTERED ONLY WHEN T = 0 OR 180.

RR1AXIS         TS      RRINDEX
                EXTEND
                QXCH    RRRET
                TCF     RR1AX2

NXTRR1AX        TC      FIXDELAY
                DEC     50              # 2 SAMPLES PER SECOND.

RR1AX2          CS      RADMODES        # IF SOMEONE REQUESTES AS DESIGNATE WHICH
                MASK    PRIO22          # REQUIRES A REMODE AND A REPOSITION IS IN
                EXTEND                  # PROGRESS, INTERRUPT IT AND START THE
                BZF     REPOSRPT        # REMODE IMMEDIATELY.

                CA      RDES
                EXTEND
                INDEX   RRINDEX
                MSU     OPTY
                TS      Q               # SAVE ERROR SIGNAL.
                EXTEND
                MP      RRSPGAIN        # TRIES TO NULL .7 OF ERROR OVER NEXT .5
                TS      L
                CA      Q               # SEE IF WITHIN 1 DEGREE.
                TC      MAGSUB
                DEC     -.00555         # SCALED IN HALF-REVS.

                TCF     +2              # NO.
                TC      RRRET           # RETURN TO CALLER.

                CCS     RRINDEX         # COMMAND FOR OTHER AXIS IS ZERO.
                TCF     +2              # SETTING A TO 0.
                XCH     L
                DXCH    TANG

                TC      RROUT

                TCF     NXTRR1AX        # COME BACK IN .5 SECONDS.

RRSPGAIN        DEC     .59062          # NULL .7 ERROR IN .5 SEC.

#          THE FOLLOWING ROUTINE RECEIVES RR GYRO COMMANDS IN TANG,+1 IN ERROR COUNTER SCALING. RROUT LIMITS THEM
# AND GENERATES COMMANDS TO THE CDU TO ADJUST THE ERROR COUNTERS TO THE DESIRED VALUES. RUPT MUST BE INHIBITED.

RROUT           LXCH    Q               # SAVE RETURN.
                CAF     ONE             # LOOP TWICE.
RROUT2          TS      ITEMP2
                INDEX   A
                CA      TANG
                TS      ITEMP1          # SAVE SIGN OF COMMAND FOR LIMITING.

                TC      MAGSUB          # SEE IF WITHIN LMITS.
-RRLIMIT        DEC     -384
                TCF     RROUTLIM        # LIMIT COMMAND TO MAG OF 384.

SETRRCTR        CA      ITEMP1          # COUNT OUT DIFFERENCE BETWEEN DESIRED
                INDEX   ITEMP2          # STATE AND PRESENT STATE AS RECORDED IN
                XCH     LASTYCMD        # LASTYCMD AND LASTXCMD
                COM
                AD      ITEMP1
                INDEX   ITEMP2
                TS      OPTYCMD

                CCS     ITEMP2          # PROCESS BOTH INPUTS.
                TCF     RROUT2

                CAF     PRIO6           # ENABLE COUNTERS.
                EXTEND
                WOR     14

                TC      L               # RETURN.

RROUTLIM        CCS     ITEMP1          # LIMIT COMMAND TO ABS VAL OF 384.
                CS      -RRLIMIT
                TCF     +2
                CA      -RRLIMIT
                TS      ITEMP1
                TCF     SETRRCTR +1

#          ROUTINE TO ZERO THE RR CDUS AND DETERMINE THE ANTENNA MODE.

RRZERO          INHINT
                CS      RRUSEFLG        # SET FLAG TO SHOW SOMEONE USING THE RR.
                MASK    STATE
                AD      RRUSEFLG
                TS      STATE

                CAF     BIT1            # SEE IF RR COMING UP. IF SO, TURNON
                MASK    RADMODES        # PROGRAM WILL DO THE WORK.
                CCS     A
                TCF     ROADBACK

                CAF     BIT11           # SEE IF MONITOR REPOSITION IN PROGRESS.
                MASK    RADMODES        # IF SO, DONT RE-ZERO CDUS.
                CCS     A
                TCF     RADNOOP         # (IMMEDIATE TASK TO RGOODEND).

                CS      BIT13           # SET FLAG TO SHOW ZEROING IN PROGRESS.
                MASK    RADMODES
                AD      BIT13
                TS      RADMODES

                CAF     ONE
                TC      WAITLIST
                2CADR   RRZ2

                CS      RADMODES        # SEE IF IN AUTO MODE.
                MASK    BIT2
                CCS     A
                TCF     ROADBACK
                TC      ALARM           # AUTO DISCRETE NOT PRESENT - TRYING
                OCT     510
ROADBACK        RELINT
                TCF     SWRETURN

RRZ2            TC      RRZEROSB        # COMMON TO TURNON AND RRZERO.
                TCF     ENDRADAR

RRUSEFLG        EQUALS  BIT7
LOKONFLG        EQUALS  BIT5

#          STABLE-MEMBER RR DESIGNATE ROUTINE. DESIGNATE TO A SM LOS VECTOR (HALF-UNIT) IN RRTARGET. REMODES IF
# REQUIRED. RETURNS TO CALLER IF MANEUVER REQUIRED FOR DES AND SKIPS IF IT CAN BE DONE IN PRESENT VEH ATTITUDE.

RRDESSM         STQ     CLEAR
                        DESRET
                        RRNBSW
                RTB     SSP             # READ CDUS FOR SMNB.
                        READCDUS
                        S1
                        20D
                STOVL   20D
                        RRTARGET
                STCALL  32D
                        SMNB

                CALL                    # GET RR GIMBAL ANGLES IN PRESENT AND
                        RRANGLES        # ALTERNATE MODE.
                EXIT

                INHINT
                TC      RRLIMCHK
                ADRES   MODEA           # CONFIGURATION FOR CURRENT MODE.
                TCF     TRYSWS

OKDESSM         INCR    DESRET          # INCREMENT SAYS NO VEHICLE MANEUVER REQ.

#          AT THIS POINT WE ARE READY TO BEGIN DESIGNATION. THE TARGET IS STORED AS A HALF-UNIT VECTOR IN RRTARGET
# WITH RRNBSW SET IF IT IS REFERRED TO NAV BASE AXES. LOKONSW IS SET IF LOCKON IS DESIRED. BIT14 OF RADMODES IS
# SET IF A REMODE IS REQUIRED. AT THIS TIME, THE ANTENNA MAY BE IN A MONITOR REPOSITION OPERATION. IN THIS
# CASE, IF A REMODE IS REQUIRED IT MAY HAVE ALREADY BEGUN BUT IT ANY CASE THE REPOSITION WILL BE INTERRUPTED.
# OTHERWISE, THE REPOSITION WILL BE COMPLETED BEFORE 2-AXIS DESIGNATION BEGINS.

STARTDES        CAF     MAXTRIES        # ALLOW 30 SECS.
                TS      DESCOUNT

                CAF     BIT10           # SHOW DESIGNATE REQUIRED.
                ADS     RADMODES
                MASK    BIT11           # SEE IF REPOSITION IN PROGRESS.
                CCS     A
                TCF     DESRETRN        # ECTR ALREADY SET UP.

                TC      SETRRECR        # SET UP ERROR COUNTERS.

                CAF     TWO
                TC      WAITLIST
                2CADR   BEGDES

DESRETRN        RELINT                  # RETURN VIA DESRET
 +1             CA      DESRET
                TCF     BANKJUMP

MAXTRIES        DEC     60

#          SEE IF RRDESSM CAN BE ACCOMPLISHED AFTER A REMODE.

TRYSWS          TC      RMODINV         # (NOTE RUPT INHIBIT)
                TC      RRLIMCHK        # TRY DIFFERENT MODE.
                ADRES   MODEB
                TCF     NODESSM         # VEHICLE MANEUVER REQUIRED.

                TC      RMODINV         # RESET BIT12
                CAF     BIT14           # SET FLAG FOR REMODE.
                ADS     RADMODES

                TCF     OKDESSM

NODESSM         TC      RMODINV         # RE-INVERT MODE AND RETURN WITHOUT IN-
                TCF     DESRETRN        # CREMENTING DESRET

#          DESIGNATE TO SPECIFIC RR GIMBAL ANGLES (INDEPENDENT OF VEHICLE MOTION).  ENTER WITH DESIRED ANGLES IN
# TANG AND TANG +1.

RRDESNB         STQ     EXIT            # ENTER IN INTERP. - EXIT IN BASIC.
                        DESRET

                INHINT                  # SEE IF CURRENT MODE OK.
                TC      RRLIMCHK
                ADRES   TANG
                TCF     TRYSWN          # SEE IF IN OTHER MODE.

OKDESNB         RELINT
                TC      INTPRET

                CALL                    # GET LOS IN NB COORDS.
                        RRNB
                STORE   RRTARGET

                SET     EXIT
                        RRNBSW

                INHINT
                TCF     STARTDES

TRYSWN          TC      RMODINV         # SEE IF OTHER MODE WILL DO.
                TC      RRLIMCHK
                ADRES   TANG
                TCF     NODESNB         # NOT POSSIBLE.

                TC      RMODINV
                CAF     BIT14           # CALL FOR REMODE.
                ADS     RADMODES
                TCF     OKDESNB

NODESNB         CAF     BIT1            # CALL FOR ERROR RETURN.
                TC      WAITLIST
                2CADR   RDBADEND

                TC      RMODINV
                TC      ALARM           # BAD GIMBAL ANGLE INPUTS.
                OCT     502
                TCF     DESRETRN +1     # ALARM DID A RELINT.

#          WAITLIST TASKS TO RUN RR DESIGNATION.

BEGDES          CAF     BIT14           # ENTER HERE FROM STARTDES OR REPOSRPT.
                MASK    RADMODES        # SEE IF REMODE REQUIRED.
                CCS     A
                TCF     REMODE
                TCF     STDESIG

DESLOOP         TC      FIXDELAY        # 2 SAMPLES PER SECOND.
                DEC     50

STDESIG         CAF     BIT11           # ENTRY FROM BEGDES AND REMODE.
                MASK    RADMODES        # SEE IF GIMBAL LIMIT MONITOR HAS FOUND US
                CCS     A               # OUT OF BOUNDS. IF SO, THIS BIT SHOWS A
                TCF     BADDES          # REPOSITION TO BE IN PROGRESS.

                CCS     RADMODES        # SEE IF CONTINUOUS DESIGNATE WANTED.
                TCF     +3              # IF SO, DONT CHECK BIT 10 TO SEE IF IN
                TCF     +2              # LIMITS BUT GO RIGHT TO FINDVAC ENTRY.
                TCF     MOREDES +1

                CS      RADMODES        # IF NON-CONTINUOUS, SEE IF END OF
                MASK    BIT10           # PROBLEM (DATA GOOD IF LOCK-ON WANTED OR
                CCS     A               # WITHIN LIMITS IF NOT). IF SO, EXIT AFTER
                TCF     ENDRADAR        # CHECKING RR CDU FAIL.

                CCS     DESCOUNT        # SEE IF TIME LIMIT HAS EXPIRED.
                TCF     MOREDES

                TC      ALARM           # OUT OF TIME.
                OCT     503
                CS      B14+B2          # IF OUT OF TIME, REMOVE ECR ENABLE + TRKR
                EXTEND
                WAND    12
BADDES          CS      BIT10           # REMOVE DESIGNATE FLAG.
                MASK    RADMODES
                TS      RADMODES
                TCF     RDBADEND

MOREDES         TS      DESCOUNT
                CAF     PRIO26          # UPDATE GYRO TORQUE COMMANDS.
                TC      FINDVAC
                2CADR   DODES

                TCF     DESLOOP

B14+B2          OCT     20002

#          CALCULATE GYRO TORQUE COMMANDS.

DODES           EXTEND
                DCA     OPTY
                DXCH    TANG

                TC      INTPRET

                VLOAD                   # MOVE TARGET VECTOR TO 32D.
                        RRTARGET
                STORE   32D

                BON     RTB             # DO STABLE-MEMBER TO NAVBASE TRANSFORMA-
                        RRNBSW          # TION IF TARGET IN SM COORDS. OTHERWISE,
                        DONBRD          # IN NB COORDS ALREADY.
                        READCDUS

                SSP
                        S1
                        20D             # LOC OF ICDUS.
                STCALL  20D
                        SMNB

DONBRD          SETPD   SLOAD           # DO NAVBASE TO RADAR DISH TRANSFORMATION.
                        0
                        TANG +1
                RTB     PUSH            # SHAFT COMMAND = V(32D).(COS(S), 0,
                        CDULOGIC        #       (-SIN(S)).
                SIN     PDDL            # SIN(S) TO 0 AND COS(S) TO 2.
                COS     PUSH
                DMP     PDDL
                        32D
                        36D
                DMP     BDSU
                        0
                STADR
                STORE   TANG +1         # SHAFT COMMAND

                SLOAD   RTB
                        TANG
                        CDULOGIC
                PUSH    COS             # COS(T) TO 4.
                PDDL    SIN
                PUSH    DMP             # SIN(T) TO 6.
                        2
                SL1     PDDL            # DEFINE VECTOR U =     (SIN(T)SIN(S))
                        4               #                       (   COS(T)   )
                PDDL    DMP             #                       (SIN(T)COS(S))
                        6
                        0
                SL1     VDEF
                DOT     EXIT            # DOT U WITH LOS TO GET TRUNNION COMMAND.
                        32D

#          AT THIS POINT WE HAVE A ROTATION VECTOR IN DISH AXES LYING IN THE TS PLANE. CONVERT THIS TO A
# COMMANDED RATE AND ENABLE THE TRACKER IF WE ARE WITHIN 1 DEGREE OF THE TARGET.

                CS      MPAC            # DOT WAS NEGATIVE OF DESIRED ANGLE.
                TS      TANG

                CS      RADMODES        # A RELAY IN THE RR REVERSES POLARITY OF
                MASK    BIT12           # THE SHAFT COMMANDS IN MODE 2 SO THAT A
                CCS     A               # POSITIVE TORQUE APPLIED TO THE SHAFT
                TCF     +3              # GYRO CAUSES A POSITIVE CHANGE IN THE

                CS      TANG +1         # SHAFT ANGLE.  COMPENSATE FOR THIS SWITCH
                TS      TANG +1         # BY CHANGING THE POLARITY OF OUR COMMAND.

                CAF     ZERO
                TS      MPAC +1
                CAF     ONE

RRSCALUP        TS      MPAC
                INDEX   A
                CA      TANG            # TRUNNION COMPONENT OF ROTATION.
                EXTEND
                MP      RDESGAIN        # SCALING ON INPUT ANGLE WAS 4 RADIANS.
                INDEX   MPAC
                XCH     TANG            # MAKE EACH COMPONENT LESS THAN .35 DEGREES
                TC      MAGSUB          # BEFORE SENDING TRACK ENABLE.
                DEC     -.00195
                INCR    MPAC +1         # IF OUT OF BOUNDS.

                CCS     MPAC
                TCF     RRSCALUP

#          SEE IF TRACKER SHOULD BE ENABLED OR DISABLED.

                INHINT

                CCS     RADMODES        # IF CONTINUOUS DESIGNATE WANTED, PUT OUT
                TCF     +3              # COMMANDS WITHOUT CHECKING MAGNITUDE OF
                TCF     +2              # ERROR SIGNALS.
                TCF     TRKOFF

                CCS     MPAC +1         # SEE IF BOTH AXES WERE WITHIN .7 DEGS.
                TCF     TRKOFF

                CS      STATE           # IF WITHIN LIMITS AND NO LOCK-ON WANTED,
                MASK    LOKONFLG        # PROBLEM IS FINISHED.
                CCS     A
                TCF     RRDESDUN

                CAF     BIT14           # ENABLE THE TRACKER.
                EXTEND
                WOR     12

                CAF     BIT4            # SEE IF DATA GOOD RECEIVED YET.
                EXTEND
                RAND    33
                CCS     A
                TCF     DORROUT

RRDESDUN        CS      BIT10           # WHEN PROBLEM DONE, REMOVE BIT 10 SO NEXT
                MASK    RADMODES        # WAITLIST TASK WE WILL GO TO RGOODEND.
                TS      RADMODES

                CS      BIT2
                EXTEND
                WAND    12
                TCF     ENDOFJOB        # WITH ECTR DISABLED.

TRKOFF          CS      BIT14
                EXTEND
                WAND    12

DORROUT         CS      RADMODES        # PUT OUT COMMAND UNLESS MONITOR
                MASK    BIT11           # REPOSITION HAS TAKEN OVER.
                CCS     A
                TC      RROUT

                TCF     ENDOFJOB

RDESGAIN        DEC     .53624          # TRIES TO NULL .5 ERROR IN .5 SEC.

# RADAR READ INITIALIZATION

# RADAR DATA ARE READ BY A BANKCALL FOR THE APPROPRIATE LEAD-IN BELOW.



LRALT           TC      INITREAD -1     # ONE SAMPLE PER READING.
ALLREAD         OCT     17

LRVELZ          TC      INITREAD
                OCT     16

LRVELY          TC      INITREAD
                OCT     15

LRVELX          TC      INITREAD
                OCT     14

RRRDOT          TC      INITREAD -1
                OCT     12

RRRANGE         TC      INITREAD -1
                OCT     11

 -1             CAF     ONE             # ENTRY TO TAKE ONLY 1 SAMPLE.
INITREAD        INHINT

                TS      TIMEHOLD        # GET DT OF MIDPOINT OF NOMINAL SAMPLING
                EXTEND                  # INTERVAL (ASSUMES NO BAD SAMPLES WILL BE
                MP      BIT3            # ENCOUNTERED).
                DXCH    TIMEHOLD

                CCS     A
                TS      NSAMP
                AD      ONE
#          INSERT FOLLOWING INSTRUCTION TO GET 2N TRIES FOR N SAMPLES.
#               DOUBLE
                TS      SAMPLIM

                CAF     DGBITS          # READ CURRENT VALUE OF DATA GOOD BITS.
                EXTEND
                RAND    33
                TS      OLDATAGD

                CS      ALLREAD
                EXTEND
                WAND    13              # REMOVE ALL RADAR BITS

                INDEX   Q
                CAF     0
                EXTEND
                WOR     13              # SET NEW RADAR BITS

                EXTEND
                DCA     TIME2
                DAS     TIMEHOLD        # TIME OF NOMINAL MIDPOINT.

                CAF     ZERO
                TS      L
                DXCH    SAMPLSUM
                TCF     ROADBACK

DGBITS          OCT     230

# RADAR RUPT READER

# THIS ROUTINE STARTS FROM A RADARUPT. IT READS THE DATA $ LOTS MORE.

RADAREAD        TS      BANKRUPT
                EXTEND
                QXCH    QRUPT

                CCS     LOTSFLAG
                TC      RESUME

ANGLREAD        EXTEND
                DCA     OPTY
                DXCH    OPTYHOLD        # SAVE RAW CDU ANGLES

TRYCOUNT        CCS     SAMPLIM
                TCF     PLENTY
                TCF     NOMORE
                TC      ALARM
                OCT     520
                TC      RESUME

NOMORE          TC      ALARM
                OCT     521
BADRAD          CS      ONE
                TS      SAMPLIM
                TC      RDBADEND -2

PLENTY          TS      SAMPLIM
                CAF     BIT3
                EXTEND
                RAND    13              # TO FIND OUT WHICH RADAR
                EXTEND
                BZF     RENDRAD

LRPOSCHK        CA      RADMODES        # SEE IF LR IN DESIRED POSITION.
                EXTEND
                RXOR    33
                MASK    BIT6
                EXTEND
                BZF     VELCHK

                TC      ALARM
                OCT     522
                TC      BADRAD

VELCHK          CAF     BIN3            # = 00003 OCT
                EXTEND
                RXOR    13
                MASK    BIN3
                EXTEND
                BZF     LRHEIGHT        # TAKE A LR RANGE READING

                CAF     POSMAX
                MASK    RNRAD
                AD      LVELBIAS
                TS      L
                CAE     RNRAD
                DOUBLE
                MASK    BIT1
                DXCH    ITEMP3

                CAF     BIT8            # DATA GOOD ISNT CHECKED UNTIL AFTER READ-
                TC      DGCHECK         # ING DATA SO SOME RADAR TESTS WILL WORK
                                        # INDEPENDENT OF DATA GOOD.

                CCS     NSAMP
                TC      NOEND
GOODRAD         CS      ONE
                TS      SAMPLIM
                CS      ITEMP1          # WHEN ENOUGH GOOD DATA HAS BEEN GATHERED,
                MASK    RADMODES        # RESET DATA FAIL FLAGS FOR SETTRKF.
                TS      RADMODES
                TC      SETTRKF         # LAMP MIGHT GO OFF IF DATA JUST GOOD.
                TC      RGOODEND -2

NOEND           TS      NSAMP
RESAMPLE        CCS     SAMPLIM         # SEE IF ANY MORE TRIES SHOULD BE MADE.
                TCF     +2
                TCF     DATAFAIL        # N SAMPLES NOT AVAILABLE.
                CAF     BIT4            # RESET ACTIVITY BIT.
                EXTEND
                WOR     13              # RESET ACTIVITY BIT
                TC      RESUME


LRHEIGHT        CAF     BIT5
                TS      ITEMP1          # (POSITION OF DATA GOOD BIT IN CHAN 33)

                CAF     BIT9
                TC      SCALECHK -1

RENDRAD         CAF     BIT11           # MAKE SURE ANTENNA HAS NOT GONE OUT OF
                MASK    RADMODES        # LIMITS.
                CCS     A
                TCF     BADRAD

                CS      RADMODES        # BE SURE RR CDU HASNT FAILED.
                MASK    BIT7
                CCS     A
                TCF     BADRAD

                CAF     BIT12           # DONT ACCEPT RR DATA IF TRUNNION MORE
                MASK    RADMODES        # THAN 55 DEGREES FROM NOMINAL POSITION.
                CCS     A
                CAF     BIT15           # 180 FOR MODE 2 - 0 FOR MODE 1.
                EXTEND
                MSU     OPTY
                TC      MAGSUB
                DEC     -.30555         # 55 DEGS AT HALF-REVS.
                TCF     BADRAD

                CAF     BIT4            # SEE IF DATA HAS BEEN GOOD.
                TS      ITEMP1          # (POSITION OF DATA GOOD BIT IN CHAN 33)

                CAF     BIT1            # SEE IF RR RDOT.
                EXTEND
                RAND    13
                TS      Q               # FOR LATER TESTING.
                CCS     A
                TCF     +2
                TCF     RADIN           # NO SCALE CHECK FOR RR RDOT.
                CAF     BIT3
                TS      L

SCALECHK        EXTEND
                RAND    33              # SCALE STATUS NOW
                XCH     L
                MASK    RADMODES        # SCALE STATUS BEFORE
                EXTEND
                RXOR    01              # SEE IF THEY DIFFER
                CCS     A
                TC      SCALCHNG        # THEY DIFFER

RADIN           CAF     POSMAX
                MASK    RNRAD
                TS      ITEMP4

                CAE     RNRAD
                DOUBLE
                MASK    BIT1
                TS      ITEMP3

                CCS     Q               # SEE IF RR RDOT.
                TCF     SCALADJ         # NO, BUT SCALE CHANGING MAY BE NEEDED.

                EXTEND                  # IF RR RANGE RATE, THROW OUT BIAS.
                DCS     RDOTBIAS
DASAMPL         DAS     ITEMP3
DGCHECK2        CA      ITEMP1          # SEE THAT DATA HAS BEEN GOOD BEFORE AND
                TC      DGCHECK +1      # AFTER TAKING SAMPLE.
                TC      GOODRAD

SCALCHNG        LXCH    RADMODES
                AD      BIT1
                EXTEND
                RXOR    01
                TS      RADMODES
                CAF     DGBITS          # UPDATE LAST VALUE OF DATA GOOD BITS.
                EXTEND
                RAND    33
                TS      OLDATAGD
                TCF     BADRAD

#          THE FOLLOWING ROUTINE INCORPORATES RR RANGE AND LR ALT SCALE INFORMATION AND LEAVES DATA AT LO SCALE.

SCALADJ         CCS     L               # L HAS SCALE INBIT FOR THIS RADAR.
                TCF     +2              # ON HIGH SCALE.
                TCF     DGCHECK2

                DXCH    ITEMP3
                DDOUBL
                DDOUBL
                DDOUBL
                DXCH    ITEMP3

                CAF     BIT3            # SEE IF LR OR RR.
                EXTEND
                RAND    13
                EXTEND                  # IF RR, NO MORE ACTION REQUIRED.
                BZF     DGCHECK2

                CAF     LRRATIO         # IF LR, CONVERT TO LO SCALING.
                EXTEND
                MP      ITEMP4
                TS      ITEMP4
                CAF     ZERO            # (SO SUBSEQUENT DAS WILL BE OK)
                XCH     ITEMP3
                EXTEND
                MP      LRRATIO
                TCF     DASAMPL

DGCHECK         TS      ITEMP1          # UPDATE DATA GOOD BIT IN OLDATAGD AND
                EXTEND                  # MAKE SURE IT WAS ON BEFORE AND AFTER THE
                RAND    33              # SAMPLE WAS TAKEN BEFORE RETURNING. IF
                TS      L               # NOT, GOES TO RESAMPLE TO TRY AGAIN. IF
                CS      ITEMP1          # MAX NUMBER OF TRIES HAS BEEN REACHED,
                MASK    OLDATAGD        # THE BIT CORRESPONDING TO THE DATA GOOD
                AD      L               # WHICH FAILED TO APPEAR IS IN ITEMP1 AND
                XCH     OLDATAGD        # CAN BE USED TO SET RADMODES WHICH VIA
                MASK    ITEMP1          # SETTRKF SETS THE TRACKER FAIL LAMP.
                AD      L
                CCS     A               # SHOULD BOTH BE ZERO.
                TC      RESAMPLE
                DXCH    ITEMP3          # IF DATA GOOD BEFORE AND AFTER, ADD TO
                DAS     SAMPLSUM        # ACCUMULATION.
                TC      Q

DATAFAIL        CS      ITEMP1          # IN THE ABOVE CASE, SET RADMODES BIT
                MASK    RADMODES        # SHOWING SOME RADAR DATA FAILED.
                AD      ITEMP1
                TS      RADMODES

                DXCH    ITEMP3          # IF WE HAVE BEEN UNABLE TO GATHER N
                DXCH    SAMPLSUM        # SAMPLES, USE LAST ONE ONLY.

                TC      SETTRKF

                TCF     NOMORE

LRRATIO         DEC     4.9977 B-3
LVELBIAS        DEC     -12288          # LANDING RADAR BIAS FOR 153.6 KC.
RDOTBIAS        2DEC    17000           # BIAS COUNT FOR RR RANGE RATE

# THIS ROUTINE CHANGES THE LR POSITION, AND CHECKS THAT IT GOT THERE.

LRPOS2          INHINT

                CS      BIT6            # DESIRED LR POSITION IS NOW 2.
                MASK    RADMODES
                AD      BIT6
                TS      RADMODES

                CAF     BIT7
                EXTEND
                RAND    33              # SEE IF ALREADY THERE.
                EXTEND
                BZF     RADNOOP

                CAF     BIT13
                EXTEND
                WOR     12              # COMMAND TO POSITION 2

                CAF     6SECS           # START SCANNING FOR INBIT AFTER 7 SECS.
                TC      WAITLIST
                2CADR   LRPOSCAN

                TC      ROADBACK

LRPOSNXT        TC      LRPSNXT1
                EXTEND
                BZF     LSTLRDT1        # IF THERE, WAIT FINAL SECOND FOR BOUNCE.

                CCS     SAMPLIM         # SEE IF MAX TIME UP.
                TCF     LRPOSNXT

                CS      BIT13           # IF TIME UP, DISABLE COMMAND AND ALARM.
                EXTEND
                WAND    12

                TC      ALARM           # LR ANTENNA DIDNT MAKE IT.
                OCT     523
                TCF     RDBADEND

RADNOOP         CAF     ONE             # NO FURTHER ACTION REQUESTED.
                TC      WAITLIST
                2CADR   RGOODEND

                TC      ROADBACK

LSTLRDT1        TC      LASTLRDT

#          SEQUENCES TO TERMINATE RR OPERATIONS.

ENDRADAR        CAF     BIT7            # PROLOG TO CHECK RR CDU FAIL BEFORE END.
                MASK    RADMODES
                CCS     A
                TCF     RGOODEND
                TCF     RDBADEND
 -2             CS      ZERO            # RGOODEND WHEN NOT UNDER WAITLIST CONTROL
                TS      RUPTAGN

RGOODEND        CAF     TWO
                TC      POSTJUMP
                CADR    GOODEND

 -2             CS      ZERO            # RDBADEND WHEN NOT UNDER WAITLIST.
                TS      RUPTAGN
RDBADEND        CAF     TWO
                TC      POSTJUMP
                CADR    BADEND

BIN3            EQUALS  THREE
ENDRMODS        EQUALS
