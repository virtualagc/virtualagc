#ifndef HALMAT_HAL_FPU_H
#define HALMAT_HAL_FPU_H

#include <stdint.h>

/* Persistent AP-101S floating-register-file state -- specifically the
 * "odd companion" halfwords of the F0:F1/F2:F3/F4:F5/F6:F7 extended-
 * precision register pairs that the runtime library's own RTL routines
 * (RANDOM.asm, EXP.asm, LOG.asm, MM14SN.asm, ...) all draw on out of
 * the SAME physical CPU register file.
 *
 * Every ported routine's own "even" register (F0/F2/F4/F6) is always
 * freshly loaded (LE/LFLR/CVFL/etc.) before use, so its own PRIOR value
 * never matters -- but the odd companion is only ever written by a
 * genuine EXTENDED instruction (AEDR/SEDR/MED/AED/SED/...), and every
 * "single" instruction (LE/STE/SER/MER/DER/CER/LECR/ME/...) leaves it
 * completely untouched. That means an odd register's value carries
 * forward, unchanged, from whatever the PREVIOUS floating-point-heavy
 * RTL call happened to leave it as -- confirmed via a real yaGPC2 trace
 * where a first MATRIX**(-1) call's own leftover F1 measurably changed
 * a SECOND, otherwise-independent MATRIX**(-1) call's own result
 * (task 100/id 51's own derivation). A routine that explicitly resets
 * its own companion first (EXP.asm/LOG.asm's own "SER F1,F1") is
 * self-contained and doesn't need to READ this incoming state, but
 * still needs to WRITE its own final value back here so the leak
 * propagates correctly to whatever comes next -- exactly the same
 * "chained_f1" idea hal_random.c's own RANU already modeled for
 * RANDOM/RANDOMG specifically, now generalized so every ported RTL
 * routine shares the one real underlying register file instead of each
 * silently assuming a fresh (usually-wrong-after-the-first-call) 0.
 *
 * f3/f7 aren't read by any routine ported so far (every current F2/F6
 * user either never extends it or explicitly reloads its own companion
 * before use -- LOG.asm's own `LE F3,ROUND`) but are kept here for
 * whatever gets ported next (DEXP/DLOG/MM14DN/ATAN2/...) rather than
 * adding a second, differently-shaped state struct later. */
typedef struct {
    uint32_t f1, f3, f5, f7;
} hal_fpu_state_t;

/* Zero -- matches a fresh process's own register reset (confirmed via
 * a real trace: every odd register's first-ever appearance in a whole
 * program's execution is always 0 until some extended instruction
 * first writes it). */
void hal_fpu_init(hal_fpu_state_t *fpu);

#endif
