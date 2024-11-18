#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   PRECSCAL.xpl
Purpose:    This is a part of the HAL/g.S-FC compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Language:   XPL.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported.
'''

import g
from HALMATTU import HALMAT_TUPLE
from SETUPVAC import SETUP_VAC

#*************************************************************************
# PROCEDURE NAME:  PREC_SCALE
# MEMBER NAME:     PRECSCAL
# INPUT PARAMETERS:
#          PP                BIT(16)
#          P_TYPE            BIT(8)
# LOCAL DECLARATIONS:
#          DIV_ERROR(1587)   LABEL
#          DIV_SCALE(1585)   LABEL
#          P_TEMP            FIXED
#          P1                FIXED
#          P2                FIXED
#          SCALE_FAIL(1582)  LABEL
# EXTERNAL VARIABLES REFERENCED:
#          COMM
#          CLASS_SQ
#          CONST_DW
#          DW_AD
#          DW
#          INT_TYPE
#          INX
#          MAT_TYPE
#          MP
#          OPTIONS_CODE
#          PSEUDO_FORM
#          SCALAR_TYPE
#          XBFNC
#          XITOS
#          XMTOM
#          XSTOI
# EXTERNAL VARIABLES CHANGED:
#          FOR_DW
#          LOC_P
#          PSEUDO_TYPE
#          PTR
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          ARITH_LITERAL
#          FLOATING
#          HALMAT_TUPLE
#          MAKE_FIXED_LIT
#          SAVE_LITERAL
#          SETUP_VAC
# CALLED BY:
#          SETUP_NO_ARG_FCN
#          SYNTHESIZE
#*************************************************************************


def PREC_SCALE(PP, P_TYPE):
    # Locals: P_TEMP, P1, P2 are DECLARE'd but there's no usage of P1 and P2.
    
    P_TEMP = g.PSEUDO_FORM[g.PTR[PP]];
    g.PTR[PP] = g.PTR[PP] + 1;
    if (P_TEMP & 0xF) != 0: 
        HALMAT_TUPLE(g.XMTOM[P_TYPE - g.MAT_TYPE], 0, g.MP, 0, P_TEMP & 0xF);
        SETUP_VAC(g.MP, P_TYPE);
# END PREC_SCALE;
