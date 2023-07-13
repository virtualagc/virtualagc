### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    EXTENDED_VERBS.agc
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


                BANK    11
                EBANK=  OGC

# FAN-OUT

LST2FAN         TC      VBZERO          # VB40 ZERO (USED WITH NOUN 20, 40, OR 70
                                        #                                    ONLY)
                TC      VBCOARK         # VB41 COARSE ALIGN (USED WITH NOUN 20, 40
                                        #                              OR 70 ONLY)
                TC      IMUFINEK        # VB42 FINE ALIGN IMU
                TC      IMUATTCK        # VB43  LOAD IMU ATTITUDE ERROR METERS.
                TC      ALM/END         # ILLEGAL VERB.
                TCF     LRPOS2K         # VB45 COMMAND LR TO POSITION 2.
                TC      REGRSAMP        # VB46 SAMPLE RADAR ONCE PER SECOND
                TC      DOFCSTST        # VB47 PERFORM LEM FCS TEST
                TC      GOLOADLV        # VB50 PLEASE PERFORM
                TC      GOLOADLV        # VB51 PLEASE MARK
                TC      GOLOADLV        # VB52 PLEASE MARK Y
                TC      GOLOADLV        # VB53 PLEASE MARK X OR Y.
                TC      TORQGYRS        # VB54 PULSE TORQUE GYROS
                TC      ALINTIME        # VB55 ALIGN TIME
                TC      GOSHOSUM        # VB56 PERFORM BANKSUM
                TC      SYSTEST         # VB57 PERFORM SYSTEM TEST
                TC      PRESTAND        # VB60 PREPARE FOR STANDBY
                TC      POSTAND         # VB61 RECOVER FROM STANDBY
                TC      SETUPMSG        # VB62 SCAM LEM INBITS
                TCF     AGSINIT         # VB63 INITIALIZE AGS
                TCF     ALM/END
                TCF     ALM/END
                TCF     LOTSTRT         # VB66 LOTS FRESH START
                TCF     ALM/END
                TC      LOTSACQ         # VB70 ACQUIRE WITH LOTS
                TC      LOTSTEST        # VB71 LOTS SELF TEST
                TC      LOTSSTOW        # VB72 RETURN LOTS TO STOW
                TCF     ALM/END
                TCF     ALM/END
                TCF     ALM/END
                TCF     ALM/END
                TC      ALM/END

TESTXACT        CAF     BIT3
                MASK    EXTVBACT
                CCS     A
                TC      XACTALM

XACT1           CS      BIT3
                INHINT
                MASK    EXTVBACT
                AD      BIT3
                TS      EXTVBACT

                RELINT
                TC      Q

XACTALM         TC      FALTON
                TC      ENDOFJOB

TERMEXTV        TC      FREEDSP         # IF WE GET A TERMINATE INSTEAD OF A LOAD.

ENDEXTVB        TC      XACT0
                TC      ENDOFJOB

XACT0           CS      BIT3
                INHINT
                MASK    EXTVBACT
                TS      EXTVBACT
                RELINT
XACT0Q          TC      Q



ALM/END         TC      FALTON
                TC      ENDEXTVB



VBZERO          TC      OP/INERT
                TC      IMUZEROK        # RETURN HERE IF NOUN = ICDU(20)
                TC      RRZEROK         # RETURN HERE IF NOUN = RCDU(40)
                TC      ALM/END         # RETURN HERE IF NOUN = OCDU(70)

VBCOARK         TC      OP/INERT
                TC      IMUCOARK        # RETURN HERE IF NOUN = ICDU (20)
                TC      RRDESNBK        # RETURN HERE IF NOUN = RCDU (40)
                TC      ALM/END         # RETURN HERE IF NOUN = OCDU (70)

# RETURNS TO L+1 IF IMU, L+2 IF RR, AND L+3 IF OT.

OP/INERT        CS      BIT5            # OCT20
                AD      NOUNREG
                EXTEND
                BZF     XACT0Q          # IF = 20.

                INCR    Q
                AD      RRIMUDIF        # = -20 OCT.
                EXTEND
                BZF     XACT0Q

                INCR    Q
                AD      OTRRDIF         # = -30 OCT.
                EXTEND
                BZF     XACT0Q

                TC      ALM/END         # ILLEGAL.

RRIMUDIF        OCT     -20
OTRRDIF         OCT     -30

# KEYBOARD REQUEST TO ZERO IMU ENCODERS

IMUZEROK        TC      TESTXACT        # ZERO ENCODERS.
                TC      BANKCALL
                CADR    IMUZERO

                TC      BANKCALL        # STALL
                CADR    IMUSTALL
                TC      +1

                TC      ENDEXTVB
RRZEROK         TC      TESTXACT
                TC      BANKCALL        # ZERO RR CDUS.
                CADR    RRZERO

RWAITK          TC      BANKCALL
                CADR    RADSTALL
                TCF     +1
                TCF     ENDEXTVB

LRPOS2K         TC      TESTXACT        # COMMAND LR TO POSITION 2.
                TC      BANKCALL
                CADR    LRPOS2
                TCF     RWAITK

# KEYBOARD REQUEST TO COARSE ALIGN THE IMU

IMUCOARK        TC      TESTXACT        # COARSE ALIGN FROM KEYBOARD.
                TC      GRABWAIT
                CAF     VNLODCDU        # CALL FOR THETAD LOAD
                TC      NVSBWAIT
                TC      ENDIDLE         # STALL WAITING FOR THE LOAD
                TC      TERMEXTV
                TC      ICSDEL          # PROCEED - ASK FOR INCREMENTAL LOAD.

ICORK2          CAF     IMUCOARV        # RE-DISPLAY COARSE ALIGN VERB.
                TC      NVSBWAIT
                TC      FREEDSP         # RELEASE THE DISPLAYS

                TC      BANKCALL        # CALL MODE SWITCHING PROG
                CADR    IMUCOARS

                TC      BANKCALL        # STALL
                CADR    IMUSTALL
                TC      ENDEXTVB
                TC      ENDEXTVB

VNLODCDU        OCT     02522
IMUCOARV        OCT     04100

#          PROVISION FOR COARSE ALIGN TO INCREMENTAL ANGLES.

ICSDEL          CAF     DELLOAD
                TC      NVSBWAIT        # REQUEST LOAD OF DELTA ICDU ANGLES.
                TC      ENDIDLE
                TC      TERMEXTV
                TC      ICORK2          # PROCEED WITHOUT DATA HERE TOO.
                TC      INCLOOP         # LOOP TO INCREMENT THETAD FROM DSPTEM2.
                TC      ICORK2          # RE-DISPLAY COARSE ALIGN VERB.

INCLOOP         XCH     Q               # INCREMENTS THETADS IN 2S COMPLEMENT FROM
                TS      MPAC            #  THREE ANGLE INCREMENTS IN DSPTEM2S.
                CAF     LTHD+2
                TS      BUF             # SET UP FOR CDUINC.
                CAF     TWO             # THREE TIMES THROUGH.

INCLOOP2        TS      MPAC +1
                INDEX   A
                XCH     DSPTEM2         # INCREMENT TO TEM2 FOR CDUINC.
                TC      BANKCALL
                CADR    CDUINC
                CCS     BUF
                TS      BUF
                CCS     MPAC +1
                TC      INCLOOP2

                TC      MPAC            # RETURN WHEN FINISHED.

DELLOAD         OCT     02523
LTHD+2          ADRES   THETAD +2

# KEYBOARD REQUEST TO FINE ALIGN AND GYRO TORQUE IMU

IMUFINEK        TC      TESTXACT        # FINE ALIGN WITH GYRO TORQUING.
                TC      GRABWAIT
                CAF     VNLODGYR        # CALL FOR LOAD OF GYRO COMMANDS
                TC      NVSBWAIT
                TC      ENDIDLE         # HOLD UP FOR THE DATA LOAD
                TC      TERMEXTV
                TC      +1              # PROCEED WITHOUT A LOAD

                CAF     IMUFINEV        # RE-DISPLAY OUR OWN VERB
                TC      NVSBWAIT
                TC      FREEDSP         # RELEASE DISPLAYS

                TC      BANKCALL        # CALL MODE SWITCH PROG
                CADR    IMUFINE

                TC      BANKCALL        # HIBERNATION
                CADR    IMUSTALL
                TC      ENDEXTVB

FINEK2          CAF     LGYROBIN        # PINBALL LEFT COMMANDS IN OGC REGIST5RS
                TC      BANKCALL
                CADR    IMUPULSE

                TC      BANKCALL        # WAIT FOR PULSES TO GET OUT.
                CADR    IMUSTALL
                TC      ENDEXTVB
                TC      ENDEXTVB

VNLODGYR        OCT     02567
IMUFINEV        OCT     04200           # FINE ALIGN VERB

#          DESIGNATE TO DESIRED GIMBAL ANGLES.

RRDESNBK        TC      TESTXACT
                TC      GRABWAIT
                CAF     VNLDRCDU        # ASK FOR GIMBAL ANGLES.
                TC      NVSBWAIT
                TC      ENDIDLE         # WAIT FOR THE LOAD
                TC      TERMEXTV
                TC      +1              # PROCEED

                TC      BANKCALL        # ASK OP FOR LOCK ON REQUIREMENTS.
                CADR    AURLOKON

                CAF     OPTCOARV        # RE-DISPLAY OUR OWN VERB
                TC      NVSBWAIT
                INHINT                  # FIRE UP JOB TO DO DESIGNATE.
                CAF     PRIO20
                TC      FINDVAC
                EBANK=  OGC
                2CADR   RRDESK2

                TCF     TERMEXTV        # FREES DISPLAY.

VNLDRCDU        OCT     02441
OPTCOARV        EQUALS  IMUCOARV        # DIFFERENT NOUNS.

RRDESK2         TC      INTPRET

                CALL
                        RRDESNB         # RETURNS IN BASIC.

                TC      RWAITK

# PLEASE PERFORM VERB AND PLEASE MARK VERB ----- PRESSING ENTER INDICATES
# ACTION REQUESTED HAS BEEN PERFORMED, AND DOES SAME RECALL AS A COMPLETED
# LOAD.  OPERATOR SHOULD DO VB PROCEED WITHOUT DATA IF HE WISHES NOT TO
# PERFORM THE REQUESTED ACTION.

GOLOADLV        TC      FLASHOFF
                TC      XACT0
                TC      POSTJUMP
                CADR    LOADLV1

# KEYBOARD REQUEST TO PULSE TORQUE IRIGA



TORQGYRS        TC      TESTXACT        # GYRO TORQUING WITH NO MODE-SWITCH.
                TC      GRABWAIT
                CAF     VNLODGYR
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      TERMEXTV
                TC      +1
                CAF     TORQGYRV        # RE-DISPLAY OUR OWN VERB
                TC      NVSBWAIT
                TC      FREEDSP
                TCF     FINEK2

LGYROBIN        ECADR   DELVX
TORQGYRV        OCT     05400

# ALIGN TIME
ALINTIME        CAF     VNLODDT         # USES NVSUBMON. DOES NOT TEST DSPLOCK.
                TS      NVTEMP          # DOES NOT KILL MONITOR.
                TC      NVSUBMON
                TC      ENDOFJOB        # IN CASE OF ALARM IN LOAD REQUEST SET UP.
                TC      ENDIDLE
                TC      ENDOFJOB        # TERMINATE
                TC      ENDOFJOB        # PROCEED WITHOUT DATA
UPDATIME        INHINT                  # DELTA TIME IS IN DSPTEM1, +1.
                CAF     ZERO
                TS      MPAC +2         # NEEDED FOR TP AGREE
                TS      L               # ZERO T1 & 2 WHILE ALIGNING.
                DXCH    TIME2
                DXCH    MPAC
                DXCH    DSPTEM1         # INCREMENT.
                DAS     MPAC

                TC      TPAGREE         # FORCE SIGN AGREEMENT.
                DXCH    MPAC            # NEW CLOCK.
                DAS     TIME2
                TC      ENDOFJOB

VNLODDT         OCT     02124           # V/N FOR LOAD DELTA TIME

                NOOP
                NOOP

#          SELECT AND INITIATE DESIRED SYSTEM TEST PROGRAM.

                EBANK=  QPLACE

SYSTEST         CCS     MODREG          # DEMAND MODE 00.
                TCF     XACTALM

                TC      GRABWAIT
REDO            CAF     LQPL            # ASK FOR TEST OPTION (1 - 7).
                TS      MPAC +2
                CAF     TESTNV
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      EJFREE
                TC      REDO

                TC      NEWMODEX
                OCT     07

                INHINT
                CAF     PRIO20
                TC      FINDVAC
                2CADR   TSELECT

                TC      ENDOFJOB        # LEAVING DISPLAY GRABBED FOR SYSTEM TEST.

TSELECT         CS      LOW4            #   OCTAL 17 OPTIONS WITHOUT OPERATOR ERRO
                TC      TSELECT1
                INDEX   QPLACE
                CAF     TESTCADR
                TC      BANKJUMP

TESTCADR        CADR    ALM/END         # 0  ILLEGAL
                CADR    IMUTEST         # 1  GYRO DRIFT TEST
                CADR    IMUBACK         # 2 REPEAT OF IMUTEST
                CADR    AOTNBIMU        # 3  IMU ALIGNMENT TEST
                CADR    OPCHK           # 4  IMU CHECK
                CADR    GYRSFTST        # 5  GYRO TORQUING TEST
                CADR    STARTPL         # 6  GYROCOMPASS TEST
                CADR                    #  AVAILABLE
                CADR    SAMODCHK        # 10 SEMI-AUTOMATIC MODING CHECK
                CADR    SAUTOIFS        # 11 SEMI-AUTOMATIC INTERFACE TEST
                CADR    AOTANGCK        # 12 AOT ANGLE CHECK
                CADR    RDRINIT         # 13 RENDEZVOUS RADAR / ANTENNAE TRACKING
                CADR    FSTRSAMP        # 14 HIGH SPEED RADAR SAMPLING.

                CADR    ZEROERAS
                CADR    DISINDT         # DISPLAY INERTIAL DATA TEST.
                CADR    ALM/END
                CADR    ALM/END

GOSHOSUM        TC      POSTJUMP        # START ROUTINE TO DISPLAY SUM OF EACH
                CADR    SHOWSUM         # BANK ON DSKY

DOFCSTST        TC      POSTJUMP
                CADR    FCSSTART

#          SET UP FOR RADAR SAMPLING.

                EBANK=  RSTKLOC

FSTRSAMP        CAF     RSTKLIST        # HIGH SPEED SAMPLING. SWITCH TO SPECIAL
                TS      DNLSTADR        # DOWNLIST.
                CS      ONE             # WANTS TM BUFFERING.
                TCF     RSAMPTST

REGRSAMP        TC      GRABWAIT
                CAF     1SEC+1          # SHOWS NO TM BUFFERING.

RSAMPTST        TS      MPAC +2
                INHINT
                CS      LRPOSCAL        # INITIALIZE SCALE AND LR POSITION BITS.
                MASK    RADMODES
                TS      RADMODES

                CAF     LRPOSCAL
                EXTEND
                RAND    33
                ADS     RADMODES

                RELINT
                CAF     LRTSTDEX
                TS      EBANK
                XCH     MPAC +2
                TS      RSAMPDT         # HI SPEED NNZ - LO SPEED PNZ.
                CAF     ZERO
                TS      RTSTLOC
                TS      RFAILCNT        # ZERO BAD SAMPLE COUNTER.
                CAF     HISPMAX
                TS      RTSTMAX

                CAF     RTSTNV
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      EJFREE          # ON TERMINATE.
                TCF     RSEMIAUT        # PROCEED MEANS SEMI-AUTO SEQUENCING.
RDRDFREE        TC      FREEDSP
                CCS     RSAMPDT         # SEE IF HI OR LO SPEED SAMPLING.
                TCF     +4

LRTSTDEX        ECADR   RTSTDEX

                TC      POSTJUMP        # EXEC. OTHERWISE, SET UP WAITLIST TIMING.
                CADR    DORSAMP

                CAF     SIX             # FIND OUT WHICH RADAR WANTED.
                MASK    RTSTDEX

                CCS     A
                TCF     LRCYCLE         # LANDING RADAR ARE SERIALS 2 - 5.

                TS      RTSTBASE        # FOR RR BASE = 0, MAX = 1.
                CAF     SIX
                TCF     +4

LRCYCLE         CAF     TWO             # FOR LR BASE = 2, MAX = 3.
                TS      RTSTBASE
                CAF     18R

 +4             TS      RTSTMAX
                INHINT
                TC      WAITLIST
                EBANK=  RSTKLOC
                2CADR   RADSAMP

                TC      ENDOFJOB

18R             DEC     18
HISPMAX         DEC     66
RTSTNV          OCT     2101
RSTKLIST        GENADR  FSTRADTM
1SEC+1          DEC     101
LRPOSCAL        OCT     444

#          SEMI-AUTO RADAR TESTING.

RSEMIAUT        INHINT
                CAF     PRIO25          # START HI SPEED SAMPLING.
                TC      NOVAC
                2CADR   DORSAMP

                RELINT
                CAF     FIVE            # SEQUENCE THROUGH ALL SIX CHANNELS.
 -1             TS      RTSTDEX

33PASTE         CAF     RV33            # ON ENTER, SWITCH TO NEXT CHANNEL.
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TC      ENDRTST         # ON TERMINATE.
                TCF     +2
                TCF     33PASTE         # DONT ACCEPT DATA.

                CCS     RTSTDEX
                TCF     33PASTE -1

ENDRTST         CAF     ZERO            # ENDTEST.
                TS      RSAMPDT
                TC      NEWMODEX
                OCT     0
                TC      EJFREE

RV33            OCT     3300

#          AGS INITIALIZATION PROGRAM.

AGSINIT         CCS     AGSWORD         # ZERO IF AGS NOT NOW BEING INITIALIZED.
                TC      ALM/END         # DO IT LATER.

                CA      TIME1
                AD      12SECS
                TS      L
                TC      SENDIT

                INHINT                  # T1 WILL OVERFLOW, DELAY FOR 12 SECS
                CA      12SECS
                TS      AGSWORD
                TC      WAITLIST
                2CADR   AGSJOB
                TC      ENDOFJOB

AGSJOB          CAF     PRIO30          # ENTER AGSINIT JOB VIA EXEC
                TC      NOVAC
                2CADR   SENDIT

                TC      TASKOVER

SENDIT          INHINT
                CAF     LAGSLIST        # SWITCH TO SPECIAL DOWNLIST FOR 10 SECS.
                XCH     DNLSTADR
                TS      AGSWORD         # TO SHOW INITIALIZATION IN PROGRESS.

                CAF     10SECS
                TC      WAITLIST
                2CADR   AGSINIT2

                TCF     ENDOFJOB

AGSINIT2        CAF     ZERO            # END OF INITIALIZATION.
                XCH     AGSWORD
                TS      DNLSTADR        # REVERT TO ORIGINAL DOWNLIST.
                TCF     TASKOVER

10SECS          DEC     1000
12SECS          DEC     1200
LAGSLIST        GENADR  AGSLIST

#          VB 43  IMU ATTITUDE ERROR METER LOADER.

IMUATTCK        TC      TESTXACT
                CS      OCT50K          # REMOVE COARSE AND ECTR ENABLE.
                EXTEND
                WAND    12

                TC      GRABWAIT
                CAF     VNLODCDU
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      TERMEXTV
                TC      +1
                CAF     V43K            # REDISPLAY OUR VERB.
                TC      NVSBWAIT
                CAF     BIT6            # ENABLE ERROR COUNTER.
                EXTEND
                WOR     12
                CAF     TWO
                INHINT
                TC      WAITLIST        # PUT OUT COMMAND IN .32 SECS.
                2CADR   ATTCK2

                TCF     TERMEXTV        # FREES DISPLAY.

ATTCK2          CAF     TWO             # PUT OUT ALL COMMANDS - CDU WILL DO LIMIT
                TS      Q               # INCASE OF EXCESS DATA.
                INDEX   A
                CA      THETAD
                EXTEND
                MP      BIT13           # SHIFT RIGHT 2.
                INDEX   Q
                TS      CDUXCMD
                CCS     Q
                TCF     ATTCK2 +1

                CAF     OCT70K
                EXTEND
                WOR     14
                TCF     TASKOVER

OCT50K          OCT     50
V43K            OCT     4300
OCT70K          OCT     70000

LOTSACQ         TC      TESTXACT
                TC      BANKCALL
                CADR    LOTSACQB

LOTSTEST        TC      TESTXACT
                TC      BANKCALL
                CADR    LOTTESTB

LOTSSTOW        TC      TESTXACT
                TC      BANKCALL
                CADR    LOTSTOWB

#          PROGRAM TO SCAN CHANNELS 30 - 32 FOR CHANGES IN SELECTED INBITS. CALLED BY SPECIAL VERB.

                EBANK=  MSGCNT

SETUPMSG        CAF     BIT1            # BEGIN SCAN.
                INHINT
                TC      WAITLIST
                2CADR   MSGSCAN +2

                TC      ENDOFJOB

MSGSCAN         TC      FIXDELAY
                DEC     50

                CAF     TWO             # SCAN ALL 3 CHANNELS FOR CHANGES.
                TS      MSGCNT
                INDEX   A
                CA      LAST30          # OLD VALUE OF INBITS.
                EXTEND
                INDEX   MSGCNT
                RXOR    30
                INDEX   MSGCNT
                MASK    30MSGMSK
                EXTEND
                BZF     NOMSG

                TS      Q               # SAVE DIFFERENCE.
                INDEX   MSGCNT
                LXCH    LAST30          # UPDATE OLD VALUE.
                EXTEND
                RXOR    L
                INDEX   MSGCNT
                TS      LAST30

                COM
                XCH     Q
                MASK    Q               # SEE IF ANY OF CHANGED BITS JUST ON.
                EXTEND
                BZF     NOMSG           # NO MESSAGE IF SO.

                MASK    BIT15
                EXTEND
                BZF     NOTRHC

                CA      MSGCNT
                MASK    BIT1
                EXTEND
                BZF     NOTRHC

                CAF     SIX

                TC      WAITLIST
                EBANK=  PCOM
                2CADR   RHCNTRL

                CAF     PRIO20          # INITIATE MONITOR.
                TC      NOVAC
                2CADR   RHCMON
                TCF     NOMSG

NOTRHC          CAF     OKT30
                AD      MSGCNT
                TS      RUPTREG2

                CS      Q
                TC      VMESSAGE

NOMSG           CCS     MSGCNT
                TCF     MSGSCAN +3
                TCF     MSGSCAN

30MSGMSK        OCT     1037
                OCT     77777
                OCT     1777

OKT30           OCT     30
DESCBITS        TC      MESSAGE         # DESCENT BITS COME HERE IN A.
                OCT     16
                TC      RESUME

RHCMON          TC      GRABWAIT        # FIRE UP DSKY MONITOR.
                CAF     RHCMONVN
                TC      NVSBWAIT
                TC      EJFREE

RHCMONVN        OCT     1645

#          MESSAGE DISPLAY - 3 COMPONENT OCTAL.

MESSAGE         TS      RUPTREG2        # NEW CHANNEL CONTENTS ARRIVE IN A.
                INDEX   Q               # CHANNEL NUMBER IN OCTAL AT CALLER +1.
                CAF     0
                INCR    Q
                XCH     RUPTREG2

VMESSAGE        TS      RUPTREG1        # FOR VARIABLE CHANNEL.
                EXTEND
                QXCH    RUPTREG3
                CAF     PRIO27          # FIRE UP SPECIAL JOB.
                TC      NOVAC
                2CADR   DOMSG

                DXCH    RUPTREG1        # NEW CONTENTS TO MPAC - CHANNEL NUMBER TO
                INDEX   LOCCTR          # MPAC +1.
                DXCH    MPAC
                CA      TIME1
                INDEX   LOCCTR
                TS      MPAC +2
                TC      RUPTREG3

DOMSG           TC      GRABWAIT
                EXTEND
                DCA     MPAC
                DXCH    DSPTEM1
                CA      MPAC +2
                TS      DSPTEM1 +2
                CAF     MSGVN
                TC      NVSUB
                TCF     MSGBUSY
                TC      EJFREE

MSGBUSY         CAF     +2
                TC      NVSUBUSY
                CADR    DOMSG +1

MSGVN           OCT     0535

#          ROUTINE FOR AURORA ONLY TO ASK OPERATOR IF RR LOCK ON REQUESTED.

AURLOKON        TC      MAKECADR
                TS      DESRET
                CAF     RV33            # ASSUMES DSKY GRABBED.
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     +3              # ON TERM.
                CAF     LOKONFLG
                TCF     +2
                CAF     ZERO
                INHINT
                XCH     STATE
                MASK    -LOKONFG
                ADS     STATE

                MASK    LOKONFLG        # IF NO LOCK-ON CALLED FOR, SET BIT15 OF
                CCS     A               # RADMODES TO INDICATE THAT ARBITRARILY-
                TCF     +3              # LONG DESIGNATION IS WANTED (TO BE

                CAF     BIT15           # TERMINATED BY FRESH START).
                ADS     RADMODES
                RELINT
                CA      DESRET
                TCF     BANKJUMP

-LOKONFG        OCT     -20

#          PROGRAM TO RUN DISPLAY INERTIAL DATA TEST.

DISINDT         CAF     FLVELVN         # ASK FOR FORWARD, LATERAL VELOCITY.
                TC      NVSBWAIT
                TC      ENDIDLE
                TCF     ENDDISIN
                TCF     +1
                CAF     ALT,R,VN        # ASK FOR INITIAL AND FINIAL ALTITUDES AND
                TC      NVSBWAIT        # ALTITUDE RATE.
                TC      ENDIDLE
                TCF     ENDDISIN
                TCF     +1

                INHINT
                CS      ONE
                TS      DIDFLG

                EXTEND
                DCA     ALT             # SO FOLLOWING MONITOR WORKS.
                DXCH    ALTSAVE

                CAF     ONE
                TC      WAITLIST
                2CADR   DISINLUP +2

                TCF     EJFREE

ENDDISIN        TC      FREEDSP
 +1             TC      NEWMODEX
                OCT     0

                TC      ENDOFJOB

#          WATCH ALTSAVE FOR END OF PROBLEM.

DISINLUP        TC      FIXDELAY
                DEC     50

 +2             EXTEND
                DCA     FINALT
                DXCH    ITEMP1
                EXTEND
                DCS     ALTSAVE         # LATEST ALTITUDE.
                DAS     ITEMP1

                CCS     ITEMP1
                TCF     +DIF
                TCF     +2
                TCF     -DIF

                CCS     ITEMP2
                TCF     +DIF
                TCF     +2
                TCF     -DIF

DISINDUN        CAF     ZERO
                TS      ALTRATE
                DXCH    FINALT
                DXCH    ALT
                CAF     PRIO20
                TC      NOVAC
                2CADR   ENDDISIN +1

                TCF     TASKOVER

+DIF            CA      ALTRATE
                EXTEND
                BZMF    DISINDUN
                TCF     DISINLUP

-DIF            CS      ALTRATE
                TCF     +DIF +1

FLVELVN         OCT     2444
ALT,R,VN        OCT     2564

LOTSTRT         INHINT
                CAF     ONE
                TC      POSTJUMP
                CADR    SLAP2

ENDEXTVS        EQUALS
