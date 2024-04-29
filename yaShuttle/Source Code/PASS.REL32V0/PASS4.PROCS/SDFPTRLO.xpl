 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SDFPTRLO.xpl
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
/* PROCEDURE NAME:  SDF_PTR_LOCATE                                         */
/* MEMBER NAME:     SDFPTRLO                                               */
/* INPUT PARAMETERS:                                                       */
/*          PTR               FIXED                                        */
/*          FLAGS             BIT(8)                                       */
/* LOCAL DECLARATIONS:                                                     */
/*          ARG               FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          PNTR                                                           */
/*          ADDRESS                                                        */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          LOC_ADDR                                                       */
/*          COMMTABL_FULLWORD                                              */
/*          LOC_PTR                                                        */
/* CALLED BY:                                                              */
/*          SDF_LOCATE                                                     */
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00159800
 /* ROUTINE TO 'LOCATE' EXTERNAL SDF DATA BY POINTER */                         00159900
                                                                                00160000
SDF_PTR_LOCATE:                                                                 00160100
   PROCEDURE (PTR,FLAGS);                                                       00160200
      DECLARE (PTR,ARG) FIXED,                                                  00160300
         FLAGS BIT(8);                                                          00160400
      PNTR,LOC_PTR = PTR;                                                       00160500
      ARG = SHL(FLAGS,28) + 5;                                                  00160600
      CALL MONITOR(22,ARG);                                                     00160700
      LOC_ADDR = ADDRESS;                                                       00160800
   END SDF_PTR_LOCATE;                                                          00160900
