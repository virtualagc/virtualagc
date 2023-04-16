 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETUPREA.xpl
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
 /* PROCEDURE NAME:  SETUP_REARRANGE                                        */
 /* MEMBER NAME:     SETUPREA                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          LOOP_INVAR        BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          INX               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CSE                                                            */
 /*          CSE_FOUND_INX                                                  */
 /*          END_OF_NODE                                                    */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          GET_INX                                                        */
 /*          N_INX                                                          */
 /*          NODE                                                           */
 /*          NODE_BEGINNING                                                 */
 /*          NONCOMMUTATIVE                                                 */
 /*          NOP                                                            */
 /*          OPR                                                            */
 /*          OR                                                             */
 /*          PREVIOUS_NODE_OPERAND                                          */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          VDLP                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FNPARITY0#                                                     */
 /*          FNPARITY1#                                                     */
 /*          LOOP_DIMENSION                                                 */
 /*          LOOPY_OPS                                                      */
 /*          MPARITY0#                                                      */
 /*          MPARITY1#                                                      */
 /*          NEW_NODE_PTR                                                   */
 /*          OP2                                                            */
 /*          OP                                                             */
 /*          PNPARITY0#                                                     */
 /*          PNPARITY1#                                                     */
 /*          PRESENT_HALMAT                                                 */
 /*          TEMP                                                           */
 /*          TOTAL_MATCH_PRES                                               */
 /*          TOTAL_MATCH_PREV                                               */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CLASSIFY                                                       */
 /*          LAST_OP                                                        */
 /*          LOOPY                                                          */
 /* CALLED BY:                                                              */
 /*          PULL_INVARS                                                    */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SETUP_REARRANGE <==                                                 */
 /*     ==> LAST_OP                                                         */
 /*     ==> CLASSIFY                                                        */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*     ==> LOOPY                                                           */
 /*         ==> GET_CLASS                                                   */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> NO_OPERANDS                                                 */
 /***************************************************************************/
                                                                                03756000
 /* GETS STATISTICS FOR REARRANGE_HALMAT AND MAKES FINAL CHECKS*/               03757000
SETUP_REARRANGE:                                                                03758000
   PROCEDURE(LOOP_INVAR) BIT(8);         /* MUST BE CALLED WITH ALL OPERATORS*/ 03759000
      DECLARE LOOP_INVAR BIT(8);                                                03759010
      DECLARE INX BIT(16);                                                      03760000
      IF TRACE THEN OUTPUT = 'SETUP_REARRANGE';                                 03761000
      IF NONCOMMUTATIVE THEN DO;                                                03762000
         PNPARITY0#,FNPARITY0#,MPARITY0# = CSE_FOUND_INX - 1;;                  03763000
            PNPARITY1#,FNPARITY1#,MPARITY1# = 0;                                03764000
         TOTAL_MATCH_PREV,TOTAL_MATCH_PRES = TRUE;                              03765000
      END;                                                                      03767000
      ELSE DO;                                                                  03767010
         MPARITY1# = 0;                                                         03768000
         DO FOR INX = 1 TO CSE_FOUND_INX - 1;                                   03769000
            IF SHR(CSE(INX),20) THEN MPARITY1# = MPARITY1# + 1;                 03770000
         END;                                                                   03771000
         MPARITY0# = CSE_FOUND_INX - MPARITY1# - 1;                             03772000
         INX = NODE_BEGINNING - 1; /* FIRST OPERATOR OF FORWARD WORD*/          03773000
         FNPARITY0#, FNPARITY1# = 0;                                            03774000
         DO WHILE NODE(INX) ^= END_OF_NODE;                                     03775000
            IF NODE(INX) ^= 0 THEN DO;                                          03776000
               IF SHR(NODE(INX),20) THEN FNPARITY1# = FNPARITY1# + 1;           03777000
               ELSE FNPARITY0# = FNPARITY0# + 1;                                03778000
            END;                                                                03779000
            INX = INX - 1;                                                      03780000
         END;                                                                   03781000
         TOTAL_MATCH_PRES = FNPARITY0# + FNPARITY1# = CSE_FOUND_INX - 1;        03782000
                                                                                03782010
         IF LOOP_INVAR THEN DO;                                                 03782020
            PNPARITY0# = FNPARITY0#;                                            03782030
            PNPARITY1# = FNPARITY1#;                                            03782040
         END;                                                                   03782050
                                                                                03782060
         ELSE DO;                                                               03782070
            PNPARITY0#,PNPARITY1# = 0;                                          03783000
            INX = PREVIOUS_NODE_OPERAND ;                                       03784000
            DO WHILE NODE(INX) ^= END_OF_NODE;                                  03785000
               IF NODE(INX) ^= 0 THEN DO;                                       03786000
                  IF SHR(NODE(INX),20) THEN PNPARITY1# = PNPARITY1# + 1;        03787000
                  ELSE PNPARITY0# = PNPARITY0# + 1;                             03788000
               END;                                                             03789000
               INX = INX - 1;                                                   03790000
            END;                                                                03791000
         END;                                                                   03791010
      END;   /* ELSE DO ^ NONCOMMUTATIVE*/                                      03791020
                                                                                03791030
      IF ^LOOP_INVAR THEN DO;                                                   03791040
         PRESENT_HALMAT = NODE(GET_INX + 1) & "FFFF";                           03791050
      END;                                                                      03791060
      ELSE DO;                                                                  03791070
         LOOPY_OPS = FALSE;                                                     03791080
         IF LOOPY(PRESENT_HALMAT) THEN DO;                                      03791090
            OP = CLASSIFY(PRESENT_HALMAT);                                      03791100
            TEMP = LAST_OP(PRESENT_HALMAT - 1);                                 03791110
            OP2 = CLASSIFY(TEMP);                                               03791120
            DO WHILE OP2 = OP OR OP2 = NOP;                                     03791130
               TEMP = LAST_OP(TEMP - 1);                                        03791140
               OP2 = CLASSIFY(TEMP);                                            03791150
            END;                                                                03791160
            IF OPR(TEMP) = VDLP THEN DO;                                        03791170
               LOOPY_OPS = TRUE;                                                03791180
               LOOP_DIMENSION = SHR(OPR(TEMP + 1),16);                          03791190
            END;                                                                03791200
         END;   /* IF LOOPY*/                                                   03791210
      END;                                                                      03791220
      NEW_NODE_PTR = N_INX;                                                     03792000
      RETURN TRUE;                                                              03793000
   END SETUP_REARRANGE;                                                         03794000
