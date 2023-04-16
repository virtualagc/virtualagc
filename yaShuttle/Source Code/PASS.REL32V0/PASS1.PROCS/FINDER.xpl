 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FINDER.xpl
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
 /* PROCEDURE NAME:  FINDER                                                 */
 /* MEMBER NAME:     FINDER                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          FILENO            BIT(16)                                      */
 /*          NAME              CHARACTER;                                   */
 /*          START             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FILENUM(2)        FIXED                                        */
 /*          FILENODD(2)       BIT(8)                                       */
 /*          I                 BIT(16)                                      */
 /*          MAXLIBFILES       MACRO                                        */
 /*          RETCODE           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          TRUE                                                           */
 /*          FALSE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INCLUDE_FILE#                                                  */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /*          EMIT_EXTERNAL                                                  */
 /***************************************************************************/
                                                                                00399500
FINDER:                                                                         00399505
   PROCEDURE(FILENO, NAME, START) BIT(1);                                       00399510
      DECLARE (FILENO, START, I, RETCODE) BIT(16), NAME CHARACTER;              00399515
      DECLARE MAXLIBFILES LITERALLY '2';                                        00399520
      DECLARE FILENUM(MAXLIBFILES) FIXED INITIAL("80000008", "4", "80000006"),  00399525
 /* SPECIFIES OUTPUT(8), INPUT(4), AND OUTPUT(6) ENTRIES */                     00399530
         FILENODD(MAXLIBFILES) BIT(1); /* TRUE IF DD STATEMENT MISSING */       00399535
      DO I = START TO MAXLIBFILES;                                              00399540
         IF ^FILENODD(I) THEN DO;                                               00399545
            CALL MONITOR(8, FILENO, FILENUM(I)); /* SET FILENO WITH NEW DDNAME*/00399550
            RETCODE = MONITOR(2, FILENO, NAME); /* FIND THE MEMBER */           00399555
            IF RETCODE = 0 THEN DO;                                             00399560
               INCLUDE_FILE# = FILENUM(I);                                      00399561
               RETURN FALSE;                                                    00399562
            END;                                                                00399563
            FILENODD(I) = SHR(RETCODE, 1);                                      00399565
         END;                                                                   00399570
      END;                                                                      00399575
      RETURN TRUE;                                                              00399580
   END FINDER;                                                                  00399585
