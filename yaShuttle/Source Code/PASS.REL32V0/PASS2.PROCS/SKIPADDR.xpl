 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SKIPADDR.xpl
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
/* PROCEDURE NAME:  SKIP_ADDR                                              */
/* MEMBER NAME:     SKIPADDR                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CODE_LINE                                                      */
/*          CSYM                                                           */
/*          EMITTING                                                       */
/*          LHS                                                            */
/*          PRELBASE                                                       */
/*          PROGDELTA                                                      */
/*          RHS                                                            */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CODE                                                           */
/*          TEMP                                                           */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          GET_CODE                                                       */
/*          NEXT_REC                                                       */
/*          SKIP                                                           */
/* CALLED BY:                                                              */
/*          OBJECT_CONDENSER                                               */
/*          OBJECT_GENERATOR                                               */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> SKIP_ADDR <==                                                       */
/*     ==> GET_CODE                                                        */
/*     ==> NEXT_REC                                                        */
/*         ==> GET_CODE                                                    */
/*     ==> SKIP                                                            */
/***************************************************************************/
                                                                                07147500
 /* ROUTINE TO SKIP OVER ANY INSTRUCTION OPERAND */                             07148000
SKIP_ADDR:                                                                      07148500
   PROCEDURE;                                                                   07149000
      CALL NEXT_REC(1);                                                         07149500
      IF LHS(1) = CSYM THEN DO;                                                 07150000
         IF RHS(1) = PRELBASE THEN DO;                                          07150010
            IF EMITTING THEN DO;                                                07150020
               CALL NEXT_REC(1);                                                07150030
               TEMP = TEMP + PROGDELTA;                                         07150040
               CODE(GET_CODE(CODE_LINE-1)) = TEMP;                              07150050
            END;                                                                07150060
            ELSE CALL SKIP(1);                                                  07150070
         END;                                                                   07150080
         ELSE CALL SKIP(1);                                                     07150090
      END;                                                                      07150100
   END SKIP_ADDR;                                                               07150500
