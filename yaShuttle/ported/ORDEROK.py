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

from g import CARD_TYPE, BYTE, CURRENT_CARD, END_GROUP, FALSE, TRUE
from ERROR import ERROR
from HALINCL.CERRDECL import CLASS_M

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
    global CURRENT_CARD, END_GROUP
    
    print("OO A", '"%s"' % CURRENT_CARD)
    ctc = CARD_TYPE[BYTE(CURRENT_CARD)]
    ctt = CARD_TYPE[TYPE]
    if ctc == 0:
        #  CASE 0 -- ILLEGAL CARD TYPES  
        ERROR(CLASS_M,1);
        CURRENT_CARD = 'C' + CURRENT_CARD[1:]
        # Note fallthrough.
    elif ctc == 1 or ctc == 2:
        #  CASE 1 -- E CARD  
        #  CASE 2 -- M CARD  
        if ctt == 2 or ctt == 3:
            END_GROUP = TRUE;
        else:
            END_GROUP = FALSE;
        return TRUE;
    elif ctc == 3:
        #  CASE 3 -- S CARD  
        END_GROUP = FALSE;
        if ctt == 2 or ctt == 3:
            return TRUE;
        else:
            return FALSE;
    #  CASE 0 -- ILLEGAL CARD TYPES
    #  CASE 4 -- A COMMENT CARD 
    #  CASE 5 -- DIRECTIVE CARD 
    if ctt == 2 or ctt == 3:
        END_GROUP = TRUE;
    else:
        END_GROUP = FALSE;
    if ctt == 1:
        return FALSE;
    else:
        return TRUE;
