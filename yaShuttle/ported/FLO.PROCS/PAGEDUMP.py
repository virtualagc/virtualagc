#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   PAGEDUMP.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-21 RSB  Ported from XPL
"""

from xplBuiltins import *
from HALINCL.VMEM3 import *
import g
from HEX import HEX

#*************************************************************************
# PROCEDURE NAME:  PAGE_DUMP
# MEMBER NAME:     PAGEDUMP
# INPUT PARAMETERS:
#          PAGE              BIT(16)
# LOCAL DECLARATIONS:
#          II                BIT(16)
#          III               BIT(16)
#          J                 BIT(16)
#          JJ                BIT(16)
#          K                 BIT(16)
#          PTR               FIXED
#          STILL_ZERO        BIT(8)
#          TS(12)            CHARACTER;
#          WORD              FIXED
# EXTERNAL VARIABLES REFERENCED:
#          FALSE
#          TRUE
#          X1
#          X3
#          X4
# EXTERNAL PROCEDURES CALLED:
#          LOCATE
#          HEX
# CALLED BY:
#          DUMP_ALL
#*************************************************************************

# I *think* that what thus function is trying to do is this:
#    1.  It is passed a memory "page number", where "pages" are aligned
#        on 64K boundaries.
#    2.  It accesses that memory page via an array of FIXED, called
#        WORD.
#    3.  Only 70 "lines" of 12 words each (840 32-bit words, or 
#        3360 bytes in all) of each page are of interest.  It dumps the 
#        hexadecimal values to the printer.
# However, our Python port does not have that type of access to memory.


def PAGE_DUMP(PAGE):
    # Locals: J,JJ,II,III,K, PTR, TS, STILL_ZERO, WORD
    WORD = bytearray([0] * 3360)
    TS = [''] * (1 + 12)
    
    PTR = SHL(PAGE, 16);
    K = 69;
    LOCATE(PTR, ADDR(WORD), 0);
    OUTPUT(1, '1');
    TS = HEX(PAGE, 3);
    OUTPUT(0, 'PAGE ' + TS + '     ..00     ..04     ..08' \
           +'        ..0C     ..10     ..14        ..18     ..1C' \
           +'     ..20        ..24     ..28     ..2C');
    OUTPUT(0, g.X1);
    for J in range(0, K + 1):
        # PAGE_SIZE/48 - 1
        II = J * 12;
        STILL_ZERO = g.TRUE;
        for JJ in range(0, 11 + 1):
            if WORD[JJ + II] != 0: STILL_ZERO = g.FALSE;
            TS[JJ + 1] = HEX(WORD[JJ + II], 8);
        # END
        if not STILL_ZERO:  # DO
            TS[0] = HEX((J * 48), 4);
            for II in range(0, 3 + 1):
                TS[0] = TS[0] + g.X3;
                for III in range(1, 3 + 1):
                    TS[0] = TS[0] + TS[3 * II + III] + g.X1;
                # END
            # END
            OUTPUT(0, g.X4 + TS[0]);
        # END
    # END
    OUTPUT(0, g.X1);
    OUTPUT(0, g.X1);
# END PAGE_DUMP;
