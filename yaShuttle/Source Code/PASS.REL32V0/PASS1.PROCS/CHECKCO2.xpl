 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKCO2.xpl
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
 /* PROCEDURE NAME:  CHECK_CONFLICTS                                        */
 /* MEMBER NAME:     CHECKCO2                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TYPE_CONFLICT     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_D                                                        */
 /*          CLASS_DA                                                       */
 /*          CLASS_DC                                                       */
 /*          CLASS_DI                                                       */
 /*          DEFAULT_TYPE                                                   */
 /*          FACTOR_FOUND                                                   */
 /*          FACTORED_BIT_LENGTH                                            */
 /*          FACTORED_CHAR_LENGTH                                           */
 /*          FACTORED_CLASS                                                 */
 /*          FACTORED_IC_FND                                                */
 /*          FACTORED_LOCK#                                                 */
 /*          FACTORED_MAT_LENGTH                                            */
 /*          FACTORED_N_DIM                                                 */
 /*          FACTORED_NONHAL                                                */
 /*          FACTORED_S_ARRAY                                               */
 /*          FACTORED_STRUC_DIM                                             */
 /*          FACTORED_STRUC_PTR                                             */
 /*          FACTORED_TYPE                                                  */
 /*          FACTORED_VEC_LENGTH                                            */
 /*          IC_FND                                                         */
 /*          IC_PTR                                                         */
 /*          ID_LOC                                                         */
 /*          INIT_CONST                                                     */
 /*          MAJ_STRUC                                                      */
 /*          MP                                                             */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          VAR                                                            */
 /*          VEC_TYPE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATTR_MASK                                                      */
 /*          ATTRIBUTES                                                     */
 /*          BIT_LENGTH                                                     */
 /*          CHAR_LENGTH                                                    */
 /*          CLASS                                                          */
 /*          FACTORED_ATTR_MASK                                             */
 /*          FACTORED_ATTRIBUTES                                            */
 /*          I                                                              */
 /*          IC_FOUND                                                       */
 /*          IC_PTR2                                                        */
 /*          LOCK#                                                          */
 /*          MAT_LENGTH                                                     */
 /*          N_DIM                                                          */
 /*          NONHAL                                                         */
 /*          S_ARRAY                                                        */
 /*          STRUC_DIM                                                      */
 /*          STRUC_PTR                                                      */
 /*          TYPE                                                           */
 /*          VEC_LENGTH                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMPARE                                                        */
 /*          CHECK_CONSISTENCY                                              */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_CONFLICTS <==                                                 */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> COMPARE                                                         */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> CHECK_CONSISTENCY                                               */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /***************************************************************************/
 /***************************************************************************/
 /* REVISION HISTORY:                                                       */
 /* -----------------                                                       */
 /*                                                                         */
 /* DATE     WHO   RLS   CR/DR #  DESCRIPTION                               */
 /*                                                                         */
 /* 03/06/98 DCP   29V0/ DR109083 CONSTANT DOUBLE SCALAR CONVERTED          */
 /*                14V0           TO CHARACTER AS SINGLE PRECISION          */
 /*                                                                         */
 /* 12/09/97 DCP   29V0/ DR109083 ARITHMETIC EXPRESSION IN CONSTANT/INITIAL */
 /*                14V0           VALUE GETS ERROR                          */
 /*                                                                         */
 /* 01/23/01 DCP   31V0/ CR13336  DON'T ALLOW ARITHMETIC EXPRESSIONS IN     */
 /*                16V0           CHARACTER INITIAL CLAUSES                 */
 /*                                                                         */
 /***************************************************************************/
                                                                                01028900
                                                                                01029000
CHECK_CONFLICTS:                                                                01029100
   PROCEDURE;                                                                   01029200
      IF (CLASS|FACTORED_CLASS)=3 THEN                                          01029300
TYPE_CONFLICT:                                                                  01029400
      CALL ERROR(CLASS_DC,4,VAR(MP));                                           01029500
      ELSE DO;                                                                  01029600
         IF TYPE=0 THEN DO;                                                     01029700
            IF FACTORED_TYPE=0 THEN DO;                   /*MOD-DR109083*/      01029800
              TYPE=DEFAULT_TYPE;                          /*MOD-DR109083*/      01029800
              DOUBLELIT = FALSE;                              /*DR109083*/
            END;                                              /*DR109083*/
            ELSE TYPE=FACTORED_TYPE;                                            01029900
         END;                                                                   01030000
         ELSE IF FACTORED_TYPE^=0 THEN                                          01030100
            IF TYPE^=FACTORED_TYPE THEN GO TO TYPE_CONFLICT;                    01030200
         CLASS=CLASS|FACTORED_CLASS;                                            01030300
      END;                                                                      01030400
      IF IC_FND THEN                                                            01030500
         DO;                                                                    01030600
         IC_FOUND = IC_FOUND | 2;                                               01030700
         IC_PTR2 = IC_PTR;                                                      01030800
         IF FACTORED_IC_FND THEN DO;                                            01030900
            FACTORED_ATTRIBUTES=FACTORED_ATTRIBUTES&(^INIT_CONST);              01031000
            FACTORED_ATTR_MASK=FACTORED_ATTR_MASK&(^INIT_CONST);                01031100
            CALL ERROR(CLASS_DI, 9, SYT_NAME(ID_LOC));                          01031200
         END;                                                                   01031300
      END;                                                                      01031400
      I = FACTORED_ATTR_MASK & ATTR_MASK;                                       01031500
      IF I ^= 0 THEN                                                            01031600
         IF (FACTORED_ATTRIBUTES & I) ^= (ATTRIBUTES & I) THEN                  01031700
         CALL ERROR(CLASS_DA, 24, SYT_NAME(ID_LOC));                            01031800
      ATTRIBUTES = ATTRIBUTES | (FACTORED_ATTRIBUTES & (^I));                   01031900
      ATTR_MASK = ATTR_MASK | (FACTORED_ATTR_MASK & (^I));                      01032000
      CALL CHECK_CONSISTENCY;                                                   01032100
      IF ^FACTOR_FOUND THEN RETURN;                                             01032200
      IF FACTORED_LOCK#^=0 THEN DO;                                             01032300
         IF LOCK#^=0 THEN CALL ERROR(CLASS_D,5,SYT_NAME(ID_LOC));               01032400
         ELSE LOCK#=FACTORED_LOCK#;                                             01032500
      END;                                                                      01032600
      IF FACTORED_N_DIM ^= 0 THEN                                               01032700
         DO;                                                                    01032800
         IF N_DIM ^= 0 THEN                                                     01032900
            CALL ERROR(CLASS_D, 6, SYT_NAME(ID_LOC));                           01033000
         ELSE DO;                                                               01033100
            N_DIM = FACTORED_N_DIM;                                             01033200
            DO I = 0 TO N_DIM;                                                  01033300
               S_ARRAY(I) = FACTORED_S_ARRAY(I);                                01033400
            END;                                                                01033500
         END;                                                                   01033600
      END;                                                                      01033700
      IF FACTORED_NONHAL>0 THEN DO;                                             01033800
         IF NONHAL=0 THEN NONHAL=FACTORED_NONHAL;                               01033900
         ELSE IF NONHAL^=FACTORED_NONHAL THEN CALL ERROR(CLASS_D,13,VAR(MP));   01034000
      END;                                                                      01034100
      IF TYPE <= VEC_TYPE THEN                                                  01034200
         DO CASE TYPE;  /* CHECK SIZES */                                       01034300
                                                                                01034400
         ;  /* NO TYPE 0 */                                                     01034500
                                                                                01034600
         BIT_LENGTH = COMPARE(BIT_LENGTH, FACTORED_BIT_LENGTH, 5);              01034700
                                                                                01034800
         CHAR_LENGTH=COMPARE(CHAR_LENGTH,FACTORED_CHAR_LENGTH,6);               01034900
                                                                                01035000
         MAT_LENGTH = COMPARE(MAT_LENGTH, FACTORED_MAT_LENGTH, 7);              01035100
                                                                                01035200
         VEC_LENGTH = COMPARE(VEC_LENGTH, FACTORED_VEC_LENGTH, 8);              01035300
                                                                                01035400
      END;  /* OF DO CASE TYPE */                                               01035500
      ELSE IF TYPE = MAJ_STRUC THEN                                             01035600
         DO;                                                                    01035700
         STRUC_DIM = COMPARE(STRUC_DIM, FACTORED_STRUC_DIM, 9);                 01035800
         STRUC_PTR = COMPARE(STRUC_PTR, FACTORED_STRUC_PTR, 10);                01035900
      END;                                                                      01036000
                                                                                01036100
   END CHECK_CONFLICTS;                                                         01036200
