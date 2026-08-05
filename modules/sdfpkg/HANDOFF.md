================================================================================
HANDOFF -- PASS corpus compilation, 2026-08-05
================================================================================
Written so a fresh session can restart from this file alone.  Companion
material: modules/sdfpkg/CLAUDE_LOG.md, and two helper scripts beside this
file, corpus-classify.py and corpus-run.sh.

This supersedes the 2026-08-03/04 handoff entirely.  Its section 7, on a
harness for reconstructing subscripts from the M/S card images, is obsolete:
that harness was measuring the output of a broken extractor, and the extractor
has since been fixed.  The one part of it worth keeping is the governing rule
about blank columns, which the separator fix now implements.

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
breaks template-dependency cycles by seeding the library (section 8), which
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
are reachable by seeding the library instead; see §11.

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
virtualagc:
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
8.  OPEN ITEMS
--------------------------------------------------------------------------------
Every failure the previous handoff listed here is now repaired, and both corpora
run to zero failures.  Kept in one line each, because the reasoning is settled
and the detail is in compilePASS.md:

  PMQTEC   FT101, "DATA TYPE CONFLICT ON PARAMETER #1", and it was CORRECT:
  SULUPLIN PMP_SL_PRB's first parameter is INTEGER in both versions and these
           called it with HEX literals, which are BIT.  Repaired with a W/V
           conditional pair, so HALSFC gets the correction (W->C, V->M) and the
           original compiler keeps the uncorrected code under CARDTYPE=WMVC.
           The control that settles the rule: GEQENT, GEPENT, GENEDM and GERENT
           all pass HEX'4000' to GKE_KIP, whose formal is BIT(16), and OI-34.06
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

THE REAL OPEN ITEM: the 156 and 161 files never attempted (section 1).  They are
blocked on each other, not broken, and the way in is to seed the template
library.  This is TESTED and works:

  1. PASS1 takes TEMPLIB as both input (--pdsi=4) and output (--pdso=6), but
     emits NO template when the compile fails.  So a cycle member cannot seed
     itself by being compiled and failing -- that was tried first and does not
     work.
  2. A stub carrying only the block statement CAN seed it, because what a
     caller needs is the name and the parameter list and nothing else.  For
     VM4BFSHU a two-line stub

         VM4_BF_SHUT_DN : PROCEDURE;
         CLOSE VM4_BF_SHUT_DN;

     compiled clean and deposited @@VM4BFS.  VM1BFDCY -- never once attempted
     before -- then compiled, exit 0, and VM4BFSHU recompiled for real over the
     stub, exit 0.  Cycle closed, nothing synthetic left in TEMPLIB.
  3. All six OI340600 cycles are seedable the same cheap way: every seed
     candidate is parameterless, so each needs only a two-line stub.  The seeds
     are ARAGPCSW (cycle of 29), GGQCOM (7), V01TCSSC (5), VM4BFSHU (2), GV6STA
     (2) and VS5SSTPR (2).  GV6STA looks parameterised only because its block
     statement is split across two cards.

  cycle-bootstrap-test.sh does step 1 and 2 for the VM pair.  What is NOT done
  is teaching compilePASS to do this by itself -- detect a cycle, seed it, and
  carry on -- which is what would actually move those 317 files into the run.

  Name a stub _stub*.hal: corpus-run.sh clears _*.hal at the start of a run, so
  a stub cannot leak into a later one.  Its .obj is NOT cleared; delete
  objects/_stub*.obj by hand.

Also open:
  - corpus-run.sh should pass --csects explicitly rather than relying on the
    ~/ForClaude/mafgen symlink (section 3).  Do not edit that script while a run
    is executing it: bash reads a script incrementally and an edit can corrupt
    the run in progress.
  - PASS4's DATABUF statistics were never checked against a known-good value;
    modules/sdfpkg/pass4-*.rpt from 2026-08-03 are a good baseline.
  - GX4DIS, PMCCYC and PMOSTA masters carry blocks no extraction has ever
    produced -- macro expansions, most likely.  Do not regenerate them blindly.

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
  the library is what works.  See section 8.
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
================================================================================
