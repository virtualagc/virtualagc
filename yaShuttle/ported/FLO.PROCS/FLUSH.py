#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   FLUSH.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-20 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g

#*************************************************************************
# PROCEDURE NAME:  FLUSH
# MEMBER NAME:     FLUSH
# INPUT PARAMETERS:
#          LAST              BIT(16)
#          NO_PTR            BIT(8)
# LOCAL DECLARATIONS:
#          I                 BIT(16)
#          J                 BIT(16)
#          K                 BIT(16)
#          OFFSET            CHARACTER;
#          STRING            CHARACTER;
# EXTERNAL VARIABLES REFERENCED:
#          LEVEL
#          LINELENGTH
#          X13
#          X3
#          X70
# EXTERNAL VARIABLES CHANGED:
#          S
# CALLED BY:
#          FORMAT_EXP_VARS_CELL
#          FORMAT_FORM_PARM_CELL
#          FORMAT_NAME_TERM_CELLS
#          FORMAT_PF_INV_CELL
#          FORMAT_VAR_REF_CELL
#*************************************************************************
# PRINTS OUT CONCATENATED S ARRAY


def FLUSH(LAST, NO_PTR=0):
    # Locals: I, J, K, OFFSET, STRING
    J = 10 + 3 * g.LEVEL;
    OFFSET = SUBSTR(g.X70, 0, J);
    J = 0;
    STRING = OFFSET;
    while J <= LAST:
        if LENGTH(STRING) + LENGTH(g.S[J]) < g.LINELENGTH:  # DO
            STRING = STRING + g.S[J];
            g.S[J] = '';
            J = J + 1;
        # END
        else:  # DO
            K = g.LINELENGTH - LENGTH(STRING) - 1;
            I = K;
            while BYTE(g.S[J], I) != BYTE(' ') and \
                    BYTE(g.S[J], I) != BYTE(',') and I > 0:
                I = I - 1;
            # END
            if I == 0:  # DO
                I = K;
                while BYTE(g.S[J]) != BYTE('.') and I > 0:
                    I = I - 1;
                # END
                if I == 0: I = K;
            # END
            OUTPUT(0, STRING + SUBSTR(g.S[J], 0, I + 1));
            g.S[J] = SUBSTR(g.S[J], I + 1);
            if NO_PTR: STRING = OFFSET + g.X3;
            else: STRING = OFFSET + g.X13;
        # END
    # END
    OUTPUT(0, STRING);
    NO_PTR = 0;
# END FLUSH;
