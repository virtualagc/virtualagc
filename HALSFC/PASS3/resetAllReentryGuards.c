/*
  File resetAllReentryGuards.c was generated by XCOM-I, 2024-08-08 04:33:10.
*/

#include "runtimeC.h"

void
resetAllReentryGuards(void) {
  _SPMANERR(1);
  _SPACE_ROUND(1);
  _ACTIVE_DESCRIPTORS(1);
  _CHECK_FOR_THEFT(1);
  _FREEBLOCK_CHECK(1);
  _UNUSED_BYTES(1);
  _MOVE_WORDS(1);
  _SQUASH_RECORDS(1);
  _PREV_FREEBLOCK(1);
  _PREV_RECORD(1);
  _ATTACH_BLOCK(1);
  _ATTACH_RECORD(1);
  _DETACH_RECORD(1);
  _REDUCE_BLOCK(1);
  _RETURN_TO_FREESTRING(1);
  _RECORD_FREE(1);
  _RETURN_UNUSED(1);
  _TAKE_BACK(1);
  COMPACTIFY(1);
  _STEAL(1);
  _MOVE_RECS(1);
  _FIND_FREE(1);
  _INCREASE_RECORD(1);
  _GET_SPACE(1);
  _HOW_MUCH(1);
  _ALLOCATE_SPACE(1);
  _RECORD_CONSTANT(1);
  _NEEDMORE_SPACE(1);
  RECORD_LINK(1);
  KOREWORD(1);
  CHAR_INDEX(1);
  FORMAT(1);
  GET_LITERAL(1);
  HEX(1);
  HEX8(1);
  MIN(1);
  DUMP_VMEM_STATUS(1);
  MOVE(1);
  ZERO_256(1);
  ZERO_CORE(1);
  DISP(1);
  PTR_LOCATE(1);
  GET_CELL(1);
  LOCATE(1);
  SYT_NAME1(1);
  PRINT_TIME(1);
  PRINT_DATE_AND_TIME(1);
  GETARRAYDIM(1);
  GETARRAYp(1);
  SDF_NAME(1);
  CSECT_NAME(1);
  PAD(1);
  PTR_FIX(1);
  STMT_TO_PTR(1);
  SYMB_TO_PTR(1);
  BLOCK_TO_PTR(1);
  P3_DISP(1);
  PAGING_STRATEGY(1);
  P3_PTR_LOCATE(1);
  P3_LOCATE(1);
  EXTRACT4(1);
  PUTN(1);
  ZERON(1);
  TRAN(1);
  PAGE_DUMP(1);
  P3_GET_CELL(1);
  GET_DIR_CELL(1);
  GET_DATA_CELL(1);
  CHECK_COMPOUND(1);
  LHS_CHECK(1);
  BUILD_SDF_LITTAB(1);
  BUILD_INITTAB(1);
  REFORMAT_HALMAT(1);
  GET_STMT_DATA(1);
  EMIT_KEY_SDF_INFO(1);
  OUTPUT_SDF(1);
  INITIALIZE(1);
  BUILD_SDF(1);
  PRINTSUMMARY(1);
  _FREEBLOCK_CHECKxADDRESS_CHECK(1);
  _FREEBLOCK_CHECKxBLKPROC(1);
  _ATTACH_BLOCKxJOIN(1);
  COMPACTIFYxADD_DESC(1);
  PTR_LOCATExSAVE_PTR_STATE(1);
  PTR_LOCATExPAGING_STRATEGY(1);
  PTR_LOCATExBAD_PTR(1);
  BUILD_SDF_LITTABxSDF_CHAR_LIT(1);
  REFORMAT_HALMATxMOD_HMAT(1);
  INITIALIZExSYT_DUMP(1);
  INITIALIZExUSED(1);
  INITIALIZExGET_CODE_HWM(1);
  INITIALIZExINVALID_SYMBOL(1);
  INITIALIZExSYMB_SUB(1);
  INITIALIZExBLOCK_SUB(1);
  INITIALIZExTRAVERSE(1);
  INITIALIZExBUILD_BLOCK_TABLES(1);
  INITIALIZExCHECK_COMP_UNIT_NAME(1);
  INITIALIZExDPRINT(1);
  BUILD_SDFxSEARCH_AND_ENQUEUE(1);
  BUILD_SDFxGET_SDF_CELL(1);
  BUILD_SDFxMOVE_CELL_TREE(1);
  BUILD_SDFxMOVE_NAME_TERM_CELLS(1);
  BUILD_SDFxGET_SYT_VPTR(1);
  BUILD_SDFxBUILD_XREF_FUNC_TAB(1);
  BUILD_SDFxINX_TO_PTR(1);
  BUILD_SDFxBAD_SRN(1);
  BUILD_SDFxMOVE_CELL_TREExDO_VAR_REF_CELL(1);
  BUILD_SDFxMOVE_CELL_TREExDO_PF_INV_CELL(1);
  BUILD_SDFxMOVE_CELL_TREExDO_EXP_VARS_CELL(1);
  BUILD_SDFxBUILD_XREF_FUNC_TABxFUNC_DATA_CELL(1);
  PRINTSUMMARYxADVISORY_MSG(1);
  PRINTSUMMARYxADVISORY_MSGxOUTPUT_MSG(1);
}
