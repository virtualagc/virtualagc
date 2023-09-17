#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   GETLITER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_LITERAL                                            */
 /* MEMBER NAME:     GETLITER                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LIT_BUF_SIZE                                                   */
 /*          LITERAL1                                                       */
 /*          LITFILE                                                        */
 /*          LIT1                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURLBLK                                                        */
 /*          LIT_PG                                                         */
 /*          LITLIM                                                         */
 /*          LITMAX                                                         */
 /*          LITORG                                                         */
 /* CALLED BY:                                                              */
 /*          ARITH_LITERAL                                                  */
 /*          BIT_LITERAL                                                    */
 /*          CHAR_LITERAL                                                   */
 /*          LIT_DUMP                                                       */
 /*          MAKE_FIXED_LIT                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

def GET_LITERAL(PTR):
    if PTR == 0:
        return 0;
    if PTR >= g.LITORG:
        if PTR < g.LITLIM:
            return PTR - g.LITORG;
    FILE(g.LITFILE,g.CURLBLK, g.LIT1(0));
    g.CURLBLK=PTR/g.LIT_BUF_SIZE;
    g.LITORG=g.CURLBLK*g.LIT_BUF_SIZE;
    g.LITLIM=g.LITORG+g.LIT_BUF_SIZE;
    if g.CURLBLK<=g.LITMAX:
        LIT1(0, FILE(g.LITFILE,g.CURLBLK));
    else:
        g.LITMAX=g.LITMAX+1;
    return PTR - g.LITORG;
