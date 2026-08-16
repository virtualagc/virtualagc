/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   version.h
 * Purpose:    Which version of ASM101S.py this program is a port of.
 * Contact:    info@sandroid.org
 *
 * THIS IS THE ONE PLACE THE PROVENANCE IS WRITTEN DOWN.  `--version` prints it,
 * `--help` names it, and the header comment of asm101s.c points here rather
 * than repeating it.  Update it as part of every parity pass, in the same
 * commit as the code it describes.
 *
 * IT IS DELIBERATELY NOT DERIVED FROM THE REPOSITORY AT BUILD TIME.  Asking
 * git for HEAD would make this claim parity with whatever happened to be
 * checked out when someone typed `make`, which is a statement nobody has
 * checked and which would be wrong more often than right -- the assembler is
 * under active development, and a build taken during a repair would announce a
 * commit whose changes are not in this program at all.  Worse, it would be
 * confidently wrong: the failure mode that prompted this file was a
 * differential sweep run while expressions.py was being edited underneath it,
 * reported as a single clean measurement when half of it was against different
 * code.  A hand-maintained constant is wrong only when someone forgets to
 * update it, and then it is wrong in the safe direction -- claiming less than
 * is true rather than more.
 *
 * THE PARITY LINE IS PART OF THE ANSWER, not a footnote to it.  A bare
 * hashcode implies "this is that version", and while any commit is missing
 * that implication is false.  Say so in the output rather than leaving the
 * reader to infer it.
 */

#ifndef ASM101SA_VERSION_H
#define ASM101SA_VERSION_H

/*
 * The commit this program was ported from, in github.com/virtualagc/virtualagc.
 * This is the most recent commit to touch ASM101S/ at all; the repository was
 * at dc5b97707 when the parity pass was made, and the four commits between the
 * two changed nothing under ASM101S/.  Naming the last commit that actually
 * altered the assembler, rather than whatever HEAD happened to be, is what
 * makes the claim checkable with a single `git diff'.
 */
#define PORTED_FROM_COMMIT "105ad9afb"
#define PORTED_FROM_DATE "2026-08-15 21:18:29"
#define PORTED_FROM_SUBJECT                                                   \
  "ASM101S: a bare END names no entry point, so do not invent one"

/*
 * Changes carried over individually since that commit.  Undefined when there
 * are none, which is the state to aim for and the state we are in:  a port
 * that is exactly one commit is far easier to reason about than one that is a
 * commit plus a list.  Define it as a string if that ever stops being true.
 *
 *   #define PORTED_EXTRAS "abcdef123 (foo.py only) -- what it does"
 */

/*
 * Whether everything up to that commit is present.  Undefined means complete;
 * define it as a string to print a warning, and say what is missing.
 *
 *   #define PARITY_INCOMPLETE "commits after abcdef123 are NOT included"
 */

#endif /* ASM101SA_VERSION_H */
