/* vehdyn_coast: carry a captured vehdyn state forward in time with nothing firing.
 *
 *   vehdyn_coast VEHDYN.txt TARGETS.txt SECONDS OUT_VEHDYN.txt OUT_TARGETS.txt [TARGETS_FILE]
 *
 * VEHDYN.txt / TARGETS.txt hold one double a line: the "vehdyn" and "targets" arrays of a capture's
 * vehdyn.json (examples/flights/undock_coast.py reads them out and writes the result back).  The
 * vehicle's physics -- the gravity field, the drag, the ISS as a second point mass -- runs SECONDS
 * of the vehicle's own clock in one go, as a capture's restore would after the computers had sat in
 * HALT that long; the state's GMT (index 126) moves with it.  Used to skip the days of an
 * orbit that carry no event: STS-134's 42 hours from SEP3 (150/08:38) to the deorbit day (152).
 *
 * Build, from yaShuttle/yaGPC2:
 *   cc -O2 -std=c11 -o build/vehdyn_coast tools/vehdyn_coast.c src/vehdyn.c src/physics.c \
 *      src/envcache.c src/eiumodel.c src/mecmodel.c -lm -pthread
 * Nothing is fired and no propellant is used; the caller sets the mass.  The TARGETS_FILE argument
 * is YAGPC_VEHDYN_TARGETS (its ports are the vehicle's facts), as a run's. */
#define _POSIX_C_SOURCE 200809L
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../src/vehdyn.h"

static int read_doubles(const char *path, double *b, int max) {
    FILE *f = fopen(path, "r");
    if (!f) { fprintf(stderr, "vehdyn_coast: cannot read %s\n", path); exit(2); }
    int n = 0;
    while (n < max && fscanf(f, "%lf", &b[n]) == 1) n++;
    fclose(f);
    return n;
}

static void write_doubles(const char *path, const double *b, int n) {
    FILE *f = fopen(path, "w");
    if (!f) { fprintf(stderr, "vehdyn_coast: cannot write %s\n", path); exit(2); }
    for (int i = 0; i < n; i++) fprintf(f, "%.17g\n", b[i]);
    fclose(f);
}

int main(int argc, char **argv) {
    if (argc < 6) {
        fprintf(stderr, "usage: vehdyn_coast VEHDYN.txt TARGETS.txt SECONDS OUT_VEHDYN.txt OUT_TARGETS.txt [TARGETS_FILE]\n");
        return 2;
    }
    static double v[512], t[512], ov[512], ot[512];
    int nv = read_doubles(argv[1], v, 512), nt = read_doubles(argv[2], t, 512);
    double secs = atof(argv[3]);
    setenv("YAGPC_VEHDYN", "1", 1);
    if (argc > 6) setenv("YAGPC_VEHDYN_TARGETS", argv[6], 1);
    if (nv < 127) { fprintf(stderr, "vehdyn_coast: %d values in %s, too few\n", nv, argv[1]); return 2; }
    /* the state's GMT (index 126) is day*86400 + seconds of the day; Unix = Jan 1 of the year + that - 86400 */
    double gmt = v[126];
    double jan1_2011 = 1293840000.0;
    double unix0 = jan1_2011 + gmt - 86400.0;
    vehdyn_reset(0.0);
    vehdyn_set_gmt_zero(unix0);
    vehdyn_advance(1.0e6);
    vehdyn_load(v, nv);
    vehdyn_targets_load(t, nt);
    vehdyn_set_gmt_zero(unix0);
    double us = 0.0;
    double step = 3600.0;
    for (double done = 0.0; done < secs - 1e-9;) {
        double dt = secs - done < step ? secs - done : step;
        done += dt;
        us = done * 1e6;
        vehdyn_advance(us);
    }
    int n = vehdyn_save(ov, 512), m = vehdyn_targets_save(ot, 512);
    if (n <= 0 || m <= 0) { fprintf(stderr, "vehdyn_coast: nothing to save (%d, %d)\n", n, m); return 2; }
    write_doubles(argv[4], ov, n);
    write_doubles(argv[5], ot, m);
    const PhysState *s = vehdyn_state();
    fprintf(stderr, "vehdyn_coast: %.0f s on; GMT %.1f -> %.1f; r %.0f m, v %.1f m/s\n", secs, gmt, ov[126],
            sqrt(s->r[0] * s->r[0] + s->r[1] * s->r[1] + s->r[2] * s->r[2]),
            sqrt(s->v[0] * s->v[0] + s->v[1] * s->v[1] + s->v[2] * s->v[2]));
    return 0;
}
