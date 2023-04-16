 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DWNTABLE.xpl
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
 
   /******************************************************************/         00010000
   /*  REVISION HISTORY :                                            */         00020000
   /*  ------------------                                            */         00030000
   /*  DATE   NAME  REL   DR NUMBER AND TITLE                        */         00040000
   /*                                                                */         00050000
   /*04/09/91 RSJ   24V0  CR11096   ADD NEW ERROR CLASS XR           */         00060000
   /*                                                                */         00050000
   /*08/13/91 PMA    7V0  CR11114   ADDED ERROR CLASS "PR" FOR   BFS */         00062900
   /*                                                                */         00050000
   /*12/08/92 JAC    8V0  CR11096   MERGING 24V0 WITH 7V0; BUMPED UP */         00063000
   /*                               NUM_ERR BY 1 (TO 120)            */
   /*                                                                */         00061000
   /*04/07/94 PMA   26V0/ CR11146   ADDED DEVELOPER NOTE             */
   /*                                                                */
   /******************************************************************/         00061100
   /*  ARRAY OF ERROR CLASSES       */                                          00062000
   /*  ANY ADDITIONS TO THIS TABLE OF ERROR CLASSES SHOULD ALSO BE REFLECTED */ 00062100
   /* IN THE INCLUDE LIBRARY MEMBER NAME CERRDECL FOR CORRECT ERROR PROCESSING*/00062200
   /*                                                                         */
   /*  NOTE:  CR11146 DELETED MANY UNUSED MEMBERS FROM THE ERRORLIB.          */
   /*         OUT OF THE MANY MEMBERS, FOUR ENTIRE CLASSES WERE DELETED.      */
   /*         THE CLASSES ARE: DF, PD, SA, AND ZR.                            */
   /*         IN ORDER TO AVOID REORGANIZING THE FOLLOWING ERROR CLASS TABLE  */
   /*         WHICH WOULD NECESSITATE RETESTING THE ENTIRE ERRORLIB, NO       */
   /*         DELETIONS WERE MADE IN THIS ROUTINE AND NO IMPACTS ARE NOTICED! */
   /*                                                                         */
                                                                                00062300
   DECLARE NUM_ERR LITERALLY '120'; /* CR11096 #D -- ADDED CLASS_XR  */         00063001
                                    /* BUMPED NUMBER UP SINCE PR WAS */
                                    /* ALSO ADDED                    */
   DECLARE ERROR_INDEX(NUM_ERR) CHARACTER INITIAL('CLASS_A ','CLASS_AA',        00068000
   'CLASS_AV','CLASS_B ','CLASS_BB','CLASS_BI','CLASS_BN',                      00068100
   'CLASS_BS','CLASS_BT','CLASS_BX','CLASS_C ','CLASS_D ','CLASS_DA','CLASS_DC',00069600
   'CLASS_DD','CLASS_DF','CLASS_DI','CLASS_DL','CLASS_DN','CLASS_DQ','CLASS_DS',00070300
   'CLASS_DT','CLASS_DU','CLASS_E ','CLASS_EA','CLASS_EB','CLASS_EC','CLASS_ED',00071000
   'CLASS_EL','CLASS_EM','CLASS_EN','CLASS_EO','CLASS_EV','CLASS_F ','CLASS_FD',00071700
   'CLASS_FN','CLASS_FS','CLASS_FT','CLASS_G ','CLASS_GB','CLASS_GC','CLASS_GE',00072400
   'CLASS_GL','CLASS_GV','CLASS_I ','CLASS_IL','CLASS_IR','CLASS_IS','CLASS_L ',00073100
   'CLASS_LB','CLASS_LC','CLASS_LF','CLASS_LS','CLASS_M ','CLASS_MC','CLASS_ME',00073800
   'CLASS_MO','CLASS_MS','CLASS_P ','CLASS_PA','CLASS_PC','CLASS_PD','CLASS_PE',00074500
   'CLASS_PF','CLASS_PL','CLASS_PM','CLASS_PP','CLASS_PR','CLASS_PS','CLASS_PT',00075208
   'CLASS_PU','CLASS_Q ','CLASS_QA','CLASS_QD','CLASS_QS','CLASS_QX','CLASS_R ',00075908
   'CLASS_RE','CLASS_RT','CLASS_RU','CLASS_S ','CLASS_SA','CLASS_SC','CLASS_SP',00076609
   'CLASS_SQ','CLASS_SR','CLASS_SS','CLASS_ST','CLASS_SV','CLASS_T ','CLASS_TC',00077308
   'CLASS_TD','CLASS_U ','CLASS_UI','CLASS_UP','CLASS_UT','CLASS_V ','CLASS_VA',00078008
   'CLASS_VC','CLASS_VE','CLASS_VF','CLASS_X ','CLASS_XA','CLASS_XD','CLASS_XI',00078708
   'CLASS_XM','CLASS_XQ','CLASS_XR','CLASS_XS','CLASS_XU','CLASS_XV','CLASS_Z ',00079408
   'CLASS_ZB','CLASS_ZC','CLASS_ZI','CLASS_ZN','CLASS_ZO','CLASS_ZP','CLASS_ZR',
   'CLASS_ZS');
                                                                                00081000
   /* CR11096 #D  -- ADDED 119 IN 24V0 & 120 IN  8V0 */                         00081101
   ARRAY ERR_VALUE(NUM_ERR) FIXED INITIAL(                                      00081200
         1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,                    00082000
         21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,                    00140000
         38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,                    00310000
         55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,                    00480000
         72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,                    00650000
         89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,              00820001
         106,107,108,109,110,111,112,113,114,115,116,117,118,119,120);          00980001
