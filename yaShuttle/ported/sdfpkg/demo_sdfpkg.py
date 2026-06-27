#!/usr/bin/env python3
"""
demo_sdfpkg.py  --  Demonstration of the sdfpkg.py API.

Shows both the write (creation) and read (access) paths:

  Part 1 -- Write: create a new SDF flat file member from scratch,
            adding a block, eight symbols of different types, and
            four statements.  This is the path PASS3 of HALSFC will use.

  Part 2 -- Read:  open the newly written file, select the member,
            and extract all blocks, symbols, and statements through
            the typed query API.  This is the path PASS1 of HALSFC
            will use to import SDF data from compiled modules.

Usage:  ./demo_sdfpkg.py [--help] [file.sdf [member]]

If file.sdf is omitted a temporary file is created and deleted on exit.
If a file is supplied it must already exist (Part 1 is skipped and
only Part 2 runs).
"""

import sys
import os
import struct
import tempfile

from sdfpkg import (
    SdfContext, SdfWriter, SdfError,
    WBlock, WSymbol, WStmt,
    BCLASS_PROGRAM,
    SCLASS_VARIABLE,
    STYPE_SCALAR, STYPE_INTEGER, STYPE_BOOLEAN, STYPE_CHARACTER,
    STYPE_BIT, STYPE_VECTOR, STYPE_MATRIX,
    STTYPE_ASSIGN, STTYPE_IF,
    WFLAG_HAS_SRNS,
    RC_NOT_EXEC, DISP_NONE,
)

# ---------------------------------------------------------------------------
# Human-readable label tables
# ---------------------------------------------------------------------------

BLK_CLASS = {
    1: 'PROGRAM', 2: 'FUNCTION', 3: 'PROCEDURE',
    4: 'TASK',    5: 'COMPOOL',  6: 'CLOSE BLOCK',
}
SYM_CLASS = {
    1: 'variable', 2: 'equate-ext', 3: 'template',
    4: 'label',    6: 'compool',
}
SYM_TYPE = {
    1: 'SCALAR',    2: 'INTEGER',   3: 'BOOLEAN',
    4: 'CHARACTER', 5: 'BIT',       6: 'VECTOR',
    7: 'MATRIX',    8: 'equate-ext', 9: 'EVENT',
    10: 'STRUCTURE', 11: 'TASK',
}
STMT_TYPE = {
    1: 'ASSIGNMENT', 2: 'IF',       3: 'DO',
    4: 'DO WHILE',   5: 'DO UNTIL', 6: 'DO FOR',
    7: 'END',        8: 'RETURN',   9: 'CALL',
    10: 'GOTO',     11: 'ON ERROR',
}

def sym_type_detail(sym):
    t = sym.sym_type
    if t == STYPE_VECTOR:    return f'VECTOR({sym.rows})' if sym.rows else 'VECTOR'
    if t == STYPE_MATRIX:
        if sym.rows and sym.columns: return f'MATRIX({sym.rows},{sym.columns})'
        return 'MATRIX'
    if t == STYPE_CHARACTER: return f'CHARACTER({sym.columns})' if sym.columns else 'CHARACTER'
    if t == STYPE_BIT:       return f'BIT({sym.rows})' if sym.rows else 'BIT'
    return SYM_TYPE.get(t, f'type={t}')


# ---------------------------------------------------------------------------
# Part 1 -- Write: create a new SDF member
# ---------------------------------------------------------------------------

def demo_write(sdf_path: str, member: str = 'NAVCOMP') -> None:
    """
    Demonstrates the SDF creation API (the PASS3 path).

    We build a member called NAVCOMP containing:
      - One PROGRAM block (NAVCOMP, CSECT NAVSECT)
      - Eight symbols of different HAL/S data types
      - Four statements (three executable, one non-executable declare)
    """
    print('=' * 60)
    print('Part 1 -- Write: creating SDF member')
    print('=' * 60)
    print(f'  Output file : {sdf_path}')
    print(f'  Member name : {member}')
    print()

    # ------------------------------------------------------------------
    # Step W1: Create a write context for a new file.
    # ------------------------------------------------------------------
    # SdfWriter.create() initialises a write context.  The actual file
    # is not opened until commit() is called, so no I/O happens here.
    # WFLAG_HAS_SRNS causes each statement node to carry a 6-character
    # Statement Reference Number alongside its data-cell pointer.

    print('Step W1: create write context')
    w = SdfWriter.create(sdf_path, member, flags=WFLAG_HAS_SRNS)

    # ------------------------------------------------------------------
    # Step W2: Add a block descriptor.
    # ------------------------------------------------------------------
    # add_block() buffers the descriptor and returns a block number.
    # The number is provisional until commit(), but may be used
    # immediately in subsequent add_symbol() and add_stmt() calls.

    print('Step W2: add block NAVCOMP')
    blk_no = w.add_block(WBlock(
        csect_name = 'NAVSECT',
        blk_name   = 'NAVCOMP',
        blk_class  = BCLASS_PROGRAM,
        blk_id     = 1,
    ))
    print(f'  Provisional block number: {blk_no}')
    print()

    # ------------------------------------------------------------------
    # Step W3: Add symbol descriptors.
    # ------------------------------------------------------------------
    # add_symbol() buffers each descriptor and returns a provisional
    # symbol number.  Symbols may be added in any order; commit() sorts
    # them alphabetically, which is required for the binary search used
    # by find_symbol_by_name() on the read side.

    print('Step W3: add symbols (in arbitrary order; sorted at commit)')
    symbols = [
        # name               type             rows  cols
        ('VELOCITY',         STYPE_VECTOR,    3,    0),
        ('ALTITUDE',         STYPE_SCALAR,    0,    0),
        ('MESSAGE',          STYPE_CHARACTER, 0,   20),
        ('BITS',             STYPE_BIT,      16,    0),
        ('COUNT',            STYPE_INTEGER,   0,    0),
        ('ARMED',            STYPE_BOOLEAN,   0,    0),
        ('INERTIA',          STYPE_MATRIX,    3,    3),
        ('LONGSYMBOLNAME',   STYPE_SCALAR,    0,    0),
    ]
    for name, typ, rows, cols in symbols:
        symb_no = w.add_symbol(WSymbol(
            blk_no    = blk_no,
            symb_name = name,
            sym_class = SCLASS_VARIABLE,
            sym_type  = typ,
            rows      = rows,
            columns   = cols,
        ))
        type_str = SYM_TYPE.get(typ, str(typ))
        print(f'  Added {name:<18} ({type_str}), provisional symb_no={symb_no}')
    print()

    # ------------------------------------------------------------------
    # Step W4: Add statement descriptors.
    # ------------------------------------------------------------------
    # add_stmt() must be called in source (statement-number) order.
    # Non-executable statements (is_exec=False) represent declarations
    # and produce a statement node with a null data-cell pointer.

    print('Step W4: add statements (in source order)')
    stmts = [
        # srn       type            exec   lhs  labls
        (b'S0001 ', STTYPE_ASSIGN,  True,   1,  0),
        (b'S0002 ', STTYPE_ASSIGN,  True,   1,  1),  # has a label
        (b'S0003 ', STTYPE_IF,      True,   0,  0),
        (b'S0004 ', 0,              False,  0,  0),  # non-executable: DECLARE
    ]
    for srn, typ, is_exec, lhs, labls in stmts:
        stmt_no = w.add_stmt(WStmt(
            blk_no    = blk_no,
            srn       = srn,
            stmt_type = typ,
            is_exec   = is_exec,
            num_lhs   = lhs,
            num_labls = labls,
        ))
        srn_str = srn.rstrip(b' ').decode()
        exec_str = 'executable' if is_exec else 'non-executable (declare)'
        print(f'  Added stmt {stmt_no}: SRN={srn_str}  {exec_str}')
    print()

    # ------------------------------------------------------------------
    # Step W5: Commit.
    # ------------------------------------------------------------------
    # commit() performs all the heavy work:
    #   - Sorts symbols alphabetically and reassigns numbers.
    #   - Sorts blocks by name and reassigns numbers.
    #   - Computes per-block symbol/statement ranges.
    #   - Allocates virtual memory (page:offset) for every structure
    #     using a bump-pointer allocator starting at page 1.
    #   - Builds the block binary-tree (BLKTCELL tree) using a
    #     balanced median-split over the sorted block array.
    #   - Builds symbol and statement extent cells (SYMEXTF/V,
    #     STMTEXTF/V) for efficient lookup by name and SRN.
    #   - Writes PAGEZERO and DROOTCEL into page 0.
    #   - Writes the flat-file header, index entry, and all pages.

    print('Step W5: commit (sort, build trees, write file)')
    w.commit()

    wstats_blks   = len(w._blocks)
    wstats_symbs  = len(w._symbols)
    wstats_stmts  = len(w._stmts)
    print(f'  Committed: {wstats_blks} block(s), {wstats_symbs} symbol(s), '
          f'{wstats_stmts} statement(s)')
    print(f'  File written: {sdf_path}')
    print()


# ---------------------------------------------------------------------------
# Part 2 -- Read: access the SDF member
# ---------------------------------------------------------------------------

def demo_read(sdf_path: str, member: str = 'NAVCOMP') -> None:
    """
    Demonstrates the SDF read API (the PASS1 path).
    """
    print('=' * 60)
    print('Part 2 -- Read: accessing SDF member')
    print('=' * 60)
    print(f'  Input file  : {sdf_path}')
    print(f'  Member name : {member}')
    print()

    # ------------------------------------------------------------------
    # Step R1: Open the SDF flat file.
    # ------------------------------------------------------------------
    # SdfContext.open() corresponds to the original SDFPKG mode-0 (INIT).
    # npages controls how many 1680-byte pages can be held in memory.

    print('Step R1: open file')
    ctx = SdfContext.open(sdf_path, npages=4)

    # ------------------------------------------------------------------
    # Step R2: Select a member.
    # ------------------------------------------------------------------
    # select() (mode 4) reads page 0 to populate the FCB with metadata.

    print('Step R2: select member')
    ctx.select(member)

    # ------------------------------------------------------------------
    # Step R3: Read the directory root cell.
    # ------------------------------------------------------------------
    # locate_root() (mode 7) returns a memoryview of the DROOTCEL.

    print('Step R3: read directory root cell')
    root       = ctx.locate_root()
    blk_nodes  = struct.unpack_from('>H', root, 16)[0]
    sym_nodes  = struct.unpack_from('>H', root, 18)[0]
    fstmt      = struct.unpack_from('>H', root, 52)[0]
    lstm       = struct.unpack_from('>H', root, 54)[0]
    sdf_flags  = (root[0] << 8) | root[1]
    has_srns   = bool(sdf_flags & 0x8000)
    print(f'  Block nodes  : {blk_nodes}')
    print(f'  Symbol nodes : {sym_nodes}')
    print(f'  Stmt range   : {fstmt}..{lstm}')
    print(f'  Has SRNs     : {has_srns}')
    print()

    # ------------------------------------------------------------------
    # Step R4: Enumerate blocks.
    # ------------------------------------------------------------------
    # find_block_by_number() (mode 8) returns a BlockResult.

    print(f'Step R4: enumerate blocks')
    print(f'  {"#":>3}  {"CSECT":<10}  {"CLASS":<12}  {"NAME":<20}  '
          f'{"SYMBS":>7}  {"STMTS":>7}')
    print(f'  {"-"*3}  {"-"*10}  {"-"*12}  {"-"*20}  {"-"*7}  {"-"*7}')
    for blk_no in range(1, blk_nodes + 1):
        blk = ctx.find_block_by_number(blk_no)
        cls = BLK_CLASS.get(blk.blk_class, str(blk.blk_class))
        sr  = f'{blk.fsymb_no}..{blk.lsymb_no}' if blk.fsymb_no else '—'
        tr  = f'{blk.fstmt_no}..{blk.lstm_no}'  if blk.fstmt_no else '—'
        print(f'  {blk.blk_no:>3}  {blk.csect_name:<10}  {cls:<12}  '
              f'{blk.blk_name:<20}  {sr:>7}  {tr:>7}')
    print()

    # ------------------------------------------------------------------
    # Step R5: Enumerate symbols.
    # ------------------------------------------------------------------
    # find_symbol_by_number() (mode 9) iterates over all symbols.
    # Note: symbols are in alphabetical order, as required for binary
    # search, so the order here differs from the order they were added.

    print(f'Step R5: enumerate symbols (in alphabetical order after sort)')
    print(f'  {"#":>3}  {"NAME":<18}  {"CLASS":<12}  {"TYPE":<18}  BLK')
    print(f'  {"-"*3}  {"-"*18}  {"-"*12}  {"-"*18}  {"-"*3}')
    for symb_no in range(1, sym_nodes + 1):
        sym = ctx.find_symbol_by_number(symb_no)
        cls = SYM_CLASS.get(sym.sym_class, str(sym.sym_class))
        typ = sym_type_detail(sym)
        print(f'  {sym.symb_no:>3}  {sym.symb_name:<18}  {cls:<12}  '
              f'{typ:<18}  {sym.blk_no}')
    print()

    # ------------------------------------------------------------------
    # Step R6: Find a symbol by name.
    # ------------------------------------------------------------------
    # find_block_by_number() first to establish the block search context,
    # then find_symbol_by_name() (mode 13) does a binary search.

    print('Step R6: find symbol by name')
    ctx.find_block_by_number(1)
    try:
        sym = ctx.find_symbol_by_name('VELOCITY')
        print(f'  VELOCITY found: symb_no={sym.symb_no}, '
              f'type={sym_type_detail(sym)}, blk={sym.blk_no}')
    except SdfError as e:
        print(f'  Not found: {e}')
    print()

    # ------------------------------------------------------------------
    # Step R7: Enumerate statements.
    # ------------------------------------------------------------------
    # find_stmt_by_number() (mode 10) raises RC_NOT_EXEC for declares;
    # find_stmt_node_by_number() (mode 17) retrieves the SRN alone.

    print(f'Step R7: enumerate statements')
    print(f'  {"#":>3}  {"SRN":<8}  {"TYPE":<14}  {"EXEC":>4}  '
          f'{"LABLS":>5}  {"LHS":>3}  BLK')
    print(f'  {"-"*3}  {"-"*8}  {"-"*14}  {"-"*4}  {"-"*5}  {"-"*3}  {"-"*3}')
    for stmt_no in range(fstmt, lstm + 1):
        try:
            stmt = ctx.find_stmt_by_number(stmt_no)
            srn  = stmt.srn.rstrip(b' ').decode() if stmt.srn else ''
            typ  = STMT_TYPE.get(stmt.stmt_type, str(stmt.stmt_type))
            print(f'  {stmt.stmt_no:>3}  {srn:<8}  {typ:<14}  {"yes":>4}  '
                  f'{stmt.num_labls:>5}  {stmt.num_lhs:>3}  {stmt.blk_no}')
        except SdfError as e:
            if e.code == RC_NOT_EXEC:
                node = ctx.find_stmt_node_by_number(stmt_no)
                srn  = node.srn.rstrip(b' ').decode() if node.srn else ''
                print(f'  {stmt_no:>3}  {srn:<8}  {"(non-exec)":<14}  '
                      f'{"no":>4}  {"—":>5}  {"—":>3}  —')
            else:
                print(f'  {stmt_no:>3}  error: {e}')
    print()

    # ------------------------------------------------------------------
    # Step R8: Find a statement by SRN.
    # ------------------------------------------------------------------
    # find_stmt_by_srn() (mode 14) uses the extent cells to locate the
    # right page, then does a binary search within that page.

    print('Step R8: find statement by SRN')
    try:
        stmt = ctx.find_stmt_by_srn(b'S0002 ')
        srn  = stmt.srn.rstrip(b' ').decode()
        print(f'  SRN S0002 found: stmt_no={stmt.stmt_no}, '
              f'type={STMT_TYPE.get(stmt.stmt_type)}, '
              f'labels={stmt.num_labls}, lhs={stmt.num_lhs}')
    except SdfError as e:
        print(f'  Not found: {e}')
    print()

    # ------------------------------------------------------------------
    # Step R9: Statistics and close.
    # ------------------------------------------------------------------

    reads, writes, selects = ctx.stats()
    print('Step R9: I/O statistics')
    print(f'  Page reads   : {reads}')
    print(f'  Page writes  : {writes}')
    print(f'  Select calls : {selects}')
    print()

    ctx.close()
    print('Context closed.')
    print()


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    if '--help' in sys.argv or '-h' in sys.argv:
        print(__doc__)
        sys.exit(0)

    member    = 'NAVCOMP'
    temp_file = None

    if len(sys.argv) >= 2:
        sdf_path = sys.argv[1]
        if len(sys.argv) >= 3:
            member = sys.argv[2]
        # Existing file: skip Part 1
        if os.path.exists(sdf_path):
            demo_read(sdf_path, member)
            return

    # No existing file: use a temp file and run both parts
    fd, sdf_path = tempfile.mkstemp(suffix='.sdf', prefix='sdfpkg_demo_')
    os.close(fd)
    temp_file = sdf_path

    try:
        demo_write(sdf_path, member)
        demo_read(sdf_path, member)
    finally:
        if temp_file and os.path.exists(temp_file):
            os.unlink(temp_file)
            print(f'Temporary file {temp_file} removed.')


if __name__ == '__main__':
    main()
