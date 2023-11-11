#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   FLOATING.xpl
Purpose:    This is a part of the HAL/g.S-FC compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported
'''

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

'''
I believe that what this function (which originally was all assembly language)
is trying to do is:
    a) Convert the input VAL (an integer) into a double-precision floating-
       point value; and
    b) Store that floating-point value in the floating-point working-area array
       as DW[0] and DW[1].
The point of this is to make the value available for subsequent floating-point
operations via calls to MONITOR(9,...).

We have no use for that nonsense, as our implementation of MONITOR(9,...) 
expects simply to find a full floating-point value in DW[0] (ignoring DW[1]).
'''
def FLOATING(VAL):
    g.DW[0] = double(VAL)
# END FLOATING;
