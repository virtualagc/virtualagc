/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   val.h
 * Purpose:    The dynamically-typed value used throughout the C port of
 *             ASM101S, standing in for the Python objects the original passes
 *             about.
 * Contact:    info@sandroid.org
 * Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
 *
 * WHY A DYNAMIC VALUE AND NOT A SET OF STRUCTS.  The assembler's parse trees
 * are TatSu concrete syntax trees, and the code that consumes them asks about
 * their SHAPE -- `len(x) == 3 and x[0] == '(' and x[2] == ')'` -- rather than
 * about any declared type.  A faithful port has to preserve those shapes
 * exactly, including the distinction Python draws between a list and a tuple,
 * because the consumers draw it too.  Re-typing the trees would mean
 * re-deriving every one of those tests, which is where a port of this kind
 * goes wrong.
 *
 * THE FIVE SEQUENCE KINDS ARE NOT DECORATION:
 *
 *   V_TUPLE    a Python tuple.  What a grammar rule returns when it has no
 *              named elements.
 *   V_LIST     a Python list, for which TatSu's `is_list` -- `type(o) is
 *              list`, an EXACT type test -- is true.  Accumulating CSTs and
 *              `+:` captures are these.
 *   V_CLOSURE  tatsu.contexts.closure, a list SUBCLASS.  `is_list` is false
 *              for it, which is the whole reason a `{ ... }` repetition
 *              becomes ONE element of the enclosing sequence instead of being
 *              flattened into it.  Python code outside the parser sees it as
 *              an ordinary list.
 *   V_SUBLIST  expressions.Sublist, a tuple subclass, which is how a macro
 *              argument written `(A,B,C)` is distinguished from a SETA array
 *              and from an anonymous parse-tree tuple.
 *   V_DICT     a Python dict, insertion-ordered as Python 3.7+ guarantees.
 *              Order is not cosmetic here: `describeExpression` walks an AST's
 *              items to rebuild the source text of an expression for a
 *              diagnostic, and `_define` deliberately puts the declared keys
 *              ahead of the captured ones.
 *
 * Equality follows Python's: a list equals a closure (both are lists), a tuple
 * equals a Sublist (both are tuples), and a list never equals a tuple.
 *
 * MEMORY.  Values are allocated from bump arenas and never individually freed.
 * There are two: the MAIN arena, which lives for the whole run, and the PARSE
 * arena, which is reset at the start of every `parserASM` call.  A parse
 * builds and discards a great deal of intermediate tree while backtracking,
 * and all of that is confined to the parse arena; the result is copied into
 * the main arena on the way out.  See `val_export`.
 */

#ifndef ASM101SA_VAL_H
#define ASM101SA_VAL_H

#include "common.h"

typedef enum
{
  V_NONE = 0,
  V_BOOL,
  V_INT,
  V_FLOAT,
  V_STR,
  V_BYTES,   /* Python bytearray */
  V_TUPLE,
  V_LIST,
  V_CLOSURE,
  V_SUBLIST,
  V_DICT
} VType;

typedef struct Val Val;

typedef struct
{
  const char *key;   /* interned-by-value; owned by the same arena */
  size_t keyLen;
  uint32_t hash;
  Val *value;
} DictEntry;

struct Val
{
  VType type;
  unsigned char arena;   /* 0 = main, 1 = parse.  See val_export. */
  union
  {
    int boolean;
    asmint integer;
    double real;
    struct
    {
      char *s;
      size_t len;
    } str;
    struct
    {
      unsigned char *b;
      size_t len;
      size_t cap;
    } bytes;
    struct
    {
      Val **items;
      size_t len;
      size_t cap;
    } seq;
    struct
    {
      DictEntry *entries;
      size_t len;
      size_t cap;
      int32_t *index;      /* open-addressed map into `entries`, -1 empty */
      size_t indexMask;
    } dict;
  } u;
};

/*---------------------------------------------------------------------------
 * Arenas
 */
#define ARENA_MAIN 0
#define ARENA_PARSE 1

void arena_init(void);
void *arena_alloc(int arena, size_t n);
void *arena_zalloc(int arena, size_t n);
char *arena_strdup(int arena, const char *s);
char *arena_strndup(int arena, const char *s, size_t n);
/* Discard everything in the parse arena.  Nothing allocated from it may be
   referenced afterwards; `val_export` is what carries a result out. */
void arena_reset_parse(void);
/* Which arena new values are built in.  The parser sets this to ARENA_PARSE
   for the duration of a parse. */
extern int val_arena;

/*---------------------------------------------------------------------------
 * Constructors.  Every one of these builds in `val_arena`.
 */
extern Val *V_None;
extern Val *V_True;
extern Val *V_False;

Val *val_bool(int b);
Val *val_int(asmint n);
Val *val_float(double d);
Val *val_str(const char *s);            /* copies */
Val *val_strn(const char *s, size_t n); /* copies */
Val *val_str_owned(char *s, size_t n);  /* takes an arena-allocated buffer */
Val *val_bytes(size_t len);             /* zero-filled bytearray */
Val *val_bytes_from(const unsigned char *b, size_t len);
Val *val_seq(VType type);               /* empty tuple/list/closure/sublist */
Val *val_dict(void);

/*---------------------------------------------------------------------------
 * Predicates.  These mirror the Python tests the original code performs, so
 * that a transliterated condition reads the same way.
 */
#define val_is_none(v) ((v) == NULL || (v)->type == V_NONE)
int val_is_str(const Val *v);
int val_is_int(const Val *v);   /* true for bool as well, as in Python */
int val_is_bool(const Val *v);
int val_is_float(const Val *v);
int val_is_number(const Val *v);
int val_is_dict(const Val *v);
int val_is_seq(const Val *v);        /* isinstance(v, (list, tuple)) */
int val_is_listlike(const Val *v);   /* isinstance(v, list) */
int val_is_tuplelike(const Val *v);  /* isinstance(v, tuple) */
int val_is_exact_list(const Val *v); /* TatSu's is_list(): type(o) is list */
int val_is_sublist(const Val *v);
int val_truthy(const Val *v);

/*---------------------------------------------------------------------------
 * Sequences
 */
size_t val_len(const Val *v);            /* len() for str/bytes/seq/dict */
Val *val_get(const Val *v, size_t i);    /* borrowed; NULL if out of range */
void val_set(Val *v, size_t i, Val *x);
void val_append(Val *v, Val *x);
void val_extend(Val *v, const Val *other);
void val_insert(Val *v, size_t i, Val *x);
void val_remove_at(Val *v, size_t i);
Val *val_slice(const Val *v, ptrdiff_t start, ptrdiff_t end);
Val *val_retype(const Val *v, VType type); /* shallow copy under a new kind */

/*---------------------------------------------------------------------------
 * Byte arrays (Python bytearray)
 */
void val_bytes_append (Val *v, unsigned char b);
void val_bytes_extend (Val *v, const Val *other);
void val_bytes_set (Val *v, size_t i, unsigned char b);
unsigned char val_bytes_get (const Val *v, size_t i);
/* Grow to `n` bytes, filling the new tail with `fill` repeated from the given
   phase, which is how the memory image's alternating fill pattern works. */
void val_bytes_grow (Val *v, size_t n, const unsigned char *fill,
                     size_t fillLen);
unsigned char *val_bytes_ptr (Val *v);

/*---------------------------------------------------------------------------
 * Strings
 */
const char *val_cstr(const Val *v);   /* NUL-terminated; "" for non-strings */
size_t val_strlen(const Val *v);

/*---------------------------------------------------------------------------
 * Dicts.  Keys are NUL-terminated strings; the dict copies them.
 */
Val *val_dget(const Val *d, const char *key);             /* borrowed, or NULL */
Val *val_dget_def(const Val *d, const char *key, Val *dflt);
int val_dhas(const Val *d, const char *key);
void val_dset(Val *d, const char *key, Val *v);
void val_ddel(Val *d, const char *key);
size_t val_dlen(const Val *d);
const char *val_dkey(const Val *d, size_t i);
Val *val_dval(const Val *d, size_t i);
void val_dupdate(Val *d, const Val *src);

/* Convenience accessors used constantly by the transliterated code. */
asmint val_as_int(const Val *v);
double val_as_float(const Val *v);
asmint val_dget_int(const Val *d, const char *key, asmint dflt);
const char *val_dget_str(const Val *d, const char *key, const char *dflt);
int val_dget_bool(const Val *d, const char *key, int dflt);
void val_dset_int(Val *d, const char *key, asmint n);
void val_dset_str(Val *d, const char *key, const char *s);
void val_dset_bool(Val *d, const char *key, int b);

/*---------------------------------------------------------------------------
 * Comparison, copying, formatting
 */
int val_eq(const Val *a, const Val *b);
int val_eq_str(const Val *v, const char *s);
Val *val_copy(const Val *v);      /* shallow, as copy.copy */
Val *val_deepcopy(const Val *v);  /* as copy.deepcopy */
/* Copy a parse-arena tree into the main arena, preserving sharing.  Returns
   the value unchanged if it is already in the main arena. */
Val *val_export(Val *v);
/* Python's repr(), used only in diagnostics that print one. */
char *val_repr(const Val *v);
/* Python's str() of the value, as `str(x)` in a diagnostic would give. */
char *val_str_of(const Val *v);

#endif /* ASM101SA_VAL_H */
