.*********************************************************************/
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   NAME:       ABAL                                                */
.*                                                                   */
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   FUNCTION:   CALLS THE INTRINSIC ROUTINE "NAME"   VALID ONLY     */
.*               IN A PROCEDURE ROUTINE                              */
.*                                                                   */
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   INVOKED BY: ABAL <NAME>,BANK=<X>                                */
.*                                                                   */
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   PARAMETERS:                                                     */
.*                                                                   */
.*      NAME     ROUTINE NAME TO BRANCH AND LINK                     */
.*                                                                   */
.*      BANK=X   OPTIONAL; IF THE ROUTINE TO BRANCH TO IS IN SECTOR  */
.*               0, THEN 'BANK=0 MUST BE SPECIFIED.  IF THIS         */
.*               PARAMETER IS OMITTED, THEN THE DEFAULT VALUE IS     */
.*               BANK=1. NOTE: BANK=1 DOES NOT MEAN THAT THE ROUTINE */
.*               IS IN SECTOR 1; IT MEANS THAT THE ROUTINE IS NOT IN */
.*               SECTOR 0, THEREFORE BRANCH AND LINK TO THE ROUTINE  */
.*               INDIRECTLY.                                         */
.*                                                                   */
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   REVISION HISTORY:                                               */
.*                                                                   */
.*     DATE      CCR#/CDR#  NAME  DESCRIPTION                        */
.*     --------  ---------  ----  ---------------------------------- */
.*     09/08/89  CCR00006   JAC   MERGE BFS AND PASS MACROS          */
.*     12/29/96  CCR11148   JCS   CHANGE RTL TO RTL CALLING STRUCTURE*/
.*                                                                   */
.*********************************************************************/
.*
         MACRO                                                          00000100
&NAME    ABAL  &P,&BANK=1                                               00000200
         GBLB  &LIB                                                     00000250
&QCON    SETC  '#Q'.'&P'                                                00000260
         AIF   (&LIB).OK                                                00000300
         MNOTE 4,'ABAL MACRO ILLEGAL FROM INTRINSIC'                    00000400
         MEXIT                                                          00000500
.OK      AIF   (&BANK EQ 0).ELSE                                        00000600
         AIF   (D'&QCON).SKIP                                           00000610
         EXTRN #Q&P                                                     00000620
.SKIP    ANOP                                                           00000630
&NAME    DC  X'E4F7'          CALL INTRINSIC INDIRECTLY                 00000640
         DC  Y(#Q&P+X'3800')  THROUGH QCON                              00000650
         MEXIT                                                          00000660
.ELSE    AIF   (D'&P).SKIP2                                             00000670
         EXTRN &P                                                       00000700
.SKIP2   ANOP                                                           00000800
&NAME    BAL   4,&P           CALL BANK0 INTRINSIC                      00000900
         MEND                                                           00001000
