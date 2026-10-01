/* The functions behind the headers in this directory; see posix_compat.h.
 * Built only by NMakefile, and linked into yaGPC2.exe, libyaGPC2.lib and
 * every unit test. */
#include <sys/socket.h>   /* this directory's: winsock2.h and the prototypes */
#include <mswsock.h>      /* SIO_UDP_CONNRESET */
#include <windows.h>
#include <timeapi.h>      /* timeBeginPeriod; WIN32_LEAN_AND_MEAN leaves it out */

#include <errno.h>
#include <fcntl.h>
#include <io.h>
#include <process.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/event.h>
#include <unistd.h>

/* The real Winsock calls from here on, not the wrappers being defined. */
#undef socket
#undef bind
#undef setsockopt
#undef getsockname
#undef recv
#undef recvfrom
#undef sendto
#undef poll
#undef close
#undef pipe

/* ---- not a background process ---------------------------------------- */

/* WINDOWS SLOWS DOWN WHAT IT THINKS NOBODY IS WATCHING.  Windows 11 applies
 * "power throttling" (EcoQoS) to a process it judges to be in the
 * background -- and one with no window of its own, like this emulator, or
 * one whose windows are all hidden, as they are when a KVM switch takes the
 * monitors away, qualifies.  Throttled, its threads may be moved to a hybrid
 * processor's efficiency cores and run at low clock, and its timer
 * resolution request (timeBeginPeriod, below) is ignored, so every short wait
 * rounds up to the 15.6 ms tick.  Measured on an i7-12700 with the monitors
 * switched away: four GPCs in OPS 2 ran at 0.61 of real time.
 *
 * A real-time emulator is never background work, so it opts out of both,
 * before main() runs, through the C runtime's initializer table.  Harmless
 * where the call does not exist (before Windows 10 1709). */
static void __cdecl not_background(void) {
    typedef BOOL (WINAPI *SetInfo)(HANDLE, int, LPVOID, DWORD);
    struct { ULONG Version, ControlMask, StateMask; } state;
    SetInfo set = (SetInfo)(void *)GetProcAddress(GetModuleHandleW(L"kernel32.dll"),
                                                  "SetProcessInformation");
    if (set == NULL) return;
    state.Version = 1;                          /* PROCESS_POWER_THROTTLING_CURRENT_VERSION */
    state.ControlMask = 0x1 | 0x4;              /* EXECUTION_SPEED | IGNORE_TIMER_RESOLUTION */
    state.StateMask = 0;                        /* ...both switched OFF */
    set(GetCurrentProcess(), 4 /* ProcessPowerThrottling */, &state, sizeof state);
}

#pragma section(".CRT$XCU", read)
__declspec(allocate(".CRT$XCU")) static void (__cdecl *yagpc_not_background)(void) = not_background;

/* ---- time ------------------------------------------------------------ */

static double qpc_seconds(void) {
    static LARGE_INTEGER freq;   /* the same value whichever thread sets it */
    LARGE_INTEGER now;
    if (freq.QuadPart == 0) QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&now);
    return (double)now.QuadPart / (double)freq.QuadPart;
}

int clock_gettime(int clockId, struct timespec *ts) {
    if (clockId == CLOCK_MONOTONIC) {
        static LARGE_INTEGER freq;
        LARGE_INTEGER now;
        if (freq.QuadPart == 0) QueryPerformanceFrequency(&freq);
        QueryPerformanceCounter(&now);
        ts->tv_sec = (time_t)(now.QuadPart / freq.QuadPart);
        ts->tv_nsec = (long)((now.QuadPart % freq.QuadPart) * 1000000000LL / freq.QuadPart);
        return 0;
    }
    if (clockId == CLOCK_REALTIME) {
        /* 100 ns units since 1601; 11644473600 s separate that from 1970. */
        FILETIME ft;
        ULARGE_INTEGER t;
        GetSystemTimePreciseAsFileTime(&ft);
        t.LowPart = ft.dwLowDateTime;
        t.HighPart = ft.dwHighDateTime;
        t.QuadPart -= 116444736000000000ULL;
        ts->tv_sec = (time_t)(t.QuadPart / 10000000ULL);
        ts->tv_nsec = (long)(t.QuadPart % 10000000ULL) * 100L;
        return 0;
    }
    errno = EINVAL;
    return -1;
}

/* HOW A SHORT SLEEP IS MADE.
 *
 * Measured on Windows 11 (10.0.26200), 300 sleeps each:
 *
 *     Sleep(1) and an ordinary waitable timer     15.9 ms  (the 64 Hz tick)
 *     high-resolution waitable timer, 20-250 us    0.55 ms median, 0.49 min
 *     the same, 1000 us                            1.55 ms median
 *     the same, 2000 us                            2.54 ms median, 2.98 p95
 *     SwitchToThread() until the deadline          the request, to the us
 *
 * So the high-resolution timer (Windows 10 1803 and later) wakes on a 0.5 ms
 * grid and about half a millisecond late, and nothing that blocks does
 * better.  The callers ask for 20 us, 50 us, 250 us, 1 ms and 2 ms, and the
 * first three cannot be had from it at all.
 *
 * A sleep is therefore the timer for as much of it as the timer can be
 * trusted with -- the request less SLEEP_MARGIN -- and then yielding to
 * other ready threads until the deadline.  Anything shorter than the margin
 * is all yield.  That is exact, and it is not free: a thread "sleeping" 250
 * us at a time is a thread that never blocks.
 *
 * YAGPC_WIN_SLEEP_MARGIN_US changes the margin (750 by default).  At 0
 * nothing is ever spun away: every sleep blocks, comes back on the 0.5 ms
 * grid, and costs no processor -- for finding out what the precision is
 * worth on a given machine. */
#ifndef CREATE_WAITABLE_TIMER_HIGH_RESOLUTION
#define CREATE_WAITABLE_TIMER_HIGH_RESOLUTION 0x00000002
#endif
#define SLEEP_MARGIN_DEFAULT_US 750.0

static double sleep_margin_seconds(void) {
    static volatile long inited;
    static double margin;
    if (!inited) {
        const char *s = getenv("YAGPC_WIN_SLEEP_MARGIN_US");
        double us = (s != NULL && *s != '\0') ? atof(s) : SLEEP_MARGIN_DEFAULT_US;
        margin = (us >= 0.0 ? us : SLEEP_MARGIN_DEFAULT_US) * 1e-6;
        inited = 1;
    }
    return margin;
}

/* One timer per thread: a waitable timer has a single due time. */
static HANDLE thread_timer(void) {
    static __declspec(thread) HANDLE timer;
    static __declspec(thread) int tried;
    if (!tried) {
        tried = 1;
        timer = CreateWaitableTimerExW(NULL, NULL, CREATE_WAITABLE_TIMER_HIGH_RESOLUTION,
                                       TIMER_ALL_ACCESS);
    }
    return timer;
}

int nanosleep(const struct timespec *req, struct timespec *rem) {
    double want = (double)req->tv_sec + (double)req->tv_nsec * 1e-9;
    if (rem != NULL) { rem->tv_sec = 0; rem->tv_nsec = 0; }
    if (want <= 0.0) return 0;
    double deadline = qpc_seconds() + want;
    double margin = sleep_margin_seconds();
    /* With no margin the timer is given at least its own grid to work with,
     * so a 20 us request blocks rather than returning at once. */
    double blocked = (margin > 0.0) ? want - margin : want;
    HANDLE timer = (blocked > 0.0) ? thread_timer() : NULL;
    if (timer != NULL) {
        LARGE_INTEGER due;
        due.QuadPart = -(LONGLONG)(blocked * 1e7);   /* relative, 100 ns units */
        if (due.QuadPart == 0) due.QuadPart = -1;
        if (SetWaitableTimer(timer, &due, 0, NULL, NULL, FALSE))
            WaitForSingleObject(timer, INFINITE);
    }
    if (margin > 0.0 || timer == NULL)
        while (qpc_seconds() < deadline) SwitchToThread();
    return 0;
}

int usleep(unsigned int microseconds) {
    struct timespec ts;
    ts.tv_sec = (time_t)(microseconds / 1000000u);
    ts.tv_nsec = (long)(microseconds % 1000000u) * 1000L;
    return nanosleep(&ts, NULL);
}

/* ---- signals --------------------------------------------------------- */

/* See posix_compat.h.  Slot 0 is SIGINT, slot 1 is SIGUSR1. */
#undef signal

static void (*volatile g_sigHandler[2])(int);
static HANDLE g_sigEvent[2];
static const int g_sigNumber[2] = { SIGINT, SIGUSR1 };
static const char *const g_sigName[2] = { "SIGINT", "SIGUSR1" };
static SRWLOCK g_sigLock = SRWLOCK_INIT;
static HANDLE g_sigChanged;          /* wakes the waiter when an event is added */

static unsigned __stdcall signal_waiter(void *unused) {
    (void)unused;
    for (;;) {
        HANDLE handles[3];
        int slot[3], n = 0;
        AcquireSRWLockShared(&g_sigLock);
        handles[n] = g_sigChanged; slot[n++] = -1;
        for (int i = 0; i < 2; i++)
            if (g_sigEvent[i] != NULL) { handles[n] = g_sigEvent[i]; slot[n++] = i; }
        ReleaseSRWLockShared(&g_sigLock);
        DWORD got = WaitForMultipleObjects((DWORD)n, handles, FALSE, INFINITE);
        if (got == WAIT_FAILED) return 0;
        int which = slot[got - WAIT_OBJECT_0];
        if (which < 0) continue;
        void (*handler)(int) = g_sigHandler[which];
        if (handler != NULL) handler(g_sigNumber[which]);
    }
}

/* Make slot's event, and the waiting thread if this is the first. */
static void signal_listen(int slot) {
    AcquireSRWLockExclusive(&g_sigLock);
    if (g_sigEvent[slot] == NULL) {
        char name[64];
        snprintf(name, sizeof name, "Local\\yaGPC2-%lu-%s",
                 (unsigned long)GetCurrentProcessId(), g_sigName[slot]);
        g_sigEvent[slot] = CreateEventA(NULL, FALSE, FALSE, name);   /* auto-reset */
        if (g_sigChanged == NULL) {
            g_sigChanged = CreateEventA(NULL, FALSE, FALSE, NULL);
            HANDLE th = (HANDLE)_beginthreadex(NULL, 0, signal_waiter, NULL, 0, NULL);
            if (th != NULL) CloseHandle(th);
        } else {
            SetEvent(g_sigChanged);
        }
    }
    ReleaseSRWLockExclusive(&g_sigLock);
}

/* What the C runtime calls for Ctrl-C and Ctrl-Break.  It has already put
 * the signal back to its default by the time this runs, so the first thing
 * is to take it again: a second Ctrl-C must not kill a run that is busy
 * writing its reports after the first. */
static void console_interrupt(int sig) {
    signal(sig, console_interrupt);
    void (*handler)(int) = g_sigHandler[0];
    if (handler != NULL) handler(SIGINT);
}

void (*yagpc_signal(int sig, void (*handler)(int)))(int) {
    if (sig != SIGINT) return signal(sig, handler);
    void (*was)(int) = g_sigHandler[0];
    if (handler == SIG_DFL || handler == SIG_IGN) {
        g_sigHandler[0] = NULL;
        signal(SIGINT, handler);
        signal(SIGBREAK, handler);
        return was != NULL ? was : SIG_DFL;
    }
    g_sigHandler[0] = handler;
    signal(SIGINT, console_interrupt);
    signal(SIGBREAK, console_interrupt);
    signal_listen(0);
    return was != NULL ? was : SIG_DFL;
}

int sigaction(int sig, const struct sigaction *act, struct sigaction *old) {
    if (sig != SIGUSR1) { errno = EINVAL; return -1; }
    if (old != NULL) {
        old->sa_handler = g_sigHandler[1];
        old->sa_mask = 0;
        old->sa_flags = 0;
    }
    if (act != NULL) {
        g_sigHandler[1] = act->sa_handler;
        signal_listen(1);
    }
    return 0;
}

/* ---- threads --------------------------------------------------------- */

int pthread_mutex_init(pthread_mutex_t *m, const void *attr) {
    (void)attr;
    InitializeSRWLock((PSRWLOCK)&m->srw);
    return 0;
}
int pthread_mutex_destroy(pthread_mutex_t *m) { (void)m; return 0; }
int pthread_mutex_lock(pthread_mutex_t *m) {
    AcquireSRWLockExclusive((PSRWLOCK)&m->srw);
    return 0;
}
int pthread_mutex_unlock(pthread_mutex_t *m) {
    ReleaseSRWLockExclusive((PSRWLOCK)&m->srw);
    return 0;
}

int pthread_cond_init(pthread_cond_t *c, const void *attr) {
    (void)attr;
    InitializeConditionVariable((PCONDITION_VARIABLE)&c->cv);
    return 0;
}
int pthread_cond_destroy(pthread_cond_t *c) { (void)c; return 0; }
int pthread_cond_wait(pthread_cond_t *c, pthread_mutex_t *m) {
    return SleepConditionVariableSRW((PCONDITION_VARIABLE)&c->cv, (PSRWLOCK)&m->srw,
                                     INFINITE, 0) ? 0 : EINVAL;
}

/* A timed wait is rounded to the scheduler tick, which is 15.6 ms unless the
 * process has asked for better -- and the waits here are 2 ms safety nets
 * under a barrier that is meant to be woken by progress.  timeBeginPeriod(1)
 * makes the tick 1 ms for this process; asked for once, the first time a
 * thread is made or a timed wait is taken, and held until exit. */
static void want_1ms_tick(void) {
    static volatile long asked;
    if (InterlockedCompareExchange(&asked, 1, 0) == 0) timeBeginPeriod(1);
}

int pthread_cond_timedwait(pthread_cond_t *c, pthread_mutex_t *m,
                           const struct timespec *deadline) {
    struct timespec now;
    want_1ms_tick();
    clock_gettime(CLOCK_REALTIME, &now);
    double left = (double)(deadline->tv_sec - now.tv_sec)
                + (double)(deadline->tv_nsec - now.tv_nsec) * 1e-9;
    DWORD ms = 0;
    if (left > 0.0) {
        double up = left * 1000.0 + 0.999;       /* never wake before it */
        ms = (up >= 4294967294.0) ? 4294967294u : (DWORD)up;
    }
    if (SleepConditionVariableSRW((PCONDITION_VARIABLE)&c->cv, (PSRWLOCK)&m->srw, ms, 0))
        return 0;
    return GetLastError() == ERROR_TIMEOUT ? ETIMEDOUT : EINVAL;
}
int pthread_cond_signal(pthread_cond_t *c) {
    WakeConditionVariable((PCONDITION_VARIABLE)&c->cv);
    return 0;
}
int pthread_cond_broadcast(pthread_cond_t *c) {
    WakeAllConditionVariable((PCONDITION_VARIABLE)&c->cv);
    return 0;
}

struct ThreadStart {
    void *(*start)(void *);
    void *arg;
    void *result;
};

static unsigned __stdcall thread_trampoline(void *p) {
    struct ThreadStart *s = (struct ThreadStart *)p;
    s->result = s->start(s->arg);
    return 0;
}

/* The start record outlives the thread so that join can return its result;
 * it is kept beside the handle rather than in pthread_t, which the callers
 * copy by value. */
#define MAX_THREADS 64
static struct { HANDLE handle; struct ThreadStart *start; } g_threads[MAX_THREADS];
static SRWLOCK g_threadsLock = SRWLOCK_INIT;

int pthread_create(pthread_t *t, const void *attr, void *(*start)(void *), void *arg) {
    (void)attr;
    want_1ms_tick();
    struct ThreadStart *s = (struct ThreadStart *)malloc(sizeof *s);
    if (s == NULL) return EAGAIN;
    s->start = start;
    s->arg = arg;
    s->result = NULL;
    HANDLE h = (HANDLE)_beginthreadex(NULL, 0, thread_trampoline, s, CREATE_SUSPENDED, NULL);
    if (h == NULL) { free(s); return EAGAIN; }
    int slot = -1;
    AcquireSRWLockExclusive(&g_threadsLock);
    for (int i = 0; i < MAX_THREADS; i++)
        if (g_threads[i].handle == NULL) {
            g_threads[i].handle = h;
            g_threads[i].start = s;
            slot = i;
            break;
        }
    ReleaseSRWLockExclusive(&g_threadsLock);
    if (slot < 0) {
        /* Never started, so nothing of its own to unwind. */
        TerminateThread(h, 0);
        CloseHandle(h);
        free(s);
        return EAGAIN;
    }
    t->handle = h;
    ResumeThread(h);
    return 0;
}

int pthread_join(pthread_t t, void **result) {
    HANDLE h = (HANDLE)t.handle;
    if (h == NULL) return EINVAL;
    if (WaitForSingleObject(h, INFINITE) != WAIT_OBJECT_0) return EINVAL;
    struct ThreadStart *s = NULL;
    AcquireSRWLockExclusive(&g_threadsLock);
    for (int i = 0; i < MAX_THREADS; i++)
        if (g_threads[i].handle == h) {
            s = g_threads[i].start;
            g_threads[i].handle = NULL;
            g_threads[i].start = NULL;
            break;
        }
    ReleaseSRWLockExclusive(&g_threadsLock);
    if (s != NULL) {
        if (result != NULL) *result = s->result;
        free(s);
    }
    CloseHandle(h);
    return 0;
}

/* ---- sockets --------------------------------------------------------- */

/* Which descriptors are sockets, so that close() knows.  A vehicle opens
 * about seventy (31 bus slots with a receive and a transmit socket each, and
 * a discrete socket per computer). */
#define MAX_SOCKETS 256
static int g_sockets[MAX_SOCKETS];
static int g_socketCount;
static SRWLOCK g_socketsLock = SRWLOCK_INIT;

static void socket_remember(int fd) {
    AcquireSRWLockExclusive(&g_socketsLock);
    if (g_socketCount < MAX_SOCKETS) g_sockets[g_socketCount++] = fd;
    ReleaseSRWLockExclusive(&g_socketsLock);
}

static int socket_forget(int fd) {
    int was = 0;
    AcquireSRWLockExclusive(&g_socketsLock);
    for (int i = 0; i < g_socketCount; i++)
        if (g_sockets[i] == fd) {
            g_sockets[i] = g_sockets[--g_socketCount];
            was = 1;
            break;
        }
    ReleaseSRWLockExclusive(&g_socketsLock);
    return was;
}

/* errno from the last Winsock failure, in the terms the callers test and
 * print.  Returns -1 so a wrapper can end `return sock_fail();`. */
static int sock_fail(void) {
    switch (WSAGetLastError()) {
        case WSAEWOULDBLOCK:     errno = EWOULDBLOCK;   break;
        case WSAEINTR:           errno = EINTR;         break;
        case WSAEBADF:
        case WSAENOTSOCK:        errno = EBADF;         break;
        case WSAEACCES:          errno = EACCES;        break;
        case WSAEFAULT:          errno = EFAULT;        break;
        case WSAEINVAL:          errno = EINVAL;        break;
        case WSAEMFILE:          errno = EMFILE;        break;
        case WSAEMSGSIZE:        errno = EMSGSIZE;      break;
        case WSAEADDRINUSE:      errno = EADDRINUSE;    break;
        case WSAEADDRNOTAVAIL:   errno = EADDRNOTAVAIL; break;
        case WSAEAFNOSUPPORT:    errno = EAFNOSUPPORT;  break;
        case WSAENETDOWN:        errno = ENETDOWN;      break;
        case WSAENETUNREACH:     errno = ENETUNREACH;   break;
        case WSAEHOSTUNREACH:    errno = EHOSTUNREACH;  break;
        case WSAECONNRESET:      errno = ECONNRESET;    break;
        case WSAENOBUFS:         errno = ENOBUFS;       break;
        case WSAENOPROTOOPT:     errno = ENOPROTOOPT;   break;
        case WSAEOPNOTSUPP:      errno = EOPNOTSUPP;    break;
        default:                 errno = EIO;           break;
    }
    return -1;
}

static BOOL CALLBACK winsock_start(PINIT_ONCE once, PVOID param, PVOID *context) {
    WSADATA data;
    (void)once; (void)param; (void)context;
    return WSAStartup(MAKEWORD(2, 2), &data) == 0;
}

int yagpc_sock_socket(int family, int type, int protocol) {
    static INIT_ONCE once = INIT_ONCE_STATIC_INIT;
    if (!InitOnceExecuteOnce(&once, winsock_start, NULL, NULL)) {
        errno = ENETDOWN;
        return -1;
    }
    SOCKET s = socket(family, type, protocol);
    if (s == INVALID_SOCKET) return sock_fail();
    if (type == SOCK_DGRAM) {
        /* See sys/socket.h: no "connection reset" from an unanswered send. */
        BOOL report = FALSE;
        DWORD got = 0;
        WSAIoctl(s, SIO_UDP_CONNRESET, &report, sizeof report, NULL, 0, &got, NULL, NULL);
    }
    socket_remember((int)s);
    return (int)s;
}

int yagpc_sock_bind(int fd, const struct sockaddr *addr, socklen_t len) {
    return bind((SOCKET)fd, addr, len) == 0 ? 0 : sock_fail();
}

int yagpc_sock_setsockopt(int fd, int level, int name, const void *value, socklen_t len) {
    DWORD wide;
    if (level == IPPROTO_IP && len == 1) {
        wide = *(const unsigned char *)value;
        value = &wide;
        len = sizeof wide;
    }
    return setsockopt((SOCKET)fd, level, name, (const char *)value, len) == 0
               ? 0 : sock_fail();
}

int yagpc_sock_getsockname(int fd, struct sockaddr *addr, socklen_t *len) {
    return getsockname((SOCKET)fd, addr, len) == 0 ? 0 : sock_fail();
}

ssize_t yagpc_sock_recv(int fd, void *buf, size_t len, int flags) {
    int n = recv((SOCKET)fd, (char *)buf, (int)len, flags);
    if (n != SOCKET_ERROR) return n;
    if (WSAGetLastError() == WSAEMSGSIZE) return (ssize_t)len;
    return sock_fail();
}

ssize_t yagpc_sock_recvfrom(int fd, void *buf, size_t len, int flags,
                            struct sockaddr *from, socklen_t *fromLen) {
    int n = recvfrom((SOCKET)fd, (char *)buf, (int)len, flags, from, fromLen);
    if (n != SOCKET_ERROR) return n;
    if (WSAGetLastError() == WSAEMSGSIZE) return (ssize_t)len;
    return sock_fail();
}

ssize_t yagpc_sock_sendto(int fd, const void *buf, size_t len, int flags,
                          const struct sockaddr *to, socklen_t toLen) {
    int n = sendto((SOCKET)fd, (const char *)buf, (int)len, flags, to, toLen);
    return n != SOCKET_ERROR ? n : sock_fail();
}

int yagpc_sock_poll(struct pollfd *fds, nfds_t n, int timeoutMs) {
    int ready = WSAPoll(fds, n, timeoutMs);
    return ready != SOCKET_ERROR ? ready : sock_fail();
}

int yagpc_sock_fcntl(int fd, int cmd, int arg) {
    if (cmd == F_GETFL) return 0;
    if (cmd == F_SETFL) {
        u_long nonBlocking = (arg & O_NONBLOCK) ? 1u : 0u;
        return ioctlsocket((SOCKET)fd, FIONBIO, &nonBlocking) == 0 ? 0 : sock_fail();
    }
    errno = EINVAL;
    return -1;
}

/* ---- kqueue, for sockets becoming readable ---------------------------- */

/* See sys/event.h.  A queue's descriptor is a number no socket or C runtime
 * descriptor can be, so close() can tell. */
#define KQ_FD_BASE   0x7f000000
#define KQ_MAX       4
#define KQ_MAX_SOCKS (MAXIMUM_WAIT_OBJECTS - 2)   /* less the wake event, and one spare */

struct Kq {
    int used;
    SRWLOCK lock;            /* guards the three arrays and n */
    HANDLE wake;             /* set when a socket is added, so a waiter re-reads them */
    int n;
    SOCKET sock[KQ_MAX_SOCKS];
    WSAEVENT ev[KQ_MAX_SOCKS];
    void *udata[KQ_MAX_SOCKS];
};
static struct Kq g_kq[KQ_MAX];
static SRWLOCK g_kqLock = SRWLOCK_INIT;

static struct Kq *kq_find(int fd) {
    int i = fd - KQ_FD_BASE;
    return (i >= 0 && i < KQ_MAX && g_kq[i].used) ? &g_kq[i] : NULL;
}

int kqueue(void) {
    int fd = -1;
    AcquireSRWLockExclusive(&g_kqLock);
    for (int i = 0; i < KQ_MAX; i++) {
        if (g_kq[i].used) continue;
        HANDLE wake = CreateEventW(NULL, FALSE, FALSE, NULL);
        if (wake == NULL) break;
        memset(&g_kq[i], 0, sizeof g_kq[i]);
        InitializeSRWLock(&g_kq[i].lock);
        g_kq[i].wake = wake;
        g_kq[i].used = 1;
        fd = KQ_FD_BASE + i;
        break;
    }
    ReleaseSRWLockExclusive(&g_kqLock);
    if (fd < 0) errno = EMFILE;
    return fd;
}

static int kq_close(struct Kq *q) {
    AcquireSRWLockExclusive(&q->lock);
    for (int i = 0; i < q->n; i++) {
        WSAEventSelect(q->sock[i], NULL, 0);   /* the socket outlives the queue */
        WSACloseEvent(q->ev[i]);
    }
    q->n = 0;
    CloseHandle(q->wake);
    ReleaseSRWLockExclusive(&q->lock);
    AcquireSRWLockExclusive(&g_kqLock);
    q->used = 0;
    ReleaseSRWLockExclusive(&g_kqLock);
    return 0;
}

static int kq_add(struct Kq *q, const struct kevent *change) {
    if (change->filter != EVFILT_READ || !(change->flags & EV_ADD)) {
        errno = EINVAL;
        return -1;
    }
    WSAEVENT ev = WSACreateEvent();   /* manual-reset; WSAEnumNetworkEvents resets it */
    if (ev == WSA_INVALID_EVENT) return sock_fail();
    int ok = 0;
    AcquireSRWLockExclusive(&q->lock);
    if (q->n < KQ_MAX_SOCKS &&
        WSAEventSelect((SOCKET)change->ident, ev, FD_READ) == 0) {
        q->sock[q->n] = (SOCKET)change->ident;
        q->ev[q->n] = ev;
        q->udata[q->n] = change->udata;
        q->n++;
        ok = 1;
    }
    ReleaseSRWLockExclusive(&q->lock);
    if (!ok) {
        int err = WSAGetLastError();
        WSACloseEvent(ev);
        WSASetLastError(err);
        if (err != 0) return sock_fail();
        errno = ENOMEM;               /* the table is full */
        return -1;
    }
    SetEvent(q->wake);
    return 0;
}

int kevent(int kq, const struct kevent *changes, int nchanges,
           struct kevent *events, int nevents, const struct timespec *timeout) {
    struct Kq *q = kq_find(kq);
    if (q == NULL) { errno = EBADF; return -1; }
    for (int i = 0; i < nchanges; i++)
        if (kq_add(q, &changes[i]) != 0) return -1;
    if (events == NULL || nevents <= 0) return 0;

    DWORD ms = INFINITE;
    if (timeout != NULL)
        ms = (DWORD)(timeout->tv_sec * 1000 + (timeout->tv_nsec + 999999L) / 1000000L);
    double deadline = qpc_seconds() + (double)ms / 1000.0;

    for (;;) {
        HANDLE handles[KQ_MAX_SOCKS + 1];
        SOCKET socks[KQ_MAX_SOCKS];
        void *udata[KQ_MAX_SOCKS];
        AcquireSRWLockShared(&q->lock);
        int n = q->n;
        handles[0] = q->wake;
        for (int i = 0; i < n; i++) {
            handles[i + 1] = q->ev[i];
            socks[i] = q->sock[i];
            udata[i] = q->udata[i];
        }
        ReleaseSRWLockShared(&q->lock);

        DWORD got = WaitForMultipleObjects((DWORD)n + 1, handles, FALSE, ms);
        if (got == WAIT_TIMEOUT) return 0;
        if (got == WAIT_FAILED) { errno = EINVAL; return -1; }
        int first = (int)(got - WAIT_OBJECT_0);
        int found = 0;
        if (first >= 1) {
            /* From the one that woke us to the end: the wait names only the
             * lowest that is set, and a busy low-numbered bus must not keep
             * the others from being looked at. */
            for (int i = first - 1; i < n && found < nevents; i++) {
                WSANETWORKEVENTS ne;
                if (WSAEnumNetworkEvents(socks[i], handles[i + 1], &ne) != 0) continue;
                if (!(ne.lNetworkEvents & FD_READ)) continue;
                memset(&events[found], 0, sizeof events[found]);
                events[found].ident = (uintptr_t)socks[i];
                events[found].filter = EVFILT_READ;
                events[found].udata = udata[i];
                found++;
            }
        }
        if (found > 0) return found;
        /* A socket was added, or an event had nothing behind it: wait out
         * what is left of the timeout with the list as it now stands. */
        if (ms != INFINITE) {
            double left = deadline - qpc_seconds();
            if (left <= 0.0) return 0;
            ms = (DWORD)(left * 1000.0 + 0.999);
        }
    }
}

/* ---- descriptors ----------------------------------------------------- */

int yagpc_close(int fd) {
    struct Kq *q = kq_find(fd);
    if (q != NULL) return kq_close(q);
    if (socket_forget(fd))
        return closesocket((SOCKET)fd) == 0 ? 0 : sock_fail();
    return _close(fd);
}

int yagpc_pipe(int fds[2]) {
    return _pipe(fds, 65536, _O_BINARY);
}
