/*
  File procedures.h generated by XCOM-I, 2024-08-09 12:40:26.
  Provides prototypes for the C functions corresponding to the
  XPL/I PROCEDUREs and setjmp/longjmp.

  Note: Due to the requirement for persistence, all function
  parameters are passed via static addresses in the `memory`
  array, rather than via parameter lists, so all parameter
  lists are `void`.
*/

#include <stdint.h>
#include <setjmp.h>

extern jmp_buf jbBAIL_OUT;
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
#define mCOMMTABL_BYTE 4280
#define mCOMMTABL_HALFWORD 4308
#define mCOMMTABL_FULLWORD 4336
#define mDATABUF_BYTE 4364
#define mDATABUF_HALFWORD 4392
#define mDATABUF_FULLWORD 4420
#define mVMEM_B 4448
#define mVMEM_H 4476
#define mVMEM_F 4504
#define mVARNAME_REC 4532
#define mCELL_PTR_REC 4560
#define mSTMT_DECL_CELL 4588
#define mSDF_SELECTxNODE_H 4616
#define mSDF_SELECTxNODE_F 4644
#define mPAGE_DUMPxWORD 4672
#define mPTR_TO_BLOCKxNODE_H 4700
#define mPRINT_REPLACE_TEXTxNODE_F 4728
#define mPRINT_REPLACE_TEXTxNODE_B 4756
#define mDUMP_SDFxNODE_F 4784
#define mDUMP_SDFxNODE_F1 4812
#define mDUMP_SDFxNODE_B 4840
#define mDUMP_SDFxNODE_B1 4868
#define mDUMP_SDFxNODE_H 4896
#define mDUMP_SDFxSYM_SORT 4924
#define mDUMP_SDFxDUMP_HALMATxNODE_F 4952
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxVMEM_F 4980
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxVMEM_H 5008
#define mINITIALIZExPRO 5036
#define mINITIALIZExCON 5064
#define mINITIALIZExTYPE2 5092
#define mINITIALIZExVALS 5120
#define mINITIALIZExMONVALS 5148
#define mINITIALIZExINIT_FCB 5176
#define mINITIALIZExINIT_PG 5204
#define mINITIALIZExPPRO 5232
#define mDX_SIZE 5260
#define mDESCRIPTOR_DESCRIPTOR 5264
#define mFREESTRING_TARGET 5296
#define mFREESTRING_TRIGGER 5300
#define mFREESTRING_MIN 5304
#define mCOMPACTIFIES 5308
#define mREALLOCATIONS 5312
#define m_IN_COMPACTIFY 5314
#define m_DX_TOTAL 5316
#define m_PREV_DX_TOTAL 5320
#define m_LAST_COMPACTIFY_FOUND 5324
#define mFORCE_MAJOR 5328
#define m_OLDFREELIMIT 5332
#define mFREEPRINT 5336
#define mTMP 5340
#define mLAST_PAGE 5344
#define mLOC_PTR 5348
#define mLOC_ADDR 5352
#define mFIRST_STMT 5356
#define mLAST_STMT 5358
#define mSTMT_NODES 5360
#define mSTMT_NODE_SIZE 5362
#define mBASE_SYMB_PAGE 5364
#define mBASE_SYMB_OFFSET 5366
#define mBASE_STMT_PAGE 5368
#define mBASE_STMT_OFFSET 5370
#define mBASE_BLOCK_PAGE 5372
#define mBASE_BLOCK_OFFSET 5374
#define mpSYMBOLS 5376
#define mpSTMTS 5378
#define mpEXECS 5380
#define mpEXTERNALS 5382
#define mpPROCS 5384
#define mpBIFUNCS 5386
#define mBASE_BI_PTR 5388
#define mKEY_BLOCK 5392
#define mKEY_SYMB 5394
#define mCOMPUNIT 5396
#define mEMITTED_CNT 5400
#define mSDFPKG_LOCATES 5404
#define mSDFPKG_READS 5408
#define mSDFPKG_SLECTCNT 5412
#define mSDFPKG_FCBAREA 5416
#define mSDFPKG_PGAREA 5420
#define mSDFPKG_NUMGETM 5422
#define mpLABELS 5424
#define mpLHS 5426
#define mSRN_FLAG 5428
#define mADDR_FLAG 5429
#define mSDL_FLAG 5430
#define mNEW_FLAG 5431
#define mCOMPOOL_FLAG 5432
#define mHMAT_OPT 5433
#define mOVERFLOW_FLAG 5434
#define mSRN_FLAG1 5435
#define mSRN_FLAG2 5436
#define mNOTRACE_FLAG 5437
#define mFC_FLAG 5438
#define mFCDATA_FLAG 5439
#define mSTAND_ALONE 5440
#define mTABDMP 5441
#define mTABLST 5442
#define mBRIEF 5443
#define mALL 5444
#define mCOMM_TAB 5448
#define mCOMMTABL_ADDR 5568
#define mCLOCK 5572
#define mVN_INX 5584
#define mPTR_INX 5586
#define mASIP_FLAG 5588
#define mVMEM_PTR_STATUS 5592
#define mVMEM_FLAGS_STATUS 5604
#define mMODF 5607
#define mRESV 5608
#define mRELS 5609
#define m_SPMANERRxNUMERRORS 5610
#define m_SPACE_ROUNDxBYTES 5612
#define m_ACTIVE_DESCRIPTORSxDOPE 5616
#define m_ACTIVE_DESCRIPTORSxDP 5620
#define m_ACTIVE_DESCRIPTORSxDW 5624
#define m_ACTIVE_DESCRIPTORSxDLAST 5628
#define m_ACTIVE_DESCRIPTORSxDND 5632
#define m_ACTIVE_DESCRIPTORSxI 5636
#define m_ACTIVE_DESCRIPTORSxJ 5640
#define m_ACTIVE_DESCRIPTORSxANS 5644
#define m_FREEBLOCK_CHECKxUPLIM 5648
#define m_FREEBLOCK_CHECKxDOWNLIM 5652
#define m_FREEBLOCK_CHECKxFBYTES 5656
#define m_FREEBLOCK_CHECKxRBYTES 5660
#define m_FREEBLOCK_CHECKxRDOPE 5664
#define m_FREEBLOCK_CHECKxRPNTR 5668
#define m_FREEBLOCK_CHECKxRSIZE 5672
#define m_FREEBLOCK_CHECKxBPNTR 5676
#define m_FREEBLOCK_CHECKxBSIZE 5680
#define m_FREEBLOCK_CHECKxBLKNO 5684
#define m_FREEBLOCK_CHECKxRECNO 5686
#define m_FREEBLOCK_CHECKxADDRESS_CHECKxADDRESS 5688
#define m_UNUSED_BYTESxCUR 5692
#define m_UNUSED_BYTESxANS 5696
#define m_MOVE_WORDSxSOURCE 5700
#define m_MOVE_WORDSxDEST 5704
#define m_MOVE_WORDSxNUMBYTES 5708
#define m_MOVE_WORDSxI 5712
#define m_SQUASH_RECORDSxCURDOPE 5716
#define m_SQUASH_RECORDSxRECPTR 5720
#define m_SQUASH_RECORDSxLAST_RECPTR 5724
#define m_SQUASH_RECORDSxCURBLOCK 5728
#define m_SQUASH_RECORDSxNEXTBLOCK 5732
#define m_SQUASH_RECORDSxBYTES_TO_MOVE_BY 5736
#define m_SQUASH_RECORDSxSQUASHED 5740
#define m_SQUASH_RECORDSxRECBYTES 5744
#define m_SQUASH_RECORDSxI 5748
#define m_PREV_FREEBLOCKxBLOCK 5752
#define m_PREV_FREEBLOCKxPREV 5756
#define m_PREV_FREEBLOCKxCUR 5760
#define m_PREV_RECORDxDOPE 5764
#define m_PREV_RECORDxPREV 5768
#define m_PREV_RECORDxCUR 5772
#define m_ATTACH_BLOCKxBLOCK 5776
#define m_ATTACH_BLOCKxPREV 5780
#define m_ATTACH_BLOCKxCUR 5784
#define m_ATTACH_BLOCKxJOINxB1 5788
#define m_ATTACH_BLOCKxJOINxB2 5792
#define m_ATTACH_RECORDxDOPE 5796
#define m_ATTACH_RECORDxPREV 5800
#define m_ATTACH_RECORDxCUR 5804
#define m_ATTACH_RECORDxLOC 5808
#define m_DETACH_RECORDxDOPE 5812
#define m_DETACH_RECORDxPREV 5816
#define m_REDUCE_BLOCKxBLOCK 5820
#define m_REDUCE_BLOCKxREMBYTES 5824
#define m_REDUCE_BLOCKxTOP 5828
#define m_REDUCE_BLOCKxPREV 5832
#define m_REDUCE_BLOCKxOLDNBYTES 5836
#define m_REDUCE_BLOCKxNEWBLOCK 5840
#define m_RETURN_TO_FREESTRINGxNBYTES 5844
#define m_RECORD_FREExDOPE 5848
#define m_RECORD_FREExSIZE 5852
#define m_RECORD_FREExPREV 5856
#define m_RECORD_FREExNEWBLOCK 5860
#define m_RETURN_UNUSEDxDOPE 5864
#define m_RETURN_UNUSEDxNRECS 5868
#define m_RETURN_UNUSEDxNEWBLOCK 5872
#define m_RETURN_UNUSEDxOLDNBYTES 5876
#define m_RETURN_UNUSEDxNEWNBYTES 5880
#define m_RETURN_UNUSEDxDIF 5884
#define m_TAKE_BACKxNBYTES 5888
#define m_TAKE_BACKxCUR 5892
#define m_TAKE_BACKxRET_RECS 5896
#define m_TAKE_BACKxDIF_RECS 5900
#define m_TAKE_BACKxPOSSIBLE 5904
#define m_TAKE_BACKxLEFTBYTES 5908
#define m_TAKE_BACKxPREV_FREEBYTES 5912
#define m_TAKE_BACKxPREV_FREEPRINT 5916
#define mCOMPACTIFYxI 5920
#define mCOMPACTIFYxJ 5924
#define mCOMPACTIFYxK 5928
#define mCOMPACTIFYxL 5932
#define mCOMPACTIFYxND 5936
#define mCOMPACTIFYxTC 5940
#define mCOMPACTIFYxBC 5944
#define mCOMPACTIFYxDELTA 5948
#define mCOMPACTIFYxMODE 5952
#define mCOMPACTIFYxACTUAL_DX_TOTAL 5956
#define mCOMPACTIFYxMASK 5960
#define mCOMPACTIFYxLOWER_BOUND 5964
#define mCOMPACTIFYxUPPER_BOUND 5968
#define mCOMPACTIFYxTRIED 5972
#define mCOMPACTIFYxDP 5976
#define mCOMPACTIFYxDW 5980
#define mCOMPACTIFYxADD_DESCxI 5984
#define mCOMPACTIFYxADD_DESCxL 5988
#define m_STEALxNBYTES 5992
#define m_STEALxBLOCKLOC 5996
#define m_MOVE_RECSxDOPE 6000
#define m_MOVE_RECSxBYTES_TO_MOVE_BY 6004
#define m_MOVE_RECSxNBYTES 6008
#define m_MOVE_RECSxSOURCE 6012
#define m_MOVE_RECSxCURDOPE 6016
#define m_FIND_FREExNBYTES 6020
#define m_FIND_FREExUNMOVEABLE 6024
#define m_FIND_FREExI 6025
#define m_FIND_FREExCURBLOCK 6028
#define m_FIND_FREExDOPE 6032
#define m_INCREASE_RECORDxDOPE 6036
#define m_INCREASE_RECORDxNRECSMORE 6040
#define m_INCREASE_RECORDxOLDNRECS 6044
#define m_INCREASE_RECORDxOLDNBYTES 6048
#define m_INCREASE_RECORDxNEWNRECS 6052
#define m_INCREASE_RECORDxNEWNBYTES 6056
#define m_INCREASE_RECORDxNBYTESMORE 6060
#define m_INCREASE_RECORDxI 6064
#define m_GET_SPACExNBYTES 6068
#define m_GET_SPACExUNMOVEABLE 6072
#define m_GET_SPACExFREEB 6076
#define m_GET_SPACExNEWREC 6080
#define m_GET_SPACExI 6084
#define m_HOW_MUCHxDOPE 6088
#define m_HOW_MUCHxANS 6092
#define m_HOW_MUCHxANSBYTES 6096
#define m_HOW_MUCHxNSTRBYTES 6100
#define m_HOW_MUCHxANSMIN 6104
#define m_ALLOCATE_SPACExDOPE 6108
#define m_ALLOCATE_SPACExHIREC 6112
#define m_ALLOCATE_SPACExNREC 6116
#define m_ALLOCATE_SPACExOREC 6120
#define m_RECORD_CONSTANTxDOPE 6124
#define m_RECORD_CONSTANTxHIREC 6128
#define m_RECORD_CONSTANTxMOVEABLE 6132
#define m_NEEDMORE_SPACExDOPE 6136
#define mRECORD_LINKxCUR 6140
#define mPADxMAX 6144
#define mPADxL 6146
#define mLEFT_PADxWIDTH 6148
#define mLEFT_PADxL 6152
#define mFORMATxI 6156
#define mFORMATxJ 6160
#define mFORMATxIVAL 6164
#define mFORMATxN 6168
#define mHEXxHVAL 6172
#define mHEXxN 6176
#define mHEX8xHVAL 6180
#define mHEX8xI 6184
#define mHEX6xHVAL 6188
#define mHEX6xI 6192
#define mCHARTIMExT 6196
#define mCHARDATExD 6200
#define mCHARDATExYEAR 6204
#define mCHARDATExDAY 6208
#define mCHARDATExM 6212
#define mCHARDATExDAYS 6216
#define mPRINT_TIMExT 6268
#define mPRINT_DATE_AND_TIMExD 6272
#define mPRINT_DATE_AND_TIMExT 6276
#define mMOVExFROM 6280
#define mMOVExINTO 6284
#define mMOVExADDRTEMP 6288
#define mMOVExLEGNTH 6292
#define mSTMT_TO_PTRxOFFSET 6296
#define mSTMT_TO_PTRxSTMT 6300
#define mSTMT_TO_PTRxPAGE 6302
#define mSYMB_TO_PTRxOFFSET 6304
#define mSYMB_TO_PTRxSYMB 6308
#define mSYMB_TO_PTRxPAGE 6310
#define mBLOCK_TO_PTRxOFFSET 6312
#define mBLOCK_TO_PTRxBLOCK 6316
#define mBLOCK_TO_PTRxPAGE 6318
#define mSDF_SELECTxTEMP 6320
#define mSDF_PTR_LOCATExPTR 6324
#define mSDF_PTR_LOCATExARG 6328
#define mSDF_PTR_LOCATExFLAGS 6332
#define mSDF_LOCATExPTR 6336
#define mSDF_LOCATExBVAR 6340
#define mSDF_LOCATExFLAGS 6344
#define mPAGE_DUMPxPAGE 6345
#define mPAGE_DUMPxJ 6347
#define mPAGE_DUMPxJJ 6349
#define mPAGE_DUMPxII 6351
#define mPAGE_DUMPxIII 6353
#define mPAGE_DUMPxSTILL_ZERO 6355
#define mBLOCK_NAMExBLKp 6356
#define mSYMBOL_NAMExSYMBp 6358
#define mPTR_TO_BLOCKxPTR 6360
#define mPRINT_REPLACE_TEXTxTEXT_PTR 6364
#define mPRINT_REPLACE_TEXTxpBYTES 6368
#define mPRINT_REPLACE_TEXTxWAS_HERE 6372
#define mPRINT_REPLACE_TEXTxJ 6373
#define mPRINT_REPLACE_TEXTxpARGS 6374
#define mPRINT_REPLACE_TEXTxCELL_SIZE 6376
#define mPRINT_REPLACE_TEXTxM_PTR 6378
#define mPRINT_REPLACE_TEXTxM_CHAR_PTR 6380
#define mDUMP_SDFxFLAG 6384
#define mDUMP_SDFxSADDR 6388
#define mDUMP_SDFxSEXTENT 6392
#define mDUMP_SDFxPTR 6396
#define mDUMP_SDFxPTR1 6400
#define mDUMP_SDFxADDR1 6404
#define mDUMP_SDFxADDR2 6408
#define mDUMP_SDFxTEMP 6412
#define mDUMP_SDFxHMAT_PTR 6416
#define mDUMP_SDFxSOFFSET 6420
#define mDUMP_SDFxINCLUDE_PTR 6424
#define mDUMP_SDFxI 6428
#define mDUMP_SDFxJ 6430
#define mDUMP_SDFxJ1 6432
#define mDUMP_SDFxJ2 6434
#define mDUMP_SDFxK 6436
#define mDUMP_SDFxK1 6438
#define mDUMP_SDFxK2 6440
#define mDUMP_SDFxL 6442
#define mDUMP_SDFxKLIM 6444
#define mDUMP_SDFxITEM 6446
#define mDUMP_SDFxLAST_BLOCK 6448
#define mDUMP_SDFxSBLK 6450
#define mDUMP_SDFxpCHARS 6452
#define mDUMP_SDFxpXREF 6454
#define mDUMP_SDFxTEMP1 6456
#define mDUMP_SDFxTEMP2 6458
#define mDUMP_SDFxTEMP3 6460
#define mDUMP_SDFxTEMP4 6462
#define mDUMP_SDFxSCLASS 6464
#define mDUMP_SDFxpBITS 6465
#define mDUMP_SDFxSHIFT 6466
#define mDUMP_SDFxSFLAG 6467
#define mDUMP_SDFxSTYPE 6468
#define mDUMP_SDFxNAME_FLAG 6469
#define mDUMP_SDFxSRNS 6470
#define mDUMP_SDFxCONST_FLAG 6471
#define mDUMP_SDFxDOUBLE_FLAG 6472
#define mDUMP_SDFxLIT_FLAG 6473
#define mDUMP_SDFxLIT_TYPE 6474
#define mDUMP_SDFxT 6475
#define mDUMP_SDFxSUBTYPE 6513
#define mDUMP_SDFxMAX_ARRAY 6514
#define mDUMP_SDFxSYM_DATA_CELL_ADDR 6516
#define mDUMP_SDFxINSERT_SORTxOFF 6520
#define mDUMP_SDFxINSERT_SORTxSIZE 6524
#define mDUMP_SDFxINSERT_SORTxSYM 6526
#define mDUMP_SDFxINSERT_SORTxI 6528
#define mDUMP_SDFxPRINT_pD_INFOxINFO_FLAG 6530
#define mDUMP_SDFxPRINT_pD_INFOxCLASS 6531
#define mDUMP_SDFxPRINT_pD_INFOxTYPE 6533
#define mDUMP_SDFxPRINT_pD_INFOxIJ 6536
#define mDUMP_SDFxPRINT_pD_INFOxSIZE 6540
#define mDUMP_SDFxPRINT_pD_INFOxFLAGS 6544
#define mDUMP_SDFxPRINT_pD_INFOxOLD_OFFSET 6548
#define mDUMP_SDFxINTEGERIZABLExFLT_NEGMAX 6552
#define mDUMP_SDFxINTEGERIZABLExNEGMAX 6556
#define mDUMP_SDFxINTEGERIZABLExNEGLIT 6560
#define mDUMP_SDFxINTEGERIZABLExTEMP 6564
#define mDUMP_SDFxINTEGERIZABLExTEMP1 6568
#define mDUMP_SDFxFLUSHxLAST 6572
#define mDUMP_SDFxFLUSHxI 6574
#define mDUMP_SDFxFLUSHxJ 6576
#define mDUMP_SDFxFLUSHxK 6578
#define mDUMP_SDFxFLUSHxSTMT_VARS 6580
#define mDUMP_SDFxSTACK_PTRxPTR 6584
#define mDUMP_SDFxFORMAT_FORM_PARM_CELLxJ 6588
#define mDUMP_SDFxFORMAT_FORM_PARM_CELLxK 6590
#define mDUMP_SDFxFORMAT_FORM_PARM_CELLxSYMBp 6592
#define mDUMP_SDFxFORMAT_FORM_PARM_CELLxPTR 6596
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxpSYTS 6600
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxJ 6602
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxLAST_SUB_TYPE 6604
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxPTR 6608
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxNO_PRINT 6612
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxSUBSCRIPTS 6613
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxALPHA 6614
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_TYPE 6615
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxBETA 6616
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxEXP_TYPE 6617
#define mDUMP_SDFxFORMAT_EXP_VARS_CELLxI 6618
#define mDUMP_SDFxFORMAT_EXP_VARS_CELLxJ 6620
#define mDUMP_SDFxFORMAT_EXP_VARS_CELLxK 6622
#define mDUMP_SDFxFORMAT_EXP_VARS_CELLxM 6624
#define mDUMP_SDFxFORMAT_EXP_VARS_CELLxpSYTS 6626
#define mDUMP_SDFxFORMAT_EXP_VARS_CELLxOUTER 6628
#define mDUMP_SDFxFORMAT_EXP_VARS_CELLxPTR 6632
#define mDUMP_SDFxDUMP_HALMATxPTR 6636
#define mDUMP_SDFxDUMP_HALMATxHPTR 6640
#define mDUMP_SDFxDUMP_HALMATxTEMP 6644
#define mDUMP_SDFxDUMP_HALMATxI 6648
#define mDUMP_SDFxDUMP_HALMATxpWORDS 6650
#define mDUMP_SDFxDUMP_HALMATxHCELL 6652
#define mDUMP_SDFxDUMP_HALMATxFORMAT_HMATxATOM 6656
#define mDUMP_SDFxDUMP_HALMATxFORMAT_HMATxPROD 6660
#define mDUMP_SDFxDUMP_HALMATxFORMAT_HMATxICNT 6662
#define mDUMP_SDFxDUMP_HALMATxFORMAT_HMATxJ 6664
#define mDUMP_SDFxFORMAT_PF_INV_CELLxpASSIGN 6666
#define mDUMP_SDFxFORMAT_PF_INV_CELLxJ 6668
#define mDUMP_SDFxFORMAT_PF_INV_CELLxK 6670
#define mDUMP_SDFxFORMAT_PF_INV_CELLxSYMB 6672
#define mDUMP_SDFxFORMAT_PF_INV_CELLxPTR 6676
#define mDUMP_SDFxFORMAT_CELL_TREExPTR_TYPE 6680
#define mDUMP_SDFxFORMAT_CELL_TREExOUTER 6681
#define mDUMP_SDFxFORMAT_CELL_TREExSTMT_VARS 6682
#define mDUMP_SDFxFORMAT_CELL_TREExPTR 6684
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxpSYTS 6688
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxSYMBp 6690
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxJ 6692
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxK 6694
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxWORDTYPE 6696
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxFIRSTWORD 6698
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxNEXT_CELL 6700
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxPTR 6704
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxPTR_TEMP 6708
#define mDUMP_SDFxPRINT_XREF_DATAxK 6712
#define mINITIALIZExJ 6716
#define mSDF_PROCESSINGxRECORD_ADDR 6720
#define mSDF_PROCESSINGxOFFSET 6724
#define mSDF_PROCESSINGxMAX_OFFSET 6726
#define mSDF_PROCESSINGxALIGNED_BUFFER 6728
#define mSDF_PROCESSINGxFFBUFF 6984
#define mPRINTSUMMARYxT 6992
#define mPRINTSUMMARYxI 6996
#define mCOLON 6998
#define mDOUBLE 7002
#define mHEXCODES 7006
#define mASTS 7010
#define mSDFLIST_ERR 7014
#define mX1 7018
#define mX2 7022
#define mX3 7026
#define mX4 7030
#define mX5 7034
#define mX6 7038
#define mX7 7042
#define mX10 7046
#define mX15 7050
#define mX20 7054
#define mX28 7058
#define mX30 7062
#define mX52 7066
#define mX60 7070
#define mX72 7074
#define mSTMT_TYPES 7078
#define mSTMT_FLAGS 7226
#define mSYMBOL_CLASSES 7246
#define mSYMBOL_TYPES 7274
#define mPROC_TYPES 7346
#define mTITLE 7386
#define mSDF_NAME 7390
#define mPRINTLINE 7394
#define mS 7398
#define mBI_NAME 7562
#define m_SPMANERRxMSG 7818
#define mEMIT_OUTPUTxSTRING 7822
#define mPADxSTRING 7826
#define mLEFT_PADxSTRING 7830
#define mFORMATxSTRING1 7834
#define mFORMATxSTRING2 7838
#define mFORMATxCHAR 7842
#define mHEXxSTRING 7846
#define mHEXxZEROS 7850
#define mHEX8xT 7854
#define mHEX6xT 7858
#define mCHARTIMExC 7862
#define mCHARDATExMONTH 7866
#define mPRINT_TIMExMESSAGE 7914
#define mPRINT_TIMExC 7918
#define mPRINT_DATE_AND_TIMExMESSAGE 7922
#define mPRINT_DATE_AND_TIMExC 7926
#define mPAGE_DUMPxTS 7930
#define mBLOCK_NAMExBNAME 7982
#define mSYMBOL_NAMExSNAME 7986
#define mPRINT_REPLACE_TEXTxS1 7990
#define mPRINT_REPLACE_TEXTxS2 7994
#define mPRINT_REPLACE_TEXTxBUILD_M 7998
#define mPRINT_REPLACE_TEXTxS 8002
#define mDUMP_SDFxSUB_STMT_TYPES 8010
#define mDUMP_SDFxTS 8054
#define mDUMP_SDFxSRN_STRING 8098
#define mDUMP_SDFxINCL_STRING 8102
#define mDUMP_SDFxADDR1_HEX 8106
#define mDUMP_SDFxADDR2_HEX 8110
#define mDUMP_SDFxADDR3_HEX 8114
#define mDUMP_SDFxSDF_TITLE 8118
#define mDUMP_SDFxINCL_FILES 8122
#define mDUMP_SDFxNAME 8146
#define mDUMP_SDFxADDR1_DEC 8150
#define mDUMP_SDFxADDR2_DEC 8154
#define mDUMP_SDFxADDR3_DEC 8158
#define mDUMP_SDFxCHAR_STRING 8162
#define mDUMP_SDFxPRINT_pD_INFOxTMPC 8166
#define mDUMP_SDFxFLUSHxSTRING 8170
#define mDUMP_SDFxFLUSHxX13 8174
#define mDUMP_SDFxSTACK_STRINGxSTRING 8178
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_STRINGS 8182
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxEXP_STRINGS 8194
#define mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG 8214
#define mDUMP_SDFxFORMAT_EXP_VARS_CELLxSTRING 8234
#define mDUMP_SDFxDUMP_HALMATxFORMAT_HMATxC 8238
#define mDUMP_SDFxDUMP_HALMATxFORMAT_HMATxBLAB1 8242
#define mDUMP_SDFxDUMP_HALMATxFORMAT_HMATxBLAB2 8246
#define mDUMP_SDFxFORMAT_NAME_TERM_CELLSxTEMPNAME 8250
#define mINITIALIZExC 8254
#define mINITIALIZExS 8258
#define mINITIALIZExPARM_TEXT 8262
#define mSDF_PROCESSINGxFFSTRING 8266
#define mSDF_PROCESSINGxBUFFER 8270

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
EMIT_OUTPUT(int reset);

descriptor_t *
PAD(int reset);

descriptor_t *
LEFT_PAD(int reset);

descriptor_t *
FORMAT(int reset);

descriptor_t *
HEX(int reset);

descriptor_t *
HEX8(int reset);

descriptor_t *
HEX6(int reset);

descriptor_t *
CHARTIME(int reset);

descriptor_t *
CHARDATE(int reset);

int32_t
PRINT_TIME(int reset);

int32_t
PRINT_DATE_AND_TIME(int reset);

int32_t
MOVE(int reset);

int32_t
STMT_TO_PTR(int reset);

int32_t
SYMB_TO_PTR(int reset);

int32_t
BLOCK_TO_PTR(int reset);

int32_t
SDF_SELECT(int reset);

int32_t
SDF_PTR_LOCATE(int reset);

int32_t
SDF_LOCATE(int reset);

int32_t
PAGE_DUMP(int reset);

descriptor_t *
BLOCK_NAME(int reset);

descriptor_t *
SYMBOL_NAME(int reset);

descriptor_t *
PTR_TO_BLOCK(int reset);

int32_t
PRINT_REPLACE_TEXT(int reset);

int32_t
DUMP_SDF(int reset);

int32_t
DUMP_SDFxINSERT_SORT(int reset);

int32_t
DUMP_SDFxPRINT_pD_INFO(int reset);

int32_t
DUMP_SDFxPRINT_ADDRS(int reset);

int32_t
DUMP_SDFxINTEGERIZABLE(int reset);

int32_t
DUMP_SDFxFLUSH(int reset);

int32_t
DUMP_SDFxSTACK_PTR(int reset);

int32_t
DUMP_SDFxSTACK_STRING(int reset);

int32_t
DUMP_SDFxFORMAT_FORM_PARM_CELL(int reset);

descriptor_t *
DUMP_SDFxFORMAT_VAR_REF_CELL(int reset);

int32_t
DUMP_SDFxFORMAT_EXP_VARS_CELL(int reset);

int32_t
DUMP_SDFxDUMP_HALMAT(int reset);

int32_t
DUMP_SDFxDUMP_HALMATxFORMAT_HMAT(int reset);

int32_t
DUMP_SDFxFORMAT_PF_INV_CELL(int reset);

int32_t
DUMP_SDFxFORMAT_CELL_TREE(int reset);

int32_t
DUMP_SDFxFORMAT_NAME_TERM_CELLS(int reset);

int32_t
DUMP_SDFxPRINT_XREF_DATA(int reset);

int32_t
INITIALIZE(int reset);

int32_t
SDF_PROCESSING(int reset);

int32_t
PRINTSUMMARY(int reset);