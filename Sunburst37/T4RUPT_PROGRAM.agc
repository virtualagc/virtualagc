### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    T4RUPT_PROGRAM.agc
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
## Reference:   pp. 90-123
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-29 HG   Transcribed
##              2017-06-15 HG   Fix operator TCF  -> TC
##                                           CS   -> CAF
##		2017-06-21 RSB	Proofed using octopus/ProoferComments.

## Page 90
                BANK            12
                EBANK=          M11
T4RUPT          TS              BANKRUPT

                CA              ZERO
                EXTEND                                  # ZERO OUT0 EVERY T4RUPT.
                WRITE           OUT0

                INDEX           T4LOC                   # NORMALLY TO NORMT4, BUT TO LMPRESET OR
                TCF             0                       # DSKYRSET AFTER OUT0 COMMAND.

NORMT4          CCS             DSRUPTSW                # GOES 7(-1)0.
                TCF             +2
                CAF             SEVEN
                TS              DSRUPTSW

                TCF             T4RUPTA

LMPRESET        CAF             LNORMT4                 # DO THINGS IN THIS ORDER FOR RESTART
                TS              T4LOC                   # PROTECTION.
                CA              LMPOUTT                 # NEW VALUE OF OUTPUT POINTER.
                TS              LMPOUT
                CS              ONE                     # TO SHOW OUTPUT POINTER ALREADY UPDATED.
                TS              LMPOUTT
                CAF             90MRUPT
                TCF             +4

DSKYRSET        CAF             LNORMT4                 # 20 MS ON / 100 MS OFF.
                TS              T4LOC
                CAF             100MRUPT
 +4             TS              TIME4
                TCF             NOQRSM

                BLOCK           02
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

## Page 91
                OCT             50037
                OCT             54000
RELTAB11        OCT             60000

## Page 92
# SWITCHED-BANK PORTION.

                BANK            12
T4RUPTA         EXTEND
                QXCH            QRUPT

                INDEX           LMPOUT                  # SEE IF LMP COMMAND TO BE PUT OUT.
                CCS             LMPCMD
                TCF             CDRVE                   # BIT 15 = 1 AND (UP TO) BITS 1 - 11
                TCF             CDRVE                   # CONTAIN THE COMMAND.

                CAF             LLMPRS                  # SET T4 FOR SPECIAL RUPT AND SHOW LMP
                TS              T4LOC                   # COMMAND IN PROGRESS IF RESTART.

                CAF             LOW11
                INDEX           LMPOUT
                MASK            LMPCMD                  # LEAVE COMMAND PORTION INTACT.
                INDEX           LMPOUT
                TS              LMPCMD
                AD              74K

                EXTEND
                WRITE           OUT0

                CCS             LMPOUT                  # PREDICT NEW VALUE OF LMPOUT BUT DONT
                TCF             +2                      # UPDATE IT UNTIL COMMAND SENT (IN CASE OF
                CAF             SEVEN                   # RESTART.)
                TS              LMPOUTT

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

## Page 93
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

## Page 94
#          JUMP TO APPROPRIATE ONCE-PER SECOND (.96 SEC ACTUALLY) ACTIVITY

T4JUMP          INDEX           DSRUPTSW
                TCF             +1

                TC              ALTOUT

                TC              NORRGMON                # WAS TCF RRAUTCHK (NO RADAR IN 206).

                TCF             IMUMON
                TCF             DAPT4S
                TC              ALTROUT
                TC              NORRGMON                # WAS TCF RRAUTCHK (NO RADAR IN 206).
                TCF             IMUMON
                TCF             DAPT4S

LDSKYRS         ADRES           DSKYRSET
LLMPRS          ADRES           LMPRESET

30MRUPT         DEC             16381
20MRUPT         DEC             16382

## Page 95
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

## Page 96
ALTROUT         TC              DISINDAT
                CAF             BIT2

                EXTEND
                WOR             14                      # SET UP OUTPUT FOR ALT. RATE
                CA              ALTRATE
                TCF             METEROUT

DISINDAT        CCS             DIDFLG
                TCF             ALLDONE                 # NOTE THAT THIS SHOULD ALWAYS GO TO
                                                        # ALLDONE AND NOT DONEDID SINCE THE
                                                        # AVAILABILITY OF DATA MAY DISAPPEAR WHILE
                                                        # THE ASTRONAUT HAS THE BUTTON DOWN.
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
                EBANK=          M11
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

## Page 97
                TS              LASTYCMD
                TC              Q

ALLDONE         CS              DIDRESET                # REMOVE DISPLAY INERTIAL DATA AND ECTR.
                EXTEND
                WAND            12                      # RESET RR ERROR COUNTER
DONEDID         TCF             RESUME                  # ** FIX LATER**

ZERODATA        CAF             ZERO
                TS              L
                TCF             ZDATA2

ARTOA           DEC             .20469                  # ALT DUE TO ALTRATE FOR .96 SEC.
BITSET          OCT             6004

DIDRESET        OCT             202

## Page 98
# PROGRAM NAME:  IMUMON

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM IS ENTERED EVERY 480 MS.  IT DETECTS CHANGES OF THE IMU STATUS BITS IN
# CHANNEL 30 AND CALLS THE APPROPRIATE SUBROUTINES.  THE BITS PROCESSED AND THEIR RELEVANT SUBROUTINES ARE:

#          FUNCTION               BIT    SUBROUTINE CALLED
#          --------               ---    -----------------
#          TEMP IN LIMITS          15    TLIM
#          ISS TURN-ON REQUEST     14    ITURNON
#          IMU FAIL                13    IMUFAIL (SETISSW)
#          IMU CDU FAIL            12    ICDUFAIL (SETISSW)
#          IMU CAGE                11    IMUCAGE
#          IMU OPERATE              9    IMUOP

#          THE LAST SAMPLED STATE OF THESE BITS IS LEFT IN IMODES30.  ALSO, EACH SUBROUTINE CALLED FINDS THE NEW
# VALUE OF THE BIT IN A, WITH Q SET TO THE PROPER RETURN LOCATION, NXTIFAIL.

# CALLING SEQUENCE:  T4RUPT EVERY 480 MILLISECONDS.

# JOBS OR TASKS INITIATED:  NONE.

# SUBROUTINES CALLED:  TLIM, ITURNON, SETISSW, IMUCAGE, IMUOP.

# ERASABLE INITIALIZATION:
#          FRESH START OR RESTART WITH NO GROUPS ACTIVE: C(IMODES30) = OCT 37411.
#          RESTART WITH ACTIVE GROUPS: C(IMODES30) = (B(IMODES30)AND(OCT 00035)) PLUS OCT 37400.
#                                      THIS LEAVES IMU FAIL BITS INTACT.

# ALARMS:  NONE.

# EXIT:  TNONTEST.

# OUTPUT:  UPDATED IMODES30 WITH CHANGES PROCESSED BY APPROPRIATE SUBROUTINE.

IMUMON          CAF             BITS4&5                 # DISABLE DAP IF ZERO ICDU OR COARSE ALIGN
                EXTEND
                RAND            12
                EXTEND

                BZMF            IMUNON1
                EXTEND
                DCA             T4DAP
                DXCH            T5ADR

IMUNON1         CA              IMODES30                # SEE IF THERE HAS BEEN A CHANGE IN THE
                EXTEND                                  # RELEVANT BITS OF CHAN 30.
                RXOR            30
                MASK            30RDMSK
                EXTEND
                BZF             TNONTEST                # NO CHANGE IN STATUS.

## Page 99
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

## Page 100
# PROGRAM NAME:  TNONTEST.

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM HONORS REQUESTS FOR ISS INITIALIZATION.  ISS TURN-ON (CHANNEL 30 BIT 14)
# AND ISS OPERATE (CHANNEL 30 BIT 9) REQUESTS ARE TREATED AS A PAIR AND PROCESSING TAKES PLACE .480 SECONDS
# AFTER EITHER ONE APPEARS.  THIS INITIALIZATION TAKES ON ONE OF THE FOLLOWING THREE FORMS:

#          1)  ISS TURN-ON:  IN THIS SITUATION THE COMPUTER IS OPERATING WHEN THE ISS IS TURNED ON.  NOMINALLY,
#          BOTH ISS TURN-ON AND ISS OPERATE APPEAR.  THE PLATFORM IS CAGED FOR 90 SECONDS AND THE ICDU'S ZEROED
#          SO THAT AT THE END OF THE PROCESS THE GIMBAL LOCK MONITOR WILL FUNCTION PROPERLY.

#          2)  ICDU INITIALIZATION:  IN THIS CASE THE COMPUTER WAS PROBABLY TURNED ON WITH THE ISS IN OPERATE OR
#          A FRESH START WAS DONE WITH THE ISS IN OPERATE.  IN THIS CASE ONLY ISS OPERATE IS ON.  THE ICDU'S ARE
#          ZEROED SO THE GIMBAL LOCK MONITOR WILL FUNCTION.  AN EXCEPTION IS IF THE ISS IS IN GIMBAL LOCK AFTER
#          A RESTART, THE ICDU'S WILL NOT BE ZEROED.

#          3)  RESTART WITH RESTARTABLE PROGRAM USING THE IMU:  IN THIS CASE, NO INITIALIZATION TAKES PLACE SINCE
#          IT IS ASSUMED THAT THE USING PROGRAM DID THE INITIALIZATION AND THEREFORE T4RUPT SHOULD NOT INTERFERE.

# IMODES30 BIT 7 IS SET = 1 BY THE FIRST BIT (CHANNEL 30 BIT 14 OR 9) WHICH ARRIVES.  FOLLOWING THIS. TNONTEST IS
# ENTERED, FINDS BIT 7 = 1 BUT BIT 8 = 0, SO IT SETS BIT 8 = 1 AND EXITS.  THE NEXT TIME IT FINDS BIT 8 = 1 AND
# PROCEEDS, SETTING BITS 8 AND 7 = 0.  AT PROCTNON, IF ISS TURN-ON REQUEST IS PRESENT, THE ISS IS CAGED (ZERO +
# COARSE).  IF ISS OPERATE IS NOT PRESENT PROGRAM ALARM 00213 IS ISSUED.  AT THE END OF A 90 SECOND CAGE, BIT 2
# OF IMODES30 IS TESTED.  IF IT IS = 1, ISS TURN-ON WAS NOT PRESENT FOR THE ENTIRE 90 SECONDS.  IN THAT CASE, IF
# THE ISS TURN-ON REQUEST IS PRESENT THE 90 SECOND WAIT IS REPEATED, OTHERWISE NO ACTION OCCURS UNLESS A PROGRAM
# WAS WAITING FOR THE INITIALIZATION IN WHICH CASE THE PROGRAM IS GIVEN AN IMUSTALL ERROR RETURN.  IF THE DELAY
# WENT PROPERLY, THE ISS DELAY OUTBIT IS SENT AND THE ICDU'S ZEROED.  A TASK IS INITIATED TO REMOVE THE PIPA FAIL

# INHIBIT BIT IN 10.24 SECONDS.  IF A MISSION PROGRAM WAS WAITING IT IS INFORMED VIA ENDIMU.

# AT PROCTNON, IF ONLY ISS OPERATE IS PRESENT (OPONLY), THE CDU'S ARE ZEROED UNLESS THE PLATFORM IS IN COARSE
# ALIGN (= GIMBAL LOCK HERE) OR A MISSION PROGRAM IS USING THE IMU (IMUSEFLG = 1).

# CALLING SEQUENCE:  T4RUPT EVERY 480 MILLISECONDS AFTER IMUMON.

# JOBS OR TASKS INITIATED:  1) ENDTNON, 90 SECONDS AFTER CAGING STARTED.  2) ISSUP, 4 SECONDS AFTER CAGING DONE.
#          3) PFAILOK, 10.24 SECONDS AFTER INITIALIZATION COMPLETED.  4) UNZ2, 320 MILLISECONDS AFTER ZEROING
#          STARTED.

# SUBROUTINES CALLED:  CAGESUB, CAGESUB2, ZEROICDU, ENDIMU, IMUBAD, NOATTOFF, SETISSW, VARDELAY.

# ERASABLE INITIALIZATION:  SEE IMUMON.

# ALARMS:  PROGRAM ALARM 00213 IF ISS TURN-ON REQUESTED WITHOUT ISS OPERATE.

# EXIT:  ENDTNON EXITS TO C33TEST.  TASKS HAVING TO DO WITH INITIALIZATION EXIT AS FOLLOWS:  MISSION PROGRAM
# WAITING AND INITIALIZATION COMPLETE, EXIT TO ENDIMU, MISSION PROGRAM WAITING AND INITIALIZATION FAILED, EXIT TO
# IMUBAD, IMU NOT IN USE, EXIT TO TASKOVER.

# OUTPUT:  ISS INITIALIZED.

TNONTEST        CS              IMODES30                # AFTER PROCESSING ALL CHANGES, SEE IF IT

## Page 101
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

#          PROCESS IMU TURN-ON REQUESTS AFTER WAITING 1 SAMPLE FOR ALL SIGNALS TO ARRIVE.

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
                EBANK=          M11
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

## Page 102
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
                WOR             CHAN12

                TC              IBNKCALL                # TURN OFF NO ATT LAMP.
                CADR            NOATTOFF

UNZ2            TC              ZEROICDU

                CS              BITS4&5                 # REMOVE ZERO AND COARSE.
                EXTEND
                WAND            CHAN12

                CAF             4SECS                   # WAIT 4 SECS FOR COUNTERS TO FIND GIMBALS
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

                EBANK=          M11
                2CADR           PFAILOK

                CS              STATE                   # SEE IF ANYONE IS WAITING FOR THE IMU AT
                MASK            IMUSEFLG                # IMUZERO. IF SO, WAKE THEM UP.
                CCS             A
                TCF             TASKOVER

                TC              POSTJUMP
                CADR            ENDIMU

OPONLY          CAF             BIT4                    # IF OPERATE ON ONLY, AND WE ARE IN COARSE

## Page 103
                EXTEND                                  # ALIGN, DONT ZERO THE CDUS BECAUSE WE
                RAND            CHAN12                  # MIGHT BE IN GIMBAL LOCK.
                CCS             A
                TCF             C33TEST

                CAF             IMUSEFLG                # OTHERWISE, ZERO THE COUNTERS
                MASK            STATE                   # UNLESS SOMEONE IS USING THE IMU.
                CCS             A
                TCF             C33TEST

                TC              CAGESUB2                # SET TURNON FLAGS.

                CAF             BIT5
                EXTEND
                WOR             12

                CAF             BIT6                    # WAIT 300 MS FOR AGS TO RECEIVE SIGNAL.
                TC              WAITLIST
                EBANK=          M11
                2CADR           UNZ2

                TCF             C33TEST

## Page 104
# PROGRAM NAME:  C33TEST

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM MONITORS THREE FLIP-FLOP INBITS OF CHANNEL 33 AND CALLS THE APPROPRIATE
# SUBROUTINE TO PROCESS A CHANGE.  IT IS ANALOGOUS TO IMUMON, WHICH MONITORS CHANNEL 30, EXCEPT THAT IT READS
# CHANNEL 33 WITH A WAND INSTRUCTION BECAUSE A 'WRITE' PULSE IS REQUIRED TO RESET THE FLIP-FLOPS.  THE BITS
# PROCESSED AND THE SUBROUTINES CALLED ARE:

#          BIT    FUNCTION                SUBROUTINE
#          ---    --------                ----------
#           13    PIPA FAIL               PIPFAIL
#           12    DOWNLINK TOO FAST       DNTMFAST
#           11    UPLINK TOO FAST         UPTMFAST

# UPON ENTRY TO THE SUBROUTINE, THE NEW BIT STATE IS IN A.

# CALLING SEQUENCE:  EVERY 480 MILLISECONDS AFTER TNONTEST.

# JOBS OR TASKS INITIATED:  NONE.

# SUBROUTINES CALLED:  PIPFAIL, DNTMFAST AND UPTMFAST ON BIT CHANGES.

# ERASABLE INITIALIZATION:  C(IMODES33) = OCT 16000 ON A FRESH START OR RESTART, THEREFORE, THESE ALARMS WILL
# REAPPEAR IF THE CONDITIONS PERSIST.

# ALARMS:  NONE.

# EXIT:  GLOCKMON.

# OUTPUT:  UPDATED BITS 13, 12 AND 11 OF IMODES33 WITH CHANGES PROCESSED.

C33TEST         CA              IMODES33                # SEE IF RELEVANT CHAN 33 BITS HAVE
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

## Page 105
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

## Page 106
# PROGRAM NAME:  GLOCKMON

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM MONITORS THE CDUZ COUNTER TO DETERMINE WHETHER THE ISS IS IN GIMBAL LOCK
# AND TAKES ACTION IF IT IS.  THREE REGIONS OF MIDDLE GIMBAL ANGLE (MGA) ARE USED:

#          1) ABS(MGA) LESS THAN OR EQUAL TO 70 DEGREES - NORMAL MODE.
#          2) ABS(MGA) GREATER THAN 70 DEGREES AND LESS THAN OR EQUAL TO 85 DEGREES - GIMBAL LOCK LAMP TURNED ON.
#          3) ABS(MGA) GREATER THAN 85 DEGREES - ISS PUT IN COARSE ALIGN AND NO ATT LAMP TURNED ON.

# CALLING SEQUENCE:  EVERY 480 MILLISECONDS AFTER C33TEST.

# JOBS OR TASKS INITIATED:  NONE.

# SUBROUTINES CALLED:  1) SETCOARS WHEN ABS(MGA) GREATER THAN 85 DEGREES AND ISS NOT IN COARSE ALIGN.
#                      2) LAMPTEST BEFORE TURNING OFF GIMBAL LOCK LAMP.

# ERASABLE INITIALIZATION:
#          1) FRESH START OR RESTART WITH NO GROUPS ACTIVE:  C(CDUZ) = 0, IMODES30 BIT 6 = 0, IMODES33 BIT 1 =  0.
#          2) RESTART WITH GROUPS ACTIVE:  SAME AS FRESH START EXCEPT C(CDUZ) NOT CHANGED SO GIMBAL MONITOR
#                                          PROCEEDS AS BEFORE.

# ALARMS:  1) MGA REGION (2) CAUSES GIMBAL LOCK LAMP TO BE LIT.
#          2) MGA REGION (3) CAUSES THE ISS TO BE PUT IN COARSE ALIGN AND THE NO ATT LAMP TO BE LIT IF EITHER NOT
#             SO ALREADY.

GLOCKMON        CCS             CDUZ
                TCF             GLOCKCHK                # SEE IF MAGNITUDE OF MGA IS GREATER THAN
                TCF             SETGLOCK                # 70 DEGREES.
                TCF             GLOCKCHK
                TCF             SETGLOCK

GLOCKCHK        AD              -70DEGS
                EXTEND
                BZMF            SETGLOCK        -1      # NO LOCK.

                AD              -15DEGS                 # SEE IF ABS(MGA) GREATER THAN 85 DEGREES.
                EXTEND
                BZMF            NOGIMRUN

                CAF             BIT4                    # IF SO, SYSTEM SHOULD BE IN COARSE ALIGN
                EXTEND                                  # TO PREVENT GIMBAL RUNAWAY.
                RAND            12
                CCS             A
                TCF             NOGIMRUN

                TC              IBNKCALL
                CADR            SETCOARS

NOGIMRUN        CAF             BIT6                    # TURN ON GIMBAL LOCK LAMP.
                TCF             SETGLOCK

## Page 107
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
-15DEGS         DEC             -.08333
OCT37737        OCT             37737

## Page 108
# PROGRAM NAME:  TLIM.

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM MAINTAINS THE TEMP LAMP (BIT 4 OF CHANNEL 11) ON THE DSKY TO AGREE WITH
# THE TEMP SIGNAL FROM THE ISS (BIT 15 OF CHANNEL 30).  HOWEVER, THE LIGHT WILL NOT BE TURNED OFF IF A LAMP TEST
# IS IN PROGRESS.

# CALLING SEQUENCE:  CALLED BY IMUMON ON A CHANGE OF BIT 15 OF CHANNEL 30.

# JOBS OR TASKS INITIATED:  NONE.

# SUBROUTINES CALLED:  LAMPTEST.

# ERASABLE INITIALIZATION:  FRESH START AND RESTART TURN THE TEMP LAMP OFF.

# ALARMS:  TEMP LAMP TURNED ON WHEN IMU TEMP GOES OUT OF LIMITS.

# EXIT:  NXTIFAIL.

# OUTPUT:  SERVICE OF TEMP LAMP.                                          IN A, EXCEPT FOR TLIM.

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

## Page 109
# PROGRAM NAME:  ITURNON.

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM IS CALLED BY IMUMON WHEN A CHANGE OF BIT 14 OF CHANNEL 30 (ISS TURN-ON
# REQUEST) IS DETECTED.  UPON ENTRY, ITURNON CHECKS IF A TURN-ON DELAY SEQUENCE HAS FAILED, AND IF SO, IT EXITS.
# IF NOT, IT CHECKS WHETHER THE TURN-ON REQUEST CHANGE IS TO ON OR OFF.  IF ON, IT SETS BIT7 OF IMODES30 TO 1 SO
# THAT TNONTEST WILL INITIATE THE ISS INITIALIZATION SEQUENCE.  IF OFF, THE TURN-ON DELAY SIGNAL, CHANNEL 12 BIT
# 15, IS CHECKED AND IF IT IS ON, ITURNON EXITS.  IF THE DELAY SIGNAL IS OFF, PROGRAM ALARM 00207 IS ISSUED, BIT 2
# OF IMODES30 IS SET TO 1 AND THE PROGRAM EXITS.

#          THE SETTING OF BIT 2 OF IMODES30 (ISS DELAY SEQUENCE FAIL) INHIBITS THIS ROUTINE AND IMUOP FROM
# PROCESSING ANY CHANGES.  THIS BIT WILL BE RESET BY THE ENDTNON ROUTINE WHEN THE CURRENT 90 SECOND DELAY PERIOD
# ENDS.

# CALLING SEQUENCE:  FROM IMUMOM WHEN ISS TURN-ON REQUEST CHANGES STATE.

# JOBS OR TASKS INITIATED:  NONE.

# SUBROUTINES CALLED:  ALARM, IF THE ISS TURN-ON REQUEST IS NOT PRESENT FOR 90 SECONDS.

# ERASABLE INITIALIZATION:  FRESH START AND RESTART SET BIT 15 OF CHANNEL 12 AND BITS 2 AND 7 OF IMODES30 TO 0,
# AND BIT 14 OF IMODES30 TO 1.

# ALARMS: PROGRAM ALARM 00207 IS ISSUED IF THE ISS TURN-ON REQUEST SIGNAL IS NOT PRESENT FOR 90 SECONDS.

# EXIT:  NXTIFAIL.

# OUTPUT:  BIT 7 OF IMODES30 TO START ISS INITIALIZATION, OR BIT 2 OF IMODES30 AND PROGRAM ALARM 00207 TO INDICATE
# A FAILED TURN-ON SEQUENCE.

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
                RAND            12                      # SENT.  IF SO, ACTION COMPLETE.
                EXTEND
                BZF             +2
                TCF             NXTIFAIL

                CAF             BIT2                    # IF NOT, SET BIT TO INDICATE REQUEST NOT
                ADS             IMODES30                # PRESENT FOR FULL DURATION.
                TC              ALARM
                OCT             207
                TCF             NXTIFAIL

## Page 110
ITURNON2        CS              BIT7                    # SET BIT 7 TO INITIATE WAIT OF 1 SAMPLE.
                MASK            IMODES30
                AD              BIT7
                TS              IMODES30
                TCF             NXTIFAIL

## Page 111
# PROGRAM NAME:  IMUCAGE.

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM PROCESSES CHANGES OF THE IMUCAGE INBIT, CHANNEL 30 BIT 11.  IF THE BIT
# CHANGES TO 0 (CAGE BUTTON PRESSED), THE ISS IS CAGED (ICDU ZERO + COARSE ALIGN + NO ATT LAMP) UNTIL THE
# ASTRONAUT SELECTS ANOTHER PROGRAM TO ALIGN THE ISS.  ANY PULSE TRAINS TO THE ICDU'S AND GYRO'S ARE TERMINATED,
# THE ASSOCIATED OUTCOUNTERS ARE ZEROED AND THE GYRO'S ARE DE-SELECTED.  NO ACTION OCCURS WHEN THE BUTTON IS
# RELEASED (INBIT CHANGES TO 1).

# CALLING SEQUENCE:  BY IMUMON WHEN IMU CAGE BIT CHANGES.

# JOBS OR TASKS INITIATED:  NONE.

# SUBROUTINES CALLED:  CAGESUB.

# ERASABLE INITIALIZATION:  FRESH START AND RESTART SET BIT 11 OF IMODES30 TO 1.

# ALARMS: NONE.

# EXIT:  NXTIFAIL.

# OUTPUT:  ISS CAGED, COUNTERS ZEROED, PULSE TRAINS TERMINATED AND NO ATT LAMP LIT.

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

## Page 112
# PROGRAM NAME:  IMUOP.

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM PROCESSES CHANGES IN THE ISS OPERATE DISCRETE, BIT 9 OF CHANNEL 30.
# IF THE INBIT CHANGES TO 0, INDICATING ISS ON, IMUOP GENERALLY SETS BIT 7 OF IMODES30 TO 1 TO REQUEST ISS
# INITIALIZATION VIA TNONTEST.  AN EXCEPTION IS DURING A FAILED ISS DELAY DURING WHICH BIT 2 OF IMODES30 IS SET
# TO 1 AND NO FURTHER INITIALIZATION IS REQUIRED.  WHEN THE INBIT CHANGES TO 1, INDICATING ISS OFF, IMUSEFLG IS
# TESTED TO SEE IF ANY PROGRAM WAS USING THE ISS.  IF SO, PROGRAM ALARM 00214 IS ISSUED.

# CALLING SEQUENCE:  BY IMUMON WHEN BIT 9 OF CHANNEL 30 CHANGES.

# JOBS OR TASKS INITIATED:  NONE.

# SUBROUTINES CALLED:  ALARM, IF ISS IS TURNED OFF WHILE IN USE.

# ERASABLE INITIALIZATION:  ON FRESH START AND RESTART, BIT 9 OF IMODES30 IS SET TO 1 EXCEPT WHEN THE GIMBAL LOCK
# LAMP IS ON, IN WHICH CASE IT IS SET TO 0.  THIS PREVENTS ICDU ZERO BY TNONTEST WITH THE ISS IN GIMBAL LOCK.

# ALARMS:  PROGRAM ALARM 00214 IF THE ISS IS TURNED OFF WHILE IN USE.

# EXIT:  NXTIFAIL.

# OUTPUT:  ISS INITIALIZATION REQUEST (IMODES30 BIT 7) OR PROGRAM ALARM 00214.

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

## Page 113
# PROGRAM NAME:  PIPFAIL

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM PROCESSES CHANGES OF BIT 13 OF CHANNEL 33, PIPA FAIL.  IT SETS BIT 10 OF
# IMODES30 TO AGREE.  IT CALLS SETISSW IN CASE A PIPA FAIL NECESSITATES AN ISS WARNING.  IF NOT,I.E., IMODES30
# BIT 1 = 1, AND A PIPA FAIL IS PRESENT AND THE ISS IS NOT BEING INITIALIZED, PROGRAM ALARM 00212 IS ISSUED.

# CALLING SEQUENCE:  BY C33TEST ON CHANGES OF CHANNEL 33 BIT 13.

# JOBS OR TASKS INITIATED:  NONE.

# SUBROUTINES CALLED:  1) SETISSW, AND 2) ALARM (SEE FUNCTIONAL DESCRIPTION).

# ERASABLE INITIALIZATION:  SEE IMUMON FOR INITIALIZATION OF IMODES30.  THE RELAVANT BITS ARE 5, 7, 8, 9, AND 10.

# ALARMS:  PROGRAM ALARM 00212 IF PIPA FAIL IS PRESENT BUT NEITHER ISS WARNING IS TO BE ISSUED NOR THE ISS IS
# BEING INITIALIZED.

# EXIT:  NXTFL33.

# OUTPUT:  PROGRAM ALARM 00212 AND ISS WARNING MAINTENANCE.

PIPFAIL         CCS             A                       # SET BIT10 IN IMODES30 SO ALL ISS WARNING
                CAF             BIT10                   # INFO IS IN ONE REGISTER.
                XCH             IMODES30
                MASK            -BIT10
                ADS             IMODES30

                TC              SETISSW

                CS              IMODES30                # IF PIP FAIL DOESNT LIGHT ISS WARNING, DO
                MASK            BIT1                    # A PROGRAM ALARM IF IMU OPERATING BUT NOT
                CCS             A                       # CAGED OR BEING TURNED ON.

                TCF             NXTFL33

                CA              IMODES30
                MASK            OCT1720
                CCS             A
                TCF             NXTFL33                 # ABOVE CONDITION NOT MET.

                TC              ALARM
                OCT             212
                TCF             NXTFL33

## Page 114
# PROGRAM NAMES:  DNTMFAST, UPTMFAST

# FUNCTIONAL DESCRIPTION:  THESE PROGRAMS PROCESS CHANGES OF BITS 12 AND 11 OF CHANNEL 33.  IF A BIT CHANGES TO A
# 0, A PROGRAM ALARM IS ISSUED.  THE ALARMS ARE:

#          BIT    ALARM           CAUSE
#          ---    -----           -----
#           12    01105           DOWNLINK TOO FAST
#           11    01106           UPLINK TOO FAST

# CALLING SEQUENCE:  BY C33TEST ON A BIT CHANGE.

# SUBROUTINES CALLED:  ALARM, IF A BIT CHANGES TO A 0.

# ERASABLE INITIALIZATION:  FRESH START OR RESTART, BITS 12 AND 11 OF IMODES33 ARE SET TO 1.

# ALARMS:  SET FUNCTIONAL DESCRIPTION.

# EXIT:  NXTFL33.

# OUTPUT:  PROGRAM ALARM ON A BIT CHANGE TO 0.

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

## Page 115
# PROGRAM NAME:  SETISSW

# FUNCTIONAL DESCRIPTION:  THIS PROGRAM TURNS THE ISS WARNING LAMP ON AND OFF (CHANNEL 11 BIT 1 = 1 FOR ON,
# 0 FOR OFF) DEPENDING ON THE STATUS OF IMODES30 BITS 13 (IMU FAIL) AND 4 (INHIBIT IMU FAIL), 12 (ICDU FAIL) AND
# 3 (INHIBIT ICDU FAIL), AND 10 (PIPA FAIL) AND 1 (INHIBIT PIPA FAIL).  THE LAMP IS LEFT ON IF A LAMP TEST IS IN
# PROGRESS.

# CALLING SEQUENCE:  CALLED BY IMUMON ON CHANGES TO IMU FAIL AND ICDU FAIL.  CALLED BY IFAILOK AND PFAILOK UPON
# REMOVAL OF THE FAIL INHIBITS.  CALLED BY PIPFAIL WHEN THE PIPA FAIL DISCRETE CHANGES.  IT IS CALLED BY PIPUSE
# SINCE THE PIPA FAIL PROGRAM ALARM MAY NECESSITATE AN ISS WARNING, AND LIKEWISE BY PIPFREE WHEN THE ALARM DEPARTS
# AND IT IS CALLED BY IMUZERO3 AND ISSUP AFTER THE FAIL INHIBITS HAVE BEEN REMOVED.

# JOBS OR TASKS INITIATED:  NONE.

# SUBROUTINES CALLED:  NONE.

# ERASABLE INITIALIZATION:

#          1) IMODES30 - SEE IMUMON.
#          2) IMODES33 BIT 1 = 0 (LAMP TEST NOT IN PROGRESS).

# ALARMS:  ISS WARNING.

# EXIT: VIA Q.

# OUTPUT: ISS WARNING LAMP SET PROPERLY.

SETISSW         CAF             OCT15                   # SET ISS WARNING USING THE FAIL BITS IN
                MASK            IMODES30                # BITS 13, 12, AND 10 OF IMODES30 AND THE
                EXTEND                                  # FAILURE INHIBIT BITS IN POSITIONS
                MP              BIT10                   # 4, 3, AND 1.
                CA              IMODES30
                EXTEND
                ROR             L                       # 0 INDICATES FAILURE.
                COM
                MASK            OCT15000
                CCS             A
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

## Page 116
                EXTEND
                WOR             11

                TC              Q

CAGESUB         CS              BITS6&15                # SET OUTBITS AND INTERNAL FLAGS FOR
                EXTEND                                  # SYSTEM TURN-ON OR CAGE.  DISABLE THE
                WAND            12                      # ERROR COUNTER AND REMOVE IMU DELAY COMP.
                CAF             BITS4&5                 # SEND ZERO AND COARSE.
                EXTEND
                WOR             12

                CS              OC40010                 # TURN ON NO ATT LAMP.
                MASK            DSPTAB          +11D
                AD              OC40010
                TS              DSPTAB          +11D

CAGESUB2        CS              OCT75                   # SET FLAGS TO INDICATE CAGING OR TURN-ON,
                MASK            IMODES30                # AND TO INHIBIT ALL ISS WARNING INFO.
                AD              OCT75
                TS              IMODES30

                EXTEND
                DCA             T4DAP                   # DISABLE DAP DURING ISS INITIALIZATION
                DXCH            T5ADR

                TC              Q

                EBANK=          DT
T4DAP           2CADR           DAPIDLER
IMUFAIL         EQUALS          SETISSW
ICDUFAIL        EQUALS          SETISSW

## Page 117
#          JUMP TABLES AND CONSTANTS.

IFAILJMP        TCF             ITURNON                 # CHANNEL 30 DISPATCH.
                TCF             IMUFAIL
                TCF             ICDUFAIL
                TCF             IMUCAGE
30RDMSK         OCT             76400                   # (BIT 10 NOT SAMPLED HERE).
                TCF             IMUOP

C33JMP          TCF             PIPFAIL                 # CHANNEL 33 DISPATCH.
                TCF             DNTMFAST
                TCF             UPTMFAST

#          SUBROUTINE TO SKIP IF LAMP TEST NOT IN PROGRESS.
LAMPTEST        CS              IMODES33                # BIT 1 OF IMODES33 = 1 IF LAMP TEST IN
                MASK            BIT1                    # PROGRESS.
                CCS             A
                INCR            Q
                TC              Q

33RDMSK         EQUALS          PRIO16
OCT15           OCT             15
OC40010         OCT             40010
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
NOIMUON         EQUALS          GLOCKOK

## Page 118
#          RR INBIT MONITOR.

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
                EBANK=          M11
                2CADR           RRTURNON
                TCF             NORRGMON

OCT10001        OCT             10001

RROFF           CS              STATE                   # IF SOMEONE WAS USING THE RR, DISPLAY AN

                MASK            BIT7                    # ALARM IF THE RR GOES OUT OF AUTO MODE.
                CCS             A
                TCF             RRCDUCHK

                TC              ALARM
                OCT             514

## Page 119
#          CHECK FOR RR CDU FAIL.

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

## Page 120
#          THE RR GIMBAL LIMIT MONITOR IS ENABLED WHENEVER THE RR IS IN THE AUTO MODE EXCEPT WHEN THE RR CDUS ARE
# BEING ZEROED, OR DURING A REMODE OR MONITOR REPOSITION OPERATION. THE LATTER IS INITIATED BY THIS MONITOR WHEN

# THE GIMBALS EXCEED THE LIMITS FOR THE CURRENT MODE. A ROUTINE IS INITIATED TO DRIVE THE GIMBALS TO T = 0 AND
# S = 0 IF IN MODE 1 AND T = 180 WITH S = -90 FOR MODE 2.

RRGIMON         CAF             OCT32002                # INHIBITED BY REMODE, ZEROING, MONITOR.
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
                EBANK=          M11
                2CADR           DORREPOS
                TCF             NORRGMON

OCT32002        OCT             32002
OCT20002        OCT             20002

## Page 121
# PROGRAM NAME:  GPMATRIX (DAPT4S) MOD. NO. 2 DATE: OCTOBER 27, 1966

# AUTHOR:  JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS PROGRAM CALCULATES ALL THE SINGLE-PRECISION MATRIX ELEMENTS WHICH ARE USED BY LEM DAP TO TRANSFORM VECTORS
# FROM GIMBAL TO PILOT (BODY) AXES AND BACK AGAIN.  THESE ELEMENTS ARE USED EXCLUSIVELY BY BASIC LANGUAGE ROUTINES
# AND THEREFORE ARE NOT ARRAYED FOR USE BY INTERPRETIVE PROGRAMS.

# CALLING SEQUENCE:  GPMATRIX IS TRANSFERRED TO FROM DAPT4S AND IS THUS EXECUTED 4 TIMES A SECOND BY T4RUPT.
# DAPT4S IS LISTED IN T4JUMP TABLE TWICE EXPLICITLY AND ALSO OCCURS AFTER RRAUTCHK (WHICH IS ALSO LISTED TWICE).

# SUBROUTINES CALLED: SPSIN, SPCOS.

# NORMAL EXIT: RESUME.

# ALARM/ABORT MODE:  THERE ARE NO REAL ALARMS OR ABORTS.  HOWEVER, WHEN THE MIDDLE GIMBAL ANGLE NEARS GIMBAL LOCK,
# A DIVISION BY COS(MG) WILL CAUSE OVERFLOW (I.E. A BAD QUOTIENT).  THIS CONDITION IS PREVENTED BY TESTING COS(MG)
# AND SUBSTITUTING POSMAX/NEGMAX FOR THE INCALCULABLE QUANTITIES.

# INPUT: CDUX,CDUY,CDUZ.          OUTPUT: M11,M21,M31,M22,M32,MR12,MR13.
#                                         (ALSO MR22=M22,MR23=M32)

# AOG = CDUX, AIG = CDUY, AMG = CDUZ: MNEMONIC IS: OIM = XYZ

#    *       *    SIN(MG)        0         1      *
#    M   =   *    COS(MG)COS(OG) SIN(OG)   0      *
#     GP     *   -COS(MG)SIN(OG) COS(OG)   0      *

#    *       *  0    COS(OG)/COS(MG)         -SIN(OG)/COS(MG)         *
#    M   =   *  0    SIN(OG)                  COS(OG)                 *
#     PG     *  1   -SIN(MG)COS(OG)/COS(MG)   SIN(MG)SIN(OG)/COS(MG)  *

# THIS CODING TRANSFERS CONTROL TO THE DAP FIXED BANK FOR GPMATRIX:

                BANK            12
                EBANK=          M11

DAPT4S          EXTEND                                  # GET 2CADR OF GPMATRIX
                DCA             DAPT4
                DTCB                                    # CROSS BANKS

NORRGMON        EQUALS          DAPT4S

                EBANK=          M11
DAPT4           2CADR           GPMATRIX

## Page 122
# T4RUPT DAP LOGIC:

                BANK            20
                EBANK=          M11

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

## Page 123
# SPECIAL LOGIC FOR MIDDLE GIMBAL ANGLES GREATER THAN OR EQUAL TO 60 DEGS:

GPGLOCK         CCS             M32                     # SINCE DIVISION BY COS(MG) MIGHT CREATE
                CAF             POSMAX
                TCF             +2                      # OVERFLOW (I.E. A NUMBER GREATER THAN 2)
                CAF             NEGMAX
                TS              MR12                    # USE THE VALUE SGN(NUMERATOR)*POSMAX AS

                CCS             M22
                CAF             POSMAX                  # THE CLOSEST APPROXIMATION
                TCF             +2
                CAF             NEGMAX
MR13STOR        TS              MR13                    # SCALED AT 2

                TCF             RESUME
