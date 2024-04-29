 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HOWTOINI.xpl
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
 /* PROCEDURE NAME:  HOW_TO_INIT_ARGS                                       */
 /* MEMBER NAME:     HOWTOINI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          NA                FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NU                FIXED                                        */
 /*          NW                FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ID_LOC                                                         */
 /*          MAJ_STRUC                                                      */
 /*          NAME_IMPLIED                                                   */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_TYPE                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ICQ_TERM#                                                      */
 /*          ICQ_ARRAY#                                                     */
 /* CALLED BY:                                                              */
 /*          HALMAT_INIT_CONST                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> HOW_TO_INIT_ARGS <==                                                */
 /*     ==> ICQ_TERM#                                                       */
 /*     ==> ICQ_ARRAY#                                                      */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 02/22/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                01013100
HOW_TO_INIT_ARGS :                                                              01013200
   PROCEDURE (NA);                                                              01013300
      DECLARE NA FIXED;                                                         01013400
      DECLARE (NU,NW) FIXED;                                                    01013500
      IF SYT_TYPE(ID_LOC)=MAJ_STRUC&(^NAME_IMPLIED) THEN DO;                    01013600
         NW,NU=ICQ_TERM#(ID_LOC);                                               01013700
         IF SYT_ARRAY(ID_LOC)>0 THEN                                            01013800
            NU=SYT_ARRAY(ID_LOC)*NU;                                            01013900
      END;                                                                      01014000
      ELSE DO;                                                                  01014100
         IF NA<=1 THEN RETURN 1;                                                01014200
         NW=ICQ_TERM#(ID_LOC);                                                  01014300
         NU=ICQ_ARRAY#(ID_LOC)*NW;                                              01014400
      END;                                                                      01014500
      IF NA=NU THEN RETURN 3;  /* MATCHES TOTAL NUMBER OF ELEMENTS */           01014600
      IF NA=NW THEN RETURN 2;                                                   01014700
      IF NA>NU THEN RETURN 4;  /* NO ROOM FOR ASTERISK  */                      01014800
      RETURN 0;   /* NO MATCH AT ALL  */                                        01014900
   END HOW_TO_INIT_ARGS;                                                        01015000
