#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   MAKEFIXE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Made a stub.
'''


'''
 /***************************************************************************/
 /* PROCEDURE NAME:  MAKE_FIXED_LIT                                         */
 /* MEMBER NAME:     MAKEFIXE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LIMIT_OK          LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          ADDR_FIXER                                                     */
 /*          ADDR_ROUNDER                                                   */
 /*          CONST_DW                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          ARITH_SHAPER_SUB                                               */
 /*          CHECK_SUBSCRIPT                                                */
 /*          ERROR_SUB                                                      */
 /*          PREC_SCALE                                                     */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

# No idea what's going on here.  Perhaps come back to it later.  The
# documentation provides the information that it's a "procedure".  Splendid!
def MAKE_FIXED_LIT(PTR):
    return 0

'''
MAKE_FIXED_LIT:
   PROCEDURE(PTR);
      DECLARE PTR FIXED;
      DECLARE LIMIT_OK LABEL;
      PTR=GET_LITERAL(PTR);
      DW(0)=LIT2(PTR);
      DW(1)=LIT3(PTR);
      PTR=ADDR(LIMIT_OK);
      CALL INLINE("58",3,0,DW_AD);             /*  L    3,DW_AD            */
      CALL INLINE("68",0,0,3,0);               /*  LD   0,0(0,3)           */
      CALL INLINE("20", 0, 0);                            /* LPDR 0,0         */
      CALL INLINE("58", 1, 0, ADDR_ROUNDER);/* L   1,ADDR_ROUNDER         */
      CALL INLINE("6A", 0, 0, 1, 0);        /* AD  0,0(0,1)               */
      CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);/* L 1,ADDR_FIXED_LIMIT   */
      CALL INLINE("58",2,0,PTR);                   /*   L   2,  PTR   */
      CALL INLINE("69", 0, 0, 1, 0);        /* CD  0,0(0,1)               */
      CALL INLINE("07",12,2);                  /*  BNHR 2                  */
      CALL INLINE("68",0,0,1,0);               /*  LD   0,0(0,1)           */
LIMIT_OK:
      CALL INLINE("58", 1, 0, ADDR_FIXER);  /* L   1,ADDR_FIXER           */
      CALL INLINE("6E", 0, 0, 1, 0);        /* AW  0,0(0,1)               */
      CALL INLINE("60",0,0,3,8);                   /*  STD 0,8(0,3)   */
      IF SHR(DW(0),31) THEN RETURN -DW(3);
      RETURN DW(3);
   END MAKE_FIXED_LIT;
'''
