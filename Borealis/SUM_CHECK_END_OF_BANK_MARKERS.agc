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
##              2017-06-28 MAS  Switched to using BNKSUM as part of the conversion to
##                              the AGC YUL target.

                BNKSUM          00

                BNKSUM          01

                BNKSUM          02

                BNKSUM          03


                BNKSUM          04

                BNKSUM          05

                BNKSUM          06

                BNKSUM          07

                BNKSUM          10


                BNKSUM          11

                BNKSUM          12

                BNKSUM          13

                BNKSUM          14

                BNKSUM          15

                BNKSUM          16


                BNKSUM          17

                BNKSUM          20

                BNKSUM          21

                BNKSUM          22

                BNKSUM          23


                BNKSUM          24

# The remaining banks are currently unused, but bank-end markers and banksums are put into
# them to allow self-check to verify operation of every bank
                BANK            25
                OCT             0
                BNKSUM          25

                BANK            26
                OCT             0
                BNKSUM          26

                BANK            27
                OCT             0
                BNKSUM          27

                BANK            30
                OCT             0
                BNKSUM          30

                BANK            31
                OCT             0
                BNKSUM          31

                BANK            32
                OCT             0
                BNKSUM          32

                BANK            33
                OCT             0
                BNKSUM          33

                BANK            34
BANK34          OCT             0
                BNKSUM          34

                BANK            35
                OCT             0
                BNKSUM          35

                BANK            36
                OCT             0
                BNKSUM          36

                BANK            37
                OCT             0
                BNKSUM          37

                BANK            40
                OCT             0
                BNKSUM          40

                BANK            41
                OCT             0
                BNKSUM          41

                BANK            42
                OCT             0
                BNKSUM          42

                BANK            43
LASTBANK        OCT             0
                BNKSUM          43
