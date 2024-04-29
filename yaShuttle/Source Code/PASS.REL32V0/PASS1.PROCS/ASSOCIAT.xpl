 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ASSOCIAT.xpl
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
 /* PROCEDURE NAME:  ASSOCIATE                                              */
 /* MEMBER NAME:     ASSOCIAT                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          TAG               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 FIXED                                        */
 /*          ARR_STRUC_CHECK   LABEL                                        */
 /*          J                 FIXED                                        */
 /*          K                 FIXED                                        */
 /*          L                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ASSIGN_ARG_LIST                                                */
 /*          CLASS_PS                                                       */
 /*          CLASS_SV                                                       */
 /*          CLASS_UI                                                       */
 /*          DELAY_CONTEXT_CHECK                                            */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          LEFT_BRACE_FLAG                                                */
 /*          LEFT_BRACKET_FLAG                                              */
 /*          LOCK_FLAG                                                      */
 /*          MP                                                             */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          READ_ACCESS_FLAG                                               */
 /*          RIGHT_BRACE_FLAG                                               */
 /*          RIGHT_BRACKET_FLAG                                             */
 /*          STACK_PTR                                                      */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_FLAGS                                                      */
 /*          TEMPL_NAME                                                     */
 /*          UPDATE_BLOCK_LEVEL                                             */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ARRAYNESS_STACK                                                */
 /*          AS_PTR                                                         */
 /*          EXT_P                                                          */
 /*          GRAMMAR_FLAGS                                                  */
 /*          TOKEN_FLAGS                                                    */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_FIX_POPTAG                                              */
 /*          SAVE_ARRAYNESS                                                 */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ASSOCIATE <==                                                       */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> HALMAT_FIX_POPTAG                                               */
 /*     ==> SAVE_ARRAYNESS                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /***************************************************************************/
                                                                                01093100
                                                                                01093200
                                                                                01095500
                                                                                01095600
ASSOCIATE:                                                                      01095700
   PROCEDURE (TAG);                                                             01095800
      DECLARE TAG BIT(16) INITIAL(-1);                                          01095900
      DECLARE (I,J,K,L) FIXED;                                                  01096000
      IF FIXV(MP)=0 THEN I=FIXL(MP);                                            01096100
      ELSE I=FIXV(MP);                                                          01096200
      IF (SYT_FLAGS(I) & READ_ACCESS_FLAG) ^= 0 THEN                            01096300
         CALL ERROR(CLASS_PS, 9, VAR(MP));                                      01096400
      IF (SYT_FLAGS(I) & LOCK_FLAG) ^= 0 THEN  /* LOCKED */                     01096500
         IF ^ASSIGN_ARG_LIST THEN                                               01096600
         IF UPDATE_BLOCK_LEVEL <= 0 THEN                                        01096700
         CALL ERROR(CLASS_UI, 1, VAR(MP));                                      01096800
      J=PSEUDO_TYPE(PTR(MP));                                                   01096900
      L = EXT_P(PTR(MP));  /* RHS OF TOKEN LIST */                              01097000
      IF J>TEMPL_NAME THEN GO TO ARR_STRUC_CHECK;                               01097100
      IF L >= 0 THEN DO;                                                        01097200
         I = TOKEN_FLAGS(L);                                                    01097300
         K = I & "1F";  /* IMPLIED TYPE */                                      01097400
         IF K = 7 THEN GO TO ARR_STRUC_CHECK;                                   01097500
         IF K >= 3 THEN                                                         01097600
            IF K <= 4 THEN                                                      01097700
            IF (J & "1F") ^= K THEN                                             01097800
            CALL ERROR(CLASS_SV, 2, VAR(MP));                                   01097900
         I = (I - K) | (J & "1F");  /* FINAL TYPE */                            01098000
         TOKEN_FLAGS(L) = I;  /* MARK GOES ON RIGTHMOST TOKEN */                01098100
      END;                                                                      01098200
ARR_STRUC_CHECK:                                                                01098300
      K = STACK_PTR(MP);                                                        01098400
      J=VAL_P(PTR(MP));                                                         01098500
      IF DELAY_CONTEXT_CHECK THEN IF SUBSCRIPT_LEVEL = 0 THEN DO;               01098600
         CALL SAVE_ARRAYNESS;                                                   01098700
         IF (J&"206")="202" THEN DO;                                            01098800
            AS_PTR=AS_PTR-1;                                                    01098900
            EXT_P(PTR(MP))=ARRAYNESS_STACK(AS_PTR);                             01099000
            IF TAG>=0 THEN CALL HALMAT_FIX_POPTAG(TAG,1);                       01099100
            J=J&"DFFE";                                                         01099200
            ARRAYNESS_STACK(AS_PTR)=ARRAYNESS_STACK(AS_PTR+1)-1;                01099300
         END;                                                                   01099400
         ELSE DO;                                                               01099500
            EXT_P(PTR(MP))=0;                                                   01099600
            J=J&"FFFC";                                                         01099700
         END;                                                                   01099800
      END;                                                                      01099900
      IF J THEN DO;             /*  ARRAY MARKS NEEDED  */                      01100000
         GRAMMAR_FLAGS(K) = GRAMMAR_FLAGS(K) | LEFT_BRACKET_FLAG;               01100100
         GRAMMAR_FLAGS(L) = GRAMMAR_FLAGS(L) | RIGHT_BRACKET_FLAG;              01100200
      END;                                                                      01100300
      IF SHR(J,1) THEN DO;     /*  STRUCTURE MARKS NEEDED  */                   01100400
         GRAMMAR_FLAGS(K) = GRAMMAR_FLAGS(K) | LEFT_BRACE_FLAG;                 01100500
         GRAMMAR_FLAGS(L) = GRAMMAR_FLAGS(L) | RIGHT_BRACE_FLAG;                01100600
      END;                                                                      01100700
      TAG=-1;                                                                   01100800
      IF SHR(J,13) THEN VAL_P(PTR(MP))=J|"10";                                  01100900
   END ASSOCIATE;                                                               01101000
