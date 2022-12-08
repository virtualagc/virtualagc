*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    OSRET.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         OSRET
         L     15,RETCODE
         LD    0,FPREG        RESTORE FLOATING REG ZERO
         L     13,SAVEAREA+4
         MVC   20(8,13),RETARG0
         L     14,12(13,0) RESTORE REGISTER 14
         LM    0,12,20(13) RESTORE THE REGISTERS
         BR    14 RETURN
         MEND
