#ifndef HALMAT_DISASM_H
#define HALMAT_DISASM_H

#include <stdio.h>

#include "halmat.h"

/* unHALMAT.py-style plain-text listing, one instruction per line plus one
 * indented line per operand. Intentionally not byte-for-byte identical to
 * unHALMAT.py's own format (that tool also interleaves --listing2/--litfile/
 * --common lookups this loader doesn't yet resolve); this exists to
 * structurally validate the loader against a known-correct instruction
 * count/opcode sequence, not to be a drop-in replacement. */
void halmat_disasm_program(const halmat_program_t *prog, FILE *out);

/* Same format, for a single instruction -- used by --debugger. */
void halmat_disasm_instr(const halmat_instr_t *ins, FILE *out);

#endif
