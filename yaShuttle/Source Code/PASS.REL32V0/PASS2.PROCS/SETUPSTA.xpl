 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETUPSTA.xpl
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
/* PROCEDURE NAME:  SETUP_STACK                                            */
/* MEMBER NAME:     SETUPSTA                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          I                 BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          STACK_SIZE                                                     */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          STACK_PTR                                                      */
/* CALLED BY:                                                              */
/*          RELEASETEMP                                                    */
/*          INITIALISE                                                     */
/***************************************************************************/
                                                                                00681500
 /* ROUTINE TO SET UP OPERAND STACK ENTRY  */                                   00682000
SETUP_STACK:                                                                    00682500
   PROCEDURE;                                                                   00683000
      DECLARE I BIT(16);                                                        00683500
      DO I = 0 TO STACK_SIZE-1;                                                 00684000
         STACK_PTR(I) = I+1;                                                    00684500
      END;                                                                      00685000
      STACK_PTR(STACK_SIZE) = 0;                                                00685500
   END SETUP_STACK;                                                             00686000
