### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    IMU_MODE_SWITCHING_ROUTINES.agc
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
##              2023-07-03 MAS  Relocated Sundial D patch to SXTMARK.


                SETLOC  ENDT4FF
                EBANK=  COMMAND

# FIXED-FIXED ROUTINES.
ZEROICDU        CAF     ZERO            # ZERO ICDU COUNTERS.
                TS      CDUX
                TS      CDUY
                TS      CDUZ
                TC      Q

4SECS           DEC     400
3SECS           DEC     300
2SECS           DEC     200

ENDIMODF        EQUALS

# IMU ZEROING ROUTINE.

                BANK    13

IMUZERO         INHINT                  # ROUTINE TO ZERO ICDUS.
                TCF     IMUZERO1
                MASK    STATE           # PROGRAM IS USING THE IMU.
                AD      IMUSEFLG
                TS      STATE

                TC      CAGETSTQ        # IF IMU COMING UP, TURN-ON PROGRAM WILL
                TCF     MODEEXIT        # DO ALL THE WORK.

                CS      BITS3&4         # INHIBIT ICDUFAIL AND IMUFAIL (IN CASE WE
                MASK    IMODES30        # JUST CAME OUT OF COARSE ALIGN).
                AD      BITS3&4
                TS      IMODES30

                CS      BITS4&6         # SEND ZERO ENCODE WITH COARSE AND ERROR
                EXTEND                  # COUNTER DISABLED.
                WAND    12

                CAF     BIT5
                EXTEND
                WOR     12

                CAF     BIT6            # WAIT 320 MS TO GIVE AGS ADEQUATE TIME TO
                TC      WAITLIST        # RECEIVE ITS PULSE TRAIN.
                2CADR   IMUZERO2

                CS      IMODES30        # SEE IF IMU OPERATING AND ALARM IF NOT.
                MASK    BIT9
                CCS     A
                TCF     MODEEXIT

                TC      ALARM
                OCT     210

MODEEXIT        RELINT                  # GENERAL MODE-SWITCHING EXIT.
                TCF     SWRETURN

IMUZERO2        TC      CAGETSTQ        # POSSIBLY SWITCH TO TURN-ON PROGRAM.
                TCF     TASKOVER

                TC      ZEROICDU        # ZERO COUNTERS.
                CS      BIT5            # REMOVE ZERO DISCRETE.
                EXTEND
                WAND    12

                CAF     4SECS           # WAIT FOR COUNTERS TO SYNCRONIZE.
                TC      VARDELAY

IMUZERO3        TC      CAGETSTQ
                TCF     TASKOVER

                CS      BITS3&4         # REMOVE IMUFAIL AND ICDUFAIL INHIBIT.
                MASK    IMODES30
                TS      IMODES30

                TC      IBNKCALL        # SET ISS WARNING IF EITHER OF ABOVE ARE
                CADR    SETISSW         # PRESENT.

                TCF     ENDIMU

# IMU COARSE ALIGN MODE.

IMUCOARS        CAF     BIT4            # SEND COARSE ALIGN ENABLE DISCRETE
                INHINT
                EXTEND
                WOR     CHAN12

                CS      BIT4            # INHIBIT IMU FAIL.
                MASK    IMODES30
                AD      BIT4
                TS      IMODES30

                CAF     SIX
                TC      WAITLIST
                2CADR   COARS

                TCF     MODEEXIT

COARS           TC      CAGETEST
                CAF     BIT6            # ENABLE ALL THREE ISS CDU ERROR COUNTERS
                EXTEND
                WOR     CHAN12

                CAF     TWO             # SET CDU INDICATOR
COARS1          TS      CDUIND

                INDEX   CDUIND          # COMPUTE THETAD - THETAA IN 1:S
                CA      THETAD          #   COMPLEMENT FORM
                EXTEND
                INDEX   CDUIND
                MSU     CDUX
                EXTEND
                MP      BIT13           # SHIFT RIGHT 2
                XCH     L               # ROUND
                DOUBLE
                TS      ITEMP1
                TCF     +2
                ADS     L

                INDEX   CDUIND          # DIFFERENCE TO BE COMPUTED
                LXCH    COMMAND
                CCS     CDUIND
                TC      COARS1

                CAF     TWO             # MINIMUM OF 4 MS WAIT
                TC      VARDELAY

COARS2          TC      CAGETEST        # DONT CONTINUE IF CAGED.
                TS      ITEMP1          # SETS TO +0.
                CAF     TWO             # SET CDU INDICATOR
 +3             TS      CDUIND

                INDEX   CDUIND
                CCS     COMMAND         # NUMBER OF PULSES REQUIRED
                TC      COMPOS          # GREATER THAN MAX ALLOWED
                TC      NEXTCDU +1
                TC      COMNEG
                TC      NEXTCDU +1

COMPOS          AD      -COMMAX         # COMMAX = MAX NUMBER OF PULSES ALLOWED
                EXTEND                  #   MINUS ONE
                BZMF    COMZERO
                INDEX   CDUIND
                TS      COMMAND         # REDUCE COMMAND BY MAX NUMBER OF PULSES
                CS      -COMMAX-        #   ALLOWED

NEXTCDU         INCR    ITEMP1
                INDEX   CDUIND
                TS      CDUXCMD         # SET UP COMMAND REGISTER.

                CCS     CDUIND
                TC      COARS2 +3

                CCS     ITEMP1          # SEE IF ANY PULSES TO GO OUT.
                TCF     SENDPULS

                TC      FIXDELAY        # WAIT FOR GIMBALS TO SETTLE.
                DEC     150

                CAF     TWO             # AT END OF COMMAND, CHECK TO SEE THAT
CHKCORS         TS      ITEMP1          # GIMBALS ARE WITHIN 2 DEGREES OF THETAD.
                INDEX   A
                CA      CDUX
                EXTEND
                INDEX   ITEMP1
                MSU     THETAD
                CCS     A
                TCF     COARSERR
                TCF     CORSCHK2
                TCF     COARSERR

CORSCHK2        CCS     ITEMP1
                TCF     CHKCORS
                TS      GCOMP           # ZERO GYRO COMPENSATION REGISTERS IN
                TS      GCOMP +1        # PREPARATION FOR COMPENSATION.
                TS      GCOMP +2
                TS      GCOMP +3
                TS      GCOMP +4
                TS      GCOMP +5

                TCF     ENDIMU          # END OF COARSE ALIGNMENT.

COARSERR        AD      COARSTOL        # 2 DEGREES.
                EXTEND
                BZMF    CORSCHK2

                TC      ALARM           # COARSE ALIGN ERROR.
                OCT     211

                TCF     IMUBAD

COARSTOL        DEC     -.01111         # 2 DEGREES SCALED AT HALF-REVOLUTIONS.

COMNEG          AD      -COMMAX
                EXTEND
                BZMF    COMZERO
                COM
                INDEX   CDUIND
                TS      COMMAND
                CA      -COMMAX-
                TC      NEXTCDU

COMZERO         CAF     ZERO
                INDEX   CDUIND
                XCH     COMMAND
                TC      NEXTCDU

SENDPULS        CAF     13,14,15
                EXTEND
                WOR     CHAN14
                CAF     600MS
                TCF     COARS2 -1       # AND THEN TO VARDELAY.

# IMU FINE ALIGN MODE SWITCH.

IMUFINE         INHINT
                TC      CAGETSTJ        # SEE IF IMU BEING CAGED.

                CS      BITS4-6         # RESET ZERO, COARSE, AND ECTR ENABLE.
                EXTEND
                WAND    12

                CAF     BIT10           # IMU FAIL WAS INHIBITED DURING THE
                TC      WAITLIST        # PRESUMABLY PRECEDING COARSE ALIGN.  LEAVE
                2CADR   IFAILOK         # IT ON FOR THE FIRST 5 SECS OF FINE ALIGN

                CAF     90SEC           # GYRO RE-CENTERING TIME.
                TC      WAITLIST
                2CADR   IMUFINED

                TCF     MODEEXIT

IMUFINED        TC      CAGETEST        # SEE THAT NO ONE HAS CAGED THE IMU.
                TCF     ENDIMU

IFAILOK         TC      CAGETSTQ        # ENABLE IMU FAIL UNLESS IMU BEING CAGED.
                TCF     TASKOVER        # IT IS.

                CAF     BIT4            # DONT RESET IMU FAIL INHIBIT IF SOMEONE
                EXTEND                  # HAS GONE INTO COARSE ALIGN.
                RAND    12
                CCS     A
                TCF     TASKOVER

                CS      BIT13           # RESET IMUFAIL.
                MASK    IMODES30
                AD      BIT13
                TS      IMODES30

                CS      BIT4
PFAILOK2        MASK    IMODES30
                TS      IMODES30
                TCF     TASKOVER

PFAILOK         TC      CAGETSTQ        # ENABLE PIP FAIL PROG ALARM.
                TCF     TASKOVER

                CS      BIT10           # RESET IMU AND PIPA FAIL BITS.
                MASK    IMODES30
                AD      BIT10
                TS      IMODES30

                CS      BIT13
                MASK    IMODES33
                AD      BIT13
                TS      IMODES33

                CS      BIT5
                TCF     PFAILOK2

# ROUTINES TO INITIATE AND TERMINATE PROGRAM USE OF THE PIPAS. NO IMUSTALL REQUIRED IN EITHER CASE.

PIPUSE          TC      CAGETSTQ        # DONT ENABLE PIPA FAIL IF IMU BEING CAGED
                TCF     SWRETURN

                INHINT
                CAF     ZERO            # ZERO COUNTERS.
                TS      PIPAX
                TS      PIPAY
                TS      PIPAZ

                CS      BIT1            # IF PIPA FAILS FROM NOW ON (UNTIL
                MASK    IMODES30        # PIPFREE), LIGHT ISS WARNING.
                TS      IMODES30

PIPFREE2        TC      IBNKCALL        # ISS WARNING MIGHT COME ON NOW.
                CADR    SETISSW         # (OR GO OFF ON PIPFREE).

                TCF     MODEEXIT

PIPFREE         INHINT                  # PROGRAM DONE WITH PIPAS. DONT LIGHT
                CS      BIT1            # ISS WARNING.
                MASK    IMODES30
                AD      BIT1
                TS      IMODES30

                MASK    BIT10           # IF PIP FAIL ON, DO PROG ALSRM AND RESET
                CCS     A               # ISS WARNING.
                TCF     MODEEXIT

                TC      ALARM
                OCT     212

                INHINT

                TCF     PIPFREE2

#          THE FOLLOWING ROUTINE TORQUES THE IRIGS ACCORDING TO DOUBLE PRECISION INPUTS IN THE SIX REGISTERS
# BEGINNING AT THE ECADR ARRIVING IN A. THE MINIMUM SIZE OF ANY PULSE TRAIN IS 16 PULSES (.25 CDU COUNTS). THE
# UNSENT PORTION OF THE COMMAND IS LEFT INTACT IN THE INPUT COMMAND REGISTERS.

                EBANK=  1400            # VARIABLE, ACTUALLY.

IMUPULSE        TS      MPAC +5         # SAVE ARRIVING ECADR.
                TC      CAGETSTJ        # DONT PROCEED IF IMU BEING CAGED.

                CCS     LGYRO           # SEE IF GYROS BUSY.
                TC      GYROBUSY        # SLEEP.

                TS      MPAC +2
                CAF     BIT6            # ENABLE THE POWER SUPPLY.
                EXTEND
                WOR     14

                CAF     FOUR
GWAKE2          INHINT                  # (IF A JOB WAS PUT TO SLEEP, THE POWER
                TC      WAITLIST        # SUPPLY IS LEFT ON BY THE WAKING JOB).
                2CADR   STRTGYRO

                CA      MPAC +5         # SET UP EBANK, SAVING CALLER'S EBANK FOR
                XCH     EBANK           # RESTORATION ON RETURN.
                XCH     MPAC +5
                TS      LGYRO           # RESERVES GYROS.
                MASK    LOW8
                TS      ITEMP1

                CAF     TWO             # FORCE SIGN AGREEMENT ON INPUTS.
GYROAGRE        TS      MPAC +3
                DOUBLE
                AD      ITEMP1
                TS      MPAC +4
                EXTEND
                INDEX   A
                DCA     1400
                DXCH    MPAC
                TC      TPAGREE
                DXCH    MPAC
                INDEX   MPAC +4
                DXCH    1400

                CCS     MPAC +3
                TCF     GYROAGRE

                CA      MPAC +5         # RESTORE CALLER'S EBANK.
                TS      EBANK
                TCF     MODEEXIT

# ROUTINES TO ALLOW TORQUING BY ONLY ONE JOB AT A TIME.

GYROBUSY        EXTEND                  # SAVE RETURN 2FCADR.
                DCA     BUF2
                DXCH    MPAC
REGSLEEP        CAF     LGWAKE
                TCF     JOBSLEEP

GWAKE           CCS     LGYRO           # WHEN AWAKENED, SEE IF GYROS STILL BUSY.
                TCF     REGSLEEP        # IF SO, SLEEP SOME MORE.

                TS      MPAC +2
                EXTEND
                DCA     MPAC
                DXCH    BUF2            # RESTORE SWRETURN INFO.
                CAF     ONE
                TCF     GWAKE2

LGWAKE          CADR    GWAKE

# GYRO-TORQUING WAITLIST TASKS.

STRTGYRO        CS      GDESELCT        # DE-SELECT LAST GYRO.
                EXTEND
                WAND    14

                TC      CAGETEST

STRTGYR2        CA      LGYRO           # JUMP ON PHASE COUNTER IN BITS 13-14.
                EXTEND
                MP      BIT4
                INDEX   A
                TCF     +1
                TC      GSELECT         # =0. DO Y GYRO.
                OCT     00202

                TC      GSELECT         # =1. DO Z GYRO.
                OCT     00302

                TC      GSELECT -2      # =2. DO X GYRO.
                OCT     00100

                CAF     ZERO            # =3. DONE
                TS      LGYRO
                CAF     LGWAKE          # WAKE A POSSIBLE SLEEPING JOB.
                TC      JOBWAKE

                CAF     BIT2            # DONT RESET POWER SUPPLY IF BIT SET
                MASK    IMODES33        # (ONLY DURING GYRO TORQUE SCALE FACTOR
                CCS     A               # TEST).
                TCF     NORESET

                CCS     LOCCTR          # IF A JOB WAS AWAKENED, DONT RESET GYRO
                TCF     NORESET         # ENABLE.

                TCF     NORESET

                CS      BIT6            # IF NO JOB AWAKENED, RESET GYRO ENABLE.
                EXTEND
                WAND    14

NORESET         TCF     IMUFINED

 -2             CS      FOUR            # SPECIAL ENTRY TO REGRESS LGYRO FOR X.
                ADS     LGYRO

GSELECT         INDEX   Q               # SELECT GYRO.
                CAF     0               # PACKED WORD CONTAINS GYRO SELECT BITS
                TS      ITEMP4          # AND INCREMENT TO LGYRO.
                MASK    SEVEN
                AD      BIT13
                ADS     LGYRO
                TS      EBANK
                MASK    LOW8
                TS      ITEMP1

                CS      SEVEN
                MASK    ITEMP4
                TS      ITEMP4

                EXTEND                  # MOVE DP COMMAND TO RUPTREGS FOR TESTING.
                INDEX   ITEMP1
                DCA     1400
                DXCH    RUPTREG1

                CCS     RUPTREG1
                TCF     MAJ+
                TCF     +2
                TCF     MAJ-

                CCS     RUPTREG2
                TCF     MIN+
                TCF     STRTGYR2
                TCF     MIN-
                TCF     STRTGYR2

MIN+            AD      -GYROMIN        # SMALL POSITIVE COMMAND. SEE IF AT LEAST
                EXTEND                  # 16 GYRO PULSES.
                BZMF    STRTGYR2

MAJ+            EXTEND                  # DEFINITE POSITIVE OUTPUT.
                DCA     GYROFRAC
                DAS     RUPTREG1

                CA      ITEMP4          # SELECT POSITIVE TORQUING FOR THIS GYRO.
                EXTEND
                WOR     14

                CAF     LOW7            # LEAVE NUMBER OF POSSIBLE 8192 AUGMENTS
                MASK    RUPTREG2        # TO INITIAL COMMAND IN MAJOR PART OF LONG
                XCH     RUPTREG2        # TERM STORAGE AND TRUNCATED FRACTION
GMERGE          EXTEND                  # IN MINOR PART. THE MAJOR PART WILL BE
                MP      BIT8            # COUNTED DOWN TO ZERO IN THE COURSE OF
                TS      ITEMP2          # PUTTING OUT THE ENTIRE COMMAND.
                CA      RUPTREG1
                EXTEND
                MP      BIT9
                TS      RUPTREG1
                CA      L
                EXTEND
                MP      BIT14
                ADS     ITEMP2          # INITIAL COMMAND.

                EXTEND                  # SEE IF MORE THAN ONE PULSE TRAIN NEEDED
                DCA     RUPTREG1        # (MORE THAN 16383 PULSES).
                AD      MINUS1
                CCS     A
                TCF     LONGGYRO
-GYROMIN        OCT     -177            # MAY BE ADJUSTED TO SPECIFY MINIMUM CMD.

                TCF     +4

                CAF     BIT14
                ADS     ITEMP2
                CAF     ZERO

 +4             INDEX   ITEMP1
                DXCH    1400
                CA      ITEMP2          # ENTIRE COMMAND.
LASTSEG         TS      GYROCMD
                EXTEND
                MP      BIT10           # WAITLIST DT
                AD      THREE           # TRUNCATION AND PHASE UNCERTAINTIES.
                TC      WAITLIST
                2CADR   STRTGYRO

GYROEXIT        CAF     BIT10           # TURN ON GYRO ACTIVITY TO START TRAIN.
                EXTEND
                WOR     14
                TCF     TASKOVER

LONGGYRO        INDEX   ITEMP1
                DXCH    1400            # INITIAL COMMAND OUT PLUS N AUGMENTS OF
                CAF     BIT14           # 8192. INITIAL COMMAND IS AT LEAST 8192.
                AD      ITEMP2
                TS      GYROCMD

AUG3            EXTEND                  # GET WAITLIST DT TO TIME WHEN TRAIN IS
                MP      BIT10           # ALMOST OUT.
                AD      NEG3
                TC      WAITLIST
                2CADR   8192AUG

                TCF     GYROEXIT

8192AUG         TC      CAGETEST

                CA      LGYRO           # ADD 8192 PULSES TO GYROCMD
                TS      EBANK
                MASK    LOW8
                TS      ITEMP1

                INDEX   ITEMP1          # SEE IF THIS IS THE LAST AUG.
                CCS     1400
                TCF     AUG2            # MORE TO COME.

                CAF     BIT14
                ADS     GYROCMD
                TCF     LASTSEG +1

AUG2            INDEX   ITEMP1
                TS      1400
                CAF     BIT14
                ADS     GYROCMD
                TCF     AUG3            # COMPUTE DT.

MIN-            AD      -GYROMIN        # POSSIBLE NEGATIVE OUTPUT.
                EXTEND
                BZMF    STRTGYR2

MAJ-            EXTEND                  # DEFINITE NEGATIVE OUTPUT.
                DCS     GYROFRAC
                DAS     RUPTREG1

                CA      ITEMP4          # SELECT NEGATIVE TORQUING FOR THIS GYRO.
                AD      BIT9
                EXTEND
                WOR     14

                CS      RUPTREG1        # SET UP RUPTREGS TO FALL INTO GMERGE.
                TS      RUPTREG1        # ALL NUMBERS PUT INTO GYROCMD ARE
                CS      RUPTREG2        # POSITIVE - BIT9 OF CHAN 14 DETERMINES
                MASK    LOW7            # THE SIGN OF THE COMMAND.
                COM
                XCH     RUPTREG2
                COM
                TCF     GMERGE

GDESELCT        OCT     1700            # TURN OFF SELECT AND ACTIVITY BITS.

GYROFRAC        2DEC    .215 B -21

# IMU MODE SWITCHING ROUTINES COME HERE WHEN ACTION COMPLETE.

ENDIMU          EXTEND                  # MODE IS BAD IF CAGE HAS OCCURED OR IF
                READ    11              # ISS WARNING IS ON.
                MASK    BIT1
                CCS     A
                TCF     IMUBAD

IMUGOOD         TCF     GOODEND         # WITH C(A) = 0.

IMUBAD          CAF     ZERO
                TCF     BADEND

CAGETEST        CAF     BIT6            # SUBROUTINE TO TERMINATE IMU MODE
                MASK    IMODES30        # SWITCH IF IMU HAS BEEN CAGED.
                CCS     A
                TCF     IMUBAD          # DIRECTLY.
                TC      Q               # WITH C(A) = +0.

CAGETSTQ        CS      IMODES30        # SKIP IF IMU NOT BEING CAGED.
                MASK    BIT6
                CCS     A
                INCR    Q
                TC      Q

CAGETSTJ        CS      IMODES30        # IF DURING MODE SWITCH INITIALIZATION
                MASK    BIT6            # IT IS FOUND THAT THE IMU IS BEING CAGED,
                CCS     A               # SET IMUCADR TO -0 TO INDICATE OPERATION
                TC      Q               # COMPLETE BUT FAILED. RETURN IMMEDIATELY

                CS      ZERO            # TO SWRETURN.
                TS      IMUCADR
                TCF     MODEEXIT

#          GENERALIZED MODE SWITCHING TERMINATION. ENTER AT GOODEND FOR SUCCESSFUL COMPLETION OF AN I/O OPERATION
# OR AT BADEND FOR A N UNSUCCESSFUL ONE. C(A) OR ARRIVAL =0 FOR IMU, 1 FOR OPTICS.

BADEND          TS      RUPTREG2        # DEVICE INDEX.
                CS      ZERO            # FOR FAILURE.
                TCF     GOODEND +2

GOODEND         TS      RUPTREG2
                CS      ONE             # FOR SUCCESS.

                TS      RUPTREG3
                INDEX   RUPTREG2        # SEE IF USING PROGRAM ASLEEP.
                CCS     MODECADR
                TCF     +2              # YES - WAKE IT UP.
                TCF     ENDMODE         # IF 0, PROGRAM NOT IN YET.

                CAF     ZERO            # WAKE SLEEPING PROGRAM.
                INDEX   RUPTREG2
                XCH     MODECADR
                TC      JOBWAKE

                CS      RUPTREG3        # ADVANCE LOC IF SUCCESSFUL.
                INDEX   LOCCTR
                ADS     LOC

                TCF     TASKOVER

ENDMODE         CA      RUPTREG3        # -0 INDICATES OPERATION COMPLETE BUT
                INDEX   RUPTREG2        # UNSUCCESSFUL - -1 INDICATES COMPLETE AND
                TS      MODECADR        # SUCCESSFUL.
                TCF     TASKOVER

# GENERAL STALLING ROUTINE. USING PROGRAMS COME HERE TO WAIT FOR I/O COMPLETION.

AOTSTALL        CAF     ONE             # AOT.
                TC      STALL

OPTSTALL        EQUALS  AOTSTALL

IMUSTALL        CAF     ZERO            # IMU.

STALL           INHINT
                TS      RUPTREG2        # SAVE DEVICE INDEX.
                INDEX   A               # SEE IF OPERATION COMPLETE.
                CCS     MODECADR
                TCF     MODABORT        # ALLOWABLE STATES ARE +0, -1, AND -0.
                TCF     MODESLP         # OPERATION INCOMPLETE.
                TCF     MODEGOOD        # COMPLETE AND GOOD IF = -1.

MG2             INDEX   RUPTREG2        # COMPLETE AND FAILED IF -0. RESET TO +0.
                TS      MODECADR        # RETURN TO CALLER.
                TCF     MODEEXIT

MODEGOOD        CCS     A               # MAKE SURE INITIAL STATE -1.
                TCF     MODABORT

                INCR    BUF2            # IF SO, INCREMENT RETURN ADDRESS AND
                TCF     MG2             # RETURN IMMEDIATELY, SETTING CADR = +0.

MODESLP         TC      MAKECADR        # CALL FROM SWITCHABLE FIXED ONLY.
                INDEX   RUPTREG2
                TS      MODECADR
                TCF     JOBSLEEP

MODABORT        TC      ABORT           # TWO PROGRAMS USING SAME DEVICE.
                OCT     1210

# CONSTANTS FOR MODE SWITCHING ROUTINES

BITS3&4         OCT     14
BITS4&6         OCT     00050
BITS4-6         OCT     00070
IMUSEFLG        EQUALS  BIT8            # INTERPRETER SWITCH 7.
13,14,15        OCT     70000

-COMMAX         DEC     -191
-COMMAX-        DEC     -192
600MS           DEC     60
3SECSM          EQUALS  3SECS
90SEC           DEC     9000

ENDIMODS        EQUALS
