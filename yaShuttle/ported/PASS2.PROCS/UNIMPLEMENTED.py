#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   HAL_S_FC_PASS2.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Language:   XPL.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-16 RSB  Began adapting PASS2.PROCS/##DRIVER.xpl.

This is my replacement for "GO TO UNIMPLEMENTED".
"""

import sys
import HALINCL.CERRDECL as d
from ERRORS   import ERRORS

ERRORS(d.CLASS_B,102);
sys.exit(1)
