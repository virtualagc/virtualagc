 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INDIRECT.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  INDIRECT                                               */
 /* MEMBER NAME:     INDIRECT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          OP                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          IND_CALL_LAB                                                   */
 /*          SYM_PTR                                                        */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /* CALLED BY:                                                              */
 /*          ADD_SMRK_NODE                                                  */
 /*          GET_P_F_INV_CELL                                               */
 /***************************************************************************/
 /* ROUTINE TO HANDLE INDIRECT CALLS */                                         00138802
INDIRECT:                                                                       00138803
 /* TRACES BACK THROUGH POINTERS TO ACTUAL SYMBOL TABLE NUMBER FOR              00138804
         OPERAND */                                                             00138805
   PROCEDURE (OP) BIT(16);                                                      00138806
      DECLARE OP BIT(16);                                                       00138807
      DO WHILE SYT_TYPE(OP) = IND_CALL_LAB;                                     00138808
         OP = SYT_PTR(OP);                                                      00138809
      END;                                                                      00138810
      RETURN OP;                                                                00138811
   END INDIRECT;                                                                00138812
