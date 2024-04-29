 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKTOK.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  CHECK_TOKEN                                            */
 /* MEMBER NAME:     CHECKTOK                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          NSTATE            BIT(16)                                      */
 /*          NLOOK             BIT(16)                                      */
 /*          NTOKEN            BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          APPLY1                                                         */
 /*          APPLY2                                                         */
 /*          INDEX1                                                         */
 /*          INDEX2                                                         */
 /*          LOOK1                                                          */
 /*          LOOK2                                                          */
 /*          MAXL#                                                          */
 /*          MAXP#                                                          */
 /*          MAXR#                                                          */
 /*          READ1                                                          */
 /*          SP                                                             */
 /*          STATE_STACK                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          I                                                              */
 /*          J                                                              */
 /*          K                                                              */
 /* CALLED BY:                                                              */
 /*          RECOVER                                                        */
 /***************************************************************************/
                                                                                01528800
                                                                                01528900
                                                                                01529000
                                                                                01529100
                                                                                01529200
 /*              SYNTACTIC PARSING FUNCTIONS                              */    01529300
                                                                                01529400
                                                                                01529500
                                                                                01529600
CHECK_TOKEN:                                                                    01529700
   PROCEDURE (NSTATE,NLOOK,NTOKEN) FIXED;                                       01529800
      DECLARE (NSTATE,NLOOK,NTOKEN) BIT(16);                                    01529900
                                                                                01530000
 /*  THIS PROCEDURE LOOKS AHEAD AT FUTURE STATE TRANSITIONS FROM THE GIVEN  */  01530100
 /*  STATE..  IF THE (READ) STATE CAN TAKE THE GIVEN TOKEN, OR IF ANOTHER  */   01530200
 /*  SUCH READ STATE CAN BE REACHED BY TAKING ANOTHER BRANCH FROM A  LOOK-  */  01530300
 /*  AHEAD STATE TO WHICH TRANSITION TO THE FIRST READ STATE WAS MADE, THEN */  01530400
 /*  THE STATE ACCEPTING THE TOKEN IS RETURNED. OTHERWISE ZERO IS RETURNED. */  01530500
                                                                                01530600
      K=SP-1;                                                                   01530700
      DO WHILE NSTATE>0;                                                        01530800
         IF NSTATE<=MAXR# THEN DO;   /* READ STATE  */                          01530900
            I=INDEX1(NSTATE);                                                   01531000
            DO I=I TO I+INDEX2(NSTATE)-1;                                       01531100
               IF READ1(I)=NTOKEN THEN DO;                                      01531200
                  IF NLOOK>=0 THEN RETURN NSTATE;                               01531300
                  ELSE RETURN -NLOOK;                                           01531400
               END;                                                             01531500
            END;                                                                01531600
            IF NLOOK<=0 THEN RETURN 0;                                          01531700
            NSTATE=NLOOK;                                                       01531800
            NLOOK=-NSTATE;                                                      01531900
         END;                                                                   01532000
         ELSE IF NSTATE>MAXP# THEN DO;   /*  APPLY STATE  */                    01532100
            I=INDEX1(NSTATE);                                                   01532200
            K=K-INDEX2(NSTATE);                                                 01532300
            J=STATE_STACK(K);                                                   01532400
            DO WHILE J^=APPLY1(I);                                              01532500
               IF APPLY1(I)=0 THEN J=0;                                         01532600
               ELSE I=I+1;                                                      01532700
            END;                                                                01532800
            NSTATE=APPLY2(I);                                                   01532900
         END;                                                                   01533000
         ELSE IF NSTATE<=MAXL# THEN DO;   /* LOOK AHEAD STATE  */               01533100
            I=INDEX1(NSTATE);                                                   01533200
            J=NTOKEN;                                                           01533300
            DO WHILE LOOK1(I)^=J;                                               01533400
               IF LOOK1(I)=0 THEN J=0;                                          01533500
               ELSE I=I+1;                                                      01533600
            END;                                                                01533700
            NSTATE=LOOK2(I);                                                    01533800
         END;                                                                   01533900
         ELSE NSTATE=0;     /*  PUSH STATE  */                                  01534000
      END;                                                                      01534100
      RETURN 0;                                                                 01534200
   END CHECK_TOKEN;                                                             01534300
