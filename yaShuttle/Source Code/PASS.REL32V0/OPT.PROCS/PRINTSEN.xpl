 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTSEN.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  PRINT_SENTENCE                                         */
 /* MEMBER NAME:     PRINTSEN                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          MSG               CHARACTER;                                   */
 /*          PRINT             LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FLAG                                                           */
 /*          NODE                                                           */
 /*          OPR                                                            */
 /*          XSMRK                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORMAT                                                         */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          CLASSIFY                                                       */
 /*          COLLAPSE_LITERALS                                              */
 /*          COLLECT_MATCHES                                                */
 /*          EJECT_INVARS                                                   */
 /*          ELIMINATE_DIVIDES                                              */
 /*          FLAG_MATCHES                                                   */
 /*          REARRANGE_HALMAT                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PRINT_SENTENCE <==                                                  */
 /*     ==> FORMAT                                                          */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                01274000
 /* PRINTS HALMAT TO END OF SENTENCE*/                                          01275000
PRINT_SENTENCE:                                                                 01276000
   PROCEDURE(PTR);                                                              01277000
      DECLARE PTR BIT(16);                                                      01278000
      DECLARE MSG CHARACTER;                                                    01279000
      OUTPUT = '';                                                              01280000
      OUTPUT ='  NO.     OPR     PTR  TYPE FLAG    TAG TAG8    RELOC';          01281000
                                                                                01282000
 /* LOCAL ROUTINE TO PRINT LINE*/                                               01283000
PRINT:                                                                          01284000
      PROCEDURE;                                                                01285000
         IF OPR(PTR) &                                                          01286000
            SHR(OPR(PTR),3) THEN MSG = FORMAT(NODE(SHR(OPR(PTR),16))&"FFFF",5); 01287000
         ELSE IF (OPR(PTR)&"FFF1")=XSMRK THEN MSG=' ST#='||SHR(OPR(PTR+1),16);  01288000
         ELSE MSG = '';                                                         01289000
         IF OPR(PTR) THEN MSG = HEX(SHR(OPR(PTR),8) & "FF",2) ||'   '||MSG;     01289100
         ELSE MSG = HEX(SHR(OPR(PTR),24),2) || '   ' || MSG;                    01289200
         MSG = FORMAT(SHR(OPR(PTR),1) & "7",2) ||'   '||MSG;                    01290000
         MSG = FORMAT(FLAG(PTR),2) || '     ' || MSG;                           01291000
         IF ^ OPR(PTR) THEN                                                     01292000
            DO;                                                                 01293000
            MSG = HEX(SHR(OPR(PTR),4)&"FFF",3) || '                '||MSG;      01294000
         END;                                                                   01295000
         ELSE DO;                                                               01296000
            MSG = HEX(SHR(OPR(PTR),4),1) || '   ' ||MSG;                        01297000
            MSG = FORMAT(SHR(OPR(PTR),16),5) || '    ' ||MSG;                   01298000
            MSG = '      ' || MSG;                                              01299000
         END;                                                                   01300000
         OUTPUT = FORMAT(PTR,5) || ' :   ' || MSG;                              01301000
                                                                                01302000
      END PRINT;                                                                01303000
                                                                                01304000
      CALL PRINT;                                                               01305000
      DO WHILE (OPR(PTR) & "FFF1") ^= XSMRK;                                    01306000
         PTR = PTR + 1;                                                         01307000
         CALL PRINT;                                                            01308000
      END; /*DO WHILE*/                                                         01309000
   END PRINT_SENTENCE;                                                          01310000
