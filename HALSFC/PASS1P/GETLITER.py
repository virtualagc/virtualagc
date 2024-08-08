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
import HALINCL.COMMON as h

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

'''
I think that this function is based on the notion that the external file of
literals is divided up into blocks of size LIT_BUF_SIZE.  Furthermore, at
any given time, precisely one block of this file is buffered in memory, and
that block comprises the indices LITORG up to (but not including) LITLIM.
The function is given an absolute index, PTR, into the LIT1[], LIT2[], and
LIT3[] arrays, and it returns a relative pointer into just the block that's
currently buffered in memory.  If the desired absolute pointer isn't actually
within that currently-buffered block, then the function loads the appropriate
block into memory, replacing the previously-buffered one, and readjusts
LITORG and LITLIM as well.

Although the function is framed as if it operates just on the LIT1[] array, 
the original XPL was so arranged that these blocks (both in the external file
and in memory) were actually the LIT_PG[] array, which contained fields for
LIT1[], LIT2[], and LIT3[], so that in apparently loading a chunk of LIT1[],
in fact the same FILE() operation saved or loaded corresponding blocks of 
LIT2[] and LIT3[] as well, transparently.
'''
def GET_LITERAL(PTR):
    if PTR == 0: return 0;
    if PTR >= g.LITORG:
        if PTR < g.LITLIM:
            return PTR - g.LITORG;
    # Must form a bytearray from h.LIT_PG[0] for the call to FILE().  I swiped
    # this code from SYNTHESI.py.
    b = bytearray([])
    lit_pg = h.LIT_PG[0]
    for lit in [lit_pg.LITERAL1, lit_pg.LITERAL2, lit_pg.LITERAL3]:
        for j in range(g.LIT_BUF_SIZE):
            v = lit[j]
            b.append((v >> 24) & 0xFF)
            b.append((v >> 16) & 0xFF)
            b.append((v >> 8) & 0xFF)
            b.append(v & 0xFF)
    FILE(g.LITFILE, g.CURLBLK, b);
    g.CURLBLK = PTR // g.LIT_BUF_SIZE;
    g.LITORG = g.CURLBLK * g.LIT_BUF_SIZE;
    g.LITLIM = g.LITORG + g.LIT_BUF_SIZE;
    b = bytearray([0] * (12 * g.LIT_BUF_SIZE))
    if g.CURLBLK <= g.LITMAX:
        FILE(b, g.LITFILE, g.CURLBLK);
    else:
        g.LITMAX = g.LITMAX + 1;
    # Convert input bytearray to LIT_PG[0].
    i = 0
    for lit in [lit_pg.LITERAL1, lit_pg.LITERAL2, lit_pg.LITERAL3]:
        for j in range(g.LIT_BUF_SIZE):
            negative = False
            v = 0
            for k in range(4):
                v = (v << 8) | b[i]
                i += 1
            lit[j] = v
    return PTR - g.LITORG;
