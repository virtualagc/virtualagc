### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PRELAUNCH_ALIGNMENT_PROGRAM.agc
## Purpose:     A section of Sundial E.
##              It is part of the reconstructed source code for the final
##              release of the Block II Command Module system test software. No
##              original listings of this program are available; instead, this
##              file was created via disassembly of dumps of Sundial core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-30 MAS  Created.
##              2023-07-12 MAS  Changed an unused constant to a TC GRABWAIT,
##                              and a WANGI reference to XSM1 +16D, based on
##                              disassembly of equivalent code in Aurora 88.

                BANK    15
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
                DCOMP   CLEAR
                        OPTUSE
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
                        DPPOSMAX
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
                TC      UPDATAZ 

                TC      INTPRET
                VLOAD
                        SCHZEROS
                STORE   ERCOMP1
                GOTO
                        EARTHRAT

UPDATAZ         TC      INTPRET
                DLOAD   DSU
                        AZIMUTH
                        AZIMUTH1
                BZE     PUSH
                        EARTHRAT
                DSU     BPL
                        2DEGS
                        TOOPOS   
                DLOAD   DAD
                        0D
                        2DEGS
                BMN     GOTO
                        TOONEG
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

EARTHRAT        DLOAD   DSU
                        PIPTIME
                        PREVTIME
                BPL     DAD
                        ERTHR
                        DPPOSMAX
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
                STORE   ERCOMP1
                BOFF    CLEAR
                        OPTUSE
                        +6
                        OPTUSE
                VLOAD   VAD
                        GYROANG
                        OGC
                STORE   GYROANG
                EXIT

                EXTEND
                DCA     PIPTIME
                DXCH    PREVTIME

                TC      PHASCHNG
                OCT     00500

                CAF     NINE
                TS      PRELTEMP
                TC      GOSPITGY

                TC      NOVAC
                2CADR   SPITGYRO

                TC      ENDOFJOB

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
                2DEC    .062
                2DEC    0
                2DEC    -.062
                2DEC    0
                2DEC    0
                2DEC    -.999999999
SCHZEROS        2DEC    0
PRUNITZ         2DEC    0
                2DEC    0
GEOCONS5        2DEC    .5

GEOCONS4        2DEC    .00003
GEOCONS2        2DEC    .005
GOMEGA          2DEC    0.97356192          # EARTH RATE IN IRIG PULSES/CS
GEOCONS1        2DEC    .1
2DEGS           2DEC    .005555555
DPPOSMAX        2DEC    .999999999
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

# PRELAUNCH CHECK PROCEDURE (USES THE Z-NORTH SYSTEM OF AXES)

OPTCHK          TC      GRABWAIT
                TC      NEWMODEX
                OCT     03
                TC      BANKCALL
                CADR    MKRELEAS
                CAF     ZERO
                TS      STARS
                AD      ONE
                TS      DSPTEM1 +2
                CAF     V06N30P
                TC      NVSBWAIT
                INDEX   STARS
                XCH     TAZ
                TS      DSPTEM1
                INDEX   STARS
                XCH     TEL
                TS      DSPTEM1 +1
                TC      LODLATAZ
                XCH     DSPTEM1
                INDEX   STARS
                TS      TAZ
                XCH     DSPTEM1 +1
                INDEX   STARS
                TS      TEL
                CCS     STARS
                TCF     +3
                CAF     ONE
                TC      OPTCHK +6

                TS      DSPTEM1 +2
                CAF     TWO
                TS      DSPTEM1 +1
                CAF     ONE
                TS      DSPTEM1         # SETS UP STAR NUMBER DISPLAY
                CAF     V06N30P
                TC      NVSBWAIT
                CAF     TWO
                TC      BANKCALL
                CADR    SXTMARK
                TC      BANKCALL
                CADR    OPTSTALL
                TC      CHEXIT

                TC      INTPRET
                CALL
                        PROCTARG
                VLOAD   MXV
                        TARGET1
                        XSM1
                VSL1
                STOVL   STARAD
                        TARGET1 +6
                MXV     VSL1
                        XSM1
                STORE   STARAD +6D
                LXC,1   AXT,2
                        MARKSTAT
                        2
                XSU,2   SXA,2
                        X1
                        S1
                CALL
                        SXTNB
                CALL
                        NBSM
                STORE   VECTEM
                LXC,1   INCR,1
                        MARKSTAT
                DEC     -7
                AXT,2   XSU,2
                        2
                        X1
                SXA,2   CALL
                        S1
                        SXTNB
                CALL
                        NBSM
                STOVL   12D
                        VECTEM
                STORE   6               # TO AVOID ERASABLE BIND

                CALL                    # FIND DESIRED SM IN PRESENT SM
                        AXISGEN

                CALL                    # CALCULATE REQUIRED PULSE TORQUE IN GYROD
                        CALCGTA
                EXIT

                CAF     V06N60P
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TC      CHEXIT
                TC      +2
                TC      -6

                TC      INTPRET
                SET     EXIT
                        OPTUSE

CHEXIT          TC      FREEDSP
                TC      BANKCALL
                CADR    MKRELEAS

                TC      NEWMODEX
                OCT     02

                TC      ENDOFJOB

V06N30P         OCT     00630
V06N60P         OCT     00660

# ROUTINE TO CONVERT TARGET AZIMUTH AND ELEVATIONS TO VECTORS

PROCTARG        AXT,1   AXT,2
                        1
                        12D
PROC1           SSP     SLOAD*
                        S2
                        6
                        TEL +1,1
                SR2     PUSH
                SIN     DCOMP
                STODL   TARGET1 +16D,2
                COS     PUSH            # PUSH DOWN THE COSINE OF ELEVATION
                SLOAD*  RTB
                        TAZ +1,1
                        CDULOGIC
                PUSH    SIN             # THEN Y=0.5SIN(AZ)COS(EL)
                DMP     SL1
                        0D
                STODL   TARGET1 +14D,2
                COS     DMP
                SL1     AXT,1
                        0D
                STORE   TARGET1 +12D,2
                TIX,2   RVQ
                        PROC1

## MAS 2023: The following routine is a patch added as what we believe to
## be the only difference between Sundial D and Sundial E. It was added
## to account for the missing INHINT before the original SPITYGRO scheduling.

GOSPITGY        INHINT
                CAF     PRIO26
                TC      NOVAC
                2CADR   SPITGYRO
                
                TC      ENDOFJOB

ENDPRELS        EQUALS
