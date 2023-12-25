#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   DISASTER.py
Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-12-01 RSB  Adapted from OPT.PROCS/##DRIVER.XPL
'''

import sys
import g
from HALINCL.DOWNSUM import DOWNGRADE_SUMMARY


def DISASTER():
    if g.MAX_SEVERITY >= 2: DOWNGRADE_SUMMARY();
    sys.exit(g.COMMON_RETURN_CODE);

