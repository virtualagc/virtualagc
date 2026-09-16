# HANDOFF — `MEDS2-port.py`

A Python 3 port of **MEDS2**, the Electron / CoffeeScript / Civet MEDS glass-cockpit
simulator that `MEDS2.sh` launches. Written 2026-09-09, amended 2026-09-11, 2026-09-13 and 2026-09-14.

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
invoked `main.js meds …` still works. `--size` is pixels, 1024 = full size.

Added here:

* `--scale X` — text size only. Config key `textScale` does the same; the CLI
  value overrides it for every MDU launched. See §10.
* `--stroke-scale X` — text stroke width only. Config key `textStrokeScale`. See §10.
* `--pane` — show the IDP pane beside the display (§10); hidden by default. Also
  `NSTS_MDU_PANE=1`. `--no-pane` is still accepted and does nothing.
* `--no-idp-box` — hide the IDP identifier box and keyboard bars at the foot of DPS
  pages (§10); also `NSTS_DPS_IDP_BOX=0`.
* `--title <text>`, `--port-base <n>` — window title, and the bus port base.
* `--no-edgekeys` — no edgekey pushbuttons under the display (§10); also
  `NSTS_MDU_EDGEKEYS=0`.

**Requirements:** PyQt6 with `QtOpenGLWidgets`, numpy, and a driver that gives an
**OpenGL 4.1 core profile**. The 4.1 requirement is not arbitrary — PyQt6 wraps
only `QOpenGLFunctions_2_0`, `_2_1` and `_4_1_Core`, and the port needs core-profile
calls, so 4.1 is the only usable wrapper. `MDUGLWidget.initializeGL` raises with a
clear message if the context comes back lower.

Everything runs in **one process**. Electron used one renderer process per window;
here several MDUs and IDPs share an event loop. Each `Bus` still binds its own
socket with `SO_REUSEADDR`, so multicast delivery and the self-echo filter behave
as they did across processes. Two threads, though: from `IDP.start()` on, every IDP's
buses and heartbeat run on the `BusPump` thread (§5); the MDUs stay on the GUI thread.

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
| `NSTS_MDU_PANE` | *port only*: `1` = show the IDP pane, as `--pane`; `0` hides it and wins (§10) |
| `NSTS_DPS_IDP_BOX` | *port only*: `0` = no IDP identifier box or keyboard bars, as `--no-idp-box` (§10) |
| `NSTS_MDU_EDGEKEYS` | *port only*: `0` = no edgekey pushbuttons, as `--no-edgekeys`; `1` = shown, whatever the option (§10) |
| `NSTS_IDP_THREAD` | *port only*: `0` = IDP buses back on the GUI thread, no `BusPump` (§5) |
| `NSTS_GUI_STALL_MS`, `NSTS_GUI_STALL_BUSY` | *port only*, test hook: every 16 ms redraw tick holds the GUI thread this many ms — sleeping, or with `_BUSY=1` spinning with the GIL held (§8h) |
| `NSTS_IDP_POWER` | *port only*: `on`/`off` overrides the IDP's power at start (§10) |
| `NSTS_CLOCK_LOG` | *port only*: file of wall-stamped header-clock lines — `send` when the IDP forwards a time fill, `draw` when the MDU draws it |

**Not supported:** `NSTS_WINDOW_LOG`. It instruments `_fitWindowToCanvas`, the
Electron measure-and-grow loop; the port sets the client area directly and has no
equivalent to log. `NSTS_TOP` is a CONFIG field in both builds, not a variable.

---

## 3. Source map

Line numbers drift — the class and function names are the durable anchors.

| original | port | notes |
|---|---|---|
| `com/bus.civet` | `BusMsg`, `Bus` ≈ 269–425, `BusPump` right after `Bus` | `busConfig` table verbatim; `BusPump` is port-only (§5) |
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
| `meds/mduEdgeKeys.coffee` | `MDUEdgeKeys` ≈ 9000 | `press(i)`/`release(i)` shared by F1–F6 and clicks; `MDUEdgeKeyStrip` (port-only pushbuttons, §10) just before `MDUWindow` |
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

Sockets are read through a `QSocketNotifier` and drained in a loop per activation —
**except an IDP's.** `IDP.start()` calls `Bus.serviceOffGuiThread()` on each of its
buses, handing the socket to `BusPump`: one daemon thread, a selector over every IDP
socket, plus the IDP heartbeat (`BusPump.every`; a `QTimer` only when
`NSTS_IDP_THREAD=0`). The MDUs keep their buses on Qt. Why: a poll reply is due
within ~5 ms, and on the GUI thread anything holding it — a long redraw, a driver
throttling swaps behind a locked screen — held every reply. An overnight two-GPC run
lost 1h14m of simulated time and its redundant set that way (gpc-causes #144).
`sys.setswitchinterval(0.001)` is part of the fix: CPython's default 5 ms GIL hand-off
is the whole reply window. **Rule: nothing on the GUI thread touches an IDP after
`start()`** — keep it that way, or take a lock.

**MDU → IDP tags** (`MDUMsg`, on the IDP's `_IDPn` bus, all below `FILL`):
`SET_MAJOR_FUNC` `0x0001`, one word 0..3 (the IDP logs it on change only — panelO6
re-asserts every second); `DEU_LOAD` `0x0002`, no words (`IDP.deuLoad` →
`DEUUnit.requestLoad`); `IDP_POWER` `0x0003`, one word, 1 ON / 0 OFF (`IDP.setPower`
→ `DEUUnit.powerUp`); `KYBD_SEL` `0x0004`, one word, bit 0 the left keyboard is
selected to this IDP, bit 1 the right (IDP/CRT SEL). `panelO6.py` sends them — panel
C2 for IDPs 1–3, R11 for IDP 4, O6 IDP LOAD 1–4 — and so does the pane when shown
(§10). Anything that can send a datagram can press them: `simulatePASS.py`'s
`--keys` tokens `DEU_LOAD`, `IDP_POWER_ON`/`_OFF` (IDP1) and `DEU_LOAD2`,
`IDP2_POWER_ON`/`_OFF` (IDP2) do exactly that; those tokens are simulatePASS's.

**The keyboard switch.** `IDP.kybdSel` is `None` until a `KYBD_SEL` arrives, and
until then every wired keyboard bus is heard, as before switches. After one,
`IDP.recvKYBD` drops `_KYBD1`/`_KYBD2` keys whose bit is clear; `_KYBD3` (aft) has no
switch and is always heard. `HEARTBEAT` word 2 is `IDP._kybdBars()`: the selection,
or with none yet, the wired forward keyboards.

**The MDU ignores MDU → IDP traffic.** `MDU.recvFromPri` and `recvFromSec` return
early for tags below `MDUMsg.FILL`, so panel traffic cannot keep a dead port alive
(the panel re-asserts IDP POWER OFF every second; the MDU must still go AUTONOMOUS).
It follows the switches it hears — `_majorFuncHeard`, `_idpPowerHeard` (window title
or pane) — and keeps heartbeat word 2 as `MDU.kybdMask`, which drives
`Screen_DPS.setIdpBox(priPortIDP, mask)` and gates `KYBD.recvKYBD`'s scratch-pad echo.

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

**f. Without a desktop.** `unshare -rn` + Xephyr with
`QT_XCB_GL_INTEGRATION=xcb_egl LIBGL_ALWAYS_SOFTWARE=1` hosts a full MDU.
`QT_QPA_PLATFORM=offscreen` cannot (no `QOpenGLWidget`), but it can render
`IDPPane` on its own.

**g. With a keyboard.** `stsKeyboard.py` → MEDS2.py was verified in a namespace
run: IDP1 logs `KYBD1: _KYBD1 recv ITEM` / `1` / `EXEC`, and its next poll reply
carries `KYBD_MSG`.

**h. IDP replies under a stalled GUI thread** (2026-09-14, gpc-causes #144). One GPC,
IPL → ITEM 1 EXEC → PASS on CRT1, `NSTS_GUI_STALL_MS=500`, `YAGPC_TIMEOUT_TRACE=1`,
240 s. `NSTS_IDP_THREAD=0`: never reached PASS, 176 of 276 peer holds unanswered,
median 200 ms. Threaded: reached PASS, 0 unanswered, median 0.31 ms with a sleeping
stall, 6.5 ms with `NSTS_GUI_STALL_BUSY=1`. Unstalled regression, `simulatePASS
--gpcs 1,2 --crts 2` through OPS 2: every count identical to the old MEDS2.

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
  LRUs are frameless regardless.  With the edgekey strip on, the frameless
  window's grab includes the strip below the display.
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
* **`--scale` resizes text only.** `CharGen.scaleGlyphs` scales each font's strokes
  at load time about that font's digit ink centre (meds 1.368, 0.330 = `GXC`/`GYC`;
  deu 1.524, 0.509). Advances, anchors, vectors and stroke weight in px are
  unchanged. ADI ball labels follow automatically, because `_ballText` reads
  `medsFont.chars`. Verified by screenshots of DPS and AE_PFD at 1 and 0.85. Side
  effect: rules built from glyphs (rows of `-`, `|`) open gaps below 1.0.
* **`--stroke-scale` thins or thickens text strokes only.** They are
  `lineWidthPx × X`; halos keep their px border either side of the thinner core.
  `VectorDisplay.lines` takes `widthScale`, with scaled materials cached in `wMats`;
  at 1 the palette's own materials are used. ADI ball labels moved from bucket `d`
  into a new `dt` bucket, created right after `d`, so the draw order at 1 is
  unchanged. Verified: at 1, DPS and AE_PFD are pixel-identical to the build before
  the change; at 0.6 every changed pixel lies in the text mask.
* **An MDU echoes keys from other keyboards.** `KYBD.recvKYBD`, the MDU's own
  keyboard-bus listener, puts keys from OTHER senders on its bus onto the scratch
  pad; the original only printed them. `stsKeyboard.py` needs this, because the IDP
  never sends typed keys back to the MDU (only `RESET_SPL`). The window's own sends
  are dropped as self-echo, so nothing echoes twice. Only while that keyboard is
  selected to the MDU's primary IDP (`MDU.kybdMask`, §5), as the IDP ignores it
  otherwise. Side effect: two MDUs on one keyboard bus both echo, as both of their
  IDPs hear the key.
* **IDP buses on their own thread** (`BusPump`, §5). Electron gave each IDP a renderer
  event loop; here the one loop also draws every MDU.
* **The IDP identifier box and keyboard bars** at the foot of DPS pages are live, and
  shown by default (`SHOW_IDP_BOX`; `--no-idp-box` or `NSTS_DPS_IDP_BOX=0` hides).
  MEDS carried them as `gpcNo`: a placeholder "1" and a red left bar nothing changed.
  The number is the IDP driving the MDU (`priPortIDP`; MEDS2's PORT SELECT only moves
  the `*`, data still come from the primary). The bars are heartbeat word 2: red left
  = left (CDR) keyboard, yellow right = right (PLT), both possible on IDP 3, never
  on IDP 4 (Crew Software Interface USA006083 Rev B §2.2, 2.5, 2.6). `setKybd` takes
  `'left'`/`'right'`/`'both'`/`None`. A flight-deck photo,
  gigapan.com/gigapans/102753, shows CRT1 with box "2" and a yellow right bar while
  GPC 4 drove it: IDP 2 with the pilot's keyboard.
* **`MEDSConf` checked against the orbiter.** IDP2 no longer lists `_KYBD3`
  (inherited from MEDS): the aft keyboard reaches only IDP 4 (USA006083 §2.6). The
  MDU ports match the per-MDU stickers in that photo — CDR2 P1 S2, MFD1 P2 S3, MFD2
  P1 S3, PLT1 P2 S1, PLT2 P3 S2, CRT1–3 a single IDP (CRT MDUs use only their primary
  port, DPS Workbook USA005350 Rev B §2.5.3); CDR1's sticker is unread (MEDS2's P3
  S1). Power matches USA005350 §2.5.4: Main A MFD2/PLT1, Main B CDR2/MFD1, Main C
  CDR1/PLT2/AFD1 via R14 breakers; CRTs on control buses via IDP/CRT POWER.
* **The IDP pane** (`IDPPane`, laid out with the canvas by `MDUWindow._layoutBox` /
  `paneBox`): IDP POWER, IDP MAJ FUNC and DEU LOAD down the right of each MDU
  window, in `panelO6.py`'s styling and `--size` unit (`PANE_FULL = 768`). It sends
  the §5 tags. **Hidden by default** (`_pane_wanted()`): those switches live on
  `panelO6.py` — C2 for IDPs 1–3, R11 for IDP 4, O6 IDP LOAD 1–4. `--pane` or
  `NSTS_MDU_PANE=1` shows it; `NSTS_MDU_PANE=0` wins. **Without the pane an IDP starts
  powered**, and panelO6's IDP/CRT POWER switch (default OFF) takes over. **With it,
  IDP POWER starts OFF**, as a display unit is not powered until the crew powers it
  (PASS User's Guide Table 2-2 step 8). `--dev` starts powered; `NSTS_IDP_POWER`
  overrides. A re-IPL needs DEU LOAD (Table 2-2 step 9). Added in
  1b8f7f3c0, which also made `_drawPasses` clear the DFG background when
  `BACKGROUND_TOP` loses its BRANCH (it used to stay drawn).
* **The header clock is redrawn only when its digits change**
  (`Screen_DPS.setClock`, tracked in `_clockDrawn`, reset when `geo_dps_time` is
  rebuilt). GPCIPL time-fills on every poll, twice a second, so half the redraws
  repainted unchanged digits, and the clock looked as though it ran 1.5–2× fast.
  `NSTS_CLOCK_LOG` (§2) is the diagnostic for it.
* **Edgekey pushbuttons under the display.** Each MDU window has six clickable
  edgekeys in a grey bezel strip below the display, as on the orbiter (DPS
  Workbook USA005350 Rev B fig. 2-26 p. 2-33; `yaShuttle/MDU.jpg`): square keys
  between seven rounded ribs, each centred under its legend box (centres from
  `MDUMenuArea.menuBoxX` mapped through `CAM_L`/`CAM_R`; the photo's key pitch,
  0.149 of display width, matches the boxes' 7.75/52.24). `MDUEdgeKeyStrip`;
  strip height `EDGE_STRIP_K` = 0.09 of canvas width; `MDUWindow.setEdgeStrip`,
  `stripBox` and `_stripK`, and `_layoutBox`/`_snapToAspect` count the strip, so
  the window grows by exactly its height and the canvas keeps every pixel.
  `MDUEdgeKeys.press(i)`/`release(i)` serve F1–F6 and clicks alike, so a key held
  `STUCK_MS` (2 s) by mouse fails exactly as by F-key. On by default;
  `--no-edgekeys` or `NSTS_MDU_EDGEKEYS=0` hides it, `=1` forces it on.
  simulatePASS.py counts the strip (0.09 × `--size`) in its fits-on-screen check.
  Verified: an offscreen widget test (a click on key 4 reached handler 3; a 2.3 s
  hold failed key 2 and later clicks on it were ignored; a bezel click was
  ignored) and a full `--dev crt1` MDU in Xephyr (a synthetic press on key 4 took
  the MAIN menu to DPS; window 508×554 = 508 canvas + 46 strip at `--size 512`,
  dpr 2).
* **A small gap, not a band, between the edgekey menu and the strip.** The
  display frustum's bottom `VectorDisplay.CAM_B` was `CAM_B_FULL` (38.57 − 2 +
  0.374 = 36.944); it is now the legend frames' bottom, 36.2 less the menu offset
  0.643, plus `CAM_B_GAP` 0.3 = 35.857. The MDU canvas is shorter by
  `VectorDisplay.canvas_height_k()` (`(CAM_B − CAM_T)/(CAM_B_FULL − CAM_T)`,
  0.9716), so the page keeps its scale. On a 1016 px display the blank rows went
  from 36 to 8. Some gap is deliberate: photos of physical MEDS show a small,
  varying one. The geometry panel no longer moves the menu area with `pageY`
  (cce2e88c5).
* **Each DPS display announces its top two lines**, so a crew script can wait
  for a page (`wait crt N title TEXT`, `wait crt N new-screen`; see
  HANDOFF-panelO6.md). `Screen_DPS._drawPasses` starts a frame by emptying
  `_frameRows`; the glyph site in `drawFCWS` records each character by
  `int(round(penY()))` and `int(round(penX()))`; after both passes
  `_announceTopLines` takes the two lowest rows, and `announceScreen` sends one
  UTF-8 datagram, `<mdu name>\n<line 1>\n<line 2>`, to the bus group at
  `PORT_BASE + SCREEN_OFFSET` (91). It goes out when the lines change with the
  clocks masked (`SCREEN_CLOCK`) **and the change has held for two refreshes**,
  so a blinking field is not a new page, and otherwise at most every
  `SCREEN_REANNOUNCE_S` (1 s) so a listener started later soon knows. The name
  is `CONFIG['config']['lru']` lowercased (`crt1`), set on the screen when
  `setCurrentDisplay` creates it. **Only refreshes speak**: `--dev` fills the
  page once, so it announces nothing there, and a real run's time fills drive
  it twice a second. Seen in a one-GPC run: `GPCIPL MENU (1) 1 PASS1 1 PASS5 9`
  13.5 s after STANDBY, then `GPC MEMORY MEM/BUS CONFIG READ/WRITE`.

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
* **AFD 1's ports are unverified.** The only aft MDU in photos is stickered "MNC
  CNTL CA2 / IDP 4" (= CRT 4, on panel R11 per USA006083 fig. 2-3); both manuals list
  a second aft MDU, AFD 1, whose `MEDSConf` ports P4 S2 nothing confirms.
* **IDP2's PASS load logs `load started` but never `load complete`** in the two-CRT
  scripted run, though CRT2 draws PASS pages. Pre-dates `BusPump`, unchanged by it.
* Prints from the `BusPump` thread and the GUI thread can interleave on one log
  line. Cosmetic.
* **A keyboard echoes only on its MDU's first `_KYBDn`** — the first keyboard bus
  of the MDU's primary IDP. So KYBD2 keys reach IDP3 but do not echo on
  crt3/cdr1/plt2.
* Only tested on Linux/X11 with an NVIDIA 4.1 context at device pixel ratio 2.
  Wayland, macOS and dpr 1 are unexercised; the dpr-sensitive code is the
  `resolution`/`pxRatio` pair in `VectorDisplay.renderFrame`.  Test note:
  `QT_SCALE_FACTOR=2` is set in this desktop's environment, so a Xephyr screen
  must be about twice the window's logical size, or a root capture shows only
  its top-left.

---

## 12. If something looks wrong, look here first

| symptom | likely cause |
|---|---|
| fills, readout boxes or pointer arrows missing | depth function is not `GL_LEQUAL` (§4) |
| text in the right place, wrong glyph shapes | `CharGen` transform or the id→charcode mapping (§6) |
| whole page shifted by ~1 row or column | `ADJ` defaults, or `penX`/`penY` in `drawFCWS` — run the cell trace (§8b) |
| page blank but the clock updates | usually NOT a dropped fill: the IDP answered GPCIPL's polls late (on the GUI thread, before `BusPump`, which also draws the MDU; up to ~65 ms against a 5 ms window), so GPCIPL re-IPLed the unit and gave up. Signature: `load started` twice in the IDP log, then no 509-halfword fill at `0x19ee`. Fixed on the GPC side (yaGPC2 `bcenet_framer_peer_wait`, gpc-causes #85). Only then suspect `net.core.rmem_max` (§5) |
| page drawn in the wrong beam frame | the `GEOM_BAD_FRACTION` discriminator in `Screen_DPS.refresh`; `Shift+V` toggles manually |
| a GPCIPL menu squashed into the upper right, over an old PASS page | a GPC was IPLed onto a display still holding PASS's load, without DEU LOAD first (panelO6's O6 IDP LOAD, or the pane). The PASS page stays, and the frame guess draws GPCIPL's text in DFG's frame. Push DEU LOAD before the IPL |
| strokes too thick or thin after a resize | `pxRatio` (§4) |
| clock falls behind real time, `I/O ERROR CRTn`, fail-to-sync after the screen locks | IDP replies held by the GUI thread. Fixed by `BusPump` (§5, gpc-causes #144); `NSTS_IDP_THREAD=0` with `NSTS_GUI_STALL_MS=500` reproduces it |
| a display corrupts when several MDUs run | `GLResources` sweep keyed to the wrong renderer (§4) |
| stroke widths right but everything washed out | an sRGB conversion crept into the shaders (§4) |

Later notes are staged in `CLAUDE_LOG.md` until the next documentation sync.
