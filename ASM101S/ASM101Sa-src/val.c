/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   val.c
 * Purpose:    Implementation of the dynamic value used throughout ASM101Sa.
 * Contact:    info@sandroid.org
 * Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
 */

#include "val.h"

#include <math.h>
#include <stdarg.h>

/*===========================================================================
 * Arenas.
 *
 * Two bump allocators.  Nothing is individually freed:  the assembler runs
 * once over one module and exits, and reference counting a graph this shape --
 * parse trees stored into line properties, line properties stored into symbol
 * table entries, symbol table entries pointing back at line properties -- buys
 * nothing but the opportunity to get it wrong.
 *
 * The PARSE arena is what keeps that honest.  A single parse of one operand
 * field builds and throws away a great deal of tree as it backtracks through
 * the alternatives, and all of it lands there and is reclaimed wholesale when
 * the next parse begins.  Only the result survives, copied out by val_export.
 */

typedef struct ArenaBlock
{
  struct ArenaBlock *next;
  size_t used;
  size_t size;
  unsigned char *data;
} ArenaBlock;

typedef struct
{
  ArenaBlock *head;   /* current block */
  ArenaBlock *spare;  /* blocks retained for reuse after a reset */
  size_t blockSize;
} Arena;

static Arena arenas[2];
int val_arena = ARENA_MAIN;

#define ARENA_BLOCK_MAIN (1024u * 1024u)
#define ARENA_BLOCK_PARSE (256u * 1024u)

void
fatal (const char *fmt, ...)
{
  va_list ap;
  fflush (stdout);
  fputs ("ASM101S internal error: ", stderr);
  va_start (ap, fmt);
  vfprintf (stderr, fmt, ap);
  va_end (ap);
  fputc ('\n', stderr);
  exit (2);
}

static ArenaBlock *
arena_new_block (Arena *a, size_t need)
{
  size_t size = a->blockSize;
  ArenaBlock *b;
  if (a->spare != NULL && a->spare->size >= need)
    {
      b = a->spare;
      a->spare = b->next;
      b->used = 0;
      b->next = a->head;
      a->head = b;
      return b;
    }
  while (size < need)
    size *= 2;
  b = (ArenaBlock *) malloc (sizeof (ArenaBlock));
  if (b == NULL)
    fatal ("out of memory");
  b->data = (unsigned char *) malloc (size);
  if (b->data == NULL)
    fatal ("out of memory");
  b->size = size;
  b->used = 0;
  b->next = a->head;
  a->head = b;
  return b;
}

void
arena_init (void)
{
  arenas[ARENA_MAIN].blockSize = ARENA_BLOCK_MAIN;
  arenas[ARENA_PARSE].blockSize = ARENA_BLOCK_PARSE;
}

void *
arena_alloc (int which, size_t n)
{
  Arena *a = &arenas[which];
  ArenaBlock *b;
  void *p;
  n = (n + 15u) & ~(size_t) 15u; /* keep everything 16-byte aligned */
  b = a->head;
  if (b == NULL || b->used + n > b->size)
    b = arena_new_block (a, n);
  p = b->data + b->used;
  b->used += n;
  return p;
}

void *
arena_zalloc (int which, size_t n)
{
  void *p = arena_alloc (which, n);
  memset (p, 0, (n + 15u) & ~(size_t) 15u);
  return p;
}

char *
arena_strndup (int which, const char *s, size_t n)
{
  char *p = (char *) arena_alloc (which, n + 1);
  if (n > 0)
    memcpy (p, s, n);
  p[n] = '\0';
  return p;
}

char *
arena_strdup (int which, const char *s)
{
  return arena_strndup (which, s, strlen (s));
}

void
arena_reset_parse (void)
{
  Arena *a = &arenas[ARENA_PARSE];
  ArenaBlock *b = a->head;
  /* Keep the blocks; a parse allocates about the same amount every time and
     handing them straight back is what makes the reset free. */
  while (b != NULL)
    {
      ArenaBlock *next = b->next;
      b->used = 0;
      b->next = a->spare;
      a->spare = b;
      b = next;
    }
  a->head = NULL;
}

/*===========================================================================
 * Singletons
 */
static Val noneVal = { V_NONE, ARENA_MAIN, { 0 } };
static Val trueVal;
static Val falseVal;
Val *V_None = &noneVal;
Val *V_True = &trueVal;
Val *V_False = &falseVal;

static void
init_singletons (void)
{
  static int done = 0;
  if (done)
    return;
  done = 1;
  trueVal.type = V_BOOL;
  trueVal.arena = ARENA_MAIN;
  trueVal.u.boolean = 1;
  falseVal.type = V_BOOL;
  falseVal.arena = ARENA_MAIN;
  falseVal.u.boolean = 0;
}

static Val *
val_new (VType type)
{
  Val *v;
  init_singletons ();
  v = (Val *) arena_zalloc (val_arena, sizeof (Val));
  v->type = type;
  v->arena = (unsigned char) val_arena;
  return v;
}

/*===========================================================================
 * Constructors
 */
Val *
val_bool (int b)
{
  init_singletons ();
  return b ? V_True : V_False;
}

Val *
val_int (asmint n)
{
  Val *v = val_new (V_INT);
  v->u.integer = n;
  return v;
}

Val *
val_float (double d)
{
  Val *v = val_new (V_FLOAT);
  v->u.real = d;
  return v;
}

Val *
val_strn (const char *s, size_t n)
{
  Val *v = val_new (V_STR);
  v->u.str.s = arena_strndup (val_arena, s, n);
  v->u.str.len = n;
  return v;
}

Val *
val_str (const char *s)
{
  return val_strn (s, s == NULL ? 0 : strlen (s));
}

Val *
val_str_owned (char *s, size_t n)
{
  Val *v = val_new (V_STR);
  v->u.str.s = s;
  v->u.str.len = n;
  return v;
}

Val *
val_bytes (size_t len)
{
  Val *v = val_new (V_BYTES);
  size_t cap = len < 16 ? 16 : len;
  v->u.bytes.b = (unsigned char *) arena_zalloc (val_arena, cap);
  v->u.bytes.len = len;
  v->u.bytes.cap = cap;
  return v;
}

Val *
val_bytes_from (const unsigned char *b, size_t len)
{
  Val *v = val_bytes (len);
  if (len > 0)
    memcpy (v->u.bytes.b, b, len);
  return v;
}

Val *
val_seq (VType type)
{
  Val *v = val_new (type);
  v->u.seq.items = NULL;
  v->u.seq.len = 0;
  v->u.seq.cap = 0;
  return v;
}

Val *
val_dict (void)
{
  Val *v = val_new (V_DICT);
  return v;
}

/*===========================================================================
 * Predicates
 */
int
val_is_str (const Val *v)
{
  return v != NULL && v->type == V_STR;
}

int
val_is_bool (const Val *v)
{
  return v != NULL && v->type == V_BOOL;
}

int
val_is_int (const Val *v)
{
  /* Python: isinstance(x, int) is true for bool. */
  return v != NULL && (v->type == V_INT || v->type == V_BOOL);
}

int
val_is_float (const Val *v)
{
  return v != NULL && v->type == V_FLOAT;
}

int
val_is_number (const Val *v)
{
  return val_is_int (v) || val_is_float (v);
}

int
val_is_dict (const Val *v)
{
  return v != NULL && v->type == V_DICT;
}

int
val_is_seq (const Val *v)
{
  return v != NULL
         && (v->type == V_LIST || v->type == V_CLOSURE || v->type == V_TUPLE
             || v->type == V_SUBLIST);
}

int
val_is_listlike (const Val *v)
{
  return v != NULL && (v->type == V_LIST || v->type == V_CLOSURE);
}

int
val_is_tuplelike (const Val *v)
{
  return v != NULL && (v->type == V_TUPLE || v->type == V_SUBLIST);
}

int
val_is_exact_list (const Val *v)
{
  return v != NULL && v->type == V_LIST;
}

int
val_is_sublist (const Val *v)
{
  return v != NULL && v->type == V_SUBLIST;
}

int
val_truthy (const Val *v)
{
  if (v == NULL)
    return 0;
  switch (v->type)
    {
    case V_NONE:
      return 0;
    case V_BOOL:
      return v->u.boolean;
    case V_INT:
      return v->u.integer != 0;
    case V_FLOAT:
      return v->u.real != 0.0;
    case V_STR:
      return v->u.str.len != 0;
    case V_BYTES:
      return v->u.bytes.len != 0;
    case V_DICT:
      return v->u.dict.len != 0;
    default:
      return v->u.seq.len != 0;
    }
}

/*===========================================================================
 * Sequences
 */
size_t
val_len (const Val *v)
{
  if (v == NULL)
    return 0;
  switch (v->type)
    {
    case V_STR:
      return v->u.str.len;
    case V_BYTES:
      return v->u.bytes.len;
    case V_DICT:
      return v->u.dict.len;
    case V_LIST:
    case V_CLOSURE:
    case V_TUPLE:
    case V_SUBLIST:
      return v->u.seq.len;
    default:
      return 0;
    }
}

Val *
val_get (const Val *v, size_t i)
{
  if (!val_is_seq (v) || i >= v->u.seq.len)
    return NULL;
  return v->u.seq.items[i];
}

static void
seq_reserve (Val *v, size_t need)
{
  size_t cap;
  Val **items;
  if (need <= v->u.seq.cap)
    return;
  cap = v->u.seq.cap ? v->u.seq.cap * 2 : 4;
  while (cap < need)
    cap *= 2;
  items = (Val **) arena_alloc (v->arena, cap * sizeof (Val *));
  if (v->u.seq.len > 0)
    memcpy (items, v->u.seq.items, v->u.seq.len * sizeof (Val *));
  v->u.seq.items = items;
  v->u.seq.cap = cap;
}

void
val_set (Val *v, size_t i, Val *x)
{
  if (!val_is_seq (v) || i >= v->u.seq.len)
    fatal ("val_set out of range");
  v->u.seq.items[i] = x ? x : V_None;
}

void
val_append (Val *v, Val *x)
{
  if (!val_is_seq (v))
    fatal ("val_append on non-sequence");
  seq_reserve (v, v->u.seq.len + 1);
  v->u.seq.items[v->u.seq.len++] = x ? x : V_None;
}

void
val_extend (Val *v, const Val *other)
{
  size_t i, n;
  if (other == NULL)
    return;
  n = val_len (other);
  seq_reserve (v, v->u.seq.len + n);
  for (i = 0; i < n; i++)
    v->u.seq.items[v->u.seq.len++] = other->u.seq.items[i];
}

void
val_insert (Val *v, size_t i, Val *x)
{
  size_t k;
  if (!val_is_seq (v))
    fatal ("val_insert on non-sequence");
  if (i > v->u.seq.len)
    i = v->u.seq.len;
  seq_reserve (v, v->u.seq.len + 1);
  for (k = v->u.seq.len; k > i; k--)
    v->u.seq.items[k] = v->u.seq.items[k - 1];
  v->u.seq.items[i] = x ? x : V_None;
  v->u.seq.len++;
}

void
val_remove_at (Val *v, size_t i)
{
  size_t k;
  if (!val_is_seq (v) || i >= v->u.seq.len)
    return;
  for (k = i; k + 1 < v->u.seq.len; k++)
    v->u.seq.items[k] = v->u.seq.items[k + 1];
  v->u.seq.len--;
}

Val *
val_slice (const Val *v, ptrdiff_t start, ptrdiff_t end)
{
  Val *out;
  ptrdiff_t n, i;
  if (v == NULL)
    return NULL;
  if (v->type == V_STR)
    {
      n = (ptrdiff_t) v->u.str.len;
      if (start < 0)
        start += n;
      if (end < 0)
        end += n;
      if (start < 0)
        start = 0;
      if (end > n)
        end = n;
      if (end < start)
        end = start;
      return val_strn (v->u.str.s + start, (size_t) (end - start));
    }
  if (v->type == V_BYTES)
    {
      n = (ptrdiff_t) v->u.bytes.len;
      if (start < 0)
        start += n;
      if (end < 0)
        end += n;
      if (start < 0)
        start = 0;
      if (end > n)
        end = n;
      if (end < start)
        end = start;
      return val_bytes_from (v->u.bytes.b + start, (size_t) (end - start));
    }
  if (!val_is_seq (v))
    return NULL;
  n = (ptrdiff_t) v->u.seq.len;
  if (start < 0)
    start += n;
  if (end < 0)
    end += n;
  if (start < 0)
    start = 0;
  if (end > n)
    end = n;
  if (end < start)
    end = start;
  out = val_seq (v->type);
  for (i = start; i < end; i++)
    val_append (out, v->u.seq.items[i]);
  return out;
}

Val *
val_retype (const Val *v, VType type)
{
  Val *out = val_seq (type);
  size_t i, n = val_len (v);
  for (i = 0; i < n; i++)
    val_append (out, v->u.seq.items[i]);
  return out;
}

/*===========================================================================
 * Strings
 */
const char *
val_cstr (const Val *v)
{
  if (v == NULL || v->type != V_STR)
    return "";
  return v->u.str.s;
}

size_t
val_strlen (const Val *v)
{
  if (v == NULL || v->type != V_STR)
    return 0;
  return v->u.str.len;
}

/*===========================================================================
 * Dicts.  Insertion-ordered, exactly as Python 3.7+: `entries` is the order,
 * and `index` is an open-addressed table of positions into it.
 */
static uint32_t
str_hash (const char *s, size_t n)
{
  /* FNV-1a.  Nothing depends on the particular function; only on iteration
     order, which comes from `entries` and not from here. */
  uint32_t h = 2166136261u;
  size_t i;
  for (i = 0; i < n; i++)
    {
      h ^= (unsigned char) s[i];
      h *= 16777619u;
    }
  return h;
}

static void
dict_rehash (Val *d, size_t newSize)
{
  size_t i;
  int32_t *index;
  size_t mask = newSize - 1;
  index = (int32_t *) arena_alloc (d->arena, newSize * sizeof (int32_t));
  for (i = 0; i < newSize; i++)
    index[i] = -1;
  for (i = 0; i < d->u.dict.len; i++)
    {
      size_t slot = d->u.dict.entries[i].hash & mask;
      while (index[slot] != -1)
        slot = (slot + 1) & mask;
      index[slot] = (int32_t) i;
    }
  d->u.dict.index = index;
  d->u.dict.indexMask = mask;
}

static ptrdiff_t
dict_find (const Val *d, const char *key, size_t keyLen, uint32_t hash)
{
  size_t slot;
  if (d->u.dict.index == NULL)
    return -1;
  slot = hash & d->u.dict.indexMask;
  for (;;)
    {
      int32_t e = d->u.dict.index[slot];
      if (e == -1)
        return -1;
      if (d->u.dict.entries[e].hash == hash
          && d->u.dict.entries[e].keyLen == keyLen
          && memcmp (d->u.dict.entries[e].key, key, keyLen) == 0)
        return e;
      slot = (slot + 1) & d->u.dict.indexMask;
    }
}

Val *
val_dget (const Val *d, const char *key)
{
  ptrdiff_t i;
  if (!val_is_dict (d) || key == NULL)
    return NULL;
  i = dict_find (d, key, strlen (key), str_hash (key, strlen (key)));
  return i < 0 ? NULL : d->u.dict.entries[i].value;
}

Val *
val_dget_def (const Val *d, const char *key, Val *dflt)
{
  Val *v = val_dget (d, key);
  return v == NULL ? dflt : v;
}

int
val_dhas (const Val *d, const char *key)
{
  if (!val_is_dict (d) || key == NULL)
    return 0;
  return dict_find (d, key, strlen (key), str_hash (key, strlen (key))) >= 0;
}

void
val_dset (Val *d, const char *key, Val *v)
{
  size_t keyLen = strlen (key);
  uint32_t hash = str_hash (key, keyLen);
  ptrdiff_t i;
  if (!val_is_dict (d))
    fatal ("val_dset on non-dict");
  i = dict_find (d, key, keyLen, hash);
  if (i >= 0)
    {
      d->u.dict.entries[i].value = v ? v : V_None;
      return;
    }
  if (d->u.dict.len + 1 > d->u.dict.cap)
    {
      size_t cap = d->u.dict.cap ? d->u.dict.cap * 2 : 8;
      DictEntry *entries
          = (DictEntry *) arena_alloc (d->arena, cap * sizeof (DictEntry));
      if (d->u.dict.len > 0)
        memcpy (entries, d->u.dict.entries,
                d->u.dict.len * sizeof (DictEntry));
      d->u.dict.entries = entries;
      d->u.dict.cap = cap;
    }
  d->u.dict.entries[d->u.dict.len].key = arena_strndup (d->arena, key, keyLen);
  d->u.dict.entries[d->u.dict.len].keyLen = keyLen;
  d->u.dict.entries[d->u.dict.len].hash = hash;
  d->u.dict.entries[d->u.dict.len].value = v ? v : V_None;
  d->u.dict.len++;
  if (d->u.dict.index == NULL || d->u.dict.len * 2 > d->u.dict.indexMask + 1)
    {
      size_t want = 16;
      while (want < d->u.dict.len * 3)
        want *= 2;
      dict_rehash (d, want);
    }
  else
    {
      size_t slot = hash & d->u.dict.indexMask;
      while (d->u.dict.index[slot] != -1)
        slot = (slot + 1) & d->u.dict.indexMask;
      d->u.dict.index[slot] = (int32_t) (d->u.dict.len - 1);
    }
}

void
val_ddel (Val *d, const char *key)
{
  size_t keyLen;
  ptrdiff_t i;
  size_t k;
  if (!val_is_dict (d))
    return;
  keyLen = strlen (key);
  i = dict_find (d, key, keyLen, str_hash (key, keyLen));
  if (i < 0)
    return;
  for (k = (size_t) i; k + 1 < d->u.dict.len; k++)
    d->u.dict.entries[k] = d->u.dict.entries[k + 1];
  d->u.dict.len--;
  {
    size_t want = 16;
    while (want < (d->u.dict.len + 1) * 3)
      want *= 2;
    dict_rehash (d, want);
  }
}

size_t
val_dlen (const Val *d)
{
  return val_is_dict (d) ? d->u.dict.len : 0;
}

const char *
val_dkey (const Val *d, size_t i)
{
  if (!val_is_dict (d) || i >= d->u.dict.len)
    return NULL;
  return d->u.dict.entries[i].key;
}

Val *
val_dval (const Val *d, size_t i)
{
  if (!val_is_dict (d) || i >= d->u.dict.len)
    return NULL;
  return d->u.dict.entries[i].value;
}

void
val_dupdate (Val *d, const Val *src)
{
  size_t i;
  if (!val_is_dict (src))
    return;
  for (i = 0; i < src->u.dict.len; i++)
    val_dset (d, src->u.dict.entries[i].key, src->u.dict.entries[i].value);
}

/*===========================================================================
 * Convenience accessors
 */
asmint
val_as_int (const Val *v)
{
  if (v == NULL)
    return 0;
  if (v->type == V_INT)
    return v->u.integer;
  if (v->type == V_BOOL)
    return v->u.boolean ? 1 : 0;
  if (v->type == V_FLOAT)
    return (asmint) v->u.real;
  return 0;
}

double
val_as_float (const Val *v)
{
  if (v == NULL)
    return 0.0;
  if (v->type == V_FLOAT)
    return v->u.real;
  if (v->type == V_INT)
    return (double) v->u.integer;
  if (v->type == V_BOOL)
    return v->u.boolean ? 1.0 : 0.0;
  return 0.0;
}

asmint
val_dget_int (const Val *d, const char *key, asmint dflt)
{
  Val *v = val_dget (d, key);
  if (v == NULL || v->type == V_NONE)
    return dflt;
  return val_as_int (v);
}

const char *
val_dget_str (const Val *d, const char *key, const char *dflt)
{
  Val *v = val_dget (d, key);
  if (!val_is_str (v))
    return dflt;
  return v->u.str.s;
}

int
val_dget_bool (const Val *d, const char *key, int dflt)
{
  Val *v = val_dget (d, key);
  if (v == NULL)
    return dflt;
  return val_truthy (v);
}

void
val_dset_int (Val *d, const char *key, asmint n)
{
  val_dset (d, key, val_int (n));
}

void
val_dset_str (Val *d, const char *key, const char *s)
{
  val_dset (d, key, val_str (s));
}

void
val_dset_bool (Val *d, const char *key, int b)
{
  val_dset (d, key, val_bool (b));
}

/*===========================================================================
 * Equality.  Python's rules:  a list and a closure are both lists and compare
 * equal; a tuple and a Sublist are both tuples and compare equal; a list never
 * equals a tuple.  A bool equals the integer it stands for.
 */
int
val_eq (const Val *a, const Val *b)
{
  if (a == b)
    return 1;
  if (a == NULL || b == NULL)
    return (a == NULL || a->type == V_NONE) && (b == NULL || b->type == V_NONE);
  if (a->type == V_NONE || b->type == V_NONE)
    return a->type == b->type;
  if (val_is_number (a) && val_is_number (b))
    {
      if (val_is_float (a) || val_is_float (b))
        return val_as_float (a) == val_as_float (b);
      return val_as_int (a) == val_as_int (b);
    }
  if (a->type == V_STR && b->type == V_STR)
    return a->u.str.len == b->u.str.len
           && memcmp (a->u.str.s, b->u.str.s, a->u.str.len) == 0;
  if (a->type == V_BYTES && b->type == V_BYTES)
    return a->u.bytes.len == b->u.bytes.len
           && memcmp (a->u.bytes.b, b->u.bytes.b, a->u.bytes.len) == 0;
  if (val_is_seq (a) && val_is_seq (b))
    {
      size_t i;
      if (val_is_listlike (a) != val_is_listlike (b))
        return 0;
      if (a->u.seq.len != b->u.seq.len)
        return 0;
      for (i = 0; i < a->u.seq.len; i++)
        if (!val_eq (a->u.seq.items[i], b->u.seq.items[i]))
          return 0;
      return 1;
    }
  if (a->type == V_DICT && b->type == V_DICT)
    {
      size_t i;
      if (a->u.dict.len != b->u.dict.len)
        return 0;
      for (i = 0; i < a->u.dict.len; i++)
        {
          Val *other = val_dget (b, a->u.dict.entries[i].key);
          if (other == NULL || !val_eq (a->u.dict.entries[i].value, other))
            return 0;
        }
      return 1;
    }
  return 0;
}

int
val_eq_str (const Val *v, const char *s)
{
  if (!val_is_str (v))
    return 0;
  return strcmp (v->u.str.s, s) == 0;
}

/*===========================================================================
 * Copying
 */
Val *
val_copy (const Val *v)
{
  if (v == NULL)
    return NULL;
  switch (v->type)
    {
    case V_LIST:
    case V_CLOSURE:
    case V_TUPLE:
    case V_SUBLIST:
      return val_retype (v, v->type);
    case V_DICT:
      {
        Val *d = val_dict ();
        val_dupdate (d, v);
        return d;
      }
    case V_BYTES:
      return val_bytes_from (v->u.bytes.b, v->u.bytes.len);
    default:
      return (Val *) v; /* immutable */
    }
}

Val *
val_deepcopy (const Val *v)
{
  size_t i;
  if (v == NULL)
    return NULL;
  switch (v->type)
    {
    case V_LIST:
    case V_CLOSURE:
    case V_TUPLE:
    case V_SUBLIST:
      {
        Val *out = val_seq (v->type);
        for (i = 0; i < v->u.seq.len; i++)
          val_append (out, val_deepcopy (v->u.seq.items[i]));
        return out;
      }
    case V_DICT:
      {
        Val *out = val_dict ();
        for (i = 0; i < v->u.dict.len; i++)
          val_dset (out, v->u.dict.entries[i].key,
                    val_deepcopy (v->u.dict.entries[i].value));
        return out;
      }
    case V_BYTES:
      return val_bytes_from (v->u.bytes.b, v->u.bytes.len);
    default:
      return (Val *) v;
    }
}

/*---------------------------------------------------------------------------
 * val_export -- carry a value out of the parse arena into the main one.
 *
 * SHARING IS PRESERVED, which is not a nicety.  Memoization hands the same
 * node to every rule that asks for it at the same position, so a parse tree
 * can be a DAG rather than a tree; copying it naively duplicates the shared
 * parts once per reference and, for a deeply memoized expression grammar, does
 * so exponentially.  A small identity map keeps one copy per original.
 */
typedef struct
{
  const Val *from;
  Val *to;
} ExportPair;

/* Open-addressed, keyed by the address of the original node.  A linear scan
   was tried and is quadratic in the size of the tree, which for a heavily
   memoized expression is the whole cost of the parse. */
static ExportPair *exportMap = NULL;
static size_t exportMapMask = 0;
static size_t exportMapLen = 0;

static size_t
export_slot (const Val *v)
{
  uintptr_t p = (uintptr_t) v;
  size_t h = (size_t) ((p >> 4) * 2654435761u);
  return h & exportMapMask;
}

static void
export_grow (void)
{
  size_t oldSize = exportMapMask ? exportMapMask + 1 : 0;
  ExportPair *old = exportMap;
  size_t newSize = oldSize ? oldSize * 2 : 1024;
  size_t i;
  exportMap = (ExportPair *) calloc (newSize, sizeof (ExportPair));
  if (exportMap == NULL)
    fatal ("out of memory");
  exportMapMask = newSize - 1;
  exportMapLen = 0;
  for (i = 0; i < oldSize; i++)
    if (old[i].from != NULL)
      {
        size_t slot = export_slot (old[i].from);
        while (exportMap[slot].from != NULL)
          slot = (slot + 1) & exportMapMask;
        exportMap[slot] = old[i];
        exportMapLen++;
      }
  free (old);
}

static void
export_clear (void)
{
  if (exportMap != NULL)
    memset (exportMap, 0, (exportMapMask + 1) * sizeof (ExportPair));
  exportMapLen = 0;
}

static Val *
export_lookup (const Val *v)
{
  size_t slot;
  if (exportMap == NULL)
    return NULL;
  slot = export_slot (v);
  while (exportMap[slot].from != NULL)
    {
      if (exportMap[slot].from == v)
        return exportMap[slot].to;
      slot = (slot + 1) & exportMapMask;
    }
  return NULL;
}

static void
export_record (const Val *from, Val *to)
{
  size_t slot;
  if (exportMap == NULL || (exportMapLen + 1) * 2 > exportMapMask + 1)
    export_grow ();
  slot = export_slot (from);
  while (exportMap[slot].from != NULL)
    slot = (slot + 1) & exportMapMask;
  exportMap[slot].from = from;
  exportMap[slot].to = to;
  exportMapLen++;
}

static Val *
export_walk (const Val *v)
{
  Val *out;
  size_t i;
  if (v == NULL)
    return NULL;
  if (v->arena == ARENA_MAIN)
    return (Val *) v;
  out = export_lookup (v);
  if (out != NULL)
    return out;
  switch (v->type)
    {
    case V_LIST:
    case V_CLOSURE:
    case V_TUPLE:
    case V_SUBLIST:
      out = val_seq (v->type);
      export_record (v, out);
      for (i = 0; i < v->u.seq.len; i++)
        val_append (out, export_walk (v->u.seq.items[i]));
      return out;
    case V_DICT:
      out = val_dict ();
      export_record (v, out);
      for (i = 0; i < v->u.dict.len; i++)
        val_dset (out, v->u.dict.entries[i].key,
                  export_walk (v->u.dict.entries[i].value));
      return out;
    case V_STR:
      out = val_strn (v->u.str.s, v->u.str.len);
      export_record (v, out);
      return out;
    case V_BYTES:
      out = val_bytes_from (v->u.bytes.b, v->u.bytes.len);
      export_record (v, out);
      return out;
    case V_INT:
      out = val_int (v->u.integer);
      export_record (v, out);
      return out;
    case V_FLOAT:
      out = val_float (v->u.real);
      export_record (v, out);
      return out;
    default:
      return (Val *) v;
    }
}

Val *
val_export (Val *v)
{
  int saved = val_arena;
  Val *out;
  if (v == NULL || v->arena == ARENA_MAIN)
    return v;
  val_arena = ARENA_MAIN;
  export_clear ();
  out = export_walk (v);
  export_clear ();
  val_arena = saved;
  return out;
}

/*===========================================================================
 * repr() and str(), needed because several diagnostics interpolate one.
 */
typedef struct
{
  char *buf;
  size_t len;
  size_t cap;
} RBuf;

static void
rbuf_add (RBuf *b, const char *s, size_t n)
{
  if (b->len + n + 1 > b->cap)
    {
      size_t cap = b->cap ? b->cap * 2 : 128;
      char *p;
      while (cap < b->len + n + 1)
        cap *= 2;
      p = (char *) realloc (b->buf, cap);
      if (p == NULL)
        fatal ("out of memory");
      b->buf = p;
      b->cap = cap;
    }
  memcpy (b->buf + b->len, s, n);
  b->len += n;
  b->buf[b->len] = '\0';
}

static void
rbuf_str (RBuf *b, const char *s)
{
  rbuf_add (b, s, strlen (s));
}

static void
repr_str (RBuf *b, const char *s, size_t n)
{
  /* Python picks single quotes unless the string contains one and no double
     quote.  The diagnostics that use repr() are printed to the user, so it is
     worth getting right. */
  size_t i;
  int hasSingle = 0, hasDouble = 0;
  char q;
  for (i = 0; i < n; i++)
    {
      if (s[i] == '\'')
        hasSingle = 1;
      else if (s[i] == '"')
        hasDouble = 1;
    }
  q = (hasSingle && !hasDouble) ? '"' : '\'';
  rbuf_add (b, &q, 1);
  for (i = 0; i < n; i++)
    {
      char c = s[i];
      if (c == '\\')
        rbuf_str (b, "\\\\");
      else if (c == q)
        {
          rbuf_str (b, "\\");
          rbuf_add (b, &c, 1);
        }
      else if (c == '\n')
        rbuf_str (b, "\\n");
      else if (c == '\r')
        rbuf_str (b, "\\r");
      else if (c == '\t')
        rbuf_str (b, "\\t");
      else if ((unsigned char) c < 0x20 || (unsigned char) c == 0x7F)
        {
          char tmp[8];
          sprintf (tmp, "\\x%02x", (unsigned char) c);
          rbuf_str (b, tmp);
        }
      else
        rbuf_add (b, &c, 1);
    }
  rbuf_add (b, &q, 1);
}

void asm_format_float (char *out, size_t outSize, double d);

static void
repr_walk (RBuf *b, const Val *v, int isRepr)
{
  char tmp[64];
  size_t i;
  if (v == NULL || v->type == V_NONE)
    {
      rbuf_str (b, "None");
      return;
    }
  switch (v->type)
    {
    case V_BOOL:
      rbuf_str (b, v->u.boolean ? "True" : "False");
      break;
    case V_INT:
      {
        /* asmint is 64-bit; print it the way Python prints an int. */
        int64_t n = (int64_t) v->u.integer;
        sprintf (tmp, "%lld", (long long) n);
        rbuf_str (b, tmp);
      }
      break;
    case V_FLOAT:
      asm_format_float (tmp, sizeof (tmp), v->u.real);
      rbuf_str (b, tmp);
      break;
    case V_STR:
      if (isRepr)
        repr_str (b, v->u.str.s, v->u.str.len);
      else
        rbuf_add (b, v->u.str.s, v->u.str.len);
      break;
    case V_BYTES:
      rbuf_str (b, "bytearray(b'");
      for (i = 0; i < v->u.bytes.len; i++)
        {
          sprintf (tmp, "\\x%02x", v->u.bytes.b[i]);
          rbuf_str (b, tmp);
        }
      rbuf_str (b, "')");
      break;
    case V_TUPLE:
    case V_SUBLIST:
      rbuf_str (b, "(");
      for (i = 0; i < v->u.seq.len; i++)
        {
          if (i > 0)
            rbuf_str (b, ", ");
          repr_walk (b, v->u.seq.items[i], 1);
        }
      if (v->u.seq.len == 1)
        rbuf_str (b, ",");
      rbuf_str (b, ")");
      break;
    case V_LIST:
    case V_CLOSURE:
      rbuf_str (b, "[");
      for (i = 0; i < v->u.seq.len; i++)
        {
          if (i > 0)
            rbuf_str (b, ", ");
          repr_walk (b, v->u.seq.items[i], 1);
        }
      rbuf_str (b, "]");
      break;
    case V_DICT:
      rbuf_str (b, "{");
      for (i = 0; i < v->u.dict.len; i++)
        {
          if (i > 0)
            rbuf_str (b, ", ");
          repr_str (b, v->u.dict.entries[i].key,
                    v->u.dict.entries[i].keyLen);
          rbuf_str (b, ": ");
          repr_walk (b, v->u.dict.entries[i].value, 1);
        }
      rbuf_str (b, "}");
      break;
    default:
      break;
    }
}

char *
val_repr (const Val *v)
{
  RBuf b;
  char *out;
  b.buf = NULL;
  b.len = 0;
  b.cap = 0;
  rbuf_add (&b, "", 0);
  repr_walk (&b, v, 1);
  out = arena_strndup (ARENA_MAIN, b.buf, b.len);
  free (b.buf);
  return out;
}

char *
val_str_of (const Val *v)
{
  RBuf b;
  char *out;
  b.buf = NULL;
  b.len = 0;
  b.cap = 0;
  rbuf_add (&b, "", 0);
  repr_walk (&b, v, 0);
  out = arena_strndup (ARENA_MAIN, b.buf, b.len);
  free (b.buf);
  return out;
}

/*===========================================================================
 * Byte arrays
 */
static void
bytes_reserve (Val *v, size_t need)
{
  if (need <= v->u.bytes.cap)
    return;
  {
    size_t cap = v->u.bytes.cap ? v->u.bytes.cap : 16;
    unsigned char *p;
    while (cap < need)
      cap *= 2;
    p = (unsigned char *) arena_alloc (v->arena, cap);
    if (v->u.bytes.len > 0)
      memcpy (p, v->u.bytes.b, v->u.bytes.len);
    v->u.bytes.b = p;
    v->u.bytes.cap = cap;
  }
}

void
val_bytes_append (Val *v, unsigned char b)
{
  bytes_reserve (v, v->u.bytes.len + 1);
  v->u.bytes.b[v->u.bytes.len++] = b;
}

void
val_bytes_extend (Val *v, const Val *other)
{
  size_t n = val_len (other);
  bytes_reserve (v, v->u.bytes.len + n);
  if (n > 0)
    memcpy (v->u.bytes.b + v->u.bytes.len, other->u.bytes.b, n);
  v->u.bytes.len += n;
}

void
val_bytes_set (Val *v, size_t i, unsigned char b)
{
  if (i < v->u.bytes.len)
    v->u.bytes.b[i] = b;
}

unsigned char
val_bytes_get (const Val *v, size_t i)
{
  return i < v->u.bytes.len ? v->u.bytes.b[i] : 0;
}

/*
 * Grow to `n` bytes.  The tail takes the fill pattern, phased by the ABSOLUTE
 * position rather than by how much is being added:  the pattern is a property
 * of the address, so `--fill=C9FB` puts C9 at every even byte whatever order
 * the memory image is grown in.
 */
void
val_bytes_grow (Val *v, size_t n, const unsigned char *fill, size_t fillLen)
{
  size_t i;
  if (n <= v->u.bytes.len)
    return;
  bytes_reserve (v, n);
  for (i = v->u.bytes.len; i < n; i++)
    v->u.bytes.b[i] = fillLen ? fill[i % fillLen] : 0;
  v->u.bytes.len = n;
}

unsigned char *
val_bytes_ptr (Val *v)
{
  return v->u.bytes.b;
}
