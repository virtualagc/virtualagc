# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Target_Filename.md]

### [2026-11-13] Target: yaShuttle/discretePanel/textures/LICENSE.md
- Owner decision: sites/ksc (119 MB) goes in portview-essential.7z (pack_archives.py now does it by default; the --ksc-essential flag is gone). Essential archive = 215 MB unpacked (~190 MB packed est.), optional = 1037 MB unpacked. LICENSE.md's archive table lists sites/* under optional: move `sites/ksc/` to the essential row, and in the "In portview-optional.7z unless noted" table mark the ksc row (essential archive). portview --check's optional list now tests sites/zza for "the other sites' imagery".
