#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PREPLITE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
from HALINCL.SAVELITE import SAVE_LITERAL

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  PREP_LITERAL                                           */
 /* MEMBER NAME:     PREPLITE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NOT_EXACT         LABEL                                        */
 /*          SAVE_NUMBER       LABEL                                        */
 /*          TEMP1             FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          ADDR_FIXER                                                     */
 /*          CPD_NUMBER                                                     */
 /*          EXP_OVERFLOW                                                   */
 /*          TABLE_ADDR                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          TOKEN                                                          */
 /*          SYT_INDEX                                                      */
 /*          VALUE                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SAVE_LITERAL                                                   */
 /* CALLED BY:                                                              */
 /*          SCAN                                                           */
 /***************************************************************************/
'''

'''
IR-182-1 describes PREP_LITERAL like so:
    "PREP_LITERAL takes a floating point number fresh from
    creation by a MONITOR(lO) call, checks it for proper limits,
    enters it in the literal table via SAVE LITERAL and sets
    SYT_INDEX to the absoulute index of the literal."

*I* think it also stores the converted value in the global variable VALUE.

MONITOR(10,string) converts a stringified representation of a number to IBM
DP floating point, and stores the most-significant word in DW[0] and the 
less-significant word in DW[1], return TRUE on error and FALSE on success; this
boolean is the value we expect to find in EXP_OVERFLOW.  So presumably, 
PREP_LITERAL() expects to find DW[0] and DW[1] filled with the data.
'''
def PREP_LITERAL():
    
    if g.EXP_OVERFLOW:
        '''
        The XPL has some INLINEs here, with no explanation of what they're
        for.  However, the documentation for the LIT1, LIT2, and LIT3 arrays
        explains that the code LIT2 == 0xFF000000 is encoded in case of an 
        invalid value.  So my guess is that the INLINEs probably store this
        illegal-value marker in place of whatever data was passed to us.
        Of course, those values could simply have been stored directly as I
        do below without any INLINEs, so perhaps that's not quite right.
        '''
        g.DW[0] = 0xFF000000
        g.DW[1] = 0x00000000
        #NOT_EXACT:
        g.VALUE = -1;
        g.TOKEN = g.CPD_NUMBER;
    else:
        '''
        Once more, we have INLINEs ... *lots* of them, again with no comments.
        The IR-182-1 description implies that their purpose is simply to 
        manufacture the value(s) stored in the variable TABLE_ADDRESS, 
        apparently branching to NOT_EXACT: (above) if there's an error 
        detected.  
        
        Alas, beyond that, I haven't a clue as to what these INLINEs are trying to 
        do to TABLE_ADDR.  My best guess is that these things are trying to use
        the value stored in DW[0],DW[1] and plce it in VALUE.
        
        TEMP1 = ADDR(NOT_EXACT);
        CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);       /* L   1,ADDR_LIMIT */
        CALL INLINE("58", 2, 0, TEMP1);                  /* L   2,TEMP1      */
        CALL INLINE("28", 6, 0);                         /* LDR 6,0          */
        CALL INLINE("20", 0, 0);                         /* LPDR 0,0         */
        CALL INLINE("69", 0, 0, 1, 0);                   /* CD  0,0(,1)      */
        CALL INLINE("07", 2, 2);                         /* BHR 2            */
        CALL INLINE("2B", 4, 4);                         /* SDR 4,4          */
        CALL INLINE("28", 2, 0);                         /* LDR 2,0          */
        CALL INLINE("58", 1, 0, ADDR_FIXER);             /* L   1,ADDR_FIXER */
        CALL INLINE("6E", 0, 0, 1, 0);                   /* AW  0,0(,1)      */
        CALL INLINE("58",1,0,TABLE_ADDR);
        CALL INLINE("60", 0, 0, 1, 0);                   /* STD 0,0(,1)      */
        CALL INLINE("2A", 0, 4);                         /* ADR 0,4          */
        CALL INLINE("2B", 2, 0);                         /* SDR 2,0          */
        CALL INLINE("07", 7, 2);                         /* BNER 2           */
        CALL INLINE("58", 2, 0, 1, 4);                   /* L   2,4(,1)      */
        CALL INLINE("50", 2, 0, VALUE);                  /* ST  2,VALUE      */
        SAVE_NUMBER:
        CALL INLINE("58",1,0,TABLE_ADDR);
        CALL INLINE("60",6,0,1,0);          /* STD 6,0(0,1)   */
        '''
        g.VALUE = fromFloatIBM(g.DW[0], g.DW[1])
        if g.VALUE.is_integer() \
                and g.VALUE < (1 << 31) and g.VALUE >= -(1 << 31):
            g.VALUE = int(g.VALUE)
    #g.SYT_INDEX = SAVE_LITERAL(1, h.TABLE_ADDR);
    g.SYT_INDEX = SAVE_LITERAL(1, g.DW_AD());
    return
