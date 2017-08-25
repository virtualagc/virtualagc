### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LUNAR_LANDING_GUIDANCE_EQUATIONS.agc
## Purpose:     A log section of Zerlina 56, the final revision of
##              Don Eyles's offline development program for the variable 
##              guidance period servicer. It also includes a new P66 with LPD 
##              (Landing Point Designator) capability, based on an idea of John 
##              Young's. Neither of these advanced features were actually flown,
##              but Zerlina was also the birthplace of other big improvements to
##              Luminary including the terrain model and new (Luminary 1E)
##              analog display programs. Zerlina was branched off of Luminary 145,
##              and revision 56 includes all changes up to and including Luminary
##              183. It is therefore quite close to the Apollo 14 program,
##              Luminary 178, where not modified with new features.
## Reference:   pp. 784-821
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-07-28 MAS  Created from Luminary 210.
##              2017-08-05 MAS  Transcribed for Zerlina 56. This section was
##                              largely rewritten to support P66 LPD and the
##                              variable servicer.
##              2017-08-06 MAS  Fixed a comment transcription error (MODULE
##                              where MODULO should have been).
##              2017-08-19 MAS  Corrected a few transcription errors.
##              2017-08-24 MAS  Fixed a branch target and a few incorrect
##                              instructions.

## Page 784
# ****************************************************************************************************************
# GUIDANCE FOR LANDING ON THE MOON                                    BY EYLES EXCEPT P66HZ AND ROOTPSRS BY KLUMPP
# ****************************************************************************************************************

                EBANK=          E2DPS  

                COUNT*          $$/F2DPS

# ****************************************************************************************************************
# LUNAR LANDING FLIGHT SEQUENCE TABLES
# ****************************************************************************************************************

# FLIGHT SEQUENCE TABLES ARE ARRANGED BY FUNCTION.   THEY ARE REFERENCED USING AS AN INDEX THE REGISTER WCHPHASE:

#                                                  WCHPHASE  =  -1  --->  IGNALG
#                                                  WCHPHASE  =   0  --->  BRAKQUAD
#                                                  WCHPHASE  =   1  --->  APPRQUAD
#                                                  WCHPHASE  =   2  --->  VERTICAL

# ****************************************************************************************************************

# ROUTINES FOR STARTING NEW GUIDANCE PHASES:

                TCF             TTFINCR                 # IGNALG
NEWPHASE        TCF             TTFINCR                 # BRAKQUAD
                TCF             STARTP64                # APPRQUAD
                TCF             ENDLLJOB                # VERTICAL  (A BRANCH RARELY IF EVER USED)
#

# PRE-GUIDANCE COMPUTATIONS:

                TCF             CALCRGVG                # IGNALG
PREGUIDE        TCF             RGVGCALC                # BRAKQUAD
                TCF             REDESIG                 # APPRQUAD
#

# GUIDANCE EQUATIONS:

                TCF             TTF/8CL                 # IGNALG
WHATGUID        TCF             TTF/8CL                 # BRAKQUAD
                TCF             TTF/8CL                 # APPRQUAD
#

# POST GUIDANCE EQUATION COMPUTATIONS:

                TCF             CGCALC                  # IGNALG
AFTRGUID        TCF             EXTLOGIC                # BRAKQUAD
                TCF             EXTLOGIC                # APPRQUAD

## Page 785
# WINDOW VECTOR COMPUTATIONS:

                TCF             EXGSUB                  # IGNALG
WHATEXIT        TCF             EXBRAK                  # BRAKQUAD
                TCF             EXNORM                  # APPRQUAD
#

# DISPLAY ROUTINES:

WHATDISP        TCF             P63DISPS                # BRAKQUAD
                TCF             P64DISPS                # APPRQUAD
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

# ****************************************************************************************************************
# ENTRY POINTS:   ?GUIDSUB FOR THE IGNITION ALGORITHM, LUNLAND FOR SERVOUT
# ****************************************************************************************************************

# IGNITION ALGORITHM ENTRY:  DELIVERS N PASSES OF QUADRATIC QUIDANCE

?GUIDSUB        EXIT
                CAF             TWO                     # N = 3
                TS              NGUIDSUB
                TCF             PASSINIT

GUIDSUB         TS              NGUIDSUB                # ON SUCEEDING PASSES SKIP TTFINCR
                TCF             CALCRGVG

# NORMAL ENTRY:  CONTROL COMES HERE FROM SERVOUT

LUNLAND         TC              SERVCHNG
                CA              FLAGWRD5                # HAS THROTTLE-UP COME YET?
                MASK            ZOOMBIT
                EXTEND
                BZF             DISPEXIT                # NO:   DO P63 DISPLAYS BUT NO GUIDANCE

# ****************************************************************************************************************
## Page 786
# INITIALIZATION FOR THIS PASS
# ****************************************************************************************************************

PASSINIT        EXTEND
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
                INHINT
                TC              C13STALL
                CA              BIT12                   # ENABLE RUPT10
                EXTEND
                WOR             CHAN13
                CAF             P64DB
                TS              DB
                CA              LRWH1
                TS              LRWH

                TC              DOWNFLAG                # INITIALIZE REDESIGNATION FLAG
                ADRES           REDFLAG

#                                             (CONTINUE TO TTFINCR)

# ****************************************************************************************************************
# INCREMENT TTF/8, UPDATE LAND FOR LUNAR ROTATION, DO OTHER USEFUL THINGS
# ****************************************************************************************************************

## Page 787
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
## Page 788
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
                CA              ELCOUNT1
                TS              ELCOUNT
                CA              AZCOUNT1
                TS              AZCOUNT
                TC              FASTCHNG

                CA              ZERO
                TS              ELCOUNT1
## Page 789
                TS              AZCOUNT1

                CA              ELCOUNT                 # COMPUTE ELEVATION INCREMENT IN RADIANS
                EXTEND
                MP              ELEACH
                XCH             L                       # SHIFT LEFT 14, A BEING ZERO AFTER THE MP
                INDEX           FIXLOC
                DXCH            12D

                CA              AZCOUNT                 # COMPUTE AZIMUTH INCREMENT IN RADIANS
                EXTEND
                MP              AZEACH
                XCH             L                       # SHIFT LEFT 14, A BEING ZERO AFTER THE MP
                INDEX           FIXLOC
                DXCH            14D

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
                                12D
                                14D
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
## Page 790
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

## Page 791
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

                TC              BANKCALL                # CALL LPDFVSUB TO PREPARE R1 DISPLAY
                CADR            LPDFVSUB

BRSPOT3         INDEX           WCHPHASE
                TCF             WHATGUID

# ****************************************************************************************************************
# TTF/8 COMPUTATION
# ****************************************************************************************************************

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
                                RDG +4,1                #              2         2
                DSU             DMP
                                RGU             +4
## Page 792
                                3/8DP
                STORE           TABLTTF                 # A(0) = -24(RGU  - RDG )/64 TO TABLTTF
                EXIT                                    #               2      2

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

QUADGUID        CS              TTF/8
                AD              LEADTIME                # LEADTIME IS A NEGATIVE NUMBER
                AD              POSMAX                  # SAFEGUARD THE COMPUTATIONS THAT FOLLOW
                TS              L                       #   BY FORCING -TTF+LEADTIME > OR = ZERO
## Page 793
                CS              L
                AD              L
                ZL
                EXTEND
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
## Page 794
                                ADG,1
                RTB             VAD
                                ZEROMID
AFCCALC1        VXM             VSL1                    # VERTGUID COMES HERE
                                CG
                PDVL            VSR2                    # RESCALE G TO UNITS OF 2(-4) M/CS/CS
                                G
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
                                MASS                    #                        2     2      2
                DSU             DSU                     # AMAXHORIZ = SQRT(ATOTAL  - A   -  A  )
                BPL             DLOAD                   #                             1      0
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

## Page 795
                CA              WCHPHOLD
                AD              ONE
                TS              WCHPHASE
                CAF             ZERO
                TS              FLPASS0

#                                             (CONTINUE TO CGCALC)

# ***************************************************************************************************************
# ERECT GUIDANCE-STABLE MEMBER TRANSFORMATION MATRIX
# ***************************************************************************************************************

CGCALC          CAF             EBANK5
                TS              EBANK
                EBANK=          TCGIBRAK
                EXTEND
                INDEX           WCHPHASE
                INDEX           TARGTDEX
                DCA             TCGFBRAK
                INCR            BBANK
                INCR            BBANK
                EBANK=          TTF/8
                AD              TTF/8
                XCH             L
                AD              TTF/8
                CCS             A
                CCS             L
                TCF             EXITSPOT
                TCF             EXITSPOT
                NOOP

                TC              INTPRETX
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
## Page 796
                                CG              +6
                STORE           CG              +14
                EXIT

EXITSPOT        INDEX           WCHPHOLD
                TCF             WHATEXIT

# ****************************************************************************************************************
# ROUTINES FOR EXITING FROM LANDING GUIDANCE
# ****************************************************************************************************************

# 1.       EXGSUB IS THE RETURN WHEN GUIDSUB IS CALLED BY THE IGNITION ALGORITHM.

# 2.       EXBRAK IN THE EXIT USED DURING THE BRAKING PHASE.   IN THIS CASE UNIT(R) IS THE WINDOW POINTING VECTOR.

# 3.       EXNORM IS THE EXIT USED AT OTHER TIMES DURING THE BURN.

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
## Page 797
                RTB
                                NORMUNIT
                STORE           UNWC/2                  # UNIT(LAND - R) IS TENTATIVE CHOICE
                VXV             DOT
                                XNBPIP
                                CG              +6
                EXIT                                    # WITH PROJ IN MPAC 1/8 REAL SIZE

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
## Page 798
                EXTEND
                BZF             STEERSW?                # NO:   CHECK STEERSW

                TC              OVFDESC                 # YES:  ISSUE ALARM AND SKIP COMMANDS
                TCF             DISPEXIT

STEERSW?        CS              FLAGWRD2                # IS STEERSW UP?
                MASK            STEERBIT
                EXTEND
                BZF             THRTCALL                # YES:  ISSUE GUIDANCE COMMANDS

RATESTOP        INHINT                                  # NO
                TC              IBNKCALL
                FCADR           STOPRATE
                RELINT
                TCF             DISPEXIT

GDUMP1          =               THRTCALL

THRTCALL        TC              CHECKMM                 # HAS MODE CHANGED TO 66 SINCE CONTROL WAS
                DEC             66                      #   TRANSFERRED TO LUNLAND FROM SERVICER?
                TCF             +2
                TCF             DISPEXIT                # YES:  SKIP COMMANDS

                TC              THROTTLE                # NO
                TC              FASTCHNG

                CA              FCODD
                TS              FCOLD

                EXTEND
                DCA             FWEIGHT1
                DXCH            FWEIGHT

                TC              INTPRET
                CALL
                                FINDCDUW        -2
                EXIT

#                                             (CONTINUE TO DISPEXIT)


# ****************************************************************************************************************
# GUIDANCE LOOP DISPLAYS
# ****************************************************************************************************************

DISPEXIT        CS              FLAGWRD8                # NO DISPLAYS THIS PASS IF FLUNDISP IS SET
                MASK            FLUNDBIT
                EXTEND
## Page 799
                BZF             ENDLLJOB

                CAF             PRIO23                  # RAISE PRIORITY TEMPORARILY SO DISPLAY
                TC              PRIOCHNG                #   RESPONSES WILL NOT WAIT FOR SERVICER

                INDEX           WCHPHOLD
                TCF             WHATDISP

P63DISPS        CS              FLGWRD11                # HAVE LR UPDATES BEEN PERMITTED?
                MASK            LRINHBIT
                EXTEND
                BZF             N63STAT                 # YES:  DO STATIC DISPLAY

                CAF             V06N63                  # NO:   FLASH NOUN 63, CORRECT RESPONSE IS
                TC              BANKCALL                #         V57E WHICH STOPS THE FLASHING
                CADR            REFLASHR
                TC              ENDOFJOB                # TERMINATE  IGNORE AND KEEP FLASHING
                TC              ENDOFJOB                # PROCEED    IGNORE AND KEEP FLASHING
                TC              ENDOFJOB                # ENTER      IGNORE AND KEEP FLASHING

                TCF             LOWRPRIO

N63STAT         CAF             V06N63
DISPCOMN        TC              BANKCALL
                CADR            REGODSPR

LOWRPRIO        CAF             PRIO20
                TC              PRIOCHNG
ENDLLJOB        TC              POSTJUMP                # RETURN CONTROL TO THE START OF SERVICER
                CADR            PIPCYCLE

P64DISPS        CA              TREDES                  # HAS TREDES REACHED ZERO?
                EXTEND
                BZF             RED-OVER                # YES:  CLEAR REDESIGNATION FLAG

                CS              FLAGWRD6                # NO:   IS REDFLAG SET?
                MASK            REDFLBIT
                EXTEND
                BZF             REDES-OK                # YES:  DO STATIC DISPLAY

                CAF             V06N64                  # NO:   USE FLASHING DISPLAY
                TC              BANKCALL
                CADR            REFLASHR
                TC              ENDOFJOB                # TERMINATE  IGNORE AND KEEP FLASHING
                TCF             P64CEED                 # PROCEED    PERMIT REDESIGNATIONS
                TC              ENDOFJOB                # ENTER      IGNORE AND KEEP FLASHING

                TCF             LOWRPRIO

P64CEED         CAF             ZERO
## Page 800
                TS              ELCOUNT1
                TS              AZCOUNT1

                TC              UPFLAG                  # ENABLE REDESIGNATION LOGIC
                ADRES           REDFLAG

                TCF             ENDOFJOB

RED-OVER        TC              DOWNFLAG
                ADRES           REDFLAG
REDES-OK        CAF             V06N64
                TCF             DISPCOMN


# ****************************************************************************************************************
# VERTICAL AND HORIZONTAL GUIDANCE FOR P66
# ****************************************************************************************************************

                SETLOC          P66LOC
                BANK
                EBANK=          TAURODL
                COUNT*          $$/F2DPS

# ********************************
# DATA TRANSFER AND PIPA READING
# ********************************

#     FIRST, PAD-LOADS FROM THE W-MATRIX AREA ARE MOVED INTO TEMPORARIES FOR USE WHENE BANK IS SET TO 7.
# THESE TRANSFERS ARE AS FOLLOWS:

#                                 VERCRIT        --->  VBUF     +1
#                                 TAURODL        --->  VBUF     +2
#                                 TAURODB        --->  VBUF     +3
#                                 MINFORCE       --->  VBUF     +4
#                                 MAXFORCE       --->  VBUF     +5
#                                 RODSCALE       --->  MPAC     +5
#                                 ROHZSCAL       --->  MPAC     +6

P66JOB          CA              VERCRIT                 # VERCRIT
                TS              VBUF            +1
                EXTEND
                DCA             TAURODL                 # TAURODL AND TAURODB
                DXCH            VBUF            +2
                EXTEND
                DCA             MINFORCE                # MINFORCE AND MAXFORCE
                DXCH            VBUF            +4
                EXTEND
                DCA             RODSCALE                # RODSCALE AND ROHZSCAL
                DXCH            MPAC            +5

## Page 801
#     ONE OTHER CHORE CAN BE DONE NOW TO MINIMIZE THE TIME BETWEEN READING PIPAX AND PUTTING OUT A THROTTLE
# COMMAND:  THE COMPUTATION OF THE PRODUCT OF COS(AIG) AND COS(AMG).

P66INH          INHINT                                  # INHINT LASTS TILL AFTER THROTTLE COMMAND

                CA              CDUY
                TC              SPCOS
                TS              VBUF
                CA              CDUZ
                TC              SPCOS
                EXTEND
                MP              VBUF
                TS              MPAC            +4      # PRODUCT OF COSINES SCALED FULL-SIZE

                INCR            BBANK                   # START P66JOB IN E5, SWITCH NOW TO E6
                EBANK=          END-E6

#     THE FOLLOWING CODING REFERS THE X-PIPA READING TO THE CENTER OF MASS OF THE SPACECRAFT BY SUBTRACTING
# THOSE PIPA COUNTS PRODUCED BY VERTICAL IMU MOTION RELATIVE TO THE CENTER-OF-MASS.  THE SPACECRAFT X-AXIS IS
# ASSUMED TO BE APPROXIMATELY VERTICAL (PARALLEL TO THE SM X-AXIS).  THE EQUATION IS:

#                                 P66PIPX = PIPAX - OMEGAQ RIMUZ

# WHERE OMEGAQ IS THE ATTITUDE-RATE ABOUT THE Q (Y) AXIS AND RIMUZ IS THE Z-COORDINATE OF THE IMU.

                CS              OMEGAQ
                
                INCR            BBANK                   # SWITCH FINALLY INTO E7
                EBANK=          END-E7

                EXTEND
                MP              RIMUZ
                XCH             L                       # ROUND BEFORE ADDING TO PIPAX
                DOUBLE
                TS              Q                       # SKIP ON OVERFLOW WITH C(A) = +1 OR -1
                CAF             ZERO                    #   DEPENDING ON THE SIGN OF THE OVERFLOW
                AD              L

                AD              PIPAX
                TS              P66PIPX

                EXTEND                                  # READ FINE-SCALED TIME FOR FP COMPUTATION
                READ            LOSCALAR
                TS              P66TPIP                 # TIME IN UNITS OF 2(9) M/CS

                EXTEND                                  # SET GTCTIME AS TIME-TAG FOR FC
                DCA             TIME2
                DXCH            GTCTIME                 # TIME IN UNITS OF 2(28) CS

# ********************************
## Page 802
# PROGRAM INITIALIZATION
# ********************************

#     THE FIRST TIME P66JOB IS EXECUTED P66 HAS NOT YET BEEN INITIALIZED.   THIS IS INDICATED BY THE FACT THAT
# MODREG CONTAINS SOMETHING OTHER THAN 66.  IN THIS CASE P66JOB BEGINS BY INITIALIZING ITSELF.

                CS              MODREG                  # HAS P66 BEEN INITIALIZED YET?
                AD              MM66
                EXTEND
                BZF             P66MAIN                 # YES

                TC              P66CHNG                 # NO:   THEN INITIALIZE IT

                TC              NEWMODEX                # SWITCH MODE LIGHTS TO 66
MM66            DEC             66

                CS              ZERO                    # CANCEL LEFT OVER P64 THROTTLE COMMAND
                TS              THRUST                  #   (DON'T EVER LOAD THRUST WITH +0)

                CAF             THREE                   # SET HZCOUNT FOR P66DISPS IN 3/4
                TS              HZCOUNT                 #   SECOND AND P66HZ IN 1 1/4 SECOND

                TC              ZEROVHZC                # SET VHZC TO ZERO, RETURN WITH C(A) = +0

                TS              FWEIGHT                 # ZERO FWEIGHT LEFT OVER FROM P64
                TS              FWEIGHT         +1

                TCF             ENDROD                  # WAIT BEFORE EXECUTING P66ROD

# ********************************
# VERTICAL (ROD) CONTROL EQUATION
# ********************************

#     HERE VVECTX IS RECOMPUTED TO MINIMIZE THE GUIDANCE LAG BETWEEN THE SAMPLING OF PIPA DATA AND THE
# OUTPUT OF COMMANDS.  THIS LEAVES THE VECTOR VVECT NON-HOMOGENEOUS, BUT THIS IS UNIMPORTANT SINCE THE VERTICAL
# AND HORIZONTAL CHANNELS ARE SEPARATE.

P66MAIN         EXTEND
                DCS             VSURFACE
                DXCH            VVECTX
                EXTEND
                DCA             V
                DDOUBL
                DDOUBL
                DAS             VVECTX

                CS              PIPTIME         +1
                AD              GTCTIME         +1
                AD              HALF
                AD              HALF
## Page 803
                XCH             DT

                CS              PIPAXOLD
                AD              P66PIPX
                TC              BANKCALL
                CADR            NORMPIP
                EXTEND
                MP              P66KPIP
                DAS             VVECTX

                CS              BIASACCX
                AD              GRAVACCX
                EXTEND
                MP              DT
                DAS             VVECTX                  # VVECTX IN UNITS OF 2(5) M/CS

# UPDATE VDGVERT ACCORDING TO ROD CLICKS.

                CAF             ZERO
                XCH             RODCOUNT                # RESTART BETWEEN NOW AND THE UPDATE OF
                EXTEND                                  #   VDGVERT COULD CAUSE LOSS OF ROD CLICKS
                MP              MPAC            +5
                CA              L
                EXTEND
                MP              BIT7
                DAS             VDGVERT                 # VDGVERT IN UNITS OF 2(5) M/CS

MANTHRT?        CAF             BIT5                    # ARE WE IN AUTO THROTTLE?
                EXTEND
                RAND            CHAN30
                EXTEND
                BZF             ERRCOMP                 # YES

                EXTEND                                  # NO:   RESET VDGVERT TO CURRENT VVECTX
                DCA             VVECTX
                DXCH            VDGVERT
                TCF             ENDROD

#     THE DECISION WHETHER TO EXECUTE THE P66ROD EQUATION IS MADE EVERY 1/4 SECOND ON THE FOLLOWING BASIS:  IF
# VELOCITY ERROR ALONG THE SM X-AXIS EXCEEDS VERCRIT IN MAGNITUDE, DO P66ROD.  OTHERWISE, DO P66ROD EVERY TAU
# (SPECIFICALLY TAUROD ROUNDED TO THE NEAREST 1/4 SECOND).

ERRCOMP         EXTEND                                  # COMPUTE VERTICAL (SM X-AXIS) VEL ERROR
                DCS             VVECTX
                DXCH            MPAC
                EXTEND
                DCA             VDGVERT
                DAS             MPAC                    # VDGVERT - VVECTX IN UNITS OF 2(5) M/CS

                TC              TPAGREE                 # SIGN-AGREE MPAC (ABSOLUTELY NECESSARY)

## Page 804
                CS              OP66TPIP                # COMPUTE TIME SINCE LAST RODCOMP
                AD              P66TPIP
                AD              HALF
                AD              HALF
                XCH             MPAC            +3      # TIME SINCE LAST P66ROD, UNITS OF 2(9) CS

                CS              P66PMIN                 # HAS IT BEEN LESS THAN P66PMIN?
                AD              MPAC            +3
                EXTEND
                BZMF            MOREP66?                # YES:  NO P66ROD THIS PASS

                LXCH            MPAC                    # NO:   LIMIT ERROR TO ABOUT 9.57 M/S
                CAF             DEC48
                TC              BANKCALL
                CADR            LIMITSUB
                TS              MPAC                    # PUT IT BACK IN MPAC

                EXTEND                                  # IS |VDGVERT - VVECTX| < VERCRIT?
                DCA             MPAC
                EXTEND
                DV              VBUF            +1
                EXTEND
                BZF             ERRFAIL

                CA              VBUF            +2      # NO:   DO ROD COMPUTATION USING TAURODL
                TCF             P66ROD

ERRFAIL         CA              MPAC            +3      # YES:  HAS IT BEEN ABOUT OLDTAU
                EXTEND                                  #         SINCE THE LAST P66ROD?
                MP              BIT10
                AD              TWELVE
                AD              -OLDTAU
                EXTEND
                BZMF            MOREP66?                # NO:   NO P66ROD THIS PASS

                CA              VBUF            +3      # YES:  DO ROD COMPUTATION USING TAURODB

P66ROD          TS              TAU
                DXCH            MPAC
                EXTEND
                DV              TAU                     # TOTAL A DESIRED, UNITS OF 2(-9) M/CS/CS

                EXTEND                                  # SUBTRACT AWAY GRAVITY
                SU              GRAVACCX
                EXTEND                                  # RESCALE TO UNITS OF 2(-4) M/CS/CS
                MP              BIT10
                TC              BANKCALL
                CADR            MASSMULT
                EXTEND                                  # DIVIDE BY COS(AIG) COS(AMG)
                DV              MPAC            +4

## Page 805
                EXTEND                                  # APPLY LOWER LIMIT OF MINFORCE (VBUF +4)
                SU              VBUF            +4
                AD              POSMAX
                TS              L
                CS              L
                AD              L
                AD              VBUF            +4

                TS              L                       # APPLY UPPER LIMIT OF MAXFORCE (VBUF +5)
                CA              VBUF            +5
                TC              BANKCALL
                CADR            LIMITSUB
                TS              FC                      # THRUST DESIRED

                CS              P66PIPX                 # COMPUTE MINUS PRESENT THRUST LEVEL
                AD              OP66PIPX
                TC              BANKCALL
                CADR            NORMPIP
                EXTEND                                  # RESCALE TO UNITS OF 1 M/CS
                MP              P66KPIPB
                DDOUBL
                EXTEND                                  # DIVIDE BY TIME IN UNITS OF 2(9) CS TO
                DV              MPAC            +3      #   GET ACC IN UNITS OF 2(-9) M/CS/CS
                AD              BIASACCX                # ADD IN PIPA BIAS PSEUDO-ACCELERATION

                EXTEND                                  # RESCALE TO UNITS OF 2(-4) M/CS/CS
                MP              BIT10
                TC              BANKCALL
                CADR            MASSMULT
                TS              FP

                EXTEND
                DCS             FWEIGHT
                EXTEND
                DV              MPAC            +3
                ADS             FP                      # MINUS THRUST ALONG THE SM X-AXIS

                ZL
                EXTEND                                  # DIVIDE BY COS(AIG) COS(AMG)
                DV              MPAC            +4

                TS              FP                      # MINUS PRESENT THRUST

                AD              FC
                TS              L                       # LIMIT PIF TO WHAT CAN BE READ OUT
                CAF             P66PMIN                 #   (LOSCALAR AND THRUST BOTH 3200 PPS)
                TC              BANKCALL
                CADR            LIMITSUB

                TC              BANKCALL                # GO TO THROTTLE WITH PIF IN A
## Page 806
                CADR            P66THROT

P66REL          RELINT

                DXCH            FWEIGHT1                # SCALE FWEIGHT FOR USE NEXT PASS
                DXCH            MPAC
                CA              MPAC            +4      # FIRST TAKE OUT THE ATTITUDE EFFECT
                TC              SHORTMP
                CAF             2SECS(9)
                TC              SHORTMP
                DXCH            MPAC
                DXCH            FWEIGHT1                # TRANSFERRED TO FWEIGHT LATER

#     UPDATE VHZC (Y AND Z COMPONENTS) ACCORDING TO HAND CONTROLLER DEFLECTIONS.  IT IS ASSUMED THAT THE PLANE OF
# THE SM Y AND Z AXES IS PARALLEL TO THE LOCAL SURFACE, AS IT WILL BE IN P66 FOR THE NORMAL "LANDING ALIGNMENT".

                CAF             ZERO
                XCH             AZCOUNT1                # RESTART BETWEEN NOW AND THE UPDATE OF
                EXTEND                                  #   VHZC COULD CAUSE LOSS OF ROHZ CLICKS
                MP              MPAC            +6
                LXCH            BUF                     # AZCOUNT1.ROHZCAL IN UNITS OF 2(-3) M/CS

                CAF             ZERO
                XCH             ELCOUNT1                # RESTART BETWEEN NOW AND THE UPDATE OF
                EXTEND                                  #   VHZC COULD CAUSE LOSS OF ROHZ CLICKS
                MP              MPAC            +6
                LXCH            BUF             +1      # ELCOUNT1.ROHZSCAL IN UNITS OF 2(-3) M/CS

                CAF             EBANK6
                TS              EBANK
                EBANK=          END-E6

                CA              BUF
                EXTEND
                MP              M32                     # COS(AOG)
                TS              Q
                CS              BUF             +1
                EXTEND
                MP              M22                     # SIN(AOG)
                AD              Q
                EXTEND
                MP              BIT7
                DXCH            MPAC                    # INCREMENT FOR VHZCY, UNITS OF 2(5) M/CS

                CA              BUF
                EXTEND
                MP              M22                     # SIN(AOG)
                XCH             BUF             +1
                EXTEND
                MP              M32                     # COS(AOG)
## Page 807
                AD              BUF             +1
                EXTEND
                MP              BIT7                    # INCREMENT FOR VHZCZ, UNITS OF 2(5) M/CS

                INCR            BBANK
                EBANK=          END-E7

                DAS             VHZC            +4      # UPDATE VHZCZ
                DXCH            MPAC
                DAS             VHZC            +2      # UPDATE VHZCY

                TC              P66CHNG

                EXTEND                                  # STORE FWEIGHT FOR USE NEXT PASS
                DCA             FWEIGHT1
                DXCH            FWEIGHT

                CS              TAU                     # STORE MINUS TAU FOR TEST NEXT PASS
                TS              -OLDTAU

ENDROD          TC              P66CHNG

                EXTEND                                  # STORE TIME AND PIPX FOR NEXT PASS
                DCA             P66TPIP
                DXCH            OP66TPIP

# ********************************
# ANY MORE WORK THIS PASS?
# ********************************

MOREP66?        EXTEND                                  # TERMINATE P66JOB RESTART PROTECTION
                DCA             NEG0
                DXCH            -PHASE3

#     NOTE:  A RESTART BETWEEN NOW AND THE END OF THE JOB WILL CAUSE THE LOSS OF THE REMAINDER OF THE JOB.  BUT
# THIS DOES NOT MATTER.  SINCE HZCOUNT IS NOT INCREMENTED UNTIL THE END OF THE JOB, THE FIRST P66JOB AFTER THE
# RESTART WILL REPEAT AND COMPLETE THE COMPUTATIONS STARTED HERE.

                CAF             PRIO22
                TC              PRIOCHNG

                CAF             PRIO23
                TC              PRIOCHNG

#     THE DESISION WHETHER TO EXECUTE THE P66 HORIZONTAL CONTROL EQUATION IS MADE EVERY 1/4 SECOND ON THE
# FOLLOWING BASIS:  IF MODE HAS BEEN SWITCHED FROM ATTITUDE-HOLD TO AUTO BETWEEN THE MOST RECENT FINDCDUW AND
# NOW, DO P66HZ IMMEDIATELY.  OTHERWISE, DO P66HZ EVERY TWO SECONDS (WHICH COULD BE CHANGED TO ONE SECOND), AND
# DO P65DISPS EVERY ONE SECOND, STAGGERED FROM P66HZ.

                CA              FIXLOC                  # ZERO PUSHDOWN POINTER
## Page 808
                TS              PUSHLOC

                CAF             EBANK6                  # SWITCH TO E6 FOR FLPAUTNO
                TS              EBANK
                EBANK=          END-E6

                CAF             BIT14                   # IS MODE IN AUTO?
                EXTEND
                RAND            CHAN31
                EXTEND
                BZF             CHKFPAUT                # YES:  GO CHECK FLPAUTNO

                TS              FLPAUTNO                # NO:   SET FLPAUTNO TO INDICATE ATT-HOLD,
                INCR            BBANK                   #         RETURN TO E7, AND ZERO VHZC
                TC              ZEROVHZC
                TCF             HZTIME?

CHKFPAUT        CA              FLPAUTNO                # WAS MODE IN AUTO LAST FINDCDUW?
                INCR            BBANK
                EBANK=          END-E7
                EXTEND
                BZF             HZTIME?                 # YES

                TC              ZEROVHZC                # NO:   MODE JUST SWITCHED SO ZERO VHZC
                TS              HZCOUNT                 #         AND HZCOUNT FOR IMMEDIATE P66HZ

HZTIME?         CA              HZCOUNT                 # DOES HZCOUNT = 0 MODULO 8?
                MASK            SEVEN
                EXTEND
                BZF             P66HZ                   # YES:  DO HORIZONTAL CONTROL EQUATION

                MASK            THREE                   # NO:   DOES HZCOUNT = 2 MODULO 4?
                AD              NEG2
                EXTEND
                BZF             P66DISPS                # YES:  GO COMPUTE DISPLAYS

END66JOB        INCR            HZCOUNT                 # NO:   INCREMENT HZCOUNT, TERMINATE JOB:
                TC              ENDOFJOB                #         P66HZ COMES HERE TOO

# ********************************
# HORIZONTAL CONTROL EQUATION
# ********************************

P66HZ           TC              INTPRET
                DLOAD           PDVL
                                AHZLIM
                                UNFC/2
                VXSC            PDVL
                                QHZ
                                VVECTX
## Page 809
                BVSU
                                VHZC
                V/SC            VSU
                                TAUHZ
                RTB             RTB                     # ZERO X-COMPONENT AND UNITIZE
                                ZEROMPAC
                                NORMUNX1
                PDDL            SL*                     # CORRECT MAGNITUDE FOR NORMUNX1 SHIFT
                                36D
                                0,1
                RTB             VXSC                    # LIMIT MAGNITUDE TO AHZLIM
                                MPACLIM
                EXIT

                CA              GHZ                     # X-COMPONENT = GRAVITY
                TS              MPAC

                CA              OVFIND                  # ANY INTERPRETIVE OVERFLOW?
                EXTEND
                BZF             ENGARM?                 # NO:   CONTINUE CHECKING

                TC              BANKCALL                # YES:  ISSUE ALARM BUT NO COMMANDS
                FCADR           OVFDESC
                TCF             END66JOB

ENGARM?         CAF             BIT3                    # IS ENGINE-ARM SWITCH ON?
                EXTEND
                RAND            CHAN30
                EXTEND
                BZF             CDUWHZ                  # YES:  LIMIT AND ISSUE COMMANDS

                CS              FLAGWRD0                # NO:   HAS ASTRONAUT RESPONDED TO P06N60?
                MASK            P66PROBT
                EXTEND
                BZF             CDUWHZ                  # NO:   LIMIT AND ISSUE COMMANDS

                CA              IDLADR                  # YES:  PREVENT RCS JET FIRINGS
                TS              T5ADR
                TCF             END66JOB

CDUWHZ          TC              INTPRET
                STCALL          UNFC/2                  # MUST STORE FOR SUCCEEDING PASS
                                FINDCDUW
                EXIT

                TCF             END66JOB

# ********************************
# P66 DISPLAY COMPUTATIONS
# ********************************
## Page 810
P66DISPS        TC              INTPRET
                DLOAD           DMP                     # AHZLIM.TAUHZ TO PD 0 FOR MPACLIM BELOW
                                AHZLIM
                                TAUHZ
                PDVL            RTB
                                VVECTX
                                ZEROMPAC
                RTB             PDDL
                                NORMUNX1
                                36D
                SL*             PUSH
                                0,1
                STORE           36D
                RTB             DSQ
                                MPACLIM
                SL1             PDDL
                DSQ             DAD
                DDV             PDDL
                                AHZLIM
## TEXTRA in the following line is cicled
                                TEXTRA
                DMP             DAD
                                36D
                DCOMP           VXSC
                DLOAD           PDDL                    # PUSH DOWN Z AND Y COMPS FOR VDEF BELOW
                                MPAC            +5
                                MPAC            +3
                PDDL            DAD                     # COMPUTE X-COMP AS ALTITUDE CORRECTED
                                ALTITUDE
                                DALTEYE
                VDEF            UNIT                    # FORM UNIT VECTOR FROM SITE TO EYE IN SM
                RTB             CALL                    #   COORDINATES AND CONVERT TO NB
                                QTPROLOG
                                *SMNB*
                VSR1            EXIT                    # EXIT WITH SINE(LOOKANGL)/4 IN MPAC

                TC              BANKCALL                # LPDFVSUB TAKES IT FROM THERE
                CADR            LPDFVSUB

UNDISP?         INCR            HZCOUNT
                CS              FLAGWRD8                # NO DISPLAYS THIS PASS IF FLUNDISP SET
                MASK            FLUNDBIT
                EXTEND
## The following line is circled, with "ENDOFJOB" written next to END66JOB in the circle.
                BZF             END66JOB

VERTDISP        TC              VACRLEAS
                CAF             V06N60
                TC              BANKCALL
                CADR            REFLASH
                TC              ENDOFJOB                # TERMINATE  IGNORE AND KEEP FLASHING
                TCF             STOPFIRE                # PROCEED    GO TERMINATE P66HZ OUTPUTS
## Page 811
STOPFIRE        TC              DOWNFLAG                # ENTER      TERMINATE P66HZ OUTPUTS
                ADRES           P66PROFL
                TCF             ENDOFJOB

# ********************************
# P66JOB SUBROUTINES
# ********************************

ZEROVHZC        CAF             ZERO                    # THE X-COMPONENT OF VHZC NEVER MATTERS,
                TS              VHZC            +2      #   AND BESIDES IT OVERLAPS VDGVERT
                TS              VHZC            +3
                TS              VHZC            +4
                TS              VHZC            +5
                TC              Q

## In the margine on the right, a note is written in:
## <pre>
## make it a
## REFLASHR
## and -increment HZ-
## go to END66JOB on
## the R ----?
## </pre>
## "increment HZ" is scratched out.

                EBANK=          PHSNAME3
P66CHNG         CAF             EBANK3
                XCH             EBANK
                DXCH            L
                TS              PHSNAME3
                LXCH            EBANK
                TC              A

                EBANK=          ELVIRA

# ********************************
# P66JOB CONSTANTS
# ********************************

IDLADR          GENADR          DAPIDLER

P66KPIP         DEC             .0512                   # SCALES PIPAS TO UNITS OF 2(5) M/CS

P66KPIPB        DEC             .8192

RIMUZ           DEC             99.486          B-14    # 1.2667 M IN UNITS (180/PI 45) 2(14) CM

GHZ             DEC             +1.62292        E-4 B+4 #           LUNAR GRAVITY

P66PMIN         DEC             37.5            B-9

DALTEYE         2DEC            5               B-15    # ROUGH DISTANCE FROM EYE TO LR ANTENNA

## Page 812
V06N60          VN              0660

DEC48           =               SUPER011

2SECS(9)        DEC             200             B-9

# ****************************************************************************************************************
# REDESIGNATOR TRAP
# ****************************************************************************************************************

                SETLOC          RODTRAP
                BANK

                COUNT*          $$/F2DPS

PITFALL         XCH             BANKRUPT
                EXTEND
                QXCH            QRUPT

                CS              BIT7                    # ARE WE IN P64 OR P66?
                AD              MODREG
                CCS             A
                MASK            OCT37776
                CCS             A
                TC              RESUME                  # NO:   RESUME IMMEDIATELY

                EXTEND                                  # YES
                READ            CHAN31
                COM
                MASK            ALL4BITS
                TS              ELVIRA
                CAF             TWO
                TS              ZERLINA
                CAF             FIVE
                TC              WAITLIST
                EBANK=          ZERLINA
                2CADR           REDESMON

                TCF             RESUME


ALL4BITS        OCT             00063


# REDESIGNATION MONITOR  (INITIATED BY PITFALL)
## Page 813
                SETLOC          F2DPS*11
                BANK
                COUNT*          $$/F2DPS

PREMON1         TS              ZERLINA
PREMON2         CAF             SEVEN
                TC              VARDELAY
REDESMON        EXTEND
                READ            31
                COM
                MASK            OCT00063
                XCH             ELVIRA
                TS              L
                CCS             ELVIRA                  # DO ANY BITS APPEAR THIS PASS?
                TCF             PREMON2                 #   Y: CONTINUE MONITOR

                CCS             L                       #   N: ANY LAST PASS?
                TCF             COUNT'EM                #      Y: COUNT 'EM, RESET RUPT, TERMINATE
                CCS             ZERLINA                 #      N: HAS ZERLINA REACHED ZERO YET?
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
                BZF             RESETRPT

                CAF             BIT10                   # NO:   DOES AGS HAVE CONTROL?
                EXTEND
                RAND            CHAN30
                CCS             A
                TCF             RESETRPT

                CA              L                       # NO
                MASK            -AZBIT
                CCS             A
-AZ             CS              ONE
                ADS             AZCOUNT1
                CA              L
                MASK            +AZBIT
                CCS             A
+AZ             CA              ONE
                ADS             AZCOUNT1
                CA              L
                MASK            -ELBIT
## Page 814
                CCS             A
-EL             CS              ONE
                ADS             ELCOUNT1
                CA              L
                MASK            +ELBIT
                CCS             A
+EL             CA              ONE
                ADS             ELCOUNT1
                TCF             RESETRPT

# THESE EQUIVALENCIES ARE BASED ON GSOP CHAPTER 4, REVISION 16 OF P64LM


+ELBIT          =               BIT2                    # -PITCH


-ELBIT          =               BIT1                    # +PITCH


+AZBIT          =               BIT5


-AZBIT          =               BIT6


OCT00063        OCT             00063


# ****************************************************************************************************************
# R.O.D. TRAP
# ****************************************************************************************************************

                SETLOC          RODTRAP
                BANK
                COUNT*          $$/F2DPS

DESCBITS        MASK            BIT7                    # COME HERE FROM MARKRUPT CODING WITH BIT
                CCS             A                       #   7 OR 6 OF CHANNEL 16 IN A: BIT 7 MEANS
                CS              TWO                     #   - RATE INCREMENT, BIT 6 + INCREMENT
                AD              ONE
                ADS             RODCOUNT
                TCF             RESUME                  # TRAP IS RESET WHEN SWITCH IS RELEASED


                BANK            31
                SETLOC          F2DPS*31
                BANK

                COUNT*          $$/F2DPS

## Page 815
# ****************************************************************************************************************
# DOUBLE PRECISION ROOT FINDER SUBROUTINE (BY ALLAN KLUMPP)
# ****************************************************************************************************************

#                                                         N        N-1
#          ROOTPSRS FINDS ONE ROOT OF THE POWER SERIES A X  + A   X    + ... + A X + A
#                                                       N      N-1              1     0

# USING NEWTON'S METHOD STARTING WITH AN INITIAL GUESS FOR THE ROOT. THE ENTERING DATA MUST BE AS FOLLOWS:

#                                         A        SP     LOC-3           ADRES FOR REFERENCING PWR COF TABL
#                                         L        SP     N-1             N IS THE DEGREE OF THE POWER SERIES
#                                         MPAC     DP     X               INITIAL GUESS FOR ROOT

#                                         LOC-2N   DP     A(0)
#                                                  ...
#                                         LOC      DP     A(N)
#                                         LOC+2    SP     PRECROOT        PREC RQD OF ROOT (AS FRACT OF 1ST GUESS)

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

# 3. AT PRESENT, ERASABLE LOCATIONS ARE RESERVED ONLY FOR N UP TO 5.   AN N IN EXCESS OF 5 WILL PRODUCE CHAOS.
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
## Page 816
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

## Page 817
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

ZEROMPAC        CAF             ZERO                    # ROUTINE TO ZERO THE FIRST COMPONENT
## Page 818
                TS              MPAC                    #   OF A VECTOR IN MPAC.   "TCF DANZIG"
                TS              MPAC            +1      #   COULD BE A "TC Q" AT THE EXPENSE OF
                TCF             DANZIG                  #   A TINY AMOUNT OF TIME.

ZEROMID         CAF             ZERO                    # ROUTINE TO ZERO THE MIDDLE COMPONENT
                TS              MPAC            +3      #   OF A VECTOR IN MPAC.   "TCF DANZIG"
                TS              MPAC            +4      #   COULD BE A "TC Q" AT THE EXPENSE OF
                TCF             DANZIG                  #   A TINY AMOUNT OF TIME.


MPACLIM         LXCH            MPAC                    # THIS SUBROUTINE LIMITS THE CONTENTS OF
                INDEX           FIXLOC                  #   MPAC TO THE SP CONTENTS OF PD 0
                CA              0
                TC              BANKCALL
                CADR            LIMITSUB
                TS              MPAC
                TCF             DANZIG

INTPRETX        INDEX           WCHPHASE                # SET X1 ON THE WAY TO THE INTERPRETER
                CS              TARGTDEX
                INDEX           FIXLOC
                TS              X1
                TCF             INTPRET


TDISPSET        CA              TTF/8
                EXTEND
                MP              TSCALINV
                DXCH            TTFDISP

                TC              Q

LPDFVSUB        TC              MAKECADR
                TS              MPAC            +5

                DXCH            MPAC
                DDOUBL
                TC              BANKCALL
                CADR            SPARCSIN        -1
                AD              1/2DEG
                AD              ELBIAS
                EXTEND
                MP              180DEGS
                TS              LOOKANGL

                EXTEND                                  # HERE IF LOOKANGL IS NOT BETWEEN ZERO AND
                BZMF            +5                      #   75 IT IS SET TO 99 FOR DISPLAY
                CS              DEC75
                AD              LOOKANGL
                EXTEND
## Page 819
                BZMF            +3
 +5             CAF             DEC99
                TS              LOOKANGL

 +3             EXTEND                                  # RESCALE FORVEL TO 1 F/S/BIT
                DCA             FORVEL
                DXCH            MPAC
                CAF             FVSCALE
                TC              SHORTMP
                CA              MPAC            +1      # ROUND TO NEAREST F/S
                DOUBLE
                TS              Q
                CAF             ZERO
                ADS             MPAC

                LXCH            MPAC                    # TRUNCATE AT 99 F/S
                CAF             DEC99
                TC              BANKCALL
                CADR            LIMITSUB
                TS              FORVDSKY

                CA              MPAC            +5
                TC              BANKJUMP

DEC75           DEC             75


DEC99           DEC             99


180DEGS         DEC             180


1/2DEG          DEC             .00278


FVSCALE         DEC             328.084         B-9     # SCALES 2(5) M/CS TO 1 F/S/BIT


1406POO         TC              POODOO
                OCT             21406
1406ALM         TC              ALARM
                OCT             01406
                TCF             RATESTOP

OVFDESC         EXTEND
                QXCH            OVFRET

                TC              ALARM
                OCT             01410

## Page 820
                INHINT                                  # MUST USE INHINT, IBNKCALL, RELINT
                TC              IBNKCALL                # BECAUSE DAP COULD INTERRUPT STOPRATE AND
                FCADR           STOPRATE                # BECAUSE WE COME FROM P66HZ VIA BANKCALL
                RELINT

                CA              ZERO
                TS              OVFIND

                TC              OVFRET

# ****************************************************************************************************************
# SPECIALIZED "PHASCHNG" SUBROUTINE
# ****************************************************************************************************************

FASTCHNG        =               SERVCHNG

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

## Page 821
ELEACH          DEC             .01746                  # ONE DEGREE


AZEACH          =               ELEACH                  # ONE DEGREE

PROJMAX         DEC             .42262          B-3     # SIN(25')/8 TO COMPARE WITH PROJ


PROJMIN         DEC             .25882          B-3     # SIN(15')/8 TO COMPARE WITH PROJ


V06N63          VN              0663                    # P63

V06N64          VN              0664                    # P64

                BANK            22
                SETLOC          LANDCNST
                BANK
                COUNT*          $$/F2DPS

HIGHESTF        2DEC            4.34546769      B-12

GSCALE          2DEC            100             B-11

2/3DP           2DEC            .333333333

3/8DP           2DEC            .375

3/4DP           2DEC            .750

DEPRCRIT        2DEC            -.02 B-1

# ****************************************************************************************************************
# ****************************************************************************************************************
