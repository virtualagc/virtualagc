#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   IFORMAT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  I_FORMAT                                               */
 /* MEMBER NAME:     IFORMAT                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          NUMBER            FIXED                                        */
 /*          WIDTH             FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L                 FIXED                                        */
 /*          STRING            CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X256                                                           */
 /* CALLED BY:                                                              */
 /*          HALMAT_BLAB                                                    */
 /*          DUMPIT                                                         */
 /*          LIT_DUMP                                                       */
 /*          OUTPUT_WRITER                                                  */
 /*          SAVE_INPUT                                                     */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
'''


def I_FORMAT(NUMBER, WIDTH):
    # Parameters are not optional, and therefore don't need persistence.
    # Locals (L, STRING) don't need to be persistent.
    
    STRING = str(NUMBER);
    L = LENGTH(STRING);
    if L >= WIDTH:
        return STRING;
    else:
        return SUBSTR(g.X256, 0, WIDTH - L) + STRING;
