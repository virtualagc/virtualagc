 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LOOPOPER.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  LOOP_OPERANDS                                          */
 /* MEMBER NAME:     LOOPOPER                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OR                                                             */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CLASS                                                      */
 /*          LAST_OPERAND                                                   */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /*          PUT_VM_INLINE                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> LOOP_OPERANDS <==                                                   */
 /*     ==> GET_CLASS                                                       */
 /*     ==> LAST_OPERAND                                                    */
 /***************************************************************************/
                                                                                01496300
                                                                                01496310
 /* RETURNS LAST_OPERAND(PTR) UNLESS MSPR,MSDV,VSPR,OR VSDV--IN WHICH CASE      01496320
      RETURNS PTR + 1   */                                                      01496330
LOOP_OPERANDS:                                                                  01496340
   PROCEDURE(PTR) BIT(16);                                                      01496350
      DECLARE (PTR,TEMP) BIT(16);                                               01496360
      TEMP = GET_CLASS(PTR);                                                    01496370
      IF TEMP = 3 OR TEMP = 4 THEN                                              01496380
         IF (SHR(OPR(PTR),9) & "7") = "5"                                       01496390
         THEN RETURN PTR + 1;                                                   01496400
                                                                                01496410
      RETURN LAST_OPERAND(PTR);                                                 01496420
   END LOOP_OPERANDS;                                                           01496430
