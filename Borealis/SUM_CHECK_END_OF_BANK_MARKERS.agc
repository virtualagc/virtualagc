### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SUM_CHECK_END_OF_BANK_MARKERS.agc
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
##              2016-12-21 MAS  Updated for new end-of-bank locations for self-tests.
##              2017-01-04 MAS  Added minimal words to all unused banks, to get self-
##                              test to at least verify that all are accessible.
##              2017-01-15 MAS  Updated for added tests. Bank 24 now occupied.

                SETLOC  ENDRTRDF
                TC
                TC
                
                SETLOC  ENDSLFS4
                TC
                TC
                
                SETLOC  ENDINTS0
                TC
                TC
                
                SETLOC  ENDSLFS2
                TC
                TC
                
                SETLOC  ENDPINS1
                TC
                TC
                
                SETLOC  ENDPINS2
                TC
                TC
                
                BANK    06
                TC
                TC
                
                BANK    07
                TC
                TC
                
                SETLOC  ENDRTSTS
                TC
                TC
                
                SETLOC  ENDEXTVS
                TC
                TC
                
                BANK    12
                TC
                TC
                
                SETLOC  ENDAMODS
                TC
                TC
                
                SETLOC  ENDIMUS1
                TC
                TC
                
                SETLOC  ENDRTBSS
                TC
                TC
                
                SETLOC  ENDIMUS3
                TC
                TC
                
                SETLOC  ENDIMUS2
                TC
                TC
                
                SETLOC  ENDSLFS1
                TC
                TC
                
                SETLOC  ENDPREL1
                TC
                TC

                SETLOC  ENDINST1
                TC
                TC

                SETLOC  ENDINST2
                TC
                TC

                SETLOC  ENDEXTST
                TC
                TC

# The remaining banks are currently unused, but bank-end markers and banksums are put into
# them to allow self-check to verify operation of every bank
                BANK    25
                TC
                TC

                BANK    26
                TC
                TC

                BANK    27
                TC
                TC

                BANK    30
                TC
                TC

                BANK    31
                TC
                TC

                BANK    32
                TC
                TC

                BANK    33
                TC
                TC

                BANK    34
BANK34          TC
                TC

                BANK    35
                TC
                TC

                BANK    36
                TC
                TC

                BANK    37
                TC
                TC

                BANK    40
                TC
                TC

                BANK    41
                TC
                TC

                BANK    42
                TC
                TC

                BANK    43
LASTBANK        TC
                TC
