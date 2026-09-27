#!/usr/bin/env python
'''
Filename:      orbiterInertialModel.py
See also:      orbiterPhysicalModels.pdf
Mod history:   2026-09-27 RSB  Created

This is the Python code for an inertial model of the Space Shuttle
Orbiter. How was it derived? I wanted a model like this, so my first
step was to google the question of what the inertial properties of the
Orbiter were. The AI responded with the moments of inertia about the 
various axes (unloaded), and then proceeded to explain about a number
of ways the model could be extended: fuel, arm extension, wind 
resistance during entry, and so on, asking me if I wanted to add them
to the model, to which I kept answering "sure!" Finally, it ran out of
features to add, and the following Python code popped out. Considering
that if it worked as advertised, it was exactly what I wanted, and 
saved me the trouble of developing it, so here it is as-is.

This model does not include the Solid Rocket Boosters. See 
solidRocketBoosters.py.
'''

import numpy as np
from scipy.integrate import solve_ivp

class ProductionSpaceShuttleSimulator:
    def __init__(self):
        # 1. Structural Dry Orbiter Properties
        self.m_dry = 78000.0  # kg
        self.cg_dry = np.array([-0.50, 0.0, 0.1])  # [x, y, z] meters
        self.I_dry = np.array([
            [1.17e6,   -3868.0,  2.18e5],
            [-3868.0,   8.73e6,  -3441.0],
            [2.18e5,   -3441.0,   9.00e6]
        ]) # Baseline Inertia Matrix (kg*m^2)
        
        # 2. Variable OMS Propellant Tank Parameters
        self.m_fuel_init = 11000.0  # kg
        self.cg_fuel = np.array([-12.0, 0.0, 1.5]) # Aft-heavy position
        self.r_tank_radius = 1.2  # meters
        self.mdot = 30.0  # kg/s continuous depletion rate
        
        # 3. Discrete Payload Bay Module
        self.m_payload = 15000.0  # kg (Heavy Satellite Module)
        self.cg_payload = np.array([2.0, 0.0, 0.5])  # Forward bay position
        self.I_payload_local = np.array([
            [5.0e4, 0.0, 0.0],
            [0.0, 2.5e5, 0.0],
            [0.0, 0.0, 2.5e5]
        ])
        self.t_deployment = 20.0  # Instantaneous step drop at t=20s
        
        # 4. Aerodynamic & Atmospheric Dimensioning
        self.S_ref = 249.9  # Wing area (m^2)
        self.c_bar = 12.0   # Mean aerodynamic chord (m)
        self.b_span = 23.8  # Total wingspan (m)
        self.rho_0 = 1.225  # Surface air density (kg/m^3)
        self.H_scale = 7500.0  # Scale height (meters)
        
        # Aerodynamic Stability Coefficients
        self.Cl_beta = -0.05   # Roll cross-coupling from sideslip
        self.Cm_alpha = -0.15  # Passive pitch restoration 
        self.Cn_beta = 0.02    # Weathercock directional yaw stability
        self.Cd_0 = 0.40       # High drag alpha entry drag profile
        
        # --- NEW: Aerodynamic Dynamic Damping Derivatives ---
        self.Cl_p = -0.40   # Roll damping (resists high-rate rolling)
        self.Cm_q = -0.75   # Pitch damping (suppresses nose pitch oscillation)
        self.Cn_r = -0.25   # Yaw damping (suppresses tail wagging/Dutch roll)
        
        # --- NEW: Closed-Loop Flight Autopilot (PID Architecture) ---
        # Gains scaled for the massive structural moments of inertia (10^6 order)
        self.Kp = np.array([2.5e5, 8.5e6, 8.5e6])  # Proportional gains [Roll, Pitch, Yaw]
        self.Kd = np.array([1.2e5, 4.0e6, 4.0e6])  # Derivative gains damping error rates
        self.Ki = np.array([1.0e4, 5.0e5, 5.0e5])  # Integral tracking gains
        
        # Internal state tracking registers for tracking errors across runtime steps
        self.error_integral = np.zeros(3)
        self.last_t = 0.0

    def get_instantaneous_mass_properties(self, t):
        """Deltas mass properties continuously for fuel and discretely for payload."""
        current_fuel = max(0.0, self.m_fuel_init - (self.mdot * t))
        current_payload_mass = 0.0 if t >= self.t_deployment else self.m_payload
        
        total_mass = self.m_dry + current_fuel + current_payload_mass
        
        # Dynamic composite cross-axis Center of Gravity calculation
        cg_total = (self.m_dry * self.cg_dry + 
                    current_fuel * self.cg_fuel + 
                    current_payload_mass * self.cg_payload) / total_mass
        
        # Core rigid body conversions via Parallel Axis Theorem
        I_fuel_local = (2/5) * current_fuel * (self.r_tank_radius**2) * np.eye(3)
        
        d_dry = cg_total - self.cg_dry
        I_dry_shifted = self.I_dry + self.m_dry * (np.dot(d_dry, d_dry) * np.eye(3) - np.outer(d_dry, d_dry))
        
        d_fuel = cg_total - self.cg_fuel
        I_fuel_shifted = I_fuel_local + current_fuel * (np.dot(d_fuel, d_fuel) * np.eye(3) - np.outer(d_fuel, d_fuel))
        
        I_total = I_dry_shifted + I_fuel_shifted
        
        if t < self.t_deployment:
            d_pl = cg_total - self.cg_payload
            I_pl_shifted = self.I_payload_local + self.m_payload * (np.dot(d_pl, d_pl) * np.eye(3) - np.outer(d_pl, d_pl))
            I_total += I_pl_shifted
            
        # Calculate time derivative matrix (dI/dt)
        if current_fuel > 0:
            dI_fuel_local_dt = (2/5) * (-self.mdot) * (self.r_tank_radius**2) * np.eye(3)
            dI_dt = dI_fuel_local_dt - self.mdot * (np.dot(d_fuel, d_fuel) * np.eye(3) - np.outer(d_fuel, d_fuel))
        else:
            dI_dt = np.zeros((3, 3))
            
        return total_mass, cg_total, I_total, dI_dt

    def compute_aerodynamics(self, altitude, velocity, omega):
        """Processes static aerodynamic coefficients paired with dynamic velocity dampening."""
        rho = self.rho_0 * np.exp(-max(0.0, altitude) / self.H_scale)
        q_inf = 0.5 * rho * (velocity**2)
        
        # Modeled relative wind angles during aggressive hypersonic re-entry profile
        alpha = 0.35  # ~20 degrees high pitch entry deck
        beta = 0.01 * np.sin(omega[0] * 2.0)  # Roll-induced yaw sideslip angle
        
        # A. Static structural aerodynamic moments
        L_static = q_inf * self.S_ref * self.b_span * (self.Cl_beta * beta)
        M_static = q_inf * self.S_ref * self.c_bar * (self.Cm_alpha * alpha)
        N_static = q_inf * self.S_ref * self.b_span * (self.Cn_beta * beta)
        
        # B. Damping moments (angular velocities scaled via non-dimensional reference lengths)
        if velocity > 1.0:
            L_damping = q_inf * self.S_ref * self.b_span * self.Cl_p * (omega[0] * self.b_span / (2.0 * velocity))
            M_damping = q_inf * self.S_ref * self.c_bar * self.Cm_q * (omega[1] * self.c_bar / (2.0 * velocity))
            N_damping = q_inf * self.S_ref * self.b_span * self.Cn_r * (omega[2] * self.b_span / (2.0 * velocity))
        else:
            L_damping = M_damping = N_damping = 0.0
            
        total_aero_torque = np.array([L_static + L_damping, M_static + M_damping, N_static + N_damping])
        drag_force = q_inf * self.S_ref * self.Cd_0
        
        return total_aero_torque, drag_force

    def run_autopilot_feedback(self, t, omega, omega_target):
        """Calculates closed-loop PID control actions to throttle active RCS commands."""
        dt = t - self.last_t
        if dt <= 0.0:
            dt = 0.001  # Prevent divide-by-zero on initial step integration initialization
            
        error = omega_target - omega
        
        # Update the mathematical accumulator registry (Integration step)
        self.error_integral += error * dt
        # Simple anti-windup clamping to prevent control saturation calculation overflow
        self.error_integral = np.clip(self.error_integral, -100.0, 100.0)
        
        # Approximate error derivative via state velocity feedback
        error_derivative = -omega  # Assumes target commands are static step targets
        
        # Compute commanded active balancing output
        control_torque = (self.Kp * error) + (self.Ki * self.error_integral) + (self.Kd * error_derivative)
        
        self.last_t = t
        return control_torque

    def simulation_state_derivative(self, t, y, omega_target):
        """
        7-Dimensional State Vector Map:
        y[0:3] = [p, q, r] Body Angular Velocities (rad/s)
        y[3:6] = [X, Y, Altitude_Z] Tracking Paths (meters)
        y[6]   = Forward Flight Speed Velocity Vector U (m/s)
        """
        omega = np.array(y[0:3])
        altitude = y[5]
        velocity = y[6]
        
        # A. Gather dynamic structural properties and calculations
        mass, _, I_t, dI_dt = self.get_instantaneous_mass_properties(t)
        I_inv = np.linalg.inv(I_t)
        
        # B. Compute Environmental Forces
        aero_torque, drag_force = self.compute_aerodynamics(altitude, velocity, omega)
        
        # C. Compute Closed-loop Reaction Control System Output
        rcs_autopilot_torque = self.run_autopilot_feedback(t, omega, omega_target)
        
        # D. Rigid-Body Mechanics Equations Matrix Processing
        gyroscopic_torque = np.cross(omega, np.dot(I_t, omega))
        mass_loss_torque = np.dot(dI_dt, omega)
        
        # Net Torque summation matching environmental realities
        net_torque = rcs_autopilot_torque + aero_torque - gyroscopic_torque - mass_loss_torque
        domega_dt = np.dot(I_inv, net_torque)
        
        # E. Translational Matrix Tracking Derivatives
        dx_dt = velocity
        dy_dt = 0.0
        dz_dt = -280.0  # Preserved standard entry atmospheric descent rate descent profile
        dv_dt = -drag_force / mass
        
        return [*domega_dt, dx_dt, dy_dt, dz_dt, dv_dt]

# --- Runner Matrix Demonstration execution ---
if __name__ == "__main__":
    sim = ProductionSpaceShuttleSimulator()
    
    # Establish entry corridor trajectory boundary parameters 
    # Target state: Hold vehicle perfectly stable throughout the profile: target rates = 0
    guidance_target = np.array([0.0, 0.0, 0.0])
    
    # Initial Conditions: 45km altitude, Mach 10 velocity, initialized with severe cross-coupling roll rates
    # State: [p, q, r, x, y, z, v]
    init_state = [0.08, -0.04, 0.02, 0.0, 0.0, 45000.0, 3400.0]
    
    sol = solve_ivp(
        fun=lambda t, y: sim.simulation_state_derivative(t, y, guidance_target),
        t_span=(0, 35),
        y0=init_state,
        t_eval=[0.0, 5.0, 15.0, 19.5, 20.5, 25.0, 35.0],  # Precise sampling points surrounding the t=20 drop
        method='RK45'
    )
    
    print("====== CLOSED-LOOP ATMOSPHERIC SIMULATION RUNNING ======")
    for idx, t in enumerate(sol.t):
        p, q, r = sol.y[0][idx], sol.y[1][idx], sol.y[2][idx]
        alt_km = sol.y[5][idx] / 1000.0
        vel_ms = sol.y[6][idx]
        
        status_flag = "NORMAL"
        if 19.0 <= t <= 21.0:
            status_flag = "!!! PAYLOAD DEPLOY EVENT BOUNDARY !!!"
            
