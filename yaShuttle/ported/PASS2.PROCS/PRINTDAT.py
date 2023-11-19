#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   PRINTDAT.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-16 RSB  Began porting from XPL.
"""

import g
from PRINTTIM import PRINT_TIME

#*************************************************************************
# PROCEDURE NAME:  PRINT_DATE_AND_TIME
# MEMBER NAME:     PRINTDAT
# INPUT PARAMETERS:
#          MESSAGE           CHARACTER;
#          D                 FIXED
#          T                 FIXED
# LOCAL DECLARATIONS:
#          DAY               FIXED
#          DAYS(12)          FIXED
#          M                 FIXED
#          MONTH(11)         CHARACTER;
#          YEAR              FIXED
# EXTERNAL VARIABLES REFERENCED:
#          BLANK
# EXTERNAL PROCEDURES CALLED:
#          PRINT_TIME
# CALLED BY:
#          PRINTSUMMARY
#*************************************************************************

# SUBROUTINE TO OUTPUT DATE AND TIME OF DAY

MONTH = ('JANUARY', 'FEBRUARY', 'MARCH',
    'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER',
    'NOVEMBER', 'DECEMBER')
DAYS = (0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366);


def PRINT_DATE_AND_TIME(MESSAGE, D, T):
    # THE BFS SPECIFIC CODE WAS REMOVED AND THE CODE THAT 
    # WAS PASS SPECIFIC WILL NOW BE USED BY BOTH SYSTEMS.
    # Locals: YEAR, DAY, M, MONTH, DAYS. 
    YEAR = D // 1000 + 1900;
    DAY = D % 1000;
    if (YEAR & 0x3) != 0:
        if DAY > 59: DAY = DAY + 1;
    M = 1;
    while DAY > DAYS[M]:
        M = M + 1;
    # END;
    PRINT_TIME(MESSAGE + str(MONTH[M - 1]) + g.BLANK + \
               str(DAY - DAYS[M - 1]) + ', ' + str(YEAR) + \
               '.  CLOCK TIME = ', T);
# END PRINT_DATE_AND_TIME;
