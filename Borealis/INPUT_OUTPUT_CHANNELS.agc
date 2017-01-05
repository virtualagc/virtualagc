### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INPUT_OUTPUT_CHANNELS.agc
## Purpose:     This program is designed to extensively test the Apollo Guidance Computer
##              (specifically the LM instantiation of it). It is built on top of a heavily
##              stripped-down Aurora 12, with all code ostensibly added by the DAP Group
##              removed. Instead Borealis expands upon the tests provided by Aurora,
##              including corrected tests from Retread 44 and tests from Ron Burkey's
##              Validation.
## Assembler:   yaYUL
## Contact:     Mike Stewart <mastewar1@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-20 MAS  Created from Aurora 12 (with much DAP stuff removed).
##              2017-01-04 MAS  Added SUPERBNK.

HISCALAR        EQUALS          3                               
LOSCALAR        EQUALS          4                               
SUPERBNK        EQUALS          7
OUT0            EQUALS          10                              
DSALMOUT        EQUALS          11                              
CHAN12          EQUALS          12                              
CHAN13          EQUALS          13                              
CHAN14          EQUALS          14                              
MNKEYIN         EQUALS          15                              
NAVKEYIN        EQUALS          16                              
CHAN33          EQUALS          33                              
DNTM1           EQUALS          34                              
DNTM2           EQUALS          35                              
# END OF CHANNEL ASSIGNMENTS
