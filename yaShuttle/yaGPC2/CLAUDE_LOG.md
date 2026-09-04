# CLAUDE_LOG.md

(Cleared 2026-09-04 by Full Documentation Sync.  Four entries applied, all to
`problems.md` (8432 → 8612).  They were one continuous story — the OI340700
source reconstructions — so they were told as such rather than filed as four
dated notes, and the first entry's "NOT ATTEMPTED: writing those
reconstructions" is superseded by the three that follow it rather than
preserved alongside them.

- **`problems.md` §8.38**, four new subsections.  **The conditional the source
  already contained**: `CPUSLS` and `CPTOSV` are fixed by four characters each,
  all in column 1, because the `F`-card conditionals are comments in those
  modules and the source already ships both branches — with the dump's eight
  null pointers agreeing rather than merely permitting.  **Reading the payload
  indexes out of the dump**: the three-step method for `CS2IX2`–`CS2IX7` and
  `CS2IXP`, and the three traps in it (the `_FDA`/`_LIM` exclusion, `0000`
  being a real null rather than `CSAS_PDT_DUMMY`, and the grouping comments
  being unrecoverable).  **Two further shapes**: `CS2PX2` and `CS2PCT`, why
  eleven "unresolved" pointers were never broken, and the 191-of-196 identical
  reproduction that validates the whole method.  **`dass-ixgen.py`**: where the
  tool lives and the three self-checks built into it.  The existing "residue is
  one root cause" subsection was updated to say which eleven files are now
  done, which four remain, and — explicitly — not to quote its "22 missing"
  figure as though it accounted for the new work.

- **`problems.md` §8.10**, two method failures.  `pgrep -f` matching the
  shell that runs it, and the worse compounding error of reading the process
  table instead of the log the job had already written; and displaying "the
  first match" as though it were the match the analysis actually found.)
