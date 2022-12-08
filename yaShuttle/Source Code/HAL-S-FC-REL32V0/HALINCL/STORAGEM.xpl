 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STORAGEM.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /*     REVISION HISTORY :                                                  */
 /*     ------------------                                                  */
 /*    DATE   NAME  REL    DR NUMBER AND TITLE                              */
 /*                                                                         */
 /* 07/13/95  DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING         */
 /*                11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)    */
 /*                                                                         */
 /***************************************************************************/
   STORAGE_MGT:                                                                 00000100
   PROCEDURE(VAR_LOC, SIZE);                                                    00000200
      DECLARE (VAR_LOC, SIZE, I,J,K) FIXED;                                     00000300
      I = FREELIMIT + 512;  /* TOP OF AVAIL MEM */                              00000400
      J = (I - SIZE) & "00FFFFF8";  /* ADDR FOR NEW VARIABLE */                 00000500
      COREWORD(VAR_LOC) = J;  /* SET UP BASED STORAGE */                        00000600
      IF J - 512 <= FREEPOINT THEN DO;                                          00000700
         CALL COMPACTIFY;                                                       00000800
         IF J - 512 <= FREEPOINT THEN DO;                                       00000900
            MEMORY_FAILURE = TRUE;                                              00001000
            CALL ERROR(CLASS_B, 1); /* CR12416 */                               00001100
         END;                                                                   00001200
      END;                                                                      00001300
      FREELIMIT = J - 512;                                                      00001400
      DO K = J TO I - 1 BY 4;  /* ZERO THE ACQUIRED AREA */                     00001500
         COREWORD(K) = 0;                                                       00001600
      END;                                                                      00001700
   END STORAGE_MGT;                                                             00001800
