 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OUTPUTSD.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2024-06-14 RSB  Suffixed the filename with ".xpl".  Somehow I
    				forgot to do this when I did all of the other
    				HAL/S-FC source-code files.
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  OUTPUT_SDF                                             */
 /* MEMBER NAME:     OUTPUTSD                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHAR_STRING       CHARACTER;                                   */
 /*          I                 FIXED                                        */
 /*          NAME              CHARACTER;                                   */
 /*          NODE_F            FIXED                                        */
 /*          NODE_H            BIT(16)                                      */
 /*          PTR               FIXED                                        */
 /*          TEMP              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #EXECS                                                         */
 /*          FREE_CHAIN                                                     */
 /*          LAST_PAGE                                                      */
 /*          LIT_ADDR                                                       */
 /*          LOC_ADDR                                                       */
 /*          MAX_PAGE                                                       */
 /*          MODF                                                           */
 /*          OVERFLOW_FLAG                                                  */
 /*          PAD_ADDR                                                       */
 /*          PHASE1_DATE                                                    */
 /*          PHASE1_TIME                                                    */
 /*          ROOT_PTR                                                       */
 /*          SDF_NAM1                                                       */
 /*          SDF_NAM2                                                       */
 /*          SELFNAMELOC                                                    */
 /*          SRN_FLAG1                                                      */
 /*          SRN_FLAG2                                                      */
 /*          VERSION#                                                       */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMM                                                           */
 /*          DATA_FREE_SPACE                                                */
 /*          DIR_FREE_SPACE                                                 */
 /*          TMP                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          KOREWORD                                                       */
 /*          P3_DISP                                                        */
 /*          P3_LOCATE                                                      */
 /*          P3_PTR_LOCATE                                                  */
 /*          SDF_NAME                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> OUTPUT_SDF <==                                                      */
 /*     ==> KOREWORD                                                        */
 /*     ==> SDF_NAME                                                        */
 /*         ==> CHAR_INDEX                                                  */
 /*     ==> P3_DISP                                                         */
 /*     ==> P3_PTR_LOCATE                                                   */
 /*         ==> HEX8                                                        */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_DISP                                                     */
 /*         ==> PAGING_STRATEGY                                             */
 /*     ==> P3_LOCATE                                                       */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/07/91 DKB  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /* 04/27/93 RSJ  25V0  CR11097  EMILINATE USE OF NOTELISTS IN THE          */
 /*                9V0           HAL COMPILER                               */
 /*                                                                         */
 /* 06/04/99 SMR  30V0  CR13079  ADD HAL/S INITIALIZATION DATA TO SDF       */
 /*               15V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00229905
 /* ROUTINE TO EMIT THE COMPLETED SDF */                                        00229910
                                                                                00229915
OUTPUT_SDF:                                                                     00229920
   PROCEDURE;                                                                   00229925
      DECLARE (NAME,CHAR_STRING) CHARACTER, (TEMP,I,PTR) FIXED;                 00229930
      BASED NODE_F FIXED, NODE_H BIT(16);                                       00229935
                                                                                00230100
 /* CALCULATE THE TOTAL AMOUNT OF SPACE IN THE DIRECTORY FREE */                00230200
 /* CELL CHAIN.  ALSO TIE THE END OF THE CHAIN TO THE START   */                00230300
 /* OF THE DATA FREE CELL CHAIN SO THAT ALL UNUSED SPACE IS   */                00230400
 /* LINKED TOGETHER.                                          */                00230500
                                                                                00230600
      DIR_FREE_SPACE = 0;                                                       00230800
      CALL P3_LOCATE(0,ADDR(NODE_F),MODF);                                      00230900
      COREWORD(ADDR(NODE_H)) = LOC_ADDR;                                        00230910
      NODE_H(0) = VERSION#;                                                     00230920
      NODE_H(1) = 0;      /* FOR FUTURE USE */                                  00230930
      PTR = NODE_F(1);                                                          00231000
      DO WHILE PTR ^= 0;                                                        00231100
         CALL P3_LOCATE(PTR,ADDR(NODE_F),0);                                    00231200
         DIR_FREE_SPACE = DIR_FREE_SPACE + NODE_F(0);                           00231300
         PTR = NODE_F(1);                                                       00231400
      END;                                                                      00231500
      NODE_F(1) = FREE_CHAIN;                                                   00231600
      CALL P3_DISP(MODF);                                                       00231700
                                                                                00231800
 /* CALCULATE THE TOTAL AMOUNT OF SPACE IN THE DATA FREE CELL */                00231900
 /* CHAIN.  ALSO CLOSE OFF ITS END BY INSERTING A ZERO PTR   */                 00232000
                                                                                00232100
      DATA_FREE_SPACE = 0;                                                      00232200
      CALL P3_LOCATE(FREE_CHAIN,ADDR(NODE_F),0);                                00232300
      PTR = NODE_F(1);                                                          00232400
      /*PAGES STARTING FROM FIRST#D_PAGE CONTAIN ONLY #P/#D */
      /*INFORMATION.  IGNORE THESE WHEN LOOKING FOR FREE SPACE*/
      TEMP = SHL((FIRST#D_PAGE),16); /*CR13079*/
      DO WHILE PTR ^= TEMP;                                                     00232600
         CALL P3_LOCATE(PTR,ADDR(NODE_F),0);                                    00232700
         DATA_FREE_SPACE = DATA_FREE_SPACE + NODE_F(0);                         00232800
         PTR = NODE_F(1);                                                       00232900
      END;                                                                      00233000
      NODE_F(1) = 0;                                                            00233100
      CALL P3_DISP(MODF);                                                       00233200
                                                                                00233300
 /* INSERT REMAINDER OF DATA ITEMS IN THE SDF DIRECTORY ROOT NODE */            00233400
                                                                                00233500
      CALL P3_LOCATE(ROOT_PTR,ADDR(NODE_F),MODF);                               00233600
      COREWORD(ADDR(NODE_H)) = LOC_ADDR;                                        00233700
      IF OVERFLOW_FLAG THEN NODE_H(0) = NODE_H(0)|"0800";                       00233800
      IF SRN_FLAG1 THEN NODE_H(0) = NODE_H(0)|"0400";                           00233900
      IF SRN_FLAG2 THEN NODE_H(0) = NODE_H(0)|"0200";                           00234000
      NODE_F(1) = PHASE1_DATE;                                                  00234100
      NODE_F(2) = PHASE1_TIME;                                                  00234200
      NODE_H(1) = LAST_PAGE;                                                    00234300
      IF LIT_ADDR = COMM(23)    /*  DATA HWM  */                                00234301
         THEN NODE_H(21) = -1;                                                  00234302
      ELSE                                                                      00234303
         NODE_H(21) = LIT_ADDR;                                                 00234305
      NODE_H(58) = DIR_FREE_SPACE + DATA_FREE_SPACE;                            00234400
      NODE_H(28) = #EXECS;                                                      00234500
                                                                                00234600
 /* WRITE OUT ALL OF THE SDF PAGES ONTO OUTPUT FILE 5 */                        00234700
                                                                                00234800
      NAME = SDF_NAME(SELFNAMELOC);                                             00234805
      CALL MONITOR(14,8,NAME);  /* ALLOW MONITOR TO DO A BLDL (IN SDFOUT) */    00234900
      CALL MONITOR(14,0,LAST_PAGE);  /* DEFINE THE LENGTH OF THE SDF */         00235000
      CALL MONITOR(14,4,PAD_ADDR(MAX_PAGE + 1));  /* PROVIDE A BUFFER AREA */   00235100
      DO I = 0 TO LAST_PAGE;                                                    00235300
         CALL P3_PTR_LOCATE(SHL(I,16),0);                                       00235400
         CALL MONITOR(14, 4, LOC_ADDR);                                         00235700
      END;                                                                      00235800
                                                                                00298600
 /* CLOSE OUTPUT FILE 5 AND NAME THE PDS MEMBER */                              00298700
                                                                                00298800
      CHAR_STRING = 'CREATED';                                                  00299000
      IF MONITOR(14, 8, NAME) THEN CHAR_STRING = 'REPLACED';                    00299100
      OUTPUT = X1;                                                              00299200
      OUTPUT = 'SIMULATION DATA FILE '|| NAME ||' HAS BEEN '|| CHAR_STRING;     00299300
      CALL MONITOR(16,"20");     /* TELL THE SDL THAT ALL IS OK */              00299400
      TMP = COREWORD(ADDR(NAME))&"FFFFFF";                                      00299410
      SDF_NAM1 = KOREWORD(TMP);                                                 00299420
      SDF_NAM2 = KOREWORD(TMP+4);                                               00299430
   END OUTPUT_SDF;                                                              00299600
