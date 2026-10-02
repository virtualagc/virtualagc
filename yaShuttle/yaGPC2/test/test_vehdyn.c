/* THE JETS ON THE VEHICLE, AGAINST HAND CALCULATION (vehdyn.c).
 *
 * The RCS checks fly a vehicle with its OMS tanks EMPTY (reset_rcs_only):
 * the hand figures below were worked for the RCS propellant alone.
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

static void reset_rcs_only(double t) {
    vehdyn_reset(t);
    vehdyn_set_propellant(3, 0.0);
    vehdyn_set_propellant(4, 0.0);
}

int main(void) {
    setenv("YAGPC_VEHDYN", "1", 1);
    uint16_t ff[5] = { 0 }, fa[5] = { 0 };

    /* F1U FOR ONE SECOND. */
    reset_rcs_only(0.0);
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
    reset_rcs_only(0.0);
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
    reset_rcs_only(0.0);
    memset(ff, 0, sizeof ff); memset(fa, 0, sizeof fa);
    ff[1] = 0x2000; fa[4] = 0x2000 | 0x0400;          /* F1U; L4D and R4D on FA4 */
    vehdyn_set_fire_words(ff, fa, 0.0);
    memset(ff, 0, sizeof ff); memset(fa, 0, sizeof fa);
    vehdyn_set_fire_words(ff, fa, 1e6);
    s = vehdyn_state();
    check(s->w[1] < wantQ * 1.3, "a couple pitches harder than F1U alone", s->w[1], wantQ);

    /* THE OMS ENGINES, a full vehicle.  Gimbals first driven to PASS's
     * two-engine trim (pitch 0.4, yaw -5.75 left / +5.75 right; DASS G2
     * CGCV_OMS_*_TRIM) at the actuators' rate, then both fire for 10 s.
     * The delta-v sensed along body X is the rocket equation's, Isp 315.1 s
     * times the cosine of each nozzle's cant -- 27.08 kN each, about 0.46
     * m/s^2 on 117 t -- and the vehicle is 175 kg lighter, from the pods.
     * PASS's trims are what its own mass properties need, so on these
     * (estimated) mounts the trimmed thrust should pass close to the centre
     * of gravity: the pitch rate after 10 s, as a miss distance
     * Iyy (q / 10 s) / 2F, is a few centimetres (it measures 6.6), well
     * inside what the mounts and the CG are known to -- and PASS's DAP
     * gimbals out whatever is left.  The 0.4 deg pitch trim moves the line
     * 9.9 m x sin 0.4 deg = 6.9 cm at the CG, nose-down for a positive
     * gimbal: the untrimmed miss is larger by that. */
    {
        double miss[2];
        for (int trimmed = 1; trimmed >= 0; trimmed--) {
            vehdyn_reset(0.0);
            double tp = trimmed ? 0.4 : 0.0, ty = trimmed ? 5.75 : 0.0;
            vehdyn_set_oms(0, false, true, tp, -ty, 0.0);
            vehdyn_set_oms(1, false, true, tp, ty, 0.0);
            vehdyn_advance(3e6);
            check(fabs(vehdyn_oms_gimbal(0, 1) + ty) < 1e-9 && fabs(vehdyn_oms_gimbal(1, 0) - tp) < 1e-9,
                  "gimbals reach their command", vehdyn_oms_gimbal(0, 1), -ty);
            const PhysState *s0 = vehdyn_state();
            double m0 = s0->mass, dv0[3], dv1[3];
            check(m0 > 116000.0 && m0 < 118000.0, "full vehicle mass (kg)", m0, 117000.0);
            vehdyn_sensed_dv(dv0);
            vehdyn_set_oms(0, true, true, tp, -ty, 3e6);
            vehdyn_set_oms(1, true, true, tp, ty, 3e6);
            check(vehdyn_oms_burning(0) && vehdyn_oms_burning(1), "both OMS burning", 1, 1);
            vehdyn_set_oms(0, false, true, tp, -ty, 13e6);
            vehdyn_set_oms(1, false, true, tp, ty, 13e6);
            const PhysState *s1 = vehdyn_state();
            vehdyn_sensed_dv(dv1);
            double used = 2 * 6087.0 * 4.4482216152605 / (10136.8 * 0.3048) * 10.0;
            check(fabs((m0 - s1->mass) - used) < 0.05, "OMS propellant used (kg)", m0 - s1->mass, used);
            check(fabs((5897.0 - vehdyn_propellant(3)) - used / 2) < 0.05, "from each pod",
                  5897.0 - vehdyn_propellant(3), used / 2);
            double P = 0.276053 - tp * 3.14159265358979323846 / 180;
            double Y = (6.50 - ty) * 3.14159265358979323846 / 180;
            double want = 10136.8 * 0.3048 * cos(P) * cos(Y) * log(m0 / s1->mass);
            double got = dv1[0] - dv0[0];
            if (trimmed)
                check(fabs(got / want - 1.0) < 0.002, "OMS delta-v along X, rocket equation (m/s)", got, want);
            check(fabs(s1->w[0]) < 1e-6 && fabs(s1->w[2]) < 1e-6, "no roll or yaw from a symmetric pair",
                  s1->w[0] + s1->w[2], 0.0);
            miss[trimmed] = s1->I[1][1] * (s1->w[1] / 10.0) / (2 * 6087.0 * 4.4482216152605);
        }
        check(fabs(miss[1]) < 0.10, "trimmed thrust passes within 10 cm of the CG (m)", miss[1], 0.0);
        check(fabs((miss[0] - miss[1]) / 0.069 - 1.0) < 0.15, "0.4 deg of pitch gimbal moves it 6.9 cm (m)",
              miss[0] - miss[1], 0.069);
    }

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
