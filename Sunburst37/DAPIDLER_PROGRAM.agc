### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     DAPIDLER_PROGRAM.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-21 HG   Transcribed
##		 2016-10-31 RSB	 Typos.
##		 2016-11-01 RSB	 More typos.
##		 2016-12-05 RSB	 Comment-proofing with octopus/ProoferComments
##				 completed, changes made.

## Page 487
# THE DAPIDLER PROGRAM IS STARTED BY FRESH START AND RESTART.             THE DAPIDLER PROGRAM IS DONE 10 TIMES
# PER SECOND UNTIL THE ASTRONAUT DESIRES THE DAP TO WAKE UP, AND THE IMU AND CDUS ARE READY FOR USE BY THE DAP.
# THE NECESSARY INITIALIZATION OF THE DAP IS DONE BY THE DAPIDLER PROGRAM.
# ADDITIONAL WORK MUST BE DONE ON DAPIDLER IN THE FUTURE.



                BANK            16
                EBANK=          DT

CHEKBITS        CAF             BIT6
                MASK            IMODES30
                CCS             A
                TCF             MOREIDLE

                CAF             BIT4
                AD              BIT5
                EXTEND
                RAND            12
                CCS             A
                TCF             MOREIDLE

                CAF             BIT10                   # BIT10 OF 30 IS PNGCS CONTROL OF S/C
                EXTEND
                RAND            30                      # BITS IN 30 ARE INVERTED
                CCS             A
                TCF             MOREIDLE

                EXTEND
                READ            31                      # IF BOTH    BIT13 AND BIT14 ARE ONE
                COM                                     # THEN MODE SELECT SWITCH IS IN OFF
                MASK            BIT13-14                # POSITION.
                EXTEND
                BZF             MOREIDLE                # HENCE DAP SHOULD BE OFF.

                CAF             GODAPGO
                MASK            DAPBOOLS
                EXTEND
                BZF             MOREIDLE

                RETURN

## Page 488
# DAPIDLER ENTRY.

DAPIDLER        LXCH            BANKRUPT                # INTERRUPT LEAD INS (CONTINUED)
# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************
                TCF             T5IDLERI
                TC              CCSHOLE

DAPIDLEI        CAF             DATAGOOD
# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

                MASK            DAPBOOLS
                EXTEND
                BZF             TESTMASS
                TC              CHEKBITS                # CHECK TO SEE IF LM DAP IS TO GO ON.

STARTDAP        TC              IBNKCALL
                FCADR           STOPRATE
                CAF             ZERO                    # ********** INITIALIZE: **********
                TS              TIME6                   # T6RUPT CLOCK
                TS              TP                      # RATE DERIVATION DTS
                TS              TQR
                TS              JETRATEQ                # Q,R JETRATES USED IN Q,R-AXES BEFORE
                TS              JETRATER                # BEING SET, GIVEN TQR ZERO.
                TS              LASTPER                 # ATTITUDE ERROR RECORDS FOR EIGHTBALL.
                TS              LASTQER
                TS              LASTRER
                TS              PERROR
                TS              QERROR
                TS              RERROR
                TS              OMEGAP                  # RATES IN BODY (PILOT) COORDINATES.
                TS              OMEGAQ
                TS              OMEGAR
                TS              T6NEXT                  # JTLST VARIABLES.
                TS              T6NEXT          +1
                TS              ADDT6JTS
                TS              ADDTLT6
                TS              DELAYCTR                # MINIMUM IMPULSE RHC MODE COUNTER.
                TS              ALPHAQ                  # DESCENT ACCELERATION ESTIMATES.
                TS              ALPHAR
                TS              DISPLACT                # EIGHTBALL ROUTINE SWITCH.
                TS              (1-K)                   # K=1 FIRST PASS.

# START CODING FOR MODULE 3 REMAKE, AUGUST 1967***START CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

INSRT16B        TCF             PROTCTOR                # RESTART PROTECT ENGINE-ON AND GIMBAL
							#   DRIVE BITS.
# **END CODING FOR MODULE 3 REMAKE, AUGUST 1967*****END CODING FOR MODULE 3 REMAKE, AUGUST 1967*******************

                CAF             BIT2                    # CHECK FOR STAGE
                EXTEND

## Page 489
                RAND            30
                EXTEND
                BZF             +9D                     # (BRANCH FOR ASCENT.)

                CAF             ZERO                    # 1/ACCS BRANCHING VALUE IS ZERO FOR
                TS              -.06R/S2                # DESCENT LM DAP.

                EXTEND                                  # SET DESCENT URGENCY LIMIT = 1.5 SECONDS
                DCA             URGLMDWN                # AS BOUND TO USE MAXIMUM JETS.
                DXCH            URGLMS
                EXTEND                                  # RATE ERROR LIMIT W/MIN JETS: 1.4 DEG/SEC
                DCA             RCOMDOWN                # RATE ERROR DB    W/MIN JETS: 0.4 DEG/SEC
                TCF             +8D

 +9D            CAF             ACCLIMIT                # 1/ACCS BRANCHING VALUE MUST BE
                TS              -.06R/S2                # 0.06 RADIANS/SECOND(2) FOR ASCENT DAP.

                EXTEND                                  # SET ASCENT URGENCY LIMIT = .25 SECONDS
                DCA             URGLMUP                 # AS BOUND TO USE MAXIMUM JETS.
                DXCH            URGLMS
                EXTEND                                  # RATE ERROR LIMIT W/MIN JETS: 2.0 DEG/SEC
                DCA             RCOMNDUP                # RATE ERROR DB    W/MIN JETS: 1.0 DEG/SEC
 +8D            DXCH            -2JETLIM

 # SET UP "OLD" MEASURED CDU ANGLES:

                EXTEND
                DCA             CDUX                    # OLDXFORP AND OLDYFORP
                DXCH            OLDXFORP
                EXTEND
                DCA             CDUY                    # OLDYFORQ AND OLDZFORQ
                DXCH            OLDYFORQ

                CAF             0.62170
                TS              4JETTORK
                CAF             .68387                  # 2200 FT LBS. SCALED AT 2(10) X PI.
                TS              JETTORK4                # QR AXIS JET TORQUE FOR 4 JETS.
# SET UP THE TORQUE VECTOR RECONSTRUCTION SWITCHES:

                EXTEND
                DCA             VISNORMQ                # PJUMPADR AND QJUMPADR
                DXCH            PJUMPADR

# SET SWITCH TO SKIP Q,R-TJETLAW SQUARE ROOT:

# SET UP INITIAL VALUES FOR WFORP AND WFORQR:

                EXTEND                                  # SCALED AT 16:
                DCA             WFORPQRK                # WFORP  = K/DT = K/.1  = 1/.1  = 0.625
                DXCH            WFORP                   # WFORQR = K/DT = K/.15 = 1/.15 = 0.41667

## Page 490
# SET UP WAITLIST CALL TO RESET WFORP AND WFORQR:

                CAF             180MS
                TC              WAITLIST
                EBANK=          WFORQR
                2CADR           WCHANGER

                EXTEND                                  # SET UP P-AXIS TO GO TO DUMMYFIL
                DCA             DF2CADR
                DXCH            PFILTADR

                EXTEND
                DCA             PAXADIDL
                DXCH            T5ADR
SETTIME5        CAF             MS100
                TS              TIME5
                TCF             RESUME
                EBANK=          DT
IDLERADR        2CADR           DAPIDLER
MOREIDLE        CS              PAXADIDL                # DAP SHOULD BE OFF
                AD              T5ADR
                EXTEND
                BZF             SHUTDOWN                # CHECK TO SEE WHETHER THIS IS FROM P-AXIS

SETT5ADR        EXTEND
                DCA             IDLERADR
                DXCH            T5ADR
                TCF             SETTIME5

SHUTDOWN        CAF             ZERO                    # COMMAND JETS OFF
                EXTEND
                WRITE           5
                EXTEND
                WRITE           6

                CS              BGIM23                  # TURN TRIM GIMBAL OFF
                EXTEND
                WAND            12

                TCF             SETT5ADR
TESTMASS        CAF             MASSGOOD
                MASK            DAPBOOLS
                EXTEND
                BZF             MOREIDLE

                CAF             PRIO34
                TC              NOVAC
                EBANK=          DT
                2BCADR          1/ACCS

## Page 491
                TCF             SETT5ADR
BGIM23          OCTAL           07400
.707P           DEC             .70711                  # SQUARE ROOT OF 1/2
                EBANK=          OMEGAP
PAXADIDL        2CADR           PAXIS

                EBANK=          ALPHAQ
DF2CADR         2CADR           DUMMYFIL

MS100           OCTAL           37766
0.00167         DEC             0.00167
0.62170         DEC             0.62170
.68387          DEC             0.68387
0.31250         DEC             0.31250

DELTADOT        DEC             0.07111                 # 0.2 DEG/SEC SCALED AT PI/64
.5ACCMIN        DEC             0.30680
DBMNMP          DEC             0.00167                 # .3 DEGREES SCALED AT PI RADIANS
# TORQUE AND WEIGHTING CONSTANTS:

180MS           DEC             18                      # 180 MS WAITLIST DT.
.075DEC         DEC             0.075                   # 100 MS JET PULSE TORQUE TERM WITH K = .5
VISNORMQ        GENADR          CHKVISFZ                # D.P. GENADR FOR INITIALIZATION OF THE
                GENADR          NORMALQ                 # TORQUE VECTOR RECONSTRUCTION SWITCHES.
10AT16          DEC             0.625                   # INITIAL VALUE FOR WFORP.
6.6AT16         DEC             0.41667                 # INITIAL VALUE FOR WFORQR.
WFORPQRK        EQUALS          10AT16                  # D.P. NAME FOR BOTH CONSTANTS



RCOMDOWN        OCTAL           77001                   # -1.4 DEG/SEC SCALED AT PI/4 RADIANS/SEC.
                OCTAL           77555                   # -0.4 DEG/SEC SCALED AT PI/4 RADIANS/SEC.
RCOMNDUP        OCTAL           76447                   # -2.0 DEG/SEC SCALED AT PI/4 RADIANS/SEC.
                OCTAL           77223                   # -1.0 DEG/SEC SCALED AT PI/4 RADIANS/SEC.
URGLMDWN        DEC             -.00293                 # -1.5 SECONDS SCALED AT 2(+9).
                DEC             -.09375                 # -1.5 SECONDS SCALED AT 2(+4).
URGLMUP         DEC             -0.25           B-9     # -0.25 SECONDS SCALED AT 2(+9).
                DEC             -0.25           B-4     # -0.25 SECONDS SCALED AT 2(+4).
ACCLIMIT        DEC             -0.03820                # -.06 RADIANS/SECOND(2) SCALED AT PI/2.
