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
from ERROR    import ERROR

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
    SYT_TYPE(ID_LOC) = TYPE;
    if (ATTRIBUTES & LOCK_FLAG) != 0:
        if (NEST == 1 and BLOCK_MODE(NEST) >= CMPL_MODE) or \
                (SYT_FLAGS(ID_LOC) and ASSIGN_PARM) != 0:
            SYT_LOCKp(ID_LOC) = LOCKp;
        else: 
            ATTRIBUTES = ATTRIBUTES & (~LOCK_FLAG);
            ERROR(d.CLASS_DL, 1, SYT_NAME(ID_LOC));
    if NAME_IMPLIED: 
        ATTRIBUTES = ATTRIBUTES | NAME_FLAG;
    SYT_FLAGS(ID_LOC) = SYT_FLAGS(ID_LOC) | ATTRIBUTES;
    if TYPE == CHAR_TYPE:
        goto_CHAR_STAR_ERR = False
        firstTry = True
        while firstTry or goto_CHAR_STAR_ERR:
            firstTry = False
            if not goto_CHAR_STAR_ERR and NAME_IMPLIED:
                if N_DIM != 0: 
                    goto_CHAR_STAR_ERR = True
                    continue
            elif not goto_CHAR_STAR_ERR and (SYT_FLAGS(ID_LOC) & PARM_FLAGS) != 0:
                if CHAR_LENGTH != -1:
                    CHAR_LENGTH = -1;
                    ERROR(d.CLASS_DS, 11);
            else: 
                goto_CHAR_STAR_ERR = False
                if CHAR_LENGTH == -1:
                    CHAR_LENGTH = DEF_CHAR_LENGTH;
                    ERROR(d.CLASS_DS, 3);
    if TYPE <= VEC_TYPE:
        VAR_LENGTH(ID_LOC) = TYPE(TYPE);
    if N_DIM != 0:
        # STUFF THE DIMENSIONS
        if EXT_ARRAY_PTR + N_DIM >= ON_ERROR_PTR:
            ERROR(d.CLASS_BX, 5);
        else: 
            if (N_DIM == 1) and (S_ARRAY == -1):
                if (SYT_FLAGS(ID_LOC) & PARM_FLAGS) != 0 and (not NAME_IMPLIED):
                    S_ARRAY[0] = -ID_LOC;
                else: 
                    S_ARRAY[0] = 2;
                    ERROR(d.CLASS_DD, 10, SYT_NAME(ID_LOC));
                ENTER_DIMS();
                # IF AN ARRAY'S SIZE IS NOT AN * THEN CHECK IF THE TOTAL
                # NUMBER OF ELEMENTS IN AN ARRAY IS GREATER THAN 32767
                # OR LESS THAN 1. IF IT IS THEN GENERATE A DD1 ERROR.
                if EXT_ARRAY(SYT_ARRAY(ID_LOC) + 1) > 0:
                    if (ICQ_TERMp(ID_LOC) * ICQ_ARRAYp(ID_LOC) > ARRAY_DIM_LIM) \
                            or (ICQ_TERMp(ID_LOC) * ICQ_ARRAYp(ID_LOC) < 1):
                        ERROR(d.CLASS_DD, 1);
    if TYPE == MAJ_STRUC:
        VAR_LENGTH(ID_LOC) = STRUC_PTR;
        if STRUC_DIM == -1:
            if (SYT_FLAGS(ID_LOC) & PARM_FLAGS) != 0 and (not NAME_IMPLIED):
                STRUC_DIM = -ID_LOC;
            else: 
                ERROR(d.CLASS_DD, 8, SYT_NAME(ID_LOC));
                STRUC_DIM = 2;
        if STRUC_DIM != 0:
            SYT_ARRAY(ID_LOC) = STRUC_DIM;
            # IF A STRUCTURE'S SIZE IS NOT AN * THEN CHECK IF THE TOTAL
            # NUMBER OF ELEMENTS IN A MAJOR STRUCTURE IS GREATER THAN
            # 32767 OR LESS THAN 1. IF IT IS THEN GENERATE A DD11 ERROR.
            if STRUC_DIM > 0:
                if (ICQ_TERMp(ID_LOC) * SYT_ARRAY(ID_LOC) > ARRAY_DIM_LIM) \
                        or (ICQ_TERMp(ID_LOC) * SYT_ARRAY(ID_LOC) < 1):
                    ERROR(d.CLASS_DD, 11);
        elif (ICQ_TERMp(ID_LOC) > ARRAY_DIM_LIM) or \
                (ICQ_TERMp(ID_LOC) < 1):
            ERROR(d.CLASS_DD, 11);
    elif TYPE == TASK_LABEL or TYPE == PROG_LABEL:
        SYT_FLAGS(ID_LOC) = SYT_FLAGS(ID_LOC) | LATCHED_FLAG;
    HALMAT_INIT_CONST();
    for I in range(0, FACTOR_LIM + 1):
        g.TYPEf(I, 0);
    
