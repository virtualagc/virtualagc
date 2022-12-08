 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETVMTAG.xpl
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
 /* PROCEDURE NAME:  SET_V_M_TAGS                                           */
 /* MEMBER NAME:     SETVMTAG                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          CSE               BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          INX               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          C_TRACE                                                        */
 /*          N_INX                                                          */
 /*          OR                                                             */
 /*          OUT_OF_ARRAY_TAG                                               */
 /*          OUTSIDE_REF_TAG                                                */
 /*          TAG_BIT                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_PARITY                                                       */
 /*          NODE                                                           */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OPERAND                                                   */
 /* CALLED BY:                                                              */
 /*          CHECK_LIST                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_V_M_TAGS <==                                                    */
 /*     ==> LAST_OPERAND                                                    */
 /***************************************************************************/
                                                                                01897760
                                                                                01897770
                                                                                01897780
 /* SETS TAG FIELD BITS FOR CSE'S IN V/M LOOPS*/                                01897790
SET_V_M_TAGS:                                                                   01897800
   PROCEDURE(PTR,CSE);                                                          01897810
      DECLARE CSE BIT(8);                                                       01897820
      DECLARE (PTR,I) BIT(16);                                                  01897830
                                                                                01897840
      DECLARE INX BIT(16);                                                      01897850
      INX = N_INX;                                                              01897860
      NODE,A_PARITY = 0;                                                        01897870
                                                                                01897880
      DO WHILE SHR(NODE(INX),16) > PTR;                                         01897890
         INX = INX - 1;                                                         01897900
      END;                                                                      01897910
                                                                                01897920
      DO WHILE INX > 0 AND ((NODE(INX) & "FFFF") > PTR                          01897930
            OR A_PARITY(INX) & CSE);                                            01897940
                                                                                01897950
         IF ^(CSE & A_PARITY(INX)) AND (NODE(INX) & "FFFF") > PTR THEN DO;      01897960
            I = LAST_OPERAND(SHR(NODE(INX),16));                                01897970
            OPR(I) = OPR(I) | OUTSIDE_REF_TAG;                                  01897980
            IF CSE THEN                                                         01897990
               OPR(PTR) = OPR(PTR) | OUT_OF_ARRAY_TAG;                          01898000
            ELSE                                                                01898010
               OPR(PTR) = OPR(PTR) | TAG_BIT;                                   01898020
            IF C_TRACE THEN OUTPUT = 'SET_V_M_TAGS:  ' ||I || ',' || PTR;       01898030
            RETURN;                                                             01898040
         END;                                                                   01898050
         INX = INX - 1;                                                         01898060
      END;                                                                      01898070
   END SET_V_M_TAGS;                                                            01898080
