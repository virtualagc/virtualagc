### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    R31.agc
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
##              2021-05-30 ABS  Aligned IAW to field boundary.



                BANK    34
                SETLOC  R31
                BANK

                COUNT*  $$/R31

DISPN5X         CA      FLAGWRD9        # TEST R31FLAG (IN SUNDANCE R31FLAG WILL
                MASK    BIT4            #     ALWAYS BE SET AS R34 DOES NOT EXIST)
                EXTEND
                BZF     +3
                CAF     V06N54          # R31    USE NOUN 54
                TC      +2
                CAF     V06N53          # R34    USE NOUN 53
                TC      BANKCALL
                CADR    GOMARKFR
                TC      B5OFF
                TC      B5OFF
                TC      ENDOFJOB

                CAF     PRIO4
                TC      PRIOCHNG
                CAF     .5SEC
                TC      BANKCALL
                CADR    DELAYJOB

V83             TC      INTPRET
                CALL
                        REDOEXTP
                GOTO
                        COMPDISP                        
V83CALL         TC      INTPRET
                CALL
                        STATEXTP        # EXTRAPOLATE STATE VECTORS
COMPDISP        VLOAD   VSU
                        RATT
                        RONE
                PUSH    ABVAL           # RATT-RONE TO 0D               PD = 6
                STORE   RANGE           # METERS B-29
                NORM    VLOAD
                        X1              # RATT-RONE                     PD = 0
                VSL*    UNIT
                        0,1
                PDVL    VSU             # UNIT(LOS) TO 0D              PD = 6
                        VATT
                        VONE
                DOT                     # (VATT-VONE).UNIT(LOS)        PD = 0
                SL1
                STCALL  RRATE           # RANGE RATE M/CS B-7
                        CDUTRIG         # TO INITIALIZE FOR *NBSM*
R34ANG          VLOAD   UNIT
                        RONE
                PDVL                    # UR TO 0D                    PD= 6
                        THISAXIS        # UNITX FOR CM, UNITZ FOR LM
                BON     VLOAD           # CHK R31FLAG. ON=R31 THETA, OFF=R34 PHI
                        R31FLAG
                        +2              #     R31-THETA
                        THISAXIS
                CALL    
                        *NBSM*
                VXM     PUSH            # UXORZ TO 6D                  PD=12D
                        REFSMMAT
                VPROJ   VSL2
                        0D
                BVSU    UNIT
                        6D
                PDVL    VXV             # UP/2 TO 12D                  PD=18D
                        RONE
                        VONE
                UNIT    VXV
                        RONE
                DOT     PDVL            # SIGN TO 12D, UP/2 TO MPAC    PD=18D
                        12D
                VSL1    DOT             # UP.UXORZ
                        6D
                SIGN    SL1
                        12D
                ACOS
                STOVL   RTHETA
                        RONE
                DOT     BPL
                        6D
                        +5
                DLOAD   BDSU            # IF UXORZ.R NEG, RTHETA = 1 - RTHETA
                        RTHETA
                        DPPOSMAX
                STORE   RTHETA          # RTHETA BETWEEN 0 AND 1 REV.
                EXIT
                CAF     BIT5            # HAVE WE BEEN ANSWERED
                MASK    EXTVBACT
                EXTEND
                BZF     ENDEXT          # YES, DIE

                TC      SETXDSP
                TC      BANKCALL
                CADR    MARKBRAN

                TCF     DISPN5X
V06N54          VN      0654
V06N53          VN      0653
                
# THE STATEXTP SUBROUTINE DOES A PRECISION EXTRAPOLATION OF BOTH VEHICLES
# STATE VECTORS TO PRESENT TIME AND SAVES THEM AS BASE VECTORS.
# IF SERVICER IS OFF ---
#                 THIS VEHICLES BASE VECTOR IS CONIC EXTRAPOLATED TO
#                 PRESENT TIME AND SAVED AS RONE, VONE.
#                 THE OTHER VEHICLES BASE VECTOR IS CONIC EXTRAPOLATED
#                 TO THE SAME TIME, THE OUTPUT BEING LEFT IN RATT, VATT.
# IF SERVICER IS ON ---
#                 RONE, VONE ARE SET EQUAL TO RN, VN AND THE OTHER
#                 VEHICLES STATE VECTOR IS PREC. EXTRAPOLATED TO PIPTIME.

STATEXTP        STQ     RTB
                        STATEXIT
                        LOADTIME
                STCALL  TDEC1
                        OTHPREC         # GET BASE VECTORS
                VLOAD
                        RATT1
                STOVL   BASEOTP         # OTHER POS.
                        VATT1
                STODL   BASEOTV         # OTHER VEL.
                        TAT
                STORE   BASETIME
                STCALL  TDEC1
                        THISPREC
                VLOAD
                        RATT1
                STOVL   BASETHP         # THIS POS.
                        VATT1
                STORE   BASETHV         # THIS VEL
HAVEBASE        BON     RTB
                        V37FLAG
                        GETRVN          # IF AVG ON ,GET RN ETC.
                        LOADTIME
                STCALL  TDEC1           # BEGIN SET UP FOR CONIC EXTRAP. FOR THIS.
                        INTSTALL
                VLOAD   CLEAR
                        BASETHP
                        MOONFLAG
                STOVL   RCV
                        BASETHV
                STODL   VCV
                        BASETIME
                BOF     SET             # GET APPROPRIATE MOONFLAG SETTING
                        MOONTHIS
                        +2
                        MOONFLAG
                SET
                        INTYPFLG        # CONIC EXTRAP.
                STCALL  TET
                        INTEGRVS        # INTEGRATION --- AT LAST---
OTHCONIC        VLOAD
                        RATT
                STOVL   RONE
                        VATT
                STCALL  VONE            # GET SET FOR CONIC EXTRAP.,OTHER.
                        INTSTALL
                SET     DLOAD
                        INTYPFLG
                        TAT
OTHINT          STORE   TDEC1
                VLOAD   CLEAR
                        BASEOTP
                        MOONFLAG
                STOVL   RCV
                        BASEOTV
                STODL   VCV
                        BASETIME
                BOF     SET
                        MOONTHIS
                        +2
                        MOONFLAG
                STCALL  TET
                        INTEGRVS
                GOTO
                        STATEXIT        # THIS VEHICLES POS.,VEL. IN PUSHLIST.
GETRVN          VLOAD
                        RN
                STOVL   RONE
                        VN
                STODL   VONE
                        PIPTIME
                CALL
                        INTSTALL
                CLEAR   GOTO
                        INTYPFLG        # PREC EXTRAP FOR OTHER
                        OTHINT
REDOEXTP        STQ     GOTO
                        STATEXIT
                        HAVEBASE

