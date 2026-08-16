/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   tablesupport.c
 * Purpose:    Lookups over the instruction tables, and the low-level
 *             machine-code generators.
 * Contact:    info@sandroid.org
 */

#include "tables.h"
#include "val.h"

/*---------------------------------------------------------------------------
 * Lookups.  The mnemonic tables are consulted several times per statement per
 * pass, so `IntMap` builds an index the first time it is asked; the smaller
 * ones are scanned, which is cheaper than an index for a dozen entries.
 */
static uint32_t
keyHash (const char *s)
{
  uint32_t h = 2166136261u;
  while (*s != '\0')
    {
      h ^= (unsigned char) *s++;
      h *= 16777619u;
    }
  return h;
}

static void
intmap_build (IntMap *m)
{
  size_t size = 16;
  size_t i;
  while (size < m->n * 3)
    size *= 2;
  m->index = (int32_t *) arena_alloc (ARENA_MAIN, size * sizeof (int32_t));
  m->mask = size - 1;
  for (i = 0; i < size; i++)
    m->index[i] = -1;
  for (i = 0; i < m->n; i++)
    {
      size_t slot = keyHash (m->entries[i].key) & m->mask;
      while (m->index[slot] != -1)
        slot = (slot + 1) & m->mask;
      m->index[slot] = (int32_t) i;
    }
}

static const IntEntry *
intmap_find (IntMap *m, const char *key)
{
  size_t slot;
  if (key == NULL)
    return NULL;
  if (m->index == NULL)
    intmap_build (m);
  slot = keyHash (key) & m->mask;
  for (;;)
    {
      int32_t e = m->index[slot];
      if (e == -1)
        return NULL;
      if (strcmp (m->entries[e].key, key) == 0)
        return &m->entries[e];
      slot = (slot + 1) & m->mask;
    }
}

int
intmap_has (IntMap *m, const char *key)
{
  return intmap_find (m, key) != NULL;
}

asmint
intmap_get (IntMap *m, const char *key, asmint dflt)
{
  const IntEntry *e = intmap_find (m, key);
  return e != NULL ? e->value : dflt;
}

const char *
strmap_get (const StrMap *m, const char *key)
{
  size_t i;
  if (key == NULL)
    return NULL;
  for (i = 0; i < m->n; i++)
    if (strcmp (m->entries[i].key, key) == 0)
      return m->entries[i].value;
  return NULL;
}

const PairEntry *
pairmap_get (const PairMap *m, const char *key)
{
  size_t i;
  if (key == NULL)
    return NULL;
  for (i = 0; i < m->n; i++)
    if (strcmp (m->entries[i].key, key) == 0)
      return &m->entries[i];
  return NULL;
}

const CnopEntry *
cnopmap_get (const CnopMap *m, const char *key)
{
  size_t i;
  if (key == NULL)
    return NULL;
  for (i = 0; i < m->n; i++)
    if (strcmp (m->entries[i].key, key) == 0)
      return &m->entries[i];
  return NULL;
}

const MscLongEntry *
msclong_get (const MscLongMap *m, const char *key)
{
  size_t i;
  if (key == NULL)
    return NULL;
  for (i = 0; i < m->n; i++)
    if (strcmp (m->entries[i].key, key) == 0)
      return &m->entries[i];
  return NULL;
}

const BceShort1Entry *
bceshort1_get (const BceShort1Map *m, const char *key)
{
  size_t i;
  if (key == NULL)
    return NULL;
  for (i = 0; i < m->n; i++)
    if (strcmp (m->entries[i].key, key) == 0)
      return &m->entries[i];
  return NULL;
}

const BceLongEntry *
bcelong_get (const BceLongMap *m, const char *key)
{
  size_t i;
  if (key == NULL)
    return NULL;
  for (i = 0; i < m->n; i++)
    if (strcmp (m->entries[i].key, key) == 0)
      return &m->entries[i];
  return NULL;
}

const char *
stripSuffixes (const char *mnemonic)
{
  size_t n = strlen (mnemonic);
  while (n > 0
         && (mnemonic[n - 1] == '$' || mnemonic[n - 1] == '@'
             || mnemonic[n - 1] == '#'))
    n--;
  return arena_strndup (ARENA_MAIN, mnemonic, n);
}

/*---------------------------------------------------------------------------
 * Machine-code generators
 *
 * A BRANCH ALIAS HAS NO OPCODE OF ITS OWN IN THE LONG FORMS.  `B`, `BL`, `BE`
 * and the rest all carry 0b1100000000, which is the SRS form's opcode; the RS
 * forms need the low bits that only `BC` -- and `BVC`, for the aliases that
 * test the overflow/carry register -- supplies.  The condition mask already
 * rides in R1, so the long form is simply a `BC` with that mask.
 *
 * FCMTRACE's `BL$ FCMWRAP(R3)` assembled C207 against the original's C2F3:
 * right register, right mask, opcode short by its low five bits.
 */
const char *
rsMnemonic (const char *mnemonic)
{
  if (intmap_has (&branchAliases, mnemonic))
    return intmap_has (&bvcfAliases, stripSuffixes (mnemonic)) ? "BVC" : "BC";
  return mnemonic;
}

/* `properties["adr2"]` records the displacement the listing prints in its
   second address column, where it differs from the first. */
static void
setAdr2 (Val *properties, asmint d2)
{
  val_dset_int (properties, "adr2", d2);
}

int
generateSRS (Val *properties, const char *mnemonic, asmint r1, asmint d2,
             asmint b2, unsigned char *data)
{
  asmint opcode = intmap_get (&argsSRSorRS, mnemonic, 0);
  data[0] = (unsigned char) (((opcode & 0x3E0) >> 2) | r1);
  data[1] = (unsigned char) (0xFF & (((asmuint) d2 << 2) | (asmuint) b2));
  if (val_dhas (properties, "adr1")
      && val_dget_int (properties, "adr1", 0) != d2
      && (b2 == 3
          || intmap_has (&branchAliases,
                         val_dget_str (properties, "operation", ""))))
    setAdr2 (properties, d2);
  return 2;
}

int
generateRS0 (Val *properties, const char *mnemonic, asmint r1, asmint d2,
             asmint b2, unsigned char *data)
{
  asmint opcode = intmap_get (&argsSRSorRS, rsMnemonic (mnemonic), 0);
  data[0] = (unsigned char) (((opcode & 0x3E0) >> 2) | r1);
  data[1] = (unsigned char) (((opcode & 0x1F) << 3) | b2);
  data[2] = (unsigned char) ((d2 & 0xFF00) >> 8);
  data[3] = (unsigned char) (d2 & 0xFF);
  if (val_dhas (properties, "adr1")
      && val_dget_int (properties, "adr1", 0) != d2)
    setAdr2 (properties, d2);
  return 4;
}

int
generateRS1 (Val *properties, const char *mnemonic, asmint ia, asmint i,
             asmint r1, asmint d2, asmint x2, asmint b2, unsigned char *data)
{
  asmint opcode = intmap_get (&argsSRSorRS, rsMnemonic (mnemonic), 0);
  data[0] = (unsigned char) (((opcode & 0x3E0) >> 2) | r1);
  data[1] = (unsigned char) (((opcode & 0x1F) << 3) | 0x4 | b2);
  data[2] = (unsigned char) (((asmuint) x2 << 5) | ((asmuint) ia << 4)
                             | ((asmuint) i << 3) | ((d2 & 0x700) >> 8));
  data[3] = (unsigned char) (d2 & 0xFF);
  if (val_dhas (properties, "adr1")
      && val_dget_int (properties, "adr1", 0) != d2)
    setAdr2 (properties, d2);
  return 4;
}
