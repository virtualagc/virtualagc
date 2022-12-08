*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    TENSTBL.bal
*/ Purpose:     This is a part of the "Monitor" of the HAL/S-FC 
*/              compiler program.
*/ Reference:   "HAL/S Compiler Functional Specification", 
*/              section 2.1.1.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-07 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ are from the Virtual AGC Project.
*/              Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'TENSTBL: POWERS OF TEN DATA TABLE FOR SCALAR OUTPUT CONVERSION' 00000009
TENSTBL  CSECT                                                          00000010
         DC    D'1'                                                     00000020
         DC    D'1E1'                                                   00000030
         DC    D'1E2'                                                   00000040
         DC    D'1E3'                                                   00000050
         DC    D'1E4'                                                   00000060
         DC    D'1E5'                                                   00000070
         DC    D'1E6'                                                   00000080
         DC    D'1E7'                                                   00000090
         DC    D'1E8'                                                   00000100
         DC    D'1E9'                                                   00000110
         DC    D'1E10'                                                  00000120
         DC    D'1E20'                                                  00000130
         DC    D'1E30'                                                  00000140
         DC    D'1E40'                                                  00000150
         DC    D'1E50'                                                  00000160
         DC    D'1E60'                                                  00000170
         DC    D'1E70'                                                  00000180
         END                                                            00000190
