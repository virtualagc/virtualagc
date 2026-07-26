/* Minimal recursive-descent JSON parser, scoped to what symbolTable.c's
 * `.sym.json`/`.symtypes.json` schemas need (linker-generated files: a
 * handful of nested objects/arrays of strings and numbers) — not a
 * general-purpose JSON library. Builds a generic tagged-value tree so
 * symbolTable.c can navigate it with simple accessor calls, matching how
 * gpc/symbolTable.coffee just walks `JSON.parse()`'s plain-object result. */
#ifndef YAGPC_JSON_H
#define YAGPC_JSON_H

#include <stdbool.h>

typedef enum {
    JSON_NULL,
    JSON_BOOL,
    JSON_NUMBER,
    JSON_STRING,
    JSON_ARRAY,
    JSON_OBJECT,
} JsonType;

typedef struct JsonValue JsonValue;

typedef struct JsonMember {
    char *key;
    JsonValue *value;
    struct JsonMember *next;
} JsonMember;

struct JsonValue {
    JsonType type;
    bool boolVal;
    double numVal;
    char *strVal;
    JsonValue **arrItems;
    int arrCount;
    JsonMember *objMembers; /* linked list, insertion order preserved */
};

/* Parses `text` (NUL-terminated). Returns NULL on a malformed document. */
JsonValue *json_parse(const char *text);
void json_free(JsonValue *v);

/* NULL if v isn't an object or has no such key. */
JsonValue *json_obj_get(const JsonValue *v, const char *key);
/* -1 if v isn't an array. */
int json_arr_count(const JsonValue *v);
/* NULL if v isn't an array or idx is out of range. */
JsonValue *json_arr_get(const JsonValue *v, int idx);

double json_as_number(const JsonValue *v, double defaultVal);
/* Never returns NULL; returns defaultVal (which may itself be NULL) if v
 * isn't a string. */
const char *json_as_string(const JsonValue *v, const char *defaultVal);
bool json_is_null_or_missing(const JsonValue *v);

#endif
