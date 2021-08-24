### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LUNAR_LANDING_GUIDANCE_EQUATIONS.agc
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
## Reference:   pp. 802-828
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.
##              2021-05-30 ABS  Removed DEC66 symbol not present in Luminary 69.

## Page 802
                EBANK=          E2DPS

                COUNT*          $$/F2DPS

# ****************************************************************************************************************
# LUNAR LANDING FLIGHT SEQUENCE TABLES
# ****************************************************************************************************************

# FLIGHT SEQUENCE TABLES ARE ARRANGED BY FUNCTION.   THEY ARE REFERENCED USING AS AN INDEX THE REGISTER WCHPHASE:
#                                                  WCHPHASE  =  -1  --->  IGNALG
#                                                  WCHPHASE  =   0  --->  BRAKQUAD
#                                                  WCHPHASE  =   1  --->  BRAKLING
#                                                  WCHPHASE  =   2  --->  APPRQUAD
#                                                  WCHPHASE  =   3  --->  APPRLING
#                                                  WCHPHASE  =   4  --->  VERTICAL

# ***************************************************************************************************************

# ROUTINES FOR STARTING NEW GUIDANCE PHASES:

                TCF             TTFINCR                 # IGNALG
NEWPHASE        TCF             TTFINCR                 # BRAKQUAD
                TCF             LINSET?                 # BRAKLING
                TCF             STARTP64                # APPRQUAD
                TCF             LINSET                  # APPRLING
                TCF             P65START                # VERTICAL
#


# PRE-GUIDANCE COMPUTATIONS:

                TCF             CALCRGVG                # IGNALG
PREGUIDE        TCF             RGVGCALC                # BRAKQUAD
                TCF             RGVGCALC                # BRAKLING
                TCF             REDESIG                 # APPRQUAD
                TCF             RGVGCALC                # APPRLING
                TCF             RGVGCALC                # VERTICAL
#

# GUIDANCE EQUATIONS:

                TCF             TTF/8CL                 # IGNALG
WHATGUID        TCF             TTF/8CL                 # BRAKQUAD
                TCF             LINGUID                 # BRAKLING
                TCF             TTF/8CL                 # APPRQUAD
                TCF             LINGUID                 # BRAKLING
                TCF             VERTGUID                # VERTICAL

## Page 803
# POST GUIDANCE EQUATION COMPUTATIONS:

                TCF             CGCALC                  # IGNALG
AFTRGUID        TCF             CGCALC                  # BRAKQUAD
                TCF             LINXLOGC                # BRAKLING
                TCF             CGCALC                  # APPRQUAD
                TCF             LINXLOGC                # APPRLING
                TCF             EXVERT                  # VERTICAL
#

# WINDOW VECTOR COMPUTATIONS:

                TCF             EXGSUB                  # IGNALG
WHATEXIT        TCF             EXBRAK                  # BRAKQUAD
                TCF             EXBRAK                  # BRAKLING
                TCF             EXNORM                  # APPRQUAD
                TCF             EXNORM                  # APPRLING
#

# DISPLAY ROUTINES:

WHATDISP        TCF             P63DISPS                # BRAKQUAD
                TCF             P63DISPS                # BRAKLING
                TCF             P64DISPS                # APPRQUAD
                TCF             P64DISPS                # APPRLING
                TCF             VERTDISP                # VERTICAL
#

# INDICES FOR REFERENCING TARGET PARAMETERS:

                OCT             0                       # IGNALG
TARGTDEX        OCT             0                       # BRAKQUAD
                OCT             0                       # BRAKLING
                OCT             30                      # APPRQUAD
                OCT             30                      # APPRLING
#

# ****************************************************************************************************************
# ENTRY POINTS:   2GUIDSUB FOR THE IGNITION ALGORITHM, LUNLAND FOR SERVOUT
# ****************************************************************************************************************

# IGNITION ALGORITHM ENTRY:  DELIVERS N PASSES OF QUADRATIC QUIDANCE

?GUIDSUB        EXIT
                CAF             TWO                     # N = 3
                TS              NGUIDSUB
                TCF             GUILDRET

GUIDSUB         TS              NGUIDSUB                # ON SUCEEDING PASSES SKIP TTFINCR
                TCF             CALCRGVG

## Page 804

# NORMAL ENTRY:  CONTROL COMES HERE FROM SERVOUT

LUNLAND         TC              PHASCHNG
                OCT             00035                   # GROUP 5:  RETAIN ONLY PIPA TASK
                TC              PHASCHNG
                OCT             05023                   # GROUP 3:  PROTECT GUIDANCE WITH PRIO 21
                OCT             21000                   #       JUST HIGHER THAN SERVICER'S PRIORITY

# ****************************************************************************************************************
# GUILDENSTERN:  AUTO-MODES MONITOR (R13)
# ****************************************************************************************************************

                COUNT*          $$/R13

#    HERE IS THE PHILOSOPHY OF GUILDENSTERN:    ON EVERY APPEARANCE OR DISAPPEARANCE OF THE MANUAL THROTTLE
# DISCRETE TO SELECT P67 OR P66 RESPECTIVELY;   ON EVERY APPEARANCE OF THE ATTITUDE-HOLD DISCRETE TO SELECT P66
# UNLESS THE CURRENT PROGRAM IS P67 IN WHICH CASE THERE IS NO CHANGE.

GUILDEN         EXTEND                                  # IS UN-AUTO-THROTTLE DISCRETE PRESENT?
  STERN         READ            CHAN30
                MASK            BIT5
                CCS             A
                TCF             STARTP67                # YES
P67NOW?         TC              CHECKMM                 # NO:   ARE WE IN P67 NOW?
                DEC             67
                TCF             STABL?                  # NO
STARTP66        TC              FASTCHNG                # YES
                TC              NEWMODEX
                DEC             66
                EXTEND                                  # INITIALIZE VDGVERT USING
                DCA             VGU                     #   PRESENT DOWNWARD VELOCITY
                DXCH            VDGVERT
                CAF             ZERO
                TS              RODCOUNT
VRTSTART        TS              WCHVERT
                CAF             FOUR                    # WCHPHASE = 4 --> VERTICAL: P65,P66,P67
                TS              WCHPHOLD
                TS              WCHPHASE
                TC              BANKCALL                # TEMPORARY, I HOPE HOPE HOPE
                CADR            STOPRATE                # TEMPORARY, I HOPE HOPE HOPE
                TC              DOWNFLAG                # PERMIT X-AXIS OVERRIDE
                ADRES           XOVINFLG
                TC              DOWNFLAG
                ADRES           REDFLAG
                TC              DOWNFLAG
                ADRES           POUTFLAG                # PERMIT PULSE-OUTS
                TCF             GUILDRET

STARTP67        TC              NEWMODEX                # NO HARM IN "STARTING" P67 OVER AND OVER
                DEC             67                      #   SO NO NEED FOR A FASTCHNG AND NO NEED

## Page 805
                CAF             TEN                     #   TO SEE IF ALREADY IN P67
                TCF             VRTSTART

STABL?          CAF             BIT13                   # IS UN-ATTITUDE-HOLD DISCRETE PRESENT?
                EXTEND
                RAND            CHAN31
                CCS             A
                TCF             GUILDRET                # YES: ALL'S WELL
P66NOW?         TC              CHECKMM                 # NO:  ARE WE IN P66 NOW?
                DEC             66
                TCF             STARTP66                # NO

#                                               (CONTINUE TO GUILDRET) YES

# ****************************************************************************************************************
# INITIALIZATION FOR THIS PASS
# ****************************************************************************************************************

                COUNT*          $$/F2DPS

GUILDRET        EXTEND
                DCA             TPIP
                DXCH            TPIPOLD

                TC              FASTCHNG

                EXTEND
                DCA             PIPTIME1
                DXCH            TPIP

                EXTEND
                DCA             TTF/8
                DXCH            TTF/8TMP

                CCS             FLPASS0
                TCF             TTFINCR

BRSPOT1         INDEX           WCHPHASE
                TCF             NEWPHASE

# ****************************************************************************************************************
# ROUTINES TO START NEW PHASES
# ****************************************************************************************************************

P65START        TC              NEWMODEX
                DEC             65
                CS              TWO
                TS              WCHVERT
                TC              DOWNFLAG                # PERMIT X-AXIS OVERRIDE
                ADRES           XOVINFLG

## Page 806
COMSTART        TC              DOWNFLAG
                ADRES           POUTFLAG
                TCF             TTFINCR


STARTP64        CAF             DELTTFAP                # AUGMENT TTF/8 (TWO-PHASE ONLY)
                ADS             TTF/8TMP
 +2             TC              NEWMODEX
                DEC             64
                CAF             TWO
                TS              WCHPHASE
                CA              BIT12                   # ENABLE RUPT10
                EXTEND
                WOR             CHAN13
                TC              DOWNFLAG                # INITIALIZE REDESIGNATION FLAG
                ADRES           REDFLAG
                TCF             COMSTART

# ****************************************************************************************************************
# SET LINEAR GUIDANCE COEFFICIENTS
# ****************************************************************************************************************

LINSET?         CA              FLAGWRD6                # ONE-PHASE OR TWO-PHASE?
                MASK            2PHASBIT
                EXTEND
                BZF             STARTP64        +2      # ONE-PHASE: GO DIRECTLY TO APPROACH PHASE

LINSET          TC              INTPRETX
                VLOAD           VSU*                    # -        -     -
                                ACG                     # JLING = (ACG - ADG)/TTF
                                ADG,1
                VSR3            V/SC
                                TTF/8TMP                # TTF/8 NOT YET UPDATED
                STORE           JLING                   # JLING IS IN UMITS OF 2(-18) M/CS/CS/CS
                EXIT

#                                             (CONTINUE TO TTFINCR)

# ****************************************************************************************************************
# INCREMENT TTF/8, UPDATE LAND FOR LUNAR ROTATION, DO OTHER USEFUL THINGS
# ****************************************************************************************************************
#
#            TTFINCR COMPUTATIONS ARE AS FOLLOWS:-

#                      TTF/8 UPDATED FOR TIME SINCE LAST PASS:

#                                 TTF/8 = TTF/8 + (TPIP - TPIPOLD)/8

#                      LANDING SITE VECTOR UPDATED FOR LUNAR ROTATION:

## Page 807
#                                 -                  -      -                      -
#                                 LAND = /LAND/ UNIT(LAND - LAND(TPIP - TPIPOLD) * WM)

#                      SLANT RANGE TO LANDING SITE, FOR DISPLAY:

#                                                  -      -
#                                 RANGEDSP = ABVAL(LAND - R)

TTFINCR         TC              INTPRET
                DLOAD           DSU
                                TPIP
                                TPIPOLD
                SLR             PUSH                    # SHIFT SCALES DELTA TIME TO 2(17) CSECS
                                11D
                VXSC            VXV
                                LAND
                                WM
                BVSU            RTB
                                LAND
                                NORMUNIT
                VXSC            VSL1
                                /LAND/
                STORE           LANDTEMP
                VSU             ABVAL
                                R
                STODL           RANGEDSP
                EXIT

                DXCH            MPAC
                DAS             TTF/8TMP                # NOW HAVE INCREMENTED TTF/8 IN TTF/8TMP

                TC              FASTCHNG

                EXTEND
                DCA             TTF/8TMP
                DXCH            TTF/8

                EXTEND
                DCA             LANDTEMP
                DXCH            LAND
                EXTEND
                DCA             LANDTEMP        +2
                DXCH            LAND            +2
                EXTEND
                DCA             LANDTEMP        +4
                DXCH            LAND            +4

                TC              TDISPSET
                TC              FASTCHNG                # SINCE REDESIG MAY CHANGE LANDTEMP

## Page 808
BRSPOT2         INDEX           WCHPHASE
                TCF             PREGUIDE

# ****************************************************************************************************************
# LANDING SITE PERTURBATION EQUATIONS
# ****************************************************************************************************************

REDESIG         CA              FLAGWRD6                # IS REDFLAG SET?
                MASK            REDFLBIT
                EXTEND
                BZF             RGVGCALC                # NO:   SKIP REDESIGNATION LOGIC

                CA              TREDES                  # YES:  HAS TREDES REACHED ZERO?
                EXTEND
                BZF             RGVGCALC                # YES:  SKIP REDESIGNATION LOGIC

                INHINT
                CA              ELINCR1
                TS              ELINCR
                CA              AZINCR1
                TS              AZINCR
                TC              FASTCHNG

                CA              ZERO
                TS              ELINCR1
                TS              AZINCR1
                RELINT
                TS              ELINCR          +1
                TS              AZINCR          +1

                CA              FIXLOC                  # SET PD TO 0
                TS              PUSHLOC

                TC              INTPRET
                VLOAD           VSU
                                LAND
                                R                       #                 -      -
                RTB             PUSH                    # PUSH DOWN UNIT (LAND - R)
                                NORMUNIT
                VXV             VSL1
                                YNBPIP                  #                    -          -      -
                VXSC            PDDL                    # PUSH DOWN - ELINCR(YNB * UNIT(LAND - R))
                                ELINCR
                                AZINCR
                VXSC            VSU
                                YNBPIP
                VAD             PUSH                    # RESULTING VECTOR IS 1/2 REAL SIZE

                DLOAD           DSU                     # MAKE SURE REDESIGNATION IS NOT
                                0                       #   TOO CLOSE TO THE HORIZON

## Page 809
                                DEPRCRIT
                BMN             DLOAD
                                REDES1
                                DEPRCRIT
                STORE           0
REDES1          DLOAD           DSU
                                LAND
                                R
                DDV             VXSC
                                0
                VAD             UNIT
                                R
                VXSC            VSL1
                                /LAND/
                STORE           LANDTEMP
                EXIT                                    # LOOKANGL WILL BE COMPUTED AT RGVGCALC

                TC              FASTCHNG

                EXTEND
                DCA             LANDTEMP
                DXCH            LAND
                EXTEND
                DCA             LANDTEMP        +2
                DXCH            LAND            +2
                EXTEND
                DCA             LANDTEMP        +4
                DXCH            LAND            +4

                TCF             RGVGCALC

# ****************************************************************************************************************
# COMPUTE STATE IN GUIDANCE COORDINATES
# ****************************************************************************************************************

#            RGVGCALC COMPUTATIONS ARE AS FOLLOWS:-

#                     VELOCITY RELATIVE TO THE SURFACE:

#                                 -         -   -   -
#                                 ANGTERM = V + R * WM

#                     STATE IN GUIDANCE COORDINATES:

#                                 -     *   -   -
#                                 RGU = CG (R - LAND)

#                                 -     *   -   -    -
#                                 VGU = CG (V - WM * R)

## Page 810
#                     HORIZONTAL VELOCITY FOR DISPLAY:

#                                 VHORIZ = 8 ABVAL (0, VG , VG )
#                                                        2    1

#                     DEPRESSION ANGLE FOR DISPLAY:

#                                                        -   -     -
#                                 LOOKANGL = ARCSIN(UNIT(R - LAND).XMBPIP)

CALCRGVG        TC              INTPRET                 # IN IGNALG, COMPUTE V FROM INTEGRATION
                VLOAD           MXV                     #   OUTPUT AND TRIM CORRECTION TERM
                                VATT1                   #   COMPUTED LAST PASS AND LEFT IN UNFC/2
                                REFSMMAT
                VSR1            VAD
                                UNFC/2
                STORE           V
                EXIT

RGVGCALC        TC              INTPRET                 # ENTER HERE TO RECOMPUTE RG AND VG
                VLOAD           VXV
                                R
                                WM
                VAD             VSR2                    # RESCALE TO UNITS OF 2(9) M/CS
                                V
                STORE           ANGTERM
                MXV
                                CG                      # NO SHIFT SINCE ANGTERM IS DOUBLE SIZED
                STORE           VGU
                PDDL            VDEF                    # FORM (0,VG ,VG ) IN UNITS OF 2(10) M/CS
                                ZEROVECS                #           2   1
                ABVAL           SL3
                STOVL           VHORIZ                  # VHORIZ FOR DISPLAY DURING P65, P66, P67
                                R                       #           -   -
                VSU             PUSH                    # PUSH DOWN R - LAND
                                LAND
                MXV             VSL1
                                CG
                STOVL           RGU
                RTB             DOT                     # NOW IN MPAC IS SINE(LOOKANGL)/4
                                NORMUNIT
                                XNBPIP
                EXIT

                CA              FIXLOC                  # RESET PUSH DOWN POINTER
                TS              PUSHLOC

                CA              MPAC                    # COMPUTE LOOKANGL ITSELF
                DOUBLE
                TC              BANKCALL

## Page 811
                CADR            SPARCSIN        -1
                AD              1/2DEG
                EXTEND
                MP              180DEGS
                TS              LOOKANGL                # LOOKANGL FOR DISPLAY DURING P64

BRSPOT3         INDEX           WCHPHASE
                TCF             WHATGUID

#****************************************************************************************************************
# LINEAR GUIDANCE EQUATION
#****************************************************************************************************************

LINGUID         TC              INTPRETX
                VLOAD           VXSC                    # -     -     -
                                JLING                   # ACG = ADG + JLING TTF
                                TTF/8
                VSL3            GOTO                    # PICK UP THE VAD* AT AFCCALC
                                AFCCALC

#****************************************************************************************************************
# TTF/4 COMPUTATION
#****************************************************************************************************************

TTF/8CL         TC              INTPRETX
                DLOAD*
                                JDG2TTF,1
                STODL*          TABLTTF         +6      # A(3) = 8 JDG  TO TABLTTF
                                ADG2TTF,1               #             2
                STODL           TABLTTF         +4      # A(2) = 6 ADG  TO TABLTTF
                                VGU             +4      #             2
                DMP             DAD*
                                3/4DP
                                VDG2TTF,1
                STODL*          TABLTTF         +2      # A(1) = (6 VGU  + 18 VDG )/8 TO TABLTTF
                                RDG             +4,1    #              2         2
                DSU             DMP
                                RGU             +4
                                3/8DP
                STORE           TABLTTF                 # A(0) = -24 (RGU  - RDG )/64 TO TABLTTF
                EXIT                                    #                2      2

                CA              BIT8
                TS              TABLTTF         +10     # FRACTIONAL PRECISION FOR TTF TO TABLE

                EXTEND
                DCA             TTF/8
                DXCH            MPAC                    # LOADS TTF/8 (INITIAL GUESS) INTO MPAC
                CAF             TWO                     # DEGREE - ONE
                TS              L

## Page 812
                CAF             TABLTTFL
                TC              ROOTPSRS                # YIELDS TTF/8 IN MPAC
                TC              POODOO                  # BAD RETURN
                OCT             01406
                EXTEND                                  # GOOD RETURN
                DCA             MPAC                    # FETCH TTF/8 KEEPING IT IN MPAC
                DXCH            TTF/8                   # CORRECTED TTF/8

                TC              TDISPSET

#                                              (CONTINUE TO QUADGUID)

# ****************************************************************************************************************
# MAIN GUIDANCE EQUATION
# ****************************************************************************************************************

#                      AS PUBLISHED:-

#                                               -     -        -     -
#                                 -     -     6(VDG + VG)   12(RDG - RG)
#                                 ACG = ADG + ----------- + ------------
#                                                 TTF         (TTF)(TTF)

#                      AS HERE PROGRAMMED:-

#                                             -     -
#                                      3 (1/4(RDG - RG)   -     - )
#                                      - (------------- + VDG + VG)
#                                -     4 (    TTF/8               )   -
#                                ACG = ---------------------------- + ADG
#                                                 TTF/8

QUADGUID        CAF             30SEC*17                # PULSE-OUTS ARE INHIBITED WHENEVER
                AD              TTF/8                   #   TTF < 30 SECONDS, REGARDLESS OF
                EXTEND                                  #   THE DURATION OF LINEAR GUIDANCE
                BZMF            Q**DG**D
                TC              UPFLAG
                ADRES           POUTFLAG
Q**DG**D        TC              INTPRETX
                VLOAD*          VSU
                                RDG,1
                                RGU
                V/SC            VSR2
                                TTF/8
                VAD*            VAD
                                VDG,1
                                VGU
                V/SC            VXSC
                                TTF/8

## Page 813
                                3/4DP
AFCCALC         VAD*
                                ADG,1                   # CURRENT TARGET ACCELERATION
                STORE           ACG
AFCCALC1        VXM             VSL1                    # VERTGUID COMES HERE
                                CG
                PDVL            V/SC
                                GDT/2
                                GSCALE
                BVSU            STADR
                STORE           UNFC/2                  # UNFC/2 NEED NOT BE UNITIZED
                ABVAL
AFCCALC2        STORE           /AFC/                   # MAGNITUDE OF AFC FOR THROTTLE
                BON             DLOAD
                                2PHASFLG
                                AFCCLEND
                                UNFC/2                  # VERTICAL COMPONENT
                DSQ             PDDL
                                UNFC/2          +2      # OUT-OF-PLANE
                DSQ             PDDL
                                HIGHESTF
                DDV             DSQ
                                MASS                    #                        2    2    2
                DSU             DSU                     # AMAXHORIZ = SQRT(ATOTAL - A  - A  )
                BPL             DLOAD                   #                            1    0
                                AFCCALC3
                                ZEROVECS
AFCCALC3        SQRT            DAD
                                UNFC/2          +4
                BPL             BDSU
                                AFCCLEND
                                UNFC/2          +4
                STORE           UNFC/2          +4
AFCCLEND        EXIT
                TC              FASTCHNG

                CA              WCHPHASE                # PREPARE FOR PHASE SWITCHING LOGIC
                TS              WCHPHOLD
                INCR            FLPASS0                 # INCREMENT PASS COUNTER

BRSPOT4         INDEX           WCHPHASE
                TCF             AFTRGUID

# ***************************************************************************************************************
# ERECT GUIDANCE-STABLE MEMBER TRANSFORMATION MATRIX
# ***************************************************************************************************************

CGCALC          TC              INTPRET
                VLOAD           UNIT
                                LAND

## Page 814
                STOVL           CG                      # FIRST ROW
                                ANGTERM
                VXSC            VAD                     # REMEMBER THAT ANGTERM IS DOUBLE-SIZED
                                TTF/8
                                LAND
                VSU             RTB
                                R
                                NORMUNIT
                VXV             RTB
                                LAND
                                NORMUNIT
                STOVL           CG              +6      # SECOND ROW
                                CG
                VXV             VSL1
                                CG              +6
                STORE           CG              +14
                EXIT

#                                             (CONTINUE TO EXTLOGIC)

# ****************************************************************************************************************
# PREPARE TO EXIT
# ****************************************************************************************************************

# DECIDE (1) HOW TO EXIT, AND (2) WHETHER TO SWITCH PHASES

EXTLOGIC        CCS             WCHPHASE
                INDEX           A                       # WCHPHASE = +2    APPRQUAD    A = 1
                CA              TENDBRAK                # WCHPHASE = +0    BRAKQUAD    A = 0
                TCF             EXSPOT1         -1      # WCHPHASE = -1    IGNALG      A = 0

LINXLOGC        CA              3SEC*17
                AD              TTF/8

EXSPOT1         EXTEND
                INDEX           WCHPHASE
                BZMF            WHATEXIT

                TC              FASTCHNG

                CA              WCHPHOLD
                AD              ONE
                ZL                                      # +0
                DXCH            WCHPHASE                # ADVANCING WCHPHASE AND RESETTING FLPASS0

                INDEX           WCHPHOLD
                TCF             WHATEXIT

# ****************************************************************************************************************
# ROUTINES FOR EXITING FROM LANDING GUIDANCE

## Page 815
# ****************************************************************************************************************

# 1.        EXGSUB IS THE RETURN WHEN GUIDSUB IS CALLED BY THE IGNITION ALGORITHM.

# 2.        EXBRAK IN THE EXIT USED DURING THE BRAKING PHASE.   IN THIS CASE UNIT(R) IS THE WINDOW POINTING VECTOR.

# 3.        EXNORM IS THE EXIT USED AT OTHER TIMES DURING THE BURN.

#          (EXOVFLOW IS A SUBROUTINE OF EXBRAK AND EXNORM CALLED WHEN OVERFLOW OCCURRED ANYWHERE IN GUIDANCE.)

EXGSUB          TC              INTPRET                 # COMPUTE TRIM VELOCITY CORRECTION TERM
                VLOAD           RTB
                                UNFC/2
                                NORMUNIT
                VXSC            VXSC
                                ZOOMTIME
                                TRIMACCL
                STORE           UNFC/2
                EXIT

                CCS             NGUIDSUB
                TCF             GUIDSUB
                CCS             NIGNLOOP
                TCF             +3
                TC              ALARM
                OCT             01412

 +3             TC              POSTJUMP
                CADR            DDUMCALC

EXBRAK          TC              INTPRET
                VLOAD
                                UNIT/R/
                STORE           UNWC/2
                EXIT
                TCF             STEER?

EXNORM          TC              INTPRET
                VLOAD           VSU
                                LAND
                                R
                RTB
                                NORMUNIT
                STORE           UNWC/2                  # UNIT(LAND - R) IS TENTATIVE CHOICE
                VXV             DOT
                                XNBPIP
                                CG              +6
                EXIT                                    # WITH PROJ IN MPAC 1/8 REAL SIZE

                CS              MPAC                    # GET COEFFICIENT FOR CG +14

## Page 816
                AD              PROJMAX
                AD              POSMAX
                TS              BUF
                CS              BUF
                ADS             BUF                     # RESULT IS 0 IF PROJMAX - PROJ NEGATIVE

                CS              PROJMIN                 # GET COEFFICIENT FOR UNIT(LAND - R)
                AD              MPAC
                AD              POSMAX
                TS              BUF             +1
                CS              BUF             +1
                ADS             BUF             +1      # RESULT IS 0 IF PROJ - PROJMIN NEGATIVE

                CAF             FOUR
UNWCLOOP        MASK            SIX
                TS              Q
                CA              EBANK5
                TS              EBANK
                EBANK=          CG
                CA              BUF
                EXTEND
                INDEX           Q
                MP              CG              +14
                INCR            BBANK
                EBANK=          UNWC/2
                INDEX           Q
                DXCH            UNWC/2
                EXTEND
                MP              BUF             +1
                INDEX           Q
                DAS             UNWC/2
                CCS             Q
                TCF             UNWCLOOP

                INCR            BBANK
                EBANK=          PIF

STEER?          CA              FLAGWRD2                # IF STEERSW DOWN NO OUTPUTS
                MASK            STEERBIT
                EXTEND
                BZF             RATESTOP

EXVERT          CA              OVFIND                  # IF OVERFLOW ANYWHERE IN GUIDANCE
                EXTEND                                  #   DON'T CALL THROTTLE OR FINDCDUW
                BZF             +6

EXOVFLOW        TC              ALARM                   # SOUND THE ALARM NON-ABORTIVELY.
                OCT             01410

RATESTOP        TC              BANKCALL                # CLEAN UP AFTER LAST FINDCDUW

## Page 817
                CADR            STOPRATE

                TCF             DISPEXIT

GDUMP1          TC              THROTTLE
                TC              INTPRET
                CALL
                                FINDCDUW        -2
                EXIT

#                                                   (CONTINUE TO DISPEXIT)


# ****************************************************************************************************************
# GUIDANCE LOOP DISPLAYS
# ****************************************************************************************************************

DISPEXIT        EXTEND                                  # KILL GROUP 3:  DISPLAYS WILL BE
                DCA             NEG0                    #   RESTORED BY NEXT GUIDANCE CYCLE
                DXCH            -PHASE3

                CS              FLAGWRD8                # IF FLUNDISP SET, NO DISPLAY THIS PASS
                MASK            FLUNDBIT
                EXTEND
                BZF             ENDLLJOB                # TO PICK UP THE TAG

                INDEX           WCHPHOLD
                TCF             WHATDISP

 -2             TC              PHASCHNG                # KILL GROUP 5
                OCT             00035

P63DISPS        CAF             V06N63
DISPCOMN        TC              BANKCALL
                CADR            REGODSPR

ENDLLJOB        TCF             ENDOFJOB

P64DISPS        CA              TREDES                  # HAS TREDES REACHED ZERO?
                EXTEND
                BZF             RED-OVER                # YES:  CLEAR REDESIGNATION FLAG

                CS              FLAGWRD6                # NO:   IS REDFLAG SET?
                MASK            REDFLBIT
                EXTEND
                BZF             REDES-OK                # YES:  DO STATIC DISPLAY

                CAF             V06N64                  # OTHERWISE USE FLASHING DISPLAY
                TC              BANKCALL

## Page 818
                CADR            REFLASHR
                TCF             GOTOPOOH                # TERMINATE
                TCF             P64CEED                 # PROCEED    PERMIT REDESIGNATIONS
                TCF             P64DISPS                # RECYCLE

                TCF             ENDLLJOB                # TO PICK UP THE TAG

P64CEED         CAF             ZERO
                TS              ELINCR1
                TS              AZINCR1

                TC              UPFLAG                  # ENABLE REDESIGNATION LOGIC
                ADRES           REDFLAG

                TCF             ENDOFJOB

RED-OVER        TC              DOWNFLAG
                ADRES           REDFLAG
REDES-OK        CAF             V06N64
                TCF             DISPCOMN


VERTDISP        CAF             V06N60
                TCF             DISPCOMN


# ****************************************************************************************************************
# GUIDANCE FOR VERTICAL DESCENT
# ****************************************************************************************************************

VERTGUID        CCS             WCHVERT
                TCF             DISPEXIT                # POSITIVE   P67, WHICH SKIPS ALL GUIDANCE
                TCF             P66VERT                 # +0

#          THE P65 GUIDANCE EQUATION IS AS FOLLOWS:-

#                           -         -
#                     -     VDGVERT - VGU	   -
#                     ACG = -------------  , WHERE VDGVERT = (-3FPS,0,0)
#                              TAUVERT

P65VERT         EXTEND                                  # NEGATIVE
                DCS             +3FPS
                DXCH            VDGVERT
                TC              INTPRET
                VLOAD           PDDL
                                ZEROVECS
                                VDGVERT
                VDEF            VSU                     # FORM (VDGVERT,0,0), LEAVING DP 0 IN PDL
                                VGU

## Page 819
                V/SC            GOTO
                                TAUVERT
                                AFCCALC1


#          THE R.O.D. EQUATION IS AS FOLLOWS:-

#                            (VDGVERTX - VGUX)/TAUVERT - GMOON
#                    /AFC/ = ---------------------------------
#                                      UNIT/R/ . XNB

P66VERT         XCH             RODCOUNT                # RESTART COULD CAUSE RODCOUNTS TO BE LOST
                EXTEND
                MP              +1FPS
                DAS             VDGVERT
                TC              FASTCHNG
                TC              INTPRET
                DLOAD           DSU
                                VDGVERT
                                VGU
                DDV             DSU
                                TAUROD
                                MOONG
                PDVL            DOT                     # HAVE ACC IN UNITS OF 2(-2) M/CS/CS
                                XNBPIP
                                UNIT/R/
                BDDV            STADR
                STORE           /AFC/
                BOVB            EXIT
                                EXOVFLOW
                TC              THROTTLE
                TCF             DISPEXIT


# ****************************************************************************************************************
# REDESIGNATOR TRAP
# ****************************************************************************************************************

                BANK            21
                SETLOC          F2DPS*21
                BANK

                COUNT*          $$/F2DPS

PITFALL         XCH             BANKRUPT
                EXTEND
                QXCH            QRUPT

                TC              CHECKMM         # IF NOT IN P64, NO REASON TO CONTINUE
                DEC             64

## Page 820
                TCF             RESUME

                EXTEND
                READ            CHAN31
                COM
                MASK            ALL4BITS
                TS              ELVIRA
                CAF             TWO
                TS              ZERLINA
                CAF             FIVE
                TC              TWIDDLE
                ADRES           REDESMON
                TCF             RESUME


# REDESIGNATION MONITOR (INITIATED BY PITFALL)


PREMON1         TS              ZERLINA
PREMON2         CAF             SEVEN
                TC              VARDELAY
REDESMON        EXTEND
                READ            31
                COM
                MASK            ALL4BITS
                XCH             ELVIRA
                TS              L
                CCS             ELVIRA                  # DO ANY BITS APPEAR THIS PASS?
                TCF             PREMON2                 #   Y: CONTINUE MONITOR

                CCS             L                       #   N: ANY LAST PASS?
                TCF             COUNT'EM                #      Y: COUNT 'EM, RESET RUPT, TERMINATE
                CCS             ZERLINA                 #      N: HAS ZERLINA REACHED ZERO YET?
                TCF             PREMON1                 #         N: DIMINISH ZERLINA, CONTINUE
RESETRPT        CAF             BIT12                   #         Y: RESET RUPT, TERMINATE
                EXTEND
                WOR             CHAN13
                TCF             TASKOVER

COUNT'EM        CA              L
                MASK            -AZBIT
                CCS             A
-AZ             CS              AZEACH
                ADS             AZINCR1
                CA              L
                MASK            +AZBIT
                CCS             A
+AZ             CA              AZEACH
                ADS             AZINCR1
                CA              L

## Page 821
                MASK            -ELBIT
                CCS             A
-EL             CS              ELEACH
                ADS             ELINCR1
                CA              L
                MASK            +ELBIT
                CCS             A
+EL             CA              ELEACH
                ADS             ELINCR1
                TCF             RESETRPT


# THESE EQUIVALENCIES ARE BASED ON GSOP CHAPTER 4, REVISION 16 OF P64LM

+ELBIT          =               BIT2                    # -PITCH


-ELBIT          =               BIT1                    # +PITCH


+AZBIT          =               BIT5


-AZBIT          =               BIT6

ALL4BITS        OCT             00063


AZEACH          DEC             .03491                  # 2 DEGREES


ELEACH          DEC             .00873                  # 1/2 DEGREE


# ****************************************************************************************************************
# R.O.D. TRAP
# ************************************************************************

                BANK            20
                SETLOC          RODTRAP
                BANK
                COUNT*          $$/F2DPS                # ****************************************

DESCBITS        MASK            BIT7                    # COME HERE FROM MARKRUPT CODING WITH BIT
                CCS             A                       #   7 OR 6 OF CHANNEL 16 IN A: BIT 7 MEANS
                CS              TWO                     #   - RATE INCREMENT, BIT 6 + INCREMENT
                AD              ONE
                ADS             RODCOUNT

## Page 822
                TCF             RESUME                  # TRAP IS RESET WHEN SWITCH IS RELEASED


                BANK            31
                SETLOC          F2DPS*31
                BANK

                COUNT*          $$/F2DPS

# ****************************************************************************************************************
# DOUBLE PRECISION ROOT FINDER SUBROUTINE (BY ALLAN KLUMPP)
# ****************************************************************************************************************

#                                                         N        N-1
#          ROOTPSRS FINDS ONE ROOT OF THE POWER SERIES A X  + A   X    + ... + A X + A
#                                                       N      N-1              1     0

# USING NEWTON'S METHOD STARTING WITH AN INITIAL GUESS FOR THE ROOT.  THE ENTERING DATA MUST BE AS FOLLOWS:

#                                         A        SP     LOC-3            ADRES FOR REFERENCING PWR COF TABL
#                                         L        SP     N-1              N IS THE DEGREE OF THE POWER SERIES
#                                         MPAC     DP     X                INITIAL GUESS FOR ROOT

#                                         LOC-2N   DP     A(0)
#                                                  ...
#                                         LOC      DP     A(N)
#                                         LOC+2    SP     PRECROOT         PREC RQD OF ROOT (AS FRACT OF 1ST GUESS)

# THE DP RESULT IS LEFT IN MPAC UPON EXIT, AND A SP COUNT OF THE ITERATIONS TO CONVERGENCE IS LEFT IN MPAC+2.
# RETURN IS NORMALLY TO LOC(TC ROOTPSRS)+3.   IF ROOTPSRS FAILS TO CONVERGE IN 32 PASSES, RETURN IS TO LOC+1 AND
# OUTPUTS ARE NOT TO BE TRUSTED.

#          PRECAUTION: ROOTPSRS MAKES NO CHECKS FOR OVERFLOW OR FOR IMPROPER USAGE. IMPROPER USAGE COULD
# PRECLUDE CONVERGENCE OR REQUIRE EXCESSIVE ITERATIONS. AS A SPECIFIC EXAMPLE, ROOTPSRS FORMS A DERIVATIVE
# COEFFICIENT TABLE BY MULTIPLYING EACH A(I) BY I, WHERE I RANGES FROM 1 TO N. IF AN ELEMENT OF THE DERIVATIVE
# COEFFICIENT TABLE = 1 OR > 1 IN MAGNITUDE, ONLY THE EXCESS IS RETAINED. ROOTPSRS MAY CONVERGE ON THE CORRECT
# ROOT NONETHELESS, BUT IT MAY TAKE AN EXCESSIVE NUMBER OF ITERATIONS. THEREFORE THE USER SHOULD RECOGNIZE:

# 1. USER'S RESPONSIBILITY TO ASSURE THAT I X A(I) < 1 IN MAGNITUDE FOR ALL I.

# 2. USER'S RESPONSIBILITY TO ASSURE OVERFLOW WILL NOT OCCUR IN EVALUATING EITHER THE RESIDUAL OR THE DERIVATIVE
#    POWER SERIES.   THIS OVERFLOW WOULD BE PRODUCED BY SUBROUTINE POWRSERS, CALLED BY ROOTPSRS, AND MIGHT NOT
#    PRECLUDE EVENTUAL CONVERGENCE.

# 3. AT PRESENT, ERASABLE LOCATIONS ARE RESERVED ONLY FOR N UP TO 5.  AN N IN EXCESS OF 5 WILL PRODUCE CHAOS.
#    ALL ERASABLES USED BY ROOTPSRS ARE UNSWITCHED LOCATED IN THE REGION FROM MPAC-33 OCT TO MPAC+7.

# 4. THE ITERATION COUNT RETURNED IN MPAC+2 MAY BE USED TO DETECT ABNORMAL PERFORMANCE.

#                                                                         STORE ENTERING DATA, INITLIZE ERASABLES

## Page 823
ROOTPSRS        EXTEND
                QXCH            RETROOT                 # RETURN ADRES
                TS              PWRPTR                  # PWR TABL POINTER
                DXCH            MPAC            +3      # PWR TABL ADRES, N-1
                CA              DERTABLL
                TS              DERPTR                  # DER TABL POINTER
                TS              MPAC            +5      # DER TABL ADRES
                CCS             MPAC            +4      # NO POWER SERIES OF DEGREE 1 OR LESS
                TS              MPAC            +6      # N-2
                CA              ZERO                    # MODE USED AS ITERATION COUNTER. MODE
                TS              MODE                    # MUST BE POS SO ABS WON'T COMP MPAC+3 ETC

                                                        # COMPUTE CRITERION TO STOP ITERATING

                EXTEND
                DCA             MPAC                    # FETCH ROOT GUESS, KEEPING IT IN MPAC
                DXCH            ROOTPS                  # AND IN ROOTPS
                INDEX           MPAC            +3      # PWR TABL ADRES
                CA              5                       # PRECROOT TO A
                TC              SHORTMP                 # YIELDS DP PRODUCT IN MPAC
                TC              USPRCADR
                CADR            ABS                     # YIELDS ABVAL OF CRITERION ON DX IN MPAC
                DXCH            MPAC
                DXCH            DXCRIT                  # CRITERION

                                                        # SET UP DER COF TABL

                EXTEND
                INDEX           PWRPTR
                DCA             3
                DXCH            MPAC                    # A(N) TO MPAC

                CA              MPAC            +4      # N-1 TO A

DERCLOOP        TS              PWRCNT                  # LOOP COUNTER
                AD              ONE
                TC              DMPNSUB                 # YIELDS DERCOF = I X A(I) IN MPAC
                EXTEND
                INDEX           PWRPTR
                DCA             1
                DXCH            MPAC                    # A(I-1) TO MPAC, FETCHING DERCOF
                INDEX           DERPTR
                DXCH            3                       # DERCOF TO DER TABL
                CS              TWO
                ADS             PWRPTR                  # DECREMENT PWR POINTER
                CS              TWO
                ADS             DERPTR                  # DECREMENT DER POINTER
                CCS             PWRCNT
                TCF             DERCLOOP


## Page 824
                                                        # CONVERGE ON ROOT

ROOTLOOP        EXTEND
                DCA             ROOTPS                  # FETCH CURRENT ROOT
                DXCH            MPAC                    # LEAVE IN MPAC
                EXTEND
                DCA             MPAC            +5      # LOAD A, L WITH DER TABL ADRES, N-2
                TC              POWRSERS                # YIELDS DERIVATIVE IN MPAC

                EXTEND
                DCA             ROOTPS
                DXCH            MPAC                    # CURRENT ROOT TO MPAC, FETCHING DERIVTIVE
                DXCH            BUF                     # LEAVE DERIVATIVE IN BUF AS DIVISOR
                EXTEND
                DCA             MPAC            +3      # LOAD A, L WITH PWR TABL ADRES, N-1
                TC              POWRSERS                # YIELDS RESIDUAL IN MPAC

                TC              USPRCADR
                CADR            DDV/BDDV                # YIELDS -DX IN MPAC

                EXTEND
                DCS             MPAC                    # FETCH DX, LEAVING -DX IN MPAC
                DAS             ROOTPS                  # CORRECTED ROOT NOW IN ROOTPS

                TC              USPRCADR
                CADR            ABS                     # YIELDS ABS(DX) IN MPAC
                EXTEND
                DCS             DXCRIT
                DAS             MPAC                    # ABS(DX)-ABS(DXCRIT) IN MPAC

                INCR            MODE                    # INCREMENT ITERATION COUNTER
                CA              MODE
                MASK            BIT4                    # KLUMPP SAYS GIVE UP AFTER EIGHT PASSES
                CCS             A
BADROOT         TC              RETROOT

                CCS             MPAC                    # TEST HI ORDER DX
                TCF             ROOTLOOP
                TCF             TESTLODX
                TCF             ROOTSTOR
TESTLODX        CCS             MPAC            +1      # TEST LO ORDER DX
                TCF             ROOTLOOP
                TCF             ROOTSTOR
                TCF             ROOTSTOR
ROOTSTOR        DXCH            ROOTPS
                DXCH            MPAC
                CA              MODE
                TS              MPAC            +2      # STORE SP ITERATION COUNT IN MPAC+2
                INDEX           RETROOT
                TCF             2

## Page 825

DERTABLL        ADRES           DERCOFN         -3

# ****************************************************************************************************************
# TRASHY LITTLE SUBROUTINES
# ****************************************************************************************************************

INTPRETX        INDEX           WCHPHASE                # SET X1 ON THE WAY TO THE INTERPRETER
                CS              TARGTDEX
                INDEX           FIXLOC
                TS              X1
                TCF             INTPRET


TDISPSET        CA              TTF/8
                EXTEND
                MP              TSCALINV
                DXCH            TTFDISP

                CA              TTF/8
                EXTEND
                MP              SCTTFDSP
                TS              L
                AD              99+LINT
                EXTEND
                BZMF            +11
                CS              L
                AD              -LINT
                EXTEND
                BZMF            +3
                TS              TREDES
                TC              Q

                CA              ZERO
                TCF             -3

                CA              99+LINT
                TCF             -10


# ****************************************************************************************************************
# SPECIALIZED "PHASCHNG" SUBROUTINE
# ****************************************************************************************************************

                EBANK=          PHSNAME2
FASTCHNG        CA              EBANK3                  # SPECIALIZED 'PHASCHNG' ROUTINE
                XCH             EBANK
                DXCH            L
                TS              PHSNAME3
                LXCH            EBANK

## Page 826
                EBANK=          E2DPS
                TC              A


# ****************************************************************************************************************
# PARAMETER TABLE INDIRECT ADDRESSES
# ****************************************************************************************************************

RDG             =               RBRFG
VDG             =               VBRFG
ADG             =               ABRFG
VDG2TTF         =               VBRFG*
ADG2TTF         =               ABRFG*
JDG2TTF         =               JBRFG*

# ****************************************************************************************************************
# LUNAR LANDING CONSTANTS
# ***************************************************************************************************************

3SEC*17         DEC             +3              E2 B-17


10SEC*17        DEC             +10             E2 B-17


20SEC*17        DEC             +20             E2 B-17


30SEC*17        DEC             +30             E2 B-17


TABLTTFL        ADRES           TABLTTF         +3      # ADDRESS FOR REFERENCING TTF TABLE


HIGHESTF        2DEC            +43245          E-4 B-12# THRUST FOR RADIAL CONTROL
TTFSCALE        =               BIT12


TSCALINV        =               BIT4


99+LINT         DEC             +119


-LINT           DEC             -20


SCTTFDSP        DEC             .08                     # RESCALES FROM 2(-17) CS TO WHOLE SECONDS


## Page 827
180DEGS         DEC             +180


1/2DEG          DEC             +.00278


DELTTFAP        DEC             -158            E2 B-17


TAUVERT         2DEC            600             B-14


TAUROD          2DEC            300             B-12


GSCALE          2DEC            100             B-11


3/8DP           2DEC            .375000000


3/4DP           2DEC            .750000000
+1FPS           DEC             .3048           E-2 B+4


+3FPS           2DEC            +0.9144         E-2 B-10


DEPRCRIT        2DEC            -.02            B-2     # DEPRESSION ANGLE CRITERION


PROJMAX         DEC             .42262          B-3     # SIN(25')/8 TO COMPARE WITH PROJ


PROJMIN         DEC             .25882          B-3     # SIN(15')/8 TO COMPARE WITH PROJ


V06N63          VN              0663                    # P63

V06N64          VN              0664                    # P64

V06N60          VN              0660                    # P65, P66, P67

## Page 828
# ****************************************************************************************************************
# ****************************************************************************************************************
