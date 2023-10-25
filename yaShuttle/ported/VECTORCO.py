#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   VECTORCO.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  VECTOR_COMPARE                                         */
 /* MEMBER NAME:     VECTORCO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          CLASS             BIT(16)                                      */
 /*          NUM               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PTR                                                            */
 /*          PSEUDO_LENGTH                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          MATCH_ARITH                                                    */
 /*          MATRIX_COMPARE                                                 */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def VECTOR_COMPARE(I, J, CLASS, NUM):
    if g.PSEUDO_LENGTH[g.PTR[I]] != g.PSEUDO_LENGTH[g.PTR[J]]:
        ERROR(CLASS, NUM);
