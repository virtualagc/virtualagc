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


def PREP_LITERAL():
    
    '''
    PROCEDURE;
    DECLARE TEMP1 FIXED;
    '''
    if g.EXP_OVERFLOW:
        '''
        CALL INLINE("58",1,0,ADDR_FIXED_LIMIT); /* L 1,ADDR_FIXED_LIMIT*/
        CALL INLINE("68",6,0,1,0);       /* LD 6,0(0,1)   */
        NOT_EXACT:
        '''
        g.VALUE = -1;
        g.TOKEN = g.CPD_NUMBER;
    '''
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
    g.SYT_INDEX = SAVE_LITERAL(1, h.TABLE_ADDR);
    return
