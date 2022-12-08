 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMOPER.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  FORM_OPERATOR                                          */
 /* MEMBER NAME:     FORMOPER                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          H_INX             BIT(16)                                      */
 /*          PARITY            BIT(8)                                       */
 /*          TAG               BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          MSG               CHARACTER;                                   */
 /*          TMP               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OP                                                             */
 /*          REVERSE_OP                                                     */
 /*          TAG_BIT                                                        */
 /*          TRACE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          SET_WORDS                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORM_OPERATOR <==                                                   */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                01687000
 /* FORMS HALMAT OPERATOR WORD*/                                                01688000
FORM_OPERATOR:                                                                  01689000
   PROCEDURE(H_INX,PARITY,TAG);                                                 01690000
      DECLARE H_INX BIT(16),                                                    01691000
         MSG CHARACTER,                                                         01692000
         (PARITY,TAG) BIT(8);                                                   01693000
      DECLARE TMP FIXED;                                                        01693010
                                                                                01693020
      TMP = OPR(H_INX) & TAG_BIT;   /* FOR V/M INLINE*/                         01693030
                                                                                01693040
      DO CASE PARITY;                                                           01694000
         OPR(H_INX) = SHL("2000"|OP,4) | SHL(TAG,3);                            01695000
         OPR(H_INX) = SHL("2000"|REVERSE_OP,4) |SHL(TAG,3);                     01696000
      END; /* DO CASE*/                                                         01697000
      OPR(H_INX) = OPR(H_INX) | TMP;                                            01697010
      TAG = 0;                                                                  01698000
      IF TRACE THEN DO;                                                         01699000
         MSG = HEX(OPR(H_INX),8);                                               01700000
         OUTPUT = 'FORM_OPERATOR(' || H_INX || '): ' || MSG;                    01701000
      END;                                                                      01702000
      PARITY,TAG = 0;                                                           01703000
   END FORM_OPERATOR;                                                           01704000
