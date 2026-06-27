/*
 * sdf_compat.h  --  Portability shims for sdfpkg.
 *
 * Included by every .c file in the library instead of scattering
 * platform guards across individual sources.
 *
 * Targets
 * -------
 *   Linux     : gcc or clang, glibc
 *   macOS     : Apple clang or homebrew gcc/clang, BSD libc
 *   MSYS2     : MinGW-w64 gcc or clang on Windows
 */

#ifndef SDF_COMPAT_H
#define SDF_COMPAT_H

/* ---- POSIX feature-test macros ------------------------------------ */
/* Must appear before any system header is included.                   */
/* Linux needs this for fseeko, off_t, mkstemp, strcasecmp.           */
/* macOS and MSYS2/MinGW expose these without a feature-test macro.   */
#if defined(__linux__)
#  ifndef _POSIX_C_SOURCE
#    define _POSIX_C_SOURCE 200809L
#  endif
#endif

/* ---- Standard headers used across the library --------------------- */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/types.h>   /* off_t */

/* ---- strcasecmp --------------------------------------------------- */
/* POSIX <strings.h>; present on Linux, macOS, and MSYS2/MinGW.       */
/* MSVC uses _stricmp from <string.h>.                                 */
#if defined(_MSC_VER)
#  include <string.h>
#  define strcasecmp  _stricmp
#  define strncasecmp _strnicmp
#else
#  include <strings.h>
#endif

/* ---- fseeko / ftello ---------------------------------------------- */
/* Available on Linux (with _POSIX_C_SOURCE), macOS, and MSYS2.       */
/* MSVC uses _fseeki64 / _ftelli64.                                    */
#if defined(_MSC_VER)
#  define fseeko  _fseeki64
#  define ftello  _ftelli64
   typedef __int64 off_t;
#endif

/* ---- mkstemp ------------------------------------------------------ */
/* POSIX; available on Linux, macOS, and MSYS2/MinGW.                 */
/* For MSVC we provide a simple replacement using _mktemp_s.           */
#if defined(_MSC_VER)
#  include <io.h>
#  include <fcntl.h>
static inline int sdf_mkstemp(char *tmpl) {
    if (_mktemp_s(tmpl, strlen(tmpl) + 1) != 0) return -1;
    return _open(tmpl, _O_CREAT | _O_EXCL | _O_RDWR | _O_BINARY,
                 _S_IREAD | _S_IWRITE);
}
#  define mkstemp sdf_mkstemp
#endif

/* ---- unlink ------------------------------------------------------- */
#if defined(_MSC_VER)
#  include <io.h>
#  define unlink _unlink
#endif

#endif /* SDF_COMPAT_H */
