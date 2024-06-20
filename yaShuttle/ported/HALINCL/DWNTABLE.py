#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   DWNTABLE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-31 RSB  Ported
'''

'''
/*  ARRAY OF ERROR CLASSES       */
/*  ANY ADDITIONS TO THIS TABLE OF ERROR CLASSES SHOULD ALSO BE REFLECTED  */
/* IN THE INCLUDE LIBRARY MEMBER NAME CERRDECL FOR CORRECT ERROR PROCESSING*/
/*                                                                         */
/*  NOTE:  DELETED MANY UNUSED MEMBERS FROM THE ERRORLIB.                  */
/*         OUT OF THE MANY MEMBERS, FOUR ENTIRE CLASSES WERE DELETED.      */
/*         THE CLASSES ARE: DF, PD, SA, AND ZR.                            */
/*         IN ORDER TO AVOID REORGANIZING THE FOLLOWING ERROR CLASS TABLE  */
/*         WHICH WOULD NECESSITATE RETESTING THE ENTIRE ERRORLIB, NO       */
/*         DELETIONS WERE MADE IN THIS ROUTINE AND NO IMPACTS ARE NOTICED! */
/*                                                                         */
'''

NUM_ERR = 120;
ERROR_INDEX = ('CLASS_A ', 'CLASS_AA',
    'CLASS_AV', 'CLASS_B ', 'CLASS_BB', 'CLASS_BI', 'CLASS_BN',
    'CLASS_BS', 'CLASS_BT', 'CLASS_BX', 'CLASS_C ', 'CLASS_D ', 'CLASS_DA', 'CLASS_DC',
    'CLASS_DD', 'CLASS_DF', 'CLASS_DI', 'CLASS_DL', 'CLASS_DN', 'CLASS_DQ', 'CLASS_DS',
    'CLASS_DT', 'CLASS_DU', 'CLASS_E ', 'CLASS_EA', 'CLASS_EB', 'CLASS_EC', 'CLASS_ED',
    'CLASS_EL', 'CLASS_EM', 'CLASS_EN', 'CLASS_EO', 'CLASS_EV', 'CLASS_F ', 'CLASS_FD',
    'CLASS_FN', 'CLASS_FS', 'CLASS_FT', 'CLASS_G ', 'CLASS_GB', 'CLASS_GC', 'CLASS_GE',
    'CLASS_GL', 'CLASS_GV', 'CLASS_I ', 'CLASS_IL', 'CLASS_IR', 'CLASS_IS', 'CLASS_L ',
    'CLASS_LB', 'CLASS_LC', 'CLASS_LF', 'CLASS_LS', 'CLASS_M ', 'CLASS_MC', 'CLASS_ME',
    'CLASS_MO', 'CLASS_MS', 'CLASS_P ', 'CLASS_PA', 'CLASS_PC', 'CLASS_PD', 'CLASS_PE',
    'CLASS_PF', 'CLASS_PL', 'CLASS_PM', 'CLASS_PP', 'CLASS_PR', 'CLASS_PS', 'CLASS_PT',
    'CLASS_PU', 'CLASS_Q ', 'CLASS_QA', 'CLASS_QD', 'CLASS_QS', 'CLASS_QX', 'CLASS_R ',
    'CLASS_RE', 'CLASS_RT', 'CLASS_RU', 'CLASS_S ', 'CLASS_SA', 'CLASS_SC', 'CLASS_SP',
    'CLASS_SQ', 'CLASS_SR', 'CLASS_SS', 'CLASS_ST', 'CLASS_SV', 'CLASS_T ', 'CLASS_TC',
    'CLASS_TD', 'CLASS_U ', 'CLASS_UI', 'CLASS_UP', 'CLASS_UT', 'CLASS_V ', 'CLASS_VA',
    'CLASS_VC', 'CLASS_VE', 'CLASS_VF', 'CLASS_X ', 'CLASS_XA', 'CLASS_XD', 'CLASS_XI',
    'CLASS_XM', 'CLASS_XQ', 'CLASS_XR', 'CLASS_XS', 'CLASS_XU', 'CLASS_XV', 'CLASS_Z ',
    'CLASS_ZB', 'CLASS_ZC', 'CLASS_ZI', 'CLASS_ZN', 'CLASS_ZO', 'CLASS_ZP', 'CLASS_ZR',
    'CLASS_ZS', '');

ERR_VALUE = (
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37,
    38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54,
    55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71,
    72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88,
    89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105,
    106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120);
