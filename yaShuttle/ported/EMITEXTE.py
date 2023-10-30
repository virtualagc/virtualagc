#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   EMITEXTE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-12 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from BLANK    import BLANK
from DESCORE  import DESCORE
from FINDER   import FINDER
from PAD      import PAD

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  EMIT_EXTERNAL                                          */
 /* MEMBER NAME:     EMITEXTE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADD_CHAR(1538)    LABEL                                        */
 /*          BINX              BIT(16)                                      */
 /*          CHAR              CHARACTER;                                   */
 /*          EX_WRITE(1528)    LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          INCR_PTR(1533)    LABEL                                        */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          NEWBUFF           CHARACTER;                                   */
 /*          OLDBUFF           CHARACTER;                                   */
 /*          VERSION           CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BCD                                                            */
 /*          BLOCK_SYTREF                                                   */
 /*          CHARACTER_STRING                                               */
 /*          CLASS_XV                                                       */
 /*          ESCP                                                           */
 /*          MAC_TXT                                                        */
 /*          MACRO_TEXTS                                                    */
 /*          MACRO_TEXT                                                     */
 /*          MP                                                             */
 /*          PARSE_STACK                                                    */
 /*          REPLACE_TEXT                                                   */
 /*          RESERVED_WORD                                                  */
 /*          SDL_OPTION                                                     */
 /*          SP                                                             */
 /*          START_POINT                                                    */
 /*          SYM_LOCK#                                                      */
 /*          SYT_LOCK#                                                      */
 /*          TOKEN                                                          */
 /*          TPL_LRECL                                                      */
 /*          TRANS_OUT                                                      */
 /*          VAR                                                            */
 /*          VOCAB_INDEX                                                    */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXTERNALIZE                                                    */
 /*          SYM_TAB                                                        */
 /*          TPL_FLAG                                                       */
 /*          TPL_NAME                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLANK                                                          */
 /*          DESCORE                                                        */
 /*          ERROR                                                          */
 /*          FINDER                                                         */
 /*          PAD                                                            */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /*          COMPILATION_LOOP                                               */
 /***************************************************************************/
'''


class cEMIT_EXTERNAL:  # Local variables for EMIT_EXTERNAL

    def __init__(self):
        self.NEWBUFF = ''
        self.OLDBUFF = ''
        self.CHAR = ''
        self.VERSION = 'D VERSION  '
        self.BINX = 0
        self.I = 0
        self.J = 0
        self.K = 0
        if not g.pfs:
            # BFS/PASS INTERFACE; FIX COMPOOL RIGID BUG
            self.BLANK_NEEDED = g.TRUE


lEMIT_EXTERNAL = cEMIT_EXTERNAL()


def EMIT_EXTERNAL():
    l = lEMIT_EXTERNAL  # Local variables.
    
    def EX_WRITE():
        # No locals.
        OUTPUT(6, l.NEWBUFF);
        if g.TPL_FLAG == 0:
            pass
        elif g.TPL_FLAG == 1:
            if l.NEWBUFF != SUBSTR(l.OLDBUFF, 0, g.TPL_LRECL):
                g.TPL_FLAG = 2;
            else:
                l.OLDBUFF = INPUT(7);
        elif g.TPL_FLAG in [2, 3]:
            pass
    
    def ADD_CHAR(VAL):
        # No locals.
        l.NEWBUFF = BYTE(l.NEWBUFF, l.BINX, VAL);
        l.BINX = l.BINX + 1;
        if l.BINX == g.TPL_LRECL:
            EX_WRITE();
            l.NEWBUFF = BLANK(l.NEWBUFF, 0, g.TPL_LRECL);
            l.BINX = 1;
    
    # DO CASE EXTERNALIZE;
    if g.EXTERNALIZE == 0:
        #  NOT OPERATING
        pass
    elif g.EXTERNALIZE == 1:
        # RUNNING
        if g.TOKEN == g.REPLACE_TEXT:
            ADD_CHAR(BYTE('"'));
            l.I = g.START_POINT;
            l.J = g.MACRO_TEXT(l.I);
            while l.J != 0xEF:
                if l.J == BYTE('"'):
                    ADD_CHAR(BYTE('"'));
                    ADD_CHAR(BYTE('"'));
                elif l.J == 0xEE:
                    '''
                    The following is trying to account for the notion the 
                    original coders apparently used -- completely 
                    undocumented -- that an expression like "x ^= y" produces 
                    a numerical value, and that that numerical value is 1 when 
                    the expression is true or 0 when it is false.
                    '''
                    mt = g.MACRO_TEXT(l.I + 1)
                    if g.MACRO_TEXT(l.I + 1) != 0:
                        mt += 1
                    for l.J in range(1, mt + 1):
                        ADD_CHAR(BYTE(g.X1));
                    l.I = l.I + 1;
                else:
                    ADD_CHAR(l.J);  # NORMAL TEXT 
                l.I = l.I + 1;
                l.J = g.MACRO_TEXT(l.I);
            # END OF WHILE NOT "EF"
            ADD_CHAR(BYTE('"'));
            if not g.pfs:
                # BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN TEMPLATE
                l.BLANK_NEEDED = g.TRUE;
        # END OF TOKEN = REPLACE_TEXT
        elif g.RESERVED_WORD:
            l.CHAR = STRING(g.VOCAB_INDEX[g.TOKEN]);
            if not g.pfs:
                # BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN TEMPLATE
                if LENGTH(l.CHAR) == 1:
                    l.BLANK_NEEDED = g.FALSE;
                else:
                    if l.BLANK_NEEDED:
                        ADD_CHAR(BYTE(g.X1));
                    l.BLANK_NEEDED = g.TRUE;
            for l.I in range(0, LENGTH(l.CHAR)):
                ADD_CHAR(BYTE(l.CHAR, l.I));
        elif g.TOKEN == g.CHARACTER_STRING:
            ADD_CHAR(BYTE(g.SQUOTE));
            l.I = 0;
            l.J = BYTE(g.BCD, l.I);
            goto_INCR_PTR = False
            firstTry = True
            while firstTry or goto_INCR_PTR:
                firstTry = False
                while goto_INCR_PTR or \
                        ((l.J != BYTE(g.SQUOTE)) and (l.I < LENGTH(g.BCD))):
                    if not goto_INCR_PTR:
                        if (g.TRANS_OUT[l.J] & 0xFF) != 0:
                            for l.K in range(0, (SHR(g.TRANS_OUT[l.J], 8) & 0xFF) + 1):
                               ADD_CHAR(g.ESCP);
                            ADD_CHAR(g.TRANS_OUT[l.J] & 0xFF);
                        else:
                            ADD_CHAR(l.J);
                    goto_INCR_PTR = False
                    l.I = l.I + 1;
                    l.J = BYTE(g.BCD, l.I);
                # END OF DO WHILE
                ADD_CHAR(BYTE(g.SQUOTE));
                if l.I != LENGTH(g.BCD):
                    ADD_CHAR(BYTE(g.SQUOTE));
                    goto_INCR_PTR = True
                    continue
            if not g.pfs:
                # BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN TEMPLATE
                l.BLANK_NEEDED = g.FALSE;
        # END OF TOKEN = CHARACTER_STRING
        else:  # TOKEN = ANYTHING ELSE
            if not g.pfs:
                # BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN TEMPLATE
                if l.BLANK_NEEDED:
                    ADD_CHAR(BYTE(g.X1));
            for l.I in range(0, LENGTH(g.BCD)):
                ADD_CHAR(BYTE(g.BCD, l.I));
            if not g.pfs:
                # BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN TEMPLATE
                l.BLANK_NEEDED = g.TRUE;
        # END OF TOKEN = ANYTHING ELSE
        if g.pfs:
            # BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN TEMPLATE FOR BFS
            ADD_CHAR(BYTE(g.X1));  # SPACE BETWEEN TOKENS
        # END OF RUNNING
    elif g.EXTERNALIZE == 2:
        #  STOPPING
        if l.BINX > 1:
            EX_WRITE();
        l.NEWBUFF = PAD(' CLOSE ;   ', g.TPL_LRECL);
        EX_WRITE();
        g.EXTERNALIZE = 0;
        if g.TPL_FLAG == 3:
            return;
        if g.TPL_FLAG == 0:
            l.J = 0x01
            #l.VERSION = BYTE(l.VERSION, 10, 0x01);
            l.VERSION = l.VERSION[:10] + ("%02X" % 0x01)
        else:
            while LENGTH(l.OLDBUFF) > 0:
                l.NEWBUFF = l.OLDBUFF;
                l.OLDBUFF = INPUT(7);
            MONITOR(3, 7);  # CLOSE THE TEMPLATE FILE
            if SUBSTR(l.NEWBUFF, 0, 10) != SUBSTR(l.VERSION, 0, 10):
                l.I = 0x01
                l.J = 0x01;
                if not g.SDL_OPTION:
                    ERROR(d.CLASS_XV, 1, g.TPL_NAME);
            else:
                #l.J = BYTE(l.NEWBUFF, 10);
                l.J = int(l.NEWBUFF[10:], 16)
                if l.J == 0xFF:
                    l.I = 0x01;
                else:
                    l.I = l.J + 1;
                if g.TPL_FLAG == 2:
                    l.J = l.I;
            #l.VERSION = BYTE(l.VERSION, 10, l.I);
            l.VERSION = l.VERSION[:10] + ("%02X" % l.I)
        g.SYT_LOCKp(g.BLOCK_SYTREF[1], l.J);
        #OUTPUT(6, l.VERSION + str(BYTE(l.VERSION, 10)));
        OUTPUT(6, l.VERSION)
    elif g.EXTERNALIZE == 3:
        #  STARTING
        l.NEWBUFF = ': EXTERNAL ' + STRING(g.VOCAB_INDEX[g.PARSE_STACK[g.SP]]) + g.X1;
        l.NEWBUFF = g.X1 + g.VAR[g.MP] + l.NEWBUFF;
        l.BINX = LENGTH(l.NEWBUFF);
        l.NEWBUFF = PAD(l.NEWBUFF, g.TPL_LRECL);
        g.EXTERNALIZE = 1;
        g.TPL_NAME = DESCORE(g.VAR[g.MP]);
        g.TPL_FLAG = (FINDER(7, g.TPL_NAME, 1) == 0);  # IGNORE INLINE BLOCKS
        if g.TPL_FLAG & 1:
            l.OLDBUFF = INPUT(7);
    elif g.EXTERNALIZE == 4:
        pass  #  QUIESCENT
