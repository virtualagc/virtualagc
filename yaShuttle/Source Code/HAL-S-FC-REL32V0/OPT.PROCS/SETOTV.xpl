 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETOTV.xpl
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
 /* PROCEDURE NAME:  SET_O_T_V                                              */
 /* MEMBER NAME:     SETOTV                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          VAC_PTR           BIT(16)                                      */
 /*          NOT_OUTER         BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CTR               BIT(16)                                      */
 /*          TYPE              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          END_OF_NODE                                                    */
 /*          NEW_NODE_PTR                                                   */
 /*          NODE2                                                          */
 /*          OUTER_TERMINAL_VAC                                             */
 /*          TERMINAL_VAC                                                   */
 /*          TRACE                                                          */
 /*          TYPE_MASK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NODE                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CSE_WORD_FORMAT                                                */
 /* CALLED BY:                                                              */
 /*          STRIP_NODES                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_O_T_V <==                                                       */
 /*     ==> CSE_WORD_FORMAT                                                 */
 /*         ==> HEX                                                         */
 /***************************************************************************/
                                                                                02176000
 /* FINDS TERMINAL VAC REFERENCING PTR AND CHANGES IT TO OUTER_TERMINAL         02177000
      _VAC, RETURNING INDEX OF OPERATOR NODE*/                                  02178000
SET_O_T_V:                                                                      02179000
   PROCEDURE(PTR,VAC_PTR,NOT_OUTER) BIT(16);                                    02180000
      DECLARE (PTR,CTR,VAC_PTR) BIT(16);                                        02181000
      DECLARE NOT_OUTER BIT(8);                                                 02182000
      DECLARE TYPE FIXED;                                                       02183000
                                                                                02184000
      IF TRACE THEN OUTPUT = 'SET_O_T_V:  PTR '||PTR;                           02185000
                                                                                02186000
      IF NOT_OUTER THEN DO;                                                     02187000
         NOT_OUTER = 0;                                                         02188000
         TYPE = TERMINAL_VAC;                                                   02189000
      END;                                                                      02190000
      ELSE TYPE = OUTER_TERMINAL_VAC;                                           02191000
                                                                                02192000
      IF PTR = 0 | NODE2(PTR) = 0 THEN RETURN 0;                                02193000
      CTR = NODE2(NODE2(PTR));     /*OPERATOR*/                                 02194000
      IF CTR ^= 0 THEN DO;                                                      02195000
         CTR = CTR - 1;                                                         02196000
         DO WHILE NODE(CTR) ^= END_OF_NODE;                                     02197000
            IF (NODE(CTR) & TYPE_MASK) = TERMINAL_VAC THEN                      02198000
               IF (NODE(CTR) & "FFFF") = VAC_PTR                                02199000
               THEN DO;                                                         02200000
               NODE(CTR) = (NODE(CTR) & "F 0 0000") | TYPE                      02201000
                  | NEW_NODE_PTR;                                               02202000
               IF TRACE THEN                                                    02202010
                  OUTPUT = '   ' || CSE_WORD_FORMAT(NODE(CTR));                 02202020
               RETURN CTR;                                                      02203000
            END;                                                                02204000
            CTR = CTR - 1;                                                      02205000
         END;                                                                   02206000
      END;                                                                      02206010
      IF TRACE THEN OUTPUT =                                                    02206012
         '   RETURN 0, CTR = ' || CTR || ', NODE(CTR + 1) = ' || CSE_WORD_FORMAT02206014
         (NODE(CTR + 1));                                                       02206016
      RETURN 0;                                                                 02206020
   END SET_O_T_V;                                                               02206030
