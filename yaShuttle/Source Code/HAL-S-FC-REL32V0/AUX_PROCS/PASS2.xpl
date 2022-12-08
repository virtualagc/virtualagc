 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PASS2.xpl
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
/* PROCEDURE NAME:  PASS2                                                  */
/* MEMBER NAME:     PASS2                                                  */
/* LOCAL DECLARATIONS:                                                     */
/*          GEN_AUXMAT_END    LABEL                                        */
/*          GEN_AUXRAND(690)  LABEL                                        */
/*          GEN_AUXRATOR(708) LABEL                                        */
/*          GEN_CASE_LIST(684)  LABEL                                      */
/*          GEN_NOOSE(716)    LABEL                                        */
/*          GEN_SNCS          LABEL                                        */
/*          GEN_TARGET        LABEL                                        */
/*          GEN_XREC          LABEL                                        */
/*          PASS2_DISPATCHER  LABEL                                        */
/*          PRINT_AUXMAT_LINE(709)  LABEL                                  */
/*          TEMP_PTR          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AUXMAT_END_OPCODE                                              */
/*          AUXMAT_FILE                                                    */
/*          AUXMAT_REQUESTED                                               */
/*          AUXMAT1                                                        */
/*          AUXM1                                                          */
/*          BLOCK_PRIME                                                    */
/*          CDR_CELL                                                       */
/*          CELL_CDR                                                       */
/*          CELL1                                                          */
/*          CELL1_FLAGS                                                    */
/*          CELL2                                                          */
/*          CELL2_FLAGS                                                    */
/*          CLOSE                                                          */
/*          C1                                                             */
/*          C1_FLAGS                                                       */
/*          C2                                                             */
/*          C2_FLAGS                                                       */
/*          FOR                                                            */
/*          GEN_CODE                                                       */
/*          GENER_CODE                                                     */
/*          HALMAT_SIZE                                                    */
/*          LIST_STRUX                                                     */
/*          MAX_POS                                                        */
/*          NEST_OPCODE                                                    */
/*          NOOSE_OPCODE                                                   */
/*          NOO                                                            */
/*          NOOSE                                                          */
/*          PNTR                                                           */
/*          PNTR_TYPE                                                      */
/*          PRETTY_PRINT_REQUESTED                                         */
/*          PTR_TYPE                                                       */
/*          PTR                                                            */
/*          TAGS                                                           */
/*          TARGET_OPCODE                                                  */
/*          TARGET                                                         */
/*          TGS                                                            */
/*          TRGT                                                           */
/*          TRUE                                                           */
/*          VAC                                                            */
/*          XREC_OPCODE                                                    */
/*          XREC_PRIME_PTR                                                 */
/*          XREC_PTR                                                       */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          AUXMAT                                                         */
/*          AUXMAT_PTR                                                     */
/*          CURR_AUXMAT_BLOCK                                              */
/*          WORK_VARS                                                      */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          FORMAT_AUXMAT                                                  */
/*          PRETTY_PRINT_MAT                                               */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PASS2 <==                                                           */
/*     ==> FORMAT_AUXMAT                                                   */
/*         ==> #RJUST                                                      */
/*         ==> HEX                                                         */
/*     ==> PRETTY_PRINT_MAT                                                */
/*         ==> FORMAT_HALMAT                                               */
/*             ==> #RJUST                                                  */
/*             ==> HEX                                                     */
/*         ==> FORMAT_AUXMAT                                               */
/*             ==> #RJUST                                                  */
/*             ==> HEX                                                     */
/***************************************************************************/
/*   REVISION HISTORY                                                      */
/*                                                                         */
/* DATE      CR/DR    DEVELOPER     DESCRIPTION                            */
/* 03/08/91  CR11109    RSJ         DELETE UNUSED VARIABLES                */
/*                                                                         */
/***************************************************************************/
                                                                                07890000
/*******************************************************************************07892000
         S E C O N D   P A S S   A T   H A L M A T                              07894000
   (THIS ROUTINE TAKES THE INTERMEDIATE LISTS AND GENERATES AUXILIARY HALMAT)   07896000
*******************************************************************************/07898000
                                                                                07900000
PASS2: PROCEDURE;                                                               07902000
                                                                                07904000
   DECLARE TEMP_PTR BIT(16);                                                    07906000
                                                                                07908000
                                                                                07910000
         /* ROUTINE TO PRINT GENERATED AUXMAT IF REQUESTED */                   07912000
                                                                                07914000
PRINT_AUXMAT_LINE: PROCEDURE(AUXMAT#);                                          07916000
                                                                                07918000
   DECLARE AUXMAT# BIT(16);                                                     07920000
                                                                                07922000
   OUTPUT = FORMAT_AUXMAT(AUXMAT#);                                             07924000
                                                                                07926000
CLOSE PRINT_AUXMAT_LINE;                                                        07928000
                                                                                07930000
                                                                                07932000
         /* ROUTINE TO GENERATE AN AUXILIARY HALMAT OPERATOR */                 07934000
                                                                                07936000
GEN_AUXRATOR: PROCEDURE(HALMAT#, PTR_TYPE_VALUE, TAGS_VALUE, OPCODE);           07938000
                                                                                07940000
   DECLARE PTR_TYPE_VALUE BIT(5), TAGS_VALUE BIT(6), HALMAT# BIT(16),           07942000
      OPCODE BIT(4);                                                            07944000
                                                                                07946000
   AUXMAT(AUXMAT_PTR) = SHL(HALMAT#, 16) | SHL(PTR_TYPE_VALUE, 11) |            07948000
      SHL(TAGS_VALUE, 5) | SHL(OPCODE, 1);                                      07950000
   AUXMAT_PTR = AUXMAT_PTR + 1;                                                 07952000
                                                                                07954000
CLOSE GEN_AUXRATOR;                                                             07956000
                                                                                07958000
                                                                                07960000
         /* ROUTINE TO GENERATE AN AUXILIARY HALMAT OPERAND */                  07962000
                                                                                07964000
GEN_AUXRAND: PROCEDURE(NOOSE_VALUE, PTR_VALUE);                                 07966000
                                                                                07968000
   DECLARE (NOOSE_VALUE, PTR_VALUE) BIT(16);                                    07970000
                                                                                07972000
   AUXMAT(AUXMAT_PTR) = SHL(PTR_VALUE, 16) |                                    07974000
      SHL(NOOSE_VALUE & "7FFF", 1) | 1;                                         07976000
   IF AUXMAT_REQUESTED THEN CALL PRINT_AUXMAT_LINE(AUXMAT_PTR);                 07978000
   AUXMAT_PTR = AUXMAT_PTR + 1;                                                 07980000
   IF AUXMAT_PTR = 1800 THEN DO;                                                07982000
      IF PRETTY_PRINT_REQUESTED THEN CALL PRETTY_PRINT_MAT;                     07984000
      FILE(AUXMAT_FILE, CURR_AUXMAT_BLOCK) = AUXMAT;                            07986000
      CURR_AUXMAT_BLOCK = CURR_AUXMAT_BLOCK + 1;                                07988000
      AUXMAT_PTR = 0;                                                           07990000
   END;                                                                         07992000
                                                                                07994000
CLOSE GEN_AUXRAND;                                                              07996000
                                                                                07998000
                                                                                08000000
         /* ROUTINE TO GENERATE A NEXT USE AUXILIARY HALMAT PAIR */             08002000
                                                                                08004000
GEN_NOOSE: PROCEDURE;                                                           08006000
                                                                                08008000
   DECLARE                                                                      08010000
        HALMAT#                        LITERALLY 'TEMP_PTR';                    08012000
                                                                                08014000
   CALL GEN_AUXRATOR(HALMAT# MOD 1800, PTR_TYPE(HALMAT#), 0, NOOSE_OPCODE);     08016000
   CALL GEN_AUXRAND(NOOSE(HALMAT#), PTR(HALMAT#));                              08018000
                                                                                08020000
CLOSE GEN_NOOSE;                                                                08022000
                                                                                08046000
                                                                                08048000
         /* ROUTINE TO GENERATE AN XREC AUXILIARY HALMAT PAIR */                08050000
                                                                                08052000
GEN_XREC: PROCEDURE;                                                            08054000
                                                                                08056000
   DECLARE                                                                      08058000
        HALMAT#                        LITERALLY 'TEMP_PTR';                    08060000
                                                                                08062000
   CALL GEN_AUXRATOR(HALMAT# MOD 1800, 0, 0, XREC_OPCODE);                      08064000
   CALL GEN_AUXRAND(0, 0);                                                      08066000
                                                                                08068000
CLOSE GEN_XREC;                                                                 08070000
                                                                                08072000
                                                                                08074000
         /* ROUTINE TO GENERATE A TARGET AUXILIARY HALMAT PAIR */               08076000
                                                                                08078000
GEN_TARGET: PROCEDURE;                                                          08080000
                                                                                08082000
   DECLARE                                                                      08084000
        HALMAT#                        LITERALLY 'TEMP_PTR';                    08086000
                                                                                08088000
   CALL GEN_AUXRATOR(HALMAT# MOD 1800, VAC, TAGS(HALMAT#), TARGET_OPCODE);      08090000
   CALL GEN_AUXRAND(TARGET(HALMAT#), HALMAT# MOD 1800);                         08092000
                                                                                08094000
CLOSE GEN_TARGET;                                                               08096000
                                                                                08120000
                                                                                08122000
         /* ROUTINE TO GENERATE AN END OF AUXMAT AUXILIARY HALMAT PAIR */       08124000
                                                                                08126000
GEN_AUXMAT_END: PROCEDURE;                                                      08128000
                                                                                08130000
   CALL GEN_AUXRATOR(MAX_POS, 0, 0, AUXMAT_END_OPCODE);                         08138000
   CALL GEN_AUXRAND(0, 0);                                                      08140000
   IF AUXMAT_PTR ^= 0 THEN DO;                                                  08142000
      IF PRETTY_PRINT_REQUESTED THEN CALL PRETTY_PRINT_MAT;                     08144000
      FILE(AUXMAT_FILE, CURR_AUXMAT_BLOCK) = AUXMAT;                            08146000
   END;                                                                         08148000
                                                                                08150000
CLOSE GEN_AUXMAT_END;                                                           08152000
                                                                                08154000
                                                                                08156000
         /* ROUTINE TO GENERATE CASE NEXT USES FROM PASS1 LISTS */              08158000
                                                                                08160000
GEN_CASE_LIST: PROCEDURE(HALMAT#);                                              08162000
                                                                                08164000
   DECLARE HALMAT# BIT(16);                                                     08166000
   DECLARE (TEMP_PTR, TEMP#) BIT(16);                                           08168000
                                                                                08170000
   TEMP_PTR = AUXMAT1(HALMAT#);                                                 08172000
   TEMP# = HALMAT# MOD 1800;                                                    08174000
                                                                                08174500
   IF TARGET(HALMAT#) ^= 0 THEN DO;                                             08175000
      CALL GEN_AUXRATOR(TEMP#, 0, 0, NEST_OPCODE);                              08175500
      CALL GEN_AUXRAND(TARGET(HALMAT#), 0);                                     08176000
      TARGET(HALMAT#) = 0;                                                      08176500
   END;                                                                         08177000
                                                                                08177500
   DO WHILE TRUE;                                                               08178000
      IF (CELL1(TEMP_PTR) = -1) | (CDR_CELL(TEMP_PTR) = 0) THEN                 08180000
         GO TO EXIT_GEN_LOOP;                                                   08182000
      CALL GEN_AUXRATOR(TEMP#, CELL1_FLAGS(TEMP_PTR) & "3F",                    08184000
         CELL2_FLAGS(TEMP_PTR) & "3F", NOOSE_OPCODE);                           08186000
      CALL GEN_AUXRAND(CELL2(TEMP_PTR), CELL1(TEMP_PTR));                       08188000
      TEMP_PTR = CDR_CELL(TEMP_PTR);                                            08190000
   END;                                                                         08192000
EXIT_GEN_LOOP:                                                                  08194000
                                                                                08196000
CLOSE GEN_CASE_LIST;                                                            08198000
                                                                                08200000
                                                                                08202000
         /* ROUTINE TO GENERATE TWO NEXT_USES BASED ON THE SNCS OPCODE */       08204000
                                                                                08206000
GEN_SNCS: PROCEDURE;                                                            08208000
                                                                                08210000
   DECLARE                                                                      08212000
        HALMAT#                        LITERALLY 'TEMP_PTR';                    08214000
                                                                                08216000
   CALL GEN_AUXRATOR(HALMAT# MOD 1800, PTR_TYPE(HALMAT#), 0, NOOSE_OPCODE);     08218000
   CALL GEN_AUXRAND(NOOSE(HALMAT#), PTR(HALMAT#));                              08220000
                                                                                08222000
   CALL GEN_AUXRATOR(HALMAT# MOD 1800, VAC, 0, NOOSE_OPCODE);                   08224000
   CALL GEN_AUXRAND(CELL1(AUXMAT1(HALMAT#)), HALMAT# MOD 1800);                 08226000
                                                                                08228000
CLOSE GEN_SNCS;                                                                 08230000
                                                                                08232000
                                                                                08234000
         /* ROUTINE TO DISPATCH AMONG THE AUXILIARY HALMAT GENERATOR OPCODES */ 08236000
                                                                                08238000
PASS2_DISPATCHER: PROCEDURE;                                                    08240000
                                                                                08242000
   DO CASE GEN_CODE(TEMP_PTR);                                                  08244000
      RETURN;                                                                   08246000
      CALL GEN_NOOSE;                                                           08248000
      ;                                                                         08250000
      CALL GEN_XREC;                                                            08252000
      ;                                                                         08254000
      ;                                                                         08256000
      CALL GEN_AUXMAT_END;                                                      08258000
      CALL GEN_CASE_LIST(TEMP_PTR);                                             08260000
      CALL GEN_SNCS;                                                            08262000
   END;                                                                         08264000
                                                                                08266000
   IF (TAGS(TEMP_PTR) ^= 0) | (TARGET(TEMP_PTR) ^= 0) THEN DO;                  08268000
      CALL GEN_TARGET;                                                          08270000
      TAGS(TEMP_PTR) = 0;                                                       08272000
      TARGET(TEMP_PTR) = 0;                                                     08274000
   END;                                                                         08276000
   NOOSE(TEMP_PTR), AUXMAT1(TEMP_PTR), PTR(TEMP_PTR) = 0;                       08278000
   GEN_CODE(TEMP_PTR), PTR_TYPE(TEMP_PTR) = 0;                                  08280000
                                                                                08282000
CLOSE PASS2_DISPATCHER;                                                         08284000
                                                                                08286000
                                                                                08288000
         /* MAIN BODY OF PASS2 */                                               08290000
                                                                                08292000
   DO FOR TEMP_PTR = 0 TO XREC_PTR;                                             08294000
      CALL PASS2_DISPATCHER;                                                    08296000
   END;                                                                         08298000
   IF BLOCK_PRIME THEN                                                          08300000
      DO FOR TEMP_PTR = HALMAT_SIZE TO XREC_PRIME_PTR;                          08302000
         CALL PASS2_DISPATCHER;                                                 08304000
      END;                                                                      08306000
                                                                                08308000
CLOSE PASS2 /* $S+ */ ; /* $S@ */                                               08310000
