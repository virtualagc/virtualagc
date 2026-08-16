# CLAUDE_LOG.md

(Cleared 2026-08-16 by Full Documentation Sync. The pending 2026-07-31 entry,
on the `yaGpcIntegration.h` contract, was DISCARDED as overtaken rather than
applied — at the user's direction, after checking it against the tree.)

Why it was overtaken, recorded so the decision is auditable rather than a
silent deletion:

- It named `src/yaGpcIntegration.h` and `src/yaGpcOps.h`. Neither exists. The
  contract header was promoted to a shared `yaShuttle/yaGpcIntegration/`,
  reached by `-I../../yaGpcIntegration` from both projects' makefiles, and
  `yaGpcOps.h` is gone entirely — `src/yaGpcOps.c` now includes the shared
  header directly. `tests/run_gpc_smoke.sh` has moved to `src/tests/`.
- Two of its three "still open" items are closed in the contract as it now
  stands. `GpcReleaseFn` is the teardown hook it said was missing, and it
  flushes output still buffered without a terminating newline.
  `GpcDebuggerStateCreateFn` and `GpcDebuggerStateDestroyFn` are contract
  members now, not the out-of-band functions the entry described.

ONE ITEM SURVIVED THE CHECK and is noted here so discarding the entry does not
lose it: `GpcInitializerFn` still has no error-message channel. Its signature
takes `state, programPath, symbolsPath, servicer, servicerCtx, output, input,
ioCtx` and nothing for diagnostics, so an initializer that fails still has
nowhere to say why except `fprintf(stderr, ...)`.

The parts of the entry that were real work — `yaGpcOps.c`, the
`debug_run_init()`/`debug_run_command()` split behind `debugger_state_t`, and
the two-instance independence smoke test — are in the code and its tests, which
is where they belong; they needed no prose to survive.
