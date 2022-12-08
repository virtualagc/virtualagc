*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DIAGSYS.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         DIAGSYS
DIAGSYS  DSECT
AHALSIM  DS    A              ADDRESS OF HALSIM
ASDFPKG  DS    A              ADDRESS OF SDFPKG
ACOMMUNE DS    A              ADDRESS OF COMMTABL
AFINAL   DS    A              ADDRESS OF FINAL TABLES
LENFINAL DS    F              LENGTH OF FINAL TABLES
AFILES   DS    A              ADDRESS OF FILE DIRECTORY
ASTMTS   DS    A              ADDRESS OF STMT TRIGGERS
ATIMET   DS    A              ADDRESS OF TIME TRIGGERS
ATIMES   DS    A              ADDRESS OF TIME ACTIONS
AMISC    DS    A              ADDRESS OF MISC TRIGGERS
AACTION  DS    A              ADDRESS OF ACTION STACK
ASYMBS   DS    A              ADDRESS OF SYMBOL STACK
#FDIRENT DS    F              # OF FILE DIRECTORY ENTRIES
#TTRIGS  DS    F              # OF TIME TRIGGERS
#MTRIGS  DS    F              # OF MISC TRIGGERS
BASEADDR DS    A              BASE ADDRESS OF COMPILATION UNIT
STKFRAME DS    A              STACK FRAME ADDRESS
SLISTADR DS    A              POINTER TO SYMBOL NUMBER LIST
STRCBASE DS    A              ADDRESS OF BEGINNING OF STRUCTURE
#HWORDS  DS    H              NUMBER OF HALFWORDS IN SYMBOL # LIST
BLOCK#   DS    H              BLOCK NUMBER TO BE DUMPED
TRACEDUR DS    H              TRACE DURATION COUNTER
TRACELVL DS    CL1            TRACE LEVEL FLAG
MNODEFLG DS    CL1            FLAG FOR DUMPING MINOR NODES
COPYWIDE DS    F              WIDTH OF STRUCTURE COPY
#COPIES  DS    H              NUMBER OF COPIES
OFFSET#  DS    H              ARRAY OFFSET FOR STACK COMPUTATION
STACKPTR DS    F              POINTER TO STACK INFO ENTRY
DATAPTR  DS    F              POINTER TO STACK VARIABLE DATA
PAG#LIM  DS    H              NUMBER OF PAGES SPECIFIED BY USER
VMSIZE   DS    H              # OF ELEMENTS IN ONE VECTOR OR MATRIX
NAMEFLAG DS    CL1            FLAG TO INDICATE NAME VARIABLE TO RESOLVE
HBFLAG   DS    CL1            STMT PROCESSOR CODE
         MEND
