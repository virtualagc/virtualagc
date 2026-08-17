#define _POSIX_C_SOURCE 200809L /* clock_gettime(), nanosleep() */
#include "compat.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

double yagpc_monotonic_seconds(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec / 1e9;
}

void yagpc_sleep_seconds(double seconds) {
    if (seconds <= 0.0) return;
    struct timespec req;
    req.tv_sec = (time_t)seconds;
    req.tv_nsec = (long)((seconds - (double)req.tv_sec) * 1e9);
    nanosleep(&req, NULL);
}

char *yagpc_strdup(const char *s) {
    size_t len = strlen(s) + 1;
    char *copy = malloc(len);
    if (!copy) return NULL;
    memcpy(copy, s, len);
    return copy;
}

int yagpc_strcasecmp(const char *a, const char *b) {
    for (;;) {
        unsigned char ca = (unsigned char)*a++;
        unsigned char cb = (unsigned char)*b++;
        int da = tolower(ca);
        int db = tolower(cb);
        if (da != db) return da - db;
        if (ca == '\0') return 0;
    }
}
