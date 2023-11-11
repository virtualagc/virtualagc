#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   NAMECOMP.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-30 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR    import ERROR
from RESETARR import RESET_ARRAYNESS
from STRUCTUR import STRUCTURE_COMPARE

#*************************************************************************
# PROCEDURE NAME:  NAME_COMPARE
# MEMBER NAME:     NAMECOMP
# INPUT PARAMETERS:
#          LOC1              BIT(16)
#          LOC2              BIT(16)
#          R_CLASS           BIT(16)
#          R_NO              BIT(16)
#          G                 BIT(16)
# LOCAL DECLARATIONS:
#          C1                BIT(16)
#          C2                BIT(16)
#          EXTN1_PTR         BIT(16)
#          EXTN2_PTR         BIT(16)
#          FIND_EXTN1(1)     LABEL
#          FIND_EXTN2        LABEL
#          F1                FIXED
#          F2                FIXED
#          NAME_MASK         FIXED
#          NODE1_PTR         BIT(16)
#          NODE1_SYT_PTR     BIT(16)
#          NODE2_PTR         BIT(16)
#          NODE2_SYT_PTR     BIT(16)
#          NUM_LOC1_OPS      BIT(16)
#          NUM_LOC2_OPS      BIT(16)
#          QQ                BIT(16)
#          STRUC_SYT_FLAGS_LOC1  FIXED
#          STRUC_SYT_FLAGS_LOC2  FIXED
#          VAR1_FLAGS        FIXED
#          VAR2_FLAGS        FIXED
# EXTERNAL VARIABLES REFERENCED:
#          CONST_ATOMS
#          ATOMS
#          FIXL
#          FIXV
#          FOR_ATOMS
#          LOC_P
#          LOCK_FLAG
#          NAME_FLAG
#          PSEUDO_LENGTH
#          PSEUDO_TYPE
#          PTR
#          SYM_CLASS
#          SYM_FLAGS
#          SYM_LOCK#
#          SYM_TAB
#          SYM_TYPE
#          SYT_CLASS
#          SYT_FLAGS
#          SYT_LOCK#
#          SYT_TYPE
#          TEMPL_NAME
#          TEMPLATE_CLASS
#          TRUE
#          VAL_P
#          XVAC
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          RESET_ARRAYNESS
# CALLED BY:
#          SETUP_CALL_ARG
#          SYNTHESIZE
#*************************************************************************

NAME_MASK = 0x00C20000;


def NAME_COMPARE(LOC1, LOC2, R_CLASS, R_NO, G=g.TRUE):
    # Note that although TRUE by default, G is BIT(16) not BIT(1).
    # Locals: QQ, C1, C2, F1, F2, NAME_MASK, VAR_1_FLAGS, VAR_2_FLAGS, ST_R_NO.
    
    ST_R_NO = R_NO - 1;
    C1 = g.FIXL[LOC1];
    C2 = g.FIXL[LOC2];
    #  POINTS TO TEMPLATES FOR STRUCTS BUT DOESNT MATTER SINCE
    #  FLAGS AND CLASS MATCHING CANNOT FAULT ERRONEOUSLY
    F1 = g.VAL_P[g.PTR[LOC1]];
    F2 = g.VAL_P[g.PTR[LOC2]];
    #  G IS TRUE FOR NAME COMPARISONS AND THE FIRST TIME THE PROCEDURE IS
    #  CALLED FOR NAME ASSIGNMENTS.
    #  G IS FALSE FOR EACH ADDITIONAL LHS VARIABLE OF NAME ASSIGNMENTS.
    #  IT IS 0 BECAUSE F2 REPRESENTS THE LHS VARIABLE THAT HAS ALREADY
    #  BEEN PROCESSED IN NAME_COMPARE AND RESET_ARRAYNESS SHOULD NOT BE
    #  CALLED AGAIN FOR THE VARIABLE.
    #  THE BELOW STATEMENT IS DETERMINING HOW MANY TIMES RESET_ARRAYNESS
    #  SHOULD BE CALLED.  ((F1/F2 & 0x500) = 0x100) IS FALSE WHEN 'NULL'
    #  IS IN THE NAME PSEUDO-FUNCTION.  RESET_ARRAYNESS DETERMINES IF
    #  ARRAYNESS MATCHES AND MOVES THE ARRAYNESS_STACK POINTER (AS_PTR)
    #  TO THE CORRECT LOCATION.
    QQ = (((F2 & 0x500) == 0x100) and (G & 1)) + ((F1 & 0x500) == 0x100);
    # CHECKING IF BOTH VARIABLES ARE IN A NAME PSEUDO-FUNCTION
    if not (SHR(F1 & F2, 8) & 1): ERROR(R_CLASS, R_NO);
    # IF NEITHER VARIABLE IS NULL THEN ENTER BLOCK
    elif not (SHR(F1 | F2, 10) & 1):  # DO
        # THE CODE ADDED TO DETERMINE THE STRUCTURE'S FLAGS WAS REMOVED BY
        # SINCE AV0,C0,FT0 ERRORS ARE NO LONGER EMITTED FOR REMOTE
        # MISMATCH. INSTEAD SET VAR_FLAGS EQUAL TO THE NODE'S FLAGS DIRECTLY.
        # (THIS WILL BE THE TEMPLATE'S FLAGS FOR STRUCTURES).
        VAR1_FLAGS = g.SYT_FLAGS(C1);
        # NOW GET THE RIGHT HAND SIDE.
        VAR2_FLAGS = g.SYT_FLAGS(C2);
        if ((VAR1_FLAGS & NAME_MASK) != (VAR2_FLAGS & NAME_MASK)): 
            R_NO = 0;
        if g.PSEUDO_TYPE[g.PTR[LOC1]] != g.PSEUDO_TYPE[g.PTR[LOC2]]: R_NO = 0;
        elif SHR(F1 | F2, 12) & 1: 
            STRUCTURE_COMPARE(C1, C2, R_CLASS, ST_R_NO);
        else:  # DO
            F1 = g.PSEUDO_LENGTH[g.PTR[LOC1]];
            F2 = g.PSEUDO_LENGTH[g.PTR[LOC2]];
            if not (SHR(F1 | F2, 15) & 1): 
                if F1 != F2: 
                    R_NO = 0;
        # END
        QQ = QQ - 1 - G;
        if G & 1: RESET_ARRAYNESS();
        if RESET_ARRAYNESS() > 0: R_NO = 0;
        F1 = g.SYT_CLASS(C1);
        F2 = g.SYT_CLASS(C2);
        if F1 != F2: 
            if F1 + g.TEMPLATE_CLASS - 1 != F2:
                if F2 + g.TEMPLATE_CLASS - 1 != F1: 
                    R_NO = 0;
        if g.FIXV[LOC1] != 0: C1 = g.FIXV[LOC1];
        if g.FIXV[LOC2] != 0: C2 = g.FIXV[LOC2];
        if (g.SYT_FLAGS(C1) & g.LOCK_FLAG) != (g.SYT_FLAGS(C2) & g.LOCK_FLAG): R_NO = 0;
        elif (g.SYT_FLAGS(C1) & g.LOCK_FLAG) != 0:  # DO
            if SYT_LOCKp(C1) != SYT_LOCKp(C2): 
                R_NO = 0;
        # END
        if R_NO == 0: ERROR(R_CLASS, 0);
    # END
    for QQ in range(1, QQ + 1):
        RESET_ARRAYNESS();
    # END
    G = g.TRUE;
# END NAME_COMPARE;
