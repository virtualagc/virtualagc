 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MAKEFIXE.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  MAKE_FIXED_LIT                                         */
 /* MEMBER NAME:     MAKEFIXE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LIMIT_OK          LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          ADDR_FIXER                                                     */
 /*          ADDR_ROUNDER                                                   */
 /*          CONST_DW                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          ARITH_SHAPER_SUB                                               */
 /*          CHECK_SUBSCRIPT                                                */
 /*          ERROR_SUB                                                      */
 /*          PREC_SCALE                                                     */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MAKE_FIXED_LIT <==                                                  */
 /*     ==> GET_LITERAL                                                     */
 /***************************************************************************/
                                                                                00284200
                                                                                00284300
MAKE_FIXED_LIT:                                                                 00284400
   PROCEDURE(PTR);                                                              00284500
      DECLARE PTR FIXED;                                                        00284600
      DECLARE LIMIT_OK LABEL;                                                   00284700
      PTR=GET_LITERAL(PTR);                                                     00284800
      DW(0)=LIT2(PTR);                                                          00284900
      DW(1)=LIT3(PTR);                                                          00285000
      PTR=ADDR(LIMIT_OK);                                                       00285100
      CALL INLINE("58",3,0,DW_AD);             /*  L    3,DW_AD            */   00285200
      CALL INLINE("68",0,0,3,0);               /*  LD   0,0(0,3)           */   00285300
      CALL INLINE("20", 0, 0);                            /* LPDR 0,0         */00285400
      CALL INLINE("58", 1, 0, ADDR_ROUNDER);/* L   1,ADDR_ROUNDER         */    00285500
      CALL INLINE("6A", 0, 0, 1, 0);        /* AD  0,0(0,1)               */    00285600
      CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);/* L 1,ADDR_FIXED_LIMIT   */    00285700
      CALL INLINE("58",2,0,PTR);                   /*   L   2,  PTR   */        00285800
      CALL INLINE("69", 0, 0, 1, 0);        /* CD  0,0(0,1)               */    00285900
      CALL INLINE("07",12,2);                  /*  BNHR 2                  */   00286000
      CALL INLINE("68",0,0,1,0);               /*  LD   0,0(0,1)           */   00286100
LIMIT_OK:                                                                       00286200
      CALL INLINE("58", 1, 0, ADDR_FIXER);  /* L   1,ADDR_FIXER           */    00286300
      CALL INLINE("6E", 0, 0, 1, 0);        /* AW  0,0(0,1)               */    00286400
      CALL INLINE("60",0,0,3,8);                   /*  STD 0,8(0,3)   */        00286500
      IF SHR(DW(0),31) THEN RETURN -DW(3);                                      00286600
      RETURN DW(3);                                                             00286700
   END MAKE_FIXED_LIT;                                                          00286800
