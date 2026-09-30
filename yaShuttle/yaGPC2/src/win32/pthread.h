/* <pthread.h> for the native Windows build; see posix_compat.h.
 *
 * Only what yaGPC2 uses: plain mutexes, condition variables with a timed
 * wait, and joinable threads.  A mutex is a slim reader/writer lock taken
 * exclusively and a condition variable is Windows' own, each one pointer
 * wide with all-zero as its initial state -- so the static initialisers
 * work and "destroy" has nothing to do.  Like a default pthread mutex the
 * lock is not recursive and must be released by the thread that took it.
 *
 * The functions are in posix_win32.c, which keeps <windows.h> out of every
 * file that includes this. */
#ifndef YAGPC_WIN32_PTHREAD_H
#define YAGPC_WIN32_PTHREAD_H

#include <time.h>

typedef struct { void *srw; } pthread_mutex_t;
typedef struct { void *cv; } pthread_cond_t;
typedef struct { void *handle; } pthread_t;

#define PTHREAD_MUTEX_INITIALIZER {0}
#define PTHREAD_COND_INITIALIZER  {0}

/* The attribute arguments must be NULL; nothing here passes anything else. */
int pthread_mutex_init(pthread_mutex_t *m, const void *attr);
int pthread_mutex_destroy(pthread_mutex_t *m);
int pthread_mutex_lock(pthread_mutex_t *m);
int pthread_mutex_unlock(pthread_mutex_t *m);

int pthread_cond_init(pthread_cond_t *c, const void *attr);
int pthread_cond_destroy(pthread_cond_t *c);
int pthread_cond_wait(pthread_cond_t *c, pthread_mutex_t *m);
/* The deadline is CLOCK_REALTIME, as POSIX has it.  Returns ETIMEDOUT when
 * it passes. */
int pthread_cond_timedwait(pthread_cond_t *c, pthread_mutex_t *m,
                           const struct timespec *deadline);
int pthread_cond_signal(pthread_cond_t *c);
int pthread_cond_broadcast(pthread_cond_t *c);

int pthread_create(pthread_t *t, const void *attr, void *(*start)(void *), void *arg);
int pthread_join(pthread_t t, void **result);

#endif
