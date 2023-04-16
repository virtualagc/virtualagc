 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITADD2.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  EMIT_ADDRS                                             */
/* MEMBER NAME:     EMITADD2                                               */
/* INPUT PARAMETERS:                                                       */
/*          STMT_NO           BIT(16)                                      */
/*          ADDR1             FIXED                                        */
/*          ADDR2             FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          CUR_STMT#         BIT(16)                                      */
/*          FIRST_CALL        BIT(8)                                       */
/*          GO_FLAG           BIT(8)                                       */
/*          NODE_F            FIXED                                        */
/*          STMT_DATA_PTR     FIXED                                        */
/*          STMT#             BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLASS_BI                                                       */
/*          COMM                                                           */
/*          CURRENT_ESDID                                                  */
/*          FALSE                                                          */
/*          MODF                                                           */
/*          OPTION_BITS                                                    */
/*          PROCLIMIT                                                      */
/*          PROGPOINT                                                      */
/*          STMT_DATA_HEAD                                                 */
/*          TRUE                                                           */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          DISP                                                           */
/*          ERRORS                                                         */
/*          LOCATE                                                         */
/* CALLED BY:                                                              */
/*          OBJECT_GENERATOR                                               */
/*          TERMINATE                                                      */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> EMIT_ADDRS <==                                                      */
/*     ==> DISP                                                            */
/*     ==> LOCATE                                                          */
/*     ==> ERRORS                                                          */
/*         ==> NEXTCODE                                                    */
/*             ==> DECODEPOP                                               */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> POPCODE                                             */
/*                 ==> POPNUM                                              */
/*                 ==> POPTAG                                              */
/*             ==> AUX_SYNC                                                */
/*                 ==> GET_AUX                                             */
/*                 ==> AUX_LINE                                            */
/*                     ==> GET_AUX                                         */
/*                 ==> AUX_OP                                              */
/*                     ==> GET_AUX                                         */
/*         ==> RELEASETEMP                                                 */
/*             ==> SETUP_STACK                                             */
/*             ==> CLEAR_REGS                                              */
/*                 ==> SET_LINKREG                                         */
/*         ==> COMMON_ERRORS                                               */
/***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 DKB  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /***************************************************************************/
EMIT_ADDRS:                                                                     00895000
   PROCEDURE(STMT_NO , ADDR1 , ADDR2);                                          00895500
      DECLARE STMT_NO BIT(16);                                                  00895510
      DECLARE (STMT#,CUR_STMT#) BIT(16),                                        00896000
         STMT_DATA_PTR FIXED,                                                   00896010
         (ADDR1,ADDR2) FIXED,                                                   00897000
         FIRST_CALL BIT(1) INITIAL(1),                                          00898000
         GO_FLAG BIT(1);                                                        00898500
      BASED NODE_F FIXED;                                                       00899000
                                                                                00899500
      STMT# = STMT_NO & "7FFF";                                                 00913000
      IF STMT# = 0 THEN DO;                                                     00913500
         IF FIRST_CALL THEN DO;                                                 00914000
            FIRST_CALL = FALSE;                                                 00914500
            IF (((OPTION_BITS&"100000")^=0)&((OPTION_BITS&"800")^=0)) THEN      00916500
               DO;                                                              00917000
               GO_FLAG = TRUE;                                                  00917500
               STMT_DATA_PTR = STMT_DATA_HEAD;                                  00918000
            END;                                                                00918500
         END;                                                                   00919000
         ELSE DO;                                                               00919500
            GO_FLAG = FALSE;                                                    00920000
         END;                                                                   00921000
      END;                                                                      00921500
      ELSE IF GO_FLAG THEN DO;                                                  00922000
         DO UNTIL CUR_STMT# = STMT#;                                            00922100
            IF STMT_DATA_PTR = -1 THEN DO;                                      00922110
               CALL ERRORS(CLASS_BI,510);                                       00922120
               CALL EXIT;                                                       00922130
            END;                                                                00922140
            CALL LOCATE(STMT_DATA_PTR,ADDR(NODE_F),0);                          00922150
            CUR_STMT# = (SHR(NODE_F(7),16) & "FFFF");                           00922160
            IF CUR_STMT# ^= 0 THEN STMT_DATA_PTR = NODE_F(0);                   00922170
         END;                                                                   00922180
         CALL DISP(MODF);                                                       00922190
         IF (CURRENT_ESDID >= PROGPOINT) & (CURRENT_ESDID <= PROCLIMIT)         00923900
            THEN DO;                                                            00924000
            NODE_F(8)= ADDR1;                                                   00924100
            NODE_F(9)= ADDR2;                                                   00924200
            NODE_F(10),NODE_F(11)= 0;                                           00924300
         END;                                                                   00924400
      END;                                                                      00925100
   END EMIT_ADDRS;                                                              00929500
