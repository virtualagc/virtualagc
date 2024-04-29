 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MOVE.xpl
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
/* PROCEDURE NAME:  MOVE                                                   */
/* MEMBER NAME:     MOVE                                                   */
/* INPUT PARAMETERS:                                                       */
/*          LEGNTH            BIT(16)                                      */
/*          FROM              FIXED                                        */
/*          INTO              FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          ADDRTEMP          FIXED                                        */
/*          MOVECHAR          LABEL                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          FOREVER                                                        */
/* CALLED BY:                                                              */
/*          SDF_PROCESSING                                                 */
/***************************************************************************/
                                                                                00139100
MOVE:                                                                           00139200
   PROCEDURE (LEGNTH,FROM,INTO);                                                00139300
      DECLARE (FROM,INTO,ADDRTEMP) FIXED,                                       00139400
         MOVECHAR LABEL,                                                        00139500
         LEGNTH BIT(16);                                                        00139600
      IF LEGNTH <= 0 THEN RETURN;                                               00139700
      FROM = FROM & "00FFFFFF";                                                 00139800
      INTO = INTO & "00FFFFFF";                                                 00139900
      DO FOREVER;                                                               00140000
         IF LEGNTH > 256 THEN DO;                                               00140100
            CALL INLINE("58",2,0,INTO);      /* L 2,INTO  */                    00140200
            CALL INLINE("58",3,0,FROM);      /* L 3,FROM  */                    00140300
            CALL INLINE("D2",15,15,2,0,3,0); /* MVC 0(255,2),0(3) */            00140400
            LEGNTH = LEGNTH - 256;                                              00140500
            FROM = FROM + 256;                                                  00140600
            INTO = INTO + 256;                                                  00140700
         END;                                                                   00140800
         ELSE DO;                                                               00140900
            ADDRTEMP = ADDR(MOVECHAR);                                          00141000
            CALL INLINE("18",0,4);           /* LR 0,4      */                  00141100
            CALL INLINE("58",2,0,INTO);      /* L  2,INTO   */                  00141200
            CALL INLINE("58",3,0,FROM);      /* L   3,FROM   */                 00141300
            CALL INLINE("48",1,0,LEGNTH);    /* LH 1,LEGNTH */                  00141400
            CALL INLINE("06",1,0);           /* BCTR 1,0    */                  00141500
            CALL INLINE("58",4,0,ADDRTEMP);  /* L 4,ADDRTEMP */                 00141600
            CALL INLINE("44",1,0,4,0);       /* EX 1,0(0,4)  */                 00141700
            CALL INLINE("18",4,0);           /* LR 4,0       */                 00141800
            RETURN;                                                             00141900
         END;                                                                   00142000
      END;                                                                      00142100
MOVECHAR:                                                                       00142200
      CALL INLINE("D2",0,0,2,0,3,0);  /* MVC 0(0,2),0(3)  */                    00142300
   END MOVE;                                                                    00142400
