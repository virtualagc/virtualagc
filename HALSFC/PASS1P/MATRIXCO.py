#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   MATRIXCO.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from VECTORCO import VECTOR_COMPARE

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  MATRIX_COMPARE                                         */
 /* MEMBER NAME:     MATRIXCO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          CLASS             BIT(16)                                      */
 /*          NUM               BIT(16)                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          VECTOR_COMPARE                                                 */
 /* CALLED BY:                                                              */
 /*          MATCH_ARITH                                                    */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def MATRIX_COMPARE(I, J, CLASS, NUM):
    VECTOR_COMPARE(I, J, CLASS, NUM);
