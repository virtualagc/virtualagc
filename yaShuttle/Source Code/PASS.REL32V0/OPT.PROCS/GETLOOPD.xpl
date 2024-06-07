 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETLOOPD.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_LOOP_DIMENSION                                     */
 /* MEMBER NAME:     GETLOOPD                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          DSUB_FLAG         BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TO_START          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ALPHA                                                          */
 /*          ARRAY_DIMENSIONS                                               */
 /*          BETA                                                           */
 /*          COMPONENT_SIZE                                                 */
 /*          FLAG                                                           */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /*          SUB_TRACE                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DSUB_INX                                                       */
 /*          LOOP_DIMENSION                                                 */
 /*          PRESENT_DIMENSION                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMPUTE_DIM_CONSTANT                                           */
 /*          COMPUTE_DIMENSIONS                                             */
 /*          LAST_OPERAND                                                   */
 /*          SET_VAR                                                        */
 /* CALLED BY:                                                              */
 /*          SEARCH_DIMENSION                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_LOOP_DIMENSION <==                                              */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> SET_VAR                                                         */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> LAST_OPERAND                                                */
 /*     ==> COMPUTE_DIM_CONSTANT                                            */
 /*         ==> SAVE_LITERAL                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GET_LITERAL                                             */
 /*         ==> TEMPLATE_LIT                                                */
 /*             ==> STRUCTURE_COMPARE                                       */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GENERATE_TEMPLATE_LIT                                   */
 /*                 ==> SAVE_LITERAL                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> GET_LITERAL                                     */
 /*         ==> INT_TO_SCALAR                                               */
 /*             ==> HEX                                                     */
 /*     ==> COMPUTE_DIMENSIONS                                              */
 /***************************************************************************/
                                                                                02373120
 /* RETURNS NO OF ELEMENTS IN VECTOR OR MATRIX.  IF DSUB_FLAG = 1 THEN PTR      02373130
      IS TO A DSUB.  OTHERWISE OPR(PTR) POINTS TO SYT_TABLE*/                   02373140
GET_LOOP_DIMENSION:                                                             02373150
   PROCEDURE(PTR,DSUB_FLAG) BIT(16);                                            02373160
      DECLARE (PTR,TO_START) BIT(16);                                           02373170
      DECLARE DSUB_FLAG BIT(8);                                                 02373180
      CALL SET_VAR(PTR + DSUB_FLAG);    /* SETS VAR*/                           02373190
      CALL COMPUTE_DIMENSIONS;                                                  02373200
      IF DSUB_FLAG THEN DO;                                                     02373210
                                                                                02373220
         DSUB_FLAG = 0;                                                         02373230
                                                                                02373240
         PRESENT_DIMENSION = 0;                                                 02373250
         LOOP_DIMENSION = 1;                                                    02373260
                                                                                02373270
         DO FOR DSUB_INX = PTR + 2 TO LAST_OPERAND(PTR);                        02373280
                                                                                02373290
            DO CASE ALPHA;                                                      02373300
                                                                                02373310
               DO;    /* 0 = * */                                               02373320
                  PRESENT_DIMENSION = PRESENT_DIMENSION + 1;                    02373330
                  IF PRESENT_DIMENSION > ARRAY_DIMENSIONS THEN                  02373340
                     LOOP_DIMENSION = LOOP_DIMENSION * COMPONENT_SIZE           02373350
                     (PRESENT_DIMENSION);                                       02373360
               END;                                                             02373370
                                                                                02373380
               PRESENT_DIMENSION = PRESENT_DIMENSION + 1;    /* 1 = INDEX*/     02373390
                                                                                02373400
               DO;                                           /* 2 = TO */       02373410
                  IF BETA THEN DO;                                              02373420
                     PRESENT_DIMENSION = PRESENT_DIMENSION + 1;                 02373430
                     TO_START = SHR(OPR(DSUB_INX),16);                          02373440
                  END;                                                          02373450
                  ELSE IF PRESENT_DIMENSION > ARRAY_DIMENSIONS THEN DO;         02373460
                     LOOP_DIMENSION =                                           02373470
                        LOOP_DIMENSION * (SHR(OPR(DSUB_INX),16) - TO_START + 1);02373480
                  END;                                                          02373490
               END;                                                             02373500
                                                                                02373510
               DO;                                            /* 3 = AT*/       02373520
                  IF BETA THEN DO;                                              02373530
                     PRESENT_DIMENSION = PRESENT_DIMENSION + 1;                 02373540
                     IF PRESENT_DIMENSION > ARRAY_DIMENSIONS THEN               02373550
                        LOOP_DIMENSION = LOOP_DIMENSION * SHR(OPR(DSUB_INX),16);02373560
                  END;                                                          02373570
               END;                                                             02373580
                                                                                02373590
            END;   /* DO CASE*/                                                 02373600
         END;   /* DO FOR*/                                                     02373610
      END;  /* DSUB FLAG*/                                                      02373620
                                                                                02373630
      ELSE DO;                                                                  02373640
         PRESENT_DIMENSION = ARRAY_DIMENSIONS;                                  02373650
         LOOP_DIMENSION = COMPUTE_DIM_CONSTANT(1);                              02373660
      END;                                                                      02373670
                                                                                02373680
      IF SUB_TRACE THEN                                                         02373690
         OUTPUT = 'GET_LOOP_DIMENSION(' ||PTR|| ',' || FLAG || ') = ' ||        02373700
         LOOP_DIMENSION;                                                        02373710
      RETURN LOOP_DIMENSION;                                                    02373720
   END GET_LOOP_DIMENSION;                                                      02373730
