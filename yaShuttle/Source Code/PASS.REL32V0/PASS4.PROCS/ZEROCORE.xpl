 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ZEROCORE.xpl
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
/* PROCEDURE NAME:  ZERO_CORE                                              */
/* MEMBER NAME:     ZEROCORE                                               */
/* INPUT PARAMETERS:                                                       */
/*          CORE_ADDR         FIXED                                        */
/*          COUNT             FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          #BYTES            FIXED                                        */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          ZERO_256                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> ZERO_CORE <==                                                       */
/*     ==> ZERO_256                                                        */
/***************************************************************************/
                                                                                00145100
 /* ZERO 'COUNT' BYTES OF THE SPECIFIED CORE LOCATIONS. */                      00145200
 /* NOTE: THERE IS NO LIMIT TO THE SIZE OF 'COUNT'!      */                     00145300
                                                                                00145400
ZERO_CORE:                                                                      00145500
   PROCEDURE (CORE_ADDR,COUNT);                                                 00145600
      DECLARE (CORE_ADDR,COUNT,#BYTES) FIXED;                                   00145700
      DO WHILE COUNT ^= 0;                                                      00145800
         IF COUNT > 256 THEN #BYTES = 256;                                      00145900
         ELSE #BYTES = COUNT;                                                   00146000
         CALL ZERO_256(CORE_ADDR,#BYTES);                                       00146100
         CORE_ADDR = CORE_ADDR + #BYTES;                                        00146200
         COUNT = COUNT - #BYTES;                                                00146300
      END;                                                                      00146400
      RETURN;                                                                   00146500
   END ZERO_CORE;                                                               00146600
