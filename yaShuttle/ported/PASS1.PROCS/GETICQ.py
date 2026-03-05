#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   GETICQ.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
            2026-03-05 RSB  Corrected mapping from IC_VAL (et al.) to/from
                            the bytearray being output or input.  Corrected
                            computation of returned block-number from a float 
                            division to an integer division.
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_ICQ                                                */
 /* MEMBER NAME:     GETICQ                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          IC_SIZE                                                        */
 /*          IC_FILE                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          IC_LIM                                                         */
 /*          CUR_IC_BLK                                                     */
 /*          IC_MAX                                                         */
 /*          IC_ORG                                                         */
 /*          IC_VAL                                                         */
 /* CALLED BY:                                                              */
 /*          HALMAT_INIT_CONST                                              */
 /*          ICQ_OUTPUT                                                     */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

# Converts the arrays IC_VAL, IC_LOC, IC_LEN, IC_FORM, IC_TYPE to a 1600-element
# bytearray.
def toBytes():
    array = bytearray(1600)
    i = 0
    for h in g.IC_VAL + g.IC_LOC + g.IC_LEN:
        array[i] = 0xFF & (h >> 8)
        array[i+1] = 0xFF & h
        i += 2
    for b in g.IC_FORM + g.IC_TYPE:
        array[i] = 0xFF & b
        i += 1
    return array;

# Converts a 1600-element bytearray to the arrays IC_VAL, IC_LOC, IC_LEN, 
# IC_FORM, IC_TYPE.
def fromBytes(array):
    j = 0
    for i in range(g.IC_SIZE):
        g.IC_VAL[i] = array[j] * 256 + array[j + 1]
        j += 2
    for i in range(g.IC_SIZE):
        g.IC_LOC[i] = array[j] * 256 + array[j + 1]
        j += 2
    for i in range(g.IC_SIZE):
        g.IC_LEN[i] = array[j] * 256 + array[j + 1]
        j += 2
    for i in range(g.IC_SIZE):
        g.IC_FORM[i] = array[j]
        j += 1
    for i in range(g.IC_SIZE):
        g.IC_TYPE[i] = array[j]
        j += 1

def GET_ICQ(PTR):
    if PTR >= g.IC_ORG:
        if PTR < g.IC_LIM:
            return PTR - g.IC_ORG;
    FILE(g.IC_FILE, g.CUR_IC_BLK, toBytes());
    g.CUR_IC_BLK = PTR // g.IC_SIZE;
    g.IC_ORG = g.CUR_IC_BLK * g.IC_SIZE;
    g.IC_LIM = g.IC_ORG + g.IC_SIZE;
    if g.CUR_IC_BLK <= g.IC_MAX:
        array = bytearray(1600)
        FILE(array, g.IC_FILE, g.CUR_IC_BLK);
        fromBytes(array)
    else:
        g.IC_MAX = g.IC_MAX + 1;
    return PTR - g.IC_ORG;
