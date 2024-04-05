 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PTRFIX.xpl
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
 /* PROCEDURE NAME:  PTR_FIX                                                */
 /* MEMBER NAME:     PTRFIX                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PAGE              BIT(16)                                      */
 /*          OFFSET            BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PAGE_SIZE                                                      */
 /* CALLED BY:                                                              */
 /*          INITIALIZE                                                     */
 /***************************************************************************/
                                                                                00151800
 /* ROUTINE TO ADJUST AN SDF POINTER SO THAT THE OFFSET IS POSITIVE AND */      00156100
 /* LESS THAN THE BLOCK SIZE */                                                 00156200
                                                                                00156300
PTR_FIX:                                                                        00156400
   PROCEDURE (PTR) FIXED;                                                       00156500
      DECLARE PTR FIXED,                                                        00156600
         (PAGE,OFFSET) BIT(16);                                                 00156700
      PAGE = SHR(PTR,16) & "FFFF";                                              00156800
      OFFSET = PTR & "FFFF";                                                    00156900
      IF OFFSET >= PAGE_SIZE THEN DO;                                           00157000
         PAGE = PAGE + OFFSET/PAGE_SIZE;                                        00157100
         OFFSET = OFFSET MOD PAGE_SIZE;                                         00157200
      END;                                                                      00157300
      RETURN (SHL(PAGE,16) + OFFSET);                                           00157400
   END PTR_FIX;                                                                 00157500
