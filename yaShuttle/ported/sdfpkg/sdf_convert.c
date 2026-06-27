/*
 * sdf_convert.c  --  Bidirectional converter between z/OS SDF PDS files
 *                    and the sdfpkg flat file format.
 *
 * Usage:
 *   sdf_convert pds2flat  <input.pds>  <output.sdf>  [member ...]
 *   sdf_convert flat2pds  <input.sdf>  <output.pds>  [member ...]
 *
 * If no member names are given, all members are converted.
 *
 * ==========================================================================
 * PDS FILE FORMAT (z/OS BPAM, as used by SDFPKG)
 * ==========================================================================
 *
 * A raw z/OS PDS binary file (as produced by Hercules, sim360, or IEBCOPY
 * unload with RECFM=U transfer) consists of:
 *
 *   1. DIRECTORY: one or more 256-byte blocks.
 *      Each block begins with a 2-byte big-endian used-bytes count
 *      (including the count itself).  Entries are packed after it.
 *      A block whose name field is 0xFF*8 marks the end of the directory.
 *
 *      Directory entry layout:
 *        [0..7]   name       8 bytes, EBCDIC, blank-padded
 *        [8..10]  TTR        3-byte relative block address of first record
 *                            (TT = relative track, R = record on that track)
 *                            In a simple sequential PDS, TTR is effectively
 *                            the 0-based block number (0, 1, 2, ...) since
 *                            each record is one block.
 *        [11]     C byte     bits 7-6: entry type (00=normal)
 *                            bits 5-3: halfwords of user data that follow
 *                            bits 2-0: note list count (unused here)
 *        [12..]   user data  (C[5:3]>>3)*2 bytes
 *
 *      For SDF members (BLDL LL=28), there are always 16 bytes of user data:
 *        [0..1]   RVL        2-byte EBCDIC revision level
 *        [2..3]   zero       (formerly TTRN1 low bytes)
 *        [4..7]   zero       (formerly TTRN2)
 *        [8..11]  zero       (formerly TTRN3)
 *        [12..13] PGELAST    last SDF page number (big-endian u16)
 *        [14..15] zero       padding
 *      Total entry length = 12 + 16 = 28 bytes.
 *      C byte value = (8 halfwords << 3) = 0x40 (bits 5-3 set to 8>>1=4? No:
 *        halfwords = 16/2 = 8, stored in bits 5-3 as the count of halfwords.
 *        bits 5-3 = 8 -> 0b01000 -> but only 3 bits, so 8 & 7 = 0!
 *        Actually: bits 5-3 store (number_of_halfwords) directly.
 *        8 halfwords -> 8 in bits 5-3. 8 in 3 bits = overflow.
 *        The IBM docs say bits 5-3 give the count of user-data halfwords,
 *        max value 7 (14 bytes) for standard entries, but SDF uses LL=28
 *        meaning 28-12=16 bytes = 8 halfwords. This is stored as 0 in bits
 *        5-3 with special handling, OR the C byte is simply 0x40 meaning
 *        the high bits indicate it's a special entry. We treat it empirically:
 *        SELECT.bal reads C byte, shifts right 3, masks with 0xC (giving 0,4,8,12),
 *        then compares with 8 to decide if there's a valid RVL. The C byte
 *        in practice for SDF entries is the number of TTRNs*8 bits. Post-CR11097
 *        there are 0 TTRNs so C=0, meaning bits 5-3=0 meaning 0 halfwords of
 *        user data. But BLDL LL=28 still returns 16 bytes after the fixed 12.
 *        Resolution: the BLDL list length LL governs how much data is returned;
 *        the C byte's halfword count field just describes TTRN data specifically.
 *        So C=0 with LL=28: 16 bytes returned, of which 0 are TTRN data, and
 *        the last 2 bytes (offset 12-13 in user data) are PGELAST.
 *
 *   2. MEMBER DATA: sequential 1680-byte fixed records (RECFM=F, LRECL=1680).
 *      Each record is one SDF page. Records are in TTR order; since this is
 *      a simple sequential PDS, TTR record number = byte_offset / 1680
 *      (after the directory blocks).
 *
 * In practice, when raw PDS files are transferred off z/OS in binary (RECFM=U),
 * the file is just the raw bytes: directory blocks followed by data records.
 * There are no IEBCOPY control records.
 *
 * ==========================================================================
 * FLAT FILE FORMAT (our sdfpkg format)
 * ==========================================================================
 *
 * [0..3]   magic      0x53 0x44 0x46 0x00  ("SDF\0")
 * [4..7]   N          member count (big-endian u32)
 * N * 20 bytes:
 *   [0..7]   name     ASCII, space-padded, no null terminator
 *   [8..11]  pages    page count = PGELAST+1 (big-endian u32)
 *   [12..19] offset   file offset of page 0 (big-endian u64)
 * Followed by member page data: N*pages*1680 bytes, concatenated in index order.
 *
 * ==========================================================================
 * EBCDIC <-> ASCII
 * ==========================================================================
 * Member names in the PDS directory are EBCDIC. We convert them to ASCII
 * for the flat file. SDF member names are always plain uppercase ASCII
 * alphanumerics and '#', so the conversion is unambiguous.
 */

#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <stdint.h>
#include <stdbool.h>
#include <ctype.h>
#include <errno.h>

/* ------------------------------------------------------------------ */
/* Constants                                                           */
/* ------------------------------------------------------------------ */

#define SDF_PAGE_SIZE       1680
#define PDS_DIR_BLOCK_SIZE   256
#define PDS_DIR_ENTRY_MIN     12   /* name(8) + TTR(3) + C(1) */
#define SDF_NAME_LEN           8
#define FLAT_MAGIC    "\x53\x44\x46\x00"   /* "SDF\0" */
#define FLAT_IDX_ENTRY_SIZE   20  /* 8+4+8 */
#define MAX_MEMBERS          500

/* ------------------------------------------------------------------ */
/* EBCDIC -> ASCII table (printable range relevant to member names)    */
/* ------------------------------------------------------------------ */

static const uint8_t ebcdic_to_ascii[256] = {
    /* 0x00-0x3F */
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    /* 0x40-0x7F */
    ' ', 0,  0,  0,  0,  0,  0,  0,  0,  0, '[', '.', '<', '(', '+', '|',
    '&', 0,  0,  0,  0,  0,  0,  0,  0,  0, '!', '$', '*', ')', ';', '^',
    '-', '/', 0,  0,  0,  0,  0,  0,  0,  0, '|', ',', '%', '_', '>', '?',
    0,  0,  0,  0,  0,  0,  0,  0,  0, '`', ':', '#', '@', '\'', '=', '"',
    /* 0x80-0xBF */
    0,  'a','b','c','d','e','f','g','h','i', 0,  0,  0,  0,  0,  0,
    0,  'j','k','l','m','n','o','p','q','r', 0,  0,  0,  0,  0,  0,
    0,  '~','s','t','u','v','w','x','y','z', 0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    /* 0xC0-0xFF */
    '{', 'A','B','C','D','E','F','G','H','I', 0,  0,  0,  0,  0,  0,
    '}', 'J','K','L','M','N','O','P','Q','R', 0,  0,  0,  0,  0,  0,
    '\\','0','S','T','U','V','W','X','Y','Z', 0,  0,  0,  0,  0,  0,
    '0','1','2','3','4','5','6','7','8','9', 0,  0,  0,  0,  0,  0,
};

static const uint8_t ascii_to_ebcdic[256] = {
    /* 0x00-0x1F */
    0x00,0x01,0x02,0x03,0x37,0x2D,0x2E,0x2F,0x16,0x05,0x25,0x0B,0x0C,0x0D,0x0E,0x0F,
    0x10,0x11,0x12,0x13,0x3C,0x3D,0x32,0x26,0x18,0x19,0x3F,0x27,0x22,0x1D,0x1E,0x1F,
    /* 0x20-0x3F (space and punctuation) */
    0x40,0x5A,0x7F,0x7B,0x5B,0x6C,0x50,0x7D,0x4D,0x5D,0x5C,0x4E,0x6B,0x60,0x4B,0x61,
    0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0x7A,0x5E,0x4C,0x7E,0x6E,0x6F,
    /* 0x40-0x5F (@ and uppercase) */
    0x7C,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,
    0xD7,0xD8,0xD9,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xBA,0xE0,0xBB,0xB0,0x6D,
    /* 0x60-0x7F (` and lowercase) */
    0x79,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x91,0x92,0x93,0x94,0x95,0x96,
    0x97,0x98,0x99,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xC0,0x4F,0xD0,0xA1,0x07,
    /* 0x80-0xFF: fill with substitution */
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
};

static void ebcdic_to_ascii_str(const uint8_t *src, char *dst, int len)
{
    for (int i = 0; i < len; i++) {
        uint8_t c = ebcdic_to_ascii[src[i]];
        dst[i] = c ? (char)c : ' ';
    }
    dst[len] = '\0';
    /* strip trailing spaces */
    for (int i = len - 1; i >= 0 && dst[i] == ' '; i--)
        dst[i] = '\0';
}

static void ascii_to_ebcdic_str(const char *src, uint8_t *dst, int len)
{
    int n = (int)strlen(src);
    if (n > len) n = len;
    for (int i = 0; i < n; i++)
        dst[i] = ascii_to_ebcdic[(uint8_t)src[i]];
    for (int i = n; i < len; i++)
        dst[i] = 0x40;   /* EBCDIC space */
}

/* ------------------------------------------------------------------ */
/* Big-endian I/O helpers                                              */
/* ------------------------------------------------------------------ */

static uint16_t be16(const uint8_t *p) {
    return (uint16_t)((p[0] << 8) | p[1]);
}
static uint32_t be32(const uint8_t *p) {
    return ((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|
           ((uint32_t)p[2]<<8)|(uint32_t)p[3];
}
static uint64_t be64(const uint8_t *p) {
    return ((uint64_t)p[0]<<56)|((uint64_t)p[1]<<48)|
           ((uint64_t)p[2]<<40)|((uint64_t)p[3]<<32)|
           ((uint64_t)p[4]<<24)|((uint64_t)p[5]<<16)|
           ((uint64_t)p[6]<<8)|(uint64_t)p[7];
}
static void put_be16(uint8_t *p, uint16_t v) {
    p[0]=(v>>8)&0xFF; p[1]=v&0xFF;
}
static void put_be32(uint8_t *p, uint32_t v) {
    p[0]=(v>>24)&0xFF; p[1]=(v>>16)&0xFF;
    p[2]=(v>>8)&0xFF;  p[3]=v&0xFF;
}
static void put_be64(uint8_t *p, uint64_t v) {
    p[0]=(v>>56)&0xFF; p[1]=(v>>48)&0xFF;
    p[2]=(v>>40)&0xFF; p[3]=(v>>32)&0xFF;
    p[4]=(v>>24)&0xFF; p[5]=(v>>16)&0xFF;
    p[6]=(v>>8)&0xFF;  p[7]=v&0xFF;
}

/* ------------------------------------------------------------------ */
/* Member descriptor                                                   */
/* ------------------------------------------------------------------ */

typedef struct {
    char     name[SDF_NAME_LEN + 1]; /* null-terminated ASCII         */
    uint32_t pgelast;                 /* last page number (0-based)    */
    uint32_t ttr;                     /* TTR from directory (big-end.) */
    /* for flat->pds: file offset of first page in flat file */
    uint64_t flat_offset;
    uint32_t page_count;              /* pgelast + 1                   */
    /* for pds2flat: byte offset of first data record in PDS file */
    long     pds_data_start;          /* set after directory is read  */
} member_t;

/* ------------------------------------------------------------------ */
/* PDS directory reader                                                */
/* ------------------------------------------------------------------ */

/*
 * Read the PDS directory from `fp` (positioned at start of file).
 * Populates `members[]` up to `max_members`.
 * Returns number of members found, or -1 on error.
 * On return, `fp` is positioned at the first data record (page 0 of
 * the first member).
 */
static int read_pds_directory(FILE *fp, member_t *members, int max_members)
{
    int count = 0;
    uint8_t block[PDS_DIR_BLOCK_SIZE];

    while (1) {
        if (fread(block, 1, PDS_DIR_BLOCK_SIZE, fp) != PDS_DIR_BLOCK_SIZE) {
            fprintf(stderr, "sdf_convert: short read on directory block\n");
            return -1;
        }

        uint16_t used = be16(block);
        if (used < 2) {
            fprintf(stderr, "sdf_convert: invalid directory block used-count %u\n", used);
            return -1;
        }

        /* Check for end-of-directory sentinel (name all 0xFF) */
        if (block[2] == 0xFF && block[3] == 0xFF && block[4] == 0xFF &&
            block[5] == 0xFF && block[6] == 0xFF && block[7] == 0xFF &&
            block[8] == 0xFF && block[9] == 0xFF)
            break;

        /* Walk entries within this block */
        int pos = 2;   /* skip the 2-byte used count */
        while (pos + PDS_DIR_ENTRY_MIN <= (int)used) {
            uint8_t *entry = block + pos;

            /* End-of-directory sentinel can also appear mid-block */
            if (entry[0] == 0xFF && entry[1] == 0xFF && entry[2] == 0xFF &&
                entry[3] == 0xFF && entry[4] == 0xFF && entry[5] == 0xFF &&
                entry[6] == 0xFF && entry[7] == 0xFF)
                goto done;

            /* Decode the C byte to find user data length */
            uint8_t c_byte      = entry[11];
            int     alias       = (c_byte >> 7) & 1;       /* bit 7: special/alias */
            int     halfwords   = (c_byte >> 3) & 0x1F;    /* bits 5-3 */
            int     user_bytes  = halfwords * 2;
            int     entry_len   = PDS_DIR_ENTRY_MIN + user_bytes;

            if (alias) {
                /* Skip alias entries -- they point to the same data */
                pos += entry_len;
                continue;
            }

            if (pos + entry_len > PDS_DIR_BLOCK_SIZE) {
                fprintf(stderr, "sdf_convert: directory entry overflows block\n");
                return -1;
            }

            /* Extract member name (EBCDIC -> ASCII) */
            char name[SDF_NAME_LEN + 1];
            ebcdic_to_ascii_str(entry, name, SDF_NAME_LEN);

            /* TTR is 3 bytes big-endian at offset 8 */
            uint32_t ttr = ((uint32_t)entry[8] << 16) |
                           ((uint32_t)entry[9] <<  8) |
                            (uint32_t)entry[10];

            /*
             * Extract PGELAST from user data.
             * SELECT.bal (CR11097): the user data area is 16 bytes:
             *   [0..1]  RVL (2 EBCDIC chars)
             *   [2..11] zeros (formerly TTRN1/2/3)
             *   [12..13] PGELAST
             * But older SDFs may have TTRN entries here; SELECT handles
             * both.  We read PGELAST from offset 12 within user data,
             * but also check if the C byte indicates TTRN data (non-zero
             * halfwords) to handle the pre-CR11097 case.
             *
             * Pre-CR11097: C byte has halfwords count > 0, meaning
             * there are TTRN entries. PGELAST is at the end of user data.
             *
             * Post-CR11097: C byte halfwords = 0, but BLDL LL=28 still
             * fills in 16 bytes of user data. We look at offset 12.
             */
            uint32_t pgelast = 0;
            if (user_bytes >= 14) {
                /* Standard SDF with user data: PGELAST at [12..13] */
                pgelast = be16(entry + 12 + 12);
            } else if (user_bytes == 0 && count == 0) {
                /*
                 * C byte says 0 halfwords, but we might be looking at a
                 * raw PDS where the directory was written with the real
                 * z/OS format including 16 bytes of user data despite C=0.
                 * Try to read PGELAST anyway from the data that follows --
                 * if BLDL returned it, it's there.
                 */
                if (pos + 12 + 14 <= PDS_DIR_BLOCK_SIZE)
                    pgelast = be16(entry + 12 + 12);
            }

            if (count < max_members) {
                strncpy(members[count].name, name, SDF_NAME_LEN);
                members[count].name[SDF_NAME_LEN] = '\0';
                members[count].pgelast    = pgelast;
                members[count].ttr        = ttr;
                members[count].page_count = pgelast + 1;
                count++;
            }

            pos += entry_len;
        }
    }

done:
    return count;
}

/*
 * In a raw PDS binary file, TTR is the 0-based block index counting
 * from the beginning of the data area (i.e., immediately after the
 * directory blocks).  We need to know how many directory blocks there
 * were; that's the current file position divided by 256.
 *
 * This function resolves each member's TTR to an absolute file offset.
 */
static void resolve_ttr_offsets(member_t *members, int count, long data_start)
{
    for (int i = 0; i < count; i++) {
        /*
         * TTR encoding: TT = 2-byte relative track number, R = 1-byte
         * record number on that track.  In a simple sequential file with
         * one record per block (which is what RECFM=F BLKSIZE=1680 gives
         * us), the absolute block number = TT * records_per_track + (R-1).
         *
         * But in a raw PDS binary dump the mapping from TTR to file offset
         * depends on the original track geometry, which we don't know.
         *
         * Fortunately, SELECT.bal (post-CR11097) doesn't use TTRs to
         * seek to individual pages at all -- it reads ALL pages sequentially
         * from page 0 to PGELAST using POINT+READ+NOTE, saving the TTR of
         * each page into FCBTTRZ. The initial FIND (using the directory TTR)
         * positions to the START of the member.
         *
         * So for pds2flat, we only need to find the start of each member.
         * Since the PDS is RECFM=F, LRECL=1680, members appear in directory
         * order in the file.  The start of member i is:
         *   data_start + sum(members[0..i-1].page_count) * 1680
         *
         * This is correct for a freshly-written PDS where members are
         * stored in directory order with no gaps.  (A real z/OS PDS may
         * have members in any order and may have gaps from deleted members,
         * but freshly-generated SDF files are sequential.)
         */
        long offset = data_start;
        for (int j = 0; j < i; j++)
            offset += (long)members[j].page_count * SDF_PAGE_SIZE;
        members[i].pds_data_start = offset;
    }
}

/* ------------------------------------------------------------------ */
/* Member filter                                                        */
/* ------------------------------------------------------------------ */

static bool member_wanted(const char *name, char **filter, int nfilter)
{
    if (nfilter == 0) return true;
    for (int i = 0; i < nfilter; i++) {
        /* Case-insensitive comparison */
        if (strcasecmp(name, filter[i]) == 0)
            return true;
    }
    return false;
}

/* ------------------------------------------------------------------ */
/* pds2flat: raw PDS -> sdfpkg flat file                              */
/* ------------------------------------------------------------------ */

static int cmd_pds2flat(const char *pds_path, const char *flat_path,
                        char **filter, int nfilter)
{
    FILE *in = fopen(pds_path, "rb");
    if (!in) {
        fprintf(stderr, "sdf_convert: cannot open '%s': %s\n",
                pds_path, strerror(errno));
        return 1;
    }

    /* Read directory */
    member_t members[MAX_MEMBERS];
    int nmembers = read_pds_directory(in, members, MAX_MEMBERS);
    if (nmembers < 0) {
        fclose(in);
        return 1;
    }
    long data_start = ftell(in);
    resolve_ttr_offsets(members, nmembers, data_start);

    printf("pds2flat: found %d member(s) in '%s'\n", nmembers, pds_path);

    /* Filter to wanted members */
    member_t wanted[MAX_MEMBERS];
    int nwanted = 0;
    for (int i = 0; i < nmembers; i++) {
        if (member_wanted(members[i].name, filter, nfilter)) {
            wanted[nwanted++] = members[i];
            printf("  member %-8s  pages=%u\n",
                   members[i].name, members[i].page_count);
        }
    }
    if (nwanted == 0) {
        fprintf(stderr, "sdf_convert: no matching members found\n");
        fclose(in);
        return 1;
    }

    /* Write flat file */
    FILE *out = fopen(flat_path, "wb");
    if (!out) {
        fprintf(stderr, "sdf_convert: cannot create '%s': %s\n",
                flat_path, strerror(errno));
        fclose(in);
        return 1;
    }

    /* Header: magic + count */
    uint8_t hdr[8];
    memcpy(hdr, FLAT_MAGIC, 4);
    put_be32(hdr + 4, (uint32_t)nwanted);
    fwrite(hdr, 1, 8, out);

    /* Index entries (placeholders; offsets filled in below) */
    long idx_start = ftell(out);
    uint8_t idx_entry[FLAT_IDX_ENTRY_SIZE];
    memset(idx_entry, 0, sizeof(idx_entry));
    for (int i = 0; i < nwanted; i++)
        fwrite(idx_entry, 1, FLAT_IDX_ENTRY_SIZE, out);

    /* Page data and index fill-in */
    uint8_t page_buf[SDF_PAGE_SIZE];
    for (int i = 0; i < nwanted; i++) {
        long page_file_offset = ftell(out);

        /* Seek to this member's data in the PDS */
        if (fseek(in, wanted[i].pds_data_start, SEEK_SET) != 0) {
            fprintf(stderr, "sdf_convert: seek error for member %s: %s\n",
                    wanted[i].name, strerror(errno));
            fclose(in); fclose(out); return 1;
        }

        /* Copy pages */
        for (uint32_t p = 0; p < wanted[i].page_count; p++) {
            if (fread(page_buf, 1, SDF_PAGE_SIZE, in) != SDF_PAGE_SIZE) {
                fprintf(stderr, "sdf_convert: short read on page %u of %s\n",
                        p, wanted[i].name);
                fclose(in); fclose(out); return 1;
            }
            fwrite(page_buf, 1, SDF_PAGE_SIZE, out);
        }

        /* Fill in index entry */
        uint8_t entry[FLAT_IDX_ENTRY_SIZE];
        /* Name: ASCII, space-padded (no null terminator in the index field) */
        memset(entry, ' ', SDF_NAME_LEN);
        int nlen = (int)strlen(wanted[i].name);
        if (nlen > SDF_NAME_LEN) nlen = SDF_NAME_LEN;
        memcpy(entry, wanted[i].name, nlen);
        put_be32(entry + 8,  wanted[i].page_count);
        put_be64(entry + 12, (uint64_t)page_file_offset);

        long cur = ftell(out);
        fseek(out, idx_start + (long)i * FLAT_IDX_ENTRY_SIZE, SEEK_SET);
        fwrite(entry, 1, FLAT_IDX_ENTRY_SIZE, out);
        fseek(out, cur, SEEK_SET);
    }

    fclose(in);
    if (fclose(out) != 0) {
        fprintf(stderr, "sdf_convert: error closing '%s': %s\n",
                flat_path, strerror(errno));
        return 1;
    }

    printf("pds2flat: wrote %d member(s) to '%s'\n", nwanted, flat_path);
    return 0;
}

/* ------------------------------------------------------------------ */
/* flat2pds: sdfpkg flat file -> raw PDS                              */
/* ------------------------------------------------------------------ */

/*
 * Build a PDS directory block containing one entry per member.
 * Returns the number of 256-byte blocks written, or -1 on error.
 *
 * We write the SDF user data in the post-CR11097 format:
 *   [0..1]  RVL = "  " (two EBCDIC spaces)
 *   [2..11] zeros
 *   [12..13] PGELAST (big-endian u16)
 *   [14..15] zeros
 * C byte = 0 (no TTRN entries; halfwords field = 0).
 * This means the raw entry is 12 bytes (no user data per C byte).
 *
 * However, to ensure SELECT.bal can find PGELAST, we set the C byte
 * halfwords field to 8 (= 16 bytes / 2), so the entry is 28 bytes.
 * This matches BLDL LL=28 exactly.
 */
static int write_pds_directory(FILE *out, member_t *members, int count,
                               long data_start_offset)
{
    /* Calculate how many directory blocks we need.
     * Each entry is 28 bytes; each block holds up to 254 bytes of entries
     * (256 - 2 for the used-count). End-of-directory sentinel = 12 bytes. */
    int entries_per_block = 254 / 28;  /* = 9 */
    int dir_blocks_needed = (count + entries_per_block - 1) / entries_per_block;
    dir_blocks_needed++;  /* +1 for the sentinel block */

    /* We need to know where data starts to set TTRs.
     * TTR is the 0-based block index from the start of the data area.
     * Since we're writing the directory first, the data area starts at
     * dir_blocks_needed * 256 bytes into the file.
     * But TTR in PDS format uses track/record encoding which depends on
     * the device geometry. For a simple sequential binary file (as used
     * by Hercules/sim360), we use a virtual geometry of 1 track = many
     * records. The simplest convention is TTR = 3-byte big-endian block
     * number from the start of the DATA AREA.
     *
     * Since SELECT uses FIND+sequential-read (not random POINT), the TTR
     * only needs to be correct enough for FIND to position to the right
     * member. In a raw binary PDS, FIND usually just seeks to the TTR
     * offset. We use the convention: TT = block_number >> 8 (track part
     * of block number treated as a flat block index / 256), R = (block_number
     * & 0xFF) + 1. With one data record per block, block_number i has
     * TTR = (i/0x100, i%0x100, 1). But sim360's PDS handling may differ.
     *
     * The safest approach: TTR encodes the absolute block number from
     * the start of the file (including directory blocks), which is what
     * sim360's submonitor expects. We set it accordingly.
     */

    uint8_t block[PDS_DIR_BLOCK_SIZE];
    int member_idx = 0;
    int blocks_written = 0;
    long page_offset = 0;  /* byte offset from start of data area */

    for (int b = 0; b < dir_blocks_needed; b++) {
        memset(block, 0, PDS_DIR_BLOCK_SIZE);
        int pos  = 2;   /* reserve space for used-bytes count */
        int used = 2;

        while (member_idx < count && pos + 28 <= PDS_DIR_BLOCK_SIZE) {
            member_t *m = &members[member_idx];

            /*
             * Compute TTR for this member.
             * Absolute block number from start of file:
             *   dir_blocks_needed blocks of directory + pages before this member
             */
            long abs_block = (long)dir_blocks_needed +
                             (page_offset / SDF_PAGE_SIZE);

            uint8_t *e = block + pos;
            /* Name in EBCDIC */
            ascii_to_ebcdic_str(m->name, e, SDF_NAME_LEN);
            /* TTR: 3 bytes, abs_block encoded as TT*R */
            uint16_t TT = (uint16_t)(abs_block >> 8);
            uint8_t  R  = (uint8_t)((abs_block & 0xFF) + 1);
            e[8]  = (TT >> 8) & 0xFF;
            e[9]  =  TT       & 0xFF;
            e[10] = R;
            /* C byte: bits 5-3 = 8 halfwords = 16 bytes of user data */
            e[11] = (8 << 3) & 0xFF;   /* = 0x40 */
            /* User data (16 bytes) */
            e[12] = 0x40; e[13] = 0x40;   /* RVL = EBCDIC "  " */
            memset(e + 14, 0, 10);         /* zeros */
            put_be16(e + 24, (uint16_t)m->pgelast);  /* PGELAST at +12 */
            memset(e + 26, 0, 2);          /* padding */

            pos   += 28;
            used  += 28;
            page_offset += (long)m->page_count * SDF_PAGE_SIZE;
            member_idx++;
        }

        /* If this is the last block or we've placed all entries,
         * add the end-of-directory sentinel if space allows */
        if (member_idx >= count && pos + 12 <= PDS_DIR_BLOCK_SIZE) {
            memset(block + pos, 0xFF, 8);   /* sentinel name = 0xFF*8 */
            memset(block + pos + 8, 0, 4);
            used += 12;
            member_idx = count + 1;  /* don't add again */
        }

        put_be16(block, (uint16_t)used);
        fwrite(block, 1, PDS_DIR_BLOCK_SIZE, out);
        blocks_written++;

        /* Stop as soon as the sentinel has been written */
        if (member_idx > count)
            break;
    }

    /* If sentinel wasn't added (all blocks full), write a sentinel block */
    if (member_idx == count) {
        memset(block, 0, PDS_DIR_BLOCK_SIZE);
        memset(block + 2, 0xFF, 8);
        memset(block + 10, 0, 4);
        put_be16(block, 14);
        fwrite(block, 1, PDS_DIR_BLOCK_SIZE, out);
        blocks_written++;
    }

    return blocks_written;
}

static int cmd_flat2pds(const char *flat_path, const char *pds_path,
                        char **filter, int nfilter)
{
    FILE *in = fopen(flat_path, "rb");
    if (!in) {
        fprintf(stderr, "sdf_convert: cannot open '%s': %s\n",
                flat_path, strerror(errno));
        return 1;
    }

    /* Read flat file header */
    uint8_t hdr[8];
    if (fread(hdr, 1, 8, in) != 8 || memcmp(hdr, FLAT_MAGIC, 4) != 0) {
        fprintf(stderr, "sdf_convert: '%s' is not a valid sdfpkg flat file\n",
                flat_path);
        fclose(in);
        return 1;
    }
    uint32_t total_members = be32(hdr + 4);
    if (total_members > MAX_MEMBERS) {
        fprintf(stderr, "sdf_convert: too many members (%u)\n", total_members);
        fclose(in);
        return 1;
    }

    /* Read index */
    member_t all_members[MAX_MEMBERS];
    for (uint32_t i = 0; i < total_members; i++) {
        uint8_t entry[FLAT_IDX_ENTRY_SIZE];
        if (fread(entry, 1, FLAT_IDX_ENTRY_SIZE, in) != FLAT_IDX_ENTRY_SIZE) {
            fprintf(stderr, "sdf_convert: short read on flat index\n");
            fclose(in); return 1;
        }
        memcpy(all_members[i].name, entry, SDF_NAME_LEN);
        all_members[i].name[SDF_NAME_LEN] = '\0';
        /* Trim trailing spaces */
        for (int j = SDF_NAME_LEN - 1;
             j >= 0 && all_members[i].name[j] == ' '; j--)
            all_members[i].name[j] = '\0';
        all_members[i].page_count   = be32(entry + 8);
        all_members[i].flat_offset  = be64(entry + 12);
        all_members[i].pgelast      = all_members[i].page_count - 1;
    }

    /* Filter */
    member_t wanted[MAX_MEMBERS];
    int nwanted = 0;
    for (uint32_t i = 0; i < total_members; i++) {
        if (member_wanted(all_members[i].name, filter, nfilter)) {
            wanted[nwanted++] = all_members[i];
            printf("flat2pds: member %-8s  pages=%u\n",
                   all_members[i].name, all_members[i].page_count);
        }
    }
    if (nwanted == 0) {
        fprintf(stderr, "sdf_convert: no matching members found\n");
        fclose(in); return 1;
    }

    FILE *out = fopen(pds_path, "wb");
    if (!out) {
        fprintf(stderr, "sdf_convert: cannot create '%s': %s\n",
                pds_path, strerror(errno));
        fclose(in); return 1;
    }

    /*
     * Write directory first (we need to know how many blocks it takes
     * to set the TTRs correctly).  We do a two-pass approach: write a
     * placeholder directory, then write the data, then rewind and
     * rewrite the directory with correct TTRs.
     */

    /* Pass 1: write placeholder directory to determine its size */
    long dir_start = ftell(out);
    int dir_blocks = write_pds_directory(out, wanted, nwanted, 0);
    long data_start = ftell(out);

    /* Pass 2: write member data */
    uint8_t page_buf[SDF_PAGE_SIZE];
    for (int i = 0; i < nwanted; i++) {
        if (fseek(in, (long)wanted[i].flat_offset, SEEK_SET) != 0) {
            fprintf(stderr, "sdf_convert: seek error for member %s\n",
                    wanted[i].name);
            fclose(in); fclose(out); return 1;
        }
        for (uint32_t p = 0; p < wanted[i].page_count; p++) {
            if (fread(page_buf, 1, SDF_PAGE_SIZE, in) != SDF_PAGE_SIZE) {
                fprintf(stderr, "sdf_convert: short read page %u of %s\n",
                        p, wanted[i].name);
                fclose(in); fclose(out); return 1;
            }
            fwrite(page_buf, 1, SDF_PAGE_SIZE, out);
        }
    }

    /* Pass 3: rewrite directory with correct TTRs */
    fseek(out, dir_start, SEEK_SET);
    write_pds_directory(out, wanted, nwanted, data_start);

    fclose(in);
    if (fclose(out) != 0) {
        fprintf(stderr, "sdf_convert: error closing '%s': %s\n",
                pds_path, strerror(errno));
        return 1;
    }

    printf("flat2pds: wrote %d member(s) and %d directory block(s) to '%s'\n",
           nwanted, dir_blocks, pds_path);
    return 0;
}

/* ------------------------------------------------------------------ */
/* flat_info: list contents of a flat file                             */
/* ------------------------------------------------------------------ */

static int cmd_flat_info(const char *flat_path)
{
    FILE *f = fopen(flat_path, "rb");
    if (!f) {
        fprintf(stderr, "sdf_convert: cannot open '%s': %s\n",
                flat_path, strerror(errno));
        return 1;
    }
    uint8_t hdr[8];
    if (fread(hdr, 1, 8, f) != 8 || memcmp(hdr, FLAT_MAGIC, 4) != 0) {
        fprintf(stderr, "sdf_convert: not a valid sdfpkg flat file\n");
        fclose(f); return 1;
    }
    uint32_t n = be32(hdr + 4);
    printf("sdfpkg flat file: %s\n", flat_path);
    printf("  members: %u\n\n", n);
    printf("  %-8s  %6s  %10s  %s\n", "NAME", "PAGES", "OFFSET", "BYTES");
    for (uint32_t i = 0; i < n; i++) {
        uint8_t e[FLAT_IDX_ENTRY_SIZE];
        if (fread(e, 1, FLAT_IDX_ENTRY_SIZE, f) != FLAT_IDX_ENTRY_SIZE) break;
        char name[SDF_NAME_LEN + 1];
        memcpy(name, e, SDF_NAME_LEN);
        name[SDF_NAME_LEN] = '\0';
        for (int j = SDF_NAME_LEN - 1; j >= 0 && name[j] == ' '; j--)
            name[j] = '\0';
        uint32_t pages  = be32(e + 8);
        uint64_t offset = be64(e + 12);
        printf("  %-8s  %6u  %10llu  %u\n",
               name, pages, (unsigned long long)offset,
               pages * SDF_PAGE_SIZE);
    }
    fclose(f);
    return 0;
}

/* ------------------------------------------------------------------ */
/* pds_info: list members in a raw PDS file                           */
/* ------------------------------------------------------------------ */

static int cmd_pds_info(const char *pds_path)
{
    FILE *f = fopen(pds_path, "rb");
    if (!f) {
        fprintf(stderr, "sdf_convert: cannot open '%s': %s\n",
                pds_path, strerror(errno));
        return 1;
    }
    member_t members[MAX_MEMBERS];
    int n = read_pds_directory(f, members, MAX_MEMBERS);
    if (n < 0) { fclose(f); return 1; }
    long data_start = ftell(f);
    resolve_ttr_offsets(members, n, data_start);

    printf("PDS file: %s\n", pds_path);
    printf("  members: %d  (directory ends at byte %ld)\n\n", n, data_start);
    printf("  %-8s  %6s  %10s  %s\n", "NAME", "PAGES", "PDS_OFFSET", "BYTES");
    for (int i = 0; i < n; i++) {
        printf("  %-8s  %6u  %10ld  %u\n",
               members[i].name,
               members[i].page_count,
               members[i].pds_data_start,
               members[i].page_count * SDF_PAGE_SIZE);
    }
    fclose(f);
    return 0;
}

/* ------------------------------------------------------------------ */
/* main                                                                 */
/* ------------------------------------------------------------------ */

static void usage(const char *prog)
{
    fprintf(stderr,
        "Usage:\n"
        "  %s pds2flat  <input.pds>  <output.sdf>  [member ...]\n"
        "  %s flat2pds  <input.sdf>  <output.pds>  [member ...]\n"
        "  %s flat_info <file.sdf>\n"
        "  %s pds_info  <file.pds>\n"
        "\n"
        "Commands:\n"
        "  pds2flat   Convert raw z/OS PDS binary to sdfpkg flat file.\n"
        "  flat2pds   Convert sdfpkg flat file to raw z/OS PDS binary.\n"
        "  flat_info  List members in a sdfpkg flat file.\n"
        "  pds_info   List members in a raw PDS binary file.\n"
        "\n"
        "If member names are supplied, only those members are converted.\n"
        "Member names are case-insensitive.\n"
        "\n"
        "The raw PDS format is a binary dump of a z/OS PDS with:\n"
        "  DSORG=PO, RECFM=F, LRECL=1680, BLKSIZE=1680\n"
        "as produced by Hercules, sim360, or IEBCOPY RECFM=U transfer.\n",
        prog, prog, prog, prog);
}

int main(int argc, char *argv[])
{
    if (argc < 2) { usage(argv[0]); return 1; }

    const char *cmd = argv[1];

    if (strcmp(cmd, "flat_info") == 0) {
        if (argc < 3) { usage(argv[0]); return 1; }
        return cmd_flat_info(argv[2]);
    }
    if (strcmp(cmd, "pds_info") == 0) {
        if (argc < 3) { usage(argv[0]); return 1; }
        return cmd_pds_info(argv[2]);
    }
    if (strcmp(cmd, "pds2flat") == 0) {
        if (argc < 4) { usage(argv[0]); return 1; }
        return cmd_pds2flat(argv[2], argv[3], argv + 4, argc - 4);
    }
    if (strcmp(cmd, "flat2pds") == 0) {
        if (argc < 4) { usage(argv[0]); return 1; }
        return cmd_flat2pds(argv[2], argv[3], argv + 4, argc - 4);
    }

    fprintf(stderr, "sdf_convert: unknown command '%s'\n", cmd);
    usage(argv[0]);
    return 1;
}
