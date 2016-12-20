### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     T4RUPT_PROGRAM.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        160-188
## Mod history:  2016-09-20 JL   Created.
##               2016-10-12 HG   fix operand  DSPRUPTSW -> DSRUPTSW
##               2016-10-15 HG   fix operand  DSPRUPTEM -> DSRUPTEM
##                                            SEDTISSW  -> SETISSW 
##                                            GLOCKKOK  -> GLOCKOK 
##                                            NCTFL33   -> NXTFL33  
##                                            BITS56&15 -> BITS6&15 
##                                            COSMSG    -> COSMG   
##                               fix label and operand
##                                            NXTIBIT   -> NTXIBT
##                                            GLOCKON   -> GLOCKOK
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

## Page 160
                SETLOC          ENDPHMNF
                EBANK=          M11
T4RUPT          EXTEND                                  # ZERO OUT0 EVERY T4RUPT.
                WRITE           OUT0                    # (COMES HERE WITH +0 IN A)

                INDEX           T4LOC                   # NORMALLY TO NORMT4, BUT TO LMPRESET OR
                TCF             0                       # DSKYRSET AFTER OUT0 COMMAND.

NORMT4          CCS             DSRUPTSW                # GOES 7(-1)0.
                TCF             +2
                CAF             SEVEN
                TS              DSRUPTSW

                CAF             T4RPTBB                 # OFF TO SWITCHED BANK
                XCH             BBANK
                TCF             T4RUPTA

LMPRESET        CAF             90MRUPT                 # 30 MS ON / 90 MS OFF.
                TCF             +2

DSKYRSET        CAF             100MRUPT                # 20 MS ON / 100 MS OFF.
                TS              TIME4
                CAF             LNORMT4
                TS              T4LOC
                TCF             NOQBRSM

90MRUPT         DEC             16375
100MRUPT        DEC             16374
LNORMT4         ADRES           NORMT4
74K             OCT             74000

# RELTAB IS A PACKED TABLE. RELAYWORD CODE IN UPPER 4 BITS, RELAY CODE
# IN LOWER 5 BITS.

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
## Page 161
ENDT4FF         EQUALS

## Page 162
#          SWITCHED-BANK PORTION.

                SETLOC          ENDFRESS

T4RUPTA         TS              BANKRUPT
                EXTEND
                QXCH            QRUPT

LMPOUT          CCS             LMPCMD                  # SEE IF LMP COMMAND TO BE SENT. IF SO,
                TCF             CDRVE                   # BIT 15 = 1 AND (UP TO) BITS 1 - 11
                TCF             CDRVE                   # CONTAIN THE COMMAND.

                CAF             LOW11
                MASK            LMPCMD                  # LEAVE COMMAND PORTION INTACT.
                TS              LMPCMD
                AD              74K
                EXTEND
                WRITE           OUT0

                CAF             LLMPRS
                TS              T4LOC
                CAF             30MRUPT
                TCF             SETTIME4

CDRVE           CCS             DSPTAB          +11D
                TC              DSPOUT
                TC              DSPOUT

                XCH             DSPTAB          +11D
                MASK            LOW11
                TS              DSPTAB          +11D
                AD              RELTAB11
                TC              DSPLAYC

## Page 163
# DSPOUT PROGRAM. PUTS OUT DISPLAYS.

DSPOUT          CCS             NOUT                    # DRIVE DISPLAY SYSTEM RELAYS.
                TCF             +3

NODSPOUT        CAF             120MRUPT                # SET FOR RUPT IN 120 MS IF NO RELAYS.
                TCF             SETTIME4

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
120MRUPT        DEC             16372                   # (DSPCNT = 0). +0 INTO NOUT.
                TS              NOUT
                TCF             NODSPOUT
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

                CAF             LDSKYRS
                TS              T4LOC
                CAF             20MRUPT

SETTIME4        TS              TIME4
## Page 164
# JUMP TO APPROPRIATE ONCE-PER SECOND (.96 SEC ACTUALLY) ACTIVITY

T4JUMP          INDEX           DSRUPTSW
                TCF             +1

                TC              ALTOUT

                TCF             RRAUTCHK
                TCF             IMUMON
                TCF             GPMATRIX
                TC              ALTROUT
                TCF             RRAUTCHK
                TCF             IMUMON
                TCF             GPMATRIX
LDSKYRS         ADRES           DSKYRSET
LLMPRS          ADRES           LMPRESET

30MRUPT         DEC             16381
20MRUPT         DEC             16382
## Page 165
# THIS ROUTINE SERVICES THE METER OUTPUTS.


# DIDFLG INDICATES THE STATE OF THE PROGRAM..............
# IF GREATER THAN ZERO, THEN UNABLE TO DISPLAY DATA
# IF EQUAL TO ZERO, THEN THE PROGRAM IS IN USE
# IF LESS THAN ZERO, THEN THE PROGRAM IS ABLE TO BE USED............

ALTOUT          TC              DISINDAT
                CS              BIT2
                EXTEND
                WAND            14                      # SET UP OUTPUT FOR ALTITUDE
                CCS             ALT                     # -1 IF OLD DATA TO BE EXTRAPOLATED.
                TCF             +4                      # NEW DATA.
                TCF             +3
                TCF             OLDDATA

                TS              ALT                     # CHANGE -0 IN ALT TO +0.
                CS              ONE                     # RESET ALTSAVE.
                DXCH            ALT
ZDATA2          DXCH            ALTSAVE
                TCF             NEWDATA

OLDDATA         CA              ALTRATE                 # USE ALTRATE TO EXTRAPOLATE.
                EXTEND
                MP              ARTOA                   # RATE APPLIES FOR .96 SEC.
                AD              ALTSAVE         +1
                TS              ALTSAVE         +1      # AND MAYBE SKIP.
                CAF             ZERO
                ADS             ALTSAVE

                CAF             POSMAX                  # FORCE SIGN AGREEMENT ASSUMING ALTSAVE IS
                AD              ONE                     # NOT NEGATIVE. IF IT IS, THE FINAL TS
                AD              ALTSAVE         +1      # WILL NOT SKIP AND WE CAN SET ALTSAVE TO
                TS              ALTSAVE         +1      # ZERO IN THAT CASE.
                CAF             ZERO
                AD              POSMAX
                AD              ALTSAVE
                TS              ALTSAVE
                TCF             ZERODATA                # ALTSAVE NEGATIVE - SET TO ZERO.

NEWDATA         CCS             ALTSAVE                 # MAKE UP 15 BIT UNSIGNED OUTPUT.
                CAF             BIT15                   # MAJOR PART +1 OR +0.
                AD              ALTSAVE         +1
METEROUT        TS              ALTM
                CAF             BITSET
                EXTEND
                WOR             14
                TCF             DONEDID
## Page 166
ALTROUT         TC              DISINDAT
                CAF             BIT2
                EXTEND
                WOR             14                      # SET UP OUTPUT FOR ALT. RATE
                CA              ALTRATE
                TCF             METEROUT

DISINDAT        CCS             DIDFLG
                TCF             DONEDID
                NOOP
                CAF             BIT6
                EXTEND
                RAND            30                      # CHECK DISPLAY INERTIAL DATA BIT
                CCS             A
                TCF             ALLDONE
                CCS             DIDFLG
                NOOP
                TCF             GOAGN

FIRSTIME        CAF             BIT8
                EXTEND
                WOR             12                      # ENABLE DISPLAY INERTIAL DATA
                CAF             ZERO
                TS              DIDFLG
                TS              LASTXCMD
                TS              LASTYCMD
                CAF             SIX
                TC              WAITLIST
                2CADR           INTLZE

                TC              DONEDID

INTLZE          CAF             BIT2
                EXTEND
                WOR             12                      # ENABLE RR ERROR COUNTER
                TC              TASKOVER

GOAGN           CS              LASTXCMD
                AD              FORVEL
                TS              OPTXCMD
                CA              FORVEL
                TS              LASTXCMD
                CS              LASTYCMD
                AD              LATVEL
                TS              OPTYCMD
                CA              LATVEL
                TS              LASTYCMD
                TC              Q

ALLDONE         CS              DIDRESET                # REMOVE DISPLAY INERTIAL DATA AND ECTR.
## Page 167
                EXTEND
                WAND            12                      # RESET RR ERROR COUNTER
DONEDID         TCF             RCSMONIT
ZERODATA        CAF             ZERO
                TS              L
                TCF             ZDATA2

ARTOA           DEC             .20469                  # ALT DUE TO ALTRATE FOR .96 SEC.
BITSET          OCT             6004

DIDRESET        OCT             202
## Page 168
# IMU INBIT MONITOR - ENTERED EVERY 480 MS BY T4RUPT.

IMUMON          CA              IMODES30                # SEE IF THERE HAS BEEN A CHANGE IN THE
                EXTEND                                  # RELEVENT BITS OF CHAN 30.
                RXOR            30
                MASK            30RDMSK
                EXTEND
                BZF             TNONTEST                # NO CHANGE IN STATUS.

                TS              RUPTREG1                # SAVE BITS WHICH HAVE CHANGED.
                LXCH            IMODES30                # UPDATE IMODES30.
                EXTEND
                RXOR            L
                TS              IMODES30

                CS              ONE
                XCH             RUPTREG1
                EXTEND
                BZMF            TLIM                    # CHANGE IN IMU TEMP.
                TCF             NXTIFBIT                # BEGIN BIT SCAN.

 -1             AD              ONE                     # (RE-ENTERS HERE FROM NXTIFAIL.)
NXTIFBIT        INCR            RUPTREG1                # ADVANCE BIT POSITION NUMBER.
 +1             DOUBLE
                TS              A                       # SKIP IF OVERFLOW.
                TCF             NXTIFBIT                # LOOK FOR BIT.

                XCH             RUPTREG2                # SAVE OVERFLOW-CORRECTED DATA.
                INDEX           RUPTREG1                # SELECT NEW VALUE OF THIS BIT.
                CAF             BIT14
                MASK            IMODES30
                INDEX           RUPTREG1
                TC              IFAILJMP

NXTIFAIL        CCS             RUPTREG2                # PROCESS ANY ADDITIONAL CHANGES.
                TCF             NXTIFBIT        -1

TNONTEST        CS              IMODES30                # AFTER PROCESSING ALL CHANGES, SEE IF IT
                MASK            BIT7                    # IS TIME TO ACT ON A TURN-ON SEQUENCE.
                CCS             A
                TCF             C33TEST                 # NO - EXAMINE CHANNEL 33.

                CAF             BIT8                    # SEE IF FIRST SAMPLE OR SECOND.
                MASK            IMODES30
                CCS             A
                TCF             PROCTNON                # REACT AFTER SECOND SAMPLE.

                CAF             BIT8                    # IF FIRST SAMPLE, SET BIT TO REACT NEXT
                ADS             IMODES30                # TIME.
                TCF             C33TEST
## Page 169
# PROCESS IMU TURN-ON REQUESTS AFTER WAITING 1 SAMPLE FOR ALL SIGNALS TO ARRIVE.

PROCTNON        CS              BITS7&8
                MASK            IMODES30
                TS              IMODES30
                MASK            BIT14                   # SEE IF TURN-ON REQUEST.
                CCS             A
                TCF             OPONLY                  # OPERATE ON ONLY.

                CS              IMODES30                # IF TURN-ON REQUEST, WE SHOULD HAVE IMU
                MASK            BIT9                    # OPERATE.
                CCS             A
                TCF             +3

                TC              ALARM                   # ALARM IF NOT.
                OCT             213

 +3             TC              CAGESUB
                CAF             90SECS
                TC              WAITLIST
                2CADR           ENDTNON
                TCF             C33TEST

RETNON          CAF             90SECS
                TC              VARDELAY

ENDTNON         CS              BIT2                    # RESET TURN-ON REQUEST FAIL BIT.
                MASK            IMODES30
                XCH             IMODES30
                MASK            BIT2                    # IF IT WAS OFF, SEND ISS DELAY COMPLETE.
                EXTEND
                BZF             ENDTNON2

                CAF             BIT14                   # IF IT WAS ON AND TURN-ON REQUEST NOW
                MASK            IMODES30                # PRESENT, RE-ENTER 90 SEC DELAY IN WL.
                EXTEND
                BZF             RETNON

                CS              STATE                   # IF IT IS NOT ON NOW, SEE IF A PROG WAS
                MASK            IMUSEFLG                # WAITING.
                CCS             A
                TCF             TASKOVER
                TC              POSTJUMP
                CADR            IMUBAD                  # UNSUCCESSFUL TURN-ON.

ENDTNON2        CAF             BIT15                   # SEND ISS DELAY COMPLETE.
                EXTEND
                WOR             12
## Page 170
UNZ2            TC              ZEROICDU

                CS              BITS4&5                 # REMOVE ZERO AND COARSE.
                EXTEND
                WAND            12

                CAF             3SECS                   # ALLOW 3 SECS FOR COUNTER TO FIND GIMBAL.
                TC              VARDELAY

ISSUP           CS              OCT54                   # REMOVE CAGING, IMU FAIL INHIBIT, AND
                MASK            IMODES30                # ICDUFAIL INHIBIT FLAGS.
                TS              IMODES30

                TC              SETISSW                 # ISS WARNING MIGHT HAVE BEEN INHIBITED.

                CS              BIT15                   # REMOVE IMU DELAY COMPLETE DISCRETE.
                EXTEND
                WAND            12

                CAF             BIT11                   # DONT ENABLE PROG ALARM ON PIP FAIL FOR
                TC              WAITLIST                # ANOTHER 10 SECS.
                2CADR           PFAILOK
                CS              STATE                   # SEE IF ANYONE IS WAITING FOR THE IMU AT
                MASK            IMUSEFLG                # IMUZERO. IF SO, WAKE THEM UP.
                CCS             A
                TCF             TASKOVER

                TC              POSTJUMP
                CADR            ENDIMU

OPONLY          CAF             IMUSEFLG                # IF OPERATE ON ONLY, ZERO THE COUNTERS
                MASK            STATE                   # UNLESS SOMEONE IS USING THE IMU.
                CCS             A
                TCF             C33TEST

                TC              CAGESUB2                # SET TURNON FLAGS.

                CAF             BIT5
                EXTEND
                WOR             12

                CAF             BIT6                    # WAIT 300 MS FOR AGS TO RECEIVE SIGNAL.
                TC              WAITLIST
                2CADR           UNZ2
                TCF             C33TEST
## Page 171
# MONITOR CHANNEL 33 FLIP-FLOP INPUTS.

C33TEST         CA              IMODES33                # SEE IF RELEVENT CHAN33 BITS HAVE
                MASK            33RDMSK
                TS              L                       # CHANGED.
                CAF             33RDMSK
                EXTEND
                WAND            33                      # RESETS FLIP-FLOP INPUTS.
                EXTEND
                RXOR            L
                EXTEND
                BZF             GLOCKMON                # ON NO CHANGE.

                TS              RUPTREG1                # SAVE BITS WHICH HAVE CHANGED.
                LXCH            IMODES33
                EXTEND
                RXOR            L
                TS              IMODES33                # UPDATED IMODES33.

                CAF             ZERO
                XCH             RUPTREG1
                DOUBLE
                TCF             NXTIBT          +1      # SCAN FOR BIT CHANGES.

 -1             AD              ONE
NXTIBT          INCR            RUPTREG1
 +1             DOUBLE
                TS              A                       # (CODING IDENTICAL TO CHAN 30).
                TCF             NXTIBT

                XCH             RUPTREG2
                INDEX           RUPTREG1                # GET NEW VALUE OF BIT WHICH CHANGED.
                CAF             BIT13
                MASK            IMODES33
                INDEX           RUPTREG1
                TC              C33JMP

NXTFL33         CCS             RUPTREG2                # PROCESS POSSIBLE ADDITIONAL CHANGES.
                TCF             NXTIBT          -1
## Page 172
# MONITOR FOR GIMBAL LOCK.

GLOCKMON        CCS             CDUZ
                TCF             GLOCKCHK                # SEE IF MAGNITUDE OF MGA IS GREATER THAN
                TCF             SETGLOCK                # 70 DEGREES.
                TCF             GLOCKCHK
                TCF             SETGLOCK

GLOCKCHK        AD              -70DEGS
                EXTEND
                BZMF            SETGLOCK        -1      # NO LOCK.

                CAF             BIT6                    # GIMAL LOCK.
                TCF             SETGLOCK

 -1             CAF             ZERO
SETGLOCK        AD              DSPTAB          +11D    # SEE IF PRESENT STATE OF GIMBAL LOCK LAMP
                MASK            BIT6                    # AGREES WITH DESIRED STATE BY HALF ADDING
                EXTEND                                  # THE TWO.
                BZF             GLOCKOK                 # OK AS IS.

                MASK            DSPTAB          +11D    # IF OFF, DONT TURN ON IF IMU BEING CAGED.
                CCS             A
                TCF             GLAMPTST                # TURN OFF UNLESS LAMP TEST IN PROGRESS.

                CAF             BIT6
                MASK            IMODES30
                CCS             A
                TCF             GLOCKOK

GLINVERT        CS              DSPTAB          +11D    # INVERT GIMBAL LOCK LAMP.
                MASK            BIT6
                AD              BIT15                   # TO INDICATE CHANGE IN DSPTAB +11D.
                XCH             DSPTAB          +11D
                MASK            OCT37737
                ADS             DSPTAB          +11D
                TCF             GLOCKOK

GLAMPTST        TC              LAMPTEST                # TURN OFF UNLESS LAMP TEST IN PROGRESS.
                TCF             GLOCKOK
                TCF             GLINVERT

-70DEGS         DEC             -.38888                 # -70 DEGREES SCALED IN HALF-REVOLUTIONS.
OCT37737        OCT             37737
## Page 173
# SUBROUTINES TO PROCESS INBIT CHANGES. NEW VALUE OF BIT ARRIVES IN A, EXCEPT FOR TLIM.

TLIM            MASK            POSMAX                  # REMOVE BIT FROM WORD OF CHANGES AND SET
                TS              RUPTREG2                # DSKY TEMP LAMP ACCORDINGLY.

                CCS             IMODES30
                TCF             TEMPOK
                TCF             TEMPOK

                CAF             BIT4                    # TURN ON LAMP.
                EXTEND
                WOR             11
                TCF             NXTIFAIL

TEMPOK          TC              LAMPTEST                # IF TEMP NOW OK, DONT TURN OFF LAMP IF
                TCF             NXTIFAIL                # LAMP TEST IN PROGRESS.

                CS              BIT4
                EXTEND
                WAND            11
                TCF             NXTIFAIL

ITURNON         CAF             BIT2                    # IF DELAY REQUEST HAS GONE OFF
                MASK            IMODES30                # PREMATURELY, DO NOT PROCESS ANY CHANGES
                CCS             A                       # UNTIL THE CURRENT 90 SEC WAIT EXPIRES.
                TCF             NXTIFAIL

                CAF             BIT14                   # SEE IF JUST ON OR OFF.
                MASK            IMODES30
                EXTEND
                BZF             ITURNON2                # IF JUST ON.

                CAF             BIT15
                EXTEND                                  # SEE IF DELAY PRESENT DISCRETE HAS BEEN
                RAND            12                      # SENT. IF SO, ACTION COMPLETE.
                EXTEND
                BZF             +2
                TCF             NXTIFAIL

                CAF             BIT2                    # IF NOT, SET BIT TO INDICATE REQUEST NOT
                ADS             IMODES30                # PRESENT FOR FULL DURATION.
                TC              ALARM
                OCTAL           207
                TCF             NXTIFAIL

ITURNON2        CS              BIT7                    # SET BIT 7 TO INITIATE WAIT OF 1 SAMPLE.
                MASK            IMODES30
                AD              BIT7
                TS              IMODES30
                TCF             NXTIFAIL
## Page 174
IMUCAGE         CCS             A                       # NO ACTION IF GOING OFF.
                TCF             NXTIFAIL

                CS              OCT71000                # TERMINATE ICDU AND GYRO PULSE TRAINS.
                EXTEND
                WAND            14

                TC              CAGESUB

                CAF             ZERO                    # ZERO COMMAND OUT-COUNTERS.
                TS              CDUXCMD
                TS              CDUYCMD
                TS              CDUZCMD
                TS              GYROCMD

                CS              OCT1700                 # HAVING WAITED AT LEAST 27 MCT FROM
                EXTEND                                  # GYRO PULSE TRAIN TERMINATION, WE CAN
                WAND            14                      # DE-SELECT THE GYROS.

                TCF             NXTIFAIL

IMUOP           EXTEND
                BZF             IMUOP2

                CS              STATE                   # IF GOING OFF, ALARM IF PROG USING IMU.
                MASK            IMUSEFLG
                CCS             A
                TCF             NXTIFAIL

                TC              ALARM
                OCT             214
                TCF             NXTIFAIL

IMUOP2          CAF             BIT2                    # SEE IF FAILED ISS TURN-ON SEQ IN PROG.
                MASK            IMODES30
                CCS             A
                TCF             NXTIFAIL                # IF SO, DONT PROCESS UNTIL PRESENT 90
                TCF             ITURNON2                # SECONDS EXPIRES.

PIPFAIL         CCS             A                       # SET BIT10 IN IMODES30 SO ALL ISS WARNING
                CAF             BIT10                   # INFO IS IN ONE REGISTER.
                XCH             IMODES30
                MASK            -BIT10
                ADS             IMODES30

                TC              SETISSW

                CS              IMODES30                # IF PIP FAIL DOESNT LIGHT ISS WARNING, DO
                MASK            BIT1                    # A PROGRAM ALARM IF IMU OPERATING BUT NOT
                CCS             A                       # CAGED OR BEING TURNED ON.
## Page 175
                TCF             NXTFL33

                CA              IMODES30
                MASK            OCT1720
                CCS             A
                TCF             NXTFL33                 # ABOVE CONDITION NOT MET.

                TC              ALARM
                OCT             212
                TCF             NXTFL33

DNTMFAST        CCS             A                       # DO PROG ALARM IF TM TOO FAST.
                TCF             NXTFL33

                TC              ALARM
                OCT             1105
                TCF             NXTFL33

UPTMFAST        CCS             A                       # SAME AS DNLINK TOO FAST WITH DIFFERENT
                TCF             NXTFL33                 # ALARM CODE.

                TC              ALARM
                OCT             1106
                TCF             NXTFL33
## Page 176
# CLOSED SUBROUTINES FOR IMU MONITORING.
SETISSW         CAF             OCT15                   # SET ISS WARNING USING THE FAIL BITS IN
                MASK            IMODES30                # BITS 13, 12, AND 10 OF IMODES30 AND THE
                EXTEND                                  # FAILURE INHIBIT BITS IN POSITIONS
                MP              BIT10                   # 4, 3, AND 1.
                CA              IMODES30
                EXTEND
                ROR             L                       # 0 INDICATES FAILURE.
                COM
                MASK            OCT15000
                CCS A
                TCF             ISSWON                  # FAILURE.

ISSWOFF         CAF             BIT1                    # DONT TURN OFF ISS WARNING IF LAMP TEST
                MASK            IMODES33                # IN PROGRESS.
                CCS             A
                TC              Q

                CS              BIT1
                EXTEND
                WAND            11
                TC              Q

ISSWON          CAF             BIT1
                EXTEND
                WOR             11
                TC              Q

CAGESUB         CS              BITS6&15                # SET OUTBITS AND INTERNAL FLAGS FOR
                EXTEND                                  # SYSTEM TURN-ON OR CAGE. DISABLE THE
                WAND            12                      # ERROR COUNTER AND REMOVE IMU DELAY COMP.
                CAF             BITS4&5                 # SEND ZERO AND COARSE.
                EXTEND
                WOR             12

CAGESUB2        CS              OCT75                   # SET FLAGS TO INDICATE CAGING OR TURN-ON,
                MASK            IMODES30                # AND TO INHIBIT ALL ISS WARNING INFO.
                AD              OCT75
                TS              IMODES30

                TC              Q

IMUFAIL         EQUALS          SETISSW
ICDUFAIL        EQUALS          SETISSW
## Page 177
# JUMP TABLES AND CONSTANTS.
IFAILJMP        TCF             ITURNON                 # CHANNEL 30 DISPATCH.
                TCF             IMUFAIL
                TCF             ICDUFAIL
                TCF             IMUCAGE
30RDMSK         OCT             76400                   # (BIT 10 NOT SAMPLED HERE).
                TCF             IMUOP

C33JMP          TCF             PIPFAIL                 # CHANNEL 33 DISPATCH.
                TCF             DNTMFAST
                TCF             UPTMFAST

# SUBROUTINE TO SKIP IF LAMP TEST NOT IN PROGRESS.
LAMPTEST        CS              IMODES33                # BIT1 OF IMODES33 = 1 IF LAMP TEST IN
                MASK            BIT1                    # PROGRESS.
                CCS             A
                INCR            Q
                TC              Q

33RDMSK         EQUALS          PRIO16
OCT15           OCT             15
BITS4&5         OCT             30
OCT54           OCT             54
OCT75           OCT             75
BITS7&8         OCT             300
OCT1720         OCT             1720
OCT1700         OCT             1700
OCT15000        EQUALS          PRIO15
OCT71000        OCT             71000
BITS6&15        OCT             40040
-BIT10          OCT             -1000

90SECS          DEC             9000
120MS           DEC             12

GLOCKOK         EQUALS          RCSMONIT
NOIMUMON        EQUALS          GLOCKOK
## Page 178
# RR INBIT MONITOR.
RRAUTCHK        CA              RADMODES                # SEE IF CHANGE IN RR AUTO MODE BIT.
                EXTEND
                RXOR            33
                MASK            BIT2
                EXTEND
                BZF             RRCDUCHK

                LXCH            RADMODES                # UPDATE RADMODES.
                EXTEND
                RXOR            L
                TS              RADMODES
                MASK            BIT2                    # SEE IF JUST ON.
                CCS             A
                TCF             RROFF                   # OFF.

                CAF             BIT7                    # IF JUST ON AND SOME PROGRAM IS USING THE
                MASK            STATE                   # RR, DONT ZERO THE CDUS.
                CCS             A
                TCF             RRCDUCHK

                CS              OCT10001                # SET BITS TO INDICATE ZERO AND TURNON
                MASK            RADMODES                # IN PROGRESS.
                AD              OCT10001
                TS              RADMODES

                CAF             ONE
                TC              WAITLIST
                2CADR           RRTURNON
                TCF             NORRGMON

OCT10001        OCT             10001

RROFF           CS              STATE                   # IF SOMEONE WAS USING THE RR, DISPLAY AN
                MASK            BIT7                    # ALARM IF THE RR GOES OUT OF AUTO MODE.
                CCS             A
                TCF             RRCDUCHK

                TC              ALARM
                OCT             514
## Page 179
# CHECK FOR RR CDU FAIL.
RRCDUCHK        CA              RADMODES                # LAST SAMPLED BIT IN RADMODES.
                EXTEND
                RXOR            30
                MASK            BIT7
                EXTEND
                BZF             RRGIMON

                CAF             BIT2                    # IF RR NOT IN AUTO MODE, DONT CHANGE BIT
                MASK            RADMODES                # 7 OF RADMODES. IF THIS WERE NOT DONE,
                CCS             A                       # THE TRACKER FAIL MIGHT COME ON WHEN
                TCF             NORRGMON                # JUST READING LR DATA.

                CAF             BIT7                    # SET BIT 7 OF RADMODES FOR SETTRKF.
                LXCH            RADMODES                # UPDATE RADMODES.
                EXTEND
                RXOR            L
                TS              RADMODES

TRKFLCDU        TC              SETTRKF                 # UPDATE TRACKER FAIL LAMP ON DSKY.
## Page 180
# THE RR GIMBAL LIMIT MONITOR IS ENABLED WHENEVER THE RR IS IN THE AUTO MODE EXCEPT WHEN THE RR CDUS ARE
# BEING ZEROED, OR DURING A REMODE OR MONITOR REPOSITION OPERATION. THE LATTER IS INITIATED BY THIS MONITOR WHEN
# THE GIMBALS EXCEED THE LIMITS FOR THE CURRENT MODE. A ROUTINE IS INITIATED TO DRIVE THE GIMBALS TO T = 0 AND
# S = 0 IF IN MODE 1 AND T = 180 WITH S = -90 FOR MODE 2.

RRGIMON         CAF             OCT32002                # INHIBITED BY REMODE, ZEROING, MONITOR,
                MASK            RADMODES                # OR RR NOT IN AUTO.
                CCS             A
                TCF             NORRGMON

                TC              RRLIMCHK                # SEE IF ANGLES IN LIMITS.
                ADRES           OPTY

                TCF             MONREPOS

                TCF             NORRGMON                # (ADDITIONAL CODING MAY GO HERE).

MONREPOS        CAF             BIT11                   # SET FLAG TO SHOW REPOSITION IN PROGRESS.
                ADS             RADMODES

                CS              OCT20002                # DISABLE TRACKER AND ERROR COUNTER.
                EXTEND
                WAND            12

                CAF             TWO
                TC              WAITLIST
                2CADR           DORREPOS
                TCF             NORRGMON

OCT32002        OCT             32002
OCT20002        OCT             20002
## Page 181
# PROGRAM NAME: GPMATRIX          MOD. NO. 0  DATE: OCTOBER 20, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS PROGRAM CALCULATES ALL THE SINGLE-PRECISION MATRIX ELEMENTS WHICH ARE USED BY LEM DAP TO TRANSFORM VECTORS
# FROM GIMBAL TO PILOT (BODY) AXES AND BACK AGAIN.  THESE ELEMENTS ARE USED EXCLUSIVELY BY BASIC LANGUAGE ROUTINES
# AND THEREFORE ARE NOT ARRAYED FOR USE BY INTERPRETIVE PROGRAMS.

# CALLING SEQUENCE: GPMATRIX IS ALWAYS EXECUTED 4 TIMES A SECOND BY T4RUPT PROGRAM.  IT IS LISTED EXPLICITLY TWICE
# IN THE T4JUMP TABLE, BUT IT ALSO OCCURS AFTER RRAUTCHK (TWICE).

# SUBROUTINES CALLED: SPSIN, SPCOS.

# NORMAL EXIT MODE: CONTROL IS ALWAYS TRANSFERRED TO DBSELECT.

# ALARM/ABORT MODE: THERE ARE NO REAL ALARMS OR ABORTS.  HOWEVER, WHEN THE MIDDLE GIMBAL ANGLE NEARS GIMBAL LOCK,
# A DIVISION BY COS(MG) WILL CAUSE OVERFLOW (I.E. A BAD QUOTIENT).  THIS CONDITION IS PREVENTED BY TESTING COS(MG)
# AND SUBSTITUTING POSMAX/NEGMAX FOR THE INCALCULABLE QUANTITITIES.

# INPUT: CDUX,CDUY,CDUZ.          OUTPUT: M11,M21,M31,M22,M32,MR12,MR13.
#                                         (ALSO MR22=M22,MR23=M32)        AM DOES NOT DETECT IT.

# *** WARNING ** IT DIES ON DV OVERFLOW.

# AOG = CDUX, AIG = CDUY, AMG = CDUZ: MNEMONIC IS: OIM = XYZ

#    *       *    SIN(MG)        0         1  *
#    M   =   *    COS(MG)COS(OG) SIN(OG)   0  *
#     GP     *   -COS(MG)SIN(OG) COS(OG)   0  *

#    *       *  0    COS(OG)/COS(MG)        -SIN(OG)/COS(MG)         *
#    M   =   *  0    SIN(OG)                 COS(OG)                 *
#     PG     *  1   -SIN(MG)COS(OG)/COS(MG)  SIN(MG)SIN(OG)/COS(MG)  *

GPMATRIX        CAE             CDUZ                    # SINGLE ENTRY POINT
                TC              SPSIN                   # SIN(CDUZ) = SIN(MG)
                TS              M11                     # SCALED AT 1

                CAE             CDUZ
                TC              SPCOS                   # COS(CDUZ) = COS(MG)
                TS              COSMG                   # SCALED AT 1 (ONLY A FACTOR)

                CAE             CDUX
                TC              SPSIN                   # SIN(CDUX) = SIN(OG)
                TS              M22                     # SCALED AT 1 (ALSO IS MR22)

                CS              M22
                EXTEND
                MP              COSMG                   # -SIN(OG)COS(MG)
                TS              M31                     # SCALED AT 1
## Page 182
                CAE             CDUX
                TC              SPCOS                   # COS(CDUX) = COS(OG)
                TS              M32                     # SCALED AT 1 (ALSO IS MR23)

                EXTEND
                MP              COSMG                   # COS(OG)COS(MG)
                TS              M21                     # SCALED AT 1

                CAE             COSMG                   # TEST FOR GIMBAL LOCK (OVERFLOW) REGION
                AD              NEG1/2                  # BY TESTING MIDDLE GIMBAL ANGLE FOR
                EXTEND                                  # VALUES EQUAL TO OR GREATER THAN 60 DEGS.
                BZMF            GPGLOCK

                CAE             M32
                EXTEND
                MP              BIT14                   # SCALE FOR DIVISION
                EXTEND
                DV              COSMG                   # COS(OG)/COS(MG)
                TS              MR12                    # SCALED AT 2

                CS              M22
                EXTEND
                MP              BIT14                   # SCALE FOR DIVISION
                EXTEND
                DV              COSMG                   # -SIN(OG)/COS(MG)
                TCF             MR13STOR

GPGLOCK         CCS             M32                     # SINCE DIVISION BY COS(MG) MIGHT CREATE
                CAF             POSMAX
                TCF                             +2      # OVERFLOW (I.E. A NUMBER GREATER THAN 2)
                CAF             NEGMAX
                TS              MR12                    # USE THE VALUE SGN(NUMERATOR)*POSMAX AS

                CCS             M22
                CAF             POSMAX                  # THE CLOSEST APPROXIMATION
                TCF                             +2
                CAF             NEGMAX
MR13STOR        TS              MR13                    # SCALED AT 2
## Page 183
# THE FOLLOWING SECTION TESTS THE ATTITUDE HOLD BIT TO DETERMINE WHICH DEA
## Page 184
# PROGRAM NAME: DB SELECT         MOD. NO. 1  DATE: OCTOBER 24, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS PROGRAM SETS THE ERASABLE REGISTER DB TO ONE OF THE THREE VALUES:
#          1) O.3 DEGREES IF IN ATTITUDE HOLD MODE OR IF IN AUTO WITH THE DEADBAND SELECT BIT OF DAPBOOLS SET
#             TO MINIMUM.
#          2) 5.0 DEGREES IF IN AUTO WITH DEADBAND SELECT BIT SET TO MAXIMUM.
#          3) 1.0 DEGREES IF IN POWERED FLIGHT (ASCENT OR DESCENT) AND OVERRIDING ANY SETTITING OF SCSMODE OR THE
#             DEADBAND SELECT BIT.  (*** SEE COMMENT AFTER CODING. ***)

# ***** NOTICE *****

# THE ABOVE CAPABILITY FULFILLS ALL THE KNOWN DEADBAND REQUIREMENTS FOR AS206, AS208B, AND AS278 (GIVEN THE
# APPROPRIATE MISSION PROGRAMS).

# (ALSO FOR MANNED FLIGHTS A DSKY ENTRY MUST BE SET UP TO SET THE DEADBAND SELECT BIT OF DAPBOOLS. - NOT DONE AS
# OF 10/24/66.)

# ***** DEADBAND SELECT BIT IS BIT13 OF DAPBOOLS. *****
#          0: MEANS MINIMUM DEADBAND
#          1: MEANS MAXIMUM DEADBAND

# CALLING SEQUENCE: CONTROL FALLS THROUGH FROM GPMATRIX. (4 TIMES/SECOND)

# SUBROUTINES CALLED: NONE.

# NORMAL EXIT MODE: CONTROL IS ALWAYS TRANSFERRED TO UP/DOWN.

# ALARM/ABORT MODE: NONE.

# INPUT: BIT13/CHNL11,BIT13/CHNL31,BIT13/DAPBOOLS.  (SPOOKY, ISN'T IT?)

# OUTPUT: DB (SCALED AT PI RADIANS).     (NO DEBRIS EXCEPT A)

DBSELECT        CAF             BIT13                   # ATTITUDE HOLD BIT OF CHANNEL 31
                EXTEND                                  # 0 MEANS ATTITUDE HOLD
                RAND            31                      # 1 MEANS EITHER OFF OR AUTO
                EXTEND
                BZF             ATTHLDDB                # (ATTITUDE HOLD BRANCH)

                CS              DAPBOOLS                # DEADBAND SELECT BIT OF DAPBOOLS
                MASK            BIT13                   # 0 MEANS MINIMUM DEADBAND
                CCS             A                       # 1 MEANS MAXIMUM DEADBAND
                TCF             ATTHLDDB                # (MINIMUM DEADBAND BRANCH)

                CAF             DBMAXUM                 # SET MAXIMUM DEADBAND
                TCF                             +2

ATTHLDDB        CAF             DBATTHLD                # SET MINUMUM (ATTITUDE HOLD) DEADBAND
## Page 185
                TS              DB

# ***** IMPORTANT NOTICE *****

# FOR EFFICIENCY, THE OVERRIDING 1 DEGREE DEADBAND DURING POWERED FLIGHT IS NOT TESTED FOR ABOVE. THE PROGRAM
# FOLLOWING (I.E. UP/DOWN) PERFORMS THIS FUNCTION AFTER THE APPROPRIATE TESTS. THEREFORE, DB MAY TRANSIENTLY BEP
# INVALID, BUT THE DAP CANNOT USE IT THEN DUE TO T4RUPT MODE.
## Page 186
# PROGRAM NAME: UP/DOWN           MOD. NO. 1  DATE: OCTOBER 25, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS PROGRAM MONITORS THE STAGE OF THE LEM AND THE ENGINE ON BIT IN ORDER TO DETERMINE WHEN ASCENT, DESCENT, AND
# COAST PHASES MUST BE SET UP FOR THE DAP. (DONE 4 TIMES A SECOND.)

# CALLING SEQUENCE: NONE.         SUBROUTINES CALLED: WAITLIST.

# NORMAL EXIT MODE: CONTROL IS ALWAYS TRANSFERRED TO ENDDAPT4.

# ALARM/ABORT MODE: NONE.

# INPUT:BIT2/CHNL30,BIT13/CHNL11,BIT8/DAPBOOLS.

# OUTPUT:  A) ASCENT COAST:
#                 1) BIT8/DAPBOOLS SET TO ZERO, MEANING COAST.
#                 2) MINIMPDB AND DBMINIMP SET TO 0.3 DEGREES.
#          B) ASCENT BURN:
#                 1) INITIALIZATION PASS:
#                        I) BIT8/DAPBOOLS SET FROM 0 TO 1, MEANING THAT THE AOSTASK HAS BEEN STARTED UP AND THAT
#                           INITIALIZATION HAS OCCURRED.
#                       II) MINIMPDB SET TO -DB.
#                      III) DBMINIMP SET TO ZERO.
#                       IV) SUMRATEQ AND SUMRATER ZEROED FOR FIRST TWO SECOND AOSTASK SAMPLE PERIOD.
#                        V) KCOEFCTR ZEROED TO RECORD INITIAL TIME.
#                       VI) OMEGAQ AND OMEGAR RECORDED IN OLDWFORQ AND OLDWFORR AS LAST OMEGA VECTOR FOR AOSTASK.
#                      VII) AOSTASK SET IN WAITLIST FOR TWO SECONDS.
#                     VIII) DB SET TO DBAUTO.
#                       IX) ****** CHECKOUT ONLY **** IXXTASK, IYYTASK, AND IZZTASK SET IN WAITLIST FOR TEN MS.
#                 2) NORMAL PASS VOID.
#          C) DESCENT COAST:
#                 1) BIT2/DAPBOOLS SET TO 1, MEANING THAT TRIM GIMBAL CONTROL OF DESCENT IS IMPOSSIBLE SINCE
#                    DESCENT ENGINE OFF.
#                 2) AOSQTERM AND AOSRTERM ZEROED.
#          D) DESCENT BURN:
#                 1) DB SET TO DBAUTO.
#                 2) BIT2/DAPBOOLS CANNOT NOW BE ZEROED (EVEN THOUGH THE DESCENT ENGINE IS ON), SINCE IT IS NOT
#                    NECESSARILY TRUE THAT THIS IMPLIES AN OPERATIVE TRIM GIMBAL SYSTEM.

UP/DOWN         CAF             BIT2                    # STAGE VERIFY BIT OF CHANNEL 30: INVERTED
                EXTEND                                  # 0 MEANS ASCENT STAGE
                RAND            30                      # 1 MEANS DESCENT STAGE
                CCS             A
                TCF             DESCLEM                 # (DESCENT STAGE BRANCH)

ASCLEM          CAF             BIT13                   # ENGINE ON BIT OF CHANNEL 11
                EXTEND                                  # 0 MEANS OFF
                RAND            11                      # 1 MEANS ON
                CCS             A
## Page 187
                TCF             ASCDAP                  # (ASCENT BURN BRANCH)

ASCCOAST        CS              BIT8                    # SET BIT8 OF DAPBOOLS TO COAST DAP LOGIC
                MASK            DAPBOOLS                # LEM IS STAGED FOR ASCENT, BUT THE ASCENT
                TS              DAPBOOLS                # ENGINE IS NOT ON.

                CAF             DBATTHLD                # FOR ASCENT COAST SET BOTH MINIMUM PULSE
                TS              MINIMPDB                # DEADBANDS TO THE DESCENT PHASE VALUE OF
                TS              DBMINIMP                # 0.3 DEGREES SCALED AT PI RADIANS.

                TCF             ENDDAPT4                # (END OF UP/DOWN)

ASCDAP          CAF             BIT8                    # CHECK AOSTASK BIT OF DAPBOOLS
                MASK            DAPBOOLS                # IF 0, SET BIT AND INITIATE WAITLIST TASK
                CCS             A                       # IF 1, THEN TASK LOOP ALREADY BEGUN
                TCF             ENDDAPT4                # (END OF UP/DOWN)

                CAF             DBAUTO                  # SINCE ASCENT ENGINE IS ON -
                TS              DB                      # SET DEADBAND TO 1.0 DEGREES

                CAF             BIT8                    # SET BIT TO INDICATE AOSTASK SET UP AND
                ADS             DAPBOOLS                # ASCENT LOGIC.  BIT CLEARLY NOT SET YET.

                CS              DB                      # MODIFY THE TJETLAW FOR ASCENT:
                TS              MINIMPDB                # (IN ONE EQUATION DELETE MINIMPDB AND
                CAF             ZERO                    # SHIFT THE SWITCHING CURVE TO THE ORIGIN)
                TS              DBMINIMP                # MINIMPDB = -DB, DBMINIMP = 0

                CAF             ZERO                    # INITIALIZE SUM RATES
                TS              SUMRATEQ
                TS              SUMRATER
                TS              KCOEFCTR                # INITIALIZE TIME COUNTER
                CAE             OMEGAQ                  # CREATE OLD OMEGAQ
                TS              OLDWFORQ
                CAE             OMEGAR                  # CREATE OLD OMEGAR
                TS              OLDWFORR

# ***** EVENTUALLY, USE 2SECWLT4 FROMM FIXED-FIXED AND NEW NAME. *****

                CAF             2SECWLT4                # SET UP AOSTASK TO BEGIN IN 2 SECONDS
                TC              WAITLIST                # IT THEN SETS UP A LOOP ON WAITLIST FOR
                2CADR           AOSTASK                 # 2 SECOND INTERVALS AND CHECKS FOR THE
                                                        # SHUTDOWN CONDITION IN BIT8 OF DAPBOOLS

# ****************************************************************************************************************

# REMOVE THIS AND THE TASKS WHEN THE INERTIA ESTIMATOR WORKS.

                CAF             ONE                     # *** SPECIAL DAP CHECKOUT SEQUENCE ***
                TC              WAITLIST                # THESE THREE CALLS TO WAITLIST BEGIN A
## Page 188
                2CADR           IXXTASK                 # COMPLICATED PROCEDURE TO DECREMENT THE
                CAF             ONE                     # INERTIA MATRIX DIAGONAL ELEMENTS (EACH
                TC              WAITLIST                # SCALED AT 2(+18) SLUG FEET(2) ) BY ONE
                2CADR           IYYTASK                 # BIT AS SOON AS APPROPRIATE BY A NOMINAL
                CAF             ONE                     # LINEAR APPROXIMATION TO INERTIAL CHANGE.
                TC              WAITLIST
                2CADR           IZZTASK                 # *** NOT TO BE USED IN MISSIONS ***
# ****************************************************************************************************************

                TCF             ENDDAPT4                # (END OF UP/DOWN)

DESCLEM         CAF             BIT13                   # ENGINE ON BIT OF CHANNEL 11
                EXTEND                                  # 0 MEANS OFF
                RAND            11                      # 1 MEANS ON
                CCS             A
                TCF             DESCDAP                 # (DESCENT BURN BRANCH)

DESCOAST        CS              BIT2                    # SET BIT2 OF DAPBOOLS TO INDICATE THAT
                MASK            DAPBOOLS                # TRIM GIMBAL CANNOT BE USED SINCE THE
                AD              BIT2                    # STAGE IS DESCENT, BUT THE ENGINE IS NOT
                TS              DAPBOOLS                # ON.

                CAF             ZERO                    # ZERO TRIM GIMBAL OFFSET ACCELERATION
                TS              AOSQTERM                # TERMS IN THE DESCENT RATE DERIVATION
                TS              AOSRTERM                # SINCE THE THRUST IS ZERO (ENGINE OFF).

                TCF             ENDDAPT4                # (END OF UP/DOWN)

DESCDAP         CAF             DBAUTO                  # SINCE DESCENT ENGINE IS ON -
                TS              DB                      # SET DEADBAND TO 1.0 DEGREES

                TCF             ENDDAPT4                # (END OF UP/DOWN)

                TCF             ENDDAPT4


2SECWLT4        DEC             200                     # 2 SECONDS WAITLIST DT
DBMAXUM         DEC             0.02778                 # 5.0 DEGREES SCALED AT PI RADIANS
DBAUTO          DEC             0.00555                 # 1.0 DEGREES SCALED AT PI RADIANS
DBATTHLD        DEC             0.00167                 # 0.3 DEGREES SCALED AT PI RADIANS



NORRGMON        EQUALS          GPMATRIX
ENDDAPT4        EQUALS          RESUME
