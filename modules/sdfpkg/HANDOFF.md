================================================================================
HANDOFF -- PASS corpus compilation, 2026-08-05
================================================================================
Written so a fresh session can restart from this file alone.  Companion
material: two helper scripts beside this file, corpus-classify.py and
corpus-run.sh.

*** THIS FILE IS GENERATED.  DO NOT EDIT IT BY HAND. ***  The source is
dass-handoff.db beside it, and dass-handoff.py is how you change it:

    dass-handoff.py list                      what is in here, by section
    dass-handoff.py show ID                   one entry in full
    dass-handoff.py search TEXT               find the entry to change
    dass-handoff.py set ID "new text"         replace it
    dass-handoff.py add --after=ID "text"     insert after an entry
    dass-handoff.py check                     has this file drifted?

Every command that changes an entry regenerates this file immediately, so the
two cannot drift apart -- but a hand edit here is invisible to the database and
the next command silently overwrites it.  Notes awaiting a documentation sync
live in dass-notes.db, managed by dass-notes.py, which is a different thing:
that is a queue for OTHER documents, and no longer for this one.

THE CORPUS PHASE IS COMPLETE.  Both corpora compile in full, and nothing in
sections 1 through 10 is blocking.  Sections 1 through 7 remain the working
knowledge a corpus run needs; section 8 records how the last failures were
resolved, and 9 what not to re-litigate.

THREE PHASES HAVE FOLLOWED IT.  Start from whichever you have been asked about
rather than reading forwards:

    12.  the DASS comparison -- our linked binary against the AP-101S memory
         dumps.  14407 of 14407 in-index HAL/S sections match.  In THIS file.
         Process detail is in compileLinkCompare.md and PFS/mafgenComparison.md.

    --   assembling the AP-101S sources with ASM101S.  In its OWN file,
         HANDOFF-ASM101S.md beside this one, because it is a separate job and
         reading this document to reach it costs four times the tokens.  The
         runtime library is finished and verified; FCOS is the open work.

    --   .dfg, which has not started and needs a preprocessor that does not
         exist.  See section 12's step 1.

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
12. DASS COMPARISON -- CURRENT STATE AND NEXT STEPS  (2026-08-07)
================================================================================

STATE (2026-08-08).  14407 of 14407 in-index sections match, 0 differ, 0 errors.
No section differs anywhere and no in-index section holds a single differing
halfword.  On the morning of 2026-08-07 this was 14379/14407 with 28 differing.
The individual reports now agree with that number as well, which they did not
before: see DONE 2026-08-08 below.

Three halfwords are suppressed on a JUDGEMENT rather than a measurement: the
.000001 literal in #DGO8ORB, #DGO3ENT and #DGO1ASC, where we hold ...ED8D and the
dump holds ...ED8C.  Ours is what truncation, round-to-nearest and the genuine
IHCFDXPI all give; no rounding mode of the exact decimal gives the dump's.  That
is a strong case, not a proof, and it is the first and only entry in
PFS/mafgen/defects.txt.  noclaim.py says so every time it reports.

Read the counts with the no-claim share, which run-configs.sh now prints after
every RESULT line: G2 0.87%, G8 1.02%, P9 1.21%, SSW 1.89%, G9 10.75%, S2
22.15%.  A perfect section count can rest on excusing a fifth of the halfwords in
those sections, and S2's does.

Process detail is in PFS/mafgenComparison.md, which was brought fully up to date
the same evening and is the document to read first.

DONE 2026-08-07.  Twenty-odd commits; the ones that changed results:

  - Foreign symbols decided per site from what the dump holds (c90e0f9f9), and
    NONHAL COMPOOLs recovered from the CSECT that supplies them (8857e5f3c,
    56512bd03).  Between them these fixed S2 outright.
  - Attribution from three new sources of evidence in dass-versions.py: lnk101's
    RLD at a resolved relocation (932f48219), MAFGEN's own resolved operand
    column (4ee23d41a), and the symbol named by an UNRESOLVED relocation
    (7cd211987).  These closed the SPSPSP family and G9's #PCSDMD1.
  - dass-literals.py splits a glued name at the '*' (9554cf34f), recovering
    I-LOADs whose variable name ends in a hex letter.
  - ibmFloat: `f = (long long)d` in place of `(long long)(d + 0.5)`, in
    XCOM-I/ibmFloat.c and both Python copies (4a4324b32).  A GENERAL defect --
    100% of odd mantissas corrupted -- and the reason our literal read ...ED8E.
    All eleven HAL/S-FC passes were rebuilt afterwards; editing the source is not
    enough, since XCOM-I copies ibmFloat.c into each *.build directory.
  - -2 exception marker: fcmcmp accepts any negative marker (upstream PR #33,
    MERGED 2026-08-08 as a21fda2), meanings declared in the exceptions file
    itself, and dass-versions.py emits entries from PFS/mafgen/defects.txt
    (868b387df).

DONE 2026-08-08.  The reports now agree with the score.

Auditing a report used to turn up failures the headline number denies.  G3's
DKFCM2 read "FAIL: 2/3 section(s) differ" while G3 scored 2905/2905, and both
were right: #DDKFCM2 and #CDKFCM2 are not in G3 at all, so fcmcmp compared them
against whatever G3 keeps at those addresses, while the scoring had already
excluded them.

fcmcmp now prints "N/A:" for such a section instead of FAIL, naming what the
memory really belongs to:

    N/A:  #DDKFCM2 @ 0B728 (15 halfwords) -- not in this configuration;
          this span belongs to #PCGZFLD

dass-syms.py supplies two fields for it.  "inConfig": false says only which pass
recovered the ADDRESS.  "spanOwner" names a DIFFERENT section, in this
configuration's own index, covering that address.  Both are required, and the
test runs AFTER the comparison has already found a difference.

THAT ORDERING IS THE WHOLE SAFETY PROPERTY, and it was arrived at by getting it
wrong twice in opposite directions:

  - Marking by absence from the scrape hides sections that are PRESENT.
    #PCDHMMU is absent from the scrape and genuinely there, 788 halfwords inside
    FCMBMTPG with 170 agreeing references.
  - Marking by provenance and skipping BEFORE comparing hides AGREEMENT.  A
    configuration can carry both a module's ZCON and the module, so across the
    eight configurations 79 marked sections MATCH the dump, 59 verifying content
    the --no-data patterns do not cover, up to 477 halfwords in SSW's #DDCDDG3.
    That rule would have silenced 36 of those, 28 with real content.

Testing only a failure, and only where the span has a named owner, cannot lose a
match however wrong the mark is.  SSW's #DDKFCM2 matches on an unclaimed span
while G3's sits inside #PCGZFLD -- same section, same address, opposite
meanings, which is why no static property of a name can decide it.

Verified by isolation, not assertion: all 439 G3 comparisons re-run with the
code held constant and only the table varying gave 2910 OK unchanged, 40
spurious FAILs reported as N/A, 15 FAILs unchanged, zero unintended
transitions.  Every one of the 231 suppressed failures across the eight
configurations has a named owner.  14407/14407 is unaffected -- none of the
marked sections was ever counted.

The verdict is spelled "N/A:" so it occupies the same 8-column field as "OK:"
and "FAIL:", keeping section names in one column, and so that it does not read
as an alarm.  dass-run.py spells N/A out separately in SECTION_RE, the slash not
being a word character, records it as verdict "not_in_config", and keeps it out
of both the run outcome and the run's section totals: counting it as differing
would contradict fcmcmp's own PASS and drop a matching unit out of the score,
while counting it as matching would claim something nobody checked.  Its n_diffs
is NULL rather than 0.

THE TRAILING SUMMARY USED TO BE SWALLOWED ON EXACTLY THE RUNS THAT NEEDED IT.
The "N section(s) differ but are not in this configuration" line sat BELOW
"raise typer.Exit(1)" in main(), so it printed only where nothing had failed.
That is backwards: an N/A section is most worth accounting for precisely when
something else in the same unit failed, because that is when the reader is
deciding what the failure means and needs to know which spans carry no claim.
Of the 2558 units, 137 reports contain at least one N/A section and 34 of those
also fail, so a quarter were losing it.  The summary now prints before the
verdict and all 137 carry it -- 103 to 137, exactly the 34.  No verdict moved:
every OK/FAIL/MISSING/N/A section line in all 2558 is byte-identical before and
after, and the exit status is unchanged.  The per-section "N/A:" lines were
never affected, being emitted inside compare() rather than main().

This went out as a FOLLOW-UP (PR #35), not as an amendment to the already
approved commit.  The wart predated the approval, and quietly changing reviewed
code because you happen to be in it is how a review stops meaning anything.

Augmented CSECT tables are now PUBLISHED, in PFS/mafgen/augmented-<CFG>.json for
all eight configurations, from the same two-pass procedure the sweep uses.
csects-<CFG>.json remains the unlinkMAFGEN2 scrape and is never rewritten:
folding recovered addresses back into it would make dass-syms.py's output its
own input and erase the line between what MAFGEN said and what we inferred.

THE NAME IS NOT COSMETIC.  dass-syms.py finds the other configurations by
globbing csects-*.json and taking whatever follows the prefix as a configuration
name, and its own default --out was csects-<config>-augmented.json.  Two such
files, csects-P9-augmented.json and csects-SSW-augmented.json, have sat in
PFS/mafgen since 2026-08-06, so every run since has seen ten configurations
rather than eight.  Measured before anything was changed, it altered nothing --
all eight augmented tables are byte-identical with and without them, the
phantoms only ever offering entries the real configurations already offered --
but a rule that happens to be harmless is not a rule.  A configuration name is
now capitals and digits throughout, never a hyphen, and the default --out is
augmented-<config>.json.  The two strays were left in place: superseded, now
ignored, and deleting published data is not a decision to take in passing.

NOT DONE, DELIBERATELY.  The marking is not extended to units a configuration
carries as ZCON-only -- GLUACC, GH2RTL, GRWIMU, ASLTMC, DXRDMM, DPDSPC and
DSPSPC in G3.  Their sections get placeholder addresses, six of them landing on
00140 in G3 which belongs to FCMPSA, and still report FAIL.  They are the same
disease, and each has a named owner available, so closing it would be easy.  The
user's decision on 2026-08-08 was to leave it until an actual unwanted effect is
observed.  Reducing a FAIL count from 15 to 1 is not the point; a non-zero FAIL
count is the disturbing thing either way, so do not re-propose this on the
grounds that it lowers a number.

VERIFIED ACROSS ALL EIGHT, and the evidence is kept as a matched TRIO:

    ~/ForClaude/baseline-preNOTINDEX/          the logs immediately BEFORE
    ~/ForClaude/verify-NA-2026-08-08/          the change in ISOLATION
    ~/ForClaude/verify-NA-postPR33-2026-08-08/ the change AS MERGED

Keep all three; no one of them proves anything alone.  This change makes fcmcmp
SUPPRESS output, and suppression is how real data goes missing quietly, so the
claim that it removes only noise is worth nothing unless every verdict is
compared before and after.  Comparing each against the baseline gives:

                        in isolation    as merged
    OK   -> OK             14551          14554
    FAIL -> N/A              231            231
    FAIL -> FAIL             115            115
    OK   -> FAIL               3              0

    unintended                 3              0

The three were #DGO8ORB @07F5B, #DGO3ENT @0AFC8 and #DGO1ASC @0B73C, one
halfword each, ED8D vs ED8C -- exactly the three entries of
PFS/mafgen/defects.txt.  They went unsuppressed because the fcmcmp used
(71c07a3, PR #34) did not yet contain fcmcmp-markers (PR #33), so a -2 was
treated as a checked value that never matches.  That diagnosis was written down
as a PREDICTION -- "they resolve when #33 lands" -- and #33 landed, the branch
was rebased onto it, and all three resolved.  The +3 in OK -> OK is exactly
them.  Confirmed independently beforehand by a control run against a CSECT table
with no inConfig fields at all, which failed identically.

THE TWO UNCHANGED ROWS ARE THE LOAD-BEARING PART of the merged column.  Rebasing
onto a master that had also absorbed #31 and #32 preserved every one of the 231
intended suppressions and introduced no new failure; had the rebase gone wrong,
those totals are where it would have shown.

The 115 are the ZCON-only units described just above, which are excluded from
the score and were left alone deliberately.

A FULL SWEEP IS NOT NEEDED to redo this.  fcmcmp needs only the .fcm and .json
the last sweep already left in <CFG>work3, so re-running the comparison alone
took 99 seconds for all 2558 units against roughly four hours for a sweep --
compilation and linking dominate, and neither is involved.
verify-NA-2026-08-08/rerun-fcmcmp-only.sh does it (self-contained, and tested to
regenerate byte-identical logs), and compare-against-baseline.py redoes the
comparison.  The real sweep logs in <CFG>logs/ were NOT overwritten.

One trap those directories will spring on anyone who returns to them: EVERY
fcmcmp log begins with its commit hash, date and source hash, so a plain diff of
two logs is never empty even when nothing changed.  Compare verdicts, not files.

A SECOND TRAP, since fixed but worth knowing about.  fcmcmp's --repro defaults to
TRUE and writes <stem>.fcmcmp.repro.json into the CURRENT directory, so a full
re-run dropped 1106 files into modules/sdfpkg before anyone noticed.  --no-repro
is NOT the fix: the commit/date/source-hash banner just described, the thing that
makes each log self-identifying, is printed under the same flag.  The script now
gives each configuration its own scratch cwd under $OUT/.repro/$C and removes it
at the end.  Per-configuration matters: unit names are unique within a
configuration but REPEAT across them, so one shared scratch directory would have
had six parallel workers writing a single path -- the same
shared-fixed-filename-under-parallelism shape as the HALSFC job-tree collision
described in step 3 below, benign here only because nothing reads these files.
Verified on P9: no stray files, scratch removed, all 158 logs produced, every
verdict line byte-identical to the recorded run.

INFRASTRUCTURE, and the traps that produced it:

  - dass-compare.db is opened WAL with a two-minute busy timeout (3b95729f9).
    Under the default rollback journal a writer blocks every reader and the
    5-second default is easily exceeded; P9's entire sweep once produced nothing
    and the only sign was a missing RESULT line.  run-configs.sh now shouts if a
    configuration produces no RESULT.
  - A timed-out compile has its whole process group killed (766cf06a9).  Six
    orphans once accumulated, each spinning on a full core, two for over three
    hours -- and worse than the waste, an orphan keeps writing halmat.bin into a
    job tree that has already been handed to another compile.
  - ~/ForClaude/stop-sweep.sh kills a sweep completely and proves it.  NEVER
    verify a kill with `ps | grep` on this machine: grep is rewritten to `rtk
    grep` and returns nothing, which reported "0 remaining, clean" three times
    while six orphans were running.  pgrep tells the truth.
  - ELAPSED TIME IS NOT WORKING TIME.  G16 once showed 304.7 minutes against
    43.8 in the previous run while G8 and G3 in that same run were normal.  Every
    direct measurement pointed away from a code cause -- compile times normal at a
    3.7s median, nothing hung, the watchdog empty, no strays, memory and disk
    fine, load steady -- and the conclusion drawn anyway was "roughly four hours
    in dass-syms and dass-versions".  The machine had been asleep: journalctl
    shows suspend at 01:04:57 and resume at 05:38:54, 4h34m, leaving about 41
    minutes of real work.  Check `journalctl | grep -i suspend` BEFORE theorising
    about a slow step.  The invariant worth keeping: for a sweep, elapsed
    wall-clock should be close to accumulated compile time divided by the job
    count, and when it is not, suspect the clock before the code.  All six stage
    banners now carry $(date -Is), which would have shown the gap immediately.

  - JOB TREES ARE LOCKED ACROSS PROCESSES, not merely across threads.  Each
    compile flocks its tree for its whole duration, so two sweeps take turns
    rather than rewriting each other's fixed-name files.  See step 3 below for
    what that cost before it existed.  The general lesson: an in-process pool,
    mutex or queue guarantees nothing about a second copy of the same program,
    and every one of these scripts can be run twice at once.
  - ~/ForClaude/hang-watch.sh captures /proc/PID/cwd and /proc/PID/fd for any
    pass running over ten minutes.  run-configs.sh now ARMS IT AT THE START OF
    EVERY SWEEP -- the only time it can catch anything -- and hang-watch.sh
    takes an flock, so arming it repeatedly exits 0 and leaves exactly one
    running.  The sweep does not stop it afterwards: it is read-only, kills
    nothing, and costs about two seconds of CPU a day.  It was previously
    started by hand, which meant it died at the first reboot while this document
    went on asserting it was armed -- a claim with a lifetime.  Expecting a
    person to remember a step is how the step gets forgotten; put it in whatever
    needs it.
  - PROCESS CHECKS LIE IN TWO DIFFERENT WAYS ON THIS MACHINE, and both have
    produced confidently wrong answers.  `ps | grep` returns nothing, as above.
    And `pgrep -f PATTERN` matches the shell running the check whenever the
    pattern appears in its own command line -- filtering $$ is NOT enough,
    because command-substitution subshells inherit that command line too.  The
    reliable form is `pgrep -x -f "<exact full command line>"`, which a long
    shell invocation cannot equal.  Both traps cost a wrong conclusion on
    2026-08-08 alone.
  - A KILLED COMMAND LOSES ALL ITS PIPED OUTPUT, not some of it.  Writing to a
    pipe is block-buffered rather than line-buffered, so a timeout, a Ctrl-C or
    an os._exit() discards the whole buffer: measured here, a program printing
    every 0.3s and killed at 2s delivered ZERO lines through a pipe, where the
    same program on a terminal had shown six.  This is why dass-run.py sets
    PYTHONUNBUFFERED=1 on its children -- compileLinkCompare's failure paths end
    in os._exit() -- and the same applies to anything WE run and then read:

        python3 -u ...            for Python; no side effects, always correct
        PYTHONUNBUFFERED=1        same, for a whole subtree of Python children
        unbuffer CMD              /usr/bin/unbuffer, for non-Python commands
        stdbuf -oL CMD            DOES NOT WORK for Python; libc stdio only

    stdbuf is the trap of the three: it reads as the general answer and does
    nothing for a program that buffers above libc, which Python does.

    unbuffer's cost is that it runs the command under a pty, so anything that
    adapts to a terminal changes shape -- `unbuffer ls --color=auto` emits ANSI
    escapes and switches to multi-column, which will corrupt whatever parses it.
    Force the non-terminal form alongside it: --color=never, ls -1,
    git --no-pager.  It does preserve exit status and does NOT convert line
    endings to CRLF, both of which were checked.

    The reason this matters and is easy to miss: the commands worth reading are
    the slow ones, and the slow ones are exactly the ones that get killed.  A
    silent empty result then reads as "it produced nothing" rather than "its
    output was thrown away".
  - PFS carries runnable copies of dass-*.py and mafgen/defects.txt so
    mafgenComparison.md can be followed from there.  The generated
    exceptions-*.txt are NOT tracked -- they are derivable from the listings
    already present.

NEXT STEPS, in order.

  1. THE NEXT PHASES.  .dfg is still blocked and still set aside by the user on
     2026-08-07: it needs a preprocessor to convert to .hal, which does not
     exist.  The .dfg files themselves are in PFS/<VER>/SSSRC alongside the
     assembly, 17 of them in OI340600.

     .asm IS NO LONGER BLOCKED, and the reason it was thought to be was wrong.
     This used to read "needs changes to ASM101S that are under way elsewhere",
     meaning Don's -- but he has not touched virtualagc/ASM101S since
     2026-04-29, and what he has been building is a separate assembler in his
     own repository that cannot be merged back.  The user's decision on
     2026-08-08 was to advance our own ASM101S instead.  That phase has its own
     handoff, HANDOFF-ASM101S.md beside this file: the runtime library is
     finished and verified, FCOS is in PFS/<VER>/SSSRC, and most of what stands
     between us and it is one defect in macro keyword-parameter handling.

  2. WHEN THE CROSS-CHECK IS FINALLY COMPLETE -- meaning after .dfg and .asm, not
     now -- weed ~/ForClaude of obsolete material, chiefly sweeps too old to
     matter, and compress what remains into one archive.  Decide then whether the
     exceptions-*-full.txt files are worth keeping: they are ~2.6 MB across the
     eight, S2's alone 1.5 MB and 46295 lines, and every sweep regenerates them
     from the plain files plus HALSTAT, so they are derived output rather than
     evidence.  The plain exceptions-<CFG>.txt are also derived, from listings
     that are themselves in mafgen/, which is why neither is tracked.

     THREE DIRECTORIES MUST SURVIVE THAT WEEDING: baseline-preNOTINDEX/,
     verify-NA-2026-08-08/ and verify-NA-postPR33-2026-08-08/, 32 MB together.
     They look like old sweep output and are not -- they are the before, the
     change in isolation and the change as merged, for the N/A change, and no one
     of them means anything without the others.  Anything else in ~/ForClaude
     that turns out to be evidence rather than output should be labelled the same
     way before that step, since by then the distinction will not be obvious.

  3. THE INTERMITTENT HALSFC HANG IS EXPLAINED AND FIXED (2026-08-08).  Six
     occurred on 2026-08-07, on six different files, each once, and none before
     or since.  The user identified the mechanism: SWEEPS WERE SHARING JOB
     TREES.  There are four, ~/ForClaude/jobs/1..4, and every sweep computes the
     same list from the same hard-coded root, so the six sweeps running that
     afternoon put 24 compiles through 4 directories.  HALSFC writes halmat.bin,
     litfile.bin and COMMON*.out into its working directory under FIXED names,
     so they were rewriting each other's files mid-read.

     dass-run.py's treePool existed to prevent exactly this, and its comment
     insists exclusion must be "by possession, not by arithmetic" -- but
     possession was a queue.Queue inside ONE interpreter, and the guard beneath
     it ("--jobs=N but only M tree(s); two compiles would share a directory and
     corrupt each other") checks only its own arithmetic.  All six sweeps passed
     it and then collided.  A lock that protects against your own threads and no
     one else's is the shape of bug to look for elsewhere in this tooling.

     Each tree is now flock'd for the whole compile, which every process can
     see, so concurrent sweeps take turns instead of corrupting each other, and
     run-configs.sh says so when it finds another sweep running.  Verified by
     two processes contending -- the second acquired the instant the first
     released -- and by a real compile through the locked path.

     This also accounts for the detail that no overload theory could: a process
     that had already reported success and went on spinning for an hour.
     Contention makes things slow; it does not do that.  Having your input
     replaced underneath you does.

     NO RESULT WAS AFFECTED, checked rather than assumed.  Every one of the 2558
     scored runs is match or differ -- none compare_failed, none timed out --
     and all fall between 19:34 and 06:00, inside the two sessions that ran
     alone, both of which re-ran the full six-stage pipeline per configuration.
     The slowest compile anywhere is 36.7s against 3600s for a hang.  And a
     corrupted compile that still reported success would have had to emit code
     matching the AP-101S dump exactly to escape notice.

     BEWARE ONE PIECE OF ARITHMETIC THAT LOOKED LIKE EVIDENCE.  A first pass at
     this counted concurrent sweeps as +1 per "started" and -1 per "all done" in
     run-configs.log, and produced a tidy dose-response table.  It was wrong: 9
     sessions started and only 4 printed "all done", the other five having been
     killed, so the counter never came down.  What survives is that all six
     hangs fall in the 12:44-18:56 pile-up and the two later solo sessions had
     none.  The mechanism is established from the code, not from that table.

  4. UPSTREAM, as of 2026-08-08.  PRs #31, #32 and #33 are MERGED at
     ColanderCombo/nsts-sdl-dps.  Two remain open and both are MERGEABLE/CLEAN,
     waiting only on Don: #34, the N/A verdict, approved "lgtm"; and #35, the
     summary-ordering follow-up described above, stacked on #34.  Nothing of ours
     is open and blocked.

     The #33/#34 interaction that used to look like a bug is GONE, and how it
     went is worth keeping.  #34 did not contain #33, so on #34's branch alone a
     -2 exception was not understood and three units reported one differing
     halfword each.  #33 merging turned #34 CONFLICTING, and the rebase both
     resolved that and absorbed #33, after which the three resolved exactly as
     predicted.

     THE REBASE HAD ONE REAL TRAP IN IT, of a kind that will recur.  Master's
     size_mismatches (from #32) and our skipped (from #34) are two DIFFERENT
     lists that happen to be declared, appended and returned at the same three
     places, so all three conflicts read as one variable renamed.  They are not,
     and resolving them as a rename would have silently deleted a feature while
     leaving code that compiles and runs.  Checking the merge base settled it in
     a minute; the resolution keeps both, and compare() returns four values now
     rather than three.  Expect this shape again -- Don reworks our PRs on merge
     (#32 became ce12d33, dropping --strict-sizes and making a size mismatch
     always fail), so our branches and his master drift in the same regions.

     ONE PROCESS LESSON, from a mistake made here.  A comment on #34 recorded the
     rebase and the re-verification, and buried in its last paragraph an offer to
     fix the ordering wart here or in a follow-up.  The user's objection was
     immediate and correct: the natural action, merging an approved PR, would
     have silently answered a question the reviewer never saw.  An offer in the
     fourth paragraph of a long comment is not an offer.  The remedy was not to
     word it better but to remove the question -- a correction comment retracting
     it, and the fix sent as its own PR -- so that the default action became
     simply correct.

     Don already consumes our CSECT tables -- tools/retest_open_issues.sh is his
     own commit, bb4e26c of 2026-07-25, passing ../csects-G9.json to BOTH
     lnk101 --external-syms and fcmcmp --csect-table -- and lnk101 CONSUMES a
     csect table (linker.py:2142), it never produces one.  So #34 needs no
     workflow change at his end, only a table carrying the two fields, which the
     scrape does not.  The PR says so in an italicised note at the top, because
     the one-word substitution to augmented-<CFG>.json is otherwise easy to miss
     and the failure mode is merging it and seeing nothing happen.

SCOPE, so the numbers above are not misread.  The HAL/S phase is 3212 of the 3859
CSECTs in the indices; the rest are assembly and HAL/S runtime library routines.
Reaching 14407/14407 finishes one phase of three, not the comparison.  Both
remaining phases are blocked as described in step 1.
