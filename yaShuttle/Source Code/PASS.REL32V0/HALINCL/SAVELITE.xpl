 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SAVELITE.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /*     REVISION HISTORY :                                                  */
 /*     ------------------                                                  */
 /*    DATE   NAME  REL    DR NUMBER AND TITLE                              */
 /*                                                                         */
 /* 07/13/95  DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING         */
 /*                11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)    */
 /*                                                                         */
 /* 12/11/97  DCP  29V0  DR109083 CONSTANT DOUBLE SCALAR CONVERTED TO       */
 /*                14V0           CHARACTER AS SINGLE PRECISION             */
 /***************************************************************************/
SAVE_LITERAL:                                                                   00000010
   PROCEDURE (TYPE,VAL,SIZE,CMPOOL);                         /*MOD-DR109083*/   00000020
      DECLARE (VAL,SIZE) FIXED, TYPE BIT(16);                                   00000030
      DECLARE MOV LABEL;                                                        00000040
      DECLARE CMPOOL BIT(1);                                     /*DR109083*/
      LIT_TOP=LIT_TOP+1;                                                        00000050
      IF LIT_TOP=LIT_TOP_MAX THEN CALL ERROR(CLASS_BT,3); /* CR12416 */         00000060
      LIT_PTR=GET_LITERAL(LIT_TOP);                                             00000070
      LIT1(LIT_PTR)=TYPE;                                                       00000080
      DO CASE TYPE;                                                             00000090
         /* CHARACTER */                                                        00000100
         DO;                                                                    00000110
            IF VAL=0 THEN DO;                                                   00000120
               LIT2(LIT_PTR)=0;                                                 00000130
               RETURN LIT_TOP;                                                  00000140
            END;                                                                00000150
   IF (RECORD_ALLOC(LIT_NDX)*RECORD_WIDTH(LIT_NDX))-LIT_CHAR_USED<=SHR(VAL,24)+100000160
                    THEN CALL ERROR(CLASS_BT,4); /* CR12416 */                  00000161
            SIZE=ADDR(MOV);                                                     00000180
            CALL INLINE("58",1,0,VAL);              /* L    1,VAL        */     00000190
            CALL INLINE("58",2,0,LIT_CHAR_AD);      /* L    2,LIT_CHAR_AD */    00000200
            CALL INLINE("58",3,0,SIZE);             /* L    3,SIZE        */    00000210
            CALL INLINE("D2",0,0,3,1,VAL);          /* MVC  1(0,3),VAL    */    00000220
         MOV:                                                                   00000230
            CALL INLINE("D2",0,0,2,0,1,0);          /* MVC  0(0,2),0(1)   */    00000240
            LIT2(LIT_PTR)=(VAL&"FF000000")|LIT_CHAR_AD;                         00000250
            VAL=SHR(VAL,24)+1;                                                  00000260
            LIT_CHAR_USED=LIT_CHAR_USED+VAL+1;                                  00000270
            LIT_CHAR_AD=LIT_CHAR_AD+VAL;                                        00000280
         END;                                                                   00000290
         /* ARITHMETIC */                                                       00000300
         DO;                                                                    00000310
            LIT2(LIT_PTR)=COREWORD(VAL);                                        00000320
            LIT3(LIT_PTR)=COREWORD(VAL+4);                                      00000330
            /* WHEN INSERTING CONSTANTS FROM A COMPOOL INTO THE  /*DR109083*/
            /* LITERAL TABLE CHECK IF THE CONSTANT IS A DOUBLE   /*DR109083*/
            /* AND THEN CHANGE LIT1 TO 5 IF IT IS.               /*DR109083*/
            IF CMPOOL THEN                                       /*DR109083*/
              IF ((SYT_FLAGS(ID_LOC) & DOUBLE_FLAG) ^= 0) THEN   /*DR109083*/
                LIT1(LIT_PTR) = 5;                               /*DR109083*/
         END;                                                                   00000340
         /*  BIT  */                                                            00000350
         DO;                                                                    00000360
            LIT2(LIT_PTR)=VAL;                                                  00000370
            LIT3(LIT_PTR)=SIZE;                                                 00000380
         END;                                                                   00000390
      END;                                                                      00000400
      CMPOOL = 0;                                                /*DR109083*/
      RETURN LIT_TOP;                                                           00000410
   END SAVE_LITERAL;                                                            00000420
