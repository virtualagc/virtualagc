/*
  File procedures.h generated by XCOM-I, 2024-08-08 04:32:07.
  Provides prototypes for the C functions corresponding to the
  XPL/I PROCEDUREs and setjmp/longjmp.

  Note: Due to the requirement for persistence, all function
  parameters are passed via static addresses in the `memory`
  array, rather than via parameter lists, so all parameter
  lists are `void`.
*/

#include <stdint.h>
#include <setjmp.h>

extern jmp_buf jbBUMMER;
// #defines for XPL variable names
#define mFIRSTRECORD 1320
#define mFIRSTBLOCK 1324
#define mFREEBYTES 1328
#define mRECBYTES 1332
#define mTOTAL_RDESC 1336
#define mCORELIMIT 1340
#define mSYM_TAB 1344
#define mDOWN_INFO 1372
#define mSYM_ADD 1400
#define mCROSS_REF 1428
#define mLIT_NDX 1456
#define mFOR_DW 1484
#define mFOR_ATOMS 1512
#define mADVISE 1540
#define mEXT_ARRAY 1568
#define mIODEV 2170
#define mCOMMON_RETURN_CODE 2180
#define mTABLE_ADDR 2184
#define mADDR_FIXER 2188
#define mADDR_FIXED_LIMIT 2192
#define mADDR_ROUNDER 2196
#define mCOMM 2200
#define mCSECT_LENGTHS 2400
#define mLIT_PG 2428
#define mVMEMREC 2456
#define mINIT_TAB 2484
#define mINITIAL_ON 2512
#define mDATA_REMOTE 2515
#define mSEVERITY_ONE 2516
#define mNOT_DOWNGRADED 2517
#define mVMEM_LOC_PTR 2520
#define mVMEM_LOC_ADDR 2524
#define mVMEM_LOC_CNT 2528
#define mVMEM_READ_CNT 2532
#define mVMEM_WRITE_CNT 2536
#define mVMEM_RESV_CNT 2540
#define mVMEM_PRIOR_PAGE 2544
#define mVMEM_LOOK_AHEAD_PAGE 2546
#define mVMEM_MAX_PAGE 2548
#define mVMEM_LAST_PAGE 2550
#define mVMEM_OLD_NDX 2552
#define mVMEM_LOOK_AHEAD 2554
#define mVMEM_PAD_PAGE 2555
#define mVMEM_PAD_ADDR 2564
#define mVMEM_PAD_DISP 2576
#define mVMEM_PAD_CNT 2584
#define mVMEM_PAGE_TO_NDX 2596
#define mVMEM_PAGE_AVAIL_SPACE 3396
#define muserMemory 4196
#define mprivateMemory 4224
#define mDX 4252
#define mLIST_STRUX 4280
#define mSTACK_FRAME 4308
#define mV_MAP_VAR 4336
#define mS_MAP_VAR 4364
#define mV_POOL 4392
#define mS_POOL 4420
#define mSNDX 4448
#define mSXPND 4476
#define mWORK_VARS 4504
#define mDX_SIZE 4532
#define mDESCRIPTOR_DESCRIPTOR 4536
#define mFREESTRING_TARGET 4568
#define mFREESTRING_TRIGGER 4572
#define mFREESTRING_MIN 4576
#define mCOMPACTIFIES 4580
#define mREALLOCATIONS 4584
#define m_IN_COMPACTIFY 4586
#define m_DX_TOTAL 4588
#define m_PREV_DX_TOTAL 4592
#define m_LAST_COMPACTIFY_FOUND 4596
#define mFORCE_MAJOR 4600
#define m_OLDFREELIMIT 4604
#define mFREEPRINT 4608
#define mTIME_EXIT 4609
#define mTARGET_TRACE 4610
#define mNOOSE_TRACE 4611
#define mOPCODE_TRACE 4612
#define mSTACK_DUMP 4613
#define mBLOCK_PRIME 4614
#define mFIRST_PRINT 4615
#define mPRETTY_PRINT_REQUESTED 4616
#define mHEADER_ISSUED 4617
#define mAUXMATING 4618
#define mAUXMAT_REQUESTED 4619
#define mSTATISTICS 4620
#define mTEMP_MAT 4624
#define mHALRATOR 4628
#define mHALRATOR_CLASS 4630
#define mHALRATOR_TAG1 4631
#define mHALRATOR_TAG2 4632
#define mHALRATOR_pRANDS 4633
#define mHALRAND 4634
#define mHALRAND_TAG1 4636
#define mHALRAND_TAG2 4637
#define mHALRAND_QUALIFIER 4638
#define mFREE_CELL_PTR 4639
#define mSTOP_COND_LIST 4641
#define mCELL_SIZE 4643
#define mpBASED_LIST_VARS 4645
#define mBASED_LIST_VAR_SIZE 4647
#define mSTACK_PTR 4667
#define mMAX_STACK_LEVEL 4669
#define mSTACK_SIZE 4671
#define mBASED_STACK_VAR_SIZE 4673
#define mPOOL_SIZE 4707
#define mVAC_REF_POOL_FRAME_SIZE 4709
#define mSYT_REF_POOL_FRAME_SIZE 4711
#define mREF_POOL_MAP_SIZE 4713
#define mMAP_INDICES 4716
#define mAUXMAT_FILE 4844
#define mHALMAT_FILE 4845
#define mCURR_HALMAT_BLOCK 4846
#define mCURR_AUXMAT_BLOCK 4848
#define mHALMAT 4852
#define mAUXMAT 19256
#define mCURRENT_STMT 26460
#define mCLOCK 26464
#define mREF_PTR1 26476
#define mREF_PTR2 26478
#define mSAVE_FREELIMIT 26480
#define mWORK1 26484
#define mAUXMAT_PTR 26488
#define mHALMAT_PTR 26490
#define mHALMAT_PRINT_PTR 26492
#define mAUXMAT_PRINT_PTR 26494
#define mXREC_PTR 26496
#define mXREC_PRIME_PTR 26498
#define mMAX_REF_SYT_SIZE 26500
#define mpGCS 26502
#define mTOTAL_GC_TIME 26504
#define mTOTAL_PRETTY_PRINT_TIME 26508
#define mMAX_USED_CELLS 26512
#define mBASED_WORK_VAR_SIZE 26514
#define mVMEM_PTR_STATUS 26528
#define mVMEM_FLAGS_STATUS 26540
#define mMODF 26543
#define mRESV 26544
#define mRELS 26545
#define mERR_VALUE 26548
#define mCLASS_A 27032
#define mCLASS_AA 27034
#define mCLASS_AV 27036
#define mCLASS_B 27038
#define mCLASS_BB 27040
#define mCLASS_BI 27042
#define mCLASS_BN 27044
#define mCLASS_BS 27046
#define mCLASS_BT 27048
#define mCLASS_BX 27050
#define mCLASS_C 27052
#define mCLASS_D 27054
#define mCLASS_DA 27056
#define mCLASS_DC 27058
#define mCLASS_DD 27060
#define mCLASS_DF 27062
#define mCLASS_DI 27064
#define mCLASS_DL 27066
#define mCLASS_DN 27068
#define mCLASS_DQ 27070
#define mCLASS_DS 27072
#define mCLASS_DT 27074
#define mCLASS_DU 27076
#define mCLASS_E 27078
#define mCLASS_EA 27080
#define mCLASS_EB 27082
#define mCLASS_EC 27084
#define mCLASS_ED 27086
#define mCLASS_EL 27088
#define mCLASS_EM 27090
#define mCLASS_EN 27092
#define mCLASS_EO 27094
#define mCLASS_EV 27096
#define mCLASS_F 27098
#define mCLASS_FD 27100
#define mCLASS_FN 27102
#define mCLASS_FS 27104
#define mCLASS_FT 27106
#define mCLASS_G 27108
#define mCLASS_GB 27110
#define mCLASS_GC 27112
#define mCLASS_GE 27114
#define mCLASS_GL 27116
#define mCLASS_GV 27118
#define mCLASS_I 27120
#define mCLASS_IL 27122
#define mCLASS_IR 27124
#define mCLASS_IS 27126
#define mCLASS_L 27128
#define mCLASS_LB 27130
#define mCLASS_LC 27132
#define mCLASS_LF 27134
#define mCLASS_LS 27136
#define mCLASS_M 27138
#define mCLASS_MC 27140
#define mCLASS_ME 27142
#define mCLASS_MO 27144
#define mCLASS_MS 27146
#define mCLASS_P 27148
#define mCLASS_PA 27150
#define mCLASS_PC 27152
#define mCLASS_PD 27154
#define mCLASS_PE 27156
#define mCLASS_PF 27158
#define mCLASS_PL 27160
#define mCLASS_PM 27162
#define mCLASS_PP 27164
#define mCLASS_PR 27166
#define mCLASS_PS 27168
#define mCLASS_PT 27170
#define mCLASS_PU 27172
#define mCLASS_Q 27174
#define mCLASS_QA 27176
#define mCLASS_QD 27178
#define mCLASS_QS 27180
#define mCLASS_QX 27182
#define mCLASS_R 27184
#define mCLASS_RE 27186
#define mCLASS_RT 27188
#define mCLASS_RU 27190
#define mCLASS_S 27192
#define mCLASS_SA 27194
#define mCLASS_SC 27196
#define mCLASS_SP 27198
#define mCLASS_SQ 27200
#define mCLASS_SR 27202
#define mCLASS_SS 27204
#define mCLASS_ST 27206
#define mCLASS_SV 27208
#define mCLASS_T 27210
#define mCLASS_TC 27212
#define mCLASS_TD 27214
#define mCLASS_U 27216
#define mCLASS_UI 27218
#define mCLASS_UP 27220
#define mCLASS_UT 27222
#define mCLASS_V 27224
#define mCLASS_VA 27226
#define mCLASS_VC 27228
#define mCLASS_VE 27230
#define mCLASS_VF 27232
#define mCLASS_X 27234
#define mCLASS_XA 27236
#define mCLASS_XD 27238
#define mCLASS_XI 27240
#define mCLASS_XM 27242
#define mCLASS_XQ 27244
#define mCLASS_XR 27246
#define mCLASS_XS 27248
#define mCLASS_XU 27250
#define mCLASS_XV 27252
#define mCLASS_Z 27254
#define mCLASS_ZB 27256
#define mCLASS_ZC 27258
#define mCLASS_ZI 27260
#define mCLASS_ZN 27262
#define mCLASS_ZO 27264
#define mCLASS_ZP 27266
#define mCLASS_ZR 27268
#define mCLASS_ZS 27270
#define mCLASS_YA 27272
#define mCLASS_YC 27274
#define mCLASS_YE 27276
#define mCLASS_YF 27278
#define mCLASS_YD 27280
#define mMAX_SEVERITY 27282
#define mSEVERITY 27284
#define m_SPMANERRxNUMERRORS 27286
#define m_SPACE_ROUNDxBYTES 27288
#define m_ACTIVE_DESCRIPTORSxDOPE 27292
#define m_ACTIVE_DESCRIPTORSxDP 27296
#define m_ACTIVE_DESCRIPTORSxDW 27300
#define m_ACTIVE_DESCRIPTORSxDLAST 27304
#define m_ACTIVE_DESCRIPTORSxDND 27308
#define m_ACTIVE_DESCRIPTORSxI 27312
#define m_ACTIVE_DESCRIPTORSxJ 27316
#define m_ACTIVE_DESCRIPTORSxANS 27320
#define m_FREEBLOCK_CHECKxUPLIM 27324
#define m_FREEBLOCK_CHECKxDOWNLIM 27328
#define m_FREEBLOCK_CHECKxFBYTES 27332
#define m_FREEBLOCK_CHECKxRBYTES 27336
#define m_FREEBLOCK_CHECKxRDOPE 27340
#define m_FREEBLOCK_CHECKxRPNTR 27344
#define m_FREEBLOCK_CHECKxRSIZE 27348
#define m_FREEBLOCK_CHECKxBPNTR 27352
#define m_FREEBLOCK_CHECKxBSIZE 27356
#define m_FREEBLOCK_CHECKxBLKNO 27360
#define m_FREEBLOCK_CHECKxRECNO 27362
#define m_FREEBLOCK_CHECKxADDRESS_CHECKxADDRESS 27364
#define m_UNUSED_BYTESxCUR 27368
#define m_UNUSED_BYTESxANS 27372
#define m_MOVE_WORDSxSOURCE 27376
#define m_MOVE_WORDSxDEST 27380
#define m_MOVE_WORDSxNUMBYTES 27384
#define m_MOVE_WORDSxI 27388
#define m_SQUASH_RECORDSxCURDOPE 27392
#define m_SQUASH_RECORDSxRECPTR 27396
#define m_SQUASH_RECORDSxLAST_RECPTR 27400
#define m_SQUASH_RECORDSxCURBLOCK 27404
#define m_SQUASH_RECORDSxNEXTBLOCK 27408
#define m_SQUASH_RECORDSxBYTES_TO_MOVE_BY 27412
#define m_SQUASH_RECORDSxSQUASHED 27416
#define m_SQUASH_RECORDSxRECBYTES 27420
#define m_SQUASH_RECORDSxI 27424
#define m_PREV_FREEBLOCKxBLOCK 27428
#define m_PREV_FREEBLOCKxPREV 27432
#define m_PREV_FREEBLOCKxCUR 27436
#define m_PREV_RECORDxDOPE 27440
#define m_PREV_RECORDxPREV 27444
#define m_PREV_RECORDxCUR 27448
#define m_ATTACH_BLOCKxBLOCK 27452
#define m_ATTACH_BLOCKxPREV 27456
#define m_ATTACH_BLOCKxCUR 27460
#define m_ATTACH_BLOCKxJOINxB1 27464
#define m_ATTACH_BLOCKxJOINxB2 27468
#define m_ATTACH_RECORDxDOPE 27472
#define m_ATTACH_RECORDxPREV 27476
#define m_ATTACH_RECORDxCUR 27480
#define m_ATTACH_RECORDxLOC 27484
#define m_DETACH_RECORDxDOPE 27488
#define m_DETACH_RECORDxPREV 27492
#define m_REDUCE_BLOCKxBLOCK 27496
#define m_REDUCE_BLOCKxREMBYTES 27500
#define m_REDUCE_BLOCKxTOP 27504
#define m_REDUCE_BLOCKxPREV 27508
#define m_REDUCE_BLOCKxOLDNBYTES 27512
#define m_REDUCE_BLOCKxNEWBLOCK 27516
#define m_RETURN_TO_FREESTRINGxNBYTES 27520
#define m_RECORD_FREExDOPE 27524
#define m_RECORD_FREExSIZE 27528
#define m_RECORD_FREExPREV 27532
#define m_RECORD_FREExNEWBLOCK 27536
#define m_RETURN_UNUSEDxDOPE 27540
#define m_RETURN_UNUSEDxNRECS 27544
#define m_RETURN_UNUSEDxNEWBLOCK 27548
#define m_RETURN_UNUSEDxOLDNBYTES 27552
#define m_RETURN_UNUSEDxNEWNBYTES 27556
#define m_RETURN_UNUSEDxDIF 27560
#define m_TAKE_BACKxNBYTES 27564
#define m_TAKE_BACKxCUR 27568
#define m_TAKE_BACKxRET_RECS 27572
#define m_TAKE_BACKxDIF_RECS 27576
#define m_TAKE_BACKxPOSSIBLE 27580
#define m_TAKE_BACKxLEFTBYTES 27584
#define m_TAKE_BACKxPREV_FREEBYTES 27588
#define m_TAKE_BACKxPREV_FREEPRINT 27592
#define mCOMPACTIFYxI 27596
#define mCOMPACTIFYxJ 27600
#define mCOMPACTIFYxK 27604
#define mCOMPACTIFYxL 27608
#define mCOMPACTIFYxND 27612
#define mCOMPACTIFYxTC 27616
#define mCOMPACTIFYxBC 27620
#define mCOMPACTIFYxDELTA 27624
#define mCOMPACTIFYxMODE 27628
#define mCOMPACTIFYxACTUAL_DX_TOTAL 27632
#define mCOMPACTIFYxMASK 27636
#define mCOMPACTIFYxLOWER_BOUND 27640
#define mCOMPACTIFYxUPPER_BOUND 27644
#define mCOMPACTIFYxTRIED 27648
#define mCOMPACTIFYxDP 27652
#define mCOMPACTIFYxDW 27656
#define mCOMPACTIFYxADD_DESCxI 27660
#define mCOMPACTIFYxADD_DESCxL 27664
#define m_STEALxNBYTES 27668
#define m_STEALxBLOCKLOC 27672
#define m_MOVE_RECSxDOPE 27676
#define m_MOVE_RECSxBYTES_TO_MOVE_BY 27680
#define m_MOVE_RECSxNBYTES 27684
#define m_MOVE_RECSxSOURCE 27688
#define m_MOVE_RECSxCURDOPE 27692
#define m_FIND_FREExNBYTES 27696
#define m_FIND_FREExUNMOVEABLE 27700
#define m_FIND_FREExI 27701
#define m_FIND_FREExCURBLOCK 27704
#define m_FIND_FREExDOPE 27708
#define m_INCREASE_RECORDxDOPE 27712
#define m_INCREASE_RECORDxNRECSMORE 27716
#define m_INCREASE_RECORDxOLDNRECS 27720
#define m_INCREASE_RECORDxOLDNBYTES 27724
#define m_INCREASE_RECORDxNEWNRECS 27728
#define m_INCREASE_RECORDxNEWNBYTES 27732
#define m_INCREASE_RECORDxNBYTESMORE 27736
#define m_INCREASE_RECORDxI 27740
#define m_GET_SPACExNBYTES 27744
#define m_GET_SPACExUNMOVEABLE 27748
#define m_GET_SPACExFREEB 27752
#define m_GET_SPACExNEWREC 27756
#define m_GET_SPACExI 27760
#define m_HOW_MUCHxDOPE 27764
#define m_HOW_MUCHxANS 27768
#define m_HOW_MUCHxANSBYTES 27772
#define m_HOW_MUCHxNSTRBYTES 27776
#define m_HOW_MUCHxANSMIN 27780
#define m_ALLOCATE_SPACExDOPE 27784
#define m_ALLOCATE_SPACExHIREC 27788
#define m_ALLOCATE_SPACExNREC 27792
#define m_ALLOCATE_SPACExOREC 27796
#define m_RECORD_CONSTANTxDOPE 27800
#define m_RECORD_CONSTANTxHIREC 27804
#define m_RECORD_CONSTANTxMOVEABLE 27808
#define m_NEEDMORE_SPACExDOPE 27812
#define mRECORD_LINKxCUR 27816
#define mpRJUSTxNUMBER 27820
#define mpRJUSTxTOTAL_LENGTH 27822
#define mHEXxNUMBER 27824
#define mHEXxTOTAL_LENGTH 27826
#define mHEXxK 27828
#define mHEXxB 27830
#define mFORMAT_HALMATxHALMATp 27832
#define mFORMAT_HALMATxHALMAT_PRINTp 27834
#define mFORMAT_HALMATxBLOCKp 27836
#define mFORMAT_AUXMATxAUXMATp 27838
#define mFORMAT_AUXMATxTEMP_MAT1 27840
#define mFORMAT_AUXMATxTEMP_MAT2 27844
#define mPRINT_TIMExT 27848
#define mPRINT_DATE_AND_TIMExD 27852
#define mPRINT_DATE_AND_TIMExT 27856
#define mPRINT_DATE_AND_TIMExYEAR 27860
#define mPRINT_DATE_AND_TIMExDAY 27864
#define mPRINT_DATE_AND_TIMExM 27868
#define mPRINT_DATE_AND_TIMExDAYS 27872
#define mPRINT_SUMMARYxT 27924
#define mPRETTY_PRINT_MATxSTMT_NO 27928
#define mPRETTY_PRINT_MATxPRETTY_PRINT_CLOCK 27932
#define mPRETTY_PRINT_MATxTEST_FOR_SKIPxOP_CODE 27940
#define mOUTPUT_LISTxLIST_HEAD 27942
#define mOUTPUT_LISTxWORK 27944
#define mOUTPUT_LISTxLINE_ENTRY 27946
#define mOUTPUT_SYT_MAPxMAPp 27948
#define mOUTPUT_SYT_MAPxWORK 27950
#define mOUTPUT_SYT_MAPxLINE_INDEX 27952
#define mOUTPUT_VAC_MAPxMAPp 27954
#define mOUTPUT_VAC_MAPxWORK 27956
#define mOUTPUT_VAC_MAPxLINE_INDEX 27958
#define mTRACE_MSGxHALMATp 27960
#define mTRACE_MSGxHALMAT_BLOCK 27962
#define mPADxWIDTH 27964
#define mPADxL 27968
#define mCHAR_INDEXxL1 27972
#define mCHAR_INDEXxL2 27976
#define mCHAR_INDEXxI 27980
#define mDOWNGRADE_SUMMARYxI 27984
#define mDOWNGRADE_SUMMARYxCOUNT 27988
#define mDOWNGRADE_SUMMARYxDOWN_COUNT 27992
#define mDOWNGRADE_SUMMARYxEND_OF_LIST 27996
#define mDOWNGRADE_SUMMARYxSEARCH_FOR_CLS 27997
#define mCOMMON_ERRORSxSEVERITY 27998
#define mCOMMON_ERRORSxK 28000
#define mCOMMON_ERRORSxCLASS 28002
#define mCOMMON_ERRORSxNUM 28004
#define mCOMMON_ERRORSxIMBED 28006
#define mCOMMON_ERRORSxERRORp 28007
#define mCOMMON_ERRORSxDOWN_COUNT 28009
#define mCOMMON_ERRORSxSTMTp 28012
#define mCOMMON_ERRORSxFOUND 28016
#define mERRORSxCLASS 28017
#define mERRORSxSEVERITY 28019
#define mERRORSxERRORp 28021
#define mERRORSxNUM 28023
#define mNEW_HALMAT_BLOCKxSTART 28025
#define mNEW_HALMAT_BLOCKxDO_PRINT 28027
#define mNEW_SYT_REF_FRAMExPTR1 28028
#define mNEW_SYT_REF_FRAMExPTR2 28030
#define mNEW_SYT_REF_FRAMExTEMP 28032
#define mFREE_SYT_REF_FRAMExPOOL_INDEX 28036
#define mFREE_SYT_REF_FRAMExTEMP_PTR 28038
#define mFREE_SYT_REF_FRAMExMAPp 28040
#define mNEW_VAC_REF_FRAMExPTR1 28042
#define mNEW_VAC_REF_FRAMExPTR2 28044
#define mNEW_VAC_REF_FRAMExTEMP 28048
#define mFREE_VAC_REF_FRAMExPOOL_INDEX 28052
#define mFREE_VAC_REF_FRAMExMAPp 28054
#define mFREE_VAC_REF_FRAMExTEMP_PTR 28056
#define mNEW_ZERO_SYT_REF_FRAMExTEMP_PTR 28058
#define mNEW_ZERO_VAC_REF_FRAMExTEMP_PTR 28060
#define mMERGE_SYT_REF_FRAMESxFRAME1 28062
#define mMERGE_SYT_REF_FRAMESxFRAME2 28064
#define mMERGE_VAC_REF_FRAMESxFRAME1 28066
#define mMERGE_VAC_REF_FRAMESxFRAME2 28068
#define mMERGE_VAC_REF_FRAMESxFIRST_MERGE 28070
#define mMERGE_VAC_REF_FRAMESxLAST_MERGE 28072
#define mCOPY_SYT_REF_FRAMExFRAME 28074
#define mCOPY_SYT_REF_FRAMExTEMP_PTR 28076
#define mCOPY_VAC_REF_FRAMExFRAME 28078
#define mCOPY_VAC_REF_FRAMExTEMP_PTR 28080
#define mPASS_BACK_VAC_REFSxWHICH_START 28082
#define mGET_FREE_CELLxTEMP_PTR 28084
#define mLISTxLIST1 28086
#define mLISTxLIST2 28088
#define mLISTxTEMP_PTR 28090
#define mLINK_CELL_AREAxLINK_UP_TIME 28092
#define mREINITIALIZExWORK_POINT1 28100
#define mREINITIALIZExWORK_POINT2 28102
#define mREINITIALIZExWORK 28104
#define mINITIALIZExI 28108
#define mINITIALIZExJ 28112
#define mINITIALIZExSHRINK_SYT_SIZExMAX_REF_NO 28116
#define mINITIALIZExSHRINK_SYT_SIZExI 28118
#define mINITIALIZExSHRINK_SYT_SIZExJ 28120
#define mINITIALIZExSHRINK_SYT_SIZExREFERENCEDxSYT_INDEX 28122
#define mINITIALIZExSHRINK_SYT_SIZExREFERENCEDxTEMP_XREF 28124
#define mPASS1xNUMOP 28128
#define mPASS1xTHIS_HALMAT_BLOCK 28130
#define mPASS1xSAVE_STACK_PTR 28131
#define mPASS1xDECODE_HALRATORxOP 28133
#define mPASS1xDECODE_HALRANDxOP 28135
#define mPASS1xSET_DEBUG_SWITCHxSWITCH 28137
#define mPASS1xSET_DEBUG_SWITCHxI 28138
#define mPASS1xCOMPUTE_NOOSExHALMATp 28140
#define mPASS1xADD_UVCxRAND_TYPE 28142
#define mPASS1xADD_UVCxRAND 28143
#define mPASS1xADD_UVCxHALMAT_LINE 28145
#define mPASS1xADD_UVCxTEMP_CELL 28147
#define mPASS1xADD_UVCxTEMP_PTR 28149
#define mPASS1xSEARCH_FOR_REFxRAND_TYPE 28151
#define mPASS1xSEARCH_FOR_REFxRAND 28152
#define mPASS1xSEARCH_FOR_REFxLIST_HEAD 28154
#define mPASS1xSEARCH_FOR_REFxPATER 28156
#define mPASS1xADD_TO_VAC_BOUNDSxSTART 28158
#define mPASS1xADD_TO_VAC_BOUNDSxFINISH 28160
#define mPASS1xADD_TO_VAC_BOUNDSxVAC_BOUNDS_PTR 28162
#define mPASS1xADD_TO_VAC_BOUNDSxPREV_BOUNDS_PTR 28164
#define mPASS1xSET_RAND_NOOSExRANDp 28166
#define mPASS1xSET_RAND_NOOSExVAL_CHANGE 28168
#define mPASS1xSET_RAND_NOOSExDO_NOT_DECODE 28169
#define mPASS1xSET_RAND_NOOSExBUMP_FACTOR 28170
#define mPASS1xSET_RAND_NOOSExTEMP_NOOSE 28172
#define mPASS1xSET_RAND_NOOSExQUAL_CASE_DECODE 28174
#define mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE1 28190
#define mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE2 28192
#define mPASS1xSET_RAND_NOOSExSET_MIN_NOOSExRAND_TYPE 28194
#define mPASS1xSET_RAND_NOOSExSET_MIN_NOOSExRAND 28195
#define mPASS1xSET_RAND_NOOSExSET_MIN_NOOSExHALMAT_LINE 28197
#define mPASS1xSET_RAND_NOOSExSET_MIN_NOOSExNEXT_USE 28199
#define mPASS1xSET_RAND_NOOSExINTERVENING_CBxSTART 28201
#define mPASS1xSET_RAND_NOOSExINTERVENING_CBxFINISH 28203
#define mPASS1xSET_RAND_NOOSExINTERVENING_CBxTEMP_PTR1 28205
#define mPASS1xSET_RAND_NOOSExINTERVENING_CBxTEMP_PTR2 28207
#define mPASS1xSET_RAND_NOOSExMARK_SYT_CASExRAND 28209
#define mPASS1xSET_RAND_NOOSExMARK_SYT_CASExNEXT_USE 28211
#define mPASS1xSET_RAND_NOOSExMARK_SYT_CASExTEMP_PTR 28213
#define mPASS1xSET_RAND_NOOSExMARK_SYT_CASExTEMP_CELL 28215
#define mPASS1xSET_RAND_NOOSExMARK_SYT_REFxRAND 28217
#define mPASS1xSET_RAND_NOOSExMARK_SYT_REFxTEMP_PTR 28219
#define mPASS1xSET_RAND_NOOSExMARK_SYT_UVCSxRAND 28221
#define mPASS1xSET_RAND_NOOSExMARK_SYT_UVCSxNEXT_USE 28223
#define mPASS1xSET_RAND_NOOSExMARK_SYT_UVCSxTEMP_PTR 28225
#define mPASS1xSET_RAND_NOOSExMARK_SYT_UVCSxLAST_HEAD 28227
#define mPASS1xSET_RAND_NOOSExMARK_SYT_UVCSxNO_MORE 28229
#define mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND_TYPE 28230
#define mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND 28231
#define mPASS1xSET_RAND_NOOSExMARK_VAC_CASExNEXT_USE 28233
#define mPASS1xSET_RAND_NOOSExMARK_VAC_CASExBUMP_FACTOR 28235
#define mPASS1xSET_RAND_NOOSExMARK_VAC_CASExXB_FLAG 28237
#define mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR 28238
#define mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_CELL 28240
#define mPASS1xSET_RAND_NOOSExMARK_VAC_REFxRAND 28242
#define mPASS1xSET_RAND_NOOSExMARK_VAC_REFxTEMP_PTR 28244
#define mPASS1xSET_RAND_NOOSExMARK_VAC_UVCSxRAND_TYPE 28246
#define mPASS1xSET_RAND_NOOSExMARK_VAC_UVCSxRAND 28247
#define mPASS1xSET_RAND_NOOSExMARK_VAC_UVCSxNEXT_USE 28249
#define mPASS1xSET_RAND_NOOSExMARK_VAC_UVCSxTEMP_PTR 28251
#define mPASS1xSET_RAND_NOOSExMARK_VAC_UVCSxLAST_HEAD 28253
#define mPASS1xSET_RAND_NOOSExMARK_VAC_UVCSxNO_MORE 28255
#define mPASS1xSET_RAND_NOOSExMARK_CASE_LIST_PTRSxRAND_TYPE 28256
#define mPASS1xSET_RAND_NOOSExMARK_CASE_LIST_PTRSxRAND 28257
#define mPASS1xSET_RAND_NOOSExMARK_CASE_LIST_PTRSxTEMP_PTR 28259
#define mPASS1xSET_RAND_NOOSExMARK_CASE_LIST_PTRSxTEMP_PTR1 28261
#define mPASS1xSET_RAND_NOOSExMARK_CASE_LIST_PTRSxNO_MORE 28263
#define mPASS1xSET_SIMP_NOOSExSTART 28264
#define mPASS1xZAPPERxZAP_TYPE 28266
#define mPASS1xZAPPERxTEMP_PTR 28267
#define mPASS1xSTACK_ERRORxFRM_TYPE 28269
#define mPASS1xPOP_CB_FRAMExTEMP_CELL 28271
#define mPASS1xPOP_CB_FRAMExTEMP_PTR1 28273
#define mPASS1xPOP_CB_FRAMExTEMP_PTR2 28275
#define mPASS1xPOP_CB_FRAMExTEMP_PTR3 28277
#define mPASS1xPOP_CB_FRAMExLAST_HEAD 28279
#define mPASS1xPOP_CB_FRAMExSYT_PREV_REF_PTR 28281
#define mPASS1xPOP_CB_FRAMExVAC_PREV_REF_PTR 28283
#define mPASS1xPOP_CB_FRAMExSYT_UNION_REF_PTR 28285
#define mPASS1xPOP_CB_FRAMExVAC_UNION_REF_PTR 28287
#define mPASS1xPOP_CB_FRAMExCASE_LIST_PTR 28289
#define mPASS1xPOP_CB_FRAMExSYT_REF_PTR 28291
#define mPASS1xPOP_CB_FRAMExVAC_REF_PTR 28293
#define mPASS1xPOP_CB_FRAMExWORK1 28296
#define mPASS1xPOP_CB_FRAMExVAC_BOUNDS_PTR 28300
#define mPASS1xPOP_CB_FRAMExVAC_BOUNDS_START 28302
#define mPASS1xPOP_CB_FRAMExVAC_BOUNDS_END 28304
#define mPASS1xPOP_CB_FRAMExMAP_INDEX 28306
#define mPASS1xPOP_CB_FRAMExPREV_MAP_INDEX 28308
#define mPASS1xPOP_CB_FRAMExWORK_MAP 28312
#define mPASS1xPOP_CB_FRAMExVAC_INDEX 28316
#define mPASS1xPOP_CB_FRAMExVAC_REF 28318
#define mPASS1xPOP_CB_FRAMExGEN_ZERO_SYT 28320
#define mPASS1xPOP_CB_FRAMExGEN_ZERO_VAC 28321
#define mPASS1xPUSH_FIRST_CASE_FRAMExPUSH_IND_FLAG 28322
#define mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1 28323
#define mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR2 28325
#define mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR3 28327
#define mPASS1xPUSH_CASE_FRAMExPUSH_IND_FLAG 28329
#define mPASS1xPUSH_CASE_FRAMExTEMP_PTR 28330
#define mPASS1xPOP_CASE_FRAMExTEMP_PTR1 28332
#define mPASS1xPOP_CASE_FRAMExTEMP_PTR2 28334
#define mPASS1xCLASS_0xCLASS_01xCASE_DECODE 28336
#define mPASS1xCLASS_0xCLASS_02xCASE_DECODE 28352
#define mPASS1xCLASS_0xCLASS_03xOPCODE_CASE_DECODE 28368
#define mPASS1xCLASS_0xCLASS_03xTEMP_PTR 28384
#define mPASS1xCLASS_0xCLASS_04xOPCODE_CASE_DECODE 28386
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxARGp 28402
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxBFNCp 28403
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxARG_HEAD 28405
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxI 28407
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxMAX_STOP_LEVEL 28409
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxHALRAND_QUALIFIER 28411
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxHALRAND 28412
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxHALRATOR 28414
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxHALRATOR_TAG2 28416
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxHALRATOR_pRANDS 28417
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCLASS_CASE_DECODE 28418
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxDECODE_HALRANDxRANDp 28434
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxDECODE_HALRATORxRATORp 28436
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxMARK_TARGETxHALMATp 28438
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOPxHALMAT_LINE 28440
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOPxTEMP_PTR 28442
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_THIS_RATORxNEXT_RATOR 28444
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_THIS_RATORxCLASS_DECODE 28446
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_THIS_RATORxGET_NEXT_RATORxHALMAT_LINE 28462
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_THIS_RATORxGET_NEXT_RATORxTEMP_MAT 28464
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxARG_HEAD 28468
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND_QUALIFIER 28470
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRAND 28471
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRATOR 28473
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxHALRATOR_pRANDS 28475
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxI 28477
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDO_ARGS 28479
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxCLASS_DECODE 28480
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxADD_TO_NODESxHALMAT_LINE 28496
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxADD_TO_NODESxTEMP_CELL 28498
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxGET_A_NODExTEMP_PTR 28500
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRANDxHALMAT_LINE 28502
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRATORxHALMAT_LINE 28504
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCOMMUTATIVE_RATORxRATOR 28506
#define mPASS1xCLASS_0xCLASS_05xOPCODE_CASE_DECODE 28508
#define mPASS2xTEMP_PTR 28524
#define mPASS2xPRINT_AUXMAT_LINExAUXMATp 28526
#define mPASS2xGEN_AUXRATORxPTR_TYPE_VALUE 28528
#define mPASS2xGEN_AUXRATORxTAGS_VALUE 28529
#define mPASS2xGEN_AUXRATORxHALMATp 28530
#define mPASS2xGEN_AUXRATORxOPCODE 28532
#define mPASS2xGEN_AUXRANDxNOOSE_VALUE 28533
#define mPASS2xGEN_AUXRANDxPTR_VALUE 28535
#define mPASS2xGEN_CASE_LISTxHALMATp 28537
#define mPASS2xGEN_CASE_LISTxTEMP_PTR 28539
#define mPASS2xGEN_CASE_LISTxTEMPp 28541
#define mEQUAL 28543
#define mCCURRENT 28547
#define mPERIOD 28551
#define mASTERISK 28555
#define mBLANK_COLON_BLANK 28559
#define mCOMMA 28563
#define mLEFT_PAREN 28567
#define mRIGHT_PAREN 28571
#define mBLANKS 28575
#define mCOLON 28579
#define mBLANK 28583
#define mERROR_INDEX 28587
#define mERROR_CLASSES 29071
#define m_SPMANERRxMSG 29075
#define mpRJUSTxSTRING 29079
#define mHEXxSTRING 29083
#define mHEXxHEXCODES 29087
#define mFORMAT_HALMATxMESSAGE 29091
#define mFORMAT_AUXMATxMESSAGE 29095
#define mPRINT_TIMExMESSAGE 29099
#define mPRINT_DATE_AND_TIMExMESSAGE 29103
#define mPRINT_DATE_AND_TIMExMONTH 29107
#define mPRETTY_PRINT_MATxMESSAGE 29155
#define mPRETTY_PRINT_MATxBLANKS 29159
#define mPRETTY_PRINT_MATxCAUXMAT 29163
#define mOUTPUT_LISTxLIST_ID 29167
#define mOUTPUT_LISTxPAD_CHARS 29171
#define mOUTPUT_LISTxMESSAGE 29175
#define mOUTPUT_SYT_MAPxMAP_ID 29179
#define mOUTPUT_SYT_MAPxMESSAGE 29183
#define mOUTPUT_SYT_MAPxPAD_CHARS 29187
#define mOUTPUT_VAC_MAPxMAP_ID 29191
#define mOUTPUT_VAC_MAPxMESSAGE 29195
#define mOUTPUT_VAC_MAPxPAD_CHARS 29199
#define mTRACE_MSGxMSG 29203
#define mPADxSTRING 29207
#define mPADxX72 29211
#define mCHAR_INDEXxSTRING1 29215
#define mCHAR_INDEXxSTRING2 29219
#define mDOWNGRADE_SUMMARYxTEMP_CLS 29223
#define mDOWNGRADE_SUMMARYxTEMP1 29227
#define mDOWNGRADE_SUMMARYxTEMP2 29231
#define mDOWNGRADE_SUMMARYxTEMP3 29235
#define mCOMMON_ERRORSxTEXT 29239
#define mCOMMON_ERRORSxC 29243
#define mCOMMON_ERRORSxS 29247
#define mCOMMON_ERRORSxCLS_COMPARE 29251
#define mCOMMON_ERRORSxNUMIT 29255
#define mCOMMON_ERRORSxTEMP_STMT 29259
#define mCOMMON_ERRORSxAST 29263
#define mERRORSxTEXT 29267
#define mERRORSxAST 29271
#define mPASS1xSTACK_ERRORxHALMAT_TYPE 29275
#define mPASS1xSTACK_ERRORxWHICH_FRAME 29279
#define mPASS1xPUSH_FIRST_CASE_FRAMExPUSH_IND 29283
#define mPASS1xPUSH_CASE_FRAMExPUSH_IND 29287
#define mPASS1xPOP_CASE_FRAMExPOP_IND 29291
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCASSIGN 29295
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCCOMPARISON 29299
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCINITIALIZATION 29303
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxCILLEGAL 29307
#define mPASS1xCLASS_0xCLASS_04xGEN_TARGETxTARGET_ERRORxRATOR_TYPE 29311

int32_t
_SPMANERR(int reset);

int32_t
_SPACE_ROUND(int reset);

int32_t
_ACTIVE_DESCRIPTORS(int reset);

int32_t
_CHECK_FOR_THEFT(int reset);

int32_t
_FREEBLOCK_CHECK(int reset);

int32_t
_FREEBLOCK_CHECKxADDRESS_CHECK(int reset);

int32_t
_FREEBLOCK_CHECKxBLKPROC(int reset);

int32_t
_UNUSED_BYTES(int reset);

int32_t
_MOVE_WORDS(int reset);

int32_t
_SQUASH_RECORDS(int reset);

int32_t
_PREV_FREEBLOCK(int reset);

int32_t
_PREV_RECORD(int reset);

int32_t
_ATTACH_BLOCK(int reset);

int32_t
_ATTACH_BLOCKxJOIN(int reset);

int32_t
_ATTACH_RECORD(int reset);

int32_t
_DETACH_RECORD(int reset);

int32_t
_REDUCE_BLOCK(int reset);

int32_t
_RETURN_TO_FREESTRING(int reset);

int32_t
_RECORD_FREE(int reset);

int32_t
_RETURN_UNUSED(int reset);

int32_t
_TAKE_BACK(int reset);

int32_t
COMPACTIFY(int reset);

int32_t
COMPACTIFYxADD_DESC(int reset);

int32_t
_STEAL(int reset);

int32_t
_MOVE_RECS(int reset);

int32_t
_FIND_FREE(int reset);

int32_t
_INCREASE_RECORD(int reset);

int32_t
_GET_SPACE(int reset);

int32_t
_HOW_MUCH(int reset);

int32_t
_ALLOCATE_SPACE(int reset);

int32_t
_RECORD_CONSTANT(int reset);

int32_t
_NEEDMORE_SPACE(int reset);

int32_t
RECORD_LINK(int reset);

descriptor_t *
pRJUST(int reset);

descriptor_t *
HEX(int reset);

descriptor_t *
FORMAT_HALMAT(int reset);

descriptor_t *
FORMAT_AUXMAT(int reset);

int32_t
PRINT_TIME(int reset);

int32_t
PRINT_DATE_AND_TIME(int reset);

int32_t
PRINT_PHASE_HEADER(int reset);

int32_t
PRINT_SUMMARY(int reset);

int32_t
PRETTY_PRINT_MAT(int reset);

int32_t
PRETTY_PRINT_MATxTEST_FOR_SKIP(int reset);

int32_t
OUTPUT_LIST(int reset);

int32_t
OUTPUT_SYT_MAP(int reset);

int32_t
OUTPUT_VAC_MAP(int reset);

descriptor_t *
TRACE_MSG(int reset);

descriptor_t *
PAD(int reset);

int32_t
CHAR_INDEX(int reset);

int32_t
DOWNGRADE_SUMMARY(int reset);

int32_t
COMMON_ERRORS(int reset);

int32_t
ERRORS(int reset);

int32_t
NEW_HALMAT_BLOCK(int reset);

descriptor_t *
NEW_SYT_REF_FRAME(int reset);

int32_t
FREE_SYT_REF_FRAME(int reset);

descriptor_t *
NEW_VAC_REF_FRAME(int reset);

int32_t
FREE_VAC_REF_FRAME(int reset);

descriptor_t *
NEW_ZERO_SYT_REF_FRAME(int reset);

descriptor_t *
NEW_ZERO_VAC_REF_FRAME(int reset);

int32_t
MERGE_SYT_REF_FRAMES(int reset);

int32_t
MERGE_VAC_REF_FRAMES(int reset);

descriptor_t *
COPY_SYT_REF_FRAME(int reset);

descriptor_t *
COPY_VAC_REF_FRAME(int reset);

int32_t
PASS_BACK_SYT_REFS(int reset);

int32_t
PASS_BACK_VAC_REFS(int reset);

descriptor_t *
GET_FREE_CELL(int reset);

descriptor_t *
LIST(int reset);

int32_t
LINK_CELL_AREA(int reset);

int32_t
REINITIALIZE(int reset);

int32_t
INITIALIZE(int reset);

descriptor_t *
INITIALIZExSHRINK_SYT_SIZE(int reset);

descriptor_t *
INITIALIZExSHRINK_SYT_SIZExREFERENCED(int reset);

int32_t
INCR_STACK_PTR(int reset);

int32_t
DECR_STACK_PTR(int reset);

int32_t
PASS1(int reset);

int32_t
PASS1xDECODE_HALRATOR(int reset);

int32_t
PASS1xDECODE_HALRAND(int reset);

int32_t
PASS1xSET_DEBUG_SWITCH(int reset);

int32_t
PASS1xCOMPUTE_NOOSE(int reset);

int32_t
PASS1xADD_UVC(int reset);

int32_t
PASS1xSEARCH_FOR_REF(int reset);

int32_t
PASS1xDUMP_STACK(int reset);

int32_t
PASS1xADD_TO_VAC_BOUNDS(int reset);

int32_t
PASS1xSET_RAND_NOOSE(int reset);

descriptor_t *
PASS1xSET_RAND_NOOSExRET_MIN_NOOSE(int reset);

int32_t
PASS1xSET_RAND_NOOSExSET_MIN_NOOSE(int reset);

descriptor_t *
PASS1xSET_RAND_NOOSExINTERVENING_CB(int reset);

int32_t
PASS1xSET_RAND_NOOSExMARK_SYT_CASE(int reset);

int32_t
PASS1xSET_RAND_NOOSExMARK_SYT_REF(int reset);

int32_t
PASS1xSET_RAND_NOOSExMARK_SYT_UVCS(int reset);

int32_t
PASS1xSET_RAND_NOOSExMARK_VAC_CASE(int reset);

int32_t
PASS1xSET_RAND_NOOSExMARK_VAC_REF(int reset);

int32_t
PASS1xSET_RAND_NOOSExMARK_VAC_UVCS(int reset);

int32_t
PASS1xSET_RAND_NOOSExMARK_CASE_LIST_PTRS(int reset);

int32_t
PASS1xSET_ASN_NOOSE(int reset);

int32_t
PASS1xSET_SIMP_NOOSE(int reset);

int32_t
PASS1xZAPPER(int reset);

int32_t
PASS1xFLUSH_INFO(int reset);

int32_t
PASS1xHANDLE_SIMP_NOOSE(int reset);

int32_t
PASS1xHANDLE_SIMP_OR_ASN_NOOSE(int reset);

int32_t
PASS1xSTACK_ERROR(int reset);

int32_t
PASS1xPUSH_BLOCK_FRAME(int reset);

int32_t
PASS1xPOP_BLOCK_FRAME(int reset);

int32_t
PASS1xPUSH_CB_FRAME(int reset);

int32_t
PASS1xPOP_CB_FRAME(int reset);

int32_t
PASS1xPUSH_FIRST_CASE_FRAME(int reset);

int32_t
PASS1xPUSH_CASE_FRAME(int reset);

int32_t
PASS1xPOP_CASE_FRAME(int reset);

int32_t
PASS1xCLASS_0(int reset);

int32_t
PASS1xCLASS_0xCLASS_00(int reset);

int32_t
PASS1xCLASS_0xCLASS_01(int reset);

int32_t
PASS1xCLASS_0xCLASS_02(int reset);

int32_t
PASS1xCLASS_0xCLASS_03(int reset);

int32_t
PASS1xCLASS_0xCLASS_04(int reset);

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGET(int reset);

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGETxDECODE_HALRAND(int reset);

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGETxDECODE_HALRATOR(int reset);

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGETxTARGET_ERROR(int reset);

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGETxMARK_TARGET(int reset);

descriptor_t *
PASS1xCLASS_0xCLASS_04xGEN_TARGETxCSE_STOP(int reset);

descriptor_t *
PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_THIS_RATOR(int reset);

descriptor_t *
PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_THIS_RATORxGET_NEXT_RATOR(int reset);

descriptor_t *
PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDS(int reset);

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxADD_TO_NODES(int reset);

descriptor_t *
PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxGET_A_NODE(int reset);

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRAND(int reset);

int32_t
PASS1xCLASS_0xCLASS_04xGEN_TARGETxSTOP_CONDSxDECODE_HALRATOR(int reset);

descriptor_t *
PASS1xCLASS_0xCLASS_04xGEN_TARGETxCOMMUTATIVE_RATOR(int reset);

int32_t
PASS1xCLASS_0xCLASS_05(int reset);

int32_t
PASS1xCLASS_1(int reset);

int32_t
PASS1xCLASS_2(int reset);

int32_t
PASS1xCLASS_3(int reset);

int32_t
PASS1xCLASS_4(int reset);

int32_t
PASS1xCLASS_5(int reset);

int32_t
PASS1xCLASS_6(int reset);

int32_t
PASS1xCLASS_7(int reset);

int32_t
PASS2(int reset);

int32_t
PASS2xPRINT_AUXMAT_LINE(int reset);

int32_t
PASS2xGEN_AUXRATOR(int reset);

int32_t
PASS2xGEN_AUXRAND(int reset);

int32_t
PASS2xGEN_NOOSE(int reset);

int32_t
PASS2xGEN_XREC(int reset);

int32_t
PASS2xGEN_TARGET(int reset);

int32_t
PASS2xGEN_AUXMAT_END(int reset);

int32_t
PASS2xGEN_CASE_LIST(int reset);

int32_t
PASS2xGEN_SNCS(int reset);

int32_t
PASS2xPASS2_DISPATCHER(int reset);
