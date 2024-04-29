 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   REALLABE.xpl
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
/* PROCEDURE NAME:  REAL_LABEL                                             */
/* MEMBER NAME:     REALLABE                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          LBL               BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          LAB_LOC                                                        */
/*          LOCAT                                                          */
/*          LOCATION                                                       */
/* CALLED BY:                                                              */
/*          OBJECT_CONDENSER                                               */
/*          OBJECT_GENERATOR                                               */
/***************************************************************************/
                                                                                07151000
 /* ROUTINE TO GET REAL LABEL FROM DEFINITION TABLE  */                         07151500
REAL_LABEL:                                                                     07152000
   PROCEDURE(LBL) BIT(16);                                                      07152500
      DECLARE LBL BIT(16);                                                      07153000
      DO WHILE LOCATION(LBL) < 0;                                               07153500
         LBL = -LOCATION(LBL);                                                  07154000
      END;                                                                      07154500
      RETURN LBL;                                                               07155000
   END REAL_LABEL;                                                              07155500
