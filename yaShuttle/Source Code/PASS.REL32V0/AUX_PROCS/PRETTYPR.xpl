 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRETTYPR.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  PRETTY_PRINT_MAT                                       */
/* MEMBER NAME:     PRETTYPR                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          BLANKS            CHARACTER;                                   */
/*          CAUXMAT           CHARACTER;                                   */
/*          EXIT_PRINT_LOOP   LABEL                                        */
/*          MESSAGE           CHARACTER;                                   */
/*          PARALLEL_CASE     LABEL                                        */
/*          PRETTY_PRINT_CLOCK(1)  FIXED                                   */
/*          PRINT_LOOP        LABEL                                        */
/*          STMT_NO           BIT(8)                                       */
/*          TEST_FOR_SKIP     LABEL                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AUXMAT                                                         */
/*          BLOCK_PRIME                                                    */
/*          CLOSE                                                          */
/*          FALSE                                                          */
/*          HALMAT_SIZE                                                    */
/*          HALMAT                                                         */
/*          TRUE                                                           */
/*          XREC_PRIME_PTR                                                 */
/*          XREC_PTR                                                       */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          AUXMAT_PRINT_PTR                                               */
/*          HALMAT_PRINT_PTR                                               */
/*          TEMP_MAT                                                       */
/*          TOTAL_PRETTY_PRINT_TIME                                        */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          FORMAT_HALMAT                                                  */
/*          FORMAT_AUXMAT                                                  */
/* CALLED BY:                                                              */
/*          NEW_HALMAT_BLOCK                                               */
/*          PASS2                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PRETTY_PRINT_MAT <==                                                */
/*     ==> FORMAT_HALMAT                                                   */
/*         ==> #RJUST                                                      */
/*         ==> HEX                                                         */
/*     ==> FORMAT_AUXMAT                                                   */
/*         ==> #RJUST                                                      */
/*         ==> HEX                                                         */
/***************************************************************************/
                                                                                01260000
                                                                                01262000
 /* ROUTINE TO PRETTY PRINT HALMAT/AUXILIARY HALMAT */                          01264000
                                                                                01266000
PRETTY_PRINT_MAT:PROCEDURE;                                                     01268000
                                                                                01270000
      DECLARE MESSAGE CHARACTER;                                                01272000
      DECLARE BLANKS CHARACTER INITIAL(                                         01274000
         '                                             ');                      01276000
      DECLARE CAUXMAT CHARACTER INITIAL('     AUXMAT: ');                       01278000
      DECLARE STMT_NO BIT(1);                                                   01280000
      DECLARE PRETTY_PRINT_CLOCK(1) FIXED;                                      01282000
                                                                                01284000
                                                                                01286000
 /* ROUTINE TO CHECK IF NICE TO SKIP TWO LINES AFTER AN OPERATOR */             01288000
                                                                                01290000
TEST_FOR_SKIP:PROCEDURE;                                                        01292000
                                                                                01294000
         DECLARE OP_CODE BIT(16);                                               01296000
                                                                                01298000
         IF (TEMP_MAT & 1) = 0 THEN DO;                                         01300000
            OP_CODE = SHR(TEMP_MAT, 4) & "FFF";                                 01302000
            IF (OP_CODE <= 4) & (OP_CODE >= 2) THEN STMT_NO = TRUE;             01304000
         END;                                                                   01306000
                                                                                01308000
         CLOSE TEST_FOR_SKIP;                                                   01310000
                                                                                01312000
         OUTPUT = '';                                                           01314000
         OUTPUT = '';                                                           01316000
                                                                                01318000
         PRETTY_PRINT_CLOCK = MONITOR(18);                                      01320000
         STMT_NO = FALSE;                                                       01322000
                                                                                01324000
PRINT_LOOP:                                                                     01326000
         DO WHILE TRUE;                                                         01328000
            IF (HALMAT_PRINT_PTR MOD 1800) <                                    01330000
               (SHR(AUXMAT(AUXMAT_PRINT_PTR - 1), 16) & "7FFF")                 01332000
               THEN DO;                                                         01334000
               IF ((HALMAT(HALMAT_PRINT_PTR) & "FFF0") = "0020") &              01336000
                  ((HALMAT(HALMAT_PRINT_PTR) & 1) = 0) &                        01338000
                 ((AUXMAT(AUXMAT_PRINT_PTR - 1) & "FFFF0000") = "7FFF0000") THEN01340000
                  GO TO PARALLEL_CASE;                                          01342000
               MESSAGE = FORMAT_HALMAT(HALMAT_PRINT_PTR);                       01344000
               TEMP_MAT = HALMAT(HALMAT_PRINT_PTR);                             01346000
               CALL TEST_FOR_SKIP;                                              01348000
               HALMAT_PRINT_PTR = HALMAT_PRINT_PTR + 1;                         01350000
            END;                                                                01352000
            ELSE                                                                01354000
               IF (HALMAT_PRINT_PTR MOD 1800) >                                 01356000
               (SHR(AUXMAT(AUXMAT_PRINT_PTR - 1), 16) & "7FFF") THEN DO;        01358000
               MESSAGE = BLANKS || CAUXMAT || FORMAT_AUXMAT(AUXMAT_PRINT_PTR);  01360000
               AUXMAT_PRINT_PTR = AUXMAT_PRINT_PTR + 2;                         01362000
            END;                                                                01364000
            ELSE DO;                                                            01366000
PARALLEL_CASE:                                                                  01368000
               MESSAGE = FORMAT_HALMAT(HALMAT_PRINT_PTR) || CAUXMAT ||          01370000
                  FORMAT_AUXMAT(AUXMAT_PRINT_PTR);                              01372000
               TEMP_MAT = HALMAT(HALMAT_PRINT_PTR);                             01374000
               CALL TEST_FOR_SKIP;                                              01376000
               AUXMAT_PRINT_PTR = AUXMAT_PRINT_PTR + 2;                         01378000
               HALMAT_PRINT_PTR = HALMAT_PRINT_PTR + 1;                         01380000
            END;                                                                01382000
            OUTPUT = MESSAGE;                                                   01384000
            IF STMT_NO THEN DO;                                                 01386000
               OUTPUT = '';                                                     01388000
               OUTPUT = '';                                                     01390000
               STMT_NO = FALSE;                                                 01392000
            END;                                                                01394000
            IF HALMAT_PRINT_PTR > XREC_PTR THEN DO;                             01396000
               IF BLOCK_PRIME THEN DO;                                          01398000
                  IF HALMAT_PRINT_PTR > XREC_PRIME_PTR THEN DO;                 01400000
                     HALMAT_PRINT_PTR = 0;                                      01402000
                     GO TO EXIT_PRINT_LOOP;                                     01404000
                  END;                                                          01406000
                  ELSE IF HALMAT_PRINT_PTR < HALMAT_SIZE THEN                   01408000
                     HALMAT_PRINT_PTR = 1800;                                   01410000
               END;                                                             01412000
               ELSE DO;                                                         01414000
                  HALMAT_PRINT_PTR = 0;                                         01416000
                  GO TO EXIT_PRINT_LOOP;                                        01418000
               END;                                                             01420000
            END;                                                                01422000
            IF AUXMAT_PRINT_PTR > 1800 THEN DO;                                 01424000
               AUXMAT_PRINT_PTR = 1;                                            01426000
               GO TO EXIT_PRINT_LOOP;                                           01428000
            END;                                                                01430000
         END;                                                                   01432000
EXIT_PRINT_LOOP:                                                                01434000
                                                                                01436000
         PRETTY_PRINT_CLOCK(1) = MONITOR(18);                                   01438000
         TOTAL_PRETTY_PRINT_TIME = TOTAL_PRETTY_PRINT_TIME +                    01440000
            (PRETTY_PRINT_CLOCK(1) - PRETTY_PRINT_CLOCK);                       01442000
                                                                                01444000
         RETURN;                                                                01446000
                                                                                01448000
         CLOSE PRETTY_PRINT_MAT;                                                01450000
