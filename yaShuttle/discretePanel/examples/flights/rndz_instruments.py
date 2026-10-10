#!/usr/bin/env python3
"""THE CREW'S RENDEZVOUS INSTRUMENTS OUTSIDE THE GPC (RENDEZVOUS_PLAN.md,
Stage 4), from the truth: what the hand-held laser (HHL), the Trajectory
Control Sensor (TCS), the -Z crewman optical alignment sight (COAS) and the
ODS centerline camera would show, each with its own noise.  PASS sees none of
it; the scripted crew (fly_rndz134.py's manual phase) flies on it, as the
crew did from MC4 on.

    readings = Instruments(seed).read(tru, tgt)

`tru` is TRU1 as fly_rndz134.Ears keeps it (r, v M50 m and m/s of the
current centre of mass, q body -> M50, w body rad/s, and `cg`, that centre
of mass as an offset from the dry CG, body m); `tgt` is TGT1 (the ISS's
centre of mass r, v, and q, its body -> M50, ISS frame +X forward, +Z nadir).

THE GEOMETRY.  Body axes are vehdyn's, origin at the Orbiter's dry CG
(X_o 1100, Y_o 0, Z_o 375), +X forward, +Y right, +Z down; structural
X_o/Z_o inches turn into them as portview's _structural does.
  - ODS_XO, ODS_ZO: the APDS docking ring's axis and face (Shuttle Systems
    Handbook Vol 3, ODS structural overview; SCOM 2.20 pp. 681-682; Flight
    Rules A10-385; via PASS-IDLE, 2026-10-09).  The axis is at X_o 649.00,
    Y_o 0 -- X_o 576, used before, is the airlock's bulkhead.  Along the
    axis (+Z_o, body -Z) the ring's face is at Z_o 475.75 ready to dock (at
    contact), 480.00 fully extended and 460.00 hard-mated (retracted);
    ODS_ZO is the ready-to-dock face, ODS_HARDMATE_ZO the retracted one.
  - CLCAM_XO, CLCAM_ZO: the ODS centerline camera, on the ring's axis at
    Z_o 422.85, looking +Z_o (body -Z) (X_o 649 for STS-134; the drawing's
    X_o 731.60 is the Mir layout).
  - TCS_XO, TCS_YO, TCS_ZO: the TCS head, Mir layout X_o 682.28, Y_o -7.45,
    Z_o 415.31, moved X_o -82.6 with the ODS for STS-134: X_o 599.68.
  - PMA2: PMA-2's docking face in the ISS frame, portview's ISS_PMA2 (the
    model's), its axis the ISS's +X.  The TCS reflectors sit around it; the
    TCS ranges to their centroid, taken as the face itself.
  - HHL: the crew aims it at the station's structure; it ranges to the
    nearest point of a 25 m sphere about the ISS's centre of mass, which is
    what "range to the ISS" meant to them at a few hundred feet and is the
    range the cue cards' gates are read against (CG range less ~80 ft).

THE NOISE (1 sigma; estimates, no document figures here):
  - HHL: range 0.5 ft + 0.1 %, range rate 0.02 ft/s (from two readings 5 s
    apart), usable inside 5,000 ft.
  - TCS: range 0.1 ft + 0.05 %, range rate 0.005 ft/s, bearing 0.03 deg,
    acquired inside 10,000 ft (AUTO ACQ, RPOP), in front of the -Z hemisphere.
  - COAS: the crew's reading of the reticle, 0.1 deg; its field 10 deg.
  - Centerline camera: alignment read off the target's cross and standoff,
    0.05 deg and 0.05 ft; it sees the target inside 50 deg of its axis.
"""
import math
import random

FT = 0.3048
IN = 0.0254
DRY_CG_XO, DRY_CG_ZO = 1100.0, 375.0
ODS_XO, ODS_ZO = 649.00, 475.75           # the ring's axis; its face ready to dock
ODS_HARDMATE_ZO = 460.00                    # the face retracted, hard-mated
CLCAM_XO, CLCAM_ZO = 649.00, 422.85         # the centerline camera, on the ring's axis
TCS_XO, TCS_YO, TCS_ZO = 599.68, -7.45, 415.31


def structural(xo, yo, zo):
    """Structural inches -> body metres from the dry CG (+X fwd, +Y right, +Z down)."""
    return (-(xo - DRY_CG_XO) * IN, yo * IN, -(zo - DRY_CG_ZO) * IN)


ODS_BODY = structural(ODS_XO, 0.0, ODS_ZO)
ODS_HARDMATE_BODY = structural(ODS_XO, 0.0, ODS_HARDMATE_ZO)
CLCAM_BODY = structural(CLCAM_XO, 0.0, CLCAM_ZO)
TCS_BODY = structural(TCS_XO, TCS_YO, TCS_ZO)
PMA2 = (15.655, 0.0, 5.562)                # ISS frame, m: portview.ISS_PMA2 (the model's own PMA-2)
HHL_SPHERE_M = 25.0
TCS_MAX_FT, HHL_MAX_FT = 10000.0, 5000.0


def dot(a, b): return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
def sub(a, b): return [a[i] - b[i] for i in range(3)]
def add(a, b): return [a[i] + b[i] for i in range(3)]
def mul(k, a): return [k * x for x in a]
def norm(a): return math.sqrt(dot(a, a))
def cross(a, b): return [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]


def qmat(q):
    """body -> M50 rotation matrix of a w x y z quaternion; columns are the
    body axes in M50."""
    w, x, y, z = q
    return [[1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y)],
            [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x)],
            [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y)]]


def to_m50(R, b): return [R[i][0] * b[0] + R[i][1] * b[1] + R[i][2] * b[2] for i in range(3)]
def to_body(R, m): return [R[0][j] * m[0] + R[1][j] * m[1] + R[2][j] * m[2] for j in range(3)]


def lvlh_axes(r, v):
    """An orbit's LVLH unit vectors in M50: x along, y -orbit normal, z down."""
    ez = mul(-1.0 / norm(r), r)
    h = cross(r, v)
    ey = mul(-1.0 / norm(h), h)
    ex = cross(ey, ez)
    return ex, ey, ez


def orbital_rate(r, v):
    return norm(cross(r, v)) / dot(r, r)


def body_point(tru, Ro, b):
    """A point fixed in the Orbiter (body m from the dry CG): M50 position
    and velocity, from the truth's c.g. offset and body rate."""
    arm_m = to_m50(Ro, sub(list(b), list(tru.get("cg") or (0.0, 0.0, 0.0))))
    w_m = to_m50(Ro, list(tru.get("w") or (0.0, 0.0, 0.0)))
    return add(list(tru["r"]), arm_m), add(list(tru["v"]), cross(w_m, arm_m))


def points(tru, tgt):
    """The ODS ring and PMA-2's face, M50 position (m) and velocity (m/s),
    and the two bodies' rotation matrices."""
    Ro, Rt = qmat(tru["q"]), qmat(tgt["q"])
    ods_r, ods_v = body_point(tru, Ro, ODS_BODY)
    pma_arm = to_m50(Rt, list(PMA2))
    # the ISS turns at the orbital rate (LVLH hold): about its -Y in LVLH
    n = orbital_rate(tgt["r"], tgt["v"])
    _, ey, _ = lvlh_axes(tgt["r"], tgt["v"])
    pma_r = add(list(tgt["r"]), pma_arm)
    pma_v = add(list(tgt["v"]), cross(mul(-n, ey), pma_arm))
    return Ro, Rt, ods_r, ods_v, pma_r, pma_v


class Instruments(object):
    def __init__(self, seed=134):
        self.rng = random.Random(seed)

    def g(self, s):
        return self.rng.gauss(0.0, s)

    def read(self, tru, tgt):
        Ro, Rt, ods_r, ods_v, pma_r, pma_v = points(tru, tgt)
        out = {}
        # HHL: to the station's nearest structure
        d = sub(list(tgt["r"]), list(tru["r"]))
        dv = sub(list(tgt["v"]), list(tru["v"]))
        rng_cg = norm(d)
        rdot_cg = dot(d, dv) / rng_cg
        hhl = (rng_cg - HHL_SPHERE_M) / FT
        if hhl < HHL_MAX_FT:
            out["hhl_range_ft"] = hhl + self.g(0.5 + 0.001 * hhl)
            out["hhl_rdot_fps"] = rdot_cg / FT + self.g(0.02)
        # TCS: to the reflectors at PMA-2, from its own head in the bay
        tcs_r, tcs_v = body_point(tru, Ro, TCS_BODY)
        tl = sub(pma_r, tcs_r)
        trng = norm(tl)
        trdot = dot(tl, sub(pma_v, tcs_v)) / trng
        tb = to_body(Ro, tl)
        if trng / FT < TCS_MAX_FT and tb[2] < 0.0:
            el = math.degrees(math.atan2(math.hypot(tb[0], tb[1]), -tb[2]))   # off -Z
            out["tcs_range_ft"] = trng / FT + self.g(0.1 + 0.0005 * trng / FT)
            out["tcs_rdot_fps"] = trdot / FT + self.g(0.005)
            out["tcs_bearing_deg"] = (math.degrees(math.atan2(tb[1], -tb[2])) + self.g(0.03),
                                      math.degrees(math.atan2(-tb[0], -tb[2])) + self.g(0.03))
            out["tcs_off_axis_deg"] = el
        # the ring's face to PMA-2's: what "100 ft out" and the lineup are read against
        los = sub(pma_r, ods_r)
        lb = to_body(Ro, los)
        # COAS (-Z): the ISS's centre in the reticle, H right V up (deg)
        cb = to_body(Ro, d)
        if cb[2] < 0.0:
            h = math.degrees(math.atan2(cb[1], -cb[2]))
            v = math.degrees(math.atan2(-cb[0], -cb[2]))
            if abs(h) < 10.0 and abs(v) < 10.0:
                out["coas_deg"] = (h + self.g(0.1), v + self.g(0.1))
        # The centerline camera: PMA-2 in the picture, and the two axes' misalignment
        if lb[2] < 0.0 and math.degrees(math.atan2(math.hypot(lb[0], lb[1]), -lb[2])) < 50.0:
            # lateral offsets of PMA-2's face from the ODS axis (ft), the
            # camera's +X (Orbiter -X) right and +Y (Orbiter +Y) ...
            out["cl_offset_ft"] = (lb[1] / FT + self.g(0.05), -lb[0] / FT + self.g(0.05))
            out["cl_range_ft"] = -lb[2] / FT                         # ring face to PMA-2's face
            cam_r, _ = body_point(tru, Ro, CLCAM_BODY)
            out["cl_cam_range_ft"] = -to_body(Ro, sub(pma_r, cam_r))[2] / FT
            # misalignment: PMA-2's axis (ISS +X) against the ODS's (-Z body),
            # in the Orbiter's body: pitch about Y, yaw about X; roll about Z
            # is the ISS +Z (nadir) against the Orbiter's -X, which the
            # docking attitude puts there (nose to the zenith, bay to the
            # ISS: fly_rndz134's VBAR)
            ax = to_body(Ro, [Rt[i][0] for i in range(3)])         # ISS +X in Orbiter body
            nz = to_body(Ro, [Rt[i][2] for i in range(3)])         # ISS +Z in Orbiter body
            out["cl_pitch_deg"] = math.degrees(math.atan2(ax[0], ax[2])) + self.g(0.05)
            out["cl_yaw_deg"] = math.degrees(math.atan2(ax[1], ax[2])) + self.g(0.05)
            out["cl_roll_deg"] = math.degrees(math.atan2(nz[1], -nz[0])) + self.g(0.05)
        return out


def fmt(rd):
    """One line of the readings, for the logs."""
    p = []
    if "hhl_range_ft" in rd:
        p.append("HHL %.1f ft %+.2f ft/s" % (rd["hhl_range_ft"], rd["hhl_rdot_fps"]))
    if "tcs_range_ft" in rd:
        p.append("TCS %.1f ft %+.3f ft/s brg %+.2f %+.2f deg" % (rd["tcs_range_ft"], rd["tcs_rdot_fps"],
                                                                  *rd["tcs_bearing_deg"]))
    if "coas_deg" in rd:
        p.append("COAS H %+.1f V %+.1f deg" % rd["coas_deg"])
    if "cl_offset_ft" in rd:
        p.append("CL cam off %+.1f %+.1f ft, P %+.1f Y %+.1f R %+.1f deg"
                 % (*rd["cl_offset_ft"], rd["cl_pitch_deg"], rd["cl_yaw_deg"], rd["cl_roll_deg"]))
    return "; ".join(p) if p else "(nothing in view)"
