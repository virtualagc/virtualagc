================================================================================
HANDOFF -- PASS corpus compilation, 2026-08-05
================================================================================
Written so a fresh session can restart from this file alone.  Companion
material: modules/sdfpkg/CLAUDE_LOG.md, and two helper scripts beside this
file, corpus-classify.py and corpus-run.sh.

THIS PHASE IS COMPLETE.  Both corpora compile in full, and nothing in here is
blocking.  The next phase is described in compileLinkCompare.md, beside this
file: comparing our linked binary against the actual AP-101S memory dumps.
Sections 1 through 7 remain the working knowledge a corpus run needs; section 8
records how the last failures were resolved, and 9 what not to re-litigate.

--------------------------------------------------------------------------------
1.  THE GOAL, AND WHERE IT STANDS
--------------------------------------------------------------------------------
Reach `successful == attempts` for a full compilePASS corpus run, for BOTH
PASS versions.

    OI340600   1188 / 1188     COMPLETE.  Zero failures, nothing unattempted.
    OI301700   1287 / 1287     COMPLETE.  Zero failures, nothing unattempted.

BOTH CORPORA COMPILE IN FULL.  Every HAL/S source file in both versions of
PASS now compiles, and the accounting closes exactly against the files on
disk:

    OI340600   1188 attempted - 21 stubs = 1167 = every source file
    OI301700   1287 attempted - 21 stubs = 1266 = every source file

with "not part of PASS" 0 and "did not compile" 0 in both, and a Done. line
on each.  For scale, OI340600 began the previous session at 843/907.

Three things got there.  corpus-run.sh passes --no-csects, so the auxiliary
files outside PASS are compiled too -- restricting to PASS was only ever a way
to reduce the up-front burden while failures were unexplained.  compilePASS
breaks template-dependency cycles by seeding the library (section 6), which
reached the 156 and 161 files no run had ever attempted; 21 cycles are seeded,
the same 21 in both corpora.  And the twelve OI301700 failures that the wider
coverage exposed were traced to six roots and repaired:

    4  macro-legend comments   GO1ASC GO2ORB GO3ENT VG9OPS9 -- the extraction
                               had copied the listing's rendering of OPSINIT's
                               own field comments back in as source, so the
                               macro emitted them AND the copy: M3, "comment
                               longer than 256 characters".  PFS a1ab8e89.
    5  DR121254 type mismatch  DM5NEW DM6OPS GO6RTL GO1ASC GO3ENT -- an INTEGER
                               literal 0 passed to a BIT(16) formal.  W/V
                               conditional pairs.  PFS be35c9e4, a1ab8e89.
    1  macro-valued subscripts VAASEQUE -- nine subscripts written $NAME where
                               NAME is a REPLACE macro; OI-34.06 writes
                               $(NAME).  PFS d5f28189.
    2  cascades                CDAP04/05/06/08 needed no change at all; their
                               DI11s were only GO1ASC and GO6RTL not existing.

*** CHECK THAT A RUN FINISHED. ***  `successful == attempts` is meaningless on
a run that stopped early, and compilePASS's summary does not say that it did.
The test is a "Done." line at the end of compilePASS.log:

    grep -c 'Done\.' compilePASS.log        # 1 = complete, 0 = aborted

An OI301700 run was reported as 935/939 when it had in fact stopped at file
1030 of 1266; the 236 files after it were never compiled.  That is fixed (a
PASS2 error is now delayable, see §6) but the habit is worth keeping.

Coverage is no longer an open question: nothing is left unattempted.  What
follows is kept because it explains WHY those files were unreachable, and the
seeding that reaches them depends on it.

Those files were NOT failures and nothing was wrong with them.  They sit in
mutually dependent groups: compilePASS compiles a file only once every template
it needs already exists, and in a cycle no member can go first.  OI340600 has
six such groups, of 29, 7, 5, 2, 2 and 2 members, and the remainder of the 156
hang off them.  155 of the 156 have unmet dependencies drawn only from the
blocked set itself, which is what proves the set closed.  The smallest group
shows the shape plainly:

    VM1BFDCY:58,63   CALL VM4_BF_SHUT_DN;      needs VM4's template
    VM4BFSHU:71      CANCEL VM1_BFD_CYCLIC;    needs VM1's template

Both uses are real, so no D INCLUDE TEMPLATE card can simply be dropped -- the
compile would fail on an undeclared name rather than a missing template.  They
are reachable by seeding the library instead, which compilePASS now does
for itself; see section 6.

--------------------------------------------------------------------------------
2.  WHERE EVERYTHING IS
--------------------------------------------------------------------------------
TWO SEPARATE GIT REPOSITORIES.  `git` run from inside the virtualagc checkout
against a PFS path reports "outside repository", which reads as "not version
controlled" and is wrong.  cd into the PFS tree first.

  /mnt/STORAGE/home/rburkey/git/virtualagc        compiler, compilePASS, HALSFC
  /mnt/STORAGE/home/rburkey/workspace/PFS         PASS source, branch master
  /home/rburkey/ForClaude                         corpus work directories

Inside ~/workspace/PFS:

  OI340600/, OI301700/                 the masters.  Committable.  OI340600's
                                       source is genuine punch cards; OI301700's
                                       was extracted from listings (§4).
  "OI301700 as received"/APPLSRC/      1115 original build listings, plus
                                       SSSRC/.  PRIMARY EVIDENCE.  See §3.
  unprint.py                           the extractor.  See §4.
  prepareSource.py                     header + anonymization.  Needs the
                                       `ahocorapy` package, which is not
                                       installed; a 60-line Aho-Corasick
                                       stand-in reproduces master bodies
                                       byte-for-byte, so the anonymizer is
                                       deterministic given its .anon files.
                                       Note it appends to collisions.anon.

Inside ~/ForClaude:

  OI340600-sdftest/, OI301700-sdftest/ the corpus work directories.  Untracked
                                       build output, and NOT under ~/workspace/
                                       PFS: that is an IDE project, and the
                                       ~2.3 million files a run's archives
                                       accumulate froze the IDE solid.  Keep
                                       generated files here.  Never run find or
                                       du across these trees; the file count
                                       makes it take hours.  See §9.

*** TRAP ***  The -sdftest directories hold their own COPIES of APPLSRC,
SSSRC and INCL80.  Editing a master does NOT affect a run.  rsync first:

    for v in OI340600 OI301700; do
      for d in APPLSRC SSSRC INCL80; do
        [ -d ~/workspace/PFS/$v/$d ] &&
          rsync -a --delete ~/workspace/PFS/$v/$d/ ~/ForClaude/$v-sdftest/$d/
      done
    done

--------------------------------------------------------------------------------
3.  HOW TO RUN A CORPUS
--------------------------------------------------------------------------------
corpus-run.sh does all of it:

    ./corpus-run.sh ~/ForClaude/OI340600-sdftest TAG

TAG names the archives of the previous run so nothing is lost.  Classify with

    python3 corpus-classify.py ~/ForClaude/OI340600-sdftest/compilePASS.log

Do NOT count failures by grepping ": Compiling" against "Compilation
successful": the log carries two phase headers that inflate the count.

*** TRAP ***  compilePASS defaults --csects to ../mafgen, a RELATIVE path, which
resolved to ~/workspace/PFS/mafgen before the work directories moved to
~/ForClaude and to nothing afterwards.  Without it every HAL/S file is compiled,
including the ones that should be reported "Not part of PASS", and the run says
so in its very first line:

    Warning: no CSECT indexes found in ../mafgen; every HAL/S file will be
    compiled.

~/ForClaude/mafgen is symlinked at the masters to restore it.  Passing --csects
explicitly from corpus-run.sh would be better and is not yet done.

Both corpora can run at once.  The abort that made the previous handoff advise
staggering is now understood and is NOT concurrency: a KILLED run leaves
orphaned HALSFC processes writing halmat.bin, litfile.bin and COMMON*.out into
the work directory, and a fresh run started on top of them loses its
intermediates and dies after FLO with exit 240 and "Unable to open COMMON input
file".  Before starting a run, check for strays BY argv[0] --

    ps -eo args --no-headers | awk '{m=split($1,b,"/"); if (b[m] ~ /^HALSFC/) c++}
                                    END {print c+0}'

-- because a pgrep -f against the whole command line matches the checking
command itself and reads as a false positive.  It is also NOT the shared
yaShuttle/ported directory, whose files are untouched during a run.

Launch runs with setsid.  A background job started from a tool-invoked shell
dies with that shell's process group; both corpora were once lost that way to a
pkill aimed at something else entirely.

corpus-run.sh now passes --extra-parms=TABLST, so PASS4 parses each SDF the run
has written rather than merely opening it, making the corpus a test of PASS4
and SDFPKG too.  It costs report size and some time.

When the compiler needs rebuilding, build only the PASS targets:

    make PASS1 FLO OPT AUXP PASS2 PASS3 PASS4

NOT `make all`, which also builds the B variants (PASS1B, OPTB, PASS2B,
PASS3B).  Those are for BFS: PASS code is not intended to compile with them and
would not be properly functional if it did.  HALSFC selects them only under
--bfs, which neither compilePASS nor corpus-run.sh passes, so they are never
used here -- building them is about half the build time wasted.

--------------------------------------------------------------------------------
4.  THE EXTRACTOR IS THE ROOT OF EVERY OI301700 ARTIFACT
--------------------------------------------------------------------------------
*** DO NOT RE-EXTRACT.  The extracted tree is now the authority, not a thing
that can be regenerated. ***  OI-30.17's listings are pre-resolved: they record
one CARDTYPE resolution and cannot say which letter a card carried.  The
column-1 letters in INCL80/GKPMNV.hal and in GKDASC, GKGMNV and GKRORB were
restored by hand from OI-34.06 and could not be recovered from the listings a
second time.  A re-extraction would silently discard them.  For the same reason
the seventh unprint.py defect below is left unfixed.

OI301700's HAL/S was extracted from the output-writer listings by
~/workspace/PFS/unprint.py.  Seven bugs in it accounted for every artifact
class the previous session had been repairing by hand.  All are fixed; the
masters were regenerated (434 files) by three-way merge with the previous
extraction as the ancestor, so anonymization, headers and hand repairs the
extractor still cannot make all survived.

  1. collapseES() recursed without passing its S flag, so a subscript of a
     subscript came out as an exponent: "$(NAME**INDEX)" for "$(NAME$(INDEX))".
     112 sites.  PFS c2a8fa9.
  2. E and S lines were padded `use` columns for an absent card but `use`-1 for
     a present one, so from the second card of a statement onward they sat one
     column left of their M card.  Subscripts lost their last character and it
     reappeared as a subscript of its own: "$AXIS" -> "$AXI" plus a stray "$S".
  3. startGap() ignored the caller's left boundary, so blanks past the end of a
     subscript let the recursion reach back and emit the subscript to its left
     a second time: "...$1);" acquired a trailing "$1".
  4. Collapsing a subscript ate the blank separating two identifiers, turning
     an implicit multiply into one undeclared identifier:
     "CGCV_GDQ_SLOPE$INDXTEMP_MACH".  The blank is kept where it separates
     identifiers, which is the only place it can matter.
  5. The DO-nesting level test demanded exactly 2*level+1 following blanks,
     missing every two-digit level and every outdented label; the digits became
     source, as in "(GSF_NZ_INHIBIT = ON) 10 THEN DO;".  120 sites.  PFS
     3a6bbea.  Levels run 1..17; the rule is now "digits at offset 1 followed
     by 3+ blanks, or by 1-2 blanks and a label".  Checked by requiring every M
     card of a statement to agree: 188510 groups, no disagreements.
  6. The test that ended an inclusion was the "elif" of the one that began one,
     so a "D INCLUDE" card immediately following another member's expansion was
     written into that member's file and vanished from the parent.  SSMANTMG
     lost its own "D INCLUDE TCSMACS", and with it the TCSOUT macro.  172 cards
     over 136 modules recovered.  Also: an include card now carries its SRN.
  7. addPar() judged a subscript by how it was spelled, so a bare identifier got
     no parentheses -- but an identifier can be a REPLACE macro standing for its
     expansion.  "$PGH_LINE_PL_NUM" expands to "$INTEGER(...)" and PASS1 rejects
     it, naming INTEGER as the illegal symbol and never mentioning the
     subscript.  unprint.py now consults each file's REPLACE table.  Of 274
     macro subscripts, 258 expand to something simple and are left alone.
     PFS 7016b8d1.

  8. A "D DEFINE" region is routed to a file of its own, exactly as a
     "D INCLUDE" expansion is, so the body arrives in INCL80 rather than
     between the DEFINE and its CLOSE.  The sequence is then empty and draws
     XD7, which costs the module through the SMRK/B100 path.  GMGMAJ and
     GMESTA were repaired by splicing the bodies back inline and deleting
     INCL80/GM6CLC, GMITUP, GM4DIS and GM8UPL, which never existed in the
     original.  UNFIXED in unprint.py, deliberately -- see the warning above.

WHAT THE EXTRACTOR STILL GETS WRONG, and cannot easily be taught:

  The output writer prints the legend of a macro's parameters as a comment on a
  card carrying the statement's ";", and unprint.py takes it for source:

      030600  295 M|   PFLOW(SAF_PFLOW, SAF_SVC_MDM_READ_EVENT, NO_WATE)
      030600  296 M|   ; /* I/O SVC NUMBER=24  UNUSED  SYNC TYPE ...       */
                  S|     /* TRANSACTION ERROR STATUS  OUTPUT I/O ...       */
                  S|     /*WORD COUNT  BUFFER NAME  EVENT  I/O SVC NUM**/

  At compile time the macro expands and emits the legend again; together they
  pass 256 characters and draw M3.  OI-34.06 shows the card is really one line
  with no comment at all.  Four files repaired by hand so far: SPSPSP, SAFACQ,
  SPNINT, SPCPPC.  A RE-EXTRACTION WILL REINTRODUCE THESE.

  Suppressing the merge in unprint.py was tried and reverted: the M and S values
  it must test are the concatenation of every card of the statement, so it
  cannot tell a closed comment from an open one, and it truncated genuine
  comment overflow (CDHMMUTI) and cost subscripts (DMPMMMSG).

  DO NOT repair this class by pattern.  "A call ending in ')' followed by a card
  beginning '; /*'" occurs 199 times in 57 files and most are genuine source
  comments -- "DISABLE INTERRUPTS", "RELEASE COMMON BUFFER", "DR44041".  Confirm
  each against OI-34.06's own copy of the file, which exists for all 57.

--------------------------------------------------------------------------------
5.  THE MOST USEFUL TOOLS
--------------------------------------------------------------------------------
FIRST:  ~/workspace/PFS/"OI301700 as received"/APPLSRC/ holds the real listings.
They settle questions that resist reasoning.  Line format:

    SRN     stmt +T| source text ...                        |rv|CURRENT_SCOPE

  - The character before "|" is the card type AFTER CARDTYPE substitution:
    C = comment, M = live code, D = directive, E/S = exponent/subscript.
  - A "+" between the statement number and column 1 marks an INCLUDED line.
  - Immediately after "|" is the DO-NESTING LEVEL.  It is NOT source.
  - An error in the original build shows as a "+ ___" underline card.  Their
    absence is evidence: PMQTEC's statement 116 has none, so the original
    compiler accepted what ours rejects.

Card ordering: zero or more E cards, then exactly one M card, then zero or more
S cards.  Exponents above, subscripts below.

They CANNOT tell you: error summaries; whether an include came from a template
or an SDF; anything at all about a NOLIST include, which prints nothing.

SECOND:  OI340600's source was NOT extracted from listings, so where a file
exists in both versions it is authoritative for correct 1-D form.  Every repair
in this session was confirmed against it before being made.

--------------------------------------------------------------------------------
6.  WHAT ELSE WAS FIXED
--------------------------------------------------------------------------------
compileLinkCompare / compileLinkRun (found while starting the DASS comparison):
             compileLinkCompare never passed --sdfi, so it read no SDFs and
             satisfied every "D INCLUDE TEMPLATE" from the template library
             alone -- a path compilePASS never exercises.  SSSRC/ARDCSBUS.hal
             found it: "REL3 SDF ##CDLANN NOT FOUND", seven errors of severity
             2.  The default now lives in halsParms.py as DEFAULT_SDFI, with
             --sdfi=D and --no-sdfi to override.  Note what this cost: it did
             not skew comparisons, it removed files from them.
             compileLinkRun's cleanup block deleted nothing.  Its last three
             clauses read "symfile = f'...'" where they meant "os.remove(...)",
             which is the source of the BASENAME*.* residue in PFS/OI340600.
             Fixed, and both scripts now take --out-dir=D so their output need
             not land in the source tree at all.
             Both scripts ended their failure paths in os._exit(), which skips
             interpreter shutdown and discards stdout's buffer -- so a failed
             compile printed its diagnostic and then exited with no output
             whatever, any time stdout was a pipe.  Replaced with a flushing
             die().
             compileLinkCompare's rldanalyze fallback named "../{config}.fcm"
             and a literal "../csects-{config}.json" (missing its f prefix);
             compileLinkRun's copy referred to `config`, which does not exist in
             that script, so a link failure raised NameError from inside the
             error handler.  Fixed and removed respectively.
             The comparison work directory is ~/ForClaude/OI340600-clc, seeded
             from PFS/OI340600's libraries -- about 113 MB, and it keeps
             HALSFC's archive.results out of the PFS IDE project.

virtualagc:
  bc0575a73  compilePASS seeds template-dependency cycles.  A file is compiled
             only once every template it needs exists, so a group needing each
             other's templates could never start.  When the ordering stalls,
             the remainder is decomposed into strongly connected components and
             one member of each is seeded with a stub carrying only its block
             statement; the real unit is compiled over it once its own
             dependencies clear, so nothing synthetic survives.  21 cycles are
             seeded per corpus.  seedable() refuses a COMPOOL, whose template
             IS its declarations, and anything taking parameters, which HAL/S
             requires a body to DECLARE -- a stub for either deposits a WRONG
             template, and its callers are never recompiled.  Stubs are named
             _stub*.hal so corpus-run.sh's "rm _*.hal" clears them.
  32e7ff3ae  sdf.py carries a VMP offset past 32K properly.  A VMP holds a page
             number above an offset 0..1679, and adding a byte count to the
             whole word survives only while the sum stays under 0x8000, where
             mode5 starts reading the low half as signed.  Only a large SDF has
             a statement index table that long: ##VAASEQ, 152 pages, made the
             Python compiler abend 4005 where the C one did not, so --test
             reported them disagreeing and abandoned VTCTCSCO.  Fix only the
             positive-past-0x8000 case: replacing the arithmetic wholesale
             breaks the negative-offset path, which mode5's "if offset < 0:
             pageNumber += 1" exists to compensate.
  a5b057fed  SDFLIST --all selects each SDF, and writes its directory as
             80-byte records.  Two independent defects: SDF_PROCESSING's ALL
             path named a member without issuing the SELECT disposition, so
             DUMP_SDF dumped whichever SDF was already current, 37448 times;
             and device 3 delivers fixed 80-byte records, so a single oversized
             directory record truncated at six members.
  65454288b  halsParms.py holds the CARDTYPE table, the conditional pairs and
             the option list for compilePASS, compileLinkRun and
             compileLinkCompare together.  They had drifted three ways, and
             compileLinkCompare appended no conditional pairs at all, so a U-Z
             card would have been M1 there while compiling everywhere else.
  3b78ef4e8  D15 becomes severity 0, so PGPPLD compiles.  Severity 1 is not
             enough: PASS1 records a statement's highest severity in its SMRK
             and OPTIMISE.xpl:144 raises B100 for any nonzero tag, so PASS2
             abandons the conversion.  Only 0 leaves the statement unflagged.
             The nine D15s still print.  THIS MECHANISM EXPLAINS M3 AND XD7
             FAILURES TOO -- a severity-1 warning still costs the object module.
  d98f97e01  compilePASS: a CARDTYPE pair naming a standard type is inert.
             PASS1 installs a pair only where the type has no meaning yet
             (INITIALI.xpl:526-538, guarded by IF CARD_TYPE(J) = 0), so
             CV5SLCOM's "DC" is nothing in the compiler -- but the scan applied
             it and turned every D card of the file into a comment, hiding
             CPSSLD as a dependency.
  443eb57ff  PASS4 defaults --sdfi to SDFLIB (PASS4 alone, gated on APP_NAME),
             and MONITOR22A reports "no SDF library" through CRETURN, which is
             where SDFPROCE.xpl:116 and INCSDF.xpl:716 actually look.  Without
             it PASS4 formatted a whole report out of address 0 and INCSDF set
             SDF_OPEN = TRUE on a failure return.
  81ee884e2  SDFLIST.py, and a PASS2 error is now delayable.  See §1 and §7.
  (also)     compilePASS --extra-parms, for TABLST.

~/workspace/PFS:
  c2a8fa9, 3a6bbea, f4d6d80, 79854d6, 7016b8d1   unprint.py, seven bugs
  5efb99e, 70d0eaa                               434 files regenerated
  d4e5bfa    19 INCL80 members borrowed from OI-34.06.  They are named by
             "D INCLUDE" in OI-30.17 source but absent from its library, and
             all 61 directives that include them say NOLIST -- which prints
             nothing in a report, so no copy was ever there to extract.  Each
             carries a History entry.  DOWBUILD, EVNTCHEK and TCSBUILD are
             wanted too but do not exist in OI-34.06 either; PMOSTA and PMCCYC,
             which want them, already carry hand-inlined expansions.
  7abb7533, fbc2110f   SAFACQ, SPNINT, SPCPPC: macro legends removed

--------------------------------------------------------------------------------
7.  RUNNING THE SDF REPORTS
--------------------------------------------------------------------------------
From a *.results directory, which is where the SDF library is left:

    SDFLIST.py "##HELLO"                    one SDF, default TABLST
    SDFLIST.py --brief "##HELLO" "##FOO"    the summary only
    SDFLIST.py --all --tabdmp                every SDF, full dump
    echo NAME | HALSFC-PASS4 --parm=BRIEF    equivalent for one, by hand

Quote the names: "##" begins a comment to the shell.

SDFLIST.py exists because of --all, which reads the names from an OS/360 PDS
directory block on device 3 (SDFPROCE.xpl:127-144) -- a halfword byte count,
then entries of an 8-byte EBCDIC name, a 3-byte TTR and a flags byte whose low
five bits give a count of user halfwords, so an entry is 12 + 2*(flags & 0x1F)
bytes, ending at a name of eight 0xFF bytes.  --pdsi=3 does not attach
INPUT(3); it must be --ddi=3,FILE,E, and without the ",E" the runtime reads the
block as ASCII and every name arrives blank.

--------------------------------------------------------------------------------
8.  HOW THE LAST FAILURES WERE RESOLVED
--------------------------------------------------------------------------------
NOTHING IS OPEN IN THIS PHASE.  Both corpora compile in full, so what follows
is a record of how the last failures were resolved, kept because the mechanisms
recur and because two of them were misdiagnosed first.

The twelve OI301700 failures that the wider coverage exposed were SIX ROOTS:

  4  MACRO-LEGEND COMMENTS, and this is the one that was misdiagnosed.
     GO1ASC, GO2ORB, GO3ENT and VG9OPS9 each carried a four-line comment after
     an OPSINIT(...) invocation, reported by PASS1 as M3, "COMMENT LONGER THAN
     256 CHARACTERS".  The comment is NOT source.  INCL80/OPSIMACS.hal defines
     OPSINIT as a STRUCTURE whose members each carry a small comment -- "/* I/O
     SVC NUMBER=24 */", "/* UNUSED */", "/* SYNC TYPE */" -- and the
     output-writer listing prints them concatenated at the statement end.  The
     extraction copied that rendering back in as a literal comment, so
     compiling emitted the macro's comments AND the copy: 218 characters twice,
     truncated at 256.  It was first called a compiler bug on the strength of
     the doubling; the minimal test case settled it, because the comment ALONE
     compiles clean.  Tells: the invented SRNs +1/+2/+3 on the continuation
     cards, since the listing's S cards carry no SRN, and OI-34.06 has no
     comment at any of these sites.  PFS a1ab8e89.
  5  DR121254 TYPE MISMATCH.  DM5NEW, DM6OPS and GO6RTL, then GO1ASC and GO3ENT
     once M3 stopped masking them, pass the INTEGER literal 0 to a BIT(16)
     formal -- ARX_RS_BUS_CHG's NEW_SET_MASK, GUS_CS_COM_PROC's MSK_INT_ITI --
     which PASS2 rejects with FT101.  This is DR121254 again, in the OPPOSITE
     direction from PMQTEC, where a BIT literal reached an INTEGER formal.
     OI-34.06 settles the form: its DM6OPS carries the same call at the same
     SRN 033700 and passes HEX'0000'.  Repaired as W/V pairs.  PFS be35c9e4,
     a1ab8e89.
  1  MACRO-VALUED SUBSCRIPTS, also misdiagnosed first.  VAASEQUE failed P8,
     "SYMBOL SYNTACTICALLY ILLEGAL: +", and the diagnostic pointed nowhere near
     the fault -- the nearest '+' was in a later statement whose source is
     provably correct, confirmed by the original listing's S card reading
     "N+2:" and by OI-34.06 writing the identical CVAA_READY$(N+2:)=OFF; and
     compiling it.  The real fault is nine subscripts written $NAME where NAME
     is a REPLACE macro; OI-34.06 writes $(NAME).  The unparenthesised form
     misparses for a macro, and error recovery then blamed a '+' further on.
     Only subscripts whose name is a known REPLACE are changed -- five
     $SPEC_CMD and four $SINGLE_CMD.  PFS d5f28189.
  0  CASCADES.  CDAP04, CDAP05, CDAP06 and CDAP08 needed no change whatever;
     their DI11s were only GO1ASC and GO6RTL not existing yet.

Two lessons in there, both of which cost time:

  - A diagnostic can point a long way from its cause.  Error recovery reported
    VAASEQUE's P8 against a statement that was correct, and the M3 truncation
    display made a doubled buffer look like a compiler defect.  Reduce to a
    minimal test case before believing the pointer.
  - Clearing one error exposes the next.  GO1ASC and GO3ENT showed FT101 only
    after M3 came off them.  A failure count is a lower bound.

Earlier failures, all repaired and confirmed, one line each:

  PMQTEC   FT101 as above, the BIT-literal-to-INTEGER-formal direction.  The
  SULUPLIN control that settles the rule: GEQENT, GEPENT, GENEDM and GERENT all
           pass HEX'4000' to GKE_KIP, whose formal is BIT(16), and OI-34.06
           compiles them clean.  Passing a hex literal is not the problem;
           passing one to an INTEGER formal is.  Page 165 of the 1974 HAL/S
           Programmer's Guide carries the same INTEGER/SCALAR PARAMETER rule
           word-for-word as the 2005 edition, so DR121254 reads as the compiler
           being brought into compliance with documentation that always said
           this, not as a rule changing under the source's feet.
  GMGMAJ   XD7, "DEFINE SEQUENCE IS EMPTY" -- the extractor had relocated the
  GMESTA   DEFINE bodies out of the module.  Spliced back inline (69, 52, 52
           and 245 lines) and four phantom INCL80 members deleted.
  GKGMNV   DU1.  GKPMNV is shared by three modules that select different
           variants of the same cards through CARDTYPE, and OI-30.17's
           pre-resolved listings had baked in GKRORB's.  The user restored the
           column-1 letters by hand in GKPMNV, GKDASC, GKGMNV and GKRORB from
           OI-34.06, matching on line beginnings; all 140 cards agree.
  GKEKIP   XI3 cascades -- a needed template's provider had failed.  They
  GM2MAJ   cleared themselves once the roots above were repaired.
  GMAMIN
  SGCKIP   DI11 plus an XI3 for @@SAFACQ; SAFACQ was repaired.
  SAFACQ   M3/P8 macro-legend and macro-subscript artifacts, all repaired and
  SPNINT   confirmed by a complete run.
  SPCPPC
  PGHHEA
  PGGPCF

Carried forward, none of it blocking:
  - PASS4's DATABUF statistics were never checked against a known-good value;
    modules/sdfpkg/pass4-*.rpt from 2026-08-03 are a good baseline.
  - GX4DIS, PMCCYC and PMOSTA masters carry blocks no extraction has ever
    produced -- macro expansions, most likely.  Do not regenerate them blindly.
  - A stub's .obj is not cleared between runs; delete objects/_stub*.obj by
    hand if it matters.  The .hal is cleared, because corpus-run.sh removes
    _*.hal at the start of a run.

--------------------------------------------------------------------------------
9.  SETTLED -- DO NOT RE-LITIGATE
--------------------------------------------------------------------------------
- The SDF include path "importing too much" is NOT a defect.  It is the
  transitive-include mechanism: ENTER_COMPOOL_VARS walks the whole declare
  chain, and INCSDF's DUPLICATE_NAME/SET_DUPL_FLAG tolerates redeclaration.
  Those are the two things preprocessHALSFC's header says the compiler lacks,
  which is why the preprocessor is off by default -- and why it did harm: it
  knows only "D INCLUDE TEMPLATE" and is blind to "D INCLUDE SDF X:".
- There is NO re-export filter in PASS1 to find.  EMIT_EXTERNAL echoes tokens
  as scanned, with no suspension during an include.
- IDENTIFY.xpl:610300 "IF I < PROCMARK THEN GO TO NOT_FOUND" is what makes a
  match in an outer scope not a duplicate.
- Duplication alone does not cause DQ7; the NAME-alias form is the trigger.
- PASS4 already receives the SDF name through COMMON.  pass4.rpt is empty in
  the chain only because the default parms carry neither TABLST nor TABDMP.
- The R-card rule is NOT "COMPOOLs get R=C".  Read the report markers.
- The CDR06D abort is orphaned HALSFC processes from a killed run, NOT
  concurrency and NOT the shared ported directory.  See section 3.
- The files never attempted are blocked on each other, not damaged.  Neither
  D INCLUDE TEMPLATE card in a cycle is vestigial -- both members really do use
  each other -- so the cycle cannot be broken by dropping an include.  Seeding
  the library is what works, and compilePASS does it.  See section 6.
- FT101 on a hex literal is the compiler being right.  Do not "fix" it in the
  compiler.
- The validation method for any change to the extractor: extract the whole
  report set with both the old and the new unprint.py, then compare each against
  the master at TOKEN level, three ways.  That separates "the fix changed this"
  from "the master was repaired by hand here" without any judgement calls.
- The corpus work directories belong under ~/ForClaude, not ~/workspace/PFS.
  PFS is an IDE project; 20 generations of archive.results.* had accumulated
  there, ~1000 module subdirectories of ~58 files apiece per generation, about
  2.3 million files across the two corpora, and the IDE could no longer open.
  relocate-sdftest.sh moved them and packs all but the two newest generations
  per corpus into .tar.zst.  Do not move them back, and do not let generated
  output accumulate under PFS again.

--------------------------------------------------------------------------------
10. WORKING RULES
--------------------------------------------------------------------------------
- Do not edit or create *.md files in a project directory without the exact
  phrase "Full Documentation Sync".  Append to ./CLAUDE_LOG.md instead.  The
  global rule carves out "working files" -- HANDOFF*.md, *-handoff.md,
  RELAY-TO-*.md, RELAY-FROM-*.md -- which may be created and updated freely
  when the user has asked for them.  That is why this file is .md.
- Commit finished, verified work proactively; do not wait to be asked.
- Virtual AGC edits to PASS source are limited to comments and conditionally
  compiled lines marked U-Z in column 1.  Other odd column-1 letters are
  PASS's own.
- Work in the -sdftest copies.  The masters are the user's.
- Verify a repair against OI-34.06 before making it.  Every repair in this
  session that was checked this way was right; the one pattern-based sweep that
  was NOT checked would have deleted 174 genuine comments.

--------------------------------------------------------------------------------
11. THE NEXT PHASE
--------------------------------------------------------------------------------
Compiling cleanly is not the same as generating correct code, and nothing in
this phase checked the code we generate.  That is the next phase, and it is
described in compileLinkCompare.md beside this file: link our objects at the
CSECT addresses the real build used, and compare our binary against the actual
AP-101S memory dumps in PFS/mafgen.

Three things from that document are worth knowing before opening it:

  - The job is 3212 HAL/S-derived CSECTs, not the 3859 in the indices.  The
    rest are assembly, which we cannot yet assemble, or HAL/S runtime library
    routines, which we do not compile at all.
  - Work one memory configuration at a time, smallest first: SSW is 387 CSECTs
    against G16's 1406.  The per-configuration counts sum to 7059 instances
    over 3212 distinct CSECTs, so a mechanism fixed in SSW is already fixed
    wherever else it occurs.
  - Do NOT start by mass-testing every file.  Only a few failure mechanisms are
    expected; take each intensively as it appears.  compilePASS is a mass
    driver, but it existed because that triage had already happened -- it was
    the tool that survived the process, not the one that began it.

The corpus tooling here is directly reusable: corpus-run.sh's discipline of
starting from source alone, the argv[0] check for stray compilers, setsid for
launching, and the habit of verifying a run finished before believing its
numbers.
================================================================================

================================================================================
11. DASS COMPARISON -- CURRENT STATE AND NEXT STEPS  (2026-08-07)
================================================================================

STATE.  The last COMPLETED sweep gave 14379 of 14407 in-index sections matching,
28 differing, 0 errors, with SSW, P9 and G2 exact.  Those numbers PREDATE the
2026-08-07 fixes below and are expected to improve; a re-measuring sweep is
running as this is written.  ~/ForClaude/run-configs.log is the live record and
holds a "RESULT" line per configuration.  Process detail is in
PFS/mafgenComparison.md, outcomes in modules/sdfpkg/compileLinkCompare.md.

DONE 2026-08-07, all committed, all pending re-measurement:

  - FOREIGN SYMBOLS, per site (c90e0f9f9).  A symbol absent from a configuration
    is no longer given a borrowed address unconditionally, nor withheld
    unconditionally; the dump decides per symbol.  Only ANCHORED sites count --
    the referencing section must sit in the index at exactly the address lnk101
    placed it -- and a site holding the bare addend, or the addend with bit 15
    set, says the build left it alone.  --foreign-symbols became
    --no-foreign-symbols.  Recovers #EVRPRAM in seven configurations and
    #EASCTIM in G3/G16; withdraws nothing.

  - NONHAL COMPOOLS (8857e5f3c).  S2's SAFACQ references #PCSADAR, #PCSAINB,
    #PCSAIXP and #PCSAPAR, which no configuration and no HALSTAT phase defines.
    HALSTAT's compilation layout marks them NONHAL: nothing in HAL/S defines
    them and the configuration supplies the storage, here #PCS2DAR, #PCS2INB,
    #PCS2IXP, #PCS2PAR.  All thirteen address references land exactly on those
    CSECT starts, including two negative displacements and one sector-encoded
    ZCON.  basesFrom() honours the RLD sign bit and bit-15 encoding and excludes
    BSR-only/DSR-only relocations, which patch a register field not an address.
    A uniqueness guard refuses an address several symbols derive -- which is
    what refuses S2's seven #ZP symbols all deriving 0x298.

  - ATTRIBUTION FROM RESOLVED OPERANDS (932f48219, then 4ee23d41a).  The
    planned sector-decoding fix was unnecessary.  At a relocation site lnk101
    already names the target and says what it resolved to, so decode the dump's
    halfword by the same amount and judge containment against the DUMP's extent.
    Better still, MAFGEN's own disassembly resolves EVERY instruction operand to
    an effective address and usually names the variable, which is evidence
    exactly where relocation records do not exist.  dass-versions.py now reads
    it.  This closed the SPSPSP family; see PFS/mafgenComparison.md.

  - owner() takes the NARROWEST containing CSECT (ae3dee531).  Spans nest by
    design.  Changes nothing measurable today and is kept as a guard.

  - SWEEP SANDBOX.  run-configs.sh now copies dass-*.py AND nsts-sdl-dps/src
    into a mktemp directory and runs from there, exporting PYTHONPATH so the
    copy shadows the build venv's editable .pth.  Both toolchain commits are
    logged at launch.

    TWO TRAPS, both paid for.  First: a snapshot only isolates if every path the
    snapshotted code derives from ITS OWN LOCATION is redirected too.  dass-db.py
    sets DEFAULT_DB from Path(__file__).parent, so results went into the
    snapshot's own database and the EXIT trap deleted them, while the
    inter-sweep resets still hit the real one -- so sweeps 2 and 3 never ran.
    The tell was "RESULT S2: 0/0 sections match".  Fixed by passing --db
    explicitly at every call site.  Second: bash reads a script incrementally,
    so run-configs.sh must be replaced with mv, never edited in place, while a
    sweep is running.

  - WORKING DISCIPLINE.  The sandbox lets you EDIT during a sweep; it does not
    make a running sweep's results current.  Three restarts in one day.  A sweep
    is a measurement: start it after changes have stopped, investigate freely
    while it runs, and expect to discard and re-run if the investigation lands a
    fix.  Killing a sweep can leak rows for the config it was mid-way through --
    check "SELECT config, COUNT(*) FROM run" before relaunching.

NEXT STEPS, in order, once that sweep finishes:

  1. RE-TEST G9 #PCSDMD1 (24 halfwords).  Called a dead end -- "no honest base
     to recover" -- but that was concluded while decoding raw halfwords, the
     very error the operand-column work corrects.  Treat the earlier verdict as
     suspect.  This is also the cheapest test of whether that work generalises
     beyond the family it was built for.

  2. RE-EXAMINE THE FCOS CASES against the DASS operand column.  References into
     FIOCDATS, FIOMODSM and FCMPSA were called "not attributable at all", partly
     on the reasoning that a base-register reference names no target.  That
     reasoning is now known to be wrong in general -- MAFGEN names it.  A
     related claim already fell: what looked like references into FIOCBLKS were
     sector-encoded ZCON halfwords pointing into #PCSASAT, a revised HAL/S
     COMPOOL.  This is the largest outstanding change to the document's
     conclusions.

  3. THE REST OF THE S2 UNRESOLVED-SYMBOL CLASS.  The NONHAL work covered
     SAFACQ.  Still open: SCKPNT, SRESTO, STMTAB and SULUPLIN leave references
     to #PCSAPDT as "8002 0000" where the dump holds "B8C0 0006", and #PCSAPDT
     IS in S2's index at 0xB040.  That makes it ours to fix, not version drift.

  4. G16 #DGFKGRT at 07DFE holds 4232 against the dump's 0000, with NO
     relocation at that site -- so it is compile-time data, not a link artefact.
     Possibly an I-LOAD that MAFGEN did not mark.  4232 coincides with
     #PCAASCC's address in other configurations, which may be a red herring.

  5. THE .000001 LITERAL.  Not blocked after all: HALSFC is a plain Python
     program invoked by path, so it can be copied and instrumented without
     disturbing anything.  The unknown is the PASS1 call site that reaches a
     via-double conversion instead of MONITOR(10)'s ibm_dp_from_string.  See
     virtualagc issue #1296, where the evidence is already posted.

  6. THE "-2" NO-CLAIM CATEGORY.  Also unblocked, now that the sweep snapshots
     nsts-sdl-dps/src.  Needs a third upstream PR: fcmcmp cannot take -2 as-is
     because int("-2",16) parses, making it a CHECKED value that fails and still
     counts.  PRs #31 (lnk101 absent-section relocations) and #32 (fcmcmp size
     reporting) have been open since 2026-08-06; #27-#30 are merged.

  7. A "reset one configuration" helper for dass-compare.db.  The SQL has been
     hand-written three times and leaked stale rows twice.

  8. CONVERT CLAUDE_LOG.md TO A DATABASE (user's instruction, 2026-08-07).
     Table (timestamp, target, entry, applied), so capture is an INSERT, a
     "Full Documentation Sync" is SELECT ... WHERE applied=0 AND target=?, and
     completing one is an UPDATE.  Rationale is context cost: today's sync read
     96 KB of log plus every target file, and hand-sorting 53 entries across two
     passes nearly lost track of which were applied.
     The design point that makes this work, from the user: a database can RENDER
     .md as a one-time operation whenever wanted.  So the DB is the store and
     the document is a generated view -- commit the rendering, which keeps it
     readable and diffable even though the store is binary.  Do not treat this
     as replacing prose; it replaces the flat staging file.

BLOCKED, needing a decision or a rebuild:

  * The .000001 literal.  Our compiler emits the CEILING (A0B5ED8E), which is
    what a round trip through a C double gives; ibm_dp_from_string gives the
    correctly rounded A0B5ED8D.  The literal is already wrong in litfile0.bin,
    so PASS1 is at fault and PASS2 is not involved.  The via-double call site is
    NOT yet found: MONITOR10 uses ibm_dp_from_string, inline360.c is clean, and
    the built HALSFC-PASS1 is newer than its runtimeC.c.  Confirming needs an
    instrumented PASS1 rebuild.  Separately the dump's A0B5ED8C is reachable by
    no rounding mode and not by the genuine S/360 IHCFDXPI either, so it is
    recorded as a suspected original-compiler defect -- see virtualagc issue
    #1296, where the case is written up.

  * Recording that residue as -2 rather than -1, to keep it distinct from the
    FCOS version differences.  fcmcmp CANNOT take -2 as it stands: int("-2",16)
    parses, so the entry becomes a CHECKED value of -2, fails its check, is
    ignored, and the difference still counts.  Needs a third upstream PR.

REFERENCE.  ~/ForClaude/mvt/extracted/ holds the System/360 FORTRAN library
recovered from Jay Moseley's tape -- 424 assembler listings (source AND object
code) including IHCFDXPI, IHCFDXPD, IHCFRXPI, IHCFRXPR, IHCLEXP, IHCLLOG,
IHCLSQRT, and IEYFORT itself.  README.txt there explains how the .het was read
without Hercules utilities.
