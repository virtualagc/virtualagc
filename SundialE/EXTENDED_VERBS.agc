### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    EXTENDED_VERBS.agc
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


                BANK    11
                EBANK=  OGC

# FAN-OUT

LST2FAN         TC      VBZERO          # VB40 ZERO (USED WITH NOUN 20 OR 40 ONLY)
                TC      VBCOARK         # VB41 COARSE ALIGN (USED WITH NOUN 20 OR
                                        #                                 40 ONLY)
                TC      IMUFINEK        # VB42 FINE ALIGN IMU
                TC      IMUATTCK        # VB43  LOAD IMU ATTITUDE ERROR METERS.
                TC      ALM/END         # ILLEGAL VERB.
                TC      ALM/END         # ILLEGAL VERB.
                TC      ALM/END         # ILLEGAL VERB.
                TC      DOCSITST        # VB47 PERFORM CSM & SATURN TEST
                TC      GOLOADLV        # VB50 PLEASE PERFORM
                TC      GOLOADLV        # VB51 PLEASE MARK
                TC      CKOPTVB         # VB52 OPTICAL VERIFICATION FOR PRELAUNCH
                TC      ALM/END         # ILLEGAL VERB.
                TC      TORQGYRS        # VB54 PULSE TORQUE GYROS
                TC      ALINTIME        # VB55 ALIGN TIME
                TC      GOSHOSUM        # VB56 PERFORM BANKSUM
                TC      SYSTEST         # VB57 PERFORM SYSTEM TEST
                TC      PRESTAND        # VB60 PREPARE FOR STANDBY
                TC      POSTAND         # VB61 RECOVER FROM STANDBY
                TC      SETUPMSG        # VB62 SCAM CSM INBITS
                TCF     +1
                TCF     ALM/END
                TCF     ALM/END
                TCF     +1
                TCF     ALM/END
                TCF     ALM/END
                TCF     ALM/END
                TCF     ALM/END
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
                TC      ALM/END         # RETURN HERE IF NOUN = OCDU(55)
                                        #         (NOT IN USE YET)

VBCOARK         TC      OP/INERT
                TC      IMUCOARK        # RETURN HERE IF NOUN = ICDU (20)
                TC      OPTCOARK        # RETURN HERE IF NOUN = OCDU (55)

# RETURNS TO L+1 IF IMU AND L+2 IF OPT.

OP/INERT        CS      BIT5            # OCT20
                AD      NOUNREG
                EXTEND
                BZF     XACT0Q          # IF = 20.

                INCR    Q
                AD      OPIMDIFF        # = -35 OCT.
                EXTEND
                BZF     XACT0Q

                TC      ALM/END         # ILLEGAL.

OPIMDIFF        OCT     -35

# KEYBOARD REQUEST TO ZERO IMU ENCODERS

IMUZEROK        TC      TESTXACT        # ZERO ENCODERS.
                TC      BANKCALL
                CADR    IMUZERO

                TC      BANKCALL        # STALL
                CADR    IMUSTALL
                TC      +1

                TC      ENDEXTVB

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

# TEMPORARY ROUTINE TO RUN THE OPTICS CDUS FROM THE KEYBOARD

OPTCOARK        CCS     SWSAMPLE        # SEE IF SWITCH AT COMPUTER
                TC      +5              # SWITCH AT COMPUTER
                TC      +1              # NOT ON COMPUTER
                TC      FALTON          # TURN ON OPERATOR ERR
                TC      ALARM           # AND ALARM
                OCT     00115

                CCS     OPTIND          # SEE IF OPTICS AVAILABLE
                TC      OPTC1           # IN USE
                TC      OPTC1           # IN USE
                TC      OPTC1           # IN USE

                TC      ALARM           # OPTICS RESERVED (OPTIND=-0)
                OCT     00117
                TC      ENDOFJOB

OPTC1           TC      GRABWAIT
                CAF     VNLDOCDU        # VERB-NOUN TO LOAD OPTICS CDUS
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      TERMEXTV
                TC      +1              # PROCEED

                CAF     OPTCOARV        # RE-DISPLAY OUR OWN VERB
                TC      NVSUB
                TC      PRENVBSY
                TC      FREEDSP

                CAF     ONE
                TS      OPTIND          # SET COARS WORKING

                TC      ENDEXTVB
                TC      ENDEXTVB

VNLDOCDU        OCT     02457
OPTCOARV        EQUALS  IMUCOARV        # DIFFERENT NOUNS.


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
                TS      MPAC    +2      # NEEDED FOR TP AGREE
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
                AD      QPLACE
                EXTEND
                BZMF    +3
                TC      FALTON
                TC      REDO
                INDEX   QPLACE
                CAF     TESTCADR
                TC      BANKJUMP

TESTCADR        CADR    ALM/END         # 0  ILLEGAL
                CADR    IMUTEST         # 1  GYRO DRIFT TEST
                CADR    IMUBACK         # 2 REPEAT OF IMUTEST
                CADR    SXTNBIMU        # 3  IMU ALIGNMENT TEST
                CADR    OPCHK           # 4  IMU CHECK
                CADR    GYRSFTST        # 5  GYRO TORQUING TEST
                CADR    STARTPL         # 6  GYROCOMPASS TEST
                CADR    GTSCPSS         # 7. OPTIMUM COMPASS
                CADR    SAMODCHK        # 10 SEMI-AUTOMATIC MODING CHECK
                CADR    SAUTOIFS        # 11 SEMI-AUTOMATIC INTERFACE TEST
                CADR    SXTANGCK        # 12 SXT ANGLE CHECK
                CADR    CTRLDISP        # 13 CONTROLS AND DISPLAYS TEST
                CADR    SUMERASE        # 14 ERASABLE SUM

                CADR    ZEROERAS
                CADR    ALM/END
                CADR    ALM/END
TESTNV          OCT     2101
LQPL            ECADR   QPLACE

GOSHOSUM        TC      POSTJUMP        # START ROUTINE TO DISPLAY SUM OF EACH
                CADR    SHOWSUM         # BANK ON DSKY

DOCSITST        TC      POSTJUMP
                CADR    CSISTART

#          CKOPTVB     VERB 52             DESCRIPTION
#              OPTICAL VERIFICATION FOR PRELAUNCH.
#              1. SCHEDULE OPTCHK, OPTICAL VERIFICATION SUBPROGRAM, WITH PRIORITY 17.

CKOPTVB         CS      TWO
                AD      MODREG          # I WONDER IF PRELAUNCH IS RUNNING
                EXTEND
                BZF     +2
                TC      XACTALM         # NOT RUNNING OPERATOR ERROR
                INHINT
                CAF     PRIO17          #  PRELAUNCH OPTICAL VERIFICATION
                TC      FINDVAC
                EBANK=  QPLACE
                2CADR   OPTCHK
                TC      ENDOFJOB


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
                CAF     BIT6            # ENABLE ERROR COUNTER.
                EXTEND
                WOR     12
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

ATTCK3          CAF     OCT70K
                EXTEND
                WOR     14
                TCF     TASKOVER

OCT50K          OCT     50
OCT70K          OCT     70000

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

                CAF     OKT30
                AD      MSGCNT
                TS      RUPTREG2

                CS      Q
                TC      VMESSAGE

NOMSG           CCS     MSGCNT
                TCF     MSGSCAN +3
                TCF     MSGSCAN

30MSGMSK        OCT     1077
                OCT     77777
                OCT     2077

OKT30           OCT     30

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


# VB 60 PREPARE FOR STANDBY OPERATION

# ROUTINE WRITTEN FOR TEST ROPES ONLY*** MUST BE UPDATED TO INCLUDE
#                                 FLIGHT REQUIREMENTS FOR FLIGHT OPERATION

                EBANK=  LST1

PRESTAND        INHINT                  # COMES HERE FROM LST2FAN
                CA      TIME1
                TS      TIMESAV         # THIS ROUTINE WILL LOOK AT TIME1 UNTIL
                CAF     OKT30           #  TIME1 IS INCREMENTED, THEN IT WILL
LONGER          TS      TIMAR           # SNATCH THE MISSION TIME REGS AND STORE
                CS      TIMESAV         # THEM IN TIMESAV FOR LATER ISE IN ARITH.
                AD      TIME1           # OPERATIONS WHICH SHOULD FIND THE
                EXTEND                  # STANDING DIFFERENCE BETWEEN THE SCALAR
                BZF     CHKTIME         # AND THE TIME1-TIME2S REGS.

                EXTEND
                DCA     TIME2           # READ AND STORE THE DP TIME AND GO
                DXCH    TIMESAV         # READ THE SCALAR USING THE EXISTING PROG
                TCF     CATCHFIN        # FINETIME.

CHKTIME         CCS     TIMAR           # MUST WATCH THE TIME SPENT IN INHINT OR
                TC      LONGER          # THE COPS MIGHT CATCH US.
                RELINT
                CCS     NEWJOB
                TC      CHANG1
                TC      LONGER -1       # GO BACK AND LOOK AGAIN

CATCHFIN        TC      FINETIME        # WILL READ CHANNELS 3 AND 4 AND RETURN
                DXCH    SCALSAV         # WITH 3 IN A AND 4 IN L..
                RELINT
                CS      BIT4
                MASK    IMODES30        # INHIBIT THE IMU FAIL LIGHT.
                AD      BIT4
                TS      IMODES30

                CAF     BIT4            # SET ALL CHAN 12 BITS EXCEPT C/A TO ZERO.
                EXTEND                  # THIS IS NECESSARY SO THAT THE GIMBALS DO
                WAND    12              # NOT DRIFT INTO GIMBALLOCK IF THE SYSTEM

                CAF     BIT4            # SHOULD BE IN OPERATE AT THE TIME STBY
                EXTEND                  # WAS STARTED.  THIS SECTION WILL MAKE
                WOR     12              # SURE THE IMU IS IN C/A.....

                CAF     BIT11           # WHEN BIT 11 IS PRESENT IN CHANNEL 13 THE
                EXTEND                  # DSKY PB. CAN THEN ENERGIZE THE STANDBY
                WOR     13              # RELAY IN THE CGC PWR SUPPLIES....
                TC      ENDOFJOB        # GO TO DUMMY JOB UNTIL YOU DIE...

#  VB 61 RECOVER FROM STANDBY OPERATION

# ROUTINE WRITTEN FOR TEST ROPES ONLY**** MUST BE UPDATED TO INCLUDE
#                 FLIGHT REQUIREMENTS FOR FLIGHT OPERATIONS SEQUENCES....

POSTAND         TC      FINETIME        # COMES HERE FROM LST2FAN
                DXCH    TIMAR           # READ THE SCALAR AND SEE IF IT OVERFLOW-
                RELINT                  # ED WHILE THE CGC WAS IN STBY, IF SO
                CAE     TIMAR           # THE OVERFLOW MUST BE ADDED OR IT WILL
                EXTEND                  # SEEM THAT THE REALATIVITY THEORY WORKS
                SU      SCALSAV         # BETTER THAN IT SHOULD...
                EXTEND
                BZMF    ADDTIME         # IF ITS NEG. IT MUST HAVE OV:FLWD..

                TC      INTPRET
                DLOAD   DSU             # IF IT DID NOT OV-FLW. FIND OUT HOW LONG
                        TIMAR           # THE CGC WAS IN STBY BY SUBTRACTING THE
                        SCALSAV         # SCALAR AT THE START OF STBY FROM THE
                SRR     RTB             # SCALAR AT THE END OF STBY AND THEN ADD
                        5               # THE DIFFERENCE TO THE TIME EXISTING
                        SGNAGREE        # WHEN THE SCALAR WAS READ AT STBY ENTRY**
                DAD
                        TIMESAV
                STORE   TIMAR
                EXIT

CORCTTIM        EXTEND
                DCA     TIMAR           # THIS IS THE CORRECTED TIME TO BE READ
                DXCH    TIME2           # INTO TIME1 AND TIME2 REGS. ADDR 24-25

                CS      BIT11
                EXTEND                  # DISABLE THE DSKY STBY PUSHBUTTON.
                WAND    13
                TC      ENDOFJOB

ADDTIME         EXTEND
                DCA     DPOSMAX         # IF THE SCALAR OVERFLOWED, FIND OUT HOW
                DXCH    TIMEDIFF        # MUCH TIME REMAINED WHEN READ THE FIRST
                TC      INTPRET         # TIME AND THEN ADD THE PRESENT READING-
                DLOAD   DSU             # WHICH WILL BE THE TOTAL TIME SPENT IN
                        TIMEDIFF        # STANDBY, TO WHICH THE TIME AT STBY
                        SCALSAV         # MAY BE ADDED TO FIND THE PRESENT TIME
                DAD     SRR             # CORRECT TO 10 MSEC..
                        TIMAR           # **** THE TIME IN STANDBY MODE MUST NOT
                        5               # EXCEED 23 HOURS IF TIME IS TO BE
                DAD                     # CORRECTLY COMPUTED BY THIS ROUTINE.*****
                        TIMESAV
                STORE   TIMAR
                EXIT
                TC      CORCTTIM

ENDEXTVS        EQUALS
