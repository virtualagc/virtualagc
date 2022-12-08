*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DROOTCEL.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         DROOTCEL
**********************************************************************
*     REVISION HISTORY :                                             *
*     ------------------                                             *
*     DATE    NAME  REL    DR/CR NUMBER AND TITLE                    *
*                                                                    *
*    05/17/99 DAS   30V0   CR13079 ADD HAL/S INITIALIZATION DATA TO  *
*                   15V0   SDF                                       *
*                                                                    *
**********************************************************************
DROOTCEL DSECT                DIRECTORY ROOT CELL
SDFFLAGS DS    2C
LASTPAGE DS    H              # OF LAST PAGE IN SDF FILE
SDFDATE  DS    F              DATE OF CREATION
SDFTIME  DS    F              TIME OF CREATION
LASTDPGE DS    H              # OF LAST DIRECTORY PAGE
COMPOOLS DS    H              # OF INCLUDED COMPOOLS
BLKNODES DS    H              # OF BLOCK NODES
SYMNODES DS    H              # OF SYMBOL NODES
FBNPTR   DS    A              POINTER TO FIRST BLOCK NODE
LBNPTR   DS    A              POINTER TO LAST BLOCK NODE
INSTRCNT DS    H              NO. OF EMITTED MACHINE INSTRUCTIONS
FREEBYTE DS    H              TOTAL AMT OF FREE SPACE IN SDF
DLSTHEAD DS    H              LIST HEAD FOR DECLARED VARS (BY ADDR)
RLSTHEAD DS    H              LIST HEAD FOR REMOTE VARS (BY ADDR)
FSNPTR   DS    A              POINTER TO FIRST SYMBOL NODE
LSNPTR   DS    A              POINTER TO LAST SYMBOL NODE
CUBTCPTR DS    A              PTR TO COMP. UNIT BLOCK DATA CELL
BTREEPTR DS    A              POINTER TO ROOT OF BLOCK TREE
FSTMTNUM DS    H              FIRST STATEMENT NUMBER
LSTMTNUM DS    H              LAST STATEMENT NUMBER
EXECSTMT DS    H              # OF EXECUTABLE STATEMENTS
STMTNODE DS    H              # OF STATEMENT NODES
FSTNPTR  DS    A              POINTER TO FIRST STATEMENT NODE
LSTNPTR  DS    A              POINTER TO LAST STATEMENT NODE
SNELPTR  DS    A              POINTER TO STATEMENT NODE EXTENT LIST
FIRSTSRN DS    CL8
LASTSRN  DS    CL8
CUBTCNUM DS    H              BLOCK NUMBER OF UNIT BLOCK
COMPUNIT DS    H              COMPILATION UNIT ID CODE
TITLEPTR DS    F              VIRTUAL MEMORY POINTER TO TITLE INFOR
USERDATA DS    CL8            FREE FOR USER DATA
SYMBCNT  DS    F              ACTUAL NUMBER OF SYMBOLS IN COMP.
MACROCNT DS    F              TOTAL SIZE OF MACRO TEXT (BYTES)
LITSCNT  DS    F              TOTAL NUMBER OF LITERAL STRINGS
XREFCNT  DS    F              ACTUAL NUMBER OF XREF ENTRIES
DUMMY    DS    CL36           CR13079 - WE DONT USE THIS AREA
DINITPTR DS    A              CR13079 - INITIAL DATA POINTER
DRCLEN   EQU    *-DROOTCEL
         MEND
