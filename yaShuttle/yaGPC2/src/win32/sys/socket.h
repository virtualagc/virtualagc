/* <sys/socket.h> for the native Windows build: Winsock under the BSD names
 * and conventions the shared sources are written to.  See posix_compat.h.
 * <netinet/in.h>, <arpa/inet.h> and <poll.h> beside this all come here.
 *
 * What differs between the two, and what is done about each:
 *
 *   - A socket is a SOCKET, not an int.  The sources keep them in ints with
 *     -1 for "none", so socket() here returns an int and -1 on failure.
 *     Windows handles are guaranteed to fit in 32 bits.
 *   - Failures are reported through WSAGetLastError(), not errno.  Every
 *     wrapper sets errno to the POSIX equivalent, because the callers both
 *     print strerror(errno) and test it against EAGAIN.
 *   - A datagram longer than the buffer is an error (WSAEMSGSIZE) rather
 *     than a short read.  recv() and recvfrom() here return the truncated
 *     length, as BSD does.
 *   - A UDP socket reports "connection reset" on its next receive if an
 *     earlier send reached a port nobody was listening on.  Switched off
 *     when the socket is made; the buses are connectionless.
 *   - Option values are char pointers, and the one-byte multicast TTL the
 *     sources pass is widened to the DWORD Windows wants.
 *   - close() is closesocket() for a socket; see unistd.h.
 *   - Non-blocking mode is ioctlsocket(FIONBIO), reached through fcntl().
 *   - WSAStartup() is called on the first socket().
 *
 * MULTICAST, which is what these sockets are for.  SO_REUSEADDR is what
 * lets several processes bind one port on Windows (there is no
 * SO_REUSEPORT), and each of them that has joined the group gets its own
 * copy of a datagram.  IP_MULTICAST_LOOP is read on the RECEIVING socket
 * here and on the sending one elsewhere; every socket in this code sets it
 * on, which is also the default, so both ends agree either way. */
#ifndef YAGPC_WIN32_SYS_SOCKET_H
#define YAGPC_WIN32_SYS_SOCKET_H

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef _WINSOCK_DEPRECATED_NO_WARNINGS
#define _WINSOCK_DEPRECATED_NO_WARNINGS   /* inet_addr, inet_ntoa */
#endif
#include <winsock2.h>
#include <ws2tcpip.h>

typedef unsigned long nfds_t;

int yagpc_sock_socket(int family, int type, int protocol);
int yagpc_sock_bind(int fd, const struct sockaddr *addr, socklen_t len);
int yagpc_sock_setsockopt(int fd, int level, int name, const void *value, socklen_t len);
int yagpc_sock_getsockname(int fd, struct sockaddr *addr, socklen_t *len);
ssize_t yagpc_sock_recv(int fd, void *buf, size_t len, int flags);
ssize_t yagpc_sock_recvfrom(int fd, void *buf, size_t len, int flags,
                            struct sockaddr *from, socklen_t *fromLen);
ssize_t yagpc_sock_sendto(int fd, const void *buf, size_t len, int flags,
                          const struct sockaddr *to, socklen_t toLen);
int yagpc_sock_poll(struct pollfd *fds, nfds_t n, int timeoutMs);
int yagpc_sock_fcntl(int fd, int cmd, int arg);

#define socket      yagpc_sock_socket
#define bind        yagpc_sock_bind
#define setsockopt  yagpc_sock_setsockopt
#define getsockname yagpc_sock_getsockname
#define recv        yagpc_sock_recv
#define recvfrom    yagpc_sock_recvfrom
#define sendto      yagpc_sock_sendto
#define poll        yagpc_sock_poll

/* Only F_GETFL and F_SETFL with O_NONBLOCK, which is all a socket is asked
 * for here.  MSVC's own <fcntl.h> has the open() flags but neither of these
 * nor fcntl() itself. */
#define F_GETFL    3
#define F_SETFL    4
#define O_NONBLOCK 0x4000
#define fcntl      yagpc_sock_fcntl

#endif
