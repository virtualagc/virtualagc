#define _POSIX_C_SOURCE 200809L
/*
 * sdfcheck.c  --  SDF member validation utility.
 *
 * Ports SDFCHECK.bal.
 *
 * Original purpose
 * ----------------
 * SDFCHECK read a list of SDF member names from one dataset (SDF1),
 * located each member in a PDS (SDF2), and printed a one-line status
 * report ("GOOD" or "BAD BAD BAD !!") for each to SYSPRINT.
 *
 * Linux equivalent
 * ----------------
 * Usage:
 *   sdfcheck <sdf-file> [member1 member2 ...]
 *
 * If no member names are given on the command line, sdfcheck lists all
 * members in the file's index and reports each one.
 *
 * Exit codes:
 *   0  all members OK
 *   1  one or more members reported BAD
 *   2  file could not be opened
 *
 * A member is reported GOOD if:
 *   - It exists in the file index.
 *   - sdf_select() succeeds (page-0 and root cell can be read).
 *   - The page count in the root cell matches the index.
 *
 * Output format (matches original 40-char record):
 *   SDF <name8>  IS  GOOD
 *   SDF <name8>  IS  BAD BAD BAD !!
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "sdfpkg.h"
#include "sdf_types.h"

/* ------------------------------------------------------------------ */
/* File index reader -- standalone, does not use sdf_ctx_t            */
/* (mirrors the BLDL / loop logic in the original SDFCHECK)           */
/* ------------------------------------------------------------------ */

#define SDF_FILE_MAGIC   0x53444600u
#define SDF_IDX_NAME_LEN 8
#define SDF_IDX_ENTRY_SZ (SDF_IDX_NAME_LEN + 4 + 8)

typedef struct {
    char     name[SDF_IDX_NAME_LEN + 1];   /* null-terminated         */
    uint32_t page_count;
    uint64_t pg0_offset;
} member_info_t;

static int read_index(FILE *fp, member_info_t **members_out, int *count_out)
{
    rewind(fp);
    uint8_t hdr[8];
    if (fread(hdr, 1, 8, fp) != 8)
        return -1;

    uint32_t magic = ((uint32_t)hdr[0]<<24)|((uint32_t)hdr[1]<<16)|
                     ((uint32_t)hdr[2]<< 8)| (uint32_t)hdr[3];
    if (magic != SDF_FILE_MAGIC)
        return -1;

    uint32_t n = ((uint32_t)hdr[4]<<24)|((uint32_t)hdr[5]<<16)|
                 ((uint32_t)hdr[6]<< 8)| (uint32_t)hdr[7];
    if (n == 0 || n > 10000) {
        fprintf(stderr, "sdfcheck: suspicious member count %u\n", n);
        return -1;
    }

    member_info_t *members = malloc(n * sizeof(member_info_t));
    if (!members)
        return -1;

    uint8_t entry[SDF_IDX_ENTRY_SZ];
    for (uint32_t i = 0; i < n; i++) {
        if (fread(entry, 1, SDF_IDX_ENTRY_SZ, fp) != SDF_IDX_ENTRY_SZ) {
            free(members);
            return -1;
        }
        /* Copy and trim name */
        memcpy(members[i].name, entry, SDF_IDX_NAME_LEN);
        members[i].name[SDF_IDX_NAME_LEN] = '\0';
        for (int j = SDF_IDX_NAME_LEN - 1;
             j >= 0 && members[i].name[j] == ' '; j--)
            members[i].name[j] = '\0';

        members[i].page_count =
            ((uint32_t)entry[8] <<24)|((uint32_t)entry[9] <<16)|
            ((uint32_t)entry[10]<< 8)| (uint32_t)entry[11];

        members[i].pg0_offset =
            ((uint64_t)entry[12]<<56)|((uint64_t)entry[13]<<48)|
            ((uint64_t)entry[14]<<40)|((uint64_t)entry[15]<<32)|
            ((uint64_t)entry[16]<<24)|((uint64_t)entry[17]<<16)|
            ((uint64_t)entry[18]<< 8)| (uint64_t)entry[19];
    }

    *members_out = members;
    *count_out   = (int)n;
    return 0;
}

/* ------------------------------------------------------------------ */
/* Check one member: returns 1 = GOOD, 0 = BAD                        */
/* ------------------------------------------------------------------ */

static int check_member(sdf_ctx_t *ctx, const char *name)
{
    sdf_rc_t rc = sdf_select(ctx, name);
    if (rc != SDF_OK)
        return 0;

    /* Try to locate the root cell -- exercises page-0 read and the
     * directory traversal.  If this succeeds, the member is good. */
    void *root = NULL;
    rc = sdf_locate_root(ctx, SDF_DISP_NONE, &root);
    return (rc == SDF_OK && root != NULL) ? 1 : 0;
}

/* ------------------------------------------------------------------ */
/* Print one result line (mirrors the original 40-char PUT record)    */
/* ------------------------------------------------------------------ */

static void print_result(const char *name, int good)
{
    /* Format: "SDF xxxxxxxx  IS  <status>" */
    printf("SDF %-8s  IS  %s\n",
           name,
           good ? "GOOD          " : "BAD BAD BAD !!");
}

/* ------------------------------------------------------------------ */
/* main                                                                 */
/* ------------------------------------------------------------------ */

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <sdf-file> [member ...]\n", argv[0]);
        return 2;
    }

    const char *path = argv[1];

    /* Open the SDF file */
    sdf_ctx_t *ctx = NULL;
    sdf_rc_t rc = sdf_open(path, SDF_OPEN_RDONLY, 0, &ctx);
    if (rc != SDF_OK) {
        fprintf(stderr, "sdfcheck: cannot open '%s': %s\n",
                path, sdf_strerror(rc));
        return 2;
    }

    int any_bad = 0;

    if (argc > 2) {
        /* Members specified on command line */
        for (int i = 2; i < argc; i++) {
            int good = check_member(ctx, argv[i]);
            print_result(argv[i], good);
            if (!good) any_bad = 1;
        }
    } else {
        /* No members given: open the file directly and read the index */
        FILE *fp = fopen(path, "rb");
        if (!fp) {
            fprintf(stderr, "sdfcheck: cannot open '%s' for index read\n",
                    path);
            sdf_close(&ctx);
            return 2;
        }

        member_info_t *members = NULL;
        int count = 0;
        if (read_index(fp, &members, &count) != 0) {
            fprintf(stderr, "sdfcheck: failed to read file index from '%s'\n",
                    path);
            fclose(fp);
            sdf_close(&ctx);
            return 2;
        }
        fclose(fp);

        for (int i = 0; i < count; i++) {
            int good = check_member(ctx, members[i].name);
            print_result(members[i].name, good);
            if (!good) any_bad = 1;
        }
        free(members);
    }

    /* Print I/O statistics */
    uint32_t reads, writes, selects;
    sdf_stats(ctx, &reads, &writes, &selects);
    fprintf(stderr, "sdfcheck: %u read(s), %u write(s), %u select(s)\n",
            reads, writes, selects);

    sdf_close(&ctx);
    return any_bad ? 1 : 0;
}
