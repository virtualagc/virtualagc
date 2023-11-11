#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   CHECKEV2.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-24 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR

#*************************************************************************
# PROCEDURE NAME:  CHECK_EVENT_CONFLICTS
# MEMBER NAME:     CHECKEV2
# EXTERNAL VARIABLES REFERENCED:
#          BUILDING_TEMPLATE
#          CLASS
#          CLASS_D
#          CLASS_DA
#          CLASS_DT
#          CLASS_FT
#          DEFAULT_TYPE
#          FALSE
#          ID_LOC
#          I
#          ILL_INIT_ATTR
#          INPUT_PARM
#          LATCHED_FLAG
#          MP
#          NAME_IMPLIED
#          SYM_NAME
#          SYM_TAB
#          SYT_NAME
#          TEMPORARY_IMPLIED
#          VAR
# EXTERNAL VARIABLES CHANGED:
#          DO_INIT
#          ATTRIBUTES
#          TYPE
# EXTERNAL PROCEDURES CALLED:
#          ERROR
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************
#********                          CALL TREE                      ********
#*************************************************************************
# ==> CHECK_EVENT_CONFLICTS <==
#     ==> ERROR
#         ==> PAD
#*************************************************************************


def CHECK_EVENT_CONFLICTS():
    if g.CLASS == 2:  # DO
        ERROR(d.CLASS_FT, 3, g.SYT_NAME(g.ID_LOC));
        g.TYPE = g.DEFAULT_TYPE;
    # END
    elif g.BUILDING_TEMPLATE:  # DO
        if not g.NAME_IMPLIED:  # DO
            ERROR(d.CLASS_DT, 7, g.SYT_NAME(g.ID_LOC));
            g.TYPE = g.DEFAULT_TYPE;
        # END
    # END
    elif g.TEMPORARY_IMPLIED:  # DO
        ERROR(d.CLASS_D, 8, g.VAR[g.MP]);
        g.TYPE = g.DEFAULT_TYPE;
    # END
    elif (g.I & g.INPUT_PARM) != 0: ERROR(d.CLASS_DT, 8, g.SYT_NAME(g.ID_LOC));
    elif (g.ATTRIBUTES & g.LATCHED_FLAG) == 0:
        if (g.ATTRIBUTES & g.ILL_INIT_ATTR) != 0:  # DO
            ERROR(d.CLASS_DA, g.TYPE);
            g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_INIT_ATTR);
            g.DO_INIT = g.FALSE;
        # END
# END CHECK_EVENT_CONFLICTS;
