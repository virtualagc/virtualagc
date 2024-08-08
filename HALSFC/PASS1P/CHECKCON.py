#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHECKCON.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-24 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CHECK_CONSISTENCY                                      */
 /* MEMBER NAME:     CHECKCON                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARRAY_FLAG                                                     */
 /*          BUILDING_TEMPLATE                                              */
 /*          CLASS                                                          */
 /*          CLASS_DA                                                       */
 /*          CLASS_DL                                                       */
 /*          CONSTANT_FLAG                                                  */
 /*          FALSE                                                          */
 /*          ILL_ATTR                                                       */
 /*          ILL_CLASS_ATTR                                                 */
 /*          ILL_LATCHED_ATTR                                               */
 /*          LATCHED_FLAG                                                   */
 /*          LOCK_FLAG                                                      */
 /*          MAJ_STRUC                                                      */
 /*          NONHAL_FLAG                             DR109024               */
 /*          RIGID_FLAG                                                     */
 /*          TRUE                                                           */
 /*          TYPE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATTR_MASK                                                      */
 /*          ATTRIBUTES                                                     */
 /*          ATTRIBUTES2                             DR109024               */
 /*          J                                                              */
 /*          N_DIM                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          CHECK_CONFLICTS                                                */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def CHECK_CONSISTENCY():
    # No local variables.
    # CHECK SOME GLOBAL ERRORS
    if (g.ATTRIBUTES & g.CONSTANT_FLAG) != 0:
        if (g.ATTRIBUTES & g.LOCK_FLAG) != 0:
            ERROR(d.CLASS_DL, 2);
            g.ATTRIBUTES = g.ATTRIBUTES & (~g.LOCK_FLAG);
            g.ATTR_MASK = g.ATTR_MASK & (~g.LOCK_FLAG);
    if (g.ATTRIBUTES & g.AUTO_FLAG) != 0:
        if ((g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & g.REENTRANT_FLAG) != 0) \
                and not g.NAME_IMPLIED:
            if (g.ATTRIBUTES & g.REMOTE_FLAG) != 0:
                ERROR(d.CLASS_DA, 15);
                g.ATTRIBUTES = g.ATTRIBUTES & (~g.REMOTE_FLAG);
                g.ATTR_MASK = g.ATTR_MASK & (~g.REMOTE_FLAG);
    # NOW CHECK ILLEGAL ATTRIBUTES THAT ARE ALWAYS SO FOR EACH DATA TYPE
    if g.TYPE <= g.MAJ_STRUC:
        if g.TYPE == g.MAJ_STRUC:
            if g.N_DIM != 0:  # ARRAY SPEC BAD
                ERROR(d.CLASS_DA, 26);
                g.N_DIM = 0;
                g.ATTRIBUTES = g.ATTRIBUTES & (~g.ARRAY_FLAG);
        g.J = g.FALSE;
        if (g.ATTRIBUTES & g.ILL_ATTR[g.TYPE]) != 0:
            g.J = g.TRUE;  # ONLY GIVE ONE ERROR
            g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_ATTR[g.TYPE]);
            g.ATTR_MASK = g.ATTR_MASK & (~g.ILL_ATTR[g.TYPE]);
        if g.TYPE == 0:
           if (g.ATTRIBUTES & g.LATCHED_FLAG) != 0:
                if (g.ATTRIBUTES & g.ILL_LATCHED_ATTR) != 0 or \
                        (g.ATTRIBUTES2 & g.NONHAL_FLAG) != 0:
                    g.J = g.TRUE;
                    g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_LATCHED_ATTR);
                    g.ATTRIBUTES2 = g.ATTRIBUTES2 & (~g.NONHAL_FLAG);
                    g.ATTR_MASK = g.ATTR_MASK & (~g.ILL_LATCHED_ATTR);
        if g.J: 
            ERROR(d.CLASS_DA, g.TYPE);
    if (g.ATTRIBUTES & g.ILL_CLASS_ATTR[g.CLASS]) != 0:
        ERROR(d.CLASS_DA, 11);
        g.N_DIM = 0;
        g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_CLASS_ATTR[g.CLASS]);
        g.ATTR_MASK = g.ATTR_MASK & (~g.ILL_CLASS_ATTR[g.CLASS]);
    elif not g.BUILDING_TEMPLATE:
        if (g.ATTRIBUTES & g.RIGID_FLAG) != 0:
            if g.TYPE == g.MAJ_STRUC:
                ERROR(d.CLASS_DA, 10);
            else:
                ERROR(d.CLASS_DA, 12);
            g.ATTRIBUTES = g.ATTRIBUTES & (~g.RIGID_FLAG);
        if g.TYPE == g.MAJ_STRUC:
            if (g.ATTRIBUTES & g.ALDENSE_FLAGS) != 0:
                ERROR(d.CLASS_DA, 10);
                g.ATTRIBUTES = g.ATTRIBUTES & (~g.ALDENSE_FLAGS);
    
