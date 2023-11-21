#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   BOMB_OUT.py
Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
            process.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-11-18 RSB  Ported from ##DRIVER XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
from HALINCL.DOWNSUM import DOWNGRADE_SUMMARY

def BOMB_OUT():
    
   # Here rather than at top of file to avoid "circular import" error.
   from DUMPALL  import DUMP_ALL

   if g.MAX_SEVERITY >= 2:
       DOWNGRADE_SUMMARY();
   OUTPUT(0, '***  COMPILATION ABANDONED  ***');
   DUMP_ALL(g.FORMATTED_DUMP);
   sys.exit(h.COMMON_RETURN_CODE);
   
   