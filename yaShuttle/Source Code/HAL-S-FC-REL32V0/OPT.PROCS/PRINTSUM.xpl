 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTSUM.xpl
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
 /* PROCEDURE NAME:  PRINTSUMMARY                                           */
 /* MEMBER NAME:     PRINTSUM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LEAFPROC          LABEL                                        */
 /*          EXITT             LABEL                                        */
 /*          T                 FIXED                                        */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLOCK                                                          */
 /*          COMBINE#                                                       */
 /*          COMM                                                           */
 /*          COMPARE_CALLS                                                  */
 /*          COMPLEX_MATCHES                                                */
 /*          CSE#                                                           */
 /*          DENEST#                                                        */
 /*          DIVISION_ELIMINATIONS                                          */
 /*          EXTN_CSES                                                      */
 /*          FOR                                                            */
 /*          FUNC_CLASS                                                     */
 /*          INVAR#                                                         */
 /*          LABEL_CLASS                                                    */
 /*          LITERAL_FOLDS                                                  */
 /*          MAX_CSE_TAB                                                    */
 /*          MAXNODE                                                        */
 /*          PROC_LABEL                                                     */
 /*          PUSH_SIZE                                                      */
 /*          PUSH#                                                          */
 /*          SCANS                                                          */
 /*          STUB_FLAG                                                      */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_NAME                                                       */
 /*          SYT_TYPE                                                       */
 /*          TRANSPOSE_ELIMINATIONS                                         */
 /*          TSUB_CSES                                                      */
 /*          VDLP#                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PRINT_TIME                                                     */
 /*          PRINT_DATE_AND_TIME                                            */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PRINTSUMMARY <==                                                    */
 /*     ==> PRINT_TIME                                                      */
 /*     ==> PRINT_DATE_AND_TIME                                             */
 /*         ==> PRINT_TIME                                                  */
 /***************************************************************************/
                                                                                04229510
 /* PRINTS OPTIMIZER STATISTICS IF REQUESTED*/                                  04230000
PRINTSUMMARY:                                                                   04231000
   PROCEDURE;                                                                   04232000
      DECLARE T FIXED;                                                          04233000
      DECLARE TEMP BIT(16);                                                     04233010
                                                                                04234000
LEAFPROC:                                                                       04235000
      PROCEDURE BIT(8);                                                         04236000
         RETURN (SYT_CLASS(TEMP) = FUNC_CLASS |                                 04237000
            SYT_CLASS(TEMP) = LABEL_CLASS &                                     04238000
            SYT_TYPE(TEMP) = PROC_LABEL) &                                      04239000
            (SYT_FLAGS(TEMP) & STUB_FLAG) = 0;                                  04240000
      END LEAFPROC;                                                             04241000
                                                                                04242000
      OUTPUT = '';                                                              04243000
      OUTPUT = 'CSE''S FOUND                   = '||CSE#;                       04244000
      IF COMPLEX_MATCHES ^= 0 THEN                                              04244010
         OUTPUT = 'COMPLEX CSE''S                 = '||COMPLEX_MATCHES;         04245000
      IF TSUB_CSES ^= 0 THEN                                                    04245010
         OUTPUT = 'TSUB CSE''S                    = '||TSUB_CSES;               04246000
      IF EXTN_CSES ^= 0 THEN                                                    04246010
         OUTPUT = 'EXTN CSE''S                    = '||EXTN_CSES;               04247000
      IF TRANSPOSE_ELIMINATIONS ^= 0 THEN                                       04247010
         OUTPUT = 'MATRIX TRANSPOSE ELIMINATIONS = '||TRANSPOSE_ELIMINATIONS;   04248000
      IF DIVISION_ELIMINATIONS ^= 0 THEN                                        04248010
         OUTPUT = 'DIVISION ELIMINATIONS         = '||DIVISION_ELIMINATIONS;    04249000
      IF LITERAL_FOLDS ^= 0 THEN                                                04249010
         OUTPUT = 'LITERAL FOLDS                 = '||LITERAL_FOLDS;            04250000
      OUTPUT = '';                                                              04250010
      IF VDLP# ^= 0 THEN                                                        04250020
         OUTPUT = 'MAT/VEC INLINE LOOPS CREATED  = '||VDLP#;                    04250030
      IF DENEST# ^= 0 THEN                                                      04250040
         OUTPUT = 'LOOPS DENESTED                = '||DENEST#;                  04250050
      IF COMBINE# ^= 0 THEN                                                     04250060
         OUTPUT = 'LOOPS COMBINED                = '||COMBINE#;                 04250070
      IF INVAR# ^= 0 THEN                                                       04250110
         OUTPUT = 'INVARIANTS PULLED FROM LOOPS  = '||INVAR#;                   04250120
      OUTPUT = '';                                                              04251000
      OUTPUT=  'COMPARE CALLS                 = '||COMPARE_CALLS;               04252000
      OUTPUT = 'SCANS                         = '||SCANS;                       04253000
      OUTPUT = 'MAX_NODE_LIST                 = '||MAXNODE;                     04254000
      OUTPUT = 'MAX_CSE_TAB                   = ' ||MAX_CSE_TAB;                04255000
      IF PUSH# ^= 0 THEN DO;                                                    04255010
         OUTPUT   = 'CALLS TO PUSH HALMAT          = '||PUSH#;                  04255020
         OUTPUT   = 'HALMAT WORDS MOVED            = '||PUSH_SIZE;              04255030
      END;                                                                      04255040
      OUTPUT = 'MINOR COMPACTIFIES            = '||COMPACTIFIES;                04256000
      OUTPUT = 'MAJOR COMPACTIFIES            = '||COMPACTIFIES(1);             04257000
      OUTPUT = 'FREE STRING AREA              = '||FREELIMIT - FREEBASE;        04258000
      OUTPUT = ''; OUTPUT = '';                                                 04259000
                                                                                04260000
      DO FOR TEMP = 1 TO COMM(10);  /* SYT SIZE*/                               04261000
         IF LEAFPROC THEN DO;                                                   04262000
            OUTPUT = 'PROCEDURES STILL ELIGIBLE FOR LEAF PROCEDURES:';          04263000
            DO FOR TEMP = TEMP TO COMM(10);                                     04264000
               IF LEAFPROC THEN OUTPUT = '     ' || SYT_NAME(TEMP);             04265000
            END;                                                                04266000
            OUTPUT = ''; OUTPUT = '';                                           04267000
            GO TO EXITT;                                                        04268000
         END;                                                                   04269000
      END;                                                                      04270000
EXITT:                                                                          04271000
      CALL PRINT_DATE_AND_TIME('END OF HAL/S OPTIMIZER ', DATE,TIME);           04272000
      OUTPUT = ''; OUTPUT = '';                                                 04273000
      T = MONITOR(18);                                                          04274000
      CALL PRINT_TIME('TOTAL CPU TIME FOR OPTIMIZER     ',T - CLOCK);           04275000
      CALL PRINT_TIME('CPU TIME FOR OPTIMIZER SETUP     ', CLOCK(1)-CLOCK);     04276000
      CALL PRINT_TIME('CPU TIME FOR OPTIMIZER CRUNCHING '                       04277000
         ,CLOCK(2) - CLOCK(1));                                                 04278000
      CALL PRINT_TIME('CPU TIME FOR OPTIMIZER CLEAN UP  '                       04279000
         ,T - CLOCK(2));                                                        04280000
   END PRINTSUMMARY;                                                            04281000
