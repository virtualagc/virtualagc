#!/bin/usr/env python
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   STRUCTU2.py
Purpose:    This is a part of the HAL/g.S-FC compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Language:   XPL.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported
'''

import g

#*************************************************************************
# PROCEDURE NAME:  STRUCTURE_FCN
# MEMBER NAME:     STRUCTU2
# EXTERNAL VARIABLES REFERENCED:
#          MAJ_STRUC
#          MP
#          SYM_LENGTH
#          SYM_TAB
#          SYM_TYPE
#          SYT_TYPE
#          VAR_LENGTH
# EXTERNAL VARIABLES CHANGED:
#          FIXV
#          FIXL
# CALLED BY:
#          SETUP_NO_ARG_FCN
#          START_NORMAL_FCN
#*************************************************************************


def STRUCTURE_FCN():
    # No locals.
    if g.SYT_TYPE(g.FIXL[g.MP]) < g.MAJ_STRUC: 
        return;
    if g.FIXV[g.MP] == 0: 
        g.FIXV[g.MP] = g.FIXL[g.MP];
    g.FIXL[g.MP] = g.VAR_LENGTH(g.FIXL[g.MP]);
# END STRUCTURE_FCN;
