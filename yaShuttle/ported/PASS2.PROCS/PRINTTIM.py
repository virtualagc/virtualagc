#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   PRINTTIM.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-16 RSB  Ported from XPL
"""

from xplBuiltins import *
import g

#*************************************************************************
# PROCEDURE NAME:  PRINT_TIME
# MEMBER NAME:     PRINTTIM
# INPUT PARAMETERS:
#          MESSAGE           CHARACTER;
#          T                 FIXED
# EXTERNAL VARIABLES REFERENCED:
#          COLON
# CALLED BY:
#          PRINT_DATE_AND_TIME
#          PRINTSUMMARY
#*************************************************************************

# SUBROUTINE TO PRINT OUT THE TIME


def PRINT_TIME(MESSAGE, T):
    # No locals
    
    g.MESSAGE = g.MESSAGE + str(T // 360000) + g.COLON + \
        str((T % 360000) // 6000) + g.COLON + \
        str((T % 6000) // 100) + '.';
    T = T % 100;
    if T < 10: g.MESSAGE = g.MESSAGE + '0';
    OUTPUT(0, g.MESSAGE + str(T));
# END PRINT_TIME;
