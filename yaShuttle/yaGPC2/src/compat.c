#include "compat.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

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
