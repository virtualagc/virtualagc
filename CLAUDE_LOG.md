# Documentation staging log

Timestamped notes staged for other documents accumulate here between
documentation syncs.  Format:

    ### [YYYY-MM-DD] Target: [Target_Filename.md]
    - Brief, high-density update note

Applied and cleared 2026-09-28.

### [2026-09-29] Target: yaShuttle/yaGPC2/tools.md, problems.md, debugger-planner.md
- test/run_all.sh, compare.sh, compare_stdin.sh, run_matrix.sh DELETED (0f90c0dcc): they compared frozen gpc (node) to old yaGPC, never yaGPC2. make test no longer needs node or yaGPC. Remove/annotate references in these docs. (Stale mentions also remain in comments: src/iop.h:81, hal-runtime-features.py:64/596, test/fixtures/build_hal_fixtures.sh:29, test/test_debugger.sh:3.)
