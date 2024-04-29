 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ESDTABLE.xpl
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
/* PROCEDURE NAME:  ESD_TABLE                                              */
/* MEMBER NAME:     ESDTABLE                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          PTR               BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          I                 BIT(16)                                      */
/*          J                 BIT(16)                                      */
/*          K                 BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          ESD_NAME                                                       */
/*          ESD_NAME_LENGTH                                                */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/*          INITIALISE                                                     */
/*          OBJECT_GENERATOR                                               */
/*          PRIM_TO_OVFL                                                   */
/***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 DKB  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /***************************************************************************/
                                                                                00603000
 /* ROUTINE TO EXTRACT ESD NAMES FROM PACKED TABLES  */                         00603500
ESD_TABLE:                                                                      00604000
   PROCEDURE(PTR) CHARACTER;                                                    00604500
      DECLARE (PTR, I, J, K) BIT(16);                                           00605000
      I = SHR(PTR, 5);                                                          00605500
      J = SHL(PTR-SHL(I,5), 3);                                                 00606000
      K = ESD_NAME_LENGTH(PTR) & "7F";                                          00606500
      RETURN SUBSTR(ESD_NAME(I), J, K);                                         00607000
   END ESD_TABLE;                                                               00607500
