 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DOEACHTE.xpl
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
 /* PROCEDURE NAME:  DO_EACH_TERMINAL                                       */
 /* MEMBER NAME:     DOEACHTE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          #SYTS             BIT(16)                                      */
 /*          INIT_CELL         FIXED                                        */
 /*          J                 BIT(16)                                      */
 /*          NODE_H            BIT(16)                                      */
 /*          OFFSET            BIT(16)                                      */
 /*          SDF_PAGE_BYTES    BIT(16)                                      */
 /*          SDF_PAGE_WORDS    BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          END_OF_LIST_OP                                                 */
 /*          MODF                                                           */
 /*          PROC_TRACE                                                     */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          VMEM_LOC_ADDR                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CELLSIZE                                                       */
 /*          INIT_LIST_HEAD                                                 */
 /*          INIT_WORD_START                                                */
 /*          SAVE_ADDR                                                      */
 /*          TERM_LIST_HEAD                                                 */
 /*          VMEM_F                                                         */
 /*          VMEM_H                                                         */
 /*          WORD_INX                                                       */
 /*          WORD_STACK                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /*          LOCATE                                                         */
 /*          MOVE                                                           */
 /*          TRAVERSE_INIT_LIST                                             */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DO_EACH_TERMINAL <==                                                */
 /*     ==> MOVE                                                            */
 /*     ==> GET_CELL                                                        */
 /*     ==> LOCATE                                                          */
 /*     ==> TRAVERSE_INIT_LIST                                              */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> MOVE                                                        */
 /*         ==> DISP                                                        */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> GET_CELL                                                    */
 /*         ==> LOCATE                                                      */
 /*         ==> FORMAT                                                      */
 /*         ==> POPCODE                                                     */
 /*         ==> POPVAL                                                      */
 /*         ==> TYPE_BITS                                                   */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /*  DATE      DEV  REL     DR/CR     TITLE                                 */
 /*                                                                         */
 /*  04/12/01  DCP  31V0/   DR111361  NAME INITIALIZATION INFORMATION       */
 /*                 16V0              MISSING IN SDF                        */
 /*                                                                         */
 /***************************************************************************/
                                                                                00227600
 /* CALLS TRAVERSE_INIT_LIST FOR EACH TERMINAL WHEN INIT LIST HAS /*DR111361*/  00227700
 /* VALUES FOR NAME TERMINALS                                     /*DR111361*/  00227800
DO_EACH_TERMINAL:                                                               00227900
   PROCEDURE (CTR);                                                             00228000
      DECLARE (CTR,J,OFFSET,#SYTS) BIT(16), INIT_CELL FIXED;                    00228100
      DECLARE SDF_PAGE_BYTES BIT(16) INITIAL(1680),                             00228110
         SDF_PAGE_WORDS BIT(16) INITIAL(420);                                   00228120
      BASED NODE_H BIT(16);                                                     00228200
                                                                                00228300
      IF PROC_TRACE THEN OUTPUT='DO_EACH_TERMINAL';                             00228301
      DO WHILE TERM_LIST_HEAD ^= 0;                                             00228400
         CALL LOCATE(TERM_LIST_HEAD,ADDR(NODE_H),RESV);                         00228500
         OFFSET = NODE_H(0);                                                    00228600
         #SYTS = NODE_H(1);                                                     00228700
         SAVE_ADDR = VMEM_LOC_ADDR;                                             00228800
         WORD_INX = 0;                                                          00228900
         CALL TRAVERSE_INIT_LIST(CTR,OFFSET);                     /*DR111361*/  00229000
         WORD_INX = WORD_INX + 1;                                               00229100
         WORD_STACK(WORD_INX) = END_OF_LIST_OP;                                 00229200
         INIT_WORD_START = SHR(#SYTS+5,1);                                      00229300
         CELLSIZE = SHL(INIT_WORD_START + WORD_INX,2);                          00229400
         DO WHILE CELLSIZE > SDF_PAGE_BYTES;                                    00229404
            CTR = WORD_INX - SDF_PAGE_WORDS + 1;                                00229408
            J = 1;                                                              00229412
            DO WHILE J <= CTR;                                                  00229416
               DO CASE SHR(WORD_STACK(J),16);                                   00229420
                  J = J + 2;                                                    00229424
                  J = J + 2;                                                    00229428
                  J = J + 1;                                                    00229432
                  J = J + 1;                                                    00229436
               END;                                                             00229440
            END;                                                                00229444
            CELLSIZE = SHL(WORD_INX-J+2,2);                                     00229448
            INIT_CELL = GET_CELL(CELLSIZE,ADDR(VMEM_F),MODF);                   00229452
            VMEM_F(0) = SHL(CELLSIZE,16);                                       00229456
            CALL MOVE(CELLSIZE-4,ADDR(WORD_STACK(J)),VMEM_LOC_ADDR+4);          00229460
            WORD_STACK(J) = END_OF_LIST_OP + 1;                                 00229464
            WORD_INX = J+1;                                                     00229468
            WORD_STACK(WORD_INX) = INIT_CELL;                                   00229472
            CELLSIZE = SHL(INIT_WORD_START + WORD_INX,2);                       00229476
         END;                                                                   00229480
         INIT_CELL = GET_CELL(CELLSIZE,ADDR(VMEM_F),MODF);                      00229500
         CALL MOVE(SHL(INIT_WORD_START,2),SAVE_ADDR,VMEM_LOC_ADDR);             00229600
         INIT_WORD_START = INIT_WORD_START - 1;                                 00229700
         DO J = 1 TO WORD_INX;                                                  00229800
            VMEM_F(INIT_WORD_START + J) = WORD_STACK(J);                        00229900
         END;                                                                   00230000
         COREWORD(ADDR(VMEM_H)) = VMEM_LOC_ADDR;                                00230100
         VMEM_H(0) = CELLSIZE;                                                  00230200
         VMEM_F(1) = INIT_LIST_HEAD;                                            00230300
         INIT_LIST_HEAD = INIT_CELL;                                            00230400
         CALL LOCATE(TERM_LIST_HEAD,ADDR(VMEM_F),RELS);                         00230401
         TERM_LIST_HEAD = VMEM_F(1);                                            00230500
      END;                                                                      00230600
   END DO_EACH_TERMINAL;                                                        00230700
