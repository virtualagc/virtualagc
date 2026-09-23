/* Reading a volume that is an encrypted archive (src/volsource.c).
 *
 * The property under test is the one the feature exists for: the bytes the
 * emulator reads out of an encrypted .7z are the bytes that went into it, and
 * a wrong password FAILS rather than yielding something plausible.  The
 * second half matters more than the first -- 7z writes nothing when it cannot
 * decrypt, so without the child's exit status a wrong password looks exactly
 * like a truncated volume, and the loader would report "not an MMUVOL01
 * volume" about a file that is a perfectly good one.
 *
 * SKIPPED, NOT FAILED, WHERE 7z IS NOT INSTALLED.  The emulator needs it only
 * for a feature nobody is obliged to use, so a machine without p7zip should
 * still be able to run the suite.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../src/volsource.h"

#define PLAIN "/tmp/yagpc2-volsource-plain.bin"
#define ARCHIVE "/tmp/yagpc2-volsource-test.7z"
#define PASSWORD "correct horse battery staple"

static int failures;

static void check(int ok, const char *what) {
    if (ok) return;
    failures++;
    printf("FAIL [volsource/%s]\n", what);
}

/* Hand the password over the way a run with no terminal does. */
static void give_password(const char *pw) {
    int fd[2];
    if (pipe(fd) != 0) return;
    ssize_t n = write(fd[1], pw, strlen(pw));
    n += write(fd[1], "\n", 1);
    (void)n;
    close(fd[1]);
    volsource_password_fd(fd[0]);
}

/* Read the whole source; returns bytes read, or -1 if it would not open. */
static long slurp(const char *path, unsigned char *buf, size_t max, bool *closedOk) {
    VolSource v;
    if (!volsource_open(&v, path)) { *closedOk = false; return -1; }
    long got = (long)fread(buf, 1, max, v.f);
    *closedOk = volsource_close(&v);
    return got;
}

int main(void) {
    /* A body with enough structure that a wrong answer is unlikely to look
     * right by accident. */
    static unsigned char want[64 * 1024];
    for (size_t i = 0; i < sizeof want; i++)
        want[i] = (unsigned char)((i * 31u + (i >> 8)) & 0xffu);

    FILE *f = fopen(PLAIN, "wb");
    if (f == NULL) { printf("FAIL [volsource/setup]: cannot write %s\n", PLAIN); return 1; }
    fwrite(want, 1, sizeof want, f);
    fclose(f);

    remove(ARCHIVE);
    char cmd[512];
    snprintf(cmd, sizeof cmd,
             "7z a -t7z -mhe=on -p'%s' %s %s >/dev/null 2>&1", PASSWORD, ARCHIVE, PLAIN);
    int made = system(cmd);
    if (made != 0 || access(ARCHIVE, R_OK) != 0) {
        printf("SKIP [volsource]: no working 7z, so an encrypted volume "
               "cannot be built to read\n");
        remove(PLAIN);
        return 0;
    }

    /* A bare file is not an archive; the .7z is. */
    check(!volsource_is_archive(PLAIN), "a plain volume is not an archive");
    check(volsource_is_archive(ARCHIVE), "a .7z is an archive");

    /* WRONG PASSWORD FIRST, because a right one would be cached and the
     * wrong case could never then be reached. */
    static unsigned char got[sizeof want + 16];
    bool closedOk = true;
    give_password("not the password");
    long n = slurp(ARCHIVE, got, sizeof got, &closedOk);
    check(!closedOk, "a wrong password is reported as a failure");
    check(n <= 0, "a wrong password yields no data");

    /* And now the right one. */
    give_password(PASSWORD);
    closedOk = false;
    n = slurp(ARCHIVE, got, sizeof got, &closedOk);
    check(closedOk, "the right password succeeds");
    check(n == (long)sizeof want, "the whole volume comes back");
    check(n > 0 && memcmp(got, want, sizeof want) == 0,
          "the bytes are the bytes that went in");

    /* The plain file still reads as it always did. */
    closedOk = false;
    n = slurp(PLAIN, got, sizeof got, &closedOk);
    check(closedOk && n == (long)sizeof want &&
          memcmp(got, want, sizeof want) == 0, "a plain volume is unaffected");

    remove(PLAIN);
    remove(ARCHIVE);

    if (failures == 0) {
        printf("6/6 volsource checks passed\n");
        return 0;
    }
    printf("%d volsource check(s) failed\n", failures);
    return 1;
}
