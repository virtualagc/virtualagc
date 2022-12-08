 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETADLP.xpl
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
 /* PROCEDURE NAME:  GET_ADLP                                               */
 /* MEMBER NAME:     GETADLP                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          OP                BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          REPEATT           LABEL                                        */
 /*          EXITT             LABEL                                        */
 /*          RET               BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADLP_WORD                                                      */
 /*          DLPE                                                           */
 /*          DLPE_WORD                                                      */
 /*          END_OF_NODE                                                    */
 /*          I_TRACE                                                        */
 /*          NODE                                                           */
 /*          OPR                                                            */
 /*          OR                                                             */
 /*          SMRK                                                           */
 /*          STACK_TRACE                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          OPOP                                                           */
 /*          LAST_OP                                                        */
 /* CALLED BY:                                                              */
 /*          CSE_MATCH_FOUND                                                */
 /*          EJECT_INVARS                                                   */
 /*          PULL_INVARS                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_ADLP <==                                                        */
 /*     ==> OPOP                                                            */
 /*     ==> LAST_OP                                                         */
 /***************************************************************************/
                                                                                01890810
 /* LOOKS BACK TO ADLP & RETURNS ITS PTR.  IF OP THEN PTR IS IN NODE LIST       01890820
      TO OP.  OTHERWISE PTR IS TO HALMAT*/                                      01890830
 /* IF OP AND ADLP PRECEEDED BY DLPE THEN REPEATS SO LOOP                       01890840
      COMBINING WORKS BETTER*/                                                  01890850
GET_ADLP:                                                                       01890860
   PROCEDURE(PTR,OP) BIT(16);                                                   01890870
      DECLARE OP BIT(8);                                                        01890880
      DECLARE (PTR,RET) BIT(16);                                                01890890
      DECLARE TEMP BIT(16);                                                     01890891
      RET = PTR;                                                                01890900
      IF OP THEN DO;                                                            01890910
         DO WHILE NODE(RET) ^= END_OF_NODE;                                     01890920
            RET = RET - 1;                                                      01890930
         END;                                                                   01890940
         RET = NODE(RET - 1) & "FFFF";  /* HALMAT PTR*/                         01890950
      END;                                                                      01890960
                                                                                01890970
REPEATT:                                                                        01890980
      RET = LAST_OP(RET - 1);                                                   01890990
      DO WHILE (OPR(RET) & "FFF8") ^= ADLP_WORD;                                01891000
                                                                                01891001
 /* THIS IS NEEDED FOR SHAPING FUNCTIONS */                                     01891002
         TEMP = OPOP(RET);                                                      01891003
         IF TEMP = SMRK OR TEMP = DLPE OR RET < 0 THEN DO;                      01891004
            RET = -1;                                                           01891005
            GO TO EXITT;                                                        01891006
         END;                                                                   01891007
                                                                                01891009
         RET = LAST_OP(RET - 1);                                                01891010
      END;                                                                      01891020
      IF OP THEN DO;                                                            01891030
         TEMP = LAST_OP(RET - 1);                                               01891033
         IF (OPR(TEMP) & "FFF8") = DLPE_WORD THEN DO;                           01891036
            RET = LAST_OP(TEMP - 1);                                            01891039
            IF (OPR(RET) & "FFF8") = ADLP_WORD THEN RET = RET + 1;              01891040
            GO TO REPEATT;                                                      01891042
         END;                                                                   01891045
      END;                                                                      01891048
                                                                                01891050
EXITT:                                                                          01891055
      IF I_TRACE THEN OUTPUT =                                                  01891060
         'GET_ADLP(' || PTR || ',' || OP || '):  ' || RET;                      01891070
      OP = 0;                                                                   01891080
      RETURN RET;                                                               01891090
   END GET_ADLP;                                                                01891100
