 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATBL.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_BLAB                                            */
 /* MEMBER NAME:     HALMATBL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          ANY_ATOM          FIXED                                        */
 /*          I                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BLAB1             CHARACTER;                                   */
 /*          BLAB2             CHARACTER;                                   */
 /*          C                 CHARACTER;                                   */
 /*          ICNT              BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X70                                                            */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /*          I_FORMAT                                                       */
 /* CALLED BY:                                                              */
 /*          HALMAT_OUT                                                     */
 /*          HALMAT                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> HALMAT_BLAB <==                                                     */
 /*     ==> HEX                                                             */
 /*     ==> I_FORMAT                                                        */
 /***************************************************************************/
                                                                                00789900
HALMAT_BLAB:                                                                    00790000
   PROCEDURE (ANY_ATOM,I);                                                      00790100
      DECLARE (ANY_ATOM,I)FIXED;                                                00790200
      DECLARE C CHARACTER,                                                      00790300
         BLAB1 CHARACTER INITIAL('0ND    X'),                                   00790400
         BLAB2 CHARACTER                                                        00790500
    INITIAL('  0 SYT INL VAC XPT LIT IMD AST CSZ ASZ OFF                     ');00790600
      DECLARE (ICNT,J) BIT(16);                                                 00790700
                                                                                00790800
      IF ANY_ATOM THEN DO;                                                      00790900
 /* PIP ATOM */                                                                 00791000
         C=HEX(SHR(ANY_ATOM,1)&"7",1);                                          00791100
         C=HEX(SHR(ANY_ATOM,8)&"FF",2)||','||C;                                 00791200
         C=SUBSTR(BLAB2,SHR(ANY_ATOM,2)&"3C",3)||')'||C;                        00791300
         J=SHR(ANY_ATOM,16);                                                    00791400
         C=I_FORMAT(J,7)||'('||C;                                               00791500
         C='  :'||C;                                                            00791600
         IF ICNT=4 THEN DO;                                                     00791700
            ICNT=1;                                                             00791800
            C=SUBSTR(X70,0,36)||C;                                              00791900
         END;                                                                   00792000
         ELSE DO;                                                               00792100
            C='+'||SUBSTR(X70,0,ICNT*20+35)||C;                                 00792200
            ICNT=ICNT+1;                                                        00792300
         END;                                                                   00792400
      END;                                                                      00792500
      ELSE DO;                                                                  00792600
 /* POP ATOM */                                                                 00792700
         C=HEX(SHR(ANY_ATOM,24),2);                                             00792800
         C='),'||SUBSTR(BLAB1,SHR(ANY_ATOM,1)&"7",1)||','||C;                   00792900
         C=I_FORMAT(SHR(ANY_ATOM,16)&"FF",3)||C;                                00793000
         C=HEX(SHR(ANY_ATOM,4)&"FFF",3)||'('||C;                                00793100
         IF HALMAT_OK THEN DO;                                                  00793200
            C=I_FORMAT(I,5)||':   '||C;                                         00793300
            C='  HALMAT LINE '||C;                                              00793400
         END;                                                                   00793500
         ELSE C='     UNSAVED HALMAT:   '||C;                                   00793600
         ICNT=0;                                                                00793700
      END;                                                                      00793800
      OUTPUT(1)=C;                                                              00793900
   END HALMAT_BLAB;                                                             00794000
