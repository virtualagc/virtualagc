 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NAMECOMP.xpl
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
 /* PROCEDURE NAME:  NAME_COMPARE                                           */
 /* MEMBER NAME:     NAMECOMP                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /*          R_CLASS           BIT(16)                                      */
 /*          R_NO              BIT(16)                                      */
 /*          G                 BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          C1                BIT(16)                                      */
 /*          C2                BIT(16)                                      */
 /*          EXTN1_PTR         BIT(16)                                      */
 /*          EXTN2_PTR         BIT(16)                                      */
 /*          FIND_EXTN1(1)     LABEL                                        */
 /*          FIND_EXTN2        LABEL                                        */
 /*          F1                FIXED                                        */
 /*          F2                FIXED                                        */
 /*          NAME_MASK         FIXED                                        */
 /*          NODE1_PTR         BIT(16)                                      */
 /*          NODE1_SYT_PTR     BIT(16)                                      */
 /*          NODE2_PTR         BIT(16)                                      */
 /*          NODE2_SYT_PTR     BIT(16)                                      */
 /*          NUM_LOC1_OPS      BIT(16)                                      */
 /*          NUM_LOC2_OPS      BIT(16)                                      */
 /*          QQ                BIT(16)                                      */
 /*          STRUC_SYT_FLAGS_LOC1  FIXED                                    */
 /*          STRUC_SYT_FLAGS_LOC2  FIXED                                    */
 /*          VAR1_FLAGS        FIXED                                        */
 /*          VAR2_FLAGS        FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_ATOMS                                                    */
 /*          ATOMS                                                          */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          FOR_ATOMS                                                      */
 /*          LOC_P                                                          */
 /*          LOCK_FLAG                                                      */
 /*          NAME_FLAG                                                      */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LOCK#                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LOCK#                                                      */
 /*          SYT_TYPE                                                       */
 /*          TEMPL_NAME                                                     */
 /*          TEMPLATE_CLASS                                                 */
 /*          TRUE                                                           */
 /*          VAL_P                                                          */
 /*          XVAC                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          RESET_ARRAYNESS                                                */
 /* CALLED BY:                                                              */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> NAME_COMPARE <==                                                    */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> RESET_ARRAYNESS                                                 */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*08/27/90 RAH   23V1  102962 INVALID AV0,CO ERRORS GENERATED FOR NAME     */
 /*                     ASSIGNMENT, NAME COMPARE STMTS.                     */
 /*                                                                         */
 /*11/22/95 JMP   27V1/ 109031 PASS 1 EMITS ILLEGAL AV0/C0 ERRORS           */
 /*               11V1  FOR STRUCTURES                                      */
 /*                                                                         */
 /*11/01/99 KHP   30V0/ C12711 ALLOW NAME ASSIGNS WITH TREE EQUIVALENT      */
 /*               15V0  TEMPLATES                                           */
 /*                                                                         */
 /*12/14/99 JAC   30V0/ 111347 NO REMOTE ATTRIBUTE ERROR CHECKING FOR       */
 /*               15V0  INPUT PARAMETERS                                    */
 /*                                                                         */
 /*08/23/02 DCP   32V0/ CR13571 COMBINE PROCEDURE/FUNCTION PARAMETER        */
 /*               17V0          CHECKING                                    */
 /*                                                                         */
 /*06/20/02 JAC   32V0/ CR13538 ALLOW MIXING OF REMOTE AND NON-REMOTE       */
 /*               17V0          POINTERS                                    */
 /***************************************************************************/
                                                                                00873300
NAME_COMPARE:                                                                   00873400
   PROCEDURE (LOC1,LOC2,R_CLASS,R_NO,G);                                        00873500
      DECLARE (LOC1,LOC2,R_CLASS,R_NO) BIT(16),                                 00873600
         G BIT(16) INITIAL(TRUE), QQ BIT(16);                                   00873700
      DECLARE (C1,C2) BIT(16);                                                  00873800
      DECLARE (F1,F2) FIXED;                                                    00873900
      DECLARE NAME_MASK FIXED  INITIAL("00C20000");  /*CR13538*/                00874000
      DECLARE (VAR1_FLAGS, VAR2_FLAGS) FIXED;
      DECLARE ST_R_NO BIT(16);     /*CR12711*/

      ST_R_NO = R_NO-1;            /*CR12711*/
      C1=FIXL(LOC1);                                                            00874100
      C2=FIXL(LOC2);                                                            00874200
 /*  POINTS TO TEMPLATES FOR STRUCTS BUT DOESNT MATTER SINCE                    00874300
        FLAGS AND CLASS MATCHING CANNOT FAULT ERRONEOUSLY  */                   00874400
      F1=VAL_P(PTR(LOC1));                                                      00874500
      F2=VAL_P(PTR(LOC2));                                                      00874600
 /*  G IS TRUE FOR NAME COMPARISONS AND THE FIRST TIME THE PROCEDURE IS  */
 /*  CALLED FOR NAME ASSIGNMENTS.                                        */
 /*  G IS FALSE FOR EACH ADDITIONAL LHS VARIABLE OF NAME ASSIGNMENTS.    */
 /*  IT IS 0 BECAUSE F2 REPRESENTS THE LHS VARIABLE THAT HAS ALREADY     */
 /*  BEEN PROCESSED IN NAME_COMPARE AND RESET_ARRAYNESS SHOULD NOT BE    */
 /*  CALLED AGAIN FOR THE VARIABLE.                                      */
 /*  THE BELOW STATEMENT IS DETERMINING HOW MANY TIMES RESET_ARRAYNESS   */
 /*  SHOULD BE CALLED.  ((F1/F2 & "500") = "100") IS FALSE WHEN 'NULL'   */
 /*  IS IN THE NAME PSEUDO-FUNCTION.  RESET_ARRAYNESS DETERMINES IF      */
 /*  ARRAYNESS MATCHES AND MOVES THE ARRAYNESS_STACK POINTER (AS_PTR)    */
 /*  TO THE CORRECT LOCATION.                                            */
      QQ=(((F2&"500")="100")&G)+((F1&"500")="100");                             00874700
      /* CHECKING IF BOTH VARIABLES ARE IN A NAME PSEUDO-FUNCTION */
      IF ^SHR(F1&F2,8) THEN CALL ERROR(R_CLASS,R_NO);                           00874800
      /* IF NEITHER VARIABLE IS NULL THEN ENTER BLOCK */
      ELSE IF ^SHR(F1|F2,10) THEN DO;                                           00874900

 /*************** DR102962  R. HANDLEY ********************************/
 /*THE CODE ADDED TO DETERMINE THE STRUCTURE'S FLAGS WAS REMOVED BY   */
 /*CR13538 SINCE AV0,C0,FT0 ERRORS ARE NO LONGER EMITTED FOR REMOTE   */
 /*MISMATCH. INSTEAD SET VAR_FLAGS EQUAL TO THE NODE'S FLAGS DIRECTLY.*/
 /* (THIS WILL BE THE TEMPLATE'S FLAGS FOR STRUCTURES).               */

         VAR1_FLAGS = SYT_FLAGS(C1);                             /*CR13538*/

 /* NOW GET THE RIGHT HAND SIDE. */

         VAR2_FLAGS = SYT_FLAGS(C2);                             /*CR13538*/

         IF ((VAR1_FLAGS & NAME_MASK)^=(VAR2_FLAGS & NAME_MASK)) /*CR13538*/
            THEN R_NO = 0;                                       /*CR13538*/

 /******************** END DR102962 ************************************/

         IF PSEUDO_TYPE(PTR(LOC1))^=PSEUDO_TYPE(PTR(LOC2)) THEN R_NO=0;         00875100
         ELSE IF SHR(F1|F2,12) THEN                          /*CR13571*/        00875200
               CALL STRUCTURE_COMPARE(C1,C2,R_CLASS,ST_R_NO);/*CR12711*/
         ELSE DO;                                                               00875500
            F1=PSEUDO_LENGTH(PTR(LOC1));                                        00875600
            F2=PSEUDO_LENGTH(PTR(LOC2));                                        00875700
            IF ^SHR(F1|F2,15) THEN IF F1^=F2 THEN R_NO=0;                       00875800
         END;                                                                   00875900
         QQ=QQ-1-G;                                                             00876000
         IF G THEN CALL RESET_ARRAYNESS;                                        00876100
         IF RESET_ARRAYNESS>0 THEN R_NO=0;                                      00876200
         F1=SYT_CLASS(C1);                                                      00876300
         F2=SYT_CLASS(C2);                                                      00876400
         IF F1^=F2 THEN IF F1+TEMPLATE_CLASS-1^=F2 THEN                         00876500
            IF F2+TEMPLATE_CLASS-1^=F1 THEN R_NO=0;                             00876600
         IF FIXV(LOC1)^=0 THEN C1=FIXV(LOC1);                                   00876700
         IF FIXV(LOC2)^=0 THEN C2=FIXV(LOC2);                                   00876800
         IF (SYT_FLAGS(C1)&LOCK_FLAG)^=(SYT_FLAGS(C2)&LOCK_FLAG) THEN R_NO=0;   00876900
         ELSE IF (SYT_FLAGS(C1)&LOCK_FLAG)^=0 THEN DO;                          00877000
            IF SYT_LOCK#(C1)^=SYT_LOCK#(C2) THEN R_NO=0;                        00877100
         END;                                                                   00877200
         IF R_NO=0 THEN CALL ERROR(R_CLASS,0);                                  00877300
      END;                                                                      00877400
      DO QQ=1 TO QQ;                                                            00877500
         CALL RESET_ARRAYNESS;                                                  00877600
      END;                                                                      00877700
      G=TRUE;                                                                   00877800
   END NAME_COMPARE;                                                            00877900
