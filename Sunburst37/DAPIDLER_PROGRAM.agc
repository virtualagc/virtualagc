### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    DAPIDLER_PROGRAM.agc
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
## Reference:   pp. 463-467
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-30 HG   Transcribed
##              2017-06-03 HG   Add missing constant DGBF                
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 463
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

## Page 464
# DAPIDLER ENTRY.

DAPIDLER        LXCH            BANKRUPT                # INTERRUPT LEAD INS (CONTINUED)
                EXTEND
                QXCH            QRUPT
                
                TC              CHEKBITS                # CHECK TO SEE IF LM DAP IS TO GO ON.

# THIS SUBROUTINE CALL PERFORMS THE FOLLOWING INITIALIZATION FUNCTIONS:
#         1. THE DESIRED RATE VECTOR IS ZEROED.
#         2. THE DELCDU VECTOR IS ZEROED.
#         3. THE DESIRED CDU REGISTERS ARE SET EQUAL TO THE CDU REGISTERS.

STARTDAP        TC              STOPRATE                # USE DAP INTERFACE SUBROUTINE

# THIS SUBROUTINE CALL PERFORMS THE FOLLOWING INITIALIZATION FUNCTIONS:
#          1. THE MINIMUM IMPULSE DEADBANDS ARE SET.
#          2. THE OFFSET ACCELERATION ESTIMATES ARE ZEROED.
#          3. THE RATE DERIVATION ACCELERATION TERMS ARE ZEROED.
#          4. THE NJ FLAGS ARE CLEARED.
#          5. THE URGENCY FUNCTION CORRECTION RATIOS ARE SET TO ONE.
                
                TC              IBNKCALL
                FCADR           ALLCOAST
                
                CAF             ZERO                    # ********** INITIALIZE: **********
                
                TS              TIME6                   # T6RUPT CLOCK
                TS              TP                      # RATE DERIVATION DTS
                TS              TQR
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
                TS              (1-K)/8
                
                TS              CH5MASK                 # TEMP. INIT. FOR FAILURE MONITOR
                
## Page 465                
                TS              CH6MASK
                
                
                
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

# SET UP INITIAL VALUES FOR WFORP AND WFORQR:

                EXTEND                                  # SCALED AT 16:
                DCA             WFORPQRK                # WFORP  = K/DT = K/.1  = 1/.1  = 0.625
                DXCH            WFORP                   # WFORQR = K/DT = K/.15 = 1/.15 = 0.41667

# SET UP WAITLIST CALL TO RESET WFORP AND WFORQR:

                CAF             180MS
                TC              WAITLIST
                EBANK=          WFORQR
                2CADR           WCHANGER

                CAF             ONE
                TC              WAITLIST
                EBANK=          IXX
                2CADR           IXXTASK
                
                CA              ONE
                TC              WAITLIST
                EBANK=          IYY
                2CADR           IYYTASK
                
                CA              ONE
                TC              WAITLIST
                EBANK=          IZZ
                2CADR           IZZTASK
                
## Page 466      
# THIS SECTION COMPUTES THE RATE OF CHANGE OF ACCELERATION DUE TO THE
#  ROTATION OF THE GIMBAL ENGINE. THE EQUATION IMPLEMENTED IN BOTH THE
#  Y-X PLANE AND THE Z-X PLANE IS -- D(ALPHA)/DT = T L/I * D(DELTA)/DT
#  WHERE ----
#             T = ENGINE THRUST COMMAND
#             L = PIVOT TO CG DISTANCE OF THE GIMBAL ENGINE
#             I = INERTIA
#             DELTA = GIMBAL ENGINE ANGLE MEASURED FROM THE X AXIS.

                CAF             DELTADOT                # 0.2 DEG/SEC SCALED AT PI/64
                EXTEND
                MP              L,PVT-CG                # GIMBAL PIVOT TO C.G. DISTANCE ,SCALE=8.
                EXTEND
                MP              THRSTCMD                # COMMANDED THRUST SCALED AT 2(14) =16384.        
                
                DXCH            ITEMP1
                EXTEND
                DCA             ITEMP1
                EXTEND
                DV              IZZ                     # AT 2(18)
                TS              ACCDOTR                 # AT PI/2(7)
                DXCH            ITEMP1
                EXTEND
                DV              IYY                     # AT 2(18)
                TS              ACCDOTQ                 # AT PI/2(7)
                
                EXTEND                                  # .3ACCDOTQ AT PI/2(8)
                MP              DGBF
                TS              KQ
                EXTEND
                SQUARE
                TS              KQ2                     # KQ(2)
                
                CAE             ACCDOTR                 # .3ACCDOTR AT PI/2(8)
                EXTEND
                MP              DGBF
                TS              KRDAP
                EXTEND
                
                SQUARE
                TS              KR2
                
                
                EXTEND                                  # SET UP P-AXIS TO GO TO DUMMYFIL
                DCA             DF2CADR
                DXCH            PFILTADR

                EXTEND
                DCA             PAXADIDL
                DXCH            T5ADR
SETTIME5        CAF             MS100
                TS              TIME5
                TCF             RESUME
                
## Page 467                
                EBANK=          DT
IDLERADR        2CADR           DAPIDLER                # DAP SHOULD BE OFF
MOREIDLE        EXTEND
                DCA             IDLERADR
                DXCH            T5ADR
                
                CAF             ZERO                    # COMMAND JETS OFF
                EXTEND
                WRITE           5
                EXTEND
                WRITE           6

                CS              BGIM23                  # TURN TRIM GIMBAL OFF
                EXTEND
                WAND            12

                TCF             SETTIME5
                
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
DGBF            DEC             0.6
.5ACCMIN        DEC             0.30680
DBMNMP          DEC             0.00167                 # .3 DEGREES SCALED AT PI RADIANS
# TORQUE AND WEIGHTING CONSTANTS:

180MS           DEC             18                      # 180 MS WAITLIST DT.
.075DEC         DEC             0.075                   # 100 MS JET PULSE TORQUE TERM WITH K = .5
VISNORMQ        GENADR          CHKVISFZ                # D.P. GENADR FOR INITIALIZATION OF THE
                GENADR          NORMALQ                 # TORQUE VECTOR RECONSTRUCTION SWITCHES.
                
10AT16          DEC             0.625                   # INITIAL VALUE FOR WFORP.
6.6AT16         DEC             0.41667                 # INITIAL VALUE FOR WFORQR.
WFORPQRK        EQUALS          10AT16                  # D.P. NAME FOR BOTH CONSTANTS.
