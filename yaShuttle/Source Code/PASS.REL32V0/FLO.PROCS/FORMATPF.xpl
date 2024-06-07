 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMATPF.xpl
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
 /* PROCEDURE NAME:  FORMAT_PF_INV_CELL                                     */
 /* MEMBER NAME:     FORMATPF                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          #ASSIGN           BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LEVEL                                                          */
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
 /* ==> FORMAT_PF_INV_CELL <==                                              */
 /*     ==> LOCATE                                                          */
 /*     ==> HEX                                                             */
 /*     ==> FLUSH                                                           */
 /*     ==> STACK_PTR                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /***************************************************************************/
                                                                                00289100
FORMAT_PF_INV_CELL:                                                             00289200
   PROCEDURE (PTR);                                                             00289300
      DECLARE (#ASSIGN,J,K) BIT(16), PTR FIXED;                                 00289400
                                                                                00289500
      CALL LOCATE(PTR,ADDR(VMEM_H),0);                                          00289600
      COREWORD(ADDR(VMEM_F)) = VMEM_LOC_ADDR;                                   00289700
      S = SYT_NAME(VMEM_H(3));                                                  00289800
      #ASSIGN = VMEM_H(1) - VMEM_H(2);                                          00289900
      IF #ASSIGN>0 THEN DO;                                                     00290000
         S(2) = '';                                                             00290100
         DO J = 1 TO #ASSIGN;                                                   00290200
            K = VMEM_H(1) + 2 - J;                                              00290300
            IF VMEM_F(K) = 0 THEN S(2) = ',-' || S(2);                          00290400
            ELSE IF (VMEM_F(K) & "C0000000") = "C0000000" THEN                  00290500
               S(2) = ','||SYT_NAME(VMEM_F(K) & "3FFFFFFF")||S(2);              00290600
            ELSE DO;                                                            00290700
               CALL STACK_PTR(VMEM_F(K),LEVEL+1);                               00290800
               S(2)= ','||HEX(VMEM_F(K) & "3FFFFFFF",8)||S(2);                  00290900
            END;                                                                00290901
         END;                                                                   00291000
         S(2) = ' ASSIGN(' || SUBSTR(S(2),1) || ')';                            00291100
      END;                                                                      00291200
      ELSE S(2) = '';                                                           00291300
      S(1) = ')';                                                               00291400
      IF VMEM_H(2) > 0 THEN DO;                                                 00291500
         DO J = 1 TO VMEM_H(2);                                                 00291600
            K = VMEM_H(2) + 2 - J;                                              00291700
            IF VMEM_F(K) = 0 THEN S(1) = ',-' || S(1);                          00291800
            ELSE IF(VMEM_F(K) & "C0000000") = "C0000000" THEN                   00291900
               S(1) = ','||SYT_NAME(VMEM_F(K) & "3FFFFFFF")||S(1);              00292000
            ELSE DO;                                                            00292100
               CALL STACK_PTR(VMEM_F(K),LEVEL+1);                               00292200
               S(1) = ','||HEX(VMEM_F(K) & "3FFFFFFF",8)||S(1);                 00292300
            END;                                                                00292400
         END;                                                                   00292500
         S(1) = SUBSTR(S(1),1);                                                 00292600
      END;                                                                      00292700
      S(1) = '(' || S(1);                                                       00292800
      CALL FLUSH(2);                                                            00292900
   END FORMAT_PF_INV_CELL;                                                      00293000
