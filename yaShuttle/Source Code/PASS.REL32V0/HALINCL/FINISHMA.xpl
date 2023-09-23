 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FINISHMA.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
                2023-09-22 RSB  Fixed the cent symbol.
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/******************************************************************/
/*  REVISION HISTORY :                                            */
/*  ------------------                                            */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                        */
/*                                                                */
/*07/28/03 JAC   32V0  DR120219 REPL_MACRO_ARGS INCORECTLY PRINTED*/
/*               17V0           IN SDF                            */
/*                                                                */
/******************************************************************/
FINISH_MACRO_TEXT:                                                              00000100
   PROCEDURE;                                                                   00000200
   /* ROUTINE TO PUT TERMINATION CHARACTERS ONTO END OF REPLACE */              00000300
   /* MACRO TEXT, AND (IF SIMULATING) MOVE THE MACRO TEXT TO    */              00000400
   /* VIRTUAL MEMORY                                            */              00000500
      BASED NODE_F FIXED;                                                       00000600
      DECLARE (ARG_FLAG,NEXT_CELL_PTR,TEXT_PTR) FIXED,                          00000700
              (BLANK_BYTES,CELLSIZE,TEXT_SIZE,II) BIT(16);                      00000800
      IF FIRST_FREE ^= 0 THEN                                                   00000900
         DO;                                                                    00001000
            II = MACRO_TEXT(FIRST_FREE-1);                                      00001100
            IF (MACRO_TEXT(FIRST_FREE-2)=BYTE(')') & II=BYTE('¢')) |            00001200
               II=BYTE(')') | MACRO_ARG_COUNT>0 THEN DO;                        00001300
               NEXT_ELEMENT(MACRO_TEXTS);                                       00001310
               NEXT_ELEMENT(MACRO_TEXTS);                                       00001320
               MACRO_TEXT(FIRST_FREE) = "EE";                                   00001400
               MACRO_TEXT(FIRST_FREE+1) = 0;                                    00001500
               FIRST_FREE = FIRST_FREE+2;                                       00001600
            END;                                                                00001700
         END;                                                                   00001800
      MACRO_TEXT(FIRST_FREE) = "EF";                                            00001900
      IF SIMULATING > 0 THEN DO;                                                00002000
         IF MACRO_TEXT(FIRST_FREE-2)="EE" &                                     00002100
            MACRO_TEXT(FIRST_FREE-1)=0 THEN DO;                /*DR120219*/
            TEXT_SIZE = (FIRST_FREE - 2 ) - START_POINT;                        00002200
            TEXT_PTR = (FIRST_FREE-2) - MACRO_CELL_LIM;                         00002300
            IF MACRO_ARG_COUNT > 0 THEN ARG_FLAG = "80000000"; /*DR120219*/     00002400
            ELSE ARG_FLAG = 0;                                 /*DR120219*/
         END;                                                                   00002500
         ELSE DO;                                                               00002600
            TEXT_SIZE = FIRST_FREE - START_POINT;                               00002700
            TEXT_PTR = FIRST_FREE - MACRO_CELL_LIM;                             00002800
            ARG_FLAG = 0;                                                       00002900
         END;                                                                   00003000
         IF TEXT_SIZE<0 THEN TEXT_SIZE = 0;                                     00003100
         NEXT_CELL_PTR = -1;                                                    00003200
         DO WHILE TEXT_SIZE >= MACRO_CELL_LIM;                                  00003300
            CELLSIZE = MACRO_CELL_LIM;                                          00003400
            IF MACRO_TEXT(TEXT_PTR-1) = "EE" THEN DO;                           00003500
               TEXT_PTR = TEXT_PTR + 1;                                         00003600
               CELLSIZE = CELLSIZE - 1;                                         00003700
            END;                                                                00003800
            REPLACE_TEXT_PTR = GET_CELL(CELLSIZE+6,ADDR(NODE_F),MODF);          00003900
            NODE_F(0) = NEXT_CELL_PTR;                                          00004000
            NODE_F(1) = SHL(CELLSIZE,16);                                       00004100
            MACRO_BYTES = MACRO_BYTES + MACRO_CELL_LIM;                         00004200
            CALL MOVE(CELLSIZE,ADDR(MACRO_TEXT(TEXT_PTR)),                      00004300
               VMEM_LOC_ADDR+6);                                                00004400
            NEXT_CELL_PTR = REPLACE_TEXT_PTR;                                   00004500
            TEXT_PTR = TEXT_PTR - MACRO_CELL_LIM;                               00004600
            TEXT_SIZE = TEXT_SIZE - CELLSIZE;                                   00004700
         END;                                                                   00004800
         IF TEXT_SIZE > 0 THEN DO;                                              00004900
            REPLACE_TEXT_PTR=GET_CELL(TEXT_SIZE+6,ADDR(NODE_F),MODF);           00005000
            NODE_F(0) = NEXT_CELL_PTR;                                          00005100
            NODE_F(1) = SHL(TEXT_SIZE,16);                                      00005200
            NEXT_CELL_PTR = REPLACE_TEXT_PTR;                                   00005300
            MACRO_BYTES = MACRO_BYTES+((TEXT_SIZE+3)&"FFFC");                   00005400
            CALL MOVE(TEXT_SIZE,ADDR(MACRO_TEXT(START_POINT)),                  00005500
               VMEM_LOC_ADDR + 6);                                              00005600
         END;                                                                   00005700
         REPLACE_TEXT_PTR = GET_CELL(8,ADDR(NODE_F),MODF);                      00005800
         NODE_F(0) = NEXT_CELL_PTR;                                             00005900
         NODE_F(1) = "FFFF0000" + BLANK_BYTES;                                  00006000
         REPLACE_TEXT_PTR = REPLACE_TEXT_PTR | ARG_FLAG;                        00006100
      END;                                                                      00006200
      FIRST_FREE = FIRST_FREE + 1;                                              00006300
         NEXT_ELEMENT(MACRO_TEXTS);                                             00006301
      RETURN;                                                                   00006400
   END FINISH_MACRO_TEXT;                                                       00006500
