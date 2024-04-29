 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SDFNAME.xpl
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
 /* PROCEDURE NAME:  SDF_NAME                                               */
 /* MEMBER NAME:     SDFNAME                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          ENTRY             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMPSTRING        CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          X10                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          IX1                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHAR_INDEX                                                     */
 /* CALLED BY:                                                              */
 /*          OUTPUT_SDF                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SDF_NAME <==                                                        */
 /*     ==> CHAR_INDEX                                                      */
 /***************************************************************************/
                                                                                00145600
 /*  SUBROUTINE FOR GENERATING SDF NAMES  */                                    00145700
SDF_NAME:                                                                       00145800
   PROCEDURE (ENTRY) CHARACTER;                                                 00145900
      DECLARE ENTRY BIT(16);                                                    00146000
      DECLARE TEMPSTRING CHARACTER;                                             00146100
      TEMPSTRING = SYT_NAME(ENTRY);                                             00146200
      ENTRY=CHAR_INDEX(TEMPSTRING,'_');                                         00146300
      DO WHILE ENTRY>0;                                                         00146400
         TEMPSTRING=SUBSTR(TEMPSTRING,0,ENTRY)||SUBSTR(TEMPSTRING,ENTRY+1);     00146500
         ENTRY=CHAR_INDEX(TEMPSTRING,'_');                                      00146600
      END;                                                                      00146700
      IX1=LENGTH(TEMPSTRING);                                                   00146800
      IF IX1 >= 6 THEN TEMPSTRING = SUBSTR(TEMPSTRING, 0, 6);                   00146900
      ELSE TEMPSTRING = TEMPSTRING || SUBSTR(X10, 0, 6-IX1);                    00147000
      RETURN '##' || TEMPSTRING;                                                00147100
   END SDF_NAME;                                                                00147200
