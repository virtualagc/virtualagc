#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   STABHDR.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  STAB_HDR                                               */
 /* MEMBER NAME:     STABHDR                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL_PTR          FIXED                                        */
 /*          CELLSIZE          BIT(16)                                      */
 /*          FIRST_CALL        BIT(8)                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          NODE_F            FIXED                                        */
 /*          NODE_H            BIT(16)                                      */
 /*          SRN_INX           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_PRESENT                                                   */
 /*          BLOCK_SYTREF                                                   */
 /*          FALSE                                                          */
 /*          HMAT_OPT                                                       */
 /*          INCL_SRN                                                       */
 /*          MODF                                                           */
 /*          NEST                                                           */
 /*          NILL                                                           */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          SRN                                                            */
 /*          SRN_COUNT                                                      */
 /*          SRN_PRESENT                                                    */
 /*          STAB_MARK                                                      */
 /*          STAB_STACK                                                     */
 /*          STAB2_MARK                                                     */
 /*          STAB2_STACK                                                    */
 /*          STMT_DATA_HEAD                                                 */
 /*          STMT_NUM                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMM                                                           */
 /*          LAST_STAB_CELL_PTR                                             */
 /*          S                                                              */
 /*          STAB_STACKTOP                                                  */
 /*          STAB2_STACKTOP                                                 */
 /*          STMT_TYPE                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /*          LOCATE                                                         */
 /*          PTR_LOCATE                                                     */
 /* CALLED BY:                                                              */
 /*          EMIT_SMRK                                                      */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


class cSTAB_HDR:

    def __init__(self):
        self.FIRST_CALL = 1
        self.NODE_H = []
        self.NODE_F = []


lSTAB_HDR = cSTAB_HDR()


def STAB_HDR():
    
    '''
    
    # Locals CELLSIZE, SRN_INX, I, J, CELL_PTR don't need to be persistent.
    l = lSTAB_HDR
    
    CELLSIZE = 32;
    IF ADDR_PRESENT THEN CELLSIZE=CELLSIZE+16;
    SRN_INX = CELLSIZE;
    # ADD SPACE FOR HALMAT CELL PTR
    IF HMAT_OPT
       THEN CELLSIZE = CELLSIZE+4;
    IF SRN_PRESENT THEN
       IF SRN_COUNT(2) > 0 THEN CELLSIZE = CELLSIZE + 17;
    ELSE CELLSIZE = CELLSIZE + 9;
    CELL_PTR, NODE_H = GET_CELL(CELLSIZE,RESV+MODF);
    # KEEP OFFSETS THE SAME; HALMAT CELL PTR IS AT NODE_F(-1) ASSUMING THAT
    #        NODE_F POINTS AT THE CELL (ONLY IF HMAT_OPT) */
    IF HMAT_OPT
       THEN DO;
       CELL_PTR = CELL_PTR+4;
       COREWORD(ADDR(NODE_H))=COREWORD(ADDR(NODE_H))+4;
    END;
    IF l.FIRST_CALL THEN DO;
       STMT_DATA_HEAD = CELL_PTR;
       l.FIRST_CALL = FALSE;
    END;
    IF LAST_STAB_CELL_PTR ^= -1 THEN DO;
       CALL LOCATE(LAST_STAB_CELL_PTR,ADDR(NODE_F),MODF);
       NODE_F(0) = CELL_PTR;
    END;
    COREWORD(ADDR(NODE_F)) = ADDR(NODE_H(0));
    IF HMAT_OPT THEN NODE_F(-1) = NILL;
    NODE_F(0) = NILL;
    NODE_F(1) = LAST_STAB_CELL_PTR;
    NODE_H(12) = 0;
    NODE_H(13) = STMT_TYPE;
    NODE_H(14) = STMT_NUM;
    NODE_H(15) = BLOCK_SYTREF(NEST);
    IF SRN_PRESENT THEN DO;
       S = SRN(2);
       CALL INLINE("48",1,0,SRN_INX);
       CALL INLINE("5A",1,0,NODE_H);
       CALL INLINE("58",2,0,S);
       CALL INLINE("D2",0,7,1,0,2,0);
       NODE_H(SHR(SRN_INX,1)+4) = SRN_COUNT(2);
       IF SRN_COUNT(2) > 0 THEN DO;
          S = INCL_SRN(2);
          SRN_INX = SRN_INX + 10;
          CALL INLINE("48", 1, 0, SRN_INX);
          CALL INLINE("5A", 1, 0, NODE_H);
          CALL INLINE("58", 2, 0, S);
          CALL INLINE("D2", 0, 7, 1, 0, 2, 0);
          NODE_H(13) = NODE_H(13) | "8000";
       END;
    END;
    CELLSIZE = STAB2_STACKTOP - STAB2_MARK;
    IF CELLSIZE > 0 THEN DO;
       NODE_F(2), NODE_H = GET_CELL(SHL(CELLSIZE,1)+2,MODF);
       NODE_H(0) = CELLSIZE;
       DO I = STAB2_MARK + 1 TO STAB2_STACKTOP;
          J = I - STAB2_MARK;
          NODE_H(J) = STAB2_STACK(I);
       END;
    END;
    ELSE NODE_F(2) = -1;
    CELLSIZE = STAB_STACKTOP - STAB_MARK;
    IF CELLSIZE > 0 THEN DO;
       NODE_F(3), NODE_H = GET_CELL(SHL(CELLSIZE,1)+2,MODF);
       NODE_H(0) = CELLSIZE;
       DO I = STAB_MARK+1 TO STAB_STACKTOP;
          J = I - STAB_MARK;
          NODE_H(J) = STAB_STACK(I);
       END;
    END;
    ELSE NODE_F(3) = -1;
    CALL PTR_LOCATE(CELL_PTR,RELS);
    LAST_STAB_CELL_PTR = CELL_PTR;
    STAB_STACKTOP =STAB_MARK;
    STAB2_STACKTOP = STAB2_MARK;
    STMT_TYPE=0;

    '''
    
