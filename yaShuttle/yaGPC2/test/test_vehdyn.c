/* THE JETS ON THE VEHICLE, AGAINST HAND CALCULATION (vehdyn.c).
 *
 * Fire jets through the same entry the device model uses -- the B words of
 * the forward and aft MDMs -- for a known time, and compare what the vehicle
 * does with numbers worked out from the jet table by hand:
 *
 *   F1U, the nose's left up-firing jet, at Xo 350.542 Yo -14.091 Zo 413.244,
 *   pushes body +Z with 870 lbf (3870 N).  From the dry CG (Xo 1100, Zo 375)
 *   its arm is x = 19.036 m forward, y = -0.358 m, z = -0.971 m, so the torque
 *   r x F is (-1385, -73,669, 0) N m: nose DOWN, and a little roll left.
 *   The pitch inertia is NOT the dry 9.68e6: the forward module's 1,460 kg
 *   of propellant sits 18.42 m forward of the dry CG and the pods' 2,920 kg
 *   10.41 m aft (and 2.29 m up), adding 1460 x 339.5 + 2920 x 113.7 =
 *   827,600 kg m^2, less 700 for the 3.4 cm the propellant moves the CG aft:
 *   Iyy = 10.507e6.  That move also lengthens F1U's arm to 19.070 m, so the
 *   torque is -73,800 N m, and one second gives a pitch rate of
 *   -73,800 / 10.507e6 = -7.024e-3 rad/s.  (The first version of this test
 *   used the dry inertia and was 8% out; the code was right.)  Propellant:
 *   3870 / (280 x 9.80665) = 1.409 kg from the forward module.
 *
 * Tolerances allow for the centre of gravity, which the propellant in the
 * three modules moves a few centimetres from the dry one. */
#define _POSIX_C_SOURCE 200809L

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../src/vehdyn.h"

static int checks, failures;

static void check(int ok, const char *what, double got, double want) {
    checks++;
    if (ok) return;
    failures++;
    printf("FAIL [vehdyn/%s] got %.9g want %.9g\n", what, got, want);
}

int main(void) {
    setenv("YAGPC_VEHDYN", "1", 1);
    uint16_t ff[5] = { 0 }, fa[5] = { 0 };

    /* F1U FOR ONE SECOND. */
    vehdyn_reset(0.0);
    double p0 = vehdyn_propellant(0);
    ff[1] = 0x2000;                                  /* F1U */
    vehdyn_set_fire_words(ff, fa, 10e6);             /* coast to t=10, then fire */
    ff[1] = 0;
    vehdyn_set_fire_words(ff, fa, 11e6);             /* fire until t=11 */
    vehdyn_advance(11e6);
    const PhysState *s = vehdyn_state();
    double wantQ = -73800.0 / 10.507e6, wantP = -1385.0 / 1.29e6;
    check(fabs(s->w[1] - wantQ) < 0.005 * fabs(wantQ), "pitch rate from F1U (rad/s)", s->w[1], wantQ);
    check(fabs(s->w[0] - wantP) < 0.05 * fabs(wantP), "roll rate from F1U (rad/s)", s->w[0], wantP);
    check(fabs(s->w[2]) < 0.02 * fabs(wantQ), "no yaw from F1U", s->w[2], 0.0);
    double used = p0 - vehdyn_propellant(0), want = 3870.0 / (280.0 * 9.80665);
    check(fabs(used - want) < 1e-3, "forward propellant used (kg)", used, want);
    check(vehdyn_propellant(1) == 1460.0 && vehdyn_propellant(2) == 1460.0,
          "pods untouched", vehdyn_propellant(1), 1460.0);
    check(fabs(vehdyn_jet_on_seconds(vehdyn_jet_index("F1U")) - 1.0) < 1e-6,
          "fired for exactly the commanded second", vehdyn_jet_on_seconds(vehdyn_jet_index("F1U")), 1.0);
    /* and it keeps that rate afterwards: coasting changes nothing about a
     * principal-axis rate except the small cross-coupling */
    double q1 = s->w[1];
    vehdyn_advance(21e6);
    check(fabs(s->w[1] - q1) < 0.01 * fabs(q1), "rate held while coasting", s->w[1], q1);

    /* A PURE TRANSLATION: L1A and R1A together push +X with no net yaw (they
     * are mirror images) -- delta-v = 2F t / m, and the sensed delta-v the
     * accelerometers would count is the same. */
    vehdyn_reset(0.0);
    double m0 = vehdyn_state()->mass;
    memset(ff, 0, sizeof ff); memset(fa, 0, sizeof fa);
    fa[1] = 0x8000 | 0x1000;                          /* L1A + R1A */
    vehdyn_set_fire_words(ff, fa, 0.0);
    memset(fa, 0, sizeof fa);
    vehdyn_set_fire_words(ff, fa, 4e6);
    double dv[3]; vehdyn_sensed_dv(dv);
    double dvn = sqrt(dv[0] * dv[0] + dv[1] * dv[1] + dv[2] * dv[2]);
    double wantDv = 2.0 * 3870.0 * 4.0 / m0;
    check(fabs(dvn - wantDv) < 0.005 * wantDv, "sensed delta-v of a +X burn (m/s)", dvn, wantDv);
    s = vehdyn_state();
    check(fabs(s->w[2]) < 1e-6, "no yaw from a symmetric pair", s->w[2], 0.0);
    double usedL = 1460.0 - vehdyn_propellant(1), usedR = 1460.0 - vehdyn_propellant(2);
    check(fabs(usedL - usedR) < 1e-9 && fabs(usedL - 4.0 * want) < 4e-3,
          "each pod used its own propellant", usedL, 4.0 * want);
    check(s->mass < m0 && fabs((m0 - s->mass) - 8.0 * want) < 1e-2,
          "the vehicle got lighter by what was burned", m0 - s->mass, 8.0 * want);

    /* A COUPLE: F1U (nose, +Z) with L4D and R4D (tail, -Z) is a nose-down
     * pitch with very little net force -- the pitch rate is larger than F1U
     * alone and the sensed delta-v smaller than one jet would give. */
    vehdyn_reset(0.0);
    memset(ff, 0, sizeof ff); memset(fa, 0, sizeof fa);
    ff[1] = 0x2000; fa[4] = 0x2000 | 0x0400;          /* F1U; L4D and R4D on FA4 */
    vehdyn_set_fire_words(ff, fa, 0.0);
    memset(ff, 0, sizeof ff); memset(fa, 0, sizeof fa);
    vehdyn_set_fire_words(ff, fa, 1e6);
    s = vehdyn_state();
    check(s->w[1] < wantQ * 1.3, "a couple pitches harder than F1U alone", s->w[1], wantQ);

    /* THE EARTH AS PASS SEES IT.  With the clock's zero at 2000-03-15
     * 00:00 UTC -- the tape's own RNP epoch, day 75 of 2000 -- the Earth
     * angle at t = 0 is zero and inertial -> Earth-fixed is GLWRNP's matrix
     * itself: a rotation, its pole within half a degree of M50's (fifty
     * years of precession is about 0.28 deg), and Greenwich at the sidereal
     * time of that midnight, about 11h 32m (173 deg), plus the 0.7 deg the
     * equinox moved from 1950. */
    {
        vehdyn_set_gmt_zero(953078400.0);
        check(fabs(vehdyn_gmt(0.0) - 75 * 86400.0) < 1e-6, "PASS GMT seconds at day 75",
              vehdyn_gmt(0.0), 75 * 86400.0);
        double M[3][3], worst = 0.0;
        phys_inertial_to_earth(0.0, M);
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++) {
                double d = M[i][0] * M[j][0] + M[i][1] * M[j][1] + M[i][2] * M[j][2] - (i == j);
                if (fabs(d) > worst) worst = fabs(d);
            }
        check(worst < 1e-12, "GLWRNP matrix is a rotation", worst, 0.0);
        double pole = acos(M[2][2]) * 180 / 3.14159265358979323846;
        check(pole > 0.2 && pole < 0.5, "pole of date vs M50 (deg)", pole, 0.28);
        double gst = atan2(M[0][1], M[0][0]) * 180 / 3.14159265358979323846;
        if (gst < 0) gst += 360;
        check(fabs(gst - 173.6) < 1.5, "Greenwich from M50 X at the epoch (deg)", gst, 173.6);
        /* and it turns at PASS's earth rate */
        double a1 = phys_earth_angle(3600.0) - phys_earth_angle(0.0);
        check(fabs(a1 - 0.729211514646E-4 * 3600.0) < 1e-12, "turns at CGNS_EARTH_RATE", a1,
              0.729211514646E-4 * 3600.0);
    }

    printf("vehdyn: %d/%d checks passed\n", checks - failures, checks);
    return failures ? 1 : 0;
}
