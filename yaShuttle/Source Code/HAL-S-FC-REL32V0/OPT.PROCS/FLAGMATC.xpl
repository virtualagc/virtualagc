 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FLAGMATC.xpl
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
 /* PROCEDURE NAME:  FLAG_MATCHES                                           */
 /* MEMBER NAME:     FLAGMATC                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CSE_FOUND_INX     BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          END_OF_NODE                                                    */
 /*          HALMAT_NODE_START                                              */
 /*          TRACE                                                          */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CSE                                                            */
 /*          CSE2                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FLAG_VAC_OR_LIT                                                */
 /*          FLAG_V_N                                                       */
 /*          PRINT_SENTENCE                                                 */
 /*          TYPE                                                           */
 /* CALLED BY:                                                              */
 /*          COLLECT_MATCHES                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FLAG_MATCHES <==                                                    */
 /*     ==> PRINT_SENTENCE                                                  */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> TYPE                                                            */
 /*     ==> FLAG_VAC_OR_LIT                                                 */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> COMPARE_LITERALS                                            */
 /*             ==> HEX                                                     */
 /*             ==> GET_LITERAL                                             */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> SET_FLAG                                                    */
 /*     ==> FLAG_V_N                                                        */
 /*         ==> CATALOG_PTR                                                 */
 /*         ==> VALIDITY                                                    */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> SET_FLAG                                                    */
 /***************************************************************************/
                                                                                02787000
 /* FLAGS MATCHED OPERANDS*/                                                    02788000
FLAG_MATCHES:                                                                   02789000
   PROCEDURE;                                                                   02790000
      DECLARE CSE_FOUND_INX BIT(16);                                            02791000
      IF TRACE THEN DO;                                                         02792000
         OUTPUT = 'FLAG_MATCHES: ';                                             02793000
         OUTPUT = '';                                                           02794000
      END;                                                                      02795000
      CSE_FOUND_INX = 1;                                                        02796000
      DO WHILE CSE(CSE_FOUND_INX) ^= END_OF_NODE;                               02797000
         CSE = CSE(CSE_FOUND_INX);                                              02798000
         CSE2 = CSE2(CSE_FOUND_INX);                                            02799000
         DO CASE TYPE(CSE);                                                     02800000
            ;;;                                                                 02800010
               DO;      /* TERMINAL VAC*/                                       02800020
               CALL FLAG_VAC_OR_LIT(2);                                         02800030
            END;                                                                02800040
            ;                                                                   02800050
            ;                                                                   02801000
            ;     /* IMMEDIATE  */                                              02802000
            ;;;;DO;   /* B = VALUE_NO */                                        02803000
                  CALL FLAG_V_N;                                                02804000
            END;                                                                02805000
            DO;      /* C = OUTER TERMINAL VAC*/                                02806000
               CALL FLAG_VAC_OR_LIT;                                            02807000
            END;                                                                02808000
            ; CALL FLAG_VAC_OR_LIT(1)   /* LITERAL*/  ;;;                       02809000
            END;                                                                02810000
         CSE_FOUND_INX = CSE_FOUND_INX + 1;                                     02811000
      END;                                                                      02812000
      IF WATCH THEN DO;                                                         02813000
         OUTPUT = 'FLAG_NODE,FLAG_MATCHES';                                     02814000
         CALL PRINT_SENTENCE(HALMAT_NODE_START);                                02815000
      END;                                                                      02816000
   END FLAG_MATCHES;                                                            02817000
