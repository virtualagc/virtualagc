#!/usr/bin/env python
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   halsParms.py
Purpose:    The default HAL/S compiler options, in one place.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2026-08-05 ACC  Factored out of compilePASS, which had the most
                            developed version, and adopted by compileLinkRun
                            and compileLinkCompare.

compilePASS, compileLinkRun and compileLinkCompare each grew their own copy of
this, and the copies drifted: the CARDTYPE table stayed identical in all three,
but they disagreed about how to look a file up in it, about which conditional
pairs to append, and about the option list.  Since the table is the part that
records hard-won findings about individual source files, drift there is the
expensive kind, so it lives here now and the three scripts import it.

Import it as

    from halsParms import getParms, getCardtype, getCardtypeMap

which works because Python puts the directory of the running script at the
front of sys.path, and these four files sit together.
'''

# CARDTYPE is a string of PAIRS, each saying "a card of type J behaves like one
# of type K" (PASS1.PROCS/INITIALI.xpl:526-538).  The pairs below vary per
# source file and belong to PASS itself; the conditional pairs further down are
# constant and belong to Virtual AGC.
#
# R=C is necessary but not sufficient for PGSCRU and PGPPLD, which fail after
# it with DQ8 rather than DQ7 -- "STRUCTURE ... CANNOT BE UNQUALIFIED".  Those
# two are a different defect and not a CARDTYPE matter at all.  PGSCRU's own
# report settles it: STRUCTURE CSAS_PDT_PAR_ENTRY appears exactly once in it,
# from its own "D INCLUDE STRPDT" at statement 28, so the CPG_PCD template it
# includes at statement 6 did not carry STRPDT's structures.  Our SDF for
# CPGPCD does carry them, and the collision follows.  The SDF include path
# (HALINCL/INCSDF.xpl) exports or imports more than the template path does --
# compiling the same unit with --no-sdfi gives PM2 instead, so the two paths
# genuinely disagree.  That is the thing to fix; R=C only moves the symptom.
cardtypesBySourceFile = {
    "default": "FCRM",
    "CS2INI" : "ACFCRM",
    "CS4INI" : "ACFCRM",
    "CPTOSV" : "ACBDFCRM",
    "CPUSLS" : "ACBDFCRM",
    "CSAPDT" : "FCRC",
    "CS2PDT" : "FCRC",
    "CS4PDT" : "FCRC",
    "PGSCRU" : "FCRC",
    # GKFHOR's five T cards were the whole of its M1 "ILLEGAL CARD TYPE"
    # failure; S, its only other unusual column 1, is a standard type.  Both
    # readings parse and compile, since the T lines wrap an IF/ELSE around a
    # block that balances either way, so the OI301700 report decides it: SRNs
    # 009228, 009240, 009260 and 009352 all appear there marked M with
    # statement numbers 349, 350, 351 and 360.  (009229 is absent only because
    # OI301700 fits the IF condition on one line where OI340600 splits it.)
    "GKFHOR" : "TMFCRM",
    "GKDASC" : "AMOCNCRMFDGCHC",
    "GKRORB" : "ACOMNCRCFCGDHC",
    "GKGMNV" : "ACOCNMRMFCGCHD",
    "CV5SLCOM": "DC"
    }

# U through Z in column 1 mark Virtual AGC's own conditionally-compiled lines,
# and these pairs are appended to every CARDTYPE.  U/X are used in OI340600 and
# V/W in OI301700; Y and Z occur in neither corpus but are reserved, and are
# kept because compileLinkRun and compileLinkCompare carried them.  A pair for
# an unused type costs nothing, so this superset suits all three callers.
#
# The corresponding string for the ORIGINAL compiler is "UCXDVCWMYMZC": each
# pair reversed, so that a W line is live there and commented here, which is
# how a correction can be applied for HALSFC while the original compiler goes
# on seeing the uncorrected code.  See the DR121254 fixes in OI301700.
CONDITIONAL_PAIRS = "UDXCVMWCYCZM"
CONDITIONAL_PAIRS_ORIGINAL = "UCXDVCWMYMZC"

# The option list compilePASS uses, and now the default for all three.
#
#   LITSTRINGS is raised from its default of 2000 for OI301700/APPLSRC/
#   CGBIH2.hal, which uses 2646.
#   NOLFXI because there are no LFXI instructions in HAL/S code, though there
#   are some in the MAFGEN memory dumps.
DEFAULT_OPTIONS = ["SREF", "LIST", "LISTING2", "SRN", "TEMPLATE", "NOLFXI",
                   "REGOPT", "LITSTRINGS=3000"]

def getCardtype(stem, original=False):
    '''The CARDTYPE value for one source file, named by its stem.

    A leading underscore is stripped, so that a preprocessed _NAME.hal or a
    seeding stub _stubNAME.hal gets the same treatment as NAME.hal.
    '''
    if stem.startswith("_"):
        stem = stem[1:]
    if stem.startswith("stub"):         # _stubNAME.hal, from cycle seeding
        stem = stem[4:]
    pairs = CONDITIONAL_PAIRS_ORIGINAL if original else CONDITIONAL_PAIRS
    return cardtypesBySourceFile.get(stem, cardtypesBySourceFile["default"]) \
           + pairs

def getCardtypeMap(stem):
    '''The same pairs as a column-1 substitution, so a caller can classify a
    card the way the compiler will rather than the way it looks.

    Needed because a "D INCLUDE TEMPLATE" is not always written on a literal D
    card: CPTOSV line 40 begins with B, and CPTOSV's BD pair makes it a
    directive.  Missing those includes hid CS4PDT from the dependency graph
    entirely, so it was never compiled and CPTOSV then failed with XI3 for want
    of its template.

    PASS1 installs a pair only where the type on its left does not already have
    a meaning: INITIALI.xpl:526-538 sets E, M, S, C, D and blank first, then
    guards the substitution with IF CARD_TYPE(J) = 0.  A pair naming one of
    those on the left is therefore inert in the compiler, and applying it here
    anyway made this scan disagree with the compilation it is meant to predict.
    CV5SLCOM's "DC" turned its own "D INCLUDE TEMPLATE CPSSLD NOLIST" into a
    comment, so CPSSLD was never recorded as a dependency; it was compiled 159
    files after CV5SLCOM, which failed XI3 for want of its template.  The same
    guard also makes the first pair for a given type win, rather than the last.
    '''
    cardtype = getCardtype(stem)
    map = {}
    for i in range(0, len(cardtype) - 1, 2):
        if cardtype[i] in "EMSCD " or cardtype[i] in map:
            continue
        map[cardtype[i]] = cardtype[i + 1]
    return map

def getParms(stem, extraParms="", options=None, adding=None, original=False):
    '''The full --parms string for one source file.

    stem        the source file's stem, e.g. "GKFHOR" for GKFHOR.hal.
    extraParms  prepended verbatim; this is where a --extra-parms switch goes,
                and it must already end in a comma if it is not empty.
    options     replaces DEFAULT_OPTIONS outright.  Prefer `adding`.
    adding      appended to DEFAULT_OPTIONS, for an option one caller needs and
                the others do not -- compileLinkRun's VARSYM.
    original    use the pairs for the original compiler rather than HALSFC.
    '''
    opts = list(DEFAULT_OPTIONS if options is None else options)
    if adding:
        opts += list(adding)
    return extraParms + ",".join(opts) + ",CARDTYPE=" + \
           getCardtype(stem, original=original)

def stemOf(filename):
    '''The stem of a source filename, for callers that hold a path rather than
    a stem.  compileLinkRun and compileLinkCompare used to test "if name in
    filename", which matches anywhere in the path and depends on dict order;
    an exact stem is what compilePASS uses and what the table is keyed by.
    '''
    from pathlib import Path
    return Path(filename).stem
