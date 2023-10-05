#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   IDENTIFY.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-09 RSB  Began porting from XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h  # For debugging.
import HALINCL.CERRDECL as d
import HALINCL.SPACELIB as s
from ERROR import ERROR
from HASH import HASH
from HALINCL.ENTER import ENTER
from SETXREF import SET_XREF
from BUFFERMA import BUFFER_MACRO_XREF
from HALINCL.SETDUPLF import SET_DUPL_FLAG


'''
 /***************************************************************************/
 /* PROCEDURE NAME:  IDENTIFY                                               */
 /* MEMBER NAME:     IDENTIFY                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          BCD               CHARACTER;                                   */
 /*          CENT_IDENTIFY     BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADD_DEFAULT(1540) LABEL                                        */
 /*          ALL_TPLS(1519)    LABEL                                        */
 /*          ASSIGN_TOO(1553)  LABEL                                        */
 /*          BAD_LAB_DEF(1502) LABEL                                        */
 /*          BUILT_IN(1575)    LABEL                                        */
 /*          DCLJOIN(1510)     LABEL                                        */
 /*          DO_LAB(1536)      LABEL                                        */
 /*          DONT_ENTER        BIT(16)                                      */
 /*          DUPL_LABEL(1508)  LABEL                                        */
 /*          END_FUNC_CHECK(1571)  LABEL                                    */
 /*          FLAG              FIXED                                        */
 /*          FUNC_CHECK(1496)  LABEL                                        */
 /*          FUNC_TOKEN_ZERO(1570)  LABEL                                   */
 /*          I                 FIXED                                        */
 /*          IDENTIFY_EXIT(1509)  LABEL                                     */
 /*          J                 FIXED                                        */
 /*          K                 FIXED                                        */
 /*          L                 FIXED                                        */
 /*          LAB_OP_CHECK(1532)  LABEL                                      */
 /*          LABELJOIN(1544)   LABEL                                        */
 /*          LOOKUP(1499)      LABEL                                        */
 /*          MAKE_DEFAULT(1541)  LABEL                                      */
 /*          MAKE_TOKEN(1537)  LABEL                                        */
 /*          MAYBE_FOUND(1574) LABEL                                        */
 /*          NO_ARG_FUNC(1567) LABEL                                        */
 /*          NO_OVERPUNCH(1518)  LABEL                                      */
 /*          NOT_FOUND(1497)   LABEL                                        */
 /*          NOT_FOUND_YET(1562)  LABEL                                     */
 /*          OP_TYPE_MISMATCH(1503)  LABEL                                  */
 /*          OVERRIDE_ERR(1546)  LABEL                                      */
 /*          PARMJOIN(1522)    LABEL                                        */
 /*          Q_TRAP(1506)      LABEL                                        */
 /*          REPL_OP_CHECK(1501)  LABEL                                     */
 /*          SET_DEF_BC(1549)  LABEL                                        */
 /*          SET_INITIAL_FLAGS(1552)  LABEL                                 */
 /*          TEMPL_BRANCH(1526)  LABEL                                      */
 /*          TEMPL_FIXUP(1517) LABEL                                        */
 /*          YES_ARG(1521)     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARITH_FUNC_TOKEN                                               */
 /*          ARITH_TOKEN                                                    */
 /*          ASSIGN_PARM                                                    */
 /*          BI_INDEX                                                       */
 /*          BI_INFO                                                        */
 /*          BI_LIMIT                                                       */
 /*          BI_NAME                                                        */
 /*          BIT_FUNC_TOKEN                                                 */
 /*          BIT_TOKEN                                                      */
 /*          BIT_TYPE                                                       */
 /*          BUILDING_TEMPLATE                                              */
 /*          CHAR_FUNC_TOKEN                                                */
 /*          CHAR_TOKEN                                                     */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_BX                                                       */
 /*          CLASS_DI                                                       */
 /*          CLASS_DT                                                       */
 /*          CLASS_DU                                                       */
 /*          CLASS_FN                                                       */
 /*          CLASS_IR                                                       */
 /*          CLASS_IS                                                       */
 /*          CLASS_MC                                                       */
 /*          CLASS_MO                                                       */
 /*          CLASS_P                                                        */
 /*          CLASS_PL                                                       */
 /*          CLASS_PM                                                       */
 /*          DECLARE_CONTEXT                                                */
 /*          DEF_BIT_LENGTH                                                 */
 /*          DEF_CHAR_LENGTH                                                */
 /*          DEF_MAT_LENGTH                                                 */
 /*          DEF_VEC_LENGTH                                                 */
 /*          DEFAULT_ATTR                                                   */
 /*          DEFAULT_TYPE                                                   */
 /*          DEFINED_LABEL                                                  */
 /*          DUPL_FLAG                                                      */
 /*          EQUATE_CONTEXT                                                 */
 /*          EQUATE_LABEL                                                   */
 /*          EVENT_TOKEN                                                    */
 /*          EVIL_FLAG                                                      */
 /*          EXPRESSION_CONTEXT                                             */
 /*          FALSE                                                          */
 /*          ID_TOKEN                                                       */
 /*          IMP_DECL                                                       */
 /*          INACTIVE_FLAG                                                  */
 /*          IND_CALL_LAB                                                   */
 /*          INPUT_PARM                                                     */
 /*          INT_TYPE                                                       */
 /*          LAB_TOKEN                                                      */
 /*          LABEL_CLASS                                                    */
 /*          LABEL_IMPLIED                                                  */
 /*          LINK_SORT                                                      */
 /*          LOOKUP_ONLY                                                    */
 /*          MAJ_STRUC                                                      */
 /*          MAT_TYPE                                                       */
 /*          NEXT_CHAR                                                      */
 /*          NO_ARG_ARITH_FUNC                                              */
 /*          NO_ARG_BIT_FUNC                                                */
 /*          NO_ARG_CHAR_FUNC                                               */
 /*          NO_ARG_STRUCT_FUNC                                             */
 /*          NONHAL_FLAG                                                    */
 /*          PROC_LABEL                                                     */
 /*          PROCMARK                                                       */
 /*          REF_ID_LOC                                                     */
 /*          REPL_ARG_CLASS                                                 */
 /*          REPL_CLASS                                                     */
 /*          REPL_CONTEXT                                                   */
 /*          REPLACE_PARM_CONTEXT                                           */
 /*          SCALAR_TYPE                                                    */
 /*          STMT_LABEL                                                     */
 /*          STRUC_TOKEN                                                    */
 /*          STRUCT_FUNC_TOKEN                                              */
 /*          STRUCT_TEMPLATE                                                */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_HASHLINK                                                   */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_PTR                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_HASHLINK                                                   */
 /*          SYT_HASHSIZE                                                   */
 /*          SYT_HASHSTART                                                  */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_MAX                                                        */
 /*          SYT_NAME                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /*          TASK_LABEL                                                     */
 /*          TEMPL_NAME                                                     */
 /*          TEMPLATE_CLASS                                                 */
 /*          TEMPLATE_IMPLIED                                               */
 /*          TEMPORARY_FLAG                                                 */
 /*          TRUE                                                           */
 /*          UNSPEC_LABEL                                                   */
 /*          VAR_CLASS                                                      */
 /*          VAR_LENGTH                                                     */
 /*          VEC_TYPE                                                       */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CONTEXT                                                        */
 /*          DELAY_CONTEXT_CHECK                                            */
 /*          EQUATE_IMPLIED                                                 */
 /*          FACTORING                                                      */
 /*          FIXING                                                         */
 /*          IDENT_COUNT                                                    */
 /*          IMPLICIT_T                                                     */
 /*          IMPLIED_TYPE                                                   */
 /*          KIN                                                            */
 /*          MACRO_NAME                                                     */
 /*          NAME_HASH                                                      */
 /*          NAMING                                                         */
 /*          QUALIFICATION                                                  */
 /*          SYM_TAB                                                        */
 /*          SYT_INDEX                                                      */
 /*          TEMPORARY_IMPLIED                                              */
 /*          TOKEN                                                          */
 /*          VALUE                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER                                                          */
 /*          BUFFER_MACRO_XREF                                              */
 /*          ERROR                                                          */
 /*          HASH                                                           */
 /*          SET_DUPL_FLAG                                                  */
 /*          SET_XREF                                                       */
 /* CALLED BY:                                                              */
 /*          SCAN                                                           */
 /***************************************************************************/
'''


class cIDENTIFY:  # Locals specific to IDENTIFY().

    def __init__(self):
        self.I = 0
        self.J = 0
        self.K = 0
        self.L = 0
        self.FLAG = 0
        self.DONT_ENTER = 0


lIDENTIFY = cIDENTIFY()


def IDENTIFY(BCD, CENT_IDENTIFY):
    l = lIDENTIFY
    if g.CONTEXT == g.DECLARE_CONTEXT:
        pass
    
    # Workaround-variables for spaghetti code.  Lots of them.  Nasty!
    goto_NOT_FOUND = False
    goto_LOOKUP = False
    goto_Q_TRAP = False
    goto_BUILT_IN = False
    goto_YES_ARG = False
    goto_MAYBE_FOUND = False
    goto_NOT_FOUND_YET = False
    goto_DO_LAB = False
    goto_LAB_OP_CHECK = False
    goto_MAKE_DEFAULT = False
    goto_ADD_DEFAULT = False
    goto_SET_INITIAL_FLAGS = False
    goto_LABELJOIN = False
    goto_DCLJOIN = False
    goto_PARMJOIN = False
    goto_REPL_OP_CHECK = False
    goto_MAKE_TOKEN = False
    goto_TEMPL_FIXUP = False
    goto_BAD_LAB_DEF = False
    goto_NO_OVERPUNCH = False
    goto_OP_TYPE_MISMATCH = False
    goto_DUPL_LABEL = False
    goto_FUNC_CHECK = False
    goto_NO_ARG_FUNC = False
    goto_FUNC_TOKEN_ZERO = False
    goto_OVERRIDE_ERR = False
    
    l.FLAG = 0;
    g.IDENT_COUNT = g.IDENT_COUNT + 1;
    if g.CONTEXT == g.REPLACE_PARM_CONTEXT:
        goto_NOT_FOUND = True;
    else:
        if CENT_IDENTIFY:
            goto_LOOKUP = True;
        else:
            l.L = LENGTH(BCD);
            if g.TEMPLATE_IMPLIED:
                BCD = g.X1 + BCD;
                l.L = l.L + 1;
                goto_LOOKUP = True;  # CAN'T BE A BUILT-IN
            elif g.EQUATE_IMPLIED:
                BCD = '@' + BCD;
                l.L = l.L + 1;
                g.EQUATE_IMPLIED = g.FALSE;
                goto_LOOKUP = True;
            elif l.L > 1:
                if l.L <= g.BI_LIMIT:
                    for l.J in range(g.BI_INDEX[l.L - 1], g.BI_INDEX[l.L]):
                        if PAD(BCD, 10) == SUBSTR(g.BI_NAME[g.BI_INDX[l.J]], g.BI_LOC[l.J], 10):
                            g.SYT_TYPE(s.RECORD_TOP(h.SYM_TAB), SHR(g.BI_INFO[l.J], 24));
                            l.I = s.RECORD_TOP(h.SYM_TAB);
                            g.SYT_INDEX = l.J + g.SYT_MAX - l.I;
                            if g.IMPLIED_TYPE != 0:
                                g.IMPLIED_TYPE = 0;
                                ERROR(d.CLASS_MC, 2);
                            if g.QUALIFICATION > 0:
                                goto_Q_TRAP = True;
                            elif (g.BI_INFO[l.J] & 0xFF0000) == 0:
                                goto_BUILT_IN = True;
                            else:
                                goto_YES_ARG = True;
    firstTry = True
    while firstTry or goto_LOOKUP or goto_NOT_FOUND or goto_Q_TRAP \
            or goto_BUILT_IN or goto_YES_ARG or goto_MAYBE_FOUND \
            or goto_NOT_FOUND_YET or goto_DO_LAB or goto_LAB_OP_CHECK \
            or goto_MAKE_DEFAULT or goto_ADD_DEFAULT or goto_LABELJOIN \
            or goto_PARMJOIN or goto_MAKE_TOKEN or goto_TEMPL_FIXUP \
            or goto_BAD_LAB_DEF or goto_NO_OVERPUNCH or goto_DUPL_LABEL \
            or goto_FUNC_CHECK:
        firstTry = False
        goto_LOOKUP = False
        if not (goto_BUILT_IN or goto_YES_ARG or goto_MAKE_TOKEN \
                or goto_TEMPL_FIXUP or goto_BAD_LAB_DEF \
                or goto_NO_OVERPUNCH or goto_DUPL_LABEL \
                or goto_FUNC_CHECK or goto_FUNC_TOKEN_ZERO):
            if not goto_MAYBE_FOUND:
                if not (goto_DO_LAB or goto_LAB_OP_CHECK \
                        or goto_MAKE_DEFAULT or goto_ADD_DEFAULT \
                        or goto_LABELJOIN or goto_PARMJOIN):
                    if not goto_NOT_FOUND:
                        if not goto_Q_TRAP:
                            if not goto_NOT_FOUND_YET:
                                g.NAME_HASH = HASH(BCD, g.SYT_HASHSIZE);
                                l.I = g.SYT_HASHSTART[g.NAME_HASH];
                            while l.I > 0 or goto_NOT_FOUND_YET:
                                if BCD == g.SYT_NAME(l.I) and not goto_NOT_FOUND_YET:
                                   goto_MAYBE_FOUND = True;
                                   break
                                goto_NOT_FOUND_YET = False
                                l.I = g.SYT_HASHLINK(l.I);
                            if goto_MAYBE_FOUND:
                                continue
                        goto_Q_TRAP = False
                        #  SPECIAL TRAP FOR QUALIFIED STRUCTURE NAMES
                        if g.QUALIFICATION > 0:
                            g.QUALIFICATION = 0
                            g.IMPLIED_TYPE = 0
                            g.SYT_INDEX = 0;
                            g.TOKEN = g.ID_TOKEN;
                            ERROR(d.CLASS_IS, 1);
                            return;
                    #  COME TO HERE FOR ALL UNQUALIFIED UNKNOWN NAMES
                    goto_NOT_FOUND = False
                    if CENT_IDENTIFY:
                        g.TOKEN = 0;
                        return;
            
                # DO CASE g.CONTEXT;
                if (g.CONTEXT == 0 or goto_DO_LAB or goto_MAKE_DEFAULT \
                        or goto_ADD_DEFAULT) \
                        and not (goto_LAB_OP_CHECK or goto_LABELJOIN \
                                 or goto_PARMJOIN):
                    #  ORDINARY                            #  CASE 0
                    if not goto_ADD_DEFAULT:
                        if not goto_MAKE_DEFAULT:
                            if g.LABEL_IMPLIED or goto_DO_LAB:
                                goto_DO_LAB = False
                                l.I = ENTER(BCD, g.LABEL_CLASS);
                                g.SYT_TYPE(l.I, g.UNSPEC_LABEL);
                                g.SYT_FLAGS(l.I, g.SYT_FLAGS(l.I) | g.DEFINED_LABEL);
                                goto_LAB_OP_CHECK = True
                                g.CONTEXT = -1
                                continue
                            if BCD == 'T':
                                g.IMPLICIT_T = g.TRUE;
                            else:
                                ERROR(d.CLASS_DU, 1, BCD);
                        goto_MAKE_DEFAULT = False
                        l.I = ENTER(BCD, g.VAR_CLASS);
                        g.SYT_FLAGS(l.I, g.SYT_FLAGS(l.I) | g.IMP_DECL);
                        if g.BUILDING_TEMPLATE:
                            g.SYT_FLAGS(g.REF_ID_LOC, g.SYT_FLAGS(g.REF_ID_LOC) | g.EVIL_FLAG);
                    goto_ADD_DEFAULT = False
                    if g.IMPLIED_TYPE == 0:
                        g.SYT_TYPE(l.I, g.DEFAULT_TYPE);
                    else:
                        g.SYT_TYPE(l.I, g.IMPLIED_TYPE);
                    if g.SYT_TYPE(l.I) > g.INT_TYPE:
                        goto_SET_INITIAL_FLAGS = True
                        g.CONTEXT = -1
                    if g.SYT_TYPE(l.I) <= g.CHAR_TYPE:
                        # GO TO SET_DEF_BC;
                        pass
                    else:
                        # INTEGER SCALAR VECTOR OR MATRIX
                        if g.SYT_TYPE(l.I) >= g.SCALAR_TYPE:
                            pass
                        elif g.SYT_TYPE(l.I) == g.VEC_TYPE:
                            g.VAR_LENGTH(l.I, g.DEF_VEC_LENGTH);
                        else:
                            g.VAR_LENGTH(l.I, g.DEF_MAT_LENGTH);
                        goto_SET_INITIAL_FLAGS = True
                        g.CONTEXT = -1
                    # SET_DEF_BC:
                    if not goto_SET_INITIAL_FLAGS:
                        if g.SYT_TYPE(l.I) == g.CHAR_TYPE:
                            g.VAR_LENGTH(l.I, g.DEF_CHAR_LENGTH);
                        else:
                            g.VAR_LENGTH(l.I, g.DEF_BIT_LENGTH);
                    goto_SET_INITIAL_FLAGS = False
                    if g.SYT_TYPE(l.I) <= g.INT_TYPE:
                        g.SYT_FLAGS(l.I, g.SYT_FLAGS(l.I) | g.DEFAULT_ATTR);
                    
                    # DO CASE SYT_TYPE(I);
                    st = g.SYT_TYPE(l.I)
                    if st == 0:
                       ERROR(d.CLASS_BX, 2);  # COMPILER_ERROR IF TYPE = 0
                    elif st == 1:
                       g.TOKEN = g.BIT_TOKEN;
                    elif st == 2:
                       g.TOKEN = g.CHAR_TOKEN;
                    elif st == 3:
                       g.TOKEN = g.ARITH_TOKEN;
                    elif st == 4:
                       g.TOKEN = g.ARITH_TOKEN;
                    elif st == 5:
                       g.TOKEN = g.ARITH_TOKEN;
                    elif st == 6:
                       g.TOKEN = g.ARITH_TOKEN;
                    elif st == 7:
                       g.TOKEN = 0;
                    elif st == 8:
                       g.TOKEN = 0;
                    elif st == 9:
                       g.TOKEN = g.EVENT_TOKEN;  # NOT POSSIBLE??
                    # END OF DO CASE SYT_TYPE(I)
                elif g.CONTEXT == 1 and not goto_LAB_OP_CHECK \
                        and not goto_LABELJOIN and not goto_PARMJOIN:
                    # EXPRESSION CONTEXT                   #  CASE 1
                    ERROR(d.CLASS_DI, 11, BCD);
                    goto_MAKE_DEFAULT = True
                    g.CONTEXT = -1
                    continue
                elif (g.CONTEXT == 2 or goto_LAB_OP_CHECK or goto_LABELJOIN) \
                        and not goto_PARMJOIN:
                    #  GO TO                               #  CASE 2
                    if not goto_LAB_OP_CHECK:
                        if not goto_LABELJOIN:
                            l.FLAG = g.STMT_LABEL;
                        goto_LABELJOIN = False
                        l.I = ENTER(BCD, g.LABEL_CLASS);
                        g.SYT_TYPE(l.I, l.FLAG);
                    goto_LAB_OP_CHECK = False
                    g.TOKEN = g.LAB_TOKEN;
                    if g.IMPLIED_TYPE != 0:
                        ERROR(d.CLASS_MC, 1, BCD);
                elif g.CONTEXT == 3 and not goto_PARMJOIN:
                    #  CALL                                #  CASE 3
                    l.FLAG = g.PROC_LABEL;  # ONLY PROCS MAY BE CALLED
                    g.CONTEXT = 0;  #  IN CASE PARAMETERS FOLLOW
                    g.FIXING = 1;
                    goto_LABELJOIN = True
                    g.CONTEXT = -1
                    continue
                elif g.CONTEXT == 4 and not goto_PARMJOIN:
                    #  SCHEDULE                            #  CASE 4
                    l.FLAG = g.TASK_LABEL;  # ONLY TASKS CAN BE "NOT FOUND"
                    g.CONTEXT = 0;
                    goto_LABELJOIN = True
                    g.CONTEXT = -1
                    continue
                elif g.CONTEXT == 5 and not goto_PARMJOIN:
                    #  DECLARE                             #  CASE 5
                    g.FACTORING = g.FALSE;
                    if g.IMPLIED_TYPE != 0:
                        ERROR(d.CLASS_MC, 6, BCD);
                    if g.TEMPORARY_IMPLIED:
                        l.FLAG = l.FLAG | g.TEMPORARY_FLAG;
                        if g.NEXT_CHAR == BYTE('='):
                            g.TEMPORARY_IMPLIED = g.FALSE;
                    if l.DONT_ENTER > 0:
                        l.I = l.DONT_ENTER;
                        l.DONT_ENTER = 0;
                        g.TOKEN = g.ID_TOKEN;
                        break  # GO TO IDENTIFY_EXIT;
                    goto_DCLJOIN = True
                    # g.CONTEXT = -1  Why did I put this here?
                # Note that the following is an "if" rather than an "elif" to
                # allow the goto_DCLJOIN in the preceding case to fallthrough 
                # into it rather than going through the tedious exercise of 
                # cycling through the containing while-loop ... though perhaps
                # for consistency it might have been better to do so.
                if g.CONTEXT == 6 or goto_DCLJOIN or goto_PARMJOIN:
                    # INPUT PARAMETER                      #  CASE 6
                    if not goto_DCLJOIN:
                        if not goto_PARMJOIN:
                            if g.LOOKUP_ONLY:
                                g.TOKEN = g.STRUCT_TEMPLATE;
                                break  # GO TO IDENTIFY_EXIT;
                            l.FLAG = g.INPUT_PARM;
                        goto_PARMJOIN = False
                        if g.IMPLIED_TYPE != 0:
                            ERROR(d.CLASS_MC, 5, BCD);
                        l.FLAG = l.FLAG | g.IMP_DECL;
                    goto_DCLJOIN = False
                    l.I = ENTER(BCD, g.VAR_CLASS);
                    g.SYT_FLAGS(l.I, g.SYT_FLAGS(l.I) | l.FLAG);
                    g.TOKEN = g.ID_TOKEN;
                elif g.CONTEXT == 7:
                    #  ASSIGN PARM                         #  CASE 7
                    l.FLAG = g.ASSIGN_PARM;
                    goto_PARMJOIN = True;
                    g.CONTEXT = -1
                    continue
                elif g.CONTEXT == 8:
                    #  REPLACE                             #  CASE 8
                    g.SYT_INDEX = ENTER(BCD, g.REPL_CLASS);
                    g.TOKEN = g.ID_TOKEN;
                    g.MACRO_NAME = BCD[:];
                    g.CONTEXT = g.REPLACE_PARM_CONTEXT;
                    goto_REPL_OP_CHECK = True
                    g.CONTEXT = -1
                    # The label is below us, so we're going to fallthrough
                    # rather than continue the enclosing while-loop.
                elif g.CONTEXT == 9:
                    #  CLOSE                               #  CASE 9
                    l.I = -1;  #  SHOULD NEVER BE REFERRED TO
                    goto_LAB_OP_CHECK = True;  #  CLOSE PRODUCTION DOES THE WORK
                    g.CONTEXT = -1
                    continue
                elif g.CONTEXT == 10:
                    #     REPLACE DEFINITION PARAMETERS       # CASE 10
                    g.TOKEN = g.ID_TOKEN;
                    g.SYT_INDEX = ENTER(BCD, g.REPL_ARG_CLASS);
                    g.SYT_FLAGS(g.SYT_INDEX, g.INACTIVE_FLAG);
                    goto_REPL_OP_CHECK = True
                    g.CONTEXT = -1
                    # The label is below us, so we're going to fallthrough
                    # rather than continue the enclosing while-loop.
                elif g.CONTEXT == 11:
                    # EQUATE
                    if g.IMPLIED_TYPE != 0:
                        ERROR(d.CLASS_MC, 7, SUBSTR(BCD, 1));
                    g.TOKEN = g.ID_TOKEN;
                    l.I = ENTER(BCD, g.LABEL_CLASS);
                    g.SYT_FLAGS(l.I, g.INACTIVE_FLAG); ''' WILL BE LEFT IN HASH TABLE
                                                         FOREVER SINCE IT APPEARS TO
                                                         BE ALREADY DISCONNECTED BY
                                                         USE OF INACTIVE_FLAG '''
                    g.SYT_TYPE(l.I, g.EQUATE_LABEL);
                    g.CONTEXT = g.EXPRESSION_CONTEXT;
                    g.NAMING = g.TRUE
                    g.DELAY_CONTEXT_CHECK = g.TRUE;
                    
                # END OF DO CASE CONTEXT
                if not goto_REPL_OP_CHECK:
                    break  # GO TO IDENTIFY_EXIT;
            
            #*************************************************************************
            #  HERE WHEN NAME IS ALREADY IN SYMBOL TABLE:
            goto_MAYBE_FOUND = False
            if g.SYT_CLASS(l.I) == g.REPL_CLASS or goto_REPL_OP_CHECK:
                if g.CONTEXT != g.REPL_CONTEXT or goto_REPL_OP_CHECK:
                    if not goto_REPL_OP_CHECK:
                        g.SYT_INDEX = l.I;
                        g.TOKEN = -1;  #  SPECIAL TOKEN FOR REPLACEMENT
                        BUFFER_MACRO_XREF(l.I);
                    goto_REPL_OP_CHECK = False
                    if g.IMPLIED_TYPE != 0:
                        ERROR(d.CLASS_MC, 3);
                        g.IMPLIED_TYPE = 0;
                    return;
                elif l.I < g.PROCMARK:
                    goto_NOT_FOUND = True
                    continue
                else:
                    ERROR(d.CLASS_IR, 5, BCD);
            elif l.I < g.PROCMARK:
                if g.CONTEXT != g.EQUATE_CONTEXT:
                    if g.CONTEXT > g.DECLARE_CONTEXT:
                        goto_NOT_FOUND = True;
                        continue
            if CENT_IDENTIFY:
                g.TOKEN = 0;
                return;
            
        # DO CASE CONTEXT;        #****  NAME FOUND  ****
        if g.CONTEXT == 0 or goto_BUILT_IN or goto_YES_ARG or goto_MAKE_TOKEN \
                or goto_TEMPL_FIXUP or goto_BAD_LAB_DEF or goto_NO_OVERPUNCH \
                or goto_DUPL_LABEL or goto_FUNC_CHECK or goto_FUNC_TOKEN_ZERO:
            #  ORDINARY                 #  CASE 0
            goto_MAKE_TOKEN = False
            # DO CASE SYT_CLASS(I);
            sc = g.SYT_CLASS(l.I)
            if sc == 0 and not goto_BUILT_IN and not goto_YES_ARG \
                    and not goto_TEMPL_FIXUP and not goto_BAD_LAB_DEF \
                    and not goto_NO_OVERPUNCH and not goto_DUPL_LABEL \
                    and not goto_FUNC_CHECK and not goto_FUNC_TOKEN_ZERO:
                ERROR(d.CLASS_BX, 1, BCD);  #  CASE 0.0
            elif (sc == 1 or goto_TEMPL_FIXUP or goto_BAD_LAB_DEF \
                    or goto_NO_OVERPUNCH) \
                    and not goto_BUILT_IN and not goto_YES_ARG \
                    and not goto_DUPL_LABEL and not goto_FUNC_CHECK \
                    and not goto_FUNC_TOKEN_ZERO:
                #  VARIABLE                         #  CASE 0.1
                if not goto_NO_OVERPUNCH:
                    if not goto_TEMPL_FIXUP and not goto_BAD_LAB_DEF \
                            and not goto_NO_OVERPUNCH:
                        if g.QUALIFICATION > 0:
                            goto_NOT_FOUND_YET = True;
                            continue
                        if g.SYT_TYPE(l.I) == g.MAJ_STRUC:
                            if g.NEXT_CHAR == BYTE(g.PERIOD):
                                g.QUALIFICATION = g.VAR_LENGTH(l.I);
                                if (g.SYT_FLAGS(g.QUALIFICATION) & g.EVIL_FLAG) != 0:
                                    goto_Q_TRAP = True;
                                    continue
                    goto_TEMPL_FIXUP = False
                    if g.LABEL_IMPLIED or goto_BAD_LAB_DEF:
                        if l.I < g.PROCMARK or goto_BAD_LAB_DEF:
                            goto_BAD_LAB_DEF = False
                            ERROR(d.CLASS_PM, 3, BCD);
                            goto_DO_LAB = True
                            continue
                        ERROR(d.CLASS_P, 4, BCD);
                # DO CASE IMPLIED_TYPE;
                if g.IMPLIED_TYPE == 0 or goto_NO_OVERPUNCH:
                    goto_NO_OVERPUNCH = False
                    # DO CASE SYT_TYPE(I);                     #  CASE 0.1.0
                    st = g.SYT_TYPE(l.I)
                    if st == 0:
                        ERROR(d.CLASS_DU, 4, BCD);
                        goto_ADD_DEFAULT = True
                        continue
                    elif st == 1:
                        g.TOKEN = g.BIT_TOKEN;
                    elif st == 2:
                        g.TOKEN = g.CHAR_TOKEN;
                    elif st == 3:
                        g.TOKEN = g.ARITH_TOKEN;  #  UNMARKED MATRIX
                    elif st == 4:
                        g.TOKEN = g.ARITH_TOKEN;  #  UNMARKED VECTOR
                    elif st == 5:
                        g.TOKEN = g.ARITH_TOKEN;
                    elif st == 6:
                        g.TOKEN = g.ARITH_TOKEN;  #  CASE 0.1.0.6
                    elif st == 7:
                        g.TOKEN = 0;  #  COMPILER ERROR
                    elif st == 8:
                        g.TOKEN = 0;  #  COMPILER ERROR
                    elif st == 9:
                        g.TOKEN = g.EVENT_TOKEN;  #  CASE 0.1.0.9
                    elif st == 10:
                        g.TOKEN = g.STRUC_TOKEN;  #  CASE 0.1.0.10
                    # END OF DO CASE SYT_TYPE(I)
                elif g.IMPLIED_TYPE == 1:
                    if g.SYT_TYPE(l.I) == g.BIT_TYPE:  # 0.1.1
                        g.TOKEN = g.BIT_TOKEN;
                    else:
                        goto_OP_TYPE_MISMATCH = True;
                        # We're going to fallthrough rather than redo the while.
                elif g.IMPLIED_TYPE == 2:
                    if g.SYT_TYPE(l.I) == g.CHAR_TYPE:
                        g.TOKEN = g.CHAR_TOKEN;
                    else:
                        goto_OP_TYPE_MISMATCH = True;
                        # We're going to fallthrough rather than redo the while.
                elif g.IMPLIED_TYPE == 3:
                    if g.SYT_TYPE(l.I) == g.MAT_TYPE:
                        g.TOKEN = g.ARITH_TOKEN;
                    else:
                        goto_OP_TYPE_MISMATCH = True;
                        # We're going to fallthrough rather than redo the while.
                # Note the "if" rather than "elif" to allow fallthrough of
                # goto_OP_TYPE_MISMATCH from the cases above.
                if g.IMPLIED_TYPE == 4 or goto_OP_TYPE_MISMATCH:
                    if g.SYT_TYPE(l.I) == g.MAT_TYPE and not goto_OP_TYPE_MISMATCH:
                        g.TOKEN = g.ARITH_TOKEN;
                    elif g.SYT_TYPE(l.I) == g.VEC_TYPE and not goto_OP_TYPE_MISMATCH:
                        g.TOKEN = g.ARITH_TOKEN;
                    else:
                        goto_OP_TYPE_MISMATCH = False
                        ERROR(d.CLASS_MO, 2, BCD);
                        g.IMPLIED_TYPE = 0;
                        goto_NO_OVERPUNCH = True
                        continue
                # END OF DO CASE IMPLIED_TYPE
                # END OF VARIABLE  (CASE 0.1)
            elif (sc == 2 or goto_DUPL_LABEL) \
                    and not goto_BUILT_IN and not goto_YES_ARG \
                    and not goto_FUNC_CHECK and not goto_FUNC_TOKEN_ZERO:
                #  LABEL NAME             #  CASE 0.2
                if g.LABEL_IMPLIED or goto_DUPL_LABEL:  #  LABEL DEFINITION
                    # DUPLICATE NAME OF EXTERNAL LABEL THAT IS NOT GOING
                    # INTO SDF. SO TREAT IT AS A NEW LABEL FOR THIS
                    # COMPILATION UNIT
                    if g.SYT_TYPE(l.I) == 0 and not goto_DUPL_LABEL:
                        goto_DO_LAB = True
                        continue 
                    if l.I < g.PROCMARK and not goto_DUPL_LABEL:
                        goto_DO_LAB = True
                        continue
                    elif (g.SYT_FLAGS(l.I) & g.DEFINED_LABEL) == 0 \
                            and not goto_DUPL_LABEL:
                        g.SYT_FLAGS(l.I, g.SYT_FLAGS(l.I) | g.DEFINED_LABEL);
                        SET_XREF(l.I, 0);
                    elif g.SYT_TYPE(l.I) != g.IND_CALL_LAB:
                        goto_DUPL_LABEL = False
                        ERROR(d.CLASS_PL, 2, BCD);
                goto_LAB_OP_CHECK = True
                continue
            elif sc == 3 or goto_BUILT_IN or goto_YES_ARG or goto_FUNC_CHECK \
                    or goto_FUNC_TOKEN_ZERO:
                if g.LABEL_IMPLIED and not goto_BUILT_IN and not goto_YES_ARG \
                        and not goto_FUNC_CHECK and not goto_FUNC_TOKEN_ZERO: 
                    #  FUNCTION NAME         #  CASE 0.3
                    if l.I < g.PROCMARK:
                        goto_BAD_LAB_DEF = True
                        continue
                    if (g.SYT_FLAGS(l.I) & g.DEFINED_LABEL) != 0:
                        goto_DUPL_LABEL = True
                        continue
                    g.SYT_FLAGS(l.I, g.SYT_FLAGS(l.I) | g.DEFINED_LABEL);
                    SET_XREF(l.I, 0);
                    goto_LAB_OP_CHECK = True
                    continue
                else:
                    if not goto_BUILT_IN:
                        if not goto_YES_ARG and not goto_FUNC_TOKEN_ZERO:
                            goto_FUNC_CHECK = False
                            if g.IMPLIED_TYPE != 0:
                                ERROR(d.CLASS_MC, 2);
                                g.IMPLIED_TYPE = 0;
                            if (g.SYT_FLAGS2(l.I) & g.NONHAL_FLAG) != 0:
                                goto_YES_ARG = True;
                                continue
                            if (g.SYT_FLAGS(l.I) & g.DEFINED_LABEL) == 0:
                                goto_YES_ARG = True;
                                continue
                            if g.SYT_PTR(l.I) == 0:
                                goto_NO_ARG_FUNC = True
                                # Will fall through rather than loop.
                            elif (g.SYT_FLAGS(g.SYT_PTR(l.I)) & g.INPUT_PARM) == 0:
                                goto_NO_ARG_FUNC = True
                                # Will fall through rather than loop
                        goto_YES_ARG = False
                        if not goto_NO_ARG_FUNC or goto_FUNC_TOKEN_ZERO:
                            # DO CASE SYT_TYPE(I)
                            st = g.SYT_TYPE(l.I)
                            if st == 0 or goto_FUNC_TOKEN_ZERO:
                                goto_FUNC_TOKEN_ZERO = False
                                ERROR(d.CLASS_BX, 2);  # COMPILER ERROR
                            elif st == 1:
                                g.TOKEN = g.BIT_FUNC_TOKEN;
                            elif st == 3:
                                g.TOKEN = g.CHAR_FUNC_TOKEN;
                            elif st == 4:
                                g.TOKEN = g.ARITH_FUNC_TOKEN;
                            elif st == 5:
                                g.TOKEN = g.ARITH_FUNC_TOKEN;
                            elif st == 6:
                                g.TOKEN = g.ARITH_FUNC_TOKEN;
                            elif st == 7:
                                g.TOKEN = g.ARITH_FUNC_TOKEN;
                            elif st == 8:
                                g.TOKEN = 0;  # COMPILER ERROR
                            elif st == 9:
                                g.TOKEN = g.ARITH_FUNC_TOKEN;
                            elif st == 10:
                                g.TOKEN = 0;  # EVENT = COMPILER ERROR
                            elif st == 11:
                                g.TOKEN = g.STRUCT_FUNC_TOKEN;
                            # END OF DO CASE SYT_TYPE(I)
                            goto_END_FUNC_CHECK = True
                            # Falls through, rather than looping.
                        if not goto_END_FUNC_CHECK:
                            goto_NO_ARG_FUNC = False
                            if not g.NAMING:
                                g.FIXING = 2;
                    goto_BUILT_IN = False
                    if not goto_END_FUNC_CHECK:
                        # DO CASE SYT_TYPE(I);
                        st = g.SYT_TYPE(l.I)
                        if st == 0:
                            goto_FUNC_TOKEN_ZERO = True
                            continue
                        elif st == 1:
                            g.TOKEN = g.NO_ARG_BIT_FUNC;
                        elif st == 2:
                            g.TOKEN = g.NO_ARG_CHAR_FUNC;
                        elif st == 3:
                            g.TOKEN = g.NO_ARG_ARITH_FUNC;
                        elif st == 4:
                            g.TOKEN = g.NO_ARG_ARITH_FUNC;
                        elif st == 5:
                            g.TOKEN = g.NO_ARG_ARITH_FUNC;
                        elif st == 6:
                            g.TOKEN = g.NO_ARG_ARITH_FUNC;
                        elif st == 7:
                            g.TOKEN = 0;  # COMPILER ERROR
                        elif st == 8:
                            g.TOKEN = g.NO_ARG_ARITH_FUNC;
                        elif st == 9:
                            g.TOKEN = 0;  # EVENT = COMPILER ERROR
                        elif st == 10:
                            g.TOKEN = g.NO_ARG_STRUCT_FUNC;
                    goto_END_FUNC_CHECK = False
                # END OF FUNC_CHECK
            elif sc == 4:
                pass;  # NO MORE STRUCTURE CLASS
            elif sc == 5:
                pass;  #  REPL ARG CLASS                       # CASE 0.5
            elif sc == 6:
                pass;  # REPL  CLASS                           #  CASE 0.6
            elif sc in [7, 8, 9]:
                #  TEMPLATE CLASS                                   #  CASE 0.7
                #  TEMPLATE LABEL CLASS                              # CASE 0.8
                #  TEMPLATE FUNCTION CLASS                           # CASE 0.9
                goto_TEMPL_BRANCH = False
                doElse = True
                if g.QUALIFICATION > 0:
                    doElse = False
                    if g.SYT_TYPE(g.QUALIFICATION) == g.MAJ_STRUC:
                        if g.VAR_LENGTH(g.QUALIFICATION) > 0:
                            g.QUALIFICATION = g.VAR_LENGTH(g.QUALIFICATION);
                            if (g.SYT_FLAGS(g.QUALIFICATION) & g.EVIL_FLAG) != 0:
                                goto_Q_TRAP = True;
                                continue
                    g.KIN = SYT_LINK1(g.QUALIFICATION);
                    while g.KIN > 0:
                        if g.KIN == l.I:
                            if g.SYT_TYPE(l.I) != g.MAJ_STRUC | (g.NEXT_CHAR != BYTE(g.PERIOD)):
                                g.QUALIFICATION = 0;
                            else:
                                g.QUALIFICATION = l.I;
                            goto_TEMPL_BRANCH = True
                            # Falls through
                        else:
                            g.KIN = g.SYT_LINK2(g.KIN);
                    if not goto_TEMPL_BRANCH:
                        goto_NOT_FOUND_YET = True;
                        continue
                if doElse or goto_TEMPL_BRANCH:  # Was "else", now falls through.
                    if not goto_TEMPL_BRANCH:
                        g.KIN = l.I;
                        while g.SYT_TYPE(g.KIN) != g.TEMPL_NAME:
                            g.KIN = g.KIN - 1;
                        if g.SYT_PTR(g.KIN) == 0:
                            goto_NOT_FOUND_YET = True;
                            continue
                        g.VALUE = g.SYT_PTR(g.KIN);
                    goto_TEMPL_BRANCH = False
                    # DO CASE SYT_CLASS(I)-TEMPLATE_CLASS;
                    diff = g.SYT_CLASS(l.I) - g.TEMPLATE_CLASS
                    if diff == 0:
                        goto_TEMPL_FIXUP = True
                        continue
                    elif diff == 1:
                        goto_LAB_OP_CHECK = True
                        continue
                    elif diff == 2:
                        goto_FUNC_CHECK = True
                        continue
            # END OF DO CASE SYT_CLASS(I) FOR ORDINARY
        elif g.CONTEXT == 1:
            # EXPRESSION CONTEXT
            goto_MAKE_TOKEN = True  #  CASE 1
            continue
        # Note that I've swapped the order of cases 2 and 3 to allow 
        # fallthrough of goto_OVERRIDE_ERR from case 3 to case 2 without looping.
        elif g.CONTEXT == 3:
            #  CALL                                #  CASE 3
            g.CONTEXT = 0;  #  IN CASE ARGUMENTS FOLLOW
            g.FIXING = 1;
            l.K = g.SYT_TYPE(l.I);
            if g.SYT_CLASS(l.I) != g.LABEL_CLASS:
                goto_MAKE_TOKEN = True
                continue
            if l.I < g.PROCMARK:
                l.J = ENTER(BCD, g.LABEL_CLASS);
                if (l.K == g.IND_CALL_LAB) or (l.K == g.PROC_LABEL):
                    g.SYT_TYPE(l.J, g.IND_CALL_LAB);
                    g.SYT_PTR(l.J, l.I);
                    g.SYT_FLAGS(l.J, g.SYT_FLAGS(l.J) | g.DEFINED_LABEL);
                else:
                    g.SYT_TYPE(l.J, g.PROC_LABEL);
                    goto_OVERRIDE_ERR = True
                    # Falls through
                if not goto_OVERRIDE_ERR:
                    l.I = l.J;
            if not goto_OVERRIDE_ERR:
                goto_LAB_OP_CHECK = True
                continue
        # Note the "if" rather than "elif" for fallthrough of OVERRID_ERR.
        if g.CONTEXT == 2 or goto_OVERRIDE_ERR:
            #  GO TO                               #  CASE 2
            if not goto_OVERRIDE_ERR:
                l.K = g.SYT_TYPE(l.I);
            if l.I < g.PROCMARK or goto_OVERRIDE_ERR:
                if not goto_OVERRIDE_ERR:
                    l.J = ENTER(BCD, g.LABEL_CLASS);
                    g.SYT_TYPE(l.J, g.STMT_LABEL);
                if g.SYT_CLASS(l.I) != g.LABEL_CLASS or goto_OVERRIDE_ERR:
                    goto_OVERRIDE_ERR = False
                    ERROR(d.CLASS_PM, 4, BCD);
                l.I = l.J;
            elif g.SYT_CLASS(l.I) != g.LABEL_CLASS:
                goto_MAKE_TOKEN = True
                continue
            elif g.SYT_TYPE(l.I) == g.UNSPEC_LABEL:
                g.SYT_TYPE(l.I, g.STMT_LABEL);
            elif g.SYT_TYPE(l.I) > g.UNSPEC_LABEL:
                ERROR(d.CLASS_DT, 3, BCD);
            goto_LAB_OP_CHECK = True
            continue
        elif g.CONTEXT == 4:
            #  SCHEDULE                            #  CASE 4
            g.CONTEXT = 0;
            goto_MAKE_TOKEN = True
            continue
        elif g.CONTEXT == 5:
            #  DECLARE                             #  CASE 5
            if g.LOOKUP_ONLY:
                g.TOKEN = g.STRUCT_TEMPLATE;
                break  # GO TO IDENTIFY_EXIT;
            if l.I < g.PROCMARK:
                goto_NOT_FOUND = True;
                continue
            if g.BUILDING_TEMPLATE:
                g.SYT_FLAGS(g.REF_ID_LOC, g.SYT_FLAGS(g.REF_ID_LOC) | g.DUPL_FLAG);
                if g.SYT_CLASS(l.I) >= g.TEMPLATE_CLASS:
                    if l.I < g.REF_ID_LOC:
                        SET_DUPL_FLAG(l.I);
                        goto_NOT_FOUND_YET = True;
                        continue
                    else:
                        l.FLAG = g.DUPL_FLAG;
            elif g.TEMPORARY_IMPLIED:
                ERROR(d.CLASS_PM, 1, BCD);
                goto_NOT_FOUND = True;
                continue
            else:
                if g.TEMPLATE_IMPLIED:
                    ERROR(d.CLASS_PM, 2, SUBSTR(BCD, 1));  # DUPL TEMPLATE
                    goto_NOT_FOUND = True;  # ENTER ANYWAY
                    continue
                if g.SYT_CLASS(l.I) >= g.TEMPLATE_CLASS:
                    SET_DUPL_FLAG(l.I);
                    goto_NOT_FOUND_YET = True;
                    continue
                if (g.SYT_FLAGS(l.I) & g.IMP_DECL) != 0:
                    g.SYT_FLAGS(l.I, g.SYT_FLAGS(l.I) & (~g.IMP_DECL));
                else:
                    ERROR(d.CLASS_PM, 1, BCD);
                SET_XREF(l.I, 0);
                l.DONT_ENTER = l.I;
            goto_NOT_FOUND_YET = True;
            continue
        elif g.CONTEXT in [6, 7]:
            #  INPUT PARAMETER                     #  CASE 6
            #  ASSIGN PARAMETER                    #  CASE 7
            if g.LOOKUP_ONLY:
                g.TOKEN = g.STRUCT_TEMPLATE;
                break  # GO TO IDENTIFY_EXIT;
            ERROR(d.CLASS_FN, 3, BCD);
            g.TOKEN = g.ID_TOKEN;
        elif g.CONTEXT == 8:
            #  REPLACE                             #  CASE 8
            ERROR(d.CLASS_IR, 1, BCD);  # REPLACING A PARAMETER
            g.TOKEN = g.ID_TOKEN;
            g.CONTEXT = 0;
        elif g.CONTEXT == 9:
            #  CLOSE                               #  CASE 9
             l.I = -1;  #  SHOULD NEVER BE REFERRED TO
             goto_LAB_OP_CHECK = True;  #  CLOSE PRODUCTION DOES THE WORK
             continue
        elif g.CONTEXT == 10:
            # CASE 10
            pass
        elif g.CONTEXT == 11:
            # EQUATE
            ERROR(d.CLASS_DU, 6, SUBSTR(BCD, 1));
            g.TOKEN = g.ID_TOKEN;
            g.CONTEXT = g.EXPRESSION_CONTEXT;
            g.NAMING = g.TRUE
            g.DELAY_CONTEXT_CHECK = g.TRUE;
        # END OF DO CASE CONTEXT WHEN NAME WAS FOUND
    
    # IDENTIFY_EXIT:
    g.SYT_INDEX = g.SYT_INDEX + l.I;
    return;
    
