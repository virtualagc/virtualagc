# Objects the Space Shuttle met in low Earth orbit, 1981-2011

A survey for portview's vehicle models: every object the Shuttle
rendezvoused with, retrieved, repaired, flew in formation with, or
deployed and then station-kept beside or later retrieved.  Satellites that
left on their upper stages at once (PAM-D, IUS, TOS, SSUS-A comsats, TDRS,
Magellan, Galileo, Ulysses, Chandra ...) and small subsatellites that were
only ejected (GAS-can and Hitchhiker satellites, picosats, ODERACS
calibration spheres, Starshine, ANDE, MEPSI ...) are listed at the end and
not modelled.  The ISS and its visitors are a separate module (`iss`).

NORAD catalogue numbers are from CelesTrak's SATCAT
(`https://celestrak.org/satcat/records.php?INTDES=YYYY-NNN&FORMAT=json`),
queried for every Shuttle launch designator below; each object free-flying
on its own has its own number (each Spartan 201 flight, for instance, is a
different catalogue object), so portview has one module per number.

"Key" is the portview module (`portview/vehicles/KEY.py`); "(others)" marks
models made before this survey by others; "--" is not modelled.

## Rendezvous, retrieval, repair and station-keeping targets

| Object | NORAD | Intl. des. | Missions (what the Shuttle did) | Configuration at the encounter | Size | Key |
|---|---|---|---|---|---|---|
| SPAS-01 (Shuttle Pallet Satellite) | 14142 | 1983-059F | STS-7 (Jun 1983): released, formation flight to ~300 m, photographed Challenger, recaptured | Blanketed box across the bay under an instrument deck, a round beam along its foot, a V keel truss below; cameras and 10 experiments on the deck and forward face | 4.8 m across x 3.4 m high x 1.5 m; 1,448 kg | `spas01` |
| SPAS-01A | -- (not catalogued: never released) | -- | STS-41B (Feb 1984): stayed on the arm after an RMS wrist fault | as SPAS-01 | as SPAS-01 | -- (not free) |
| Integrated Rendezvous Target (IRT) | 14689 | 1984-011C | STS-41B: a 2 m balloon released as a radar/optical target; it burst on inflation, so no rendezvous | Fragments | -- | -- |
| Solar Maximum Mission | 11703 | 1980-014A | STS-41C (Apr 1984): rendezvous, MMU capture attempt, RMS capture, repair, release | MMS bus + instrument module, two arrays, HGA mast | 4 m x 2.3 m; arrays ~12 m | `smm` |
| LDEF (Long Duration Exposure Facility) | 14898 | 1984-034B | STS-41C (Apr 1984): released; STS-32 (Jan 1990): rendezvous and retrieval after 5.7 years | 12-sided open frame, 86 experiment trays; gravity-gradient, axis vertical | 9.14 m long x 4.27 m; 9.7 t | `ldef` |
| ERBS (Earth Radiation Budget Satellite) | 15354 | 1984-108B | STS-41G (Oct 1984): released by the arm after Ride shook its stuck solar array free; the orbiter stayed near until it boosted itself away | Box bus, two solar wings, instrument scanners | ~4.6 x 3.8 x 1.6 m; 2.45 t | `erbs` |
| Westar 6 (HS-376) | 14688 | 1984-011B | STS-51A (Nov 1984): retrieved by MMU/stinger | Spinning drum, antenna stowed | 2.16 m x 2.8 m | `westar6` |
| Palapa B2 (HS-376) | 14692 | 1984-011D | STS-51A: retrieved | as Westar 6 | as Westar 6 | `palapab2` |
| Leasat 3 (Syncom IV-3) | 15643 | 1985-028C | STS-51D (Apr 1985): rendezvous, "flyswatter" attempt; STS-51I (Aug 1985): captured, repaired, re-released | Spinning drum, UHF helix and dish stowed | 4.26 m x 4.3 m (6.2 m with antennas) | `leasat3` |
| Spartan 101 (Spartan-1) | 15831 | 1985-048E | STS-51G (Jun 1985): X-ray astronomy free-flyer, deployed and retrieved | Spartan carrier lengthened by the X-ray instrument section, white blankets | 3.20 x 1.07 x 1.22 m (126 x 42 x 48 in) | `spartan101` |
| Plasma Diagnostics Package (PDP) | 15929 | 1985-063B | STS-51F (Jul 1985): released from the arm; Challenger flew round it (~6 h) and recaptured it | Cylindrical instrument package on its RMS fitting | 1.06 m dia. x 0.6 m; 360 kg | `pdp` |
| Hubble Space Telescope | 20580 | 1990-037B | STS-31 deploy; STS-61, 82, 103, 109, 125 servicing | | 13.2 m x 4.2 m | `hst` (others) |
| Compton Gamma Ray Observatory | 21225 | 1991-027B | STS-37 (Apr 1991): unberthed; its high-gain antenna boom freed by EVA (Ross, Apt), then released | Arrays and HGA boom deployed | 7.6 m long x 4.6 m; arrays 21 m; 17 t | `cgro` |
| IBSS / SPAS-II | 21244 | 1991-031B | STS-39 (Apr-May 1991): released; Discovery manoeuvred round it for the infrared sensor's plume observations; recaptured | SPAS-II carrier with the IBSS cryogenic IR sensor | ~4.5 x 1.9 x 1.5 m (bay-width carrier) | `ibss` |
| CRO-A/B/C chemical release subsatellites | 21247/21246/21245 | 1991-031D-F | STS-39: ejected and observed (from far) | small canisters | -- | -- |
| UARS (Upper Atmosphere Research Satellite) | 21701 | 1991-063B | STS-48 (Sep 1991): unberthed, solar array and HGA deployed on the arm, released | MMS bus + instrument module, one solar wing, HGA boom | 10.7 m x 4.6 m; 6.5 t | `uars` |
| Intelsat 603 (Intelsat VI F-3) | 20523 | 1990-021A | STS-49 (May 1992): three rendezvous, capture bar attempts, three-person EVA hand capture, new perigee motor fitted, released | Stowed: drums telescoped, antennas folded, TT&C omni up | 3.64 m dia. x ~4.3 m (5.3 m stowed overall) | `intelsat603` |
| EURECA (European Retrievable Carrier) | 22065 | 1992-049B | STS-46 (Aug 1992): deployed; STS-57 (Jun 1993): rendezvous and retrieval (antennas latched by EVA) | Arrays folded at retrieval (deployed at release) | 4.6 x 2.6 x ~2.3 m; arrays 20 m span; 4.5 t | `eureca` |
| TSS-1 (Tethered Satellite System) | -- (not catalogued: tethered) | -- | STS-46: deployed on its tether to only 256 m (a jammed reel), reeled back | 1.6 m sphere, white, on a tether from the bay boom | 1.6 m; 518 kg | -- |
| Spartan 201-01 | 22623 | 1993-023B | STS-56 (Apr 1993): solar corona free-flyer, deployed and retrieved | Spartan carrier with UVCS and the White Light Coronagraph | carrier ~1.0 x 1.2 x 1.2 m; tubes 3.3 m; ~1.3 t | `spartan201` |
| ORFEUS-SPAS I | 22798 | 1993-058C | STS-51 (Sep 1993): deployed, 6 days free, retrieved | ASTRO-SPAS carrier + 1 m UV telescope + IMAPS | 4.4 x 1.9 x 1.5 m carrier; telescope 4.0 m x 1.3 m | `orfeus_spas` |
| WSF-1 (Wake Shield Facility) | -- (not catalogued: stayed on the arm) | -- | STS-60 (Feb 1994): attitude-control fault kept it on the arm | 3.66 m steel disc | 3.66 m; ~2 t | -- (not free) |
| Spartan 201-02 | 23253 | 1994-059B | STS-64 (Sep 1994): deployed and retrieved | as 201-01 | | `spartan201_2` |
| CRISTA-SPAS I | 23341 | 1994-073B | STS-66 (Nov 1994): deployed, 8 days free, retrieved | ASTRO-SPAS + CRISTA dewar and telescopes + MAHRSI | 4.4 x 1.9 x 1.5 m carrier | `crista_spas` |
| Spartan 204 | 23470 | 1995-004B | STS-63 (Feb 1995): far-UV imager free-flyer, deployed and retrieved (then handled on EVA for mass-handling tests) | Spartan carrier with the FUV imaging spectrograph | ~1.3 m carrier | `spartan204` |
| Mir | 16609 | 1986-017A | STS-63 near-rendezvous (to 11 m); STS-71 ... 91 dockings | | | `mir` (others) |
| Space Flyer Unit (SFU) | 23521 | 1995-011A | STS-72 (Jan 1996): rendezvous and retrieval after its arrays were jettisoned | Bare octagon (array paddles jettisoned) | 4.46 m across x ~2.8 m; 3.8 t; arrays were 24.4 m span | `sfu` |
| OAST-Flyer (Spartan 206) | 23763 | 1996-001B | STS-72 (Jan 1996): deployed and retrieved | Spartan carrier with four experiments (REFLEX, GADACS, SELODE, SPRE) and amateur radio | ~1.3 m carrier | `oast_flyer` |
| TSS-1R | 23805 | 1996-012B | STS-75 (Feb 1996): deployed to 19.7 km when the tether broke; the satellite drifted away and was never met again | 1.6 m sphere, trailing 19.7 km of tether | 1.6 m | `tss1r` |
| Spartan 201-03 | 23668 | 1995-048B | STS-69 (Sep 1995): deployed and retrieved | as 201-01 | | `spartan201_3` |
| WSF-2 | 23669 | 1995-048C | STS-69 (Sep 1995): its first free flight; deployed, ~3 days free (station-kept tens of km away), retrieved | 3.66 m steel disc, wake-side experiments | 3.66 m; ~2 t | `wsf2` |
| Spartan 207 + Inflatable Antenna Experiment | 23871 | 1996-032B | STS-77 (May 1996): deployed; the 14 m IAE inflated and filmed from Endeavour while station-keeping; IAE jettisoned; Spartan retrieved | Spartan carrier, IAE canister; antenna inflated (14 m reflector, 28 m struts) | 28 m x 14 m inflated | `spartan207` |
| IAE (jettisoned antenna) | 23872 | 1996-032C | STS-77: free after the jettison, re-entered in days | Inflated reflector, torus, three struts | as above | `iae` |
| PAMS-STU (Passive Aerodynamically-stabilised Magnetically-damped Satellite, Satellite Test Unit) | 23876 | 1996-032D | STS-77: deployed; Endeavour made four rendezvous with it (tests of rendezvous techniques) | White cylinder with black bars and a red band, weighted forward to fly like a dart; two magnetic damping rods inside | 0.6 m x 0.9 m (NASA's "2 x 3 ft"); 35-49 kg | `pams_stu` |
| ORFEUS-SPAS II | 24661 | 1996-065B | STS-80 (Nov-Dec 1996): deployed, 14 days free, retrieved | as ORFEUS-SPAS I | | `orfeus_spas2` |
| WSF-3 | 24662 | 1996-065C | STS-80: deployed, 3 days free, retrieved | as WSF-2 | | `wsf3` |
| CRISTA-SPAS II | 24890 | 1997-039B | STS-85 (Aug 1997): deployed, 9 days free, retrieved | as CRISTA-SPAS I | | `crista_spas2` |
| Spartan 201-04 | 25062 | 1997-073B | STS-87 (Nov 1997): released, failed to activate (no attitude control), tumbled slowly; recaptured by hand on EVA (Scott, Doi) and berthed | as 201-01 | | `spartan201_4` |
| Spartan 201-05 | 25521 | 1998-064C | STS-95 (Oct-Nov 1998): deployed and retrieved | as 201-01 | | `spartan201_5` |
| International Space Station | 25544 | 1998-067A | STS-88 ... STS-135 | | | `iss` (others) |

Notes on the encounters:

* SMM, LDEF, Westar 6, Palapa B2, Leasat 3, Intelsat 603, EURECA and SFU were
  true rendezvous targets of satellites the Shuttle had not just released
  (or, for LDEF and EURECA, released on an earlier flight).
* The Spartans, SPASes, PDP, IBSS, WSF and PAMS-STU were released and
  retrieved on the same flight, with hours to days of free flight and
  formation flying, station-keeping or fly-arounds in between.
* GRO, UARS and ERBS were deployed from the arm; the orbiter stayed close
  only until each was released and checked out.  They are included because
  they were on, or just off, the arm in full view.
* Hubble's servicing missions met no other objects; Hubble carried no
  companions.  The Syncom IV (Leasat) satellites other than Leasat 3 left
  on their own stages at once.

## Deployed and gone at once (not modelled)

Comsats on PAM-D or other stages (Anik C2/C3, Palapa B1, SBS-C/D, Telesat,
Syncom IV-1/2/4/5, Telstar 3C/3D, Arabsat-1B, Morelos 1/2, AUSSAT 1/2,
ASC-1, Satcom K1/K2, Insat 1B; TDRS A, C-G (IUS), Magellan,
Galileo, Ulysses, Chandra (IUS; Columbia separated within hours), ACTS
(TOS), LAGEOS-2 (IRIS/LAGEOS apogee stage)); small ejected satellites
(NUSAT, GLOMR, ODERACS-1/2 spheres and dipoles, BREMSAT, PANSAT,
Starshine 1-3, MightySat 1, SAC-A, SNOOPY/MEPSI, ANDE, RAFT, DRAGONSAT,
PSSC-2); classified DoD payloads (STS-51C, 51J, 27, 28, 33, 36, 38, 44, 53;
STS-39's USA 70).

## Not modelled (no free-flying catalogued object, or nothing to see)

* SPAS-01A (STS-41B) and WSF-1 (STS-60): never released from the arm;
  no NORAD number.  `spas01` and `wsf2` would serve for either.
* TSS-1 (STS-46): tethered to 256 m and reeled in; no NORAD number.
  `tss1r` is the same satellite.
* IRT (STS-41B): burst on inflation.
* CRO-A/B/C (STS-39): chemical-release canisters, watched from afar.

## The models made for this survey

Each module's docstring gives its sources and the configuration it shows;
each meta['frame'] its body axes and origin.  Shared pieces live in
`_leo_util.py` (fixtures, procedural textures, mesh refinement),
`_leo_spartan.py` (the Spartan carrier, from NASA 3D Resources' Spartan
201, and a procedural one, `bus_parts()`, for 101, 204 and OAST-Flyer), `_leo_astrospas.py` (+ `_leo_orfeus.py`, `_leo_crista.py`),
`_leo_wsf.py` and `_leo_iae.py`.  mag_1000km values are estimates from
size and finish.

| Key | NORAD | Built from | Configuration | Triangles |
|---|---|---|---|---|
| `ldef` | 14898 | shapes; NASA SP-473 fig. 2 and SP-531 (tray map, structure, finishes); 41C, STS-32 (S32-85-081, s32-541-018, STS032-85-008) and KSC (KSC-84PC-0219) photos | 1990 retrieval look, every tray its own experiment (`LOOK = "1984"` gives the deploy look) | 55,308 |
| `intelsat603` | 20523 | shapes; STS-49 photos (9301572, 9257083, 9259496, 9301420, s49-91-020/026/029) | stowed, as captured (no capture bar, no new motor) | 15,268 |
| `eureca` | 22065 | shapes; eoPortal; STS-46/57 photos | arrays folded, antennas up (STS-57); `ARRAYS_DEPLOYED = True` gives STS-46's | 26,896 |
| `sfu` | 23521 | shapes measured off STS072-720-076, STS072-734-018/011, sts072-720-042; JAXA diameter | arrays jettisoned (STS-72) | 5,292 |
| `cgro` | 21225 | shapes; GRO Prelaunch Mission Operations Report (NTRS 20050229325) drawings, STS-37 and KSC photos (Ron's collection) | deployed, as released | 26,520 |
| `uars` | 21701 | shapes measured off NASA 9254338 (scale: the array's 3.3 m), 9248071, s48-05-024, s48-31-002, s48-e-013, STS048-23-12/21; NTRS 19930015545/19930019519 drawings; Ron's collection (sts48uarsdeploy) | array up and HGA out, as released | 11,892 |
| `spas01` | 14142 | shapes measured off STS-7 photos (S07-25-1421, S07-11-528, S83-35782, S07-18-774); STS-41B photos of SPAS-01A | as released on STS-7 (STS-7 fit-out); aft face unphotographed | 7,512 |
| `orfeus_spas`, `orfeus_spas2` | 22798, 24661 | shapes; STS-51/80 photos, the ASTRO-SPAS carrier from Ron's collection | free-flying | 8,540 |
| `crista_spas`, `crista_spas2` | 23341, 24890 | shapes; STS-66/85 and KSC photos (Ron's collection) | free-flying (II with IPEX-II) | 8,448 / 11,252 |
| `wsf2` | 23669 | shapes measured off sts069-723-072/732-048, sts060-76-095/74-054 | free-flying (grey boxes, green bars) | 10,288 |
| `wsf3` | 24662 | as `wsf2` + sts080-708-065/084, 755-016 (white boxes, gold bars, extra box and bar) | free-flying | 10,348 |
| `spartan201` ... `spartan201_5` | 22623, 23253, 23668, 25062, 25521 | NASA 3D Resources "Spartan 201", recoloured | free-flying | 30,672 |
| `spartan207` | 23871 | Spartan carrier + shapes; STS-77 photos | IAE inflated; `IAE_ATTACHED = False` gives the bare Spartan retrieved | 13,875 |
| `iae` | 23872 | shapes; STS-77 photos | jettisoned antenna | 5,940 |
| `ibss` | 21244 | shapes; STS-39 photos s39-15-017/17-017/19-015/11-027, preflight s91-27781/27784 | free-flying (cryostat across the bay, aperture -Y) | 5,556 |
| `pdp` | 15929 | shapes; Univ. of Iowa spec (NTRS 19810006441); 51F-34-041, 51F-33-024, 8772046, STS-3 sts003-009-444 | free-flying, booms out | 5,020 |
| `erbs` | 15354 | shapes; STS-41G and KSC photos (s84-41265/41266), NASA Langley, eoPortal (Ron's collection) | panels deployed, as released | 6,632 |
| `spartan204` | 23470 | procedural Spartan carrier + shapes; STS-63 photos (STS063-716-055/060/066/072, sts063-716-064) | free-flying | 3,116 |
| `oast_flyer` | 23763 | procedural Spartan carrier + shapes; STS-72 photos (STS072-726-051/054) | free-flying | 2,844 |
| `spartan101` | 15831 | procedural Spartan carrier + shapes; STS-51G press kit (126 x 42 x 48 in), 51-G photos (STS51G-35-53/54/57/64, 36-77/80/82) | free-flying | 4,862 |
| `pams_stu` | 23876 | shapes; STS-77 ESC frames S77-E-5067/5068/5069 | free-flying | 1,632 |
| `smm` | 11703 | shapes; STS-41C photos (Ron's collection) | as met on STS-41C, HGA stowed (`HGA_DEPLOYED = True` gives the post-repair mast) | 7,770 |
| `westar6`, `palapab2` | 14688, 14692 | shapes (`_hs376.py`); STS-51A photos (Ron's collection), JPL's 1.83 m reflector | free-flying, as approached; `CAPTURED = True` adds the MMU stinger in the nozzle | 9,696 |
| `leasat3` | 15643 | shapes; STS-51D/51I photos (Ron's collection), STS-51I press kit (cradle points, EVA timeline) | as captured on 51-I with the crew's grapple bar (`GRAPPLE_BAR = False` for the rendezvous) | 17,352 |
| `tss1r` | 23805 | shapes; Aeritalia exploded view (NTRS 19910009845); STS-46 9311302, STS-75 STS075-701-087, 9612176, 9606462 | the satellite (its 2.5 mm tether not drawn) | 7,296 |

A note for all models: portview's model fragment shader writes its own
depth, linear in the distance computed per fragment, so long triangles seen
obliquely no longer let surfaces a few centimetres behind show through.
Earlier, the depth was interpolated across the screen from the vertices,
an error of about L^2/(8d).  The models made before that fix cut their big
surfaces into 0.4-0.5 m pieces (`_leo_util.refine`, `cylinder_fine`,
`refine_parts`); that is harmless now and need not be copied.
