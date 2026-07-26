#include "json.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    const char *p;
    bool ok;
} Parser;

static JsonValue *json_alloc(JsonType type) {
    JsonValue *v = calloc(1, sizeof(JsonValue));
    v->type = type;
    return v;
}

static void skip_ws(Parser *ps) {
    while (*ps->p == ' ' || *ps->p == '\t' || *ps->p == '\n' || *ps->p == '\r') ps->p++;
}

static JsonValue *parse_value(Parser *ps);

static void fail(Parser *ps) { ps->ok = false; }

static bool expect_char(Parser *ps, char c) {
    if (*ps->p != c) {
        fail(ps);
        return false;
    }
    ps->p++;
    return true;
}

/* Appends a UTF-8 encoding of a Unicode code point to a growable buffer. */
static void append_utf8(char **buf, size_t *len, size_t *cap, unsigned int cp) {
    char tmp[4];
    int n;
    if (cp < 0x80) {
        tmp[0] = (char)cp;
        n = 1;
    } else if (cp < 0x800) {
        tmp[0] = (char)(0xC0 | (cp >> 6));
        tmp[1] = (char)(0x80 | (cp & 0x3F));
        n = 2;
    } else if (cp < 0x10000) {
        tmp[0] = (char)(0xE0 | (cp >> 12));
        tmp[1] = (char)(0x80 | ((cp >> 6) & 0x3F));
        tmp[2] = (char)(0x80 | (cp & 0x3F));
        n = 3;
    } else {
        tmp[0] = (char)(0xF0 | (cp >> 18));
        tmp[1] = (char)(0x80 | ((cp >> 12) & 0x3F));
        tmp[2] = (char)(0x80 | ((cp >> 6) & 0x3F));
        tmp[3] = (char)(0x80 | (cp & 0x3F));
        n = 4;
    }
    if (*len + (size_t)n + 1 > *cap) {
        *cap = (*cap + (size_t)n + 1) * 2;
        *buf = realloc(*buf, *cap);
    }
    memcpy(*buf + *len, tmp, (size_t)n);
    *len += (size_t)n;
}

static unsigned int hex4(Parser *ps) {
    unsigned int v = 0;
    for (int i = 0; i < 4; i++) {
        char c = *ps->p;
        int d;
        if (c >= '0' && c <= '9') d = c - '0';
        else if (c >= 'a' && c <= 'f') d = 10 + c - 'a';
        else if (c >= 'A' && c <= 'F') d = 10 + c - 'A';
        else {
            fail(ps);
            return 0;
        }
        v = v * 16 + (unsigned int)d;
        ps->p++;
    }
    return v;
}

static char *parse_string_raw(Parser *ps) {
    if (!expect_char(ps, '"')) return NULL;
    size_t cap = 16, len = 0;
    char *buf = malloc(cap);
    for (;;) {
        char c = *ps->p;
        if (c == '\0') {
            fail(ps);
            free(buf);
            return NULL;
        }
        if (c == '"') {
            ps->p++;
            break;
        }
        if (c == '\\') {
            ps->p++;
            char e = *ps->p;
            switch (e) {
                case '"': append_utf8(&buf, &len, &cap, '"'); ps->p++; break;
                case '\\': append_utf8(&buf, &len, &cap, '\\'); ps->p++; break;
                case '/': append_utf8(&buf, &len, &cap, '/'); ps->p++; break;
                case 'b': append_utf8(&buf, &len, &cap, '\b'); ps->p++; break;
                case 'f': append_utf8(&buf, &len, &cap, '\f'); ps->p++; break;
                case 'n': append_utf8(&buf, &len, &cap, '\n'); ps->p++; break;
                case 'r': append_utf8(&buf, &len, &cap, '\r'); ps->p++; break;
                case 't': append_utf8(&buf, &len, &cap, '\t'); ps->p++; break;
                case 'u': {
                    ps->p++;
                    unsigned int cp = hex4(ps);
                    if (!ps->ok) {
                        free(buf);
                        return NULL;
                    }
                    if (cp >= 0xD800 && cp <= 0xDBFF && ps->p[0] == '\\' && ps->p[1] == 'u') {
                        ps->p += 2;
                        unsigned int lo = hex4(ps);
                        if (!ps->ok) {
                            free(buf);
                            return NULL;
                        }
                        if (lo >= 0xDC00 && lo <= 0xDFFF) {
                            cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00);
                        }
                    }
                    append_utf8(&buf, &len, &cap, cp);
                    break;
                }
                default:
                    fail(ps);
                    free(buf);
                    return NULL;
            }
        } else {
            if (len + 1 >= cap) {
                cap *= 2;
                buf = realloc(buf, cap);
            }
            buf[len++] = c;
            ps->p++;
        }
    }
    if (len >= cap) {
        cap = len + 1;
        buf = realloc(buf, cap);
    }
    buf[len] = '\0';
    return buf;
}

static JsonValue *parse_object(Parser *ps) {
    JsonValue *v = json_alloc(JSON_OBJECT);
    ps->p++; /* '{' */
    skip_ws(ps);
    if (*ps->p == '}') {
        ps->p++;
        return v;
    }
    JsonMember *tail = NULL;
    for (;;) {
        skip_ws(ps);
        char *key = parse_string_raw(ps);
        if (!ps->ok) return v;
        skip_ws(ps);
        if (!expect_char(ps, ':')) {
            free(key);
            return v;
        }
        skip_ws(ps);
        JsonValue *val = parse_value(ps);
        if (!ps->ok) {
            free(key);
            return v;
        }
        JsonMember *m = calloc(1, sizeof(JsonMember));
        m->key = key;
        m->value = val;
        if (tail) {
            tail->next = m;
        } else {
            v->objMembers = m;
        }
        tail = m;
        skip_ws(ps);
        if (*ps->p == ',') {
            ps->p++;
            continue;
        }
        if (*ps->p == '}') {
            ps->p++;
            break;
        }
        fail(ps);
        break;
    }
    return v;
}

static JsonValue *parse_array(Parser *ps) {
    JsonValue *v = json_alloc(JSON_ARRAY);
    ps->p++; /* '[' */
    skip_ws(ps);
    if (*ps->p == ']') {
        ps->p++;
        return v;
    }
    int cap = 8;
    v->arrItems = malloc((size_t)cap * sizeof(JsonValue *));
    for (;;) {
        skip_ws(ps);
        JsonValue *item = parse_value(ps);
        if (!ps->ok) return v;
        if (v->arrCount >= cap) {
            cap *= 2;
            v->arrItems = realloc(v->arrItems, (size_t)cap * sizeof(JsonValue *));
        }
        v->arrItems[v->arrCount++] = item;
        skip_ws(ps);
        if (*ps->p == ',') {
            ps->p++;
            continue;
        }
        if (*ps->p == ']') {
            ps->p++;
            break;
        }
        fail(ps);
        break;
    }
    return v;
}

static JsonValue *parse_number(Parser *ps) {
    const char *start = ps->p;
    if (*ps->p == '-') ps->p++;
    while (isdigit((unsigned char)*ps->p)) ps->p++;
    if (*ps->p == '.') {
        ps->p++;
        while (isdigit((unsigned char)*ps->p)) ps->p++;
    }
    if (*ps->p == 'e' || *ps->p == 'E') {
        ps->p++;
        if (*ps->p == '+' || *ps->p == '-') ps->p++;
        while (isdigit((unsigned char)*ps->p)) ps->p++;
    }
    if (ps->p == start) {
        fail(ps);
        return NULL;
    }
    JsonValue *v = json_alloc(JSON_NUMBER);
    v->numVal = strtod(start, NULL);
    return v;
}

static JsonValue *parse_value(Parser *ps) {
    skip_ws(ps);
    char c = *ps->p;
    if (c == '{') return parse_object(ps);
    if (c == '[') return parse_array(ps);
    if (c == '"') {
        char *s = parse_string_raw(ps);
        if (!ps->ok) return NULL;
        JsonValue *v = json_alloc(JSON_STRING);
        v->strVal = s;
        return v;
    }
    if (strncmp(ps->p, "true", 4) == 0) {
        ps->p += 4;
        JsonValue *v = json_alloc(JSON_BOOL);
        v->boolVal = true;
        return v;
    }
    if (strncmp(ps->p, "false", 5) == 0) {
        ps->p += 5;
        JsonValue *v = json_alloc(JSON_BOOL);
        v->boolVal = false;
        return v;
    }
    if (strncmp(ps->p, "null", 4) == 0) {
        ps->p += 4;
        return json_alloc(JSON_NULL);
    }
    if (c == '-' || isdigit((unsigned char)c)) return parse_number(ps);
    fail(ps);
    return NULL;
}

JsonValue *json_parse(const char *text) {
    Parser ps = {text, true};
    JsonValue *v = parse_value(&ps);
    if (!ps.ok) {
        if (v) json_free(v);
        return NULL;
    }
    skip_ws(&ps);
    /* Trailing garbage is tolerated rather than rejected — this parser
     * only needs to successfully read well-formed linker output, not
     * validate arbitrary input. */
    return v;
}

void json_free(JsonValue *v) {
    if (!v) return;
    switch (v->type) {
        case JSON_STRING:
            free(v->strVal);
            break;
        case JSON_ARRAY:
            for (int i = 0; i < v->arrCount; i++) json_free(v->arrItems[i]);
            free(v->arrItems);
            break;
        case JSON_OBJECT: {
            JsonMember *m = v->objMembers;
            while (m) {
                JsonMember *next = m->next;
                free(m->key);
                json_free(m->value);
                free(m);
                m = next;
            }
            break;
        }
        default:
            break;
    }
    free(v);
}

JsonValue *json_obj_get(const JsonValue *v, const char *key) {
    if (!v || v->type != JSON_OBJECT) return NULL;
    for (JsonMember *m = v->objMembers; m; m = m->next) {
        if (strcmp(m->key, key) == 0) return m->value;
    }
    return NULL;
}

int json_arr_count(const JsonValue *v) {
    if (!v || v->type != JSON_ARRAY) return -1;
    return v->arrCount;
}

JsonValue *json_arr_get(const JsonValue *v, int idx) {
    if (!v || v->type != JSON_ARRAY || idx < 0 || idx >= v->arrCount) return NULL;
    return v->arrItems[idx];
}

double json_as_number(const JsonValue *v, double defaultVal) {
    if (!v || v->type != JSON_NUMBER) return defaultVal;
    return v->numVal;
}

const char *json_as_string(const JsonValue *v, const char *defaultVal) {
    if (!v || v->type != JSON_STRING) return defaultVal;
    return v->strVal;
}

bool json_is_null_or_missing(const JsonValue *v) {
    return v == NULL || v->type == JSON_NULL;
}
