#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SAVELITE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Made a stub for this.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR


def SAVE_LITERAL(TYPE, VAL, SIZE=0, CMPOOL=0):
    '''
    LIT_TOP=LIT_TOP+1;
    if LIT_TOP=LIT_TOP_MAX:
        ERROR(d.CLASS_BT,3);
    LIT_PTR=GET_LITERAL(LIT_TOP);
    LIT1(LIT_PTR)=TYPE;
    DO CASE TYPE;
       # CHARACTER
       DO;
          IF VAL=0 THEN DO;
             LIT2(LIT_PTR)=0;
             RETURN LIT_TOP;
          END;
          IF (RECORD_ALLOC(LIT_NDX)*RECORD_WIDTH(LIT_NDX))-LIT_CHAR_USED<=SHR(VAL,24)+1
                  THEN CALL ERROR(CLASS_BT,4);
          SIZE=ADDR(MOV);
          CALL INLINE(0x58,1,0,VAL);              # L    1,VAL
          CALL INLINE(0x58,2,0,LIT_CHAR_AD);      # L    2,LIT_CHAR_AD
          CALL INLINE(0x58,3,0,SIZE);             # L    3,SIZE
          CALL INLINE(0xD2,0,0,3,1,VAL);          # MVC  1(0,3),VAL
       MOV:
          CALL INLINE(0xD2,0,0,2,0,1,0);          # MVC  0(0,2),0(1)
          LIT2(LIT_PTR)=(VAL&0xFF000000)|LIT_CHAR_AD;
          VAL=SHR(VAL,24)+1;
          LIT_CHAR_USED=LIT_CHAR_USED+VAL+1;
          LIT_CHAR_AD=LIT_CHAR_AD+VAL;
       END;
       # ARITHMETIC
       DO;
          LIT2(LIT_PTR)=COREWORD(VAL);
          LIT3(LIT_PTR)=COREWORD(VAL+4);
          # WHEN INSERTING CONSTANTS FROM A COMPOOL INTO THE
          # LITERAL TABLE CHECK IF THE CONSTANT IS A DOUBLE
          # AND THEN CHANGE LIT1 TO 5 IF IT IS.
          IF CMPOOL THEN
            IF ((SYT_FLAGS(ID_LOC) & DOUBLE_FLAG) ^= 0) THEN
              LIT1(LIT_PTR) = 5;
       END;
       #  BIT
       DO;
          LIT2(LIT_PTR)=VAL;
          LIT3(LIT_PTR)=SIZE;
       END;
    END;
    CMPOOL = 0;
    RETURN LIT_TOP;
    '''
    return 0

