#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHECKCO2.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-24 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR    import ERROR
from CHECKCON import CHECK_CONSISTENCY
from COMPARE  import COMPARE

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CHECK_CONFLICTS                                        */
 /* MEMBER NAME:     CHECKCO2                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TYPE_CONFLICT     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_D                                                        */
 /*          CLASS_DA                                                       */
 /*          CLASS_DC                                                       */
 /*          CLASS_DI                                                       */
 /*          DEFAULT_TYPE                                                   */
 /*          FACTOR_FOUND                                                   */
 /*          FACTORED_BIT_LENGTH                                            */
 /*          FACTORED_CHAR_LENGTH                                           */
 /*          FACTORED_CLASS                                                 */
 /*          FACTORED_IC_FND                                                */
 /*          FACTORED_LOCK#                                                 */
 /*          FACTORED_MAT_LENGTH                                            */
 /*          FACTORED_N_DIM                                                 */
 /*          FACTORED_NONHAL                                                */
 /*          FACTORED_S_ARRAY                                               */
 /*          FACTORED_STRUC_DIM                                             */
 /*          FACTORED_STRUC_PTR                                             */
 /*          FACTORED_TYPE                                                  */
 /*          FACTORED_VEC_LENGTH                                            */
 /*          IC_FND                                                         */
 /*          IC_PTR                                                         */
 /*          ID_LOC                                                         */
 /*          INIT_CONST                                                     */
 /*          MAJ_STRUC                                                      */
 /*          MP                                                             */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          VAR                                                            */
 /*          VEC_TYPE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATTR_MASK                                                      */
 /*          ATTRIBUTES                                                     */
 /*          BIT_LENGTH                                                     */
 /*          CHAR_LENGTH                                                    */
 /*          CLASS                                                          */
 /*          FACTORED_ATTR_MASK                                             */
 /*          FACTORED_ATTRIBUTES                                            */
 /*          I                                                              */
 /*          IC_FOUND                                                       */
 /*          IC_PTR2                                                        */
 /*          LOCK#                                                          */
 /*          MAT_LENGTH                                                     */
 /*          N_DIM                                                          */
 /*          NONHAL                                                         */
 /*          S_ARRAY                                                        */
 /*          STRUC_DIM                                                      */
 /*          STRUC_PTR                                                      */
 /*          TYPE                                                           */
 /*          VEC_LENGTH                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMPARE                                                        */
 /*          CHECK_CONSISTENCY                                              */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

def CHECK_CONFLICTS():
    # There are no locals.
    goto_TYPE_CONFLICT = False
    firstTry = True
    while firstTry or goto_TYPE_CONFLICT:
        firstTry = False
        if (g.CLASS|g.FACTORED_CLASS)==3:
            goto_TYPE_CONFLICT = False
            ERROR(d.CLASS_DC,4,g.VAR[g.MP]);
        else: 
            if g.TYPE==0: 
                if g.FACTORED_TYPE==0:
                    g.TYPE=g.DEFAULT_TYPE;
                    g.DOUBLELIT = g.FALSE;
                else: 
                    g.TYPE=g.FACTORED_TYPE;
            elif g.FACTORED_TYPE!=0:
                if g.TYPE!=g.FACTORED_TYPE: 
                    goto_TYPE_CONFLICT = True
                    continue
            g.CLASS=g.CLASS|g.FACTORED_CLASS;
    if g.IC_FND & 1:
        g.IC_FOUND = g.IC_FOUND | 2;
        g.IC_PTR2 = g.IC_PTR;
        if g.FACTORED_IC_FND & 1:
            g.FACTORED_ATTRIBUTES=g.FACTORED_ATTRIBUTES&(~g.INIT_CONST);
            g.FACTORED_ATTR_MASK=g.FACTORED_ATTR_MASK&(~g.INIT_CONST);
            ERROR(d.CLASS_DI, 9, g.SYT_NAME(g.ID_LOC));
    I = g.FACTORED_ATTR_MASK & g.ATTR_MASK;
    if I != 0:
        if (g.FACTORED_ATTRIBUTES & I) != (g.ATTRIBUTES & I):
            ERROR(d.CLASS_DA, 24, g.SYT_NAME(g.ID_LOC));
    g.ATTRIBUTES = g.ATTRIBUTES | (g.FACTORED_ATTRIBUTES & (~I));
    g.ATTR_MASK = g.ATTR_MASK | (g.FACTORED_ATTR_MASK & (~I));
    CHECK_CONSISTENCY();
    if  not (g.FACTOR_FOUND & 1): 
        return;
    if g.FACTORED_LOCKp!=0:
        if g.LOCKp!=0: 
            ERROR(d.CLASS_D,5,g.SYT_NAME(g.ID_LOC));
        else: 
            g.LOCKp=g.FACTORED_LOCKp;
    if g.FACTORED_N_DIM != 0:
        if g.N_DIM != 0:
            ERROR(d.CLASS_D, 6, g.SYT_NAME(g.ID_LOC));
        else: 
            g.N_DIM = g.FACTORED_N_DIM;
            for I in range(0, g.N_DIM + 1):
               g.S_ARRAY[I] = g.FACTORED_S_ARRAY[I];

    if g.FACTORED_NONHAL>0:
        if g.NONHAL==0: 
            g.NONHAL=g.FACTORED_NONHAL;
        elif g.NONHAL!=g.FACTORED_NONHAL: 
            ERROR(d.CLASS_D,13,g.VAR[g.MP]);
    if g.TYPE <= g.VEC_TYPE:
        # CHECK SIZES
        if g.TYPE == 0:
            pass;  # NO TYPE 0
        elif g.TYPE == 1:
            g.BIT_LENGTH = COMPARE(g.BIT_LENGTH, g.FACTORED_BIT_LENGTH, 5);
        elif g.TYPE == 2:
            g.CHAR_LENGTH=COMPARE(g.CHAR_LENGTH,g.FACTORED_CHAR_LENGTH,6);
        elif g.TYPE == 3:
            g.MAT_LENGTH = COMPARE(g.MAT_LENGTH, g.FACTORED_MAT_LENGTH, 7);
        elif g.TYPE == 4:
            g.VEC_LENGTH = COMPARE(g.VEC_LENGTH, g.FACTORED_VEC_LENGTH, 8);
        # ENF OF DO CASE TYPE
    elif g.TYPE == g.MAJ_STRUC:
        g.STRUC_DIM = COMPARE(g.STRUC_DIM, g.FACTORED_STRUC_DIM, 9);
        g.STRUC_PTR = COMPARE(g.STRUC_PTR, g.FACTORED_STRUC_PTR, 10);
    
