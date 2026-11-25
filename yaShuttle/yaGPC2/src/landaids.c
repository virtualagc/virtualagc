/* THE LANDING AIDS: the Microwave Scanning Beam Landing System (MSBLS, "MLS")
 * and the radar altimeters, as PASS reads them through the forward MDMs.
 *
 * WHERE THE BEACONS ARE.  YAGPC_NAVAIDS names a text file written by
 * tools/landing_sites.py --navaids from the same site file (in tools/sites/)
 * that writes PASS's own I-loads (CGN13R), with every value as PASS decodes it
 * from those I-loads -- so the vehicle's beacons and its navigation's idea of
 * them agree to the bit:
 *     runway SLOT ID LAT LON ALT_FT AZ
 *     mls SLOT RWSLOT RAZ_LAT RAZ_LON RAZ_ALT RAZ_BEARING EL_LAT EL_LON EL_ALT EL_BEARING
 * (radians, feet).  Without it the aids answer "no data".
 *
 * WHAT IS MEASURED.  Everything from the navigation base -- the IMUs' place,
 * which PASS navigates and offsets its aids' antennas from (vehdyn.c,
 * vehdyn_navbase_ef) -- in PASS's Earth-fixed frame, with PASS's own
 * geometry, so that a perfect navigation state predicts these measurements
 * exactly:
 *   GNK_GEODETIC_TO_EF (GNKGEO.hal): a 20,925,646.3255 ft, f 1/298.3;
 *   GNL_EF_TO_RUNWAY / GNG_EF_TO_TOPDET: X along the bearing, Y right, Z down;
 *   GNM_EF_TO_SCANNER (GNMEFT.hal): that with Y and Z negated (left, up);
 *   GNAMLS.hal: range |R - R_RAZ| (:177), azimuth atan(R2/R1) in the R/AZ
 *     scanner's frame (:203-212), elevation atan(R3/R1) in the elevation
 *     scanner's (:240-255).
 * The elevation antenna's own small offset (CGNS_MLSANT_NB_DIST, :257) is not
 * modelled: a few tenths of a degree close in, which navigation absorbs.
 *
 * THE WORDS.  MLS: FF1-3 card 11 channel 1, three words (FIOFFIC6, X'26C22';
 * GYKMLS.hal:88-96): azimuth, elevation, range.  Bit 16 (0x0001) 1 = invalid;
 * bits 2-14 the magnitude, (w>>2)&0x1FFF; azimuth bit 1 the sign; elevation
 * bit 1 the receiver's BITE (0 here).  Range 10.36 x 2^-12 n.mi. a count
 * (6076.1155 ft/n.mi., CGIGNC.hal:92-103), azimuth and elevation 16 x 2^-12
 * deg.  Real receivers' words never sit still, and PASS time-tags a value
 * only when it changes (GYKMLS.hal:104-245): a dither of a count keeps them
 * moving.  Out of coverage -- beyond the 20.7 n.mi. the word can hold, or
 * outside the scanners' beams -- all three words read 0x0001, invalid.
 *
 * TACAN: see landaids_tacan_ra below and the "TACAN" comment there.
 *
 * Radar altimeter: RA i in FF i's card 0 channel 0 seven-word read
 * (FIOFFIC2, X'24006'), word 5, with its power bit in word 6 (GYRRAD.hal
 * 54-83; CGBIM1.hal:921-923): word 6 0x0400 power on; word 5 0x0002 valid,
 * bits 2-14 altitude in feet, and ODD parity over all sixteen bits (0x0001
 * the parity bit).  The reading is the antenna's height above the ground;
 * PASS takes the antenna back to its navigation point itself, 12.915 ft at
 * 2.005 rad from it in pitch (GHEUPG.hal:457-463), and so does this.  Ground
 * is the nearest runway's height (KSC is flat and at sea level); valid
 * below 5000 ft. */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "envcache.h"
#include "landaids.h"
#include "vehdyn.h"

#define FT_M        0.3048
#define PASS_A_FT   20925646.3255
#define PASS_F      (1.0 / 298.3)
#define MLS_RANGE_FT_PER_COUNT (10.36 / 4096.0 * 6076.1155)
#define MLS_DEG_PER_COUNT      (16.0 / 4096.0)
#define MLS_MAX_COUNT 0x1FFF
#define MLS_AZ_COVER_DEG 15.0
#define MLS_EL_MIN_DEG 0.0
#define MLS_EL_MAX_DEG 30.0
#define RA_MAX_FT 5000.0
#define RA_ANT_FT 12.915
#define RA_ANT_RAD 2.005
/* PASS's own tables' sizes: CGNS_RW_AREA_TABLE(90), CGNS_MLS_AREA_TABLE(15)
 * (tools/landing_sites.py).  A site file uses the slots its flight's area
 * table did -- Edwards's are 79-90 -- so 8 dropped them all. */
#define RW_MAX 90
#define MLS_MAX 15
#define LA_PI 3.14159265358979323846

typedef struct { double lat, lon, alt, az; char id[8]; } Runway;
typedef struct {
    int rw;
    double raz[3], el[3];            /* Earth-fixed, ft */
    double Mraz[3][3], Mel[3][3];    /* Earth-fixed -> scanner */
} Mls;

/* A TACAN station, from the navaids file's "tacan" lines:
 *     tacan SLOT ID CHANNEL MODE LAT LON ALT_FT MAGVAR
 * (radians, feet; MODE X or Y; MAGVAR the table's east-positive magnetic
 * variation, radians).  TACAN_MAX is PASS's own table size, CGNS_TACAN_AREA_TABLE(90). */
#define TACAN_MAX 90
typedef struct { int slot, channel, y; double lat, lon, alt, magvar, ef[3], M[3][3]; char id[8]; } Tacan;
static Tacan tac[TACAN_MAX];
static int nTac;

static Runway rws[RW_MAX];                   /* by slot - 1; id[0] 0: no runway there */
static Mls mls[MLS_MAX];
static int nRw, nMls, loaded;
static unsigned dither;

static void geodetic_to_ef(double lat, double lon, double alt, double r[3]) {
    double c = cos(lat), s = sin(lat), d = (1.0 - PASS_F) * (1.0 - PASS_F);
    double n = PASS_A_FT / sqrt(c * c + s * s * d);
    double eq = (n + alt) * c;
    r[0] = eq * cos(lon);
    r[1] = eq * sin(lon);
    r[2] = (d * n + alt) * s;
}

/* GNM_EF_TO_SCANNER: rows X along the bearing, Y left, Z up. */
static void ef_to_scanner(double lat, double lon, double az, double M[3][3]) {
    double sl = sin(lat), cl = cos(lat), so = sin(lon), co = cos(lon);
    double N[3] = { -sl * co, -sl * so, cl }, E[3] = { -so, co, 0.0 }, Dn[3] = { -cl * co, -cl * so, -sl };
    double ca = cos(az), sa = sin(az);
    for (int j = 0; j < 3; j++) {
        M[0][j] = ca * N[j] + sa * E[j];
        M[1][j] = -(ca * E[j] - sa * N[j]);
        M[2][j] = -Dn[j];
    }
}

static void load(void) {
    loaded = 1;
    const char *path = yagpc_getenv("YAGPC_NAVAIDS");
    if (path == NULL || *path == '\0') return;
    FILE *fp = fopen(path, "r");
    if (fp == NULL) {
        fprintf(stderr, "landaids: cannot read YAGPC_NAVAIDS %s\n", path);
        return;
    }
    char line[512];
    while (fgets(line, sizeof line, fp)) {
        if (line[0] == '#') continue;
        int slot, rw;
        char id[16];
        double v[8];
        if (strncmp(line, "runway ", 7) == 0 &&
            sscanf(line + 7, "%d %15s %lf %lf %lf %lf", &slot, id, &v[0], &v[1], &v[2], &v[3]) == 6 &&
            slot >= 1 && slot <= RW_MAX) {
            Runway *r = &rws[slot - 1];
            r->lat = v[0]; r->lon = v[1]; r->alt = v[2]; r->az = v[3];
            snprintf(r->id, sizeof r->id, "%.7s", id);   /* PASS ids are six characters */
            if (slot > nRw) nRw = slot;
        } else if (strncmp(line, "tacan ", 6) == 0) {
            int ch;
            char md[4];
            double q[4];
            if (sscanf(line + 6, "%d %15s %d %3s %lf %lf %lf %lf", &slot, id, &ch, md, &q[0], &q[1], &q[2], &q[3]) == 8 &&
                slot >= 1 && slot <= TACAN_MAX) {
                Tacan *t = &tac[slot - 1];
                t->slot = slot; t->channel = ch; t->y = (md[0] == 'Y' || md[0] == 'y');
                t->lat = q[0]; t->lon = q[1]; t->alt = q[2]; t->magvar = q[3];
                snprintf(t->id, sizeof t->id, "%.7s", id);
                geodetic_to_ef(t->lat, t->lon, t->alt, t->ef);
                /* GNG_EF_TO_TOPDET: rows north, east, down */
                double sl = sin(t->lat), cl = cos(t->lat), so = sin(t->lon), co = cos(t->lon);
                double N[3] = { -sl * co, -sl * so, cl }, E[3] = { -so, co, 0.0 }, D[3] = { -cl * co, -cl * so, -sl };
                for (int j = 0; j < 3; j++) { t->M[0][j] = N[j]; t->M[1][j] = E[j]; t->M[2][j] = D[j]; }
                if (slot > nTac) nTac = slot;
            }
        } else if (strncmp(line, "mls ", 4) == 0 &&
                   sscanf(line + 4, "%d %d %lf %lf %lf %lf %lf %lf %lf %lf", &slot, &rw,
                          &v[0], &v[1], &v[2], &v[3], &v[4], &v[5], &v[6], &v[7]) == 10 &&
                   slot >= 1 && slot <= MLS_MAX) {
            Mls *m = &mls[slot - 1];
            m->rw = rw;
            geodetic_to_ef(v[0], v[1], v[2], m->raz);
            ef_to_scanner(v[0], v[1], v[3], m->Mraz);
            geodetic_to_ef(v[4], v[5], v[6], m->el);
            ef_to_scanner(v[4], v[5], v[7], m->Mel);
            if (slot > nMls) nMls = slot;
        }
    }
    fclose(fp);
    fprintf(stderr, "landaids: %d runway(s), %d MLS site(s), %d TACAN station(s) from %s\n", nRw, nMls, nTac, path);
}

static uint16_t mag_word(double counts, int sign) {
    long c = lround(fabs(counts));
    if (c > MLS_MAX_COUNT) c = MLS_MAX_COUNT;
    return (uint16_t)(((unsigned)c << 2) | (sign && counts < 0.0 ? 0x8000u : 0u));
}

void landaids_mls(int unit, uint16_t w[3]) {
    (void)unit;
    if (!loaded) load();
    w[0] = w[1] = w[2] = 0x0001u;
    if (!vehdyn_enabled() || nMls == 0) return;
    double rM[3], vM[3], C[3][3], r[3];
    vehdyn_navbase_ef(rM, vM, C);
    for (int i = 0; i < 3; i++) r[i] = rM[i] / FT_M;
    int best = -1;
    double bestAz = 1e9, az = 0, el = 0, rng = 0;
    for (int k = 0; k < nMls; k++) {
        Mls *m = &mls[k];
        if (m->rw == 0) continue;
        double d[3], sa[3], se[3];
        for (int i = 0; i < 3; i++) d[i] = r[i] - m->raz[i];
        for (int i = 0; i < 3; i++) sa[i] = m->Mraz[i][0] * d[0] + m->Mraz[i][1] * d[1] + m->Mraz[i][2] * d[2];
        if (sa[0] <= 0.0) continue;                      /* behind the azimuth scanner */
        double a = atan(sa[1] / sa[0]) * 180.0 / LA_PI;
        double R = sqrt(d[0] * d[0] + d[1] * d[1] + d[2] * d[2]);
        if (fabs(a) > MLS_AZ_COVER_DEG || R / MLS_RANGE_FT_PER_COUNT > MLS_MAX_COUNT) continue;
        for (int i = 0; i < 3; i++) d[i] = r[i] - m->el[i];
        for (int i = 0; i < 3; i++) se[i] = m->Mel[i][0] * d[0] + m->Mel[i][1] * d[1] + m->Mel[i][2] * d[2];
        double e = se[0] > 0.0 ? atan(se[2] / se[0]) * 180.0 / LA_PI : -90.0;
        if (fabs(a) < bestAz) { bestAz = fabs(a); best = k; az = a; el = e; rng = R; }
    }
    if (best < 0) return;
    dither++;
    double dj = (dither & 1) ? 0.5 : -0.5;              /* a count's worth of motion */
    w[0] = mag_word(az / MLS_DEG_PER_COUNT + dj, 1);
    if (el >= MLS_EL_MIN_DEG && el <= MLS_EL_MAX_DEG)
        w[1] = mag_word(el / MLS_DEG_PER_COUNT - dj, 0);
    w[2] = mag_word(rng / MLS_RANGE_FT_PER_COUNT + dj, 0);
}

/* Height of a point above PASS's ellipsoid, ft (the standard iteration). */
static double ellipsoid_height_ft(const double r[3]) {
    double e2 = PASS_F * (2.0 - PASS_F), p = sqrt(r[0] * r[0] + r[1] * r[1]);
    double lat = atan2(r[2], p * (1.0 - e2)), h = 0.0;
    for (int i = 0; i < 5; i++) {
        double s = sin(lat), n = PASS_A_FT / sqrt(1.0 - e2 * s * s);
        h = p / cos(lat) - n;
        lat = atan2(r[2], p * (1.0 - e2 * n / (n + h)));
    }
    return h;
}

/* THE TACAN.  Three units (FF1-3), each a transceiver the GPC tunes by a
 * control word it writes (GYUTAC.hal:157-163; FIOHO205, X'200C1': card 0
 * channel 6, two words, the control register and the antenna word) and reads
 * back, with the measurements, in the seven-word FIOFFIC2 read (X'24006'):
 *   word 1  bearing A (GYTTAC.hal:143-184): bits 2-3 status (00 valid <180 deg,
 *           11 valid >=180, 01 self-test failure, 10 no data), bits 4-15 a
 *           12-bit count of 90 x 2^-11 deg (the 180 deg of status 11 is added
 *           by PASS); e.g. 0x6CC0 = 251.71875 deg (SOP 4.43 Fig -5)
 *   word 2  bearing B: 0x0001, not read
 *   word 3  range A (110-142): bits 1-2 status (00 valid, 10 no data), then
 *           BCD hundreds (2 bits), tens, ones, tenths of a n.mi.
 *   word 4  range B: the hundredths in the top nibble, label 0x89
 *           (257.85 n.mi. = 0x2578, 0x5089)
 *   word 5  the radar altimeter, below
 *   word 6  discretes: 0x4000 TACAN power, 0x1000 test status good, 0x0400 RA power
 *   word 7  the control register read back: PASS compares (w & 0x21FE) with the
 *           channel of the station it has selected (GYTTAC.hal:185-195,
 *           GVQSIT.hal:393-401): 0x2000 Y mode, units 1,2,4,8 = 0x0100..0x0020,
 *           tens 10,20,40,80 = 0x0010..0x0002 (TTS 59Y: 0x2134; COF 97X: 0x01D2).
 * WHAT IS MEASURED, from the navigation base as every other aid (the antenna's
 * offset is not modelled), with PASS's geometry and the 29 ms PASS assumes
 * between the measurement and its time tag (CGNS_TIME_BIAS_TACAN,
 * CGNFL1.hal:320; the position is taken back by that much):
 *   range    the slant range to the tuned station, encoded in true n.mi.
 *            (6076.1155 ft) -- PASS decodes with CGYS_TNM_FT, 6077.6248
 *            (CGYFL1.hal:280), so a flown 0.025% scale error is kept;
 *   bearing  the MAGNETIC bearing from the vehicle TO the station,
 *            atan2(E, N) of the vehicle about the station + 180 deg - the
 *            table's east-positive variation (GNBTAC.hal:252-257).
 * WHEN IT LOCKS: the unit is tuned (the control register's channel and mode
 * are a station of the file), at most TACAN_MAX_NMI (400, LEC-13790 p.12) and
 * inside the radio horizon, 1.23 (sqrt h_veh + sqrt h_stn) n.mi. (heights in
 * ft), below TACAN_LOCK_ALT_FT (default 150,000 ft: the planned acquisition
 * altitude is ~148.5 kft in LEC-13790, STS-2 locked at Mach 9.6 / 157.6 kft,
 * STS 41-B at ~130 kft; the plasma blackout is not modelled, so this is its
 * end), and TACAN_ACQ_S (default 10 s, the antenna search; PASS itself toggles
 * antennas after 11 s, GYTTAC.hal:216-222) after those hold.  Noise is white:
 * bearing TACAN_BRG_SIGMA_DEG (0.3; spec 1.0 deg) and range TACAN_RNG_SIGMA_NMI
 * (0.03; spec 0.1) -- ASSUMPTIONS, as is a fixed per-unit bearing bias
 * (TACAN_BRG_BIAS_DEG, 0.5 deg, signs 0, +1, -1 by unit); flights saw a
 * station bias of about 2 deg and 40 deg bearing glitches (AE_009M, AE_013M),
 * which PASS's RM is built for.  Never locked before TIME of the first
 * tuned read: a unit not yet commanded reads powered with no data.
 * The model is OFF (the words read as before, TACAN power off) unless the
 * navaids file has a tacan line: OV-105 (STS-134) had no TACAN. */
static struct { uint16_t ctrl, ant; int have; double tTuned, tLock; } tun[4];

void landaids_tacan_command(int unit, uint16_t ctrl, uint16_t ant) {
    if (unit < 1 || unit > 3) return;
    if (!tun[unit].have || tun[unit].ctrl != ctrl) {
        tun[unit].tTuned = vehdyn_enabled() ? vehdyn_state()->t : 0.0;
        tun[unit].tLock = -1.0;
    }
    tun[unit].ctrl = ctrl;
    tun[unit].ant = ant;
    tun[unit].have = 1;
}

/* a channel's control-register bits, 0x2000 for Y (GVQSIT.hal:393-401) */
static uint16_t channel_word(int ch, int y) {
    int v = ch < 0 ? -ch : ch;
    unsigned a = (unsigned)(v + 6 * (v / 10));
    uint16_t w = 0;
    for (int k = 0; k < 8; k++)
        if (a & (1u << k)) w |= (uint16_t)(0x0100u >> k);
    return (uint16_t)(w | (y ? 0x2000u : 0u));
}

static double gauss(unsigned *st) {
    double u1, u2;
    *st = *st * 1664525u + 1013904223u; u1 = ((*st >> 8) + 1.0) / 16777217.0;
    *st = *st * 1664525u + 1013904223u; u2 = ((*st >> 8) + 1.0) / 16777217.0;
    return sqrt(-2.0 * log(u1)) * cos(2.0 * LA_PI * u2);
}

static double envd(const char *n, double dflt) {
    const char *v = yagpc_getenv(n);
    return (v != NULL && *v) ? atof(v) : dflt;
}

#define TACAN_MAX_NMI 400.0
#define NMI_FT 6076.1155

/* the measurement for a unit; 1 when locked (range and bearing set) */
static int tacan_measure(int unit, const double r[3], const double v[3], double *rng_nmi, double *brg_deg) {
    Tacan *st = NULL;
    uint16_t cw = tun[unit].ctrl & 0x21FEu;
    for (int k = 0; k < nTac; k++)
        if (tac[k].slot && channel_word(tac[k].channel, tac[k].y) == cw) { st = &tac[k]; break; }
    if (st == NULL) return 0;
    double rb[3], d[3], R, h_veh;
    for (int i = 0; i < 3; i++) rb[i] = r[i] - v[i] * 0.029;       /* the 29 ms PASS takes back */
    for (int i = 0; i < 3; i++) d[i] = rb[i] - st->ef[i];
    R = sqrt(d[0] * d[0] + d[1] * d[1] + d[2] * d[2]);
    double rn = sqrt(rb[0] * rb[0] + rb[1] * rb[1] + rb[2] * rb[2]);
    (void)rn;
    h_veh = ellipsoid_height_ft(rb);
    double nmi = R / NMI_FT;
    if (nmi > TACAN_MAX_NMI) return 0;
    double hv = h_veh > 0 ? h_veh : 0, hs = st->alt > 0 ? st->alt : 0;
    if (nmi > 1.23 * (sqrt(hv) + sqrt(hs))) return 0;                 /* beyond the radio horizon */
    if (h_veh > envd("YAGPC_TACAN_LOCK_ALT_FT", 150000.0)) return 0;
    double t = vehdyn_enabled() ? vehdyn_state()->t : 0.0;
    if (tun[unit].tLock < 0.0) tun[unit].tLock = t;                    /* the conditions now hold: the search starts */
    if (t - tun[unit].tLock < envd("YAGPC_TACAN_ACQ_S", 10.0)) return 0;
    double n_ = st->M[0][0] * d[0] + st->M[0][1] * d[1] + st->M[0][2] * d[2];
    double e_ = st->M[1][0] * d[0] + st->M[1][1] * d[1] + st->M[1][2] * d[2];
    double q = atan2(e_, n_) - st->magvar + LA_PI;
    q = fmod(q, 2.0 * LA_PI); if (q < 0.0) q += 2.0 * LA_PI;
    static unsigned seed[4] = { 0, 12345u, 67890u, 24680u };
    double bias = (unit == 2 ? 1.0 : unit == 3 ? -1.0 : 0.0) * envd("YAGPC_TACAN_BRG_BIAS_DEG", 0.5);
    *brg_deg = q * 180.0 / LA_PI + bias + gauss(&seed[unit]) * envd("YAGPC_TACAN_BRG_SIGMA_DEG", 0.3);
    *rng_nmi = nmi + gauss(&seed[unit]) * envd("YAGPC_TACAN_RNG_SIGMA_NMI", 0.03);
    if (*rng_nmi < 0.0) *rng_nmi = 0.0;
    *brg_deg = fmod(*brg_deg + 360.0, 360.0);
    return 1;
}

static uint16_t odd_parity(uint16_t v) {
    unsigned ones = 0;
    for (uint16_t t = v; t; t &= (uint16_t)(t - 1)) ones++;
    return (ones & 1u) == 0 ? (uint16_t)(v | 0x0001u) : v;
}

void landaids_tacan_ra(int unit, uint16_t w[7]) {
    if (!loaded) load();
    memset(w, 0, 7 * sizeof w[0]);
    if (unit < 1 || unit > 3 || !vehdyn_enabled()) return;
    double rM[3], vM[3], C[3][3], r[3], vf[3];
    vehdyn_navbase_ef(rM, vM, C);
    for (int i = 0; i < 3; i++) { r[i] = rM[i] / FT_M; vf[i] = vM[i] / FT_M; }
    if (nTac > 0) {                                        /* the TACAN: powered, tuned by the GPC's command */
        w[5] |= 0x5000u;                                   /* power on, test status good */
        w[6] = tun[unit].have ? tun[unit].ctrl : 0u;
        w[0] = 0x4000u; w[1] = 0x0001u; w[2] = 0x8000u; w[3] = 0x0089u;      /* no data, until locked */
        double rng, brg;
        if (tun[unit].have && tacan_measure(unit, r, vf, &rng, &brg)) {
            long tb = lround(brg / (90.0 / 2048.0));
            if (tb > 8191) tb -= 8192;
            w[0] = (uint16_t)((tb >= 4096 ? 0x6000u : 0u) | (((unsigned)tb & 0xFFFu) << 1));
            long h = lround(rng * 100.0);
            if (h > 39999) h = 39999;
            w[2] = (uint16_t)((((h / 10000) % 10) << 12) | (((h / 1000) % 10) << 8) | (((h / 100) % 10) << 4) | ((h / 10) % 10));
            w[3] = (uint16_t)(((h % 10) << 12) | 0x0089u);
        }
    }
    if (unit > 2) return;                                  /* only RA 1 and 2 */
    w[5] |= 0x0400u;                                       /* RA power on */
    double ground = 0.0, near = 1e30;
    for (int k = 0; k < nRw; k++) {                       /* the nearest runway's height */
        if (rws[k].id[0] == '\0') continue;              /* a slot the file left empty */
        double p[3];
        geodetic_to_ef(rws[k].lat, rws[k].lon, rws[k].alt, p);
        double d = sqrt((r[0] - p[0]) * (r[0] - p[0]) + (r[1] - p[1]) * (r[1] - p[1]) +
                        (r[2] - p[2]) * (r[2] - p[2]));
        if (d < near) { near = d; ground = rws[k].alt; }
    }
    /* pitch: the body X axis above the local horizontal */
    double rn = sqrt(r[0] * r[0] + r[1] * r[1] + r[2] * r[2]);
    double sinth = (C[0][0] * r[0] + C[1][0] * r[1] + C[2][0] * r[2]) / rn;
    double th = asin(sinth < -1 ? -1 : sinth > 1 ? 1 : sinth);
    double ra = ellipsoid_height_ft(r) - ground - RA_ANT_FT * sin(RA_ANT_RAD - th);
    if (ra < 0.0) ra = 0.0;
    if (ra > RA_MAX_FT) return;                           /* beyond range: not valid */
    w[4] = odd_parity((uint16_t)(((unsigned)lround(ra) & 0x1FFFu) << 2 | 0x0002u));
}
