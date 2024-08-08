#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   LABELMAT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-29 RSB  Ported from XPL
'''

import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  LABEL_MATCH                                            */
 /* MEMBER NAME:     LABELMAT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIXL                                                           */
 /*          DO_PARSE                                                       */
 /*          LABEL_DEFINITION                                               */
 /*          MPP1                                                           */
 /*          PARSE_STACK                                                    */
 /*          TEMP                                                           */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def LABEL_MATCH():
    # Local: LOC
    
    if g.FIXL[g.MPP1] == 0:
        return 1;
    LOC = g.DO_PARSE[g.TEMP];
    while g.PARSE_STACK[LOC] == g.LABEL_DEFINITION:
        if g.FIXL[LOC] == g.FIXL[g.MPP1]:
            return 1;
        LOC = LOC - 1;
    return 0;
