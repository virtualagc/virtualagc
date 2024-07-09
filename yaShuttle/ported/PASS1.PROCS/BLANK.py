#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   BLANK.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  BLANK                                                  */
 /* MEMBER NAME:     BLANK                                                  */
 /* INPUT PARAMETERS:                                                       */
 /*          STRING            CHARACTER;                                   */
 /*          START             BIT(16)                                      */
 /*          COUNT             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          J                 FIXED                                        */
 /*          MVC               LABEL                                        */
 /* CALLED BY:                                                              */
 /*          DECOMPRESS                                                     */
 /*          EMIT_EXTERNAL                                                  */
 /*          OUTPUT_WRITER                                                  */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
'''

# Note that this function, of necessity, returns the modified string rather
# than modifying STRING in place.
def BLANK(STRING, START, COUNT):
    '''
    THIS PROCEDURE ACCEPTS A CHARACTER STRING AS INPUT AND
    REPLACES "COUNT" CHARACTERS STARTING WITH THE CHARACTER INDICATED
    BY "START" WITH BLANKS
    '''
    g.traceInline("BLANK p25")
    return STRING[:START] + ("%*s" % (COUNT, '') + STRING[START+COUNT:])
