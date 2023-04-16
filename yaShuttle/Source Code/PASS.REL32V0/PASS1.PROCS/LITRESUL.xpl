 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LITRESUL.xpl
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
 /* PROCEDURE NAME:  LIT_RESULT_TYPE                                        */
 /* MEMBER NAME:     LITRESUL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          CONST_DW                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /*          FOR_DW                                                         */
 /*          INT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00849400
LIT_RESULT_TYPE:                                                                00849500
   PROCEDURE (LOC1,LOC2);                                                       00849600
      DECLARE (LOC1,LOC2) BIT(16);                                              00849700
      CALL INLINE("58",1,0,DW_AD);               /* L   1,DW_AD     */          00849800
      CALL INLINE("68",0,0,1,0);                 /* LD  0,0(0,1)    */          00849900
      CALL INLINE("20",0,0);                     /* LPDR 0,0        */          00850000
      CALL INLINE("58",2,0,ADDR_FIXED_LIMIT);    /* L 2,ADDR_FIXED_LIMIT */     00850100
      CALL INLINE("6B",0,0,2,0);                 /* SD  0,0(0,2)    */          00850200
      CALL INLINE("60",0,0,1,8);                 /* STD 0,8(0,1)    */          00850300
      IF PSEUDO_TYPE(PTR(LOC1))=INT_TYPE THEN                                   00850400
         IF PSEUDO_TYPE(PTR(LOC2))=INT_TYPE THEN                                00850500
         IF DW(2)<=0 THEN RETURN INT_TYPE;                                      00850600
      RETURN SCALAR_TYPE;                                                       00850700
   END LIT_RESULT_TYPE;                                                         00850800
