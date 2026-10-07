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
#define NAV_MAX 8
#define LA_PI 3.14159265358979323846

typedef struct { double lat, lon, alt, az; char id[8]; } Runway;
typedef struct {
    int rw;
    double raz[3], el[3];            /* Earth-fixed, ft */
    double Mraz[3][3], Mel[3][3];    /* Earth-fixed -> scanner */
} Mls;

static Runway rws[NAV_MAX];
static Mls mls[NAV_MAX];
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
            slot >= 1 && slot <= NAV_MAX) {
            Runway *r = &rws[slot - 1];
            r->lat = v[0]; r->lon = v[1]; r->alt = v[2]; r->az = v[3];
            snprintf(r->id, sizeof r->id, "%s", id);
            if (slot > nRw) nRw = slot;
        } else if (strncmp(line, "mls ", 4) == 0 &&
                   sscanf(line + 4, "%d %d %lf %lf %lf %lf %lf %lf %lf %lf", &slot, &rw,
                          &v[0], &v[1], &v[2], &v[3], &v[4], &v[5], &v[6], &v[7]) == 10 &&
                   slot >= 1 && slot <= NAV_MAX) {
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
    fprintf(stderr, "landaids: %d runway(s), %d MLS site(s) from %s\n", nRw, nMls, path);
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

void landaids_tacan_ra(int unit, uint16_t w[7]) {
    if (!loaded) load();
    memset(w, 0, 7 * sizeof w[0]);
    if (unit < 1 || unit > 2 || !vehdyn_enabled()) return;
    w[5] = 0x0400u;                                       /* RA power on */
    double rM[3], vM[3], C[3][3], r[3];
    vehdyn_navbase_ef(rM, vM, C);
    for (int i = 0; i < 3; i++) r[i] = rM[i] / FT_M;
    double ground = 0.0, near = 1e30;
    for (int k = 0; k < nRw; k++) {                       /* the nearest runway's height */
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
    uint16_t v = (uint16_t)(((unsigned)lround(ra) & 0x1FFFu) << 2 | 0x0002u);
    unsigned ones = 0;
    for (uint16_t t = v; t; t &= (uint16_t)(t - 1)) ones++;
    if ((ones & 1u) == 0) v |= 0x0001u;                   /* odd parity */
    w[4] = v;
}
