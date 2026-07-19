#ifndef HALMAT_INTERP_H
#define HALMAT_INTERP_H

#include <stdio.h>

#include "halmat.h"
#include "literal.h"
#include "state.h"

void interp_init(halmat_state_t *state, const halmat_program_t *prog,
                  const halmat_literal_table_t *literals, int num_blanks);

/* Runs to completion (CLOS on the outermost program) or to the first
 * unimplemented/malformed instruction. Returns the process exit code:
 * 0 on a clean CLOS, nonzero (with a message on stderr) otherwise. */
int interp_run(halmat_state_t *state, FILE *out);

#endif
