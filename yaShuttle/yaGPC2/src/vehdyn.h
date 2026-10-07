/* THE VEHICLE'S DYNAMICS: the RCS jets acting on the truth state.
 *
 * physics.c is a rigid body in orbit; this is what pushes it.  The computers'
 * jet fire commands (mdmdev.c, the "B" discretes) say which of the 44 jets
 * are firing; each firing jet applies its thrust along its own axis at its own
 * position, so a force and a torque about the current centre of gravity, and
 * burns propellant out of its own module (forward, left pod, right pod),
 * which changes the vehicle's mass, centre of gravity and inertia tensor.
 *
 * Time is the vehicle's shared simulated clock: vehdyn_advance() brings the
 * state up to a given moment with the jets as they were, and
 * vehdyn_set_jets() changes them from that moment on -- so a jet fires for
 * exactly as long as the computers commanded it.
 *
 * OFF unless YAGPC_VEHDYN is set (1/on); see vehdyn_enabled().  The jet
 * table, thrusts, specific impulses, propellant loads and mass properties
 * are documented with their sources and their uncertainties in vehdyn.c. */
#ifndef YAGPC_VEHDYN_H
#define YAGPC_VEHDYN_H

#include <stdbool.h>
#include <stdint.h>

#include "physics.h"

#define VEHDYN_NJETS 44

bool vehdyn_enabled(void);

/* The fire commands as the computers wrote them: the B word of each forward
 * MDM (bits 0xF000 used) and each aft MDM (0xFF00 on FA1/FA2, 0xFC00 on
 * FA3/FA4), index 1-4.  Takes effect at sharedUs, after the state has been
 * advanced to it. */
void vehdyn_set_fire_words(const uint16_t ff[5], const uint16_t fa[5], double sharedUs);

/* Bring the state up to sharedUs with the jets as they are. */
void vehdyn_advance(double sharedUs);

/* The current truth state, for the sensors. */
const PhysState *vehdyn_state(void);

/* Propellant left in a module (kg): RCS 0 forward, 1 left pod, 2 right pod;
 * OMS 3 left, 4 right.  Set it -- for tests that want a vehicle without,
 * say, the OMS load -- and the mass properties follow. */
double vehdyn_propellant(int module);
void vehdyn_set_propellant(int module, double kg);

/* THE OMS ENGINES, 0 left and 1 right: whether the engine's valves are open
 * (fire), whether an actuator controller is powered, and the gimbal command
 * it is giving (deg, pitch and yaw as PASS scales them), from sharedUs on.
 * And what they are doing: burning, and where each gimbal is (axis 0 pitch,
 * 1 yaw, deg). */
void vehdyn_set_oms(int e, bool fire, bool powered, double pitchDeg, double yawDeg,
                    double sharedUs);
bool vehdyn_oms_burning(int e);
double vehdyn_oms_thrust(int e);      /* fraction of full, tail-off included */
double vehdyn_oms_gimbal(int e, int axis);
double vehdyn_oms_on_seconds(int e);

/* Non-gravitational velocity change sensed since the start, in the inertial
 * frame (m/s) -- what ideal accelerometers on an inertial platform count. */
void vehdyn_sensed_dv(double out[3]);

/* Jet bookkeeping, for tests and the report: how long jet k has fired (s),
 * and its name. */
double vehdyn_jet_on_seconds(int k);
const char *vehdyn_jet_name(int k);
int vehdyn_jet_index(const char *name);

void vehdyn_report(void);

/* THE CLOCK: the Unix time that the state's t = 0 stands for, as the timing
 * unit reports it (mtumodel.c).  Sets the Earth's orientation to the flight
 * software's own (GLWRNP, GNFEAR) at that clock.  vehdyn_gmt(t) is the
 * flight software's GMT in seconds -- day of year x 86400 + seconds of day
 * -- at state time t, or -1 before the clock is known. */
void vehdyn_set_gmt_zero(double unixAtZero);

/* The truth position and velocity (inertial, m and m/s) at a recent time t
 * no later than now -- interpolated from the steps taken; false if t is
 * outside what is kept (a few hundred steps). */
bool vehdyn_state_at(double t, double r[3], double v[3]);
double vehdyn_gmt(double t);
/* The same clock as a Unix time (s), which carries the year -- for the Sun
 * and the Moon; -1 before the clock is known. */
double vehdyn_unix(double t);

/* A session capture: the state as numbers, into b[0..max-1], returning how
 * many it takes (call with max 0 to ask); and back, rebased so that the
 * restored clock's zero is the captured instant.  vehdyn_load returns the
 * captured time (s), or a negative number for a record it cannot read. */
int vehdyn_save(double *b, int max);
double vehdyn_load(const double *b, int n);

/* THE ASCENT THRUST-VECTOR COMMANDS, degrees: [0..2] the SSMEs' pitch and
 * yaw bell deflections, [3] the left and [4] the right SRB's rock and tilt.
 * The actuators follow at their own rate. */
void vehdyn_set_tvc(const double cmd[5][2]);

/* THE AEROSURFACE COMMANDS, degrees, as PASS writes them (mdmdev, FA AOD):
 * left inboard, left outboard, right inboard, right outboard elevon
 * (+ trailing edge down), speedbrake (0..98.6), rudder; and the body flap's
 * drive from its discretes, +1 down, -1 up, 0 stopped. */
void vehdyn_set_aerosurf(const double cmd[6], int bodyFlapDrive);
/* Where the surfaces are, degrees: the six above, then the body flap. */
void vehdyn_aerosurf_pos(double pos[7]);
/* For tests: the entry tables' CN, CA and CM (about the MRP) at Mach,
 * alpha and elevon, body flap, speedbrake deflection (degrees). */
void vehdyn_aero_coeffs(double mach, double alpha, double de, double dbf, double dsb, double c[3]);

/* The ascent: 0 not (on orbit), 1 on the pad, 2 the stack in flight, 3 the
 * orbiter and tank after SRB separation (YAGPC_VEHDYN_PAD). */
int vehdyn_ascent_phase(void);

/* What the accelerometers feel now: the specific force in body axes, m/s^2
 * (set on the pad and in powered flight). */
void vehdyn_specific_force(double out[3]);
/* An SRB's chamber pressure, psia (< 0: the boosters have gone). */
double vehdyn_srb_pc_psia(void);

/* For tests: start over at time t with full tanks, a 400 km circular orbit
 * and the vehicle at rest. */
void vehdyn_reset(double t);

/* For tests: set the attitude (body -> inertial, [w x y z], normalised here)
 * and body rates directly. */
void vehdyn_set_attitude(const double q[4], const double w[3]);
/* The navigation base (the IMUs' place, PASS's navigation point), Earth-fixed
 * in PASS's frame: position m, velocity m/s relative to the Earth, and the
 * body -> Earth-fixed matrix -- for the landing aids. */
void vehdyn_navbase_ef(double rEf[3], double vEf[3], double Cbe[3][3]);
/* THE HARDWIRED FUNCTIONS, from the crew's pushbuttons: 0x8000 LANDING GEAR
 * ARM, 0x4000 DN, 0x2000 DRAG CHUTE ARM, 0x1000 DPY, 0x0800 JETT (latched
 * here).  And the gear: travel 0 stowed .. 1 down and locked; weight on the
 * left and right main gear and the nose gear (1 = weight). */
void vehdyn_hardwired(unsigned w);
void vehdyn_gear(double *pos, int wow[3]);
/* The lower main wheel's height above the runway (ft) and the ground speed
 * (kt) -- the crew's cues for the gear, the chute and the brakes. */
void vehdyn_ground_state(double *wheelFt, double *gsKt);
/* The point the state (r, v) describes: the CURRENT centre of mass, as an
 * offset from the orbiter's dry CG (Xo 1100, Yo 0, Zo 375) in body metres
 * (+X forward = -Xo, +Y right, +Z down = -Zo).  It moves with propellant,
 * and on the pad and in ascent it is the whole stack's. */
void vehdyn_cg_offset(double b[3]);
/* The air data probes, left and right: 0 stowed .. 1 deployed (the crew's
 * AIR DATA PROBE switches, hardwired 0x0100/0x0080 DEPLOY, 0x0040/0x0020
 * STOW).  And the air they meet: free-stream pressure (psf), Mach, alpha,
 * beta (deg), dynamic pressure (psf); false above the aero tables. */
void vehdyn_probes(double pos[2]);
bool vehdyn_air_data(double *pPsf, double *mach, double *alphaDeg, double *betaDeg, double *qPsf);
/* For tests: set the position and velocity directly (M50, m and m/s). */
void vehdyn_set_rv(const double r[3], const double v[3]);

#endif
