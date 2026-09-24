/* See volsource.h. */
#include "volsource.h"

#include <errno.h>
#include <signal.h>
#include <strings.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <termios.h>
#include <unistd.h>

#include "envcache.h"

#define PASSWORD_MAX 256

static char g_password[PASSWORD_MAX];
static bool g_havePassword = false;
static int g_passwordFd = -1;

void volsource_password_fd(int fd) { g_passwordFd = fd; }

static void strip_newline(char *s) {
    size_t n = strlen(s);
    while (n > 0 && (s[n - 1] == '\n' || s[n - 1] == '\r')) s[--n] = '\0';
}

/* Read one line without echoing it.  Returns false if there is no terminal,
 * which is the normal case for an unattended run and must not be fatal
 * without explanation -- see the caller. */
static bool ask_terminal(const char *path, char *out, size_t n) {
    int fd = open("/dev/tty", O_RDWR);
    if (fd < 0) return false;
    FILE *tty = fdopen(fd, "r+");
    if (tty == NULL) { close(fd); return false; }

    struct termios was, now;
    bool quiet = tcgetattr(fd, &was) == 0;
    if (quiet) {
        now = was;
        now.c_lflag &= ~(tcflag_t)ECHO;
        quiet = tcsetattr(fd, TCSAFLUSH, &now) == 0;
    }
    fprintf(tty, "password for %s: ", path);
    fflush(tty);
    char *got = fgets(out, (int)n, tty);
    if (quiet) {
        tcsetattr(fd, TCSAFLUSH, &was);
        fprintf(tty, "\n");           /* the newline the echo would have shown */
        fflush(tty);
    }
    fclose(tty);
    if (got == NULL) return false;
    strip_newline(out);
    return true;
}

/* THE PASSWORD, ONCE.  Two mass memories are commonly served from one
 * archive, and asking twice for the same secret is how people end up putting
 * it in a shell variable instead. */
static const char *password_for(const char *path) {
    if (g_havePassword) return g_password;

    if (g_passwordFd >= 0) {
        FILE *f = fdopen(g_passwordFd, "r");
        if (f == NULL) {
            fprintf(stderr, "mmu: cannot read the password fd: %s\n",
                    strerror(errno));
            return NULL;
        }
        char *got = fgets(g_password, sizeof g_password, f);
        fclose(f);
        g_passwordFd = -1;
        if (got == NULL) {
            fprintf(stderr, "mmu: nothing on the password fd\n");
            return NULL;
        }
        strip_newline(g_password);
        g_havePassword = true;
        return g_password;
    }

    const char *env = yagpc_getenv("YAGPC_TAPE_PASSWORD");
    if (env != NULL && *env != '\0') {
        snprintf(g_password, sizeof g_password, "%s", env);
        g_havePassword = true;
        return g_password;
    }

    if (ask_terminal(path, g_password, sizeof g_password)) {
        g_havePassword = true;
        return g_password;
    }

    /* NO TERMINAL AND NOTHING TOLD US.  Say all three ways rather than
     * "cannot open": a run launched by simulatePASS has its standard input on
     * /dev/null, and an unattended one has no terminal at all, so this is the
     * first thing anybody automating it will hit. */
    fprintf(stderr,
            "mmu: %s is encrypted and there is no terminal to ask on.\n"
            "     Give the password with --tape-password-fd N, or in the\n"
            "     environment variable YAGPC_TAPE_PASSWORD, or run where\n"
            "     /dev/tty can be opened.\n", path);
    return NULL;
}

bool volsource_is_archive(const char *path) {
    if (path == NULL) return false;
    size_t n = strlen(path);
    if (n >= 3 && strcasecmp(path + n - 3, ".7z") == 0) return true;
    /* ALSO BY CONTENT, because a tape that has been renamed is still a tape.
     * The extension is what the owner asked to select on; the signature is
     * what stops a mis-named archive being read as a volume and reported as
     * "not an MMUVOL01 volume", which says nothing useful. */
    static const unsigned char sig[6] = {0x37, 0x7a, 0xbc, 0xaf, 0x27, 0x1c};
    FILE *f = fopen(path, "rb");
    if (f == NULL) return false;
    unsigned char head[6];
    bool is = fread(head, 1, sizeof head, f) == sizeof head &&
              memcmp(head, sig, sizeof sig) == 0;
    fclose(f);
    return is;
}

/* Run `7z x -so -- path`, its standard input a pipe we put the password
 * down, its standard output a pipe the caller reads the volume from. */
static bool spawn_7z(VolSource *v, const char *path, const char *password) {
    int toChild[2], fromChild[2];
    if (pipe(toChild) != 0) return false;
    if (pipe(fromChild) != 0) {
        close(toChild[0]); close(toChild[1]);
        return false;
    }
    pid_t pid = fork();
    if (pid < 0) {
        close(toChild[0]); close(toChild[1]);
        close(fromChild[0]); close(fromChild[1]);
        return false;
    }
    if (pid == 0) {
        dup2(toChild[0], STDIN_FILENO);
        dup2(fromChild[1], STDOUT_FILENO);
        close(toChild[0]); close(toChild[1]);
        close(fromChild[0]); close(fromChild[1]);
        /* 7z's own chatter would otherwise land in the middle of the run's
         * log; its failures are reported by the exit status. */
        int null = open("/dev/null", O_WRONLY);
        if (null >= 0) { dup2(null, STDERR_FILENO); close(null); }
        execlp("7z", "7z", "x", "-so", "--", path, (char *)NULL);
        _exit(127);
    }
    close(toChild[0]);
    close(fromChild[1]);

    /* The password, then end-of-file so 7z stops waiting for more.  It is
     * short and the pipe is empty, so this cannot block long enough to
     * deadlock against the child's output. */
    size_t len = strlen(password);
    if (write(toChild[1], password, len) < 0 ||
        write(toChild[1], "\n", 1) < 0) {
        /* Not fatal here: the child will fail and say so through its exit
         * status, which volsource_close reports. */
    }
    close(toChild[1]);

    v->f = fdopen(fromChild[0], "rb");
    if (v->f == NULL) {
        close(fromChild[0]);
        kill(pid, SIGKILL);
        waitpid(pid, NULL, 0);
        return false;
    }
    v->pid = (int)pid;
    v->encrypted = true;
    return true;
}

bool volsource_open(VolSource *v, const char *path) {
    v->f = NULL;
    v->pid = -1;
    v->encrypted = false;

    if (!volsource_is_archive(path)) {
        v->f = fopen(path, "rb");
        return v->f != NULL;
    }
    /* THERE BEFORE ASKING FOR A PASSWORD.  The extension alone makes a name
     * an archive, so a path that does not exist used to be handed to 7z and
     * come back as "wrong password?" -- which sends somebody looking for the
     * wrong thing entirely. */
    if (access(path, R_OK) != 0) {
        fprintf(stderr, "mmu: cannot read %s: %s\n", path, strerror(errno));
        return false;
    }
    const char *pw = password_for(path);
    if (pw == NULL) return false;
    return spawn_7z(v, path, pw);
}

bool volsource_close(VolSource *v) {
    bool ok = true;
    if (v->f != NULL) {
        fclose(v->f);
        v->f = NULL;
    }
    if (v->pid >= 0) {
        int status = 0;
        while (waitpid((pid_t)v->pid, &status, 0) < 0 && errno == EINTR) { }
        v->pid = -1;
        if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
            if (WIFEXITED(status) && WEXITSTATUS(status) == 127)
                fprintf(stderr, "mmu: cannot run 7z -- it is needed to read an "
                                "encrypted volume (package p7zip-full)\n");
            else
                fprintf(stderr, "mmu: 7z could not unpack the volume -- wrong "
                                "password?\n");
            /* A WRONG PASSWORD MUST NOT BE REMEMBERED.  Otherwise the second
             * mass memory reuses it, fails the same way, and the run reports
             * two mysteries instead of one. */
            g_havePassword = false;
            ok = false;
        }
    }
    return ok;
}
