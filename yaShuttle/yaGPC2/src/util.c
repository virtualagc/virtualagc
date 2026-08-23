#include <stdbool.h>
#include "util.h"

#include <string.h>

/* Collapse consecutive-duplicate characters in `s` (comparing against the
 * true previous *original* character, matching JS's
 * `s.replace(/(.)\1+/g,"$1")`), then drop any '0'/'1' from the result
 * (matching the chained `.replace(/[01]/g,'')`). Writes into `out`, which
 * must be at least strlen(s)+1 bytes. */
static void collapse_and_strip01(const char *s, char *out) {
    int oi = 0;
    char prev = '\0';
    bool havePrev = false;
    for (const char *p = s; *p; p++) {
        char c = *p;
        if (havePrev && c == prev) continue;
        prev = c;
        havePrev = true;
        if (c != '0' && c != '1') out[oi++] = c;
    }
    out[oi] = '\0';
}

/* Build the mask/shift/bitlen for field character `fld` by scanning the
 * whole first-halfword substring `w1` (MSB-first) — a field may occupy a
 * single run of bit positions, or several disjoint ones; either way every
 * matching position contributes to the mask, and shift is measured from
 * the rightmost (least-significant) match. Matches
 * PackedBits#getFieldMask/getFieldShft/getFieldBitlen. */
/* JS `parseInt(str, 2)`: parses the leading run of '0'/'1' characters and
 * silently ignores everything from the first non-binary character onward
 * (it does not error/throw).  getMask/getMaskedDescVal replace EVERY
 * field letter, either case, with '0' -- `.replace(/[a-zA-Z_]/g,'0')` --
 * so nothing non-binary survives to truncate on.  An earlier reference
 * replaced only lowercase, which left an uppercase field letter in the
 * string and truncated the mask there; that was faithfully reproduced
 * here, and it silently wrecked the mask of every pattern with an
 * uppercase field in its first halfword (the MSC's "0011Illlllllllll"
 * and the BCE's "0001I__________f").  The parse is kept prefix-tolerant
 * anyway, since it costs nothing. */
static uint32_t js_parse_binary_prefix(const char *s) {
    uint32_t v = 0;
    for (const char *p = s; *p == '0' || *p == '1'; p++) {
        v = (v << 1) | (uint32_t)(*p - '0');
    }
    return v;
}

static PBField make_field_desc(const char *w1, char fld) {
    int w1len = (int)strlen(w1);
    uint32_t mask = 0;
    int lastIdx = -1;
    int bitlen = 0;
    for (int i = 0; i < w1len; i++) {
        mask <<= 1;
        if (w1[i] == fld) {
            mask |= 1;
            lastIdx = i;
            bitlen++;
        }
    }
    PBField f;
    f.present = true;
    f.mask = mask;
    f.shift = (lastIdx == -1) ? w1len : (w1len - lastIdx - 1);
    f.bitlen = bitlen;
    return f;
}

PBDesc pb_make_desc(const char *s) {
    PBDesc desc;
    memset(&desc, 0, sizeof(desc));
    desc.bitLen = (int)strlen(s);

    /* w1 = first-halfword substring (portion before '/', or all of s). */
    char w1[64];
    const char *slash = strchr(s, '/');
    size_t w1len = slash ? (size_t)(slash - s) : strlen(s);
    if (w1len >= sizeof(w1)) w1len = sizeof(w1) - 1;
    memcpy(w1, s, w1len);
    w1[w1len] = '\0';

    /* mask/maskedVal: literal '0'/'1' positions vs field-placeholder
     * positions, over w1 only (PackedBits#getMask/getMaskedDescVal).
     * Built as strings (not accumulated directly) since both feed through
     * js_parse_binary_prefix, matching the JS string-then-parseInt
     * pipeline (including its truncate-on-uppercase quirk). */
    char maskStr[64], maskedStr[64];
    for (size_t i = 0; i < w1len; i++) {
        char c = w1[i];
        bool isField = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
        maskStr[i] = (c == '0' || c == '1') ? '1' : (isField ? '0' : c);
        maskedStr[i] = isField ? '0' : c;
    }
    maskStr[w1len] = '\0';
    maskedStr[w1len] = '\0';
    desc.mask = js_parse_binary_prefix(maskStr);
    desc.maskedVal = js_parse_binary_prefix(maskedStr);

    /* len/type: derived from the collapsed+stripped *full* descriptor
     * (including '/' and the second-halfword marker), matching
     * PackedBits#makeDesc's `fields` variable. */
    char fieldsFull[128];
    collapse_and_strip01(s, fieldsFull);
    char *fSlash = strchr(fieldsFull, '/');
    bool hasD = strchr(fieldsFull, 'd') != NULL;
    if (fSlash) {
        desc.len = 2;
        char after = fSlash[1];
        if (after == 'I') {
            desc.type = hasD ? PB_TYPE_SI : PB_TYPE_RI;
        } else if (after == 'X') {
            desc.type = PB_TYPE_RS;
        } else {
            desc.type = PB_TYPE_NONE;
        }
    } else {
        desc.len = 1;
        desc.type = hasD ? PB_TYPE_SRS : PB_TYPE_RR;
    }
    desc.origLen = desc.len;

    /* Per-field masks: one PBField per distinct non-0/1 character present
     * in w1 (PackedBits#makeAllFieldDescs, iterating over the
     * collapsed+stripped first-halfword string — equivalent to iterating
     * distinct characters here since make_field_desc already scans all
     * occurrences regardless of how many times we (re)build the same
     * field). */
    bool seen[PB_FIELD_TABLE_SIZE] = {0};
    for (size_t i = 0; i < w1len; i++) {
        unsigned char c = (unsigned char)w1[i];
        if (c == '0' || c == '1') continue;
        if (c >= PB_FIELD_TABLE_SIZE || seen[c]) continue;
        seen[c] = true;
        desc.field[c] = make_field_desc(w1, (char)c);
    }

    return desc;
}

uint32_t pb_get_field(uint32_t data, const PBField *f) {
    if (!f->present) return 0;
    return (data & f->mask) >> f->shift;
}

uint32_t pb_fld(const PBField *f, uint32_t v) {
    if (!f->present) return 0;
    return (v << f->shift) & f->mask;
}

uint32_t pb_set_fld(uint32_t t, int bitLen, const PBField *f, uint32_t v) {
    uint32_t full = (bitLen >= 32) ? 0xFFFFFFFFu : ((1u << bitLen) - 1u);
    uint32_t tv = t & (full ^ f->mask);
    tv = tv | ((v << f->shift) & f->mask);
    return tv;
}
