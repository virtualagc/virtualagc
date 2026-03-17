#!/usr/bin/env python3
"""
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SRNCMP.py
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2026-03-12 RSB  Manually ported.
"""

import g
from xplBuiltins import *

"""
 /***************************************************************************/
 /* PROCEDURE NAME:  SRNCMP                                                 */
 /* MEMBER NAME:     SRNCMP                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          TEXT1             CHARACTER;                                   */
 /*          TEXT2             CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BYTE1             BIT(16)                                      */
 /*          BYTE2             BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          LIMIT             MACRO                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NO_MORE_SOURCE                                                 */
 /* CALLED BY:                                                              */
 /*          SOURCE_COMPARE                                                 */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /***************************************************************************/
"""

def SRNCMP(TEXT1,TEXT2): # Returns BIT(16)
    """
    /*SRNCMP COMPARES TWO INPUT TEXTS BYTE FOR BYTE FOR NUMERICAL*/
    /* ORDERING AND RETURNS THE FOLLOWING*/
    /*  0 IF 1=2  */
    /*  1 IF 1<2  */
    /*  2 IF 1>2  */
    """
    LIMIT = 6
    if g.NO_MORE_SOURCE:
        return 2
    for I in range(1, LIMIT+1):
        BYTE1 = BYTE(TEXT1,I-1) - BYTE('0')
        BYTE2 = BYTE(TEXT2,I-1) - BYTE('0')
        if BYTE1<BYTE2:
            return 1
        if BYTE1>BYTE2:
            return 2
    return 0
