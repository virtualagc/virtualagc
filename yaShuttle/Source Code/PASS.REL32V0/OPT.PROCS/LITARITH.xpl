 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LITARITH.xpl
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
 /* PROCEDURE NAME:  LIT_ARITHMETIC                                         */
 /* MEMBER NAME:     LITARITH                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FLAG              BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          CLASS_BI                                                       */
 /*          TRUE                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /* CALLED BY:                                                              */
 /*          COMBINED_LITERALS                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> LIT_ARITHMETIC <==                                                  */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /***************************************************************************/
                                                                                00769000
                                                                                00770000
 /* PERFORMS MONITOR CALL TO DO LITERAL ARITHMETIC */                           00771000
 /* ARG1=DW,DW(1)   ARG2=DW(2),DW(3)    ANS=DW,DW(1)  */                        00772000
LIT_ARITHMETIC:                                                                 00773000
   PROCEDURE(MODE) BIT(8);                                                      00774000
      DECLARE MODE BIT(16),FLAG BIT(8);                                         00775000
      IF MONITOR(9,MODE) THEN DO;                                               00776000
         DO CASE MODE-1;                                                        00777000
            CALL ERRORS (CLASS_BI, 300);                                        00778000
            CALL ERRORS (CLASS_BI, 301);                                        00778010
            CALL ERRORS (CLASS_BI, 302);                                        00778020
            CALL ERRORS (CLASS_BI, 303);                                        00778030
         END;                                                                   00782000
         FLAG=TRUE;                                                             00783000
      END;                                                                      00784000
      ELSE FLAG=FALSE;                                                          00785000
      RETURN FLAG;                                                              00786000
   END LIT_ARITHMETIC;                                                          00787000
