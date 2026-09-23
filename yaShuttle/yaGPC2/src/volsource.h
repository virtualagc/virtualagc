/* Opening a mass-memory volume that may be compressed and encrypted.
 *
 * A .mmv is the flight software.  Keeping one on disk in the clear is a
 * choice, not a requirement, so a volume may instead be handed over as an
 * encrypted 7-Zip archive and named as one:
 *
 *     --mmu-model 1:OI340700-v44boot.7z
 *
 * The plaintext then exists only in this process: it is read from a pipe and
 * never written anywhere.  Nothing else in the emulator knows the difference
 * -- volsource_open() returns an ordinary FILE* either way, and the volume
 * loader reads it exactly as it always did, which it can because it reads a
 * volume start to finish and never seeks.
 *
 * WHY 7-ZIP AND NOT liblzma.  liblzma implements the .xz and .lzma STREAM
 * formats: no archive container, and no encryption of any kind.  The .7z
 * container and its AES-256 belong to 7-Zip's own LZMA SDK, which would have
 * to be vendored.  Spawning 7z instead costs a runtime dependency and buys
 * a format the owner can make and inspect with ordinary tools.
 *
 * THE PASSWORD IS NEVER AN ARGUMENT.  `7z -p<password>` would put it in the
 * process's argv, where every user on the machine can read it out of ps for
 * as long as the archive is being unpacked.  It goes down a pipe to the
 * child's standard input instead, which 7z reads when it wants one.
 */
#ifndef YAGPC_VOLSOURCE_H
#define YAGPC_VOLSOURCE_H

#include <stdbool.h>
#include <stdio.h>

/* A volume being read.  Close it with volsource_close(), which also collects
 * the child and is how a wrong password is reported -- 7z writes nothing and
 * exits non-zero, so the loader's own "short read" is a symptom rather than
 * the cause. */
typedef struct {
    FILE *f;
    int pid;            /* the 7z child, or -1 for a plain file */
    bool encrypted;
} VolSource;

/* True if `path` names an archive rather than a bare volume: a .7z extension,
 * or a file whose first six bytes are 7-Zip's signature. */
bool volsource_is_archive(const char *path);

/* Open `path` for reading.  Returns false and explains on stderr.  For an
 * archive this asks for a password the first time and remembers it, so a
 * second mass memory served from the same archive does not ask again. */
bool volsource_open(VolSource *v, const char *path);

/* Close it.  Returns false if the child failed -- which, with an encrypted
 * archive, almost always means the password was wrong. */
bool volsource_close(VolSource *v);

/* Take the password from this file descriptor (first line) rather than
 * asking.  For runs with no terminal; see --tape-password-fd. */
void volsource_password_fd(int fd);

#endif
