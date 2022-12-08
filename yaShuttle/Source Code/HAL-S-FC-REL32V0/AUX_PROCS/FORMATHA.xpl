 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMATHA.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  FORMAT_HALMAT                                          */
/* MEMBER NAME:     FORMATHA                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          HALMAT#           BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          HALMAT_PRINT#     BIT(16)                                      */
/*          BLOCK#            BIT(16)                                      */
/*          MESSAGE           CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          ASTERISK                                                       */
/*          BLANK                                                          */
/*          BLOCK_PRIME                                                    */
/*          CLOSE                                                          */
/*          COLON                                                          */
/*          COMMA                                                          */
/*          CURR_HALMAT_BLOCK                                              */
/*          HALMAT_SIZE                                                    */
/*          HALMAT                                                         */
/*          LEFT_PAREN                                                     */
/*          PERIOD                                                         */
/*          RIGHT_PAREN                                                    */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          TEMP_MAT                                                       */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          #RJUST                                                         */
/*          HEX                                                            */
/* CALLED BY:                                                              */
/*          PRETTY_PRINT_MAT                                               */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> FORMAT_HALMAT <==                                                   */
/*     ==> #RJUST                                                          */
/*     ==> HEX                                                             */
/***************************************************************************/
                                                                                00886000
                                                                                00888000
 /* ROUTINE TO FORMAT HALMAT OPERATORS/OPERANDS */                              00890000
                                                                                00892000
FORMAT_HALMAT:PROCEDURE(HALMAT#) CHARACTER;                                     00894000
                                                                                00896000
      DECLARE HALMAT# BIT(16);                                                  00898000
      DECLARE MESSAGE CHARACTER, (HALMAT_PRINT#, BLOCK#) BIT(16);               00900000
                                                                                00902000
      IF HALMAT# >= HALMAT_SIZE THEN DO;                                        00904000
         HALMAT_PRINT# = HALMAT# - 1800;                                        00906000
         BLOCK# = CURR_HALMAT_BLOCK - 1;                                        00908000
      END;                                                                      00910000
      ELSE DO;                                                                  00912000
         HALMAT_PRINT# = HALMAT#;                                               00914000
         IF BLOCK_PRIME THEN BLOCK# = CURR_HALMAT_BLOCK - 2;                    00916000
         ELSE BLOCK# = CURR_HALMAT_BLOCK - 1;                                   00918000
      END;                                                                      00920000
      TEMP_MAT = HALMAT(HALMAT#);                                               00922000
      IF (TEMP_MAT & 1) = 0 THEN                                                00924000
         MESSAGE = '           HALMAT:   ' ||                                   00926000
         HEX(SHR(TEMP_MAT, 4) & "FFF", 3) ||   /* OPCODE */                     00928000
         LEFT_PAREN ||                                                          00930000
         #RJUST(SHR(TEMP_MAT, 16) & "FF", 3) ||   /* # RANDS */                 00932000
         RIGHT_PAREN ||                                                         00934000
         COMMA ||                                                               00936000
         #RJUST(SHR(TEMP_MAT, 24) & "FF", 3) ||   /* T */                       00938000
         COMMA ||                                                               00940000
         #RJUST(SHR(TEMP_MAT, 1) & "7", 1) ||   /* CSE'S */                     00942000
         COLON ||                                                               00944000
         #RJUST(BLOCK#, 3) ||                                                   00946000
         PERIOD ||                                                              00948000
         #RJUST(HALMAT_PRINT#, 4) ||                                            00950000
         BLANK;                                                                 00952000
      ELSE DO;                                                                  00954000
         MESSAGE = '                   ' ||                                     00956000
            #RJUST(SHR(TEMP_MAT, 16) & "7FFF", 5) ||   /* PTR */                00958000
            LEFT_PAREN ||                                                       00960000
            #RJUST(SHR(TEMP_MAT, 4) & "F", 3) ||   /* PTR_TYPE */               00962000
            RIGHT_PAREN ||                                                      00964000
            COMMA ||                                                            00966000
            #RJUST(SHR(TEMP_MAT, 8) & "FF", 3) ||   /* T */                     00968000
            COMMA ||                                                            00970000
            #RJUST(SHR(TEMP_MAT, 1) & "7", 1) ||   /* CSE */                    00972000
            COLON ||                                                            00974000
            #RJUST(BLOCK#, 3) ||                                                00976000
            PERIOD ||                                                           00978000
            #RJUST(HALMAT_PRINT#, 4);                                           00980000
         IF (TEMP_MAT & "80000000") ^= 0 THEN                                   00982000
            MESSAGE = MESSAGE || ASTERISK;                                      00984000
         ELSE                                                                   00986000
            MESSAGE = MESSAGE || BLANK;                                         00988000
      END;                                                                      00990000
      RETURN MESSAGE;                                                           00992000
                                                                                00994000
      CLOSE FORMAT_HALMAT;                                                      00996000
