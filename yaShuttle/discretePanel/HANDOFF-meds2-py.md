# HANDOFF — `MEDS2-port.py`

A Python 3 port of **MEDS2**, the Electron / CoffeeScript / Civet MEDS glass-cockpit
simulator that `MEDS2.sh` launches. Written 2026-09-09, amended 2026-09-11.

One file, `MEDS2-port.py`, ~10 500 lines, at the tree root beside `MEDS2.sh`. It
reads the same `config/meds.json` and the same `data/` fonts and `.dfb` files, and
speaks the same multicast bus, so a Python MDU and a JavaScript IDP (or the
reverse) interoperate. It is not a rewrite: it is a line-for-line port, and the
places where it deliberately differs are listed under **Departures** below.

---

## 1. Running it

```bash
./MEDS2-port.py --list                  # list LRU names
./MEDS2-port.py crt1 idp1               # the config's usual pair
./MEDS2-port.py cdr1 plt1 idp1 idp2     # commander + pilot MDUs
./MEDS2-port.py --display AE_PFD crt2   # override the initial display
./MEDS2-port.py --dev crt1              # standalone: no IDP gating, test formats
```

Same flags as `MEDS2.sh`: `--config`, `--display`, `--menu`, `--size`, `--dev`,
`--list`. A leading `meds` argument is accepted and ignored, so anything that
invoked `main.js meds …` still works.

**Requirements:** PyQt6 with `QtOpenGLWidgets`, numpy, and a driver that gives an
**OpenGL 4.1 core profile**. The 4.1 requirement is not arbitrary — PyQt6 wraps
only `QOpenGLFunctions_2_0`, `_2_1` and `_4_1_Core`, and the port needs core-profile
calls, so 4.1 is the only usable wrapper. `MDUGLWidget.initializeGL` raises with a
clear message if the context comes back lower.

Everything runs in **one process**. Electron used one renderer process per window;
here several MDUs and IDPs share an event loop. Each `Bus` still binds its own
socket with `SO_REUSEADDR`, so multicast delivery and the self-echo filter behave
as they did across processes.

---

## 2. Environment variables

Every `NSTS_*` variable the original reads is honoured, with one exception.

| variable | effect |
|---|---|
| `NSTS_SIM_CONFIG` | extra config JSON, deep-merged over `config/meds.json` |
| `NSTS_BUS_IFACE` | local address the multicast buses bind to (default `127.0.0.1`) |
| `NSTS_BUS_RCVBUF` | socket receive buffer, default 4 MiB (see §5, lost display fills) |
| `NSTS_MDU_POS` | `x,y` placement, overriding the config |
| `NSTS_MDU_CHROME`, `NSTS_MDU_CHROME_X` | painted title bar height / side inset |
| `NSTS_DEU_GEOM` | `dfg` to start in DFG's beam frame instead of GPCIPL's |
| `NSTS_MAJOR_FUNC` | initial MAJOR FUNCTION switch position, 0..3 |
| `NSTS_DPS_ROWGAP`, `_TEXTY`, `_TEXTX`, `_VECY`, `_VECX`, `_YSHIFT` | initial `ADJ` page geometry |
| `NSTS_MENU_DX`, `NSTS_VIEW_DX`, `NSTS_VIEW_DY` | menu offset, camera pan |
| `NSTS_CELL_TRACE` | one line per drawn glyph — the best correctness oracle, see §8 |
| `NSTS_FCW_TRACE` | beam-interpreter trace to stdout |
| `NSTS_DEU_LOG` | append the DEU unit's log to a file |
| `NSTS_EXEC` | code run 2 s after the LRUs start — **Python here, not JavaScript** |
| `NSTS_MDU_FRAMELESS` | *port only*: restore the original's borderless window |

**Not supported:** `NSTS_WINDOW_LOG`. It instruments `_fitWindowToCanvas`, the
Electron measure-and-grow loop; the port sets the client area directly and has no
equivalent to log. `NSTS_TOP` is a CONFIG field in both builds, not a variable.

---

## 3. Source map

Line numbers drift — the class and function names are the durable anchors.

| original | port | notes |
|---|---|---|
| `com/bus.civet` | `BusMsg`, `Bus` ≈ 269–425 | `busConfig` table verbatim |
| `com/lru.civet` | `LRU` ≈ 427 | |
| `gpc/util.coffee` `PackedBits` | `PackedBits` ≈ 473 | |
| `meds/deuFCW.coffee` | `FCW` ≈ 751, geometry helpers ≈ 565–750 | `GEOMS`, `setGeom`, `cellCol`/`cellRow`, `inAUGrid` |
| `meds/deuProto.coffee` | `class DEU` ≈ 1069 | a namespace class, so `DEU.FUNC.POLL` still reads as it did |
| `meds/deuSPL.coffee` | `SPL` ≈ 1392 | |
| `meds/deuUnit.coffee` | `DEUUnit` ≈ 1573 | |
| `meds/medsConf.coffee` | `MDUMsg` ≈ 1852, `MEDSConf` ≈ 1867 | |
| `meds/mduMenu.coffee` | `Menus` ≈ 1955 | menu actions are lambdas |
| `three.js` subset | `Object3D`…`OrthographicCamera` ≈ 2214–2588 | §4 |
| `meds/shader/sdfLine.coffee` | `SDF_VERT`/`SDF_FRAG`, `makeSDFLine[s]Geometry` ≈ 2600–2840 | GLSL ported verbatim bar the clipping chunks |
| the WebGL renderer | `GLRenderer` ≈ 2860 | §4 |
| `meds/mduScreen_DPS.coffee` `ADJ` | `ADJ` ≈ 3104 | module-level mutable dict, as in the original |
| the SVG stroke fonts | `CharGen` ≈ 3242 | §6 |
| `meds/mduVectorDisplay.coffee` | `VectorDisplay` ≈ 3429, `OverlayWidget` ≈ 3861 | |
| `meds/mduScreen.coffee` | `VertGauge` ≈ 4387, `MDUScreen` ≈ 4495 | |
| `meds/mduScreen_DPS.coffee` | `Screen_DPS` ≈ 4632 | beam interpreter in `drawFCWS` |
| the other screens | `Screen_*` ≈ 5563–8425 | `Screen_AE_PFD` ≈ 6352 is the big one |
| `meds/mduMenuArea.coffee` | `MDUMenuArea` ≈ 8427 | |
| `meds/kybd.coffee` | `KeyEvent` ≈ 8753, `KYBD` ≈ 8794 | |
| `meds/mduEdgeKeys.coffee` | `MDUEdgeKeys` ≈ 9000 | |
| `meds/mdu.coffee` | `MDU` ≈ 9095, `mdu_start` ≈ 9532 | |
| `meds/idp.coffee` | `IDP` ≈ 9558, `idp_start` ≈ 9734 | |
| the param editor in `mdu.coffee` | `ParamPanel` ≈ 9770 | Qt widgets instead of DOM |
| `simRunner/main/main.civet` | `MDUWindow` ≈ 10019, `MedsRunner` ≈ 10262 | |
| `simRunner/renderer/startup.civet` | `MedsRunner.startLRUsIn` | |

**Not ported**, because they are not part of the MEDS2 runtime: `cde/*.ts` (the
`cde-window` chrome MEDS2 explicitly disables, plus dock/toolbar/split-pane, which
MEDS2 never loads), `meds/dfbDump.coffee` and `meds/dpsDispToFcb.coffee` (standalone
node tools), `meds/gpcmd.coffee`, and the `gpc/` and `mmu/` trees.

---

## 4. The renderer — read this before touching drawing code

The original draws through three.js: an orthographic camera over a scene of
`Object3D`s, two materials (a flat `MeshBasicMaterial` for fills, a custom SDF
stroke `ShaderMaterial` for every line). The port reimplements just enough of
three.js to run that unchanged, then draws it with OpenGL 4.1 core through Qt's GL
wrappers. The displays are tuned against three.js's exact draw rules, so those
rules are reproduced rather than approximated:

* **Sorting.** Opaque first, sorted `(renderOrder, material.id, z, object.id)`;
  then transparent, sorted `(renderOrder, −z, object.id)`. These are three.js's
  `painterSortStable` / `reversePainterSortStable`. `groupOrder` is always 0 because
  the code builds plain `Object3D`s, never `Group`s.
* **`glDepthFunc(GL_LEQUAL)` — the one that will bite you.** three.js's
  `Material.depthFunc` defaults to `LessEqualDepth`, and the displays lean on it
  hard: tape faces, readout boxes, green pointer arrows, the alpha limit bar and
  the menu masks are all coplanar at z 0, and the one drawn **last** is meant to
  win. Under `GL_LESS` every one of them silently disappears behind whatever drew
  first at the same depth. This cost a debugging session; it is the only bug that
  survived to the screenshot stage.
* **Depth writes.** SDF line materials set `depthWrite: false` (the AA fringe must
  not block crossing strokes); fills write depth. The ADI ball's self-occlusion
  depends on this — markings ride at `LINE_R = BALL_R × 1.012`, just proud of the
  hemisphere fills, and the far side fails the depth test.
* **Clipping planes.** Ported as three.js has them: `vClipPosition = −mvPosition.xyz`,
  discard when `dot(vClipPosition, plane.xyz) > plane.w`. The view matrix is the
  identity (camera at the origin, `lookAt` degenerate), so planes need no transform.
  Max four planes; every call site uses exactly four or none.
* **Colour.** three 0.150 defaults `outputEncoding` to `LinearEncoding` and
  `ColorManagement.enabled` to false, so palette values pass through unconverted.
  The port writes `hex / 255` straight out. Do not add an sRGB conversion.
* **Antialiasing.** `antialias: true` → `QSurfaceFormat.setSamples(4)`.
* **`supersample` in `config/meds.json` is inert, in the original too.** The single
  `RenderPass` gets `renderToScreen`, so `EffectComposer`'s 4× targets are never
  used. MSAA does the work. Don't "restore" it without checking that first.
* **Resolution and stroke width.** `resolution` = the real framebuffer size,
  `pxRatio` = framebuffer width ÷ config width. That is the original's own formula,
  and it is why `--size` and a dragged resize both scale stroke weights correctly.
* **GL resource lifetime.** Geometries are created and thrown away constantly
  (a DPS refresh twice a second, the self-test animation at 20 Hz). `dispose()`
  parks buffers in `GLResources`, **keyed by the owning renderer**, and each
  renderer sweeps its own list at the top of its frame. The key matters: several
  MDUs share a process but not a GL context, and destroying a buffer with the wrong
  context current corrupts the other display. Memory is flat over 30 s of 20 Hz
  rebuilds.
* **One optimisation.** `CharGen.drawGlyph` merges a glyph's strokes into a single
  batched mesh instead of one mesh per stroke. Same material, same transform, same
  z — visually identical, roughly a third of the draw calls.

---

## 5. The bus

UDP multicast on `239.255.1.1`, one port per bus, words big-endian on the wire. The
interface is pinned (`NSTS_BUS_IFACE`, default loopback) because joining without
naming one delivers every datagram twice on some platforms; the self-echo filter
then drops one copy and passes the other, which desynchronises every bus program by
one word.

The 4 MiB receive buffer is deliberate and the comment in `Bus._startMulticast`
records why: GPCIPL sends its menu as one 509-halfword `DISPLAY_FILL` inside a burst
of seven, and the default buffer drops words mid-burst while the display is drawing.
The OS silently caps at `net.core.rmem_max`, so the achieved size is logged.

Sockets are read through a `QSocketNotifier` and drained in a loop per activation.

---

## 6. The fonts

`data/deu_font.svg` and `data/meds_font.svg` are stroke fonts. The mapping is
non-obvious and worth writing down: **an SVG element's `id`, with a leading `c`
stripped, parsed as an integer, plus 33, is the character code.** So `c0` is `!`,
`c32` is `A`, `c696` is `˙` (U+02D9), `c8221` is `‾` (U+203E). Ids that don't parse
(`path13519`, `s0_0`, `edit_plus`) land on `"\0"` and are discarded.

The coordinate transform is the original's, unchanged:
`x = 0.95 + 0.9·xc·43/512`, `y = 0.10 + 0.9·yc·30/512`.

That this is right is confirmed independently: the meds-font digit ink comes out at
left 1.009, centre 1.368, right 1.726, y-centre 0.330, half-height 0.409 — exactly
the `GXL`/`GXC`/`GXR`/`GYC`/`GHH` constants `scrollTape` and the ADI ball were hand-
measured against. If you ever change the font pipeline, re-check those five numbers.

Path parsing handles `M m L l H h V v Z` only, matching the original's switch;
relative `m` updates the pen without emitting a point, and the two stray `c` (cubic)
segments in `deu_font.svg` are ignored, as they were before.

---

## 7. Language traps

Things that are *not* mechanical translation, each of which changes behaviour:

1. **`Math.round` breaks ties upward; Python's `round()` breaks to even.** The beam
   interpreter rounds coordinates constantly. Use the `jsround` helper, never
   `round()`.
2. **CoffeeScript 2 compiles parameter defaults to ES6 defaults**, so an explicit
   `null` does *not* take the default — only `undefined` does. `VectorDisplay.box`
   depends on this: `box(…, null, fill)` means "no outline", while omitting the
   argument means "green outline". Hence the `UNDEF` sentinel. (CoffeeScript 1
   behaved the opposite way; don't reason from that.)
3. **`for x in y` is CoffeeScript's *indexed* loop.** It compiles to
   `for (i = 0; i < y.length; i++)`, so handing it an object with no `.length`
   iterates zero times. See §9.
4. **`"IDP1" & 0xffff` is 0 in JavaScript.** The IDP writes its LRU *name* into the
   POLL and HEARTBEAT halfword, which therefore goes out as 0. `_js_uint16`
   reproduces that. Nothing reads it, but matching it keeps a Python IDP
   indistinguishable on the wire.
5. **A `'_'` don't-care run in a `PackedBits` descriptor becomes an unnamed field.**
   JavaScript parks it under the key `undefined`; the port skips it. Nothing reads
   it — but a diff against JS-dumped decode output will show the extra key.
6. **`%%` is CoffeeScript's modulo (always positive) = Python's `%`; `%` is JS
   remainder.** Both were checked case by case; where the sign could differ the
   result was only ever tested for zero/non-zero.

---

## 8. Verification — how to re-run every check

The port was not eyeballed into place; each layer has an oracle. Reproduce them
before trusting a change.

**a. Protocol layers against the real JavaScript.** Bundle the CoffeeScript with
esbuild inside the project (so `node_modules` resolves) and dump reference data,
then compare. The harness used lives in the scratch directory, but it is 150 lines
and easy to rebuild: `esbuild.build({entryPoints: ['meds/deuFCW.coffee'], bundle:
true, platform: 'node', format: 'cjs', plugins: [coffeePlugin({})], resolveExtensions:
['.coffee','.js','.ts','.civet','.json'], external: ['dgram','three','react','electron']})`.
It covered, and all matched:

* `decodeFCW` over **all 65 536 halfwords**, in both beam geometries
* every word constructor, `cellX/cellY/cellCol/cellRow/screenX/screenY`, `vector`,
  `positionRun`, `signed11`, `inAUGrid`
* `encodeCommand`/`decodeCommand`, IBM float48 round trips, `timeFillWords`,
  `packKeys`/`unpackKeys`, `checksum`, `pollResponse`, `biteResponse`, `fillMessages`
* the full SPL grammar — 15 key sequences × both POLL FAIL limits, comparing line,
  keys, error, state, `initSpan` after **every keystroke**
* `DEUUnit` transcripts (fills, time fills, polls, BITE, dump, MEDS transfer,
  abandoned transfer, unknown command) down to the exact log strings and every
  `stats` counter

Result: **130/130**. Two rounding notes when you rebuild it: apply `Math.round`
semantics on both sides, and drop the JS `undefined` key (trap §7.5).

**b. Beam geometry — the cheapest and sharpest check.** Run both builds with
`NSTS_CELL_TRACE=<file> … --dev crt1` and `diff`. Each line is the pass, the cell
row and column to two decimals, and the character. It is **byte-identical**, 184
lines. If you change anything in `drawFCWS`, `ADJ`, `CharGen` or the camera, this
diff is the first thing to run.

**c. Pixels.** Screenshot both and compare. `Shift+S`, or
`NSTS_EXEC='lrus.crt1.screenshot()'`, writes `mduScreenshot-<ms>.png` from the
framebuffer. For the Electron side capture the X window (`import -window <id>`;
find it with `wmctrl -l`, and note that `wmctrl`'s reported y may be off by the
frame — scan a few crop offsets and take the RMSE minimum). Measured: **AE_PFD
0.62 % RMSE, DPS and ENTRY_TRAJ_1 0.98 %**, all of it antialiasing — an 8×-amplified
difference image shows only edge outlines.

**d. Interoperability.** Start a Python MDU and a JavaScript IDP (and the reverse)
and confirm the GPC MEMORY page appears. Order matters: the `--dev` background is a
**one-shot** fill, so the MDU must be up first or it misses it and shows a blank
page with POLL FAIL — that is correct behaviour, not a fault.

**e. Stability.** `Screen_DPS.enterSelfTest()` rebuilds the whole FCW list 20×/s.
RSS was flat at 228 MB over 30 s.

---

## 9. Faithful quirks — deliberately preserved, do not "fix"

* **`VectorDisplay.add` does nothing when handed a bare `Object3D`** (trap §7.3).
  Callers that pass one object rather than a list therefore add nothing to the
  scene: `Screen_FILE_PATCH`'s labels (so that page really does render as a single
  white rule), `drawGSI`, `drawRange`, and `Screen_IDP_CST`'s colour fills. The port
  reproduces it and says so in a comment at the call sites.
* The IDP's poll/heartbeat id halfword is 0 (trap §7.4).
* The `DEUUnit` is named `IDPIDP1` — `"IDP#{@id}"` where `@id` is already `IDP1`.
  Log lines read `IDPIDP1:`. Likewise `MDU#{@id}` prints `MDUMDU:`.
* `MDUMenuArea.setNegView` compares a boolean against an `Object3D`, so it never
  fires. Untouched.
* `MDU.mduConfig.flightCritBus` reads `@flightCritBus` before it is assigned.
* Two menus (`VIDEO`, `AE_FLT_INST`) declare fewer than six edgekeys. The original
  throws on them; both are unreachable. The port renders the missing keys blank
  rather than crashing — the one place tolerance was chosen over fidelity, since
  the alternative is a half-updated UI.

---

## 10. Departures from MEDS2 — intentional

* **Ordinary decorated windows by default.** Electron asked for `frame: false` and
  painted its own bar over the canvas; its default `window.backgroundColor`
  (`#101336`) is the same value the canvas clears to, so the surround could be told
  neither from the display nor from the desktop. A window-manager frame costs the
  display nothing — it sits outside the client area, the canvas keeps every pixel,
  and nothing the renderer draws can paint over it.
  **`NSTS_MDU_FRAMELESS=1` restores the original.** Keep that in mind for screenshot
  tooling: only in the frameless window is the content area *exactly* the canvas,
  which is what makes a whole-window grab a 1:1 capture of the display. Fullscreen
  LRUs are frameless regardless.
* **Windows are resizable, aspect locked.** Drag a border: the canvas letterboxes in
  `window.backgroundColor` during the drag, then the window snaps to the config's
  ratio 250 ms after it settles (`MDUWindow._snapToAspect`). Render resolution is
  unchanged — only `pxRatio` moves, so stroke weights scale exactly as `--size`
  does. A window dragged to 512 is **bit-identical** (RMSE 0) to `--size 512`.
* **`NSTS_EXEC` is Python**, evaluated with `lru`/`lrus` in scope. `lrus` is an
  attribute-accessible dict, so strings written for the JavaScript build —
  `window.lrus.cdr1.screens.AE_PFD.enterTapeTest()` — still parse. It is `eval`'d,
  falling back to `exec` for multi-statement source.
* **`Shift+S` works.** In Electron it throws: `screenshot()` looks up
  `//*[@id="screen"]`, which does not exist once the `cde-window` chrome is off, so
  three.js made its own unnamed canvas. The port grabs the framebuffer.
* **`MDU.seq_mdu_selftest`** exists and forwards to the `IDP_CST` screen. The CST
  menu calls it on the MDU, which in the original has no such method.
* **Ctrl+R** marks the display dirty rather than reloading a renderer process.
* `machina` FSM → a `QTimer` chain (`Screen_IDP_CST.seq_mdu_selftest`).
* `localStorage` → one JSON file, `~/.local/state/meds2-port/localStorage.json`
  (`$XDG_STATE_HOME` honoured). Same API, so the overlay-slot code is unchanged.

---

## 11. Known gaps and untested ground

* **The reference-overlay tooling is untested against real images.**
  `data/overlay_images/` does not exist in this tree, so `overlayImageNames()`
  returns `[]` and the original logs the same "can't list" message. The warp, the
  corner/edge handles, the rotate and nudge tools and the slot registry are all
  implemented (`OverlayWidget`, `QTransform.quadToQuad` for the homography) but have
  only been exercised with no image loaded. **Drop some PNGs in that directory
  before trusting it.**
* **`cde-left-inset` / `resize-left` are not implemented.** That dev-mode path let an
  Electron left-edge drag grow the window while content stayed put. There is no
  equivalent gesture here and `_leftInset` stays 0. If overlay corner handles need
  work space, resize the window (§10) instead.
* The painted `NSTS_MDU_CHROME` bar is largely redundant now that windows have real
  frames; it is kept for parity.
* `Screen_ORBIT_PFD` subclasses `Screen_AE_PFD` with no changes — as in the original,
  so both render identically.
* The FC1–4 buses are received and discarded (`IDP.recvFC` is empty), matching the
  original: ADC flight-instrument data is not implemented on either side.
* Only tested on Linux/X11 with an NVIDIA 4.1 context at device pixel ratio 2.
  Wayland, macOS and dpr 1 are unexercised; the dpr-sensitive code is the
  `resolution`/`pxRatio` pair in `VectorDisplay.renderFrame`.

---

## 12. If something looks wrong, look here first

| symptom | likely cause |
|---|---|
| fills, readout boxes or pointer arrows missing | depth function is not `GL_LEQUAL` (§4) |
| text in the right place, wrong glyph shapes | `CharGen` transform or the id→charcode mapping (§6) |
| whole page shifted by ~1 row or column | `ADJ` defaults, or `penX`/`penY` in `drawFCWS` — run the cell trace (§8b) |
| page blank but the clock updates | a `DISPLAY_FILL` was dropped at the socket — raise `net.core.rmem_max` (§5) |
| page drawn in the wrong beam frame | the `GEOM_BAD_FRACTION` discriminator in `Screen_DPS.refresh`; `Shift+V` toggles manually |
| strokes too thick or thin after a resize | `pxRatio` (§4) |
| a display corrupts when several MDUs run | `GLResources` sweep keyed to the wrong renderer (§4) |
| stroke widths right but everything washed out | an sRGB conversion crept into the shaders (§4) |

Related notes are staged in `CLAUDE_LOG.md` pending a documentation sync.
