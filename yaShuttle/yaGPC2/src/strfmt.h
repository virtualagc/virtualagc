/* String/number formatting helpers ported from com/util.coffee. Only
 * lpad/rpad/asHex are ported — asBin/asOct/.bin()/.oct() aren't exercised
 * by any code reachable from `gpc run` (verified by grep across the
 * cmd_run dependency graph; the few `.bin()` call sites in cpu.coffee are
 * binary integer literals, hand-translated to C constants when cpu.c is
 * ported in Phase 4, not runtime formatting). */
#ifndef YAGPC_STRFMT_H
#define YAGPC_STRFMT_H

#include <stddef.h>

/* String::lpad(padString, length): prepend padString (whole, possibly
 * more than once) until the string is at least `length` chars. Writes
 * into `out` (must be large enough — see callers; typical widths here
 * are small). Returns `out`. */
char *str_lpad(char *out, size_t outSize, const char *s, const char *padStr, int length);

/* String::rpad(padString, length): if shorter than `length`, append
 * padString repeated (length - len(s)) times (matches the source's
 * `padString.repeat(length-@length)` literally — for a multi-char
 * padString this overshoots `length`, but every call site in the ported
 * code uses a single-char pad). */
char *str_rpad(char *out, size_t outSize, const char *s, const char *padStr, int length);

/* Number::asHex(l=4): zero-pad the hex representation of `v` on the left
 * to at least 8 digits, then take the last `l` characters — i.e.
 * zero-padded to `l` digits, or truncated to the low `l` hex digits if
 * the value needs more than 8. Negative values format as '-' followed by
 * the hex of the absolute value (matches Number.prototype.toString(16)),
 * though every call site in the ported code passes an already-unsigned
 * value. Returns `out`. */
char *as_hex(char *out, size_t outSize, long long v, int len);

#endif
