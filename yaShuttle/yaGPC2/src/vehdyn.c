#include "vehdyn.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <time.h>

#include "envcache.h"
#include "eiumodel.h"
#include "mecmodel.h"

/* =====================================================================
 * THE JETS.
 *
 * Positions are Orbiter structural coordinates in inches -- Xo increasing
 * aft from a point ahead of the nose (the nose is at Xo 238), Yo to the
 * right, Zo up -- and converted below to body axes about the centre of
 * gravity.  27 of the 38 primaries are MEASURED: Table 2-1 of "Space Shuttle
 * Orbiter Reaction Control System Interactions With the Vehicle Flow Field"
 * (test IA148, configuration 102 lines), decoded against the Draper "RCS Jet
 * Locations and Plume Directions" figure (from STS 81-0009).  The rest are
 * ESTIMATED from symmetry and the figures and marked so; they are the
 * forward-firing F1F/F2F/F3F, the aft-firing L1A/L3A/R1A/R3A, L1L/R1R (a
 * dummy nozzle in the test), F2R/F4R (mirrors of F1L/F3L) and the six
 * verniers.  JSC-19350, the I-load document that has the true values, is not
 * available.
 *
 * Direction is opposite the plume, which the jet's last letter names (the
 * Draper legend): A aft plume, +X thrust; F fore plume, -X; L left plume,
 * +Y; R right plume, -Y; U up plume, +Z (body Z is down); D down plume, -Z.
 * The real jets are canted a few degrees off these axes; that is not
 * modelled.
 *
 * The fire bit is the jet's place in its MDM's B word (GRORCS.hal:138-151,
 * GRRRCS.hal:283-373, GP1ORB.hal:104-108).
 * ===================================================================== */
typedef struct {
    const char *name;
    char mdm;            /* 'F' forward, 'A' aft */
    int unit;            /* MDM 1-4 */
    uint16_t bit;
    double xo, yo, zo;   /* inches, Orbiter structural */
    bool vernier;
    bool estimated;
} Jet;

static const Jet JETS[VEHDYN_NJETS] = {
    /* forward module */
    { "F1F", 'F', 1, 0x8000, 325.0, -14.0, 390.0, false, true  },
    { "F1L", 'F', 1, 0x4000, 362.819, -69.538, 373.634, false, false },
    { "F1U", 'F', 1, 0x2000, 350.542, -14.091, 413.244, false, false },
    { "F1D", 'F', 1, 0x1000, 335.982, -63.481, 356.600, false, false },
    { "F2F", 'F', 2, 0x8000, 325.0,  14.0, 390.0, false, true  },
    { "F2R", 'F', 2, 0x4000, 362.819,  69.538, 373.634, false, true  },
    { "F2U", 'F', 2, 0x2000, 350.542,  14.091, 413.244, false, false },
    { "F2D", 'F', 2, 0x1000, 335.982,  63.481, 356.600, false, false },
    { "F4R", 'F', 3, 0x8000, 364.814,  71.484, 359.506, false, true  },
    { "F4D", 'F', 3, 0x4000, 349.971,  67.581, 357.543, false, false },
    { "F5L", 'F', 3, 0x2000, 345.0, -66.0, 352.0, true,  true  },
    { "F5R", 'F', 3, 0x1000, 345.0,  66.0, 352.0, true,  true  },
    { "F3F", 'F', 4, 0x8000, 325.0,   0.0, 392.0, false, true  },
    { "F3L", 'F', 4, 0x4000, 364.814, -71.484, 359.506, false, false },
    { "F3U", 'F', 4, 0x2000, 350.524,   0.0, 414.231, false, false },
    { "F3D", 'F', 4, 0x1000, 349.971, -67.581, 357.543, false, false },
    /* aft: FA1 */
    { "L1A", 'A', 1, 0x8000, 1565.0, -132.0, 480.0, false, true  },
    { "L1L", 'A', 1, 0x4000, 1555.0, -149.55, 459.04, false, true  },
    { "L1U", 'A', 1, 0x2000, 1542.00, -132.00, 498.56, false, false },
    { "R1A", 'A', 1, 0x1000, 1565.0,  132.0, 480.0, false, true  },
    { "R1R", 'A', 1, 0x0800, 1555.0,  149.55, 459.04, false, true  },
    { "R1U", 'A', 1, 0x0400, 1542.00,  132.00, 498.56, false, false },
    { "L5D", 'A', 1, 0x0200, 1560.0, -118.0, 420.0, true,  true  },
    { "L5L", 'A', 1, 0x0100, 1560.0, -149.55, 445.0, true,  true  },
    /* FA2 */
    { "L3A", 'A', 2, 0x8000, 1565.0, -132.0, 465.0, false, true  },
    { "L3L", 'A', 2, 0x4000, 1542.00, -149.55, 459.04, false, false },
    { "L3D", 'A', 2, 0x2000, 1544.56, -114.40, 430.72, false, false },
    { "R3A", 'A', 2, 0x1000, 1565.0,  132.0, 465.0, false, true  },
    { "R3R", 'A', 2, 0x0800, 1542.00,  149.55, 459.04, false, false },
    { "R3D", 'A', 2, 0x0400, 1544.56,  114.40, 430.72, false, false },
    { "R5R", 'A', 2, 0x0200, 1560.0,  149.55, 445.0, true,  true  },
    { "R5D", 'A', 2, 0x0100, 1560.0,  118.0, 420.0, true,  true  },
    /* FA3 */
    { "L2L", 'A', 3, 0x8000, 1529.04, -149.55, 459.04, false, false },
    { "L2U", 'A', 3, 0x4000, 1529.04, -132.00, 498.56, false, false },
    { "L2D", 'A', 3, 0x2000, 1531.52, -115.28, 452.40, false, false },
    { "R2R", 'A', 3, 0x1000, 1529.04,  149.55, 459.04, false, false },
    { "R2U", 'A', 3, 0x0800, 1529.04,  132.00, 498.56, false, false },
    { "R2D", 'A', 3, 0x0400, 1531.52,  115.28, 452.40, false, false },
    /* FA4 */
    { "L4L", 'A', 4, 0x8000, 1516.00, -149.55, 459.04, false, false },
    { "L4U", 'A', 4, 0x4000, 1516.00, -132.00, 498.56, false, false },
    { "L4D", 'A', 4, 0x2000, 1518.56, -115.92, 425.52, false, false },
    { "R4R", 'A', 4, 0x1000, 1516.00,  149.55, 459.04, false, false },
    { "R4U", 'A', 4, 0x0800, 1516.00,  132.00, 498.56, false, false },
    { "R4D", 'A', 4, 0x0400, 1518.56,  115.92, 425.52, false, false },
};

/* THRUST AND SPECIFIC IMPULSE.  Primary 870 lbf (TD0340 RCS training manual;
 * the flight software's own nominal is 877.2 lbf, CGGC01.hal:662) = 3870 N;
 * vernier 24 lbf = 106.8 N.  Vacuum Isp: primary 280 s, vernier 228 s --
 * published nominal values, not from the flight software. */
#define LBF_N            4.4482216152605
#define JET_PRI_N        (870.0 * LBF_N)
#define JET_VER_N        (24.0 * LBF_N)
#define ISP_PRI_S        280.0
#define ISP_VER_S        228.0
#define G0               9.80665
#define IN_M             0.0254
#define VD_PI            3.14159265358979323846

/* =====================================================================
 * MASS PROPERTIES.  An on-orbit Orbiter WITHOUT its RCS propellant, then
 * the three RCS modules' propellant as point masses at their tanks.
 *
 * Dry: 100,000 kg about a centre of gravity at Xo 1100, Yo 0, Zo 375 --
 * typical on-orbit values -- with principal inertias 1.29e6, 9.68e6,
 * 1.01e7 kg m^2 (the textbook on-orbit figures) and no products of inertia.
 * RCS propellant: about 1,460 kg usable per module (forward, left pod,
 * right pod), oxidizer and fuel together, at Xo 375 Zo 400 forward and
 * Xo 1510 Yo -/+105 Zo 465 in the pods.  ALL APPROXIMATE; they set the
 * scale of the response, not its form, and are meant to be replaced by
 * better numbers as they are found.
 * ===================================================================== */
#define DRY_MASS_KG      100000.0
/* YAGPC_VEHDYN_ORBITER_KG: a flight's orbiter at liftoff, kg, payload and
 * full OMS and RCS included (STS-134: 121,826 kg, JSC 37461 / spacefacts);
 * the dry mass is what is left after the propellant modelled below. */
static double dryKg = DRY_MASS_KG;
#define DRY_CG_XO        1100.0
#define DRY_CG_ZO        375.0
#define DRY_IXX          1.29e6
#define DRY_IYY          9.68e6
#define DRY_IZZ          1.01e7
#define RCS_LOAD_KG      1460.0

/* THE OMS PROPELLANT, modules 3 (left pod) and 4 (right): "1% OMS = 130
 * lb/side" (SCOM 2.18), so 13,000 lb = 5,897 kg a pod at 100%, as a point
 * mass at the pod's tanks -- the position ESTIMATED, forward of and level
 * with the engines. */
#define OMS_LOAD_KG      5897.0
#define NMOD             5

static const double TANK_XYZ[NMOD][3] = {  /* inches, Orbiter structural */
    {  375.0,    0.0, 400.0 },
    { 1510.0, -105.0, 465.0 },
    { 1510.0,  105.0, 465.0 },
    { 1400.0,  -88.0, 480.0 },
    { 1400.0,   88.0, 480.0 },
};

/* =====================================================================
 * THE OMS ENGINES.  6,087 lbf (27.08 kN) each, CGGS_OMS_THRUST_NOM; exhaust
 * velocity CGGS_VEX_ORB 10,136.8 ft/s, an Isp of 315.1 s -- both the flight
 * software's own I-loads (DASS G2/G3).  Thrust direction in body axes is
 * (cos P cos Y, sin Y, sin P cos Y) with P = 15.82 deg - pitch gimbal and
 * Y = yaw gimbal + 6.50 deg left, - 6.50 deg right (GHBCMD.hal:253-302): each
 * nozzle canted down and inboard so the thrust passes near the centre of
 * gravity.  The mounts, Xo 1518, Yo -/+88, Zo 492, are NOT from a document
 * found here; they are consistent with those cants, whose lines cross the
 * dry CG's Zo 375 and the centreline near its Xo 1100.
 *
 * The gimbals follow the command of whichever actuator controller is
 * powered, at OMS_SLEW_DEG_S -- a rate not found in any document, chosen to
 * keep up with PASS's 2-degree, 24-pass servo check -- and stop at the
 * mechanical limits, +/-7 deg pitch and +/-8 deg yaw (SCOM 2.18-21: +/-6 and
 * +/-7 plus about a degree of snubbing).  Unpowered, they stay where they
 * are.  The engine fires while its valves are commanded open (mdmdev.c
 * decides that from the coils and the ARM switches) and its pod has
 * propellant.  It starts at once, but it does not stop at once: the
 * propellant between the valves and the injector still burns, and the flight
 * software allows for exactly that -- it commands cutoff CGGV_TCO_BIAS =
 * 0.398 s early (GHOORB.hal:238-246, DASS G2) so the tail-off impulse
 * finishes the burn.  The thrust here falls linearly to zero over twice that,
 * an impulse of 0.398 s at full thrust; an engine that stopped dead
 * underburned every maneuver by that much.  The shape is not documented
 * here, only the impulse PASS expects. */
#define OMS_THRUST_N     (6087.0 * LBF_N)
#define OMS_ISP_S        (10136.8 * 0.3048 / G0)
#define OMS_SLEW_DEG_S   5.0
#define OMS_CANT_P       0.276053
#define OMS_CANT_Y       0.113446
#define OMS_TAILOFF_S    (2.0 * 0.398)

static const double OMS_XYZ[2][3] = { { 1518.0, -88.0, 492.0 }, { 1518.0, 88.0, 492.0 } };
static struct {
    bool fire, powered;
    double cmd[2];       /* deg, pitch and yaw, as commanded */
    double pos[2];       /* deg, where the actuators are */
    double onSec;
    double tail;         /* s of tail-off still to come, after the valves close */
} oms[2];


static PhysState st;
static double gmtZero = -1.0;   /* PASS GMT seconds at t = 0; < 0 unknown */
static double unixZero = -1.0;  /* the Unix time at t = 0, the same clock with its year */
/* After a restore, the GMT the restored state belongs to, until the timing
 * unit says what GMT the restored clock's zero is (vehdyn_set_gmt_zero). */
static double restoredGmt = -1.0;

/* THE RECENT PAST: (t, r, v) after every step, so a sensor can report the
 * state at a moment just gone -- a GPS solution's time of validity -- by
 * cubic Hermite interpolation, which at the steps used here (<= 1 s coasting,
 * 5 ms under thrust) is exact to well under a millimetre. */
#define HIST_N 256
static struct { double t, r[3], v[3]; } hist[HIST_N];
static int histHead, histCount;

/* YAGPC_VEHDYN_STATELOG=<seconds>: the truth state every so often, in the
 * flight software's own units and frame -- M50 feet and feet a second, PASS
 * GMT -- to set beside its navigation state (CGNV_R_FILT_LFE and the rest,
 * read from a memory snapshot with tools/pasvar.py). */
static void ascent_log(void);
static void state_log(void) {
    static double every = -1.0, next = 0.0;
    if (every < 0.0) {
        const char *e = yagpc_getenv("YAGPC_VEHDYN_STATELOG");
        every = (e != NULL) ? atof(e) : 0.0;
    }
    if (every <= 0.0 || st.t < next) return;
    next = (floor(st.t / every) + 1.0) * every;
    double g = (gmtZero >= 0.0) ? gmtZero + st.t : -1.0;
    fprintf(stderr, "vehdyn-state: t=%.3f gmt=%.3f r_ft=%.1f %.1f %.1f v_fts=%.3f %.3f %.3f "
                    "mass_kg=%.1f\n", st.t, g,
            st.r[0] / 0.3048, st.r[1] / 0.3048, st.r[2] / 0.3048,
            st.v[0] / 0.3048, st.v[1] / 0.3048, st.v[2] / 0.3048, st.mass);
    ascent_log();
    /* in orbit: the osculating apsides -- nmi above the equatorial radius
     * and above the WGS-84 ellipsoid under each -- and the inclination to
     * the equator of date, to set beside a flight's published orbit */
    if (vehdyn_ascent_phase() == 0) {
        const double MU = 3.986004418e14, RE = 6378137.0, F = 1.0 / 298.257223563, NM = 1852.0;
        const double *r = st.r, *v = st.v;
        double rn = sqrt(r[0] * r[0] + r[1] * r[1] + r[2] * r[2]);
        double vv = v[0] * v[0] + v[1] * v[1] + v[2] * v[2], rv = r[0] * v[0] + r[1] * v[1] + r[2] * v[2];
        double h[3] = { r[1] * v[2] - r[2] * v[1], r[2] * v[0] - r[0] * v[2], r[0] * v[1] - r[1] * v[0] };
        double hn = sqrt(h[0] * h[0] + h[1] * h[1] + h[2] * h[2]), e[3], pole[3];
        for (int i = 0; i < 3; i++) e[i] = ((vv - MU / rn) * r[i] - rv * v[i]) / MU;
        double en = sqrt(e[0] * e[0] + e[1] * e[1] + e[2] * e[2]);
        double a = 1.0 / (2.0 / rn - vv / MU), ra = a * (1 + en), rp = a * (1 - en);
        phys_earth_pole(pole);
        double inc = acos((h[0] * pole[0] + h[1] * pole[1] + h[2] * pole[2]) / hn) * 180.0 / VD_PI;
        double sl = en > 1e-9 ? (e[0] * pole[0] + e[1] * pole[1] + e[2] * pole[2]) / en : 0.0;
        double gp = RE * (1.0 - F * sl * sl), ga = RE * (1.0 - F * sl * sl);  /* +/- e: same latitude magnitude */
        double sf[3];                  /* what the accelerometer assemblies feel, g */
        vehdyn_specific_force(sf);
        fprintf(stderr, "vehdyn-orbit: t=%.1f HA %.2f HP %.2f nmi (eq radius) HA %.2f HP %.2f nmi (ellipsoid) "
                        "inc %.3f deg (of date) sf_g=%.5f %.5f %.5f\n", st.t, (ra - RE) / NM, (rp - RE) / NM,
                (ra - ga) / NM, (rp - gp) / NM, inc, sf[0] / 9.80665, sf[1] / 9.80665, sf[2] / 9.80665);
    }
}

static void hist_push(void) {
    histHead = (histHead + 1) % HIST_N;
    hist[histHead].t = st.t;
    memcpy(hist[histHead].r, st.r, sizeof st.r);
    memcpy(hist[histHead].v, st.v, sizeof st.v);
    if (histCount < HIST_N) histCount++;
}
static double prop[5];                 /* kg left: RCS F, L, R; OMS L, R */
static double cgB[3];                  /* current CG, as an offset from the dry CG, body m */
static bool on[VEHDYN_NJETS];
static double onSec[VEHDYN_NJETS];
static double sensedDv[3];             /* inertial, m/s */
static bool haveTime;
static long fireChanges;

bool vehdyn_enabled(void) {
    static int inited = 0, enabled = 0;
    if (!inited) {
        inited = 1;
        const char *e = yagpc_getenv("YAGPC_VEHDYN");
        enabled = e != NULL && *e != '\0' && strcmp(e, "0") != 0 &&
                  strcasecmp(e, "off") != 0 && strcasecmp(e, "no") != 0 &&
                  strcasecmp(e, "false") != 0;
    }
    return enabled != 0;
}

/* Orbiter structural inches -> body metres relative to the DRY CG:
 * +X forward is -Xo, +Y right is +Yo, +Z down is -Zo. */
static void to_body(double xo, double yo, double zo, double b[3]) {
    b[0] = -(xo - DRY_CG_XO) * IN_M;
    b[1] =  yo * IN_M;
    b[2] = -(zo - DRY_CG_ZO) * IN_M;
}

static void jet_axis(const Jet *j, double u[3]) {
    u[0] = u[1] = u[2] = 0.0;
    switch (j->name[2]) {
    case 'A': u[0] =  1.0; break;
    case 'F': u[0] = -1.0; break;
    case 'L': u[1] =  1.0; break;
    case 'R': u[1] = -1.0; break;
    case 'U': u[2] =  1.0; break;
    case 'D': u[2] = -1.0; break;
    }
}

static int jet_module(const Jet *j) {
    if (j->mdm == 'F') return 0;
    return (j->name[0] == 'L') ? 1 : 2;
}

static double jet_thrust(const Jet *j) { return j->vernier ? JET_VER_N : JET_PRI_N; }
static double jet_mdot(const Jet *j) {
    return jet_thrust(j) / ((j->vernier ? ISP_VER_S : ISP_PRI_S) * G0);
}

static void mass_properties(void);
static void qmat_body(const double q[4], double R[3][3]);

/* =====================================================================
 * THE ASCENT: THE STACK ON THE PAD, IN FLIGHT, AND SHEDDING ITS PARTS.
 *
 * YAGPC_VEHDYN_PAD (simulatePASS --pad) starts the vehicle on the launch
 * pad instead of in orbit: the whole stack -- orbiter, external tank full,
 * both solid rocket boosters -- standing on its hold-down posts, fixed to the
 * turning Earth.  Then, as the flight software commands them:
 *
 *   ON THE PAD   held: it goes round with the Earth whatever the main
 *                engines do (their 1.1 Mlbf is less than the stack's weight,
 *                and the posts take the overturning moment); its
 *                accelerometers feel the pad's reaction, about 1 g up.
 *   LIFTOFF      when the master events controllers FIRE SRM IGNITION
 *                (mecmodel.c) -- the same command blows the hold-down nuts.
 *   SRB SEP      when they FIRE SRB SEPARATION: the boosters' mass goes.
 *   ET SEP       when they FIRE ET SEPARATION: the tank goes, and the
 *                orbiter flies on as the on-orbit model above it.
 *
 * Forces: the three SSMEs at the chamber pressure their controllers report
 * (eiumodel.c), less the back pressure on their nozzles, along their null
 * axes deflected by the gimbals PASS commands through the ATVCs (mdmdev.c's
 * decoding, vehdyn_set_tvc); the SRBs on a thrust-time profile from
 * ignition, through their rock/tilt nozzles; gravity (physics.c); and the
 * air, a crude axial-force model on a Mach table.  Mass flows out of the
 * tank and the boosters as they burn, and the mass properties follow.
 *
 * THE NUMBERS ARE IN ONE PLACE, below, each with where it came from, so
 * that better ones replace them.  Several are published round values or
 * estimates, said so.
 * ===================================================================== */

/* -- the pad: the flight software's own nav-base I-loads (CGGS_NAVBASE_LAT,
 * _LONG, _ALT in memory, CGNCOM.hal:208-213), so that its navigation, which
 * starts from them, starts from the truth.  Geodetic, WGS-84 here. */
#define PAD_LAT_RAD      0.49931150
#define PAD_LON_RAD      (-1.4068068)
#define PAD_ALT_M        (-2.4 * 0.3048)
/* The orbiter's heading on the pad: the azimuth (deg from north, toward
 * east) of body +Z, the belly, which faces the tank.  "-Z body points
 * south" (JSC-14483 Vol 3, STS-1 Ascent OFP, 4.2.1.21): belly north, 0.
 * YAGPC_VEHDYN_PAD_AZ. */
#define PAD_AZ_DEG_DEFAULT 0.0
/* The navigation base, where the IMUs are: Xo 404.5, Yo -0.8, Zo 422.6 --
 * the dry CG less GRW_R_NB_CG (57.959, -0.067, -3.967 ft, GRWIMU.hal:72). */
#define NB_XO 404.5
#define NB_YO (-0.8)
#define NB_ZO 422.6

/* -- the external tank and the boosters.  Frames: Xt = Xo + 741.0,
 * Zt = Zo + 336.5; the ET's axis and both SRBs' at Zo 63.5, the SRBs at
 * Yo -/+250.5 (JSC-08934 Vol 1 Rev E, SODB Table 2-1).  Masses are STS-134's
 * at SRB ignition (Space Shuttle Missions Summary, NASA 20110001406, App. A):
 * ET 1,657,445 lb, SRBs 1,298,824 and 1,299,313 lb.  The ET's split is not
 * given: SLWT inert 58,500 lb (SCOM), so 1,598,945 lb of propellant at SRB
 * ignition, plus the 13,860 lb the main engines burn on the pad here, is
 * 1,612,805 lb loaded -- shared at the engines' mixture ratio of 6.0 with
 * STS-134's 954 lb fuel bias (Missions Summary, STS-134 page) on the LH2.
 * (These were the tank's capacities, LO2 1,387,457 and LH2 234,265 lb, and
 * the pad burn was not drawn: the stack was 23,700 lb heavy at T-0.)
 * Stations (ESTIMATED from the geometry; they reproduce PASS's own
 * second-stage CG table): ET inert Xo 525, LO2 Xo 59, LH2 Xo 869.  SRBs:
 * 1,110 klb propellant (SCOM) and the rest inert, 1,299,069 lb each (the
 * mean of the two), CG Xo 975. */
#define ET_INERT_KG      (58500.0 * 0.45359237)
#define ET_LO2_KG        (fl.etLo2Lb * 0.45359237)
#define ET_LH2_KG        (fl.etLh2Lb * 0.45359237)
#define ET_AXIS_ZO       63.5
#define ET_INERT_XO      525.0
#define ET_LO2_XO        59.0
#define ET_LH2_XO        869.0
#define ET_RADIUS_M      4.2
#define SRB_INERT_KG     (fl.srbInertLb * 0.45359237)
#define SRB_PROP_KG      (1110000.0 * 0.45359237)
#define SRB_YO           250.5
#define SRB_AXIS_ZO      63.5
#define SRB_XO           975.0
/* the nozzle pivot Xt 2410.5 = Xo 1669.5, no cant (SODB Table 6.3.4-1);
 * exit area 16,660 in^2 (STS-1 OFP); Isp 266 s vacuum (SODB Table
 * 6.3.1-1) */
#define SRB_NOZ_XO       1669.5
#define SRB_ISP_VAC      266.0
#define SRB_AE_M2        (16660.0 * IN_M * IN_M)
#define SRB_RADIUS_M     1.85
/* -- the SSMEs: gimbal points (STS-1 OFP; SSV80-1; the tape's own engine
 * vectors CGCS_RME1..3 are these divided by 12) and null directions -- the
 * upper engine pitched 16 deg, the lower two 10 deg and 3.5 deg outboard
 * (SCOM; SSV80-1): thrust forward and toward the tank.  100% = 470,000 lbf
 * vacuum (CGGS_SSME_THRUST_NOM); exit area 6,461 in^2, which gives the
 * sea-level 375,000 lbf.  Isp 452.07 s, STS-134's predicted average at
 * 104.5% (JSC 37461 sec. SSME): the controller holds the thrust, so the
 * flow is the thrust over it, 1,039.7 lb/s at 100% -- PASS's own I-loads
 * (1,032.5 lb/s, 455.2 s) are its nominal model, not the engines. */
static const double ME_XYZ[3][3] = { { 1445.0, 0.0, 443.0 }, { 1468.17, -53.0, 342.64 },
                                     { 1468.17, 53.0, 342.64 } };
static const double ME_CANT_P[3] = { 16.0, 10.0, 10.0 };   /* deg, thrust toward +Z body */
static const double ME_CANT_Y[3] = { 0.0, 3.5, -3.5 };     /* deg, thrust toward +Y body: outboard
                                                               nozzle, inboard thrust */
#define ME_TVAC_N        (470000.0 * LBF_N)
#define ME_ISP_VAC       (fl.isp)
#define ME_AE_M2         (6461.0 * IN_M * IN_M)
#define ME_LIM_P         10.5
#define ME_LIM_Y         8.5
#define SRB_LIM          5.0
#define TVC_RATE_DEG_S   10.0
/* Sign conventions of the gimbal commands (+1 or -1), which the documents
 * found here could not show (their figures did not survive): set by the
 * flight software's own behaviour -- the wrong sign makes its loop diverge
 * within seconds of liftoff.  PITCH, main engines and boosters both: -1.
 * With +1 PASS drove the nozzles to their stops at liftoff while the pitch
 * rate ran away the same way (-0.5, -3, -10, -32 deg/s in four seconds);
 * with -1 it held the stack to 0.2 deg/s and flew the pitch-over.  YAW +1:
 * the roll program and the yaw steering through max-q stay under 1 deg/s.
 * YAGPC_VEHDYN_TVC_SIGNS=mp,my,sp,sy overrides. */
static double tvcSign[4] = { -1, 1, -1, 1 };
static void tvc_signs(void) {          /* read once, whether the pad was set up or restored */
    static bool done = false;
    if (done) return;
    done = true;
    const char *sg = yagpc_getenv("YAGPC_VEHDYN_TVC_SIGNS");
    if (sg != NULL)
        sscanf(sg, "%lf,%lf,%lf,%lf", &tvcSign[0], &tvcSign[1], &tvcSign[2], &tvcSign[3]);
}

/* The SRBs' thrust, each, in vacuum, against time from ignition: the RSRM
 * population nominal at 60 F (burn rate 0.368 in/s at 625 psia), digitized
 * from JSC-19041 SRB Overview Rev F (2003) Figure 4.3-I, with a 0.3 s
 * ignition ramp.  (The earlier table was SODB JSC-08934 Fig 6.3.1-2, the
 * pre-Challenger HPM, whose tail-off is about 3 s longer: it put Pc 50 psia
 * at +123.4 and staging at +129.8, where STS-134's RSRMs reached 50 psia at
 * +120.0/+120.3 and staged at +124.7 -- JSC 37461 Appendix A; PMBT 62 F.)
 * Its integral, 295 Mlbf s, is the 1,110,000 lb of propellant at Isp 266 s
 * to 0.1%, so it is not scaled. */
static const double SRB_T[][2] = {   /* s, Mlbf */
    { 0.0, 0.0 }, { 0.3, 3.132 }, { 1, 3.134 }, { 3, 3.145 }, { 5, 3.199 }, { 7, 3.251 },
    { 10, 3.282 }, { 15, 3.294 }, { 20, 3.312 }, { 21, 3.312 }, { 22, 3.289 }, { 25, 3.125 },
    { 30, 2.925 }, { 35, 2.764 }, { 40, 2.618 }, { 45, 2.507 }, { 48, 2.441 }, { 50, 2.382 },
    { 52, 2.363 }, { 55, 2.382 }, { 60, 2.447 }, { 65, 2.503 }, { 70, 2.553 }, { 75, 2.575 },
    { 77, 2.576 }, { 78, 2.572 }, { 80, 2.524 }, { 85, 2.388 }, { 88, 2.281 }, { 90, 2.207 },
    { 92, 2.183 }, { 95, 2.115 }, { 100, 1.980 }, { 105, 1.803 }, { 108, 1.718 }, { 110, 1.652 },
    { 111, 1.566 }, { 112, 1.435 }, { 113, 1.257 }, { 114, 1.033 }, { 115, 0.824 },
    { 116, 0.660 }, { 117, 0.537 }, { 118, 0.433 }, { 119, 0.350 }, { 120, 0.272 },
    { 121, 0.200 }, { 122, 0.146 }, { 123, 0.103 }, { 124, 0.074 }, { 125, 0.049 },
    { 127, 0.0 } };
#define SRB_SCALE 1.0
/* STS-134's motors (RSRM-113, PMBT 62 F) reached 50 psia at T+119.95 and
 * +120.31 (JSC 37461 App. A), 0.9 s ahead of the population nominal: the
 * trace is run 0.74% fast, its thrust 0.74% up, the impulse unchanged. */
#define SRB_TSCALE (fl.pc50 / 121.0)

/* THE FLIGHT: the values above that differ from flight to flight, STS-134's
 * by default, each overridable from the environment so another flight can
 * be flown with the same model (Space Shuttle Missions Summary App. A and
 * the flight's mission report give them):
 *   YAGPC_VEHDYN_ET_LB         ET at SRB ignition, inert and propellant, lb
 *   YAGPC_VEHDYN_FUEL_BIAS_LB  the flight's fuel bias, lb (LH2 beyond MR 6.0)
 *   YAGPC_VEHDYN_SRB_LB        each SRB at SRB ignition, lb
 *   YAGPC_VEHDYN_SRB_PC50_S    the SRMs' 50 psia time after ignition, s
 *   YAGPC_VEHDYN_SSME_ISP      the SSMEs' predicted Isp tag value, s
 * The ET's split assumes the SLWT's 58,500 lb inert and the 13,860 lb the
 * main engines burn on the pad here. */
static struct {
    double etLo2Lb, etLh2Lb, srbInertLb, pc50, isp;
} fl = { 1381587.0, 231218.0, 189069.0, 120.13, 452.07 };
static void flight_params(void) {
    static bool done = false;
    if (done) return;
    done = true;
    const char *e;
    double etLb = 1657445.0, bias = 954.0;
    if ((e = yagpc_getenv("YAGPC_VEHDYN_ET_LB")) != NULL) etLb = atof(e);
    if ((e = yagpc_getenv("YAGPC_VEHDYN_FUEL_BIAS_LB")) != NULL) bias = atof(e);
    double loaded = etLb - 58500.0 + 13860.0;
    fl.etLh2Lb = (loaded - bias) / 7.0 + bias;
    fl.etLo2Lb = (loaded - bias) * 6.0 / 7.0;
    if ((e = yagpc_getenv("YAGPC_VEHDYN_SRB_LB")) != NULL) fl.srbInertLb = atof(e) - 1110000.0;
    if ((e = yagpc_getenv("YAGPC_VEHDYN_SRB_PC50_S")) != NULL) fl.pc50 = atof(e);
    if ((e = yagpc_getenv("YAGPC_VEHDYN_SSME_ISP")) != NULL) fl.isp = atof(e);
    fprintf(stderr, "vehdyn: flight: ET %.0f lb at SRB ignition (LO2 %.0f, LH2 %.0f loaded), "
                    "SRBs %.0f lb, SRM 50 psia at %.2f s, SSME Isp %.2f s\n",
            etLb, fl.etLo2Lb, fl.etLh2Lb, fl.srbInertLb + 1110000.0, fl.pc50, fl.isp);
}
#define SRB_NT (int)(sizeof SRB_T / sizeof SRB_T[0])

/* The air on the stack, on the orbiter's wing reference area, 2,690 ft^2.
 * From STS-1's ascent OFP (JSC-14483, 78-FM-51 Vol. III, Cycle 3, May
 * 1980), whose aerodynamics are the IA156 wind-tunnel data of the Mated
 * Vehicle ADDB, SD72-SH-0060-2K (sec. 5.2): its nominal ascent plotted
 * against time the forebody axial and normal force coefficients (fig.
 * 6.2-1(ww)), the angle of attack (o), the Mach number (l), the dynamic
 * pressure (k) and the base drag in pounds (yy), here digitized and put on
 * Mach.  The axial force the OFP plots (zz) is CA q S plus that base drag
 * to a few percent, so the base force is an extra term, as here; it is
 * power-on (the plumes lower the base pressure), and its coefficient on
 * the OFP's q is a function of Mach along STS-1's trajectory only.  The
 * thrust convention matches SVDS's: vacuum thrust less p_amb Ae. */
#define ASC_SREF_M2      (2690.0 * 0.09290304)
static const double CA_TAB[][2] = {   /* forebody, (ww) */
    { 0.0, 0.085 }, { 0.3, 0.100 }, { 0.4, 0.111 }, { 0.6, 0.113 }, { 0.74, 0.122 },
    { 0.83, 0.137 }, { 0.89, 0.151 }, { 0.95, 0.171 }, { 0.97, 0.209 }, { 1.03, 0.239 },
    { 1.08, 0.255 }, { 1.15, 0.268 }, { 1.21, 0.286 }, { 1.3, 0.290 }, { 1.7, 0.293 },
    { 2.0, 0.287 }, { 2.2, 0.258 }, { 2.42, 0.252 }, { 2.7, 0.239 }, { 3.0, 0.231 },
    { 3.35, 0.217 }, { 3.6, 0.211 }, { 10.0, 0.211 } };
#define CA_NT (int)(sizeof CA_TAB / sizeof CA_TAB[0])
static const double CAB_TAB[][2] = {  /* base, (yy) / (q S) */
    { 0.0, 0.23 }, { 0.3, 0.23 }, { 0.41, 0.180 }, { 0.53, 0.162 }, { 0.62, 0.153 },
    { 0.74, 0.151 }, { 0.83, 0.161 }, { 0.89, 0.206 }, { 0.95, 0.195 }, { 0.97, 0.168 },
    { 1.03, 0.140 }, { 1.15, 0.118 }, { 1.3, 0.081 }, { 1.43, 0.064 }, { 1.61, 0.040 },
    { 1.86, 0.026 }, { 2.0, 0.021 }, { 2.23, 0.010 }, { 2.42, -0.004 }, { 2.7, -0.013 },
    { 3.0, -0.017 }, { 3.35, -0.025 }, { 3.7, -0.036 }, { 10.0, -0.036 } };
#define CAB_NT (int)(sizeof CAB_TAB / sizeof CAB_TAB[0])
/* Normal force, CN = CNA (alpha - ALPHA0), alpha in degrees.  The OFP has
 * one (alpha, CN) pair per Mach number, so slope and zero-lift angle are not
 * separable there except below Mach 0.4, where alpha swept 8 to 1 deg
 * (slope 0.059, zero lift -0.5 to -0.8); above it the slope is assumed,
 * rising into the transonic and falling after, and ALPHA0 is what puts
 * every OFP point on the line.  Supersonic, the OFP's load relief holds the
 * stack at zero normal force, at alpha +2.2 to +2.9 deg.  Through the CG:
 * the OFP plots moments too (xx), but nothing here uses them yet. */
static const double CNA_TAB[][2] = { { 0.0, 0.059 }, { 0.6, 0.059 }, { 1.0, 0.066 }, { 1.3, 0.066 },
                                     { 2.0, 0.055 }, { 3.0, 0.045 }, { 4.0, 0.040 }, { 10.0, 0.040 } };
static const double AL0_TAB[][2] = { { 0.0, -0.8 }, { 0.8, -0.8 }, { 0.95, -0.4 }, { 1.05, 0.2 },
                                     { 1.4, 0.2 }, { 1.8, 0.8 }, { 2.1, 0.9 }, { 2.5, 2.2 },
                                     { 3.0, 2.6 }, { 3.6, 2.95 }, { 10.0, 2.95 } };
static double cnaScale = -1.0;     /* YAGPC_VEHDYN_CNA_SCALE, for calibration */
#define CNA_NT (int)(sizeof CNA_TAB / sizeof CNA_TAB[0])
#define AL0_NT (int)(sizeof AL0_TAB / sizeof AL0_TAB[0])
/* Side force per degree of sideslip, as a fraction of the normal force's:
 * the stack seen from the side is the tank and boosters without the wing.
 * At 1.0 the DAP's lateral load relief (gain KN_NY 55.4 against KM_NZ
 * 29.5, CGCUN1.hal) oscillated with growing amplitude through max-q. */
#define CYB_FRAC 0.4

enum { ASC_NONE = 0, ASC_PAD, ASC_STACK, ASC_ORB_ET };
static int asc = ASC_NONE;
static double etLo2, etLh2, srbProp;
static double srbIgnT = -1.0;
static double tvcCmd[5][2], tvcPos[5][2];
static double padAz = PAD_AZ_DEG_DEFAULT;
static double padR[3];            /* the nav base, Earth-fixed, m */
static double padCbe[3][3];       /* body -> Earth-fixed */
static double sfB[3];             /* the specific force, body, m/s^2, last step */
static double aeroAl, aeroBe, aeroQ; /* angle of attack, sideslip (deg), dynamic pressure (Pa) */
static double aeroFb[3];             /* the air's force, body, N, last step */
/* THE ASCENT'S BUDGET, m/s, integrated while the stack flies: thrust,
 * thrust along the velocity (the rest is steering loss), drag and gravity
 * along the velocity -- to set beside the published figures. */
static double budThrust, budThrustAlong, budDrag, budGrav;
static void budget_report(const char *when) {
    const double F = 0.3048;
    fprintf(stderr, "vehdyn: ascent budget at %s: thrust %.0f ft/s, of it along the velocity %.0f "
                    "(steering loss %.0f); drag loss %.0f; gravity loss %.0f ft/s\n", when,
            budThrust / F, budThrustAlong / F, (budThrust - budThrustAlong) / F, budDrag / F,
            budGrav / F);
}

static double interp(const double (*tab)[2], int n, double x) {
    if (x <= tab[0][0]) return tab[0][1];
    for (int i = 1; i < n; i++)
        if (x <= tab[i][0])
            return tab[i - 1][1] + (tab[i][1] - tab[i - 1][1]) * (x - tab[i - 1][0]) /
                                       (tab[i][0] - tab[i - 1][0]);
    return tab[n - 1][1];
}

int vehdyn_ascent_phase(void) { return asc; }

void vehdyn_set_tvc(const double cmd[5][2]) { memcpy(tvcCmd, cmd, sizeof tvcCmd); }

void vehdyn_specific_force(double out[3]) { memcpy(out, sfB, sizeof sfB); }

/* An SRB thrust, vacuum, N, at time tau from ignition. */
static double srb_thrust_vac(double tau) {
    if (tau < 0.0) return 0.0;
    return interp(SRB_T, SRB_NT, tau / SRB_TSCALE) * 1e6 * LBF_N * SRB_SCALE / SRB_TSCALE;
}

/* Height above the WGS-84 ellipsoid (first order), m, and the air there. */
/* The state is in M50, whose Z is the 1950 pole: latitude is measured from
 * the pole of date (about 0.34 deg away by 2011, up to ~100 m of height). */
static double height_m(const double r[3]) {
    double rn = sqrt(r[0] * r[0] + r[1] * r[1] + r[2] * r[2]), p[3];
    phys_earth_pole(p);
    double sl = (r[0] * p[0] + r[1] * p[1] + r[2] * p[2]) / rn, f = 1.0 / 298.257223563;
    return rn - 6378137.0 * (1.0 - f * sl * sl);
}
/* Geodetic height above PASS's ellipsoid (GNKGEO's: a 20,925,646.3255 ft,
 * f 1/298.3), feet -- what PASS's altitude, and so the crew's cue cards, use. */
static double geodetic_h_ft(const double r[3]) {
    double p[3];
    phys_earth_pole(p);
    double a = 20925646.3255 * 0.3048, f = 1.0 / 298.3, e2 = f * (2.0 - f);
    double z = r[0] * p[0] + r[1] * p[1] + r[2] * p[2];
    double rr = r[0] * r[0] + r[1] * r[1] + r[2] * r[2], w = sqrt(rr > z * z ? rr - z * z : 0.0);
    double lat = atan2(z, w * (1.0 - e2)), h = 0.0;
    for (int i = 0; i < 4; i++) {
        double sl = sin(lat), N = a / sqrt(1.0 - e2 * sl * sl);
        h = w / cos(lat) - N;
        lat = atan2(z, w * (1.0 - e2 * N / (N + h)));
    }
    return h / 0.3048;
}
/* THE DAY'S AIR: a radiosonde sounding, YAGPC_VEHDYN_SOUNDING naming its
 * file in the University of Wyoming archive's CSV form (pressure hPa,
 * geopotential height m, temperature and dew point C, mixing ratio g/kg,
 * wind direction deg (from) and speed m/s) -- for STS-134, Cape Canaveral
 * (74794) at 2011-05-16 12Z, an hour before launch.  Below its top it gives
 * the atmosphere (pressure log-linear in height, virtual temperature linear)
 * and the wind; above, the reference atmospheres below and no wind.
 * Heights are made geometric from geopotential (Re 6,356,766 m). */
#define SND_MAX 400
static int sndN = -1;
static double sndZ[SND_MAX], sndLnP[SND_MAX], sndTv[SND_MAX], sndWE[SND_MAX], sndWN[SND_MAX];
static void sounding_load(void) {
    if (sndN >= 0) return;
    sndN = 0;
    const char *path = yagpc_getenv("YAGPC_VEHDYN_SOUNDING");
    if (path == NULL || !*path) return;
    FILE *fp = fopen(path, "r");
    if (fp == NULL) {
        fprintf(stderr, "vehdyn: sounding %s: cannot open\n", path);
        return;
    }
    char line[512];
    double lastWE = 0.0, lastWN = 0.0;
    while (fgets(line, sizeof line, fp) != NULL && sndN < SND_MAX) {
        /* time,lon,lat,p,z,T,Td,Ti,RH,RHi,w,dir,speed */
        char *f[16];
        int nf = 0;
        for (char *c = line, *s0 = line; nf < 16; c++)
            if (*c == ',' || *c == '\n' || *c == '\0') {
                int end = (*c == '\n' || *c == '\0');
                *c = '\0';
                f[nf++] = s0;
                s0 = c + 1;
                if (end) break;
            }
        if (nf < 13) continue;
        char *e1, *e2, *e3;
        double p = strtod(f[3], &e1), zg = strtod(f[4], &e2), t = strtod(f[5], &e3);
        if (e1 == f[3] || e2 == f[4] || e3 == f[5]) continue;     /* the header, or a gap */
        char *e4;
        double w = strtod(f[10], &e4);
        if (e4 == f[10]) w = 0.0;
        double tv = (t + 273.15) * (1.0 + 0.61 * w / 1000.0);
        char *e5, *e6;
        double dir = strtod(f[11], &e5), spd = strtod(f[12], &e6);
        double we = lastWE, wn = lastWN;
        if (e5 != f[11] && e6 != f[12]) {      /* toward = from + 180 */
            we = -spd * sin(dir * VD_PI / 180.0);
            wn = -spd * cos(dir * VD_PI / 180.0);
            lastWE = we; lastWN = wn;
        }
        double z = 6356766.0 * zg / (6356766.0 - zg);
        if (sndN > 0 && z <= sndZ[sndN - 1]) continue;
        sndZ[sndN] = z; sndLnP[sndN] = log(p * 100.0); sndTv[sndN] = tv;
        sndWE[sndN] = we; sndWN[sndN] = wn;
        sndN++;
    }
    fclose(fp);
    fprintf(stderr, "vehdyn: sounding %s: %d levels to %.0f m\n", path, sndN,
            sndN ? sndZ[sndN - 1] : 0.0);
}
static int sounding_seg(double h, double *f) {
    sounding_load();
    if (sndN < 2 || h >= sndZ[sndN - 1]) return -1;
    if (h < sndZ[0]) h = sndZ[0];
    int i = 0;
    while (i < sndN - 2 && h > sndZ[i + 1]) i++;
    *f = (h - sndZ[i]) / (sndZ[i + 1] - sndZ[i]);
    return i;
}
static int sounding(double h, double *rho, double *temp) {
    double f;
    int i = sounding_seg(h, &f);
    if (i < 0) return 0;
    double p = exp(sndLnP[i] + f * (sndLnP[i + 1] - sndLnP[i]));
    *temp = sndTv[i] + f * (sndTv[i + 1] - sndTv[i]);
    *rho = p / (287.05 * *temp);
    return 1;
}
/* The wind at height h, m/s toward east and north (zero above the sounding). */
static void sounding_wind(double h, double *we, double *wn) {
    double f;
    int i = sounding_seg(h, &f);
    if (i < 0) { *we = *wn = 0.0; return; }
    *we = sndWE[i] + f * (sndWE[i + 1] - sndWE[i]);
    *wn = sndWN[i] + f * (sndWN[i + 1] - sndWN[i]);
}

/* THE 1963 PATRICK AFB REFERENCE ATMOSPHERE, the one the Shuttle's ascent
 * design used (STS-1 OFP JSC-14483 Vol 3 sec. 5.3; Smith & Weidner, NASA
 * TM X-53139, 1964), as tabulated for SVDS in JSC-08964 (Kirkpatrick,
 * "Cubic spline function interpolation in atmosphere models...", App. A,
 * IOP = 5): pressure (mb) and density (kg/m^3) at 55 of its 123 altitudes,
 * 0-66 km.  Temperature is p / (rho R).  A subtropical column: 3% thinner
 * than the 1976 standard at the ground, 2-7% denser at 10-12 km where
 * max-q is, 12% denser at 14-16 km.  Above 66 km, and with
 * YAGPC_VEHDYN_ATMOS=us1976, the 1976 standard below is used instead. */
static const double PAT_H[] = {
    0, 250, 500, 750, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 3500, 4000, 4500,
    5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 13000, 14000, 15000, 16000, 17000,
    18000, 19000, 20000, 22000, 24000, 26000, 28000, 30000, 32000, 34000, 36000, 38000, 40000,
    42000, 44000, 46000, 48000, 50000, 52000, 54000, 56000, 58000, 60000, 62000, 64000, 66000 };
static const double PAT_P[] = {      /* mb */
    1017.0147, 988.29373, 960.22651, 932.80664, 906.03418, 879.89596, 854.38573, 829.49430,
    805.21168, 781.52728, 758.43002, 735.90840, 713.95065, 671.67869, 631.51745, 593.37050,
    557.14348, 490.09912, 429.67959, 375.32040, 326.49869, 282.77555, 243.73144, 209.09281,
    178.61068, 151.99026, 128.92856, 109.11841, 92.252642, 78.097365, 66.260092, 56.315652,
    40.899191, 29.918759, 22.038159, 16.327363, 12.146273, 9.0905080, 6.8429914, 5.1807184,
    3.9447995, 3.0209180, 2.3262411, 1.8004513, 1.3994781, 1.0910568, 0.85180215, 0.66393197,
    0.51553130, 0.39852059, 0.30651143, 0.23442082, 0.17818466, 0.13454170, 0.10086976 };
static const double PAT_RHO[] = {    /* kg/m^3 */
    1.1835467, 1.1573534, 1.1312045, 1.1051789, 1.0793462, 1.0537666, 1.0284922, 1.0035670,
    0.97902601, 0.95490, 0.93122447, 0.90800345, 0.88525681, 0.84122243, 0.79915662,
    0.75904647, 0.72084275, 0.64983435, 0.58535153, 0.52651817, 0.47249382, 0.42255460,
    0.37638429, 0.33302120, 0.29232218, 0.25432637, 0.21920326, 0.18717685, 0.15845601,
    0.13239218, 0.11096236, 0.093193799, 0.066193250, 0.047478898, 0.034382489, 0.025119029,
    0.018334060, 0.013457797, 0.0099301028, 0.0073654170, 0.0054934199, 0.0041220200,
    0.0031134715, 0.0023684559, 0.0018151546, 0.0014015768, 0.0010965534, 0.00086526723,
    0.00068253221, 0.00053756684, 0.00042227457, 0.00033048920, 0.00025745233, 0.00019944483,
    0.00015352539 };
#define PAT_N (int)(sizeof PAT_H / sizeof PAT_H[0])
static int patrick(double h, double *rho, double *temp) {
    static int use = -1;
    if (use < 0) {
        const char *e = yagpc_getenv("YAGPC_VEHDYN_ATMOS");
        use = !(e != NULL && strcmp(e, "us1976") == 0);
    }
    if (!use || h >= PAT_H[PAT_N - 1]) return 0;
    if (h < 0.0) h = 0.0;
    int i = 0;
    while (i < PAT_N - 2 && h > PAT_H[i + 1]) i++;
    double f = (h - PAT_H[i]) / (PAT_H[i + 1] - PAT_H[i]);
    double p = exp(log(PAT_P[i]) + f * (log(PAT_P[i + 1]) - log(PAT_P[i]))) * 100.0;
    *rho = exp(log(PAT_RHO[i]) + f * (log(PAT_RHO[i + 1]) - log(PAT_RHO[i])));
    *temp = p / (*rho * 287.05);
    return 1;
}
/* THE 1976 STANDARD ATMOSPHERE to 86 km, layer by layer: physics.c's
 * single exponential below 25 km is 20-26% thin where max-q happens. */
static void us1976(double h, double *rho, double *temp) {
    if (sounding(h, rho, temp)) return;
    if (patrick(h, rho, temp)) return;
    static const double HB[] = { 0, 11000, 20000, 32000, 47000, 51000, 71000, 86000 };
    static const double LB[] = { -0.0065, 0.0, 0.001, 0.0028, 0.0, -0.0028, -0.002 };
    static const double PB[] = { 101325.0, 22632.06, 5474.889, 868.0187, 110.9063, 66.93887,
                                 3.956420 };
    static const double TB[] = { 288.15, 216.65, 216.65, 228.65, 270.65, 270.65, 214.65 };
    if (h < 0.0) h = 0.0;
    if (h >= 86000.0) {
        *temp = 186.87;
        *rho = phys_air_density(h);
        return;
    }
    int i = 0;
    while (i < 6 && h >= HB[i + 1]) i++;
    double T = TB[i] + LB[i] * (h - HB[i]), P;
    if (LB[i] == 0.0) P = PB[i] * exp(-9.80665 * 0.0289644 * (h - HB[i]) / (8.3144598 * TB[i]));
    else P = PB[i] * pow(TB[i] / T, 9.80665 * 0.0289644 / (8.3144598 * LB[i]));
    *temp = T;
    *rho = P / (287.053 * T);
}

/* An SRB's chamber pressure, psia, for the FA's transducers: 914 psia
 * (the motor's maximum, SCOM 2.16 / SODB) scaled by the thrust, which
 * puts the 50 psia separation cue (GSESRB) in the tail-off, near 123 s.
 * Ambient before ignition; negative once the boosters have gone (no
 * signal -- the words read zero). */
double vehdyn_srb_pc_psia(void) {
    if (asc == ASC_PAD || (asc == ASC_STACK && srbIgnT < 0.0)) return 14.7;
    if (asc != ASC_STACK) return -1.0;
    /* Head pressure per pound of thrust falls as the throat erodes: 914
     * psia at the 3.312 Mlbf peak, and "at 50 psia, an SRB may produce
     * approximately 200,000 lbs of thrust" at the end (Booster Console
     * Handbook, SRB separation) -- taken linear in time between. */
    double tau = st.t - srbIgnT, end = 121.0 * SRB_TSCALE;
    double k0 = 914.0 / 3.312e6, k1 = 50.0 / 0.2e6;
    double kk = k0 + (k1 - k0) * (tau > end ? 1.0 : tau < 0.0 ? 0.0 : tau / end);
    double pc = kk * srb_thrust_vac(tau) / LBF_N;
    double h = height_m(st.r), rho, T;
    us1976(h, &rho, &T);
    double pamb = rho * 287.05 * T / 6894.757;
    return pc > pamb ? pc : pamb;
}


/* Rotate unit vector u (body) by a pitch angle (toward +Z) and a yaw angle
 * (toward +Y), degrees -- small-angle composition, then normalised. */
static void deflect(double u[3], double pitchDeg, double yawDeg) {
    double p = pitchDeg * VD_PI / 180.0, y = yawDeg * VD_PI / 180.0;
    double v[3] = { u[0] - p * u[2] - y * u[1], u[1] + y * u[0], u[2] + p * u[0] };
    double n = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    for (int i = 0; i < 3; i++) u[i] = v[i] / n;
}

static void add_force(double f[3], double tau[3], const double fk[3], const double pB[3]) {
    double r[3] = { pB[0] - cgB[0], pB[1] - cgB[1], pB[2] - cgB[2] };
    tau[0] += r[1] * fk[2] - r[2] * fk[1];
    tau[1] += r[2] * fk[0] - r[0] * fk[2];
    tau[2] += r[0] * fk[1] - r[1] * fk[0];
    for (int i = 0; i < 3; i++) f[i] += fk[i];
}

/* The velocity relative to the air, inertial, m/s: the air turns with the
 * Earth, and below the sounding's top it moves with the day's wind. */
static void air_velocity(double va[3]) {
    double we[3] = { 0, 0, phys_earth_rate() };
    va[0] = st.v[0] - (we[1] * st.r[2] - we[2] * st.r[1]);
    va[1] = st.v[1] - (we[2] * st.r[0] - we[0] * st.r[2]);
    va[2] = st.v[2] - (we[0] * st.r[1] - we[1] * st.r[0]);
    double wE, wN, pole[3], rn = sqrt(st.r[0] * st.r[0] + st.r[1] * st.r[1] + st.r[2] * st.r[2]);
    sounding_wind(height_m(st.r), &wE, &wN);
    if (wE == 0.0 && wN == 0.0) return;
    phys_earth_pole(pole);
    double up[3] = { st.r[0] / rn, st.r[1] / rn, st.r[2] / rn };
    double e[3] = { pole[1] * up[2] - pole[2] * up[1], pole[2] * up[0] - pole[0] * up[2],
                    pole[0] * up[1] - pole[1] * up[0] };
    double en = sqrt(e[0] * e[0] + e[1] * e[1] + e[2] * e[2]);
    for (int k = 0; k < 3; k++) e[k] /= en;
    double n[3] = { up[1] * e[2] - up[2] * e[1], up[2] * e[0] - up[0] * e[2],
                    up[0] * e[1] - up[1] * e[0] };
    for (int k = 0; k < 3; k++) va[k] -= wE * e[k] + wN * n[k];
}

/* The ascent's forces and torques (body), and the flows out of the tank and
 * the boosters, kg/s. */
static void ascent_loads(double f[3], double tau[3], double *mdotEt, double *mdotSrb) {
    flight_params();
    *mdotEt = *mdotSrb = 0.0;
    if (asc == ASC_NONE) return;
    tvc_signs();
    double h = height_m(st.r), rho, T;
    us1976(h, &rho, &T);
    double pamb = rho * 287.05 * T;
    /* the main engines, while the tank has propellant */
    if (etLo2 > 0.0 && etLh2 > 0.0)
        for (int e = 0; e < 3; e++) {
            double pc = eiu_pc_percent(e + 1, st.t) / 100.0;
            if (pc <= 0.0) continue;
            double thr = pc * ME_TVAC_N - pamb * ME_AE_M2;
            if (thr < 0.0) thr = 0.0;
            double u[3] = { 1, 0, 0 }, pB[3], fk[3];
            deflect(u, ME_CANT_P[e] + tvcSign[0] * tvcPos[e][0], ME_CANT_Y[e] + tvcSign[1] * tvcPos[e][1]);
            to_body(ME_XYZ[e][0], ME_XYZ[e][1], ME_XYZ[e][2], pB);
            for (int i = 0; i < 3; i++) fk[i] = thr * u[i];
            add_force(f, tau, fk, pB);
            *mdotEt += pc * ME_TVAC_N / (ME_ISP_VAC * G0);
        }
    /* the boosters, once lit and while attached */
    if (asc == ASC_STACK && srbIgnT >= 0.0 && srbProp > 0.0)
        for (int b = 0; b < 2; b++) {
            double tv = srb_thrust_vac(st.t - srbIgnT);
            if (tv <= 0.0) continue;
            double thr = tv - pamb * SRB_AE_M2;
            if (thr < 0.0) thr = 0.0;
            /* rock and tilt act on axes at 45 deg to the body's: pitch and
             * yaw of the nozzle (STS 83-0008 mixing; TD0358A 5-45) */
            double rk = tvcPos[3 + b][0], tl = tvcPos[3 + b][1], pd, yd;
            if (b == 0) { pd = (rk - tl) / sqrt(2.0); yd = -(rk + tl) / sqrt(2.0); }
            else        { pd = (tl - rk) / sqrt(2.0); yd = (tl + rk) / sqrt(2.0); }
            double u[3] = { 1, 0, 0 }, pB[3], fk[3];
            deflect(u, tvcSign[2] * pd, tvcSign[3] * yd);
            to_body(SRB_NOZ_XO, b == 0 ? -SRB_YO : SRB_YO, SRB_AXIS_ZO, pB);
            for (int i = 0; i < 3; i++) fk[i] = thr * u[i];
            add_force(f, tau, fk, pB);
            *mdotSrb += tv / (SRB_ISP_VAC * G0);
        }
    /* the air: axial force against the air-relative velocity */
    aeroFb[0] = aeroFb[1] = aeroFb[2] = 0.0;
    {
        double va[3];
        air_velocity(va);
        double sp = sqrt(va[0] * va[0] + va[1] * va[1] + va[2] * va[2]);
        if (sp > 1.0 && rho > 0.0) {
            double mach = sp / sqrt(1.4 * 287.05 * T);
            double q = 0.5 * rho * sp * sp, D = q * ASC_SREF_M2 *
                       (interp(CA_TAB, CA_NT, mach) + interp(CAB_TAB, CAB_NT, mach));
            double R[3][3], dB[3];
            qmat_body(st.q, R);
            for (int i = 0; i < 3; i++)
                dB[i] = -D * (R[0][i] * va[0] + R[1][i] * va[1] + R[2][i] * va[2]) / sp;
            for (int i = 0; i < 3; i++) f[i] += dB[i];   /* through the CG, here */
            for (int i = 0; i < 3; i++) aeroFb[i] = dB[i];
            /* normal and side force from the angle of attack and sideslip
             * of the air-relative velocity in body axes (limited to 10 deg) */
            double vb[3];
            for (int i = 0; i < 3; i++) vb[i] = R[0][i] * va[0] + R[1][i] * va[1] + R[2][i] * va[2];
            double D2 = 180.0 / VD_PI;
            double al = atan2(vb[2], vb[0]) * D2, be = asin(vb[1] / sp) * D2;
            aeroAl = al; aeroBe = be; aeroQ = q;
            if (al > 10.0) al = 10.0;
            if (al < -10.0) al = -10.0;
            if (be > 10.0) be = 10.0;
            if (be < -10.0) be = -10.0;
            if (cnaScale < 0.0) {
                const char *e = yagpc_getenv("YAGPC_VEHDYN_CNA_SCALE");
                cnaScale = e ? atof(e) : 1.0;
            }
            double qsc = q * ASC_SREF_M2 * interp(CNA_TAB, CNA_NT, mach) * cnaScale;
            double cnal = al - interp(AL0_TAB, AL0_NT, mach);
            f[2] -= qsc * cnal;
            f[1] -= CYB_FRAC * qsc * be;
            aeroFb[2] -= qsc * cnal;
            aeroFb[1] -= CYB_FRAC * qsc * be;
        }
    }
}

/* ---------------------------------------------------------------------
 * THE ORBITER ALONE IN THE AIR: entry, TAEM and approach.
 *
 * Longitudinal aerodynamics from src/entryaero.h, generated by
 * tools/entryaero.py: wind-tunnel SHAPES (OA98, NASA CR-141550, M 5.25
 * and 10.27; LA66, NASA CR-147621, M 0.29) at the LEVEL and TRIM of the
 * STS-1 descent OFP (JSC-14483 Vol. 5, April 1979 ADDB) -- see that file.
 * Body-axis CN and CA through the MRP, X 1076.7 / Z 375.0 in, and CM about
 * it.  Lateral-directional derivatives against Mach (TP-1011 above 1.3, the
 * data book subsonic) and damping against alpha (TP-1634), linear in
 * sideslip, aileron and rudder; the rudder below Mach 1.3 and all damping
 * above it are held from where the sources stop.
 *
 * The aerosurfaces follow PASS's commands (mdmdev, FA AOD) at their rates,
 * inside their travel; the body flap runs while its up or down discrete
 * is set.  Elevon 20 deg/s, SCOM OI-25 2.8 (the ROLL/PITCH lights' drive
 * rate); travel +20/-35, the software limits printed on the F7 surface
 * position indicator (SCOM 2.7); body flap -11.7..+22.5 (same).  The
 * rudder, speedbrake and body flap RATES are PROVISIONAL until TP-1011's
 * actuator model is read.
 * ------------------------------------------------------------------- */
#include "entryaero.h"

#define EA_NM  (int)(sizeof EA_MACH / sizeof EA_MACH[0])
#define EA_NA  (int)(sizeof EA_ALPHA / sizeof EA_ALPHA[0])
#define EA_NE  (int)(sizeof EA_DE / sizeof EA_DE[0])
#define EA_NBF (int)(sizeof EA_DBF / sizeof EA_DBF[0])
#define EA_NSB (int)(sizeof EA_DSB / sizeof EA_DSB[0])
#define EA_CREF_M   (474.8 * IN_M)
#define EA_BREF_M   (936.68 * IN_M)
#define EA_ALT_M    130000.0      /* below this the tables, above the cannonball */

enum { SURF_LIB, SURF_LOB, SURF_RIB, SURF_ROB, SURF_SB, SURF_RUD, SURF_N };
static const double SURF_RATE[SURF_N] = { 20.0, 20.0, 20.0, 20.0, 10.0, 14.0 };
static const double SURF_MIN[SURF_N]  = { -35.0, -35.0, -35.0, -35.0, 0.0, -27.1 };
static const double SURF_MAX[SURF_N]  = { 20.0, 20.0, 20.0, 20.0, 98.6, 27.1 };
#define BF_RATE_DEG_S 1.3
#define BF_MIN (-11.7)
#define BF_MAX 22.5
static double surfCmd[SURF_N], surfPos[SURF_N];
static double bfPos;              /* body flap, deg, + trailing edge down */
static int bfDrive;               /* +1 down, -1 up, 0 stopped */
static bool aeroOn;               /* the tables are in charge (below EA_ALT_M) */
static double eaMach, eaCN, eaCA, eaCM;

void vehdyn_set_aerosurf(const double cmd[6], int bodyFlapDrive) {
    for (int i = 0; i < SURF_N; i++) surfCmd[i] = cmd[i];
    bfDrive = bodyFlapDrive;
}

void vehdyn_aerosurf_pos(double pos[7]) {
    for (int i = 0; i < SURF_N; i++) pos[i] = surfPos[i];
    pos[6] = bfPos;
}

static void surf_slew(double dt) {
    for (int i = 0; i < SURF_N; i++) {
        double want = surfCmd[i];
        if (want > SURF_MAX[i]) want = SURF_MAX[i];
        if (want < SURF_MIN[i]) want = SURF_MIN[i];
        double d = want - surfPos[i], mx = SURF_RATE[i] * dt;
        surfPos[i] += (d > mx) ? mx : (d < -mx) ? -mx : d;
    }
    bfPos += bfDrive * BF_RATE_DEG_S * dt;
    if (bfPos > BF_MAX) bfPos = BF_MAX;
    if (bfPos < BF_MIN) bfPos = BF_MIN;
}

/* Index and fraction of v in x[0..n-1], clamped to the ends. */
static int ea_brk(const double *x, int n, double v, double *f) {
    if (v <= x[0]) { *f = 0.0; return 0; }
    if (v >= x[n - 1]) { *f = 1.0; return n - 2; }
    int i = 0;
    while (i < n - 2 && v > x[i + 1]) i++;
    *f = (v - x[i]) / (x[i + 1] - x[i]);
    return i;
}

/* One table at (Mach, alpha, deflection index d with fraction fd). */
#define EA_TAB(T, nd, d, fd, out) do {                                          \
    for (int j_ = 0; j_ < 3; j_++) {                                            \
        double a0_ = T[im][ia][d][j_] + fd * (T[im][ia][(d) + ((nd) > 1)][j_] - T[im][ia][d][j_]); \
        double a1_ = T[im][ia + 1][d][j_] + fd * (T[im][ia + 1][(d) + ((nd) > 1)][j_] - T[im][ia + 1][d][j_]); \
        double b0_ = T[im + 1][ia][d][j_] + fd * (T[im + 1][ia][(d) + ((nd) > 1)][j_] - T[im + 1][ia][d][j_]); \
        double b1_ = T[im + 1][ia + 1][d][j_] + fd * (T[im + 1][ia + 1][(d) + ((nd) > 1)][j_] - T[im + 1][ia + 1][d][j_]); \
        double m0_ = a0_ + fa * (a1_ - a0_), m1_ = b0_ + fa * (b1_ - b0_);     \
        (out)[j_] += m0_ + fm * (m1_ - m0_);                                    \
    } } while (0)

static void ea_coeffs(double mach, double alpha, double de, double dbf, double dsb, double c[3]) {
    static double logM[EA_NM];
    static int ready;
    if (!ready) { for (int i = 0; i < EA_NM; i++) logM[i] = log(EA_MACH[i]); ready = 1; }
    double fm, fa, fe, fb, fs;
    int im = ea_brk(logM, EA_NM, log(mach > 0.05 ? mach : 0.05), &fm);
    int ia = ea_brk(EA_ALPHA, EA_NA, alpha, &fa);
    int ie = ea_brk(EA_DE, EA_NE, de, &fe);
    int ib = ea_brk(EA_DBF, EA_NBF, dbf, &fb);
    int is = ea_brk(EA_DSB, EA_NSB, dsb, &fs);
    c[0] = c[1] = c[2] = 0.0;
    EA_TAB(EA_BASE, 1, 0, 0.0, c);
    EA_TAB(EA_D_ELEVON, EA_NE, ie, fe, c);
    EA_TAB(EA_D_BODYFLAP, EA_NBF, ib, fb, c);
    EA_TAB(EA_D_SPEEDBRAKE, EA_NSB, is, fs, c);
}

void vehdyn_aero_coeffs(double mach, double alpha, double de, double dbf, double dsb, double c[3]) {
    ea_coeffs(mach, alpha, de, dbf, dsb, c);
}

/* The air's force and moment on the orbiter alone, added to f and tau
 * (body, N and N m about the c.g.).  Returns false above EA_ALT_M, where
 * physics.c's drag (the cannonball) stands in. */
static bool entry_aero(double f[3], double tau[3]) {
    double h = height_m(st.r);
    if (h > EA_ALT_M) return false;
    double rho, T;
    us1976(h, &rho, &T);
    double va[3];
    air_velocity(va);
    double sp = sqrt(va[0] * va[0] + va[1] * va[1] + va[2] * va[2]);
    if (sp < 1.0) return true;
    double R[3][3], vb[3];
    qmat_body(st.q, R);
    for (int i = 0; i < 3; i++) vb[i] = R[0][i] * va[0] + R[1][i] * va[1] + R[2][i] * va[2];
    const double D2 = 180.0 / VD_PI;
    double al = atan2(vb[2], vb[0]) * D2, be = asin(vb[1] / sp) * D2;
    double mach = sp / sqrt(1.4 * 287.05 * T), q = 0.5 * rho * sp * sp;
    double de = 0.25 * (surfPos[SURF_LIB] + surfPos[SURF_LOB] + surfPos[SURF_RIB] + surfPos[SURF_ROB]);
    double c[3];
    ea_coeffs(mach, al, de, bfPos, surfPos[SURF_SB], c);
    double qs = q * ASC_SREF_M2;
    /* lateral-directional, per degree, at this Mach (log interpolation):
     * aileron (left - right)/2, elevon pairs; rudder + trailing edge left */
    double lat[9], fl;
    {
        static double logL[sizeof EA_LAT_MACH / sizeof EA_LAT_MACH[0]];
        static int ready;
        const int nl = (int)(sizeof EA_LAT_MACH / sizeof EA_LAT_MACH[0]);
        if (!ready) { for (int i = 0; i < nl; i++) logL[i] = log(EA_LAT_MACH[i]); ready = 1; }
        int i = ea_brk(logL, nl, log(mach > 0.05 ? mach : 0.05), &fl);
        for (int k = 0; k < 9; k++) lat[k] = EA_LAT[i][k] + fl * (EA_LAT[i + 1][k] - EA_LAT[i][k]);
    }
    double da = 0.25 * ((surfPos[SURF_LIB] + surfPos[SURF_LOB]) - (surfPos[SURF_RIB] + surfPos[SURF_ROB]));
    double dr = surfPos[SURF_RUD];
    double cy = lat[0] * be + lat[3] * da + lat[6] * dr;
    double cn = lat[1] * be + lat[4] * da + lat[7] * dr;
    double cl = lat[2] * be + lat[5] * da + lat[8] * dr;
    /* damping, per radian, on rate x length / 2V (TP-1634, against alpha) */
    double dmp[5], fd;
    {
        const int nd = (int)(sizeof EA_DAMP_ALPHA / sizeof EA_DAMP_ALPHA[0]);
        int i = ea_brk(EA_DAMP_ALPHA, nd, al, &fd);
        for (int k = 0; k < 5; k++) dmp[k] = EA_DAMP[i][k] + fd * (EA_DAMP[i + 1][k] - EA_DAMP[i][k]);
    }
    double bs = EA_BREF_M / (2.0 * sp), cs = EA_CREF_M / (2.0 * sp);
    double cm = c[2] + dmp[0] * st.w[1] * cs;
    cl += bs * (dmp[1] * st.w[0] + dmp[2] * st.w[2]);
    cn += bs * (dmp[3] * st.w[0] + dmp[4] * st.w[2]);
    double fk[3] = { -c[1] * qs, cy * qs, -c[0] * qs }, pB[3];   /* CA aft, CY right, CN up (-Z) */
    to_body(1076.7, 0.0, 375.0, pB);
    add_force(f, tau, fk, pB);
    tau[0] += cl * qs * EA_BREF_M;                           /* + right wing down */
    tau[1] += cm * qs * EA_CREF_M;                           /* + nose up */
    tau[2] += cn * qs * EA_BREF_M;                           /* + nose right */
    for (int i = 0; i < 3; i++) aeroFb[i] = fk[i];
    aeroAl = al; aeroBe = be; aeroQ = q;
    eaMach = mach; eaCN = c[0]; eaCA = c[1]; eaCM = cm;
    return true;
}

/* With the state log, every 5 s in the air: Mach, alpha, beta, qbar,
 * the coefficients and the surfaces. */
static void entry_log(void) {
    static double last = -1e9;
    if (!aeroOn || st.t - last < 5.0) return;
    last = st.t;
    double r = aeroAl / (180.0 / VD_PI);
    double cl = eaCN * cos(r) - eaCA * sin(r), cd = eaCN * sin(r) + eaCA * cos(r);
    fprintf(stderr, "vehdyn-entry: t=%.1f h=%.0f ft M=%.3f alpha=%.2f beta=%.2f q=%.1f psf CL=%.4f "
                    "CD=%.4f L/D=%.3f CM=%+.4f elev=%.2f %.2f %.2f %.2f sb=%.1f rud=%.1f bf=%.2f (drive %+d)\n",
            st.t, height_m(st.r) / 0.3048, eaMach, aeroAl, aeroBe, aeroQ / 47.880259, cl, cd,
            cd != 0.0 ? cl / cd : 0.0, eaCM, surfPos[SURF_LIB], surfPos[SURF_LOB], surfPos[SURF_RIB],
            surfPos[SURF_ROB], surfPos[SURF_SB], surfPos[SURF_RUD], bfPos, bfDrive);
}

/* The gimbals follow their commands at TVC_RATE_DEG_S, inside their limits. */
static void tvc_slew(double dt) {
    for (int a = 0; a < 5; a++)
        for (int x = 0; x < 2; x++) {
            double lim = a < 3 ? (x == 0 ? ME_LIM_P : ME_LIM_Y) : SRB_LIM;
            double want = tvcCmd[a][x];
            if (want > lim) want = lim;
            if (want < -lim) want = -lim;
            double d = want - tvcPos[a][x], mx = TVC_RATE_DEG_S * dt;
            tvcPos[a][x] += (d > mx) ? mx : (d < -mx) ? -mx : d;
        }
}

/* THE PAD: where the stack is at time t, held to the Earth. */
/* With the state log, during the ascent: the body rates (deg/s), local
 * up in body axes, and the gimbal positions (deg) -- to see a TVC loop's
 * sense at a glance. */
static void ascent_log(void) {
    if (asc == ASC_NONE) return;
    double R[3][3], rn = sqrt(st.r[0] * st.r[0] + st.r[1] * st.r[1] + st.r[2] * st.r[2]), up[3];
    qmat_body(st.q, R);                     /* body -> inertial */
    for (int i = 0; i < 3; i++)
        up[i] = (R[0][i] * st.r[0] + R[1][i] * st.r[1] + R[2][i] * st.r[2]) / rn;
    const double D = 180.0 / VD_PI;
    fprintf(stderr, "vehdyn-asc: t=%.2f w=%.2f %.2f %.2f up_b=%.3f %.3f %.3f "
                    "alpha=%.2f beta=%.2f q=%.0f nz=%.3f ny=%.3f "
                    "me_p=%.2f %.2f %.2f me_y=%.2f %.2f %.2f srb_rt=%.2f %.2f %.2f %.2f "
                    "h_ft=%.0f hdot_fts=%.1f\n",
            st.t, st.w[0] * D, st.w[1] * D, st.w[2] * D, up[0], up[1], up[2],
            aeroAl, aeroBe, aeroQ / 47.880259, -sfB[2] / 9.80665, sfB[1] / 9.80665,
            tvcPos[0][0], tvcPos[1][0], tvcPos[2][0], tvcPos[0][1], tvcPos[1][1], tvcPos[2][1],
            tvcPos[3][0], tvcPos[3][1], tvcPos[4][0], tvcPos[4][1], geodetic_h_ft(st.r),
            (st.r[0] * st.v[0] + st.r[1] * st.v[1] + st.r[2] * st.v[2]) / rn / 0.3048);
}

static void pad_state(double t) {
    double M[3][3];                                  /* inertial -> Earth-fixed */
    phys_inertial_to_earth(t, M);
    double Rbi[3][3];                                /* body -> inertial = M^T Cbe */
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            Rbi[i][j] = M[0][i] * padCbe[0][j] + M[1][i] * padCbe[1][j] + M[2][i] * padCbe[2][j];
    /* the CG: the nav base less the body vector from CG to nav base */
    double nb[3], dEf[3], d[3];
    to_body(NB_XO, NB_YO, NB_ZO, nb);
    for (int i = 0; i < 3; i++) d[i] = nb[i] - cgB[i];
    for (int i = 0; i < 3; i++)
        dEf[i] = padCbe[i][0] * d[0] + padCbe[i][1] * d[1] + padCbe[i][2] * d[2];
    double rEf[3] = { padR[0] - dEf[0], padR[1] - dEf[1], padR[2] - dEf[2] };
    for (int i = 0; i < 3; i++) st.r[i] = M[0][i] * rEf[0] + M[1][i] * rEf[1] + M[2][i] * rEf[2];
    double w = phys_earth_rate();
    st.v[0] = -w * st.r[1];
    st.v[1] = w * st.r[0];
    st.v[2] = 0.0;
    /* the attitude, as a quaternion, and the Earth's rate in body axes */
    double tr = Rbi[0][0] + Rbi[1][1] + Rbi[2][2], q[4];
    if (tr > 0.0) {
        double s4 = sqrt(tr + 1.0) * 2.0;
        q[0] = 0.25 * s4; q[1] = (Rbi[2][1] - Rbi[1][2]) / s4;
        q[2] = (Rbi[0][2] - Rbi[2][0]) / s4; q[3] = (Rbi[1][0] - Rbi[0][1]) / s4;
    } else if (Rbi[0][0] > Rbi[1][1] && Rbi[0][0] > Rbi[2][2]) {
        double s4 = sqrt(1.0 + Rbi[0][0] - Rbi[1][1] - Rbi[2][2]) * 2.0;
        q[0] = (Rbi[2][1] - Rbi[1][2]) / s4; q[1] = 0.25 * s4;
        q[2] = (Rbi[0][1] + Rbi[1][0]) / s4; q[3] = (Rbi[0][2] + Rbi[2][0]) / s4;
    } else if (Rbi[1][1] > Rbi[2][2]) {
        double s4 = sqrt(1.0 + Rbi[1][1] - Rbi[0][0] - Rbi[2][2]) * 2.0;
        q[0] = (Rbi[0][2] - Rbi[2][0]) / s4; q[1] = (Rbi[0][1] + Rbi[1][0]) / s4;
        q[2] = 0.25 * s4; q[3] = (Rbi[1][2] + Rbi[2][1]) / s4;
    } else {
        double s4 = sqrt(1.0 + Rbi[2][2] - Rbi[0][0] - Rbi[1][1]) * 2.0;
        q[0] = (Rbi[1][0] - Rbi[0][1]) / s4; q[1] = (Rbi[0][2] + Rbi[2][0]) / s4;
        q[2] = (Rbi[1][2] + Rbi[2][1]) / s4; q[3] = 0.25 * s4;
    }
    memcpy(st.q, q, sizeof q);
    for (int i = 0; i < 3; i++) st.w[i] = Rbi[2][i] * w;   /* R^T (0,0,w) */
    st.t = t;
}

/* Put the stack on the pad (YAGPC_VEHDYN_PAD), at time t. */
static void pad_init(double t) {
    flight_params();
    const char *az = yagpc_getenv("YAGPC_VEHDYN_PAD_AZ");
    if (az != NULL) padAz = atof(az);
    /* ON PASS'S OWN ELLIPSOID, as GNKGEO.hal converts the same I-loads: the
     * equatorial radius 20,925,646.3255 ft (CGNS_EARTH_EQU_RADIUS_D) and
     * flattening 1/298.3 -- so that the truth's nav base is exactly where
     * PASS's navigation starts it (WGS-84 put it 9 ft away). */
    double a = 20925646.3255 * 0.3048, f = 1.0 / 298.3, e2 = f * (2.0 - f);
    double sl = sin(PAD_LAT_RAD), cl = cos(PAD_LAT_RAD), so = sin(PAD_LON_RAD), co = cos(PAD_LON_RAD);
    double N = a / sqrt(1.0 - e2 * sl * sl);
    padR[0] = (N + PAD_ALT_M) * cl * co;
    padR[1] = (N + PAD_ALT_M) * cl * so;
    padR[2] = (N * (1.0 - e2) + PAD_ALT_M) * sl;
    double up[3] = { cl * co, cl * so, sl }, east[3] = { -so, co, 0.0 },
           north[3] = { -sl * co, -sl * so, cl };
    double A = padAz * VD_PI / 180.0, zb[3], yb[3];
    for (int i = 0; i < 3; i++) zb[i] = cos(A) * north[i] + sin(A) * east[i];
    /* body Y = Z x X */
    yb[0] = zb[1] * up[2] - zb[2] * up[1];
    yb[1] = zb[2] * up[0] - zb[0] * up[2];
    yb[2] = zb[0] * up[1] - zb[1] * up[0];
    for (int i = 0; i < 3; i++) { padCbe[i][0] = up[i]; padCbe[i][1] = yb[i]; padCbe[i][2] = zb[i]; }
    asc = ASC_PAD;
    etLo2 = ET_LO2_KG; etLh2 = ET_LH2_KG; srbProp = SRB_PROP_KG;
    srbIgnT = -1.0;
    memset(tvcPos, 0, sizeof tvcPos);
    phys_set_drag(0.0, 0.0, 0.0, 0.0);           /* the stack's air is ascent_loads' */
    mass_properties();
    pad_state(t);
    fprintf(stderr, "vehdyn: the stack is on the pad at %.5f N %.5f E, belly toward %.0f deg; "
                    "%.0f kg\n", PAD_LAT_RAD * 180 / VD_PI, PAD_LON_RAD * 180 / VD_PI, padAz, st.mass);
}

/* The events that change what the vehicle is, as the MECs fire them. */
static void ascent_events(void) {
    if (asc == ASC_PAD) {
        double ig = mec_fired_at(MEC_SRM_IGN);
        if (ig >= 0.0 && st.t >= ig) {
            asc = ASC_STACK;
            srbIgnT = ig;
            fprintf(stderr, "vehdyn: LIFTOFF -- the hold-down posts let go at t=%.3f; the stack %.0f lb, "
                            "the ET's propellant %.0f lb (LO2 %.0f, LH2 %.0f)\n", st.t,
                    st.mass / 0.45359237, (etLo2 + etLh2) / 0.45359237, etLo2 / 0.45359237,
                    etLh2 / 0.45359237);
        }
    } else if (asc == ASC_STACK) {
        double sep = mec_fired_at(MEC_SRB_SEP);
        if (sep >= 0.0 && st.t >= sep) {
            asc = ASC_ORB_ET;
            fprintf(stderr, "vehdyn: SRB SEPARATION at t=%.3f, %.0f kg of booster gone\n", st.t,
                    2.0 * (SRB_INERT_KG + srbProp));
            budget_report("SRB separation");
            srbProp = 0.0;
            mass_properties();
        }
    } else if (asc == ASC_ORB_ET) {
        double sep = mec_fired_at(MEC_ET_SEP);
        if (sep >= 0.0 && st.t >= sep) {
            asc = ASC_NONE;
            fprintf(stderr, "vehdyn: ET SEPARATION at t=%.3f; %.0f kg LO2 and %.0f kg LH2 left in it\n",
                    st.t, etLo2, etLh2);
            budget_report("ET separation");
            phys_set_drag(2.2, 40.0, 220.0, 360.0);
            mass_properties();
        }
    }
}

static void qmat_body(const double q[4], double R[3][3]) {
    double w = q[0], x = q[1], y = q[2], z = q[3];
    R[0][0] = 1 - 2 * (y * y + z * z); R[0][1] = 2 * (x * y - w * z); R[0][2] = 2 * (x * z + w * y);
    R[1][0] = 2 * (x * y + w * z); R[1][1] = 1 - 2 * (x * x + z * z); R[1][2] = 2 * (y * z - w * x);
    R[2][0] = 2 * (x * z - w * y); R[2][1] = 2 * (y * z + w * x); R[2][2] = 1 - 2 * (x * x + y * y);
}

/* Total mass, the CG (as an offset from the dry CG) and the inertia tensor
 * about it, from the dry vehicle and the propellant left: parallel-axis
 * shifts of the dry body and of each module's propellant as a point mass. */
static void mass_properties(void) {
    flight_params();
    double m = dryKg, c[3] = { 0, 0, 0 };
    double tank[NMOD][3];
    for (int k = 0; k < NMOD; k++) {
        to_body(TANK_XYZ[k][0], TANK_XYZ[k][1], TANK_XYZ[k][2], tank[k]);
        m += prop[k];
        for (int i = 0; i < 3; i++) c[i] += prop[k] * tank[k][i];
    }
    /* THE STACK'S OTHER PARTS while attached (see the ascent, below) */
    double part[6][4];               /* body x, y, z, kg */
    int np = 0;
    if (asc != ASC_NONE) {
        double b[3];
        to_body(ET_INERT_XO, 0.0, ET_AXIS_ZO, b);
        part[np][0] = b[0]; part[np][1] = b[1]; part[np][2] = b[2]; part[np++][3] = ET_INERT_KG;
        to_body(ET_LO2_XO, 0.0, ET_AXIS_ZO, b);
        part[np][0] = b[0]; part[np][1] = b[1]; part[np][2] = b[2]; part[np++][3] = etLo2;
        to_body(ET_LH2_XO, 0.0, ET_AXIS_ZO, b);
        part[np][0] = b[0]; part[np][1] = b[1]; part[np][2] = b[2]; part[np++][3] = etLh2;
        if (asc == ASC_PAD || asc == ASC_STACK)
            for (int k = 0; k < 2; k++) {
                to_body(SRB_XO, k ? SRB_YO : -SRB_YO, SRB_AXIS_ZO, b);
                part[np][0] = b[0]; part[np][1] = b[1]; part[np][2] = b[2];
                part[np++][3] = SRB_INERT_KG + srbProp;
            }
    }
    for (int k = 0; k < np; k++) {
        m += part[k][3];
        for (int i = 0; i < 3; i++) c[i] += part[k][3] * part[k][i];
    }
    for (int i = 0; i < 3; i++) c[i] /= m;
    double I[3][3] = { { DRY_IXX, 0, 0 }, { 0, DRY_IYY, 0 }, { 0, 0, DRY_IZZ } };
    for (int k = 0; k < np; k++) {
        /* each part: a point mass at its centre plus its own inertia as a
         * cylinder along body X (tank or booster) */
        double p[3] = { part[k][0] - c[0], part[k][1] - c[1], part[k][2] - c[2] };
        double pp = p[0] * p[0] + p[1] * p[1] + p[2] * p[2], mk = part[k][3];
        double rad = (k < 3) ? ET_RADIUS_M : SRB_RADIUS_M, len = (k < 3) ? 15.0 : 45.0;
        double ia = 0.5 * mk * rad * rad, it = mk * (3 * rad * rad + len * len) / 12.0;
        I[0][0] += ia; I[1][1] += it; I[2][2] += it;
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++)
                I[i][j] += mk * ((i == j ? pp : 0.0) - p[i] * p[j]);
    }
    /* the dry body, from its own CG (the origin) to the new one */
    double d[3] = { -c[0], -c[1], -c[2] };
    double dd = d[0] * d[0] + d[1] * d[1] + d[2] * d[2];
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            I[i][j] += dryKg * ((i == j ? dd : 0.0) - d[i] * d[j]);
    for (int k = 0; k < NMOD; k++) {
        double p[3] = { tank[k][0] - c[0], tank[k][1] - c[1], tank[k][2] - c[2] };
        double pp = p[0] * p[0] + p[1] * p[1] + p[2] * p[2];
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++)
                I[i][j] += prop[k] * ((i == j ? pp : 0.0) - p[i] * p[j]);
    }
    st.mass = m;
    memcpy(st.I, I, sizeof I);
    memcpy(cgB, c, sizeof c);
}

/* An engine's thrust as a fraction of full: 1 burning, falling through the
 * tail-off, 0 with its pod dry. */
static double oms_fraction(int e) {
    if (prop[3 + e] <= 0.0) return 0.0;
    if (oms[e].fire) return 1.0;
    return (oms[e].tail > 0.0) ? oms[e].tail / OMS_TAILOFF_S : 0.0;
}

/* The force and the torque about the current CG of the jets that are on. */
static void jet_loads(double f[3], double tau[3], double *mdot) {
    f[0] = f[1] = f[2] = tau[0] = tau[1] = tau[2] = 0.0;
    for (int m = 0; m < NMOD; m++) mdot[m] = 0.0;
    for (int k = 0; k < VEHDYN_NJETS; k++) {
        if (!on[k]) continue;
        const Jet *j = &JETS[k];
        int mod = jet_module(j);
        if (prop[mod] <= 0.0) continue;             /* a dry module fires nothing */
        double u[3], p[3], r[3], fk[3], t[3];
        jet_axis(j, u);
        to_body(j->xo, j->yo, j->zo, p);
        for (int i = 0; i < 3; i++) { r[i] = p[i] - cgB[i]; fk[i] = jet_thrust(j) * u[i]; }
        t[0] = r[1] * fk[2] - r[2] * fk[1];
        t[1] = r[2] * fk[0] - r[0] * fk[2];
        t[2] = r[0] * fk[1] - r[1] * fk[0];
        for (int i = 0; i < 3; i++) { f[i] += fk[i]; tau[i] += t[i]; }
        mdot[mod] += jet_mdot(j);
    }
    for (int e = 0; e < 2; e++) {
        double frac = oms_fraction(e);
        if (frac <= 0.0) continue;
        double P = OMS_CANT_P - oms[e].pos[0] * VD_PI / 180.0;
        double Y = oms[e].pos[1] * VD_PI / 180.0 + (e == 0 ? OMS_CANT_Y : -OMS_CANT_Y);
        double u[3] = { cos(P) * cos(Y), sin(Y), sin(P) * cos(Y) }, p[3], r[3], fk[3];
        to_body(OMS_XYZ[e][0], OMS_XYZ[e][1], OMS_XYZ[e][2], p);
        for (int i = 0; i < 3; i++) { r[i] = p[i] - cgB[i]; fk[i] = frac * OMS_THRUST_N * u[i]; }
        tau[0] += r[1] * fk[2] - r[2] * fk[1];
        tau[1] += r[2] * fk[0] - r[0] * fk[2];
        tau[2] += r[0] * fk[1] - r[1] * fk[0];
        for (int i = 0; i < 3; i++) f[i] += fk[i];
        mdot[3 + e] += frac * OMS_THRUST_N / (OMS_ISP_S * G0);
    }
}

/* The actuators, and the tail-off, dt seconds on. */
static void oms_slew(double dt) {
    for (int e = 0; e < 2; e++) {
        oms[e].tail -= dt;
        if (oms[e].tail < 0.0) oms[e].tail = 0.0;
    }
    static const double LIM[2] = { 7.0, 8.0 };
    for (int e = 0; e < 2; e++) {
        if (!oms[e].powered) continue;
        for (int a = 0; a < 2; a++) {
            double want = oms[e].cmd[a];
            if (want > LIM[a]) want = LIM[a];
            if (want < -LIM[a]) want = -LIM[a];
            double d = want - oms[e].pos[a], mx = OMS_SLEW_DEG_S * dt;
            oms[e].pos[a] += (d > mx) ? mx : (d < -mx) ? -mx : d;
        }
    }
}

void vehdyn_reset(double t) {
    flight_params();
    memset(&st, 0, sizeof st);
    for (int k = 0; k < 3; k++) prop[k] = RCS_LOAD_KG;
    prop[3] = prop[4] = OMS_LOAD_KG;
    {
        const char *e = yagpc_getenv("YAGPC_VEHDYN_ORBITER_KG");
        double kg = e ? atof(e) : 0.0, p = 0.0;
        for (int k = 0; k < NMOD; k++) p += prop[k];
        dryKg = (kg > p + 50000.0) ? kg - p : DRY_MASS_KG;
        if (kg > 0.0)
            fprintf(stderr, "vehdyn: the orbiter %.0f kg at liftoff (dry %.0f + propellant %.0f)\n",
                    dryKg + p, dryKg, p);
    }
    memset(oms, 0, sizeof oms);
    memset(on, 0, sizeof on);
    memset(onSec, 0, sizeof onSec);
    memset(sensedDv, 0, sizeof sensedDv);
    mass_properties();
    phys_init_circular(&st, 6378137.0, 400e3, 51.6 * VD_PI / 180.0, 0.0, 0.0, t);
    /* YAGPC_VEHDYN_ORBIT: the starting orbit, instead of 400 km circular at
     * 51.6 deg from the ascending node.  Four numbers, a circular orbit:
     * altitude (km), inclination, node and argument of latitude (deg); six,
     * any orbit: apogee and perigee altitudes (km), inclination, node,
     * argument of perigee and true anomaly (deg).  Altitudes above the
     * equatorial radius; the node in M50. */
    {
        const char *e = yagpc_getenv("YAGPC_VEHDYN_ORBIT");
        double x[6];
        int n = (e != NULL) ? sscanf(e, "%lf,%lf,%lf,%lf,%lf,%lf",
                                     &x[0], &x[1], &x[2], &x[3], &x[4], &x[5]) : 0;
        const double D = VD_PI / 180.0;
        if (n == 4)
            phys_init_circular(&st, 6378137.0, x[0] * 1e3, x[1] * D, x[2] * D, x[3] * D, t);
        else if (n == 6)
            phys_init_elements(&st, 6378137.0, x[0] * 1e3, x[1] * 1e3, x[2] * D,
                               x[3] * D, x[4] * D, x[5] * D, t);
        else if (e != NULL)
            fprintf(stderr, "vehdyn: YAGPC_VEHDYN_ORBIT wants 4 or 6 numbers, got \"%s\"\n", e);
    }
    /* YAGPC_VEHDYN_ATT=roll,pitch,yaw (degrees): the starting attitude, as a
     * yaw-pitch-roll sequence from M50; and YAGPC_VEHDYN_RATE=p,q,r (deg/s)
     * the starting body rates.  For tests: see that the IMU and the flight
     * software follow a vehicle that is not at the identity, or is turning. */
    {
        const char *e = yagpc_getenv("YAGPC_VEHDYN_ATT");
        double r = 0, p = 0, y = 0;
        if (e != NULL && sscanf(e, "%lf,%lf,%lf", &r, &p, &y) >= 1) {
            double cr = cos(r * VD_PI / 360), sr = sin(r * VD_PI / 360),
                   cp = cos(p * VD_PI / 360), sp = sin(p * VD_PI / 360),
                   cy = cos(y * VD_PI / 360), sy = sin(y * VD_PI / 360);
            /* q = qz(yaw) * qy(pitch) * qx(roll) */
            st.q[0] = cy * cp * cr + sy * sp * sr;
            st.q[1] = cy * cp * sr - sy * sp * cr;
            st.q[2] = cy * sp * cr + sy * cp * sr;
            st.q[3] = sy * cp * cr - cy * sp * sr;
        }
        const char *w = yagpc_getenv("YAGPC_VEHDYN_RATE");
        double a = 0, b = 0, c = 0;
        if (w != NULL && sscanf(w, "%lf,%lf,%lf", &a, &b, &c) >= 1) {
            st.w[0] = a * VD_PI / 180; st.w[1] = b * VD_PI / 180; st.w[2] = c * VD_PI / 180;
        }
    }
    asc = ASC_NONE;
    phys_set_drag(2.2, 40.0, 220.0, 360.0);
    {
        const char *pad = yagpc_getenv("YAGPC_VEHDYN_PAD");
        if (pad != NULL && *pad != '\0' && strcmp(pad, "0") != 0) pad_init(t);
    }
    haveTime = true;
    fireChanges = 0;
    histCount = 0;
    hist_push();
}

/* Advance in steps no longer than STEP_S, re-deriving the loads and the mass
 * properties at each, so propellant use changes the vehicle as it goes. */
#define STEP_S 0.005

void vehdyn_advance(double sharedUs) {
    if (sharedUs < 0.0) return;
    double t = sharedUs / 1e6;
    if (!haveTime) { vehdyn_reset(t); return; }
    if (t <= st.t) return;
    /* A long gap -- the computers in HALT, say -- is coasted in larger
     * steps when nothing is firing; with jets on, every step is short. */
    while (st.t < t) {
        ascent_events();
        /* ON THE PAD the stack goes round with the Earth whatever its engines
         * do; its accelerometers feel the pad holding it up. */
        if (asc == ASC_PAD) {
            double dt = t - st.t;
            if (dt > 0.02) dt = 0.02;
            if (dt < 1e-9) { st.t = t; break; }
            double v0[3], g[3], R[3][3];
            memcpy(v0, st.v, sizeof v0);
            tvc_slew(dt);
            pad_state(st.t + dt);
            phys_gravity(st.t, st.r, g);
            double a[3];
            for (int i = 0; i < 3; i++) {
                a[i] = (st.v[i] - v0[i]) / dt - g[i];
                sensedDv[i] += a[i] * dt;
            }
            qmat_body(st.q, R);
            for (int i = 0; i < 3; i++) sfB[i] = R[0][i] * a[0] + R[1][i] * a[1] + R[2][i] * a[2];
            /* the main engines run for 6.6 s before the SRBs light: their
             * propellant comes out of the tank here, though the hold-down
             * posts take their thrust */
            {
                double fp[3] = { 0, 0, 0 }, tp[3] = { 0, 0, 0 }, me = 0.0, ms = 0.0;
                ascent_loads(fp, tp, &me, &ms);
                if (me > 0.0) {
                    etLo2 -= me * dt * 6.0 / 7.0;
                    etLh2 -= me * dt / 7.0;
                    if (etLo2 < 0.0) etLo2 = 0.0;
                    if (etLh2 < 0.0) etLh2 = 0.0;
                    mass_properties();
                }
            }
            hist_push();
            state_log();
            continue;
        }
        double f[3], tau[3], mdot[NMOD], mdotEt = 0.0, mdotSrb = 0.0;
        jet_loads(f, tau, mdot);
        ascent_loads(f, tau, &mdotEt, &mdotSrb);
        if (asc == ASC_NONE) {          /* the orbiter alone: the tables, or the cannonball */
            bool was = aeroOn;
            aeroOn = entry_aero(f, tau);
            if (aeroOn != was) phys_set_drag(aeroOn ? 0.0 : 2.2, 40.0, 220.0, 360.0);
        }
        bool firing = (mdot[0] + mdot[1] + mdot[2] + mdot[3] + mdot[4]) > 0.0 ||
                      asc != ASC_NONE || aeroOn;
        double dt = t - st.t;
        double maxDt = firing ? STEP_S : 1.0;
        if (dt > maxDt) dt = maxDt;
        if (dt < 1e-9) { st.t = t; break; }
        oms_slew(dt);
        tvc_slew(dt);
        surf_slew(dt);
        /* What the accelerometers feel: everything but gravity -- the jets
         * and the air, the drag taken at the middle of the step. */
        double ad0[3], ad1[3];
        phys_drag_accel(&st, ad0);
        phys_step(&st, dt, firing ? f : NULL, firing ? tau : NULL);
        phys_drag_accel(&st, ad1);
        hist_push();
        state_log();
        entry_log();
        for (int i = 0; i < 3; i++) sensedDv[i] += 0.5 * (ad0[i] + ad1[i]) * dt;
        if (firing) {
            double fi[3];
            phys_body_to_inertial(&st, f, fi);
            for (int i = 0; i < 3; i++) sensedDv[i] += fi[i] / st.mass * dt;
            for (int k = 0; k < VEHDYN_NJETS; k++)
                if (on[k] && prop[jet_module(&JETS[k])] > 0.0) onSec[k] += dt;
            for (int e = 0; e < 2; e++)
                if (oms[e].fire && prop[3 + e] > 0.0) oms[e].onSec += dt;
            for (int m = 0; m < NMOD; m++) {
                prop[m] -= mdot[m] * dt;
                if (prop[m] < 0.0) prop[m] = 0.0;
            }
            if (asc == ASC_STACK || asc == ASC_ORB_ET) {
                double vn = sqrt(st.v[0] * st.v[0] + st.v[1] * st.v[1] + st.v[2] * st.v[2]);
                double rn = sqrt(st.r[0] * st.r[0] + st.r[1] * st.r[1] + st.r[2] * st.r[2]);
                double ai[3], ti[3], tn = 0, ta = 0, da = 0, ga = 0;
                phys_body_to_inertial(&st, aeroFb, ai);
                for (int i = 0; i < 3; i++) {
                    ti[i] = fi[i] - ai[i];
                    tn += ti[i] * ti[i];
                    ta += ti[i] * st.v[i] / vn;
                    da -= ai[i] * st.v[i] / vn;
                    ga += 3.986004418e14 / (rn * rn) * (st.r[i] / rn) * st.v[i] / vn;
                }
                budThrust += sqrt(tn) / st.mass * dt;
                budThrustAlong += ta / st.mass * dt;
                budDrag += da / st.mass * dt;
                budGrav += ga * dt;
            }
            if (asc != ASC_NONE) {
                etLo2 -= mdotEt * dt * 6.0 / 7.0;
                etLh2 -= mdotEt * dt / 7.0;
                srbProp -= 0.5 * mdotSrb * dt;
                if (etLo2 < 0.0) etLo2 = 0.0;
                if (etLh2 < 0.0) etLh2 = 0.0;
                if (srbProp < 0.0) srbProp = 0.0;
                for (int i = 0; i < 3; i++) sfB[i] = f[i] / st.mass;
            }
            mass_properties();
        }
        /* THE ORBITER ALONE: what the accelerometer assemblies feel is the
         * jets' and engines' thrust over the mass plus the air's drag, the
         * same quantity sensedDv integrates.  It was set only while the stack
         * flew, so after ET separation the AAs read the last ascent value
         * through OMS burns, RCS firings and (to come) entry. */
        if (asc == ASC_NONE) {
            double a[3], R[3][3];
            for (int i = 0; i < 3; i++) a[i] = 0.5 * (ad0[i] + ad1[i]);
            if (firing) {
                double fi[3];
                phys_body_to_inertial(&st, f, fi);
                for (int i = 0; i < 3; i++) a[i] += fi[i] / st.mass;
            }
            qmat_body(st.q, R);
            for (int i = 0; i < 3; i++) sfB[i] = R[0][i] * a[0] + R[1][i] * a[1] + R[2][i] * a[2];
        }
    }
}

void vehdyn_set_fire_words(const uint16_t ff[5], const uint16_t fa[5], double sharedUs) {
    if (!vehdyn_enabled()) return;
    vehdyn_advance(sharedUs);
    bool changed = false;
    for (int k = 0; k < VEHDYN_NJETS; k++) {
        const Jet *j = &JETS[k];
        uint16_t w = (j->mdm == 'F') ? ff[j->unit] : fa[j->unit];
        bool now = (w & j->bit) != 0;
        if (now != on[k]) changed = true;
        on[k] = now;
    }
    if (changed) {
        fireChanges++;
        /* YAGPC_VEHDYN_TRACE=1: every change of the fire command, with the
         * jets then on -- which jets a THC pulse or an RHC deflection fired,
         * and when. */
        static int trace = -1;
        if (trace < 0) trace = yagpc_getenv("YAGPC_VEHDYN_TRACE") != NULL;
        if (trace) {
            fprintf(stderr, "vehdyn: t=%.3f s fire:", st.t);
            int n = 0;
            for (int k = 0; k < VEHDYN_NJETS; k++)
                if (on[k]) { fprintf(stderr, " %s", JETS[k].name); n++; }
            fprintf(stderr, "%s   rates p q r %+.3f %+.3f %+.3f deg/s\n", n ? "" : " none",
                    st.w[0] * 57.29578, st.w[1] * 57.29578, st.w[2] * 57.29578);
        }
    }
}

/* ---------------------------------------------------------------------
 * THE VEHICLE'S CLOCK AND THE EARTH UNDER IT.
 *
 * The state's time t is the shared clock in seconds; the timing unit reports
 * GMT from the same clock, offset by the epoch the run stands for
 * (mtumodel.c, mtu_fill_time), and tells this module that offset as the Unix
 * time of t = 0.  The flight software counts GMT in seconds as
 * day-of-year x 86400 + seconds of the day, with day 1 Jan 1 -- FPMMTURM
 * defaults an unset clock to X'30' half-hours, "GMT TO 1 DAY" -- and so does
 * vehdyn_gmt().  A run that crosses New Year's Eve sees the count wrap, as
 * the unit's own day field does.
 *
 * The Earth turns as the flight software believes it does, exactly: M50 to
 * Earth-fixed at its epoch is GLW_RNP_MAT_COMP (GLWRNP.hal) evaluated with
 * the tape's I-loads -- LAUNCH_YEAR 2000, RNP_DAY 75 (CGGCOM.hal:576-583;
 * YAGPC_RNP=year,day for a tape built otherwise) -- the epoch is
 * RNP_DAY x 86400 (GO2ORB.hal, step 127.7D), and the angle since is
 * CGNS_EARTH_RATE (CGNCOM.hal:123) times the time since (GNFEAR.hal).  A GPS
 * position is then the truth state's own Earth-fixed position as PASS will
 * convert it back, with no difference of frame for navigation to absorb; the
 * gravity field turns with the same Earth.  That this is PASS's model of the
 * sky rather than the real one -- its fit is good near 2022 and the I-loads
 * say 2000 -- does not matter: no part of this simulation looks at stars. */
#define PASS_EARTH_RATE 0.729211514646E-4


static void pass_rnp(int year, int day, double A[3][3]) {
    const double PI = 3.14159265358979323846;
    double jday = day + trunc(365.25 * (year + 4799)) - 31790.5;
    double ut1 = jday - 2459579.5;
    double et = ut1 + 63.18 / 86400.0;
    double at = et * PI * 1e-4, sa = sin(at), ca = cos(at), ss = sa * sa, cc = 1.0 - ss;
    double s2 = 2 * ca * sa, c2 = cc - ss, s3 = sa * (3 * cc - ss), c3 = ca * (cc - 3 * ss);
    double X = 4.086914938E-5 + 3.30570821156E-9 * et + 5.3101057542E-13 * et * et
             + 1.91701187619E-5 * ca + 6.84908162624E-6 * sa - 6.07687147621E-6 * c2
             - 5.08608200417E-6 * s2 - 2.0912057236E-5 * c3 - 3.61848835411E-5 * s3;
    double Y = 7.00499683245E-3 + 2.67922724381E-7 * et - 3.72836339327E-13 * et * et
             - 1.08609567896E-5 * ca - 1.23753947146E-5 * sa - 8.83842901467E-7 * c2
             + 6.05983470459E-6 * s2 - 2.73258319638E-5 * c3 + 1.48249685562E-5 * s3;
    double Z = fmod(1.72302078155 + 6.30038748669 * ut1 - 2.30211679566E-15 * ut1 * ut1, 2 * PI);
    double cx = cos(X), sx = sin(X), cy = cos(Y), sy = sin(Y), cz = cos(Z), sz = sin(Z);
    A[0][0] = cy * cz;  A[0][1] = cx * sz + sx * sy * cz;  A[0][2] = sx * sz - cx * sy * cz;
    A[1][0] = -cy * sz; A[1][1] = cx * cz - sx * sy * sz; A[1][2] = sx * cz + cx * sy * sz;
    A[2][0] = sy;       A[2][1] = -sx * cy;               A[2][2] = cx * cy;
}

void vehdyn_set_gmt_zero(double unixAtZero) {
    unixZero = unixAtZero;
    time_t whole = (time_t)floor(unixAtZero);
    struct tm g;
    gmtime_r(&whole, &g);
    double z = (g.tm_yday + 1) * 86400.0 + g.tm_hour * 3600.0 + g.tm_min * 60.0 + g.tm_sec
             + (unixAtZero - (double)whole);
    if (fabs(z - gmtZero) < 1e-3) return;          /* already so */
    gmtZero = z;
    /* A RESTORED VEHICLE FLIES ON THROUGH THE GAP.  The timing unit's GMT
     * includes the time the restored computers sat in HALT before RUN (its
     * latched halt offset), which the flight software's clock counts and the
     * restored state did not: coast the truth through it, as the real
     * vehicle would have while its computers were stopped, so that state and
     * GMT agree again.  Without this the flight software's navigation,
     * propagated to the new GMT, was seconds -- tens of kilometres -- ahead
     * of the truth. */
    if (restoredGmt > 0.0) {
        double gap = z - restoredGmt;
        restoredGmt = -1.0;
        if (gap > 1e-6 && gap < 3600.0) {
            double r[3], v[3];
            memcpy(r, st.r, sizeof r);
            memcpy(v, st.v, sizeof v);
            PhysState c = st;
            c.t = 0.0;
            phys_advance_to(&c, gap, 1.0, NULL, NULL);
            memcpy(st.r, c.r, sizeof st.r); memcpy(st.v, c.v, sizeof st.v);
            memcpy(st.q, c.q, sizeof st.q); memcpy(st.w, c.w, sizeof st.w);
            histCount = 0;
            hist_push();
            fprintf(stderr, "vehdyn: restored state coasted %.3f s, to the timing unit's GMT\n", gap);
        }
    }
    int year = 2000, day = 75;
    const char *e = yagpc_getenv("YAGPC_RNP");
    if (e != NULL) sscanf(e, "%d,%d", &year, &day);
    double A[3][3];
    pass_rnp(year, day, A);
    /* angle = rate (GMT - RNP_DAY 86400), GMT = gmtZero + t */
    phys_set_earth(A, 0.0, day * 86400.0 - gmtZero, PASS_EARTH_RATE);
}

bool vehdyn_state_at(double t, double r[3], double v[3]) {
    if (histCount == 0) return false;
    int k = histHead, newer = -1;
    for (int n = 0; n < histCount; n++) {
        if (hist[k].t <= t) break;
        newer = k;
        k = (k - 1 + HIST_N) % HIST_N;
        if (n == histCount - 1) return false;          /* older than we keep */
    }
    if (newer < 0) {                                     /* at or after the newest */
        if (t - hist[k].t > 1e-9) return false;
        memcpy(r, hist[k].r, 3 * sizeof *r); memcpy(v, hist[k].v, 3 * sizeof *v);
        return true;
    }
    double t0 = hist[k].t, h = hist[newer].t - t0, s = (t - t0) / h;
    double s2 = s * s, s3 = s2 * s;
    double h00 = 2 * s3 - 3 * s2 + 1, h10 = s3 - 2 * s2 + s, h01 = -2 * s3 + 3 * s2, h11 = s3 - s2;
    double d00 = (6 * s2 - 6 * s) / h, d10 = 3 * s2 - 4 * s + 1, d01 = (-6 * s2 + 6 * s) / h,
           d11 = 3 * s2 - 2 * s;
    for (int i = 0; i < 3; i++) {
        double r0 = hist[k].r[i], v0 = hist[k].v[i], r1 = hist[newer].r[i], v1 = hist[newer].v[i];
        r[i] = h00 * r0 + h10 * h * v0 + h01 * r1 + h11 * h * v1;
        v[i] = d00 * r0 + d10 * v0 + d01 * r1 + d11 * v1;
    }
    return true;
}

double vehdyn_gmt(double t) { return (gmtZero >= 0.0) ? gmtZero + t : -1.0; }
double vehdyn_unix(double t) { return (unixZero >= 0.0) ? unixZero + t : -1.0; }

const PhysState *vehdyn_state(void) { return &st; }
double vehdyn_propellant(int module) { return (module >= 0 && module < NMOD) ? prop[module] : 0.0; }

void vehdyn_set_propellant(int module, double kg) {
    if (module < 0 || module >= NMOD) return;
    prop[module] = (kg > 0.0) ? kg : 0.0;
    mass_properties();
}

void vehdyn_set_oms(int e, bool fire, bool powered, double pitchDeg, double yawDeg,
                    double sharedUs) {
    if (!vehdyn_enabled() || e < 0 || e > 1) return;
    vehdyn_advance(sharedUs);
    if (fire != oms[e].fire) {
        fireChanges++;
        static int trace = -1;
        if (trace < 0) trace = yagpc_getenv("YAGPC_VEHDYN_TRACE") != NULL;
        if (trace)
            fprintf(stderr, "vehdyn: t=%.3f s %s OMS %s, gimbal %+.2f %+.2f deg\n", st.t,
                    e ? "right" : "left", fire ? "ON" : "off", oms[e].pos[0], oms[e].pos[1]);
    }
    if (oms[e].fire && !fire) oms[e].tail = OMS_TAILOFF_S;
    if (fire) oms[e].tail = 0.0;
    oms[e].fire = fire;
    oms[e].powered = powered;
    if (powered) { oms[e].cmd[0] = pitchDeg; oms[e].cmd[1] = yawDeg; }
}

bool vehdyn_oms_burning(int e) {
    return e >= 0 && e <= 1 && oms[e].fire && prop[3 + e] > 0.0;
}

double vehdyn_oms_thrust(int e) { return (e >= 0 && e <= 1) ? oms_fraction(e) : 0.0; }

double vehdyn_oms_gimbal(int e, int axis) {
    return (e >= 0 && e <= 1 && axis >= 0 && axis <= 1) ? oms[e].pos[axis] : 0.0;
}

double vehdyn_oms_on_seconds(int e) { return (e >= 0 && e <= 1) ? oms[e].onSec : 0.0; }
void vehdyn_sensed_dv(double out[3]) { memcpy(out, sensedDv, sizeof sensedDv); }
double vehdyn_jet_on_seconds(int k) { return (k >= 0 && k < VEHDYN_NJETS) ? onSec[k] : 0.0; }
const char *vehdyn_jet_name(int k) { return (k >= 0 && k < VEHDYN_NJETS) ? JETS[k].name : "?"; }
int vehdyn_jet_index(const char *name) {
    for (int k = 0; k < VEHDYN_NJETS; k++) if (strcmp(JETS[k].name, name) == 0) return k;
    return -1;
}

void vehdyn_report(void) {
    if (!vehdyn_enabled() || !haveTime) return;
    double fired = 0.0;
    for (int k = 0; k < VEHDYN_NJETS; k++) fired += onSec[k];
    fprintf(stderr, "vehdyn: t=%.1f s; %ld fire-command change(s), %.2f jet-seconds; "
                    "RCS propellant F/L/R %.1f/%.1f/%.1f kg; OMS L/R %.1f/%.1f kg, "
                    "%.1f/%.1f s burning; rates %.4f/%.4f/%.4f deg/s; "
                    "q %.6f %.6f %.6f %.6f\n",
            st.t, fireChanges, fired, prop[0], prop[1], prop[2], prop[3], prop[4],
            oms[0].onSec, oms[1].onSec,
            st.w[0] * 180 / VD_PI, st.w[1] * 180 / VD_PI, st.w[2] * 180 / VD_PI,
            st.q[0], st.q[1], st.q[2], st.q[3]);
}

/* ---------------------------------------------------------------------
 * IN A SESSION CAPTURE (mdmdev.c writes it into vehdyn.json).  Everything
 * that is state rather than configuration, as numbers in a fixed order after
 * a version.  A restore starts the vehicle's clock at zero, so the state's
 * time is rebased: t becomes 0 and the history starts over at that instant;
 * GMT stays continuous because the timing unit's epoch moves with it
 * (vehdyn_set_gmt_zero is called again from the restored clock). */
#define SAVE_VERSION 1.0

int vehdyn_save(double *b, int max) {
    int n = 0;
#define PUT(x) do { if (n < max) b[n] = (double)(x); n++; } while (0)
    PUT(SAVE_VERSION);
    PUT(haveTime ? 1 : 0);
    PUT(st.t);
    for (int i = 0; i < 3; i++) PUT(st.r[i]);
    for (int i = 0; i < 3; i++) PUT(st.v[i]);
    for (int i = 0; i < 4; i++) PUT(st.q[i]);
    for (int i = 0; i < 3; i++) PUT(st.w[i]);
    for (int k = 0; k < NMOD; k++) PUT(prop[k]);
    for (int i = 0; i < 3; i++) PUT(sensedDv[i]);
    for (int k = 0; k < VEHDYN_NJETS; k++) PUT(on[k] ? 1 : 0);
    for (int k = 0; k < VEHDYN_NJETS; k++) PUT(onSec[k]);
    for (int e = 0; e < 2; e++) {
        PUT(oms[e].fire ? 1 : 0); PUT(oms[e].powered ? 1 : 0);
        PUT(oms[e].cmd[0]); PUT(oms[e].cmd[1]); PUT(oms[e].pos[0]); PUT(oms[e].pos[1]);
        PUT(oms[e].onSec);
    }
    PUT(gmtZero >= 0.0 ? gmtZero + st.t : -1.0);      /* the state's GMT */
    PUT(oms[0].tail); PUT(oms[1].tail);
    /* the ascent: what the vehicle is, and what it has left */
    PUT(asc); PUT(etLo2); PUT(etLh2); PUT(srbProp); PUT(srbIgnT < 0.0 ? -1.0 : srbIgnT - st.t);
    PUT(padAz);
    for (int i = 0; i < 3; i++) PUT(padR[i]);
    for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) PUT(padCbe[i][j]);
    for (int a = 0; a < 5; a++) for (int x = 0; x < 2; x++) { PUT(tvcCmd[a][x]); PUT(tvcPos[a][x]); }
    PUT(dryKg);
#undef PUT
    return n;
}

double vehdyn_load(const double *b, int n) {
    int i = 0;
#define GET() ((i < n) ? b[i++] : (i++, 0.0))
    if (n < 1 || GET() != SAVE_VERSION) return -1.0;
    bool had = GET() != 0.0;
    double t = GET();
    for (int k = 0; k < 3; k++) st.r[k] = GET();
    for (int k = 0; k < 3; k++) st.v[k] = GET();
    for (int k = 0; k < 4; k++) st.q[k] = GET();
    for (int k = 0; k < 3; k++) st.w[k] = GET();
    for (int k = 0; k < NMOD; k++) prop[k] = GET();
    for (int k = 0; k < 3; k++) sensedDv[k] = GET();
    for (int k = 0; k < VEHDYN_NJETS; k++) on[k] = GET() != 0.0;
    for (int k = 0; k < VEHDYN_NJETS; k++) onSec[k] = GET();
    for (int e = 0; e < 2; e++) {
        oms[e].fire = GET() != 0.0; oms[e].powered = GET() != 0.0;
        oms[e].cmd[0] = GET(); oms[e].cmd[1] = GET();
        oms[e].pos[0] = GET(); oms[e].pos[1] = GET();
        oms[e].onSec = GET();
    }
    double gmtCap = (i < n) ? b[i] : -1.0;
    i++;
    for (int e = 0; e < 2; e++, i++) oms[e].tail = (i < n) ? b[i] : 0.0;
    if (i < n) {
        asc = (int)GET(); etLo2 = GET(); etLh2 = GET(); srbProp = GET();
        double ig = GET();
        srbIgnT = ig < 0.0 ? -1.0 : ig;            /* rebased: the clock restarts at 0 */
        padAz = GET();
        for (int k = 0; k < 3; k++) padR[k] = GET();
        for (int k = 0; k < 3; k++) for (int j = 0; j < 3; j++) padCbe[k][j] = GET();
        for (int a = 0; a < 5; a++) for (int x = 0; x < 2; x++) { tvcCmd[a][x] = GET(); tvcPos[a][x] = GET(); }
        if (i < n) dryKg = GET();
        if (asc != ASC_NONE) phys_set_drag(0.0, 0.0, 0.0, 0.0);
    }
#undef GET
    if (i > n + 3 && asc == ASC_NONE) return -1.0;     /* the GMT and the tail-offs may be missing: older */
    haveTime = had;
    st.t = 0.0;                    /* the restored clock's zero */
    mass_properties();
    histCount = 0;
    hist_push();
    if (gmtZero >= 0.0) gmtZero += t;
    if (unixZero >= 0.0) unixZero += t;
    restoredGmt = gmtCap;
    return t;
}

void vehdyn_set_rv(const double r[3], const double v[3]) {
    memcpy(st.r, r, sizeof st.r);
    memcpy(st.v, v, sizeof st.v);
}

void vehdyn_set_attitude(const double q[4], const double w[3]) {
    double n = sqrt(q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3]);
    for (int i = 0; i < 4; i++) st.q[i] = (n > 0.0) ? q[i] / n : (i == 0);
    for (int i = 0; i < 3; i++) st.w[i] = w ? w[i] : 0.0;
}
