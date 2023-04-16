 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CSECTTYP.xpl
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
 /* PROCEDURE NAME:  CSECT_TYPE                                             */
 /* MEMBER NAME:     CSECTTYP                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*       BIT(16)                                                           */
 /* INPUT PARAMETERS:                                                       */
 /*       PTR               BIT(16)                                         */
 /*       OP                BIT(16)                                         */
 /* LOCAL DECLARATIONS:                                                     */
 /*       FRM               BIT(16)                                         */
 /*       LC2               BIT(16)                                         */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       AUTO_FLAG                            PROC_LEVEL                   */
 /*       COMPOOL_LABEL                        REENTRANT_FLAG               */
 /*       COMPOOL#P                            REMOTE_FLAG                  */
 /*       COMPOOL#R                            REMOTE#R                     */
 /*       I_FORM                               STACKADDR                    */
 /*       I_LOC2                               STACKVAL                     */
 /*       INCLUDED_REMOTE                      SYM_FLAGS                    */
 /*       INCREM#P                             SYM_SCOPE                    */
 /*       IND_STACK                            SYM_TAB                      */
 /*       LIT                                  SYM_TYPE                     */
 /*       LOCAL#D                              SYT_FLAGS                    */
 /*       NAME_OR_REMOTE                       SYT_SCOPE                    */
 /*       NONHAL_FLAG                          SYT_TYPE                     */
 /*       PARM_FLAGS                           TEMPORARY_FLAG               */
 /*       PDENTRY#E                            WORK                         */
 /*       POINTER_FLAG                                                      */
 /* CALLED BY:                                                              */
 /*       INITIALISE                                                        */
 /*       GENERATE                                                          */
 /***************************************************************************/
 /*  REVISION HISTORY :                                              */
 /*  ------------------                                              */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                          */
 /*                                                                  */
 /*07/08/91 RSJ   24V0  CR11096F #DFLAG - USED TO TELL WHICH CSECT   */
 /*                              A SYMBOL IS FOUND                   */
 /*                                                                  */
 /*12/23/92 PMA    8V0  *        MERGED 7V0 AND 24V0 COMPILERS.      */
 /*                              * REFERENCE 24V0 CR/DRS             */
 /*                                                                  */
 /*12/06/95 SMR   27V1  DR108618 DI107 ERROR INCORRECTLY EMITTED FOR */
 /*               11V1           NAME PROGRAM & NAME TASK            */
 /*                                                                  */
 /* 3/04/97 TEV   28V0/ DR109055 MATRIX STRUCTURE NODE USE           */
 /*               12V0           INCORRECTLY CALLS VR1SN             */
 /********************************************************************/
   /*------------------------------ #D ------------------------------*/         01508020
   /* DANNY -- RETURN THE CSECT TYPE OF THE GIVEN SYMBOL TABLE       */         01508030
   /*          POINTER.                                              */         01508040
   CSECT_TYPE: PROCEDURE(PTR,OP) BIT(16);                                       01508050
      DECLARE (PTR,OP,FRM,LC2) BIT(16);                                         01508050
      /* STRC_WLK --> STRUCT_WALK FROM INDIRECT STACK    -- DR109055 */
      /* P_R      --> POINTS_REMOTE FROM INDIRECT STACK  -- DR109055 */
      DECLARE (STRC_WLK,P_R) BIT(16);                    /* DR109055 */
                                                                                01508050
      /* CLEAR STRC_WLK AND P_R WHEN OP IS NOT PASSED IN -- DR109055 */
      IF OP=0 THEN FRM,LC2,STRC_WLK,P_R = 0; /* OP MAY NOT BE PASSED IN */      01508050
      ELSE DO;                                                                  01508050
         FRM = IND_STACK(OP).I_FORM;                                            01508050
         LC2 = IND_STACK(OP).I_LOC2;                                            01508050
         STRC_WLK = IND_STACK(OP).I_STRUCT_WALK;         /* DR109055 */
         P_R = IND_STACK(OP).I_PNTREMT;                  /* DR109055 */
         OP = 0;                                                                01508050
      END;                                                                      01508050
      IF PTR < 1 THEN RETURN -1; /* HANDLE NULL VARIABLE */                     01508050
                                                                                01508050
      /* HANDLE LITERALS (#D). SAVE_LITERAL CHANGES THE FORM */                 01508050
      /* FROM LIT (5) TO CHARLIT (8) + OPMODE (0 - 5).       */                 01508050
      IF (FRM = LIT) | ((FRM > 7) & (FRM < 14)) THEN DO;                        01508050
         RETURN LOCAL#D;                                                        01508050
      END;                                                                      01508050
                                                                                01508050
      IF (FRM=WORK) | (LC2=-1) THEN DO; /* STORED VAC (ON STACK) */             01508050
         RETURN STACKVAL;                                                       01508050
      END;                                                                      01508050
                                                                                01508050
      /* CHECK IF A STRUCTURE WALK OCCURRED. IF SO, CHECK    -- DR109055*/
      /* WHICH SECTOR OF MEMORY WE ENDED UP IN. OTHERWISE,   -- DR109055*/
      /* CONTINUE WITH THE REST OF THE ROUTINE...            -- DR109055*/
      IF STRC_WLK THEN DO;                                    /*DR109055*/
         /* WHEN POINTS_REMOTE IS SET, WE DEREFERENCED A     -- DR109055*/
         /* NAME REMOTE ADDRESS SO RETURN NAME32 INDICATOR.  -- DR109055*/
         /* ELSE WE DEREFERENCED A 16-BIT NAME ADDRESS SO    -- DR109055*/
         /* RETURN A NAME16 INDICATOR.                       -- DR109055*/
         IF P_R THEN                                          /*DR109055*/
            RETURN STRUCT_NAME32;                             /*DR109055*/
         ELSE                                                 /*DR109055*/
            RETURN STRUCT_NAME16;                             /*DR109055*/
      END;                                                    /*DR109055*/
      ELSE                                                    /*DR109055*/

      IF (SYT_FLAGS(PTR) & POINTER_FLAG) ^= 0 THEN DO;                          01508460
         RETURN STACKADDR; /* ADDRESS ON STACK */                               01508470
                           /*(FORMAL PARAMETER PASSED BY REFERENCE)*/           01508470
      END;                                                                      01508510
      ELSE                                                                      01508510
                                                                                01508520
      IF ((SYT_FLAGS(PTR) & TEMPORARY_FLAG) ^= 0) |                             01508390
         ((SYT_FLAGS(PTR) & PARM_FLAGS)     ^= 0) |                             01508390
         (((SYT_FLAGS(PTR) & AUTO_FLAG) ^= 0) &                                 01508390
          ((SYT_FLAGS(PROC_LEVEL(SYT_SCOPE(PTR))) & REENTRANT_FLAG)^=0))        01508390
      THEN DO;          /* DATA ON STACK */                                     01508400
         RETURN STACKVAL;                                                       01508400
      END;                                                                      01508440
      ELSE                                                                      01508440
                                                                                01508450
      IF (SYT_FLAGS(PTR) & INCLUDED_REMOTE) ^= 0 THEN DO;                       01508530
         RETURN INCREM#P;  /* INCLUDED REMOTE COMPOOL DATA */                   01508540
      END;                                                                      01508580
      ELSE                                                                      01508580
                                                                                01508590
      IF SYT_TYPE(PROC_LEVEL(SYT_SCOPE(PTR))) = COMPOOL_LABEL                   01508600
      THEN DO;
      IF (SYT_FLAGS(PTR) & NAME_OR_REMOTE) = REMOTE_FLAG
         THEN RETURN COMPOOL#R; /* COMPOOL REMOTE DATA (#R) */
         ELSE RETURN COMPOOL#P; /* COMPOOL LOCAL DATA  (#P) */                  01508660
      END;                                                                      01508710
      ELSE                                                                      01508710
                                                                                01508720
      IF (SYT_FLAGS(PTR) & NAME_OR_REMOTE) = REMOTE_FLAG THEN DO;               01508730
         RETURN REMOTE#R; /* #R DATA */                                         01508740
      END;                                                                      01508740
                                                                                01508780
      ELSE                                                    /*DR108618*/
      IF (SYT_TYPE(PTR) = PROG_LABEL) |                       /*DR108618*/
         (SYT_TYPE(PTR) = TASK_LABEL) THEN DO;                /*DR108618*/
         RETURN PDENTRY#E; /* PROCESS DIRECTORY ENTRY (#E) */ /*DR108618*/
      END;                                                    /*DR108618*/

      ELSE DO;            /* #D DATA */                                         01508790
         RETURN LOCAL#D;                                                        01508740
      END;                                                                      01508740
                                                                                01508800
   END CSECT_TYPE;                                                              01508810
   /*----------------------------------------------------------------*/         01508020
