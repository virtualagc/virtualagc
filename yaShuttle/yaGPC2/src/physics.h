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
 * Forces.  Gravity is EGM96 to degree and order 4 -- J2's bulge and the
 * rest, fixed in an Earth that turns under the inertial frame -- with the
 * modern mu, not the onboard I-loads, so the small real difference between
 * the vehicle and its navigation's model of it survives.  Drag is an
 * exponential atmosphere turning with the Earth, on an area that follows
 * the attitude.  Both are described in physics.c and can be cut back (to a
 * point mass and no air) for closed-form tests.  Everything else is applied:
 * a body-frame force and torque, which is where jets and engines come in.  Gravity-gradient torque is not modelled (about 1e-2 N m on this
 * vehicle, negligible beside a jet's 1e4).
 *
 * Integration is fixed-step fourth-order Runge-Kutta. */
#ifndef YAGPC_PHYSICS_H
#define YAGPC_PHYSICS_H

#define PHYS_MU_EARTH 3.986004418e14    /* m^3/s^2, EGM96/WGS84 */
#define PHYS_GRAV_NMAX 4                /* the field's largest degree */

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

/* An orbit from its elements: apogee and perigee altitudes above a sphere
 * of radius re (m), inclination, node, argument of perigee and true anomaly
 * (rad), at time t.  Attitude identity, rates zero. */
void phys_init_elements(PhysState *s, double re, double ha, double hp, double incl,
                        double raan, double argp, double nu, double t);

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

/* The environment, shared by every state.  phys_set_gravity(0, 0) is a
 * point mass; (n, 0) the zonal terms J2..Jn alone; the default is 4x4.
 * phys_set_drag(0, ...) turns the air off; the default is Cd 2.2 on 40, 220
 * and 360 m^2 seen along body X, Y and Z. */
void phys_set_gravity(int degree, int order);
void phys_set_drag(double cd, double areaX, double areaY, double areaZ);

/* The Earth's orientation: inertial -> Earth-fixed is Rz(theta) P, with P
 * constant and theta = theta0 + rate (t - t0).  Default: P identity,
 * theta 0 at t = 0, the sidereal rate (rate <= 0 also means that). */
void phys_set_earth(const double P[3][3], double theta0, double t0, double rate);
double phys_earth_angle(double t);
double phys_earth_rate(void);
/* The Earth's pole of date, a unit vector in the inertial frame. */
void phys_earth_pole(double p[3]);
void phys_inertial_to_earth(double t, double M[3][3]);

/* The field and the air, for tests and sensors: gravitational acceleration
 * and potential (positive, mu/r for a point mass) at inertial r and time t;
 * the zonal coefficient Jn; density at a height above the ellipsoid; and the
 * drag acceleration on a state as it stands (what an accelerometer feels of
 * the air). */
void phys_gravity(double t, const double r[3], double a[3]);
double phys_potential(double t, const double r[3]);
double phys_jn(int n);
double phys_air_density(double altM);
void phys_drag_accel(const PhysState *s, double a[3]);

/* Rotate a body-frame vector into the inertial frame. */
void phys_body_to_inertial(const PhysState *s, const double b[3], double out[3]);

#endif
