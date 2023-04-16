 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SWITCH.xpl
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
 /* PROCEDURE NAME:  SWITCH                                                 */
 /* MEMBER NAME:     SWITCH                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          ORIG              BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          HIGH              BIT(16)                                      */
 /*          LOW               BIT(16)                                      */
 /*          ORIG_HIGH         BIT(16)                                      */
 /*          REF               BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NODE                                                           */
 /*          TRACE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FLAG                                                           */
 /*          OPR                                                            */
 /*          TMP                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER                                                          */
 /*          HALMAT_FLAG                                                    */
 /*          LAST_OP                                                        */
 /*          MOVE_LIMB                                                      */
 /*          NEXT_FLAG                                                      */
 /*          NO_OPERANDS                                                    */
 /*          VAC_OR_XPT                                                     */
 /* CALLED BY:                                                              */
 /*          FORCE_MATCH                                                    */
 /*          FORCE_TERMINAL                                                 */
 /*          REARRANGE_HALMAT                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SWITCH <==                                                          */
 /*     ==> VAC_OR_XPT                                                      */
 /*     ==> ENTER                                                           */
 /*     ==> LAST_OP                                                         */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> HALMAT_FLAG                                                     */
 /*         ==> VAC_OR_XPT                                                  */
 /*     ==> MOVE_LIMB                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> RELOCATE                                                    */
 /*         ==> MOVECODE                                                    */
 /*             ==> ENTER                                                   */
 /*     ==> NEXT_FLAG                                                       */
 /*         ==> NO_OPERANDS                                                 */
 /***************************************************************************/
                                                                                01654000
 /* SWITCH HALMAT OPERANDS*/                                                    01655000
SWITCH:                                                                         01656000
   PROCEDURE(ORIG,PTR);                                                         01657000
      DECLARE (ORIG,PTR,REF,LOW,ORIG_HIGH,HIGH,TEMP) BIT(16);                   01658000
      IF TRACE THEN OUTPUT = 'SWITCH: '||ORIG||' TO '||PTR;                     01659000
      IF ORIG = PTR THEN RETURN;                                                01660000
      TMP = OPR(ORIG);                                                          01661000
      TEMP = FLAG(ORIG);                                                        01662000
      OPR(ORIG) = OPR(PTR);                                                     01663000
      FLAG(ORIG) = FLAG(PTR);                                                   01664000
      OPR(PTR) = TMP;                                                           01665000
      FLAG(PTR) = TEMP;                                                         01666000
      IF HALMAT_FLAG(ORIG) THEN CALL ENTER (ORIG);                              01667000
      IF HALMAT_FLAG(PTR) THEN CALL ENTER(PTR);                                 01668000
      IF VAC_OR_XPT(ORIG) THEN DO;                                              01669000
         REF = SHR(OPR(ORIG),16);                                               01670000
         IF HALMAT_FLAG(ORIG) THEN REF = NODE(REF) & "FFFF";                    01671000
         IF REF > ORIG THEN DO;                   /* FORWARD VAC REFERENCE*/    01672000
            LOW = LAST_OP(ORIG);                                                01673000
            REF = LAST_OP(REF);                                                 01674000
            ORIG_HIGH,HIGH = LOW + 1;                                           01675000
            TEMP = NEXT_FLAG(HIGH);                                             01676000
            DO WHILE TEMP < REF;                                                01677000
               HIGH = TEMP;                                                     01678000
               TEMP = NEXT_FLAG(HIGH + 1);                                      01679000
            END;                                                                01680000
            IF HIGH = ORIG_HIGH THEN HIGH = LOW + NO_OPERANDS(LOW) + 1;         01681000
            ELSE HIGH = HIGH + NO_OPERANDS(HIGH) + 1;                           01682000
            CALL MOVE_LIMB(LOW,HIGH,REF - HIGH + NO_OPERANDS(REF) + 1);         01683000
         END;                                                                   01684000
      END;                                                                      01685000
   END SWITCH;                                                                  01686000
