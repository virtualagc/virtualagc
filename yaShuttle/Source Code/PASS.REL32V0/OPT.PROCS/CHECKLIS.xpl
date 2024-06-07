 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKLIS.xpl
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
 /* PROCEDURE NAME:  CHECK_LIST                                             */
 /* MEMBER NAME:     CHECKLIS                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          DN                BIT(8)                                       */
 /*          INX               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          INX2              BIT(16)                                      */
 /*          EXITT             LABEL                                        */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          A_PARITY                                                       */
 /*          C_TRACE                                                        */
 /*          DIFF_NODE                                                      */
 /*          EXTN                                                           */
 /*          FOR                                                            */
 /*          LOOP_HEAD                                                      */
 /*          N_INX                                                          */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORMAT                                                         */
 /*          OPOP                                                           */
 /*          SET_V_M_TAGS                                                   */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_LIST <==                                                      */
 /*     ==> FORMAT                                                          */
 /*     ==> OPOP                                                            */
 /*     ==> SET_V_M_TAGS                                                    */
 /*         ==> LAST_OPERAND                                                */
 /***************************************************************************/
                                                                                01898090
                                                                                01898100
 /* CHECKS FOR REFER BACKS TO CSE'S.  DN = 1 IF POSSIBLE CSE IN PREVIOUS        01898110
      ARRAY.  DN = 0 IF POSSIBLE LOOPY IN PREVIOUS VECTOR LOOP*/                01898120
CHECK_LIST:                                                                     01898130
   PROCEDURE(DN,INX);                                                           01898140
      DECLARE DN BIT(8);                                                        01898150
      DECLARE (TEMP,INX,INX2) BIT(16);                                          01898160
      IF C_TRACE THEN DO;                                                       01898170
         OUTPUT = 'CHECK_LIST(' || DN || ',' || INX || '):';                    01898180
         IF N_INX > 0 THEN OUTPUT =                                             01898190
            '   K   NODE(K) A_PARITY(K)';                                       01898200
         DO FOR TEMP = 1 TO N_INX;                                              01898210
            OUTPUT = FORMAT(TEMP,4) || ' ' ||                                   01898220
               FORMAT(SHR(NODE(TEMP),16),4) || ' ' ||                           01898230
               FORMAT(NODE(TEMP) & "FFFF",4)||                                  01898240
               FORMAT(A_PARITY(TEMP),12);                                       01898250
         END;                                                                   01898260
      END;                                                                      01898270
                                                                                01898280
      DO WHILE INX > 0;                                                         01898290
         IF DN THEN DO;                                                         01898300
            TEMP = DIFF_NODE(INX);                                              01898310
            IF C_TRACE THEN OUTPUT = '   REF=' || TEMP || ', LOOP_HEAD='||      01898320
               LOOP_HEAD;                                                       01898330
            IF TEMP < LOOP_HEAD THEN DO;                                        01898340
               IF OPOP(TEMP) ^= EXTN THEN CALL SET_V_M_TAGS(TEMP,1);            01898350
 /* CALLED WITH PTR*/                                                           01898360
            END;                                                                01898370
         END;                                                                   01898380
         ELSE DO;                                                               01898390
            INX2 = N_INX;                                                       01898400
            DO WHILE INX2 > 0;                                                  01898410
               TEMP = NODE(INX2) & "FFFF";                                      01898420
               IF C_TRACE THEN OUTPUT = '   REF=' || TEMP || ', NODE2(INX)='    01898430
                  ||NODE2(INX);                                                 01898440
               IF TEMP < NODE2(INX) THEN DO;                                    01898450
                  IF SHR(OPR(NODE2(INX)),16) < TEMP THEN DO;                    01898460
                     CALL SET_V_M_TAGS(SHR(OPR(NODE2(INX)),16),0);              01898470
                  END;                                                          01898480
                  GO TO EXITT;                                                  01898490
               END;                                                             01898500
               INX2 = INX2 - 1;                                                 01898510
            END;  /* DO WHILE INX2*/                                            01898520
         END;    /* ELSE DO (^DN)*/                                             01898530
EXITT:                                                                          01898540
         INX = INX - 1;                                                         01898550
      END;   /* DO WHILE INX*/                                                  01898560
   END CHECK_LIST;                                                              01898570
