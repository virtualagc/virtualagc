### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LUNAR_LANDING_GUIDANCE_EQUATIONS.agc
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
##              2021-05-30 ABS  DEC -> DEC* for extended address fields.

## Sundance 292

                EBANK=          E2DPS

                COUNT*          $$/F2DPS

# ****************************************************************************************************************
# LUNAR LANDING FLIGHT SEQUENCE TABLES
# ****************************************************************************************************************

# FLIGHT SEQUENCE TABLES ARE ARRANGED BY PHASE.   THEY ARE REFERENCED USING AS AN INDEX THE REGISTER WCHPHASE:
#                                                  WCHPHASE  -1  --->  DISPLAY ROUTINES
#                                                  WCHPHASE  +0  --->  ROUTINE FOR STARTING NEW GUIDANCE PHASES
#                                                  WCHPHASE  +1  --->  GUIDANCE EQUATIONS
#                                                  WCHPHASE  +2  --->  WINDOW VECTOR COMPUTATIONS
#                                                  WCHPHASE  +3  --->  EXIT CRITERION
#                                                  WCHPHASE  +4  --->  POST GUIDANCE EQUATION COMPUTATIONS
#                                                  WCHPHASE  +5  --->  INDICES FOR REFERENCING TARGET PARAMETERS
#                                                  WCHPHASE  +6  --->  AUGMENT FOR TTF/8

# ***************************************************************************************************************

# IGNITION ALGORITHM:
                                                        # -1  NO DISPLAYS
IGNALG          TCF             TTFINCR                 # +0
                TCF             TTF/8CL                 # +1
                TCF             EXGSUB                  # +2
                DEC             0                       # +3
                TCF             CGCALC                  # +4
                OCT             0                       # +5
                DEC             108 E2 B-17             # +6


# BRAKING QUADRATIC:
                TCF             P63DISPS                # -1
BRAKQUAD        TCF             TTFINCR                 # +0
                TCF             TTF/8CL                 # +1
                TCF             EXBRAK                  # +2
                DEC             -20 E2 B-17             # +3
                TCF             CGCALC                  # +4
                OCT             0                       # +5
                DEC             0                       # +6

# BRAKING LINEAR:
                TCF             P63DISPS                # -1
BRAKLING        TCF             LINSET                  # +0
                TCF             LINGUID                 # +1
                TCF             EXBRAK                  # +2
                DEC             -2 E2 B-17              # +3
                TCF             RGVGCALC                # +4
                OCT             0                       # +5
                DEC             0                       # +6

# APPROACH QUADRATIC:
                TCF             P64DISPS                # -1
APPRQUAD        TCF             STARTP64                # +0
                TCF             TTF/8CL                 # +1
                TCF             EXNORM                  # +2
                DEC             -10 E2 B-17             # +3
                TCF             REDESIG                 # +4
                OCT             30                      # +5
                DEC             -158 E2 B-17            # +6

# APPROACH LINEAR:
                TCF             P64DISPS                # -1
APPRLING        TCF             LINSET                  # +0
                TCF             LINGUID                 # +1
                TCF             EXNORM                  # +2
                DEC             -2 E2 B-17              # +3
                TCF             RGVGCALC                # +4
                OCT             30                      # +5
                DEC             0                       # +6

# VERTICAL:
                TCF             VERTDISP                # -1
VERTICAL        TCF             P65START                # +0
                TCF             VERTGUID                # +1
                TCF             EXVERT                  # +2
                OCT             37777                   # +3
                TCF             RGVGCALC                # +4

# ****************************************************************************************************************
# ENTRY POINTS:   ?GUIDSUB FOR THE IGNITION ALGORITHM, LUNLAND FOR SERVOUT
# ****************************************************************************************************************

# IGNITION ALGORITHM ENTRY:  DELIVERS N PASSES OF QUADRATIC QUIDANCE

?GUIDSUB        EXIT
                CAF             ONE                     # N = 2
GUIDSUB         TS              NGUIDSUB
                TCF             GUILDRET


# NORMAL ENTRY:  CONTROL COMES HERE FROM SERVOUT

LUNLAND         TC              2PHSCHNG
                OCT             00035                   # GROUP 5:  RETAIN ONLY PIPA TASK
                OCT             05022                   # GROUP 2:  PROTECT GUIDANCE WITH PRIO 21
                OCT             21000                   #       JUST HIGHER THAN SERVICER'S PRIORITY

                TC              GUILDEN

# ****************************************************************************************************************
# INITIALIZATION FOR THIS PASS
# ****************************************************************************************************************

                COUNT*          $$/F2DPS

GUILDRET        INDEX           WCHPHASE
                CA              5
                TS              TARGTDEX
                COM
                INDEX           FIXLOC
                TS              X1

                EXTEND
                DCA             TPIP
                DXCH            TPIPOLD

                TC              FASTCHNG

                EXTEND
                DCA             PIPTIME
                DXCH            TPIP

                EXTEND
                DCA             TTF/8
                DXCH            TTF/8TMP

                CCS             FLPASS0
                TCF             TTFINCR

BRSPOT1         INDEX           WCHPHASE
                CA              6
                ADS             TTF/8TMP
                INDEX           WCHPHASE
                TCF             0

# ****************************************************************************************************************
# ROUTINES TO START NEW PHASES
# ****************************************************************************************************************

P65START        TC              NEWMODEX
                DEC             65
                CS              TWO
                TS              WCHVERT
                TC              DOWNFLAG                # PERMIT X-AXIS OVERRIDE
                CADR            XOVINFLG

                TCF             TTFINCR


STARTP64        TC              NEWMODEX
                DEC             64
                CA              BIT12                   # ENABLE RUPT10
                EXTEND
                WOR             CHAN13
                TC              DOWNFLAG                # INITIALIZE REDESIGNATION FLAG
                ADRES           REDFLAG
                TCF             TTFINCR

# ****************************************************************************************************************
# SET LINEAR GUIDANCE COEFFICIENTS
# ****************************************************************************************************************

LINSET          TC              INTPRET
                VLOAD           VSU*                    # -        -     -
                                ACG                     # JLING = (ACG - ADG)/TTF
                                ADG,1
                V/SC
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
                STORE           RANGEDSP
                VLOAD           VXV
                                R
                                WM
                VAD             VSR2                    # RESCALE TO UNITS OF 2(9) M/CS
                                V
                STODL           ANGTERM
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

BRSPOT2         INDEX           WCHPHASE
                TCF             4

# ****************************************************************************************************************
# LANDING SITE PERTURBATION EQUATIONS
# ****************************************************************************************************************

REDESIG         TC              FASTCHNG
                CA              FLAGWRD6                # IS REDFLAG SET?
                MASK            REDFLBIT
                CCS             A
                TCF             +3
                TS              ELINCR1
                TS              AZINCR1

                CA              TREDES                  # YES:  HAS TREDES REACHED ZERO?
                EXTEND
                BZF             CGCALC                  # YES:  SKIP REDESIGNATION LOGIC

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

                TC              INTPRET
                SETPD           VLOAD
                                0
                                LAND
                VSU             RTB                     #                 -      -
                                R                       # PUSH DOWN UNIT (LAND - R)
                                NORMUNIT
                MXV             VSL1
                                XNBPIP
                STODL           20D
                                20D
                DMP             BDSU
                                ELINCR
                                24D
                PDDL            VSR1
                                AZINCR
                DAD             PDDL
                                22D
                                24D
                DMP             DAD
                                ELINCR
                                20D
                VDEF            VXM
                                XNBPIP
                PUSH            DLOAD
                                0
                DSU
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
                VSU             RTB
                                R
                                NORMUNIT
                DOT             SL1
                                XNBPIP
                VCOMP           ASIN
                EXIT                                    # LOOKANGL WILL BE COMPUTED AT RGVGCALC

                CAF             360DEGS
                TC              SHORTMP

                CAF             BIT14
                TS              L
                CAF             ZERO
                DAS             MPAC
                DXCH            MPAC
                TC              ALSIGNAG
                TS              GEFF

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

# ***************************************************************************************************************
# ERECT GUIDANCE-STABLE MEMBER TRANSFORMATION MATRIX
# ***************************************************************************************************************

CGCALC          TC              INTPRET
                VLOAD           UNIT
                                LAND

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

#                     HORIZONTAL VELOCITY FOR DISPLAY:

#                                 VHORIZ = 8 ABVAL (0, VG , VG )
#                                                        2    1

#                     DEPRESSION ANGLE FOR DISPLAY:

#                                                        -   -     -
#                                 LOOKANGL = ARCSIN(UNIT(R - LAND).XMBPIP)

RGVGCALC        TC              INTPRET                 # ENTER HERE TO RECOMPUTE RG AND VG
                VLOAD           VSU
                                R                       #           -   -
                                LAND                    # PUSH DOWN R - LAND
                MXV             VSL1
                                CG
                STOVL           RGU
                                ANGTERM
                MXV
                                CG                      # NO SHIFT SINCE ANGTERM IS DOUBLE SIZED
                STORE           VGU
                PDDL            VDEF                    # FORM (0,VG ,VG ) IN UNITS OF 2(10) M/CS
                                ZEROVECS                #           2   1
                ABVAL           SL3
                STODL           VHORIZ                  # VHORIZ FOR DISPLAY DURING P65, P66, P67
                EXIT

BRSPOT3         INDEX           WCHPHASE
                TCF             1

#****************************************************************************************************************
# LINEAR GUIDANCE EQUATION
#****************************************************************************************************************

LINGUID         TC              INTPRET
                VLOAD           VXSC                    # -     -     -
                                JLING                   # ACG = ADG + JLING TTF
                                TTF/8
                VAD*            GOTO
                                ADG,1
                                AFCCALC         +2

#****************************************************************************************************************
# TTF/4 COMPUTATION
#****************************************************************************************************************

TTF/8CL         EXTEND
                INDEX           TARGTDEX
                DCA             JDG2TTF                 # A(3) = 8 JDG  TO TABLTTF
                DXCH            TABLTTF         +6      #             2
                EXTEND
                INDEX           TARGTDEX
                DCA             ADG2TTF                 # A(2) = 6 ADG  TO TABLTTF
                DXCH            TABLTTF         +4      #             2
                EXTEND
                DCA             VGU             +4
                DXCH            MPAC
                CAF             3/4DP
                TC              SHORTMP
                EXTEND
                INDEX           TARGTDEX
                DCA             VDG2TTF
                DAS             MPAC
                DXCH            MPAC                    # A(1) = (6 VGU  + 18 VDG )/8 TO TABLTTF
                DXCH            TABLTTF         +2      #              2         2
                EXTEND
                DCS             RGU             +4
                DXCH            MPAC
                EXTEND
                INDEX           TARGTDEX
                DCA             RDG             +4
                DAS             MPAC
                CAF             3/8
                TC              SHORTMP
                DXCH            MPAC                    # A(0) = -24 (RGU  - RDG )/64 TO TABLTTF
                DXCH            TABLTTF                 #                2      2

                CA              BIT8
                TS              TABLTTF         +10     # FRACTIONAL PRECISION FOR TTF TO TABLE

                EXTEND
                DCA             TTF/8
                DXCH            MPAC                    # LOADS TTF/8 (INITIAL GUESS) INTO MPAC
                EXTEND
                DCA             TABLTTFL
                TC              ROOTPSRS                # YIELDS TTF/8 IN MPAC

                EXTEND
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

QUADGUID        TC              INTPRET
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
                EXIT
                TC              FASTCHNG

                INCR            FLPASS0                 # INCREMENT PASS COUNTER

#                                             (CONTINUE TO EXTLOGIC)

# ****************************************************************************************************************
# PREPARE TO EXIT
# ****************************************************************************************************************

# DECIDE (1) HOW TO EXIT, AND (2) WHETHER TO SWITCH PHASES

EXTLOGIC        INDEX           WCHPHASE
                CS              3
                AD              TTF/8
                EXTEND
                INDEX           WCHPHASE
                BZMF            2

                CA              WCHPHASE                # PREPARE FOR PHASE SWITCHING LOGIC
                TS              WCHPHOLD

                TC              FASTCHNG

                CA              WCHPHOLD
                AD              BIT4
                ZL                                      # +0
                DXCH            WCHPHASE                # ADVANCING WCHPHASE AND RESETTING FLPASS0
                INDEX           WCHPHOLD
                TCF             2

# ****************************************************************************************************************
# ROUTINES FOR EXITING FROM LANDING GUIDANCE

# ****************************************************************************************************************

# 1.        EXGSUB IS THE RETURN WHEN GUIDSUB IS CALLED BY THE IGNITION ALGORITHM.

# 2.        EXBRAK IN THE EXIT USED DURING THE BRAKING PHASE.   IN THIS CASE UNIT(R) IS THE WINDOW POINTING VECTOR.

# 3.        EXNORM IS THE EXIT USED AT OTHER TIMES DURING THE BURN.

#          (EXOVFLOW IS A SUBROUTINE OF EXBRAK AND EXNORM CALLED WHEN OVERFLOW OCCURRED ANYWHERE IN GUIDANCE.)

EXGSUB          CCS             NGUIDSUB
                TCF             GUIDSUB
                INCR            NIGNLOOP
                CS              BIT5
                AD              NIGNLOOP
                EXTEND
                BZMF            +3
                TC              ALARM
                OCT             01412

 +3             TC              INTPRET
                GOTO            
                                DDUMCALC

EXBRAK          TC              INTPRET
                VLOAD           GOTO
                                UNIT/R/
                                STEER?

EXNORM          TC              INTPRET
                VLOAD           VSU
                                LAND
                                R
                RTB
                                NORMUNIT
                STORE           20D                     # UNIT(LAND - R) IS TENTATIVE CHOICE
                VXV             DOT
                                XNBPIP
                                CG              +6
                STORE           18D                     # PROJ 1/8 REAL SIZE
                DSU             BMN
                                PROJMAX
                                +4
                VLOAD           GOTO
                                20D
                                STEER?
                DLOAD
                                18D
                DSU             BPL
                                PROJMIN
                                +4
                VLOAD           GOTO
                                CG              +12D
                                STEER?
                DLOAD           DSU
                                18D
                                PROJMAX
                VXSC            PDDL
                                CG              +12D
                                18D
                DSU             VXSC
                                PROJMIN
                                20D
                VSU
                V/SC
                                PROJDIV

STEER?          STORE           UNWC/2
                BOFF            EXIT                    # IF STEERSW DOWN NO OUTPUTS
                                STEERSW
                                DISPEXIT        -1

EXVERT          CA              OVFIND                  # IF OVERFLOW ANYWHERE IN GUIDANCE
                EXTEND                                  #   DON'T CALL THROTTLE OR FINDCDUW
                BZF             +4

EXOVFLOW        TC              ALARM                   # SOUND THE ALARM NON-ABORTIVELY.
                OCT             01410

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

DISPEXIT        EXTEND                                  # KILL GROUP 2:  DISPLAYS WILL BE
                DCA             NEG0                    #   RESTORED BY NEXT GUIDANCE CYCLE
                DXCH            -PHASE2

                CS              FLAGWRD8                # IF FLUNDISP SET, NO DISPLAY THIS PASS
                MASK            FLUNDBIT
                EXTEND
                BZF             ENDLLJOB                # TO PICK UP THE TAG

                INDEX           WCHPHASE
                TCF             0 -1

P63DISPS        CAF             V06N63
DISPCOMN        TC              BANKCALL
                CADR            GODSPR

ENDLLJOB        TCF             ENDOFJOB

P64DISPS        CS              FLAGWRD6                # NO:   IS REDFLAG SET?
                MASK            REDFLBIT
                EXTEND
                BZF             REDES-OK                # YES:  DO STATIC DISPLAY

                CAF             V06N64                  # OTHERWISE USE FLASHING DISPLAY
                TC              BANKCALL

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

REDES-OK        CAF             V06N64
                TCF             DISPCOMN


VERTDISP        CAF             FOUR
                TC              BANKCALL
                CADR            ALTCHK
                TCF             VERTDSP2

                CAF             V06N60
                TC              BANKCALL
                CADR            REFLASHR
                TCF             GOTOPOOH
                TCF             LANDJUNK
                TCF             VERTDISP

                TCF             ENDLLJOB

VERTDSP2        CAF             V06N60
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

## Sundance 302

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

                BANK            21
                SETLOC          RODTRAP
                BANK
                COUNT*          $$/F2DPS                # ****************************************

DESCBITS        MASK            BIT7                    # COME HERE FROM MARKRUPT CODING WITH BIT
                CCS             A                       #   7 OR 6 OF CHANNEL 16 IN A: BIT 7 MEANS
                CS              TWO                     #   - RATE INCREMENT, BIT 6 + INCREMENT
                AD              ONE
                ADS             RODCOUNT

                TCF             RESUME                  # TRAP IS RESET WHEN SWITCH IS RELEASED

## Sundance 292


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
                TC              RETROOT


DERTABLL        ADRES           DERCOFN         -3

# ****************************************************************************************************************
# TRASHY LITTLE SUBROUTINES
# ****************************************************************************************************************

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
                TS              PHSNAME2
                LXCH            EBANK

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

#          LUNAR LANDING TARGET PARAMETERS
#
ABRFG           2DEC*           -3.43285501     E-5 B+4*
                2DEC*           +0.00000000     E+0 B+4*
                2DEC*           -2.74418853     E-4 B+4*

RBRFG           2DEC*           +3.12375000     E+3 B-24*
                2DEC*           +0.00000000     E+0 B-24*
                2DEC*           -1.07834375     E+4 B-24*

VBRFG           2DEC*           -4.92340088     E-1 B-10*
                2DEC*           +0.00000000     E+0 B-10*
                2DEC*           +1.80714798     E+0 B-10*

VBRFG*          2DEC*           +4.06608200     E+0 B-10*
ABRFG*          2DEC*           -1.64651359     E-3 B+4*
JBRFG*          2DEC*           -2.69203326     E-8 B+18*

AAPFG           2DEC*           +1.52399999     E-6 B+4*
                2DEC*           +0.00000000     E+0 B+4*
                2DEC*           -1.98119999     E-5 B+4*

RAPFG           2DEC*           +2.35092239     E+1 B-24*
                2DEC*           +0.00000000     E+0 B-24*
                2DEC*           -5.28319999     E-1 B-24*

VAPFG           2DEC*           -9.44879999     E-3 B-10*
                2DEC*           +0.00000000     E+0 B-10*
                2DEC*           +3.96239999     E-3 B-10*

VAPFG*          2DEC*           +8.91539999     E-3 B-10*
AAPFG*          2DEC*           -1.18871999     E-4 B+04*
JAPFG*          2DEC*           +8.37250411     E-8 B+18*

TABLTTFL        ADRES           TABLTTF         +3      # ADDRESS FOR REFERENCING TTF TABLE
                DEC             2                       # DEGREE - ONE


TSCALINV        =               BIT4


99+LINT         DEC             +119


-LINT           DEC             -20


SCTTFDSP        DEC             .08                     # RESCALES FROM 2(-17) CS TO WHOLE SECONDS


360DEGS         DEC             +360


TAUVERT         2DEC            600             B-14


TAUROD          2DEC            300             B-12


GSCALE          2DEC            100             B-11


3/8             DEC             .375000000


2/3DP           2DEC            .666666667


3/4DP           2DEC            .750000000


WMREF           2DEC            0.0
                2DEC*           .26616994890062991 E-7 B+18* # RAD/CS.
                2DEC            0.0


MOONG           2DEC            -1.6226         E-4 B2


+1FPS           DEC             .3048           E-2 B+4


+3FPS           2DEC            +0.9144         E-2 B-10


+5FPS           2DEC            +1.524          E-2 B-10


DEPRCRIT        2DEC            -.02            B-2     # DEPRESSION ANGLE CRITERION


PROJMAX         2DEC            .42262          B-3     # SIN(25')/8 TO COMPARE WITH PROJ


PROJMIN         2DEC            .25882          B-3     # SIN(15')/8 TO COMPARE WITH PROJ


PROJDIV         2DEC            .1638           B-3


V06N63          VN              0663                    # P63

V06N64          VN              0664                    # P64

V06N60          VN              0660                    # P65, P66, P67

# ****************************************************************************************************************
# ****************************************************************************************************************
