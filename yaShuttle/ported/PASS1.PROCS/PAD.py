#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PAD.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-09 RSB  Ported PAD
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  PAD                                                    */
 /* MEMBER NAME:     PAD                                                    */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          STRING            CHARACTER;                                   */
 /*          WIDTH             FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X256                                                           */
 /* CALLED BY:                                                              */
 /*          DESCORE                                                        */
 /*          EMIT_EXTERNAL                                                  */
 /*          ERROR                                                          */
 /*          INITIALIZATION                                                 */
 /*          SAVE_INPUT                                                     */
 /*          STREAM                                                         */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
'''

def PAD(STRING, WIDTH):
    # Local L
    
    L = LENGTH(STRING);
    if L >= WIDTH:
        return STRING[:];
    else:
        return STRING + SUBSTR(g.X256, 0, WIDTH - L);
# END PAD;

