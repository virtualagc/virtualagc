 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PREPLITE.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  PREP_LITERAL                                           */
 /* MEMBER NAME:     PREPLITE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NOT_EXACT         LABEL                                        */
 /*          SAVE_NUMBER       LABEL                                        */
 /*          TEMP1             FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          ADDR_FIXER                                                     */
 /*          CPD_NUMBER                                                     */
 /*          EXP_OVERFLOW                                                   */
 /*          TABLE_ADDR                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          TOKEN                                                          */
 /*          SYT_INDEX                                                      */
 /*          VALUE                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SAVE_LITERAL                                                   */
 /* CALLED BY:                                                              */
 /*          SCAN                                                           */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PREP_LITERAL <==                                                    */
 /*     ==> SAVE_LITERAL                                                    */
 /***************************************************************************/
                                                                                00667300
                                                                                00667400
                                                                                00671600
                                                                                00671700
PREP_LITERAL:                                                                   00671800
   PROCEDURE;                                                                   00671900
      DECLARE TEMP1 FIXED;                                                      00672000
      IF EXP_OVERFLOW THEN DO;                                                  00672100
         CALL INLINE("58",1,0,ADDR_FIXED_LIMIT); /* L 1,ADDR_FIXED_LIMIT*/      00672200
         CALL INLINE("68",6,0,1,0);       /* LD 6,0(0,1)   */                   00672300
NOT_EXACT:                                                                      00672400
         VALUE = -1;                                                            00672500
         TOKEN = CPD_NUMBER;                                                    00672600
         GO TO SAVE_NUMBER;                                                     00672700
      END;                                                                      00672800
      TEMP1 = ADDR(NOT_EXACT);                                                  00672900
      CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);       /* L   1,ADDR_LIMIT */   00673000
      CALL INLINE("58", 2, 0, TEMP1);                  /* L   2,TEMP1      */   00673100
      CALL INLINE("28", 6, 0);                         /* LDR 6,0          */   00673200
      CALL INLINE("20", 0, 0);                         /* LPDR 0,0         */   00673300
      CALL INLINE("69", 0, 0, 1, 0);                   /* CD  0,0(,1)      */   00673400
      CALL INLINE("07", 2, 2);                         /* BHR 2            */   00673500
      CALL INLINE("2B", 4, 4);                         /* SDR 4,4          */   00673600
      CALL INLINE("28", 2, 0);                         /* LDR 2,0          */   00673700
      CALL INLINE("58", 1, 0, ADDR_FIXER);             /* L   1,ADDR_FIXER */   00673800
      CALL INLINE("6E", 0, 0, 1, 0);                   /* AW  0,0(,1)      */   00673900
      CALL INLINE("58",1,0,TABLE_ADDR);                                         00674000
      CALL INLINE("60", 0, 0, 1, 0);                   /* STD 0,0(,1)      */   00674100
      CALL INLINE("2A", 0, 4);                         /* ADR 0,4          */   00674200
      CALL INLINE("2B", 2, 0);                         /* SDR 2,0          */   00674300
      CALL INLINE("07", 7, 2);                         /* BNER 2           */   00674400
      CALL INLINE("58", 2, 0, 1, 4);                   /* L   2,4(,1)      */   00674500
      CALL INLINE("50", 2, 0, VALUE);                  /* ST  2,VALUE      */   00674600
SAVE_NUMBER:                                                                    00674700
      CALL INLINE("58",1,0,TABLE_ADDR);                                         00674800
      CALL INLINE("60",6,0,1,0);          /* STD 6,0(0,1)   */                  00674900
      SYT_INDEX=SAVE_LITERAL(1,TABLE_ADDR);                                     00675000
   END PREP_LITERAL;                                                            00675100
