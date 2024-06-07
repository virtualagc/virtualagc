 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CERRDECL.xpl
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
 
   /**************************************************************************/ 00010000
   /*  ERROR CLASSES FOR ALL PHASES */                                          00062000
   /*  ANY ADDITIONS TO THIS TABLE OF ERROR CLASSES SHOULD ALSO BE REFLECTED */ 00063000
   /*  IN THE INCLUDE LIBRARY MEMBER NAME DWNTABLE FOR DOWNGRADE UTILIZATION */ 00064000
   /*                                                                        */
   /*  NOTE:  CR11146 DELETED MANY UNUSED MEMBERS FROM THE ERRORLIB.         */
   /*         OUT OF THE MANY MEMBERS, FOUR ENTIRE CLASSES WERE DELETED.     */
   /*         THE CLASSES ARE: DF, PD, SA, AND ZR.                           */
   /*         IN ORDER TO AVOID REORGANIZING THE ERROR CLASS CHARACTER STRING*/
   /*         WHICH WOULD NECESSITATE RETESTING THE ENTIRE ERRORLIB, NO      */
   /*         DELETIONS WERE MADE IN THIS ROUTINE AND NO IMPACTS ARE NOTICED!*/
   /*                                                                        */
   /******************************************************************/         00064100
   /******************************************************************/         00064100
   /*------------------------------------------------------------------------*/ 00065000
   /*  REVISION HISTORY                                                      */ 00065100
   /*                                                                        */ 00065200
   /*  DATE         WHO    RLS    DR/CR #     DESCRIPTION                    */ 00066000
   /*                                                                        */ 00067000
   /*  04/09/91     RSJ   24V0    CR11096     ADD NEW ERROR CLASS XR         */ 00064600
   /*                                                                        */ 00064500
   /*  08/13/91     PMA    7V0    CR11114     ADDED ERROR CLASS "PR" FOR BFS */ 00067100
   /*                                                                        */
   /*  12/07/92     JAC    8V0    CR11096     MERGED 24V0 IN WITH 7V0        */
   /*                                                                        */ 00067300
   /*  04/07/92     PMA   26V0/   CR11146     ADDED DEVELOPER NOTE           */
   /*                     10V0                                               */
   /*                                                                        */ 00067300
   /*  01/30/00     DCP   30V0/   CR13211     GENERATE ADVISORY MESSAGE WHEN */
   /*                     15V0                BIT STRING ASSIGNED TO SHORTER */
   /*                                         STRING                         */
   /*  01/05/04     JAC   32V0/   CR13813     REMOTE SHOULD BE IGNORED ON    */
   /*                     17V0                NON-NAME INPUT PARAMETER       */
   /*                                                                        */
   /**************************************************************************/ 00067400
   DECLARE CLASS_A  BIT(16) INITIAL(1),                                         00068000
           CLASS_AA BIT(16) INITIAL(2),                                         00069000
           CLASS_AV BIT(16) INITIAL(3),                                         00069100
           CLASS_B  BIT(16) INITIAL(4),                                         00069200
           CLASS_BB BIT(16) INITIAL(5),                                         00069300
           CLASS_BI BIT(16) INITIAL(6),                                         00069400
           CLASS_BN BIT(16) INITIAL(7),                                         00069500
           CLASS_BS BIT(16) INITIAL(8),                                         00069600
           CLASS_BT BIT(16) INITIAL(9),                                         00069700
           CLASS_BX BIT(16) INITIAL(10),                                        00069800
           CLASS_C  BIT(16) INITIAL(11),                                        00069900
           CLASS_D  BIT(16) INITIAL(12),                                        00070000
           CLASS_DA BIT(16) INITIAL(13),                                        00070100
           CLASS_DC BIT(16) INITIAL(14),                                        00070200
           CLASS_DD BIT(16) INITIAL(15),                                        00070300
           CLASS_DF BIT(16) INITIAL(16),                                        00070400
           CLASS_DI BIT(16) INITIAL(17),                                        00070500
           CLASS_DL BIT(16) INITIAL(18),                                        00070600
           CLASS_DN BIT(16) INITIAL(19),                                        00070700
           CLASS_DQ BIT(16) INITIAL(20),                                        00070800
           CLASS_DS BIT(16) INITIAL(21),                                        00070900
           CLASS_DT BIT(16) INITIAL(22),                                        00071000
           CLASS_DU BIT(16) INITIAL(23),                                        00071100
           CLASS_E  BIT(16) INITIAL(24),                                        00071200
           CLASS_EA BIT(16) INITIAL(25),                                        00071300
           CLASS_EB BIT(16) INITIAL(26),                                        00071400
           CLASS_EC BIT(16) INITIAL(27),                                        00071500
           CLASS_ED BIT(16) INITIAL(28),                                        00071600
           CLASS_EL BIT(16) INITIAL(29),                                        00071700
           CLASS_EM BIT(16) INITIAL(30),                                        00071800
           CLASS_EN BIT(16) INITIAL(31),                                        00071900
           CLASS_EO BIT(16) INITIAL(32),                                        00072000
           CLASS_EV BIT(16) INITIAL(33),                                        00072100
           CLASS_F  BIT(16) INITIAL(34),                                        00072200
           CLASS_FD BIT(16) INITIAL(35),                                        00072300
           CLASS_FN BIT(16) INITIAL(36),                                        00072400
           CLASS_FS BIT(16) INITIAL(37),                                        00072500
           CLASS_FT BIT(16) INITIAL(38),                                        00072600
           CLASS_G  BIT(16) INITIAL(39),                                        00072700
           CLASS_GB BIT(16) INITIAL(40),                                        00072800
           CLASS_GC BIT(16) INITIAL(41),                                        00072900
           CLASS_GE BIT(16) INITIAL(42),                                        00073000
           CLASS_GL BIT(16) INITIAL(43),                                        00073100
           CLASS_GV BIT(16) INITIAL(44),                                        00073200
           CLASS_I  BIT(16) INITIAL(45),                                        00073300
           CLASS_IL BIT(16) INITIAL(46),                                        00073400
           CLASS_IR BIT(16) INITIAL(47),                                        00073500
           CLASS_IS BIT(16) INITIAL(48),                                        00073600
           CLASS_L  BIT(16) INITIAL(49),                                        00073700
           CLASS_LB BIT(16) INITIAL(50),                                        00073800
           CLASS_LC BIT(16) INITIAL(51),                                        00073900
           CLASS_LF BIT(16) INITIAL(52),                                        00074000
           CLASS_LS BIT(16) INITIAL(53),                                        00074100
           CLASS_M  BIT(16) INITIAL(54),                                        00074200
           CLASS_MC BIT(16) INITIAL(55),                                        00074300
           CLASS_ME BIT(16) INITIAL(56),                                        00074400
           CLASS_MO BIT(16) INITIAL(57),                                        00074500
           CLASS_MS BIT(16) INITIAL(58),                                        00074600
           CLASS_P  BIT(16) INITIAL(59),                                        00074700
           CLASS_PA BIT(16) INITIAL(60),                                        00074800
           CLASS_PC BIT(16) INITIAL(61),                                        00074900
           CLASS_PD BIT(16) INITIAL(62),                                        00075000
           CLASS_PE BIT(16) INITIAL(63),                                        00075100
           CLASS_PF BIT(16) INITIAL(64),                                        00075200
           CLASS_PL BIT(16) INITIAL(65),                                        00075300
           CLASS_PM BIT(16) INITIAL(66),                                        00075400
           CLASS_PP BIT(16) INITIAL(67),                                        00075500
           CLASS_PR BIT(16) INITIAL(68),                                        00075608
           CLASS_PS BIT(16) INITIAL(69),                                        00075708
           CLASS_PT BIT(16) INITIAL(70),                                        00075808
           CLASS_PU BIT(16) INITIAL(71),                                        00075908
           CLASS_Q  BIT(16) INITIAL(72),                                        00076008
           CLASS_QA BIT(16) INITIAL(73),                                        00076108
           CLASS_QD BIT(16) INITIAL(74),                                        00076208
           CLASS_QS BIT(16) INITIAL(75),                                        00076308
           CLASS_QX BIT(16) INITIAL(76),                                        00076408
           CLASS_R  BIT(16) INITIAL(77),                                        00076508
           CLASS_RE BIT(16) INITIAL(78),                                        00076608
           CLASS_RT BIT(16) INITIAL(79),                                        00076708
           CLASS_RU BIT(16) INITIAL(80),                                        00076808
           CLASS_S  BIT(16) INITIAL(81),                                        00076908
           CLASS_SA BIT(16) INITIAL(82),                                        00077008
           CLASS_SC BIT(16) INITIAL(83),                                        00077108
           CLASS_SP BIT(16) INITIAL(84),                                        00077208
           CLASS_SQ BIT(16) INITIAL(85),                                        00077308
           CLASS_SR BIT(16) INITIAL(86),                                        00077408
           CLASS_SS BIT(16) INITIAL(87),                                        00077508
           CLASS_ST BIT(16) INITIAL(88),                                        00077608
           CLASS_SV BIT(16) INITIAL(89),                                        00077708
           CLASS_T  BIT(16) INITIAL(90),                                        00077808
           CLASS_TC BIT(16) INITIAL(91),                                        00077908
           CLASS_TD BIT(16) INITIAL(92),                                        00078008
           CLASS_U  BIT(16) INITIAL(93),                                        00078108
           CLASS_UI BIT(16) INITIAL(94),                                        00078208
           CLASS_UP BIT(16) INITIAL(95),                                        00078308
           CLASS_UT BIT(16) INITIAL(96),                                        00078408
           CLASS_V  BIT(16) INITIAL(97),                                        00078508
           CLASS_VA BIT(16) INITIAL(98),                                        00078608
           CLASS_VC BIT(16) INITIAL(99),                                        00078708
           CLASS_VE BIT(16) INITIAL(100),                                       00078808
           CLASS_VF BIT(16) INITIAL(101),                                       00078908
           CLASS_X  BIT(16) INITIAL(102),                                       00079008
           CLASS_XA BIT(16) INITIAL(103),                                       00079108
           CLASS_XD BIT(16) INITIAL(104),                                       00079208
           CLASS_XI BIT(16) INITIAL(105),                                       00079308
           CLASS_XM BIT(16) INITIAL(106),                                       00079408
           CLASS_XQ BIT(16) INITIAL(107),                                       00079508
           CLASS_XR BIT(16) INITIAL(108), /* ADDED FOR #D COMPILER */           00079501
           CLASS_XS BIT(16) INITIAL(109),                                       00079600
           CLASS_XU BIT(16) INITIAL(110),                                       00079700
           CLASS_XV BIT(16) INITIAL(111),                                       00079800
           CLASS_Z  BIT(16) INITIAL(112),                                       00079900
           CLASS_ZB BIT(16) INITIAL(113),                                       00080000
           CLASS_ZC BIT(16) INITIAL(114),                                       00080100
           CLASS_ZI BIT(16) INITIAL(115),                                       00080200
           CLASS_ZN BIT(16) INITIAL(116),                                       00080300
           CLASS_ZO BIT(16) INITIAL(117),                                       00080400
           CLASS_ZP BIT(16) INITIAL(118),                                       00080500
           CLASS_ZR BIT(16) INITIAL(119),                                       00080600
           CLASS_ZS BIT(16) INITIAL(120), /*CR13211*/                           00080700
           CLASS_YA BIT(16) INITIAL(121), /*CR13211*/
           CLASS_YC BIT(16) INITIAL(122), /*CR13211*/
           CLASS_YE BIT(16) INITIAL(123), /*CR13211*/
           CLASS_YF BIT(16) INITIAL(124), /*CR13211*/
           CLASS_YD BIT(16) INITIAL(125); /*CR13813*/
   DECLARE ERROR_CLASSES CHARACTER INITIAL('A AAAVB BBBIBNBSBTBXC D DADCDDDFDIDL00082304
DNDQDSDTDUE EAEBECEDELEMENEOEVF FDFNFSFTG GBGCGEGLGVI ILIRISL LBLCLFLSM MCMEMOMS00082404
P PAPCPDPEPFPLPMPPPRPSPTPUQ QAQDQSQXR RERTRUS SASCSPSQSRSSSTSVT TCTDU UIUPUTV VA00082508
VCVEVFX XAXDXIXMXQXRXSXUXVZ ZBZCZIZNZOZPZRZSYAYCYEYFYD'); /*CR13211,CR13813*/   00083008
