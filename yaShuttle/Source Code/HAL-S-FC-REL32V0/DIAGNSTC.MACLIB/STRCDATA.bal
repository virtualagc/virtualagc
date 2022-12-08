*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    STRCDATA.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         STRCDATA
STRCDATA DSECT                STRUCTURE LINKAGES TEMPLATE
LINK1    DS    H              LINK TO UNQUALIFIED STRUCTURE
LINK2    DS    H              LINK TO ELDEST SON
LINK3    DS    H              LINK TO BROTHER
STRCLEN  EQU   *-STRCDATA
         MEND
