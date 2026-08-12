R0       EQU   0
R3       EQU   3
ONE      CSECT
BASEA    DS    0H
         USING BASEA,R0
         STH   R3,FARSYM
         STH   R3,NEARSYM
NEARSYM  DC    H'0'
         DS    2000H
TWO      CSECT
         DS    100H
FARSYM   DC    H'0'
         END
