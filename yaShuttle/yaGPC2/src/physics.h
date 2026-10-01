/* THE VEHICLE'S TRUTH STATE: a rigid body in orbit.
 *
 * What the devices behind the MDMs will report from -- the IMU's gimbal
 * angles and velocity counts, GPS position and velocity -- once they stop
 * reporting a vehicle at rest (mdmdev.c).  The flight software never sees
 * this state directly; it sees only what those devices measure of it, as on
 * the real vehicle.
 *
 * Frame and units.  Position and velocity are in an inertial, Earth-centred
 * frame whose axes are taken to be the flight software's M50; metres,
 * seconds, kilograms, radians throughout.  Attitude is the quaternion that
 * rotates BODY vectors into that frame (q = [w, x, y, z]), body rates are in
 * the body frame, and body axes are the Orbiter's: +X forward, +Y right
 * wing, +Z down.
 *
 * Forces.  Gravity is a point mass, mu / r^2, with the modern value of mu --
 * not the onboard I-load, so that the small real difference between the
 * vehicle and its navigation's model of it survives (the onboard field is
 * 4x4, and a richer truth field is a later step).  Everything else is
 * applied: a body-frame force and torque, which is where jets and engines
 * come in.  Gravity-gradient torque is not modelled (about 1e-2 N m on this
 * vehicle, negligible beside a jet's 1e4).
 *
 * Integration is fixed-step fourth-order Runge-Kutta. */
#ifndef YAGPC_PHYSICS_H
#define YAGPC_PHYSICS_H

#define PHYS_MU_EARTH 3.986004418e14    /* m^3/s^2, EGM96/WGS84 */

typedef struct {
    double t;            /* s, the vehicle's simulated time */
    double r[3], v[3];   /* m, m/s, inertial */
    double q[4];         /* body -> inertial, [w x y z], unit */
    double w[3];         /* rad/s, body */
    double mass;         /* kg */
    double I[3][3];      /* kg m^2, body, about the centre of mass */
} PhysState;

/* A circular orbit: altitude above a spherical Earth of radius re (m),
 * inclination, right ascension of the ascending node and argument of
 * latitude (rad), at time t.  Attitude is identity, rates zero; mass and
 * inertia are left as the caller set them. */
void phys_init_circular(PhysState *s, double re, double alt, double incl,
                        double raan, double arglat, double t);

/* Advance by dt seconds under gravity plus the applied body-frame force
 * (N) and torque (N m), both held constant over the step; NULL for none. */
void phys_step(PhysState *s, double dt, const double fBody[3], const double tBody[3]);

/* Advance to time t in steps of at most maxDt, with the same applied force
 * and torque throughout. */
void phys_advance_to(PhysState *s, double t, double maxDt,
                     const double fBody[3], const double tBody[3]);

/* Diagnostics: specific orbital energy (J/kg), specific angular momentum
 * vector (m^2/s), and rotational kinetic energy (J). */
double phys_orbit_energy(const PhysState *s);
void phys_orbit_h(const PhysState *s, double h[3]);
double phys_spin_energy(const PhysState *s);

/* Rotate a body-frame vector into the inertial frame. */
void phys_body_to_inertial(const PhysState *s, const double b[3], double out[3]);

#endif
