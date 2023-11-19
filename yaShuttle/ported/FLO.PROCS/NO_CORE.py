#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   NO_CORE.py
Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
            process.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-11-18 RSB  Ported from ##DRIVER XPL
'''

from xplBuiltins import *
import g
from DUMPALL  import DUMP_ALL

def NO_CORE():
   OUTPUT(0, '***  COMPILATION ABANDONED -- INSUFFICIENT CORE  ***');
   DUMP_ALL(g.FORMATTED_DUMP);
   sys.exit(20);
   