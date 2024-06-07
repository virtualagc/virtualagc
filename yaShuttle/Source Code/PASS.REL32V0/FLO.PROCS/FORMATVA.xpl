 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMATVA.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  FORMAT_VAR_REF_CELL                                    */
 /* MEMBER NAME:     FORMATVA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /*          NO_PRINT          BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          #SYTS             BIT(16)                                      */
 /*          ALPHA             BIT(8)                                       */
 /*          BETA              BIT(8)                                       */
 /*          EXP_STRINGS(4)    CHARACTER;                                   */
 /*          EXP_TYPE          BIT(8)                                       */
 /*          J                 BIT(16)                                      */
 /*          LAST_SUB_TYPE     BIT(16)                                      */
 /*          SUB_STRINGS(2)    CHARACTER;                                   */
 /*          SUB_TYPE          BIT(8)                                       */
 /*          SUBSCRIPTS        BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          LEVEL                                                          */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          TRUE                                                           */
 /*          VMEM_F                                                         */
 /*          VMEM_H                                                         */
 /*          VMEM_LOC_ADDR                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /*          MSG                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FLUSH                                                          */
 /*          HEX                                                            */
 /*          LOCATE                                                         */
 /*          STACK_PTR                                                      */
 /* CALLED BY:                                                              */
 /*          FORMAT_CELL_TREE                                               */
 /*          FORMAT_NAME_TERM_CELLS                                         */
 /*          FORMAT_SYT_VPTRS                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORMAT_VAR_REF_CELL <==                                             */
 /*     ==> LOCATE                                                          */
 /*     ==> HEX                                                             */
 /*     ==> FLUSH                                                           */
 /*     ==> STACK_PTR                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /***************************************************************************/
                                                                                00278500
FORMAT_VAR_REF_CELL:                                                            00278600
   PROCEDURE (PTR,NO_PRINT);                                                    00278700
      DECLARE (#SYTS,J,LAST_SUB_TYPE) BIT(16), PTR FIXED,                       00278800
         (NO_PRINT,SUBSCRIPTS,ALPHA,SUB_TYPE,BETA,EXP_TYPE) BIT(8),             00278900
         SUB_STRINGS(2) CHARACTER INITIAL('',':',';'),                          00279000
         EXP_STRINGS(4) CHARACTER INITIAL('','#+','#-','','#');                 00279100
                                                                                00279200
      CALL LOCATE(PTR,ADDR(VMEM_H),0);                                          00279300
      COREWORD(ADDR(VMEM_F)) = VMEM_LOC_ADDR;                                   00279400
      IF VMEM_H(1) < 0 THEN DO;                                                 00279500
         SUBSCRIPTS = TRUE;                                                     00279600
         #SYTS = VMEM_H(1) & "7FFF";                                            00279700
      END;                                                                      00279800
      ELSE DO;                                                                  00279900
         SUBSCRIPTS = FALSE;                                                    00280000
         #SYTS = VMEM_H(1);                                                     00280100
      END;                                                                      00280200
      MSG = HEX(PTR,8) || ' --> ' || SYT_NAME(VMEM_H(4));                       00280300
      DO J = 5 TO #SYTS+3;                                                      00280400
         MSG = MSG || '.' || SYT_NAME(VMEM_H(J));                               00280500
      END;                                                                      00280600
      IF ^SUBSCRIPTS THEN DO;                                                   00280700
         IF NO_PRINT THEN MSG = SUBSTR(MSG,13);                                 00280701
         ELSE DO;                                                               00280702
            S = MSG;                                                            00280703
            CALL FLUSH(0);                                                      00280800
         END;                                                                   00280801
         NO_PRINT = FALSE;                                                      00280802
         RETURN;                                                                00280900
      END;                                                                      00281000
      J = #SYTS + 4;                                                            00281100
      MSG(1) = '$(';                                                            00281200
      MSG(2), MSG(3) = '';                                                      00281300
      LAST_SUB_TYPE = -1;                                                       00281400
      DO WHILE J <= SHR(VMEM_H(0),1) - 1;                                       00281500
         ALPHA = SHR(VMEM_H(J),8) & 3;                                          00281600
         SUB_TYPE = SHR(VMEM_H(J),10) & 3;                                      00281700
         BETA = VMEM_H(J) & "F";                                                00281800
         EXP_TYPE = SHR(VMEM_H(J),4) & "F";                                     00281900
         MSG(3) = MSG(3) || EXP_STRINGS(SHR(EXP_TYPE,1));                       00282000
         IF EXP_TYPE THEN DO;                                                   00282100
            J = J + 1;                                                          00282200
            MSG(3) = MSG(3) || VMEM_H(J);                                       00282300
         END;                                                                   00282400
         ELSE MSG(3) = MSG(3) || '?';                                           00282500
         DO CASE ALPHA;                                                         00282600
            MSG(3) = '*';                                                       00282700
            ;                                                                   00282800
            IF BETA THEN MSG(3) = MSG(3) || ' TO ';                             00282900
            IF BETA THEN MSG(3) = MSG(3) || ' AT ';                             00283000
         END;                                                                   00283100
         IF BETA = 0 THEN DO;                                                   00283200
            IF LAST_SUB_TYPE >= 0 THEN                                          00283300
              IF SUB_TYPE^=LAST_SUB_TYPE THEN MSG(2)=SUB_STRINGS(LAST_SUB_TYPE);00283400
            ELSE MSG(2) = ',';                                                  00283500
            LAST_SUB_TYPE = SUB_TYPE;                                           00283600
            MSG(1) = MSG(1) || MSG(2) || MSG(3);                                00283700
            MSG(3) = '';                                                        00283800
         END;                                                                   00283900
         J = J + 1;                                                             00283901
      END;                                                                      00284000
      IF SUB_TYPE=1 | SUB_TYPE=2 THEN MSG(1)=MSG(1)||SUB_STRINGS(SUB_TYPE);     00284001
      MSG(1) = MSG(1) || ')';                                                   00284100
      MSG(2), MSG(3) = '';                                                      00284200
      IF VMEM_F(1) ^= 0 THEN DO;                                                00284300
         MSG(1) = MSG(1) || ' , ' || HEX(VMEM_F(1),8);                          00284400
         CALL STACK_PTR(VMEM_F(1) | "80000000",LEVEL+1);                        00284500
      END;                                                                      00284600
      IF NO_PRINT THEN MSG = SUBSTR(MSG,13) || MSG(1);                          00284601
      ELSE DO;                                                                  00284700
         S = MSG;                                                               00284701
         S(1) = MSG(1);                                                         00284702
         CALL FLUSH(1);                                                         00284703
      END;                                                                      00284704
      NO_PRINT = FALSE;                                                         00284710
   END FORMAT_VAR_REF_CELL;                                                     00284800
