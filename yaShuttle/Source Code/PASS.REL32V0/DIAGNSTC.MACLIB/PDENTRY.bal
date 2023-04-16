*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    PDENTRY.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         PDENTRY
PDENTRY  DSECT PAGING AREA DIRECTORY ENTRY
PAGEADDR DS    A    ADDRESS OF IN-CORE PAGE
FCBADDR  EQU   *    ADDRESS OF FILE CONTROL BLOCK (FCB)
MODFIND  DS    CL1  '80' > PAGE IS MODIFIED
         DS    CL3  ADDRESS OF FILE CONTROL BLOCK (FCB)
USECOUNT DS    F    USAGE COUNTER
PAGENO   DS    H    PAGE # * 8
RESVCNT  DS    H    RESERVE COUNTER
PDENTLEN EQU   *-PDENTRY
         MEND
