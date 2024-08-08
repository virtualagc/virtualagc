#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   CHECKNAM.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-24 RSB  Imported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR    import ERROR
from CHECKASS import CHECK_ASSIGN_CONTEXT
from SETXREFR import SET_XREF_RORS

#*************************************************************************
# PROCEDURE NAME:  CHECK_NAMING
# MEMBER NAME:     CHECKNAM
# INPUT PARAMETERS:
#          VALUE             FIXED
#          LOC               BIT(16)
# LOCAL DECLARATIONS:
#          H1                FIXED
#          ACCESS_NAME       LABEL
#          H2                FIXED
# EXTERNAL VARIABLES REFERENCED:
#          ACCESS_FLAG
#          CLASS_A
#          CLASS_EN
#          DENSE_FLAG
#          EXTERNAL_FLAG
#          INP_OR_CONST
#          MAJ_STRUC
#          MISC_NAME_FLAG
#          MP
#          NONHAL_FLAG
#          SYM_FLAGS
#          SYM_TYPE
#          SYT_FLAGS
#          SYT_TYPE
#          TASK_LABEL
#          TEMPORARY_FLAG
#          VAL_P
#          XREF_ASSIGN
# EXTERNAL VARIABLES CHANGED:
#          FIXL
#          FIXV
#          PTR
#          SYM_TAB
#          VAR
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          CHECK_ASSIGN_CONTEXT
#          SET_XREF_RORS
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def CHECK_NAMING(VALUE, LOC):
    # Locals: H1, H2.
    goto = None
    
    g.PTR[g.MP] = g.PTR[LOC];
    H2 = g.VAL_P[g.PTR[g.MP]];
    g.VAR[g.MP] = g.VAR[LOC];
    H1 = g.SYT_FLAGS(g.FIXL[LOC]);
    # DO CASE VALUE;
    if VALUE == 0:
        # DO
        #  LABEL REFERENCE
        SET_XREF_RORS(LOC);
        if not (SHR(H2, 9) & 1):  # DO
            # DISCONNECT SYT_FLAGS FROM NONHAL **
            if (g.SYT_FLAGS2(g.FIXL[LOC]) & g.NONHAL_FLAG) != 0:
                ERROR(d.CLASS_EN, 5, g.VAR[g.MP]);
            # ** END DR108643 **
            elif g.SYT_TYPE(g.FIXL[LOC]) < g.TASK_LABEL:
                if (H1 & g.EXTERNAL_FLAG) == 0: 
                    ERROR(d.CLASS_EN, 6, g.VAR[g.MP]);
            # CHECK IF VAL_P 0x4000 BIT IS SET. IF IT IS, THERE
            # IS A NAME VARIABLE IN THE STRUCTURE REFERENCE LIST;
            # THIS STRUCTURE CANNOT HAVE ITS MISC_NAME_FLAG SET.
            if not (SHR(H2, 14) & 1): 
                g.SYT_FLAGS(g.FIXL[LOC], H1 | g.MISC_NAME_FLAG);
            goto = "ACCESS_NAME";
        # END
        # END
    # Notice that case 1 is an "if" rather than an "elif" in order to allow
    # GO TO ACCESS_NAME to fall into it.
    if (VALUE == 1 and goto == None) or goto == "ACCESS_NAME":
        # DO
        #  DATA RFEFERENCE
        if goto == None:
            if SHR(H2, 4) & 1: 
                ERROR(d.CLASS_EN, 7, g.VAR[g.MP]);
            SET_XREF_RORS(LOC);
        if goto == "ACCESS_NAME" or not (SHR(H2, 9) & 1):  # DO
            if goto == None:
                if (H2 & 0x6) == 0x2: ERROR(d.CLASS_EN, 13, g.VAR[g.MP]);
                if (H1 & g.DENSE_FLAG) != 0: 
                    if g.SYT_TYPE(g.FIXL[LOC]) < g.MAJ_STRUC:
                        ERROR(d.CLASS_EN, 8, g.VAR[g.MP]);
                if g.FIXV[LOC] > 0:  # DO
                    if g.SYT_TYPE(g.FIXL[LOC]) == g.MAJ_STRUC:
                        ERROR(d.CLASS_EN, 9, g.VAR[g.MP]);
                    H1 = g.SYT_FLAGS(g.FIXV[LOC]);
                    # CHECK IF VAL_P 0x4000 BIT IS SET. IF IT IS, THERE
                    # IS A NAME VARIABLE IN THE STRUCTURE REFERENCE LIST;
                    # THIS STRUCTURE CANNOT HAVE ITS MISC_NAME_FLAG SET.
                    if not (SHR(H2, 14) & 1): 
                        g.SYT_FLAGS(g.FIXV[LOC], H1 | g.MISC_NAME_FLAG);
                # END
                # CHECK IF VAL_P 0x4000 BIT IS SET. IF IT IS, THERE
                # IS A NAME VARIABLE IN THE STRUCTURE REFERENCE LIST;
                # THIS STRUCTURE CANNOT HAVE ITS MISC_NAME_FLAG SET.
                elif not (SHR(H2, 14 & 1)): 
                    g.SYT_FLAGS(g.FIXL[LOC], H1 | g.MISC_NAME_FLAG);
                if not (SHR(H2, 14) & 1):  # DO
                    if (H1 & g.TEMPORARY_FLAG) != 0: ERROR(d.CLASS_EN, 10, g.VAR[g.MP]);
                    if (H1 & g.INP_OR_CONST) != 0: ERROR(d.CLASS_EN, 11, g.VAR[g.MP]);
                # END
            if goto == "ACCESS_NAME": goto = None
            if (H1 & g.ACCESS_FLAG) != 0: ERROR(d.CLASS_EN, 12, g.VAR[g.MP]);
        # END
        # END
    elif VALUE == 2:
        pass;
        #  ERROR CASE
    elif VALUE == 3:
        # DO
        #  ASSIGNMENT
        if SHR(H2, 9) & 1:  # DO
            if SHR(H2, 3) & 1: ERROR(d.CLASS_A, 2, g.VAR[g.MP]);
            #  CHECK THE BITMASK OF 0x24 INSTEAD OF 0x28 FOR ILLEGAL
            #  SUBSCRIPTS OF A NAME STRUCTURE
            elif (H2 & 0x24) == 0x24: ERROR(d.CLASS_A, 2, g.VAR[g.MP]);
            CHECK_ASSIGN_CONTEXT(LOC);
        # END
        else:  # DO
            ERROR(d.CLASS_A, 3, g.VAR[g.MP]);
            SET_XREF_RORS(g.MP, 0, g.XREF_ASSIGN);
        # END
        # END
    # END DO CASE
    g.FIXL[g.MP] = g.FIXL[LOC];
    g.FIXV[g.MP] = g.FIXV[LOC];
    if SHR(H2, 6) & 1: 
        ERROR(d.CLASS_EN, 14);
# END CHECK_NAMING;
