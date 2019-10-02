### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    BANK11.agc
## Purpose:     Part of the source code for AGC program Retread 50.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/Restoration.html
## Mod history: 2019-06-12 MAS  Recreated from Computer History Museum's
##				physical core-rope modules.
##              2019-10-01 MAS  Completed disassembly.

## This entire section was added between Retread 44 and Retread 50. As such, all labels, variable names,
## and comments (and even the name of the section itself!) are not original and have been added as part
## of the disassembly process. Labels and comments were taken from similar code in later programs where
## possible, and created anew by VirtualAGC where not.

                SETLOC          32000
                EBANK=          COMMAND

VBZERO          CA              BIT5                            # ROUTINE TO ZERO ICDUS.
                EXTEND
                WOR             12

                CA              20MSEC                          # WAIT 20 MS.
                INHINT
                TC              WAITLIST
                2CADR           ZEROICDU

                TC              ENDOFJOB

ZEROICDU        CAF             ZERO                            # ZERO ICDU COUNTERS.
                TS              CDUX
                TS              CDUY
                TS              CDUZ

                CS              BIT5                            # REMOVE ZERO DISCRETE.
                EXTEND
                WAND            12

                TC              TASKOVER

# IMU COARSE ALIGN MODE.

IMUCOARS        CAF             BIT4                            # SEND COARSE ALIGN ENABLE DISCRETE
                EXTEND
                WOR             12

                CAF             50MSEC
                INHINT
                TC              WAITLIST
                2CADR           COARS

                TC              ENDOFJOB

COARS           CAF             BIT6                            # ENABLE ALL THREE ISS CDU ERROR COUNTERS
                EXTEND
                WOR             12

                CAF             TWO                             # SET CDU INDICATOR
COARS1          TS              CDUIND

                INDEX           CDUIND                          # COMPUTE THETAD - THETAA IN 1:S
                CA              THETAD                          #   COMPLEMENT FORM
                EXTEND
                INDEX           CDUIND
                MSU             CDUX
                EXTEND
                MP              BIT13                           # SHIFT RIGHT 2
                XCH             L                               # ROUND
                DOUBLE
                TS              ITEMP1
                TCF             +2
                ADS             L

                INDEX           CDUIND                          # DIFFERENCE TO BE COMPUTED
                LXCH            COMMAND
                CCS             CDUIND
                TC              COARS1

                CA              20MSEC
                TC              WAITLIST
                2CADR           COARS2

                TC              TASKOVER

COARS2          CAF             ZERO
                TS              ITEMP1                          # SETS TO +0.
                CAF             TWO                             # SET CDU INDICATOR
 +3             TS              CDUIND

                INDEX           CDUIND
                CCS             COMMAND                         # NUMBER OF PULSES REQUIRED
                TC              COMPOS                          # GREATER THAN MAX ALLOWED
                TC              NEXTCDU         +1
                TC              COMNEG
                TC              NEXTCDU         +1

COMPOS          AD              -COMMAX                         # COMMAX = MAX NUMBER OF PULSES ALLOWED
                EXTEND                                          #   MINUS ONE
                BZMF            COMZERO
                INDEX           CDUIND
                TS              COMMAND                         # REDUCE COMMAND BY MAX NUMBER OF PULSES
                CS              -COMMAX-                        #   ALLOWED

NEXTCDU         INCR            ITEMP1
                INDEX           CDUIND
                TS              CDUXCMD                         # SET UP COMMAND REGISTER.

                CCS             CDUIND
                TC              COARS2          +3

                CCS             ITEMP1                          # SEE IF ANY PULSES TO GO OUT.
                TC              SENDPULS
                TC              COARS1          -1
                EXTEND
                WAND            12

                TC              TASKOVER

COMNEG          AD              -COMMAX
                EXTEND
                BZMF            COMZERO
                COM
                INDEX           CDUIND
                TS              COMMAND
                CA              -COMMAX-
                TC              NEXTCDU

COMZERO         CAF             ZERO
                INDEX           CDUIND
                XCH             COMMAND
                TC              NEXTCDU

SENDPULS        CAF             13,14,15
                EXTEND
                WOR             14
                CAF             600MS
                TC              WAITLIST
                2CADR           COARS2
                TC              TASKOVER

# KEYBOARD REQUEST TO PULSE TORQUE IRIGA

TORQGYRS        CS              BITS4-6                         # RESET ZERO, COARSE, AND ECTR ENABLE.
                EXTEND
                WAND            12

                CAF             TWO                             # INITIALIZE THE GYRO INDEX ERASABLES.
                TS              GYRONUM
                DOUBLE
                TS              GYCMDIDX
                AD              ONE
                TS              GYCMDIDX        +1

                CAF             BIT6                            # ENABLE THE POWER SUPPLY.
                EXTEND
                WOR             14

                CAF             30MSEC
                INHINT
                TC              WAITLIST
                2CADR           IMUPULSE

                TC              ENDOFJOB

#          THE FOLLOWING ROUTINE TORQUES THE IRIGS ACCORDING TO DOUBLE PRECISION INPUTS IN THE SIX REGISTERS
# BEGINNING AT LOCATION OGC. THE MINIMUM SIZE OF ANY PULSE TRAIN IS 16 PULSES (.25 CDU COUNTS). THE
# UNSENT PORTION OF THE COMMAND IS LEFT INTACT IN THE INPUT COMMAND REGISTERS.

IMUPULSE        INDEX           GYCMDIDX
                CCS             OGC                             # SEE IF MORE THAN ONE PULSE TRAIN NEEDED
                TC              LONGGYRO                        # (MORE THAN 16383 PULSES).
                TC              LASTSEG
                TC              LONGGYRO
                TC              LASTSEG

LONGGYRO        INDEX           GYCMDIDX                        # SEND MAXIMUM 16383 PULSES.
                TS              OGC

                INDEX           GYCMDIDX        +1
                INCR            OGC

                CAF             POSMAX
                TS              GYROCTR

                CA              5.13SEC                         # WAIT FOR FULL PULSE TRAIN TO GO OUT.
                TC              +1
                TC              WAITLIST
                2CADR           IMUPULSE

STRTGYRO        INDEX           GYCMDIDX        +1              # DETERMINE POLARITY OF COMMAND.
                CCS             OGC
                CAF             ZERO
                TCF             +2
                CAF             BIT9

                INDEX           GYRONUM                         # SEND PULSE COMMAND TO GYRO.
                AD              GYBITTAB
                EXTEND
                WRITE           14

                TC              TASKOVER

LASTSEG         INDEX           GYCMDIDX        +1              # ENTIRE COMMAND.
                CCS             OGC
                TC              +4
                TC              GYROEXIT
                TC              +2
                TC              GYROEXIT

                AD              ONE
                TS              GYROCTR

                AD              -GYROMIN                        # SMALL GYRO COMMAND. SEE IF AT LEAST
                EXTEND                                          # 16 GYRO PULSES.
                BZMF            GYROEXIT

                CAF             BIT10                           # GET WAITLIST DT TO TIME WHEN TRAIN IS
                EXTEND                                          # ALMOST OUT.
                MP              GYROCTR
                AD              TWO
                TC              +1
                TC              WAITLIST
                2CADR           GYROEXIT

                TC              STRTGYRO

GYROEXIT        CCS             GYRONUM
                TCF             NEXTGYRO

                CS              BIT6                            # RESET GYRO ENABLE.
                EXTEND
                WAND            14

                TC              TASKOVER

NEXTGYRO        TS              GYRONUM
                DOUBLE
                TS              GYCMDIDX
                AD              ONE
                TS              GYCMDIDX        +1
                TC              IMUPULSE

# KEYBOARD REQUEST TO TURN ON INERTIAL SUBSYSTEM

ISSUP           CS              BIT15                           # REMOVE IMU DELAY COMPLETE DISCRETE.
                EXTEND
                WAND            12

                CAF             BIT14                           # SEE IF ISS HAS TURNED ON.
                EXTEND
                RAND            30

                CCS             A
                TC              +2
                TC              CAGESUB

                CAF             1SEC                            # CHECK AGAIN IN ONE SECOND.
                TC              WAITLIST
                2CADR           ISSUP

                TC              TASKOVER

CAGESUB         CA              BITS4&5                         # SEND ZERO AND COARSE.
                EXTEND
                WOR             12

                CA              90SECS
                TC              +1
                TC              WAITLIST
                2CADR           ENDTNON

                TC              TASKOVER

ENDTNON         CAF             BIT15                           # SEND ISS DELAY COMPLETE.
                EXTEND
                WOR             12

ENDTNON2        CAF             BIT14
                EXTEND
                RAND            30

                CCS             A                               # IS TURN-ON COMPLETE?
                TC              +2                              # YES.
                TC              ENDTNON3                        # NO. TRY AGAIN IN 10 MS.

                CS              BITS5&15                        # REMOVE IMU ZERO AND DELAY COMPLETE.
                EXTEND
                WAND            12

                CAF             BIT6                            # ENABLE ERROR COUNTERS.
                EXTEND
                WOR             12

                TC              TASKOVER

ENDTNON3        CAF             10MSEC
                TC              +1
                TC              WAITLIST
                2CADR           ENDTNON2

                TC              TASKOVER

# IMU FINE ALIGN MODE SWITCH.

IMUFINE         CS              BITS4-6                         # RESET ZERO, COARSE, AND ECTR ENABLE.
                EXTEND
                WAND            12
                TC              ENDOFJOB


# WAITLIST DELAY TIME CONSTANTS

10MSEC          DEC             1
20MSEC          DEC             2
30MSEC          DEC             3
50MSEC          DEC             5
600MS           DEC             60
1SEC            DEC             100
90SECS          DEC             9000

# CONSTANTS FOR MODE SWITCHING ROUTINES

-COMMAX         DEC             -191
-COMMAX-        DEC             -192

5.13SEC         DEC             513
-GYROMIN        DEC             -16                             # MAY BE ADJUSTED TO SPECIFY MINIMUM CMD.

BITS4&6         OCT             00050
BITS4-6         OCT             00070
BITS4&5         OCT             00030
BITS5&15        OCT             40020
13,14,15        OCT             70000

GYBITTAB        OCT             1140                            # POWER SUPPLY ENABLE, GYRO SELECT,
                OCT             1340                            # GYRO COMMAND OUT.
                OCT             1240

# FAN-OUT

LST2FAN         TC              VBZERO                          # VB40 ZERO ISS CDU
                TC              IMUCOARS                        # VB41 COARSE ALIGN IMU
                TC              IMUFINE                         # VB42 FINE ALIGN IMU
                TC              TORQGYRS                        # VB43 PULSE TORQUE GYROS
ITURNON         INHINT                                          # VB44 ISS TURN ON
                CAF             ONE
                TC              WAITLIST
                2CADR           ISSUP
                TC              ENDOFJOB
