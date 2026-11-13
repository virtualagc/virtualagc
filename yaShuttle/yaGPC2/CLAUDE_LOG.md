# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Target_Filename.md]

### [2026-11-13] Target: yaShuttle/discretePanel/textures/LICENSE.md
- Owner decision: sites/ksc (119 MB) goes in portview-essential.7z (pack_archives.py now does it by default; the --ksc-essential flag is gone). Essential archive = 215 MB unpacked (~190 MB packed est.), optional = 1037 MB unpacked. LICENSE.md's archive table lists sites/* under optional: move `sites/ksc/` to the essential row, and in the "In portview-optional.7z unless noted" table mark the ksc row (essential archive). portview --check's optional list now tests sites/zza for "the other sites' imagery".
### [2026-11-13] Target: yaShuttle/discretePanel/PORTVIEW_PLAN.md
- portview --star-core F (default 1.0) and --star-gain G (default 1.0): the faintest stars' core radius in pixels (uCore = F x devicePixelRatio; a star's total light kept by 4/(F+1)^2) and a brightness multiplier. The defaults are made for 4K; owner chose --star-core 0.1 --star-gain 0.7 for a 1920x1080 screen (sharp, a few more stars than the default; gain 0.5 matches the default's star count: 2003 vs 1942 local maxima on the --test lvlh sky at --size 192). Defaults deliberately unchanged. Memory measured on the owner's 2 GB NVIDIA (nvidia-smi, 4 views): 4K/200%/--size 384 reduced 1517 MiB (desktop 766); 1080p/100%/--size 384 1121 (383); 1080p/--size 192 878 (356); full textures at 1080p/192 1826. portview's own cost depends on --size, not on the desktop scaling; a view's buffers are shared, extra views ~70 MiB at 384, ~20 at 192.
### [2026-11-13] Target: yaShuttle/yaGPC2/PHASES.md
- W7: the wizard's "return" scenario (fly_return.py --from COAST on T1, rate 3, started through flightwizard.py) ran SEP3 -> ORBIT and ended `done`: PASS orbiter error 1.09 ft, attitude 0.074 deg, vs AB30's 1.28 ft / 0.098 deg. Scenario committed and pushed to origin master (Python only).
### [2026-11-13] Target: yaShuttle/yaGPC2/PHASES.md
- W8: the wizard's "undock" scenario (T1, rate 3, no portview, 1 CRT) reached SEP3 and `done`; SEP3 range 2708 ft vs AB28's 2840, same burn timeline. Note in ~/sts134-runs/singletape/W8-wizard-undock/RUN-NOTE.txt.
### [2026-11-13] Target: yaShuttle/yaGPC2/PHASES.md
- W9: the wizard's "landing" scenario (T1, rate 3) flew OPS 301 to wheels stopped and `done`; stop t=4184 s vs AB29 4180, chute armed 190 vs 191 KGS. With W7 (return) and W8 (undock) all three wizard scenarios added this session are verified end to end.
