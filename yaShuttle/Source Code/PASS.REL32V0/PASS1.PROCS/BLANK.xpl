 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BLANK.xpl
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
 /* PROCEDURE NAME:  BLANK                                                  */
 /* MEMBER NAME:     BLANK                                                  */
 /* INPUT PARAMETERS:                                                       */
 /*          STRING            CHARACTER;                                   */
 /*          START             BIT(16)                                      */
 /*          COUNT             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          J                 FIXED                                        */
 /*          MVC               LABEL                                        */
 /* CALLED BY:                                                              */
 /*          DECOMPRESS                                                     */
 /*          EMIT_EXTERNAL                                                  */
 /*          OUTPUT_WRITER                                                  */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
                                                                                00265900
                                                                                00266000
BLANK:                                                                          00266100
   PROCEDURE(STRING, START, COUNT);                                             00266200
 /* THIS PROCEDURE ACCEPTS A CHARACTER STRING AS INPUT AND                      00266300
      REPLACES "COUNT" CHARACTERS STARTING WITH THE CHARACTER INDICATED         00266400
      BY "START" WITH BLANKS                                                    00266500
      WARNING: DISASTER WILL STRIKE IF BLANK IS CALLED WITH COUNT = 1           00266600
  */                                                                            00266700
                                                                                00266800
      DECLARE J FIXED;                                                          00266900
      DECLARE MVC LABEL;                                                        00267000
      DECLARE STRING CHARACTER, (START, COUNT) BIT(16);                         00267100
      COUNT = COUNT - 2;                                                        00267200
      J = ADDR(MVC);                                                            00267300
      CALL INLINE("58", 1, 0, STRING);      /* L   1,DESCRIPTOR      */         00267400
      CALL INLINE("41", 1, 0, 1, 0);        /* LA  1,0(0,1)          */         00267500
      CALL INLINE("4A", 1, 0, START);       /* AH  1,START           */         00267600
      CALL INLINE("92", 4, 0, 1, 0);        /* MVI X'40',0(1)        */         00267700
      CALL INLINE("48", 2, 0, COUNT);       /* LH  2,COUNT           */         00267800
      CALL INLINE("58", 3, 0, J);           /* L   3,J               */         00267900
      CALL INLINE("44", 2, 0, 3, 0);        /* EX  2,0(0,3)          */         00268000
      RETURN;                                                                   00268100
MVC:                                                                            00268200
      CALL INLINE("D2", 0, 0, 1, 1, 1, 0);  /* MVC 1(0,1),0(1)       */         00268300
   END BLANK;                                                                   00268400
