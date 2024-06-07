.*********************************************************************/
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   NAME:       AMAIN                                               */
.*                                                                   */
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   FUNCTION:   DEFINES "NAME" AS THE PRIMARY ENTRY POINT           */
.*               OF A ROUTINE                                        */
.*                                                                   */
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   INVOKED BY: <NAME>   AMAIN INTSIC = <YES,INTERNAL>              */
.*                              ACALL  = YES                         */
.*                              SECTOR = 0                           */
.*                                                                   */
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   PARAMETERS:                                                     */
.*                                                                   */
.*      NAME     ROUTINE NAME THAT IS THE PRIMARY ENTRY POINT.       */
.*               NAME IS IN THE LABEL POSITION.                      */
.*                                                                   */
.*      OPTIONAL OPERANDS:                                           */
.*                                                                   */
.*      INTSIC=YES - DEFINES ROUTINE AS AN INTRINSIC.  IF INTSIC     */
.*                   OPERAND IS OMITTED, THE ROUTINE IS DEFINED AS   */
.*                   A PROCEDURE                                     */
.*                                                                   */
.*      INTSIC=INTERNAL - DEFINES AN INTRINSIC  WHICH IS CALLED ONLY */
.*                   BY OTHER ROUTINES IN THE LIBRARY                */
.*                                                                   */
.*      ACALL=YES -  VALID ONLY FOR PROCEDURE ROUTINES; ALLOWS USE   */
.*                   OF THE ACALL MACRO WITHIN THE ROUTINE           */
.*                                                                   */
.*      SECTOR=0  -  DEFINES THE ROUTINE (INTRINSIC OR PROCEDURE)    */
.*                   AS A SECTOR 0 ROUTINE.                          */
.*                                                                   */
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   COMMENTS:  &SYSPARM IS A SYSTEM PARAMETER WHICH IS SET IN       */
.*              IN THE CLIST THAT ASSEMBLES THE RUNTIME LIBRARY      */
.*              ROUTINE.  THE VALID VALUES OF &SYSPARM ARE 'BFS'     */
.*              OR 'PASS'. &SYSPARM INDICATES IF THE COMPILATION     */
.*              IS FOR BFS OR PASS.                                  */
.*                                                                   */
.*-------------------------------------------------------------------*/
.*                                                                   */
.*   REVISION HISTORY:                                               */
.*                                                                   */
.*     DATE      CCR#/CDR#  NAME  DESCRIPTION                        */
.*     -------  ----------  ----  ---------------------------------- */
.*     09/08/89  CCR00006   JAC   MERGE BFS AND PASS MACROS          */
.*                                                                   */
.*********************************************************************/
.*
         MACRO                                                          00000100
&NAME    AMAIN &INTSIC=NO,&ACALL=NO,&SECTOR=,&QDED=NO                   00000200
         GBLA  &ENTCNT                                                  00000300
         GBLB  &CALLOK,&LIB,&NOEXTRA,&INTERN,&SECT0,&QDEDOK             00000400
         GBLC  &CSECT,&NAMES(20)                                        00000500
&CSECT   SETC  '&NAME'                                                  00000600
&ENTCNT  SETA  &ENTCNT+1                                                00000700
&NAMES(&ENTCNT) SETC '&NAME'                                            00000800
*********************************************************************** 00000900
*                                                                       00001000
*        PRIMARY ENTRY POINT                                            00001100
*                                                                       00001200
*********************************************************************** 00001300
&CNAME   SETC  '&NAME'                                                  00001400
         AIF   ('&SECTOR' EQ '').REG                                    00001500
         AIF   ('&SECTOR' NE '0').BADSECT                               00001600
&CNAME   SETC  '#0'.'&NAME'                                             00001700
&SECT0   SETB  1                                                        00001800
&CNAME   CSECT                                                          00001900
&NAME    DS    0H             PRIMARY ENTRY POINT                       00002000
         ENTRY &NAME                                                    00002100
         AGO   .COMM                                                    00002200
.REG     ANOP                                                           00002300
&CNAME   CSECT                                                          00002400
.COMM    ANOP                                                           00002500
&LIB     SETB  ('&INTSIC' EQ 'NO')                                      00002600
&INTERN  SETB  ('&INTSIC' EQ 'INTERNAL')                                00002700
         AIF   (NOT &LIB).SPACE                                         00002800
STACK    DSECT                                                          00002900
*        DS    18H            STANDARD STACK AREA DEFINITION            00003000
         DS    F              PSW (LEFT HALF)                           00003100
         DS    2F             R0,R1                                     00003200
ARG2     DS    F              R2                                        00003300
         DS    F              R3                                        00003400
ARG4     DS    F              R4                                        00003500
ARG5     DS    F              R5                                        00003600
ARG6     DS    F              R6                                        00003700
ARG7     DS    F              R7                                        00003800
*        END OF STANDARD STACK AREA                                     00003900
         WORKAREA                                                       00004000
&QDEDOK  SETB  ('&QDED' EQ 'YES')                                       00004010
         AIF   (NOT &QDEDOK).STKEND                                     00004020
QARGA    DS    D                                                        00004030
QARGB    DS    D                                                        00004040
&NOEXTRA SETB  0                                                        00004050
.STKEND  ANOP                                                           00004060
STACKEND DS    0F             END OF COMBINED STACK AREA                00004100
&CNAME   CSECT                                                          00004200
         USING STACK,0        ADDRESS STACK AREA                        00004300
&CALLOK  SETB  ('&ACALL' EQ 'YES')                                      00004400
         AIF   (&NOEXTRA OR NOT &CALLOK).NIST                           00004500
         IAL   0,STACKEND-STACK SET STACK SIZE                          00004600
.*                                              /*********************/
.NIST    AIF   ('&SYSPARM' EQ 'BFS').SPACE      /* CR#CCR00006 - INS */
.*                                              /* NIST NOT REQUIRED */
.*                                              /*   FOR BOS         */
         AIF   ('&SYSPARM' EQ 'PASS').PASS      /*                   */
         MNOTE 4,'INVALID SYSPARM - VALID VALUES ARE BFS AND PASS'   */
         MEXIT                                  /*                   */
.*                                              /*********************/
.PASS    NIST  9(0),0         CLEAR ON ERROR INFO (LCL DATA PTR)        00004700
.*                                          /* CR#CCR00006 - MOD */
.SPACE   SPACE                                                          00004800
         MEXIT                                                          00004900
.BADSECT MNOTE 4,'ONLY SECTOR=0 MAY BE SPECIFIED'                       00005000
         MEND                                                           00005100
