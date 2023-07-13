### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PHASE_TABLE_MAINTENANCE.agc
## Purpose:     A section of Aurora 88.
##              It is part of the reconstructed source code for the final
##              release of the Lunar Module system test software. No original
##              listings of this program are available; instead, this file
##              was created via disassembly of dumps of Aurora 88 core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-30 MAS  Created from Aurora 12.


#       THE FOLLOWING ROUTINES ARE PROVIDED TO MAINTAIN THE PHASE TABLE. TWO ROUTINES ARE AVAILABLE:

#               TC      PHASCHNG        SLOWER BUT LESS STORAGE.
#               OCT     PPPGG           CHANGE RESTART GROUP GG TO PHASE PPP
#                                       (PPP IS A SIGNED 8 BIT NUMBER).

#               CA      PPPPP           NEW PHASE ARRIVES IN A.
#               TC      NEWPHASE
#               OCT     000GG           UPDATES GG.

#       IN ALL CASES THE OLD PHASE RETURNS IN A. IF THE OLD PHASE WAS NEGATIVE, CALL A ROUTINE USING THE
# CORRESPONDING TERMCADR.

                SETLOC  ENDWAITF

PHASCHNG        INHINT
                INDEX   Q
                CAF     0               # GET PARAMETER WORD.
                TS      RUPTREG4
                MASK    LOW5            # GROUP NUMBER 0 - 37.
                DOUBLE
                XCH     RUPTREG4
                EXTEND
                MP      BIT9            # SIGNED NEW PHASE.
                TCF     PHASCH2

NEWPHASE        INHINT                  # NEW PHASE ARRIVES IN A.
                TS      RUPTREG4
                INDEX   Q
                CAF     0               # GROUP NUMBER.
                DOUBLE
                XCH     RUPTREG4

PHASCH2         TS      L               # DIRECT VERSION.
                COM                     # COMPLEMENTED VERSION IMMEDIATELY PRE-
                INDEX   RUPTREG4        # CEDES THE DIRECT ONE.
                DXCH    -PHASE0         # COPIES DISAGREE FOR MINIMUM TIME.
                EXTEND
                BZMF    PHASEXIT        # IF NO DERAIL.

                TS      RUPTREG1        # IF NEGATIVE, SAVE ABSOLUTE VALUE OF
                EXTEND                  # OLD PHASE AND RETURN Q.
                QXCH    RUPTREG2
                CA      RUPTREG4        # GET BACK GROUP NUMBER.
                EXTEND
                MP      HALF
                INDEX   A               # SELECT TERMCADR.
                CAF     TERMCADR
                TC      ISWCALL

                DXCH    RUPTREG1        # -OLD PHASE BITS TO A - RETURN -1 TO L.
                LXCH    Q

PHASEXIT        COM                     # RETURN OLD PHASE IN A.
                RELINT
                INDEX   Q
                TC      1

TERMCADR        CADR    10000           # FILLED IN AS NEEDED.
                CADR    10000
                CADR    10000
                CADR    10000
                CADR    10000
                CADR    10000

#       SUBROUTINE TO UPDATE THE PROGRAM NUMBER DISPLAY ON THE DSKY.

NEWMODEX        INDEX   Q               # UPDATE MODREG.
                CAF     0
                INCR    Q
                XCH     MODREG
                COM                     # IF NO CHANGE IN MODE, RETURN IMMEDIATELY
                AD      MODREG
                EXTEND
                BZF     TCQ

                CAF     +2              # CALL PINBALL SUBROUTINE.
                TCF     SWCALL          # WITH Q SET TO CALLERS RETURN.

                CADR    DSPMM

#       RETURN TO CALLER +3 IF MODE = THAT AT CALLER +1. OTHERWISE RETURN TO CALLER +2.

CHECKMM         INDEX   Q
                CS      0
                AD      MODREG
                EXTEND
                BZF     +3

                INDEX   Q
                TC      1               # NO MATCH.

                INDEX   Q
TCQ             TC      2               # (ALWAYS AVAILABLE TO BZF & BZMF)

ENDPHMNF        EQUALS
