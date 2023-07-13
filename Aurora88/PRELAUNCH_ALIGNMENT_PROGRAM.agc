### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PRELAUNCH_ALIGNMENT_PROGRAM.agc
## Purpose:     A section of Aurora 88.
##              It is part of the reconstructed source code for the final
##              release of the Lunar Module system test software. No original
##              listings of this program are available; instead, this file
##              was created via disassembly of dumps of Aurora 88 core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-07-12 MAS  Created via disassembly.

                SETLOC  ENDPINS3
                EBANK=  XSM

2STODP1S        CCS     A
                AD      ONE
                TCF     2TO1OUT
                AD      ONE
                AD      ONE
                OVSK
                TCF     +4
                ZL
                CS      BIT14
                TC      Q
                COM
2TO1OUT         EXTEND
                MP      BIT14
                TC      Q

DP1STO2S        DDOUBL
                CCS     A
                AD      ONE
                TCF     +2
                COM
                TS      L
                TC      Q
                INDEX   A
                CAF     LIMITS
                ADS     L
                TC      Q

LODLATAZ        EXTEND
                QXCH    QSAVED
                CAF     V06N61E
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TC      LODLATAZ +2
                TC      QSAVED
                TC      LODLATAZ +2

V06N61E         OCT     00661

                TC      GRABWAIT
STARTPL         TC      NEWMODEX
                OCT     01
                EXTEND
                DCA     AZIMUTH
                TC      DP1STO2S
                TS      DSPTEM1

                CAF     ZERO
                TS      DSPTEM1 +1
                TC      LODLATAZ

                CA      DSPTEM1
                TC      2STODP1S
                DXCH    AZIMUTH
                EXTEND
                DCA     AZIMUTH
                DXCH    AZIMUTH1
                DXCH    LATITUD1
                TC      DP1STO2S
                TS      DSPTEM1
                DXCH    LATITUDE
                DDOUBL
                DDOUBL
                TS      DSPTEM1 +1
                TC      LODLATAZ

                CA      DSPTEM1
                TC      2STODP1S
                DXCH    LATITUD1
                CA      DSPTEM1 +1
                EXTEND
                MP      BIT13
                DXCH    LATITUDE
                TC      FREEDSP

                EXTEND
                DCA     LATITUD1
                TC      DP1STO2S
                TS      MPAC
                EXTEND
                DCA     AZIMUTH1
                TC      DP1STO2S
                EXTEND
                MSU     MPAC
                TC      DP1STO2S +1
                TS      THETAD
                CAF     BIT14
                TS      THETAD +1
                CAF     ZERO
                TS      THETAD +2

                TC      BANKCALL
                CADR    IMUZERO
                TC      BANKCALL
                CADR    IMUSTALL
                TC      PRELEXIT

                TC      PHASCHNG
                OCT     00100

REDO0.1         TC      BANKCALL
                CADR    IMUCOARS
                TC      BANKCALL
                CADR    IMUSTALL
                TC      PRELEXIT

                TC      PHASCHNG
                OCT     00200

REDO0.2         TC      BANKCALL
                CADR    IMUFINE

                CAF     DEC49
ZEROS1          TS      MPAC
                CAF     ZERO
                INDEX   MPAC
                TS      XSM1
                CCS     MPAC
                TC      ZEROS1

                EXTEND
                DCA     TIME2
                DXCH    PREVTIME
                TC      BANKCALL
                CADR    IMUSTALL
                TC      PRELEXIT

                TC      NEWMODEX
                OCT     05

                CAF     SIXHNDRD        # INITIALIZE FOR 5 MIN VERTICAL
                TS      GYROCSW

                TC      BANKCALL
                CADR    PIPUSE

                CAF     NINE
                TS      PRELTEMP
                TC      INTPRET
                DLOAD   SIN
                        LATITUDE
                DCOMP   DMP
                        GOMEGA
                STODL   ERVECT1 +4
                        LATITUDE
                COS     DMP
                        GOMEGA
                STODL   ERVECT1
                        AZIMUTH1
                PUSH    COS
                STORE   XSM1
                STODL   XSM1 +8D
                SIN
                STORE   XSM1 +2
                DCOMP
                STODL   XSM1 +6
                        GEOCONS5
                STORE   XSM1 +16D
                EXIT

                INHINT
                CAF     PRELDT
                TC      WAITLIST
                2CADR   PRELALTS

                TC      ENDOFJOB

DEC49           DEC     49
SIXHNDRD        DEC     600

#	PRELAUNCH WAITLIST TASK - EXECUTED EVERY .5 SEC. IN LOOP.

PRELALTS        CAF     ZERO
                XCH     PIPAX
                TS      DELVX
                CAF     ZERO
                XCH     PIPAY
                TS      DELVX +2
                CAF     ZERO
                XCH     PIPAZ
                TS      DELVX +4
                CAF     ZERO
                TS      DELVX +1
                TS      DELVX +3
                TS      DELVX +5

                TC      PHASCHNG
                OCT     00300

                EXTEND
                DCA     TIME2
                DXCH    PIPTIME

REPRELAL        CAF     PRELDT          # SELF-SUSTAINING WAITLIST CALL
                TC      WAITLIST
                2CADR   PRELALTS

                CAF     PRIO20
                TC      FINDVAC
                2CADR   PRAWAKE

                TC      TASKOVER        # RESUME

REDO0.4         TC      PRLRSTOR
                TC      RE0.4

PRAWAKE         TC      PRLSAVE
                TC      PHASCHNG
                OCT     00400

RE0.4           TC      INTPRET
                VLOAD   VXM
                        DELVX
                        XSM1
                VSL1    VSU
                        FILDELV
                VXSC    VAD
                        GEOCONS1
                        FILDELV
                STORE   FILDELV
                VAD
                        THETAN
                STORE   THETAN
                EXIT

                TC      CHECKMM
                OCT     5
                TC      TJL

NOGYROCM        CCS     GYROCSW         # COUNT DOWN FOR 5 MIN OF VERTICAL ERECT.
                TC      MORE            #  IF MORE TO COME.
                TC      NEWMODEX        # IF NOT, GO INTO GYROCOMP. (MM 02)
                OCT     2

MORE            TS      GYROCSW

                TC      INTPRET
                VLOAD   VXSC
                        THETAN
                        GEOCONS2
                VAD     VXSC
                        FILDELV
                        POINT2
                VXV     VAD
                        PRUNITZ
                        ERCOMP1
                STORE   ERCOMP1
                GOTO
                        ENDOFPR

TJL             TC      INTPRET
                VLOAD   MXV
                        FILDELV
                        GEOCONS3
                VAD
                        ERCOMP1
                STODL   ERCOMP1
                        THETAN +2
                DMP     DAD
                        GEOCONS4
                        ERCOMP1
                STORE   ERCOMP1
ENDOFPR         EXIT

                CCS     PRELTEMP
                TC      JUMPY

                CCS     LGYRO           # IF BUSY GO AROUND LOOP AGAIN
                TCF     JUMPY +1        # WAIT TIL NEXT TIME.  PRELTEM = 0 STILL.

                TC      CHECKMM
                OCT     03
                TC      EARTHRAT -1

                CAF     ZERO
                TS      ERCOMP1
                TS      ERCOMP1 +1
                TS      ERCOMP1 +2
                TS      ERCOMP1 +3
                TS      ERCOMP1 +4
                TS      ERCOMP1 +5

                TC      INTPRET
EARTHRAT        DLOAD   DSU
                        PIPTIME
                        PREVTIME
                BPL     DAD
                        ERTHR
                        NEARONE
ERTHR           SL      VXSC
                        6D
                        ERVECT1
                VAD     MXV
                        ERCOMP1
                        XSM1
                VSL1    VAD
                        GYROANG
                STOVL   GYROANG
                        SCHZEROS
                STODL   ERCOMP1
                        AZIMUTH
                DSU     BZE
                        AZIMUTH1
                        ERTHROUT
                PUSH    DSU
                        2DEGS
                BPL     DLOAD
                        TOOPOS
                        0D
                DAD     BMN
                        2DEGS
                        TOONEG
                GOTO
                        JUSTRITE

TOOPOS          DLOAD
                        2DEGS
                STORE   0D
                GOTO
                        JUSTRITE

TOONEG          DLOAD   DCOMP
                        2DEGS
                STORE   0D

JUSTRITE        DLOAD   DAD
                        0D
                        AZERR
                STODL   AZERR
                DAD
                        AZIMUTH1
                STORE   AZIMUTH1
                PUSH    COS
                STORE   XSM1
                STODL   XSM1 +8D
                SIN
                STORE   XSM1 +2
                DCOMP
                STORE   XSM1 +6
ERTHROUT        EXIT

                EXTEND
                DCA     PIPTIME
                DXCH    PREVTIME

                TC      PHASCHNG
                OCT     00500

                CAF     NINE
                TS      PRELTEMP

SPITGYRO        CAF     LGYROANG
                TC      BANKCALL
                CADR    IMUPULSE
                TC      BANKCALL
                CADR    IMUSTALL
                TC      PRELEXIT
                TCF     ENDOFJOB

JUMPY           TS      PRELTEMP
                TC      PHASCHNG
                OCT     00500
                TC      ENDOFJOB

LGYROANG        ECADR   GYROANG

GEOCONS3        2DEC    0
                2DEC    .025
                2DEC    0
                2DEC    -.025
                2DEC    0
                2DEC    0
                2DEC    -.999999999
SCHZEROS        2DEC    0
PRUNITZ         2DEC    0
                2DEC    0
GEOCONS5        2DEC    .5

GEOCONS4        2DEC    .00003
POINT2          2DEC    .2
GEOCONS2        2DEC    .005
GOMEGA          2DEC    0.97356192          # EARTH RATE IN IRIG PULSES/CS
GEOCONS1        2DEC    .1
2DEGS           2DEC    .005555555
DEC43           DEC     43
PRELDT          DEC     .5 E2               # HALF SECOND PRELAUNCH CYCLE

PRELGO          INDEX   PHASE0
                TC      +0
                TC      REPL1
                TC      REPL2
                TC      REPL3
                TC      REPL4
                TC      REPL5

REPL1           CAF     PRIO21
                TC      FINDVAC
                2CADR   REDO0.1

                TC      SWRETURN

REPL2           CAF     PRIO21
                TC      FINDVAC
                2CADR   REDO0.2

                TC      SWRETURN

REPL3           CAF     ONE
                TC      WAITLIST
                2CADR   REPRELAL

                TC      SWRETURN

REPL4           CAF     PRIO21
                TC      FINDVAC
                2CADR   REDO0.4

REPL5           CAF     LGYROANG
                TS      EBANK
                CS      TIME1
                AD      PIPTIME +1
                EXTEND
                BZMF    +2
                AD      NEGMAX
                AD      PRELDT
                EXTEND
                BZMF    RIGHTGTS
WTGTSMPL        TC      WAITLIST
                2CADR   PRELALTS

                TC      SWRETURN

RIGHTGTS        CAF     ONE
                TC      WAITLIST
                2CADR   PRELALTS

                TC      SWRETURN

#	PRELAUNCH TERMINATION.

PRELEXIT        TC      BANKCALL
                CADR    PIPFREE
                INHINT
                CS      IMUSEFLG
                MASK    STATE
                TS      STATE
                TC      NEWMODEX
                OCT     0
                TC      ENDOFJOB

PRLSAVE         CAF     DEC43           # SAVE CURRENT VARIABLES FOR RESTARTS
                TS      MPAC
                INDEX   MPAC
                CAF     XSM1
                INDEX   MPAC
                TS      PTEMP
                CCS     MPAC
                TCF     PRLSAVE +1
                TC      Q

PRLRSTOR        CAF     DEC43           # RESTORE OLD VALUES OF VARIABLES
                TS      MPAC
                INDEX   MPAC
                CA      PTEMP
                INDEX   MPAC
                TS      XSM1
                CCS     MPAC
                TCF     PRLRSTOR +1
                TC      Q


## MAS 2023: The following chunks of code (down to ENDPRELS) were added as patches
## between Aurora 85 and Aurora 88. They were placed here at the end of the bank
## so as to not change addresses of existing symbols.

TESTCAL1        TS      CALCDIR
                EXTEND                  # THIS ROUTINE LOOKS AT THE SIZE OF THE
                BZMF    NEGSIZ          # ENTRY MADE BY THE OPERATOR, IF HE DID NO
SIZLOOK         MASK    NEG3            # T ENTER TEST NO THAT IS W/I PERMISSIBLE
                EXTEND                  # RANGE- HE WILL BE ASKED TO LOAD AGAIN.
                BZF     GUDENTRY        #   THIS IS CONSIDERED NECESSARY BECAUSE
                TC      POSTJUMP        # OF FOLLOWING INDEXED TC WHICH COULD
                CADR    TESTCALL
NEGSIZ          COM                     # SEND THE COMPUTER OFF INTO THE BOONDOCKS
                TC      SIZLOOK         # TO PLAY WITH ITSELF IF THE OPERATOR
GUDENTRY        CA      CALCDIR         # MAKES ABAD ENTRY******
                AD      FOUR
                TC      POSTJUMP
                CADR    GUDENT1



STOPTST1        CAF     ZERO
                TS      LGYRO           # **** RELEASE GYROS FOR OTHERS USAGE*****
                TC      POSTJUMP
                CADR    ALARMS
                TC      POSTJUMP
                CADR    ENDTEST1



ALFLT2          VLOAD   VXM
                        FILDELVX
                        GEOMTRX
                DLOAD   DCOMP
                        MPAC +3
                STODL   DPIPAY
                        MPAC +5
                STORE   DPIPAZ

                SETPD   AXT,1           # MEASUREMENT INCORPORATION ROUTINES.
                        0
                        8D
                GOTO
                        DELMLP



SHOWSUM2        TS      SMODE           # PUT SELF-CHECK TO SLEEP
                CA      SELFADR1        # INITIALIZE SELFRET TO GO TO SELFCHK.
                TS      SELFRET
                TC      POSTJUMP
                CADR    SHOWSUM3

SELFADR1        GENADR  SELFCHK         # SELFCHK RETURN ADDRESS.

ENDPRELS        EQUALS
