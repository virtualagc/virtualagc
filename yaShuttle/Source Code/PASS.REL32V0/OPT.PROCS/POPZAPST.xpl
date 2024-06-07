 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPZAPST.xpl
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
 /* PROCEDURE NAME:  POP_ZAP_STACK                                          */
 /* MEMBER NAME:     POPZAPST                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          COMBINE_LEVELS    BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          STACK_TRACE                                                    */
 /*          STT#                                                           */
 /*          SYT_USED                                                       */
 /*          SYT_WORDS                                                      */
 /*          TSAPS                                                          */
 /*          ZAPS                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OBPS                                                           */
 /*          ZAP_LEVEL                                                      */
 /* CALLED BY:                                                              */
 /*          END_MULTICASE                                                  */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
                                                                                02206470
 /* POPS STACK OF ZAPS IN CURRENT BLOCK*/                                       02206480
POP_ZAP_STACK:                                                                  02206490
   PROCEDURE(COMBINE_LEVELS);                                                   02206500
      DECLARE COMBINE_LEVELS BIT(8);                                            02206510
      DECLARE K BIT(16);                                                        02206520
      IF STACK_TRACE THEN OUTPUT='POP_ZAP_STACK('||COMBINE_LEVELS||'):  '||STT#;02206530
      IF ZAP_LEVEL <= 0 THEN RETURN; /*AT LEVEL 0*/                             02206540
      ZAP_LEVEL = ZAP_LEVEL - 1;                                                02206550
                                                                                02206560
      IF COMBINE_LEVELS THEN DO;                                                02206570
         COMBINE_LEVELS = 0;                                                    02206580
         IF OBPS(ZAP_LEVEL+1).TSAPS(0) THEN ZAPS(0) = 1;                        02206590
         ELSE DO FOR K = 0 TO SYT_WORDS;                                        02206600
            OBPS(ZAP_LEVEL).TSAPS(K) = OBPS(ZAP_LEVEL).TSAPS(K) |               02206610
               OBPS(ZAP_LEVEL+1).TSAPS(K);                                      02206611
         END;                                                                   02206620
      END;                                                                      02206630
   END POP_ZAP_STACK;                                                           02206640
