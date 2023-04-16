 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ARRAYEDE.xpl
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
 /* PROCEDURE NAME:  ARRAYED_ELT                                            */
 /* MEMBER NAME:     ARRAYEDE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          NODE_WORD         FIXED                                        */
 /*          NODE2_WORD        BIT(16)                                      */
 /*          DSUB_FLAG         BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          RET               BIT(8)                                       */
 /*          TEMP              BIT(16)                                      */
 /*          TERM_VAC          LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          DA_MASK                                                        */
 /*          EXTN                                                           */
 /*          I_TRACE                                                        */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /*          STACK_TRACE                                                    */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CSE_WORD_FORMAT                                                */
 /*          TYPE                                                           */
 /* CALLED BY:                                                              */
 /*          INVAR                                                          */
 /*          CHECK_INVAR                                                    */
 /*          SET_ARRAYNESS                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ARRAYED_ELT <==                                                     */
 /*     ==> CSE_WORD_FORMAT                                                 */
 /*         ==> HEX                                                         */
 /*     ==> TYPE                                                            */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 05/10/99 SMR  30V0  DR111323 BS122 ERROR FOR NAME STRUCTURE COMPARE     */
 /*               15V0                                                      */
 /*                                                                         */
 /***************************************************************************/

 /* DETERMINES WHETHER NODE LIST ENTRY IS ARRAYED.  USED AFTER GET NODE SO      01891120
      NO SYT ENTRIES*/                                                          01891130
ARRAYED_ELT:                                                                    01891140
   PROCEDURE(NODE_WORD,NODE2_WORD,DSUB_FLAG) BIT(8);                            01891150
      DECLARE NODE_WORD FIXED;                                                  01891160
      DECLARE (NODE2_WORD,TEMP) BIT(16),                                        01891170
         (RET,DSUB_FLAG) BIT(8);                                                01891180
      RET = 0;                                                                  01891190
      DO CASE TYPE(NODE_WORD);                                                  01891200
         ;                                                                      01891210
         ;   /* NO SYT*/                                                        01891220
         ;                                                                      01891230
         DO;   /* 3 = TERM VAC*/                                                01891240
TERM_VAC:                                                                       01891250
            TEMP = NODE2((NODE_WORD & "FFFF") + 1);   /* INDEX OF OP OF NODE    01891260
                                                        REFERENCED BY VAC */    01891261
            RET = SHR((NODE(TEMP) & DA_MASK),29);                               01891262
            IF (NODE(TEMP) & "FFFF") = EXTN AND ^DSUB_FLAG THEN DO;/*DR111323*/ 01891263
               IF NODE(TEMP-1)=DUMMY_NODE THEN RET = RET | 2;      /*DR111323*/
               ELSE RET = RET | SYT_ARRAY(NODE2(TEMP - 1)) ^= 0;   /*DR111323*/ 01891264
            END;                                                   /*DR111323*/
         END;                                                                   01891270
         ;;;;;;;                                                                01891280
            DO;  /* B = VALUE NO*/                                              01891290
            RET = SYT_ARRAY(NODE2_WORD) ^= 0;                                   01891300
         END;                                                                   01891310
         GO TO TERM_VAC;   /* C = OUTER TERM VAC*/                              01891320
         RET = 2;   /* D = DUMMY*/                                              01891330
         ;;                                                                     01891340
         END;   /* DO CASE*/                                                    01891350
                                                                                01891360
      IF I_TRACE THEN OUTPUT =                                                  01891370
         'ARRAYED_ELT(' || CSE_WORD_FORMAT(NODE_WORD) || ',' || NODE2_WORD ||   01891380
         '):  ' || RET;                                                         01891390
      RETURN RET;                                                               01891400
   END ARRAYED_ELT;                                                             01891410
