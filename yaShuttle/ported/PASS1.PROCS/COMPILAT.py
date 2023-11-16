#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   COMPILAT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-25 RSB  Created place-holder file.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON   as h
from ERROR import ERROR
if g.scan1:
    from SCAN1 import SCAN
elif g.scan2:
    from SCAN2 import SCAN
else:
    from SCAN import SCAN
from SRNUPDAT import SRN_UPDATE
from SAVETOKE import SAVE_TOKEN
from POPMACRO import POP_MACRO_XREF
from SYTDUMP import SYT_DUMP
from EMITEXTE import EMIT_EXTERNAL
from STACKDUM import STACK_DUMP
from RECOVER import RECOVER

from SYNTHESI import SYNTHESIZE
from CALLSCAN import CALL_SCAN

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  COMPILATION_LOOP                                       */
 /* MEMBER NAME:     COMPILAT                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADD_TO_STACK(1803)  LABEL                                      */
 /*          COMP(1808)        LABEL                                        */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /*          LOOK_MATCH(1857)  LABEL                                        */
 /*          TOP_MATCH(1833)   LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #PRODUCE_NAME                                                  */
 /*          APPLY1                                                         */
 /*          APPLY2                                                         */
 /*          CHARACTER_STRING                                               */
 /*          CLASS_BS                                                       */
 /*          CLASS_P                                                        */
 /*          CONTROL                                                        */
 /*          FIXING                                                         */
 /*          IMPLIED_TYPE                                                   */
 /*          INDEX1                                                         */
 /*          INDEX2                                                         */
 /*          LOOK1                                                          */
 /*          LOOK2                                                          */
 /*          MAXL#                                                          */
 /*          MAXP#                                                          */
 /*          MAXR#                                                          */
 /*          READ1                                                          */
 /*          READ2                                                          */
 /*          REPLACE_TEXT                                                   */
 /*          RESERVED_WORD                                                  */
 /*          SEMI_COLON                                                     */
 /*          SRN_FLAG                                                       */
 /*          STACKSIZE                                                      */
 /*          STMT_END_FLAG                                                  */
 /*          STMT_PTR                                                       */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYT_INDEX                                                      */
 /*          TOKEN                                                          */
 /*          TRUE                                                           */
 /*          VALUE                                                          */
 /*          VOCAB_INDEX                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BCD                                                            */
 /*          COMPILING                                                      */
 /*          CONTEXT                                                        */
 /*          FIXF                                                           */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          GRAMMAR_FLAGS                                                  */
 /*          LOOK                                                           */
 /*          LOOK_STACK                                                     */
 /*          MAXSP                                                          */
 /*          MP                                                             */
 /*          MPP1                                                           */
 /*          NO_LOOK_AHEAD_DONE                                             */
 /*          PARSE_STACK                                                    */
 /*          REDUCTIONS                                                     */
 /*          SP                                                             */
 /*          STATE_STACK                                                    */
 /*          STATE                                                          */
 /*          STMT_END_PTR                                                   */
 /*          TEMPORARY_IMPLIED                                              */
 /*          VAR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CALL_SCAN                                                      */
 /*          EMIT_EXTERNAL                                                  */
 /*          ERROR                                                          */
 /*          POP_MACRO_XREF                                                 */
 /*          RECOVER                                                        */
 /*          SAVE_TOKEN                                                     */
 /*          SRN_UPDATE                                                     */
 /*          STACK_DUMP                                                     */
 /*          SYNTHESIZE                                                     */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
'''


def COMPILATION_LOOP():
    # The locals, I and J, don't require persistence.  However, they can't 
    # be left uninitialized, in case CONTROL[0x0C] is set for debugging.
    I = 0
    J = 0
    
    #   THIS PROC PARSES THE INPUT STRING (BY CALLING THE SCANNER)
    #   AND CALLS THE CODE EMISSION PROC (SYNTHESIZE) WHENEVER A
    #   PRODUCTION CAN BE APPLIED
    
    #   INITIALIZE
    g.COMPILING = g.TRUE;
    
    def ADD_TO_STACK():
        # No locals.
        g.SP = g.SP + 1;
        if g.SP > g.MAXSP:
            g.MAXSP = g.SP;
            if g.SP > g.STACKSIZE:
                ERROR(d.CLASS_BS, 3);
                return;  #  THUS ABORTING COMPILATION
    
    goto_COMP = True
    while goto_COMP:
        goto_COMP = False
        
        while g.COMPILING:
            
            #   FIND WHICH OF THE FOUR KINDS OF STATES WE ARE DEALING WITH:
            #   READ,APPLY PRODUCTION,LOOKAHEAD, OR PUSH STATE
            if g.CONTROL[0xC] & 1:
                OUTPUT(0, ' COMP: STATE=' + str(g.STATE) + ' I=' + str(I)\
                            +' J=' + str(J));
            if g.STATE <= g.MAXRp:
                #   READ STATE
                if g.NO_LOOK_AHEAD_DONE:
                    CALL_SCAN();
                if g.SRN_FLAG:
                    SRN_UPDATE();
                ADD_TO_STACK();
                g.STATE_STACK[g.SP] = g.STATE;  #   PUSH PRESENT STATE
                g.LOOK_STACK[g.SP] = g.LOOK;
                g.LOOK = 0;
                I = g.INDEX1[g.STATE];  #   GET STARTING POINT
                #   COMPARE TOKEN WITH EACH TRANSITION SYMBOL IN
                #   READ STATE
                for I in range(I, I + g.INDEX2[g.STATE]):
                    if g.READ1[I] == g.TOKEN:
                        #   FOUND IT
                        SAVE_TOKEN(g.TOKEN, g.BCD, g.IMPLIED_TYPE);
                        POP_MACRO_XREF();
                        g.NO_LOOK_AHEAD_DONE = g.TRUE;
                        if g.TOKEN == g.SEMI_COLON:
                            if g.SUBSCRIPT_LEVEL == 0:
                                g.SQUEEZING = g.FALSE;
                                g.CONTEXT = 0
                                g.TEMPORARY_IMPLIED = 0;
                                g.GRAMMAR_FLAGS(g.STMT_PTR, \
                                    g.GRAMMAR_FLAGS(g.STMT_PTR) | g.STMT_END_FLAG);
                                g.STMT_END_PTR = g.STMT_PTR;
                                if g.CONTROL[7] & 1:
                                    SYT_DUMP();
                        g.VAR[g.SP] = g.BCD[:];
                        g.FIXV[g.SP] = hround(g.VALUE) & 0xFFFFFFFF;
                        g.FIXF[g.SP] = g.FIXING;
                        g.FIXL[g.SP] = g.SYT_INDEX;
                        g.PARSE_STACK[g.SP] = g.TOKEN;
                        g.STATE = g.READ2[I];
                        EMIT_EXTERNAL();
                        goto_COMP = True
                        break
                if goto_COMP:
                    break
                #   FOUND AN ERROR
                STACK_DUMP();
                SAVE_TOKEN(g.TOKEN, g.BCD, g.IMPLIED_TYPE);
                if (g.RESERVED_WORD or (g.TOKEN == g.CHARACTER_STRING) or \
                        (g.TOKEN == g.REPLACE_TEXT)):
                    g.BCD = STRING(g.VOCAB_INDEX[g.TOKEN]);
                ERROR(d.CLASS_P, 8, g.BCD);
                RECOVER();
            elif g.STATE > g.MAXPp:
                #   APPLY PRODUCTION STATE
                g.REDUCTIONS = g.REDUCTIONS + 1;
                #   SP POINTS AT RIGHT END OF PRODUCTION
                #   MP POINTS AT LEFT END OF PRODUCTION
                g.MP = g.SP - g.INDEX2[g.STATE];
                g.MPP1 = g.MP + 1;
                SYNTHESIZE (g.STATE - g.MAXPp);  #   APPLY PRODUCTION
                g.SP = g.MP;  #   RESET STACK POINTER
                g.PARSE_STACK[g.SP] = g.pPRODUCE_NAME[g.STATE - g.MAXPp] & 0xFFF;
                I = g.INDEX1[g.STATE];
                #   COMPARE TOP OF STATE STACK WITH TABLES
                J = g.STATE_STACK[g.SP];
                while g.APPLY1[I] != 0:
                    if J == g.APPLY1[I]:
                        break  # GO TO TOP_MATCH;
                    I = I + 1;
                #   HAS THE PROGRAM GOAL BEEN REACHED
                # TOP_MATCH:  
                if g.APPLY2[I] == 0:  #  YES, FINISHED
                    saveClassArray(h.SYM_TAB, "SYM_TAB.json")
                    saveClassArray(h.CROSS_REF, "CROSS_REF.json")
                    #saveClassArray(h.ADVISE, "ADVISE.json")
                    # In the next pass, undo this with:
                    # h.SYM_TAB = loadClassArray(h.sym_tab, "SYM_TAB.json")
                    # h.CROSS_REF = loadClassArray(h.cross_ref, "CROSS_REF.json")
                    # h.ADVISE = loadClassArray(h.advise, "ADVISE.json")
                    # I hope!
                    return
                g.STATE = g.APPLY2[I];  #   PICK UP THE NEXT STATE
                g.LOOK = 0;
            elif g.STATE <= g.MAXLp:
                #   LOOKAHEAD STATE
                I = g.INDEX1[g.STATE];  #   INDEX INTO THE TABLE
                g.LOOK = g.STATE;
                if g.NO_LOOK_AHEAD_DONE:
                    CALL_SCAN();
                #   CHECK TOKEN AGAINST LEGAL LOOKAHEAD TRANSITION SYMBOLS
                while g.LOOK1[I] != 0:
                    if g.LOOK1[I] == g.TOKEN:
                        break  # GO TO LOOK_MATCH;   #   FOUND ONE
                    I = I + 1;
                # LOOK_MATCH: 
                g.STATE = g.LOOK2[I];
            else:  #   PUSH STATE
                ADD_TO_STACK();
                #   PUSH A STATE # INTO THE STATE_STACK
                g.STATE_STACK[g.SP] = g.INDEX2[g.STATE];
                #   GET NEXT STATE
                g.STATE = g.INDEX1[g.STATE];
                g.LOOK_STACK[g.SP] = 0
                g.LOOK = 0;
        # END OF COMPILE LOOP
            
