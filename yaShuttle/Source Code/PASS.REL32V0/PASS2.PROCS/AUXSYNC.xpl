 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   AUXSYNC.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  AUX_SYNC                                               */
/* MEMBER NAME:     AUXSYNC                                                */
/* INPUT PARAMETERS:                                                       */
/*          CTR               BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AUX                                                            */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          AUX_CTR                                                        */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          AUX_LINE                                                       */
/*          AUX_OP                                                         */
/*          GET_AUX                                                        */
/* CALLED BY:                                                              */
/*          NEXTCODE                                                       */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> AUX_SYNC <==                                                        */
/*     ==> GET_AUX                                                         */
/*     ==> AUX_LINE                                                        */
/*         ==> GET_AUX                                                     */
/*     ==> AUX_OP                                                          */
/*         ==> GET_AUX                                                     */
/***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*03/04/91 RAH   23V2  CR11109 CLEANUP OF COMPILER SOURCE CODE             */
 /*                                                                         */
 /***************************************************************************/
                                                                                  637160
 /* ROUTINE TO SYNCHRONISE AUXILIARY HALMAT FILE WITH HALMAT */                   637180
AUX_SYNC:                                                                         637200
   PROCEDURE(CTR);                                                                637220
      DECLARE CTR BIT(16);                                                        637240
      DO WHILE AUX(GET_AUX(AUX_CTR));                                             637260
         AUX_CTR = AUX_CTR + 1;                                                   637280
      END;                                                                        637300
      IF AUX_OP(AUX_CTR) ^= 6 THEN                                                637320
         DO WHILE AUX_LINE(AUX_CTR) < CTR;                                        637340
         AUX_CTR = AUX_CTR + 2;                                                   637360
      END;                                                                        637380
   END AUX_SYNC;                                                                  637400
