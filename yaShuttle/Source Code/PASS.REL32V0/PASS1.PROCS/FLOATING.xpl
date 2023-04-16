 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FLOATING.xpl
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
 /* PROCEDURE NAME:  FLOATING                                               */
 /* MEMBER NAME:     FLOATING                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          VAL               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /* CALLED BY:                                                              */
 /*          PREC_SCALE                                                     */
 /*          SETUP_NO_ARG_FCN                                               */
 /***************************************************************************/
                                                                                00286900
FLOATING:                                                                       00287000
   PROCEDURE (VAL);                                                             00287100
      DECLARE VAL FIXED;                                                        00287200
      DW(0)=DW(8);                                                              00287300
      IF VAL<0 THEN DO;                                                         00287310
         VAL=-VAL;                                                              00287320
         CALL INLINE("58",1,0,DW_AD);                                           00287330
         CALL INLINE("97",8,0,1,0);                                             00287340
      END;                                                                      00287350
      DW(1)=VAL;                                                                00287400
      CALL INLINE("58",1,0,DW_AD);                          /* L    1,DW_AD  */ 00287500
      CALL INLINE("2B",0,0);                                /* SDR  0,0      */ 00287600
      CALL INLINE("6A",0,0,1,0);                            /* AD   0,0(0,1) */ 00287700
      CALL INLINE("60",0,0,1,0);                            /* STD  0,0(0,1) */ 00287800
   END FLOATING;                                                                00287900
