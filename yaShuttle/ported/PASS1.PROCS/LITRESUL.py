#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   LITRESUL.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  LIT_RESULT_TYPE                                        */
 /* MEMBER NAME:     LITRESUL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          CONST_DW                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /*          FOR_DW                                                         */
 /*          INT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def LIT_RESULT_TYPE(LOC1, LOC2):
    g.traceInline("LIT_RESULT_TYPE p86")
    if False:
        # My original implementation.
        '''
        # What the following inlines do is to determine whether the IBM Hex
        # floating-point value stored in DW(0),DW(1) is in-range for a 32-bit
        # integer.  It stores a value in DW[2] which is >0 if not and <=0 if is.
        INLINE("58", 1, 0, g.DW_AD);  # L   1,DW_AD
        INLINE("68", 0, 0, 1, 0);  # LD  0,0(0,1)
        INLINE("20", 0, 0);  # LPDR 0,0
        INLINE("58", 2, 0, h.ADDR_FIXED_LIMIT);  # L 2,ADDR_FIXED_LIMIT
        INLINE("6B", 0, 0, 2, 0);  # SD  0,0(0,2)
        INLINE("60", 0, 0, 1, 8);  # STD 0,8(0,1)
        '''
        d = fromFloatIBM(g.DW[0], g.DW[1])
        if d > 0x7FFFFFFF or d < -0x80000000:
            g.DW[2] = 1
        else:
            g.DW[2] = 0x80000000
    else:
        # My replacement implementation, based on C-language patchfile
        # GR[1] loaded with `DW_AD @p86_0
        g.FR[0] = fromFloatIBM(g.DW[0], g.DW[1]) # p86_4
        g.FR[0] = abs(g.FR[0]) # p86_8
        # GR[2] loaded with `ADDR_FIXED_LIMIT` @p86_10
        g.FR[0] -= fromFloatIBM(0x487FFFFF, 0xFFFFFFFF) # p86_14
        g.DW[2], g.DW[3] = toFloatIBM(g.FR[0]) # p86_18
    
    if g.PSEUDO_TYPE[g.PTR[LOC1]] == g.INT_TYPE:
        if g.PSEUDO_TYPE[g.PTR[LOC2]] == g.INT_TYPE:
            if g.DW[2] == 0 or 0 != (0x80000000 & g.DW[2]):
                return g.INT_TYPE;
    return g.SCALAR_TYPE;
