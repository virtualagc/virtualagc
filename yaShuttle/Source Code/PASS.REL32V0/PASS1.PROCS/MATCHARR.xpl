 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MATCHARR.xpl
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
 /* PROCEDURE NAME:  MATCH_ARRAYNESS                                        */
 /* MEMBER NAME:     MATCHARR                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          J                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARRAYNESS_FLAG                                                 */
 /*          CLASS_AA                                                       */
 /*          CLASS_EA                                                       */
 /*          MP                                                             */
 /*          VAR                                                            */
 /*          VAR_ARRAYNESS                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MATCH_ARRAYNESS <==                                                 */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
 /*    DATE    DEV   REL  DR/CR/PCR     TITLE                               */
 /* 11/21/95 BAF/RCK 27V1 DR107302   INCORRECT ERROR MESSAGE FOR NAME       */
 /*                  11V1               INITIALIZATION                      */
 /*                                                                         */
 /* 08/06/96 SMR     28V0 DR109044   DI17 ERROR EMITTED FOR NAME            */
 /*                  12V0            CHARACTER(*) PARAMETERS                */
 /***************************************************************************/
MATCH_ARRAYNESS:                                                                00887800
   PROCEDURE;                                                                   00887900
      DECLARE J BIT(16);                                                        00888000
      IF VAR_ARRAYNESS=0 THEN RETURN;                                           00888100
      IF CURRENT_ARRAYNESS=0 THEN DO;                                           00888200
         DO J=0 TO VAR_ARRAYNESS;                                               00888300
            CURRENT_ARRAYNESS(J)=VAR_ARRAYNESS(J);                              00888400
         END;                                                                   00888500
         RETURN;                                                                00888600
      END;                                                                      00888700
      DO J=0 TO CURRENT_ARRAYNESS;                                              00888800
         IF CURRENT_ARRAYNESS(J)>0 THEN DO;                                     00888900
            IF VAR_ARRAYNESS(J)>0 THEN DO;                                      00889000
               IF CURRENT_ARRAYNESS(J)^=VAR_ARRAYNESS(J) THEN DO;               00889100
                  IF ARRAYNESS_FLAG THEN CALL ERROR(CLASS_AA,3,VAR(MP));        00889200
                  ELSE CALL ERROR(CLASS_EA,1,VAR(MP));                          00889300
                  RETURN;                                                       00889400
               END;                                                             00889500
            END;                                                                00889600
         END;                                                                   00889700
         ELSE CURRENT_ARRAYNESS(J)=VAR_ARRAYNESS(J);                            00889800
      END;                                                                      00889900
   END MATCH_ARRAYNESS;                                                         00890000
