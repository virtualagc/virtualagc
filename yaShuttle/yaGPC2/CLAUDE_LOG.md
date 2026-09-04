# CLAUDE_LOG.md

(Cleared 2026-09-04 by Full Documentation Sync.  Thirty-two entries applied to
`problems.md` (8087 → 8432) and `HANDOFF-FCMBOOT.md` (1506 → 1607).  They were
one continuous story — the hunt for why the phase-8 overlay transfer is refused,
the discovery that the descriptors were never a reverse-engineering problem, and
the OI340700 object build that followed — so they were told as such rather than
filed as thirty-two dated notes.  Several entries retracted earlier ones on the
same day; the retractions are integrated where the claim lives, not appended.

- **`problems.md`**: three new sections.  **§8.36** the bisection — what it
  established (the loader does not verify checksums; block count is not the
  discriminator; no single descriptor is at fault, block 10 is necessary and
  provably-correct block 6 is its partner) and the four hypotheses measurement
  refuted, kept so they are not re-run.  **§8.37** the reframing: `mmu2mmv`'s own
  docstring says `derive_load_blocks(lib, …)` returns the partition, so phase 8's
  descriptors are a function of `PHASE08.lib`; the stamped GPT and the tape's
  data therefore came from different builds.  With it, the two beliefs that had
  to go first — the tape is our own build, not a recovered artifact, and CON80
  does record phase membership — and what the FCMs can and cannot audit (4.8% of
  tape blocks are in no FCM at all, GPCIPL among them).  **§8.38** the OI340700
  object build: use our tools and know which are ours, the zero-length tombstone
  as the overlay's missing "remove" verb, and the residue tracing to one root
  cause.  Plus five new method failures in **§8.10**, of which the sharpest are
  "do not log a hypothesis as a finding before you test it" and "elimination
  across a set is valid only if the property is additive".

- **`HANDOFF-FCMBOOT.md`**: the phase-8 open item rewritten around §8.37 with an
  explicit "do not resume that line", Don's `#DLY` timing note flagged as the
  thing to wait for, a new CON80 reference subsection (the deck hierarchy, the
  three DD names and what they resolve to now, where the runtime sources really
  are), and traps 33–35 — running builds in Don's repo, foreground `sleep`
  killing a detached launch, and `halsc` supplying one global CARDTYPE where
  `halsParms` has a per-file table.

The OI340700 build's own state and recipe live in `HANDOFF-OI340700-BUILD.md`,
written yesterday and not duplicated here.)
