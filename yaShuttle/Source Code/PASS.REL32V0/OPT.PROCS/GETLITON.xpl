 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETLITON.xpl
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
 /* PROCEDURE NAME:  GET_LIT_ONE                                            */
 /* MEMBER NAME:     GETLITON                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          OLD_PTR           BIT(16)                                      */
 /*          ONE_PTR           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          DW                                                             */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PREVIOUS_CALL                                                  */
 /*          FOR_DW                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SAVE_LITERAL                                                   */
 /* CALLED BY:                                                              */
 /*          REARRANGE_HALMAT                                               */
 /*          STRIP_NODES                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_LIT_ONE <==                                                     */
 /*     ==> SAVE_LITERAL                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> GET_LITERAL                                                 */
 /***************************************************************************/
                                                                                00755000
 /* GETS LITERAL WITH VALUE 1 */                                                00756000
GET_LIT_ONE:                                                                    00757000
   PROCEDURE BIT(16);                                                           00758000
      DECLARE (OLD_PTR,ONE_PTR) BIT(16);                                        00759000
      IF PREVIOUS_CALL THEN RETURN OLD_PTR;                                     00760000
      ELSE DO;                                                                  00761000
         DW(5)="41100000";   /* DON'T HAVE TO PRESERVE DW(5) */                 00762000
         ONE_PTR = SAVE_LITERAL(5,0,0,1,1);                                     00763000
         OLD_PTR=ONE_PTR;                                                       00764000
         PREVIOUS_CALL=TRUE;                                                    00765000
         RETURN ONE_PTR;                                                        00766000
      END;                                                                      00767000
   END GET_LIT_ONE;                                                             00768000
