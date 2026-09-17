/* A memoised getenv, because the emulator asks the same questions millions
 * of times a second.
 *
 * WHY.  About 165 places in yaGPC2 gate a trace, a tuning value or a mode on
 * an environment variable, and many of them sit in per-instruction or
 * per-datagram paths: `if (getenv("YAGPC_EATRACE"))` runs on every effective
 * address, `getenv("YAGPC_WATCHRD")` on every memory read.  glibc's getenv
 * walks the whole `environ` array comparing each entry, so a variable that
 * is NOT set costs a scan of every variable that is -- the expensive answer
 * is the common one.  Profiling a saturated four-GPC run put `getenv` at
 * 3.2% of cycles with a further share of `__strcmp_avx2` behind it, spent
 * entirely on re-deriving answers that cannot change.
 *
 * They cannot change because nothing in this codebase calls `setenv`,
 * `putenv` or touches `environ`: the environment is fixed at exec and every
 * lookup after the first is the same lookup.
 *
 * HOW.  Every call site passes a STRING LITERAL, so the argument's ADDRESS
 * identifies the question -- no string comparison is needed to recognise a
 * repeat.  A small direct-mapped table keyed on that address answers a hit
 * with one pointer compare; a miss calls the real getenv once and records
 * it, NULL included, since "not set" is an answer worth caching too.  The
 * table is per-thread, so the four GPC threads neither share slots nor need
 * a lock, and a key/value pair can never be torn across a store.
 *
 * The same trick is in `timing.c` for the instruction-timing table, for the
 * same reason and with the same shape.
 *
 * CAUTION: the key is the POINTER, not the text.  Passing a buffer whose
 * contents change would return the previous answer.  Every caller in this
 * tree passes a literal; keep it that way. */
#ifndef YAGPC_ENVCACHE_H
#define YAGPC_ENVCACHE_H

/* Same contract as getenv: the value, or NULL when the variable is unset.
 * `name` must be a string literal (see CAUTION above). */
const char *yagpc_getenv(const char *name);

#endif /* YAGPC_ENVCACHE_H */
