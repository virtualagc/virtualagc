 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BOTTOM.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  BOTTOM                                                 */
 /* MEMBER NAME:     BOTTOM                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          ORIG              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          A_INX             BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          LOW               BIT(16)                                      */
 /*          OP_PTR            BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /*          TYPE              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          NODE                                                           */
 /*          OPR                                                            */
 /*          VAC                                                            */
 /*          XPT                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ADD                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OP                                                        */
 /*          HALMAT_FLAG                                                    */
 /*          NO_OPERANDS                                                    */
 /* CALLED BY:                                                              */
 /*          REARRANGE_HALMAT                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> BOTTOM <==                                                          */
 /*     ==> LAST_OP                                                         */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> HALMAT_FLAG                                                     */
 /*         ==> VAC_OR_XPT                                                  */
 /***************************************************************************/
                                                                                03089000
 /* FIND START OF LIMB WHICH JOINS TREE AT PTR*/                                03090000
BOTTOM:                                                                         03091000
   PROCEDURE(PTR,ORIG);                                                         03092000
      DECLARE (PTR, A_INX,LOW,TEMP,ORIG,I,TYPE,OP_PTR) BIT(16);                 03093000
      A_INX = 1;                                                                03094000
      LOW,ADD(1) = LAST_OP(PTR);                                                03095000
      DO WHILE A_INX ^= 0;                                                      03096000
         TEMP = ADD(A_INX);                                                     03097000
         A_INX = A_INX - 1;                                                     03098000
         IF TEMP < LOW THEN LOW = TEMP;                                         03099000
         DO FOR I = 1 TO NO_OPERANDS(TEMP);                                     03100000
            TYPE = SHR(OPR(TEMP + I),4) & "F";                                  03101000
            OP_PTR = SHR(OPR(TEMP + I),16);                                     03102000
            IF TYPE = VAC | TYPE = XPT THEN DO;                                 03103000
               IF HALMAT_FLAG(TEMP + I) THEN                                    03104000
                  OP_PTR = NODE(OP_PTR) & "FFFF";                               03105000
               IF OP_PTR > ORIG THEN DO;                                        03106000
                  A_INX = A_INX + 1;                                            03107000
                  ADD(A_INX) = LAST_OP(OP_PTR);                                 03108000
               END;                                                             03109000
            END;                                                                03110000
         END; /* DO FOR*/                                                       03111000
      END; /* DO WHILE*/                                                        03112000
      RETURN LOW;                                                               03113000
   END BOTTOM;                                                                  03114000
