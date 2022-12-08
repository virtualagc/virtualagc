 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MAKEINCL.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
MAKE_INCL_CELL:                                                                 00000100
PROCEDURE(NAME, FLAGS, REV_CAT);                                                00000200
   /* MAKE AN ENTRY IN THE VMEM INCLUDE CELL CHAIN */                           00000300
                                                                                00000400
   DECLARE NAME CHARACTER,                                                      00000500
           FLAGS BIT(8),                                                        00000600
           REV_CAT FIXED;  /* REVISION/ CATENATION NUMBER FOR PDS */            00000700
   DECLARE INCLUDE_CELL_PTR FIXED,                                              00000800
           #INCL_CELLS BIT(16);                                                 00000900
   BASED NODE_F FIXED, NODE_H BIT(16);                                          00001000
   INCLUDE_CELL_PTR = GET_CELL(28, ADDR(NODE_F), MODF);                         00001100
   #INCL_CELLS = #INCL_CELLS + 1;                                               00001200
   NODE_F(0) = INCLUDE_LIST_HEAD;                                               00001300
   INCLUDE_LIST_HEAD = INCLUDE_CELL_PTR;                                        00001400
   COREWORD(ADDR(NODE_H)) = VMEM_LOC_ADDR;                                      00001500
   NODE_H(12) = #INCL_CELLS;                                                    00001600
   CALL MOVE(8, NAME, VMEM_LOC_ADDR + 4);                                       00001700
   NODE_F(3) = REV_CAT;                                                         00001800
   IF SRN_PRESENT THEN CALL MOVE(6, SRN, VMEM_LOC_ADDR + 18);                   00001900
   NODE_H(8) = SHL(FLAGS, 8);                                                   00002000
   RETURN;                                                                      00002100
END MAKE_INCL_CELL;                                                             00002200
