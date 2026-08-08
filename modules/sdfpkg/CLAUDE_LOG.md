# This log has moved into a database.

Notes now live in `dass-notes.db` beside this file, managed by `dass-notes.py`.
Do not append here: an entry written below would not be seen by a sync.

    dass-notes.py add --target=FILE.md "text"    capture a note
    dass-notes.py pending [--target=FILE.md]     what a sync must apply
    dass-notes.py done N [N ...]                 mark applied
    dass-notes.py supersede NEWER OLDER          NEWER replaces OLDER
    dass-notes.py render [--pending]             the whole queue as Markdown

Why it moved, from the day that prompted it.  Three costs grew with the flat
file.  A sync meant reading the entire log plus every target document -- 96 KB of
log on one occasion -- and sorting entries by target by hand.  "Which of these
did I already apply?" had no answer except re-reading.  And entries that
SUPERSEDED earlier ones were the real hazard: on 2026-08-07 the SPSPSP analysis
was rewritten twice and an SDF finding reversed outright, so applying that log in
order would have written three contradictory accounts into one document.  Catching
it depended on remembering.  `pending` now excludes superseded entries, while
`render` still shows them with the relationship marked, so nothing is lost.

The documents remain the product.  This replaces the staging queue, which was
never prose.  Run `dass-notes.py render` whenever you want it back as Markdown.

The four entries that were here on 2026-08-08 were imported and are still
pending; the import was verified character-for-character before this file was
replaced.
