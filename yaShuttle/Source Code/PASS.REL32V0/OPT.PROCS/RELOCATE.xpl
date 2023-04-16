 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   RELOCATE.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  RELOCATE                                               */
 /* MEMBER NAME:     RELOCATE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          NEW               BIT(16)                                      */
 /*          START             BIT(16)                                      */
 /*          ROW               BIT(16)                                      */
 /*          CHECKTAG          BIT(8)                                       */
 /*          NOT_TOTAL_RELOCATE  BIT(8)                                     */
 /*          CHECK_TO_XREC     BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          BACK              BIT(16)                                      */
 /*          REL_STOP          BIT(16)                                      */
 /*          STOP              BIT(16)                                      */
 /*          STOPPING          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SIZE                                                           */
 /*          MOVE_TRACE                                                     */
 /*          SMRK_CTR                                                       */
 /*          VAC                                                            */
 /*          XPT                                                            */
 /*          XSMRK                                                          */
 /*          XXREC                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          HP                                                             */
 /*          OP1                                                            */
 /*          OPR                                                            */
 /*          PRESENT_HALMAT                                                 */
 /*          TAG1                                                           */
 /* CALLED BY:                                                              */
 /*          MOVE_LIMB                                                      */
 /*          PREPARE_HALMAT                                                 */
 /*          QUICK_RELOCATE                                                 */
 /***************************************************************************/
 /* DATE     WHO  RLS        DR/CR #  DESCRIPTION                           */
 /* 01/18/95 JMP  27V0/11V0  DR109007 FIX POTENTIAL INFINITE LOOP           */
 /*                                                                         */
 /* 05/27/98 JAC 29V0/14V0   DR109098 OPTIMIZER GENERATES WRONG HALMAT      */
 /*                                   FOR LONG STATEMENTS                   */
 /* 06/03/99 JAC 30V0/15V0   DR111313 BS122 ERROR FOR MULTIDIMENSIONAL      */
 /*                                   ASSIGNMENTS                           */
 /***************************************************************************/
                                                                                00919000
                                                                                00920000
                                                                                00921000
 /*  LOCAL SUBROUTINE FOR RELOCATING LINES OF CODE  */                          00922000
RELOCATE:                                                                       00923000
   PROCEDURE(NEW,START,SIZE,CHECKTAG,NOT_TOTAL_RELOCATE,CHECK_TO_XREC);         00924000
      DECLARE CHECK_TO_XREC BIT(8), STOPPING BIT(16);                           00924003
      DECLARE NOT_TOTAL_RELOCATE BIT(8),                                        00924010
         REL_STOP BIT(16);                                                      00924020
      DECLARE (NEW,START,SIZE) BIT(16);                                         00925000
      DECLARE CHECKTAG BIT(8);                                                  00926000
      DECLARE (I,STOP,BACK) BIT(16);                                            00927000
      I=NEW;                                                                    00928000
      REL_STOP,                                                                 00928500
         STOP=START+SIZE;                                                       00929000
                                                                                00929010
      IF CHECK_TO_XREC THEN STOPPING = XXREC;                                   00929012
      ELSE DO;                                                                  00929014
         STOPPING = XSMRK;                                                      00929016
         IF ^ NOT_TOTAL_RELOCATE THEN                                           00929020
            IF SMRK_CTR > REL_STOP THEN REL_STOP = SMRK_CTR;                    00929030
      END;                                                                      00929032
                                                                                00929040
      BACK=NEW-START;                                                           00930000
      DO WHILE I < REL_STOP; /*FIX POTENTIAL INFINITE LOOP DR-109*/             00930010
         DO WHILE (OPR(I) & "FFF1") ^= STOPPING & /* DR109007FIX*/              00931000
                  (OPR(I) & "FFF1") ^= XXREC; /* DR109007 FIX*/

            IF OPR(I) THEN DO;                                                  00932000
               TAG1=SHR(OPR(I),4)&"F";                                          00933000
               OP1=SHR(OPR(I),16);                                              00934000
               IF (TAG1=VAC | TAG1=XPT) & ^((OPR(I)&"C") = "C" &CHECKTAG)       00935000
                  THEN DO;                                                      00936000
                  IF OP1<START THEN DO;                                         00937000
                     IF OP1>=NEW THEN OP1=OP1+SIZE;                             00938000
                  END;                                                          00939000
                  ELSE IF OP1<STOP THEN OP1=OP1+BACK;                           00940000
                  OPR(I)=SHL(OP1,16)+(OPR(I)&"FFFF");                           00941000
               END;                                                             00942000
            END;                                                                00943000
            I=I+1;                                                              00944000
         END;                                                                   00945000
                                                                                00945010
         I = I + 2;                                                             00945030
      END;       /* WHILE I < REL_STOP */                                       00945050

      /* DR109098-UPDATE PRESENT_HALMAT POINTER FOR USE WITH   */
      /* COLLECT_MATCHES IF IT WAS DISPLACED DURING LAST MOVE  */
      IF PRESENT_HALMAT<START THEN DO;               /*DR109098*/
         IF PRESENT_HALMAT>=NEW THEN                 /*DR109098*/
            PRESENT_HALMAT=PRESENT_HALMAT+SIZE;      /*DR109098*/
      END;                                           /*DR109098*/
      ELSE IF PRESENT_HALMAT<STOP THEN               /*DR109098*/
         PRESENT_HALMAT=PRESENT_HALMAT+BACK;         /*DR109098*/
      IF HP < START THEN DO;                         /*DR111313*/
         IF HP >= NEW THEN                           /*DR111313*/
            HP = HP + SIZE;                          /*DR111313*/
      END;                                           /*DR111313*/
      ELSE IF HP < STOP THEN                         /*DR111313*/
         HP = HP + BACK;                             /*DR111313*/
                                                                                00945060
      IF MOVE_TRACE THEN OUTPUT = 'MOVE_TRACE:  '                               00945070
         || START || ' TO ' || STOP - 1 || ' MOVED BEFORE '                     00945080
         || NEW || ' AND RELOCATED TO ' || I;                                   00945090
      CHECK_TO_XREC,                                                            00945095
         CHECKTAG = 0;                                                          00946000
   END RELOCATE;                                                                00947000
