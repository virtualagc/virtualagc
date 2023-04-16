 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   REMUNDIE.xpl
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
 /* PROCEDURE NAME:  REM_UNDIES                                             */
 /* MEMBER NAME:     REMUNDIE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*       CHARACTER                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*       HAL_NAME          CHARACTER                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*       TEMP_STRING       CHARACTER                                       */
 /*       UNDERSCORE        CHARACTER                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       WORK1                                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       CHAR_INDEX                                                        */
 /* CALLED BY:                                                              */
 /*                                                                         */
 /*       PROGNAME                                                          */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> REM_UNDIES <==                                                      */
 /*     ==> CHAR_INDEX                                                      */
 /***************************************************************************/
 /*     REVISION HISTORY                                                    */
 /*                                                                         */
 /*  DATE    NAME  RLS  CR/DR #  DESCRIPTION                                */
 /*                                                                         */
 /* 02/18/92 ADM   7V0  CR11114  MERGE BFS/PASS COMPILERS WITH DR FIXES     */
 /*                                                                         */
 /***************************************************************************/
   /* SUBROUTINE TO REMOVE UNDERSCORES FROM A HAL/S BLOCK NAME */               00874600
REM_UNDIES:                                                                     00874650
   PROCEDURE(HAL_NAME) CHARACTER;                                               00874700
                                                                                00874750
      DECLARE HAL_NAME CHARACTER;                                               00874800
      DECLARE TEMP_STRING CHARACTER;                                            00874850
      DECLARE UNDERSCORE CHARACTER INITIAL('_');                                00874900
                                                                                00874950
      TEMP_STRING = HAL_NAME;                                                   00875000
      WORK1 = CHAR_INDEX(TEMP_STRING, UNDERSCORE);                              00875050
                                                                                00875100
      DO WHILE WORK1 > 0;                                                       00875150
         TEMP_STRING = SUBSTR(TEMP_STRING, 0, WORK1) ||                         00875200
            SUBSTR(TEMP_STRING, WORK1 + 1);                                     00875250
         WORK1 = CHAR_INDEX(TEMP_STRING, UNDERSCORE);                           00875300
      END;                                                                      00875350
                                                                                00875400
      RETURN TEMP_STRING;                                                       00875450
                                                                                00875500
   END REM_UNDIES;                                                              00875550
