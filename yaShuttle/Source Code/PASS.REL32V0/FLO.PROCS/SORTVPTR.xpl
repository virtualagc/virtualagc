 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SORTVPTR.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SORT_VPTRS                                             */
 /* MEMBER NAME:     SORTVPTR                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          NEXT(790)         LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SYM_NUM                                                        */
 /*          SYM_VPTR                                                       */
 /*          SYT_NUM                                                        */
 /*          SYT_VPTR                                                       */
 /*          VPTR_INX                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_ADD                                                        */
 /***************************************************************************/
                                                                                00309000
SORT_VPTRS:                                                                     00309001
   PROCEDURE;                                                                   00309002
      DECLARE (I,J,K) BIT(16);                                                  00309003
                                                                                00309004
      J = SHR(VPTR_INX,1);                                                      00309005
      DO WHILE J > 0;                                                           00309006
         DO K = 1 TO VPTR_INX - J;                                              00309007
            I = K;                                                              00309008
            DO WHILE SYT_NUM(I) > SYT_NUM(I+J);                                 00309009
               SYT_NUM(0) = SYT_NUM(I);                                         00309010
               SYT_NUM(I) = SYT_NUM(I+J);                                       00309011
               SYT_NUM(I+J) = SYT_NUM(0);                                       00309012
               SYT_VPTR(0) = SYT_VPTR(I);                                       00309013
               SYT_VPTR(I) = SYT_VPTR(I+J);                                     00309014
               SYT_VPTR(I+J) = SYT_VPTR(0);                                     00309015
               I = I - J;                                                       00309016
               IF I < 1 THEN GO TO NEXT;                                        00309017
            END;                                                                00309018
NEXT:                                                                           00309019
         END;                                                                   00309020
         J = SHR(J,1);                                                          00309021
      END;                                                                      00309022
      SYT_VPTR(0) = VPTR_INX;                                                   00309023
   END SORT_VPTRS;                                                              00309024
