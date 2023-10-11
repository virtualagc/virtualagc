#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   UPDATEBL.py
Purpose:    This is a part of the HAL/g.S-FC compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported
'''

import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

#*************************************************************************
# PROCEDURE NAME:  UPDATE_BLOCK_CHECK
# MEMBER NAME:     UPDATEBL
# INPUT PARAMETERS:
#          LOC               BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          FIXL
#          CLASS_PU
#          NEST
#          SYM_NEST
#          SYM_TAB
#          SYT_NEST
#          UPDATE_BLOCK_LEVEL
#          VAR
# EXTERNAL PROCEDURES CALLED:
#          ERROR
# CALLED BY:
#          SETUP_NO_ARG_FCN
#          START_NORMAL_FCN
#*************************************************************************


def UPDATE_BLOCK_CHECK(LOC):
    # No locals.
    if g.UPDATE_BLOCK_LEVEL > 0:
        if g.SYT_NEST(g.FIXL[LOC]) < g.NEST:
            ERROR(d.CLASS_PU, 3, g.VAR[LOC]);
# END UPDATE_BLOCK_CHECK;
