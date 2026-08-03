/*
 * Licensing:   Declared by the author (Ronald Burkey) to be Public Domain in
 *              the U.S., and can be freely distributed or modified in any
 *              desired way whatsoever.
 * Filename:    sdfpkg.h
 * Purpose:     C implementation of the services the original SDFPKG.ASM
 *              provided to XPL/I programs through MONITOR(22).  Used by
 *              HAL/S-FC's INCSDF to satisfy a "D INCLUDE TEMPLATE" from a
 *              Simulation Data File (SDF) rather than from the template
 *              library.
 * Reference:   "HAL/S-FC SDL Interface Control Document", USA001556, for the
 *              format of an SDF; SDFPKG-USERS-GUIDE-29-14.pdf and
 *              PASS.REL32V0/SDFPKG.ASM/ for the services themselves.  Where
 *              the two disagree the assembly wins, it being what actually ran.
 * Contact:     info@sandroid.org
 * Mod history: 2026-08-02 RSB  Wrote, porting modules/{sdfpkg,cmem,sdf} from
 *                              Python.  Note that the Python is the tested
 *                              reference implementation here, not the other
 *                              way round.
 *
 * This is part of the *runtime library*, not of any XPL/I translation: the C
 * that XCOM-I emits from ##DRIVER.xpl cannot be edited, so everything to do
 * with MONITOR(22) has to live here.  Do not edit the copy of this file that
 * appears in a *.build folder; that copy is overwritten from this one on every
 * build.
 */

#ifndef SDFPKG_H
#define SDFPKG_H

#include <stdint.h>

/* An SDF is paged in units of 1680 bytes, and the Paging Area Directory has
 * one 16-byte entry per page frame. */
#define SDF_PAGE_SIZE 1680
#define SDF_PAD_ENTRY_SIZE 16

/* Offsets within COMMTABL, the fixed-layout area through which every argument
 * and result of MONITOR(22) is passed.  Taken from SDFPKG.ASM and cross-checked
 * against INCSDF.xpl's own COMMTABL_BYTE/HALFWORD/FULLWORD accessors. */
#define SDF_OFF_APGAREA   0    /* Address of the Paging Area                */
#define SDF_OFF_AFCBAREA  4    /* Address of the FCB area                   */
#define SDF_OFF_NPAGES    8    /* Number of page frames in the Paging Area  */
#define SDF_OFF_NBYTES    10   /* Bytes in the FCB area                     */
#define SDF_OFF_MISC      12
#define SDF_OFF_CRETURN   14   /* Return code; 0 is success                 */
#define SDF_OFF_BLKNO     16
#define SDF_OFF_SYMBNO    18
#define SDF_OFF_STMTNO    20
#define SDF_OFF_BLKNLEN   22   /* Significant length of BLKNAM              */
#define SDF_OFF_SYMBNLEN  23   /* Significant length of SYMBNAM             */
#define SDF_OFF_PNTR      24   /* Virtual-memory pointer of the located cell*/
#define SDF_OFF_ADDR      28   /* Where that cell has been paged in         */
#define SDF_OFF_SDFNAM    32   /* 8 characters, blank-padded                */
#define SDF_OFF_CSECTNAM  40   /* 8 characters                              */
#define SDF_OFF_SREFNO    48   /* 6 characters                              */
#define SDF_OFF_INCLCNT   54
#define SDF_OFF_BLKNAM    56   /* 32 characters                             */
#define SDF_OFF_SYMBNAM   88   /* 32 characters                             */
#define SDF_COMMTABL_SIZE 120

/* Dispositions, carried in the top nibble of the mode word rather than in a
 * field of their own. */
#define SDF_DISP_SELECT 0x8
#define SDF_DISP_MODF   0x4
#define SDF_DISP_RELS   0x2
#define SDF_DISP_RESV   0x1

/* MONITOR(22, 0, commtablAddress): establish the COMMTABL and initialize.
 * Everything else is MONITOR(22, mode), the mode word carrying its disposition
 * in the top nibble.  Both return the value the XPL/I expects to see, which
 * for these services is simply zero; the real result is CRETURN in COMMTABL. */
uint32_t sdfpkgInitialize(uint32_t commtablAddress);
uint32_t sdfpkgService(uint32_t mode);

/* Releases every open SDF.  Called at normal termination so that a modified
 * page cannot be left unwritten. */
void sdfpkgTerminate(void);

#endif /* SDFPKG_H */
