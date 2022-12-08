 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DUMPSTMT.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  DUMP_STMT_HALMAT                                       */
 /* MEMBER NAME:     DUMPSTMT                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL              BIT(16)                                      */
 /*          HALMAT            LABEL                                        */
 /*          HLINK             FIXED                                        */
 /*          HNODE             FIXED                                        */
 /*          SLINK             FIXED                                        */
 /*          SNODE             FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          FOREVER                                                        */
 /*          NILL                                                           */
 /*          STMT_DATA_HEAD                                                 */
 /*          TRUE                                                           */
 /*          XREC_WORD                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LOCATE                                                         */
 /*          HEX                                                            */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DUMP_STMT_HALMAT <==                                                */
 /*     ==> LOCATE                                                          */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                00140010
 /* PROCEDURE TO DUMP STMT HALMAT */                                            00140020
DUMP_STMT_HALMAT:                                                               00140030
   PROCEDURE;                                                                   00140040
      BASED (SNODE,HNODE) FIXED;                                                00140050
      DECLARE (SLINK,HLINK) FIXED,                                              00140060
         CELL BIT (16);                                                         00140070
      SLINK = STMT_DATA_HEAD;                                                   00140080
      DO FOREVER;                                                               00140090
         IF SLINK = NILL THEN RETURN;                                           00140100
         CALL LOCATE(SLINK,ADDR(SNODE),0);                                      00140110
         OUTPUT = '';                                                           00140120
         OUTPUT = 'STATEMENT ' || SHR(SNODE(7),16);                             00140130
         HLINK = SNODE(-1);                                                     00140140
         SLINK = SNODE(0);                                                      00140150
HALMAT:  DO FOREVER;                                                            00140160
            IF HLINK = NILL THEN ESCAPE HALMAT;                                 00140170
            CALL LOCATE(HLINK,ADDR(HNODE),0);                                   00140180
            CELL = 0;                                                           00140190
            DO WHILE HNODE(CELL) ^= XREC_WORD;                                  00140200
               OUTPUT = HEX(HNODE(CELL));                                       00140210
               CELL = CELL+1;                                                   00140220
            END;                                                                00140230
            HLINK = HNODE(CELL+1);                                              00140240
         END HALMAT;                                                            00140250
      END;                                                                      00140260
   END DUMP_STMT_HALMAT;                                                        00140270
