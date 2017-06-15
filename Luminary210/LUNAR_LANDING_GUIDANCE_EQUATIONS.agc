### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LUNAR_LANDING_GUIDANCE_EQUATIONS.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 794-830
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-12-02 HG   Transcribed
##              2016-12-07 HG   Fix P00 -> POO
##              2016-12-10 HG   add missing CCS MPAC
##                                          EXTEND
##                              fix opcode CAF -> TC
##		2016-12-25 RSB	Comment-text proofed using ProoferComments
##				and corrected errors found.
##		2017-03-10 RSB	Comment-text fixes noted while transcribing Luminary 116.
##		2017-03-16 RSB	Comment-text fixes identified in 5-way
##				side-by-side diff of Luminary 69/99/116/131/210.

## Page 794
                EBANK=          E2DPS

                COUNT*          $$/F2DPS

# ===================================================================================================================
# LUNAR LANDING FLIGHT SEQUENCE TABLES
# ===================================================================================================================

# FLIGHT SEQUENCE TABLES ARE ARRANGED BY FUNCTION.   THEY ARE REFERENCED USING AS AN INDEX THE REGISTER WCHPHASE:

#                                                     WCHPHASE  =  -1  --->  IGNALG
#                                                     WCHPHASE  =   0  --->  BRAKQUAD
#                                                     WCHPHASE  =   1  --->  APPRQUAD
#                                                     WCHPHASE  =   2  --->  VERTICAL

#====================================================================================================================

# ROUTINES FOR STARTING NEW GUIDANCE PHASES:

                TCF             TTFINCR                 # IGNALG
NEWPHASE        TCF             TTFINCR                 # BRAKQUAD
                TCF             STARTP64                # APPRQUAD
                TCF             STARTP66                # VERTICAL
#

# PRE-GUIDANCE COMPUTATIONS:

                TCF             CALCRGVG                # IGNALG
PREGUIDE        TCF             RGVGCALC                # BRAKQUAD
                TCF             REDESIG                 # APPRQUAD
#

# GUIDANCE EQUATIONS:

                TCF             TTF/8CL                 # IGNALG
WHATGUID        TCF             TTF/8CL                 # BRAKQUAD   **** HOBSON'S CHOICE? ****
                TCF             TTF/8CL                 # APPRQUAD
#

# POST GUIDANCE EQUATION COMPUTATIONS:

                TCF             CGCALC                  # IGNALG
AFTRGUID        TCF             EXTLOGIC                # BRAKQUAD
                TCF             EXTLOGIC                # APPRQUAD

## Page 795
# WINDOW VECTOR COMPUTATIONS:

                TCF             EXGSUB                  # IGNALG
WHATEXIT        TCF             EXBRAK                  # BRAKQUAD
                TCF             EXNORM                  # APPRQUAD
#

# DISPLAY ROUTINES:

WHATDISP        TCF             P63DISPS                # BRAKQUAD
                TCF             P64DISPS                # APPRQUAD
                TCF             VERTDISP                # VERTICAL
#

# ALARM ROUTINE FOR TTF COMPUTATION:

                TCF             1406POO                 # IGNALG
WHATALM         TCF             1406ALM                 # BRAKQUAD
                TCF             1406ALM                 # APPRQUAD
#

# INDICES FOR REFERENCING TARGET PARAMETERS:

                OCT             0                       # IGNALG
TARGTDEX        OCT             0                       # BRAKQUAD
                OCT             2                       # APPRQUAD

## Page 796

## The suffixed ':' at the end of the third line below is '=' in the original
## printout.  It is a workaround for our proof-reading system.
# ================================================================================================================
# ENTRY POINTS:  ?GUIDSUB FOR THE IGNITION ALGORITHM, LUNLAND FOR SERVOUT
# ===============================================================================================================:

# IGNITION ALGORITHM ENTRY:  DELIVERS N PASSES OF QUADRATIC QUIDANCE

?GUIDSUB        EXIT
                CAF             TWO                     # N = 3
                TS              NGUIDSUB
                TCF             GUILDRET

GUIDSUB         TS              NGUIDSUB                # ON SUCEEDING PASSES SKIP TTFINCR
                TCF             CALCRGVG

# NORMAL ENTRY:  CONTROL COMES HERE FROM SERVOUT

LUNLAND         TC              PHASCHNG
                OCT             00035                   # GROUP 5:  RETAIN ONLY PIPA TASK
                CA              FLAGWRD5                # HAS THROTTLE-UP COME YET?
                MASK            ZOOMBIT
                EXTEND
                BZF             DISPEXIT        +3      # NO:   DO DISPLAYS ONLY

                TC              PHASCHNG                # YES:  DO GUIDANCE
                OCT             05023
                OCT             20000

## Page 797
# ================================================================================================================
# GUILDENSTERN (AUTO-MODES MONITOR - R13)
# SELECT P66 WHEN THE ROD SWITCH HAS BEEN MANIPULATED IN THE ATTITUDE HOLD MODE
# ================================================================================================================

                COUNT*          $$/R13

GUILDEN         CS              MODREG                  # ARE WE ALREADY IN P66?
  STERN         AD              DEC66
                EXTEND
                BZF             RE-IN66?                # Y: GO SEE IF WE SHOULD RE-INITIALIZE P66

                CAF             BIT13                   # N: ATTITUDE HOLD?
                EXTEND
                RAND            CHAN31
                CCS             A
                TCF             GUILDRET                # N: CONTINUE P63 OR P64

                CA              RODCOUNT                # Y: ANY ROD COMMANDS?
                EXTEND
                BZF             GUILDRET                # N: CONTINUE P63 OR P64

# INITIALIZE P66

STARTP66        TC              FASTCHNG                # Y: START P66
                TC              NEWMODEX
DEC66           DEC             66

                EXTEND
                DCA             HDOTDISP                # SET DESIRED ALTITUDE RATE TO THE
                DXCH            VDGVERT                 #     CURRENTLY DISPLAYED ALTITUDE RATE

                TC              UPFLAG                  # SET FLAG TO CONTINUE P66 HORIZONTAL
                ADRES           P66PROFL                #    UNTIL 'PROCEED' AFTER TOUCHDOWN

                CS              TOOFEW                  # INITIALIZE CNTTHROT TO -TOOFEW
                TS              CNTTHROT

# P66 RE-INITIALIZATION WHEN RODFLAG RESET - P66 INITIALIZATION CONTINUED

RE-IN66         TC              INTPRET
                VLOAD           VXV                     # COMPUTE HORIZONTAL VELOCITY COMMAND
                                WM                      # MOON'S ANGULAR RATE IN 2(-17)RAD/CS
                                R                       # LM POSITION IN 2(24)M
                STORE           VHZC
                TLOAD           DCOMP
                                TEMX
                STOVL           OLDPIPAX                # NOTE: VECTOR INIT OF SP OLDPIPA'S OVER-
                                ZEROVECS                #    LAPS ADJACENT DELVROD.  THUS INIT
                STODL           DELVROD                 #    DELVROD AFTER OLDPIPA'S

## Page 798
                                RODSCALE
                STODL           RODSCAL1

                                PIPTIME                 # SHOW THAT LAST P66 WAS, IN EFFECT,
                STORE           LASTTPIP                #    PERFORMED AT PIPTIME

                EXIT

                TC              BANKCALL                # REFER CURRENT PIPAX READING TO THE CM:
                FCADR           DEIMUBOB                #    ALAS, OMEGAQ AT PIPTIME NOT AVAILABLE

                CAF             ZERO
                TS              FCOLD
                TS              FWEIGHT
                TS              FWEIGHT         +1

                CAF             TWO                     # WCHPHOLD=2 --> VERTICAL  PHASE
                TS              WCHPHOLD

                TS              WCHPHASE                # ***DOES ANYONE SEE ANY NEED FOR THIS?***

                TC              DOWNFLAG                # PERMIT X-AXIS OVERRIDE
                ADRES           XOVINFLG                # SHOULD DO INTERPRETIVELY TO SAVE A WORD

                TC              UPFLAG                  # TERMINATE TERRAIN MODEL
                ADRES           NOTERFLG                # SHOULD DO INTERPRETIVELY TO SAVE A WORD

                TC              UPFLAG                  # P66 INITIALIZATION COMPLETE
                ADRES           RODFLAG

                TCF             P66

RE-IN66?        CA              FLAGWRD1                # RE-INITIALIZE P66?
                MASK            RODFLBIT
                EXTEND
                BZF             RE-IN66                 # Y
                                                        # N
                TCF             P66

## Page 799
# ===============================================================================================================
# INITIALIZATION FOR THIS PASS
# ===============================================================================================================

                COUNT*          $$/F2DPS

GUILDRET        CAF             ZERO
                TS              RODCOUNT

                EXTEND
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

STARTP64        TC              NEWMODEX
                DEC             64
                CA              DELTTFAP                # AUGMENT TTF/8
                ADS             TTF/8TMP
                CAF             P64DB
                TS              DB
                TC              DOWNFLAG                # INITIALIZE REDESIGNATION FLAG
                ADRES           REDFLAG

                CA              LRWH1                   # PUT P64 LR WEIGHTING FUNCTION INTO
                TS              LRWH                    # LRWH SO LR UPDATES ARE DONE PROPERLY
#               (CONTINUE TO TTFINCR)

# ****************************************************************************************************************
# INCREMENT TTF/8, UPDATE LAND FOR LUNAR ROTATION, DO OTHER USEFUL THINGS
# ****************************************************************************************************************

## Page 800
#
#          TTFINCR COMPUTATIONS ARE AS FOLLOWS:-

#                    TTF/8 UPDATED FOR TIME SINCE LAST PASS:

#                               TTF/8 = TTF/8 + (TPIP - TPIPOLD)/8

#                    LANDING SITE VECTOR UPDATED FOR LUNAR ROTATION:

#                               -                  -      -                      -
#                               LAND = /LAND/ UNIT(LAND - LAND(TPIP - TPIPOLD) * WM)

#                    SLANT RANGE TO LANDING SITE, FOR DISPLAY:

#                                                -      -
#                               RANGEDSP = ABVAL(LAND - R)

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
                STODL           LANDTEMP
                EXIT

                DXCH            MPAC
                DAS             TTF/8TMP                # NOW HAVE INCREMENTED TTF/8 IN TTF/8TMP

                TC              FASTCHNG

                EXTEND
                DCA             TTF/8TMP
                DXCH            TTF/8

                TC              TDISPSET

                CAF             PRIO31                  # TEMPORARILY OVER-PRIO CHARIN
                TC              PRIOCHNG

                TC              INTPRET
                VLOAD           VAD                     # ADD IN CORRECTION FROM NOUN 69
                                LANDTEMP

## Page 801
                                DLAND
                STORE           LAND
                ABVAL                                   # RECOMPUTE /LAND/
                STORE           /LAND/
                EXIT

                TC              FASTCHNG                # SINCE REDESIG MAY CHANGE LANDTEMP

                CAF             EBANK5
                EBANK=          DLAND
                TS              EBANK
                CAF             ZERO                    # ZERO N 69 REGISTERS
                TS              DLAND
                TS              DLAND           +1
                TS              DLAND           +2
                TS              DLAND           +3
                TS              DLAND           +4
                TS              DLAND           +5
                CAF             EBANK7
                EBANK=          TREDES
                TS              EBANK

                CAF             PRIO20
                TC              PRIOCHNG

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

## Page 802
                TS              AZINCR1
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

## Page 803
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
                STOVL           VGU
                                R                       #           -   -
                VSU             PUSH                    # PUSH DOWN R - LAND

## Page 804
                                LAND
                MXV             VSL1
                                CG
                STODL           RGU
                                MPAC            +5
                STOVL           RANGEDSP                # SM Z-AXIS RANGE FOR DISPLAY IN N68
                RTB             DOT                     # NOW IN MPAC IS SINE(LOOKANGL)/4
                                NORMUNIT
                                XNBPIP
                EXIT

                CA              FIXLOC                  # RESET PUSH DOWN POINTER
                TS              PUSHLOC

                CA              MPAC                    # COMPUTE LOOKANGL ITSELF
                DOUBLE
                TC              BANKCALL
                CADR            SPARCSIN        -1
                AD              1/2DEG
                AD              ELBIAS                  # BIAS LPD ANGLE FOR WINDOW BENDING
                EXTEND
                MP              180DEGS
                TS              LOOKANGL                # LOOKANGL FOR DISPLAY DURING P64

BRSPOT3         INDEX           WCHPHASE
                TCF             WHATGUID

# ****************************************************************************************************************
# TTF/8 COMPUTATION
# ****************************************************************************************************************

TTF/8CL         CA              WCHPHASE
                TC              INTPRETX
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
                                RDG +4,1                #              2         2
                DSU             DMP
                                RGU             +4
                                3/8DP
                STORE           TABLTTF                 # A(0) = -24 (RGU  - RDG )/64 TO TABLTTF
                EXIT                                    #                2      2

## Page 805

                CA              BIT8
                TS              TABLTTF         +10     # FRACTIONAL PRECISION FOR TTF TO TABLE

                EXTEND
                DCA             TTF/8
                DXCH            MPAC                    # LOADS TTF/8 (INITIAL GUESS) INTO MPAC
                CAF             TWO                     # DEGREE - ONE
                TS              L
                CAF             TABLTTFL
                TC              ROOTPSRS                # YIELDS TTF/8 IN MPAC
                INDEX           WCHPHASE
                TCF             WHATALM

                EXTEND                                  # GOOD RETURN
                DCA             MPAC                    # FETCH TTF/8 KEEPING IT IN MPAC
                DXCH            TTF/8                   # CORRECTED TTF/8

                TC              TDISPSET

#               (CONTINUE TO QUADGUID)

# ****************************************************************************************************************
# MAIN GUIDANCE EQUATION
# ****************************************************************************************************************

#                      AS PUBLISHED:-

#                                               -     -        -     -
#                                 -     -     6(VDG + VG)   12(RDG - RG)
#                                 ACG = ADG + ----------- + ------------
#                                                 TTF        (TTF)(TTF)

#                      AS HERE PROGRAMMED:-

#                                             -     -
#                                      3 (1/4(RDG - RG)   -     - )
#                                      - (------------- + VDG + VG)
#                                -     4 (    TTF/8               )   -
#                                ACG = ---------------------------- + ADG
#                                                 TTF/8

QUADGUID        CS              TTF/8
                AD              LEADTIME                # LEADTIME IS A NEGATIVE NUMBER
                AD              POSMAX                  # SAFEGUARD THE COMPUTATIONS THAT FOLLOW
                TS              L                       #   BY FORCING -TTF+LEADTIME > OR = ZERO
                CS              L
                AD              L
                ZL
                EXTEND

## Page 806
                DV              TTF/8
                TS              BUF                     # - RATIO OF LAG-DIMINISHED TTF TO TTF
                EXTEND
                SQUARE
                TS              BUF             +1
                AD              BUF
                XCH             BUF             +1      # RATIO SQUARED - RATIO
                AD              BUF             +1
                TS              MPAC                    # COEFFICIENT FOR VGU TERM
                AD              BUF             +1
                INDEX           FIXLOC
                TS              26D                     # COEFFICIENT FOR RDG-RGU TERM
                AD              BUF             +1
                INDEX           FIXLOC
                TS              28D                     # COEFFICIENT FOR VDG TERM
                AD              BUF
                AD              POSMAX
                AD              BUF             +1
                AD              BUF             +1
                INDEX           FIXLOC
                TS              30D                     # COEFFICIENT FOR ADG TERM

                CAF             ZERO
                TS              MODE

                CA              WCHPHASE
                TC              INTPRETX
                VXSC            PDDL
                                VGU
                                28D
                VXSC*           RTB
                                VDG,1
                                ZEROMID
                PDVL*           RTB
                                RDG,1
                                ZEROMID
                VSU             V/SC
                                RGU
                                TTF/8
                VSR2            VXSC
                                26D
                VAD             VAD
                V/SC            VXSC
                                TTF/8
                                3/4DP
                PDDL            VXSC*
                                30D
                                ADG,1
                RTB             VAD
                                ZEROMID

## Page 807
AFCCALC1        VXM             VSL1                    # VERTGUID COMES HERE
                                CG
                PDVL            V/SC
                                GDT/2
                                GSCALE
                BVSU            STADR
                STORE           UNFC/2                  # UNFC/2 NEED NOT BE UNITIZED
                ABVAL
AFCCALC2        STODL           /AFC/                   # MAGNITUDE OF AFC FOR THROTTLE
                                UNFC/2                  # VERTICAL COMPONENT
                DSQ             PDDL
                                UNFC/2          +2      # OUT-OF-PLANE
                DSQ             PDDL
                                HIGHESTF
                DDV             DSQ
                                MASS                    #                        2    2     2
                DSU             DSU                     # AMAXHORIZ = SQRT(ATOTAL - A  -  A  )
                BPL             DLOAD                   #                            1     0
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

# ****************************************************************************************************************
# NEW PHASE NOW?
# ****************************************************************************************************************

EXTLOGIC        INDEX           WCHPHASE                # IS TTF NEARER ZERO THAN CRITERION?
                CA              TENDBRAK
                AD              TTF/8
                EXTEND
                BZMF            CGCALC                  # NO

                TC              FASTCHNG                # YES:  INCREMENT WCHPHASE, ZERO FLPASS0

                CA              WCHPHOLD
                AD              ONE

## Page 808
                TS              WCHPHASE
                CAF             ZERO
                TS              FLPASS0

#               (CONTINUE TO CGCALC)

# ***************************************************************************************************************
# ERECT GUIDANCE-STABLE MEMBER TRANSFORMATION MATRIX
# ***************************************************************************************************************

CGCALC          CA              WCHPHOLD
                TC              INTPRETX
                DLOAD*          EXIT
                                TCGFBRAK,1
                CA              TTF/8
                TS              L
                DAS             MPAC
                CCS             MPAC            +1
                CCS             MPAC
                TCF             EXITSPOT
                TCF             EXITSPOT
                NOOP

                TC              INTPRET
                VLOAD           UNIT
                                LAND
                STODL           CG
                                TTF/8
                DMP*            VXSC
                                GAINBRAK,1              # NUMERO MYSTERIOSO
                                ANGTERM
                VAD
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

EXITSPOT        INDEX           WCHPHOLD
                TCF             WHATEXIT

# ****************************************************************************************************************

## Page 809
# ROUTINES FOR EXITING FROM LANDING GUIDANCE
# ****************************************************************************************************************

# 1.        EXGSUB IS THE RETURN WHEN GUIDSUB IS CALLED BY THE IGNITION ALGORITHM.

# 2.        EXBRAK IN THE EXIT USED DURING THE BRAKING PHASE.  IN THIS CASE UNIT(R) IS THE WINDOW POINTING VECTOR.

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

## Page 810

                CS              MPAC                    # GET COEFFICIENT FOR CG +14
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

                CA              AZBIAS                  # SET OUTER GIMBAL
                TS              OGABIAS                 #   ANGLE BIAS FOR WINDOW BENDING

                INCR            BBANK
                EBANK=          PIF

STEER?          CA              OVFIND                  # OVERFLOW?
                EXTEND
                BZF             STEERSW?                # N: CHECK STEERSW

                TC              OVFDESC                 # Y: REMEDIAL ACTION AND
                TCF             DISPEXIT                #    SKIP ISSUANCE OF CMDS. NO STEERSW CHK

STEERSW?        CS              FLAGWRD2                # IS STEERSW UP?
                MASK            STEERBIT

## Page 811
                EXTEND
                BZF             THRTCALL                # Y: ISSUE GUIDANCE CMDS

RATESTOP        INHINT                                  # N: REMEDIAL ACTION
                TC              IBNKCALL                #    AND
                FCADR           STOPRATE                #    SKIP ISSUANCE OF CMDS
                RELINT
                TCF             DISPEXIT

GDUMP1          =               THRTCALL
THRTCALL        TC              THROTTLE
                TC              FASTCHNG
                TC              INTPRET
                CALL
                                FINDCDUW        -2
                EXIT

#               (CONTINUE TO DISPEXIT)

# ****************************************************************************************************************
# GUIDANCE LOOP DISPLAYS
# ****************************************************************************************************************

DISPEXIT        EXTEND                                  # KILL GROUP 3:   DISPLAYS WILL BE
                DCA             NEG0                    #   RESTORED BY NEXT GUIDANCE CYCLE
                DXCH            -PHASE3

ENDLLJOB        =               DISPEXIT        +3

DISPEX66        =               DISPEXIT        +3
 +3             CS              FLAGWRD8                # IF FLUNDISP IS SET, NO DISPLAY THIS PASS
                MASK            FLUNDBIT
                EXTEND
                BZF             ENDOFJOB

                INDEX           WCHPHOLD
                TCF             WHATDISP

P63DISPS        TC              VACRLEAS
                CS              FLGWRD11                # HAVE LR UPDATES BEEN PERMITTED?
                MASK            LRINHBIT
                EXTEND
                BZF             N63STAT                 # YES: DO STATIC DISPLAY

                CAF             V06N63                  # NO:   FLASH NOUN 63, CORRECT RESPONSE IS
                TC              BANKCALL                #         V57E WHICH STOPS THE FLASHING
                CADR            REFLASH
                TC              ENDOFJOB                # TERMINATE  IGNORE AND KEEP FLASHING

## Page 812
                TC              ENDOFJOB                # PROCEED    IGNORE AND KEEP FLASHING
                TC              ENDOFJOB                # ENTER      IGNORE AND KEEP FLASHING

N63STAT         CAF             V06N63
DISPCOMN        TC              BANKCALL
                CADR            REGODSP

P64DISPS        CA              TREDES                  # HAS TREDES REACHED ZERO?
                EXTEND
                BZF             RED-OVER                # YES:  CLEAR REDESIGNATION FLAG

                CS              FLAGWRD6                # NO:   IS REDFLAG SET?
                MASK            REDFLBIT
                EXTEND
                BZF             REDES-OK                # YES:  DO STATIC DISPLAY

                TC              VACRLEAS
                CAF             V06N64                  # OTHERWISE USE FLASHING DISPLAY
                TC              BANKCALL
                CADR            REFLASH
                TCF             GOTOPOOH                # TERMINATE
                TCF             P64CEED                 # PROCEED     PERMIT REDESIGNATIONS
                TCF             P64DISPS                # RECYCLE

P64CEED         CAF             ZERO
                TS              ELINCR1
                TS              AZINCR1

                INHINT                                  # ENABLE RUPT 10 FOR REDESIGNATIONS
                TC              C13STALL
                CAF             BIT12
                EXTEND
                WOR             CHAN13

                TC              UPFLAG                  # ENABLE REDESIGNATION LOGIC
                ADRES           REDFLAG

                TCF             ENDOFJOB

RED-OVER        TC              DOWNFLAG
                ADRES           REDFLAG
REDES-OK        TC              VACRLEAS
                CAF             V06N64
                TCF             DISPCOMN


VERTDISP        TC              VACRLEAS
                CAF             V06N60
                TC              BANKCALL
                CADR            REFLASH

## Page 813
                TCF             GOTOPOOH                # TERMINATE
                TCF             STOPFIRE                # PROCEED
                TCF             STOPFIRE                # V32E

STOPFIRE        TC              DOWNFLAG
                ADRES           P66PROFL		# FLAG TO STOP P66 HORIZONTAL
                TCF             ENDOFJOB

THROT66         TC              THROTTLE        +3
                INCR            CNTTHROT                # COUNT ONE THROTTLE COMPLETION

                TCF             DISPEX66

## Page 814
## The ':' suffixed in the 2nd dividing line below is an '=' in the original printout.  
## The change is a workaround for our proof-reading system.
# ================================================================================================================
# GUIDANCE FOR P66
# ===============================================================================================================:

#          THE P66 HORIZONTAL (HZ) EQUATION IS:

#                 UNFC/2X = GHZ

#                 UNFC/2Y = (LIMIT AHZLIM)(-QHZ UNFC/2Y   -(VY-VHZCY)/TAUHZ)
#                                                      I-1

#                 UNFC/2Z = (LIMIT AHZLIM)(-QHZ UNFC/2Z   -(VZ-VHZCZ)/TAUHZ)
#                                                      I-1

#          WHERE  GHZ IS LUNAR GRAVITY
#                 QHZ AND 1/TAUHZ ARE GAIN CONSTANTS
#                 VHZCY AND VHZCZ ARE THE Y AND Z COMPONENTS OF COMMANDED
#                    VELOCITY, PLATFORM COORDINATES. THESE ARE INITIALIZED
#                    TO MOONRATE
#                 (LIMIT AHZLIM) INDICATES THE CONTENT OF THE SUBSEQUENT
#                    PARENTHESES IS MAGNITUDE LIMITED TO AHZLIM

P66             TC              PHASCHNG                # TERMINATE GROUP 3
                OCT             00003

                TC              INTPRET
                RTB             DSU                     # IS THERE TIME FOR P66?
                                LOADTIME
                                PIPTIME
                BDSU            BPL
                                2LATE466
                                P66HZ                   # Y: DOIT
                CLEAR           EXIT                    # N: OMIT
                                RODFLAG

                CS              TOOFEW                  # INITIALIZE CNTTHROT TO TOOFEW AND LOAD
                XCH             CNTTHROT                # ACCUMULATOR WITH ITS PREVIOUS CONTENTS
                EXTEND                                  # TOO FEW THROTTLINGS SINCE LAST OMISSION?
                BZMF            OMITWALM

                TCF             DISPEX66                # N: PERMIT OMISSION SANS ALARM

OMITWALM        INHINT
                TC              BANKCALL
                CADR            STOPRATE
                TC              ALARM                   # Y: PERMIT OMISSION WITH ALARM
                OCT             01466

                TCF             DISPEX66

## Page 815
# ======================================================================================================
# P66 HORIZONTAL CHANNELS
# ======================================================================================================

                SETLOC          P66LOC
                BANK
                COUNT*          $$/F2DPS

P66HZ           VLOAD           VXSC
                                UNFC/2                  # P63, P64, & P66 UNITS 2(-4)M/CS/CS
                                QHZ
                PDVL            VSU
                                VHZC                    # IN 2(7)M/CS
                                V                       # IN 2(7)M/CS
                V/SC            VSU                     # YIELDS UNLIM HZ ACCEL CMD, 2(-4)M/CS/CS
                                TAUHZ                   # IN 2(1))CS
                EXIT

                CA              PRIO21                  # ASSURE THIS SERVICER JOB ENDS
                TC              PRIOCHNG                # BEFORE NEXT SERVICER JOB BEGINS

                CA              GHZ
                TS              MPAC                    # X COMPONENT = G

                CA              EBANK5
                TS              EBANK
                EBANK=          END-E5

                LXCH            MPAC            +3
                CA              AHZLIM
                TC              BANKCALL
                FCADR           LIMITSUB
                TS              MPAC            +3      # Y COMPONENT LIMITED TO AHZLIM

                LXCH            MPAC            +5
                CA              AHZLIM
                TC              BANKCALL
                FCADR           LIMITSUB
                TS              MPAC            +5      # Z COMPONENT LIMITED TO AHZLIM

                CA              EBANK7
                TS              EBANK
                EBANK=          END-E7

                CA              OVFIND                  # OVERFLOW?
                EXTEND
                BZF             ENGARM?                 # N: KEEP CHECKING
                TC              BANKCALL                # Y: TAKE REMEDIAL ACTION
                FCADR           OVFDESC                 #    AND
                TCF             P66VERT                 #    SKIP ISSUANCE OF HZ CMDS

## Page 816
ENGARM?         CA              BIT3                    # IS ENGINE ARM SWITCH STILL ON?
                EXTEND
                RAND            CHAN30
                EXTEND
                BZF             CDUWHZ                  # Y: ISSUE HZ CMDS

                CA              FLAGWRD0                # N: HAVE WE PROCEEDED AFTER TOUCHDOWN?
                MASK            P66PROBT
                EXTEND
                BZF             ASTROPRO                # Y: PREVENT RCS FIRINGS
CDUWHZ          TC              INTPRET                 # N: ISSUE HZ CMDS
                STORE           UNFC/2                  # MUST STORE FOR SUCCEEDING PASS
                CALL
                                FINDCDUW
                EXIT

                TCF             P66VERT

ASTROPRO        CA              IDLADR                  # Y: PREVENT RCS JET FIRINGS
                TS              T5ADR                   #    AND
                TCF             P66VERT                 #    SKIP HZ CMDS, BUT CONTINUE DISPLAYS

# ================================================================================================================
# P66 VERTICAL CHANNEL
# ================================================================================================================

RODTASK         CA              PRIO22                  # BUMPS ALL OF SERVICER JOB EXCEPT RODCOMP
                TC              FINDVAC
                EBANK=          DVCNTR
                2CADR           RODCOMP
                TCF             TASKOVER

P66VERT         CA              1SEC
                TC              TWIDDLE
                ADRES           RODTASK

RODCOMP         CA              PRIO23                  # LET ONLY ONE JOB THRU RODCOMP AT A TIME
                TC              PRIOCHNG

                INHINT

                CAF             ZERO
                XCH             RODCOUNT
                EXTEND
                MP              RODSCAL1
                DAS             VDGVERT                 # UPDATE DESTRED ALTITUDE RATE.

MANTHRT?        CAF             BIT4
                MASK            CHANBKUP

## Page 817
                CCS             A
                TCF             RODCOMPA                # IGNORE CHAN 30 BIT 5. ASSUME AUTO THROT

                CAF             BIT5                    # ARE WE IN AUTO THROTTLE?
                EXTEND
                RAND            CHAN30
                EXTEND
                BZF             RODCOMPA                # Y: CONTINUE ROD

                EXTEND                                  # N: RESET VDGVERT TO CURRENT HDOT
                DCA             HDOTDISP
                DXCH            VDGVERT

# READ THE PIPAS FOR P66

RODCOMPA        EXTEND
                DCA             PIPAX
                DXCH            OLDPIPAX                # CURRENT PIPA READINGS INTO OLDPIPAX,Y,Z
                DXCH            RUPTREG1                # SAVE PRIOR READINGS IN RUPTREG1,2,3
                CA              PIPAZ
                XCH             OLDPIPAZ
                XCH             RUPTREG3

                EXTEND                                  # SNAPSHOT TIME OF PIPA READING.
                DCA             TIME2
                DXCH            THISTPIP

                TC              DEIMUBOB                # REFER CURRENT PIPAX READING TO THE CM

# COMPUTE DELV SINCE PIPTIME. RETURN FROM DEIMUBOB WITH CORRECTED OLDPIPAX IN A
                                                        # CURRENT P66 PIPA
                AD              PIPATMPX                # + PIPA BY PIPASR IF B4 COPYCYCL, 0 AFTER
                TS              MPAC                    # = DELV SINCE VALIDITY OF V, 2(14)CM/SEC
                CA              OLDPIPAY
                AD              PIPATMPY
                TS              MPAC            +3
                CA              OLDPIPAZ
                AD              PIPATMPZ
                TS              MPAC            +5

# COMPUTE DELV SINCE THE LAST P66 PASS

                CS              OLDPIPAX                # - CURRENT P66 PIPA
                AD              TEMX                    # - PIPA BY PIPASR IF INTERVENING, ELSE 0
                AD              RUPTREG1                # + PIPA BY P66 ON THE LAST P66 PASS
                TS              DELVROD                 # = -DELV SINCE LAST P66 PASS, 2(14)CM/SEC
                CS              OLDPIPAY
                AD              TEMY
                AD              RUPTREG2

## Page 818
                TS              DELVROD         +2
                CS              OLDPIPAZ
                AD              TEMZ
                AD              RUPTREG3
                TS              DELVROD         +4

# PRE-INTERPRETIVE HOUSEKEEPING AND RESETTING PIPASR'S TEMS FOR NEXT P66

                CAF             ZERO
                TS              MPAC            +1      # ZERO LO-ORDER MPAC COMPONENTS
                TS              MPAC            +4
                TS              MPAC            +6
                TS              TEMX                    # ZERO TEMX, TEMY, AND TEMZ SO WE WILL
                TS              TEMY                    #       KNOW WHEN READACCS CHANGES THEM.
                TS              TEMZ
                CS              ONE
                TS              MODE                    # INDICATE VECTOR IN MPAC

# COMPUTE THE CURRENT P66 VELOCITY AND CERTAIN DISPLAYS

                TC              INTPRET
ITRPNT1         VXSC            PDDL                    # PUSH DELV SINCE LAST P66 IN 2(7)M/CS (6)
                                KPIP1                   # 1/10,000 IN 2(-7)
                                THISTPIP
                DSU
                                PIPTIME
                STORE           30D                     # TTPIP = T-TPIP IN 2(28)CS
                DDV             PDVL                    # QUOTIENT = TTPIP/(1SEC) IN 2(2)      (8)
                                4SEC(28)
                                GDT/2                   # GDT/2 = VEL IN 100 CS IN 2(7)M/CS
                VSU             VXSC                    # (TTPIP/1SEC)(GDT/2-VBIAS),2(9)M/CS   (6)
                                VBIAS			# IN 2(7)M/CS
                VSL2            VAD			# SHIFT YIELDS 2(7)M/CS
                                V                   	# IN 2(7)M/CS
                VAD             STADR                   #                                      (0)
                STOVL           24D                     # STORE P66 VELOCITY IN 2(7)M/CS
                                R
                UNIT
                STORE           14D                     # UNIT(R)
                DOT             SL1
                                24D                     # P66 VELOCITY IN 2(7)M/CS
                STODL           HDOTDISP                # HDOT FOR NOUN 60 IN 2(7)M/CS
                                30D                     # TTPIP IN 2(28)CS
                SL              DMP                     # DELTAH IN 2(24)M =
                                11D                     # 2(11) TTPIP IN 2(28)CS HDOT IN 2(7)M/CS
                                HDOTDISP
                DAD             DSU                     # DELTAH + |R| - |LAND|
                                36D                     # |R| FROM PRECEDING UNIT OPERATION
                                /LAND/
                STODL           HCALC1                  # ALTITUDE FOR N 60 IN 2(24)M

## Page 819
# COMPUTE UNCORRECTED COMMANDED THRUST ACCELERATION

                                HDOTDISP                # IN 2(7)M/CS
                BDSU            DDV
                                VDGVERT                 # IN 2(7)M/CS
                                TAUROD                  # TAU IN 2(9)CS
                PDVL            ABVAL                   # PUSH (VDG-HDOT)/TAU IN 2(-2)M/CS/CS  (2)
                                GDT/2                   # GDT/2 = VEL IN 100CS IN 2(7)M/CS
                DDV             SR2                     # DDV YIELDS G IN 2(-4)M/CS/CS
                                GSCALE                  # 100 CS IN 2(11)M/CS
                STORE           20D                     # |G| IN 2(-2)M/CS/CS
                RTB             DAD                     # UP (VDG-HDOT)/TAU                    (0)
                                QTPROLOG                # QUICTRIG PRESERVES MPAC
                PDVL            CALL                    # (VDG-HDOT)/TAU+|G| IN 2(-2)M/CS/CS   (2)
                                UNITX                   # X AXIS IN NB COORDS
                                *NBSM*                  # TRANSFORMS TO SM COORDS
                DOT                                     # YIELDS COS/4 OF ANGLE OF X WRT VERT
                                14D                     # UNIT(R)
                STORE           22D                     # COS/4
                BDDV            STADR                   # YIELDS ((VDG-HDOT)/TAU+|G|)/COS =    (0)
                STOVL           /AFC/                   # |AFC| RAW IN 2(-4)M/CS/CS

# COMPUTE MEASURED THRUST ACCELERATION

                                DELVROD                 # -DELV SINCE LAST P66 IN 2(14)CM/SEC
                VXSC            VAD                     # ADD SINCE DELV IS REVERSE SIGN
                                KPIP1                   # 1/10,000 IN 2(-7)
                                VBIAS                   # IN 2(7)M/CS
                ABVAL           PDDL                    # PUSH DE-BIASED |DELV| IN 2(7)M/CS    (2)
                                THISTPIP
                DSU             PDDL                    # PUSH PERP66 IN 2(28)CS               (4)
                                LASTTPIP
                                THISTPIP
                STODL           LASTTPIP                # REPLACE LASTTPIP LOADING PERP66       (2)
                DDV             BDDV                    #                                       (0)
                                SHFTFACT                # SCALES PERP66 TO 2(11)CS
                PDDL            DMP                     # PUSH |AF| IN 2(-4)M/CS/CS             (2)

# ADD VELOCITY EXTRAPOLATION CORRECTION TO YIELD UNLIMITED COMMANDED THRUST ACCELERATION

                                FWEIGHT                 # FW IN 2(14)BITS
                                BIT1H                   # SCALES FW TO 2(28)BITS
                DDV             DDV                     # THINK OF DIVIDES BEING REVERSED IN ORDER
                                MASS                    # IN 2(16)KG
                                SCALEFAC                # SF RESCALES FW TO 10,000 2(12)NEWTON
                DAD             PDDL                    # PUSH FW/SF/MASS+|AF| IN 2(-4)M/CS/CS  (4)
                                0D                      # |AF|
                                20D                     # |G|
                DDV             DSU                     # |G|/COS-FW/SF/MASS-|AF|,2(-4)M/CS/CS  (2)
                                22D                     # COS/4

## Page 820
                DMP             DAD                     # (L/T)(|G|/COS-FW/SF/MASS-|AF|)+|AFC|
                                LAG/TAU                 # (L/T) DIMENSIONLESS
                                /AFC/
                PDDL            DDV                     #  PUSH |AFC| UNLIMITED IN 2(-4)M/CS/CS (4)

# LIMIT MINFORCE/MASS <= |AFC| <= MAXFORCE/MASS

                                MAXFORCE
                                MASS
                PDDL            DDV                     #                                       (6)
                                MINFORCE
                                MASS
                PUSH            BDSU                    #                                       (8)
                                2D
                BMN             DLOAD                   #                                       (6)
                                AFCSPOT
                DLOAD           PUSH                    #                                       (6)
                BDSU            BPL
                                2D
                                AFCSPOT
                DLOAD                                   #                                       (4)
AFCSPOT         DLOAD                                   #                            (2),(4),OR (6)
                SETPD                                   #                                       (2)
                                2D
                STODL           /AFC/                   # CORRECTED AND LIMITED |AFC|           (0)
ITRPNT2         EXIT
                DXCH            MPAC                    # FETCH MEASURED THRUST ACCEL FOR THROTTLE
                TC              POSTJUMP
                FCADR           THROT66

# THE FOLLOWING SUBROUTINE REFERS THE X PIPA READING TO THE CENTER OF MASS
# BY SUBTRACTING THOSE PIPA COUNTS PRODUCED BY VERTICAL IMU MOTION
# RELATIVE TO THE CENTER OF MASS.  THE SPACECRAFT X AXIS IS ASSUMED
# APPROXIMATELY VERTICAL.  THE EQUATION IS:

#          OLDPIPAX = OLDPIPAX - OMEGAQ RIMUZ

# WHERE OLDPIPAX IS THE CURRENT P66 PIPA READING, OMEGAQ IS THE ATTITUDE
# RATE ABOUT THE Q (Y) AXIS, AND RIMUZ IS THE Z COORDINATE OF THE IMU.

DEIMUBOB        CA              EBANK6
                TS              EBANK
                EBANK=          END-E6
                CS              OMEGAQ                  # PITCH RATE IN UNITS 45 DEG/SEC
                INCR            BBANK
                EBANK=          END-E7
                EXTEND
                MP              RIMUZ                   # IMU Z IN UNITS (180/PI 45) 2(14) CM
                ADS             OLDPIPAX                # CURRENT P66 PIPA X IN UNITS 2(14) CM/SEC
                TC              Q

## Page 821
# CONSTANTS FOR P66

IDLADR          GENADR          DAPIDLER
GHZ             DEC             1.62292         E-4 B+4 # GRAVITY IN 2(-4)M/CS/CS

BIT1H           OCT             00001                   # MUST PRECEDE A ZERO
SHFTFACT        2DEC            1               B-17    # SCALES P66 PERIOD TO 2(1))CS
RIMUZ           DEC             99.486          B-14    # 1.2667 M IN UNITS (180/PI 45) 2(14) CM

## Page 822
## The suffixed ':' in the second divider below was '=' in the original printout.
## The change is a workaround for our proof-reading system.
# ================================================================================================================
# REDESIGNATOR TRAP
# ===============================================================================================================:

# END INSERT
                BANK            11
                SETLOC          F2DPS*11
                BANK

                COUNT*          $$/F2DPS

PITFALL         XCH             BANKRUPT
                EXTEND
                QXCH            QRUPT

                TC              CHECKMM                 # IF NOT IN P64, NO REASON TO CONTINUE
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


# REDESIGNATION MONITOR (INITIATED BY PITFALL)


PREMON1         TS              ZERLINA
PREMON2         CAF             SEVEN
                TC              VARDELAY
REDESMON        EXTEND
                READ            CHAN31
                COM
                MASK            ALL4BITS
                XCH             ELVIRA
                TS              L
                CCS             ELVIRA                  # DO ANY BITS APPEAR THIS PASS?
                TCF             PREMON2                 #   Y: CONTINUE MONITOR

                CCS             L                       #   N: ANY LAST PASS?
                TCF             COUNT'EM                #      Y: COUNT 'EM, RESET RUPT, TERMINATE
                CCS             ZERLINA                 #      N: HAS ZERLINA REACHED ZERO YET?

## Page 823
                TCF             PREMON1                 #      N: DIMINISH ZERLINA, CONTINUE
RESETRPT        TC              C13STALL                #      Y: RESET RUPT, TERMINATE
                CAF             BIT12
                EXTEND
                WOR             CHAN13
                TCF             TASKOVER

COUNT'EM        CAF             BIT13                   # ARE WE IN ATTITUDE-HOLD?
                EXTEND
                RAND            CHAN31
                EXTEND
                BZF             RESETRPT                # YES: SKIP REDESIGNATION LOGIC.

                CA              L                       # NO
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

## Page 824

ALL4BITS        OCT             00063


AZEACH          DEC             .01746                  # ONE DEGREE


ELEACH          =               AZEACH                  # ONE DEGREE


                BANK    31
                SETLOC  F2DPS*31
                BANK

                COUNT*  $$/F2DPS

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
# RETURN IS NORMALLY TO LOC(TC ROOTPSRS)+3.   IF ROOTPSRS FAILS TO CONVERGE IN 8 PASSES, RETURN IS TO LOC+1 AND
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

## Page 825
# 3. AT PRESENT, ERASABLE LOCATIONS ARE RESERVED ONLY FOR N UP TO 5.  AN N IN EXCESS OF 5 WILL PRODUCE CHAOS.
#    ALL ERASABLES USED BY ROOTPSRS ARE UNSWITCHED LOCATED IN THE REGION FROM MPAC-33 OCT TO MPAC+7.

# 4. THE ITERATION COUNT RETURNED IN MPAC+2 MAY BE USED TO DETECT ABNORMAL PERFORMANCE.

                                                        # STORE ENTERING DATA, INITLIZE ERASABLES

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

## Page 826
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

                CA              MODE
                MASK            BIT4                    # KLUMPP SAYS GIVE UP AFTER EIGHT PASSES
                CCS             A
BADROOT         TC              RETROOT

                INCR            MODE                    # INCREMENT ITERATION COUNTER
                CCS             MPAC                    # TEST HI ORDER DX
                TCF             ROOTLOOP
                TCF             TESTLODX
                TCF             ROOTSTOR
TESTLODX        CCS             MPAC            +1      # TEST LO ORDER DX
                TCF             ROOTLOOP
                TCF             ROOTSTOR

## Page 827
                TCF             ROOTSTOR
ROOTSTOR        DXCH            ROOTPS
                DXCH            MPAC
                CA              MODE
                TS              MPAC            +2      # STORE SP ITERATION COUNT IN MPAC+2
                INDEX           RETROOT
                TCF             2

DERTABLL        ADRES           DERCOFN         -3


# ****************************************************************************************************************
# TRASHY LITTLE SUBROUTINES
# ****************************************************************************************************************

ZEROMID         CAF             ZERO                    # ROUTINE TO ZERO THE MIDDLE COMPONENT
                TS              MPAC            +3      #   OF A VECTOR IN MPAC.   "TCF DANZIG"
                TS              MPAC            +4      #   COULD BE A "TC Q" AT THE EXPENSE OF
                TCF             DANZIG                  #   A TINY AMOUNT OF TIME.


INTPRETX        INDEX           A                       # SET X1 ON THE WAY TO THE INTERPRETER
                CS              TARGTDEX
                INDEX           FIXLOC
                TS              X1
                TCF             INTPRET

TDISPSET        CA              TTF/8
                EXTEND
                MP              TSCALINV
                DXCH            TTFDISP

                CA              EBANK5                  # TREDES BECOMES ZERO TWO PASSES
                TS              EBANK                   #   BEFORE TCGFAPPR IS REACHED
                EBANK=          TCGFAPPR
                CA              TCGFAPPR
                INCR            BBANK
                INCR            BBANK
                EBANK=          TTF/8
                AD              TTF/8
                EXTEND
                MP              TREDESCL
                AD              -DEC103
                AD              NEGMAX
                TS              L
                CS              L
                AD              L
                AD              +DEC99
                AD              POSMAX

## Page 828
                TS              TREDES
                CS              TREDES
                ADS             TREDES
                TC              Q


1406POO         TC              POODOO
                OCT             21406
1406ALM         TC              ALARM
                OCT             01406
                TCF             RATESTOP

# DESCENT OVERFLOW SUBROUTINE
OVFDESC         EXTEND
                QXCH            OVFRET

                TC              ALARM
                OCT             01410

                INHINT                                  # MUST USE INHINT, IBNKCALL, RELINT
                TC              IBNKCALL                # BECAUSE DAP COULD INTERRUPT STOPRATE AND
                FCADR           STOPRATE                # BECAUSE WE COME FROM P66HZ VIA BANKCALL
                RELINT

                CA              ZERO
                TS              OVFIND

                TC              OVFRET

## Page 829

# ****************************************************************************************************************
# SPECIALIZED "PHASCHNG" SUBROUTINE
# ****************************************************************************************************************

                EBANK=          PHSNAME2
FASTCHNG        CA              EBANK3                  # SPECIALIZED 'PHASCHNG' ROUTINE
                XCH             EBANK
                DXCH            L
                TS              PHSNAME3
                LXCH            EBANK
                EBANK=          E2DPS
                TC              A

# ****************************************************************************************************************
# PARAMETER TABLE INDIRECT ADDRESSES
# ****************************************************************************************************************

RDG             =               RBRFGX
VDG             =               VBRFGX
ADG             =               ABRFGX
VDG2TTF         =               VBRFG*
ADG2TTF         =               ABRFG*
JDG2TTF         =               JBRFG*

# ****************************************************************************************************************
# LUNAR LANDING CONSTANTS
# ***************************************************************************************************************

TABLTTFL        ADRES           TABLTTF         +3      # ADDRESS FOR REFERENCING TTF TABLE


TTFSCALE        =               BIT12


TSCALINV        =               BIT4


-DEC103         DEC             -103


P64DB           OCT             00155                   # 0.3 DEGREES SCALED AT CDU SCALING


+DEC99          DEC             +99


TREDESCL        DEC             -.08

## Page 830
180DEGS         DEC             +180


1/2DEG          DEC             +.00278


PROJMAX         DEC             .42262          B-3     # SIN(25')/8 TO COMPARE WITH PROJ


PROJMIN         DEC             .25882          B-3     # SIN(15')/8 TO COMPARE WITH PROJ


V06N63          VN              0663                    # P63

V06N64          VN              0664                    # P64

V06N60          VN              0660                    # P65, P66, P67


                BANK            22
                SETLOC          LANDCNST
                BANK
                COUNT*          $$/F2DPS

HIGHESTF        2DEC            4.34546769      B-12
GSCALE          2DEC            100             B-11
3/8DP           2DEC            .375
3/4DP           2DEC            .750
DEPRCRIT        2DEC            -.02 B-1
# ****************************************************************************************************************
# ****************************************************************************************************************
