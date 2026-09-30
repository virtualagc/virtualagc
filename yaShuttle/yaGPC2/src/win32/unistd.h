/* <unistd.h> for the native Windows build; see posix_compat.h. */
#ifndef YAGPC_WIN32_UNISTD_H
#define YAGPC_WIN32_UNISTD_H

#include <io.h>
#include <process.h>

#define STDIN_FILENO  0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#define F_OK 0
#define W_OK 2
#define R_OK 4

/* A descriptor here is either one of the C runtime's or a socket from the
 * socket() in sys/socket.h, and the two are closed by different calls.
 * This closes whichever it was given: sockets are remembered when they are
 * made, so there is no guessing from the number. */
int yagpc_close(int fd);
#define close yagpc_close

/* A pipe of bytes, not of text: no newline translation in either direction. */
int yagpc_pipe(int fds[2]);
#define pipe yagpc_pipe

int usleep(unsigned int microseconds);

#endif
