 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKARR.xpl
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
 /* PROCEDURE NAME:  CHECK_ARRAYNESS                                        */
 /* MEMBER NAME:     CHECKARR                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          K                 BIT(16)                                      */
 /*          LOOP              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LOOPE             BIT(16)                                      */
 /*          ARRAYED           BIT(8)                                       */
 /*          MV                BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          ASSIGN_OP                                                      */
 /*          C_TRACE                                                        */
 /*          FALSE                                                          */
 /*          IN_AR                                                          */
 /*          IN_VM                                                          */
 /*          MAT_VAR                                                        */
 /*          OR                                                             */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          VAR                                                            */
 /*          VAR_TYPE                                                       */
 /*          VEC_VAR                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NESTED_VM                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LOOPY                                                          */
 /*          BUMP_REF_OPS                                                   */
 /*          SET_VAR                                                        */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_ARRAYNESS <==                                                 */
 /*     ==> SET_VAR                                                         */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> LAST_OPERAND                                                */
 /*     ==> LOOPY                                                           */
 /*         ==> GET_CLASS                                                   */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> NO_OPERANDS                                                 */
 /*     ==> BUMP_REF_OPS                                                    */
 /*         ==> POP_COMPARE                                                 */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> NO_OPERANDS                                             */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 07/19/99 DAS  30V0/ DR111333 BIX LOOP COMBINING CAUSES INCORRECT        */
 /*               15V0           OBJECT CODE                                */
 /*                                                                         */
 /***************************************************************************/
                                                                                01896910
                                                                                01896920
                                                                                01896930
CHECK_ARRAYNESS:                                                                01896940
   PROCEDURE(K,LOOP);                                                           01896950
      DECLARE (K,LOOP,LOOPE) BIT(16);                                           01896952
      DECLARE (MV,ARRAYED) BIT(8);                                              01896954
      DECLARE I BIT(16); /* DR111333 */
      CALL SET_VAR(K);                                                          01896956
      MV = VAR_TYPE = MAT_VAR OR VAR_TYPE = VEC_VAR;                            01896958
      /* DR111333 - STRUCTURE TEMPLATE NODE ASSIGNED ? */
      IF (SYT_CLASS(VAR)=7) & (SYT_LINK2(VAR)^=0) & /* DR111333 */
         (ASSIGN_OP) & (K>LOOP+1)  /* DR111333 - ON LHS OF ASSIGN */
         THEN DO;                  /* DR111333 */
         I = VAR;                  /* DR111333 */
         DO UNTIL SYT_LINK2(I)=0;  /* DR111333 */
            I = I - 1;             /* DR111333 - GET TEMPLATE SYM# */
         END;                      /* DR111333 */
         STRUC_TEMPL = I;          /* DR111333 */
      END;                         /* DR111333 */
      /* DR111333 - IS THE STRUC BEING REFERENCED AFTER NODE ASSIGN ? */
      IF (SYT_TYPE(VAR)=62) &            /* DR111333 - STRUC TEMPLATE */
         (ASSIGN_OP) & (K=LOOP+1) THEN   /* DR111333 - ON RHS OF ASSIGNMENT */
      IF STRUC_TEMPL ^= 0 /* DR111333- FLAG FOR ANY STRUC REF */
         THEN REF_TO_STRUC = TRUE;       /* DR111333 */
      ARRAYED = SYT_ARRAY(VAR) = 0;                                             01896960
      LOOPE = LOOPY(LOOP);                                                      01896962
      IF MV AND ARRAYED                                                         01896964
      /* DR111333 - ADD ">" TO NEXT STATEMENT TO LOOK AT MULTIPLE LHS */
         THEN IF ASSIGN_OP AND K>=LOOP+2 AND IN_VM AND ^IN_AR THEN /* DR111333*/01896966
         CALL BUMP_REF_OPS(K,1);                                                01896967
      ELSE IF (^ASSIGN_OP AND (^LOOPE OR (IN_AR AND IN_VM))) THEN               01896968
         CALL BUMP_REF_OPS(K,0);                                                01896969
      ELSE IF ASSIGN_OP AND K=LOOP+1 AND IN_AR AND IN_VM THEN                   01896970
         CALL BUMP_REF_OPS(K,0);                                                01896971
      IF IN_VM THEN IF MV = ARRAYED THEN DO;                                    01896972
         NESTED_VM = FALSE;                                                     01897010
         IF C_TRACE THEN OUTPUT = 'CHECK_ARRAYNESS(' || K||') = 1';             01897020
                                                                                01897040
 /* NO MIXED DENESTING IF ARRAY DIMS OF MV'S DON'T MATCH*/                      01897050
 /* OR AFFAYED VARS PRESENT*/                                                   01897060
      END;                                                                      01897070
   END CHECK_ARRAYNESS;                                                         01897080
