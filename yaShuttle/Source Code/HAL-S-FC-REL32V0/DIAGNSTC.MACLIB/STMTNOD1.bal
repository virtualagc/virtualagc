*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    STMTNOD1.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         STMTNOD1
STMTNOD1 DSECT                STATEMENT NODE (SRN_FLAG=1)
SRN      DS    CL6            STATEMENT REFERENCE NUMBER
INCOUNT  DS    CL2            INCLUDE COUNT
STDCPTR1 DS    A              POINTER TO STATEMENT DATA CELL
         MEND
