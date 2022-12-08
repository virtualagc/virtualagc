*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    OSSAV.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
&L       OSSAV
         DROP  9,13
         USING *,15
&L       STM   14,12,12(13) SAVE REGISTERS
         ST    13,SAVEAREA+4
         LR    9,13
         LA    13,SAVEAREA
         ST    13,8(0,9)
         USING SAVEAREA,13
         BALR  9,0
         USING *,9
         DROP  15
         STM   0,1,RETARG0
         XC    RETCODE,RETCODE         ZERO RETURN CODE
         STD   0,FPREG        SAVE FLOATING REG ZERO
         MEND
