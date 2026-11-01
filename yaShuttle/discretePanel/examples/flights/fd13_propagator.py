"""Fast Python binding to the Orbiter's C truth propagator for FD13 targeting.

The rendezvous target is still built by ``rndz_start.py``.  This module only
propagates the Orbiter side of a differential-correction trajectory, using the
same rotating 4x4 EGM96 gravity field as ``vehdyn.c``.  It compiles the small
existing physics translation unit into a content-addressed temporary shared
library so the flight scripts do not depend on a particular CMake build tree.
"""
import ctypes
import hashlib
import math
import os
import shlex
import shutil
import subprocess
import sys
import tempfile


PASS_EARTH_RATE = 0.729211514646e-4


class _PhysState(ctypes.Structure):
    _fields_ = [
        ("t", ctypes.c_double),
        ("r", ctypes.c_double * 3),
        ("v", ctypes.c_double * 3),
        ("q", ctypes.c_double * 4),
        ("w", ctypes.c_double * 3),
        ("mass", ctypes.c_double),
        ("I", (ctypes.c_double * 3) * 3),
    ]


def pass_rnp(year, day):
    """Return the exact M50-to-Earth-fixed RNP matrix used by ``vehdyn.c``."""
    pi = math.pi
    jday = day + math.trunc(365.25 * (year + 4799)) - 31790.5
    ut1 = jday - 2459579.5
    et = ut1 + 63.18 / 86400.0
    at = et * pi * 1e-4
    sa, ca = math.sin(at), math.cos(at)
    ss, cc = sa * sa, 1.0 - sa * sa
    s2, c2 = 2 * ca * sa, cc - ss
    s3, c3 = sa * (3 * cc - ss), ca * (cc - 3 * ss)
    x = (4.086914938e-5 + 3.30570821156e-9 * et + 5.3101057542e-13 * et * et
         + 1.91701187619e-5 * ca + 6.84908162624e-6 * sa - 6.07687147621e-6 * c2
         - 5.08608200417e-6 * s2 - 2.0912057236e-5 * c3 - 3.61848835411e-5 * s3)
    y = (7.00499683245e-3 + 2.67922724381e-7 * et - 3.72836339327e-13 * et * et
         - 1.08609567896e-5 * ca - 1.23753947146e-5 * sa - 8.83842901467e-7 * c2
         + 6.05983470459e-6 * s2 - 2.73258319638e-5 * c3 + 1.48249685562e-5 * s3)
    z = math.fmod(1.72302078155 + 6.30038748669 * ut1
                  - 2.30211679566e-15 * ut1 * ut1, 2 * pi)
    cx, sx = math.cos(x), math.sin(x)
    cy, sy = math.cos(y), math.sin(y)
    cz, sz = math.cos(z), math.sin(z)
    return ((cy * cz, cx * sz + sx * sy * cz, sx * sz - cx * sy * cz),
            (-cy * sz, cx * cz - sx * sy * sz, sx * cz + cx * sy * sz),
            (sy, -sx * cy, cx * cy))


def _build_physics_msvc(source_dir, source, output):
    """Build physics.c into a DLL with MSVC (Windows has no cc).

    cl must be on PATH, or vswhere must find a Visual Studio whose vcvars64.bat
    can be run first.  The four entry points the propagator calls are exported
    on the link line, so physics.c needs no dllexport.
    """
    exports = ["/EXPORT:" + name for name in
               ("phys_set_gravity", "phys_set_drag", "phys_set_earth", "phys_advance_to")]
    cl = ["cl", "/nologo", "/O2", "/LD", "/I", source_dir, source,
          "/Fo" + output + ".obj", "/Fe" + output, "/link"] + exports
    prefix = ""
    if shutil.which("cl") is None:
        vswhere = os.path.join(os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)"),
                               "Microsoft Visual Studio", "Installer", "vswhere.exe")
        found = subprocess.run([vswhere, "-latest", "-products", "*", "-property",
                                "installationPath"], capture_output=True, text=True)
        root = found.stdout.strip() if found.returncode == 0 else ""
        vcvars = os.path.join(root, "VC", "Auxiliary", "Build", "vcvars64.bat")
        if not root or not os.path.isfile(vcvars):
            raise RuntimeError("no C compiler: cl is not on PATH and vswhere found no "
                               "Visual Studio; run from a Developer Command Prompt")
        prefix = 'call "%s" >nul && ' % vcvars
    try:
        subprocess.run(prefix + subprocess.list2cmdline(cl), shell=True, check=True,
                       capture_output=True, text=True)
    finally:
        for extra in (output + ".obj",):
            if os.path.exists(extra):
                os.unlink(extra)
        base = os.path.splitext(output)[0]
        for extra in (base + ".lib", base + ".exp"):
            if os.path.exists(extra):
                os.unlink(extra)


def _load_physics():
    source_dir = os.path.abspath(os.path.join(os.path.dirname(__file__),
                                              "../../../yaGPC2/src"))
    source = os.path.join(source_dir, "physics.c")
    header = os.path.join(source_dir, "physics.h")
    with open(source, "rb") as stream:
        digest = hashlib.sha256(stream.read()).hexdigest()[:20]
    with open(header, "rb") as stream:
        digest = hashlib.sha256((digest.encode() + stream.read())).hexdigest()[:20]
    windows = sys.platform == "win32"
    library_path = os.path.join(tempfile.gettempdir(), "libfd13-physics-%s.%s"
                                % (digest, "dll" if windows else "so"))
    if not os.path.isfile(library_path):
        temporary = library_path + ".%d.tmp" % os.getpid()
        try:
            if windows:
                _build_physics_msvc(source_dir, source, temporary)
            else:
                command = shlex.split(os.environ.get("CC", "cc")) + [
                    "-O3", "-std=c11", "-fPIC", "-shared", "-I", source_dir,
                    "-o", temporary, source, "-lm"]
                subprocess.run(command, check=True, capture_output=True, text=True)
            try:
                os.replace(temporary, library_path)
            except OSError:
                if not os.path.isfile(library_path):
                    raise
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
    library = ctypes.CDLL(library_path)
    matrix = (ctypes.c_double * 3) * 3
    library.phys_set_gravity.argtypes = [ctypes.c_int, ctypes.c_int]
    library.phys_set_drag.argtypes = [ctypes.c_double] * 4
    library.phys_set_earth.argtypes = [ctypes.POINTER(matrix), ctypes.c_double,
                                       ctypes.c_double, ctypes.c_double]
    library.phys_advance_to.argtypes = [ctypes.POINTER(_PhysState), ctypes.c_double,
                                       ctypes.c_double, ctypes.c_void_p, ctypes.c_void_p]
    library.phys_advance_to.restype = None
    return library, matrix


class FD13Propagator:
    """Propagate an M50 r/v state with the flight's rotating 4x4 gravity."""

    def __init__(self, epoch_state, rnp=(2011, 136), max_step_s=15.0,
                 drag_cd=2.2, drag_areas_m2=(40.0, 220.0, 360.0)):
        self.library, matrix_type = _load_physics()
        year, day = map(int, rnp)
        gmt_zero = float(epoch_state["gmt"]) - float(epoch_state["t"])
        matrix = pass_rnp(year, day)
        earth = matrix_type(*[(ctypes.c_double * 3)(*row) for row in matrix])
        self.library.phys_set_gravity(4, 4)
        self.drag = (float(drag_cd), *map(float, drag_areas_m2))
        self.library.phys_set_drag(*self.drag)
        self.library.phys_set_earth(ctypes.byref(earth), 0.0,
                                    day * 86400.0 - gmt_zero, PASS_EARTH_RATE)
        self.max_step_s = float(max_step_s)
        if self.max_step_s <= 0.0:
            raise ValueError("max_step_s must be positive")

    def advance(self, r, v, t, duration_s, q=(1.0, 0.0, 0.0, 0.0),
                w=(0.0, 0.0, 0.0), mass_kg=113000.0):
        """Return (r, v, q, w) after a coast in simulator time."""
        duration_s = float(duration_s)
        if duration_s < 0.0:
            raise ValueError("FD13 propagation cannot run backward")
        # physics.c keeps model settings in process-global state. Reassert this
        # propagator's coefficients before every advance so independent model
        # instances cannot silently affect each other.
        self.library.phys_set_drag(*self.drag)
        state = _PhysState()
        state.t = float(t)
        state.mass = float(mass_kg)
        if state.mass <= 0.0:
            raise ValueError("mass_kg must be positive")
        for i in range(4):
            state.q[i] = float(q[i])
        for i in range(3):
            state.w[i] = float(w[i])
        for i in range(3):
            state.r[i] = float(r[i])
            state.v[i] = float(v[i])
            state.I[i][i] = 1.0
        self.library.phys_advance_to(ctypes.byref(state), state.t + duration_s,
                                     self.max_step_s, None, None)
        return (list(state.r), list(state.v), list(state.q), list(state.w))
