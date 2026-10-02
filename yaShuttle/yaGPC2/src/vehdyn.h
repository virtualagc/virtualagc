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

/* Propellant left in a module: 0 forward, 1 left pod, 2 right pod (kg). */
double vehdyn_propellant(int module);

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
double vehdyn_gmt(double t);

/* For tests: start over at time t with full tanks, a 400 km circular orbit
 * and the vehicle at rest. */
void vehdyn_reset(double t);

/* For tests: set the attitude (body -> inertial, [w x y z], normalised here)
 * and body rates directly. */
void vehdyn_set_attitude(const double q[4], const double w[3]);

#endif
