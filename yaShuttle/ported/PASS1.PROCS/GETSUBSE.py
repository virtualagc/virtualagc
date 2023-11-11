#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   GETSUBSE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-30 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from PAD import PAD

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_SUBSET                                             */
 /* MEMBER NAME:     GETSUBSE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SUBSET            CHARACTER;                                   */
 /*          FLAGS             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          A_TOKEN           CHARACTER;                                   */
 /*          CASE_B2           LABEL                                        */
 /*          CASE_P2           LABEL                                        */
 /*          CP                BIT(16)                                      */
 /*          GET_TOKEN         LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          L                 BIT(16)                                      */
 /*          LIMIT             BIT(16)                                      */
 /*          S                 CHARACTER;                                   */
 /*          SUBSET_ERROR      LABEL                                        */
 /*          SUBSET_MSG        CHARACTER;                                   */
 /*          VALUE             LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BI#                                                            */
 /*          BI_NAME                                                        */
 /*          FOREVER                                                        */
 /*          P#                                                             */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          #PRODUCE_NAME                                                  */
 /*          BI_FLAGS                                                       */
 /*          BIT_LENGTH_LIM                                                 */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
'''


def GET_SUBSET(SUBSET, FLAGS):
    # The locals are A_TOKEN, S, I, L, LIMIT, CP, and SUBSET_MSG.
    # They don't require persistence.  They're initialized below only to
    # cater to the 'nonlocal' declarations in the embedded functions.
    A_TOKEN = ''
    S = ''
    I = 0
    L = 0
    CP = 0
    SUBSET_MSG = '0 *** LANGUAGE SUBSET IN EFFECT: ';

    def VALUE():
        nonlocal L
        # J and M are local, but don't need persistence.
        L = 0;
        for J in range(1, LENGTH(A_TOKEN) + 1):
            M = BYTE(A_TOKEN, J - 1) - BYTE('0');
            if (M < 0)or(M > 9):
                return -1;
            L = L * 10 + M;
        return L;

    def GET_TOKEN():
        nonlocal A_TOKEN, CP, I, S
        # The only locals, Tp and TERM, require no persistence.
        Tp = 3;
        TERM = (0, BYTE('('), BYTE(')'), BYTE(','));
        A_TOKEN = '';
        while True:
            CP = CP + 1;
            if CP > LIMIT:
                while True:
                    S = INPUT(6);
                    I = 0;
                    if LENGTH(S) == 0:
                        return 0;
                    if BYTE(S) != BYTE('C'):
                        break;
                CP = 0;
            if BYTE(S, CP) != BYTE(g.X1):
                for I in range(1, Tp + 1):
                    if BYTE(S, CP) == TERM[I]:
                        return I;
                A_TOKEN = A_TOKEN + SUBSTR(S, CP, 1);

    def SUBSET_ERROR(NUM):
        # The locals, T, S_PREFIX, and S_MSG, require no persistence.
        S_PREFIX = '  *** SUBSET ACQUISITION ERROR - ';
        S_MSG = ('PREMATURE EOF',
           'BAD SYNTAX: ', 'UNKNOWN FUNCTION: ',
           'UNKNOWN PRODUCTION: ', 'ILLEGAL BIT LENGTH: ');
        if NUM == 0:
            T = '';
        elif NUM == 1:
            T = S;
            while GET_TOKEN():
                pass;
        elif NUM == 2:
            T = A_TOKEN;
        elif NUM == 3:
            T = A_TOKEN;
        elif NUM == 4:
            T = A_TOKEN;
        OUTPUT(0, S_PREFIX + S_MSG[NUM] + T);

    '''
    According to the "HAL/S-FC User's Manual" section 8.6, if there is no
    device 6 to read, or if the specified SUBSET isn't found in it, then
    the message "*** NO LANGUAGE SUBSET IN EFFECT ***" is printed and there
    are no restrictions on the language applied.  That's the normal case,
    and that's what happens when the following 2 lines return 1.  If 
    restrictions were desired for some reason, the afore-mentioned section 8.6
    describes the appropriate data (for device 6) for defining them.
    '''
    if MONITOR(2, 6, SUBSET):
        return 1;
    S = INPUT(6);
    if LENGTH(S) == 0:
        return 1;
    LIMIT = LENGTH(S) - 1;
    OUTPUT(1, SUBSET_MSG + S);
    OUTPUT(0, g.X1);
    CP = LIMIT;
    I = 1;
    while I != 0:
        gt = GET_TOKEN()
        if gt == 0:
            if LENGTH(A_TOKEN) > 0:
                SUBSET_ERROR(0);
        elif gt == 1:
            if A_TOKEN == '$BUILTINS':
                while I:
                    gt2 = GET_TOKEN()
                    if gt2 == 0:
                        SUBSET_ERROR(0);
                    elif gt2 == 1:
                        SUBSET_ERROR(1);
                    elif gt2 == 2 or gt2 == 3:
                        L = BIp;
                        while L > 0:
                            if SUBSTR(g.BI_NAME[g.BI_INDX[L]], g.BI_LOC[L], 10) \
                                    == PAD(A_TOKEN, 10):
                                g.BI_FLAGS[L] = g.BI_FLAGS[L] | FLAGS;
                                L = -1;
                            else: 
                                L = L - 1;
                        if L == 0:
                            SUBSET_ERROR(2);
            elif A_TOKEN == '$PRODUCTIONS':
                while I:
                    gt2 = GET_TOKEN()
                    if gt2 == 0:
                       SUBSET_ERROR(0);
                    elif gt2 == 1:
                       SUBSET_ERROR(1);
                    elif gt2 == 2 or gt2 == 3:
                        L = VALUE;
                        if (L > 0)and(L <= Pp):
                            g.pPRODUCE_NAME[L] = g.pPRODUCE_NAME[L] | SHL(FLAGS, 12);
                        else:
                            SUBSET_ERROR(3);
            elif A_TOKEN == '$BITLENGTH':
                while I:
                    gt2 = GET_TOKEN()
                    if gt2 == 0:
                       SUBSET_ERROR(0);
                    elif gt2 == 1:
                       SUBSET_ERROR(1);
                    elif gt2 == 2:
                        L = VALUE;
                        if L < 1 or L > g.BIT_LENGTH_LIM:
                            SUBSET_ERROR(4);
                        else:
                            g.BIT_LENGTH_LIM = L;
                    elif gt2 == 3:
                       SUBSET_ERROR(1);
            else:
                SUBSET_ERROR(1);
        elif gt == 2:
            SUBSET_ERROR(1);
        elif gt == 3:
            SUBSET_ERROR(1);
    OUTPUT(0, g.X1);
    return 0;
