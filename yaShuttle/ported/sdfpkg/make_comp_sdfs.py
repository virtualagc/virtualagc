#!/usr/bin/env python3
"""
make_comp_sdfs.py  --  Build SDF flat files for COMPA.hal and COMPB.hal.

COMPA: COMPOOL;
   STRUCTURE ASTRUCTURE:
      1 SI INTEGER, 1 SL BOOLEAN, 1 SS SCALAR, 1 SC CHARACTER(20);
   DECLARE ASTRUCTURE ASTRUCTURE-STRUCTURE;
   DECLARE IA INTEGER, BA BIT(16), SA SCALAR, CA CHARACTER(30);
CLOSE COMPA;

COMPB: COMPOOL;
   STRUCTURE ASTRUCTURE:   /* same template as COMPA, independent definition */
      1 SI INTEGER, 1 SL BOOLEAN, 1 SS SCALAR, 1 SC CHARACTER(20);
   DECLARE BSTRUCTURE ASTRUCTURE-STRUCTURE;
   DECLARE IB INTEGER, BB BIT(16), SB SCALAR, CB CHARACTER(30);
CLOSE COMPB;

After commit(), blocks sort alphabetically:
  Block 1 = ASTRUCTURE (BCLASS_PROCEDURE=3, structure template)
  Block 2 = COMPA or COMPB (BCLASS_COMPOOL=5)

Symbol ordering within ASTRUCTURE block (alphabetical):
  1: ASTRUCTURE  (template header, SCLASS_TEMPLATE, rows=own symb_no=1)
  2: SC
  3: SI
  4: SL
  5: SS

Symbol ordering within COMPA block (alphabetical):
  6: ASTRUCTURE  (instance, STYPE_STRUCTURE, rows=1 = template header symb#)
  7: BA
  8: CA
  9: IA
  10: SA

Symbol ordering within COMPB block (alphabetical):
  6: BB
  7: BSTRUCTURE  (instance, STYPE_STRUCTURE, rows=1 = template header symb#)
  8: CB
  9: IB
  10: SB
"""

import os
import sys

script_dir = os.path.dirname(os.path.abspath(__file__))
if script_dir not in sys.path:
    sys.path.insert(0, script_dir)

from sdfpkg import (
    SdfWriter, WBlock, WSymbol,
    SdfContext, flat_info,
    BCLASS_PROCEDURE, BCLASS_COMPOOL,
    SCLASS_VARIABLE, SCLASS_TEMPLATE,
    STYPE_SCALAR, STYPE_INTEGER, STYPE_BOOLEAN, STYPE_CHARACTER,
    STYPE_BIT, STYPE_STRUCTURE,
)

SYM_TYPE_NAME = {
    STYPE_SCALAR: 'SCALAR', STYPE_INTEGER: 'INTEGER', STYPE_BOOLEAN: 'BOOLEAN',
    STYPE_CHARACTER: 'CHARACTER', STYPE_BIT: 'BIT', STYPE_STRUCTURE: 'STRUCTURE',
}
BLK_CLASS_NAME = {BCLASS_PROCEDURE: 'STRUCTURE template', BCLASS_COMPOOL: 'COMPOOL'}


def report(path):
    info = flat_info(path)
    mem = info[0]
    print(f'Written {path}')
    print(f'  Member: {mem["name"]}  pages: {mem["page_count"]}')
    ctx = SdfContext.open(path)
    ctx.select(mem['name'].rstrip())
    import struct as _s
    root = ctx.locate_root()
    blk_nodes = _s.unpack_from('>H', root, 16)[0]
    sym_nodes = _s.unpack_from('>H', root, 18)[0]
    print(f'  Blocks: {blk_nodes}  Symbols: {sym_nodes}')
    for bn in range(1, blk_nodes + 1):
        blk = ctx.find_block_by_number(bn)
        cls = BLK_CLASS_NAME.get(blk.blk_class, str(blk.blk_class))
        sr = f'{blk.fsymb_no}..{blk.lsymb_no}' if blk.fsymb_no else '—'
        print(f'  Block {blk.blk_no}: {blk.blk_name:<16} {cls:<22} symbols={sr}')
        for sn in range(blk.fsymb_no, blk.lsymb_no + 1):
            sym = ctx.find_symbol_by_number(sn)
            extra = ''
            if sym.sym_type == STYPE_CHARACTER:
                extra = f'({sym.columns})'
            elif sym.sym_type == STYPE_BIT:
                extra = f'({sym.rows})'
            elif sym.sym_type == STYPE_STRUCTURE:
                extra = f' rows={sym.rows}'
            tname = SYM_TYPE_NAME.get(sym.sym_type, str(sym.sym_type))
            print(f'    {sn:>3}: {sym.symb_name:<16} {tname}{extra}')
    ctx.close()
    print()


def make_compa():
    OUTPUT = os.path.join(script_dir, 'COMPA.sdf')
    w = SdfWriter.create(OUTPUT, 'COMPA', flags=0)

    b_astruc = w.add_block(WBlock(
        csect_name='ASTRUC',
        blk_name='ASTRUCTURE',
        blk_class=BCLASS_PROCEDURE,
        blk_id=1,
    ))
    b_compa = w.add_block(WBlock(
        csect_name='COMPA',
        blk_name='COMPA',
        blk_class=BCLASS_COMPOOL,
        blk_id=2,
    ))

    # ASTRUCTURE template header (rows = own symb_no, filled by commit())
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='ASTRUCTURE',
                         sym_class=SCLASS_TEMPLATE, sym_type=STYPE_STRUCTURE))
    # Template members (sorted alphabetically: SC < SI < SL < SS)
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='SC',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_CHARACTER, columns=20))
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='SI',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_INTEGER))
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='SL',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_BOOLEAN))
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='SS',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))

    # COMPA compool variables (sorted alphabetically: ASTRUCTURE < BA < CA < IA < SA)
    # ASTRUCTURE instance: rows = symb_no of ASTRUCTURE template header = 1
    w.add_symbol(WSymbol(blk_no=b_compa, symb_name='ASTRUCTURE',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_STRUCTURE, rows=1))
    w.add_symbol(WSymbol(blk_no=b_compa, symb_name='BA',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_BIT, rows=16))
    w.add_symbol(WSymbol(blk_no=b_compa, symb_name='CA',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_CHARACTER, columns=30))
    w.add_symbol(WSymbol(blk_no=b_compa, symb_name='IA',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_INTEGER))
    w.add_symbol(WSymbol(blk_no=b_compa, symb_name='SA',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))

    w.commit()
    return OUTPUT


def make_compb():
    OUTPUT = os.path.join(script_dir, 'COMPB.sdf')
    w = SdfWriter.create(OUTPUT, 'COMPB', flags=0)

    b_astruc = w.add_block(WBlock(
        csect_name='ASTRUC',
        blk_name='ASTRUCTURE',
        blk_class=BCLASS_PROCEDURE,
        blk_id=1,
    ))
    b_compb = w.add_block(WBlock(
        csect_name='COMPB',
        blk_name='COMPB',
        blk_class=BCLASS_COMPOOL,
        blk_id=2,
    ))

    # ASTRUCTURE template (same definition as in COMPA, independent)
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='ASTRUCTURE',
                         sym_class=SCLASS_TEMPLATE, sym_type=STYPE_STRUCTURE))
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='SC',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_CHARACTER, columns=20))
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='SI',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_INTEGER))
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='SL',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_BOOLEAN))
    w.add_symbol(WSymbol(blk_no=b_astruc, symb_name='SS',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))

    # COMPB compool variables (sorted alphabetically: BB < BSTRUCTURE < CB < IB < SB)
    w.add_symbol(WSymbol(blk_no=b_compb, symb_name='BB',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_BIT, rows=16))
    # BSTRUCTURE instance: rows = symb_no of ASTRUCTURE template header = 1
    w.add_symbol(WSymbol(blk_no=b_compb, symb_name='BSTRUCTURE',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_STRUCTURE, rows=1))
    w.add_symbol(WSymbol(blk_no=b_compb, symb_name='CB',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_CHARACTER, columns=30))
    w.add_symbol(WSymbol(blk_no=b_compb, symb_name='IB',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_INTEGER))
    w.add_symbol(WSymbol(blk_no=b_compb, symb_name='SB',
                         sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))

    w.commit()
    return OUTPUT


if __name__ == '__main__':
    report(make_compa())
    report(make_compb())
