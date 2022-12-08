 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STRUCTU2.xpl
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
 /* PROCEDURE NAME:  STRUCTURE_WALK                                         */
 /* MEMBER NAME:     STRUCTU2                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL              FIXED                                        */
 /*          I                 BIT(16)                                      */
 /*          INITOP            BIT(16)                                      */
 /*          INITWALK          BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          N                 BIT(16)                                      */
 /*          NODE_F            FIXED                                        */
 /*          OLD_CELL          FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOREVER                                                        */
 /*          NAME_FLAG                                                      */
 /*          PROC_TRACE                                                     */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          STRUCT_TEMPL                                                   */
 /*          SYM_FLAGS                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_FLAGS                                                      */
 /*          SYT_NAME                                                       */
 /*          TEMPL_INX                                                      */
 /*          TEMPL_LIST                                                     */
 /*          TRUE                                                           */
 /*          VMEM_LOC_ADDR                                                  */
 /*          WALK_TRACE                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          MSG                                                            */
 /*          STRUCT_REF                                                     */
 /*          TEMPL_WIDTH                                                    */
 /*          TERM_LIST_HEAD                                                 */
 /*          VMEM_H                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /*          LUMP_ARRAYSIZE                                                 */
 /*          LUMP_TERMINALSIZE                                              */
 /*          PTR_LOCATE                                                     */
 /*          STRUCTURE_ADVANCE                                              */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STRUCTURE_WALK <==                                                  */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> GET_CELL                                                        */
 /*     ==> LUMP_ARRAYSIZE                                                  */
 /*     ==> LUMP_TERMINALSIZE                                               */
 /*     ==> STRUCTURE_ADVANCE                                               */
 /*         ==> DESCENDENT                                                  */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*         ==> SUCCESSOR                                                   */
 /***************************************************************************/
                                                                                00158600
 /* ROUTINE TO WALK THRU A TEMPLATE TO COLLECT QUALIFIED NAMES AND              00158700
INITIALIZATION OFFSETS OF NAME TERMINALS */                                     00158800
STRUCTURE_WALK:                                                                 00158900
   PROCEDURE ;                                                                  00159000
      DECLARE (OLD_CELL,CELL) FIXED,                                            00159100
         (I,J,N,INITOP,INITWALK) BIT(16);                                       00159200
      BASED NODE_F FIXED;                                                       00159300
                                                                                00159400
      IF PROC_TRACE THEN OUTPUT='STRUCTURE_WALK('||SYT_NAME(STRUCT_TEMPL)||')'; 00159401
      STRUCT_REF,TERM_LIST_HEAD = 0;                                            00159500
      INITWALK = -1;                                                            00159600
      N = 1;                                                                    00159700
      DO FOREVER;                                                               00159800
         IF N = 1 THEN DO;                                                      00159900
            INITOP = STRUCTURE_ADVANCE;                                         00160000
            IF WALK_TRACE THEN DO;                                              00160001
               MSG = '';                                                        00160002
               DO J = 1 TO TEMPL_INX;                                           00160003
                  MSG=MSG||SYT_NAME(TEMPL_LIST(J))||'.';                        00160004
               END;                                                             00160005
               OUTPUT=MSG||SYT_NAME(INITOP);                                    00160006
            END;                                                                00160007
            IF INITOP = 0 THEN DO;                                              00160100
               IF TERM_LIST_HEAD ^= 0 THEN CALL PTR_LOCATE(OLD_CELL,RELS);      00160200
               TEMPL_WIDTH = INITWALK + 1;                                      00160300
               RETURN;                                                          00160400
            END;                                                                00160500
            INITWALK = INITWALK + 1;                                            00160600
            IF (SYT_FLAGS(INITOP) & NAME_FLAG) ^= 0 THEN DO;                    00160700
               N = 1;                                                           00160800
               CELL = GET_CELL(SHL(TEMPL_INX+5,1),ADDR(VMEM_H),RESV);           00160900
               IF TERM_LIST_HEAD = 0 THEN DO;                                   00161000
                  TERM_LIST_HEAD = CELL;                                        00161100
                  COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;                       00161105
               END;                                                             00161200
               ELSE DO;                                                         00161300
                  NODE_F(1) = CELL;                                             00161400
                  COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;                       00161405
                  CALL PTR_LOCATE(OLD_CELL,RELS);                               00161500
               END;                                                             00161600
               VMEM_H(0) = INITWALK;                                            00161700
               VMEM_H(1) = TEMPL_INX + 1;                                       00161800
               DO I = 1 TO TEMPL_INX;                                           00161900
                  VMEM_H(I+3) = TEMPL_LIST(I);                                  00162000
               END;                                                             00162100
               VMEM_H(TEMPL_INX+4) = INITOP;                                    00162200
               OLD_CELL = CELL;                                                 00162300
            END;                                                                00162500
            ELSE N = LUMP_ARRAYSIZE(INITOP) * LUMP_TERMINALSIZE(INITOP);        00162600
         END;                                                                   00162700
         ELSE DO;                                                               00162800
            N = N - 1;                                                          00162900
            INITWALK = INITWALK + 1;                                            00163000
         END;                                                                   00163100
      END;                                                                      00163200
   END STRUCTURE_WALK;                                                          00163300
