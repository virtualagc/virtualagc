 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMATFO.xpl
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
 /* PROCEDURE NAME:  FORMAT_FORM_PARM_CELL                                  */
 /* MEMBER NAME:     FORMATFO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SYMB#             BIT(16)                                      */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LINELENGTH                                                     */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          VMEM_B                                                         */
 /*          VMEM_H                                                         */
 /*          VMEM_LOC_ADDR                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /*          FLUSH                                                          */
 /*          LOCATE                                                         */
 /* CALLED BY:                                                              */
 /*          FORMAT_SYT_VPTRS                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORMAT_FORM_PARM_CELL <==                                           */
 /*     ==> LOCATE                                                          */
 /*     ==> HEX                                                             */
 /*     ==> FLUSH                                                           */
 /***************************************************************************/
                                                                                00275800
FORMAT_FORM_PARM_CELL:                                                          00275900
   PROCEDURE (SYMB#,PTR) ;                                                      00276000
      DECLARE (J,K,SYMB#) BIT(16), PTR FIXED;                                   00276100
                                                                                00276200
      S = HEX(PTR,8) || ' --> ' || SYT_NAME(SYMB#) || '(';                      00276300
      CALL LOCATE(PTR,ADDR(VMEM_H),0);                                          00276400
      COREWORD(ADDR(VMEM_B)) = VMEM_LOC_ADDR;                                   00276500
      K = 0;                                                                    00276600
      IF VMEM_B(3) > 0 THEN DO;                                                 00276700
         DO J = 2 TO VMEM_B(3) + 1;                                             00276800
            IF LENGTH(S(K)) > LINELENGTH THEN K = K + 1;                        00276900
            S(K) = S(K) || SYT_NAME(VMEM_H(J)) || ',';                          00277000
         END;                                                                   00277100
         BYTE(S(K),LENGTH(S(K))-1) = BYTE(')');                                 00277200
      END;                                                                      00277300
      ELSE S = S || ')';                                                        00277400
      IF VMEM_B(2) > VMEM_B(3) THEN DO;                                         00277500
         S(K) = S(K) || ' ASSIGN(';                                             00277600
         DO J = VMEM_B(3)+2 TO VMEM_B(2)+1;                                     00277700
            IF LENGTH(S(K)) > LINELENGTH THEN K = K + 1;                        00277800
            S(K) = S(K) || SYT_NAME(VMEM_H(J)) || ',';                          00277900
         END;                                                                   00278000
         BYTE(S(K),LENGTH(S(K))-1) = BYTE(')');                                 00278100
      END;                                                                      00278200
      CALL FLUSH(K);                                                            00278300
   END FORMAT_FORM_PARM_CELL;                                                   00278400
