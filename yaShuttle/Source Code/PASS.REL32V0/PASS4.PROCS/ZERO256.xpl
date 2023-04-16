 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ZERO256.xpl
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
/* PROCEDURE NAME:  ZERO_256                                               */
/* MEMBER NAME:     ZERO256                                                */
/* INPUT PARAMETERS:                                                       */
/*          CORE_ADDR         FIXED                                        */
/*          COUNT             BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          MVCTEMP           FIXED                                        */
/*          MVC               LABEL                                        */
/* CALLED BY:                                                              */
/*          ZERO_CORE                                                      */
/***************************************************************************/
                                                                                00142500
 /* ZERO 'COUNT' BYTES OF THE SPECIFIED CORE LOCATIONS */                       00142600
 /* NOTE: 1<= COUNT <= 256                             */                       00142700
                                                                                00142800
ZERO_256:                                                                       00142900
   PROCEDURE (CORE_ADDR,COUNT);                                                 00143000
      DECLARE (CORE_ADDR,MVCTEMP) FIXED,                                        00143100
         COUNT BIT(16),                                                         00143200
         MVC LABEL;                                                             00143300
      COUNT = COUNT - 2;                                                        00143400
      IF COUNT < 0 THEN DO;                                                     00143500
         CALL INLINE("58", 1, 0, CORE_ADDR);  /* L   1,CORE_ADDR      */        00143600
         CALL INLINE("92", 0, 0, 1, 0);       /* MVI 0(1),X'00'       */        00143700
      END;                                                                      00143800
      ELSE DO;                                                                  00143900
         MVCTEMP = ADDR(MVC);                                                   00144000
         CALL INLINE("58", 1, 0, CORE_ADDR);  /* L   1,CORE_ADDR      */        00144100
         CALL INLINE("92", 0, 0, 1, 0);       /* MVI 0(1),X'00'       */        00144200
         CALL INLINE("48", 2, 0, COUNT);      /* LH  2,COUNT          */        00144300
         CALL INLINE("58", 3, 0, MVCTEMP);    /* L   3,MVCTEMP        */        00144400
         CALL INLINE("44", 2, 0, 3, 0);       /* EX  2,0(0,3)         */        00144500
      END;                                                                      00144600
      RETURN;                                                                   00144700
MVC:                                                                            00144800
      CALL INLINE("D2", 0, 0, 1, 1, 1, 0);    /* MVC 1(0,1),0(1)      */        00144900
   END ZERO_256;                                                                00145000
