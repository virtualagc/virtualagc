 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NAMESIZE.xpl
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
/* PROCEDURE NAME:  NAMESIZE                                               */
/* MEMBER NAME:     NAMESIZE                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          OP                BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          REMOTE_FLAG                                                    */
/*          SYM_FLAGS                                                      */
/*          SYM_TAB                                                        */
/*          SYT_FLAGS                                                      */
/* CALLED BY:                                                              */
/*          INITIALISE                                                     */
/*          GENERATE                                                       */
/***************************************************************************/
                                                                                  874510
 /* ROUTINE TO DETERMINE ALIGNMENT AND SPACE REQUIRED FOR NAME VARIABLE */        874520
NAMESIZE:                                                                         874530
   PROCEDURE(OP) BIT(16);                                                         874540
      DECLARE OP BIT(16);                                                         874550
      IF (SYT_FLAGS(OP) & REMOTE_FLAG) = 0 THEN RETURN 1;                         874560
      ELSE RETURN 2;                                                              874570
   END NAMESIZE;                                                                  874580
