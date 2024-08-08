#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SETSYTEN.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-24 RSB  Began porting from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR
from HALMATIN import HALMAT_INIT_CONST
from HALINCL.ENTERDIM import ENTER_DIMS
from HALINCL.ICQARRAY import ICQ_ARRAYp
from HALINCL.ICQTERMp import ICQ_TERMp

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_SYT_ENTRIES                                        */
 /* MEMBER NAME:     SETSYTEN                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHAR_STAR_ERR     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ASSIGN_PARM                                                    */
 /*          BLOCK_MODE                                                     */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_BX                                                       */
 /*          CLASS_DD                                                       */
 /*          CLASS_DL                                                       */
 /*          CLASS_DS                                                       */
 /*          CMPL_MODE                                                      */
 /*          DEF_CHAR_LENGTH                                                */
 /*          EXT_ARRAY_PTR                                                  */
 /*          FACTOR_LIM                                                     */
 /*          ID_LOC                                                         */
 /*          LATCHED_FLAG                                                   */
 /*          LOCK_FLAG                                                      */
 /*          LOCK#                                                          */
 /*          MAJ_STRUC                                                      */
 /*          N_DIM                                                          */
 /*          NAME_FLAG                                                      */
 /*          NAME_IMPLIED                                                   */
 /*          NEST                                                           */
 /*          ON_ERROR_PTR                                                   */
 /*          PARM_FLAGS                                                     */
 /*          PROG_LABEL                                                     */
 /*          STRUC_PTR                                                      */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LOCK#                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LOCK#                                                      */
 /*          SYT_NAME                                                       */
 /*          TASK_LABEL                                                     */
 /*          VAR_LENGTH                                                     */
 /*          VEC_TYPE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATTRIBUTES                                                     */
 /*          CHAR_LENGTH                                                    */
 /*          I                                                              */
 /*          S_ARRAY                                                        */
 /*          STRUC_DIM                                                      */
 /*          SYM_TAB                                                        */
 /*          TYPE                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER_DIMS                                                     */
 /*          ERROR                                                          */
 /*          HALMAT_INIT_CONST                                              */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def SET_SYT_ENTRIES():
    g.SYT_TYPE(g.ID_LOC, g.TYPE);
    if (g.ATTRIBUTES & g.LOCK_FLAG) != 0:
        if (g.NEST == 1 and g.BLOCK_MODE[g.NEST] >= g.CMPL_MODE) or \
                (g.SYT_FLAGS(g.ID_LOC) and g.ASSIGN_PARM) != 0:
            g.SYT_LOCKp(g.ID_LOC, g.LOCKp);
        else: 
            g.ATTRIBUTES = g.ATTRIBUTES & (~g.LOCK_FLAG);
            ERROR(d.CLASS_DL, 1, g.SYT_NAME(g.ID_LOC));
    if g.NAME_IMPLIED: 
        g.ATTRIBUTES = g.ATTRIBUTES | g.NAME_FLAG;
    g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) | g.ATTRIBUTES);
    if g.TYPE == g.CHAR_TYPE:
        goto_CHAR_STAR_ERR = False
        firstTry = True
        while firstTry or goto_CHAR_STAR_ERR:
            firstTry = False
            if not goto_CHAR_STAR_ERR and g.NAME_IMPLIED:
                if g.N_DIM != 0: 
                    goto_CHAR_STAR_ERR = True
                    continue
            elif not goto_CHAR_STAR_ERR and (g.SYT_FLAGS(g.ID_LOC) & g.PARM_FLAGS) != 0:
                if g.CHAR_LENGTH != -1:
                    g.CHAR_LENGTH = -1;
                    ERROR(d.CLASS_DS, 11);
            else: 
                goto_CHAR_STAR_ERR = False
                if g.CHAR_LENGTH == -1:
                    g.CHAR_LENGTH = g.DEF_CHAR_LENGTH;
                    ERROR(d.CLASS_DS, 3);
    if g.TYPE <= g.VEC_TYPE:
        g.VAR_LENGTH(g.ID_LOC, g.TYPEf(g.TYPE));
    if g.N_DIM != 0:
        # STUFF THE DIMENSIONS
        if g.EXT_ARRAY_PTR + g.N_DIM >= g.ON_ERROR_PTR:
            ERROR(d.CLASS_BX, 5);
        else: 
            if (g.N_DIM == 1) and (g.S_ARRAY[0] == -1):
                if (g.SYT_FLAGS(g.ID_LOC) & g.PARM_FLAGS) != 0 and (not g.NAME_IMPLIED):
                    g.S_ARRAY[0] = -g.ID_LOC;
                else: 
                    g.S_ARRAY[0] = 2;
                    ERROR(d.CLASS_DD, 10, g.SYT_NAME(g.ID_LOC));
            ENTER_DIMS();
            # IF AN ARRAY'S SIZE IS NOT AN * THEN CHECK IF THE TOTAL
            # NUMBER OF ELEMENTS IN AN ARRAY IS GREATER THAN 32767
            # OR LESS THAN 1. IF IT IS THEN GENERATE A DD1 ERROR.
            if h.EXT_ARRAY[g.SYT_ARRAY(g.ID_LOC) + 1] > 0:
                if (ICQ_TERMp(g.ID_LOC) * ICQ_ARRAYp(g.ID_LOC) > g.ARRAY_DIM_LIM) \
                        or (ICQ_TERMp(g.ID_LOC) * ICQ_ARRAYp(g.ID_LOC) < 1):
                    ERROR(d.CLASS_DD, 1);
    if g.TYPE == g.MAJ_STRUC:
        g.VAR_LENGTH(g.ID_LOC, g.STRUC_PTR);
        if g.STRUC_DIM == -1:
            if (g.SYT_FLAGS(g.ID_LOC) & g.PARM_FLAGS) != 0 and (not g.NAME_IMPLIED):
                g.STRUC_DIM = -g.ID_LOC;
            else: 
                ERROR(d.CLASS_DD, 8, g.SYT_NAME(g.ID_LOC));
                g.STRUC_DIM = 2;
        if g.STRUC_DIM != 0:
            g.SYT_ARRAY(g.ID_LOC, g.STRUC_DIM);
            # IF A STRUCTURE'S SIZE IS NOT AN * THEN CHECK IF THE TOTAL
            # NUMBER OF ELEMENTS IN A MAJOR STRUCTURE IS GREATER THAN
            # 32767 OR LESS THAN 1. IF IT IS THEN GENERATE A DD11 ERROR.
            if g.STRUC_DIM > 0:
                if (ICQ_TERMp(g.ID_LOC) * g.SYT_ARRAY(g.ID_LOC) > g.ARRAY_DIM_LIM) \
                        or (ICQ_TERMp(g.ID_LOC) * g.SYT_ARRAY(g.ID_LOC) < 1):
                    ERROR(d.CLASS_DD, 11);
        elif (ICQ_TERMp(g.ID_LOC) > g.ARRAY_DIM_LIM) or \
                (ICQ_TERMp(g.ID_LOC) < 1):
            ERROR(d.CLASS_DD, 11);
    elif g.TYPE == g.TASK_LABEL or g.TYPE == g.PROG_LABEL:
        g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) | g.LATCHED_FLAG);
    HALMAT_INIT_CONST();
    for I in range(0, g.FACTOR_LIM + 1):
        g.TYPEf(I, 0);
    
