/*
  File main.c generated by XCOM-I, 2024-08-08 04:33:20.
  XPL/I source-code files used: SPACELIB.xpl ##DRIVER.xpl COMMON.xpl
  COMDEC19.xpl VMEM1.xpl VMEM2.xpl EMITOUTP.xpl PAD.xpl LEFTPAD.xpl FORMAT.xpl
  HEX.xpl HEX8.xpl HEX6.xpl CHARTIME.xpl CHARDATE.xpl PRINTTIM.xpl PRINTDAT.xpl
  MOVE.xpl ZERO256.xpl ZEROCORE.xpl STMTTOPT.xpl SYMBTOPT.xpl BLOCKTOP.xpl
  SDFSELEC.xpl SDFPTRLO.xpl SDFLOCAT.xpl PAGEDUMP.xpl BLOCKNAM.xpl SYMBOLNA.xpl
  PTRTOBLO.xpl PRINTREP.xpl DUMPSDF.xpl INITIALI.xpl SDFPROCE.xpl PRINTSUM.xpl.
  To build the program from the command line, using defaults:
          cd PASS4/
          make
  View the Makefile to see different options for the `make`
  command above.  To run the program:
          PASS4 [OPTIONS]
  Use `PASS4 --help` to see the available OPTIONS.
*/

#include "runtimeC.h"

jmp_buf jbBAIL_OUT;

// clang-format off
/*
            *** Memory Map ***
  Address (Hex)   Data Type   Variable
  -------------   ---------   --------
  1320 (000528)   FIXED       FIRSTRECORD
  1324 (00052C)   FIXED       FIRSTBLOCK
  1328 (000530)   FIXED       FREEBYTES
  1332 (000534)   FIXED       RECBYTES
  1336 (000538)   FIXED       TOTAL_RDESC
  1340 (00053C)   FIXED       CORELIMIT
  1344 (000540)   BASED       SYM_TAB
  1372 (00055C)   BASED       DOWN_INFO
  1400 (000578)   BASED       SYM_ADD
  1428 (000594)   BASED       CROSS_REF
  1456 (0005B0)   BASED       LIT_NDX
  1484 (0005CC)   BASED       FOR_DW
  1512 (0005E8)   BASED       FOR_ATOMS
  1540 (000604)   BASED       ADVISE
  1568 (000620)   BIT(16)     EXT_ARRAY(300)
  2170 (00087A)   BIT(8)      IODEV(9)
  2180 (000884)   BIT(16)     COMMON_RETURN_CODE
  2184 (000888)   FIXED       TABLE_ADDR
  2188 (00088C)   FIXED       ADDR_FIXER
  2192 (000890)   FIXED       ADDR_FIXED_LIMIT
  2196 (000894)   FIXED       ADDR_ROUNDER
  2200 (000898)   FIXED       COMM(49)
  2400 (000960)   BASED       CSECT_LENGTHS
  2428 (00097C)   BASED       LIT_PG
  2456 (000998)   BASED       VMEMREC
  2484 (0009B4)   BASED       INIT_TAB
  2512 (0009D0)   BIT(1)      INITIAL_ON(2)
  2515 (0009D3)   BIT(1)      DATA_REMOTE
  2516 (0009D4)   BIT(1)      SEVERITY_ONE
  2517 (0009D5)   BIT(1)      NOT_DOWNGRADED
  2520 (0009D8)   FIXED       VMEM_LOC_PTR
  2524 (0009DC)   FIXED       VMEM_LOC_ADDR
  2528 (0009E0)   FIXED       VMEM_LOC_CNT
  2532 (0009E4)   FIXED       VMEM_READ_CNT
  2536 (0009E8)   FIXED       VMEM_WRITE_CNT
  2540 (0009EC)   FIXED       VMEM_RESV_CNT
  2544 (0009F0)   BIT(16)     VMEM_PRIOR_PAGE
  2546 (0009F2)   BIT(16)     VMEM_LOOK_AHEAD_PAGE
  2548 (0009F4)   BIT(16)     VMEM_MAX_PAGE
  2550 (0009F6)   BIT(16)     VMEM_LAST_PAGE
  2552 (0009F8)   BIT(16)     VMEM_OLD_NDX
  2554 (0009FA)   BIT(1)      VMEM_LOOK_AHEAD
  2555 (0009FB)   BIT(16)     VMEM_PAD_PAGE(2)
  2564 (000A04)   FIXED       VMEM_PAD_ADDR(2)
  2576 (000A10)   BIT(16)     VMEM_PAD_DISP(2)
  2584 (000A18)   FIXED       VMEM_PAD_CNT(2)
  2596 (000A24)   BIT(16)     VMEM_PAGE_TO_NDX(399)
  3396 (000D44)   BIT(16)     VMEM_PAGE_AVAIL_SPACE(399)
  4196 (001064)   BASED       userMemory
  4224 (001080)   BASED       privateMemory
  4252 (00109C)   BASED       DX
  4280 (0010B8)   BASED       COMMTABL_BYTE
  4308 (0010D4)   BASED       COMMTABL_HALFWORD
  4336 (0010F0)   BASED       COMMTABL_FULLWORD
  4364 (00110C)   BASED       DATABUF_BYTE
  4392 (001128)   BASED       DATABUF_HALFWORD
  4420 (001144)   BASED       DATABUF_FULLWORD
  4448 (001160)   BASED       VMEM_B
  4476 (00117C)   BASED       VMEM_H
  4504 (001198)   BASED       VMEM_F
  4532 (0011B4)   BASED       VARNAME_REC
  4560 (0011D0)   BASED       CELL_PTR_REC
  4588 (0011EC)   BASED       STMT_DECL_CELL
  4616 (001208)   BASED       SDF_SELECTxNODE_H
  4644 (001224)   BASED       SDF_SELECTxNODE_F
  4672 (001240)   BASED       PAGE_DUMPxWORD
  4700 (00125C)   BASED       PTR_TO_BLOCKxNODE_H
  4728 (001278)   BASED       PRINT_REPLACE_TEXTxNODE_F
  4756 (001294)   BASED       PRINT_REPLACE_TEXTxNODE_B
  4784 (0012B0)   BASED       DUMP_SDFxNODE_F
  4812 (0012CC)   BASED       DUMP_SDFxNODE_F1
  4840 (0012E8)   BASED       DUMP_SDFxNODE_B
  4868 (001304)   BASED       DUMP_SDFxNODE_B1
  4896 (001320)   BASED       DUMP_SDFxNODE_H
  4924 (00133C)   BASED       DUMP_SDFxSYM_SORT
  4952 (001358)   BASED       DUMP_SDFxDUMP_HALMATxNODE_F
  4980 (001374)   BASED       DUMP_SDFxFORMAT_NAME_TERM_CELLSxVMEM_F
  5008 (001390)   BASED       DUMP_SDFxFORMAT_NAME_TERM_CELLSxVMEM_H
  5036 (0013AC)   BASED       INITIALIZExPRO
  5064 (0013C8)   BASED       INITIALIZExCON
  5092 (0013E4)   BASED       INITIALIZExTYPE2
  5120 (001400)   BASED       INITIALIZExVALS
  5148 (00141C)   BASED       INITIALIZExMONVALS
  5176 (001438)   BASED       INITIALIZExINIT_FCB
  5204 (001454)   BASED       INITIALIZExINIT_PG
  5232 (001470)   BASED       INITIALIZExPPRO
  5260 (00148C)   FIXED       DX_SIZE
  5264 (001490)   FIXED       DESCRIPTOR_DESCRIPTOR(7)
  5296 (0014B0)   FIXED       FREESTRING_TARGET
  5300 (0014B4)   FIXED       FREESTRING_TRIGGER
  5304 (0014B8)   FIXED       FREESTRING_MIN
  5308 (0014BC)   BIT(16)     COMPACTIFIES(1)
  5312 (0014C0)   BIT(16)     REALLOCATIONS
  5314 (0014C2)   BIT(1)      _IN_COMPACTIFY
  5316 (0014C4)   FIXED       _DX_TOTAL
  5320 (0014C8)   FIXED       _PREV_DX_TOTAL
  5324 (0014CC)   FIXED       _LAST_COMPACTIFY_FOUND
  5328 (0014D0)   BIT(1)      FORCE_MAJOR
  5332 (0014D4)   FIXED       _OLDFREELIMIT
  5336 (0014D8)   BIT(1)      FREEPRINT
  5340 (0014DC)   FIXED       TMP
  5344 (0014E0)   BIT(16)     LAST_PAGE
  5348 (0014E4)   FIXED       LOC_PTR
  5352 (0014E8)   FIXED       LOC_ADDR
  5356 (0014EC)   BIT(16)     FIRST_STMT
  5358 (0014EE)   BIT(16)     LAST_STMT
  5360 (0014F0)   BIT(16)     STMT_NODES
  5362 (0014F2)   BIT(16)     STMT_NODE_SIZE
  5364 (0014F4)   BIT(16)     BASE_SYMB_PAGE
  5366 (0014F6)   BIT(16)     BASE_SYMB_OFFSET
  5368 (0014F8)   BIT(16)     BASE_STMT_PAGE
  5370 (0014FA)   BIT(16)     BASE_STMT_OFFSET
  5372 (0014FC)   BIT(16)     BASE_BLOCK_PAGE
  5374 (0014FE)   BIT(16)     BASE_BLOCK_OFFSET
  5376 (001500)   BIT(16)     pSYMBOLS
  5378 (001502)   BIT(16)     pSTMTS
  5380 (001504)   BIT(16)     pEXECS
  5382 (001506)   BIT(16)     pEXTERNALS
  5384 (001508)   BIT(16)     pPROCS
  5386 (00150A)   BIT(16)     pBIFUNCS
  5388 (00150C)   BIT(32)     BASE_BI_PTR
  5392 (001510)   BIT(16)     KEY_BLOCK
  5394 (001512)   BIT(16)     KEY_SYMB
  5396 (001514)   BIT(16)     COMPUNIT
  5400 (001518)   FIXED       EMITTED_CNT
  5404 (00151C)   FIXED       SDFPKG_LOCATES
  5408 (001520)   FIXED       SDFPKG_READS
  5412 (001524)   FIXED       SDFPKG_SLECTCNT
  5416 (001528)   FIXED       SDFPKG_FCBAREA
  5420 (00152C)   BIT(16)     SDFPKG_PGAREA
  5422 (00152E)   BIT(16)     SDFPKG_NUMGETM
  5424 (001530)   BIT(16)     pLABELS
  5426 (001532)   BIT(16)     pLHS
  5428 (001534)   BIT(1)      SRN_FLAG
  5429 (001535)   BIT(1)      ADDR_FLAG
  5430 (001536)   BIT(1)      SDL_FLAG
  5431 (001537)   BIT(1)      NEW_FLAG
  5432 (001538)   BIT(1)      COMPOOL_FLAG
  5433 (001539)   BIT(1)      HMAT_OPT
  5434 (00153A)   BIT(1)      OVERFLOW_FLAG
  5435 (00153B)   BIT(1)      SRN_FLAG1
  5436 (00153C)   BIT(1)      SRN_FLAG2
  5437 (00153D)   BIT(1)      NOTRACE_FLAG
  5438 (00153E)   BIT(1)      FC_FLAG
  5439 (00153F)   BIT(1)      FCDATA_FLAG
  5440 (001540)   BIT(1)      STAND_ALONE
  5441 (001541)   BIT(1)      TABDMP
  5442 (001542)   BIT(1)      TABLST
  5443 (001543)   BIT(1)      BRIEF
  5444 (001544)   BIT(1)      ALL
  5448 (001548)   FIXED       COMM_TAB(29)
  5568 (0015C0)   FIXED       COMMTABL_ADDR
  5572 (0015C4)   FIXED       CLOCK(2)
  5584 (0015D0)   BIT(16)     VN_INX
  5586 (0015D2)   BIT(16)     PTR_INX
  5588 (0015D4)   BIT(8)      ASIP_FLAG
  5592 (0015D8)   FIXED       VMEM_PTR_STATUS(2)
  5604 (0015E4)   BIT(8)      VMEM_FLAGS_STATUS(2)
  5607 (0015E7)   BIT(8)      MODF
  5608 (0015E8)   BIT(8)      RESV
  5609 (0015E9)   BIT(8)      RELS
  5610 (0015EA)   BIT(16)     _SPMANERRxNUMERRORS
  5612 (0015EC)   FIXED       _SPACE_ROUNDxBYTES
  5616 (0015F0)   FIXED       _ACTIVE_DESCRIPTORSxDOPE
  5620 (0015F4)   FIXED       _ACTIVE_DESCRIPTORSxDP
  5624 (0015F8)   FIXED       _ACTIVE_DESCRIPTORSxDW
  5628 (0015FC)   FIXED       _ACTIVE_DESCRIPTORSxDLAST
  5632 (001600)   FIXED       _ACTIVE_DESCRIPTORSxDND
  5636 (001604)   FIXED       _ACTIVE_DESCRIPTORSxI
  5640 (001608)   FIXED       _ACTIVE_DESCRIPTORSxJ
  5644 (00160C)   FIXED       _ACTIVE_DESCRIPTORSxANS
  5648 (001610)   FIXED       _FREEBLOCK_CHECKxUPLIM
  5652 (001614)   FIXED       _FREEBLOCK_CHECKxDOWNLIM
  5656 (001618)   FIXED       _FREEBLOCK_CHECKxFBYTES
  5660 (00161C)   FIXED       _FREEBLOCK_CHECKxRBYTES
  5664 (001620)   FIXED       _FREEBLOCK_CHECKxRDOPE
  5668 (001624)   FIXED       _FREEBLOCK_CHECKxRPNTR
  5672 (001628)   FIXED       _FREEBLOCK_CHECKxRSIZE
  5676 (00162C)   FIXED       _FREEBLOCK_CHECKxBPNTR
  5680 (001630)   FIXED       _FREEBLOCK_CHECKxBSIZE
  5684 (001634)   BIT(16)     _FREEBLOCK_CHECKxBLKNO
  5686 (001636)   BIT(16)     _FREEBLOCK_CHECKxRECNO
  5688 (001638)   FIXED       _FREEBLOCK_CHECKxADDRESS_CHECKxADDRESS
  5692 (00163C)   FIXED       _UNUSED_BYTESxCUR
  5696 (001640)   FIXED       _UNUSED_BYTESxANS
  5700 (001644)   FIXED       _MOVE_WORDSxSOURCE
  5704 (001648)   FIXED       _MOVE_WORDSxDEST
  5708 (00164C)   FIXED       _MOVE_WORDSxNUMBYTES
  5712 (001650)   FIXED       _MOVE_WORDSxI
  5716 (001654)   FIXED       _SQUASH_RECORDSxCURDOPE
  5720 (001658)   FIXED       _SQUASH_RECORDSxRECPTR
  5724 (00165C)   FIXED       _SQUASH_RECORDSxLAST_RECPTR
  5728 (001660)   FIXED       _SQUASH_RECORDSxCURBLOCK
  5732 (001664)   FIXED       _SQUASH_RECORDSxNEXTBLOCK
  5736 (001668)   FIXED       _SQUASH_RECORDSxBYTES_TO_MOVE_BY
  5740 (00166C)   FIXED       _SQUASH_RECORDSxSQUASHED
  5744 (001670)   FIXED       _SQUASH_RECORDSxRECBYTES
  5748 (001674)   FIXED       _SQUASH_RECORDSxI
  5752 (001678)   FIXED       _PREV_FREEBLOCKxBLOCK
  5756 (00167C)   FIXED       _PREV_FREEBLOCKxPREV
  5760 (001680)   FIXED       _PREV_FREEBLOCKxCUR
  5764 (001684)   FIXED       _PREV_RECORDxDOPE
  5768 (001688)   FIXED       _PREV_RECORDxPREV
  5772 (00168C)   FIXED       _PREV_RECORDxCUR
  5776 (001690)   FIXED       _ATTACH_BLOCKxBLOCK
  5780 (001694)   FIXED       _ATTACH_BLOCKxPREV
  5784 (001698)   FIXED       _ATTACH_BLOCKxCUR
  5788 (00169C)   FIXED       _ATTACH_BLOCKxJOINxB1
  5792 (0016A0)   FIXED       _ATTACH_BLOCKxJOINxB2
  5796 (0016A4)   FIXED       _ATTACH_RECORDxDOPE
  5800 (0016A8)   FIXED       _ATTACH_RECORDxPREV
  5804 (0016AC)   FIXED       _ATTACH_RECORDxCUR
  5808 (0016B0)   FIXED       _ATTACH_RECORDxLOC
  5812 (0016B4)   FIXED       _DETACH_RECORDxDOPE
  5816 (0016B8)   FIXED       _DETACH_RECORDxPREV
  5820 (0016BC)   FIXED       _REDUCE_BLOCKxBLOCK
  5824 (0016C0)   FIXED       _REDUCE_BLOCKxREMBYTES
  5828 (0016C4)   BIT(1)      _REDUCE_BLOCKxTOP
  5832 (0016C8)   FIXED       _REDUCE_BLOCKxPREV
  5836 (0016CC)   FIXED       _REDUCE_BLOCKxOLDNBYTES
  5840 (0016D0)   FIXED       _REDUCE_BLOCKxNEWBLOCK
  5844 (0016D4)   FIXED       _RETURN_TO_FREESTRINGxNBYTES
  5848 (0016D8)   FIXED       _RECORD_FREExDOPE
  5852 (0016DC)   FIXED       _RECORD_FREExSIZE
  5856 (0016E0)   FIXED       _RECORD_FREExPREV
  5860 (0016E4)   FIXED       _RECORD_FREExNEWBLOCK
  5864 (0016E8)   FIXED       _RETURN_UNUSEDxDOPE
  5868 (0016EC)   FIXED       _RETURN_UNUSEDxNRECS
  5872 (0016F0)   FIXED       _RETURN_UNUSEDxNEWBLOCK
  5876 (0016F4)   FIXED       _RETURN_UNUSEDxOLDNBYTES
  5880 (0016F8)   FIXED       _RETURN_UNUSEDxNEWNBYTES
  5884 (0016FC)   FIXED       _RETURN_UNUSEDxDIF
  5888 (001700)   FIXED       _TAKE_BACKxNBYTES
  5892 (001704)   FIXED       _TAKE_BACKxCUR
  5896 (001708)   FIXED       _TAKE_BACKxRET_RECS
  5900 (00170C)   FIXED       _TAKE_BACKxDIF_RECS
  5904 (001710)   FIXED       _TAKE_BACKxPOSSIBLE
  5908 (001714)   FIXED       _TAKE_BACKxLEFTBYTES
  5912 (001718)   FIXED       _TAKE_BACKxPREV_FREEBYTES
  5916 (00171C)   BIT(1)      _TAKE_BACKxPREV_FREEPRINT
  5920 (001720)   FIXED       COMPACTIFYxI
  5924 (001724)   FIXED       COMPACTIFYxJ
  5928 (001728)   FIXED       COMPACTIFYxK
  5932 (00172C)   FIXED       COMPACTIFYxL
  5936 (001730)   FIXED       COMPACTIFYxND
  5940 (001734)   FIXED       COMPACTIFYxTC
  5944 (001738)   FIXED       COMPACTIFYxBC
  5948 (00173C)   FIXED       COMPACTIFYxDELTA
  5952 (001740)   FIXED       COMPACTIFYxMODE
  5956 (001744)   FIXED       COMPACTIFYxACTUAL_DX_TOTAL
  5960 (001748)   FIXED       COMPACTIFYxMASK
  5964 (00174C)   FIXED       COMPACTIFYxLOWER_BOUND
  5968 (001750)   FIXED       COMPACTIFYxUPPER_BOUND
  5972 (001754)   BIT(1)      COMPACTIFYxTRIED
  5976 (001758)   FIXED       COMPACTIFYxDP
  5980 (00175C)   FIXED       COMPACTIFYxDW
  5984 (001760)   FIXED       COMPACTIFYxADD_DESCxI
  5988 (001764)   FIXED       COMPACTIFYxADD_DESCxL
  5992 (001768)   FIXED       _STEALxNBYTES
  5996 (00176C)   FIXED       _STEALxBLOCKLOC
  6000 (001770)   FIXED       _MOVE_RECSxDOPE
  6004 (001774)   FIXED       _MOVE_RECSxBYTES_TO_MOVE_BY
  6008 (001778)   FIXED       _MOVE_RECSxNBYTES
  6012 (00177C)   FIXED       _MOVE_RECSxSOURCE
  6016 (001780)   FIXED       _MOVE_RECSxCURDOPE
  6020 (001784)   FIXED       _FIND_FREExNBYTES
  6024 (001788)   BIT(1)      _FIND_FREExUNMOVEABLE
  6025 (001789)   BIT(16)     _FIND_FREExI
  6028 (00178C)   FIXED       _FIND_FREExCURBLOCK
  6032 (001790)   FIXED       _FIND_FREExDOPE
  6036 (001794)   FIXED       _INCREASE_RECORDxDOPE
  6040 (001798)   FIXED       _INCREASE_RECORDxNRECSMORE
  6044 (00179C)   FIXED       _INCREASE_RECORDxOLDNRECS
  6048 (0017A0)   FIXED       _INCREASE_RECORDxOLDNBYTES
  6052 (0017A4)   FIXED       _INCREASE_RECORDxNEWNRECS
  6056 (0017A8)   FIXED       _INCREASE_RECORDxNEWNBYTES
  6060 (0017AC)   FIXED       _INCREASE_RECORDxNBYTESMORE
  6064 (0017B0)   FIXED       _INCREASE_RECORDxI
  6068 (0017B4)   FIXED       _GET_SPACExNBYTES
  6072 (0017B8)   BIT(1)      _GET_SPACExUNMOVEABLE
  6076 (0017BC)   FIXED       _GET_SPACExFREEB
  6080 (0017C0)   FIXED       _GET_SPACExNEWREC
  6084 (0017C4)   FIXED       _GET_SPACExI
  6088 (0017C8)   FIXED       _HOW_MUCHxDOPE
  6092 (0017CC)   FIXED       _HOW_MUCHxANS
  6096 (0017D0)   FIXED       _HOW_MUCHxANSBYTES
  6100 (0017D4)   FIXED       _HOW_MUCHxNSTRBYTES
  6104 (0017D8)   FIXED       _HOW_MUCHxANSMIN
  6108 (0017DC)   FIXED       _ALLOCATE_SPACExDOPE
  6112 (0017E0)   FIXED       _ALLOCATE_SPACExHIREC
  6116 (0017E4)   FIXED       _ALLOCATE_SPACExNREC
  6120 (0017E8)   FIXED       _ALLOCATE_SPACExOREC
  6124 (0017EC)   FIXED       _RECORD_CONSTANTxDOPE
  6128 (0017F0)   FIXED       _RECORD_CONSTANTxHIREC
  6132 (0017F4)   BIT(1)      _RECORD_CONSTANTxMOVEABLE
  6136 (0017F8)   FIXED       _NEEDMORE_SPACExDOPE
  6140 (0017FC)   FIXED       RECORD_LINKxCUR
  6144 (001800)   BIT(16)     PADxMAX
  6146 (001802)   BIT(16)     PADxL
  6148 (001804)   FIXED       LEFT_PADxWIDTH
  6152 (001808)   FIXED       LEFT_PADxL
  6156 (00180C)   FIXED       FORMATxI
  6160 (001810)   FIXED       FORMATxJ
  6164 (001814)   FIXED       FORMATxIVAL
  6168 (001818)   FIXED       FORMATxN
  6172 (00181C)   FIXED       HEXxHVAL
  6176 (001820)   FIXED       HEXxN
  6180 (001824)   FIXED       HEX8xHVAL
  6184 (001828)   FIXED       HEX8xI
  6188 (00182C)   FIXED       HEX6xHVAL
  6192 (001830)   FIXED       HEX6xI
  6196 (001834)   FIXED       CHARTIMExT
  6200 (001838)   FIXED       CHARDATExD
  6204 (00183C)   FIXED       CHARDATExYEAR
  6208 (001840)   FIXED       CHARDATExDAY
  6212 (001844)   FIXED       CHARDATExM
  6216 (001848)   FIXED       CHARDATExDAYS(12)
  6268 (00187C)   FIXED       PRINT_TIMExT
  6272 (001880)   FIXED       PRINT_DATE_AND_TIMExD
  6276 (001884)   FIXED       PRINT_DATE_AND_TIMExT
  6280 (001888)   FIXED       MOVExFROM
  6284 (00188C)   FIXED       MOVExINTO
  6288 (001890)   FIXED       MOVExADDRTEMP
  6292 (001894)   BIT(16)     MOVExLEGNTH
  6296 (001898)   FIXED       STMT_TO_PTRxOFFSET
  6300 (00189C)   BIT(16)     STMT_TO_PTRxSTMT
  6302 (00189E)   BIT(16)     STMT_TO_PTRxPAGE
  6304 (0018A0)   FIXED       SYMB_TO_PTRxOFFSET
  6308 (0018A4)   BIT(16)     SYMB_TO_PTRxSYMB
  6310 (0018A6)   BIT(16)     SYMB_TO_PTRxPAGE
  6312 (0018A8)   FIXED       BLOCK_TO_PTRxOFFSET
  6316 (0018AC)   BIT(16)     BLOCK_TO_PTRxBLOCK
  6318 (0018AE)   BIT(16)     BLOCK_TO_PTRxPAGE
  6320 (0018B0)   BIT(16)     SDF_SELECTxTEMP
  6324 (0018B4)   FIXED       SDF_PTR_LOCATExPTR
  6328 (0018B8)   FIXED       SDF_PTR_LOCATExARG
  6332 (0018BC)   BIT(8)      SDF_PTR_LOCATExFLAGS
  6336 (0018C0)   FIXED       SDF_LOCATExPTR
  6340 (0018C4)   FIXED       SDF_LOCATExBVAR
  6344 (0018C8)   BIT(8)      SDF_LOCATExFLAGS
  6345 (0018C9)   BIT(16)     PAGE_DUMPxPAGE
  6347 (0018CB)   BIT(16)     PAGE_DUMPxJ
  6349 (0018CD)   BIT(16)     PAGE_DUMPxJJ
  6351 (0018CF)   BIT(16)     PAGE_DUMPxII
  6353 (0018D1)   BIT(16)     PAGE_DUMPxIII
  6355 (0018D3)   BIT(1)      PAGE_DUMPxSTILL_ZERO
  6356 (0018D4)   BIT(16)     BLOCK_NAMExBLKp
  6358 (0018D6)   BIT(16)     SYMBOL_NAMExSYMBp
  6360 (0018D8)   FIXED       PTR_TO_BLOCKxPTR
  6364 (0018DC)   FIXED       PRINT_REPLACE_TEXTxTEXT_PTR
  6368 (0018E0)   FIXED       PRINT_REPLACE_TEXTxpBYTES
  6372 (0018E4)   BIT(8)      PRINT_REPLACE_TEXTxWAS_HERE
  6373 (0018E5)   BIT(8)      PRINT_REPLACE_TEXTxJ
  6374 (0018E6)   BIT(16)     PRINT_REPLACE_TEXTxpARGS
  6376 (0018E8)   BIT(16)     PRINT_REPLACE_TEXTxCELL_SIZE
  6378 (0018EA)   BIT(16)     PRINT_REPLACE_TEXTxM_PTR
  6380 (0018EC)   BIT(16)     PRINT_REPLACE_TEXTxM_CHAR_PTR
  6384 (0018F0)   FIXED       DUMP_SDFxFLAG
  6388 (0018F4)   FIXED       DUMP_SDFxSADDR
  6392 (0018F8)   FIXED       DUMP_SDFxSEXTENT
  6396 (0018FC)   FIXED       DUMP_SDFxPTR
  6400 (001900)   FIXED       DUMP_SDFxPTR1
  6404 (001904)   FIXED       DUMP_SDFxADDR1
  6408 (001908)   FIXED       DUMP_SDFxADDR2
  6412 (00190C)   FIXED       DUMP_SDFxTEMP
  6416 (001910)   FIXED       DUMP_SDFxHMAT_PTR
  6420 (001914)   FIXED       DUMP_SDFxSOFFSET
  6424 (001918)   FIXED       DUMP_SDFxINCLUDE_PTR
  6428 (00191C)   BIT(16)     DUMP_SDFxI
  6430 (00191E)   BIT(16)     DUMP_SDFxJ
  6432 (001920)   BIT(16)     DUMP_SDFxJ1
  6434 (001922)   BIT(16)     DUMP_SDFxJ2
  6436 (001924)   BIT(16)     DUMP_SDFxK
  6438 (001926)   BIT(16)     DUMP_SDFxK1
  6440 (001928)   BIT(16)     DUMP_SDFxK2
  6442 (00192A)   BIT(16)     DUMP_SDFxL
  6444 (00192C)   BIT(16)     DUMP_SDFxKLIM
  6446 (00192E)   BIT(16)     DUMP_SDFxITEM
  6448 (001930)   BIT(16)     DUMP_SDFxLAST_BLOCK
  6450 (001932)   BIT(16)     DUMP_SDFxSBLK
  6452 (001934)   BIT(16)     DUMP_SDFxpCHARS
  6454 (001936)   BIT(16)     DUMP_SDFxpXREF
  6456 (001938)   BIT(16)     DUMP_SDFxTEMP1
  6458 (00193A)   BIT(16)     DUMP_SDFxTEMP2
  6460 (00193C)   BIT(16)     DUMP_SDFxTEMP3
  6462 (00193E)   BIT(16)     DUMP_SDFxTEMP4
  6464 (001940)   BIT(8)      DUMP_SDFxSCLASS
  6465 (001941)   BIT(8)      DUMP_SDFxpBITS
  6466 (001942)   BIT(8)      DUMP_SDFxSHIFT
  6467 (001943)   BIT(8)      DUMP_SDFxSFLAG
  6468 (001944)   BIT(8)      DUMP_SDFxSTYPE
  6469 (001945)   BIT(8)      DUMP_SDFxNAME_FLAG
  6470 (001946)   BIT(8)      DUMP_SDFxSRNS
  6471 (001947)   BIT(8)      DUMP_SDFxCONST_FLAG
  6472 (001948)   BIT(8)      DUMP_SDFxDOUBLE_FLAG
  6473 (001949)   BIT(8)      DUMP_SDFxLIT_FLAG
  6474 (00194A)   BIT(8)      DUMP_SDFxLIT_TYPE
  6475 (00194B)   BIT(8)      DUMP_SDFxT(37)
  6513 (001971)   BIT(8)      DUMP_SDFxSUBTYPE
  6514 (001972)   BIT(16)     DUMP_SDFxMAX_ARRAY
  6516 (001974)   FIXED       DUMP_SDFxSYM_DATA_CELL_ADDR
  6520 (001978)   FIXED       DUMP_SDFxINSERT_SORTxOFF
  6524 (00197C)   BIT(16)     DUMP_SDFxINSERT_SORTxSIZE
  6526 (00197E)   BIT(16)     DUMP_SDFxINSERT_SORTxSYM
  6528 (001980)   BIT(16)     DUMP_SDFxINSERT_SORTxI
  6530 (001982)   BIT(1)      DUMP_SDFxPRINT_pD_INFOxINFO_FLAG
  6531 (001983)   BIT(16)     DUMP_SDFxPRINT_pD_INFOxCLASS
  6533 (001985)   BIT(16)     DUMP_SDFxPRINT_pD_INFOxTYPE
  6536 (001988)   FIXED       DUMP_SDFxPRINT_pD_INFOxIJ
  6540 (00198C)   BIT(32)     DUMP_SDFxPRINT_pD_INFOxSIZE
  6544 (001990)   BIT(32)     DUMP_SDFxPRINT_pD_INFOxFLAGS
  6548 (001994)   FIXED       DUMP_SDFxPRINT_pD_INFOxOLD_OFFSET
  6552 (001998)   FIXED       DUMP_SDFxINTEGERIZABLExFLT_NEGMAX
  6556 (00199C)   FIXED       DUMP_SDFxINTEGERIZABLExNEGMAX
  6560 (0019A0)   BIT(8)      DUMP_SDFxINTEGERIZABLExNEGLIT
  6564 (0019A4)   FIXED       DUMP_SDFxINTEGERIZABLExTEMP
  6568 (0019A8)   FIXED       DUMP_SDFxINTEGERIZABLExTEMP1
  6572 (0019AC)   BIT(16)     DUMP_SDFxFLUSHxLAST
  6574 (0019AE)   BIT(16)     DUMP_SDFxFLUSHxI
  6576 (0019B0)   BIT(16)     DUMP_SDFxFLUSHxJ
  6578 (0019B2)   BIT(16)     DUMP_SDFxFLUSHxK
  6580 (0019B4)   BIT(16)     DUMP_SDFxFLUSHxSTMT_VARS
  6584 (0019B8)   FIXED       DUMP_SDFxSTACK_PTRxPTR
  6588 (0019BC)   BIT(16)     DUMP_SDFxFORMAT_FORM_PARM_CELLxJ
  6590 (0019BE)   BIT(16)     DUMP_SDFxFORMAT_FORM_PARM_CELLxK
  6592 (0019C0)   BIT(16)     DUMP_SDFxFORMAT_FORM_PARM_CELLxSYMBp
  6596 (0019C4)   FIXED       DUMP_SDFxFORMAT_FORM_PARM_CELLxPTR
  6600 (0019C8)   BIT(16)     DUMP_SDFxFORMAT_VAR_REF_CELLxpSYTS
  6602 (0019CA)   BIT(16)     DUMP_SDFxFORMAT_VAR_REF_CELLxJ
  6604 (0019CC)   BIT(16)     DUMP_SDFxFORMAT_VAR_REF_CELLxLAST_SUB_TYPE
  6608 (0019D0)   FIXED       DUMP_SDFxFORMAT_VAR_REF_CELLxPTR
  6612 (0019D4)   BIT(8)      DUMP_SDFxFORMAT_VAR_REF_CELLxNO_PRINT
  6613 (0019D5)   BIT(8)      DUMP_SDFxFORMAT_VAR_REF_CELLxSUBSCRIPTS
  6614 (0019D6)   BIT(8)      DUMP_SDFxFORMAT_VAR_REF_CELLxALPHA
  6615 (0019D7)   BIT(8)      DUMP_SDFxFORMAT_VAR_REF_CELLxSUB_TYPE
  6616 (0019D8)   BIT(8)      DUMP_SDFxFORMAT_VAR_REF_CELLxBETA
  6617 (0019D9)   BIT(8)      DUMP_SDFxFORMAT_VAR_REF_CELLxEXP_TYPE
  6618 (0019DA)   BIT(16)     DUMP_SDFxFORMAT_EXP_VARS_CELLxI
  6620 (0019DC)   BIT(16)     DUMP_SDFxFORMAT_EXP_VARS_CELLxJ
  6622 (0019DE)   BIT(16)     DUMP_SDFxFORMAT_EXP_VARS_CELLxK
  6624 (0019E0)   BIT(16)     DUMP_SDFxFORMAT_EXP_VARS_CELLxM
  6626 (0019E2)   BIT(16)     DUMP_SDFxFORMAT_EXP_VARS_CELLxpSYTS
  6628 (0019E4)   BIT(16)     DUMP_SDFxFORMAT_EXP_VARS_CELLxOUTER
  6632 (0019E8)   FIXED       DUMP_SDFxFORMAT_EXP_VARS_CELLxPTR
  6636 (0019EC)   FIXED       DUMP_SDFxDUMP_HALMATxPTR
  6640 (0019F0)   FIXED       DUMP_SDFxDUMP_HALMATxHPTR
  6644 (0019F4)   FIXED       DUMP_SDFxDUMP_HALMATxTEMP
  6648 (0019F8)   BIT(16)     DUMP_SDFxDUMP_HALMATxI
  6650 (0019FA)   BIT(16)     DUMP_SDFxDUMP_HALMATxpWORDS
  6652 (0019FC)   BIT(16)     DUMP_SDFxDUMP_HALMATxHCELL
  6656 (001A00)   FIXED       DUMP_SDFxDUMP_HALMATxFORMAT_HMATxATOM
  6660 (001A04)   BIT(16)     DUMP_SDFxDUMP_HALMATxFORMAT_HMATxPROD
  6662 (001A06)   BIT(16)     DUMP_SDFxDUMP_HALMATxFORMAT_HMATxICNT
  6664 (001A08)   BIT(16)     DUMP_SDFxDUMP_HALMATxFORMAT_HMATxJ
  6666 (001A0A)   BIT(16)     DUMP_SDFxFORMAT_PF_INV_CELLxpASSIGN
  6668 (001A0C)   BIT(16)     DUMP_SDFxFORMAT_PF_INV_CELLxJ
  6670 (001A0E)   BIT(16)     DUMP_SDFxFORMAT_PF_INV_CELLxK
  6672 (001A10)   BIT(16)     DUMP_SDFxFORMAT_PF_INV_CELLxSYMB
  6676 (001A14)   FIXED       DUMP_SDFxFORMAT_PF_INV_CELLxPTR
  6680 (001A18)   BIT(8)      DUMP_SDFxFORMAT_CELL_TREExPTR_TYPE
  6681 (001A19)   BIT(8)      DUMP_SDFxFORMAT_CELL_TREExOUTER
  6682 (001A1A)   BIT(8)      DUMP_SDFxFORMAT_CELL_TREExSTMT_VARS
  6684 (001A1C)   FIXED       DUMP_SDFxFORMAT_CELL_TREExPTR
  6688 (001A20)   BIT(16)     DUMP_SDFxFORMAT_NAME_TERM_CELLSxpSYTS
  6690 (001A22)   BIT(16)     DUMP_SDFxFORMAT_NAME_TERM_CELLSxSYMBp
  6692 (001A24)   BIT(16)     DUMP_SDFxFORMAT_NAME_TERM_CELLSxJ
  6694 (001A26)   BIT(16)     DUMP_SDFxFORMAT_NAME_TERM_CELLSxK
  6696 (001A28)   BIT(16)     DUMP_SDFxFORMAT_NAME_TERM_CELLSxWORDTYPE
  6698 (001A2A)   BIT(16)     DUMP_SDFxFORMAT_NAME_TERM_CELLSxFIRSTWORD
  6700 (001A2C)   FIXED       DUMP_SDFxFORMAT_NAME_TERM_CELLSxNEXT_CELL
  6704 (001A30)   FIXED       DUMP_SDFxFORMAT_NAME_TERM_CELLSxPTR
  6708 (001A34)   FIXED       DUMP_SDFxFORMAT_NAME_TERM_CELLSxPTR_TEMP
  6712 (001A38)   BIT(16)     DUMP_SDFxPRINT_XREF_DATAxK
  6716 (001A3C)   FIXED       INITIALIZExJ
  6720 (001A40)   FIXED       SDF_PROCESSINGxRECORD_ADDR
  6724 (001A44)   BIT(16)     SDF_PROCESSINGxOFFSET
  6726 (001A46)   BIT(16)     SDF_PROCESSINGxMAX_OFFSET
  6728 (001A48)   FIXED       SDF_PROCESSINGxALIGNED_BUFFER(63)
  6984 (001B48)   FIXED       SDF_PROCESSINGxFFBUFF(1)
  6992 (001B50)   FIXED       PRINTSUMMARYxT
  6996 (001B54)   BIT(16)     PRINTSUMMARYxI
  6998 (001B56)   CHARACTER   COLON
  7002 (001B5A)   CHARACTER   DOUBLE
  7006 (001B5E)   CHARACTER   HEXCODES
  7010 (001B62)   CHARACTER   ASTS
  7014 (001B66)   CHARACTER   SDFLIST_ERR
  7018 (001B6A)   CHARACTER   X1
  7022 (001B6E)   CHARACTER   X2
  7026 (001B72)   CHARACTER   X3
  7030 (001B76)   CHARACTER   X4
  7034 (001B7A)   CHARACTER   X5
  7038 (001B7E)   CHARACTER   X6
  7042 (001B82)   CHARACTER   X7
  7046 (001B86)   CHARACTER   X10
  7050 (001B8A)   CHARACTER   X15
  7054 (001B8E)   CHARACTER   X20
  7058 (001B92)   CHARACTER   X28
  7062 (001B96)   CHARACTER   X30
  7066 (001B9A)   CHARACTER   X52
  7070 (001B9E)   CHARACTER   X60
  7074 (001BA2)   CHARACTER   X72
  7078 (001BA6)   CHARACTER   STMT_TYPES(36)
  7226 (001C3A)   CHARACTER   STMT_FLAGS(4)
  7246 (001C4E)   CHARACTER   SYMBOL_CLASSES(6)
  7274 (001C6A)   CHARACTER   SYMBOL_TYPES(17)
  7346 (001CB2)   CHARACTER   PROC_TYPES(9)
  7386 (001CDA)   CHARACTER   TITLE
  7390 (001CDE)   CHARACTER   SDF_NAME
  7394 (001CE2)   CHARACTER   PRINTLINE
  7398 (001CE6)   CHARACTER   S(40)
  7562 (001D8A)   CHARACTER   BI_NAME(63)
  7818 (001E8A)   CHARACTER   _SPMANERRxMSG
  7822 (001E8E)   CHARACTER   EMIT_OUTPUTxSTRING
  7826 (001E92)   CHARACTER   PADxSTRING
  7830 (001E96)   CHARACTER   LEFT_PADxSTRING
  7834 (001E9A)   CHARACTER   FORMATxSTRING1
  7838 (001E9E)   CHARACTER   FORMATxSTRING2
  7842 (001EA2)   CHARACTER   FORMATxCHAR
  7846 (001EA6)   CHARACTER   HEXxSTRING
  7850 (001EAA)   CHARACTER   HEXxZEROS
  7854 (001EAE)   CHARACTER   HEX8xT
  7858 (001EB2)   CHARACTER   HEX6xT
  7862 (001EB6)   CHARACTER   CHARTIMExC
  7866 (001EBA)   CHARACTER   CHARDATExMONTH(11)
  7914 (001EEA)   CHARACTER   PRINT_TIMExMESSAGE
  7918 (001EEE)   CHARACTER   PRINT_TIMExC
  7922 (001EF2)   CHARACTER   PRINT_DATE_AND_TIMExMESSAGE
  7926 (001EF6)   CHARACTER   PRINT_DATE_AND_TIMExC
  7930 (001EFA)   CHARACTER   PAGE_DUMPxTS(12)
  7982 (001F2E)   CHARACTER   BLOCK_NAMExBNAME
  7986 (001F32)   CHARACTER   SYMBOL_NAMExSNAME
  7990 (001F36)   CHARACTER   PRINT_REPLACE_TEXTxS1
  7994 (001F3A)   CHARACTER   PRINT_REPLACE_TEXTxS2
  7998 (001F3E)   CHARACTER   PRINT_REPLACE_TEXTxBUILD_M
  8002 (001F42)   CHARACTER   PRINT_REPLACE_TEXTxS(1)
  8010 (001F4A)   CHARACTER   DUMP_SDFxSUB_STMT_TYPES(10)
  8054 (001F76)   CHARACTER   DUMP_SDFxTS(10)
  8098 (001FA2)   CHARACTER   DUMP_SDFxSRN_STRING
  8102 (001FA6)   CHARACTER   DUMP_SDFxINCL_STRING
  8106 (001FAA)   CHARACTER   DUMP_SDFxADDR1_HEX
  8110 (001FAE)   CHARACTER   DUMP_SDFxADDR2_HEX
  8114 (001FB2)   CHARACTER   DUMP_SDFxADDR3_HEX
  8118 (001FB6)   CHARACTER   DUMP_SDFxSDF_TITLE
  8122 (001FBA)   CHARACTER   DUMP_SDFxINCL_FILES(5)
  8146 (001FD2)   CHARACTER   DUMP_SDFxNAME
  8150 (001FD6)   CHARACTER   DUMP_SDFxADDR1_DEC
  8154 (001FDA)   CHARACTER   DUMP_SDFxADDR2_DEC
  8158 (001FDE)   CHARACTER   DUMP_SDFxADDR3_DEC
  8162 (001FE2)   CHARACTER   DUMP_SDFxCHAR_STRING
  8166 (001FE6)   CHARACTER   DUMP_SDFxPRINT_pD_INFOxTMPC
  8170 (001FEA)   CHARACTER   DUMP_SDFxFLUSHxSTRING
  8174 (001FEE)   CHARACTER   DUMP_SDFxFLUSHxX13
  8178 (001FF2)   CHARACTER   DUMP_SDFxSTACK_STRINGxSTRING
  8182 (001FF6)   CHARACTER   DUMP_SDFxFORMAT_VAR_REF_CELLxSUB_STRINGS(2)
  8194 (002002)   CHARACTER   DUMP_SDFxFORMAT_VAR_REF_CELLxEXP_STRINGS(4)
  8214 (002016)   CHARACTER   DUMP_SDFxFORMAT_VAR_REF_CELLxMSG(4)
  8234 (00202A)   CHARACTER   DUMP_SDFxFORMAT_EXP_VARS_CELLxSTRING
  8238 (00202E)   CHARACTER   DUMP_SDFxDUMP_HALMATxFORMAT_HMATxC
  8242 (002032)   CHARACTER   DUMP_SDFxDUMP_HALMATxFORMAT_HMATxBLAB1
  8246 (002036)   CHARACTER   DUMP_SDFxDUMP_HALMATxFORMAT_HMATxBLAB2
  8250 (00203A)   CHARACTER   DUMP_SDFxFORMAT_NAME_TERM_CELLSxTEMPNAME
  8254 (00203E)   CHARACTER   INITIALIZExC
  8258 (002042)   CHARACTER   INITIALIZExS
  8262 (002046)   CHARACTER   INITIALIZExPARM_TEXT
  8266 (00204A)   CHARACTER   SDF_PROCESSINGxFFSTRING
  8270 (00204E)   CHARACTER   SDF_PROCESSINGxBUFFER
  8274 (002052)   EBCDIC      COLON
  8275 (002053)   EBCDIC      DOUBLE
  8276 (002054)   EBCDIC      HEXCODES
  8292 (002064)   EBCDIC      ASTS
  8312 (002078)   EBCDIC      SDFLIST_ERR
  8340 (002094)   EBCDIC      X1
  8341 (002095)   EBCDIC      X2
  8343 (002097)   EBCDIC      X3
  8346 (00209A)   EBCDIC      X4
  8350 (00209E)   EBCDIC      X5
  8355 (0020A3)   EBCDIC      X6
  8361 (0020A9)   EBCDIC      X7
  8368 (0020B0)   EBCDIC      X10
  8378 (0020BA)   EBCDIC      X15
  8393 (0020C9)   EBCDIC      X20
  8413 (0020DD)   EBCDIC      X28
  8441 (0020F9)   EBCDIC      X30
  8471 (002117)   EBCDIC      X52
  8523 (00214B)   EBCDIC      X60
  8583 (002187)   EBCDIC      X72
  8655 (0021CF)   EBCDIC      STMT_TYPES(36)
  8921 (0022D9)   EBCDIC      STMT_FLAGS(4)
  8945 (0022F1)   EBCDIC      SYMBOL_CLASSES(6)
  9029 (002345)   EBCDIC      SYMBOL_TYPES(17)
  9197 (0023ED)   EBCDIC      PROC_TYPES(9)
  9305 (002459)   EBCDIC      BI_NAME(63)
  9627 (00259B)   EBCDIC      HEXxZEROS
  9635 (0025A3)   EBCDIC      CHARDATExMONTH(11)
  9709 (0025ED)   EBCDIC      PRINT_REPLACE_TEXTxS(1)
  9710 (0025EE)   EBCDIC      DUMP_SDFxSUB_STMT_TYPES(10)
  9779 (002633)   EBCDIC      DUMP_SDFxINCL_FILES(5)
  9815 (002657)   EBCDIC      DUMP_SDFxFLUSHxX13
  9828 (002664)   EBCDIC      DUMP_SDFxFORMAT_VAR_REF_CELLxSUB_STRINGS(2)
  9830 (002666)   EBCDIC      DUMP_SDFxFORMAT_VAR_REF_CELLxEXP_STRINGS(4)
  9835 (00266B)   EBCDIC      DUMP_SDFxDUMP_HALMATxFORMAT_HMATxBLAB1
  9842 (002672)   EBCDIC      DUMP_SDFxDUMP_HALMATxFORMAT_HMATxBLAB2
*/
// clang-format on

int
main (int argc, char *argv[])
{

  // Setup for MONITOR(6), MONITOR(7), MONITOR(21).  Initially,
  // entire physical memory is a single pre-allocated block.
  MONITOR6a (USER_MEMORY, PHYSICAL_MEMORY_LIMIT, 0);
  MONITOR6a (PRIVATE_MEMORY, PRIVATE_MEMORY_SIZE, 0);

  if (parseCommandLine (argc, argv))
    exit (0);

  static int reentryGuard = 0;
  reentryGuard = guardReentry (reentryGuard, "main");
  int setjmpInitialize = 1;
  if (setjmpInitialize)
    {
      goto BAIL_OUT;
    setjmpInitialized:
      setjmpInitialize = 0;
    }
// MAIN_PROGRAM: (0)
MAIN_PROGRAM:
  // CLOCK = MONITOR(18); (1)
  {
    int32_t numberRHS = (int32_t)(MONITOR18 ());
    putFIXED (mCLOCK, numberRHS);
  }
  // CALL INITIALIZE; (2)
  INITIALIZE (0);
  // CLOCK(1) = MONITOR(18); (3)
  {
    int32_t numberRHS = (int32_t)(MONITOR18 ());
    putFIXED (mCLOCK + 4 * (1), numberRHS);
  }
  // CALL SDF_PROCESSING; (4)
  SDF_PROCESSING (0);
  // CLOCK(2) = MONITOR(18); (5)
  {
    int32_t numberRHS = (int32_t)(MONITOR18 ());
    putFIXED (mCLOCK + 4 * (2), numberRHS);
  }
  // IF STAND_ALONE THEN (6)
  if (1 & (bitToFixed (getBIT (1, mSTAND_ALONE))))
    // CALL PRINTSUMMARY; (7)
    PRINTSUMMARY (0);
  // RETURN COMMON_RETURN_CODE; (8)
  {
    RECORD_LINK (0);
  }
// NO_CORE: (9)
NO_CORE:
  // OUTPUT = X1; (10)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mX1);
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = '*** INSUFFICIENT CORE MEMORY -- INCREASE REGION SIZE ***'; (11)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (
        NULL, "*** INSUFFICIENT CORE MEMORY -- INCREASE REGION SIZE ***");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // BAIL_OUT: (12)
  if (0)
    {
    BAIL_OUT:
      if (setjmpInitialize)
        {
          if (!setjmp (jbBAIL_OUT))
            goto setjmpInitialized;
        }
    }
  // OUTPUT = X1; (13)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mX1);
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'S D F L I S T   P R O C E S S I N G   A B A N D O N E D'; (14)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (
        NULL, "S D F L I S T   P R O C E S S I N G   A B A N D O N E D");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = X1; (15)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mX1);
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // RETURN 16; (16)
  {
    RECORD_LINK (0);
  }

  RECORD_LINK (0);
  {
    reentryGuard = 0;
    return 0;
  } // Just in case ...
}
