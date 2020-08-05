### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    S-BAND_ANTENNA_FOR_LM.agc
## Purpose:     A section of an attempt to reconstruct Sundance revision 306
##              as closely as possible with available information. Sundance
##              306 is the source code for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 9. This program was created
##              using the mixed-revision SundanceXXX as a starting point, and
##              pulling back features from Luminary 69 believed to have been
##              added based on memos, checklists, observed address changes,
##              or the Sundance GSOPs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-07-24 MAS  Created from SundanceXXX.



# SUBROUTINE NAME: R05 - S-BAND ANTENNA FOR LM
#
# MOD0 BY T. JAMES
# MOD1 BY P. SHAKIR
#
# FUNCTIONAL DESCRIPTION
#
#       THE S-BAND ANTENNA ROUTINE, R05, COMPUTES AND DISPLAYS THE PITCH AND
# YAW ANTENNA GIMBAL ANGLES REQUIRED TO POINT THE LM STEERABLE ANTENNA
# TOWARD THE CENTER OF THE EARTH.  THIS ROUTINE IS SELECTED BY THE ASTRO-
# NAUT VIA DSKY ENTRY DURING COASTING FLIGHT OR WHEN THE LM IS ON THE MOON
# SURFACE.  THE EARTH OR MOON REFERENCE COORDINATE SYSTEM IS USED DEPENDING
# ON WHETHER THE LM IS ABOUT TO ENTER OR HAS ALREADY ENTERED THE MOON
# SPHERE OF INFLUENCE, RESPECTIVELY
#
# TO CALL SUBROUTINE, ASTRONAUT KEYS IN V 64 E
#
# SUBROUTINES CALLED-
#       R02BOTH
#       INTPRET
#       LOADTIME
#       LEMCONIC
#       LUNPOS
#       CDUTRIG
#       *SMNB*
#       BANKCALL
#       B5OFF
#       ENDOFJOB
#       BLANKET
#
# RETURNS WITH
#       PITCH ANGLE IN PITCHANG  REV. B0
#       YAW ANGLE IN YAWANG  REV. B0
#
# ERASABLES USED
#       PITCHANG
#       YAWANG
#       RLM
#       VAC AREA

                BANK    41
                SETLOC  SBAND
                BANK
                
                EBANK=  WHOCARES
                COUNT*  $$/R05
SBANDANT        CAF     BIT5
                ADS     EXTVBACT
                TC      BANKCALL
                CADR    R02BOTH         # CHECK IF IMU IS ON AND ALIGNED
                TC      INTPRET
                RTB     CALL
                        LOADTIME        # PICK UP CURRENT TIME
                        CDUTRIG
                STCALL  TDEC1           # ADVANCE INTEGRATION TO TIME IN TDEC1
                        LEMCONIC        # USING CONIC INTEGRATION
                VLOAD
                        RATT
                STORE   RLM
                DLOAD
                        TAT
CONV3           CALL
                        LUNPOS          # UNIT POSITION VECTOR FROM EARTH TO MOON
                VAD     VCOMP
                        RLM
                MXV     VSL1            # TRANSFORM REF. COORDINATE SYSTEM TO
                        REFSMMAT        # STABLE MEMBER B-1 X B-1 X B+1 = B-1
                PUSH    DLOAD           # 8D
                        HI6ZEROS
                STORE   PITCHANG
                STOVL   YAWANG          # ZERO OUT ANGLES
                        RLM
                CALL
                        *SMNB*
                STORE   RLM             # PRE-MULTIPLY RLM BY (NBSA) MATRIX(B0)
                UNIT    PDVL
                        RLM
                VPROJ   VSL2            # PROJECTION OF R ONTO LM XZ PLANE
                        HIUNITY
                BVSU    BOV             # CLEAR OVERFLOW INDICATOR IF ON
                        RLM
                        COVCNV
COVCNV          UNIT    BOV             # EXIT ON OVERFLOW
                        SBANDEX
                PUSH    VXV             # URP VECTOR B-1
                        HIUNITZ
                VSL1    VCOMP           # UZ X URP = -(URP X UZ)
                STORE   RLM             # X VEC B-1
                ABVAL
                STOVL   PITCHANG
                        RLM
                DOT     SL1             # SGN(X.UY) UNSCALED
                        HIUNITY
                STODL   RLM
                        PITCHANG
                SIGN    ASIN            # ASIN((SGN(X.UY))ABV(X)) REV B0
                        RLM
                STOVL   PITCHANG
                        URP
                DOT     SL1
                        HIUNITZ
                BPL     DLOAD
                        NOADJUST        # YES, -90 TO +90
                        HIDPHALF
                DSU
                        PITCHANG
                STORE   PITCHANG
NOADJUST        VLOAD   VXV
                        UR              # Z = (UR X URP)
                        URP
                VSL1
                STORE   RLM             # Z VEC B-1
                DLOAD   SIN
                        PITCHANG
                VXSC    VSL1
                        HIUNITZ
                STODL   UR
                        PITCHANG
                COS     VXSC
                        HIUNITX         # (UX COS ALPHA) - (UZ SIN ALPHA)
                VSL1    VSU
                        UR
                DOT     SL1             # YAW.Z
                        RLM
                STOVL   UR
                        RLM
                ABVAL   SIGN
                        UR
                ASIN
                STORE   YAWANG
SBANDEX         EXIT
                CAF     V06N51          # DISPLAY ANGLES
                TC      BANKCALL
                CADR    GOMARKFR
                TC      B5OFF           # TERMINATE
                TC      ENDOFJOB        # PROCEED
                TC      ENDOFJOB        # RECYCLE
                CAF     BIT3            # IMMEDIATE RETURN
                TC      BLANKET         # BLANK R3
                CA      EXTVBACT
                MASK    BIT5            # IS BIT5 STILL ON
                EXTEND
                BZF     ENDEXT          # NO
                TC      SBANDANT +2     # YES, CONTINUE DISPLAYING ANGLES
V06N51          VN      0651

UR              EQUALS  8D
URP             EQUALS  14D
                SBANK=  LOWSUPER
