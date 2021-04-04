### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    R31.agc
## Purpose:     The main source file for Luminary revision 069.
##              It is part of the source code for the original release
##              of the flight software for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 10. The actual flown
##              version was Luminary 69 revision 2, which included a
##              newer lunar gravity model and only affected module 2.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 712-716
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-13 MAS  Created from Luminary 99.
##              2016-12-14 MAS  Updated from comment-proofed Luminary 99 version.
##              2016-12-15 RRB  Updated for Luminary 69.
##              2017-01-20 HG   add label V16N54
##                              fix label REDOEXPT -> REDOEXTP
##                                        GETRVN   -> GETRVN2
##                              fix operand RRONE   -> RONE 
##                                          REFSMAT -> REFSMMAT
##                                          RHTETA  -> RTHETA
##                                          EDNEXT  -> ENDEXT
##              2017-01-22 HG   Add missing segemnt of interpretive statements
##                              Fix some comments, remove tabs
##		2017-01-28 RSB	Proofed comment text using octopus/prooferComments
##				and fixed errors found.
##              2021-05-30 ABS  Aligned IAW to field boundary.

## Page 712
                BANK    34
                SETLOC  R31
                BANK

                COUNT*  $$/R31

R31CALL         CAF     PRIO3
                TC      FINDVAC
                EBANK=  SUBEXIT
                2CADR   V83CALL

DSPDELAY        TC      FIXDELAY
                DEC     100
                CA      EXTVBACT
                MASK    BIT12
                EXTEND
                BZF     DSPDELAY

                CAF     PRIO5
                TC      NOVAC
                EBANK=  TSTRT
                2CADR   DISPN5X

                TCF     TASKOVER

DISPN5X         CAF     V16N54
                TC      BANKCALL
                CADR    GOMARKF
                TC      B5OFF
                TC      B5OFF
                TCF     DISPN5X
                
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
## Page 713
                PDVL    VSU             # UNIT(LOS) TO 0D              PD = 6
                        VATT
                        VONE
                DOT                     # (VATT-VONE).UNIT(LOS)        PD = 0
                SL1
                STOVL   RRATE           # RANGE RATE M/CS B-7
                        RONE
                UNIT    PDVL            # UR TO 0D                           PD = 6
                        THISAXIS        # UNITX FOR CM, UNTIZ FOR LM
                CALL
                        CDU*NBSM
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
                
                CS      EXTVBACT
                MASK    BIT12
                ADS     EXTVBACT
                
                TCF     V83
V16N54          VN      1654
                
## Page 714
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
                        AVEGFLAG
                        GETRVN          # IF AVG ON ,GET RN ETC.
                        LOADTIME
                BON     GOTO            # TEST FOR LM ON SURFACE.
                        SURFFLAG
                        R31SURF
                        +1
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
## Page 715
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
GETRVN          VLOAD   GOTO
                        RN
                        +1
                STCALL  RONE
                        +1
                VLOAD   GOTO
                        VN
                        +1
                STODL   VONE
                        PIPTIME
GETRVN2         CALL
                        INTSTALL
                CLEAR   GOTO
                        INTYPFLG        # PREC EXTRAP FOR OTHER
                        OTHINT
R31SURF         STCALL  TDEC1           # LM ON SURFACE.
                        LEMPREC
                GOTO                    # DO CSM CONIC
                        OTHCONIC
## Page 716
REDOEXTP        STQ     GOTO
                        STATEXIT
                        HAVEBASE

