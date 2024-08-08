#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SETUPVAC.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SETUP_VAC                                              */
 /* MEMBER NAME:     SETUPVAC                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /*          TYPE              BIT(16)                                      */
 /*          SIZE              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PTR                                                            */
 /*          LAST_POP#                                                      */
 /*          XVAC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          ARITH_TO_CHAR                                                  */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /*          MATCH_SIMPLES                                                  */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          PREC_SCALE                                                     */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /*          UNARRAYED_INTEGER                                              */
 /*          UNARRAYED_SCALAR                                               */
 /***************************************************************************/
'''


def SETUP_VAC(LOC, TYPE, SIZE=-1):
    g.LOC_P[g.PTR[LOC]] = g.LAST_POPp;
    g.PSEUDO_FORM[g.PTR[LOC]] = g.XVAC;
    g.PSEUDO_TYPE[g.PTR[LOC]] = TYPE;
    if SIZE > 0:
        g.PSEUDO_LENGTH[g.PTR[LOC]] = SIZE;

            
