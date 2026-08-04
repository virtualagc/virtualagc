================================================================================
HANDOFF -- PASS corpus compilation, 2026-08-04
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

    OI340600    974 / 974      MET.  Zero failures, run complete.
    OI301700    984 / 991      7 failures, which are 4 roots and 3 cascades:
                               GKEKIP waits on GKGMNV; GM2MAJ and GMAMIN wait
                               on GMGMAJ.  SULUPLIN repaired again since.

For scale, OI340600 began the previous session at 843/907.

*** CHECK THAT A RUN FINISHED. ***  `successful == attempts` is meaningless on
a run that stopped early, and compilePASS's summary does not say that it did.
The test is a "Done." line at the end of compilePASS.log:

    grep -c 'Done\.' compilePASS.log        # 1 = complete, 0 = aborted

An OI301700 run was reported as 935/939 when it had in fact stopped at file
1030 of 1266; the 236 files after it were never compiled.  That is fixed (a
PASS2 error is now delayable, see §6) but the habit is worth keeping.

Coverage is a separate question from the goal.  Of files that are neither
compiled nor "Not part of PASS", OI340600 leaves 156 and OI301700 183 never
attempted at all -- their dependencies were never satisfiable.  Nobody has
looked at why.  The accounting closes exactly:

    OI340600   974 attempted + 156 not attempted +  37 not in PASS = 1167
    OI301700   986 attempted + 183 not attempted +  97 not in PASS = 1266

--------------------------------------------------------------------------------
2.  WHERE EVERYTHING IS
--------------------------------------------------------------------------------
TWO SEPARATE GIT REPOSITORIES.  `git` run from inside the virtualagc checkout
against a PFS path reports "outside repository", which reads as "not version
controlled" and is wrong.  cd into the PFS tree first.

  /mnt/STORAGE/home/rburkey/git/virtualagc        compiler, compilePASS, HALSFC
  /mnt/STORAGE/home/rburkey/workspace/PFS         PASS source, branch master

Inside ~/workspace/PFS:

  OI340600/, OI301700/                 the masters.  Committable.  OI340600's
                                       source is genuine punch cards; OI301700's
                                       was extracted from listings (§4).
  OI340600-sdftest/, OI301700-sdftest/ the corpus work directories.  Untracked
                                       build output -- keep out of commits.
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

*** TRAP ***  The -sdftest directories hold their own COPIES of APPLSRC,
SSSRC and INCL80.  Editing a master does NOT affect a run.  rsync first:

    for v in OI340600 OI301700; do
      for d in APPLSRC SSSRC INCL80; do
        [ -d ~/workspace/PFS/$v/$d ] &&
          rsync -a --delete ~/workspace/PFS/$v/$d/ ~/workspace/PFS/$v-sdftest/$d/
      done
    done

--------------------------------------------------------------------------------
3.  HOW TO RUN A CORPUS
--------------------------------------------------------------------------------
corpus-run.sh does all of it:

    ./corpus-run.sh ~/workspace/PFS/OI340600-sdftest TAG

TAG names the archives of the previous run so nothing is lost.  Classify with

    python3 corpus-classify.py ~/workspace/PFS/OI340600-sdftest/compilePASS.log

Do NOT count failures by grepping ": Compiling" against "Compilation
successful": the log carries two phase headers that inflate the count.

Both corpora can run at once, but STAGGER THEM by a couple of minutes.  Two
launched in the same second once aborted together on the first file, with the
PASS1 cross-comparison differing and litfile.bin vanishing mid-run.  It did not
reproduce, and the mechanism was never found -- it is NOT the shared
yaShuttle/ported directory, whose files are untouched during a run.

corpus-run.sh now passes --extra-parms=TABLST, so PASS4 parses each SDF the run
has written rather than merely opening it, making the corpus a test of PASS4
and SDFPKG too.  It costs report size and some time.

--------------------------------------------------------------------------------
4.  THE EXTRACTOR IS THE ROOT OF EVERY OI301700 ARTIFACT
--------------------------------------------------------------------------------
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
The eight OI301700 failures not yet repaired, from the last complete run:

  PMQTEC   FT101, "DATA TYPE CONFLICT ON PARAMETER #1".  TWO files now, on
  SULUPLIN the very same call:  PMP_SL_PRB(HEX'0003', ...) at PMQTEC statement
           116 and PMP_SL_PRB(HEX'0001', ...) at SULUPLIN statement 884.  Both
           versions declare that parameter INTEGER, and the original listing
           carries NO error underline at PMQTEC's statement, so the original
           build accepted a hex literal there.  PASS2's XPL *is* the original,
           so the difference has to be in the type our compiler gives the
           literal, or in what the template/SDF records about the parameter.
           Compiling without --sdfi is NOT a valid control: it fails earlier,
           with DI11, because templates lack the transitive includes.  The next
           step is to compare what the SDF and the template each say about
           PMP_SL_PRB's parameter 1 against what CHECK_ASSIGN_PARM expects.
           PMQTEC is also the file that used to abort the whole run.
  GMGMAJ   XD7, "DEFINE SEQUENCE IS EMPTY".  "D DEFINE GM6CLC NOLIST" and its
  GMESTA   CLOSE have nothing between them, because NOLIST prints nothing in
           the listing.  OI-34.06 has the content, at the same SRNs.  Four such
           sequences in these two files.  Borrowing it would splice OI-34.06
           code INSIDE an OI-30.17 module, which is more invasive than the
           INCL80 borrowing and is the user's call.
  GKGMNV   DU1, undeclared GK3_ORB_TGT and CGGV_THR_VEC_ROLL_ANG_COS.
  GKEKIP   XI3 cascades -- a needed template's provider failed.  These should
  GM2MAJ   clear themselves as their providers are fixed; SGCKIP's XI3 was for
  GMAMIN   @@SAFACQ and is already fixed.
  SGCKIP   DI11, and an XI3 for @@SAFACQ.

Repaired since that run and awaiting confirmation: SAFACQ, SPNINT, SPCPPC,
PGHHEA, PGGPCF (all verified to compile individually).

Also open:
  - The 156 and 183 files never attempted (§1).  Nobody has looked at why.
  - The concurrent-run abort (§3), mechanism unknown.
  - PASS4's DATABUF statistics were never checked against a known-good value;
    modules/sdfpkg/pass4-*.rpt from 2026-08-03 are a good baseline.

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
