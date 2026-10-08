These are my thoughts for a program (`portview.py`) that would show relatively realistic views of the environment surrounding the Space Shuttle Orbiter vehicle as simulated by the program `yaGPC2` and the simulated peripheral devices in the present directory, in the directions straight ahead, upward, rightward, and leftward. I suspect that `portview.py` would be very dependent on a number of auxiliary files, such as PNG or JPG images, ephemeris data, and so on; such files would be stored in a directory called portview/.

Note that in the following I describe implementation details as they are presently in my imagination, but I seek the most-efficient implementation that produces something similar to the described visual appearance, and do not insist on the implementation details I'm suggesting. The most-efficient and most-pleasing results will likely depend on whatever tools are pre-existing, and I am unfamiliar with those.

The displayed image(s) would vary continuously and vary smoothly, or as much so as possible, based on:

- orientation and position of the Orbiter vehicle

- current date/time, as they affect the position and appearance of the items displayed.

- date/time/Orbiter state data would be obtained from a running instances of `yaGPC2` and/or its peripherals such as the GPS receiver or the Inertial Measurement Unit. Consult with the Claude agent called `PASS-IDLE` for details of how that would be accomplished, as well as for coordination of changes to this directory.

The items shown in the views, regardless of direction, would be the following, in the order of increasing priority; i.e., with higher-priority items occluding lower-priority ones.  In other words, think of the rendering of a sequence of nested spherical layers, with the Orbiter at the center of which only rectangular patches are viewed at any given time, and the ordering of the layers from outward to inward (towards the Orbiter) are:

1. The star field. I'd suggest that the image portview/starfield.jpg, which is a 8192&times;4096 full-sky equirectangular image [from here](https://svs.gsfc.nasa.gov/4856), would be wrapped as a texture around the interior of a sphere.

2. The planets Saturn, Jupiter, Mars, and Venus. These can be depicted as small disks of the appropriate colors, with unvarying sizes.  The average angular widths as seen from Earth are respectively about 18 seconds of arc, 40 seconds, 10 seconds, and 25 seconds, while the colors are roughly #EADAA2, #E3D5C1, #D47A4A, and #FAF6E8.  They can simply be rendered on the interior of the afore-mentioned sphere on an occasional basis, since their angular motion is quite slow.

3. The Sun. (While physically Venus sometimes is in front of the sun, it cannot be viewed by humans under those circumstances, so it is acceptable to consider it visually to be behind the sun.)  The sun can just be depicted as a uniformly-colored disk of unvarying size.  The color is pure white (#FFFFFF) and the angular width is about 32 minutes of arc. Like the planets, it can just be re-rendered on the sphere interior on an as-needed basis. 

4. The Moon.  While the Moon physically wobbles slightly with respect to the Earth, and thus does not *always* present exactly the same face, it's acceptable for this application to simply choose one unvarying face for display.  However, the Moon's phase must be depicted properly by masking the unlit portions.  Similarly, the Moon's apparent size physically varies with distance, but for our purposes it can alway be a disk of the same angular width as the Sun. I'd suggest the image portview/moon.jpg, which I just adapted from somewhere on the web, with its phase mask, can be rendered on the afore-mentioned sphere from time to time. It is okay to ignore lunar eclipses, but if there's a relatively cheap way to account for them, then do so.

5. A transparent sphere I refer to as `LEO 2`. (See `LEO 1` below.)

6. The Earth.  The Earth would be displayed oriented and lit properly according to its current rotation and orbital position with respect to the Sun.  Since cloud cover cannot be properly simulated in the historical time-frames in which Shuttle flights occurred, a cloudless image of the Earth should be shown.  I would suggest using [NASA Blue Marble](https://science.nasa.gov/earth/earth-observatory/blue-marble-next-generation/base-map/) imagery specific to the flight month for the daytime portions of the Earth, composited with [NASA Black Marble](https://science.nasa.gov/earth/earth-observatory/earth-at-night/maps/) imagery for the nighttime portions. It's okay to ignore the shadow of the Moon, but if there's a relatively cheap way to account for it, then do so.

7. A transparent sphere I refer to as `LEO 1`.  Collectively, the planes `LEO 1` and `LEO 2` would display a small number of selected objects in Low Earth Orbit (LEO). For many Shuttle flights, a sole LEO object would be used, namely the International Space Station (ISS). Simulated objects in LEO would move according the same gravitational physics as the Orbiter itself, but other aspects of object translation or rotation might be subject to specific properties of the object itself that cannot be predicted right not.  For the ISS in particular, that's discussed below.  Such objects would be rendered in `LEO 2` when farther away from the Orbiter than the Earth's radius, but would be rendered in `LEO 1` when closer to the Orbiter than that. The point is that the objects would always correctly appear to be "behind" or in "front" of the Earth.  Object would always be displayed in their proper orientation from the viewpoint of the Orbiter.  It's okay to ignore the shadows of the Earth and Moon on LEO objects, but if there's a relatively cheap way to account for them, then do so.

Regarding ephemeris data for the planets, Moon, and Earth, I'd suggest that it should be fetched from [JPL Horizons](https://ssd.jpl.nasa.gov/horizons/app.html#/) for each Shuttle mission, and stored permanently in portview/.  Possibly it could just be fetched for the entire time range spanning Orbiter flights.  For non-historical flights, such as a hypothetical flight *today*, it should be fetched as needed from JPL Horizons.

Regarding phases of the Moon and Earth, I have no particular suggestion as to where data can be downloaded from, although it can obviously be calculated from the positions of these objects relative to the Sun.

As mentioned before, my thought is that the star field would likely be wrapped around the inside of a sphere as a texture.  But also, Blue Marble and BlackMarble data would be wrapped around the outside of a separate sphere as textures.  Since wrapping is likely to be computationally expensive, my thought is that if multiple views (front, up, right, left) are desired, they should all be opened from the same instance of `portview.py`, in order to reuse that wrapping/rendering data.  However, an alternate approach would be to start a separate instance of `portview.py` for each desired view.

Regarding the ISS specifically:  Historical trajectory data for the ISS would be obtained from Space-track.org, for which I have an account, and would be saved in portview/.  The ISS maintains a specific orientation with respect to the earth and the direction of travel along the orbit, so additional information about its orientation isn't needed.  [3D models of the ISS are available here](https://science.nasa.gov/resource/international-space-station-3d-model/), but as to whether it would be efficient to use them is unclear. For realistic lighting, it's probably necessary to do so.  Personally, I want realistic lighting, but I'll take what I can get.  I presume that the external appearance of the ISS changed over time, but I don't know if it's realistic to hope to model those changes.

Regarding other potential LEO objects visited by the Shuttle, a non-exhaustive list includes:

- The Hubble Space Telescope, for which I know that there are 3D models, but I haven't researched historical trajectory.

- MIR

- Solar Max

- Palapa B2

- Westar 6

- Leasat 3

- Intelsat VI.

Produce a plan for implementing this, and give me feedback, but do not implement the plan unless asked to do so.


