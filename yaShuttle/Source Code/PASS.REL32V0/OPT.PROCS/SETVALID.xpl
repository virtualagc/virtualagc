 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETVALID.xpl
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
 /* PROCEDURE NAME:  SET_VALIDITY                                           */
 /* MEMBER NAME:     SETVALID                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          VAL               BIT(8)                                       */
 /*          ZAPS_ONLY         BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BIT_PTR           BIT(16)                                      */
 /*          MSG               CHARACTER;                                   */
 /*          WD#               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          LEVEL                                                          */
 /*          REL                                                            */
 /*          SYM_REL                                                        */
 /*          SYM_SHRINK                                                     */
 /*          TEST                                                           */
 /*          TSAPS                                                          */
 /*          VAL_ARRAY                                                      */
 /*          VALIDITY_ARRAY                                                 */
 /*          ZAP_LEVEL                                                      */
 /*          ZAPS                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYT_USED                                                       */
 /*          OBPS                                                           */
 /*          VAL_TABLE                                                      */
 /* CALLED BY:                                                              */
 /*          ASSIGNMENT                                                     */
 /*          CATALOG                                                        */
 /*          NAME_CHECK                                                     */
 /*          PREVENT_PULLS                                                  */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                00646000
                                                                                00647000
                                                                                00648000
 /* SETS VALIDITY_ARRAY BIT TO VAL*/                                            00649000
SET_VALIDITY:                                                                   00650000
   PROCEDURE(PTR,VAL,ZAPS_ONLY);                                                00651000
      DECLARE (BIT_PTR,PTR,WD#) BIT(16);                                        00652000
      DECLARE ZAPS_ONLY BIT(8);                                                 00652020
      DECLARE VAL BIT(8);                                                       00653000
      DECLARE MSG CHARACTER;                                                    00654000
      IF TEST THEN DO;     /* DEBUG H(64) */                                    00655000
         MSG = '    SET_VALIDITY(' || PTR || ',' || VAL || ')';                 00656000
         IF ^VAL THEN MSG = '                      ' || MSG;                    00657000
         OUTPUT = MSG;                                                          00658000
      END;                                                                      00659000
      PTR = REL(PTR);                                                           00659010
      WD# = SHR(PTR,5);                                                         00660000
      BIT_PTR = PTR & "1F";                                                     00661000
      IF VAL THEN DO;                                                           00662000
         VALIDITY_ARRAY(WD#) = VALIDITY_ARRAY(WD#) | SHL(1,BIT_PTR);            00663000
         IF PTR > SYT_USED THEN SYT_USED = PTR;                                 00664000
      END;                                                                      00665000
      ELSE DO;                                                                  00666000
         IF ^ZAPS_ONLY THEN                                                     00666010
            VALIDITY_ARRAY(WD#) = VALIDITY_ARRAY(WD#) & ^SHL(1,BIT_PTR);        00666020
         ZAPS(WD#) = ZAPS(WD#) | SHL(1,BIT_PTR);                                00666030
      END;                                                                      00666040
      ZAPS_ONLY = FALSE;                                                        00666050
   END SET_VALIDITY;                                                            00667000
