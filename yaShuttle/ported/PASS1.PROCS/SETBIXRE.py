#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   SETBIXRE.xpl
Purpose:    This is a part of the HAL/g.S-FC compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Language:   XPL.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported.
'''

from xplBuiltins import *
import g
from HALINCL.ENTERXRE import ENTER_XREF

#*************************************************************************
# PROCEDURE NAME:  SET_BI_XREF
# MEMBER NAME:     SETBIXRE
# INPUT PARAMETERS:
#          LOC               BIT(16)
# LOCAL DECLARATIONS:
#          TAG               BIT(16)
#          NEW_XREF          MACRO
# EXTERNAL VARIABLES REFERENCED:
#          COMM
#          CR_REF
#          CROSS_REF
#          STMT_NUM
#          SUBSCRIPT_LEVEL
#          TRUE
#          XREF_MASK
#          XREF_REF
#          XREF_SUBSCR
#          XREF
# EXTERNAL VARIABLES CHANGED:
#          BI_XREF
#          BI_XREF#
# EXTERNAL PROCEDURES CALLED:
#          ENTER_XREF
# CALLED BY:
#          SETUP_NO_ARG_FCN
#          START_NORMAL_FCN
#          SYNTHESIZE
#*************************************************************************

    
def SET_BI_XREF(LOC):
    # Locals are TAG and NEW_XREF, but NEW_XREF is a macro I've changed to
    # a function..

    def NEW_XREF():
        return (g.XREF(g.BI_XREF[LOC]) & g.XREF_MASK) != g.STMT_NUM();

    if g.SUBSCRIPT_LEVEL > 0: 
        TAG = g.XREF_SUBSCR;
    elif (SHR(g.ATOMS(g.LAST_POPp), 24) == 1) and (LOC == g.SBIT_NDX): 
        TAG = g.XREF_ASSIGN;
    else: 
        TAG = g.XREF_REF;
    if NEW_XREF(): 
        g.BI_XREFp[LOC] = g.BI_XREFp[LOC] + 1;
    g.BI_XREF[LOC] = ENTER_XREF(g.BI_XREF[LOC], TAG);
    g.BI_XREF[0] = g.TRUE;
# END SET_BI_XREF;
