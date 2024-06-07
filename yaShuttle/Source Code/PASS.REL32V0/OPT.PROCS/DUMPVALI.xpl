 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DUMPVALI.xpl
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
 /* PROCEDURE NAME:  DUMP_VALIDS                                            */
 /* MEMBER NAME:     DUMPVALI                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          COMM                                                           */
 /*          FOR                                                            */
 /*          LEVEL                                                          */
 /*          REL                                                            */
 /*          SYM_NAME                                                       */
 /*          SYM_REL                                                        */
 /*          SYM_SHRINK                                                     */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CATALOG_PTR                                                    */
 /*          FORMAT                                                         */
 /*          VALIDITY                                                       */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DUMP_VALIDS <==                                                     */
 /*     ==> FORMAT                                                          */
 /*     ==> CATALOG_PTR                                                     */
 /*     ==> VALIDITY                                                        */
 /***************************************************************************/
                                                                                01425000
                                                                                01425010
 /* PRINTS VALID VARS AT THIS LEVEL*/                                           01425020
DUMP_VALIDS:                                                                    01425030
   PROCEDURE;                                                                   01425040
      DECLARE K BIT(16);                                                        01425050
      OUTPUT = '';                                                              01425060
      OUTPUT = 'SYT# REL# CATALOG_PTR    VARIABLE NAME FOR VALID VARS, '        01425070
         ||  'LEVEL =' || LEVEL || ', BLOCK# =' || BLOCK#;                      01425080
      DO FOR K = 2 TO COMM(10);                                                 01425090
         IF VALIDITY(K) THEN                                                    01425100
            OUTPUT = FORMAT(K,4)                                                01425110
            || FORMAT(REL(K),5)                                                 01425120
            || FORMAT(CATALOG_PTR(K),12)                                        01425130
            || '    ' || SYT_NAME(K);                                           01425140
      END;                                                                      01425150
   END DUMP_VALIDS;                                                             01425160
