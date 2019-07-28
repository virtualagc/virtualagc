### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    THE_LUNAR_LANDING.agc
## Purpose:     A section of LUM69 revision 2.
##              It is part of the reconstructed source code for the flown
##              version of the flight software for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 10. The code has
##              been recreated from a copy of Luminary revsion 069, using
##              changes present in Luminary 099 which were described in
##              Luminary memos 75 and 78. The code has been adapted such
##              that the resulting bugger words exactly match those specified
##              for LUM69 revision 2 in NASA drawing 2021152B, which gives
##              relatively high confidence that the reconstruction is correct.
## Reference:   pp. 789-796
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.

## Page 789
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

                CAF     DPSTHRSH        # INITIALIZE DVMON
                TS      DVTHRUSH
                CAF     FOUR
                TS      DVCNTR

                CS      ONE             # INITIALIZE WCHPHASE AND FLPASSO
                ZL                      #   FOR IGNITION ALGORITHM
                DXCH    WCHPHASE


                CS      BIT14
                EXTEND
                WAND    CHAN12          # REMOVE TRACK-ENABLE DISCRETE.

FLAGORGY        TC      INTPRET         # DIONYSIAN FLAG WAVING
                CLEAR   CLEAR
                        NOTHROTL
                        REDFLAG
                CLEAR   SET
                        LRBYPASS
                        MUNFLAG
                CLEAR   CLEAR
                        P25FLAG         # TERMINATE P25 IF IT IS RUNNING.
                        RNDVZFLG        # TERMINATE P20 IF IT IS RUNNING

                                        # ****************************************

IGNALG          SETPD   VLOAD           # FIRST SET UP INPUTS FOR RP-TO-R:-
                        0               #       AT 0D LANDING SITE IN MOON FIXED FRAME
                        RLS             #       AT 6D ESTIMATED TIME OF LANDING
## Page 790
                PDDL    PUSH            #       MPAC NON-ZERO TO INDICATE LUNAR CASE
                        TLAND
                STCALL  TPIP            # ALSO SET TPIP FOR FIRST GUIDANCE PASS
                        RP-TO-R
                VSL4    MXV
                        REFSMMAT
                STCALL  LAND
                        GUIDINIT        # GUIDINIT INITIALIZES WM AND /LAND/
                DLOAD   DSU
                        TLAND
                        GUIDDURN
                STCALL  TDEC1           # INTEGRATE STATE FORWARD TO THAT TIME
                        LEMPREC
                SSP     VLOAD
                        NIGNLOOP
                        40D
                        UNITX
                STOVL   CG
                        UNITY
                STOVL   CG +6
                        UNITZ
                STODL   CG +14
                        99999CON
                STOVL   DELTAH          # INITIALIZE DELTAH FOR V16N68 DISPLAY
                        ZEROVECS
                STODL   UNFC/2          # INITIALIZE TRIM VELOCITY CORRECTION TERM
                        HI6ZEROS
                STORE   TTF/8

IGNALOOP        DLOAD
                        TAT
                STOVL   PIPTIME1
                        RATT1
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
## Page 791
# THE NUMERATOR IS SCALED IN METERS AT 2(28).  THE DENOMINATOR IS A VELOCITY IN UNITS OF 2(10) M/CS.
# THE QUOTIENT IS THUS A TIME IN UNITS OF 2(18) CENTISECONDS.  THE FINAL SHIFT RESCALES TO UNITS OF 2(28) CS.
# THERE IS NO DAMPING FACTOR.  THE CONSTANTS KIGNX/B4, KIGNY/B8 AND KIGNV/B4 ARE ALL NEGATIVE IN SIGN.

DDUMCALC        TS      NIGNLOOP
                TC      INTPRET
                DLOAD   DMPR            # FORM DENOMINATOR FIRST
                        VGU
                        KIGNX/B4
                SL4R    BDSU
                        VGU +4
                PDDL    DSU
                        RIGNZ
                        RGU +4
                SR4R    PDDL
                        RGU +2
                DSQ     DMPR
                        KIGNY/B8
                SL4R    PDDL
                        RGU
                DSU     DMPR
                        RIGNX
                        KIGNX/B4
                PDVL    ABVAL
                        VGU
                DSU     DMPR
                        VIGN
                        KIGNV/B4
                DAD     DAD
                DAD     DDV
                SRR
                        10D

                PUSH    DAD
                        PIPTIME1
                STODL   TDEC1           # STORE NEW GUESS FOR NEXT INTEGRATION
                ABS     DSU
                        DDUMCRIT
                BMN     CALL
                        DDUMGOOD
                        INTSTALL
                SET     SET
                        INTYPFLG
                        MOONFLAG
                DLOAD
                        PIPTIME1
                STOVL   TET             # HOPEFULLY ?GUIDSUB DID NOT
                        RATT1           #       CLOBBER RATT1 AND VATT1
                STOVL   RCV
                        VATT1
## Page 792
                STCALL  VCV
                        INTEGRVS
                GOTO
                        IGNALOOP

DDUMGOOD        SLOAD   SR
                        ZOOMTIME
                        14D
                BDSU
                        TDEC1
                STOVL   TIG             # COMPUTE DISTANCE LANDING SITE WILL BE
                        V               #       OUT OF LM'S ORBITAL PLANE AT IGNITION:
                VXV     UNIT            #       SIGN IS + IF LANDING SITE IS TO THE
                        R               #       RIGHT, NORTH; - IF TO THE LEFT, SOUTH.
                DOT     SL1
                        LAND
R60INIT         STOVL   OUTOFPLN        # INITIALIZATION FOR CALCMANU
                        UNFC/2
                STORE   R60VSAVE        # STORE UNFC/2 TEMPORARILY IN R60SAVE
                EXIT
                                        # ****************************************

IGNALGRT        TC      PHASCHNG        # PREVENT REPEATING IGNALG
                OCT     04024

ASTNCLOK        CS      ASTNDEX
                TC      BANKCALL
                CADR    STCLOK2
                TCF     ENDOFJOB        # RETURN IN NEW JOB AND IN EBANK FIVE

ASTNRET         TC      INTPRET
                SSP     RTB             # GO PICK UP DISPLAY AT END OF R51:
                        QMAJ            #       "PROCEED" WILL DO A FINE ALIGNMENT
                FCADR   P63SPOT2        #       "ENTER" WILL RETURN TO P63SPOT2
                        R51P63
P63SPOT2        VLOAD   UNIT            # INITIALIZE KALCMANU FOR BURN ATTITUDE
                        R60VSAVE
                STOVL   POINTVSM
                        UNITX
                STORE   SCAXIS
                EXIT

                CAF     EBANK7
                TS      EBANK

                INHINT
                TC      IBNKCALL
                CADR    PFLITEDB
                RELINT

## Page 793
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

ASTNDEX         OCT     00027           # INDEX FOR CLOKTASK

CODE500         OCT     00500

99999CON        2DEC    30479.7 B-24

GUIDDURN        2DEC    +65164
DDUMCRIT        2DEC    +8 B-28         # CRITERION FOR IGNALG CONVERGENCE

## Page 794
#       ----------------------------------------

## Page 795
#       ****************************************
#       P68: LANDING CONFIRMATION
#       ****************************************

                BANK    31
                SETLOC  F2DPS*31
                BANK

                COUNT*  $$/P6567

LANDJUNK        TC      PHASCHNG
                OCT     04024

                INHINT
                TC      BANKCALL        # ZERO ATTITUDE ERROR
                CADR    ZATTEROR

                TC      BANKCALL        # SET 5 DEGREE DEADBAND
                CADR    SETMAXDB

                TC      INTPRET         # TO INTERPRETIVE AS TIME IS NOT CRITICAL
                SET     CLEAR
                        SURFFLAG
                        LETABORT
                SET     CLEAR
                        APSFLAG
                        SWANDISP
                SET     VLOAD
                        LRBYPASS
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

## Page 796
                TC      INTPRET
                VLOAD                   # INITIALIZE GSAV AND (USING REFMF)
                        UNITX           # YNBSAV, ZNBSAV AND ATTFLAG FOR P57
                STCALL  GSAV
                        REFMF
                EXIT

                TCF     GOTOPOOH        # ASTRONAUT:  PLEASE SELECT P57

V06N43*         VN      0643

