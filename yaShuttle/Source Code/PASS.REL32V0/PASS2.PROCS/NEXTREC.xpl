 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEXTREC.xpl
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
/* PROCEDURE NAME:  NEXT_REC                                               */
/* MEMBER NAME:     NEXTREC                                                */
/* INPUT PARAMETERS:                                                       */
/*          I                 BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CODE                                                           */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CODE_LINE                                                      */
/*          LHS                                                            */
/*          RHS                                                            */
/*          TEMP                                                           */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          GET_CODE                                                       */
/* CALLED BY:                                                              */
/*          OBJECT_CONDENSER                                               */
/*          OBJECT_GENERATOR                                               */
/*          SKIP_ADDR                                                      */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NEXT_REC <==                                                        */
/*     ==> GET_CODE                                                        */
/***************************************************************************/
                                                                                07136000
   DECLARE                                                                      07136500
      CURRENT_ADDRESS LITERALLY 'WORKSEG(CURRENT_ESDID)',                       07137000
      RLD_POS_HEAD LITERALLY 'LASTBASE',                                        07137500
      (TEMP, INST, R, IX, IA, AM, F, B, D) FIXED,                               07138000
      XLEN BIT(16),                                                             07138010
      EMITTING BIT(1);                                                          07138500
                                                                                07139000
 /* ROUTINE TO ADVANCE TO NEXT CODE LINE FOR PROCESSING  */                     07139500
NEXT_REC:                                                                       07140000
   PROCEDURE(I);                                                                07140500
      DECLARE I BIT(16);                                                        07141000
      TEMP = CODE(GET_CODE(CODE_LINE));                                         07141500
      LHS(I) = SHR(TEMP, 16);                                                   07142000
      RHS(I) = TEMP;                                                            07142500
      CODE_LINE = CODE_LINE + 1;                                                07143000
   END NEXT_REC;                                                                07143500
