 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ##DRIVER.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  MAIN PROGRAM                                           */
/* MEMBER NAME:     ##DRIVER                                               */
/* PURPOSE:         THE DRIVER PROGRAM FOR A PHASE OF THE COMPILER.        */
/*                  THIS MEMBER IS THE MAIN PROGRAM, THE OTHER MEMBERS     */
/*                  SHOULD BE CHECKED FOR HEADER INFORMATION.              */
/* LOCAL DECLARATIONS:                                                     */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/* EXTERNAL VARIABLES CHANGED:                                             */
/* CALLED BY:                                                              */
/***************************************************************************/
/*                                                                         */
/* REVISION HISTORY:                                                       */
/*                                                                         */
/* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
/*                                                                         */
/* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
/* 03/07/91 RSJ  23V2  CR11109  REMOVE UNUSED VARIABLES                    */
/* 10/29/93 TEV  26V0/ DR108630 0C4 ABEND OCCURS ON ILLEGAL DOWNGRADE      */
/*               10V0                                                      */
/*                                                                         */
/* 04/03/00 DCP  30V0/ CR13273  PRODUCE SDF MEMBER WHEN OBJECT MODULE      */
/*               15V0           CREATED                                    */
/*                                                                         */
/* 02/14/01 TKN  31V0/ DR111353 DOWNGRADE SUMMARY NOT PRINTED IN LISTING   */
/*               16V0                                                      */
/***************************************************************************/
                                                                                00002000
/* $HA U X I L I A R Y   H A L M A T   G E N E R A T O R   --   INTERMETRICS, IN00004000
C. */                                                                           00006000
                                                                                00008000
/*******************************************************************************00010000
   A U X I L I A R Y   H A L M A T   G E N E R A T O R :  INTERMETRICS, INC.    00012000
*******************************************************************************/00014000
        /* $Z */                                                                00016000
                                                                                00018000
                                                                                00020000
/*******************************************************************************00022000
   G L O B A L   D E C L A R A T I O N S                                        00024000
*******************************************************************************/00026000
                                                                                00028000
                                                                                00030000
/*******************************************************************************00032000
   C O M M O N   D E C L A R A T I O N S   (AND ASSOCIATED CRUFT)               00034000
*******************************************************************************/00036000
                                                                                00038000
/%INCLUDE COMMON %/                                                             00040000
DECLARE        OPTION_BITS   LITERALLY 'COMM(7)';                               00040010
DECLARE        SYT_SIZE      LITERALLY 'COMM(10)';                              00114000
                                                                                00116000
/*******************************************************************************00118000
        LIMITING SIZES FOR AUXILIARY HALMAT GENERATOR                           00120000
*******************************************************************************/00122000
                                                                                00124000
DECLARE                                                                         00126000
        DOUBLE_BLOCK_SIZE              LITERALLY '3600',                        00128000
        HALMAT_SIZE                    LITERALLY '1800',                        00130000
        AUXMAT_SIZE                    LITERALLY '1800';                        00132000
                                                                                00134000
/*******************************************************************************00136000
        S Y N T A C T I C   R E P L A C E S                                     00138000
*******************************************************************************/00140000
                                                                                00142000
DECLARE                                                                         00144000
        FUNCTION                       LITERALLY 'PROCEDURE',                   00146000
        TRUE                           LITERALLY '1',                           00148000
        FALSE                          LITERALLY '0',                           00150000
        ON                             LITERALLY '1',                           00152000
        OFF                            LITERALLY '0',                           00154000
        CLOSE                          LITERALLY 'END',                         00162000
        FOR                            LITERALLY '';                            00166000
                                                                                00168000
/*******************************************************************************00170000
         G L O B A L   S W I T C H E S                                          00172000
*******************************************************************************/00174000
                                                                                00176000
DECLARE                                                                         00178000
        TIME_EXIT                      BIT(1) INITIAL(0),                       00180000
        TARGET_TRACE                   BIT(1) INITIAL(0),                       00182000
        NOOSE_TRACE                    BIT(1) INITIAL(0),                       00184000
        OPCODE_TRACE                   BIT(1) INITIAL(0),                       00186000
        STACK_DUMP                     BIT(1) INITIAL(0),                       00188000
        BLOCK_PRIME                    BIT(1) INITIAL(0),                       00190000
        FIRST_PRINT                    BIT(1) INITIAL(0),                       00192000
        PRETTY_PRINT_REQUESTED         BIT(1) INITIAL(0),                       00194000
        HEADER_ISSUED                  BIT(1) INITIAL(0),                       00196000
        AUXMATING                      BIT(1) INITIAL(1),                       00198000
        AUXMAT_REQUESTED               BIT(1) INITIAL(0),                       00200000
        STATISTICS                     BIT(1) INITIAL(0);                       00204000
                                                                                00206000
/*******************************************************************************00208000
        G L O B A L   D A T A   F O R   D E C O D I N G   H A L M A T           00210000
*******************************************************************************/00212000
                                                                                00214000
DECLARE                                                                         00216000
        TEMP_MAT                       FIXED,                                   00218000
                                                                                00220000
                                                                                00222000
        /* USEFUL HALMAT FLAGS/VARIABLES */                                     00224000
                                                                                00226000
        SYT                            LITERALLY '"01"',                        00228000
        VAC                            LITERALLY '"03"',                        00230000
                                                                                00234000
                                                                                00236000
        /* DATA FOR HALMAT OPERATORS */                                         00238000
                                                                                00240000
        HALRATOR                       BIT(16),                                 00242000
        HALRATOR_CLASS                 BIT(8),                                  00244000
        HALRATOR_TAG1                  BIT(8),                                  00246000
        HALRATOR_TAG2                  BIT(8),                                  00248000
        HALRATOR_#RANDS                BIT(8),                                  00250000
                                                                                00252000
                                                                                00254000
        /* DATA FOR HALMAT OPERANDS */                                          00256000
                                                                                00258000
        HALRAND                        BIT(16),                                 00260000
        HALRAND_TAG1                   BIT(8),                                  00262000
        HALRAND_TAG2                   BIT(8),                                  00264000
        HALRAND_QUALIFIER              BIT(8);                                  00266000
                                                                                00268000
/*******************************************************************************00270000
        D E C L A R E S   F O R   E N C O D I N G   A U X M A T                 00272000
*******************************************************************************/00274000
                                                                                00276000
DECLARE                                                                         00278000
        SNCS_OPCODE                    LITERALLY '"08"',                        00280000
        GEN_LIST_OPCODE                LITERALLY '"07"',                        00282000
        NEST_OPCODE                    LITERALLY '"07"',                        00283000
        AUXMAT_END_OPCODE              LITERALLY '"06"',                        00284000
        TARGET_OPCODE                  LITERALLY '"04"',                        00288000
        XREC_OPCODE                    LITERALLY '"03"',                        00290000
        NOOSE_OPCODE                   LITERALLY '"01"';                        00294000
                                                                                00298000
                                                                                00300000
/*******************************************************************************00302000
        D E C L A R A T I O N S   F O R   L I S T   S T R U C T U R E           00304000
*******************************************************************************/00306000
                                                                                00308000
DECLARE                                                                         00310000
        FREE_CELL_PTR                  BIT(16),                                 00312000
        STOP_COND_LIST                 BIT(16) INITIAL(0),                      00314000
        CELL_SIZE                      BIT(16) INITIAL(500);                    00316000
                                                                                00318000
                                                                                00320000
        /* BASED VARIABLES FOR LIST STRUCTURE */                                00322000
                                                                                00324000
BASED    LIST_STRUX     RECORD DYNAMIC:                                         00326000
      C1                         BIT(16),                                       00326100
      C2                         BIT(16),                                       00326200
      CELL_CDR                   BIT(16),                                       00326300
      C1_FLAGS                   BIT(8),                                        00326400
      C2_FLAGS                   BIT(8),                                        00326500
END;                                                                            00326600
                                                                                00338000
DECLARE                                                                         00340000
        #BASED_LIST_VARS               BIT(16) INITIAL(4),                      00342000
        BASED_LIST_VAR_SIZE(9)         BIT(16)                                  00344000
           INITIAL(1, 1, 0, 0, 1, 0, 0, 0, 0, 0);                               00346000
                                                                                00348000
                                                                                00350000
/*******************************************************************************00352000
        S T A C K   D E C L A R A T I O N S                                     00354000
*******************************************************************************/00356000
                                                                                00358000
                                                                                00360000
DECLARE                                                                         00362000
        STACK_PTR                      BIT(16) INITIAL(0),                      00364000
        MAX_STACK_LEVEL                BIT(16) INITIAL(0),                      00366000
        STACK_SIZE                     BIT(16) INITIAL(63),                     00368000
                                                                                00370000
                                                                                00372000
        /* DECLARATIONS DESCRIBING STACK FRAME TYPES */                         00374000
                                                                                00376000
        BLOCK_TYPE                     LITERALLY '1',                           00378000
        CB_TYPE                        LITERALLY '2',                           00380000
        CASE_TYPE                      LITERALLY '3',                           00382000
                                                                                00384000
                                                                                00386000
        /* DECLARATIONS DESCRIBING THE FRAMES FLAGS VALUES */                   00388000
                                                                                00390000
        FIRST_CASE_TBD_FLAG            LITERALLY '"40"',                        00392000
        FALSE_CASE                     LITERALLY '"20"',                        00394000
        TRUE_CASE                      LITERALLY '"10"',                        00396000
        IF_THEN_ELSE_MASK              LITERALLY '"30"',                        00398000
        ZAP_OR_FLUSH                   LITERALLY '"05"',                        00398500
        FLUSH_FLAG                     LITERALLY '"04"',                        00399000
        PREV_BLOCK_FLAG                LITERALLY '"02"',                        00400000
        ZAP_FLAG                       LITERALLY '"01"';                        00402000
                                                                                00404000
                                                                                00406000
        /* BASED VARIABLES FOR STACK FRAMES */                                  00408000
                                                                                00410000
BASED   STACK_FRAME     RECORD DYNAMIC:                                         00412000
      M_CASE_LENGTH           BIT(16),                                          00413000
      F_CB_NEST_LEVEL         BIT(16),                                          00414000
      F_START                 BIT(16),                                          00415000
      F_UVCS                  BIT(16),                                          00416000
      F_INL                   BIT(16),                                          00417000
      F_SYT_REF               BIT(16),                                          00418000
      F_VAC_REF               BIT(16),                                          00419000
      F_SYT_PREV_REF          BIT(16),                                          00420000
      F_VAC_PREV_REF          BIT(16),                                          00421000
      F_BUMP_FACTOR           BIT(16),                                          00422000
      F_CASE_LIST             BIT(16),                                          00423000
      F_MAP_SAVE              BIT(16),                                          00424000
      V_BOUNDS                BIT(16),                                          00425000
      F_BLOCK_PTR             BIT(16),                                          00426000
      C_LIST_PTRS             BIT(16),                                          00427000
      F_TYPE                  BIT(8),                                           00428000
      F_FLAGS                 BIT(8),                                           00429000
END;                                                                            00430000
                                                                                00448000
DECLARE                                                                         00450000
        #BASED_STACK_VARS              LITERALLY '16',                          00452000
        BASED_STACK_VAR_SIZE(#BASED_STACK_VARS) BIT(16)                         00454000
           INITIAL(1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);          00456000
                                                                                00458000
                                                                                00460000
/*******************************************************************************00462000
        M A P   D E C L A R A T I O N S                                         00464000
*******************************************************************************/00466000
                                                                                00468000
                                                                                00470000
DECLARE                                                                         00472000
        POOL_SIZE                      BIT(16) INITIAL(95),                     00474000
        VAC_REF_POOL_FRAME_SIZE        BIT(16) INITIAL(112),                    00476000
        SYT_REF_POOL_FRAME_SIZE        BIT(16),                                 00478000
        REF_POOL_MAP_SIZE              BIT(16),                                 00480000
                                                                                00482000
                                                                                00484000
        /* USEFUL MAP INDICES */                                                00486000
                                                                                00488000
        MAP_INDICES(31)                FIXED INITIAL(                           00490000
                                                                                00492000
            "80000000",                                                         00494000
            "40000000",                                                         00496000
            "20000000",                                                         00498000
            "10000000",                                                         00500000
            "08000000",                                                         00502000
            "04000000",                                                         00504000
            "02000000",                                                         00506000
            "01000000",                                                         00508000
            "00800000",                                                         00510000
            "00400000",                                                         00512000
            "00200000",                                                         00514000
            "00100000",                                                         00516000
            "00080000",                                                         00518000
            "00040000",                                                         00520000
            "00020000",                                                         00522000
            "00010000",                                                         00524000
            "00008000",                                                         00526000
            "00004000",                                                         00528000
            "00002000",                                                         00530000
            "00001000",                                                         00532000
            "00000800",                                                         00534000
            "00000400",                                                         00536000
            "00000200",                                                         00538000
            "00000100",                                                         00540000
            "00000080",                                                         00542000
            "00000040",                                                         00544000
            "00000020",                                                         00546000
            "00000010",                                                         00548000
            "00000008",                                                         00550000
            "00000004",                                                         00552000
            "00000002",                                                         00554000
            "00000001");                                                        00556000
                                                                                00558000
                                                                                00560000
        /* BASED MAP VARIABLES */                                               00562000
                                                                                00564000
BASED   V_MAP_VAR   RECORD DYNAMIC:                                             00566000
      V_REF_POOL_MAP             BIT(32),                                       00566100
END;                                                                            00566200
BASED S_MAP_VAR   RECORD DYNAMIC:                                               00566300
      S_REF_POOL_MAP             BIT(32),                                       00566400
END;                                                                            00566500
BASED   V_POOL    RECORD DYNAMIC:                                               00566600
      V_REF_POOL                 BIT(32),                                       00566700
END;                                                                            00566800
BASED    S_POOL   RECORD DYNAMIC:                                               00566900
      S_REF_POOL                 BIT(32),                                       00567000
END;                                                                            00567100
BASED SNDX   RECORD DYNAMIC:                                                    00567200
      S_SHRINK_NDX               BIT(16),                                       00567300
END;                                                                            00567400
BASED SXPND     RECORD DYNAMIC:                                                 00567500
      S_EXPAND_NDX               BIT(16),                                       00567600
END;                                                                            00567700
                                                                                00580000
                                                                                00582000
/*******************************************************************************00596000
        D A T A   F O R   H A N D L I N G   F I L E S                           00598000
*******************************************************************************/00600000
                                                                                00602000
DECLARE                                                                         00604000
        AUXMAT_FILE                    BIT(8) INITIAL(1),                       00606000
        HALMAT_FILE                    BIT(8) INITIAL(4),                       00608000
        CURR_HALMAT_BLOCK              BIT(16) INITIAL(0),                      00610000
        CURR_AUXMAT_BLOCK              BIT(16) INITIAL(0);                      00612000
                                                                                00614000
ARRAY                                                                           00616000
        HALMAT(DOUBLE_BLOCK_SIZE)      FIXED,                                   00618000
        AUXMAT(AUXMAT_SIZE)            FIXED;                                   00620000
                                                                                00622000
/*******************************************************************************00624000
         M I S C E L L A N E O U S   D E C L A R A T I O N S                    00626000
*******************************************************************************/00628000
                                                                                00630000
DECLARE                                                                         00632000
        EQUAL                          CHARACTER INITIAL(' = '),                00634000
        CCURRENT                       CHARACTER INITIAL('CURRENT '),           00636000
        PERIOD                         CHARACTER INITIAL('.'),                  00638000
        ASTERISK                       CHARACTER INITIAL('*'),                  00640000
        BLANK_COLON_BLANK              CHARACTER INITIAL(' : '),                00642000
        COMMA                          CHARACTER INITIAL(','),                  00644000
        LEFT_PAREN                     CHARACTER INITIAL('('),                  00646000
        RIGHT_PAREN                    CHARACTER INITIAL(')'),                  00648000
        BLANKS                         CHARACTER INITIAL(                       00650000
'                                                                            '),00652000
        COLON                          CHARACTER INITIAL(':'),                  00654000
        BLANK                          CHARACTER INITIAL(' '),                  00656000
        CURRENT_STMT                   BIT(16),                                 00657000
        CLOCK(2)                       FIXED,                                   00658000
        BUMMER                         LABEL;                                   00660000
                                                                                00662000
/*******************************************************************************00664000
         G L O B A L   W O R K   D E C L A R A T I O N S                        00666000
*******************************************************************************/00668000
                                                                                00670000
DECLARE                                                                         00672000
                                                                                00674000
        /* VARIOUS CONSTANTS/WORK FLAGS */                                      00676000
                                                                                00678000
        RATOR_CSE_FLAG                 LITERALLY '"8"',                         00682000
        RAND_XB_FLAG                   LITERALLY '"10"',                        00684000
        RAND_CSE_FLAG                  LITERALLY '"8"',                         00686000
        TRUE_ONLY_FLAG                 LITERALLY '"01"',                        00688000
        BEYOND_CONDITIONAL_FLAG        LITERALLY '"02"',                        00690000
        MAX_POS                        LITERALLY '"7FFF"',                      00692000
                                                                                00694000
                                                                                00696000
        /* WORK AREAS/POINTERS */                                               00698000
                                                                                00700000
        REF_PTR1                       BIT(16),                                 00702000
        REF_PTR2                       BIT(16),                                 00704000
        SAVE_FREELIMIT                 FIXED,                                   00706000
        WORK1                          FIXED,                                   00708000
        AUXMAT_PTR                     BIT(16) INITIAL(0),                      00710000
        HALMAT_PTR                     BIT(16),                                 00712000
        HALMAT_PRINT_PTR               BIT(16) INITIAL(0),                      00714000
        AUXMAT_PRINT_PTR               BIT(16) INITIAL(1),                      00716000
        XREC_PTR                       BIT(16) INITIAL(0),                      00718000
        XREC_PRIME_PTR                 BIT(16) INITIAL(3601),                   00720000
        MAX_REF_SYT_SIZE               BIT(16),                                 00722000
                                                                                00724000
                                                                                00726000
        /* STATISTICS DATA */                                                   00728000
                                                                                00730000
        #GCS                           BIT(16) INITIAL(0),                      00732000
        TOTAL_GC_TIME                  FIXED INITIAL(0),                        00734000
        TOTAL_PRETTY_PRINT_TIME        FIXED INITIAL(0),                        00736000
        MAX_USED_CELLS                 BIT(16) INITIAL(0);                      00738000
                                                                                00760000
                                                                                00762000
        /* BASED GLOBAL WORK STORAGE */                                         00764000
                                                                                00766000
BASED   WORK_VARS   RECORD DYNAMIC:                                             00768000
      PNTR                    BIT(16),                                          00769000
      AUXM1                   BIT(16),                                          00770000
      NOO                     BIT(16),                                          00771000
      TRGT                    BIT(16),                                          00772000
      TGS                     BIT(8),                                           00773000
      PNTR_TYPE               BIT(8),                                           00774000
      GENER_CODE              BIT(8),                                           00775000
END;                                                                            00776000
                                                                                00784000
DECLARE                                                                         00786000
        #BASED_WORK_VARS               LITERALLY '6',                           00788000
        BASED_WORK_VAR_SIZE(#BASED_WORK_VARS) BIT(16)                           00790000
           INITIAL(0, 1, 0, 1, 1, 0, 1);                                        00792000
DECLARE  MOVEABLE LITERALLY '1';                                                00792001
DECLARE  SYT_XREF(1) LITERALLY 'SYM_TAB(%1%).SYM_XREF',                         00792005
         SYT_DIMS(1) LITERALLY 'SYM_TAB(%1%).SYM_LENGTH',                       00792008
      XREF(1) LITERALLY 'CROSS_REF(%1%).CR_REF';                                00792018
DECLARE CELL1(1) LITERALLY 'LIST_STRUX(%1%).C1',                                00792025
   CELL2(1) LITERALLY 'LIST_STRUX(%1%).C2',                                     00792026
   CELL1_FLAGS(1) LITERALLY 'LIST_STRUX(%1%).C1_FLAGS',                         00792027
   CELL2_FLAGS(1) LITERALLY 'LIST_STRUX(%1%).C2_FLAGS',                         00792028
   CDR_CELL(1) LITERALLY 'LIST_STRUX(%1%).CELL_CDR';                            00792029
DECLARE MAX_CASE_LENGTH(1) LITERALLY 'STACK_FRAME(%1%).M_CASE_LENGTH',          00792030
FRAME_CB_NEST_LEVEL(1) LITERALLY 'STACK_FRAME(%1%).F_CB_NEST_LEVEL',            00792031
FRAME_START(1) LITERALLY 'STACK_FRAME(%1%).F_START',                            00792032
FRAME_TYPE(1) LITERALLY 'STACK_FRAME(%1%).F_TYPE',                              00792033
FRAME_FLAGS(1) LITERALLY 'STACK_FRAME(%1%).F_FLAGS',                            00792034
FRAME_UVCS(1) LITERALLY 'STACK_FRAME(%1%).F_UVCS',                              00792035
FRAME_INL(1) LITERALLY 'STACK_FRAME(%1%).F_INL',                                00792036
FRAME_SYT_REF(1) LITERALLY 'STACK_FRAME(%1%).F_SYT_REF',                        00792037
FRAME_VAC_REF(1) LITERALLY 'STACK_FRAME(%1%).F_VAC_REF',                        00792038
FRAME_SYT_PREV_REF(1) LITERALLY 'STACK_FRAME(%1%).F_SYT_PREV_REF',              00792039
FRAME_VAC_PREV_REF(1) LITERALLY 'STACK_FRAME(%1%).F_VAC_PREV_REF',              00792040
FRAME_BUMP_FACTOR(1) LITERALLY 'STACK_FRAME(%1%).F_BUMP_FACTOR',                00792041
FRAME_CASE_LIST(1) LITERALLY 'STACK_FRAME(%1%).F_CASE_LIST',                    00792042
FRAME_MAP_SAVE(1) LITERALLY 'STACK_FRAME(%1%).F_MAP_SAVE',                      00792043
VAC_BOUNDS(1) LITERALLY 'STACK_FRAME(%1%).V_BOUNDS',                            00792044
FRAME_BLOCK_PTR(1) LITERALLY 'STACK_FRAME(%1%).F_BLOCK_PTR',                    00792045
CASE_LIST_PTRS(1) LITERALLY 'STACK_FRAME(%1%).C_LIST_PTRS';                     00792046
DECLARE VAC_REF_POOL_MAP(1) LITERALLY 'V_MAP_VAR(%1%).V_REF_POOL_MAP',          00792047
SYT_REF_POOL_MAP(1) LITERALLY 'S_MAP_VAR(%1%).S_REF_POOL_MAP',                  00792048
VAC_REF_POOL(1) LITERALLY 'V_POOL(%1%).V_REF_POOL',                             00792049
SYT_SHRINK_INDEX(1) LITERALLY 'SNDX(%1%).S_SHRINK_NDX',                         00792050
SYT_EXPAND_INDEX(1) LITERALLY 'SXPND(%1%).S_EXPAND_NDX',                        00792051
SYT_REF_POOL(1) LITERALLY 'S_POOL(%1%).S_REF_POOL';                             00792052
DECLARE PTR_TYPE(1) LITERALLY 'WORK_VARS(%1%).PNTR_TYPE',                       00792053
PTR(1) LITERALLY 'WORK_VARS(%1%).PNTR',                                         00792054
GEN_CODE(1) LITERALLY 'WORK_VARS(%1%).GENER_CODE',                              00792055
AUXMAT1(1) LITERALLY 'WORK_VARS(%1%).AUXM1',                                    00792056
NOOSE(1) LITERALLY 'WORK_VARS(%1%).NOO',                                        00792057
TAGS(1) LITERALLY 'WORK_VARS(%1%).TGS',                                         00792058
TARGET(1) LITERALLY 'WORK_VARS(%1%).TRGT';                                      00792059
                                                                                00794000
                                                                                00794100
      /* INCLUDE VMEM DECLARES:  $%VMEM1  */                                    00794200
      /* AND:  $%VMEM2  */                                                      00794300
                                                                                00794400
   DECLARE DWN_STMT(1) LITERALLY 'DOWN_INFO(%1%).DOWN_STMT';                    00794401
   DECLARE DWN_ERR(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_ERR';                     00794402
   DECLARE DWN_CLS(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_CLS';                     00794403
/********************* DR108630 - TEV - 10/29/93 *********************/
   DECLARE DWN_UNKN(1) LITERALLY 'DOWN_INFO(%1%).DOWN_UNKN';
/********************* END DR108630 **********************************/
   DECLARE DWN_VER(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_VER';                     00794404
GO TO MAIN_PROGRAM;                                                             00796000
                                                                                00798000
                                                                                00800000
/*******************************************************************************00802000
         T O P   L E V E L   P R O C E D U R E   D E C L A R A T I O N S        00804000
*******************************************************************************/00806000
                                                                                00808000
/*******************************************************************************00810000
         M I S C E L L A N E O U S   'U S E F U L'   P R O C E D U R E S        00812000
*******************************************************************************/00814000
                                                                                00816000
                                                                                00818000
/**MERGE #RJUST       #RJUST                          */
/**MERGE HEX          HEX                             */
/**MERGE FORMATHA     FORMAT_HALMAT                   */
/**MERGE FORMATAU     FORMAT_AUXMAT                   */
/**MERGE PRINTTIM     PRINT_TIME                      */
/**MERGE PRINTDAT     PRINT_DATE_AND_TIME             */
/**MERGE PRINTPHA     PRINT_PHASE_HEADER              */
/**MERGE PRINTSUM     PRINT_SUMMARY                   */
/**MERGE PRETTYPR     PRETTY_PRINT_MAT                */
/**MERGE OUTPUTLI     OUTPUT_LIST                     */
/**MERGE OUTPUTSY     OUTPUT_SYT_MAP                  */
/**MERGE OUTPUTVA     OUTPUT_VAC_MAP                  */
/**MERGE TRACEMSG     TRACE_MSG                       */
/**MERGE ERRORS       ERRORS                          */
/**MERGE NEWHALMA     NEW_HALMAT_BLOCK                */
/**MERGE NEWSYTRE     NEW_SYT_REF_FRAME               */
/**MERGE FREESYTR     FREE_SYT_REF_FRAME              */
/**MERGE NEWVACRE     NEW_VAC_REF_FRAME               */
/**MERGE FREEVACR     FREE_VAC_REF_FRAME              */
/**MERGE NEWZEROS     NEW_ZERO_SYT_REF_FRAME          */
/**MERGE NEWZEROV     NEW_ZERO_VAC_REF_FRAME          */
/**MERGE MERGESYT     MERGE_SYT_REF_FRAMES            */
/**MERGE MERGEVAC     MERGE_VAC_REF_FRAMES            */
/**MERGE COPYSYTR     COPY_SYT_REF_FRAME              */
/**MERGE COPYVACR     COPY_VAC_REF_FRAME              */
/**MERGE PASSBACK     PASS_BACK_SYT_REFS              */
/**MERGE PASSBAC2     PASS_BACK_VAC_REFS              */
/**MERGE GETFREEC     GET_FREE_CELL                   */
/**MERGE LIST         LIST                            */
/**MERGE LINKCELL     LINK_CELL_AREA                  */
/**MERGE REINITIA     REINITIALIZE                    */
/**MERGE INITIALI     INITIALIZE                      */
/**MERGE INCRSTAC     INCR_STACK_PTR                  */
/**MERGE DECRSTAC     DECR_STACK_PTR                  */
/**MERGE PASS1        PASS1                           */
/**MERGE PASS2        PASS2                           */
                                                                                08312000
                                                                                08314000
/*******************************************************************************08316000
         T H E   M A I N   P R O G R A M                                        08318000
*******************************************************************************/08320000
                                                                                08322000
MAIN_PROGRAM:                                                                   08324000
                                                                                08326000
   CLOCK = MONITOR(18);                                                         08328000
   CALL INITIALIZE;                                                             08330000
                                                                                08332000
   IF STATISTICS & (^HEADER_ISSUED) THEN                                        08334000
      CALL PRINT_PHASE_HEADER;                                                  08336000
                                                                                08338000
   CLOCK(1) = MONITOR(18);                                                      08340000
   DO WHILE AUXMATING;                                                          08342000
      CALL NEW_HALMAT_BLOCK(0, FIRST_PRINT);                                    08344000
      CALL REINITIALIZE(XREC_PTR, XREC_PRIME_PTR);                              08346000
      XREC_PRIME_PTR = DOUBLE_BLOCK_SIZE + 1;                                   08348000
      CALL PASS1;                                                               08350000
      CALL PASS2;                                                               08352000
   END;                                                                         08354000
   CLOCK(2) = MONITOR(18);                                                      08356000
   IF STATISTICS THEN CALL PRINT_SUMMARY;                                       08358000
                                                                                08362000
   IF TIME_EXIT THEN                                                            08364000
      CALL ERRORS(CLASS_BI, 412);                                               08364010
                                                                                08368000
   RECORD_FREE(LIST_STRUX);                                                     08370000
   RECORD_FREE(STACK_FRAME);                                                    08370100
   RECORD_FREE(V_MAP_VAR);                                                      08370200
   RECORD_FREE(S_MAP_VAR);                                                      08370300
   RECORD_FREE(V_POOL);                                                         08370400
   RECORD_FREE(S_POOL);                                                         08370500
   RECORD_FREE(SNDX);                                                           08370600
   RECORD_FREE(SXPND);                                                          08370700
   RECORD_FREE(WORK_VARS);                                                      08370800
   CALL RECORD_LINK;                                                            08370900
                                                                                08372000
BUMMER:                                                                         08374000
   IF MAX_SEVERITY >=2 THEN CALL DOWNGRADE_SUMMARY; /*CR13273 DR111353*/        08368010
   RETURN COMMON_RETURN_CODE;                                                   08376000
                                                                                08378000
EOF EOF EOF EOF                                                                 08380000
