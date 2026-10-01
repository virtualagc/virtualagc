#include "vehdyn.h"

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>

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

static const double TANK_XYZ[3][3] = {     /* inches, Orbiter structural */
    {  375.0,    0.0, 400.0 },
    { 1510.0, -105.0, 465.0 },
    { 1510.0,  105.0, 465.0 },
};

static PhysState st;
static double prop[3];                 /* kg left, per module */
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
    double tank[3][3];
    for (int k = 0; k < 3; k++) {
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
    for (int k = 0; k < 3; k++) {
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

/* The force and the torque about the current CG of the jets that are on. */
static void jet_loads(double f[3], double tau[3], double *mdot) {
    f[0] = f[1] = f[2] = tau[0] = tau[1] = tau[2] = 0.0;
    for (int m = 0; m < 3; m++) mdot[m] = 0.0;
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
}

void vehdyn_reset(double t) {
    memset(&st, 0, sizeof st);
    for (int k = 0; k < 3; k++) prop[k] = RCS_LOAD_KG;
    memset(on, 0, sizeof on);
    memset(onSec, 0, sizeof onSec);
    memset(sensedDv, 0, sizeof sensedDv);
    mass_properties();
    phys_init_circular(&st, 6378137.0, 400e3, 51.6 * VD_PI / 180.0, 0.0, 0.0, t);
    haveTime = true;
    fireChanges = 0;
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
        double f[3], tau[3], mdot[3];
        jet_loads(f, tau, mdot);
        bool firing = (mdot[0] + mdot[1] + mdot[2]) > 0.0;
        double dt = t - st.t;
        double maxDt = firing ? STEP_S : 1.0;
        if (dt > maxDt) dt = maxDt;
        if (dt < 1e-9) { st.t = t; break; }
        phys_step(&st, dt, firing ? f : NULL, firing ? tau : NULL);
        if (firing) {
            double fi[3];
            phys_body_to_inertial(&st, f, fi);
            for (int i = 0; i < 3; i++) sensedDv[i] += fi[i] / st.mass * dt;
            for (int k = 0; k < VEHDYN_NJETS; k++)
                if (on[k] && prop[jet_module(&JETS[k])] > 0.0) onSec[k] += dt;
            for (int m = 0; m < 3; m++) {
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
    if (changed) fireChanges++;
}

const PhysState *vehdyn_state(void) { return &st; }
double vehdyn_propellant(int module) { return (module >= 0 && module < 3) ? prop[module] : 0.0; }
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
                    "RCS propellant F/L/R %.1f/%.1f/%.1f kg; rates %.4f/%.4f/%.4f deg/s; "
                    "q %.6f %.6f %.6f %.6f\n",
            st.t, fireChanges, fired, prop[0], prop[1], prop[2],
            st.w[0] * 180 / VD_PI, st.w[1] * 180 / VD_PI, st.w[2] * 180 / VD_PI,
            st.q[0], st.q[1], st.q[2], st.q[3]);
}

void vehdyn_set_attitude(const double q[4], const double w[3]) {
    double n = sqrt(q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3]);
    for (int i = 0; i < 4; i++) st.q[i] = (n > 0.0) ? q[i] / n : (i == 0);
    for (int i = 0; i < 3; i++) st.w[i] = w ? w[i] : 0.0;
}
