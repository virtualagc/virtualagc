#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   CHECKSTR.xpl
Purpose:    Part of the HAL/g.S-FC compiler.
Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description",
section TBD.
Language:   XPL.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported.
'''

from xplBuiltins import SUBSTR
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR


def CHECK_STRUC_CONFLICTS():
    # Locals: SNAME, KIN_REF
    SNAME = g.SYT_NAME(g.ID_LOC);
    if g.SYT_CLASS(g.ID_LOC) != g.VAR_CLASS:
        if g.STRUC_DIM != 0: 
            ERROR(d.CLASS_DD, 12, SNAME);
            g.STRUC_DIM = 0;
        if SUBSTR(g.SYT_NAME(g.STRUC_PTR), 1) == SNAME:
            ERROR(d.CLASS_DQ, 3);
    elif SUBSTR(g.SYT_NAME(g.STRUC_PTR), 1) == SNAME:
        g.KIN = g.STRUC_PTR;
        if g.STRUC_PTR < g.PROCMARK:
            ERROR(d.CLASS_DQ, 5, SNAME);
        elif g.SYT_PTR(g.STRUC_PTR) != 0: 
            ERROR(d.CLASS_DQ, 4, SNAME);
        elif (g.SYT_FLAGS(g.STRUC_PTR) & g.DUPL_FLAG) != 0:
            ERROR(d.CLASS_DQ, 8, SNAME);
        elif (g.SYT_FLAGS(g.STRUC_PTR) & g.EVIL_FLAG) == 0: 
            while True:
                while g.SYT_LINK1(g.KIN) > 0:
                    g.KIN = g.SYT_LINK1(g.KIN);
                if g.SYT_TYPE(g.KIN) == g.MAJ_STRUC: 
                    ERROR(d.CLASS_DQ, 6, SNAME);
                    break  # GO TO MNF_CHECK;
                while g.SYT_LINK2(g.KIN) < 0:
                    g.KIN = -g.SYT_LINK2(g.KIN);
                g.KIN = g.SYT_LINK2(g.KIN);
                if g.KIN == 0: 
                    g.SYT_PTR(g.STRUC_PTR, g.ID_LOC);
                    break  # GO TO MNF_CHECK;
    # MNF_CHECK:
    if (g.SYT_FLAGS(g.STRUC_PTR) & g.MISC_NAME_FLAG) != 0: 
        if g.BUILDING_TEMPLATE: 
            g.SYT_FLAGS(g.REF_ID_LOC, \
                        g.SYT_FLAGS(g.REF_ID_LOC) | g.MISC_NAME_FLAG);
# END CHECK_STRUC_CONFLICTS;
