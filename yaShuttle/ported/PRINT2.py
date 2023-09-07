#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PRINT2.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-06 RSB  Ported from XPL
'''

from g import LISTING2_COUNT, LINE_LIM, OUTPUT, BYTE

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  PRINT2                                                 */
 /* MEMBER NAME:     PRINT2                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          LINE              CHARACTER;                                   */
 /*          SPACE             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PAGE_NUM          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LINE_LIM                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LISTING2_COUNT                                                 */
 /* CALLED BY:                                                              */
 /*          OUTPUT_GROUP                                                   */
 /*          STREAM                                                         */
 /***************************************************************************/
'''

def PRINT2(LINE, SPACE):
    global LISTING2_COUNT
    # Local
    PAGE_NUM = 0
    
    LISTING2_COUNT = LISTING2_COUNT + SPACE;
    if LISTING2_COUNT > LINE_LIM:
        PAGE_NUM = PAGE_NUM + 1;
        OUTPUT(2, \
            '1  H A L   C O M P I L A T I O N   --   P H A S E   1   --   U N F O R M A T T E D   S O U R C E   L I S T I N G             PAGE ' \
            + str(PAGE_NUM));
        BYTE(LINE, 0, BYTE('-'));
        LISTING2_COUNT = 4;
    OUTPUT(2, LINE);
