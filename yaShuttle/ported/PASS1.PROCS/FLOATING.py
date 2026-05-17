#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   FLOATING.xpl
Purpose:    This is a part of the HAL/g.S-FC compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported
            2026-03-12 RSB  Wasn't importing g.py; was using non-existent
                            `double()` function.
            2026-05-14 RSB  Changes per issue #1306, and other changes
                            for conformance to original FLOATING.xpl.
'''

import g
from ibmFloat import ibm_dp_from_double, hfpJoin, hfpSplit, IBM_SP_SIGN_BIT

#*************************************************************************
# PROCEDURE NAME:  FLOATING
# MEMBER NAME:     FLOATING
# INPUT PARAMETERS:
#          VAL               FIXED
# EXTERNAL VARIABLES REFERENCED:
#          CONST_DW
#          DW_AD
#          DW
# EXTERNAL VARIABLES CHANGED:
#          FOR_DW
# CALLED BY:
#          PREC_SCALE
#          SETUP_NO_ARG_FCN
#*************************************************************************

def FLOATING(VAL):
    g.DW[0] = g.DW[8] # MSW of the FIXER
    if VAL < 0:
        VAL = -VAL
        DW[0] = DW[0] ^ IBM_SP_SIGN_BIT # p46_0, 4
    g.DW[1] = VAL # DW(0),DW(1) now contains an unnormalized HFP of the VAL (an integer)
    g.FR[0] = ibm_dp_addsub(0, hfpJoin(DW[0], DW[1]), 0, 1) # p48_4, 6.  Normalize it
    g.DW[0], g.DW[1] = hfpSplit(g.FR[0]) # p48_10.  And save it.
    
# END FLOATING;
