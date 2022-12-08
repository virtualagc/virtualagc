 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CSTACKDU.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  C_STACK_DUMP                                           */
 /* MEMBER NAME:     CSTACKDU                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADJACENT                                                       */
 /*          AR_DENESTABLE                                                  */
 /*          AR_DIMS                                                        */
 /*          AR_SIZE                                                        */
 /*          ASSIGN                                                         */
 /*          IN_AR                                                          */
 /*          IN_VM                                                          */
 /*          LOOP_END                                                       */
 /*          LOOP_HEAD                                                      */
 /*          LOOP_STACKSIZE                                                 */
 /*          NESTED_VM                                                      */
 /*          REF_TO_DSUB                                                    */
 /*          STACKED_VDLPS                                                  */
 /*          STRUCTURE_COPIES                                               */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORMAT                                                         */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> C_STACK_DUMP <==                                                    */
 /*     ==> FORMAT                                                          */
 /***************************************************************************/
                                                                                01894010
                                                                                01894020
                                                                                01894030
 /* ROUTINES FOR LOOP MANGLING */                                               01894040
                                                                                01894050
                                                                                01894060
 /* DUMPS VARIABLES USED IN LOOP COMBINING AND DENESTING*/                      01894070
C_STACK_DUMP:                                                                   01894080
   PROCEDURE;                                                                   01894090
      DECLARE K BIT(16);                                                        01894100
      OUTPUT = '   K LOOP_HEAD LOOP_END AR_SIZE ADJACENT REF_TO_DSUB ASSIGN';   01894110
      K = LOOP_STACKSIZE;                                                       01894120
      DO WHILE K >= 0;                                                          01894130
         IF LOOP_HEAD(K) ^= 0 THEN OUTPUT =                                     01894140
            FORMAT(K,4)||                                                       01894150
            FORMAT(LOOP_HEAD(K),10)||                                           01894160
            FORMAT(LOOP_END (K),9)||                                            01894170
            FORMAT(AR_SIZE(K),8)||                                              01894180
            FORMAT(ADJACENT(K),9)||                                             01894190
            FORMAT(REF_TO_DSUB(K),12)||                                         01894200
            FORMAT(ASSIGN(K),7);                                                01894210
         K = K-1;                                                               01894220
      END;                                                                      01894230
                                                                                01894240
      OUTPUT = '';                                                              01894250
      OUTPUT = '   AR_DIMS='||AR_DIMS||', NESTED_VM='||NESTED_VM                01894260
         ||', IN_VM='||IN_VM||', IN_AR='||IN_AR||', AR_DENESTABLE='             01894270
         ||AR_DENESTABLE||', STRUCTURE_COPIES='||STRUCTURE_COPIES               01894280
         ||', STACKED_VDLPS='||STACKED_VDLPS;                                   01894290
      OUTPUT = '';                                                              01894300
      OUTPUT = '';                                                              01894310
   END C_STACK_DUMP;                                                            01894320
