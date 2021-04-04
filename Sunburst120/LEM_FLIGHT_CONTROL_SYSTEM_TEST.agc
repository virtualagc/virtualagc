### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	LEM_FLIGHT_CONTROL_SYSTEM_TEST.agc
## Purpose:	A module for revision 0 of BURST120 (Sunburst). It 
##		is part of the source code for the Lunar Module's
##		(LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2016-09-30 RSB	Created draft version.
##		2016-10-18 RSB	Corrected against AURORA 12 version,
##				with which it is seemingly identical other than
##				a handful of comments and EBANK= placements.
##		2016-12-05 RSB	Comment-proofing with octopus/ProoferComments
##				completed, changes made.
##		2017-06-05 MAS	Made comment corrections found during Sunburst 37
##				transcription.
##		2021-05-30 ABS	Added missing EBANK= statement.

## Page 367
                BANK            6
                EBANK=          JETSTEP

# LEM FCS TEST  ENTRY AND INITIALIZATION JOB.

#       THIS JOB INITIALIZES THE ERASABLE TABLES FOR THE FCS TEST AND PUTS THE FOLLOWING PROGRAMS UNDER
# WAITLIST CONTROL.
#            (1) RCS JET SET TASK
#            (2) ENGINE ON - OFF TASK
#            (3) DESCENT ENGINE GIMBAL TRIM TASK
#            (4) DESCENT ENGINE THROTTLE TASK
#            (5) INTERFACE CHANNEL LOOK TASK


FCSSTART        TC              GRABWAIT                        # SO NOTHING DISRUPTS THE LOAD.
                CAF             JSTEPADR                        # THE START OF THE LIST.
FCS3            CCS             A
                TS              MPAC            +2
FCS2            CAF             V04N01K                         # DISPLAY PRESENT CONTENTS IN R2.
                TC              NVSBWAIT
                INCR            MPAC            +2
                CAF             V21N02K
                TC              NVSBWAIT                        # IN CASE IT,S BUSY BUT IT SHOULDN,T BE.
                TC              ENDIDLE                         # WHILE LOADING.
                TC              +3                              # V34E. TERMINATE LOAD OF THIS LIST
                                                                # SECTION, GO TO NEW SECTION OR TO TEST.
                TC              +1                              # V33E. PRESENT CONTENTS OK, PROCEED TO
                                                                # NEXT LOCATION IN LIST.
                TC              FCS2
                CAF             V21N30K
                TC              NVSBWAIT
                TC              ENDIDLE
                TC              EJFREE
                TC              FCSTEST1                        # PROCEED TO TEST.
                CAE             DSPTEM1                         # NEW ADDRESS.
                TC              FCS3
FCSTEST1        CAF             V47K
                TC              NVSBWAIT                        # OUR VERB IN THE LIGHTS.
FCSTEST         INHINT
                CAF             TWO                             # 20MS.
                TC              WAITLIST
                EBANK=          JETSTEP
                2CADR           JETSTART

                CAF             BIT1                            # 10MS.
                TC              WAITLIST
                EBANK=          JETSTEP
## Page 368
                2CADR           ENGSTART

                CAF             THREE                           # 30MS.
                TC              WAITLIST
                EBANK=		JETSTEP
                2CADR           TRIMTOP

                CAF             FOUR                            # 40MS.
                TC              WAITLIST
                EBANK=          JETSTEP
                2CADR           THRSTART

                CAF             FIVE                            # 50MS.
                TC              WAITLIST
                EBANK=          JETSTEP
                2CADR           LOOKTOP

                TC              EJFREE                          # NOW THEY START.

JSTEPADR        ECADR           JETSTEP
V21N02K         OCT             02102
V21N30K         OCT             02130
V04N01K         OCT             00401
V47K            OCT             04700

## Page 369
# LEM FCS TEST   RCS JETSET TASK
#     THIS JOB ISSUES A PROFILE OF  JET ON-OFF SIGNALS AS DETERMINED BY THE CONSTANTS IN A SET OF SIX REGISTERS.
# THE SIX REGISTERS ARE, (1) NTIMES, THE NUMBER OF TIMES A PARTICULAR STEP WILL BE PERFORMED. (2) NEXTTIME, THE
# TIME BETWEEN STEPS, A MAXIMUM OF 2 MINUTES, (3) JETONTM, THE TIME TO TURN THE JETS ON, SCALED FOR T3, (4) JET-
# OFFTM, THE TIME AFTER ONTM TO TURN THE JETS OFF, (5) XJETS, THE PARTICULAR X JETS TO BE TURNED ON AND OFF
# DURING EACH REPEAT OF A STEP, AND (6) YZJETS,, THE Y AND Z JETS TO BE TURNED ON AND OFF DURING EACH REPEAT OF A
# STEP.  XJETS AND YZJETS MUST BE IN THE SAME FORMAT AS CHANNELS 5 AND6 RESPECTIVELY.  THERE ARE EIGHT SETS OF
# THESE SIX REGISTERS.
#     THE REGISTER JETSTEP IS USED TO INDEX THE 8 SETS OF REGISTERS, THE ALLOWABLE VALUES OF JETSTEP ARE +0 THRU 7
#     THIS JOB WILL BE ENTERED BUT IMMEDIATELY ENDED IF THE INITIAL VALUES OF JETSTEP AND NTIMES ARE +0.


NEXTSET         CCS             JETSTEP                         # IT MAY BE ZERO.
                TC              +2                              # NOPE
                TC              TASKOVER                        # IT IS SO WE ARE DONE WITH THIS TASK.
                TS              JETSTEP

JETSTART        NDX             JETSTEP                         # ENTER HERE.
                CCS             NTIMES                          # SEE IF THIS STEP IS FINISHED.
                TC              +2                              # NO
                TC              NEXTSET                         # YES
                NDX             JETSTEP
                CAE             NEXTTIME                        # MUST BE SCALED FOR T3.  REMEMBER TO BIAS
                                                                # THIS FOR ON TIME.
                TC              WAITLIST
                EBANK=          JETSTEP
                2CADR           JTOP

                TC              TASKOVER

JETOFF          CAF             ZERO
                EXTEND
                WRITE           5
                EXTEND
                WRITE           6
                NDX             JETSTEP
                CCS             NTIMES
                NDX             JETSTEP
                TS              NTIMES                          # ONE LESS TIME.
JTOP            NDX             JETSTEP
                CCS             NTIMES                          # FOR LOOPING.
                TC              +2
                TC              NEXTSET
                NDX             JETSTEP
                CAE             JETONTM                         # SCALED FOR T3.  TIME FOR JETS ON.
                TC              WAITLIST
                EBANK=          JETSTEP
                2CADR           JETON

## Page 370
                TC              TASKOVER

JETON           NDX             JETSTEP
                CAE             XJETS                           # MUST BE IN CHANNEL 5 FORMAT.
                TS              XJBUF
                NDX             JETSTEP
                CAE             YZJETS                          # MUST BE IN CHANNEL 6 FORMAT.
                TS              YZJBUF
JFAILCK         EXTEND                                          # THIS ROUTINE EXAMINES EACH JETFAIL BIT
                READ            32                              # AND IF A FAILURE IS INDICATED THE CORRES
                COM                                             # PONDING COMMANDS ARE MASKED OUT .
                TS              JFBUF                           # SAVE 32 REINVERTED.
                CAF             SEVEN
JF3             TS              FCNTR
                CAE             JFBUF
                NDX             FCNTR
                MASK            BIT8
                CCS             A
                TC              JFAIL
JFAIL1          CCS             FCNTR
                TC              JF3
                CAE             XJBUF
                EXTEND
                WRITE           5                               # XJETS GO ON.
                CAE             YZJBUF
                EXTEND
                WRITE           6                               # YZJETS GO ON.
                NDX             JETSTEP
                CAE             JETOFFTM                        # JET OFF TIME SCALED FOR T3.
                TC              WAITLIST
                EBANK=          JETSTEP
                2CADR           JETOFF

                TC              TASKOVER

JFAIL           NDX             FCNTR
                CS              XJETMASK
                MASK            XJBUF
                TS              XJBUF
                NDX             FCNTR
                CS              YZJETMSK
                MASK            YZJBUF
                TS              YZJBUF
                TC              ALARM
                OCT             01410                           # TEMPORARY JET FAIL ALARM CODE.
                TC              JFAIL1

## Page 371
YZJETMSK        OCT             00010                           # JET 11
                OCT             00020                           # JET 12
                OCT             00004                           # JET 15
                OCT             00200                           # JET 16
                OCT             00001                           # JET 7
                OCT             00002                           # JET 3
                OCT             00040                           # JET 8
                OCT             00100                           # JET 4

XJETMASK        OCT             00040                           # JET 10
                OCT             00020                           # JET 9
                OCT             00100                           # JET 13
                OCT             00200                           # JET 14
                OCT             00010                           # JET 6
                OCT             00001                           # JET 1
                OCT             00004                           # JET 5
                OCT             00002                           # JET 2

## Page 372
# LEM FCS TEST  ENGINE ON - OFF TASK
# THIS TASK TURNS THE LEM ASCENT OR DESCENT ENGINE ON AND OFF ACCORDING TOTHE CONSTANTS STORED IN THE FIVE SETS OF
# REGISTERS, (1) CYLTIMES, WHICH CONTAINS THE NUMBER OF TIMES A PARTICULARSTEP WILL BE REPEATED, (2) NEXTCYLT,
#  WHICH CONTAINS THE TIME BETWEEN STEPS SCALED FOR T3, (3) ONTIME, WHICH CONTAINS THE TIME TO TURN THE ENGINE ON
# WHICH ALSO DETERMINES THE LENGTH OF TIME THE ENGIME WILL BE OFF WITHIN A SERIES OF ON:OFF CYCLES, (4) OFFTIME,
#  WHICH CONTAINS THE NUMBER OF 2 MINUTES BEFORE THE ENGINE WILL BE TURNED OFF, AND (5) OFFTIMER, WHICH
# CONTAINS THE RESIDUAL TIME BEFORE THE ENGINE WILL BE TURNED OFF.  OFFTIME AND OFFTIMER DETERMINE THE LENGTH
# OF TIME THE ENGINE WILL BE ON IN ANY ONE CYCLE. THERE ARE THREE SETS OF THESE REGISTERS.
#     THE ENGSTEP REGISTER IS USED AS AN INDEX TO PICK UP A PARTICULAR SET  OF THE ABOVE 5 REGISTERS.  THIS TASK
# WILL BE ENTERED BUT IMMEDIATELY ENDED IF ENGSTEP AND CYLTIMES = +0.     THE ALLOWABLE VALUES OF ENGSTEP ARE +0,
# 1 AND 2.


NXTONOFF        CCS             ENGSTEP
                TC              +2
                TC              TASKOVER                        # EXIT HERE WHEN STEP AND CYL ARE +0.
                TS              ENGSTEP                         # ONE LESS.

ENGSTART        NDX             ENGSTEP                         # ENTER HERE.
                CCS             CYLTIMES                        # NUM OF EACH  ON/OFF SET
                TC              +2
                TC              NXTONOFF                        # NO MORE OF THIS SET
                NDX             ENGSTEP
                CAE             NEXTCYLT                        # START OF NEXT CYCLE.
                TC              WAITLIST
                EBANK=          ENGSTEP
                2CADR           ENGONTM

                TC              TASKOVER

ENGRESET        CS              PRIO30                          # BITS 13 AND 14.
                EXTEND
                RAND            11
                AD              BIT14
                EXTEND
                WRITE           11                              # ENG ON = 0, ENG OFF = 1.
                NDX             ENGSTEP
                CCS             CYLTIMES
                CCS             A
                TC              +2
                TC              NXTONOFF                        # WAS ONE.
                AD              ONE                             # WAS MORE THAN ONE.
                NDX             ENGSTEP
                TS              CYLTIMES

ENGONTM         NDX             ENGSTEP
                CAE             OFFTIME
                TS              OFFTMBUF
                NDX             ENGSTEP
## Page 373
                CAE             ONTIME
                TC              WAITLIST
                EBANK=          ENGSTEP
                2CADR           ENGSET

                TC              TASKOVER

ENGSET          CS              PRIO30
                EXTEND
                RAND            11
                AD              BIT13
                EXTEND
                WRITE           11                              # ENG ON = 1, ENG OFF = 0.
ENGRST          CCS             OFFTMBUF
                TC              LTIMEON                         # AT LEAST 2MIN. BEFORE ENGINE OFF.
                NDX             ENGSTEP
                CAE             OFFTIMER                        # LESS THAN 2MIN. TO ENGINE OFF.
                TC              WAITLIST
                EBANK=          ENGSTEP
                2CADR           ENGRESET

                TC              TASKOVER

LTIMEON         CCS             OFFTMBUF                        # IS THERE ANY MORE.
                TC              +2                              # YES.
                TC              ENGRST                          # NO.
                TS              OFFTMBUF			# ONE LESS.
                CAF             2MIN
                TC              WAITLIST
                EBANK=          ENGSTEP
                2CADR           LTIMEON

                TC              TASKOVER

2MIN            DEC             12000

## Page 374
# LEM FCS TEST  TRIM TASK
# THIS PROGRAM ISSUES A PROFILE OF PITCH AND ROLL TRIM COMMANDS TO THE LEM DESCENT ENGINE GIMBAL IN ACCORDANCEWITH
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


NEXTTRIM        CCS             TRIMSTEP
                TC              +2
                TC              TASKOVER                        # EXIT HERE.
                TS              TRIMSTEP                        # LESS ONE.

TRIMTOP         NDX             TRIMSTEP                        # ENTER HERE.
                CCS             NUMTIMES
                TC              +2
                TC              NEXTTRIM
                NDX             TRIMSTEP
                CAE             STEPDLYT
                TC              WAITLIST
                EBANK=          TRIMSTEP
                2CADR           TRIMSET

                TC              TASKOVER

TRIMOFF         CS              TRIMMASK
                EXTEND
                WAND            12                              # TRIM GOES OFF.
NUMSTEP         NDX             TRIMSTEP
                CCS             NUMTIMES
                CCS             A
                TC              +2
                TC              NEXTTRIM                        # WAS ONE.
                AD              ONE
                NDX             TRIMSTEP
                TS              NUMTIMES
TRIMSET         NDX             TRIMSTEP
                CAE             TRIMONT
                TC              WAITLIST
## Page 375
                EBANK=          TRIMSTEP
                2CADR           TRIMON

                TC              TASKOVER

TRIMON          CAF             BITS9,10                        # CHECK PITCH AND ROLL TRIM FAIL BITS.
                EXTEND
                RXOR            32
                MASK            BITS9,10
                EXTEND
                BZF             TRIMON1
                CAF             PRIO35                          # FAIL IS ON. FLASH FAIL CODE (01400) AND
                TC              NOVAC                           # IDLE UNTIL SOMEONE RESETS IT, TERMINATES
                EBANK=		JETSTEP
                2CADR           PERFORM                         # THE TASK, OR DECIDES TO PROCEED WITH IT.

                TC              TASKOVER

TRIMON1         NDX             TRIMSTEP
                CAE             TRIMIND
                MASK            TRIMMASK                        # SAFETY PLAY
                EXTEND
                WOR             12                              # TRIM STARTS.
                NDX             TRIMSTEP
                CAE             TRIMOFFT
                TC              WAITLIST
                EBANK=          TRIMSTEP
                2CADR           TRIMOFF

                TC              TASKOVER

PERFORM         TC              GRABWAIT                        # KEY RELEASE MAY COME ON.
                CAF             TRIMCODE                        # 01400
                TS              DSPTEM1
                CAF             V01N25K
                TC              NVSBWAIT
                CAF             V50K                            # PLEASE PERFORM.
                TC              NVSBWAIT
                TC              FLASHON                         # ANY RESPONSE TURNS IT OFF.
                TC              ENDIDLE                         # WAIT FOR SOMEONE TO DO SOMETHING.
                TC              EJFREE                          # V34E. TERMINATE THE TASK.
                TC              TR1                             # V33E. PROCEED WITH THE FAIL ON.
                INHINT                                          # ENTER. THE FAIL HAS BEEN RESET.
                CAF             BIT2                            # 20MS.
                TC              WAITLIST
                EBANK=          JETSTEP
                2CADR           TRIMON                          # CHECK AGAIN TO BE SURE. THEN PROCEED..

                TC              EJFREE

## Page 376
TR1             INHINT                                          # PROCEED WITH THE FAIL.
                CAF             BIT2                            # 20MS.
                TC              WAITLIST
                EBANK=		JETSTEP
                2CADR           TRIMON1                         # BYPASS THE RECHECK.

                TC              EJFREE

BITS9,10        OCT             01400
TRIMCODE        EQUALS          BITS9,10
TRIMMASK        OCT             07400
V01N25K         OCT             00125
V50K            OCT             05000

## Page 377
# LEM FCS TEST  THROTTLE TASK
#    THIS PROGRAM ISSUES A PROFILE OF THROTTLE COMMANDS TO THE LEM DESCENT ENGINE.  THE PROFILE IS DETERMINED BY
# THE VALUES IN THE THRTSTEP REGISTER AND THE 6  SETS OF REGISTERS, 5 PER SET, CALLED  DOTIMES, DELAY, THR1TIME,
# THCOMM1 AND THCOMM2.  THE THRTSTEP REGISTER VALUE IS USED TO INDEX THE  6  SETS OF 5 REGISTERS AND HAS ALLOWABLE
# VALUES OF +0 THROUGH +5.  THE 5 REGISTERS PER SET ARE DEFINED AS FOLLOWS
#     (1) DOTIMES DETERMINES THE NUMBER OF TIMES THE THROTTLE WILL BE EXERCISED AS PER THE VALUES OF THR1TIME,
# THCOMM1 AND THCOMM2 OF THE CURRENT STEP.  IT HAS ALLOWABLE VALUES OF +0 THROUGH 37777 OCT.
#     (2) DELAY DETERMINES THE TIME BETWEEN THE START OF A STEP AND THE BE GINNING OF THR1TIME. ITIS CALLED ONLY
# ONCE PER STEP,I.E., REPEATS OF THE SAME THCOMM1 AND THCOMM2 START AT THR1TIME.  DELAY MUST BE FORMATTED FOR T3
# AND HENCE HAS A MAXIMUM VALUE OF 2 MINUTES.
#     (3) THR1TIME DETERMINES THE TIME BETWEEN THE END OF DELAY OR THE END   OF THCOMM2 AND THE START OF
# THCOMM1.  IT MUST BE FORMATTED FOR T3.
#     (4) THCOMM1 AND (5) THCOMM2 DETERMINE THE NUMBER OF THRUST INCREASE  OR DECREASE PULSES TOBE ISSUED AT A
# 3.2KPPS RATE.  THE RANGE OF POSSIBLE VALUES OF EITHER IS FROM POSMAX (OCT 37777) TO NEGMAX (OCT 40000) ALTHOUGH
# THE ACTUAL THROTTLE RANGE IS FROM OCT 6116 TO OCT 71661 (+,- 3150 DEC).
#    THIS TASK WILL BE ENTERED BUT IMMEDIATELY ENDED IF THE INITIAL VALUES OF THRTSTEP AND DOTIMES ARE +0.


NEXTTHRT        CCS             THRTSTEP
                TC              +2
                TC              TASKOVER                        # EXIT HERE.
                TS              THRTSTEP

THRSTART        NDX             THRTSTEP                        # ENTER HERE.
                CCS             DOTIMES                         # NUMBER OF TIMES COMMANDS 1 AND 2 DONE.
                TC              +2
                TC              NEXTTHRT
                NDX             THRTSTEP
                CAE             DELAY                           # TIME BETWEEN STEPS.  BIAS FOR THR1TIME.
                                                                # MUST BE SCALED FOR T3.
                TC              WAITLIST
                EBANK=          THRTSTEP
                2CADR           THROTON1

                TC              TASKOVER

THR2COMM        NDX             THRTSTEP
                CAE             THCOMM2                         # SAME REMARKS AS FOR THCOMM1.
                TC              THROTON
                AD              BIT1                            # 10MS IN CASE OF NO THCOMM2.
                TC              WAITLIST
                EBANK=          THRTSTEP
                2CADR           CKDOTIME

                TC              TASKOVER

CKDOTIME        NDX             THRTSTEP
                CCS             DOTIMES
                CCS             A
## Page 378
                TC              +2
                TC              NEXTTHRT                        # WAS ONE.
                AD              ONE
                NDX             THRTSTEP
                TS              DOTIMES
THROTON1        NDX             THRTSTEP
                CAE             THR1TIME                        # TIME BETWEEN DOTIMES.  SCALED FOR T3.
                TC              WAITLIST
                EBANK=          THRTSTEP
                2CADR           THR1COMM

                TC              TASKOVER

THR1COMM        NDX             THRTSTEP
                CAE             THCOMM1                         # SHOULD BE NO LARGER THAN 3150DEC.
                TC              THROTON
                AD              250MS                           # SO ACE CAN SAMPLE.
                TC              WAITLIST
                EBANK=          THRTSTEP
                2CADR           THR2COMM

                TC              TASKOVER

THROTON         TS              THRUST                          # THROTTLE OUTPUT COUNTER.
                TS              THBUF                           # SAVE FOR BZMF.
                CAF             BIT4
                EXTEND
                WOR             14                              # ENABLE THRUST DRIVE.  COMMAND STARTS NOW
                CAE             THBUF
                EXTEND
                BZMF            +2
                COM
                COM
                EXTEND
                MP              BIT10                           # SCALES FOR T3.
                TC              Q

250MS           OCT             00031

## Page 379
# LEM FCS TEST  INTERFACE LOOK TASK.

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
#     THIS PROGRAM IS PRIMARILY INTENDED FOR INTERFACE MONITORING DURING THE LEM VIBRATION TEST AT BETHPAGE, N.Y.,
# ALTHOUGH IT MAY ALSO BE USEFUL DURING VEHICAL LEVEL EMI TESTS.

LOOKTOP         CCS             QUITLOOK                        # IS THIS TASK WANTED.
                TC              +2                              # YES.
                TC              TASKOVER                        # NO.
                CAF             THREE                           # START SCAN OF CHANNELS.
LOOKLOOP        TS              CHCNTR                          # 3, 2, 1, 0.
                NDX             CHCNTR
                CAE             30BUF1
                EXTEND
                NDX             CHCNTR
                RAND            30                              # DETECTS CHANGES FROM 1 TO 0.
                NDX             CHCNTR
                XCH             30BUF1                          # STORE NEW ZEROS.
                NDX             CHCNTR
                CAE             30BUF0
                EXTEND
                NDX             CHCNTR
                ROR             30                              # DETECTS CHANGES FROM 0 TO 1.
                NDX             CHCNTR
                XCH             30BUF0                          # STORE NEW ONES.
                CCS             CHCNTR                          # IS THIS SCAN DONE.
                TC              LOOKLOOP                        # NO.
                CAF             TEN                             # YES.  100MS RECALL.
                TC              WAITLIST
                EBANK=          QUITLOOK
                2CADR           LOOKTOP

                TC              TASKOVER

