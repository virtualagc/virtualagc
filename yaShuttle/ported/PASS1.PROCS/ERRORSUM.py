#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ERRORSUM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-25 RSB  Created place-holder file.
'''

from xplBuiltins import OUTPUT
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ERROR_SUMMARY                                          */
 /* MEMBER NAME:     ERRORSUM                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ERROR_COUNT                                                    */
 /*          SAVE_LINE_#                                                    */
 /*          SAVE_SEVERITY                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /*          IND_ERR_#                                                      */
 /* CALLED BY:                                                              */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
'''


def ERROR_SUMMARY():
    OUTPUT(1, '0**** SUMMARY OF ERRORS DETECTED IN PHASE 1 ****');
    for g.IND_ERR_p in range(1, g.ERROR_COUNT + 1):
        if g.SAVE_LINE_p[g.IND_ERR_p] > 0:
            g.S = ' AT STATEMENT ' + str(g.SAVE_LINE_p[g.IND_ERR_p]);
        else: 
            # DO CASE -SAVE_LINE_p(IND_ERR_p);
            sl = -g.SAVE_LINE_p[g.IND_ERR_p]
            if sl == 0:
                g.S = ' IN PHASE 1 SET UP';
            elif sl == 1:
                g.S = ' IN CROSS-REFERENCE';
            elif sl == 2:
                g.S = ' IN PROGRAM LAYOUT';
            # END;
        OUTPUT(0, '   ERROR #' + str(g.IND_ERR_p) + ' OF SEVERITY ' + \
                    str(g.SAVE_SEVERITY[g.IND_ERR_p]) + g.S);
    return
