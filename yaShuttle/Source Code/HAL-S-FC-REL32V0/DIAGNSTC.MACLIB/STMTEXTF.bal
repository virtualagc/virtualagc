*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    STMTEXTF.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         STMTEXTF
STMTEXTF DSECT DSECT FOR FIXED PART OF STMT EXTENT CELL
SUCCPTR1 DS    F    POINTER TO SUCCESSOR CELL
NXNTRY   DS    H    NUMBER OF EXTENT ENTRIES
FSTPAGE1 DS    H    PAGE # CORRESPONDING TO 1ST ENTRY
         MEND
