### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    CSM_AND_SATURN_INTEGRATED_TESTS.agc
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



                SETLOC  ENDINFSS
                EBANK=  JETSTEP

# CSM & SATURN TESTS  ENTRY AND INITIALIZATION JOB.

#       THIS JOB INITIALIZES THE ERASABLE TABLES FOR THE CSM AND SATURN TESTS AND PUTS THE
# FOLLOWING PROGRAMS UNDER WAITLIST CONTROL.
#            (1) RCS JET SET TASK
#            (2) ENGINE ON - OFF TASK
#            (3) SPS ENGINE GIMBAL TRIM TASK
#            (4) SATURN STEERING TASK
#            (5) INTERFACE CHANNEL LOOK TASK


CSISTART        TC      GRABWAIT        # SO NOTHING DISRUPTS THE LOAD.
                CAF     JSTEPADR        # THE START OF THE LIST.
                TS      EBANK
CSI3            CCS     A
                TS      MPAC +2
CSI2            CAF     V04N01K         # DISPLAY PRESENT CONTENTS IN R2.
                TC      NVSBWAIT
                INCR    MPAC +2
                CAF     V21N02K
                TC      NVSBWAIT        # IN CASE IT,S BUSY BUT IT SHOULDN,T BE.
                TC      ENDIDLE         # WHILE LOADING.
                TC      +3              # V34E. TERMINATE LOAD OF THIS LIST
                                        # SECTION, GO TO NEW SECTION OR TO TEST.
                TC      +1              # V33E. PRESENT CONTENTS OK, PROCEED TO
                                        # NEXT LOCATION IN LIST.
                TC      CSI2
                CAF     V21N30K
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      EJFREE
                TC      CSI4
                CAE     DSPTEM1         # NEW ADDRESS.
                TC      CSI3
CSI4            CS      TWO
                AD      TESTIDX
                EXTEND
                BZMF    +2
                TC      TIDXALRM

                INDEX   TESTIDX
                TC      +1
                TC      CSITEST0
                TC      CSITEST1
                TC      CSITEST2

CSITEST1        CAF     BIT3
                EXTEND
                RAND    30
                CCS     A
                TC      +2
                TC      CMCCHECK

                CAF     OCT400
                TC      PERFORM
                TC      CMCCHECK

CMCCHECK        EXTEND
                READ    31
                CCS     A
                TC      NOOPTCHK
                TC      NOOPTCHK
                TC      +1
                CAF     OCT401
                TC      PERFORM
                TC      CMCCHECK
                TC      PERFFAIL

NOOPTCHK        CAF     BIT5
                EXTEND
                RAND    33
                CCS     A
                TC      CSI1STRT
                CAF     OCT403
                TC      PERFORM
                TC      NOOPTCHK
                TC      PERFFAIL

CSI1STRT        CAF     NEG0
                TS      OPTIND

                CS      BIT2
                EXTEND
                WAND    12

                CAF     ZERO
                TS      OPTYCMD
                TS      OPTXCMD

                INHINT
                CAF     ONE
                TC      WAITLIST
                2CADR   TRIMTOP

                RELINT
                TC      CSITEST0


PERFORM         TS      DSPTEM1
                EXTEND
                QXCH    QCSI
                CAF     V01N25K
                TC      NVSBWAIT
                CAF     VB50            # PLEASE PERFORM.
                TC      NVSBWAIT
                TC      FLASHON         # ANY RESPONSE TURNS IT OFF.
                TC      ENDIDLE         # WAIT FOR SOMEONE TO DO SOMETHING.
                TC      EJFREE          # V34E. TERMINATE THE TASK.
                TC      +2              # V33E. RETURN TO Q +1.
                TC      QCSI            # ENTER. RETURN TO Q.
                INDEX   QCSI
                TC      1

PERFFAIL        TC      ALARM
                OCT     01404
                TC      FALTON
                TC      EJFREE



CSITEST2        TC      ICDUCHK
                TC      +2
                TC      EJFREE

                CAF     BIT10
                EXTEND
                RAND    30
                CCS     A
                TC      +2
                TC      CSI2STRT

                CAF     OCT402
                TC      PERFORM
                TC      CSITEST2
                TC      PERFFAIL

CSI2STRT        CCS     NOSIVBNJ
                TC      +4
                CAF     BIT13
                EXTEND
                WOR     12

                CS      BIT6
                EXTEND
                WAND    12

                INHINT
                CAF     .5SEC
                TC      WAITLIST
                2CADR   SATSTART

                RELINT

                CAF     ZERO
                TS      CDUXCMD
                TS      CDUYCMD
                TS      CDUZCMD

                TC      CSITEST3

CSITEST0        INHINT
                CAF     TWO
                TC      WAITLIST
                2CADR   JETSTART

                CAF     ONE
                TC      WAITLIST
                2CADR   ENGSTART

                RELINT

CSITEST3        CAF     FIVE
                INHINT
                TC      WAITLIST
                2CADR   LOOKTOP

                CAF     V47K
                TC      NVSBWAIT
                TC      EJFREE

ICDUCHK         EXTEND
                QXCH    QCSI
                CAF     OCTHIRTY
                EXTEND
                RAND    12
                CCS     A
                TC      +2
                TC      QCSI

                TC      ALARM
                OCT     01405
                INDEX   QCSI
                TC      1

TIDXALRM        TC      ALARM
                OCT     01401
                TC      EJFREE

JSTEPADR        ECADR   JETSTEP
V21N02K         OCT     02102
V21N30K         OCT     02130
V47K            OCT     04700
V01N25K         OCT     00125
OCT400          OCT     400
OCT401          OCT     401
V04N01K         =       OCT401
OCT402          OCT     402
OCT403          OCT     403
.5SEC           DEC     50
SATMASK         OCT     70000

# CSM & SATURN TESTS   RCS JETSET TASK
#     THIS JOB ISSUES A PROFILE OF  JET ON-OFF SIGNALS AS DETERMINED BY THE CONSTANTS IN A SET OF SIX REGISTERS.
# THE SIX REGISTERS ARE, (1) NTIMES, THE NUMBER OF TIMES A PARTICULAR STEP WILL BE PERFORMED. (2) NEXTTIME, THE
# TIME BETWEEN STEPS, A MAXIMUM OF 2 MINUTES, (3) JETONTM, THE TIME TO TURN THE JETS ON, SCALED FOR T3, (4) JET-
# OFFTM, THE TIME AFTER ONTM TO TURN THE JETS OFF, (5) XJETS, THE PARTICULAR X JETS TO BE TURNED ON AND OFF
# DURING EACH REPEAT OF A STEP, AND (6) YZJETS,, THE Y AND Z JETS TO BE TURNED ON AND OFF DURING EACH REPEAT OF A
# STEP.  XJETS AND YZJETS MUST BE IN THE SAME FORMAT AS CHANNELS 5 AND6 RESPECTIVELY.  THERE ARE EIGHT SETS OF
# THESE SIX REGISTERS.
#     THE REGISTER JETSTEP IS USED TO INDEX THE 8 SETS OF REGISTERS, THE ALLOWABLE VALUES OF JETSTEP ARE +0 THRU 7
#     THIS JOB WILL BE ENTERED BUT IMMEDIATELY ENDED IF THE INITIAL VALUES OF JETSTEP AND NTIMES ARE +0.

JTENGCHK        EXTEND
                BZMF    JTENGALM
                TC      Q
JTENGALM        TC      ALARM
                OCT     1402
                TC      TASKOVER

STEERCHK        EXTEND
                BZMF    STEERALM
                TC      Q
STEERALM        TC      ALARM
                OCT     1403
                INDEX   TESTIDX
                TC      0
                TC      TRIMSTOP
                TC      SATSTOP

NEXTSET         CCS     JETSTEP         # IT MAY BE ZERO.
                TC      +2              # NOPE
                TC      TASKOVER        # IT IS SO WE ARE DONE WITH THIS TASK.
                TS      JETSTEP

JETSTART        CS      SEVEN
                AD      JETSTEP
                EXTEND
                BZMF    +2
                TC      JTENGALM

                NDX     JETSTEP         # ENTER HERE.
                CCS     NTIMES          # SEE IF THIS STEP IS FINISHED.
                TC      +2              # NO
                TC      NEXTSET         # YES
                NDX     JETSTEP
                CAE     NEXTTIME        # MUST BE SCALED FOR T3.  REMEMBER TO BIAS
                                        # THIS FOR ON TIME.
                TC      JTENGCHK
                TC      VARDELAY

JTOP            NDX     JETSTEP
                CCS     NTIMES          # FOR LOOPING.
                TC      +2
                TC      NEXTSET
                NDX     JETSTEP
                CAE     JETONTM         # SCALED FOR T3.  TIME FOR JETS ON.
                TC      JTENGCHK
                TC      VARDELAY

JETON           NDX     JETSTEP
                CAE     XJETS           # MUST BE IN CHANNEL 5 FORMAT.
                EXTEND
                WRITE   5
                NDX     JETSTEP
                CAE     YZJETS          # MUST BE IN CHANNEL 6 FORMAT.
                EXTEND
                WRITE   6
                NDX     JETSTEP
                CAE     JETOFFTM
                TC      JTENGCHK
                TC      VARDELAY

JETOFF          CAF     ZERO
                EXTEND
                WRITE   5
                EXTEND
                WRITE   6
                NDX     JETSTEP
                CCS     NTIMES
                NDX     JETSTEP
                TS      NTIMES          # ONE LESS TIME.
                TC      JTOP

# CSM & SATURN TESTS  ENGINE ON - OFF TASK
# THIS TASK TURNS THE CSM SPS ENGINE ON AND OFF ACCORDING TO THE CONSTANTS STORED IN THE FIVE SETS OF
# REGISTERS, (1) CYLTIMES, WHICH CONTAINS THE NUMBER OF TIMES A PARTICULARSTEP WILL BE REPEATED, (2) NEXTCYLT,
#  WHICH CONTAINS THE TIME BETWEEN STEPS SCALED FOR T3, (3) ONTIME, WHICH CONTAINS THE TIME TO TURN THE ENGINE ON
# WHICH ALSO DETERMINES THE LENGTH OF TIME THE ENGIME WILL BE OFF WITHIN A SERIES OF ON:OFF CYCLES, (4) OFFTIME,
#  WHICH CONTAINS THE NUMBER OF 2 MINUTES BEFORE THE ENGINE WILL BE TURNED OFF, AND (5) OFFTIMER, WHICH
# CONTAINS THE RESIDUAL TIME BEFORE THE ENGINE WILL BE TURNED OFF.  OFFTIME AND OFFTIMER DETERMINE THE LENGTH
# OF TIME THE ENGINE WILL BE ON IN ANY ONE CYCLE. THERE ARE THREE SETS OF THESE REGISTERS.
#     THE ENGSTEP REGISTER IS USED AS AN INDEX TO PICK UP A PARTICULAR SET  OF THE ABOVE 5 REGISTERS.  THIS TASK
# WILL BE ENTERED BUT IMMEDIATELY ENDED IF ENGSTEP AND CYLTIMES = +0.     THE ALLOWABLE VALUES OF ENGSTEP ARE +0,
# 1 AND 2.

NXTONOFF        CCS     ENGSTEP
                TC      +2
                TC      TASKOVER        # EXIT HERE WHEN STEP AND CYL ARE +0.
                TS      ENGSTEP         # ONE LESS.

ENGSTART        CAF     NEG2
                AD      ENGSTEP
                EXTEND
                BZMF    +2
                TC      JTENGALM

                NDX     ENGSTEP         # ENTER HERE.
                CCS     CYLTIMES        # NUM OF EACH  ON/OFF SET
                TC      +2
                TC      NXTONOFF        # NO MORE OF THIS SET
                NDX     ENGSTEP
                CAE     NEXTCYLT        # START OF NEXT CYCLE.
                TC      JTENGCHK
                TC      VARDELAY

ENGONTM         NDX     ENGSTEP
                CAE     OFFTIME
                TS      OFFTMBUF
                NDX     ENGSTEP
                CAE     ONTIME
                TC      JTENGCHK
                TC      VARDELAY

ENGSET          CS      PRIO30
                EXTEND
                RAND    11
                AD      BIT13
                EXTEND
                WRITE   11              # ENG ON = 1, ENG OFF = 0.
ENGRST          CCS     OFFTMBUF
                TC      LTIMEON         # AT LEAST 2MIN. BEFORE ENGINE OFF.
                NDX     ENGSTEP
                CAE     OFFTIMER        # LESS THAN 2MIN. TO ENGINE OFF.
                TC      JTENGCHK
                TC      VARDELAY

ENGRESET        CS      PRIO30          # BITS 13 AND 14.
                EXTEND
                RAND    11
                AD      BIT14
                EXTEND
                WRITE   11              # ENG ON = 0, ENG OFF = 1.
                NDX     ENGSTEP
                CCS     CYLTIMES
                CCS     A
                TC      +2
                TC      NXTONOFF        # WAS ONE.
                AD      ONE             # WAS MORE THAN ONE.
                NDX     ENGSTEP
                TS      CYLTIMES
                TC      ENGONTM

LTIMEON         CCS     OFFTMBUF        # IS THERE ANY MORE.
                TC      +2              # YES.
                TC      ENGRST          # NO.
                TS      OFFTMBUF
                CAF     2MIN
                TC      WAITLIST
                EBANK=  ENGSTEP
                2CADR   LTIMEON

                TC      TASKOVER

2MIN            DEC     12000

# CSM & SATURN TESTS  TRIM TASK
# THIS PROGRAM ISSUES A PROFILE OF PITCH AND ROLL TRIM COMMANDS TO THE SPS ENGINE GIMBAL IN ACCORDANCEWITH
# THE VALUE S IN THE TRIMSTEP REGISTER AND THE 12 SETS OF 5 REGISTERS CALLED NUMTIMES, STEPDLYT, TRIMONT, TRIMOFFT
# AND TRIMIND.  TRIMSTEP IS USED TO PICK UP A PARTICULAR SET OF THE 5 REGISTERS AND HAS ALLOWABLE VALUES FROM +0
# THROUGH +11 DECIMAL.  THE 5 REGISTERS IN EACH SET ARE DEFINED AS FOLLOWS
#     (1) NUMTIMES DETERMINES THE NUMBER OF TIMES THE COMMAND IN TRIMIND  WILL BE ISSUED.  VALUES FROM +0 TO
# OCT 37777 ARE PERMITTED.
#     (2) STEPDLYT DETERMINES THE TIME BETWEEN THE START OF A STEP AND THE BEGINNING OF TRIMONT.  STEPDLYT MUST BE
# FORMATTED FOR T3, ITS MAXIMUM VALUE IS 2 MINUTES.
#     (3) TRIMONT DETERMINES THE TIME BETWEEN THE END OF STEPDLYT OR TRIMOFFT AND THE TIME THE TRIM COMMANDS ARE
# ISSUED.  IT MUST BE FORMATTED FOR T3.
#     (4) TRIMOFFT DETERMINES THE LENGTH OF TIME THE TRIM COMMAND WILL BE ON, FORMATTED FOR T3.
#     (5) TRIMIND DETERMINES THE PITCH AND ROLL COMMAND TO BE ISSUED.  THE FORMAT IS, BIT9=1=+ PITCH COMMAND,
# BIT10=1=-PITCH, BIT11=1= +ROLL, BIT12=1= -ROLL.  A BIT=0 INDICATES NO COMMAND.  ANY COMBINATION OF COMMANDS IS
# PERMITTED.
#    THIS TASK WILL BE ENTERED BUT IMMEDIATELY ENDED IF TRIMSTEP AND NUMTIMES = +0.

TRIMTOP         CAF     BIT8            # ENTER HERE.
                EXTEND
                WOR     12
                CAF     FIVE
                TC      VARDELAY

                CAF     BIT2
                EXTEND
                WOR     12

                CAF     .5SEC
                TC      VARDELAY

TRIMTOP1        CS      FIVE
                AD      TRIMSTEP
                EXTEND
                BZMF    +2
                TC      STEERALM

                NDX     TRIMSTEP
                CCS     NUMTIMES
                TC      +2
                TC      NEXTTRIM
                NDX     TRIMSTEP
                CAE     STEPDLYT
                TC      STEERCHK
                TC      VARDELAY

TRIMSET         NDX     TRIMSTEP
                CAE     TRIMONT
                TC      STEERCHK
                TC      VARDELAY

TRIMON          NDX     TRIMSTEP
                CAE     TRIMPTCH
                TS      OPTXCMD
                NDX     TRIMSTEP
                CAE     TRIMYAW
                TS      OPTYCMD

                EXTEND
                BZMF    +2
                TC      +2
                COM
                TS      TRIMYBUF

                CS      OPTXCMD
                EXTEND
                BZMF    +2
                TC      +2
                COM
                EXTEND
                SU      TRIMYBUF
                CCS     A
                TC      +4
                TC      TRIMUSEY
                TC      TRIMUSEY
                TC      TRIMUSEY

                CS      OPTXCMD
                EXTEND
                BZMF    +2
                TC      TRIMUSEP
                COM
                TC      TRIMUSEP

TRIMUSEY        CA      TRIMYBUF

TRIMUSEP        EXTEND
                MP      BIT10
                AD      .5SEC
                TC      WAITLIST
                2CADR   NUMSTEP

                CAF     11,12
                EXTEND
                WOR     14              # TRIM STARTS.

                TC      TASKOVER

TRIMSTOP        CS      BIT8            # TRIM GOES OFF.
                EXTEND
                WAND    12

                CAF     FIVE
                TC      VARDELAY

                CS      BIT2
                EXTEND
                WAND    12

                CAF     ZERO
                TS      OPTXCMD
                TS      OPTYCMD

                CAF     NEGONE
                TS      OPTIND
                TC      TASKOVER

NUMSTEP         NDX     TRIMSTEP
                CCS     NUMTIMES
                CCS     A
                TC      +2
                TC      NEXTTRIM        # WAS ONE.
                AD      ONE
                NDX     TRIMSTEP
                TS      NUMTIMES
                TC      TRIMSET

NEXTTRIM        CCS     TRIMSTEP
                TC      +2
                TC      TRIMSTOP        # EXIT HERE.
                TS      TRIMSTEP        # LESS ONE.
                TC      TRIMTOP1

SATSTART        CAF     BIT9
                EXTEND
                WOR     12

                CS      BIT13
                EXTEND
                WAND    12

                CAF     FIVE
                TC      VARDELAY

                CAF     BIT6
                EXTEND
                WOR     12

                CAF     .5SEC
                TC      VARDELAY

SATSTRT1        CS      NINE
                AD      SATSTEP
                EXTEND
                BZMF    +2
                TC      STEERALM

                NDX     SATSTEP
                CCS     SATTIMES
                TC      +2
                TC      NEXTSAT
                NDX     SATSTEP
                CAE     SATDELAY
                TC      STEERCHK
                TC      VARDELAY

SATSET          NDX     SATSTEP
                CAE     SATONT
                TC      STEERCHK
                TC      VARDELAY

                TC      ICDUCHK
                TC      +2
                TC      SATSTOP
                NDX     SATSTEP
                CAE     SATPITCH
                TS      CDUYCMD
                NDX     SATSTEP
                CAE     SATYAW
                TS      CDUZCMD
                NDX     SATSTEP
                CAE     SATROLL
                TS      CDUXCMD

                EXTEND
                BZMF    +2
                TC      +2
                COM
                TS      SATRBUF

                CA      CDUYCMD
                EXTEND
                BZMF    +2
                TC      +2
                COM
                TS      SATPBUF
                EXTEND
                SU      SATRBUF
                CCS     A
                TC      +4
                TC      SATCHKRY
                TC      SATCHKRY
                TC      SATCHKRY

                CA      CDUZCMD
                EXTEND
                BZMF    +2
                TC      +2
                COM
                TS      SATYBUF

                EXTEND
                SU      SATPBUF
                CCS     A
                TC      SATUSEY
                TC      SATUSEP
                TC      SATUSEP
                TC      SATUSEP

SATCHKRY        CA      CDUZCMD
                EXTEND
                BZMF    +2
                TC      +2
                COM
                TS      SATYBUF

                EXTEND
                SU      SATRBUF
                CCS     A
                TC      SATUSEY
                TC      SATUSER
                TC      SATUSER
                TC      SATUSER

SATUSEP         CA      SATPBUF
                TC      SATSTEER

SATUSER         CA      SATRBUF
                TC      SATSTEER

SATUSEY         CA      SATYBUF

SATSTEER        EXTEND
                MP      BIT10
                AD      .5SEC
                TC      WAITLIST
                2CADR   STEERSTP

                CAF     SATMASK
                EXTEND
                WOR     14
                TC      TASKOVER

SATSTOP         CS      BIT9
                EXTEND
                WAND    12

                CAF     FIVE
                TC      VARDELAY

                CS      BIT6
                EXTEND
                WAND    12

                CAF     ZERO
                TS      CDUXCMD
                TS      CDUYCMD
                TS      CDUZCMD

                CAF     BIT14
                EXTEND
                WOR     12

                CAF     .5SEC
                TC      VARDELAY

                CS      BIT14
                EXTEND
                WAND    12

                TC      TASKOVER

STEERSTP        NDX     SATSTEP
                CCS     SATTIMES
                CCS     A
                TC      +2
                TC      NEXTSAT
                AD      ONE
                NDX     SATSTEP
                TS      SATTIMES
                TC      SATSET

NEXTSAT         CCS     SATSTEP
                TC      +2
                TC      SATSTOP
                TS      SATSTEP
                TC      SATSTRT1


# CSM & SATURN TESTS  INTERFACE LOOK TASK.

#     THIS PROGRAM KEEPS A RUNNING HISTORY OF THE STATE OF ALL THE BITS IN INPUT CHANNELS 30, 31, 32 AND 33.
# IT DOES THIS BY DETECTING A CHANGE OF AN INPUT BIT FROM AN INITIAL ONE STATE TO A ZERO STATE OR FROM AN INITIAL
# ZERO TO A ONE.  THE HISTORY IS MAINTAINED IN TWO BUFFER REGISTERS FOR EACH CHANNEL, ONE FOR STORING ONE TO ZERO
# CHANGES (30BUF1, +1, +2, AND +3) AND ONE FOR ZERO TO ONE CHANGES (30BUF0, +1 +2 AND +3).  THE OPERATOR MUST
# LOAD THE INITIAL STATES OF THE INPUT CHANNELS INTO THEIR RESPECTIVE BUFFER REGISTERS BEFORE THIS PROGRAM IS IN-
# ITIATED.
#     TO ALLOW THIS PROGRAM TO RUN C(QUITLOOK) MUST BE SET GREATER THAN +0 BEFORE IT IS STARTED.  IF THE OPERATOR
# DOES NOT DESIRE THIS PROGRAM TO RUN HE SHOULD SET C(QUITLOOK)=+0 BEFORE STARTING THE FCS TEST.  AFTER THIS TASK
# IS RUNNING THE OPERATOR CAN STOP IT BY SETTING C(QUITLOOK) = +0.
#     NO DISPLAYS OF EITHER THE BUFFER REGISTERS OR CHANNELS ARE INCORPORATED INTO THIS PROGRAM.  THIS WAS DONE TO
# ALLOW THE TEST OPERATOR MONITORING FLEXIBILITY.  FOR REAL TIME MONITORING IT IS SUGGESTED THAT THE BUFFER
# REGISTERS BE DISPLAYED WITH THE MONITOR VERBS (11 THROUGH 15).  ON THE OTHER HAND, THE OPERATOR MAY ELECT TO
# PERFORM NO REAL TIME MONITORING UNTIL THE TEST IS COMPLETED, WHEN THE BUFFER REGISTERS WOULD BE CALLED FOR
# DISPLAY (VERB 01) AND RECORDED.

LOOKLOOP        TS      CHCNTR          # 3, 2, 1, 0.
                NDX     CHCNTR
                CAE     30BUF1
                EXTEND
                NDX     CHCNTR
                RAND    30              # DETECTS CHANGES FROM 1 TO 0.
                NDX     CHCNTR
                XCH     30BUF1          # STORE NEW ZEROS.
                NDX     CHCNTR
                CAE     30BUF0
                EXTEND
                NDX     CHCNTR
                ROR     30              # DETECTS CHANGES FROM 0 TO 1.
                NDX     CHCNTR
                XCH     30BUF0          # STORE NEW ONES.
                CCS     CHCNTR          # IS THIS SCAN DONE.
                TC      LOOKLOOP        # NO.
                CAF     TEN             # YES.  100MS RECALL.
                TC      VARDELAY

LOOKTOP         CCS     QUITLOOK        # IS THIS TASK WANTED.
                TC      +2              # YES.
                TC      TASKOVER        # NO.
                CAF     THREE           # START SCAN OF CHANNELS.
                TC      LOOKLOOP

ENDCSITS        =
