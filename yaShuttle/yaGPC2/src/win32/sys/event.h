/* <sys/event.h> for the native Windows build: as much of kqueue as the bus
 * transport's arrival watcher uses.  See posix_compat.h.
 *
 * WHY WINDOWS TAKES THE macOS PATH.  The transport asks "has any bus a
 * datagram waiting?" every 2 us of simulated time -- half a million times a
 * simulated second for each computer.  Linux answers with a poll() at about
 * 1 us.  macOS takes 16 us, which ran the vehicle at 0.4 of real time, so
 * there a watcher thread blocks in kevent() and counts arrivals, and the
 * question becomes a comparison of two counters.  WSAPoll() over the same
 * 24 sockets was measured here at 4.9 us: better than macOS and still five
 * times what the rate was tuned against.  So bcenet_transport.c's BCENET_KQ
 * path is used on Windows too, and this is the kqueue under it.
 *
 * Only this much: EVFILT_READ on sockets, added with EV_ADD | EV_CLEAR and
 * never removed; kevent() either registers (no event list) or waits (no
 * change list).  Each socket gets a Winsock event (WSAEventSelect, FD_READ)
 * and the wait is WaitForMultipleObjects, so at most 62 sockets.
 *
 * FD_READ is not quite EV_CLEAR and the difference is on the safe side.
 * kqueue reports every new arrival; Winsock reports one, and then nothing
 * more until somebody has called recv() on the socket -- at which point it
 * reports again if data is (still, or newly) there.  The transport answers
 * every report by draining the socket until recv() fails, and that failing
 * recv() is what re-arms the report.  So a report can be spurious, which
 * costs one empty drain, but an arrival cannot go unreported. */
#ifndef YAGPC_WIN32_SYS_EVENT_H
#define YAGPC_WIN32_SYS_EVENT_H

#include <stdint.h>
#include <time.h>

struct kevent {
    uintptr_t ident;
    short filter;
    unsigned short flags;
    unsigned int fflags;
    intptr_t data;
    void *udata;
};

#define EVFILT_READ (-1)
#define EV_ADD      0x0001
#define EV_CLEAR    0x0020

#define EV_SET(kev, id, flt, flg, ffl, dat, ud) \
    do {                                        \
        struct kevent *yagpc_kev_ = (kev);      \
        yagpc_kev_->ident = (uintptr_t)(id);    \
        yagpc_kev_->filter = (short)(flt);      \
        yagpc_kev_->flags = (unsigned short)(flg); \
        yagpc_kev_->fflags = (unsigned int)(ffl);  \
        yagpc_kev_->data = (intptr_t)(dat);     \
        yagpc_kev_->udata = (ud);               \
    } while (0)

/* Closed with close(), like any descriptor; see unistd.h. */
int kqueue(void);
int kevent(int kq, const struct kevent *changes, int nchanges,
           struct kevent *events, int nevents, const struct timespec *timeout);

#endif
