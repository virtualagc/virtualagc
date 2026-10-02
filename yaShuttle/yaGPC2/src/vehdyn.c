#include "vehdyn.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <time.h>

#include "envcache.h"

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

/* Total mass, the CG (as an offset from the dry CG) and the inertia tensor
 * about it, from the dry vehicle and the propellant left: parallel-axis
 * shifts of the dry body and of each module's propellant as a point mass. */
static void mass_properties(void) {
    double m = DRY_MASS_KG, c[3] = { 0, 0, 0 };
    double tank[NMOD][3];
    for (int k = 0; k < NMOD; k++) {
        to_body(TANK_XYZ[k][0], TANK_XYZ[k][1], TANK_XYZ[k][2], tank[k]);
        m += prop[k];
        for (int i = 0; i < 3; i++) c[i] += prop[k] * tank[k][i];
    }
    for (int i = 0; i < 3; i++) c[i] /= m;
    double I[3][3] = { { DRY_IXX, 0, 0 }, { 0, DRY_IYY, 0 }, { 0, 0, DRY_IZZ } };
    /* the dry body, from its own CG (the origin) to the new one */
    double d[3] = { -c[0], -c[1], -c[2] };
    double dd = d[0] * d[0] + d[1] * d[1] + d[2] * d[2];
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            I[i][j] += DRY_MASS_KG * ((i == j ? dd : 0.0) - d[i] * d[j]);
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
    memset(&st, 0, sizeof st);
    for (int k = 0; k < 3; k++) prop[k] = RCS_LOAD_KG;
    prop[3] = prop[4] = OMS_LOAD_KG;
    memset(oms, 0, sizeof oms);
    memset(on, 0, sizeof on);
    memset(onSec, 0, sizeof onSec);
    memset(sensedDv, 0, sizeof sensedDv);
    mass_properties();
    phys_init_circular(&st, 6378137.0, 400e3, 51.6 * VD_PI / 180.0, 0.0, 0.0, t);
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
        double f[3], tau[3], mdot[NMOD];
        jet_loads(f, tau, mdot);
        bool firing = (mdot[0] + mdot[1] + mdot[2] + mdot[3] + mdot[4]) > 0.0;
        double dt = t - st.t;
        double maxDt = firing ? STEP_S : 1.0;
        if (dt > maxDt) dt = maxDt;
        if (dt < 1e-9) { st.t = t; break; }
        oms_slew(dt);
        /* What the accelerometers feel: everything but gravity -- the jets
         * and the air, the drag taken at the middle of the step. */
        double ad0[3], ad1[3];
        phys_drag_accel(&st, ad0);
        phys_step(&st, dt, firing ? f : NULL, firing ? tau : NULL);
        phys_drag_accel(&st, ad1);
        hist_push();
        state_log();
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
            mass_properties();
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
#undef GET
    if (i > n + 3) return -1.0;     /* the GMT and the tail-offs may be missing: older */
    haveTime = had;
    st.t = 0.0;                    /* the restored clock's zero */
    mass_properties();
    histCount = 0;
    hist_push();
    if (gmtZero >= 0.0) gmtZero += t;
    restoredGmt = gmtCap;
    return t;
}

void vehdyn_set_attitude(const double q[4], const double w[3]) {
    double n = sqrt(q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3]);
    for (int i = 0; i < 4; i++) st.q[i] = (n > 0.0) ? q[i] / n : (i == 0);
    for (int i = 0; i < 3; i++) st.w[i] = w ? w[i] : 0.0;
}
