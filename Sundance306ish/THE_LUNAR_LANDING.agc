### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    THE_LUNAR_LANDING.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

## Sundance 292

                BANK    32
                SETLOC  F2DPS*32
                BANK

                EBANK=  E2DPS

#       ****************************************
#       P63: THE LUNAR LANDING, BRAKING PHASE
#       ****************************************

                COUNT*  $$/P63

P63LM           TC      PHASCHNG
                OCT     04024

                TC      BANKCALL        # DO IMU STATUS CHECK ROUTINE R02
                CADR    R02BOTH

                CAF     P63ADRES        # INITIALIZE WHICH FOR BURNBABY
                TS      WHICH

                CAF     IGNADRES        # INITIALIZE WCHPHASE AND FLPASSO
                ZL                      #   FOR IGNITION ALGORITHM
                DXCH    WCHPHASE


FLAGORGY        TC      INTPRET         # DIONYSIAN FLAG WAVING
                CLEAR   CLEAR
                        NOTHROTL
                        3AXISFLG
                CLEAR   CLEAR
                        VINHFLG
                        HINHFLG
                SET     SET
                        SWANDISP
                        MUNFLAG

                                        # ****************************************

IGNALG1         SETPD   VLOAD           # FIRST SET UP INPUTS FOR RP-TO-R:-
                        0               #       AT 0D LANDING SITE IN MOON FIXED FRAME
                        RLS             #       AT 6D ESTIMATED TIME OF LANDING
                PDDL    PUSH            #       MPAC NON-ZERO TO INDICATE LUNAR CASE
                        TLAND
                STCALL  TPIP            # ALSO SET TPIP FOR FIRST GUIDANCE PASS
                        RP-TO-R
                VSL4    MXV
                        REFSMMAT
                STODL   LAND
                        TLAND
                DSU
                        GUIDDURN
                STCALL  TDEC1           # INTEGRATE STATE FORWARD TO THAT TIME
                        LEMPREC
                VLOAD   MXV
                        WMREF
                        REFSMMAT
                STODL   WM
                        WMREF
                STORE   NIGNLOOP
                STORE   TTF/8

IGNALOOP        DLOAD
                        TAT
                STOVL   PIPTIME
                        VATT1
                STORE   VCV
                MXV     VSR1
                        REFSMMAT
                STOVL   V
                        RATT1
                STORE   RCV
                VSL4    MXV
                        REFSMMAT
                STCALL  R
                        MUNGRAV
                STCALL  GDT/2
                        ?GUIDSUB        # WHICH DELIVERS N PASSES OF GUIDANCE

# DDUMCALC IS PROGRAMMED AS FOLLOWS:-
#                                         2                                           -
#              (RIGNZ - RGU )/16 + 16(RGU  )KIGNY/B8 + (RGU - RIGNX)KIGNX/B4 + (ABVAL(VGU) - VIGN)KIGNV/B4
#                          2             1                 0
#       DDUM = -------------------------------------------------------------------------------------------
#                                                10
#                                               2   (VGU - 16 VGU KIGNX/B4)
#                                                       2        0
# THE NUMERATOR IS SCALED IN METERS AT 2(28).  THE DENOMINATOR IS A VELOCITY IN UNITS OF 2(10) M/CS.
# THE QUOTIENT IS THUS A TIME IN UNITS OF 2(18) CENTISECONDS.  THE FINAL SHIFT RESCALES TO UNITS OF 2(28) CS.
# THERE IS NO DAMPING FACTOR.  THE CONSTANTS KIGNX/B4, KIGNY/B8 AND KIGNV/B4 ARE ALL NEGATIVE IN SIGN.

DDUMCALC        DLOAD   DSU             # FORM DENOMINATOR FIRST
                        RIGNZ
                        RGU +4
                PDDL    DSQ
                        RGU +2
                DMPR    PDDL
                        KIGNY
                        RGU
                DSU     DDV
                        RIGNX
                        1/KIGNX
                PDVL    ABVAL
                        VGU
                DSU     DMPR
                        VIGN
                        KIGNV
                DAD     DAD
                DAD     SR4R
                DDV     SRR
                        VGU +4
                        12D

                PUSH    DAD
                        PIPTIME
                STODL   TDEC1           # STORE NEW GUESS FOR NEXT INTEGRATION
                ABS     DSU
                        DDUMCRIT
                BMN     CALL
                        DDUMGOOD
                        INTSTALL
                SET     SET
                        INTYPFLG
                        MOONFLAG
                CLEAR   DLOAD
                        MIDFLAG
                        PIPTIME
                STCALL  TET
                        INTEGRVS
                GOTO
                        IGNALOOP

DDUMGOOD        DLOAD   DSU
                        TDEC1
                        ZOOMTDP
                STOVL   TIG             # COMPUTE DISTANCE LANDING SITE WILL BE
                        R               #       OUT OF LM'S ORBITAL PLANE AT IGNITION:
                VXV     UNIT            #       SIGN IS + IF LANDING SITE IS TO THE
                        V               #       RIGHT, NORTH; - IF TO THE LEFT, SOUTH.
                DOT     SL1
                        LAND
R60INIT         STOVL   OUTOFPLN        # INITIALIZATION FOR CALCMANU
                        UNFC/2
                STOVL   POINTVSM
                        UNITX
                STORE   SCAXIS
                EXIT
                                        # ****************************************

IGNALGRT        TC      PHASCHNG        # PREVENT REPEATING IGNALG
                OCT     04024

                TC      BANKCALL
                CADR    GOASTCLK

                CAF     OCT14
                TC      BANKCALL
                CADR    GOPERF1
                TCF     GOTOPOOH
                TCF     P63SPOT2
                TCF     +5

P63SPOT2        TC      INTPRET
                CALL
                        R51
                EXIT

                INHINT
                TC      IBNKCALL
                CADR    PFLITEDB
                RELINT

                TC      BANKCALL
                CADR    R60LEM

                TC      PHASCHNG        # PREVENT RECALLING R60
                OCT     04024

P63SPOT3        CA      BIT6            # IS THE LR ANTENNA IN POSITION 1 YET
                EXTEND
                RAND    CHAN33
                EXTEND
                BZF     P63SPOT4        # BRANCH IF ANTENNA ALREADY IN POSITION 1

                CAF     CODE500         # ASTRONAUT:    PLEASE CRANK THE
                TC      BANKCALL        #               SILLY THING AROUND
                CADR    GOPERF1
                TCF     GOTOPOOH        # TERMINATE
                TCF     P63SPOT3        # PROCEED       SEE IF HE'S LYING

P63SPOT4        TC      BANKCALL        # ENTER         INITIALIZE LANDING RADAR
                CADR    SETPOS1

                TC      POSTJUMP        # OFF TO SEE THE WIZARD ...
                CADR    BURNBABY

#       ----------------------------------------

# CONSTANTS FOR P63LM AND IGNALG

P63ADRES        GENADR  P63TABLE

IGNADRES        GENADR  IGNALG

CODE500         OCT     00500

GUIDDURN        2DEC    +60800
DDUMCRIT        2DEC    +20 B-28        # CRITERION FOR IGNALG CONVERGENCE

VIGN            2DEC*   +1.69664345 E+1 B-10*
RIGNX           2DEC*   -3.41873750 E+4 B-24*
RIGNZ           2DEC*   -4.35548938 E+5 B-24*
1/KIGNX         2DEC*   -1.99999999 E-1 B+0*
KIGNY           2DEC*   -0.02430170 E-6 B+8*
KIGNV           2DEC    -384 E2 B-20

#       ----------------------------------------

#       ****************************************
#       LANDING CONFIRMATION
#       ****************************************

                BANK    31
                SETLOC  F2DPS*31
                BANK

                COUNT*  $$/P6567

LANDJUNK        TC      UPFLAG
                ADRES   FLUNDISP
                TC      FASTCHNG
                TC      PHASCHNG
                OCT     00005

                INHINT
                TC      IBNKCALL
                CADR    ENGINOF3

                TC      UPFLAG
                CADR    LRBYPASS

                TC      INTPRET         # TO INTERPRETIVE AS TIME IS NOT CRITICAL
                RTB     TLOAD
                        RDCDUS
                        1D
                STORE   CDUXD
                SET     SET
                        SURFFLAG
                        KILLROSE
                CLEAR   CLEAR
                        AVEGFLAG
                        SWANDISP
                VLOAD   VSL2
                        RN
                STODL   ALPHAV
                        PIPTIME
                SET     CALL
                        LUNAFLAG
                        LAT-LONG
                SETPD   VLOAD           # COMPUTE RLS AND STORE IT AWAY
                        0
                        RN
                VSL2    PDDL
                        PIPTIME
                PUSH    CALL
                        R-TO-RP
                STORE   RLS
                EXIT
                CAF     V06N43*         # ASTRONAUT:  NOW LOOK WHERE YOU ENDED UP
                TC      BANKCALL
                CADR    GOFLASH
                TCF     GOTOPOOH        # TERMINATE
                TCF     +2              # PROCEED
                TCF     -5              # RECYCLE

                CAF     OCT501
                TC      BANKCALL
                CADR    GOPERF1
                TCF     GOTOPOOH
                TCF     +2
                TCF     -5

                TCF     GOTOPOOH        # ASTRONAUT:  PLEASE SELECT P57

V06N43*         VN      0643
OCT501          OCT     501
OCT71           OCT     71

#       ****************************************
#       LANDING TEST PROGRAM
#       ****************************************

LANDTEST        CA      VERTADR
                TS      WCHPHASE
                TS      FLPASS0
                TS      WCHVERT

                TC      INTPRET
                VLOAD   MXV
                        WMREF
                        REFSMMAT
                STODL   WM
                        LUNLANAD
                STOVL   AVEGEXIT
                        RGU
                UNIT    VXSC
                        LANDSCAL
                STORE   LAND
                ABVAL   SET
                        IDLEFLAG
                STOVL   /LAND/
                        UNITX
                STOVL   CG
                        UNITY
                STOVL   CG +6
                        UNITZ
                STORE   CG +12D
                SET     RTB
                        MUNFLAG
                        LOADTIME
                STORE   TPIP
                EXIT

                INHINT
                CAF     ONE
                TC      WAITLIST
                EBANK=  DVCNTR
                2CADR   PREREAD

                CAF     BIT13
                EXTEND
                RAND    DSALMOUT
                CCS     A
                TCF     TSTENGON

                TC      IBNKCALL
                CADR    ONULLAGE

                CAF     3SECS
                TC      TWIDDLE
                ADRES   TESTIGN

                CAF     LOW9
                TC      BANKCALL
                CADR    DELAYJOB

TSTENGON        INHINT
                CS      DRIFTBIT
                MASK    DAPBOOLS
                TS      DAPBOOLS
                
                CAF     ZERO
                TS      FLPASS0

                CAF     TESTDB
                TS      DB
                TCF     ENDOFJOB

TESTIGN         CS      PRIO30
                EXTEND
                RAND    DSALMOUT
                AD      BIT13
                EXTEND
                WRITE   DSALMOUT
                TC      UPFLAG
                ADRES   ENGONFLG
                TCF     TASKOVER

LANDSCAL        2DEC    0.207196475
TESTDB          DEC     0.02222
