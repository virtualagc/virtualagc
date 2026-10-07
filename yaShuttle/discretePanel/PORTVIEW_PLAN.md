# portview.py — implementation plan

Out-the-window views from the Orbiter, driven by yaGPC2's vehicle dynamics.
Requirements are in `PortviewThoughts.md`; this is the plan that answers them.
Status: plan only, nothing implemented.

## Data in

Agreed with PASS-IDLE 2026-10-07.

- **Orbiter:** yaGPC2's truth packet `TRU1`, multicast 239.255.1.1, port
  base + 98 (`YAGPC_VEHDYN=1`).  Truth, not PASS's navigation state or GPS:
  the window shows where the vehicle *is*.  Big-endian doubles after "TRU1":
  - [0] vehicle t (s); [1] PASS GMT (s, day of year);
  - [2-5] quaternion body -> M50 (w x y z); [6-8] body rates (rad/s);
  - [9-11] M50 position (m); [12-14] M50 velocity (m/s);
  - [15] main-wheel height (ft); [16] ground speed (kt);
  - [17] Unix time (s), -1 until the timing unit sets the epoch (being added);
  - [18-26] M50 -> Earth-fixed rotation, row-major, r_ef = M r_m50 (being added).

  Read the first N doubles portview knows, as truthball.py does.  One packet per
  0.05 s of *vehicle* time (40 Hz wall at `--rate 2`); none while paused or
  restoring.  Between packets, position is extrapolated with the velocity and
  attitude with the body rates, keyed on [0], not on arrival time.
- **Earth orientation:** use [18-26] (PASS's own RNP precession/nutation plus
  rotation, as the GPS and landing aids use), *not* GMST computed here, so the
  Earth agrees with PASS's ground track and landing sites.
- **LEO targets:** planned in yaGPC2, not built yet.  The ISS is a second
  point-mass body in vehdyn, started from the historical TLE (epoch
  11138.51317551, for STS-134) and moved by the same gravity and drag.
  Proposed feed: "TGT1" on port base + 96, big-endian doubles: vehicle t,
  object id (NORAD number, 25544 for the ISS), M50 position (m), M50
  velocity (m/s), attitude quaternion body -> M50 (w x y z), already resolved
  by vehdyn.  One packet per object per 0.05 s of vehicle time.  portview maps
  each model's own axes and origin onto that body frame itself.
- **Ephemerides:** JPL DE440s (~32 MB, 1849-2150) through Skyfield, so no
  network is needed at run time, for historical or present-day flights.  J2000/ICRF
  vectors converted to M50 (mean equator and equinox of B1950) with the same
  J2000 -> B1950 matrix as `yaGPC2/src/startrk.c` (`to_m50`), so portview
  agrees with the star trackers.  Time from TRU1 [17].

## Windows and sizing

- PyQt6 with a `QOpenGLWidget` per view, as MEDS2.py does.  One process, up to
  four top-level windows (front, overhead, left, right), sharing one set of GL
  textures (`Qt.AA_ShareOpenGLContexts`), so the Earth textures are loaded once.
  Only the selected views are opened: `--views front,up,left,right`.
- Plain OS windows with title bars; no drawn window frames.
- `--size N`, with 768 = full size and the same scaling as panelO6.py, plus
  `--geometry` per view as simulatePASS.py passes to the others.  A working
  design value: at N = 768 the front view is 1536 logical px wide, 16:9, and
  spans 40 deg horizontally (+/-20 deg).
- Resizing (by `--size` or by dragging) **scales** the view by default: the
  field of view stays the same.  With `--crop`, the angle per pixel stays at the
  design value instead, so a bigger window shows more sky.
- The views (direction and field of view) live in a small table so they can
  be adjusted:
  - front: forward windows, +X;
  - up: overhead windows W7/W8, -Z;
  - left / right: the commander's and pilot's side windows (W1 / W6), looking
    outward, partly forward and somewhat downward; the angles are to be taken
    from Orbiter drawings.

## Rendering (back to front)

1. **Stars** (built in P1): real catalogues, not `starfield.jpg`.  That map
   (NASA SVS 4856, "An Elsewhere Starfield") has a real Milky Way but its
   stars were deliberately moved at random, so it can't match the sky or the
   star trackers.  Instead, prepared by `portview/fetch_assets.py`:
   - the Milky Way's diffuse light, SVS 4851 "Deep Star Maps 2020"
     `milkyway_2020_8k.exr` (stars removed; J2000 plate carree; linear HDR);
   - the ~118,000 Hipparcos stars (CDS I/239) drawn as points, brightness by
     V magnitude, colour by B-V, carried to the flight's date by proper motion.
   Light adds up linearly in a floating-point buffer per view; one exposure
   (`--exposure`, `--milkyway`, keys + - [ ]) sets how the sky looks, the
   same in every view.
2. **Planets** (Saturn, Jupiter, Mars, Venus): 1-pixel points in the given
   colours, with brightness from magnitude.
3. **Sun:** a #FFFFFF disk 32 arcmin across (about 50 physical px at the design
   scale) with a little glare.
4. **Moon:** `moon.jpg` on a disk 32 arcmin across, the direction taken from
   the Orbiter (parallax is up to 1 deg from LEO).  Phase per pixel in the
   shader, by lighting a sphere from the Sun direction, which also tilts the
   terminator correctly.  Lunar eclipse: dim and redden by the Moon's distance
   from the anti-Sun point against the radii of Earth's shadow.
5. **LEO objects farther than the Earth** (LEO 2).
6. **Earth:** a real sphere at its true distance and size, oriented by
   TRU1's M50 -> Earth-fixed matrix.  A shader blends Blue
   Marble NG (the flight's month) by day with Black Marble by night across a
   soft terminator, and adds the atmosphere's blue rim and the Sun's glint on
   the oceans.  Moon shadow: the fraction of the Sun's disk the Moon hides at
   each surface point, cheap in the same shader.  Textures 8192 x 4096 first;
   16K (macOS's limit) or tiles later.
7. **LEO objects in front of the Earth** (LEO 1).

**Which LEO layer:** the stated rule (behind the Earth if farther than the
Orbiter's geocentric distance) gets one case wrong: an object nearer than that
whose line of sight meets the Earth before reaching it.  From 400 km the
horizon is only ~2300 km away, so an object 3000 km away below the horizon
would be drawn in front of the Earth.  The exact test costs the same: intersect
the line of sight with the Earth sphere; the object is in LEO 2 if the Earth
is hit nearer than the object, else LEO 1.  Partial occlusion at the limb is
sub-pixel at such ranges.

**LEO object rendering:** glTF models with simple lighting: ISS (NASA's
model, final configuration to start with), HST, Mir; the HS-376/381
satellites (Palapa B2, Westar 6, Leasat 3) and Intelsat VI are generated
procedurally as textured drums.  Earth's and the Moon's shadow on each object:
one Sun-visibility test per object per frame.

## Assets

`portview/fetch_assets.py` downloads and converts the large inputs into a
git-ignored `portview/cache/`: today the Milky Way map (200 MB as float16) and
the Hipparcos catalogue (~4 MB prepared); later Blue Marble NG (12 months),
Black Marble and DE440s.  `moon.jpg` stays committed; `starfield.jpg` is no
longer used.  No Git LFS.

## Dependencies

PyQt6 and numpy (already required), PyOpenGL, OpenEXR (only for
`fetch_assets.py`), Pillow (later, for images), Skyfield (with jplephem),
and, only to prepare the ISS model, DracoPy and pygltflib; plus the 32 MB DE440s file.  portview
is optional: nothing else (simulatePASS, manager, panels, MEDS2) imports or
requires these, and portview exits with a clear message naming whatever is
missing.  Whether the other platforms install them is Ron's call.

## Later: ascent and entry (designed for now, not built now)

Ron intends to extend portview to launch/ascent and entry/landing: real
terrain, the sky seen from inside the atmosphere, and the landing sites (SLF
and others), with smooth hand-overs to and from the orbital views.  The orbital
case is common to all three, so it is built first; these choices in it keep
the rest an extension rather than a rewrite.

- **One scene, layers weighted by state, not modes.**  Each frame builds one
  frame state (time, camera pose in both M50 and Earth-fixed, Sun direction,
  altitude), and the renderer is a list of layers (sky, bodies, Earth,
  atmosphere, terrain, LEO objects).  Each layer can fade by altitude or
  other state.  Transitions are then blends over altitude bands, never a
  switch; ascent -> orbit -> entry comes from the trajectory alone.
- **Precision.**  All positions in float64 on the CPU; the GPU sees only
  positions relative to the camera (camera-relative rendering), with depth
  split into ranges (or a logarithmic depth buffer).  The same scene must hold
  a runway centimetres away and the Moon 384,000 km away.
- **The Earth is an ellipsoid in the Earth-fixed frame**, oriented by TRU1's
  M50 -> Earth-fixed matrix: PASS's own figure, a = 6378137.0 m exactly,
  f = 1/298.3 (not WGS-84's 1/298.257223563, which the physics uses only for
  drag altitude and gravity; the two differ by tens of metres, visible on
  final approach).  This is the ellipsoid of PASS's navigation, the landing-site
  I-loads and the landing aids (yaGPC2 vehdyn.c, landaids.c), so terrain and
  runways sit where PASS says they are.  TRU1 position is geocentric M50, so
  M * r is geocentric Earth-fixed; geodetic coordinates by Bowring's method
  with PASS's a and f.  (A sphere would be 21 km off at the poles.)
- **The globe is drawn as tiles** (a quadtree over the ellipsoid) even while
  each tile only samples one global texture.  Terrain is later per-tile
  heights (SRTM), and high-resolution imagery for the few regions that need it
  (KSC and the ascent corridor, the SLF, Edwards, White Sands, TAL sites) is
  more levels in the same tree.  The rest of the world stays at the global
  resolution, which is adequate above ~10 km.
- **The atmosphere is a physical scattering model** (precomputed Rayleigh/Mie
  scattering tables, Bruneton style) rather than a painted blue rim.  The same
  tables give the limb seen from orbit, the sky colour seen from inside the
  atmosphere at any altitude, and haze over distant terrain, so the views
  from orbit and from the runway agree.  Star visibility then follows from the
  sky brightness.
- **Data later:** runways and landing aids from the navaids text files
  yaGPC2's `tools/landing_sites.py` writes from `tools/sites/<site>.json`
  (e.g. `tools/sites/ksc-navaids.txt`, the file the emulator reads through
  `YAGPC_NAVAIDS`), read-only.  They hold the values exactly as PASS decodes
  them: `runway SLOT ID LAT LON ALT_FT AZ` (geodetic radians on PASS's
  ellipsoid, the landing threshold, AZ the true landing direction) and `mls`
  lines.  Only KSC exists today.  Scale check for a landing view: autolands
  touch down ~800-1400 ft past the KSC15 threshold of the 15,000 x 300 ft
  runway and stop ~8,300-9,200 ft down it.  Also later: SRTM elevations and Landsat/NAIP-class imagery for the
  selected regions, prepared offline by `fetch_assets.py` into tile sets;
  simple runway/facility models.  Out of scope until decided: clouds and
  weather, entry plasma glow, views of the ET/SRBs.

The alternative would be an existing globe engine (CesiumJS in a Qt web view),
which already does terrain, ground-to-orbit atmosphere and tile streaming.
Against it: it keeps its own Earth orientation and star sky (not PASS's), each
of the four windows would be a separate engine with its own memory, and
offline terrain means building and hosting tile sets anyway.  The plan keeps
the hand-built renderer.

## Landing-site imagery (built 2026-10-07)

Ron asked for real ground imagery near the ground.  The resolution needed
falls with the distance to the ground seen (about 1.4 mrad x distance per
texel at the views' scale), and close ground only occurs near the runway,
so each site has four nested rings, 8192 x 8192 each in geodetic lat/lon,
centred on the runway's midpoint from the navaids file:

| Ring | Size | Resolution | Source |
|---|---|---|---|
| 0 | +-4 km | ~1 m | USDA NAIP via the USGS National Map (public domain; US only) |
| 1 | +-40 km | ~10 m | Sentinel-2 cloudless 2016, EOX (CC BY 4.0) |
| 2 | +-400 km | ~100 m | the same |
| 3 | +-2000 km | ~500 m | the same |

~70 MB of JPEG per site in the cache; ~400 MB of GPU memory (ring 0
uncompressed, the others DXT1).  Each ring's colours are matched to the
next coarser one's.  Rings 0 and 1 are placed in the shader from the eye's
east-north-up offset from the site (double precision on the CPU), and the
ground intersection uses a cancellation-free root, so the runway is steady
at cockpit height.  Checked: the view down KSC 15's centreline from 600 m
past the threshold is centred and symmetric, so the imagery and PASS's
navaids agree to a few metres.  KSC only so far; Edwards and White Sands
are entries in fetch_assets.py's SITES table.  Later: terrain heights
(Copernicus GLO-30), and a finer ring (NAIP's native 0.3-0.6 m) for rollout.

## Ascent (started 2026-10-07; Ron: higher priority than the rest)

Like the landing in reverse, plus the pad's structures, and the roll to
heads-down after the tower (the overhead windows then look at the ground),
which portview follows from TRU1's attitude with no special handling.

- Done: KSC's site rings already cover the ascent's ground track to ~2000 km;
  fine patches (+-1.2 km NAIP, ~0.3 m) at pads 39A and 39B; the Shuttle-era
  LC-39 structures (NASA 3D Resources "Gantry": FSS with lightning mast, RSS,
  pad deck; 5.89 m a model unit, from the FSS's 40 ft footprint) drawn as a
  ground-fixed model at the pad (`--pad lc39a|lc39b|none`).
- To do: place and orient the gantry exactly from vehdyn's on-pad geometry
  (asked of PASS-IDLE: the stack's position, attitude and height), so the
  crew access arm meets the Orbiter's side hatch; then fly an ascent and
  check the views on the pad, through the roll, and downrange.  The current
  imagery shows today's pads (SpaceX's hangars and launch mount at 39A).

## Phases

- **P0 — coordinate with PASS-IDLE:** done 2026-10-07 (see "Data in").
  TRU1 [17-26] arrive with PASS-IDLE's next yaGPC2 commit; TGT1 comes with
  the rendezvous work.
- **P1 — skeleton:** windows, `--size`/`--geometry`/`--crop`/`--views`, the
  `TRU1` receiver with extrapolation, a camera per view, stars.  `--test` flies
  a synthetic orbit without yaGPC2.  Check: put a navigation star in a view at
  the attitude the star tracker reports for it.
- **P2 — Sun, Moon, planets** (done).  Checked: the Moon's phase and the
  tilt of its lit limb (2026-10-07, 10% lit), the total lunar eclipse of
  2011-06-15 (partial and total phases), the Venus-Jupiter conjunction of
  2023-03-02 (0.46 deg apart).  True angular sizes are used for the Sun and
  Moon (free, and they make eclipses come out right).
- **P3 — Earth** (done): ray-cast per pixel against PASS's ellipsoid rather
  than a tiled mesh, which is exact from orbit and needs no geometry; tiles
  remain the way to add terrain and high-resolution imagery for ascent and
  entry (a level-of-detail texture lookup keyed by latitude/longitude, and
  heights).  Blue Marble NG by month (16384x8192, compressed by the driver:
  ~90 MB of GPU memory), Black Marble lights, GEBCO water mask for glint,
  single-scattering atmosphere, the Moon's shadow.
  Checked: the Americas at noon from 20,000 km; the Galapagos at nadir; the
  2017-08-21 eclipse (total at Hopkinsville at 18:26:40, 83-85% at Chicago
  and Atlanta).  Apple's OpenGL falls back to software for dual-source
  blending, so the Earth goes to its own buffers (colour, transmittance).
- **P4 — LEO objects** (ISS done 2026-10-07): TGT1 reader on base + 96 per
  PASS-IDLE's proposal (axes and origin confirmed with PASS-IDLE); the ISS
  from NASA JSC IGOAL's model (NASA 3D Resources "ISS (D) (IGOAL)", 96 MB
  glb, Draco-compressed; fetch_assets.py decodes it once, needing DracoPy and
  pygltflib) as at STS-134: later parts (BEAM, Bishop, Nauka, Prichal, IDAs,
  iROSAs, later payloads) and STS-134's own AMS-02 and ELC-3 left out; 1.94
  million triangles, 35 MB prepared.  The model's root is a mirroring
  negative scale in inches; corrected to metres in the ISS analysis frame
  (checked: Kibo port, Columbus starboard, Cupola nadir, PMA-2 forward).
  Missing from the model for 2011: Pirs, the docked Soyuz/Progress, ATV-2.
  Eye points per view (forward and aft stations, approximate Orbiter
  structural coordinates).  Far away: a point by magnitude.  `--test vbar
  --test-range M` flies the final V-bar approach with a synthetic ISS.
  Other vehicles (HST, Mir, ...) are more models keyed by NORAD id.
- **P5 — integration:** simulatePASS.py / manager.py launch it, and window
  layouts include it (coordinated with PASS-IDLE; Ron's hand-placed
  `*.layout` files are never overwritten).
- **P6 — polish:** Moon-lit Earth at night.  No simulated glare or eye
  adaptation (Ron, 2026-10-07): the viewer's own eyes dim the stars next to
  a bright object on the screen, and a view dimming its own stars looks
  wrong beside one that doesn't.
