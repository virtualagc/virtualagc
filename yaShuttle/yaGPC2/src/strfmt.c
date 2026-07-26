#include "strfmt.h"

#include <stdio.h>
#include <string.h>

char *str_lpad(char *out, size_t outSize, const char *s, const char *padStr, int length) {
    char buf[256];
    int bufCap = (int)sizeof(buf);
    size_t slen = strlen(s);
    if (slen > (size_t)bufCap) slen = (size_t)bufCap; /* not expected in practice */
    int start = bufCap - (int)slen;
    memcpy(buf + start, s, slen);

    int padLen = (int)strlen(padStr);
    int curLen = bufCap - start;
    while (curLen < length && padLen > 0 && start - padLen >= 0) {
        start -= padLen;
        memcpy(buf + start, padStr, (size_t)padLen);
        curLen += padLen;
    }

    size_t n = (size_t)(bufCap - start);
    if (n >= outSize) n = outSize - 1;
    memcpy(out, buf + start, n);
    out[n] = '\0';
    return out;
}

char *str_rpad(char *out, size_t outSize, const char *s, const char *padStr, int length) {
    size_t slen = strlen(s);
    if ((int)slen >= length) {
        size_t n = slen < outSize - 1 ? slen : outSize - 1;
        memcpy(out, s, n);
        out[n] = '\0';
        return out;
    }

    size_t written = slen < outSize - 1 ? slen : outSize - 1;
    memcpy(out, s, written);
    int repeat = length - (int)slen;
    size_t padLen = strlen(padStr);
    for (int i = 0; i < repeat && written < outSize - 1; i++) {
        size_t n = padLen;
        if (written + n > outSize - 1) n = outSize - 1 - written;
        memcpy(out + written, padStr, n);
        written += n;
    }
    out[written] = '\0';
    return out;
}

char *as_hex(char *out, size_t outSize, long long v, int len) {
    char hexPart[32];
    if (v < 0) {
        snprintf(hexPart, sizeof(hexPart), "-%llx", (unsigned long long)(-v));
    } else {
        snprintf(hexPart, sizeof(hexPart), "%llx", (unsigned long long)v);
    }

    char padded[48];
    snprintf(padded, sizeof(padded), "00000000%s", hexPart);
    int plen = (int)strlen(padded);

    /* JS String#slice(start,end): a negative `start` counts from the end
     * (max(length+start,0)), not clamp-to-zero — matters when len exceeds
     * the padded string's length. */
    int start = plen - len;
    if (start < 0) {
        start = plen + start;
        if (start < 0) start = 0;
    }

    size_t n = (size_t)(plen - start);
    if (n >= outSize) n = outSize - 1;
    memcpy(out, padded + start, n);
    out[n] = '\0';
    return out;
}
