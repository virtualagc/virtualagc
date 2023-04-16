 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMDEC19.xpl
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
 
 /***************************************************************************/
 /* MEMBER NAME:     COMDEC19                                               */
 /* PURPOSE:         COMMON DECLARATIONS                                    */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 05/24/93 RAH  25V0  DR105709 ADDED DEFINE STATEMENTS FOR                */
 /*                9V0           REPLACE_STMT_TYPE AND STRUC_STMT_TYPE      */
 /*                                                                         */
 /***************************************************************************/
   /*********************************************                               0000000
      COMMON DECLARATIONS FOR REL19 1.7                                         0000000
      LAST MODIFIED ON 11/4/80 AT 13:49:55                                      0000000
    *********************************************/                              0000000
   /* STMT_DECL DESCRIBES WHAT A STATEMENT DECLARATION CELL LOOKS LIKE          0000000
      SEE     . IT SHOULD BE ACCESSED ONLY WITH LOCATE_STMT_DECL_CELL(PTR,FLAGS)0000000
      BECAUSE HALMAT_CELL_PTR IS REALLY NODE_F(-1) IF ONE HAD CALLED            0000000
      LOCATE(PTR,ADDR(NODE_F),FLAGS) (BASED NODE_F FIXED). */                   0000000
BASED STMT_DECL_CELL RECORD:                                                    0000000
      HALMAT_CELL_PTR FIXED,                                                    0000000
      NEXT_STMT_PTR   FIXED,                                                    0000000
      PREV_STMT_PTR   FIXED,                                                    0000000
      NAME_INIT_PTR   FIXED,                                                    0000000
      FILLER(2)       FIXED,                                                    0000000
      FILL16          BIT(16),                                                  0000000
      STMT_TYPE       BIT(16),                                                  0000000
      STMT_NO         BIT(16),                                                  0000000
      BLOCK_NO        BIT(16),                                                  0000000
      END;                                                                      0000000
DECLARE LOCATE_STMT_DECL_CELL(2) LITERALLY                                      0000000
        'DO; CALL LOCATE(%1%),ADDR(STMT_DECL_CELL),%2%);                        0000000
         COREWORD(ADDR(STMT_DECL_CELL))=COREWORD(ADDR(STMT_DECL_CELL)-4;END;';  0000000
DECLARE AS LITERALLY 'LITERALLY',                                               0000000
        DEFINE AS 'DECLARE';                                                    0000000
DEFINE DECL_STMT_TYPE AS '"15"',                                                0000000
       EQUATE_TYPE AS '"17"',                                                   0000000
       TEMP_TYPE AS '"18"';                                                     0000000
/************ DR105709, RAH, 4/23/92 **********************************/
DEFINE REPLACE_STMT_TYPE AS '"19"',                                             0000000
       STRUC_STMT_TYPE AS '"1A"';                                               0000000
/************ END DR105709 ********************************************/
DEFINE NILL AS '-1'; /* DEFAULT NULL POINTER VALUE FOR VMEM */                  0000000
DEFINE POINTER_PREFIX AS '-1';                                                  0000000
DEFINE CLOSE AS 'END';                                                          0000000
DEFINE XREC_WORD AS '"00000020"';/* TO INDICATE THE END OF A HALMAT             0000000
                                            CELL */                             0000000
