/* inlines=19
 * This is a C-language "patch" for CALL INLINEs #0-18 in xcom4.xpl, as compiled
 * by XCOM-I.py.
 *
 * The patch spans the entirety of the `SCAN_FINDS` procedure embedded in
 * the `SCAN` procedure.  This comprises every `CALL INLINE` statement in
 * the entire xcom4 program.
 *
 * What the procedure does is this:  It's given the address of a "translation
 * table" of one of the following types:
 *      `BLANKTABLE`  (Blanks)
 *      `ALPHATABLE`  (Identifier)
 *      `STRINGTABLE` (Quoted string)
 *      `COMMENTABLE` (Comment)
 * Starting at position `CP=0` (already set up upon entry so that we know the
 * first character is of the asked-for type) in the string `TEXT`, searches
 * for the end of the pattern of the selected type, and updates `CP` to the
 * length of the found string.  It returns 0 on failure and 1 on success.  An
 * empty string counts as a failure.
 *
 * This was apparently coded in BAL because the IBM 360 has a translation-table
 * instruction, TRT, that does this efficiently.  But from my perspective,
 * considering that there's no other embedded BAL code in the entire program,
 * it seems as though it's a big price to pay, maintenance-wise and
 * portability-wise, for a pretty small gain in efficiency.  Yes, you can
 * always make assembly-language go faster than a high-level language; this is
 * news?
 */

// Note the use of the `RETURN()` macro in place of `return`.  This is to
// account for the possible use of XCOM-I's --reentry-guard switch.

static memoryMapEntry_t *mapCP = NULL, *mapTEXT = NULL, *mapTABLE,
      *mapBLANKTABLE, *mapALPHATABLE, *mapSTRINGTABLE, *mapCOMMENTABLE;
char *s, *TEXT;
uint32_t TABLE;
int returnValue = 0;

if (mapCP == NULL)
  {
    mapCP = lookupVariable("CP");
    mapTEXT = lookupVariable("TEXT");
    mapTABLE = lookupVariable("SCANxSCAN_FINDS_END_OFxTABLE");
    mapBLANKTABLE = lookupVariable("BLANKTABLE");
    mapALPHATABLE = lookupVariable("ALPHATABLE");
    mapSTRINGTABLE = lookupVariable("STRINGTABLE");
    mapCOMMENTABLE = lookupVariable("COMMENTABLE");
  }

TEXT = descriptorToAscii(getCHARACTER(mapTEXT->address));

if (*TEXT != 0)
  {

    TABLE = getFIXED(mapTABLE->address);
    if (TABLE == mapBLANKTABLE->address)
      {
        for (s = TEXT; *s == ' ' || *s == '\t'; s++);
      }
    else if (TABLE == mapALPHATABLE->address)
      {
        for (s = TEXT;
             isalnum(*s) || *s == '_' || *s == '@' || *s == '#' || *s == '$';
             s++);
      }
    else if (TABLE == mapSTRINGTABLE->address)
      {
        for (s = TEXT; *s && *s != '\''; s++);

      }
    else if (TABLE == mapCOMMENTABLE->address)
      {
        for (s = TEXT; *s && *s != '*' && *s != '$'; s++);
      }
    else
      abend("Requested translation table for SCAN_FINDS_END_OF not found");
    if (*s == 0)
      {
        putFIXED(mapCP->address, s + 1 - TEXT);
        RETURN(fixedToBit(1, 0));
      }
    putFIXED(mapCP->address, s - TEXT);
    returnValue = 1;

  }

descriptor_t *d = fixedToBit(1,returnValue);
RETURN(d);
