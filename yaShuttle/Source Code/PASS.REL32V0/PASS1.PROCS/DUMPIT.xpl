 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DUMPIT.xpl
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
 /* PROCEDURE NAME:  DUMPIT                                                 */
 /* MEMBER NAME:     DUMPIT                                                 */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FORM_UP           CHARACTER                                    */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AS_PTR                                                         */
 /*          COMM                                                           */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          EXT_ARRAY_PTR                                                  */
 /*          FIRST_FREE                                                     */
 /*          IDENT_COUNT                                                    */
 /*          LIT_CHAR_SIZE                                                  */
 /*          LIT_CHAR_USED                                                  */
 /*          MACRO_TEXT_LIM                                                 */
 /*          MAX_PTR_TOP                                                    */
 /*          MAXNEST                                                        */
 /*          MAXSP                                                          */
 /*          NDECSY                                                         */
 /*          OUTER_REF_LIM                                                  */
 /*          OUTER_REF_MAX                                                  */
 /*          PTR_TOP                                                        */
 /*          REDUCTIONS                                                     */
 /*          SCAN_COUNT                                                     */
 /*          STMT_NUM                                                       */
 /*          SYTSIZE                                                        */
 /*          XREF_INDEX                                                     */
 /*          XREF_LIM                                                       */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          I_FORMAT                                                       */
 /* CALLED BY:                                                              */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DUMPIT <==                                                          */
 /*     ==> I_FORMAT                                                        */
 /***************************************************************************/
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   CR/DR NUMBER AND TITLE                              */
 /*                                                                         */
 /*03/22/04 TKN   32V0  13670  ENHANCE & UPDATE INFORMATION ON THE USAGE    */
 /*               17V0         OF TYPE 2 OPTIONS                            */
 /***************************************************************************/
                                                                                01083000
                                                                                01083100
DUMPIT:                                                                         01083200
   PROCEDURE;    /* DUMP OUT THE STATISTICS COLLECTED DURING THIS RUN  */       01083300
 /*  PUT OUT THE ENTRY COUNT FOR IMPORTANT PROCEDURES */                        01083400
                                                                                01083500
FORM_UP:                                                                        01083600
      PROCEDURE(MSG, VAL1, VAL2) CHARACTER;                                     01083700
         DECLARE MSG CHARACTER, (VAL1, VAL2) FIXED;                             01083800
         IF VAL2>VAL1 THEN S = ' <-<-<- ';   /*CR13670*/                        01083920
         ELSE S = '';                                                           01083930
         S = I_FORMAT(VAL2, 8) || S;                                            01083950
         S = I_FORMAT(VAL1, 10) || S;                                           01084000
         RETURN MSG || S;                                                       01084100
      END FORM_UP;                                                              01084200
                                                                                01084300
                                                                                01084400
      OUTPUT = '       OPTIONAL TABLE SIZES';                                   01084500
      OUTPUT(1) = '0NAME       REQUESTED    USED';                              01084600
      OUTPUT(1) = '+____       _________    ____';                              01084700
      OUTPUT = X1;                                                              01084800
      OUTPUT = FORM_UP('LITSTRINGS',LIT_CHAR_SIZE,LIT_CHAR_USED);  /*CR13670*/  01085100
      OUTPUT = FORM_UP('SYMBOLS   ', SYTSIZE, NDECSY);                          01084900
      OUTPUT = FORM_UP('MACROSIZE ', MACRO_TEXT_LIM, FIRST_FREE);               01085000
      OUTPUT = FORM_UP('XREFSIZE  ', XREF_LIM, XREF_INDEX);                     01085300
      OUTPUT = FORM_UP('BLOCKSUM  ', OUTER_REF_LIM, OUTER_REF_MAX);             01085310
      OUTPUT(1) = DOUBLE;                                                       01085400
                                                                                01085500
      OUTPUT = 'CALLS TO SCAN        = ' || SCAN_COUNT;                         01085600
      OUTPUT = 'CALLS TO IDENTIFY    = ' || IDENT_COUNT;                        01085700
      OUTPUT = 'NUMBER OF REDUCTIONS = ' || REDUCTIONS;                         01085800
      OUTPUT = 'MAX STACK SIZE       = ' || MAXSP;                              01085900
      OUTPUT = 'MAX IND. STACK SIZE  = ' || MAX_PTR_TOP;                        01086000
      OUTPUT = 'END IND. STACK SIZE  = ' || PTR_TOP;                            01086100
      OUTPUT = 'END ARRAY STACK SIZE = ' || AS_PTR;                             01086200
      OUTPUT = 'MAX EXT_ARRAY INDEX  = ' || EXT_ARRAY_PTR;                      01086300
      OUTPUT = 'STATEMENT COUNT      = '||STMT_NUM-1;                           01086400
      OUTPUT = 'MINOR COMPACTIFIES   = ' || COMPACTIFIES;                       01086500
      OUTPUT = 'MAJOR COMPACTIFIES   = ' || COMPACTIFIES(1);                    01086600
      OUTPUT = 'REALLOCATIONS        = '|| REALLOCATIONS;                       01086601
      OUTPUT = 'MAX NESTING DEPTH    = ' || MAXNEST;                            01086700
      OUTPUT = 'FREE STRING AREA     = ' || FREELIMIT - FREEBASE;               01086800
      DOUBLE_SPACE;                                                             01086900
   END DUMPIT;                                                                  01087000
