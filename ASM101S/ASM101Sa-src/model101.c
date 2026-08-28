/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   model101.c
 * Purpose:    Object-code generation for ASM101S, specific to the assembly
 *             language of the IBM AP-101S computer.
 * Contact:    info@sandroid.org
 *
 * ****************************************************************************
 *                                *** Warning ***
 *
 *     There are several issues with the design of the assembly language
 *     itself, or at least with the author's understanding of how to deal with
 *     its issues, that turn some aspects of the code generator's algorithm
 *     into an ad hoc mess of special cases, with no guarantee that the
 *     algorithm is generally correct.
 *
 *     A big culprit is the use of the same mnemonic in many cases for an
 *     SRS-type instruction (assembling to a halfword), an RS-type instruction
 *     of subtype AM=1 (a fullword), and an RS-type of subtype AM=0 (also a
 *     fullword).  Another is that SOME SRS and RS AM=0 instructions differ in
 *     their addressing of halfword operands versus fullword operands, with no
 *     documented way to tell which do and which do not.
 * ****************************************************************************
 *
 * STRUCTURE OF THE CODE GENERATOR
 *
 * The assembler as a whole proceeds in five passes, of which the first has
 * already occurred before `generateObjectCode` is called:  that pass resolves
 * the macro language, leaving only lines of pure AP-101S assembly language.
 * `generateObjectCode` itself has four:
 *
 *   Pass 0: parses each operand into an AST appropriate to its operation.
 *   Pass 1: processes CSECT and the other pseudo-ops that move the position
 *           pointers, resolving symbols and their addresses.  Where a mnemonic
 *           is ambiguous between SRS and RS -- which occupy different amounts
 *           of memory, and which cannot be told apart syntactically -- it
 *           looks ahead at the sizes of the displacements involved.
 *   Pass 2: repeats pass 1 using the sizes pass 1 settled on, which fixes the
 *           locations pass 1 got wrong while it was still deciding them.
 *   Pass 3: generates the object code.  It repeats -- through 4, 5 and so on
 *           -- while any EQU value or label position is still moving.
 *
 * PSEUDO-ADDRESSES
 *
 * A unique 28-bit value, left-shifted by 36 bits, is assigned as a hashcode to
 * each CSECT, DSECT and EXTRN symbol.  The values used in computing arithmetic
 * expressions are then
 *     hashcode + 32-bit offset   for a local symbol (the offset in halfwords)
 *     hashcode                   for an EXTRN symbol
 *     a 32-bit number            for a plain number
 * so that `symbol + number` keeps its hashcode and `symbol1 - symbol2` in one
 * section cancels to a number.  `unhash` separates the two again:
 *     number   = result & 0x00000000FFFFFFFF
 *     buffer   = result & 0x0000000F00000000
 *     hashcode = result & 0xFFFFFFF000000000
 * `buffer` is an unused gap between the two, and a dirty one is how overflow
 * out of the numeric part is detected.
 *
 * "SECOND OPERANDS" OF SRS AND RS INSTRUCTIONS
 *
 * For some instructions D2 is in units of halfwords and for others fullwords.
 * The AP-101S Principles of Operation does not settle which; the inferences
 * applied here are that an opcode whose most significant bit is 0 uses
 * fullword addresses and one whose bit is 1 uses halfwords, that the
 * floating-point instructions are an exception and always use halfwords, and
 * that these rules apply only to SRS and RS AM=0 -- RS AM=1 is always
 * halfwords.
 */

#include "model101.h"

#include "ebcdic.h"
#include "expressions.h"
#include "fieldparser.h"
#include "ibmhex.h"
#include "pyutil.h"
#include "tables.h"

/*===========================================================================
 * Module state
 */
Val *sects = NULL;
Val *symtab = NULL;
Val *entries = NULL;
Val *extrns = NULL;
Val *relocations = NULL;
/* STORE-PROTECT TRANSITIONS from SPON/SPOFF, as {section, offset, protect}.
   The interpretation of these pseudo-ops is INFERRED FROM USAGE -- no manual,
   POO section or linkage-editor document defines them -- so nothing here
   diagnoses against them and nothing reconciles them with the deck-level
   SET/CLEAR cards.  What the assembler records is what the source says. */
Val *protects = NULL;
Val *literalPools = NULL;
Val *metadata = NULL;
Val *ignoreOps = NULL;
unsigned char fillPattern[2] = { 0x00, 0x00 };

static int forceDisplacement = 1;
static const char *firstCSECT = NULL;
static int firstCSECTSet = 0;

/*
 * `srsCeiling` and its relatives.
 *
 * THE ORIGINAL BUILD NEVER ENCODED AN SRS *BRANCH* DISPLACEMENT ABOVE 53.
 * Measured off the as-received listings:  a two-byte encoding of a branch
 * mnemonic is the SRS form and its displacement is byte1 >> 2.  Across 803
 * such encodings in the byte-exact modules the tail runs 49:2 50:2 51:1 52:1
 * 53:1 and then stops -- 54 and 55 do not occur.
 *
 * This is applied where the instruction is ENCODED, not where
 * `optimizeScratch` decides, because those see different numbers.  Applying it
 * as a decision threshold breaks DMOD and takes DCICYC from 1983 mismatched
 * bytes to 4756.
 */
#define SRS_FLOOR 0
#define SRS_CEILING 55
#define SRS_BRANCH_CEILING 54

/* `branchAliases` holds the mnemonics that CARRY their condition and does NOT
   hold `BC`, which takes its mask as an operand.  DCICYC's case is a `BC`, so
   the limit has to name these too or it never fires where it is wanted. */
static const char *srsBranchOperations[]
    = { "BC", "BCF", "BVC", "BVCF", "BCB", "BCT", "BCTB", NULL };

static int
isSrsBranchOperation (const char *op)
{
  int i;
  for (i = 0; srsBranchOperations[i] != NULL; i++)
    if (strcmp (op, srsBranchOperations[i]) == 0)
      return 1;
  return 0;
}

/*---------------------------------------------------------------------------
 * Hashcodes
 */
typedef struct
{
  asmint hashcode;
  const char *symbol;
} HashEntry;

static HashEntry *hashcodeLookup = NULL;
static size_t hashcodeCount = 0;
static size_t hashcodeCap = 0;
static uint64_t rngState = 0;

/*
 * The hashcodes only have to be DISTINCT 28-bit values; nothing in the
 * assembler depends on which they are, and none of them reaches the listing --
 * every place a symbol's value is printed masks off bit 32 and above.  The
 * Python seeds Python's Mersenne Twister explicitly so that a run is
 * repeatable; a small counter-based generator gives the same guarantee without
 * reproducing CPython's random module.
 */
static asmint
nextHashcode (void)
{
  uint64_t x;
  rngState += 0x9E3779B97F4A7C15ULL;
  x = rngState;
  x = (x ^ (x >> 30)) * 0xBF58476D1CE4E5B9ULL;
  x = (x ^ (x >> 27)) * 0x94D049BB133111EBULL;
  x = x ^ (x >> 31);
  return (asmint) (((x % (((uint64_t) 1 << 28) - 1)) + 1) << 36);
}

asmint
getHashcode (const char *symbol)
{
  size_t i;
  asmint hashcode;
  for (i = 0; i < hashcodeCount; i++)
    if (strcmp (hashcodeLookup[i].symbol, symbol) == 0)
      return hashcodeLookup[i].hashcode;
  for (;;)
    {
      int clash = 0;
      hashcode = nextHashcode ();
      for (i = 0; i < hashcodeCount; i++)
        if (hashcodeLookup[i].hashcode == hashcode)
          {
            clash = 1;
            break;
          }
      if (!clash)
        break;
    }
  if (hashcodeCount == hashcodeCap)
    {
      hashcodeCap = hashcodeCap ? hashcodeCap * 2 : 32;
      hashcodeLookup = (HashEntry *) realloc (
          hashcodeLookup, hashcodeCap * sizeof (HashEntry));
      if (hashcodeLookup == NULL)
        fatal ("out of memory");
    }
  hashcodeLookup[hashcodeCount].hashcode = hashcode;
  hashcodeLookup[hashcodeCount].symbol = arena_strdup (ARENA_MAIN, symbol);
  hashcodeCount++;
  return hashcode;
}

const char *
hashcodeSymbol (asmint hashcode)
{
  size_t i;
  for (i = 0; i < hashcodeCount; i++)
    if (hashcodeLookup[i].hashcode == hashcode)
      return hashcodeLookup[i].symbol;
  return NULL;
}

int
unhash (asmint result, const char **sectOut, asmint *numberOut)
{
  asmint offset = ASM_AND (result, (asmint) 0xFFFFFFFFULL);
  asmint buffer = ASM_AND (result, (asmint) 0xF00000000ULL);
  asmint hashcode = ASM_AND (result, HASHCODE_MASK);
  const char *symbol;
  *sectOut = NULL;
  *numberOut = 0;
  if (hashcode == 0 || hashcode == HASHCODE_MASK)
    {
      /* A purely-numerical value. */
      *numberOut = result;
      return 1;
    }
  symbol = hashcodeSymbol (hashcode);
  if (buffer == 0 && symbol != NULL)
    {
      *sectOut = symbol;
      *numberOut = offset;
      return 1;
    }
  return 0; /* None, None */
}

/* Similar to `unhash`, but uses the `USING` list, and returns a pair B2,D2 (or
   nothing, for None,None). */
static int
unUsing (Val *using, asmint hashed, asmint *b2Out, asmint *d2Out)
{
  int haveB2 = 0;
  asmint b2 = 0, d2 = 0;
  size_t i;
  for (i = 0; i < val_len (using); i++)
    {
      Val *u = val_get (using, i);
      asmint j;
      if (val_is_none (u))
        continue;
      j = ASM_SUB (hashed, val_as_int (val_get (u, 0)));
      if (j < 0 || j > 0xFFFFFF)
        continue;
      if (!haveB2 || j < d2)
        {
          haveB2 = 1;
          b2 = (asmint) i;
          d2 = j;
        }
    }
  *b2Out = b2;
  *d2Out = d2;
  return haveB2;
}

/*
 * Rejoin the text of an AST fragment that the parser broke into tokens.  A
 * `floatNumber` keeps its sign, digits, fraction and exponent as separate
 * tokens, and anything that wants to read the number back as written has to
 * put them together again.
 */
static void
joinTokensInto (StrBuf *b, Val *ast)
{
  size_t i;
  if (val_is_none (ast))
    return;
  if (val_is_str (ast))
    {
      sb_add (b, val_cstr (ast));
      return;
    }
  if (val_is_seq (ast))
    {
      for (i = 0; i < val_len (ast); i++)
        joinTokensInto (b, val_get (ast, i));
      return;
    }
  sb_add (b, val_str_of (ast));
}

static char *
joinTokens (Val *ast)
{
  StrBuf b;
  sb_init (&b);
  joinTokensInto (&b, ast);
  return sb_take (&b);
}

const char *
rextrnSymbol (asmint value)
{
  Val *v = val_dget (metadata, "rextrns");
  size_t i;
  for (i = 0; i < val_dlen (v); i++)
    if (val_as_int (val_dval (v, i)) == value)
      return val_dkey (v, i);
  return NULL;
}

/* `rextrns` is keyed by an integer in the Python.  Here it is a dict from the
   symbol name to its hashed value, searched the other way round, which is the
   only direction anything uses. */
static void
rextrnSet (const char *symbol, asmint value)
{
  val_dset_int (val_dget (metadata, "rextrns"), symbol, value);
}

static int
rextrnHas (asmint value)
{
  return rextrnSymbol (value) != NULL;
}

void
model101_init (int forceD)
{
  forceDisplacement = forceD;
  sects = val_dict ();
  symtab = val_dict ();
  entries = val_dict ();
  extrns = val_dict ();
  relocations = val_seq (V_LIST);
  protects = val_seq (V_LIST);
  metadata = val_dict ();
  ignoreOps = val_dict ();
  rngState = 16134176201611561415ULL;
  setProgramSymtab (symtab);
  val_dset (metadata, "sects", sects);
  val_dset (metadata, "entries", entries);
  val_dset (metadata, "extrns", extrns);
  val_dset (metadata, "rextrns", val_dict ());
  val_dset (metadata, "symtab", symtab);
  val_dset (metadata, "relocations", relocations);
  val_dset (metadata, "protects", protects);
  val_dset_int (metadata, "passCount", 0);
  {
    static const char *const ignored[]
        = { "TITLE", "GBLA", "GBLB", "GBLC", "LCLA", "LCLB", "LCLC", "SETA",
            "SETB",  "SETC", "AIF",  "AGO",  "ANOP", "SPACE", "MEXIT",
            "MNOTE", "SPON", "SPOFF", "PRINT", "ACTR",
            /* COPY is acted on during macro expansion, which splices the
               copied file into the source; the COPY statement itself then
               reaches the code generator with nothing left to do.  It was the
               single commonest diagnostic in the corpus, 2332 of them in five
               modules alone.  EJECT is listing control and generates nothing
               either. */
            "COPY", "EJECT", NULL };
    int i;
    for (i = 0; ignored[i] != NULL; i++)
      val_dset (ignoreOps, ignored[i], V_True);
  }
  literalPools = val_seq (V_LIST);
  {
    /* emptyPool = ["", None, None, [], 0] */
    Val *pool = val_seq (V_LIST);
    val_append (pool, val_str (""));
    val_append (pool, V_None);
    val_append (pool, V_None);
    val_append (pool, val_seq (V_LIST));
    val_append (pool, val_int (0));
    val_append (literalPools, pool);
  }
}

size_t emptyPoolLength = 5;

static Val *
newEmptyPool (void)
{
  Val *pool = val_seq (V_LIST);
  val_append (pool, val_str (""));
  val_append (pool, V_None);
  val_append (pool, V_None);
  val_append (pool, val_seq (V_LIST));
  val_append (pool, val_int (0));
  return pool;
}

/*===========================================================================
 * Literal pools
 *
 * `literalPools` tracks what the System/360 manual calls "literals", the
 * strings like `=1234` and `=X'ABCD'` that appear within an operand and whose
 * VALUES the assembler places in a pool, using their addresses in the
 * generated instruction.  Because a pool always FOLLOWS the instructions that
 * use it, every literal is a forward reference until the pool is formed.
 *
 * There is one entry per pool, the last being the default pool at the end of
 * the first CSECT, and each entry is itself a list:
 *     0.  the name of the CSECT containing the pool
 *     1.  the byte offset within that CSECT at which the pool starts
 *     2.  the alignment (8, 4, 2) of the pool itself
 *     3.  a list of the offsets into the pool of the entries below
 *     4.  the total size of the pool, in bytes
 *     5+. one dictionary per unique literal
 *
 * Duplicates within one LTORG-to-LTORG interval are stored once; duplicates
 * across pools are stored in each.  Two literals with the same numeric value
 * but different attributes are not duplicates:  `=X'0000001234'` and
 * `=X'1234'` occupy different amounts of memory.
 */

/* Call this whenever an `LTORG` is encountered. */
static void
ltorg (const char *sect)
{
  Val *pool = val_get (literalPools, val_len (literalPools) - 1);
  val_set (pool, 0, val_str (sect));
  val_set (pool, 1, val_dget (val_dget (sects, sect), "pos1"));
  val_append (literalPools, newEmptyPool ());
}

/* Call this at the end of the source code. */
static void
endOfSource (void)
{
  Val *pool = val_get (literalPools, val_len (literalPools) - 1);
  size_t i;
  if (val_len (pool) == emptyPoolLength)
    {
      val_remove_at (literalPools, val_len (literalPools) - 1);
      return;
    }
  for (i = 0; i < val_dlen (sects); i++)
    if (!val_dget_bool (val_dval (sects, i), "dsect", 0))
      {
        val_set (pool, 0, val_str (val_dkey (sects, i)));
        val_set (pool, 1, val_dget (val_dval (sects, i), "pos1"));
        return;
      }
}

/*
 * WHICH ENTRY OF A POOL IS THIS LITERAL, by the text the source wrote --
 * `operand` -- and not by the whole attribute dictionary.
 *
 * Two literals are the same literal when they are written the same way; that
 * is what pooling means.  Comparing the dictionaries also compares `value` and
 * `assembled`, which is harmless for an absolute literal because those never
 * move, and wrong for a RELOCATABLE one because they settle over the passes.
 * `=Y(#DDCICYC)` is pooled on the collecting pass with whatever address the
 * symbol had then, and looked up on a compile pass with the address it has
 * ended up at, so it was never found.
 */
static ptrdiff_t
literalIndex (Val *pool, Val *attributes)
{
  const char *key = val_dget_str (attributes, "operand", NULL);
  size_t i;
  for (i = 0; i < val_len (pool); i++)
    {
      Val *entry = val_get (pool, i);
      if (val_is_dict (entry))
        {
          const char *other = val_dget_str (entry, "operand", NULL);
          if (key == NULL && other == NULL)
            return (ptrdiff_t) i;
          if (key != NULL && other != NULL && strcmp (key, other) == 0)
            return (ptrdiff_t) i;
        }
    }
  return -1;
}

/* `re.match(r"[A-Z@#$][A-Z0-9@#$]*", s)` -- the leading identifier, which for
   an address constant is the symbol the linker must relocate. */
static const char *
leadingIdentifier (const char *s)
{
  size_t n = 0;
  if (!((s[0] >= 'A' && s[0] <= 'Z') || s[0] == '@' || s[0] == '#'
        || s[0] == '$'))
    return NULL;
  n = 1;
  while ((s[n] >= 'A' && s[n] <= 'Z') || (s[n] >= '0' && s[n] <= '9')
         || s[n] == '@' || s[n] == '#' || s[n] == '$')
    n++;
  return arena_strndup (ARENA_MAIN, s, n);
}

#define H_MAX ((asmint) 1 << 15)
#define F_MAX ((asmint) 1 << 31)

/* Evaluates the AST of a literal, returning an attributes dictionary for the
   literal pool, or NULL. */
static Val *
evalLiteralAttributes (Val *properties, Val *ast, Val *symtabArg)
{
  Val *l2 = evalArithmeticExpression (val_dget (ast, "L2"), NULL, properties,
                                      symtabArg, NULL, 0);
  Val *lit;
  const char *t;
  Val *scale;
  int numerical = 1;
  asmint length = 0;
  Val *value = NULL;
  Val *bytes = NULL;
  StrBuf operand;
  const char *zsymbol = NULL;
  Val *attributes;

  if (l2 == NULL)
    return NULL;
  lit = val_get (val_dget (ast, "L2"), 0);
  t = val_cstr (val_get (val_dget (lit, "T"), 0));
  scale = val_int (1);
  if (val_dhas (lit, "S") && val_len (val_dget (lit, "S")) > 0)
    {
      /* The scale modifier arrives as a captured LIST, the same shape as
         `ast["T"]` and `ast[t]`, which are both indexed with [0]. */
      Val *s = val_dget (lit, "S");
      asmint n;
      if (val_is_seq (s))
        s = val_get (s, 0);
      if (!py_parse_int (val_cstr (s), &n))
        {
          ERROR (properties, "Cannot evaluate the scale modifier of a literal");
          return NULL;
        }
      {
        double p = 1.0;
        asmint k;
        for (k = 0; k < (n < 0 ? -n : n); k++)
          p *= 2.0;
        scale = val_float (n < 0 ? p : 1.0 / p);
      }
    }

  if (strcmp (t, "C") == 0)
    {
      /* Unreachable:  a character literal cannot be evaluated as an arithmetic
         expression, so `l2` is None above and this function has already
         returned.  The Python's own branch here references an undefined name
         and would raise if it were ever entered. */
      return NULL;
    }
  else if (strcmp (t, "B") == 0)
    {
      length = (asmint) ((val_strlen (val_get (val_dget (lit, t), 0)) + 7) / 8);
      value = l2;
    }
  else if (strcmp (t, "X") == 0)
    {
      length = (asmint) ((val_strlen (val_get (val_dget (lit, t), 0)) + 1) / 2);
      value = l2;
    }
  else if (strcmp (t, "H") == 0 || strcmp (t, "F") == 0)
    {
      asmint limit;
      if (strcmp (t, "H") == 0)
        {
          length = 2;
          limit = H_MAX;
        }
      else
        {
          length = 4;
          limit = F_MAX;
        }
      if (val_is_float (scale) || val_is_float (l2))
        {
          double v = val_as_float (l2) * val_as_float (scale);
          if (v > -1.0 && v < 1.0)
            {
              v *= (double) limit;
              if (v >= (double) limit)
                v = (double) (limit - 1);
              else if (v <= -(double) limit)
                v = (double) (-limit + 1);
            }
          value = val_int (py_round (v));
        }
      else
        {
          asmint v = ASM_MUL (val_as_int (l2), val_as_int (scale));
          /* An integer is never strictly between -1 and 1 unless it is zero,
             and zero times the field width is still zero, so the fractional
             path below changes nothing for it. */
          value = val_int (v);
        }
    }
  else if (strcmp (t, "E") == 0)
    {
      uint32_t msw, lsw;
      Dec dscale;
      char *text = joinTokens (val_get (val_dget (lit, "E"), 0));
      length = 4;
      if (val_is_float (scale))
        dec_from_double (&dscale, val_as_float (scale));
      else
        dec_from_int (&dscale, 1);
      toFloatIBM (text, &dscale, &msw, &lsw);
      /* Rounded to short precision, not truncated. */
      value = val_int ((asmint) roundFloatIBMShort (msw, lsw));
    }
  else if (strcmp (t, "D") == 0)
    {
      uint32_t msw, lsw;
      Dec dscale;
      char *text = joinTokens (val_get (val_dget (lit, "D"), 0));
      length = 8;
      if (val_is_float (scale))
        dec_from_double (&dscale, val_as_float (scale));
      else
        dec_from_int (&dscale, 1);
      toFloatIBM (text, &dscale, &msw, &lsw);
      value = val_int ((asmint) (((asmuint) msw << 32) | (asmuint) lsw));
    }
  else if (strcmp (t, "Y") == 0)
    {
      const char *ySect;
      asmint yOffset;
      length = 2;
      /* Resolved the way `DC Y(...)` resolves its own operand:  a relocatable
         value arrives hashed, and the halfword wanted is the offset within its
         section plus wherever that section landed. */
      value = l2;
      if (unhash (val_as_int (l2), &ySect, &yOffset) && ySect != NULL)
        value = val_int (
            ASM_ADD (yOffset, val_dget_int (val_dget (sects, ySect), "offset", 0)));
    }
  else if (strcmp (t, "Z") == 0)
    {
      length = 4;
      value = l2;
    }
  else
    {
      asmError (properties,
                py_format ("Unknown constant-type specifier '%s'", t), 255);
      return NULL;
    }

  if (numerical)
    {
      asmint v = val_as_int (value);
      asmint i;
      bytes = val_bytes ((size_t) length);
      for (i = length - 1; i >= 0; i--)
        {
          bytes->u.bytes.b[i] = (unsigned char) (v & 0xFF);
          v >>= 8;
        }
    }

  if (val_dhas (lit, "L") && val_len (val_dget (lit, "L")) > 0)
    {
      /* Note that the length modifier is treated as a count of HALFWORDS
         rather than bytes, in contradiction to the System/360 manual. */
      asmint lm = 0;
      py_parse_int (val_cstr (val_get (val_dget (lit, "L"), 0)), &lm);
      length = 2 * lm;
      if (length < (asmint) val_len (bytes))
        bytes = numerical ? val_slice (bytes, -(ptrdiff_t) length,
                                       (ptrdiff_t) val_len (bytes))
                          : val_slice (bytes, 0, (ptrdiff_t) length);
      while (length > (asmint) val_len (bytes))
        {
          Val *grown = val_bytes (val_len (bytes) + 1);
          if (numerical)
            {
              grown->u.bytes.b[0] = 0;
              memcpy (grown->u.bytes.b + 1, bytes->u.bytes.b,
                      val_len (bytes));
            }
          else
            {
              memcpy (grown->u.bytes.b, bytes->u.bytes.b, val_len (bytes));
              grown->u.bytes.b[val_len (bytes)] = 0x40; /* EBCDIC space */
            }
          bytes = grown;
        }
    }

  sb_init (&operand);
  sb_addf (&operand, "=%s", t);
  if (val_len (val_dget (lit, "L")) > 0)
    sb_addf (&operand, "L%s", val_cstr (val_get (val_dget (lit, "L"), 0)));
  if (val_dhas (lit, "S") && val_len (val_dget (lit, "S")) > 0)
    sb_addf (&operand, "S%s", val_cstr (val_get (val_dget (lit, "S"), 0)));
  if (strcmp (t, "Z") == 0)
    {
      /* A Z literal has no quoted value; it carries an address expression and
         a flags expression, and the pool key has to distinguish two literals
         that differ only in those.  The leading identifier of the address
         expression is the symbol the linker must relocate. */
      char *a1 = describeExpression (val_dget (lit, "A1"));
      sb_addf (&operand, "(,%s,%s)", a1,
               describeExpression (val_dget (lit, "A2")));
      zsymbol = leadingIdentifier (a1);
    }
  else if (strcmp (t, "Y") == 0)
    {
      /* A Y literal is parenthesised too, and its value is an EXPRESSION, so
         the pool key has to be written the way the source writes it. */
      sb_addf (&operand, "(%s)",
               describeExpression (val_get (val_dget (lit, "Y"), 0)));
    }
  else
    sb_addf (&operand, "'%s'", joinTokens (val_get (val_dget (lit, t), 0)));

  attributes = val_dict ();
  val_dset (attributes, "value", l2);
  val_dset_str (attributes, "T", t);
  val_dset_int (attributes, "L", length);
  val_dset (attributes, "operand", val_str (sb_take (&operand)));
  val_dset (attributes, "assembled", bytes);
  if (zsymbol != NULL)
    val_dset_str (attributes, "zsymbol", zsymbol);
  return attributes;
}

/*===========================================================================
 * `optimizeScratch` analyses the "scratch" structures created during the
 * collecting pass, to resolve the ambiguity in how those mnemonics that could
 * be either SRS or RS instructions are coded.  It returns the number of
 * instructions it shortened, so the caller can iterate to a fixed point
 * instead of guessing a repeat count.
 */
static asmint adjustments;
static const char *optSect;

static void
optAdjust (Val *scratch, Val *properties, size_t i)
{
  Val *entry = val_get (scratch, i);
  Val *lastEntry;
  size_t j;
  adjustments += 1;
  val_dset_int (entry, "length", 2);
  val_dset_int (properties, "length", 2);
  val_dset_bool (entry, "ambiguous", 0);
  lastEntry = entry;
  for (j = i + 1; j < val_len (scratch); j++)
    {
      Val *entry2 = val_get (scratch, j);
      asmint nextPos1, nextPos2;
      if (strcmp (optSect, val_dget_str (entry2, "sect", "")) != 0)
        continue;
      nextPos1 = ASM_ADD (val_dget_int (lastEntry, "pos1", 0),
                          val_dget_int (lastEntry, "length", 0));
      lastEntry = entry2;
      {
        Val *p2 = val_dget (entry2, "properties");
        if (val_dhas (p2, "alignment"))
          {
            asmint alignment = val_dget_int (p2, "alignment", 0);
            if (alignment > 2)
              {
                asmint rem = nextPos1 % alignment;
                if (rem > 0)
                  nextPos1 += alignment - rem;
              }
          }
        nextPos2 = nextPos1 / 2;
        val_dset_int (entry2, "pos1", nextPos1);
        val_dset_int (p2, "pos1", nextPos1);
      }
      val_dset_int (entry2, "pos2", nextPos2);
      val_dset_str (entry2, "debug", py_format ("%05X", (unsigned) nextPos2));
      if (val_dhas (entry2, "name")
          && val_dhas (symtab, val_dget_str (entry2, "name", "")))
        {
          /* A labelled statement whose label is not in the symbol table YET.
             This pass only slides locations about, and a symbol with no entry
             has no location to slide; `EQU FCMBEND-FCMBSTRT` is the shape that
             gets here.  Indexing unconditionally was a KeyError that killed
             nine OI301700 modules outright. */
          const char *name = val_dget_str (entry2, "name", "");
          Val *sym2 = val_dget (symtab, name);
          val_dset_int (sym2, "address", nextPos2);
          val_dset_int (sym2, "value",
                        ASM_AND (val_dget_int (sym2, "value", 0), HASHCODE_MASK)
                            | nextPos2);
          val_dset_str (sym2, "debug", py_format ("%05X", (unsigned) nextPos2));
        }
    }
}

/*
 * A NEGATIVE SECTION-RELATIVE VALUE BORROWS OUT OF THE HASHCODE.  A hashcode
 * is `random << 36`, so a bare symbol has zeros below bit 36 and subtracting
 * from it borrows out of the HASHCODE itself:  `hash - n` is
 * `((random-1) << 36) + (2**36 - n)`.  `unhash` therefore finds no section,
 * and the symbol keeps address 0.
 *
 * PCGEN writes `&CURLABL EQU *-FIOBUS&STRTBUS` with `FIOBUS1 EQU 2`, making
 * FIOADCNS's FIOIPR the virtual base two halfwords BEFORE the section -- and
 * it was exported as `LD FIOIPR addr=0`.  THE FORMAT EXPECTS IT:  lnk101's
 * objModule.py stores a negative section-relative offset as a 24-bit two's
 * complement and its comment names this very symbol.
 */
static int
unhashBorrowed (asmint v, int requireSect, const char **sectOut,
                asmint *magnitudeOut)
{
  asmint hash = ASM_ADD (ASM_AND (v, HASHCODE_MASK), (asmint) 1 << 36);
  asmint low = ASM_AND (v, (asmint) 0xFFFFFFFFFULL);
  const char *symbol = hashcodeSymbol (hash);
  if (symbol == NULL || low < ((asmint) 1 << 35))
    return 0;
  if (requireSect && !val_dhas (sects, symbol))
    return 0;
  {
    asmint d = low - ((asmint) 1 << 36);
    *sectOut = symbol;
    *magnitudeOut = d < 0 ? -d : d;
  }
  return 1;
}

static asmint
optimizeScratch (void)
{
  size_t si;
  size_t literalPoolNumber = 0;
  adjustments = 0;

  for (si = 0; si < val_dlen (sects); si++)
    {
      Val *scratch;
      size_t i;
      optSect = val_dkey (sects, si);
      scratch = val_dget (val_dval (sects, si), "scratch");
      for (i = 0; i < val_len (scratch); i++)
        {
          Val *entry = val_get (scratch, i);
          Val *properties = val_dget (entry, "properties");
          const char *operation = val_dget_str (properties, "operation", "");
          Val *ast;
          asmint d2 = 0;
          int haveD2 = 0;
          const char *section;
          asmint value;
          int unhashed;

          if (strcmp (operation, "EQU") == 0)
            {
              Val *v;
              const char *n;
              const char *s;
              asmint d;
              if (!val_dhas (entry, "name"))
                continue;
              if (val_is_none (val_dget (properties, "ast")))
                {
                  /* The EQU's operand did not parse, which was diagnosed where
                     it was parsed.  Subscripting the None here turned that
                     diagnosis into a traceback. */
                  continue;
                }
              v = evalArithmeticExpression (
                  val_dget (val_dget (properties, "ast"), "v"), NULL, properties,
                  symtab,
                  val_int (ASM_ADD (
                      val_dget_int (val_dget (symtab, optSect), "value", 0),
                      val_dget_int (entry, "pos1", 0) / 2)),
                  0);
              if (v == NULL)
                continue;
              n = val_dget_str (entry, "name", "");
              if (!val_dhas (symtab, n))
                {
                  /* The EQU never made it into the symbol table, which is what
                     happens when its operand could not be evaluated on an
                     earlier pass.  This pass is where the value gets
                     established, so create the entry rather than index one
                     that is not there. */
                  Val *e = val_dict ();
                  val_dset_str (e, "type", "EQU");
                  val_dset (e, "value", v);
                  val_dset (e, "properties", properties);
                  val_dset (symtab, n, e);
                }
              val_dset (val_dget (symtab, n), "value", v);
              unhashed = unhash (val_as_int (v), &section, &value);
              s = unhashed ? section : NULL;
              d = value;
              if (s == NULL)
                {
                  const char *bs;
                  asmint bo;
                  if (unhashBorrowed (val_as_int (v), 1, &bs, &bo))
                    {
                      s = bs;
                      d = -bo;
                    }
                }
              if (s != NULL)
                {
                  Val *e = val_dget (symtab, n);
                  val_dset_str (e, "section", s);
                  val_dset_int (e, "address", d);
                  val_dset_bool (e, "dsect",
                                 val_dget_bool (val_dget (sects, s), "dsect", 0));
                  val_dset (e, "properties", properties);
                }
              continue;
            }
          if (strcmp (operation, "LTORG") == 0)
            {
              literalPoolNumber += 1;
              continue;
            }
          val_dset (properties, "length", val_dget (entry, "length"));
          if (!val_dget_bool (entry, "ambiguous", 0))
            continue;

          /* We have found an ambiguous instruction (SRS vs RS) that must be
             resolved.  The first thing is to work out the target address. */
          ast = val_dget (properties, "ast");
          if (val_is_none (ast) || val_dhas (ast, "X2") || val_dhas (ast, "noX"))
            {
              /* `D2(,B2)` is as unambiguous as `D2(X2,B2)`:  both are the
                 indexed form and neither has a short version. */
              val_dset_bool (entry, "ambiguous", 0);
              continue;
            }
          if (val_dhas (ast, "B2"))
            {
              Val *b2v = evalArithmeticExpression (
                  val_dget (ast, "B2"), NULL, properties, symtab,
                  val_int (ASM_ADD (
                      val_dget_int (val_dget (symtab, optSect), "value", 0),
                      val_dget_int (entry, "pos1", 0) / 2)),
                  0);
              if (b2v != NULL)
                {
                  asmint b2 = val_as_int (b2v);
                  if (b2 >= 4 && b2 <= 7)
                    {
                      /* B2 was really X2. */
                      val_dset_bool (entry, "ambiguous", 0);
                      continue;
                    }
                }
            }
          if (val_dhas (ast, "L2"))
            {
              Val *attributes;
              Val *literalPool;
              ptrdiff_t index;
              asmint offset;
              Val *poolSect;
              attributes = evalLiteralAttributes (properties, ast, symtab);
              if (attributes == NULL)
                {
                  val_dset_bool (entry, "ambiguous", 0);
                  continue;
                }
              if (literalPoolNumber >= val_len (literalPools))
                {
                  val_dset_bool (entry, "ambiguous", 0);
                  continue;
                }
              literalPool = val_get (literalPools, literalPoolNumber);
              index = literalIndex (literalPool, attributes);
              if (index < 0)
                {
                  /* NOT AN ERROR HERE.  `optimizeScratch` runs at the end of
                     pass 1 and nowhere else, and the pool it is consulting is
                     built during that same pass, so a literal whose operand is
                     a forward reference is legitimately absent at this moment.
                     Raised at severity 255 it aborted the assembly instead,
                     which is what made DCICYC's 34 such literals fatal. */
                  asmError (properties, "Literal not in literal pool", 0);
                  val_dset_bool (entry, "ambiguous", 0);
                  continue;
                }
              offset = ASM_ADD (
                  val_as_int (val_get (val_get (literalPool, 3), (size_t) index)),
                  val_as_int (val_get (literalPool, 1)));
              poolSect = val_dget (symtab, val_cstr (val_get (literalPool, 0)));
              if (poolSect == NULL)
                {
                  val_dset_bool (entry, "ambiguous", 0);
                  continue;
                }
              d2 = ASM_ADD (val_dget_int (poolSect, "value", 0), offset / 2);
              haveD2 = 1;
            }
          else if (val_dhas (ast, "D2"))
            {
              Val *d2v = evalArithmeticExpression (
                  val_dget (ast, "D2"), NULL, properties, symtab,
                  val_int (ASM_ADD (
                      val_dget_int (val_dget (symtab, optSect), "value", 0),
                      val_dget_int (entry, "pos1", 0) / 2)),
                  0);
              if (d2v != NULL)
                {
                  d2 = val_as_int (d2v);
                  haveD2 = 1;
                }
            }
          if (!haveD2)
            {
              val_dset_bool (entry, "ambiguous", 0);
              continue;
            }

          unhashed = unhash (d2, &section, &value);
          if (!unhashed)
            section = NULL;
          if (section == NULL)
            {
              if (val_dhas (ast, "B2") && unhashed && value >= SRS_FLOOR
                  && value < SRS_CEILING && strcmp (operation, "BCT") != 0)
                {
                  optAdjust (scratch, properties, i);
                  continue;
                }
              val_dset_bool (entry, "ambiguous", 0);
              continue;
            }

          /*
           * Special cases that branch backward.
           *
           * THE OVERFLOW/CARRY ALIASES HAVE NO BACKWARD SHORT FORM.  The short
           * branch's two-bit field selects the form -- BCF 00, BVCF 01, BCB 10,
           * BCTB 11 -- so `BNC`, `BOV` and `BOC`, which take BVCF's 01, have
           * nowhere to put the backward bit:  11 is already BCTB.
           */
          if (strcmp (section, optSect) == 0
              && !intmap_has (&bvcfAliases, stripSuffixes (operation))
              && (intmap_has (&branchAliases, operation)
                  || strcmp (operation, "BCT") == 0
                  || strcmp (operation, "BC") == 0
                  || isSrsBranchOperation (operation)))
            {
              asmint d = ASM_SUB (
                  ASM_ADD (ASM_ADD (val_dget_int (val_dget (symtab, optSect),
                                                  "value", 0),
                                    val_dget_int (properties, "pos1", 0) / 2),
                           1),
                  d2);
              if (d >= SRS_FLOOR && d < SRS_CEILING)
                {
                  optAdjust (scratch, properties, i);
                  continue;
                }
            }
          if (strcmp (operation, "BCT") == 0)
            {
              val_dset_bool (entry, "ambiguous", 0);
              continue;
            }
          /* `OPCODE R1,D2` where D2 is a location in the current CSECT. */
          if (strcmp (section, optSect) == 0
              && (intmap_has (&branchAliases, operation)
                  || strcmp (operation, "BC") == 0
                  || isSrsBranchOperation (operation)))
            {
              asmint d = ASM_SUB (
                  ASM_SUB (value, val_dget_int (properties, "pos1", 0) / 2), 1);
              if (d >= SRS_FLOOR && d < SRS_CEILING)
                {
                  optAdjust (scratch, properties, i);
                  continue;
                }
            }
          /* `OPCODE R1,D2` where D2 is a location in a CSECT currently in
             `USING`. */
          {
            Val *using = val_dget (entry, "using");
            int haveB = 0;
            asmint d = 10000000;
            int haveUBase = 0;
            asmint uDisp = 10000000;
            size_t r;
            for (r = 0; r < val_len (using); r++)
              {
                Val *u = val_get (using, r);
                if (val_is_none (u))
                  continue;
                if (val_is_str (val_get (u, 1))
                    && strcmp (section, val_cstr (val_get (u, 1))) == 0)
                  {
                    asmint u2 = val_as_int (val_get (u, 2));
                    if (u2 < d)
                      {
                        d = u2;
                        haveB = 1;
                      }
                  }
              }
            /*
             * THE TEST ABOVE IS NOT THE DISPLACEMENT and never was:  `u[2]` is
             * where the USING was established, `value` is where the operand
             * is, and only the DISTANCE between them has to fit the SRS field.
             * It cannot simply be corrected, because the two are from different
             * moments -- the snapshot was taken while the USING still named a
             * symbol defined hundreds of cards further on.  RE-EVALUATING THE
             * BASE EXPRESSION HERE gets it right, because by the end of the
             * pass the symbol is placed.
             *
             * Kept as an ADDITIONAL chance rather than a replacement.  The
             * accidental test is load bearing:  where the base is still wholly
             * unresolved it captures 0, passes, and shortens correctly for the
             * wrong reason, and modules that are byte-exact today depend on
             * that.  An `or` can only shorten more, never less.
             */
            for (r = 0; r < val_len (using); r++)
              {
                Val *u = val_get (using, r);
                asmint base;
                Val *usingAst;
                asmint dd;
                asmint unitizer = 1;
                asmint opcodeSRS;
                if (val_is_none (u))
                  continue;
                if (!val_is_str (val_get (u, 1))
                    || strcmp (section, val_cstr (val_get (u, 1))) != 0)
                  continue;
                /*
                 * FALL BACK TO THE SNAPSHOT WHEN THE EXPRESSION WILL NOT
                 * RE-EVALUATE, rather than abandoning the register.  The one
                 * form that will not is `USING *,0` -- `*` needs the location
                 * of the card it sat on -- and for exactly that form the
                 * SNAPSHOT IS ALREADY THE RIGHT NUMBER.
                 *
                 * `u[2]` already carries this register's 4096 offset, the
                 * capture having advanced `address` per register; a
                 * re-evaluated base is the FIRST operand's and still needs it.
                 */
                base = val_as_int (val_get (u, 2));
                if (val_len (u) >= 6 && !val_is_none (val_get (u, 5))
                    && val_dhas (sects, val_cstr (val_get (u, 1))))
                  {
                    Val *sc = val_dget (val_dget (sects, val_cstr (val_get (u, 1))),
                                        "scratch");
                    asmint idx = val_as_int (val_get (u, 5));
                    if (idx >= 0 && (size_t) idx < val_len (sc))
                      base = ASM_ADD (
                          val_dget_int (val_get (sc, (size_t) idx), "pos1", 0) / 2,
                          ASM_MUL (4096, val_as_int (val_get (u, 4))));
                  }
                usingAst = (val_len (u) >= 5)
                               ? val_dget (val_get (u, 3), "ast")
                               : NULL;
                if (usingAst != NULL && val_is_dict (usingAst)
                    && val_dhas (usingAst, "r")
                    && val_len (val_dget (usingAst, "r")) > 0)
                  {
                    Val *h2 = evalArithmeticExpression (
                        val_get (val_dget (usingAst, "r"), 0), NULL,
                        val_get (u, 3), symtab, NULL, 0);
                    if (h2 != NULL)
                      {
                        const char *s2;
                        asmint a2;
                        if (unhash (val_as_int (h2), &s2, &a2) && s2 != NULL
                            && strcmp (s2, section) == 0)
                          base = ASM_ADD (a2,
                                          ASM_MUL (4096,
                                                   val_as_int (val_get (u, 4))));
                      }
                  }
                dd = ASM_SUB (value, base);
                /*
                 * AND THE SRS FIELD COUNTS UNITS, NOT HALFWORDS.  For a
                 * fullword operation the displacement is in FULLWORDS, which
                 * doubles the reach.  ROUND UP, AS THE ENCODER DOES:  refusing
                 * a distance that is not a whole number of units was wrong
                 * here, because THE DISTANCE IS STILL MOVING.  Nothing is lost
                 * -- this pass only decides whether the short form is
                 * REACHABLE, and `forbiddenSRS` still refuses a genuinely
                 * unaligned displacement where the instruction is encoded.
                 */
                opcodeSRS = intmap_get (&argsSRSorRS, operation, -1);
                if (opcodeSRS != -1 && (opcodeSRS & 0x201) == 0)
                  unitizer = 2;
                dd = (dd + unitizer - 1) / unitizer;
                if (dd >= 0 && dd < uDisp)
                  {
                    uDisp = dd;
                    haveUBase = 1;
                  }
              }
            if ((haveB && d >= SRS_FLOOR && d < SRS_CEILING)
                || (haveUBase && uDisp >= SRS_FLOOR && uDisp < SRS_CEILING))
              {
                optAdjust (scratch, properties, i);
                continue;
              }
          }
        }
    }
  return adjustments;
}

/*===========================================================================
 * DC/DS length modifiers
 *
 * `Ln` is a length in bytes and `L.n` one in BITS (GC28-6514-8).  The whole
 * token list, leading 'L' and all, used to be handed straight to the
 * arithmetic evaluator, which could make nothing of a bare 'L' -- so EVERY
 * length modifier failed, not merely the bit form, and `XL8`, `CL4` and `FL2`
 * were as broken as `XL.8`.
 */
static Val *
lengthTokens (Val *tokens, int *bits, int *sign)
{
  Val *list;
  size_t i = 0;
  tokens = unroll (tokens);
  if (val_is_str (tokens))
    {
      Val *one = val_seq (V_LIST);
      val_append (one, tokens);
      tokens = one;
    }
  if (!val_is_seq (tokens))
    return NULL;
  list = val_retype (tokens, V_LIST);
  *bits = 0;
  *sign = 1;
  if (val_len (list) > i && val_eq_str (val_get (list, i), "L"))
    i++;
  if (val_len (list) > i && val_eq_str (val_get (list, i), "."))
    {
      *bits = 1;
      i++;
    }
  if (val_len (list) > i
      && (val_eq_str (val_get (list, i), "+")
          || val_eq_str (val_get (list, i), "-")))
    {
      if (val_eq_str (val_get (list, i), "-"))
        *sign = -1;
      i++;
    }
  return val_slice (list, (ptrdiff_t) i, (ptrdiff_t) val_len (list));
}

/* Evaluate a DC or DS length modifier and return it in BYTES, or 0 with
   `*ok` cleared where the Python returns None. */
static asmint
evalLengthModifier (Val *properties, Val *tokens, int *ok)
{
  int bits, sign;
  Val *rest = lengthTokens (tokens, &bits, &sign);
  Val *v;
  asmint value;
  *ok = 0;
  if (rest == NULL)
    return 0;
  v = evalArithmeticExpression (rest, NULL, properties, NULL, NULL, 255);
  if (v == NULL)
    return 0;
  value = ASM_MUL (val_as_int (v), sign);
  if (!bits)
    {
      *ok = 1;
      return value;
    }
  /* A bit length that is a whole number of bytes is simply that many bytes,
     which covers `L.8` -- by far the commonest form in the corpus, and just a
     way of writing one byte.  Anything else would change how the value is
     packed and is diagnosed rather than approximated. */
  if (value % 8 != 0)
    {
      asmError (properties,
                py_format ("A bit length modifier that is not a whole number "
                           "of bytes (L.%lld) reached the byte-oriented path",
                           (long long) value),
                255);
      return 0;
    }
  *ok = 1;
  return value / 8;
}

/* The same thing in BITS, so the caller can tell `AL.8(...)`, a bit
   specification that happens to be a whole byte, from `AL8(...)`, a byte
   count.  `*ok` is cleared when the modifier was not written as `L.n` at
   all. */
static asmint
evalBitLengthModifier (Val *properties, Val *tokens, int *ok)
{
  int bits, sign;
  Val *rest = lengthTokens (tokens, &bits, &sign);
  Val *v;
  *ok = 0;
  if (rest == NULL || !bits)
    return 0;
  v = evalArithmeticExpression (rest, NULL, properties, NULL, NULL, 255);
  if (v == NULL)
    return 0;
  *ok = 1;
  return ASM_MUL (sign, val_as_int (v));
}

/*
 * The size in BYTES of one element of a DC/DS suboperand, ignoring the
 * duplication factor -- which is what the length attribute L' is built from.
 * `*ok` is cleared when the size cannot be established, and the caller then
 * leaves the symbol without a length attribute rather than inventing one.
 */
static asmint
dcSuboperandBytes (Val *properties, Val *suboperand, int *ok)
{
  const char *thisType;
  Val *l;
  const char *text;
  *ok = 0;
  if (!val_is_dict (suboperand) || !val_dhas (suboperand, "t")
      || val_len (val_dget (suboperand, "t")) == 0)
    return 0;
  thisType = val_cstr (val_get (val_dget (suboperand, "t"), 0));
  l = val_dget (suboperand, "l");
  if (l != NULL && !(val_is_seq (l) && val_len (l) == 0))
    {
      int subOk = 0;
      asmint bits = evalBitLengthModifier (properties, l, &subOk);
      if (subOk)
        {
          asmint n = (bits + 7) / 8;
          *ok = 1;
          return n < 1 ? 1 : n;
        }
      {
        asmint modifier = evalLengthModifier (properties, l, &subOk);
        if (subOk)
          {
            *ok = 1;
            return modifier;
          }
      }
      return 0;
    }
  {
    static const char *const naturalKeys[]
        = { "F", "E", "A", "Z", "D", "H", "Y", "S", "V", NULL };
    static const asmint naturalValues[] = { 4, 4, 4, 4, 8, 2, 2, 2, 4 };
    int i;
    for (i = 0; naturalKeys[i] != NULL; i++)
      if (strcmp (thisType, naturalKeys[i]) == 0)
        {
          *ok = 1;
          return naturalValues[i];
        }
  }
  /* The remaining types take their size from the value as written. */
  {
    Val *v = val_dget (suboperand, "v");
    Val *first = (v != NULL && val_len (v) > 0) ? val_get (v, 0) : NULL;
    Val *second = (first != NULL && val_len (first) > 1) ? val_get (first, 1)
                                                         : NULL;
    if (!val_is_str (second))
      return 0;
    text = val_cstr (second);
  }
  if (strcmp (thisType, "C") == 0)
    {
      asmint n = (asmint) strlen (text);
      *ok = 1;
      return n < 1 ? 1 : n;
    }
  if (strcmp (thisType, "X") == 0)
    {
      /* WHOLE HALFWORDS, as the generator lays them down -- the two used to
         disagree for a constant of fewer than four digits, which is the
         standing failure mode here. */
      asmint digits = (asmint) strlen (py_replace (text, ",", ""));
      asmint n = 2 * ((digits + 3) / 4);
      *ok = 1;
      return n < 2 ? 2 : n;
    }
  if (strcmp (thisType, "B") == 0)
    {
      asmint n = ((asmint) strlen (text) + 7) / 8;
      *ok = 1;
      return n < 1 ? 1 : n;
    }
  return 0;
}

/*
 * `dcBuffer` is the working area for assembling a single `DC`.  It GROWS
 * rather than refusing:  the Shuttle flight software contains sixteen
 * patch-space modules whose entire content is one `DC 594X'C6C6'`, which is
 * 1188 bytes.
 */
static unsigned char *dcBuffer = NULL;
static size_t dcBufferSize = 0;

static void
dcBufferNeed (size_t n)
{
  if (n <= dcBufferSize)
    return;
  {
    size_t want = dcBufferSize ? dcBufferSize : 1024;
    while (want < n)
      want *= 2;
    dcBuffer = (unsigned char *) realloc (dcBuffer, want);
    if (dcBuffer == NULL)
      fatal ("out of memory");
    memset (dcBuffer + dcBufferSize, 0, want - dcBufferSize);
    dcBufferSize = want;
  }
}

/*
 * Replicate the first `length` bytes of `dcBuffer`, which are one copy of the
 * data a DC generates, until the buffer holds `duplicationFactor` copies.
 * Returns the resulting buffer length.
 *
 * A factor of zero is legal and generates no data whatever -- it is written to
 * fix an alignment or to attach a label and a length attribute.
 */
static size_t
replicateDC (size_t length, asmint duplicationFactor)
{
  size_t pointer;
  asmint copy;
  size_t i;
  if (duplicationFactor <= 0)
    return 0;
  dcBufferNeed (length * (size_t) duplicationFactor);
  pointer = length;
  for (copy = 0; copy < duplicationFactor - 1; copy++)
    for (i = 0; i < length; i++)
      dcBuffer[pointer++] = dcBuffer[i];
  return pointer;
}

/*===========================================================================
 * generateObjectCode
 *
 * Work is done in place on the `source` list, which holds one "properties"
 * dictionary per line of source code.  All macro expansion has already been
 * performed, so only lines of pure assembly language are processed, and while
 * continuation lines are present, all after the first in a sequence have been
 * merged into the first.  The `macros` argument is provided merely to have a
 * list of operations that can be ignored.
 *
 * The only manipulations done to any entry of `source` are that the `errors`
 * field may be augmented, and that non-previously-existing fields may be added
 * to hold object-code data.
 *
 * Note that addresses are in units of bytes.
 */

/* The state the Python holds as closure variables of `generateObjectCode`. */
static int collect, asis, compiling;
static const char *sect;        /* NULL for None */
static Val *properties;
static const char *gName;
static const char *gOperation;
static const char *gOperand;
static Val *using;
static asmint passCount;
static int repeatPass;
static int cVsD;
static int nameAssigned;
static Val *memoryFillChunk; /* not a value; see toMemory */

#define MEMORY_CHUNK_SIZE 4096

static Val *
sectEntry (const char *name)
{
  return name == NULL ? NULL : val_dget (sects, name);
}

static Val *
newSection (const char *name, int dsect)
{
  Val *s = val_dict ();
  Val *memory = val_bytes (0);
  val_bytes_grow (memory, MEMORY_CHUNK_SIZE, fillPattern, 2);
  val_dset_int (s, "pos1", 0);
  val_dset_int (s, "used", 0);
  val_dset (s, "memory", memory);
  val_dset (s, "scratch", val_seq (V_LIST));
  val_dset_bool (s, "dsect", dsect);
  val_dset (sects, name, s);
  return s;
}

/*
 * A function for writing to memory, or allocating it without writing to it as
 * appropriate.  `bytes` is either a byte array (for DC) or NULL with `size`
 * giving how much memory to allocate (for DS).  Alignment must have been done
 * before entry.
 */
static void
toMemory (Val *bytes, asmint size, asmint alignment)
{
  Val *s = sectEntry (sect);
  asmint pos1;
  if (s == NULL)
    return;
  pos1 = val_dget_int (s, "pos1", 0);
  if (collect)
    {
      asmint pos2 = pos1 / 2;
      Val *newScratch = val_dict ();
      if (gName[0] != '\0')
        {
          val_dset_str (newScratch, "name", gName);
          val_dset_int (newScratch, "alignment", alignment);
        }
      val_dset_int (newScratch, "length",
                    bytes == NULL ? size : (asmint) val_len (bytes));
      val_dset_bool (newScratch, "ambiguous",
                     intmap_has (&argsSRSandRS, gOperation)
                         || strcmp (gOperation, "BCT") == 0);
      val_dset_str (newScratch, "debug", py_format ("%05X", (unsigned) pos2));
      val_dset_int (newScratch, "pos1", pos1);
      val_dset_int (newScratch, "pos2", pos2);
      val_dset_str (newScratch, "sect", sect);
      val_dset_str (newScratch, "operation", gOperation);
      val_dset_str (newScratch, "operand", gOperand);
      val_dset (newScratch, "properties", properties);
      val_dset (newScratch, "using", val_retype (using, V_LIST));
      val_append (val_dget (s, "scratch"), newScratch);
      val_dset (properties, "scratch", newScratch);
    }
  val_dset_str (properties, "section", sect);
  if (bytes != NULL)
    {
      asmint end = ASM_ADD (pos1, (asmint) val_len (bytes));
      int samePass;
      if (cVsD && compiling)
        {
          Val *memory = val_dget (s, "memory");
          size_t i;
          while (end > (asmint) val_len (memory))
            val_bytes_grow (memory, val_len (memory) + MEMORY_CHUNK_SIZE,
                            fillPattern, 2);
          for (i = 0; i < val_len (bytes); i++)
            val_bytes_set (memory, (size_t) pos1 + i, val_bytes_get (bytes, i));
        }
      /*
       * ACCUMULATE ACROSS THE SUBOPERANDS OF ONE STATEMENT.  toMemory is
       * called once per suboperand, and both `pos1` and `assembled` used to be
       * overwritten by each call, so a statement was recorded as its LAST
       * suboperand alone -- `DC X'1122',X'33'` listed as `00001 33`.
       *
       * A new statement, or a new pass over the same one, starts the run
       * again; a suboperand that continues where the last left off extends it.
       * A gap -- alignment inserted between suboperands -- is filled from
       * memory so the run stays contiguous.
       */
      samePass = val_dhas (properties, "_assembledPass")
                 && val_dget_int (properties, "_assembledPass", -1) == passCount;
      if (samePass && val_dhas (properties, "_assembledEnd")
          && !val_is_none (val_dget (properties, "_assembledEnd"))
          && pos1 >= val_dget_int (properties, "_assembledEnd", 0)
          && pos1 - val_dget_int (properties, "_assembledEnd", 0) < 16
          && val_dhas (properties, "assembled"))
        {
          Val *run = val_dget (properties, "assembled");
          asmint gap = pos1 - val_dget_int (properties, "_assembledEnd", 0);
          if (gap > 0)
            {
              Val *memory = val_dget (s, "memory");
              asmint i;
              for (i = 0; i < gap; i++)
                {
                  asmint a = val_dget_int (properties, "_assembledEnd", 0) + i;
                  val_bytes_append (run, (a >= 0 && a < (asmint) val_len (memory))
                                             ? val_bytes_get (memory, (size_t) a)
                                             : 0);
                }
            }
          val_bytes_extend (run, bytes);
          val_dset (properties, "assembled", run);
        }
      else
        {
          val_dset_int (properties, "pos1", pos1);
          val_dset (properties, "assembled",
                    val_bytes_from (val_bytes_ptr (bytes), val_len (bytes)));
        }
      val_dset_int (properties, "_assembledEnd", end);
      val_dset_int (properties, "_assembledPass", passCount);
      val_dset_int (s, "pos1", end);
    }
  else
    {
      val_dset_int (properties, "pos1", pos1);
      val_dset_int (s, "pos1", ASM_ADD (pos1, size));
    }
  if (val_dget_int (s, "pos1", 0) > val_dget_int (s, "used", 0))
    val_dset (s, "used", val_dget (s, "pos1"));
}

/*
 * Common processing for all instructions.  `alignment` is 1 (byte), 2
 * (halfword), 4 (word) or 8 (doubleword).  Padding is zero-filled if `zero`,
 * or left unchanged otherwise.
 */
static void
commonProcessing (asmint alignment, int zero)
{
  Val *s;
  /* Make sure we are in *some* CSECT or DSECT. */
  if (sect == NULL)
    {
      cVsD = 1;
      sect = "";
      firstCSECT = sect;
      firstCSECTSet = 1;
      val_dset_str (symtab, "_firstCSECT", firstCSECT);
      if (!val_dhas (sects, sect))
        newSection (sect, 0);
    }
  s = sectEntry (sect);
  if (s == NULL)
    return;

  if (alignment > 1)
    {
      asmint pos1, rem;
      if (alignment > val_dget_int (properties, "alignment", 0))
        val_dset_int (properties, "alignment", alignment);
      pos1 = val_dget_int (s, "pos1", 0);
      rem = pos1 % alignment;
      if (rem != 0)
        {
          /* toMemory() used to do this, but that can have unintended side
             effects such as giving a statement like `DS 0F` a non-zero
             length. */
          if (zero)
            {
              Val *memory = val_dget (s, "memory");
              asmint p;
              for (p = pos1; p < pos1 + alignment - rem; p++)
                val_bytes_set (memory, (size_t) p, 0);
            }
          else
            pos1 += alignment - rem;
          val_dset_int (s, "pos1", pos1);
          if (pos1 > val_dget_int (s, "used", 0))
            val_dset_int (s, "used", pos1);
        }
    }

  /*
   * Add `name` (if any) to the symbol table.
   *
   * ON EVERY PASS, not only the collecting ones.  Instruction lengths are
   * still settling during the compile passes, so a label recorded only while
   * collecting keeps a position from before the instruction ahead of it grew.
   *
   * ONCE PER STATEMENT.  `commonProcessing` runs once per SUBOPERAND of a
   * `DC`, and recording the label at whatever the location counter had reached
   * walked the label forward through its own constant:  DCI#DATA's
   * `DCIDOUT DC Y(DCIDOUT+2),Y(DCIDOUT+508),510H'0'` computed every value
   * against a different base.
   */
  if (gName[0] != '\0' && !nameAssigned)
    {
      asmint pos2;
      Val *entry;
      nameAssigned = 1;
      pos2 = val_dget_int (s, "pos1", 0) / 2;
      if (val_dhas (symtab, gName) && !val_dhas (val_dget (symtab, gName),
                                                 "preliminary"))
        {
          Val *old = val_dget (symtab, gName);
          const char *oldSect = val_dget_str (old, "section", NULL);
          asmint oldPos = val_dget_int (old, "address", -1);
          if (oldSect == NULL || strcmp (oldSect, sect) != 0 || oldPos != pos2)
            {
              /* A LABEL THAT MOVES ASKS FOR ANOTHER PASS.  It is not an error:
                 instruction lengths are still settling, so a label naturally
                 shifts, and every instruction ALREADY assembled on this pass
                 used its old value. */
              if (compiling)
                repeatPass = 1;
            }
        }
      if (!val_dhas (symtab, gName))
        val_dset (symtab, gName, val_dict ());
      entry = val_dget (symtab, gName);
      val_ddel (entry, "preliminary");
      val_dset_str (entry, "section", sect);
      val_dset_int (entry, "address", pos2);
      val_dset_int (entry, "value",
                    ASM_ADD (val_dget_int (val_dget (symtab, sect), "value", 0),
                             pos2));
      val_dset_str (entry, "debug", py_format ("%05X", (unsigned) pos2));
      val_dset_bool (entry, "dsect", val_dget_bool (s, "dsect", 0));
      if (strcmp (gOperation, "DC") == 0 || strcmp (gOperation, "DS") == 0)
        val_dset_str (entry, "type", "DATA");
      else
        val_dset_str (entry, "type", "INSTRUCTION");
    }
}

/* The hashed address of the current program counter. */
static asmint
currentHash (void)
{
  Val *s = sectEntry (sect);
  Val *e = sect == NULL ? NULL : val_dget (symtab, sect);
  if (s == NULL || e == NULL)
    return 0;
  return ASM_ADD (val_dget_int (e, "value", 0),
                  val_dget_int (s, "pos1", 0) / 2);
}

/*
 * Evaluate a single suboperand of an RR, RS, SRS, SI or RI instruction.
 * Returns whether an ERROR occurred; `*value` is set and `*present` cleared
 * when the desired subfield is not there at all.
 */
static int
evalInstructionSubfield (Val *props, const char *subfield, Val *ast,
                         Val *symtabArg, asmint *value, int *present)
{
  Val *v;
  *value = 0;
  *present = 0;
  if (ast == NULL || !val_is_dict (ast) || !val_dhas (ast, subfield))
    return 0;
  *present = 1;
  v = evalArithmeticExpression (val_dget (ast, subfield), NULL, props,
                                symtabArg, val_int (currentHash ()), 0);
  if (v == NULL)
    {
      /* QUIET ON THE COLLECTING PASSES.  A subfield naming a symbol defined
         further down the module cannot be evaluated on pass 1, and that is
         what the later passes are for; reporting it at severity 255 there
         aborted the assembly before it could reach them. */
      asmError (props, py_format ("Could not evaluate %s subfield", subfield),
                compiling ? 255 : 0);
      *present = 0;
      return 1;
    }
  *value = val_as_int (v);
  return 0;
}

/*
 * For an instruction with a nominal suboperand D2(B2) that the source writes
 * simply as D2, find a suitable B2 and adjusted D2 among the registers named
 * by `USING`.  `d2` is in hashed form.  Returns 1 with `*b2` set when a base
 * register was found, 0 with `*d2Out` holding the constant when the value is
 * not relocatable, and -1 when nothing matched.  There is no upper limit on
 * the returned D2; the caller decides whether it is small enough.
 */
static int
findB2D2 (asmint d2, asmint *b2Out, asmint *d2Out)
{
  const char *section;
  asmint offset;
  const char *targetSection = NULL;
  int haveD2 = 0;
  asmint bestD2 = 0, bestB2 = 0;
  size_t i;

  *b2Out = 0;
  *d2Out = 0;
  if (ASM_AND (d2, HASHCODE_MASK) == 0
      || ASM_AND (d2, HASHCODE_MASK) == HASHCODE_MASK)
    {
      *d2Out = ASM_AND (d2, 0xFFFFFF);
      return 0;
    }
  /*
   * A `USING` ON A CONTROL SECTION ADDRESSES THAT SECTION AND NO OTHER.  The
   * register holds an address in the section the USING names, and where a
   * different section will sit relative to it is the linker's business.
   * Reaching across anyway produced an arithmetically correct instruction
   * against the wrong authority.
   *
   * A DSECT `USING` IS EXEMPT, and this is the whole difficulty:  it asserts
   * nothing about where anything sits -- the register points at some storage
   * and the DSECT names the fields laid over it -- so there is no other
   * section to reach across.  Most USINGs in this corpus are of that kind.
   *
   * THE SECTION IS FOUND BY ADDRESS.  `unhash(d2)` will not give it:  its
   * hashcode names the section the REFERENCE OCCURS IN, not the one the symbol
   * is DEFINED in.
   */
  if (unhash (d2, &section, &offset))
    {
      asmint combined
          = section != NULL
                ? ASM_ADD (offset,
                           val_dget_int (val_dget (sects, section), "offset", 0))
                : offset;
      for (i = 0; i < val_dlen (sects); i++)
        {
          Val *sd = val_dval (sects, i);
          asmint so, su;
          if (val_dget_bool (sd, "dsect", 0) || !val_dhas (sd, "offset"))
            continue;
          so = val_dget_int (sd, "offset", 0);
          su = val_dget_int (sd, "used", 0) / 2;
          if (so <= combined && combined < so + su)
            {
              targetSection = val_dkey (sects, i);
              break;
            }
        }
    }
  for (i = 0; i < val_len (using); i++)
    {
      Val *e = val_get (using, i);
      asmint d;
      if (val_is_none (e))
        continue;
      /*
       * A SECTION'S OWN LITERAL POOL IS PART OF IT.  The pool is named "#L"
       * plus the section's name and the ASSEMBLER places it, not the linker,
       * so a USING has to reach it.
       */
      if (targetSection != NULL && val_is_str (val_get (e, 1)))
        {
          const char *es = val_cstr (val_get (e, 1));
          char *poolName = py_concat ("#L", es);
          if (strcmp (es, targetSection) != 0
              && strcmp (targetSection, poolName) != 0 && val_dhas (sects, es)
              && !val_dget_bool (val_dget (sects, es), "dsect", 0))
            continue;
        }
      d = ASM_SUB (d2, val_as_int (val_get (e, 0)));
      if (d >= 0 && d < 0x10000)
        {
          /* "<=" rather than "<":  the assembler manual states that if two
             candidate registers give the same D2, the higher-numbered
             register is used. */
          if (!haveD2 || d <= bestD2)
            {
              bestD2 = d;
              bestB2 = (asmint) i;
              haveD2 = 1;
            }
        }
    }
  if (!haveD2)
    return -1;
  *b2Out = bestB2;
  *d2Out = bestD2;
  return 1;
}

/*---------------------------------------------------------------------------
 * Operand evaluation for the MSC and BCE instruction sets.
 *
 * An MSC or BCE address is as relocatable as a Y constant, and each of these
 * resolves a hashed value to the combined offset the encoder wants while
 * recording, where the caller asks for it, which symbol the linker has to fill
 * in.  Emitting the address without that record is how FIOICCPG's
 * `#LBR@ FIOBRE` assembled FA00 0000 where DASS_SSW has FA00 8BC6, with ER
 * cards in the object and no RLD card at all.
 *
 * Each returns 0 where the Python returns None.
 */
static int
mscField (Val *props, const char *subfield, Val *ast, asmint *out)
{
  asmint value;
  int present;
  const char *section;
  asmint offset;
  if (evalInstructionSubfield (props, subfield, ast, symtab, &value, &present)
      || !present)
    return 0;
  if (!unhash (value, &section, &offset) || section == NULL)
    {
      *out = value;
      return 1;
    }
  *out = ASM_ADD (offset,
                  val_dget_int (val_dget (sects, section), "offset", 0));
  return 1;
}

static int
mscLongField (Val *props, const char *subfield, Val *ast, Val *relocSymbol,
              asmint *out)
{
  asmint value;
  int present;
  const char *section;
  asmint offset;
  if (evalInstructionSubfield (props, subfield, ast, symtab, &value, &present)
      || !present)
    return 0;
  if (!unhash (value, &section, &offset) || section == NULL)
    {
      *out = value;
      return 1;
    }
  if (rextrnHas (value))
    val_dset_str (relocSymbol, subfield, rextrnSymbol (value));
  else if (rextrnHas (ASM_AND (value, HASHCODE_MASK)))
    val_dset_str (relocSymbol, subfield,
                  rextrnSymbol (ASM_AND (value, HASHCODE_MASK)));
  else if (val_dhas (sects, section)
           && !val_dget_bool (val_dget (sects, section), "dsect", 0)
           && val_dhas (val_dget (sects, section), "offset"))
    val_dset_str (relocSymbol, subfield, section);
  *out = ASM_ADD (offset,
                  val_dget_int (val_dget (sects, section), "offset", 0));
  return 1;
}

static int
bceField (Val *props, const char *subfield, Val *ast, Val *relocSymbol,
          Val *negative, asmint *out)
{
  asmint value;
  int present;
  const char *section;
  asmint offset;
  if (evalInstructionSubfield (props, subfield, ast, symtab, &value, &present)
      || !present)
    return 0;
  if (!unhash (value, &section, &offset) || section == NULL)
    {
      /* A NEGATIVE DISPLACEMENT FROM AN EXTRN borrows out of the offset into
         the buffer nibble, so `unhash` reports nothing and this returned the
         raw hashed value with NO RELOCATION.  The magnitude is what the
         listing shows and what the ADDRESS arm below emits; the SIGN travels
         in the RLD. */
      const char *bs;
      asmint bm;
      if (unhashBorrowed (value, 0, &bs, &bm))
        {
          val_dset_str (relocSymbol, subfield, bs);
          val_dset (negative, subfield, V_True);
        }
      *out = value;
      return 1;
    }
  /* An EXTRN is keyed in `rextrns` by its hashcode alone, so a reference
     carrying a displacement -- `#LBR@ FIOPDBR+2` -- has to be looked up with
     the low bits masked off. */
  if (rextrnHas (value))
    val_dset_str (relocSymbol, subfield, rextrnSymbol (value));
  else if (rextrnHas (ASM_AND (value, HASHCODE_MASK)))
    val_dset_str (relocSymbol, subfield,
                  rextrnSymbol (ASM_AND (value, HASHCODE_MASK)));
  else if (val_dhas (sects, section)
           && !val_dget_bool (val_dget (sects, section), "dsect", 0)
           && val_dhas (val_dget (sects, section), "offset"))
    val_dset_str (relocSymbol, subfield, section);
  *out = ASM_ADD (offset,
                  val_dget_int (val_dget (sects, section), "offset", 0));
  return 1;
}

Val *
generateObjectCode (Val *source, Val *macros)
{
  size_t propNum;
  int continuation;
  Val *ast = NULL;
  size_t literalPoolNumber;

  /*-----------------------------------------------------------------------
   * Setup
   */
  collect = 0;
  asis = 0;
  compiling = 0;
  sect = NULL;
  {
    size_t i;
    for (i = 0; i < val_dlen (macros); i++)
      val_dset (ignoreOps, val_dkey (macros, i), V_True);
  }
  properties = val_dict ();
  gName = "";
  gOperation = "";
  gOperand = "";
  using = val_seq (V_LIST);
  {
    int i;
    for (i = 0; i < 8; i++)
      val_append (using, V_None);
  }
  (void) memoryFillChunk;

  /*-----------------------------------------------------------------------
   * Pass 0
   */
  passCount = 0;
  val_dset_int (svGlobals, "_passCount", passCount);
  val_dset_int (metadata, "passCount", passCount);
  continuation = 0;
  sect = NULL;

  for (propNum = 0; propNum < val_len (source); propNum++)
    {
      const char *operation;
      char *operand;
      const char *name;
      properties = val_get (source, propNum);

      /* A card already CONSUMED as a continuation still has to update the
         flag, because its own column 72 says whether the card after it
         continues too.  Returning early on "skip" left the flag set from the
         statement that started the sequence, so the next real statement was
         taken for a continuation and silently dropped. */
      if (val_dhas (properties, "skip"))
        {
          continuation = val_dget_bool (properties, "continues", 0);
          continue;
        }
      if (val_dget_bool (properties, "inMacroDefinition", 0)
          || val_dget_bool (properties, "fullComment", 0)
          || val_dget_bool (properties, "dotComment", 0)
          || val_dget_bool (properties, "empty", 0))
        continue;
      /* Only the first line of a sequence of continued lines matters. */
      if (continuation)
        {
          continuation = val_dget_bool (properties, "continues", 0);
          continue;
        }
      continuation = val_dget_bool (properties, "continues", 0);
      operation = val_dget_str (properties, "operation", "");
      if (val_dhas (ignoreOps, operation))
        continue;
      operand = py_rstrip (val_dget_str (properties, "operand", ""));
      if (operand[0] != '\0')
        {
          const char *rule = strmap_get (&appropriateRules, operation);
          if (rule != NULL)
            {
              ast = parserASM (operand, rule);
              if (ast == NULL)
                {
                  /* Name the operand and the rule.  This message used to say
                     only "Could not parse operands", which identifies neither
                     what failed nor which grammar rejected it, and it is one
                     of the two commonest diagnostics in the FCOS corpus. */
                  asmError (properties,
                            py_format ("Could not parse the operand of %s "
                                       "against rule '%s': %s",
                                       operation, rule, operand),
                            255);
                  val_dset_bool (properties, "astFailed", 1);
                }
              val_dset (properties, "ast", ast == NULL ? V_None : ast);
            }
        }

      /*
       * Preliminary symbol-table entries exist only to give `USING
       * symbol,register` something to resolve against on the next pass, which
       * corrects them.  Also:  the original assembler transparently discarded
       * `EXTRN` statements for already-defined symbols -- not merely ignored
       * them, they did not appear in the listing at all -- so that has to be
       * detected and reproduced.
       */
      if (strcmp (operation, "EXTRN") == 0)
        {
          Val *u = unroll (ast);
          if (u != NULL && val_is_str (u))
            {
              const char *symbol = val_cstr (u);
              Val *list = val_seq (V_LIST);
              if (val_dhas (symtab, symbol))
                {
                  /* Already defined:  the statement disappears. */
                }
              else
                {
                  Val *e = val_dict ();
                  val_dset_str (e, "type", "EXTERNAL");
                  val_dset_int (e, "value", getHashcode (symbol));
                  val_dset (e, "properties", properties);
                  val_dset (symtab, symbol, e);
                  val_append (list, u);
                }
              val_dset (properties, "ast", list);
              if (val_len (list) == 0)
                val_dset_bool (properties, "empty", 1);
            }
          continue;
        }
      if (strcmp (operation, "EQU") == 0)
        continue;
      if (!val_dhas (properties, "name"))
        continue;
      name = val_dget_str (properties, "name", "");
      /*
       * AN UNNAMED DSECT STILL SWITCHES SECTIONS.  The guard below skips any
       * statement without a label, which is right for everything except this:
       * a bare `DSECT` carries no name and was therefore skipped BEFORE the
       * section switch, so every symbol in the dummy section was given a
       * preliminary address inside the enclosing control section.  FCMBMASK is
       * what that cost -- `optimizeScratch` could never match the section for
       * `LH R4,TBMPVAR`, and we emitted the four-byte form where the original
       * has two.
       */
      if (strcmp (operation, "DSECT") == 0 && name[0] == '\0')
        name = UNNAMED_DSECT;
      if (name[0] == '\0')
        continue;
      if (strcmp (operation, "CSECT") == 0 || strcmp (operation, "DSECT") == 0)
        {
          sect = arena_strdup (ARENA_MAIN, name);
          if (!val_dhas (sects, sect))
            {
              Val *s = newSection (sect, strcmp (operation, "DSECT") == 0);
              if (!val_dhas (symtab, sect))
                {
                  Val *e = val_dict ();
                  val_dset_str (e, "section", sect);
                  val_dset_int (e, "address", 0);
                  val_dset_str (e, "type", "CSECT");
                  val_dset_int (e, "value", getHashcode (sect));
                  val_dset_bool (e, "preliminary", 1);
                  val_dset (e, "n", val_dget (properties, "n"));
                  val_dset_bool (e, "dsect", val_dget_bool (s, "dsect", 0));
                  val_dset (e, "properties", properties);
                  val_dset (symtab, sect, e);
                }
            }
          else if (passCount == 3)
            {
              Val *e = val_dget (symtab, sect);
              Val *refs = val_dget (e, "references");
              if (refs == NULL || !val_is_seq (refs))
                {
                  refs = val_seq (V_LIST);
                  val_dset (e, "references", refs);
                }
              val_append (refs, val_dget (properties, "n"));
            }
          continue;
        }
      if (sect == NULL || !val_dhas (sects, sect))
        continue;
      {
        Val *s = val_dget (sects, sect);
        asmint pos1 = val_dget_int (s, "pos1", 0);
        Val *e = val_dict ();
        val_dset_int (s, "pos1", pos1 + 4);
        val_dset_str (e, "section", sect);
        val_dset_int (e, "address", pos1);
        val_dset_int (e, "value",
                      ASM_ADD (val_dget_int (val_dget (symtab, sect), "value", 0),
                               pos1));
        val_dset_int (e, "alignment", 4);
        val_dset_str (e, "debug", py_format ("%05X", (unsigned) pos1));
        val_dset_bool (e, "preliminary", 1);
        val_dset (e, "n", val_dget (properties, "n"));
        val_dset_bool (e, "dsect", val_dget_bool (s, "dsect", 0));
        val_dset (e, "properties", properties);
        if (strcmp (operation, "DC") == 0 || strcmp (operation, "DS") == 0)
          val_dset_str (e, "type", "DATA");
        else
          val_dset_str (e, "type", "INSTRUCTION");
        val_dset (symtab, name, e);
      }
    }

  /*-----------------------------------------------------------------------
   * Passes 1 through 3.  Pass 3 repeats -- through 4, 5 and so on -- while
   * any EQU value or label position is still moving.  BOUNDED, because a
   * layout that oscillates rather than settling would otherwise spin forever;
   * 20 is far above anything the corpus needs, the worst observed being 6.
   */
  repeatPass = 0;
  passCount = 0;
  while (passCount < 3 || (repeatPass && passCount < 20))
    {
      repeatPass = 0;
      passCount += 1;
      /* THE RELOCATIONS BELONG TO THE PASS THAT PRODUCED THEM.  They used to
         be recorded on pass 3 exactly and never cleared, which was safe only
         while pass 3 was always the last.  It no longer is. */
      relocations->u.seq.len = 0;
      /* And so do the protect transitions, for the same reason. */
      protects->u.seq.len = 0;
      val_dset_int (metadata, "passCount", passCount);
      val_dset_int (svGlobals, "_passCount", passCount);
      collect = (passCount == 1 || passCount == 2);
      asis = (passCount == 2);
      compiling = (passCount >= 3);
      continuation = 0;

      if (asis)
        {
          sects->u.dict.len = 0;
          if (sects->u.dict.index != NULL)
            {
              size_t k;
              for (k = 0; k <= sects->u.dict.indexMask; k++)
                sects->u.dict.index[k] = -1;
            }
        }
      else
        {
          asmint ppos1 = 0;
          size_t si;
          for (si = 0; si < val_dlen (sects); si++)
            {
              const char *sn = val_dkey (sects, si);
              Val *sd = val_dval (sects, si);
              if (val_dhas (symtab, sn))
                {
                  if (!val_dget_bool (sd, "dsect", 0))
                    {
                      asmint used;
                      size_t pi;
                      ppos1 += ppos1 & 1;
                      val_dset_int (val_dget (symtab, sn), "preliminaryOffset",
                                    ppos1);
                      used = val_dget_int (sd, "used", 0);
                      ppos1 += used / 2;
                      /*
                       * The "used" field does not include a literal pool
                       * appended to the end of the section.  ONLY A TRAILING
                       * POOL, THOUGH:  an INTERIOR pool -- one with statements
                       * after its LTORG -- is already inside "used", because
                       * those statements were assembled past it and carried
                       * "used" with them, so adding it again counts it twice.
                       * That is also why this no longer stops at the FIRST
                       * pool of the section:  DCICYC has two, and the interior
                       * one came first.
                       */
                      for (pi = 0; pi < val_len (literalPools); pi++)
                        {
                          Val *pool = val_get (literalPools, pi);
                          if (!val_eq_str (val_get (pool, 0), sn)
                              || val_is_none (val_get (pool, 1)))
                            continue;
                          if (ASM_ADD (val_as_int (val_get (pool, 1)),
                                       val_as_int (val_get (pool, 4)))
                              <= used)
                            continue;
                          ppos1 += ppos1 & 1;
                          ppos1 += val_as_int (val_get (pool, 4)) / 2;
                          break;
                        }
                    }
                }
              val_dset_int (sd, "pos1", 0);
            }
        }
      sect = NULL;
      {
        int i;
        for (i = 0; i < 8; i++)
          val_set (using, (size_t) i, V_None);
      }
      literalPoolNumber = 0;

      for (propNum = 0; propNum < val_len (source); propNum++)
        {
          const char *operation;
          char *operand;
          asmint startingPos1;
          unsigned char data[8];
          int dataLen = 0;
          properties = val_get (source, propNum);

          if (val_dhas (properties, "skip"))
            {
              continuation = val_dget_bool (properties, "continues", 0);
              continue;
            }
          if (continuation)
            {
              continuation = val_dget_bool (properties, "continues", 0);
              continue;
            }
          continuation = val_dget_bool (properties, "continues", 0);
          if (val_dget_bool (properties, "inMacroDefinition", 0)
              || val_dget_bool (properties, "fullComment", 0)
              || val_dget_bool (properties, "dotComment", 0)
              || val_dget_bool (properties, "empty", 0))
            continue;
          operation = val_dget_str (properties, "operation", "");
          /* SPON/SPOFF mark the store-protect state of what follows.  They stay
             in `ignoreOps' -- they generate no object code and the collect pass
             still discards them -- but on a compile pass the location counter is
             meaningful, so the transition is recorded first.

             NO DIAGNOSTIC IS EMITTED HERE, DELIBERATELY.  The obvious one,
             "unbalanced SPOFF/SPON", would fire on 36 of the 40 files in
             OI340600 that use these at all:  31 have SPOFF with no SPON and 5
             have SPON with no SPOFF, against 4 balanced.  Unbalanced is not the
             error case, it is the normal case. */
          if (compiling
              && (strcmp (operation, "SPON") == 0
                  || strcmp (operation, "SPOFF") == 0))
            {
              Val *sd = (sect != NULL) ? val_dget (sects, sect) : NULL;
              if (sd != NULL && !val_dget_bool (sd, "dsect", 0))
                {
                  Val *t = val_dict ();
                  val_dset (t, "section", val_str (sect));
                  val_dset_int (t, "offset", val_dget_int (sd, "pos1", 0));
                  val_dset (t, "protect",
                            (strcmp (operation, "SPON") == 0) ? V_True
                                                              : V_False);
                  val_append (protects, t);
                }
            }
          if (val_dhas (ignoreOps, operation))
            continue;
          if (val_dget_bool (properties, "astFailed", 0))
            {
              /* The operand did not parse, which was diagnosed where it was
                 parsed.  There is nothing to generate from a null AST, and
                 going on regardless is what turned that diagnosis into a
                 traceback.  The condition holds identically on every pass, so
                 skipping here does not put the passes out of step. */
              continue;
            }

          gOperation = operation;
          gName = val_dget_str (properties, "name", "");
          if (gName[0] == '.')
            gName = "";
          /* A LABEL IS PLACED ONCE PER STATEMENT, not once per suboperand. */
          nameAssigned = 0;
          /*
           * AND THE STATEMENT'S OBJECT CODE BELONGS TO THIS PASS.  A statement
           * that emits NOTHING on this pass never calls `toMemory` at all, so
           * last pass's bytes simply stayed, and the listing and --compare
           * both read them.  FCMSSYNC's `CNOP 2` is the case.
           */
          val_ddel (properties, "assembled");
          val_ddel (properties, "_assembledEnd");
          operand = py_rstrip (val_dget_str (properties, "operand", ""));
          gOperand = operand;

          /*************** Most pseudo-ops ***************
           * These add nothing to AP-101S memory.  Each either continues or
           * breaks, so as not to fall through to instruction processing.
           */
          if (strcmp (operation, "CSECT") == 0
              || strcmp (operation, "DSECT") == 0)
            {
              const char *name = gName;
              /* The current section name starts as None, meaning none has been
                 assigned.  `START` or `CSECT` changes that to either "" (the
                 unnamed section) or an identifier.  Code that must be
                 assembled while the section name is still None automatically
                 switches to the unnamed section. */
              cVsD = (strcmp (operation, "CSECT") == 0);
              if (cVsD && sect == NULL)
                {
                  firstCSECT = arena_strdup (ARENA_MAIN, name);
                  firstCSECTSet = 1;
                  val_dset_str (symtab, "_firstCSECT", firstCSECT);
                }
              if (name[0] == '\0' && !cVsD)
                {
                  /* The name field of DSECT may be blank; FCMBMASK's listing
                     assembles one.  A blank name defines the one UNNAMED dummy
                     section, which any later blank-named DSECT continues.  It
                     needs an internal name only because "" is already the
                     unnamed CONTROL section and merging the two would put
                     dummy storage in the object. */
                  name = UNNAMED_DSECT;
                }
              sect = arena_strdup (ARENA_MAIN, name);
              if (!val_dhas (sects, sect))
                {
                  Val *s = newSection (sect, !cVsD);
                  if (!val_dhas (symtab, sect))
                    {
                      Val *e = val_dict ();
                      val_dset_str (e, "section", sect);
                      val_dset_int (e, "address", 0);
                      val_dset_str (e, "type", "CSECT");
                      val_dset_int (e, "value", getHashcode (sect));
                      val_dset_bool (e, "dsect", val_dget_bool (s, "dsect", 0));
                      val_dset (symtab, sect, e);
                    }
                }
              val_dset_str (properties, "section", sect);
              val_dset (properties, "pos1",
                        val_dget (val_dget (sects, sect), "pos1"));
              continue;
            }
          if (strcmp (operation, "END") == 0)
            break;
          if (strcmp (operation, "ENTRY") == 0
              || strcmp (operation, "EXTRN") == 0)
            {
              Val *a = val_dget (properties, "ast");
              if (val_is_none (a))
                asmError (properties,
                          py_format ("Cannot parse operand of %s", operation),
                          255);
              else
                {
                  Val *u = unroll (a);
                  Val *symbols = val_seq (V_LIST);
                  size_t k;
                  if (val_is_str (u))
                    val_append (symbols, u);
                  else if (val_is_seq (u) && val_len (u) >= 2)
                    {
                      val_append (symbols, val_get (u, 0));
                      for (k = 0; k < val_len (val_get (u, 1)); k++)
                        val_append (symbols,
                                    val_get (val_get (val_get (u, 1), k), 1));
                    }
                  for (k = 0; k < val_len (symbols); k++)
                    {
                      const char *symbol = val_cstr (val_get (symbols, k));
                      if (strcmp (operation, "ENTRY") == 0)
                        {
                          val_dset (entries, symbol, V_True);
                          if (val_dhas (symtab, symbol))
                            {
                              Val *e = val_dget (symtab, symbol);
                              val_dset_bool (e, "entry", 1);
                              if (passCount == 3)
                                {
                                  Val *refs = val_dget (e, "references");
                                  if (refs == NULL || !val_is_seq (refs))
                                    {
                                      refs = val_seq (V_LIST);
                                      val_dset (e, "references", refs);
                                    }
                                  val_append (refs, val_dget (properties, "n"));
                                }
                            }
                        }
                      else
                        {
                          val_dset (extrns, symbol, V_True);
                          if (!val_dhas (symtab, symbol))
                            {
                              Val *e = val_dict ();
                              val_dset_str (e, "type", "EXTERNAL");
                              val_dset_int (e, "value", getHashcode (symbol));
                              val_dset (symtab, symbol, e);
                            }
                          rextrnSet (symbol,
                                     val_dget_int (val_dget (symtab, symbol),
                                                   "value", 0));
                        }
                    }
                }
              continue;
            }
          if (strcmp (operation, "EQU") == 0)
            {
              Val *oldValue = NULL;
              Val *a;
              asmint v = 0;
              int present = 0, err;
              const char *vs;
              asmint vd;
              if (gName[0] == '\0')
                {
                  ERROR (properties, "EQU has no name field");
                  continue;
                }
              toMemory (NULL, 0, 1);
              if (val_dhas (symtab, gName))
                {
                  Val *e = val_dget (symtab, gName);
                  const char *ty = val_dget_str (e, "type", "");
                  if (strcmp (ty, "EQU") != 0)
                    {
                      asmError (properties,
                                py_format ("EQU name already in use: %s", gName),
                                255);
                      continue;
                    }
                  oldValue = val_dget (e, "value");
                }
              a = val_dget (properties, "ast");
              if (val_is_none (a))
                {
                  ERROR (properties, "Cannot parse operand of EQU");
                  continue;
                }
              err = evalInstructionSubfield (properties, "v", a, symtab, &v,
                                             &present);
              /*
               * EQU's optional second and third operands GIVE the symbol its
               * length and type attributes outright, rather than the assembler
               * deducing them from a DC or DS.  That is how the position
               * symbols are built:  PDEF writes `&N.X EQU &X,&X+1025,C'@'`,
               * and the POS macro then reads L'&N.X.  The value of the second
               * operand is stored exactly as written -- it is not a halfword
               * count and must not be scaled.  The third is a character
               * self-defining term whose value IS the type character.
               */
              if (val_dhas (a, "len") && val_len (val_dget (a, "len")) > 0)
                {
                  Val *lv = evalArithmeticExpression (
                      val_get (val_dget (a, "len"), 0), NULL, properties, symtab,
                      val_int (currentHash ()), 0);
                  if (lv != NULL)
                    {
                      if (!val_dhas (symtab, gName))
                        val_dset (symtab, gName, val_dict ());
                      val_dset (val_dget (symtab, gName), "lengthAttribute", lv);
                    }
                }
              if (val_dhas (a, "typc") && val_len (val_dget (a, "typc")) > 0)
                {
                  /* THE CHARACTER INSIDE THE QUOTES, not the rebuilt term.
                     `joinTokens` gives back `C'#'`, so the self-defining test
                     was applied to `C'C'#''` -- which fails, so the attribute
                     was never recorded at all. */
                  const char *tc
                      = characterTermValue (val_get (val_dget (a, "typc"), 0));
                  if (tc != NULL && tc[0] != '\0')
                    {
                      if (!val_dhas (symtab, gName))
                        val_dset (symtab, gName, val_dict ());
                      val_dset_str (val_dget (symtab, gName), "typeAttribute",
                                    py_substr (tc, 0, 1));
                    }
                }
              else if (val_dhas (a, "typ") && val_len (val_dget (a, "typ")) > 0)
                {
                  Val *tv = evalArithmeticExpression (
                      val_get (val_dget (a, "typ"), 0), NULL, properties, symtab,
                      val_int (currentHash ()), 0);
                  if (tv != NULL)
                    {
                      asmint t = val_as_int (tv);
                      if (t >= 0 && t < 256)
                        {
                          char buf[2];
                          buf[0] = ebcdicToAscii[t];
                          buf[1] = '\0';
                          if (!val_dhas (symtab, gName))
                            val_dset (symtab, gName, val_dict ());
                          val_dset_str (val_dget (symtab, gName),
                                        "typeAttribute", buf);
                        }
                    }
                }
              if (operand[0] == '*'
                  && (firstCSECT == NULL || sect == NULL
                      || strcmp (sect, firstCSECT) != 0))
                {
                  /*
                   * `EQU *` in a section other than the first has to be
                   * converted from section-relative to absolute.  A DSECT is
                   * the exception and must be left alone:  it is a template
                   * describing the shape of storage somebody else owns, it
                   * occupies no address of its own, and `preliminaryOffset` is
                   * deliberately not computed for one.
                   */
                  if (sect != NULL && val_dhas (sects, sect)
                      && val_dget_bool (val_dget (sects, sect), "dsect", 0))
                    {
                      /* pass */
                    }
                  else if (sect == NULL || firstCSECT == NULL)
                    {
                      /* `EQU *` before any CSECT has been opened.  Nothing
                         precedes it, so there is nothing to add. */
                    }
                  else if (!val_dhas (val_dget (symtab, sect),
                                      "preliminaryOffset"))
                    {
                      asmError (properties,
                                py_format ("EQU * appears in section %s, whose "
                                           "position has not been established; "
                                           "the value is left relative to that "
                                           "section",
                                           sect),
                                255);
                    }
                  else
                    v = ASM_ADD (
                        ASM_ADD (ASM_AND (v, 0xFFFFFF),
                                 val_dget_int (val_dget (symtab, firstCSECT),
                                               "value", 0)),
                        val_dget_int (val_dget (symtab, sect),
                                      "preliminaryOffset", 0));
                }
              if (err)
                {
                  /* Quiet on the collecting passes:  an EQU whose operands are
                     defined further down is ordinary. */
                  if (compiling)
                    ERROR (properties, "Cannot evaluate EQU");
                  continue;
                }
              if (compiling
                  && (oldValue == NULL || val_as_int (oldValue) != v))
                repeatPass = 1;
              {
                Val *e = val_dict ();
                val_dset_str (e, "type", "EQU");
                val_dset_int (e, "value", v);
                val_dset (e, "properties", properties);
                val_dset (symtab, gName, e);
                if (!unhash (v, &vs, &vd))
                  vs = NULL;
                if (vs == NULL)
                  {
                    const char *bs;
                    asmint bo;
                    if (unhashBorrowed (v, 1, &bs, &bo))
                      {
                        vs = bs;
                        vd = -bo;
                      }
                  }
                if (vs != NULL)
                  {
                    val_dset_str (e, "section", vs);
                    val_dset_int (e, "address", vd);
                    val_dset_bool (e, "dsect",
                                   val_dget_bool (val_dget (sects, vs), "dsect",
                                                  0));
                  }
              }
              continue;
            }
          if (strcmp (operation, "LTORG") == 0)
            {
              commonProcessing (4, 0);
              if (collect && !asis)
                ltorg (sect);
              else if (literalPoolNumber < val_len (literalPools))
                {
                  /* RE-RECORD THE POOL'S POSITION ON EVERY LATER PASS, not
                     only the collecting ones.  In FCMNINIT pass 2 puts the
                     LTORG at 001CA and pass 3 at 001D2, which is where the
                     original build has it; the pool was written 16 bytes early,
                     straight over FCM25MS and FCMDLTIM. */
                  asmint poolBytes;
                  val_set (val_get (literalPools, literalPoolNumber), 1,
                           val_dget (val_dget (sects, sect), "pos1"));
                  /*
                   * AND ADVANCE PAST IT.  `commonProcessing(4)` aligns the
                   * location counter and nothing moved it over the pool's own
                   * bytes, so whatever followed an LTORG was assembled on top
                   * of the literals.
                   *
                   * `pos1` ONLY, DELIBERATELY NOT `used`:  "used" is
                   * documented as NOT including a trailing pool, and the
                   * between-passes bookkeeping adds the pool back to get a
                   * section's true length.  Forcing "used" here would make a
                   * TRAILING pool count twice and move every following CSECT.
                   */
                  poolBytes = val_as_int (
                      val_get (val_get (literalPools, literalPoolNumber), 4));
                  if (poolBytes)
                    val_dset_int (val_dget (sects, sect), "pos1",
                                  ASM_ADD (val_dget_int (val_dget (sects, sect),
                                                         "pos1", 0),
                                           poolBytes));
                }
              literalPoolNumber += 1;
              continue;
            }
          if (strcmp (operation, "USING") == 0
              || strcmp (operation, "DROP") == 0)
            {
              Val *a = val_deepcopy (val_dget (properties, "ast"));
              Val *rlist;
              size_t k;
              asmint h = 0;
              const char *section = NULL;
              asmint address = 0;
              if (strcmp (operation, "DROP") == 0
                  && py_strip (val_dget_str (properties, "operand", ""))[0]
                         == '\0')
                {
                  /* A DROP WITH NO OPERAND DROPS EVERY ACTIVE BASE REGISTER.
                     No source card in the corpus writes one, but a macro
                     generates one -- FIOCMPLT meets it in an expansion. */
                  int r;
                  for (r = 0; r < 8; r++)
                    val_set (using, (size_t) r, V_None);
                  continue;
                }
              if (val_is_none (a) || !val_dhas (a, "r")
                  || !val_is_exact_list (val_dget (a, "r")))
                {
                  asmError (properties,
                            py_format ("Cannot parse operand of %s", operation),
                            255);
                  continue;
                }
              rlist = val_retype (val_dget (a, "r"), V_LIST);
              for (k = 0; k < val_len (rlist); k++)
                {
                  Val *r = evalArithmeticExpression (
                      val_get (rlist, k), NULL, properties, symtab,
                      val_int (currentHash ()), 255);
                  val_set (rlist, k, r == NULL ? V_None : r);
                }
              if (strcmp (operation, "USING") == 0)
                {
                  if (val_len (rlist) < 1)
                    {
                      ERROR (properties, "No value specified");
                      continue;
                    }
                  if (val_is_none (val_get (rlist, 0)))
                    {
                      ERROR (properties, "Bad location");
                      continue;
                    }
                  h = val_as_int (val_get (rlist, 0));
                  val_remove_at (rlist, 0);
                  if (!unhash (h, &section, &address))
                    {
                      section = NULL;
                      address = 0;
                    }
                  val_dset_int (properties, "using", address);
                }
              for (k = 0; k < val_len (rlist); k++)
                {
                  Val *rv = val_get (rlist, k);
                  asmint r;
                  if (val_is_none (rv) || val_as_int (rv) < 0
                      || val_as_int (rv) > 7)
                    {
                      ERROR (properties, "Bad register number");
                      continue;
                    }
                  r = val_as_int (rv);
                  if (strcmp (operation, "USING") == 0)
                    {
                      /*
                       * THE BASE EXPRESSION IS CARRIED ALONG, with this
                       * register's place in the USING's register list.  The
                       * resolved `address` beside it is a SNAPSHOT, and where
                       * the base is a forward reference that snapshot is wrong
                       * by however far the symbol later moves;
                       * `optimizeScratch` re-evaluates the expression at the
                       * end of the pass, when it is known.
                       *
                       * ...AND WHERE THE USING ITSELF STANDS.  A USING emits
                       * nothing, so the NEXT scratch entry appended in this
                       * section begins at exactly the USING's own address, and
                       * `adjust` keeps that entry's `pos1` current as it
                       * slides.  Recording the index is how `optimizeScratch`
                       * recovers a LIVE location for `USING *,0`, whose base is
                       * a place rather than a symbol.
                       */
                      Val *tuple = val_seq (V_TUPLE);
                      val_append (tuple, val_int (h));
                      val_append (tuple,
                                  section == NULL ? V_None : val_str (section));
                      val_append (tuple, val_int (address));
                      val_append (tuple, properties);
                      val_append (tuple, val_int ((asmint) k));
                      if (section != NULL && val_dhas (sects, section))
                        val_append (tuple,
                                    val_int ((asmint) val_len (val_dget (
                                        val_dget (sects, section), "scratch"))));
                      else
                        val_append (tuple, V_None);
                      val_set (using, (size_t) r, tuple);
                      h = ASM_ADD (h, 4096);
                      address = ASM_ADD (address, 4096);
                    }
                  else
                    val_set (using, (size_t) r, V_None);
                }
              continue;
            }

          /*************** Partial alignment ***************
           * All `DC`, `DS` and all instructions must minimally be aligned to
           * halfword boundaries -- the addresses printed in assembly listings
           * are halfword addresses.  The manual's claim that some data is
           * byte-aligned refers to suboperands beyond the first.
           */
          if (sect == NULL || !val_dhas (sects, sect))
            {
              asmError (properties,
                        py_format ("Instruction outside of control section "
                                   "(undefined macro '%s'?)",
                                   operation),
                        255);
              continue;
            }
          {
            Val *s = val_dget (sects, sect);
            val_dset_int (s, "pos1",
                          val_dget_int (s, "pos1", 0)
                              + (val_dget_int (s, "pos1", 0) & 1));
            startingPos1 = val_dget_int (s, "pos1", 0);
          }
          (void) startingPos1;
          (void) data;
          (void) dataLen;

          /*************** Process instruction ***************
           * For these purposes pseudo-ops like `DS` and `DC`, which can have
           * labels, modify memory and move the instruction pointer, are
           * "instructions".
           */
          if (strcmp (operation, "ORG") == 0)
            {
              Val *a = val_dget (properties, "ast");
              asmint offset = 0;
              asmint newPos;
              if (val_is_none (a) || !val_is_dict (a))
                {
                  asmError (properties,
                            py_format ("Cannot parse %s operand", operation),
                            255);
                  continue;
                }
              if (val_dhas (a, "here"))
                offset = 0;
              else if (val_dhas (a, "plus"))
                {
                  if (!py_parse_int (val_dget_str (a, "dec", ""), &offset))
                    {
                      asmError (properties,
                                py_format ("Cannot parse %s operand", operation),
                                255);
                      continue;
                    }
                }
              else
                {
                  if (!py_parse_int (val_dget_str (a, "dec", ""), &offset))
                    {
                      asmError (properties,
                                py_format ("Cannot parse %s operand", operation),
                                255);
                      continue;
                    }
                  offset = -offset;
                }
              newPos = ASM_ADD (startingPos1, ASM_MUL (2, offset));
              if (newPos < 0)
                {
                  asmError (properties, "ORG out of range", compiling ? 255 : 0);
                  continue;
                }
              val_dset_int (val_dget (sects, sect), "pos1", newPos);
              if (newPos > val_dget_int (val_dget (sects, sect), "used", 0))
                val_dset_int (val_dget (sects, sect), "used", newPos);
              if (gName[0] != '\0' && val_dhas (symtab, gName))
                {
                  Val *e = val_dget (symtab, gName);
                  val_dset_int (e, "value",
                                ASM_AND (val_dget_int (e, "value", 0),
                                         (asmint) 0xFFFFFFFF00000000ULL)
                                    | (newPos / 2));
                }
              continue;
            }

          if (strcmp (operation, "DC") == 0 || strcmp (operation, "DS") == 0)
            {
              Val *a = val_dget (properties, "ast");
              Val *flattened;
              size_t dcBufferPtr = 0;
              Val *bitLengths;
              int packed = 0;
              size_t k;
              int isDC = (strcmp (operation, "DC") == 0);

              if (val_is_none (a))
                {
                  asmError (properties,
                            py_format ("Cannot parse %s operand: %s", operation,
                                       val_repr (val_dget (properties,
                                                           "operand"))),
                            255);
                  continue;
                }
              flattened = astFlattenList (a);

              /*
               * THE LENGTH ATTRIBUTE, L'.  GC28-6514-8 page 15 defines it as
               * the length of the storage the symbol names, taken from the
               * FIRST suboperand and ignoring the duplication factor.  There
               * it is a count of BYTES; here it is a count of HALFWORDS,
               * because the AP-101S is halfword-addressed and every other term
               * of the expressions L' appears in is in halfwords too.
               *
               * FIOCBLKS establishes that without reference to any manual:
               * `DC (TIOQPRI-(TIOQSELF+L'TIOQSELF))H'0'` runs from 000A4 to
               * 000A9, so the duplication factor is 5; with
               * TIOQPRI-TIOQSELF = 7 that forces L'TIOQSELF to 2, and
               * TIOQSELF is `DS F`, four bytes.
               */
              if (val_dhas (symtab, gName) && val_len (flattened) > 0)
                {
                  int ok = 0;
                  asmint lengthBytes = dcSuboperandBytes (
                      properties, val_get (flattened, 0), &ok);
                  if (ok)
                    {
                      asmint la = (lengthBytes + 1) / 2;
                      val_dset_int (val_dget (symtab, gName), "lengthAttribute",
                                    la < 1 ? 1 : la);
                    }
                }

              /*
               * BIT-LENGTH CONSTANTS, `DC AL.8(a),AL.5(b),AL.4(c),AL.15(d)`.
               * The operands are packed CONTIGUOUSLY, without regard to byte
               * boundaries, and the last byte is padded with zeros.  An
               * explicit length modifier also suppresses the alignment the
               * type would otherwise force.  Confirmed by the original build:
               * FCMINSSL's three command-word skeletons assemble to 00580000,
               * 005C8000 and 00598000, which is what contiguous packing of
               * 8+5+4+15 bits gives and nothing else does.
               */
              bitLengths = val_seq (V_LIST);
              for (k = 0; k < val_len (flattened); k++)
                {
                  Val *suboperand = val_get (flattened, k);
                  Val *l = val_dget (suboperand, "l");
                  int ok = 0;
                  asmint b = 0;
                  if (l != NULL && !(val_is_seq (l) && val_len (l) == 0))
                    b = evalBitLengthModifier (properties, l, &ok);
                  val_append (bitLengths, ok ? val_int (b) : V_None);
                  if (ok)
                    {
                      /* ANY bit-length modifier packs, not only one that is
                         not a whole byte.  `DC XL.8'24',YL.8(a-b)` is two
                         bytes in the original build and was three here. */
                      packed = 1;
                    }
                }
              if (packed)
                {
                  unsigned char *bits;
                  size_t nbits = 0, bitsCap = 256;
                  int failed = 0;
                  commonProcessing (1, 0);
                  bits = (unsigned char *) malloc (bitsCap);
                  if (bits == NULL)
                    fatal ("out of memory");
                  for (k = 0; k < val_len (flattened) && !failed; k++)
                    {
                      Val *suboperand = val_get (flattened, k);
                      Val *widthVal = val_get (bitLengths, k);
                      asmint width;
                      asmint repeats = 1;
                      Val *values;
                      const char *thisType;
                      Val *inner = NULL;
                      int haveLiteral = 0;
                      asmint literal = 0;
                      size_t e;

                      if (val_is_none (widthVal) || val_as_int (widthVal) <= 0)
                        {
                          /*
                           * AN OPERAND WITHOUT A BIT-LENGTH MODIFIER IS NOT
                           * PART OF THE PACKING.  It is not an error either:
                           * the packed run that precedes it is padded out to a
                           * byte boundary and the plain constant is laid down
                           * at its own natural length, which is what
                           * GC28-6514-8 says and what the original build does.
                           * BILDNEW5's `RDENVPTR DC AL.16(ENVIRONS),X'0001'`
                           * assembles to 80000001 there.
                           */
                          int ok = 0;
                          width = dcSuboperandBytes (properties, suboperand, &ok);
                          if (!ok || width <= 0)
                            {
                              ERROR (properties,
                                     "Cannot determine the length of a constant "
                                     "packed beside bit-length ones");
                              failed = 1;
                              break;
                            }
                          width *= 8;
                          while (nbits % 8 != 0)
                            {
                              if (nbits == bitsCap)
                                {
                                  bitsCap *= 2;
                                  bits = (unsigned char *) realloc (bits,
                                                                    bitsCap);
                                  if (bits == NULL)
                                    fatal ("out of memory");
                                }
                              bits[nbits++] = 0;
                            }
                        }
                      else
                        width = val_as_int (widthVal);

                      if (val_is_seq (val_dget (suboperand, "d"))
                          && val_len (val_dget (suboperand, "d")) == 0)
                        repeats = 1;
                      else
                        {
                          Val *r = evalArithmeticExpression (
                              val_dget (suboperand, "d"), NULL, properties,
                              symtab, val_int (currentHash ()),
                              compiling ? 255 : 0);
                          if (r == NULL)
                            {
                              ERROR (properties,
                                     "Could not evaluate duplication factor");
                              failed = 1;
                              break;
                            }
                          repeats = val_as_int (r);
                        }
                      values = val_dget (suboperand, "v");
                      /*
                       * HOW THE VALUE ARRIVES DEPENDS ON THE TYPE.  An address
                       * constant is parenthesised and may hold several
                       * expressions, while a quoted one is a single literal.
                       * Slicing parentheses off a quoted constant produced a
                       * malformed AST and the message "Implementation error:
                       * AST for X{',',X} not appropriate".
                       */
                      thisType = val_cstr (val_get (val_dget (suboperand, "t"), 0));
                      if (strcmp (thisType, "A") == 0
                          || strcmp (thisType, "Y") == 0
                          || strcmp (thisType, "Z") == 0
                          || strcmp (thisType, "S") == 0
                          || strcmp (thisType, "V") == 0)
                        {
                          Val *first = (values != NULL && val_len (values) > 0)
                                           ? val_get (values, 0)
                                           : NULL;
                          if (first != NULL && val_is_seq (first)
                              && val_len (first) >= 2)
                            inner = astFlattenList (
                                val_slice (first, 1,
                                           (ptrdiff_t) val_len (first) - 1));
                          else
                            inner = astFlattenList (values);
                        }
                      else
                        {
                          Val *first = (values != NULL && val_len (values) > 0)
                                           ? val_get (values, 0)
                                           : NULL;
                          Val *text = (first != NULL && val_len (first) > 1)
                                          ? val_get (first, 1)
                                          : NULL;
                          inner = val_seq (V_LIST);
                          if (strcmp (thisType, "X") == 0 && val_is_str (text))
                            {
                              int ok = 0;
                              literal = py_atoi_base (
                                  py_replace (val_cstr (text), ",", ""), 16, &ok);
                              haveLiteral = ok;
                            }
                          else if (strcmp (thisType, "B") == 0
                                   && val_is_str (text))
                            {
                              int ok = 0;
                              literal = py_atoi_base (
                                  py_replace (val_cstr (text), ",", ""), 2, &ok);
                              haveLiteral = ok;
                            }
                          else if (strcmp (thisType, "F") == 0
                                   || strcmp (thisType, "H") == 0)
                            {
                              /*
                               * `quotedFloatList` hands back the sign and the
                               * digits as SEPARATE tokens, so `-38` arrives as
                               * ('-', '38') rather than as a string; `int()` of
                               * that raises, and every negative packed constant
                               * failed while the positive ones beside them
                               * assembled.  MENU12 writes 29 of them.
                               *
                               * A COMMA IS NOT COSMETIC HERE, unlike in an X
                               * constant:  inside F or H it separates whole
                               * constants, and this path packs one value into
                               * one field.  `quotedFloatList` is
                               * ["'", first, [more...], "'"], so an empty
                               * element 2 means there is just one.
                               */
                              if (first != NULL && val_len (first) > 2
                                  && val_truthy (val_get (first, 2)))
                                haveLiteral = 0;
                              else if (text != NULL)
                                haveLiteral
                                    = py_parse_int (joinTokens (text), &literal);
                            }
                          if (!haveLiteral)
                            {
                              asmError (properties,
                                        py_format ("Cannot pack a %s constant "
                                                   "of this form into a bit "
                                                   "field",
                                                   thisType),
                                        255);
                              failed = 1;
                              break;
                            }
                          val_append (inner, V_None);
                        }

                      for (e = 0; e < val_len (inner) && !failed; e++)
                        {
                          asmint v;
                          const char *section;
                          asmint offset;
                          asmint rep;
                          if (haveLiteral)
                            v = literal;
                          else
                            {
                              /* QUIET ON THE COLLECTING PASSES.  This site took
                                 the default severity of 255, so a plain forward
                                 reference was fatal on pass 1 even though pass
                                 3 resolves it -- FIOCBLKS uses `AL.4(FIOMEBCC)`
                                 four statements before the EQU that defines
                                 it. */
                              Val *vv = evalArithmeticExpression (
                                  val_get (inner, e), NULL, properties, symtab,
                                  val_int (currentHash ()),
                                  compiling ? 255 : 0);
                              if (vv == NULL)
                                {
                                  if (compiling)
                                    ERROR (properties,
                                           "Cannot evaluate a bit-length "
                                           "constant");
                                  failed = 1;
                                  break;
                                }
                              v = val_as_int (vv);
                            }
                          if (unhash (v, &section, &offset) && section != NULL)
                            v = ASM_ADD (offset,
                                         val_dget_int (val_dget (sects, section),
                                                       "offset", 0));
                          for (rep = 0; rep < repeats; rep++)
                            {
                              asmint shift;
                              for (shift = width - 1; shift >= 0; shift--)
                                {
                                  if (nbits == bitsCap)
                                    {
                                      bitsCap *= 2;
                                      bits = (unsigned char *) realloc (bits,
                                                                        bitsCap);
                                      if (bits == NULL)
                                        fatal ("out of memory");
                                    }
                                  bits[nbits++]
                                      = (unsigned char) (((asmuint) v >> shift)
                                                         & 1);
                                }
                            }
                        }
                    }
                  if (failed)
                    {
                      free (bits);
                      continue;
                    }
                  /*
                   * PADDED OUT TO A HALFWORD, NOT TO A BYTE, and zero-filled.
                   * Measured off the OI301700 listings:  15 bits -> 2 bytes,
                   * 16 -> 2, 17 -> 4, 32 -> 4.  Byte padding predicts 3 bytes
                   * for the 17-bit group and the listing says 4; fullword
                   * padding is ruled out by the 15-bit group at two bytes.
                   *
                   * THE BYTE IT ADDS HAS TO COME FROM THE CONSTANT, NOT FROM
                   * THE FILL:  with `--fill=C6C6` FIODLCMW read 0088 00C6
                   * against the dump's 0088 0000.
                   */
                  while (nbits % 16 != 0)
                    {
                      if (nbits == bitsCap)
                        {
                          bitsCap *= 2;
                          bits = (unsigned char *) realloc (bits, bitsCap);
                          if (bits == NULL)
                            fatal ("out of memory");
                        }
                      bits[nbits++] = 0;
                    }
                  {
                    Val *bytesVal = val_bytes (nbits / 8);
                    size_t i;
                    for (i = 0; i < nbits; i++)
                      if (bits[i])
                        val_bytes_set (bytesVal, i / 8,
                                       (unsigned char) (val_bytes_get (bytesVal,
                                                                       i / 8)
                                                        | (0x80 >> (i % 8))));
                    free (bits);
                    if (isDC)
                      toMemory (bytesVal, 0, 1);
                    else
                      toMemory (NULL, (asmint) val_len (bytesVal), 1);
                  }
                  continue;
                }

              /*
               * At this point `flattened` has one entry per suboperand, each a
               * dictionary with the keys 'd' (duplication factor), 't' (type),
               * 'l' (length modifier) and 'v' (value), and each of those is
               * itself an AST.  How they are to be interpreted is in the
               * section "DC -- DEFINE CONSTANT" of GC28-6514-8.
               */
              for (k = 0; k < val_len (flattened); k++)
                {
                  Val *suboperand = val_get (flattened, k);
                  asmint duplicationFactor;
                  const char *suboperandType;
                  int haveLengthModifier = 0;
                  asmint lengthModifier = 0;
                  Val *lmod;

                  /* RESET THE BUFFER FOR EACH SUBOPERAND.  `toMemory` is
                     called once per suboperand, so whatever a suboperand
                     leaves in `dcBuffer` must not be written again by the next
                     one:  `DC X'1401D058',H'0'` wrote ten bytes for a six-byte
                     constant, with the X repeated. */
                  dcBufferPtr = 0;
                  if (val_is_seq (val_dget (suboperand, "d"))
                      && val_len (val_dget (suboperand, "d")) == 0)
                    duplicationFactor = 1;
                  else
                    {
                      /* WITH THE SYMBOL TABLE.  A duplication factor may be a
                         parenthesised expression naming symbols --
                         `DC (TTIOTNUM*2)H'0'` -- and this was evaluating it
                         against an EMPTY symtab, so every such symbol was
                         undefined by construction. */
                      Val *r = evalArithmeticExpression (
                          val_dget (suboperand, "d"), NULL, properties, symtab,
                          val_int (currentHash ()), compiling ? 255 : 0);
                      if (r == NULL)
                        {
                          if (compiling)
                            ERROR (properties,
                                   "Could not evaluate duplication factor");
                          continue;
                        }
                      duplicationFactor = val_as_int (r);
                    }
                  if (!val_dhas (suboperand, "t")
                      || val_len (val_dget (suboperand, "t")) == 0)
                    {
                      ERROR (properties, "Suboperand type not specified");
                      continue;
                    }
                  suboperandType
                      = val_cstr (val_get (val_dget (suboperand, "t"), 0));

                  /* Z type has a different field layout (z/f, not l/v), so it
                     is handled before the common l/v processing. */
                  if (strcmp (suboperandType, "Z") == 0)
                    {
                      /*
                       * ZCons:  `DC Z(symbol,,flags)`.  Four bytes,
                       * fullword-aligned, creating an external reference with
                       * a relocation.
                       */
                      const char *symbolName = NULL;
                      Val *zxExpression = NULL;
                      Val *a1Expression = NULL;
                      asmint flags = 0;
                      const char *zLocalSect = NULL;
                      asmint zAddress = 0;
                      Val *zaExpression;
                      commonProcessing (4, 0);
                      if (!isDC)
                        {
                          toMemory (NULL, ASM_MUL (duplicationFactor, 4), 1);
                          continue;
                        }
                      /* The symbol name comes from the 'z' field, or -- for
                         the `Z(,expression,flags)` form, which has no such
                         field -- from the leading identifier of the
                         expression.  Without this the constant still assembles
                         to the right bytes but carries NO relocation, so the
                         linker never fills its address in. */
                      if (val_is_str (val_dget (suboperand, "z")))
                        symbolName = val_dget_str (suboperand, "z", NULL);
                      if (symbolName == NULL
                          && val_truthy (val_dget (suboperand, "zx")))
                        {
                          zxExpression = val_get (val_dget (suboperand, "zx"), 0);
                          symbolName = leadingIdentifier (
                              describeExpression (zxExpression));
                        }
                      /* THE `Z(,expr,flags)` FORM CARRIES ITS ADDRESS IN THAT
                         EXPRESSION and only the SYMBOL was being taken from
                         it, so any displacement was dropped and the address
                         field emitted as zero. */
                      if (symbolName == NULL
                          && val_truthy (val_dget (suboperand, "A1")))
                        {
                          char *a1 = describeExpression (
                              val_dget (suboperand, "A1"));
                          symbolName = leadingIdentifier (a1);
                          if (symbolName != NULL)
                            a1Expression = val_dget (suboperand, "A1");
                        }
                      if (val_dhas (suboperand, "f")
                          && !val_is_none (val_dget (suboperand, "f")))
                        {
                          Val *fv = evalArithmeticExpression (
                              val_dget (suboperand, "f"), NULL, properties,
                              symtab, val_int (currentHash ()), 255);
                          flags = fv == NULL ? 0 : val_as_int (fv);
                        }
                      /*
                       * A SYMBOL THIS MODULE DEFINES ITSELF RELOCATES AGAINST
                       * ITS SECTION, NOT AGAINST ITSELF.  The address field
                       * below already holds the symbol's offset, so an RLD
                       * naming the SYMBOL makes the linker add its resolved
                       * address to its own offset and count it twice.  Naming
                       * the SECTION instead makes the linker add the section's
                       * base to the offset, which is what the field is for.
                       */
                      if (symbolName != NULL && val_dhas (symtab, symbolName))
                        {
                          Val *zl = val_dget (symtab, symbolName);
                          if (strcmp (val_dget_str (zl, "type", ""), "EXTERNAL")
                              != 0)
                            {
                              const char *zs;
                              asmint zo;
                              if (unhash (val_dget_int (zl, "value", 0), &zs, &zo)
                                  && zs != NULL && val_dhas (sects, zs)
                                  && !val_dget_bool (val_dget (sects, zs),
                                                     "dsect", 0))
                                zLocalSect = zs;
                            }
                        }
                      if (symbolName != NULL)
                        {
                          if (!val_dhas (symtab, symbolName))
                            {
                              Val *e = val_dict ();
                              val_dset (extrns, symbolName, V_True);
                              val_dset_str (e, "type", "EXTERNAL");
                              val_dset_int (e, "value", getHashcode (symbolName));
                              val_dset (symtab, symbolName, e);
                              rextrnSet (symbolName,
                                         val_dget_int (e, "value", 0));
                            }
                          else if (zLocalSect == NULL
                                   && strcmp (val_dget_str (
                                                  val_dget (symtab, symbolName),
                                                  "type", ""),
                                              "EXTERNAL")
                                          != 0)
                            {
                              if (!val_dhas (extrns, symbolName))
                                val_dset (extrns, symbolName, V_True);
                            }

                          if (compiling)
                            {
                              /*
                               * WHICH SECTOR REGISTER THE LINKER PATCHES IS THE
                               * RLD FLAG'S JOB, and every ZCON was being given
                               * the same one:  0x04 and 0x10 write the address
                               * and patch BSR, 0x50 writes it and patches DSR.
                               * With 0x04 for all of them a data ZCON had its
                               * sector put in BSR where the original build has
                               * it in DSR -- FCMZCONS read 0030 against
                               * DASS_SSW's 0003, twenty-one times over.
                               *
                               * `Z(sym,,flags)` and `Z(sym+n,...)` name a
                               * symbol first and are code; `Z(,expr,flags)`
                               * names none and is data.
                               */
                              asmint pos1
                                  = val_dget_int (val_dget (sects, sect), "pos1",
                                                  0);
                              int isCode
                                  = val_truthy (val_dget (suboperand, "z"))
                                    || val_truthy (val_dget (suboperand, "zx"));
                              Val *rel = val_dict ();
                              val_dset_str (rel, "symbol",
                                            zLocalSect != NULL ? zLocalSect
                                                               : symbolName);
                              val_dset_str (rel, "section", sect);
                              val_dset_int (rel, "address", pos1);
                              val_dset_int (rel, "flags", flags);
                              val_dset_int (rel, "rldFlags", isCode ? 0x04 : 0x50);
                              val_dset_str (rel, "type", "Z");
                              val_append (relocations, rel);
                              /*
                               * THE SECOND OPERAND IS THE DATA BASE AND IT WAS
                               * BEING THROWN AWAY.  HW1 of a ZCON is
                               * XC C CB CD BSR(7-4) DSR(3-0):  the address
                               * relocation above patches BSR from the ENTRY's
                               * sector, and the BASE's sector belongs in DSR,
                               * which came out 0.  A SEPARATE RLD says so --
                               * lnk101's addrcon.py documents the three that
                               * may point at one ZCON.
                               *
                               * ONLY FOR THE CODE FORM.  `Z(,expr,flags)` keeps
                               * its address in A1 and has no base operand at
                               * all; its DSR is patched by the 0x50 above.
                               */
                              if (isCode && val_truthy (val_dget (suboperand,
                                                                  "A1")))
                                {
                                  char *zBase = describeExpression (
                                      val_dget (suboperand, "A1"));
                                  const char *zBaseName
                                      = leadingIdentifier (zBase);
                                  if (zBaseName != NULL)
                                    {
                                      const char *zBaseSect = NULL;
                                      Val *zb = val_dget (symtab, zBaseName);
                                      if (zb != NULL
                                          && strcmp (val_dget_str (zb, "type",
                                                                   ""),
                                                     "EXTERNAL")
                                                 != 0)
                                        {
                                          const char *bs;
                                          asmint bo;
                                          if (unhash (val_dget_int (zb, "value",
                                                                    0),
                                                      &bs, &bo)
                                              && bs != NULL
                                              && val_dhas (sects, bs)
                                              && !val_dget_bool (
                                                  val_dget (sects, bs), "dsect",
                                                  0))
                                            zBaseSect = bs;
                                        }
                                      if (zb == NULL)
                                        {
                                          Val *e = val_dict ();
                                          val_dset (extrns, zBaseName, V_True);
                                          val_dset_str (e, "type", "EXTERNAL");
                                          val_dset_int (e, "value",
                                                        getHashcode (zBaseName));
                                          val_dset (symtab, zBaseName, e);
                                          rextrnSet (zBaseName,
                                                     val_dget_int (e, "value",
                                                                   0));
                                        }
                                      else if (zBaseSect == NULL
                                               && !val_dhas (extrns, zBaseName))
                                        val_dset (extrns, zBaseName, V_True);
                                      {
                                        Val *rel2 = val_dict ();
                                        val_dset_str (rel2, "symbol",
                                                      zBaseSect != NULL
                                                          ? zBaseSect
                                                          : zBaseName);
                                        val_dset_str (rel2, "section", sect);
                                        val_dset_int (rel2, "address", pos1);
                                        val_dset_int (rel2, "flags", 0);
                                        val_dset_int (rel2, "rldFlags", 0x40);
                                        val_dset_str (rel2, "type", "Z");
                                        val_append (relocations, rel2);
                                      }
                                    }
                                }
                            }
                        }

                      /*
                       * Emit four bytes:  address, address, flags, 0.
                       *
                       * A LOCALLY DEFINED SYMBOL GETS ITS ADDRESS HERE.  Zero
                       * is right only when the linker will fill the field, so
                       * only when the symbol is external.  FCMG3INT's
                       * `DC Z(FCG3INL1,FCMCBLKS,X'D')` names a label of its own
                       * at 0B and ASM101S assembled 0000.
                       */
                      zaExpression = zxExpression != NULL ? zxExpression
                                                          : a1Expression;
                      if (zaExpression != NULL)
                        {
                          Val *zv = evalArithmeticExpression (
                              zaExpression, NULL, properties, symtab,
                              val_int (currentHash ()), compiling ? 255 : 0);
                          if (zv != NULL)
                            {
                              const char *zxSect;
                              asmint zxOffset;
                              if (unhash (val_as_int (zv), &zxSect, &zxOffset)
                                  && zxSect != NULL)
                                zAddress = ASM_ADD (
                                    zxOffset,
                                    val_dget_int (val_dget (sects, zxSect),
                                                  "offset", 0));
                              else
                                zAddress = val_as_int (zv);
                            }
                        }
                      else if (symbolName != NULL
                               && val_dhas (symtab, symbolName)
                               && strcmp (val_dget_str (val_dget (symtab,
                                                                  symbolName),
                                                        "type", ""),
                                          "EXTERNAL")
                                      != 0)
                        {
                          Val *zEntry = val_dget (symtab, symbolName);
                          const char *zSect;
                          asmint zOffset;
                          if (unhash (val_dget_int (zEntry, "value", 0), &zSect,
                                      &zOffset)
                              && zSect != NULL)
                            zAddress = ASM_ADD (
                                zOffset, val_dget_int (val_dget (sects, zSect),
                                                       "offset", 0));
                          else
                            zAddress = val_dget_int (zEntry, "address", 0);
                        }
                      /* SECTION-RELATIVE, because the RLD above names the
                         SECTION for a local symbol and the linker adds that
                         section's base.  `zAddress` is measured from the first
                         CSECT, so a module with more than one would otherwise
                         carry the inter-section offset twice. */
                      if (zLocalSect != NULL)
                        zAddress = ASM_SUB (
                            zAddress, val_dget_int (val_dget (sects, zLocalSect),
                                                    "offset", 0));
                      dcBufferNeed (4);
                      dcBuffer[dcBufferPtr++]
                          = (unsigned char) ((zAddress >> 8) & 0xFF);
                      dcBuffer[dcBufferPtr++] = (unsigned char) (zAddress & 0xFF);
                      dcBuffer[dcBufferPtr++] = (unsigned char) (flags & 0xFF);
                      dcBuffer[dcBufferPtr++] = 0;
                      toMemory (val_bytes_from (dcBuffer, dcBufferPtr), 0, 1);
                      continue;
                    }

                  lmod = val_dget (suboperand, "l");
                  if (lmod == NULL || (val_is_seq (lmod) && val_len (lmod) == 0))
                    haveLengthModifier = 0;
                  else
                    {
                      int ok = 0;
                      lengthModifier = evalLengthModifier (properties, lmod, &ok);
                      if (!ok)
                        {
                          asmError (properties,
                                    py_format ("Could not evaluate the length "
                                               "modifier '%s'",
                                               describeExpression (lmod)),
                                    255);
                          continue;
                        }
                      haveLengthModifier = 1;
                    }

                  if (strcmp (suboperandType, "C") == 0)
                    {
                      /* Character constants used to generate NOTHING here --
                         no bytes, no advance of the location counter, and no
                         diagnostic either.  RUNASM contains no `DC C'...'`
                         anywhere, so 205 of 205 never showed it. */
                      Val *v = val_dget (suboperand, "v");
                      commonProcessing (1, 0);
                      if (isDC)
                        {
                          Val *quoted = val_len (v) > 0 ? val_get (v, 0) : NULL;
                          StrBuf text;
                          char *s;
                          size_t i;
                          if (quoted == NULL || val_len (quoted) < 3)
                            {
                              ERROR (properties, "Cannot parse C value");
                              continue;
                            }
                          sb_init (&text);
                          sb_add (&text, val_cstr (val_get (quoted, 1)));
                          for (i = 0; i < val_len (val_get (quoted, 2)); i++)
                            {
                              /* "''" inside a string is one quote. */
                              Val *piece = val_get (val_get (quoted, 2), i);
                              sb_add (&text, "'");
                              sb_add (&text, val_cstr (val_get (piece, 1)));
                            }
                          s = py_replace (sb_take (&text), "&&", "&");
                          if (haveLengthModifier)
                            {
                              /* Padded on the RIGHT with blanks, or truncated
                                 on the right, which is what distinguishes a
                                 character constant from the numeric types. */
                              if ((asmint) strlen (s) > lengthModifier)
                                s = py_substr (s, 0,
                                               (size_t) (lengthModifier < 0
                                                             ? 0
                                                             : lengthModifier));
                              else
                                s = py_ljust (s, (size_t) (lengthModifier < 0
                                                               ? 0
                                                               : lengthModifier));
                            }
                          dcBufferPtr = 0;
                          dcBufferNeed (strlen (s) + 1);
                          for (i = 0; s[i] != '\0'; i++)
                            {
                              unsigned char c = (unsigned char) s[i];
                              dcBuffer[dcBufferPtr++]
                                  = c < 128 ? asciiToEbcdic[c] : 0;
                            }
                          dcBufferPtr
                              = replicateDC (dcBufferPtr, duplicationFactor);
                          toMemory (val_bytes_from (dcBuffer, dcBufferPtr), 0, 1);
                          continue;
                        }
                      {
                        asmint length;
                        if (haveLengthModifier)
                          length = lengthModifier;
                        else if (val_len (v) > 0 && val_len (val_get (v, 0)) > 1)
                          length = (asmint) val_strlen (
                              val_get (val_get (v, 0), 1));
                        else
                          {
                            /* `DS C` with no length and no value:  the Python
                               raises IndexError here.  Diagnose it rather than
                               abandon the assembly. */
                            ERROR (properties,
                                   "DS C requires a length modifier or a value");
                            continue;
                          }
                        toMemory (NULL, ASM_MUL (duplicationFactor, length), 1);
                      }
                      continue;
                    }
                  if (strcmp (suboperandType, "X") == 0)
                    {
                      Val *v = val_dget (suboperand, "v");
                      Val *first = val_len (v) > 0 ? val_get (v, 0) : NULL;
                      Val *text = (first != NULL && val_len (first) > 1)
                                      ? val_get (first, 1)
                                      : NULL;
                      char *hexString;
                      asmint count;
                      commonProcessing (1, 0);
                      if (!val_is_str (text))
                        {
                          ERROR (properties, "Cannot parse X value");
                          continue;
                        }
                      hexString = arena_strdup (ARENA_MAIN, val_cstr (text));
                      if (strchr (hexString, ',') != NULL)
                        {
                          /*
                           * Commas inside a hexadecimal constant separate
                           * FULLWORDS for the reader and are not part of the
                           * value.  Every one of the 658 such constants across
                           * both PASS versions is written in groups of exactly
                           * eight digits, so concatenating them is right for
                           * all of them -- but that also means the corpus
                           * cannot distinguish concatenation from padding each
                           * group to a fullword on its own.  Say so rather
                           * than guess.
                           */
                          char **groups;
                          size_t ngroups = py_split_char (hexString, ',',
                                                          &groups);
                          size_t g;
                          int uniform = 1;
                          for (g = 0; g < ngroups; g++)
                            if (strlen (groups[g]) != 8)
                              uniform = 0;
                          if (!uniform)
                            ERROR (properties,
                                   "The groups of this hexadecimal constant are "
                                   "not all one fullword; whether they "
                                   "concatenate or are each padded separately is "
                                   "not established, and the object code here "
                                   "may be WRONG");
                          hexString = py_replace (hexString, ",", "");
                        }
                      if (!haveLengthModifier)
                        {
                          /*
                           * A HEXADECIMAL CONSTANT OCCUPIES WHOLE HALFWORDS,
                           * right-justified.  This was padded to an even number
                           * of DIGITS -- one byte -- which is what a System/360
                           * assembler does and is not what this one does:
                           * BILDNEW5's `DC X'8'` is 0008 and its
                           * `DC Y(RETRNJOB),X'11'` is 1E7B 0011.
                           */
                          count = (asmint) strlen (hexString);
                          count += (4 - (count % 4)) % 4;
                        }
                      else
                        count = lengthModifier * 2;
                      if (count > 0)
                        {
                          hexString = py_rjust (hexString, (size_t) count, '0');
                          hexString = py_substr (hexString,
                                                 strlen (hexString)
                                                     - (size_t) count,
                                                 (size_t) count);
                        }
                      if (isDC)
                        {
                          asmint i;
                          dcBufferPtr = 0;
                          dcBufferNeed ((size_t) count);
                          for (i = 0; i + 1 < count; i += 2)
                            {
                              int ok = 0;
                              char pair[3];
                              pair[0] = hexString[i];
                              pair[1] = hexString[i + 1];
                              pair[2] = '\0';
                              dcBuffer[dcBufferPtr++]
                                  = (unsigned char) py_atoi_base (pair, 16, &ok);
                            }
                          /* THE DUPLICATION FACTOR USED TO BE IGNORED HERE, and
                             only here.  `DC 594X'C6C6'` generated one halfword
                             instead of 594 of them, silently; the whole of
                             PCH27SRC and its fifteen siblings are a single such
                             statement. */
                          dcBufferPtr
                              = replicateDC (dcBufferPtr, duplicationFactor);
                          toMemory (val_bytes_from (dcBuffer, dcBufferPtr), 0, 1);
                        }
                      else
                        toMemory (NULL,
                                  ASM_MUL (duplicationFactor, count / 2), 1);
                      continue;
                    }
                  if (strcmp (suboperandType, "B") == 0)
                    {
                      /*
                       * THIS WAS A STUB -- `commonProcessing(1)` and nothing
                       * else -- so `DC B'...'` emitted no bytes AND reserved no
                       * space, silently.  A bit-length modifier goes to the
                       * packing path above and never arrives here, which is why
                       * the form that IS common in the corpus worked and the
                       * plain one did not.  FIOCBLKS writes 81 of them.
                       *
                       * A binary constant is padded or truncated on the LEFT,
                       * like the other numeric types.
                       */
                      Val *v = val_dget (suboperand, "v");
                      Val *first = val_len (v) > 0 ? val_get (v, 0) : NULL;
                      Val *text = (first != NULL && val_len (first) > 1)
                                      ? val_get (first, 1)
                                      : NULL;
                      char *digits;
                      asmint nBytes;
                      commonProcessing (1, 0);
                      if (!val_is_str (text))
                        {
                          ERROR (properties, "Cannot parse B value");
                          continue;
                        }
                      digits = arena_strdup (ARENA_MAIN, val_cstr (text));
                      if (haveLengthModifier)
                        nBytes = lengthModifier;
                      else
                        {
                          nBytes = ((asmint) strlen (digits) + 7) / 8;
                          if (nBytes < 1)
                            nBytes = 1;
                        }
                      if (nBytes > 0)
                        {
                          digits = py_rjust (digits, (size_t) (nBytes * 8), '0');
                          digits = py_substr (digits,
                                              strlen (digits)
                                                  - (size_t) (nBytes * 8),
                                              (size_t) (nBytes * 8));
                        }
                      if (isDC)
                        {
                          asmint i;
                          dcBufferPtr = 0;
                          dcBufferNeed ((size_t) nBytes + 1);
                          for (i = 0; i < nBytes * 8; i += 8)
                            {
                              int ok = 0;
                              char byte[9];
                              memcpy (byte, digits + i, 8);
                              byte[8] = '\0';
                              dcBuffer[dcBufferPtr++]
                                  = (unsigned char) py_atoi_base (byte, 2, &ok);
                            }
                          dcBufferPtr
                              = replicateDC (dcBufferPtr, duplicationFactor);
                          toMemory (val_bytes_from (dcBuffer, dcBufferPtr), 0, 1);
                        }
                      else
                        toMemory (NULL, ASM_MUL (duplicationFactor, nBytes), 1);
                      continue;
                    }
                  if (strcmp (suboperandType, "F") == 0
                      || strcmp (suboperandType, "H") == 0)
                    {
                      asmint length;
                      asmint multiplier;
                      asmuint mask;
                      double scaleFactor = 1.0;
                      int scaled = 0;
                      if (strcmp (suboperandType, "H") == 0)
                        {
                          length = 2;
                          multiplier = (asmint) 1 << 15;
                          mask = 0xFFFFu;
                        }
                      else
                        {
                          length = 4;
                          multiplier = (asmint) 1 << 31;
                          mask = 0xFFFFFFFFu;
                        }
                      commonProcessing (haveLengthModifier ? 1 : length, 0);
                      if (haveLengthModifier)
                        {
                          /* Honour it, rather than the `pass` that used to
                             stand here and left F and H at their natural 4 and
                             2 bytes however they were written. */
                          if (lengthModifier < 1)
                            {
                              asmError (properties,
                                        py_format ("Length modifier %lld is out "
                                                   "of range",
                                                   (long long) lengthModifier),
                                        compiling ? 255 : 0);
                              continue;
                            }
                          length = lengthModifier;
                          multiplier = (length >= 8)
                                           ? (asmint) ((asmuint) 1 << 63)
                                           : ((asmint) 1 << (8 * length - 1));
                          mask = (length >= 8) ? (asmuint) 0xFFFFFFFFFFFFFFFFULL
                                               : (((asmuint) 1 << (8 * length))
                                                  - 1);
                        }
                      /*
                       * THE SCALE MODIFIER moves the binary point:  the value is
                       * multiplied by two to the MINUS scale before being taken
                       * as a fraction of the full word.  Checked against the
                       * original build, which assembles `DC FS4'10'` as
                       * 50000000 -- 10 x 2^-4 is 0.625, and 0.625 x 2^31 is
                       * 0x50000000 -- and `DC FS-19'1E-6'` as 431BDE83, which
                       * comes out right only when the product is ROUNDED.
                       */
                      if (val_dhas (suboperand, "s")
                          && !(val_is_seq (val_dget (suboperand, "s"))
                               && val_len (val_dget (suboperand, "s")) == 0))
                        {
                          Val *sv = unroll (val_dget (suboperand, "s"));
                          StrBuf digits;
                          asmint n;
                          size_t i;
                          sb_init (&digits);
                          if (val_is_str (sv))
                            {
                              if (!val_eq_str (sv, "S"))
                                sb_add (&digits, val_cstr (sv));
                            }
                          else
                            for (i = 0; i < val_len (sv); i++)
                              if (!val_eq_str (val_get (sv, i), "S"))
                                sb_add (&digits, val_cstr (val_get (sv, i)));
                          if (!py_parse_int (sb_take (&digits), &n))
                            {
                              ERROR (properties,
                                     "Cannot evaluate the scale modifier");
                              continue;
                            }
                          {
                            double p = 1.0;
                            asmint j;
                            for (j = 0; j < (n < 0 ? -n : n); j++)
                              p *= 2.0;
                            scaleFactor = (n < 0) ? p : 1.0 / p;
                          }
                          scaled = 1;
                        }
                      if (isDC)
                        {
                          Val *v = val_dget (suboperand, "v");
                          Val *first = val_len (v) > 0 ? val_get (v, 0) : NULL;
                          Val *list;
                          size_t i;
                          if (first == NULL || val_len (first) < 2)
                            {
                              ERROR (properties, "Cannot parse F/H value");
                              continue;
                            }
                          /* `suboperand["v"]` holds ONE quotedFloatList, and
                             every value after the first lives inside its
                             repetition element.  Iterating it directly saw only
                             the first, so `DC F'1,2'` silently generated just
                             the 1. */
                          list = astFlattenList (val_slice (
                              first, 1, (ptrdiff_t) val_len (first) - 1));
                          dcBufferNeed ((size_t) (length * (asmint) val_len (list)
                                                  + 8));
                          for (i = 0; i < val_len (list); i++)
                            {
                              Val *exp1 = val_get (list, i);
                              asmuint v;
                              asmint j;
                              asmint b;
                              if (!scaled && val_is_str (exp1)
                                  && py_isdigit (val_cstr (exp1)))
                                {
                                  asmint iv = 0;
                                  py_parse_int (val_cstr (exp1), &iv);
                                  v = (asmuint) iv & mask;
                                }
                              else if (!scaled && val_is_tuplelike (exp1)
                                       && val_len (exp1) == 2
                                       && val_eq_str (val_get (exp1, 0), "-")
                                       && py_isdigit (
                                           val_cstr (val_get (exp1, 1))))
                                {
                                  asmint iv = 0;
                                  py_parse_int (joinTokens (exp1), &iv);
                                  v = (asmuint) iv & mask;
                                }
                              else
                                {
                                  /*
                                   * THE SCALED VALUE IS TAKEN AS A FRACTION OF
                                   * THE FIELD ONLY WHEN IT IS ONE.  It is not
                                   * "unscaled means integer":  that was tried
                                   * and it broke CTOI, ETOC, ITOC and KTOC, all
                                   * of which write `DC F'0.625'` with no scale
                                   * modifier and expect 50000000.  Magnitude
                                   * decides it -- 0.625 is a fraction, 1800E6
                                   * is a count.
                                   */
                                  double d = py_atof (joinTokens (exp1))
                                             * scaleFactor;
                                  if (d > -1.0 && d < 1.0)
                                    {
                                      d *= (double) multiplier;
                                      if (d >= (double) multiplier)
                                        d = (double) (multiplier - 1);
                                      else if (d <= -(double) multiplier)
                                        d = (double) (-multiplier + 1);
                                    }
                                  v = (asmuint) py_round (d) & mask;
                                }
                              j = (length - 1) * 8;
                              for (b = 0; b < length; b++)
                                {
                                  dcBuffer[dcBufferPtr++]
                                      = (unsigned char) ((v >> j) & 0xFF);
                                  j -= 8;
                                }
                            }
                          dcBufferPtr
                              = replicateDC (dcBufferPtr, duplicationFactor);
                          toMemory (val_bytes_from (dcBuffer, dcBufferPtr), 0, 1);
                          continue;
                        }
                      toMemory (NULL, ASM_MUL (duplicationFactor, length), 1);
                      continue;
                    }
                  if (strcmp (suboperandType, "E") == 0
                      || strcmp (suboperandType, "D") == 0)
                    {
                      asmint fpLength = strcmp (suboperandType, "E") == 0 ? 4 : 8;
                      asmint length = fpLength;
                      /* Even doublewords are aligned to a fullword. */
                      commonProcessing (4, 0);
                      if (isDC)
                        {
                          Val *v = val_dget (suboperand, "v");
                          Val *first = val_len (v) > 0 ? val_get (v, 0) : NULL;
                          Val *values;
                          size_t i;
                          if (first == NULL || val_len (first) < 2)
                            {
                              ERROR (properties, "Cannot parse E/D value");
                              continue;
                            }
                          values = astFlattenList (val_slice (
                              first, 1, (ptrdiff_t) val_len (first) - 1));
                          dcBufferNeed ((size_t) (fpLength
                                                      * (asmint) val_len (values)
                                                  + 8));
                          for (i = 0; i < val_len (values); i++)
                            {
                              uint32_t msw, lsw;
                              asmint j, b;
                              toFloatIBM (joinTokens (val_get (values, i)), NULL,
                                          &msw, &lsw);
                              if (fpLength == 4)
                                {
                                  /* A short constant keeps only the top 24 bits
                                     of the fraction, and the original ROUNDS the
                                     rest rather than dropping it. */
                                  msw = roundFloatIBMShort (msw, lsw);
                                }
                              j = 24;
                              for (b = 0; b < 4; b++)
                                {
                                  dcBuffer[dcBufferPtr++]
                                      = (unsigned char) ((msw >> j) & 0xFF);
                                  j -= 8;
                                }
                              if (fpLength == 8)
                                {
                                  j = 24;
                                  for (b = 0; b < 4; b++)
                                    {
                                      dcBuffer[dcBufferPtr++]
                                          = (unsigned char) ((lsw >> j) & 0xFF);
                                      j -= 8;
                                    }
                                }
                            }
                          dcBufferPtr
                              = replicateDC (dcBufferPtr, duplicationFactor);
                          toMemory (val_bytes_from (dcBuffer, dcBufferPtr), 0, 1);
                          continue;
                        }
                      toMemory (NULL, ASM_MUL (duplicationFactor, length), 1);
                      continue;
                    }
                  if (strcmp (suboperandType, "A") == 0)
                    {
                      if (haveLengthModifier)
                        commonProcessing (1, 0);
                      else if (!isDC)
                        {
                          /* `DS A` reached NEITHER of the commonProcessing
                             calls below, and commonProcessing is what replaces
                             a label's PRELIMINARY value with its real one.  So
                             every `DS A` label kept the placeholder -- TCVTIOQ
                             came out as 220 where it belongs at 78 -- and never
                             got the fullword alignment an A-type constant is
                             due. */
                          commonProcessing (4, 0);
                        }
                      if (isDC)
                        {
                          Val *v;
                          Val *first;
                          Val *list;
                          size_t i;
                          commonProcessing (4, 0);
                          if (val_dhas (suboperand, "h")
                              && val_len (val_dget (suboperand, "h")) > 0)
                            {
                              int ok = 0;
                              asmint lsw = py_atoi_base (
                                  val_cstr (val_get (
                                      val_get (val_dget (suboperand, "h"), 0),
                                      1)),
                                  16, &ok);
                              asmint j = 24, b;
                              dcBufferNeed (8);
                              for (b = 0; b < 4; b++)
                                {
                                  dcBuffer[dcBufferPtr++]
                                      = (unsigned char) (((asmuint) lsw >> j)
                                                         & 0xFF);
                                  j -= 8;
                                }
                              dcBufferPtr
                                  = replicateDC (dcBufferPtr, duplicationFactor);
                              toMemory (val_bytes_from (dcBuffer, dcBufferPtr), 0,
                                        1);
                              continue;
                            }
                          /*
                           * `DC A(expression)` NEVER EMITTED ITS VALUE.  Only
                           * the `A'hexadecimal'` form above wrote anything; the
                           * ordinary parenthesised form fell through to a
                           * `toMemory(count)` that only ADVANCES the location
                           * counter.  It went unnoticed because an A constant
                           * inside a DSECT generates no object code to compare,
                           * and that is where most of them are.
                           */
                          v = val_dget (suboperand, "v");
                          first = val_len (v) > 0 ? val_get (v, 0) : NULL;
                          if (first == NULL || val_len (first) < 2)
                            {
                              ERROR (properties, "Cannot parse A value");
                              continue;
                            }
                          list = astFlattenList (val_slice (
                              first, 1, (ptrdiff_t) val_len (first) - 1));
                          dcBufferNeed (4 * val_len (list) + 8);
                          for (i = 0; i < val_len (list); i++)
                            {
                              Val *vv = evalArithmeticExpression (
                                  val_get (list, i), NULL, properties, symtab,
                                  val_int (currentHash ()),
                                  compiling ? 255 : 0);
                              asmint value;
                              const char *aSect;
                              asmint aOffset;
                              int j;
                              if (vv == NULL)
                                {
                                  if (compiling)
                                    ERROR (properties,
                                           "Cannot evaluate A-type constant");
                                  value = 0;
                                }
                              else
                                value = val_as_int (vv);
                              if (unhash (value, &aSect, &aOffset)
                                  && aSect != NULL)
                                {
                                  value = ASM_ADD (
                                      aOffset,
                                      val_dget_int (val_dget (sects, aSect),
                                                    "offset", 0));
                                  /*
                                   * AND IT NEEDS AN RLD ENTRY.  Emitting the
                                   * resolved value satisfies a comparison
                                   * against the LISTING, which shows that value
                                   * whether or not the constant relocates -- so
                                   * the sweep cannot see this missing and did
                                   * not.  A link can:  without it an A constant
                                   * naming an external symbol is never
                                   * relocated.
                                   */
                                  if (compiling)
                                    {
                                      const char *rldSymbol = aSect;
                                      size_t sn;
                                      Val *rel;
                                      for (sn = 0; sn < val_dlen (sects); sn++)
                                        {
                                          Val *sd = val_dval (sects, sn);
                                          asmint so, su;
                                          if (val_dget_bool (sd, "dsect", 0)
                                              || !val_dhas (sd, "offset"))
                                            continue;
                                          so = val_dget_int (sd, "offset", 0);
                                          su = val_dget_int (sd, "used", 0) / 2;
                                          if (value >= so && value < so + su
                                              && strcmp (val_dkey (sects, sn),
                                                         sect)
                                                     != 0)
                                            {
                                              rldSymbol = val_dkey (sects, sn);
                                              break;
                                            }
                                        }
                                      rel = val_dict ();
                                      val_dset_str (rel, "symbol", rldSymbol);
                                      val_dset_str (rel, "section", sect);
                                      val_dset_int (
                                          rel, "address",
                                          ASM_ADD (val_dget_int (
                                                       val_dget (sects, sect),
                                                       "pos1", 0),
                                                   (asmint) dcBufferPtr));
                                      val_dset_str (rel, "type", "A");
                                      val_append (relocations, rel);
                                    }
                                }
                              for (j = 24; j >= 0; j -= 8)
                                dcBuffer[dcBufferPtr++]
                                    = (unsigned char) (((asmuint) value >> j)
                                                       & 0xFF);
                            }
                          dcBufferPtr
                              = replicateDC (dcBufferPtr, duplicationFactor);
                          toMemory (val_bytes_from (dcBuffer, dcBufferPtr), 0, 1);
                          continue;
                        }
                      toMemory (NULL, ASM_MUL (duplicationFactor, 4), 1);
                      continue;
                    }
                  if (strcmp (suboperandType, "Y") == 0)
                    {
                      commonProcessing (haveLengthModifier ? 1 : 2, 0);
                      if (isDC)
                        {
                          Val *v = val_dget (suboperand, "v");
                          Val *first = val_len (v) > 0 ? val_get (v, 0) : NULL;
                          Val *list;
                          size_t i;
                          if (first == NULL || val_len (first) < 2)
                            {
                              ERROR (properties, "Cannot parse Y value");
                              continue;
                            }
                          /* As in the integer path above, every address after
                             the first lives inside the repetition element of a
                             single `addresses`, so iterating "v" directly
                             handed the whole tuple to the evaluator and
                             `DC Y(L1,L2)` produced one halfword. */
                          list = astFlattenList (val_slice (
                              first, 1, (ptrdiff_t) val_len (first) - 1));
                          dcBufferNeed (2 * val_len (list) + 8);
                          for (i = 0; i < val_len (list); i++)
                            {
                              /* QUIET ON THE COLLECTING PASSES.  A Y constant
                                 may name a symbol EQU'd further down the
                                 module, which is exactly what the later passes
                                 are for; 58 modules were blocked by forward
                                 references of this kind. */
                              Val *vv = evalArithmeticExpression (
                                  val_get (list, i), NULL, properties, symtab,
                                  val_int (currentHash ()),
                                  compiling ? 255 : 0);
                              asmint value;
                              const char *ySect;
                              asmint yOffset;
                              int yNegative = 0;
                              if (vv == NULL)
                                {
                                  if (compiling)
                                    ERROR (properties,
                                           "Cannot evaluate Y-type constant");
                                  value = 0;
                                }
                              else
                                value = val_as_int (vv);
                              if (!unhash (value, &ySect, &yOffset))
                                ySect = NULL;
                              if (ySect == NULL)
                                {
                                  /*
                                   * A NEGATIVE OFFSET FROM AN EXTERNAL SYMBOL
                                   * borrows out of the 32-bit offset field into
                                   * the four-bit buffer above it, so `unhash`
                                   * returns nothing and the low sixteen bits
                                   * fell through raw:  FCMCBLKS'
                                   * `DC Y(CZ2VNOMB-1)` assembled FFFF where the
                                   * original has 0001.
                                   *
                                   * THE ORIGINAL EMITS THE MAGNITUDE, not the
                                   * two's complement -- the field is an
                                   * unsigned address the linker adds the symbol
                                   * to -- AND THE RLD HAS TO SAY IT IS
                                   * NEGATIVE.  Without that flag the linker
                                   * ADDS the magnitude, so `Y(SYM-1)` links as
                                   * SYM+1.
                                   */
                                  const char *bs;
                                  asmint bm;
                                  if (unhashBorrowed (value, 0, &bs, &bm))
                                    {
                                      ySect = bs;
                                      yOffset = bm;
                                      yNegative = 1;
                                    }
                                }
                              if (ySect != NULL && compiling)
                                {
                                  asmint combinedOffset = ASM_ADD (
                                      yOffset,
                                      val_dget_int (val_dget (sects, ySect),
                                                    "offset", 0));
                                  const char *rldSymbol = ySect;
                                  size_t sn;
                                  Val *rel;
                                  for (sn = 0; sn < val_dlen (sects); sn++)
                                    {
                                      Val *sd = val_dval (sects, sn);
                                      asmint so, su;
                                      if (val_dget_bool (sd, "dsect", 0)
                                          || !val_dhas (sd, "offset"))
                                        continue;
                                      so = val_dget_int (sd, "offset", 0);
                                      su = val_dget_int (sd, "used", 0) / 2;
                                      if (combinedOffset >= so
                                          && combinedOffset < so + su
                                          && strcmp (val_dkey (sects, sn), sect)
                                                 != 0)
                                        {
                                          rldSymbol = val_dkey (sects, sn);
                                          break;
                                        }
                                    }
                                  rel = val_dict ();
                                  val_dset_str (rel, "symbol", rldSymbol);
                                  val_dset_str (rel, "section", sect);
                                  val_dset_int (
                                      rel, "address",
                                      ASM_ADD (val_dget_int (
                                                   val_dget (sects, sect), "pos1",
                                                   0),
                                               (asmint) dcBufferPtr));
                                  val_dset_bool (rel, "negative", yNegative);
                                  val_dset_str (rel, "type", "Y");
                                  val_append (relocations, rel);
                                  value = combinedOffset;
                                }
                              dcBuffer[dcBufferPtr++]
                                  = (unsigned char) (((asmuint) value >> 8)
                                                     & 0xFF);
                              dcBuffer[dcBufferPtr++]
                                  = (unsigned char) (value & 0xFF);
                            }
                          dcBufferPtr
                              = replicateDC (dcBufferPtr, duplicationFactor);
                          toMemory (val_bytes_from (dcBuffer, dcBufferPtr), 0, 1);
                          continue;
                        }
                      toMemory (NULL, ASM_MUL (duplicationFactor, 2), 1);
                      continue;
                    }
                  asmError (properties,
                            py_format ("Unsupported DC/DS type %s",
                                       suboperandType),
                            255);
                  continue;
                }
              continue;
            }

          if (intmap_has (&argsRR, operation))
            {
              Val *a;
              commonProcessing (2, 0);
              if (!compiling)
                {
                  toMemory (NULL, 2, 1);
                  continue;
                }
              memset (data, 0, 2);
              dataLen = 2;
              a = val_dget (properties, "ast");
              if (!val_is_none (a))
                {
                  /* The mnemonics below supply R1 themselves, and left `err`
                     holding whatever the last RR instruction assembled had put
                     there. */
                  int err = 0;
                  int present = 0;
                  asmint r1 = 0, r2 = 0;
                  asmint opcode;
                  if (strcmp (operation, "SPM") == 0)
                    {
                      if (val_dhas (a, "r1")
                          && val_len (val_dget (a, "r1")) != 0)
                        ERROR (properties, "Cannot specify register R1.");
                      r1 = 0;
                    }
                  else if (intmap_has (&rrBranchAliases, operation))
                    {
                      /* `BR`, `NOPR`, `BZR` and the rest are all `BCR` with the
                         condition mask written into the mnemonic, so the single
                         operand is R2 and R1 must not be given. */
                      if (val_dhas (a, "r1")
                          && val_len (val_dget (a, "r1")) != 0)
                        ERROR (properties, "Cannot specify condition.");
                      r1 = intmap_get (&rrBranchAliases, operation, 0);
                    }
                  else
                    err = evalInstructionSubfield (properties, "R1", a, symtab,
                                                   &r1, &present);
                  if (err || r1 < 0 || r1 > 7)
                    {
                      ERROR (properties, "Invalid register R1; must be 0-7");
                      r1 = 0;
                    }
                  err = evalInstructionSubfield (properties, "R2", a, symtab,
                                                 &r2, &present);
                  if (strcmp (operation, "LFXI") == 0)
                    {
                      if (err || r2 < -2 || r2 > 13)
                        {
                          ERROR (properties,
                                 "Invalid immediate value; must be -2 through "
                                 "13");
                          r2 = -2;
                          err = 0;
                        }
                      r2 = (r2 + 2) & 0x0F;
                      val_dset_int (properties, "adr2", r2);
                    }
                  else if (strcmp (operation, "LFLI") == 0)
                    {
                      if (err || r2 < 0 || r2 > 15)
                        {
                          ERROR (properties,
                                 "Invalid immediate value; must be 0-15");
                          r2 = 0;
                          err = 0;
                        }
                      r2 &= 0x0F;
                    }
                  else if (err || r2 < 0 || r2 > 7)
                    {
                      ERROR (properties, "Invalid register R2; must be 0-7");
                      r2 = 0;
                    }
                  opcode = intmap_get (&argsRR, operation, 0);
                  data[0] = (unsigned char) (((opcode & 0x3E) << 2) | r1);
                  data[1] = (unsigned char) (0xE0 | ((opcode & 1) << 3) | r2);
                }
              toMemory (val_bytes_from (data, (size_t) dataLen), 0, 1);
              continue;
            }

          if (intmap_has (&argsSRSorRS, operation))
            {
              /*
               * THE CONUNDRUM.  For the mnemonics in `argsSRSandRS` there is
               * both an RS version of the instruction (two halfwords) and an
               * SRS version (one), with no syntactic difference between them.
               * The old assembler decided, it seems, on the size of D2 --
               * short below 56, long at or above -- but the size of D2 often
               * cannot be determined on an early pass, because it may involve
               * unresolved forward references.  In other words the size of the
               * instruction frequently cannot be worked out without already
               * knowing the size of the instruction.
               */
              Val *a;
              asmint dataSize;
              Val *literalAttributes = NULL;
              const char *op = operation;
              commonProcessing (2, 0);
              if (collect && !asis)
                dataSize = 4;
              else
                dataSize = val_dget_int (properties, "length", 4);
              if (intmap_has (&argsSRSonly, op))
                dataSize = 2;
              a = val_dget (properties, "ast");
              if (val_is_none (a))
                {
                  /* An RS/SRS mnemonic with no operand field at all, so there
                     was nothing to parse and nothing to generate from.  This
                     used to fall straight into `"L2" in ast` and raise. */
                  asmError (properties,
                            py_format ("%s requires an operand", op), 255);
                  continue;
                }
              if (val_dhas (a, "L2"))
                {
                  literalAttributes
                      = evalLiteralAttributes (properties, a, symtab);
                  if (literalAttributes == NULL)
                    continue;
                  if (collect && !asis)
                    {
                      Val *pool
                          = val_get (literalPools, val_len (literalPools) - 1);
                      if (literalIndex (pool, literalAttributes) < 0)
                        val_append (pool, literalAttributes);
                    }
                  else
                    {
                      Val *pool = val_get (literalPools, literalPoolNumber);
                      ptrdiff_t i = literalIndex (pool, literalAttributes);
                      if (i < 0)
                        {
                          asmError (properties,
                                    py_format ("Literal is not in the pool: %s",
                                               val_dget_str (literalAttributes,
                                                             "operand", "")),
                                    255);
                          continue;
                        }
                      /* A RELOCATABLE LITERAL SETTLES like anything else that
                         depends on an address, so a changed value is news to
                         act on rather than an error:  store it and go round
                         again. */
                      if (!val_eq (val_dget (val_get (pool, (size_t) i), "value"),
                                   val_dget (literalAttributes, "value")))
                        {
                          val_set (pool, (size_t) i, literalAttributes);
                          repeatPass = 1;
                        }
                    }
                }
              if (!compiling)
                {
                  toMemory (NULL, dataSize, 1);
                  continue;
                }
              dataLen = (int) dataSize;
              memset (data, 0, sizeof (data));
              {
                int err = 0, present = 0;
                int haveR1 = 0, haveD2 = 0, haveB2 = 0, haveX2 = 0;
                asmint r1 = 0, d2 = 0, b2 = 0, x2 = 0;
                asmint originalD2 = 0;
                int extrnD2 = 0, extrnBase = 0;

                /* R1 is syntactically omitted for various instructions, and an
                   implied R1 is used instead. */
                if (intmap_has (&branchAliases, op))
                  {
                    r1 = intmap_get (&branchAliases, op, 0);
                    haveR1 = 1;
                  }
                else if (intmap_has (&impliedR1, op))
                  {
                    r1 = intmap_get (&impliedR1, op, 0);
                    haveR1 = 1;
                    err = 0;
                  }
                else
                  {
                    err = evalInstructionSubfield (properties, "R1", a, symtab,
                                                   &r1, &present);
                    haveR1 = present;
                  }
                if (haveR1)
                  {
                    if (literalAttributes != NULL)
                      {
                        /* This can happen only if "L2" is in the AST, and hence
                           the second operand is a so-called literal. */
                        Val *pool = val_get (literalPools, literalPoolNumber);
                        ptrdiff_t idx = literalIndex (pool, literalAttributes);
                        err = 0;
                        d2 = ASM_ADD (val_as_int (val_get (pool, 1)),
                                      val_as_int (val_get (val_get (pool, 3),
                                                           (size_t) idx)))
                             / 2;
                        haveD2 = 1;
                      }
                    else
                      {
                        err = evalInstructionSubfield (properties, "D2", a,
                                                       symtab, &d2, &present);
                        haveD2 = present;
                      }
                    originalD2 = d2;
                    extrnD2 = haveD2 && rextrnHas (d2);
                    /* IS THE OPERAND EXTERNAL AT ALL, offset or not?
                       `rextrns` is keyed by the bare hashcode, so an EXTRN
                       carrying a displacement -- `FIOBCES1+2` -- is absent from
                       it and `extrnD2` is False. */
                    extrnBase = extrnD2
                                || (haveD2
                                    && rextrnHas (ASM_AND (d2, HASHCODE_MASK)));
                    if (!err && haveD2)
                      {
                        val_dset_int (properties, "adr1", ASM_AND (d2, 0xFFFF));
                        err = evalInstructionSubfield (properties, "B2", a,
                                                       symtab, &b2, &present);
                        haveB2 = present;
                        if (!err)
                          {
                            err = evalInstructionSubfield (properties, "X2", a,
                                                           symtab, &x2,
                                                           &present);
                            haveX2 = present;
                            if (!haveX2 && val_dhas (a, "noX"))
                              {
                                /* `D2(,B2)` names no index but still selects
                                   the indexed addressing mode:  the original
                                   build assembles `LH R2,d(,R2)` as 9AF6 000A,
                                   which is generateRS1 with b2=2, x2=0 and the
                                   0b100 bit set, and never as the two-byte
                                   short form. */
                                x2 = 0;
                                haveX2 = 1;
                              }
                            if (!err)
                              {
                                int droppedBase = 0;
                                int atStar;
                                int done = 0;
                                int forceRS = intmap_has (&argsRSonly, op);
                                int forceAM0 = (strchr (op, '$') != NULL);
                                int sectionOverflowAM0 = 0;
                                int forceAM1 = 0;
                                int isConstant = 0;
                                int specifiedB2;
                                int usingB2 = 0;
                                int sameSectionB2 = 0;
                                asmint opcode;
                                const char *section;
                                asmint offset;

                                /*
                                 * A register in parentheses is the BASE only if
                                 * it can be one.  If no USING is active for it
                                 * and the displacement is a RELOCATABLE symbol
                                 * -- which therefore already draws its base
                                 * from some other USING -- then the register is
                                 * an INDEX, and an indexed operand cannot take
                                 * the short form.  `b2 > 3` was a narrower
                                 * version of the same idea and missed
                                 * FPMEVENQ's `LH R2,TEQEVAR1(R1)`.
                                 */
                                if (haveB2 && b2 >= 0 && b2 < 8
                                    && val_is_none (val_get (using, (size_t) b2))
                                    && haveD2
                                    && unhash (d2, &section, &offset)
                                    && section != NULL
                                    && strchr (op, '$') == NULL)
                                  droppedBase = 1;
                                /*
                                 * `$` NAMES A BASE REGISTER, NOT AN INDEX.  It
                                 * selects the FORM, not the addressing:
                                 * ap101s-notes.py records it as long-form with
                                 * the addressing bits CLEAR and the second byte
                                 * 0xF0 | base.  So the reasoning above does not
                                 * apply:  under `$` the programmer is promising
                                 * the register holds the base.
                                 */
                                atStar = (strchr (op, '@') != NULL)
                                         || (strchr (op, '#') != NULL)
                                         || (haveB2 && b2 > 3) || droppedBase;
                                /*
                                 * ONLY IF SOMETHING ELSE SUPPLIES THE BASE.
                                 * The register can be read as an INDEX only
                                 * when a USING provides a base to replace it
                                 * with; otherwise it IS the base, and moving it
                                 * into x2 while leaving b2 alone puts the same
                                 * register in both fields.
                                 */
                                if (atStar && !haveX2)
                                  {
                                    asmint b, d;
                                    if (unUsing (using, d2, &b, &d))
                                      {
                                        x2 = b2;
                                        haveX2 = haveB2;
                                        b2 = b;
                                        haveB2 = 1;
                                        d2 = d;
                                      }
                                  }
                                if (strcmp (op, "BC") == 0
                                    || strcmp (op, "BCT") == 0)
                                  {
                                    /* From the STATEMENT's own position, not
                                       `currentHash()`, which is the section's
                                       running position and by here can be a
                                       halfword further on.  FIOPDHF falls from
                                       22 wrong bytes to 2 on this alone. */
                                    asmint d = ASM_SUB (
                                        d2,
                                        ASM_ADD (
                                            ASM_ADD (
                                                val_dget_int (properties, "pos1",
                                                              0)
                                                    / 2,
                                                val_dget_int (
                                                    val_dget (symtab, sect),
                                                    "value", 0)),
                                            1));
                                    if (d < 0 && d > -0x38)
                                      {
                                        char *m = py_concat (op, "B");
                                        dataLen = generateSRS (
                                            properties, m, r1, (-d) & 0x3F,
                                            strcmp (op, "BC") == 0 ? 0x2 : 0x3,
                                            data);
                                        done = 1;
                                      }
                                    else if (strcmp (op, "BC") == 0 && d >= 0
                                             && d < SRS_BRANCH_CEILING)
                                      {
                                        /* A FORWARD `BC` also has a short form,
                                           and only the backward one was written
                                           here.  FIOPDHF's `BC 07-4,#@LB3`
                                           jumps 48 halfwords forward and the
                                           original assembles it DBC0 while this
                                           emitted C3F7 0030. */
                                        dataLen = generateSRS (properties, "BCF",
                                                               r1, d & 0x3F, 0x0,
                                                               data);
                                        done = 1;
                                      }
                                  }
                                else if (intmap_has (&branchAliases, op)
                                         && (!haveX2 || x2 == 0) && !forceRS)
                                  {
                                    /*
                                     * NOT WHEN A REGISTER IS INDEXING IT:  the
                                     * short branch form has neither an index
                                     * field nor a base field -- its two bits are
                                     * the FORM selector -- so shortening simply
                                     * drops the register.  AND NOT WHEN THE
                                     * FORM IS FORCED:  `$` selects the long form
                                     * and sets `forceRS`, which every other
                                     * shortening path honours and this one did
                                     * not.
                                     *
                                     * THE CEILING HERE WAS A LITERAL 56 AND
                                     * NOTHING AGREED WITH IT.  `B PURGSAVF` in
                                     * GPCRTOPT arrives at a distance of 55,
                                     * which `optimizeScratch` had already
                                     * refused to shorten -- correctly, the
                                     * original writes the four-byte C7F7 0036 --
                                     * and 55 < 56 shortened it here regardless.
                                     */
                                    asmint d = ASM_SUB (
                                        d2,
                                        ASM_ADD (
                                            ASM_ADD (
                                                val_dget_int (properties, "pos1",
                                                              0)
                                                    / 2,
                                                val_dget_int (
                                                    val_dget (symtab, sect),
                                                    "value", 0)),
                                            1));
                                    if (d >= 0 && d < SRS_BRANCH_CEILING)
                                      {
                                        int isBvcf = intmap_has (
                                            &bvcfAliases, op);
                                        dataLen = generateSRS (
                                            properties, isBvcf ? "BVCF" : "BCF",
                                            r1, d & 0x3F, isBvcf ? 0x1 : 0x0,
                                            data);
                                        done = 1;
                                      }
                                    else if (d < 0 && d > -0x38
                                             && !intmap_has (
                                                 &bvcfAliases,
                                                 stripSuffixes (op)))
                                      {
                                        dataLen = generateSRS (properties, "BCB",
                                                               r1, (-d) & 0x3F,
                                                               0x2, data);
                                        done = 1;
                                      }
                                    else
                                      {
                                        /*
                                         * THERE IS NO BACKWARD SHORT FORM FOR
                                         * THE OVERFLOW/CARRY ALIASES.  `BNC`,
                                         * `BOV` and `BOC` test the
                                         * overflow/carry register and so take
                                         * form 01; a backward one would need 11,
                                         * which is BCTB.  Shortening it emitted
                                         * BCB -- the CONDITION-REGISTER branch
                                         * of the same mask -- so BILDNEW5's
                                         * `BNC STMMAIN1` assembled a correctly
                                         * formed backward branch ON THE WRONG
                                         * CONDITION.
                                         *
                                         * `BVC`, NOT `BC`, or the long form
                                         * loses the distinction too:
                                         * `rsMnemonic` gives BC's opcode C6 for
                                         * mask 6 and BVC's CE, and the
                                         * original's byte is CE.
                                         */
                                        op = intmap_has (&bvcfAliases,
                                                         stripSuffixes (op))
                                                 ? "BVC"
                                                 : "BC";
                                        forceRS = 1;
                                      }
                                  }
                                specifiedB2 = haveB2;
                                if (!done && !haveB2)
                                  {
                                    asmint newb2, newd2;
                                    int found = findB2D2 (d2, &newb2, &newd2);
                                    if (found <= 0)
                                      {
                                        if (found < 0)
                                          {
                                            newd2 = ASM_SUB (
                                                d2, val_dget_int (
                                                        val_dget (symtab, sect),
                                                        "value", 0));
                                            if (newd2 >= 0 && newd2 < 4096
                                                && newd2 < val_dget_int (
                                                       val_dget (sects, sect),
                                                       "used", 0)
                                                               / 2)
                                              {
                                                b2 = 3;
                                                haveB2 = 1;
                                                d2 = newd2;
                                                sameSectionB2 = 1;
                                              }
                                            else if (unhash (d2, &section,
                                                             &offset)
                                                     && section != NULL)
                                              {
                                                forceAM0 = 1;
                                                sectionOverflowAM0
                                                    = (strcmp (section, sect) == 0
                                                       && newd2 >= 4096);
                                              }
                                            else
                                              {
                                                ERROR (properties,
                                                       "Cannot determine "
                                                       "B2(D2)");
                                                done = 1;
                                              }
                                          }
                                        else
                                          {
                                            isConstant = 1;
                                            forceRS = 1;
                                          }
                                      }
                                    else
                                      {
                                        b2 = newb2;
                                        haveB2 = 1;
                                        d2 = newd2;
                                        usingB2 = 1;
                                      }
                                  }
                                if (haveB2 && (b2 < 0 || b2 > 3)
                                    && !intmap_has (&shiftOperations, op))
                                  {
                                    if (!haveX2 && b2 >= 4 && b2 <= 7)
                                      {
                                        x2 = b2;
                                        haveX2 = 1;
                                        haveB2 = 0;
                                      }
                                    else
                                      {
                                        asmError (properties, "B2 out of range",
                                                  compiling ? 255 : 0);
                                        done = 1;
                                      }
                                  }
                                opcode = intmap_get (&argsSRSorRS, op, 0);
                                /*
                                 * `forceAM0` is purely empirical.  BUT NOT WHEN
                                 * THE MNEMONIC CARRIES `@` OR `#`:  those two
                                 * bits live in the AM=1 form and nowhere else,
                                 * so forcing AM=0 asks for a form that cannot
                                 * express the instruction at all, and the AM=0
                                 * arm below then rejected the statement.
                                 */
                                forceAM0
                                    = forceAM0
                                      || ((opcode & 1) != 0
                                          && !(haveB2 && b2 == 3) && haveB2
                                          && !haveX2
                                          && strchr (op, '@') == NULL
                                          && strchr (op, '#') == NULL);
                                if (extrnD2)
                                  forceAM0 = 1;
                                forceAM1 = forceAM1 || haveX2;
                                if (!done)
                                  {
                                    asmint unhashedValue = ASM_AND (d2, 0xFFFFFF);
                                    asmint ic = val_dget_int (
                                                    val_dget (sects, sect),
                                                    "pos1", 0)
                                                / 2;
                                    asmint icSRS = ic + 1;
                                    asmint icRS = ic + 2;
                                    asmint dUnitizer;
                                    int isNumberD2 = 0;
                                    Val *rawD2;
                                    asmint dSRSa, dRSAM1, dSRS;
                                    int forbiddenSRS;
                                    asmint uUnhashedValue;
                                    asmint ia, i;
                                    asmint ib2;
                                    asmint d, d1;

                                    /* The conditional here is entirely
                                       empirical. */
                                    dUnitizer = ((opcode & 0x201) == 0) ? 2 : 1;
                                    if (val_dhas (a, "L2") && dUnitizer == 2
                                        && (!haveB2 || b2 == 3))
                                      {
                                        /* There is no way for us to know that a
                                           literal is an integral number of
                                           fullword addresses away from the
                                           current location. */
                                        forceRS = 1;
                                        forceAM0 = 1;
                                        forceAM1 = 0;
                                      }
                                    rawD2 = unroll (val_dget (a, "D2"));
                                    if (val_is_str (rawD2)
                                        && py_isdigit (val_cstr (rawD2)))
                                      isNumberD2 = 1;
                                    if (isNumberD2)
                                      {
                                        dSRSa = unhashedValue;
                                        dRSAM1 = unhashedValue;
                                      }
                                    else
                                      {
                                        dSRSa = ASM_SUB (unhashedValue, icSRS);
                                        dRSAM1 = ASM_SUB (unhashedValue, icRS);
                                      }
                                    dSRS = py_floordiv (dSRSa + dUnitizer - 1,
                                                       dUnitizer);
                                    forbiddenSRS = (py_mod (dSRSa, dUnitizer) != 0);
                                    uUnhashedValue = py_floordiv (
                                        dUnitizer - 1 + unhashedValue, dUnitizer);
                                    ia = (strchr (op, '@') != NULL) ? 1 : 0;
                                    i = (strchr (op, '#') != NULL) ? 1 : 0;
                                    ib2 = haveB2 ? b2 : 3;
                                    /*
                                     * `ib2 == 3` WAS DOING DOUBLE DUTY:  the
                                     * sentinel for "no base register", and the
                                     * legitimate base register B3.  A symbol
                                     * reached through `USING TFTQE,R3` therefore
                                     * took the section-relative path and got a
                                     * NEGATIVE displacement, which generateSRS
                                     * masked into six bits and turned into a
                                     * large positive one.
                                     */
                                    if (ib2 == 3 && !usingB2)
                                      {
                                        d = dSRS;
                                        d1 = dRSAM1;
                                      }
                                    else
                                      {
                                        d = uUnhashedValue;
                                        d1 = unhashedValue;
                                        /*
                                         * A BRANCH'S SHORT FORM IS PC-RELATIVE,
                                         * and by this point `d2` has been
                                         * replaced by the offset from the
                                         * USING's base -- so `uUnhashedValue` is
                                         * a distance to the wrong thing
                                         * entirely.  `originalD2` still holds
                                         * the address before the base register
                                         * was substituted.
                                         */
                                        if (usingB2
                                            && (intmap_has (&branchAliases, op)
                                                || isSrsBranchOperation (op)))
                                          {
                                            const char *brSect;
                                            asmint brAbs;
                                            if (unhash (originalD2, &brSect,
                                                        &brAbs))
                                              d = py_floordiv (ASM_SUB (brAbs,
                                                                       icSRS)
                                                                  + dUnitizer - 1,
                                                              dUnitizer);
                                          }
                                      }

                                    /*
                                     * `forceDisplacement` uses the displacement
                                     * (D2) directly in the encoded instruction,
                                     * rather than computing it relative to
                                     * something.  See issues #1324-#1326.
                                     */
                                    if (forceDisplacement
                                        && !intmap_has (&shiftOperations, op)
                                        && !extrnD2 && !forceAM1 && !forceRS
                                        && !haveX2 && haveR1
                                        && val_dhas (a, "B2") && haveB2 && b2 < 4
                                        && i == 0 && ia == 0
                                        && unhashedValue >= 0
                                        && (unhashedValue % dUnitizer) == 0
                                        && unhashedValue < 0x38 * dUnitizer)
                                      {
                                        /* For SRS-type instructions. */
                                        asmint ud2
                                            = ASM_AND (d2,
                                                       (asmint) 0xFFFFFFFF00000000ULL)
                                              | py_floordiv (
                                                  ASM_AND (d2, 0xFFFFFFFF),
                                                  dUnitizer);
                                        dataLen = generateSRS (properties, op, r1,
                                                               ud2, b2, data);
                                      }
                                    else if (forceDisplacement
                                             && !intmap_has (&shiftOperations, op)
                                             && !extrnD2 && !forceAM0 && !haveX2
                                             && haveR1 && val_dhas (a, "B2")
                                             && haveB2 && b2 < 4 && i == 0
                                             && ia == 0 && unhashedValue >= 0
                                             && unhashedValue < 0x10000)
                                      {
                                        /* For extended RS-type instructions. */
                                        dataLen = generateRS0 (properties, op, r1,
                                                               d2, b2, data);
                                        val_ddel (properties, "adr1");
                                      }
                                    else if (forceDisplacement
                                             && !intmap_has (&shiftOperations, op)
                                             && !extrnD2 && !forceAM0 && haveX2
                                             && haveR1 && val_dhas (a, "B2")
                                             && haveB2 && b2 < 4
                                             && unhashedValue >= 0
                                             && unhashedValue < 0x800)
                                      {
                                        /* For indexed RS-type instructions. */
                                        dataLen = generateRS1 (properties, op, ia,
                                                               i, r1, d2, x2, b2,
                                                               data);
                                        val_ddel (properties, "adr1");
                                      }
                                    else if (intmap_has (&shiftOperations, op))
                                      {
                                        asmint dd = haveB2 ? (56 + b2) : d2;
                                        dataLen = generateSRS (
                                            properties, op, r1, dd,
                                            intmap_get (&shiftOperations, op, 0),
                                            data);
                                        val_ddel (properties, "adr1");
                                        val_dset_int (properties, "adr2",
                                                      ASM_AND (d2, 0x3F));
                                      }
                                    /*
                                     * NOT WHEN A `USING` SUPPLIED THE BASE
                                     * REGISTER.  By this point `d2` has been
                                     * replaced by the offset from that register,
                                     * so a symbol reached through
                                     * `USING CDDLOCAL,R1` arrives here as a small
                                     * number and matches -- and this branch then
                                     * throws the register away.
                                     *
                                     * THE RANGE CHECK MUST BE ON THE
                                     * DISPLACEMENT, NOT ON THE ADDRESS.  Both
                                     * AM=1 forms encode the DISTANCE from the
                                     * instruction counter in eleven bits, but the
                                     * guard used to admit any `d2` under 2048 and
                                     * say nothing about how far away it was --
                                     * REALEXEC's `LA G4,MCHO` assembled a branch
                                     * to the wrong address, silently.
                                     */
                                    else if (strcmp (op, "LA") == 0 && !usingB2
                                             && !haveX2 && haveB2 && d2 > -2048
                                             && d2 < 2048
                                             && ((d2 >= 0 && d2 < SRS_CEILING
                                                  && dataLen == 2)
                                                 || (ASM_SUB (d2, icRS) > -2048
                                                     && ASM_SUB (d2, icRS)
                                                            < 2048)))
                                      {
                                        if (d2 >= 0 && d2 < SRS_CEILING
                                            && dataLen == 2)
                                          dataLen = generateSRS (properties, op,
                                                                 r1, d2, ib2,
                                                                 data);
                                        else if (d2 < icRS)
                                          {
                                            /* An RS AM=1 instruction with the I
                                               bit set, which subtracts d2 from
                                               the updated IC. */
                                            dataLen = generateRS1 (
                                                properties, op, 0, 1, r1,
                                                ASM_SUB (icRS, d2), 0, 3, data);
                                          }
                                        else
                                          dataLen = generateRS1 (
                                              properties, op, 0, 0, r1,
                                              ASM_SUB (d2, icRS), 0, 3, data);
                                      }
                                    /*
                                     * A FORWARD SHORT BRANCH CANNOT HOLD A
                                     * NEGATIVE DISPLACEMENT.  Only `BCB` and
                                     * `BCTB` take one; everything else arriving
                                     * here with d < 0 has no short form at all,
                                     * and `generateSRS` masked it into six bits.
                                     * DCICYC's `BC 6,#@LB259` is 65 halfwords
                                     * BACK and assembled DEFC, a forward branch
                                     * of 63 -- not a different-but-valid
                                     * encoding, a branch to the wrong address.
                                     */
                                    else if ((dataLen == 2
                                              && (d >= SRS_FLOOR
                                                  || (strcmp (op, "BC") != 0
                                                      && strcmp (op, "BCF") != 0
                                                      && strcmp (op, "BVC") != 0
                                                      && strcmp (op, "BVCF") != 0
                                                      && !intmap_has (
                                                          &branchAliases, op)))
                                              && d < ((intmap_has (&branchAliases,
                                                                   op)
                                                       || isSrsBranchOperation (op))
                                                          ? SRS_BRANCH_CEILING
                                                          : SRS_CEILING))
                                             || (!(ib2 == 3
                                                   && intmap_has (&fpOperationsSP,
                                                                  op))
                                                 && !forceRS && !haveX2
                                                 && (specifiedB2 || ib2 == 3)
                                                 && d >= SRS_FLOOR
                                                 && d < SRS_BRANCH_CEILING
                                                 && !forbiddenSRS
                                                 && intmap_has (&branchAliases,
                                                                op)))
                                      {
                                        /* Is SRS.
                                         *
                                         * NOT WHEN THE OPERAND IS A NUMBER.
                                         * `BCB` and `BCTB` hold the backward
                                         * distance as a MAGNITUDE, so a
                                         * displacement worked out from an
                                         * address has to be negated -- but a
                                         * literal operand IS that magnitude
                                         * already.  STM1's `BCB B'000',1` is
                                         * D806 in the original; negating the 1
                                         * gave 63 and assembled D8FE.
                                         */
                                        if ((strcmp (op, "BCB") == 0
                                             || strcmp (op, "BCTB") == 0)
                                            && !isNumberD2)
                                          d = ASM_NEG (d);
                                        if (strcmp (op, "BC") == 0
                                            || strcmp (op, "BCF") == 0)
                                          {
                                            op = "BCF";
                                            ib2 = 0x0;
                                          }
                                        else if (strcmp (op, "BVC") == 0)
                                          {
                                            op = "BVCF";
                                            ib2 = 0x1;
                                          }
                                        else if (strcmp (op, "BCB") == 0)
                                          ib2 = 0x2;
                                        else if (strcmp (op, "BCTB") == 0)
                                          ib2 = 0x3;
                                        if (d >= SRS_CEILING)
                                          asmError (properties,
                                                    "SRS displacement out of "
                                                    "range",
                                                    compiling ? 255 : 0);
                                        dataLen = generateSRS (properties, op, r1,
                                                               d, ib2, data);
                                      }
                                    else if (isConstant
                                             && literalAttributes == NULL)
                                      dataLen = generateRS0 (properties, op, r1,
                                                             ASM_AND (d2, 0xFFFF),
                                                             3, data);
                                    else if (isNumberD2 && haveB2 && !haveX2
                                             && !i && !ia)
                                      dataLen = generateRS0 (properties, op, r1,
                                                             ASM_AND (d2, 0xFFFF),
                                                             b2, data);
                                    else if (literalAttributes != NULL)
                                      {
                                        Val *pool
                                            = val_get (literalPools,
                                                       literalPoolNumber);
                                        ptrdiff_t idx
                                            = literalIndex (pool,
                                                            literalAttributes);
                                        d1 = ASM_SUB (
                                            ASM_ADD (
                                                val_as_int (val_get (pool, 1)),
                                                val_as_int (val_get (
                                                    val_get (pool, 3),
                                                    (size_t) idx)))
                                                / 2,
                                            icRS);
                                        dataLen = generateRS1 (properties, op, 0,
                                                               0, r1, d1, 0, 3,
                                                               data);
                                      }
                                    /*
                                     * `BCT` BELONGS IN THIS LIST and was missing,
                                     * so a backward BCT fell past here to the
                                     * AM=0 form and encoded its target as an
                                     * absolute section offset.
                                     *
                                     * `d1 <= 0` rather than `d1 < 0` because the
                                     * original build writes `*+2` -- a
                                     * displacement of exactly zero -- as the
                                     * negative form too.
                                     *
                                     * `OST`, `LPS` and `SSM` REACH BACKWARD THE
                                     * SAME WAY:  nothing about this encoding is
                                     * peculiar to branches.  ONLY FOR A LOCAL
                                     * TARGET, though -- an EXTRN is resolved by
                                     * the linker and keeps the absolute form.
                                     *
                                     * A SECTION-OVERFLOW `forceAM0` IS NOT A
                                     * REASON TO REFUSE THIS FORM:  it says only
                                     * that the offset will not fit AM=0's
                                     * twelve-bit field, not that the instruction
                                     * wants an absolute address.
                                     */
                                    else if ((strcmp (op, "BC") == 0
                                              || strcmp (op, "BIX") == 0
                                              || strcmp (op, "BAL") == 0
                                              || strcmp (op, "BCT") == 0
                                              || (!extrnBase
                                                  && (!forceAM0
                                                      || (sectionOverflowAM0
                                                          && ib2 == 3 && !usingB2
                                                          && !extrnD2))
                                                  && !ia && !i))
                                             && (!haveX2 || x2 == 0) && d1 > -2048
                                             && d1 <= 0)
                                      {
                                        if (extrnD2)
                                          {
                                            dataLen = generateRS0 (properties, op,
                                                                   r1, 0, 3, data);
                                            if (compiling)
                                              {
                                                Val *rel = val_dict ();
                                                val_dset_str (
                                                    rel, "symbol",
                                                    rextrnSymbol (originalD2));
                                                val_dset_str (rel, "section",
                                                              sect);
                                                val_dset_int (
                                                    rel, "address",
                                                    ASM_ADD (
                                                        val_dget_int (
                                                            val_dget (sects,
                                                                      sect),
                                                            "pos1", 0),
                                                        2));
                                                val_dset_str (rel, "type", "Y");
                                                val_append (relocations, rel);
                                              }
                                          }
                                        else
                                          {
                                            /* ELEVEN BITS, NOT TEN.
                                               `generateRS1` packs bits 10-8 into
                                               data[2] and 7-0 into data[3], so
                                               the mask is 0x7FF; 0x3FF silently
                                               dropped bit 10 of any magnitude of
                                               1024 or more. */
                                            dataLen = generateRS1 (
                                                properties, op, 0, 1, r1,
                                                0x7FF & ASM_NEG (d1), 0, ib2,
                                                data);
                                          }
                                      }
                                    else if ((!forceAM0
                                              || (sectionOverflowAM0
                                                  && strchr (op, '$') == NULL))
                                             && (haveX2 || ia || i
                                                 || (!usingB2 && d1 >= 0
                                                     && d1 < 2048)))
                                      {
                                        /* RS AM=1 here. */
                                        if (ib2 == 3)
                                          {
                                            if (d1 < 0)
                                              {
                                                d1 = ASM_NEG (d1);
                                                i = 1;
                                              }
                                          }
                                        if (!haveX2)
                                          {
                                            x2 = 0;
                                            haveX2 = 1;
                                          }
                                        if (x2 < 0 || x2 > 7)
                                          {
                                            asmError (properties,
                                                      "X2 out of range",
                                                      compiling ? 255 : 0);
                                            x2 = 0;
                                          }
                                        dataLen = generateRS1 (properties, op, ia,
                                                               i, r1, d1, x2, ib2,
                                                               data);
                                      }
                                    else if (!haveX2 && !ia && !i)
                                      {
                                        /* RS AM=0 here. */
                                        asmint d0 = 0;
                                        int haveD0 = 0;
                                        if (haveB2)
                                          {
                                            d0 = ASM_AND (d2, 0xFFFF);
                                            haveD0 = 1;
                                            /*
                                             * AN AM=0 DISPLACEMENT IS THE WHOLE
                                             * EFFECTIVE ADDRESS, so where it
                                             * names a location in this section it
                                             * has to be RELOCATED -- the
                                             * section's load address is not known
                                             * until the link.  `b2 == 3` reaches
                                             * here two ways and only one of them
                                             * wants this:  from a `USING`, where
                                             * the displacement is an offset from
                                             * a base register, or from the
                                             * fallback above, which means no
                                             * USING matched and the target is in
                                             * this section.
                                             *
                                             * A DSECT TARGET MUST NOT BE
                                             * RELOCATED:  `LH R3,TPSATENT` is
                                             * base 3 and AM=0 too, but TPSATENT
                                             * is a PSA location at absolute 8 --
                                             * an address the build knows and the
                                             * linker must leave alone.
                                             */
                                            if (compiling && b2 == 3 && !usingB2)
                                              {
                                                const char *rSect;
                                                asmint rOff;
                                                Val *rd;
                                                if (sameSectionB2)
                                                  {
                                                    rSect = sect;
                                                    rOff = d2;
                                                  }
                                                else if (!unhash (d2, &rSect,
                                                                  &rOff))
                                                  rSect = NULL;
                                                rd = rSect == NULL
                                                         ? NULL
                                                         : val_dget (sects, rSect);
                                                if (rd != NULL
                                                    && !val_dget_bool (rd, "dsect",
                                                                       0)
                                                    && val_dhas (rd, "offset"))
                                                  {
                                                    Val *rel = val_dict ();
                                                    d0 = ASM_SUB (
                                                        ASM_ADD (
                                                            rOff,
                                                            val_dget_int (
                                                                rd, "offset", 0)),
                                                        val_dget_int (
                                                            val_dget (sects, sect),
                                                            "offset", 0));
                                                    val_dset_str (rel, "symbol",
                                                                  rSect);
                                                    val_dset_str (rel, "section",
                                                                  sect);
                                                    val_dset_int (
                                                        rel, "address",
                                                        ASM_ADD (
                                                            val_dget_int (
                                                                val_dget (sects,
                                                                          sect),
                                                                "pos1", 0),
                                                            2));
                                                    val_dset_str (rel, "type",
                                                                  "Y");
                                                    val_append (relocations, rel);
                                                  }
                                              }
                                          }
                                        else if (rextrnHas (d2)
                                                 || rextrnHas (ASM_AND (
                                                     d2, HASHCODE_MASK)))
                                          {
                                            /* An EXTRN, with or without a
                                               displacement.  Only the bare symbol
                                               used to be recognised, because
                                               `rextrns` is keyed by the hashcode
                                               alone and `FP$COMSA+14` carries the
                                               14 in the low bits.  It was the
                                               broadest complaint in the corpus,
                                               across 44 modules. */
                                            const char *externalSymbol;
                                            if (rextrnHas (d2))
                                              {
                                                externalSymbol
                                                    = rextrnSymbol (d2);
                                                d0 = 0;
                                              }
                                            else
                                              {
                                                externalSymbol = rextrnSymbol (
                                                    ASM_AND (d2, HASHCODE_MASK));
                                                d0 = ASM_AND (d2, 0xFFFFFFFF);
                                              }
                                            haveD0 = 1;
                                            b2 = 3;
                                            haveB2 = 1;
                                            if (compiling)
                                              {
                                                Val *rel = val_dict ();
                                                val_dset_str (rel, "symbol",
                                                              externalSymbol);
                                                val_dset_str (rel, "section",
                                                              sect);
                                                val_dset_int (
                                                    rel, "address",
                                                    ASM_ADD (
                                                        val_dget_int (
                                                            val_dget (sects,
                                                                      sect),
                                                            "pos1", 0),
                                                        2));
                                                val_dset_str (rel, "type", "Y");
                                                val_append (relocations, rel);
                                              }
                                          }
                                        else
                                          {
                                            if (unhash (d2, &section, &offset)
                                                && section != NULL
                                                && val_dhas (sects, section)
                                                && val_dhas (
                                                    val_dget (sects, section),
                                                    "offset"))
                                              {
                                                const char *rldSymbol = section;
                                                size_t sn;
                                                Val *rel;
                                                d0 = ASM_SUB (
                                                    ASM_ADD (
                                                        offset,
                                                        val_dget_int (
                                                            val_dget (sects,
                                                                      section),
                                                            "offset", 0)),
                                                    val_dget_int (
                                                        val_dget (sects, sect),
                                                        "offset", 0));
                                                haveD0 = 1;
                                                b2 = 3;
                                                haveB2 = 1;
                                                if (compiling)
                                                  {
                                                    for (sn = 0;
                                                         sn < val_dlen (sects);
                                                         sn++)
                                                      {
                                                        Val *sd
                                                            = val_dval (sects, sn);
                                                        asmint so, su;
                                                        if (val_dget_bool (
                                                                sd, "dsect", 0)
                                                            || !val_dhas (sd,
                                                                          "offset"))
                                                          continue;
                                                        so = val_dget_int (
                                                            sd, "offset", 0);
                                                        su = val_dget_int (
                                                                 sd, "used", 0)
                                                             / 2;
                                                        if (d0 >= so
                                                            && d0 < so + su
                                                            && strcmp (
                                                                   val_dkey (sects,
                                                                             sn),
                                                                   sect)
                                                                   != 0)
                                                          {
                                                            rldSymbol = val_dkey (
                                                                sects, sn);
                                                            break;
                                                          }
                                                      }
                                                    rel = val_dict ();
                                                    val_dset_str (rel, "symbol",
                                                                  rldSymbol);
                                                    val_dset_str (rel, "section",
                                                                  sect);
                                                    val_dset_int (
                                                        rel, "address",
                                                        ASM_ADD (
                                                            val_dget_int (
                                                                val_dget (sects,
                                                                          sect),
                                                                "pos1", 0),
                                                            2));
                                                    val_dset_str (rel, "type",
                                                                  "Y");
                                                    val_append (relocations, rel);
                                                  }
                                              }
                                            if (!haveB2)
                                              {
                                                /* There is no base register from
                                                   which the operand's address can
                                                   be reached -- no USING covers
                                                   it.  The message used to say
                                                   only "Could not interpret
                                                   operand", which named neither
                                                   the instruction nor the address
                                                   and was the broadest complaint
                                                   in the corpus. */
                                                const char *whichSect;
                                                asmint whichOffset;
                                                char *shown;
                                                if (!unhash (d2, &whichSect,
                                                             &whichOffset))
                                                  whichSect = NULL;
                                                shown = py_substr (
                                                    py_strip (val_dget_str (
                                                        properties, "operand",
                                                        "")),
                                                    0, 32);
                                                asmError (
                                                    properties,
                                                    py_format (
                                                        "No USING covers the "
                                                        "operand of '%s %s' "
                                                        "(section %s, offset %s)",
                                                        op, shown,
                                                        whichSect == NULL
                                                            ? "None"
                                                            : whichSect,
                                                        whichSect == NULL
                                                            ? "None"
                                                            : py_format (
                                                                "%lld",
                                                                (long long)
                                                                    whichOffset)),
                                                    255);
                                                done = 1;
                                              }
                                          }
                                        if (!done)
                                          {
                                            (void) haveD0;
                                            dataLen = generateRS0 (properties, op,
                                                                   r1, d0, b2,
                                                                   data);
                                          }
                                        else
                                          continue;
                                      }
                                    else
                                      ERROR (properties,
                                             "Could not interpret line as SRS or "
                                             "RS");
                                  }
                              }
                          }
                      }
                  }
              }
              toMemory (val_bytes_from (data, (size_t) dataLen), 0, 1);
              continue;
            }

          if (intmap_has (&argsRI, operation))
            {
              Val *a;
              const char *op = operation;
              commonProcessing (2, 0);
              if (!compiling)
                {
                  toMemory (NULL, 4, 1);
                  continue;
                }
              memset (data, 0, 4);
              dataLen = 4;
              a = val_dget (properties, "ast");
              if (!val_is_none (a))
                {
                  asmint r2 = 0, i1 = 0;
                  int present = 0;
                  int err = evalInstructionSubfield (properties, "R2", a, symtab,
                                                     &r2, &present);
                  if (!err && present && r2 >= 0 && r2 <= 7)
                    {
                      err = evalInstructionSubfield (properties, "I1", a, symtab,
                                                     &i1, &present);
                      if (!err)
                        {
                          asmint opcode;
                          if (present)
                            val_dset_int (properties, "adr2",
                                          ASM_AND (i1, 0xFFFF));
                          if (strcmp (op, "SHI") == 0)
                            {
                              i1 = ASM_NEG (i1);
                              op = "AHI";
                            }
                          if (strcmp (op, "LHI") == 0)
                            {
                              /*
                               * LHI is not actually an RI instruction, though
                               * it is RI syntactically:  it is an alias for LA,
                               * an RS instruction, with special field values.
                               *
                               * AND BEING AN `LA`, IT REACHES A RELOCATABLE
                               * OPERAND THROUGH A `USING` LIKE ANY OTHER MEMORY
                               * REFERENCE.  The base field was the literal
                               * 0b11110011 -- AM=0, B2=3, the "no base
                               * register" sentinel -- so the operand's own
                               * value went into the displacement whatever it
                               * was.  That is right for a constant, which is
                               * what `LHI` almost always takes:  901 of the
                               * corpus's 902 cards.  The exception is
                               * BILDNEW5's `LHI R5,DISABLFL`, where the
                               * original writes EDF1 00A6 and we wrote
                               * EDF3 1580.
                               */
                              const char *section;
                              asmint offset;
                              asmint b2 = 0, d = 0;
                              int haveBase = 0;
                              opcode = intmap_get (&argsSRSorRS, "LA", 0);
                              data[0]
                                  = (unsigned char) (((opcode & 0x3E0) >> 2) | r2);
                              if (unhash (i1, &section, &offset)
                                  && section != NULL)
                                haveBase = unUsing (using, i1, &b2, &d);
                              if (haveBase && b2 >= 0 && b2 <= 3 && d < 0x10000)
                                {
                                  data[1] = (unsigned char) (0xF0 | b2);
                                  i1 = d;
                                }
                              else
                                data[1] = 0xF3; /* AM=0, B2=11 */
                            }
                          else
                            {
                              opcode = intmap_get (&argsRI, op, 0);
                              data[0] = (unsigned char) ((opcode & 0x1FE0) >> 5);
                              data[1]
                                  = (unsigned char) (((opcode & 0x1F) << 3) | r2);
                            }
                          i1 = ASM_AND (i1, 0xFFFF);
                          data[2] = (unsigned char) (i1 >> 8);
                          data[3] = (unsigned char) (i1 & 0xFF);
                        }
                    }
                }
              toMemory (val_bytes_from (data, (size_t) dataLen), 0, 1);
              continue;
            }

          if (intmap_has (&argsSI, operation))
            {
              Val *a;
              commonProcessing (2, 0);
              if (!compiling)
                {
                  toMemory (NULL, 4, 1);
                  continue;
                }
              memset (data, 0, 4);
              dataLen = 4;
              a = val_dget (properties, "ast");
              if (!val_is_none (a))
                {
                  asmint d2 = 0, b2 = 0, i1 = 0;
                  int present = 0, haveB2 = 0, haveD2 = 0;
                  int err = evalInstructionSubfield (properties, "D2", a, symtab,
                                                     &d2, &present);
                  haveD2 = present;
                  if (!err)
                    {
                      if (haveD2)
                        val_dset_int (properties, "adr1", ASM_AND (d2, 0xFFFF));
                      err = evalInstructionSubfield (properties, "B2", a, symtab,
                                                     &b2, &present);
                      haveB2 = present;
                      if (!err)
                        {
                          if (!haveB2)
                            haveB2 = unUsing (using, d2, &b2, &d2);
                          if (haveB2 && b2 >= 0 && b2 <= 3)
                            {
                              err = evalInstructionSubfield (properties, "I1", a,
                                                             symtab, &i1,
                                                             &present);
                              /* Alone among the subfield evaluations here, this
                                 one used to ignore `err` and go straight to the
                                 mask, which raises when I1 could not be
                                 evaluated or was simply absent. */
                              if (err || !present)
                                ERROR (properties,
                                       "Could not evaluate I1 subfield");
                              else
                                {
                                  asmint opcode;
                                  i1 = ASM_AND (i1, 0xFFFF);
                                  val_dset_int (properties, "adr2", i1);
                                  d2 = ASM_AND (d2, 0x3F);
                                  opcode = intmap_get (&argsSI, operation, 0);
                                  data[0] = (unsigned char) opcode;
                                  data[1] = (unsigned char) ((d2 << 2) | b2);
                                  data[2] = (unsigned char) (i1 >> 8);
                                  data[3] = (unsigned char) (i1 & 0xFF);
                                }
                            }
                          else
                            ERROR (properties, "Cannot identify base register");
                        }
                    }
                }
              toMemory (val_bytes_from (data, (size_t) dataLen), 0, 1);
              continue;
            }

          if (cnopmap_get (&cnopFills, operation) != NULL)
            {
              /*
               * CNOP aligns the location counter and FILLS the gap with no-ops,
               * which is what distinguishes it from the silent alignment
               * `commonProcessing` performs for DC and DS.
               *
               * The operand is a number of HALFWORDS within a fullword, and the
               * target is simply its parity:  `CNOP 2` aligns to an even
               * halfword address, which is a fullword boundary.  That is IBM's
               * `CNOP b,w` with w fixed at a fullword and b counted in
               * halfwords, 2 standing where 0 would.
               *
               * The three spellings are three processors and they fill with
               * their own no-ops:  CNOP is the CPU's and fills with D800, and
               * @CNOP is the MSC's and fills with C000, both read off the
               * original build.
               */
              const CnopEntry *fill = cnopmap_get (&cnopFills, operation);
              Val *a;
              asmint halfwords = 0;
              int present = 0;
              asmint target;
              commonProcessing (1, 0);
              a = val_dget (properties, "ast");
              if (val_is_none (a))
                {
                  asmError (properties,
                            py_format ("%s requires an operand", operation), 255);
                  continue;
                }
              if (evalInstructionSubfield (properties, "v", a, symtab, &halfwords,
                                           &present)
                  || !present)
                {
                  asmError (properties,
                            py_format ("Could not evaluate %s operand", operation),
                            compiling ? 255 : 0);
                  continue;
                }
              target = py_mod (halfwords, 2);
              /*
               * AN ALREADY-ALIGNED CNOP NEEDS NO FILL, and so needs no known
               * fill instruction.  The diagnostic below used to be raised on
               * sight of the directive, rejecting a whole module over an
               * alignment that was already satisfied -- FIODDUPG's `#CNOP 2`
               * sits at 00018 and the statement after it is at 00018 too.
               */
              while (py_mod (val_dget_int (val_dget (sects, sect), "pos1", 0) / 2,
                             2)
                     != target)
                {
                  unsigned char pad[2];
                  if (!fill->known)
                    {
                      asmError (properties,
                                py_format ("%s needs to fill a gap here, and its "
                                           "fill instruction is unknown -- no "
                                           "instance needing one has been seen "
                                           "in the original build",
                                           operation),
                                255);
                      break;
                    }
                  pad[0] = fill->b0;
                  pad[1] = fill->b1;
                  toMemory (val_bytes_from (pad, 2), 0, 1);
                }
              continue;
            }

          if (intmap_has (&mscMemory, operation)
              || pairmap_get (&mscBranch, operation) != NULL
              || intmap_has (&mscImmediate, operation)
              || intmap_has (&mscImmediate11, operation)
              || intmap_has (&mscOpx, operation)
              || strcmp (operation, "@BC") == 0
              || strcmp (operation, "@BXC") == 0)
            {
              /* The two-byte MSC instructions, in the three formats derived and
                 checked against the original build.  See `mscMemory`,
                 `mscBranch` and `mscImmediate` in model101tables.py for where
                 each opcode comes from and how far it is verified. */
              Val *a;
              asmint value = 0;
              commonProcessing (2, 0);
              a = val_dget (properties, "ast");
              memset (data, 0, 2);
              dataLen = 2;
              if (val_is_none (a))
                {
                  asmError (properties,
                            py_format ("%s requires an operand", operation), 255);
                  toMemory (val_bytes_from (data, 2), 0, 1);
                  continue;
                }

              if (intmap_has (&mscOpx, operation))
                {
                  /* @STP, whose operand is the OPX field in the second nibble
                     rather than an immediate value. */
                  if (!mscField (properties, "A1", a, &value))
                    {
                      asmError (properties,
                                py_format ("Could not evaluate %s operand",
                                           operation),
                                compiling ? 255 : 0);
                      toMemory (val_bytes_from (data, 2), 0, 1);
                      continue;
                    }
                  if (!(value >= 0 && value <= 7))
                    asmError (properties,
                              py_format ("%s operand %lld is not an OPX value; "
                                         "OPX is three bits and the POO names 0 "
                                         "through 3",
                                         operation, (long long) value),
                              compiling ? 255 : 0);
                  data[0] = (unsigned char) ((intmap_get (&mscOpx, operation, 0)
                                              << 4)
                                             | (value & 0x0F));
                  data[1] = 0;
                  toMemory (val_bytes_from (data, 2), 0, 1);
                  continue;
                }

              if (intmap_has (&mscImmediate, operation)
                  || intmap_has (&mscImmediate11, operation))
                {
                  int isEleven = intmap_has (&mscImmediate11, operation);
                  if (!mscField (properties, "A1", a, &value))
                    {
                      asmError (properties,
                                py_format ("Could not evaluate %s operand",
                                           operation),
                                compiling ? 255 : 0);
                      toMemory (val_bytes_from (data, 2), 0, 1);
                      continue;
                    }
                  if (isEleven)
                    {
                      if (!(value >= 0 && value <= 0x7FF))
                        asmError (properties,
                                  py_format ("%s operand %lld does not fit in "
                                             "the 11-bit immediate field",
                                             operation, (long long) value),
                                  compiling ? 255 : 0);
                    }
                  else if (!(value >= -128 && value <= 255))
                    asmError (properties,
                              py_format ("%s operand %lld does not fit in the "
                                         "8-bit immediate field",
                                         operation, (long long) value),
                              compiling ? 255 : 0);
                  if (value != 0
                      && intmap_has (&mscImmediateZeroOnly, operation))
                    asmError (properties,
                              py_format ("%s is written with a non-zero operand, "
                                         "%lld.  It appears only ever with zero "
                                         "in the original build, so where its "
                                         "opcode ends and its operand begins is "
                                         "not established and the object code "
                                         "here may be WRONG",
                                         operation, (long long) value),
                              255);
                  if (isEleven)
                    {
                      /* An eleven-bit operand:  opcode nibble, index flag, then
                         the value across both bytes. */
                      data[0] = (unsigned char) ((intmap_get (&mscImmediate11,
                                                              operation, 0)
                                                  << 4)
                                                 | ((value >> 8) & 0x07));
                    }
                  else
                    data[0]
                        = (unsigned char) intmap_get (&mscImmediate, operation, 0);
                  if (val_dhas (a, "X1"))
                    {
                      if (intmap_has (&mscImmediateIndexable, operation))
                        data[0] |= 0x08;
                      else
                        asmError (properties,
                                  py_format ("%s is written with an index, which "
                                             "does not appear in the original "
                                             "build for this instruction; the "
                                             "index bit is not encoded and the "
                                             "object code here is WRONG",
                                             operation),
                                  255);
                    }
                  data[1] = (unsigned char) (value & 0xFF);
                  toMemory (val_bytes_from (data, 2), 0, 1);
                  continue;
                }

              /* What is left is PC-relative, so it needs the address of the
                 halfword AFTER this instruction.  `pos1` is a byte offset and
                 `commonProcessing` has not yet advanced it past these two
                 bytes, hence the +2. */
              {
                asmint target;
                asmint updatedPC;
                asmint displacement;
                asmint indexed;
                asmint word;
                if (!mscField (properties, "A1", a, &target))
                  {
                    asmError (properties,
                              py_format ("Could not evaluate %s operand",
                                         operation),
                              compiling ? 255 : 0);
                    toMemory (val_bytes_from (data, 2), 0, 1);
                    continue;
                  }
                updatedPC = ASM_ADD (ASM_ADD (val_dget_int (val_dget (sects, sect),
                                                            "pos1", 0),
                                              val_dget_int (val_dget (sects, sect),
                                                            "offset", 0)),
                                     2)
                            / 2;
                displacement = ASM_SUB (target, updatedPC);
                indexed = val_dhas (a, "X1") ? 1 : 0;

                if (intmap_has (&mscMemory, operation))
                  {
                    if (!(displacement >= -1024 && displacement <= 1023))
                      asmError (properties,
                                py_format ("%s is %lld halfwords away, out of "
                                           "range of the 11-bit PC-relative "
                                           "displacement",
                                           operation, (long long) displacement),
                                compiling ? 255 : 0);
                    word = (intmap_get (&mscMemory, operation, 0) << 12)
                           | (indexed << 11) | ASM_AND (displacement, 0x7FF);
                  }
                else
                  {
                    asmint condition = 0;
                    if (strcmp (operation, "@BC") == 0
                        || strcmp (operation, "@BXC") == 0)
                      {
                        /* @BC and @BXC state the condition as their first
                           operand rather than in the mnemonic, the branch
                           target being the second.  @BXC is the index-register
                           form, which is what M distinguishes. */
                        indexed = (strcmp (operation, "@BXC") == 0) ? 1 : 0;
                        if (!mscField (properties, "CC", a, &condition)
                            || !(condition >= 0 && condition <= 7))
                          {
                            asmError (properties,
                                      py_format ("%s requires a condition code "
                                                 "of 0 to 7 as its first operand",
                                                 operation),
                                      255);
                            toMemory (val_bytes_from (data, 2), 0, 1);
                            continue;
                          }
                      }
                    else
                      {
                        const PairEntry *e = pairmap_get (&mscBranch, operation);
                        indexed = e->a;
                        condition = e->b;
                      }
                    if (!(displacement >= -128 && displacement <= 127))
                      asmError (properties,
                                py_format ("%s is %lld halfwords away, out of "
                                           "range of the 8-bit PC-relative "
                                           "displacement",
                                           operation, (long long) displacement),
                                compiling ? 255 : 0);
                    word = ((0x20 | (indexed << 3) | condition) << 8)
                           | ASM_AND (displacement, 0xFF);
                  }
                data[0] = (unsigned char) ((word >> 8) & 0xFF);
                data[1] = (unsigned char) (word & 0xFF);
                toMemory (val_bytes_from (data, 2), 0, 1);
                continue;
              }
            }

          if (msclong_get (&mscLong, operation) != NULL)
            {
              /* The four-byte MSC instructions.  The POO gives the layout on
                 the @BU and @CALL pages:
                   OP(4)=1111  I(1)  SUBOP(3)  FIELD(5)  M(1)  ADDRESS(18) */
              const MscLongEntry *e = msclong_get (&mscLong, operation);
              Val *a;
              Val *mscRelocSymbol = val_dict ();
              asmint field;
              asmint address;
              asmint word;
              commonProcessing (2, 0);
              a = val_dget (properties, "ast");
              memset (data, 0, 4);
              dataLen = 4;
              if (val_is_none (a))
                {
                  asmError (properties,
                            py_format ("%s requires an operand", operation), 255);
                  toMemory (val_bytes_from (data, 4), 0, 1);
                  continue;
                }
              field = e->field;
              if (e->fieldFromOperand)
                {
                  /* The delta of @CALL, or the BCE number of @LBB and @LBP,
                     which is written as the first of the two operands. */
                  if (!val_dhas (a, "CC"))
                    {
                      asmError (properties,
                                py_format ("%s requires two operands", operation),
                                255);
                      toMemory (val_bytes_from (data, 4), 0, 1);
                      continue;
                    }
                  if (!mscLongField (properties, "CC", a, mscRelocSymbol, &field))
                    {
                      asmError (properties,
                                py_format ("Could not evaluate the first operand "
                                           "of %s",
                                           operation),
                                255);
                      toMemory (val_bytes_from (data, 4), 0, 1);
                      continue;
                    }
                  if (!(field >= 0 && field <= 31))
                    asmError (properties,
                              py_format ("The first operand of %s is %lld, "
                                         "outside the 5-bit field it is placed in",
                                         operation, (long long) field),
                              compiling ? 255 : 0);
                }
              if (!mscLongField (properties, "A1", a, mscRelocSymbol, &address))
                {
                  /* Quiet on the collecting passes.  FIOHISAM writes
                     `DATALOAD @LH DATA(1)` at card 171 and `DATA EQU 0` at card
                     255, an ordinary forward reference that pass 3 resolves. */
                  if (compiling)
                    asmError (properties,
                              py_format ("Could not evaluate the address operand "
                                         "of %s",
                                         operation),
                              255);
                  toMemory (val_bytes_from (data, 4), 0, 1);
                  continue;
                }
              if (!(address >= -0x20000 && address <= 0x3FFFF))
                asmError (properties,
                          py_format ("The address operand of %s is %lld, outside "
                                     "the 18-bit address field",
                                     operation, (long long) address),
                          compiling ? 255 : 0);
              word = ((asmint) 0xF << 28)
                     | ((val_dhas (a, "X1") ? (asmint) 1 : (asmint) 0) << 27)
                     | (e->subop << 24) | ((field & 0x1F) << 19)
                     | (e->mbit << 18) | ASM_AND (address, 0x3FFFF);
              data[0] = (unsigned char) ((word >> 24) & 0xFF);
              data[1] = (unsigned char) ((word >> 16) & 0xFF);
              data[2] = (unsigned char) ((word >> 8) & 0xFF);
              data[3] = (unsigned char) (word & 0xFF);
              /* An ACON over the whole word:  the address field is 18 bits, the
                 format has no relocation that narrow, and a relocation adds
                 rather than replaces, so the opcode and the M bit in the top
                 half survive. */
              if (compiling && val_dhas (mscRelocSymbol, "A1"))
                {
                  Val *rel = val_dict ();
                  val_dset_str (rel, "symbol",
                                val_dget_str (mscRelocSymbol, "A1", ""));
                  val_dset_str (rel, "section", sect);
                  val_dset_int (rel, "address",
                                val_dget_int (val_dget (sects, sect), "pos1", 0));
                  val_dset_str (rel, "type", "A");
                  val_append (relocations, rel);
                }
              toMemory (val_bytes_from (data, 4), 0, 1);
              continue;
            }

          if (intmap_has (&argsMSC, operation))
            {
              /* The MSC instructions the survey of the original build did NOT
                 settle:  the long forms F0 to FD, the four whose high byte
                 varies and so carries a modifier, and those seen only ever with
                 a zero operand.  These say so rather than emit a guess:  four
                 zero bytes are obviously wrong; a plausible but wrong halfword
                 is not, and that is the worse failure. */
              commonProcessing (2, 0);
              asmError (properties,
                        py_format ("%s is an MSC instruction whose encoding has "
                                   "not been established; four zero bytes are "
                                   "generated in its place and the object code "
                                   "is WRONG",
                                   operation),
                        255);
              toMemory (val_bytes (4), 0, 1);
              continue;
            }

          if (bcelong_get (&bceLong, operation) != NULL)
            {
              /* The four-byte BCE instructions.  See `bceLong` in
                 model101tables.py for where the opcodes and the three operand
                 layouts come from; they were derived from the original build
                 rather than from the POO, which names the operands but not the
                 bit layout. */
              const BceLongEntry *e = bcelong_get (&bceLong, operation);
              Val *a;
              Val *bceRelocSymbol = val_dict ();
              Val *bceNegative = val_dict ();
              asmint first = 0, second = 0;
              commonProcessing (2, 0);
              a = val_dget (properties, "ast");
              memset (data, 0, 4);
              dataLen = 4;
              data[0] = (unsigned char) e->opcode;
              if (val_is_none (a))
                {
                  asmError (properties,
                            py_format ("%s requires an operand", operation), 255);
                  toMemory (val_bytes_from (data, 4), 0, 1);
                  continue;
                }
              if (!bceField (properties, "A1", a, bceRelocSymbol, bceNegative,
                             &first))
                {
                  asmError (properties,
                            py_format ("Could not evaluate %s operand", operation),
                            compiling ? 255 : 0);
                  toMemory (val_bytes_from (data, 4), 0, 1);
                  continue;
                }
              if (val_dhas (a, "X1"))
                {
                  /* An index used to be captured under the same name as the
                     second operand, so this silently became a displacement.
                     Where the long format puts the index bit is not known. */
                  asmError (properties,
                            py_format ("%s is written with an index, whose bit "
                                       "position in the long BCE format is not "
                                       "established; it is not encoded and the "
                                       "object code here is WRONG",
                                       operation),
                            255);
                }
              if (val_dhas (a, "A2"))
                {
                  if (!bceField (properties, "A2", a, bceRelocSymbol, bceNegative,
                                 &second))
                    {
                      asmError (properties,
                                py_format ("Could not evaluate second operand of "
                                           "%s",
                                           operation),
                                255);
                      second = 0;
                    }
                }
              else
                second = 0;

              if (e->layout == BCE_ADDRESS)
                {
                  /* THE SAME BORROW as the Y constant above.  `#LBR@ FIOBRE-2`
                     with FIOBRE an EXTRN evaluates to `hash - 2`, whose low 24
                     bits are FFFFFE; FIOMDPPG assembled FAFF FFFE where the
                     original has FA00 0002.  The POO gives this field as an
                     18-bit unsigned address, in which a negative constant cannot
                     be represented at all, and the original writes the
                     magnitude. */
                  const char *bs;
                  asmint bm;
                  asmint field;
                  if (unhashBorrowed (first, 0, &bs, &bm))
                    first = bm;
                  field = ASM_AND (first, 0xFFFFFF);
                  data[1] = (unsigned char) ((field >> 16) & 0xFF);
                  data[2] = (unsigned char) ((field >> 8) & 0xFF);
                  data[3] = (unsigned char) (field & 0xFF);
                  /*
                   * AN ACON OVER THE WHOLE WORD, not a YCON over the low
                   * halfword.  The address field is 24 bits here and the format
                   * has no 3-byte relocation, so a YCON at +2 cannot carry a
                   * target at or above 0x10000 -- FCMSFCAM proves that matters:
                   * DASS_SSW has F001 CB4C for its `@BU FIOMNTR`, address
                   * 0x1CB4C, whose high byte lands in data[1].
                   *
                   * An ACON at +0 works because a relocation ADDS:  lnk101
                   * computes `existing + target` and masks to the length, so
                   * with the opcode in the top byte the sum keeps the opcode and
                   * fills in the low 24 bits.
                   */
                  if (compiling && val_dhas (bceRelocSymbol, "A1"))
                    {
                      Val *rel = val_dict ();
                      val_dset_str (rel, "symbol",
                                    val_dget_str (bceRelocSymbol, "A1", ""));
                      val_dset_str (rel, "section", sect);
                      val_dset_int (rel, "address",
                                    val_dget_int (val_dget (sects, sect), "pos1",
                                                  0));
                      val_dset_bool (rel, "negative",
                                     val_dhas (bceNegative, "A1"));
                      val_dset_str (rel, "type", "A");
                      val_append (relocations, rel);
                    }
                }
              else if (e->layout == BCE_IUACOMMAND)
                {
                  /*
                   * A 5-BIT IUA over a 19-BIT COMMAND, not a byte over a
                   * halfword.  This was wrong for years and could not have been
                   * caught by the corpus, whose operands here are EXTRN symbols
                   * that assemble to zero either way.  The one source line that
                   * settles it says so in its own comment:  `#CMDI 15,0
                   * CMD WORD=X'00780000'`, and 0x780000 is 15 shifted by 19.
                   */
                  asmint field;
                  if (!(first >= 0 && first <= 31))
                    asmError (properties,
                              py_format ("The IUA of %s is %lld, outside its "
                                         "5-bit field",
                                         operation, (long long) first),
                              compiling ? 255 : 0);
                  field = ((first & 0x1F) << 19) | ASM_AND (second, 0x7FFFF);
                  data[1] = (unsigned char) ((field >> 16) & 0xFF);
                  data[2] = (unsigned char) ((field >> 8) & 0xFF);
                  data[3] = (unsigned char) (field & 0xFF);
                }
              else
                {
                  /* DISPCOUNT and PARAMETER share a shape:  one byte then one
                     halfword.  For PARAMETER the opcode byte is 00 and the
                     operands are an IUA and a command, the word being data that
                     follows a #MIN or #MOUT rather than an instruction. */
                  data[1] = (unsigned char) (first & 0xFF);
                  data[2] = (unsigned char) ((second >> 8) & 0xFF);
                  data[3] = (unsigned char) (second & 0xFF);
                }
              toMemory (val_bytes_from (data, 4), 0, 1);
              continue;
            }

          if (bceshort1_get (&bceShort1, operation) != NULL
              || intmap_has (&bceShort2, operation))
            {
              /* The two-byte BCE instructions.  The POO gives both short
                 formats:
                   short format 1   OP(4) M(1) DISP(11)
                   short format 2   OP(3) TC(5) DISP(8) */
              Val *a;
              asmint first = 0;
              asmint word;
              commonProcessing (2, 0);
              a = val_dget (properties, "ast");
              memset (data, 0, 2);
              dataLen = 2;
              if (val_is_none (a))
                {
                  asmError (properties,
                            py_format ("%s requires an operand", operation), 255);
                  toMemory (val_bytes_from (data, 2), 0, 1);
                  continue;
                }
              if (!mscField (properties, "A1", a, &first))
                {
                  asmError (properties,
                            py_format ("Could not evaluate %s operand", operation),
                            compiling ? 255 : 0);
                  toMemory (val_bytes_from (data, 2), 0, 1);
                  continue;
                }
              if (intmap_has (&bceShort2, operation))
                {
                  /* `TC,DISP`:  a 5-bit transfer count over an 8-bit
                     displacement off the BCE's base register. */
                  asmint count = first;
                  asmint displacement = 0;
                  if (val_dhas (a, "A2"))
                    {
                      if (!mscField (properties, "A2", a, &displacement))
                        {
                          asmError (properties,
                                    py_format ("Could not evaluate the "
                                               "displacement of %s",
                                               operation),
                                    255);
                          displacement = 0;
                        }
                    }
                  if (!(count >= 0 && count <= 31))
                    asmError (properties,
                              py_format ("The transfer count of %s is %lld, "
                                         "outside the 5-bit field it is placed in",
                                         operation, (long long) count),
                              compiling ? 255 : 0);
                  if (!(displacement >= -128 && displacement <= 255))
                    asmError (properties,
                              py_format ("The displacement of %s is %lld, outside "
                                         "its 8-bit field",
                                         operation, (long long) displacement),
                              compiling ? 255 : 0);
                  word = (intmap_get (&bceShort2, operation, 0) << 13)
                         | ((count & 0x1F) << 8) | ASM_AND (displacement, 0xFF);
                }
              else
                {
                  const BceShort1Entry *e = bceshort1_get (&bceShort1, operation);
                  asmint mbit = e->mbitIsIndex ? (val_dhas (a, "X1") ? 1 : 0)
                                               : e->mbit;
                  asmint displacement = first;
                  if (e->kind == BCE_RELATIVE)
                    {
                      /* PC-relative from the updated BCE program counter, which
                         is the halfword after this instruction. */
                      displacement = ASM_SUB (
                          displacement,
                          ASM_ADD (ASM_ADD (val_dget_int (val_dget (sects, sect),
                                                          "pos1", 0),
                                            val_dget_int (val_dget (sects, sect),
                                                          "offset", 0)),
                                   2)
                              / 2);
                      if (!(displacement >= -1024 && displacement <= 1023))
                        asmError (properties,
                                  py_format ("%s is %lld halfwords away, out of "
                                             "range of the 11-bit displacement",
                                             operation, (long long) displacement),
                                  compiling ? 255 : 0);
                    }
                  else if (!(displacement >= -1024 && displacement <= 2047))
                    asmError (properties,
                              py_format ("The operand of %s is %lld, outside the "
                                         "11-bit field it is placed in",
                                         operation, (long long) displacement),
                              compiling ? 255 : 0);
                  word = (e->opcode << 12) | (mbit << 11)
                         | ASM_AND (displacement, 0x7FF);
                }
              data[0] = (unsigned char) ((word >> 8) & 0xFF);
              data[1] = (unsigned char) (word & 0xFF);
              toMemory (val_bytes_from (data, 2), 0, 1);
              continue;
            }

          if (intmap_has (&argsBCE, operation))
            {
              /* The two-byte BCE instructions that are NOT encoded:  their
                 opcode/operand boundary could not be read off the original
                 build, most of their observed operands being zero.  Say so
                 rather than emit a guess, since wrong object code that
                 assembles quietly is worse than none. */
              commonProcessing (2, 0);
              asmError (properties,
                        py_format ("%s is a BCE instruction whose encoding has "
                                   "not been established; four zero bytes are "
                                   "generated in its place and the object code "
                                   "is WRONG",
                                   operation),
                        255);
              toMemory (val_bytes (4), 0, 1);
              continue;
            }

          /* Name the operation.  This is the catch-all at the end of the
             instruction dispatch, and it accounted for 16720 diagnostics across
             166 of OI340600's 225 modules -- by far the commonest thing the
             assembler says -- while giving no clue whatever as to what it had
             failed to recognise. */
          asmError (properties,
                    py_format ("Unrecognized operation '%s'", operation), 255);
          continue;
        }

      if (collect && !asis)
        {
          size_t pi, si;
          /* Close out the final literal pool. */
          endOfSource ();
          /* Rearrange the literals in each pool by alignment, and work out
             their offsets into the pool. */
          for (pi = 0; pi < val_len (literalPools); pi++)
            {
              Val *pool = val_get (literalPools, pi);
              asmint offset = 0;
              asmint alignment;
              size_t i;
              Val *offsets;
              if (val_len (pool) == emptyPoolLength)
                continue;
              /* A LITERAL POOL BEGINS ON A FULLWORD BOUNDARY whatever it holds.
                 Seeded at 2, a pool whose widest member is a halfword was
                 aligned to a halfword and started two bytes early wherever the
                 section happened to end odd:  FPMWAIT's pool holds one `=H'1'`
                 and the original build puts it at 00056 where we put it at
                 00055. */
              val_set (pool, 2, val_int (4));
              offsets = val_seq (V_LIST);
              for (i = 0; i < val_len (pool); i++)
                val_append (offsets, V_None);
              val_set (pool, 3, offsets);
              val_set (pool, 4, val_int (0));
              for (alignment = 8; alignment >= 1; alignment /= 2)
                {
                  for (i = emptyPoolLength; i < val_len (pool); i++)
                    {
                      asmint rem;
                      asmint L;
                      if (!val_is_none (val_get (offsets, i)))
                        continue;
                      L = val_dget_int (val_get (pool, i), "L", 0);
                      if ((L % alignment) != 0)
                        continue;
                      if (alignment > val_as_int (val_get (pool, 2)))
                        val_set (pool, 2, val_int (alignment));
                      rem = offset % alignment;
                      if (rem != 0)
                        offset += alignment - rem;
                      val_set (offsets, i, val_int (offset));
                      offset += L;
                      if (offset > val_as_int (val_get (pool, 4)))
                        val_set (pool, 4, val_int (offset));
                    }
                }
              {
                const char *pname = val_cstr (val_get (pool, 0));
                asmint used = val_dget_int (val_dget (sects, pname), "used", 0);
                asmint align = val_as_int (val_get (pool, 2));
                asmint rem = used % align;
                if (rem != 0)
                  used += align - rem;
                val_set (pool, 1, val_int (used));
              }
            }
          /*
           * Eliminate the ambiguity between SRS and RS instructions, TO A FIXED
           * POINT.  This was `for sect in sects: optimizeScratch()`, and the
           * function takes no argument and never reads `sect`, so the number of
           * times it ran was the number of control sections the module happened
           * to have.  Each run gives instructions left ambiguous by the last one
           * another chance against shorter addresses, so the count is not
           * cosmetic:  running it ONCE was tried and is worse, taking DMOD and
           * DSNCS out of byte-exactness.
           */
          {
            int pass;
            for (pass = 0; pass < 20; pass++)
              if (optimizeScratch () == 0)
                break;
          }
          /*
           * The optimization may have shrunk CSECTs, which may require moving
           * LTORGs downward in memory, and it leaves no direct record of the new
           * sizes.  Recompute them by walking the whole source.
           */
          for (si = 0; si < val_dlen (sects); si++)
            {
              val_dset_int (val_dval (sects, si), "used", 0);
              val_dset_int (val_dval (sects, si), "pos1", 0);
            }
          for (pi = 0; pi < val_len (source); pi++)
            {
              /* ###FIXME### This does not account for the possibility of `ORG`
                 pseudo-ops. */
              Val *p = val_get (source, pi);
              const char *sn = val_dget_str (p, "section", NULL);
              Val *sd;
              asmint alignment, pos1, rem;
              if (sn == NULL || !val_dhas (sects, sn)
                  || !val_dhas (p, "alignment") || !val_dhas (p, "length")
                  || val_is_none (val_dget (p, "length")))
                continue;
              sd = val_dget (sects, sn);
              alignment = val_dget_int (p, "alignment", 1);
              if (alignment <= 0)
                continue;
              pos1 = val_dget_int (sd, "pos1", 0);
              rem = pos1 % alignment;
              if (rem != 0)
                pos1 += alignment - rem;
              pos1 += val_dget_int (p, "length", 0);
              val_dset_int (sd, "pos1", pos1);
              if (pos1 > val_dget_int (sd, "used", 0))
                val_dset_int (sd, "used", pos1);
            }
          for (pi = 0; pi < val_len (literalPools); pi++)
            {
              Val *pool = val_get (literalPools, pi);
              const char *pname;
              asmint usage, offset, alignment;
              if (val_len (pool) == emptyPoolLength)
                continue;
              pname = val_cstr (val_get (pool, 0));
              if (!val_dhas (sects, pname))
                continue;
              usage = val_dget_int (val_dget (sects, pname), "used", 0);
              offset = val_as_int (val_get (pool, 1));
              alignment = val_as_int (val_get (pool, 2));
              if (alignment < 2)
                alignment = 2;
              else if (alignment > 4)
                alignment = 4;
              while (offset - alignment >= usage)
                offset -= alignment;
              val_set (pool, 1, val_int (offset));
            }
        }
      if (asis || compiling)
        {
          /*
           * ON EVERY COMPILE PASS, not on pass 2 alone.  Pass 2 lays the module
           * out with the lengths pass 1's optimizer settled on, and those are
           * not final -- a compile pass can still find that an instruction needs
           * its long form.  Freezing the inter-section offsets at pass 2 froze
           * them against a layout later passes then revised, which cost
           * BILDNEW5 9225 of its 10174 mismatched bytes.
           *
           * A CHANGED OFFSET ASKS FOR ANOTHER PASS, for exactly the reason a
           * moved label does.
           */
          Val *previousOffsets = val_dict ();
          asmint lastOffset = 0;
          int previousWasZcon = 0;
          size_t si;
          for (si = 0; si < val_dlen (sects); si++)
            val_dset (previousOffsets, val_dkey (sects, si),
                      val_dget (val_dval (sects, si), "offset") == NULL
                          ? V_None
                          : val_dget (val_dval (sects, si), "offset"));
          /*
           * For reasons not fully understood the assembler treats at least some
           * control sections as contiguous.  For now all CSECTs are treated that
           * way, with realignment in between; each CSECT (but not DSECT) gets an
           * `offset` field giving its offset in halfwords from the first CSECT.
           *
           * THE RULE, from 132 inter-CSECT boundaries in the corpus:
           *   ordinary section after ordinary   127 cases, FULLWORD
           *   first ZCON section after one        1 case,  DOUBLEWORD
           *   ZCON section after a ZCON section   1 case,  PACKED, no padding
           *
           * THIS IS PROBABLY THE RIGHT BYTES FOR THE WRONG REASON, and it is
           * recorded that way deliberately.  The linked memory map shows what is
           * actually going on:  a checksummed section is followed by a checksum
           * word and the ZCONs then pack tight behind it, which accounts for
           * both of FIOCGR's boundaries with one mechanism and explains why the
           * other 127 show plain fullword rounding.  What nothing here explains
           * is how the ASSEMBLER knew to reserve the word, since the gap is in
           * the listing before any linking.  Until that is understood this
           * reproduces the layout by asserting an alignment rule instead, fitted
           * to n=1 in each ZCON case.  If a second module with ZCON sections
           * turns up, or the reservation mechanism is found, replace this rather
           * than extend it.
           */
          for (si = 0; si < val_dlen (sects); si++)
            {
              const char *sn = val_dkey (sects, si);
              Val *sd = val_dval (sects, si);
              int thisIsZcon;
              asmint offset;
              size_t pi;
              if (val_dget_bool (sd, "dsect", 0))
                continue;
              {
                /* A SECTION OF ZCONS AND NOTHING ELSE. */
                Val *scratch = val_dget (sd, "scratch");
                size_t i;
                int any = 0;
                thisIsZcon = 1;
                for (i = 0; i < val_len (scratch); i++)
                  {
                    Val *e = val_get (scratch, i);
                    const char *o;
                    if (!val_truthy (val_dget (e, "length")))
                      continue;
                    any = 1;
                    if (strcmp (val_dget_str (e, "operation", ""), "DC") != 0)
                      {
                        thisIsZcon = 0;
                        break;
                      }
                    o = py_lstrip (val_dget_str (e, "operand", ""));
                    if (!py_startswith (o, "Z("))
                      {
                        thisIsZcon = 0;
                        break;
                      }
                  }
                if (!any)
                  thisIsZcon = 0;
              }
              if (thisIsZcon && previousWasZcon)
                {
                  /* packed */
                }
              else if (thisIsZcon)
                lastOffset = (lastOffset + 3) & (asmint) 0xFFFFFC; /* doubleword */
              else
                lastOffset = (lastOffset + 1) & (asmint) 0xFFFFFE; /* fullword */
              val_dset_int (sd, "offset", lastOffset);
              /* WHERE THE SECTION ENDS IS THE LATER OF ITS HIGH-WATER MARK AND
                 ITS POOLS, not the pool alone.  Taking the pool's end outright
                 is right only when the pool is the last thing in the section;
                 where statements FOLLOW the LTORG they sit beyond it and every
                 later CSECT was laid down on top of them. */
              offset = val_dget_int (sd, "used", 0);
              for (pi = 0; pi < val_len (literalPools); pi++)
                {
                  Val *pool = val_get (literalPools, pi);
                  if (val_len (pool) == emptyPoolLength)
                    continue;
                  if (val_eq_str (val_get (pool, 0), sn)
                      && !val_is_none (val_get (pool, 1))
                      && ASM_ADD (val_as_int (val_get (pool, 1)),
                                  val_as_int (val_get (pool, 4)))
                             > offset)
                    offset = ASM_ADD (val_as_int (val_get (pool, 1)),
                                      val_as_int (val_get (pool, 4)));
                }
              lastOffset += offset / 2;
              previousWasZcon = thisIsZcon;
            }
          if (compiling)
            {
              for (si = 0; si < val_dlen (sects); si++)
                {
                  Val *before = val_dget (previousOffsets, val_dkey (sects, si));
                  Val *after = val_dget (val_dval (sects, si), "offset");
                  if (!val_eq (before == NULL ? V_None : before,
                               after == NULL ? V_None : after))
                    {
                      repeatPass = 1;
                      break;
                    }
                }
            }
        }
    }

  /*-----------------------------------------------------------------------
   * Append the literal pools to their CSECTs.
   */
  {
    size_t pi;
    for (pi = 0; pi < val_len (literalPools); pi++)
      {
        Val *pool = val_get (literalPools, pi);
        const char *pname;
        Val *assembled;
        asmint desiredLength;
        size_t i;
        if (val_len (pool) == emptyPoolLength)
          continue;
        pname = val_cstr (val_get (pool, 0));
        if (!val_dhas (sects, pname))
          continue;
        assembled = val_dget (val_dget (sects, pname), "memory");
        desiredLength = ASM_ADD (val_as_int (val_get (pool, 1)),
                                 val_as_int (val_get (pool, 4)));
        if ((asmint) val_len (assembled) < desiredLength)
          val_bytes_grow (assembled, (size_t) desiredLength, fillPattern, 2);
        for (i = emptyPoolLength; i < val_len (pool); i++)
          {
            asmint offset = ASM_ADD (val_as_int (val_get (pool, 1)),
                                     val_as_int (val_get (val_get (pool, 3), i)));
            Val *lassembled = val_dget (val_get (pool, i), "assembled");
            size_t j;
            const char *zsymbol;
            for (j = 0; j < val_len (lassembled); j++)
              val_bytes_set (assembled, (size_t) offset + j,
                             val_bytes_get (lassembled, j));
            /*
             * A ZCON in the pool needs the same relocation a `DC Z(...)` gets,
             * AND THE SAME FLAG BYTE, WHICH IT WAS NOT GETTING.  Omitting
             * rldFlags leaves objectWriter's fallback of 0x04 -- the CODE kind
             * -- and lnk101 then patches BSR from the target's sector where the
             * DATA kind 0x50 would have patched DSR.
             *
             * 0x50 IS NOT A CHOICE HERE:  a literal ZCON is parsed as `(,A1,A2)`
             * and that is the only shape the literal grammar admits, so it is
             * always the data form.
             */
            zsymbol = val_dget_str (val_get (pool, i), "zsymbol", NULL);
            if (zsymbol != NULL)
              {
                Val *rel = val_dict ();
                val_dset_str (rel, "symbol", zsymbol);
                val_dset_str (rel, "section", pname);
                val_dset_int (rel, "address", offset);
                val_dset_int (rel, "flags",
                              ASM_AND (val_dget_int (val_get (pool, i), "value",
                                                     0)
                                           >> 8,
                                       0xFF));
                val_dset_int (rel, "rldFlags", 0x50);
                val_dset_str (rel, "type", "Z");
                val_append (relocations, rel);
              }
            /*
             * AND SO DOES A Y LITERAL, for exactly the same reason.  Its value
             * is resolved the way `DC Y(...)` resolves its operand, but no RLD
             * accompanied it, so `=Y(FPMXQELE)` sat in the pool as 0000 where
             * DASS_SSW has 8B86.  The symbol is found the same three ways the DC
             * path finds it.
             */
            if (val_eq_str (val_dget (val_get (pool, i), "T"), "Y"))
              {
                asmint yvalue = val_dget_int (val_get (pool, i), "value", 0);
                const char *ysymbol = NULL;
                if (rextrnHas (yvalue))
                  ysymbol = rextrnSymbol (yvalue);
                else if (rextrnHas (ASM_AND (yvalue, HASHCODE_MASK)))
                  ysymbol = rextrnSymbol (ASM_AND (yvalue, HASHCODE_MASK));
                else
                  {
                    const char *ySect;
                    asmint yOff;
                    if (unhash (yvalue, &ySect, &yOff) && ySect != NULL
                        && val_dhas (sects, ySect)
                        && !val_dget_bool (val_dget (sects, ySect), "dsect", 0)
                        && val_dhas (val_dget (sects, ySect), "offset"))
                      ysymbol = ySect;
                  }
                if (ysymbol != NULL)
                  {
                    Val *rel = val_dict ();
                    val_dset_str (rel, "symbol", ysymbol);
                    val_dset_str (rel, "section", pname);
                    val_dset_int (rel, "address", offset);
                    val_dset_str (rel, "type", "Y");
                    val_append (relocations, rel);
                  }
              }
          }
        /*
         * THE POOL EXTENDS ITS SECTION, IT DOES NOT DEFINE ITS END.  This was a
         * plain assignment, which is right for a pool that is the last thing in
         * its section and TRUNCATES the section for one that is not -- and the
         * section's length is what the ESD card reports and what the TXT card is
         * sliced to, so both the length and the CONTENT after the LTORG were
         * lost.
         *
         * FIXING IT HERE AND NOT IN THE LTORG ARM IS THE POINT:  that arm
         * deliberately advances `pos1` past the pool and leaves `used` alone,
         * and forcing `used` there makes a TRAILING pool count twice.
         */
        if (desiredLength > val_dget_int (val_dget (sects, pname), "used", 0))
          val_dset_int (val_dget (sects, pname), "used", desiredLength);
      }
  }

  return metadata;
}
