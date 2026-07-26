/* Small portability shims so the rest of the codebase never needs
 * POSIX-only functions (`strdup`, `strcasecmp`) or platform-specific
 * feature-test macros (`_POSIX_C_SOURCE`) — needed for MSVC, which has
 * neither. Trivial enough to just implement directly rather than
 * `#ifdef`-selecting between `_strdup`/`strdup` and `_stricmp`/
 * `strcasecmp` everywhere they're used. */
#ifndef YAGPC_COMPAT_H
#define YAGPC_COMPAT_H

/* Same contract as POSIX strdup: a malloc'd copy of s (caller frees), or
 * NULL on allocation failure. */
char *yagpc_strdup(const char *s);

/* Same contract as POSIX strcasecmp: ASCII case-insensitive compare. */
int yagpc_strcasecmp(const char *a, const char *b);

#endif
