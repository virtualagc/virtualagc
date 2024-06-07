*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    FDIREC.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         FDIREC
FDIREC   DSECT
FSDFNAME DS    CL8            NAME OF SIMULATION DATA FILE
FFSIMADR DS    A              ADDRESS OF FSIM CSECT
FSTMTOF1 DS    H              OFFSET TO FIRST STATEMENT ENTRY
FSTMTOF2 DS    H              OFFSET TO LAST STATEMENT ENTRY
FDIRCLEN EQU   *-FDIREC
         MEND
