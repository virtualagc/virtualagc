#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   DESCORE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-10 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from PAD import PAD

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  DESCORE                                                */
 /* MEMBER NAME:     DESCORE                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          CHAR              CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X1                                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PAD                                                            */
 /* CALLED BY:                                                              */
 /*          EMIT_EXTERNAL                                                  */
 /*          STREAM                                                         */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

def DESCORE(CHAR):
    # I, J, K are local, but there's no need to make them persistent
    
    CHAR=CHAR+g.X1;
    I = 1
    J = 1;
    while I<LENGTH(CHAR):
        if BYTE(CHAR,I)!=BYTE('_'):
            K=BYTE(CHAR,I);
            CHAR = BYTE(CHAR,J,K);
            J=J+1;
        I=I+1;
    CHAR=SUBSTR(CHAR,0,J);
    if LENGTH(CHAR)>=6:
        CHAR=SUBSTR(CHAR,0,6);
    else:
        CHAR=PAD(CHAR,6);
    return '@@' + CHAR;
