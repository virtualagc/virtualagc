 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ORDEROK.xpl
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
 /* PROCEDURE NAME:  ORDER_OK                                               */
 /* MEMBER NAME:     ORDEROK                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          TYPE              FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          COMMENT_JOIN      LABEL                                        */
 /*          E_CARD            LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CARD_TYPE                                                      */
 /*          CLASS_M                                                        */
 /*          CURRENT_CARD                                                   */
 /*          FALSE                                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          END_GROUP                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ORDER_OK <==                                                        */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00436360
                                                                                00436370
ORDER_OK:                                                                       00436380
   PROCEDURE(TYPE) BIT(1);                                                      00436390
      DECLARE TYPE FIXED;                                                       00436400
      DO CASE CARD_TYPE(BYTE(CURRENT_CARD));                                    00436500
 /*  CASE 0 -- ILLEGAL CARD TYPES  */                                           00436600
         DO;                                                                    00436700
            CALL ERROR(CLASS_M,1);                                              00436800
            BYTE(CURRENT_CARD) = BYTE('C');                                     00436900
            GO TO COMMENT_JOIN;                                                 00437000
         END;                                                                   00437100
 /*  CASE 1 -- E CARD  */                                                       00437200
E_CARD:                                                                         00437300
         DO;                                                                    00437400
            IF CARD_TYPE(TYPE) = 2 | CARD_TYPE(TYPE) = 3 THEN                   00437500
               END_GROUP = TRUE;                                                00437600
            ELSE                                                                00437700
               END_GROUP = FALSE;                                               00437800
            RETURN TRUE;                                                        00437900
         END;                                                                   00438000
 /*  CASE 2 -- M CARD  */                                                       00438100
         GO TO E_CARD;                                                          00438200
 /*  CASE 3 -- S CARD  */                                                       00438300
         DO;                                                                    00438400
            END_GROUP = FALSE;                                                  00438500
            IF CARD_TYPE(TYPE) = 2 | CARD_TYPE(TYPE) = 3 THEN                   00438600
               RETURN TRUE;                                                     00438700
            ELSE                                                                00438800
               RETURN FALSE;                                                    00438900
         END;                                                                   00439000
 /*  CASE 4 -- A COMMENT CARD  */                                               00439100
         DO;                                                                    00439200
COMMENT_JOIN:                                                                   00439300
            IF CARD_TYPE(TYPE) = 2 | CARD_TYPE(TYPE) = 3 THEN                   00439400
               END_GROUP = TRUE;                                                00439500
            ELSE                                                                00439600
               END_GROUP = FALSE;                                               00439700
            IF CARD_TYPE(TYPE) = 1 THEN                                         00439800
               RETURN FALSE;                                                    00439900
            ELSE                                                                00440000
               RETURN TRUE;                                                     00440100
         END;                                                                   00440200
         GO TO COMMENT_JOIN;  /* DIRECTIVE CARD */                              00440210
      END; /* OF DO CASE */                                                     00440300
   END ORDER_OK;                                                                00440400
