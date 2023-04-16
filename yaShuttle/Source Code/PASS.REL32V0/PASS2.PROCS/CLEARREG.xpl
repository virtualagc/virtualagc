 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CLEARREG.xpl
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
/* PROCEDURE NAME:  CLEAR_REGS                                             */
/* MEMBER NAME:     CLEARREG                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          I                 BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          REG_NUM                                                        */
/*          ASSEMBLER_CODE                                                 */
/*          TRUE                                                           */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          LASTRESULT                                                     */
/*          USAGE                                                          */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          SET_LINKREG                                                    */
/* CALLED BY:                                                              */
/*          RELEASETEMP                                                    */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> CLEAR_REGS <==                                                      */
/*     ==> SET_LINKREG                                                     */
/***************************************************************************/
                                                                                00692000
 /* SUBROUTINE TO RESET REGISTER CONTENT REMEMBERING  */                        00692500
CLEAR_REGS:                                                                     00693000
   PROCEDURE;                                                                   00693500
      DECLARE I BIT(16);                                                        00694000
      DO I = 0 TO REG_NUM;                                                      00694500
         IF ASSEMBLER_CODE THEN IF (USAGE(I)&(^TRUE)) ^= 0 THEN                 00695000
            OUTPUT='*** WARNING - REGISTER '||I||' HAD OUTSTANDING USAGE';      00695500
         USAGE(I) = 0;                                                          00696000
      END;                                                                      00696500
      CALL SET_LINKREG;                                                         00697000
      LASTRESULT = 0;                                                           00697500
   END CLEAR_REGS;                                                              00698000
