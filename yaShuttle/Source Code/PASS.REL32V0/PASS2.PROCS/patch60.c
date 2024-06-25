/* inlines=8,4
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch60.c
 * Purpose:     C-language patches for CALL INLINEs in OBJECT_GENERATOR
 *              module of HAL/S-FC PASS2.
 *              BFS only:  INLINEs TBD.
 *              PFS only:  INLINEs #60-67 in `EMIT_SYM` of `EMIT_SYM_CARDS`
 * History:     2024-06-17 RSB  Created.
 */

#ifdef BFS
/*
 * Here's my analysis of the IBM 360 machine code being replaced by C:
 *
 * CALL INLINE("58", 1, 0, FROM_ADDR);       Load value of `FROM_ADDR` into GR1.
 * CALL INLINE("58", 2, 0, TO_ADDR);         Load value of `TO_ADDR` into GR2.
 * CALL INLINE("48", 3, 0, BYTE_COUNT);      Load 1 + value of `BYTE_COUNT` (a
 *                                           halfword) into GR3.  Note that
 *                                           `BYTE_COUNT` has been
 *                                           pre-decremented by 1.
 * CALL INLINE("44", 3, 0, MVC_INSTRUCTION); This is an EX instruction, which
 *                                           a fancy way of executing
 *                                           self-modifying code while neither
 *                                           changing the memory at which the
 *                                           instruction to be executed is
 *                                           stored, nor branching to the
 *                                           instruction.  The instruction to
 *                                           be modified and executed in this
 *                                           case is a MVC instruction, and this
 *                                           closely follows the example found
 *                                           on p. A-21 of the IBM "Enterprise
 *                                           Systems Architecture/390 Principles
 *                                           of Operation" document.
 *
 * The net result of all that stuff simply seems to be moving `BYTE_COUNT`+1
 * bytes from `FROM_ADDR` to `TO_ADDR`.
 */

uint32_t FROM_ADDR = getFIXED(mOBJECT_GENERATORxMOVE_CHARSxFROM_ADDR);
uint32_t TO_ADDR   = getFIXED(mOBJECT_GENERATORxMOVE_CHARSxTO_ADDR);
uint32_t length    = 1 + COREHALFWORD(mOBJECT_GENERATORxMOVE_CHARSxBYTE_COUNT);
memmove(&memory[TO_ADDR], &memory[FROM_ADDR], length);

#endif // BFS

#ifdef PFS
/*
 * Here's my analysis of the IBM 360 machine code being replaced by C:
 *
 * CALL INLINE("58", 1, 0, TEMP);  Load contents of `TEMP` into GR1.  Note
 *                                 that `TEMP` contains an address.
 * CALL INLINE("58", 2, 0, NAME);  Load contents of `NAME` into GR2.
 * CALL INLINE("1B", 3, 3);        Subtract GR3 from GR3 ... i.e., load 0.
 * CALL INLINE("43", 3, 0, NAME);  Note that the contents of `NAME` is a
 *                                 string descriptor.  This instruction will
 *                                 Take the L-1 field of the descriptor and
 *                                 overwrite bits 31-23 of GR3.
 * CALL INLINE("18", 0, 4);        Copy GR4 into GR0.
 * CALL INLINE("58", 4, 0, TEMPL); Load contents of `TEMPL` into GR4.  Note
 *                                 that `TEMPL` contains an address of a
 *                                 MVC instruction.
 * CALL INLINE("44", 3, 0, 4, 0);  Copies the string data of `NAME` to
 *                                 `COLUMN(J+4)`; i.e., to position J+4 of
 *                                 the `COLUMN` array.
 * CALL INLINE("18", 4, 0);        Copy GR0 into GR4.
 */

uint32_t nameDesc = getFIXED(mOBJECT_GENERATORxEMIT_SYM_CARDSxEMIT_SYMxNAME);
uint32_t j = getFIXED(mOBJECT_GENERATORxEMIT_SYM_CARDSxJ);
memmove(&memory[mOBJECT_GENERATORxCOLUMN + j + 4],
        &memory[nameDesc & 0xFFFFFF], 1 + ((nameDesc >> 24) & 0xFF));

#endif // PFS
