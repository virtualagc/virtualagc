 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMATEX.xpl
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
 /* PROCEDURE NAME:  FORMAT_EXP_VARS_CELL                                   */
 /* MEMBER NAME:     FORMATEX                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          #SYTS             BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          L                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LEVEL                                                          */
 /*          LINELENGTH                                                     */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          VMEM_F                                                         */
 /*          VMEM_H                                                         */
 /*          VMEM_LOC_ADDR                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FLUSH                                                          */
 /*          HEX                                                            */
 /*          LOCATE                                                         */
 /*          STACK_PTR                                                      */
 /* CALLED BY:                                                              */
 /*          FORMAT_CELL_TREE                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORMAT_EXP_VARS_CELL <==                                            */
 /*     ==> LOCATE                                                          */
 /*     ==> HEX                                                             */
 /*     ==> FLUSH                                                           */
 /*     ==> STACK_PTR                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /***************************************************************************/
                                                                                00284900
FORMAT_EXP_VARS_CELL:                                                           00285000
   PROCEDURE (PTR);                                                             00285100
      DECLARE (I,J,K,L,#SYTS) BIT(16), PTR FIXED;                               00285200
                                                                                00285300
      CALL LOCATE(PTR,ADDR(VMEM_H),0);                                          00285400
      COREWORD(ADDR(VMEM_F)) = VMEM_LOC_ADDR;                                   00285500
      #SYTS = VMEM_H(1);                                                        00285600
      S = HEX(PTR,8) || ' --> ';                                                00285700
      L = 1;                                                                    00285800
      IF #SYTS > 0 THEN DO;                                                     00285900
         J = 2;                                                                 00286000
         DO WHILE J<=#SYTS+1;                                                   00286100
            IF LENGTH(S(L)) > LINELENGTH THEN L = L + 1;                        00286200
            IF VMEM_H(J) >= 0 THEN S(L) = S(L)||','||SYT_NAME(VMEM_H(J));       00286300
            ELSE DO;                                                            00286400
               J = J + 1;                                                       00286500
               S(L) = S(L)||','||SYT_NAME(VMEM_H(J));                           00286600
               DO K = 2 TO -VMEM_H(J-1);                                        00286700
                  J = J + 1;                                                    00286800
                  S(L) = S(L)||'.'||SYT_NAME(VMEM_H(J));                        00286900
               END;                                                             00287000
            END;                                                                00287100
            J = J + 1;                                                          00287200
         END;                                                                   00287300
      END;                                                                      00287400
      I = SHR(#SYTS+3,1);                                                       00287500
      K = SHR(VMEM_H(0),2)-1;                                                   00287600
      DO J = I TO K;                                                            00287700
         IF LENGTH(S(L)) > LINELENGTH THEN L = L + 1;                           00287800
         IF (VMEM_F(J) & "C0000000") = "C0000000" THEN                          00287900
            S(L) = S(L) || ',' || (VMEM_F(J) & "3FFFFFFF");                     00288000
         ELSE DO;                                                               00288200
            CALL STACK_PTR(VMEM_F(I+K-J),LEVEL+1);                              00288300
            S(L) = S(L) || ',' || HEX(VMEM_F(J),8);                             00288400
         END;                                                                   00288500
      END;                                                                      00288600
      S(L) = S(L) || ')';                                                       00288700
      BYTE(S(1)) = BYTE('(');                                                   00288800
      CALL FLUSH(L);                                                            00288900
   END FORMAT_EXP_VARS_CELL;                                                    00289000
