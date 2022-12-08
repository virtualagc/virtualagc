 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETDEBUG.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_DEBUG_TOGGLES                                      */
 /* MEMBER NAME:     SETDEBUG                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          HVAL              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DONT_LINK                                                      */
 /*          FORMATTED_DUMP                                                 */
 /*          HALMAT_DUMP                                                    */
 /*          PROC_TRACE                                                     */
 /*          VMEM_DUMP                                                      */
 /*          WALK_TRACE                                                     */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
                                                                                00140280
SET_DEBUG_TOGGLES:                                                              00140290
   PROCEDURE (HVAL);                                                            00140300
      DECLARE HVAL BIT(16);                                                     00140310
                                                                                00140320
      DO CASE HVAL - 100;                                                       00140330
         DO;      /* DEB H(100) */                                              00140340
            VMEM_DUMP = TRUE;                                                   00140350
         END;                                                                   00140360
         DO;      /* DEB H(101) */                                              00140370
            FORMATTED_DUMP = TRUE;                                              00140380
         END;                                                                   00140390
         DO;      /* DEB H(102) */                                              00140400
            DONT_LINK =  TRUE;                                                  00140410
         END;                                                                   00140420
         DO;      /* DEB H(103) */                                              00140430
            PROC_TRACE = PROC_TRACE = 0;                                        00140440
         END;                                                                   00140450
         DO;      /* DEB H(104) */                                              00140460
            WALK_TRACE = WALK_TRACE = 0;                                        00140470
         END;                                                                   00140480
         DO;  /* DEB H(105) */                                                  00140490
            HALMAT_DUMP = TRUE;                                                 00140500
         END;                                                                   00140510
         ;;;;;;;;;                                                              00140520
         END;                                                                   00140530
   END SET_DEBUG_TOGGLES;                                                       00140540
