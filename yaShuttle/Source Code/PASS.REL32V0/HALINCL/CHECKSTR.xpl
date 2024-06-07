 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKSTR.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/*                                                                         */
/*  REVISION HISTORY :                                                     */
/*  ------------------                                                     */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
/*                                                                         */
/*06/12/98 DAS   29V0  109097 INCORRECT ZB1 OR BS123 ERROR GENERATED       */
/*               14V0                                                      */
/*                                                                         */
/*12/09/99 DAS   30V0  CR13212 ALLOW NAME REMOTE VARIABLES IN THE          */
/*               15V0           RUNTIME STACK                              */
/*                                                                         */
/***************************************************************************/
CHECK_STRUC_CONFLICTS:                                                          00000100
   PROCEDURE;                                                                   00000200
      DECLARE SNAME CHARACTER, KIN_REF BIT(16);                                 00000300
      SNAME=SYT_NAME(ID_LOC);                                                   00000400
      IF SYT_CLASS(ID_LOC)^=VAR_CLASS THEN DO;                                  00000500
         IF STRUC_DIM^=0 THEN DO;                                               00000600
            CALL ERROR(CLASS_DD,12,SNAME);                                      00000700
            STRUC_DIM=0;                                                        00000800
         END;                                                                   00000900
         IF SUBSTR(SYT_NAME(STRUC_PTR),1)=SNAME THEN                            00001000
            CALL ERROR(CLASS_DQ,3);                                             00001100
      END;                                                                      00001200
      ELSE IF SUBSTR(SYT_NAME(STRUC_PTR),1)=SNAME THEN DO;                      00001300
         KIN=STRUC_PTR;                                                         00001400
         IF STRUC_PTR < PROCMARK THEN                                           00001500
                              CALL ERROR(CLASS_DQ,5,SNAME);                     00001600
         ELSE IF SYT_PTR(STRUC_PTR)^=0 THEN CALL ERROR(CLASS_DQ,4,SNAME);       00001700
         ELSE IF (SYT_FLAGS(STRUC_PTR)&DUPL_FLAG)^=0 THEN                       00001800
                       CALL ERROR(CLASS_DQ,8,SNAME);                            00001900
         ELSE IF (SYT_FLAGS(STRUC_PTR)&EVIL_FLAG)=0 THEN DO FOREVER;            00002000
            DO WHILE SYT_LINK1(KIN)>0;                                          00002100
               KIN=SYT_LINK1(KIN);                                              00002200
            END;                                                                00002300
            IF SYT_TYPE(KIN)=MAJ_STRUC THEN DO;                                 00002400
               CALL ERROR(CLASS_DQ,6,SNAME);                                    00002500
               GO TO MNF_CHECK;                                                 00002600
            END;                                                                00002700
            DO WHILE SYT_LINK2(KIN)<0;                                          00002800
               KIN=-SYT_LINK2(KIN);                                             00002900
            END;                                                                00003000
            KIN=SYT_LINK2(KIN);                                                 00003100
            IF KIN=0 THEN DO;                                                   00003200
               SYT_PTR(STRUC_PTR)=ID_LOC;                                       00003300
               GO TO MNF_CHECK;                                                 00003400
            END;                                                                00003500
         END;                                                                   00003600
      END;                                                                      00003700
   MNF_CHECK:                                                                   00003800
      IF (SYT_FLAGS(STRUC_PTR)&MISC_NAME_FLAG)^=0 THEN DO;                      00003900
      /*CR13212 - REMOVED DQ10 ERROR */
         IF BUILDING_TEMPLATE THEN /*CR13212*/                                  00004100
              SYT_FLAGS(REF_ID_LOC)=SYT_FLAGS(REF_ID_LOC)|MISC_NAME_FLAG;       00004200
      END;                                                                      00004300
   END CHECK_STRUC_CONFLICTS;                                                   00004400
