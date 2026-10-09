/* What MSVC lacks that the rest of yaGPC2 takes for granted, for the native
 * Windows build (NMakefile) and nothing else.
 *
 * NMakefile force-includes this file into every translation unit (/FI) and
 * puts this directory on the include path, where pthread.h, unistd.h,
 * strings.h, poll.h and the socket headers beside it stand in for the POSIX
 * ones.  The point of doing it this way round is that the sources shared
 * with Linux, macOS and WSL are compiled there exactly as they always were:
 * nothing in src/ includes this, and the GNU Makefile -- whose wildcard is
 * src/*.c -- never looks in this directory.
 *
 * DELIBERATELY DOES NOT INCLUDE <windows.h>.  This reaches every source
 * file, and windows.h brings macros (ERROR, IN, OUT, small, near, far, min,
 * max) that have no business in an AP-101 emulator.  Whatever needs the
 * Windows API is a function declared here and defined in posix_win32.c. */
#ifndef YAGPC_WIN32_POSIX_COMPAT_H
#define YAGPC_WIN32_POSIX_COMPAT_H

#ifdef _MSC_VER

/* Lets a shared source tell "Windows, with these shims" from "Windows,
 * without" (MinGW, which brings its own POSIX layer and never sees this). */
#define YAGPC_POSIX_SHIMS 1

#include <stddef.h>
#include <stdlib.h>
#include <time.h>

/* ---- types ---------------------------------------------------------- */

typedef ptrdiff_t ssize_t;

/* ---- time ----------------------------------------------------------- */

#define CLOCK_REALTIME  0
#define CLOCK_MONOTONIC 1

/* CLOCK_MONOTONIC is QueryPerformanceCounter; CLOCK_REALTIME is the system
 * time as UTC since 1970, which is what pthread_cond_timedwait's deadline
 * is measured against. */
int clock_gettime(int clockId, struct timespec *ts);

/* NOT Sleep().  That rounds up to the scheduler tick -- 15.6 ms unless
 * something has asked for better -- and this code sleeps for 20 us to 2 ms
 * at a time to keep a vehicle in step with the wall clock.  See
 * posix_win32.c for what it does instead and what that was measured at. */
int nanosleep(const struct timespec *req, struct timespec *rem);

static __inline struct tm *gmtime_r(const time_t *t, struct tm *out) {
    return gmtime_s(out, t) == 0 ? out : NULL;
}

/* ---- signals -------------------------------------------------------- */

/* The emulator is told two things by signal: SIGINT ends a run in good order
 * (its stop reason and the device reports are printed), and SIGUSR1 asks for
 * a snapshot.  Windows has neither in a form another process can send -- a
 * console Ctrl-C reaches only programs sharing a console that have not been
 * started in a group of their own, which is exactly how the launcher starts
 * this one, and there is no SIGUSR1 at all.
 *
 * So each is ALSO a named event here.  Installing a handler for either
 * creates "Local\yaGPC2-<pid>-SIGINT" or "Local\yaGPC2-<pid>-SIGUSR1", and a
 * thread calls the handler when the event is set; discretePanel/procinfo.py
 * is what sets them.  The handlers only set a flag, as a signal handler
 * must, so being called on another thread changes nothing.  Ctrl-C and
 * Ctrl-Break at a console still work, and both mean SIGINT. */
#include <signal.h>

#define SIGUSR1    30      /* not a number the C runtime's own signal() knows */
#define SA_RESTART 0

typedef int sigset_t;
struct sigaction {
    void (*sa_handler)(int);
    sigset_t sa_mask;
    int sa_flags;
};
#define sigemptyset(set) (*(set) = 0, 0)

int sigaction(int sig, const struct sigaction *act, struct sigaction *old);
void (*yagpc_signal(int sig, void (*handler)(int)))(int);
#define signal(sig, handler) yagpc_signal(sig, handler)

/* ---- environment ---------------------------------------------------- */

static __inline int setenv(const char *name, const char *value, int overwrite) {
    if (!overwrite && getenv(name) != NULL) return 0;
    return _putenv_s(name, value) == 0 ? 0 : -1;
}

/* An empty value removes the variable (_putenv_s's convention). */
static __inline int unsetenv(const char *name) {
    return _putenv_s(name, "") == 0 ? 0 : -1;
}

/* ---- compiler builtins (cl only; clang-cl has the real ones) --------- */

#ifndef __clang__

#include <intrin.h>

#if !defined(_M_X64) && !defined(_M_IX86)
#error "the __atomic_* shims below assume x86's strong memory ordering; build with clang-cl on this architecture"
#endif

#define __thread __declspec(thread)
#define __builtin_return_address(level) _ReturnAddress()

/* GCC's __atomic builtins, on ordinary (non-_Atomic) objects of 1, 2, 4 or
 * 8 bytes, which is how the sources use them.  The ordering argument is
 * accepted and ignored: every write is an interlocked operation, which is
 * sequentially consistent, and on x86 a plain load is already as strong as
 * an acquire.  The load goes through a volatile lvalue so the compiler
 * cannot hoist it out of a loop that is waiting for another thread. */
#define __ATOMIC_RELAXED 0
#define __ATOMIC_CONSUME 1
#define __ATOMIC_ACQUIRE 2
#define __ATOMIC_RELEASE 3
#define __ATOMIC_ACQ_REL 4
#define __ATOMIC_SEQ_CST 5

#define YAGPC_ATOMIC_BY_SIZE_(p, f8, f16, f32, f64, v)                          \
    (sizeof(*(p)) == 1 ? (__int64)f8((volatile char *)(p), (char)(v))          \
     : sizeof(*(p)) == 2 ? (__int64)f16((volatile short *)(p), (short)(v))     \
     : sizeof(*(p)) == 4 ? (__int64)f32((volatile long *)(p), (long)(v))       \
     : (__int64)f64((volatile __int64 *)(p), (__int64)(v)))

#define __atomic_load_n(p, order) (*(volatile __typeof__(*(p)) *)(p))

#define __atomic_exchange_n(p, v, order)                                        \
    ((__typeof__(*(p)))YAGPC_ATOMIC_BY_SIZE_(p, _InterlockedExchange8,          \
        _InterlockedExchange16, _InterlockedExchange, _InterlockedExchange64, v))

#define __atomic_store_n(p, v, order) ((void)__atomic_exchange_n(p, v, order))

#define __atomic_fetch_add(p, v, order)                                         \
    ((__typeof__(*(p)))YAGPC_ATOMIC_BY_SIZE_(p, _InterlockedExchangeAdd8,       \
        _InterlockedExchangeAdd16, _InterlockedExchangeAdd,                     \
        _InterlockedExchangeAdd64, v))

#define __atomic_add_fetch(p, v, order)                                         \
    ((__typeof__(*(p)))(__atomic_fetch_add(p, v, order) + (v)))

static __inline int yagpc_cas8_(volatile char *p, char *expected, char desired) {
    char was = _InterlockedCompareExchange8(p, desired, *expected);
    if (was == *expected) return 1;
    *expected = was;
    return 0;
}
static __inline int yagpc_cas16_(volatile short *p, short *expected, short desired) {
    short was = _InterlockedCompareExchange16(p, desired, *expected);
    if (was == *expected) return 1;
    *expected = was;
    return 0;
}
static __inline int yagpc_cas32_(volatile long *p, long *expected, long desired) {
    long was = _InterlockedCompareExchange(p, desired, *expected);
    if (was == *expected) return 1;
    *expected = was;
    return 0;
}
static __inline int yagpc_cas64_(volatile __int64 *p, __int64 *expected, __int64 desired) {
    __int64 was = _InterlockedCompareExchange64(p, desired, *expected);
    if (was == *expected) return 1;
    *expected = was;
    return 0;
}

#define __atomic_compare_exchange_n(p, expected, desired, weak, success, failure) \
    (sizeof(*(p)) == 1 ? yagpc_cas8_((volatile char *)(p), (char *)(expected), (char)(desired))      \
     : sizeof(*(p)) == 2 ? yagpc_cas16_((volatile short *)(p), (short *)(expected), (short)(desired)) \
     : sizeof(*(p)) == 4 ? yagpc_cas32_((volatile long *)(p), (long *)(expected), (long)(desired))    \
     : yagpc_cas64_((volatile __int64 *)(p), (__int64 *)(expected), (__int64)(desired)))

#endif /* !__clang__ */

#endif /* _MSC_VER */
#endif
