# Textures for `portview.py` and `truthball.py`

This directory holds **textures only**: the pictures that are mapped onto surfaces on the screen.  It does not hold the
imagery they were derived from; private copies of that exist elsewhere and are not part of the repository.

The repository as a whole is GPL v2, and anything here under that licence is not listed again below, except that
its origin is noted.

## What is here, and what is not

| In the repository (this directory) | |
|---|---|
| `adi_ball.png` | The ADI ball map used by `truthball.py`, from the *Space Shuttle Ultra* add-on for the Orbiter simulator (GPL v2). |
| `moon.jpg` | The Moon's near side, north up.  **Origin uncertain** (see below). |

The large textures are not in git.  They are in one archive, **`portview-textures.7z`**, kept with the other downloads
of the Virtual AGC project (<https://www.ibiblio.org/apollo/Downloads/portview-textures.7z>).  Unpack it in
`yaShuttle/discretePanel`:

    7z x portview-textures.7z

(900 MiB; sha256 `a6fac80c77b5bc6071a0e9c093e6702d0eb4a6fdf13961dfea7c4beb02488ae7`.)  It holds everything `portview.py` needs to run that is not in git: a `textures/` directory
(which merges with this one) and a `portview/cache/` directory with the data that are not textures (listed at the end).
**The archive is the supported source.**  `python3 portview/fetch_assets.py` is the record of how each file was made from
its public source, and can remake them into `portview/cache/`, but the sources are web sites that can change or vanish;
nobody should have to depend on them.  `portview.py` looks in `textures/` first and then in `portview/cache/`.

| In the archive | Source |
|---|---|
| `bluemarble_01.jpg` to `bluemarble_12.jpg` | NASA Earth Observatory, *Blue Marble Next Generation* (2004), the monthly world maps, 21600 x 10800 cut to 16384 x 8192. |
| `nightlights.jpg` | NASA Earth Observatory, *Black Marble* 2016 (3 km), city lights only. |
| `watermask.png` | From the GEBCO bathymetry and elevation maps that NASA publishes with *Blue Marble Next Generation*. |
| `milkyway_8k.npy` | NASA Scientific Visualization Studio 4851, *Deep Star Maps 2020* (`milkyway_2020_8k.exr`); float16 RGB, J2000. |
| `sites/ksc/` | `ringF.jpg`, `ring0.jpg` and the pad patches `patch_lc39a.jpg`, `patch_lc39b.jpg`: USDA NAIP, KSC's from the flight of 2010-05-02.  `ring1.jpg` to `ring3.jpg`: Sentinel-2 cloudless (below). |
| `sites/nor/` | `ringF.jpg`, `ring0.jpg`: USDA NAIP through the USGS National Map.  `ring1.jpg` to `ring3.jpg`: Sentinel-2 cloudless. |
| `sites/edw/` | `ring0.jpg` to `ring3.jpg`: Sentinel-2 cloudless (Edwards has no NAIP). |
| `sites/*/ring.json` | The rings' bounds, and each site's centre and height (from the airfield reference points and yaGPC2's navaids). |

## Licence categories

**US Government works (no restriction):** NASA's Blue Marble, Black Marble, Deep Star Maps and the GEBCO-derived water
mask as NASA publishes them; USDA NAIP and USGS products.

**CC BY 4.0, attribution required:** the Sentinel-2 cloudless layer, wherever it is used (`ring1` to `ring3` of the
sites above, and the base layers under the others):
*Sentinel-2 cloudless - <https://s2maps.eu> by EOX IT Services GmbH (Contains modified Copernicus Sentinel data 2016)*,
licensed CC BY 4.0.

**GPL v2:** `adi_ball.png` (*Space Shuttle Ultra*).

**Origin of the imagery uncertain.**  The origin of the imagery from which this texture has been derived is uncertain.  We are convinced that
nobody's rights have been bypassed in the usage of these textures.  However, if you believe your imagery has been
used illegitimately, and can demonstrate that a texture has been derived from your work, register a complaint with
us and the offending texture will be removed, or if you prefer, attributed to you.

| Texture | What is known |
|---|---|
| `moon.jpg` | Source not recorded. |
| `sites/zza/` | Zaragoza AB (LEZG): `ringF.jpg`, `ring0.jpg`, `ring1.jpg`, built from the imagery of the aerial-scenery add-on for Microsoft Flight Simulator *AirHispania LEZG Zaragoza v1.3.3* (a free download that states no licence terms), over a Sentinel-2 cloudless base. |
| `sites/esn/` | Ankara Esenboga (LTAC): the same, from *argaeus-ltac-ankara v056*. |
| `sites/kbo/` | Koeln/Bonn (EDDK): the same, from *eddk-aerial*. |
| `sites/ilm/` | Wilmington (KILM): the same, from *trynaeat-kilm-wilmington-intl*. |

For those four sites the outer rings (`ring2.jpg`, `ring3.jpg`) are Sentinel-2 cloudless (CC BY 4.0, above), and the
heights (`height0.npy` to `height2.npy`) are from the AWS terrain tiles (SRTM / EU-DEM, about 30 m), which are open data.

## Also in the archive, in `portview/cache/` (not textures)

| File | Source |
|---|---|
| `hipparcos.npy` | ESA Hipparcos main catalogue (CDS I/239), prepared; free to use with acknowledgement. |
| `de440s.bsp` | JPL planetary ephemeris DE440s (NAIF); used as downloaded. |
| `models/iss/` | The ISS as at STS-134, from NASA 3D Resources "International Space Station (ISS) (D) (IGOAL)" (NASA JSC IGOAL), decoded and trimmed, with its base-colour textures as JPEG.  A US Government work. |
| `models/gantry/`, `models/gantry.glb` | Launch Complex 39's pad structures, NASA 3D Resources "Gantry".  A US Government work. |
| `models/<spacecraft>/` | The other vehicles (HST, Mir, SPAS, LDEF and so on), built by `portview/vehicles/*.py` from this repository's own code: GPL v2. |
