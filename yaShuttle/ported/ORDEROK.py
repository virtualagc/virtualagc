#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ORDEROK.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-31 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ORDER_OK                                               */
 /* MEMBER NAME:     ORDEROK                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          TYPE              FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          COMMENT_JOIN      LABEL                                        */
 /*          E_CARD            LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CARD_TYPE                                                      */
 /*          CLASS_M                                                        */
 /*          CURRENT_CARD                                                   */
 /*          FALSE                                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          END_GROUP                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
'''


def ORDER_OK(TYPE):
    # There are no locals (from XPL).
    
    ctc = g.CARD_TYPE[BYTE(g.CURRENT_CARD)]
    ctt = g.CARD_TYPE[TYPE]
    if ctc == 0:
        #  CASE 0 -- ILLEGAL CARD TYPES  
        ERROR(d.CLASS_M, 1);
        g.CURRENT_CARD = BYTE(g.CURRENT_CARD, 0, BYTE('C'))
        pass
        # Note fallthrough.
    elif ctc == 1 or ctc == 2:
        #  CASE 1 -- E CARD  
        #  CASE 2 -- M CARD  
        if ctt == 2 or ctt == 3:
            g.END_GROUP = g.TRUE;
        else:
            g.END_GROUP = g.FALSE;
        return g.TRUE;
    elif ctc == 3:
        #  CASE 3 -- S CARD  
        g.END_GROUP = g.FALSE;
        if ctt == 2 or ctt == 3:
            return g.TRUE;
        else:
            return g.FALSE;
    #  CASE 0 -- ILLEGAL CARD TYPES
    #  CASE 4 -- A COMMENT CARD 
    #  CASE 5 -- DIRECTIVE CARD 
    if ctt == 2 or ctt == 3:
        g.END_GROUP = g.TRUE;
    else:
        g.END_GROUP = g.FALSE;
    if ctt == 1:
        return g.FALSE;
    else:
        return g.TRUE;
