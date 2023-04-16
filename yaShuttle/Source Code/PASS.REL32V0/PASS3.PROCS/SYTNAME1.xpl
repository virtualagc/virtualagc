 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SYTNAME1.xpl
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
 /* PROCEDURE NAME:  SYT_NAME1                                              */
 /* MEMBER NAME:     SYTNAME1                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          X72                                                            */
 /* CALLED BY:                                                              */
 /*          EMIT_KEY_SDF_INFO                                              */
 /***************************************************************************/
                                                                                00139780
                                                                                00139800
                                                                                00139802
 /* INCLUDE VMEM ROUTINES:  $%VMEM3A  */                                        00139804
 /* ROUTINE TO GIVE SYMBOLIC NAME (28 CHARS) FOR HAL VARIABLE */                00139900
                                                                                00140000
SYT_NAME1:                                                                      00140100
   PROCEDURE(PTR) CHARACTER;                                                    00140200
      DECLARE (PTR, K) FIXED;                                                   00140300
      K = LENGTH(SYT_NAME(PTR));                                                00140400
      IF K >= 28 THEN RETURN SUBSTR(SYT_NAME(PTR), 0, 28);                      00140500
      ELSE RETURN SYT_NAME(PTR) || SUBSTR(X72, 0, 28-K);                        00140600
   END SYT_NAME1;                                                               00140700
