*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    OSSAVE.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         OSSAVE
         USING *,15
         STM   14,12,12(13) SAVE REGISTERS
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
R0       EQU    0
R1       EQU    1
R2       EQU    2
R3       EQU    3
R4       EQU    4
R5       EQU    5
R6       EQU    6
R7       EQU    7
R8       EQU    8
R9       EQU    9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
BASEREG  EQU    9
         MEND
