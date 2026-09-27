#!/usr/bin/env python
'''
Filename:      solidRocketBoosters.py
See also:      orbiterPhysicalModels.pdf
Mod history:   2026-09-27 RSB  Created

This is the Python code for an inertial model of the Space Shuttle
Orbiter + Solid Rocket Boosters during the launch phase. See the 
comments in orbiterInertialModel.py
'''

import numpy as np
from scipy.integrate import solve_ivp

class SpaceShuttleAscentMaxQModel:
    def __init__(self):
        # 1. Structural Mass Profiles (Liftoff Stack Elements)
        self.m_orbiter = 109000.0       # kg (Orbiter + nominal payload)
        self.cg_orbiter = np.array([-2.0, 0.0, 4.2]) # Mounted high on the stack side
        
        self.m_et_empty = 30000.0       # External Tank Structure
        self.m_et_prop_init = 730000.0  # Liquid Hydrogen/Oxygen Fuel
        self.cg_et = np.array([0.0, 0.0, 0.0]) # Stack centerline reference point
        
        self.m_srb_casing_each = 88000.0
        self.m_srb_prop_init = 500000.0
        self.srb_y_offset = 6.0         # Symmetrical lateral spacing (meters)
        self.srb_x_offset = -1.5        # Longitudinal offset
        self.srb_radius = 1.86
        self.srb_length = 45.4
        
        # 2. Propulsion System Performance Matrix
        self.srb_mdot_nominal = 4400.0  # kg/s per booster
        self.ssme_mdot_max = 1050.0     # kg/s total liquid fuel at 104% thrust
        self.thrust_ssme_max = 6.0e6    # Newtons (Combined Sea Level/Vacuum SSME thrust)
        self.thrust_srb_each = 1.2e7    # Newtons (Massive solid rocket thrust force)
        
        self.ssme_location = np.array([-18.0, 0.0, 3.5]) # Main engines at the base of the Orbiter
        self.t_srb_sep = 120.0          # Staging trigger timeline (seconds)
        
        # 3. Atmospheric Constants
        self.rho_0 = 1.225              # Sea-level density (kg/m^3)
        self.H_scale = 7500.0           # Atmospheric scale height (meters)
        self.S_ref_stack = 350.0        # Combined cross-sectional frontal area (m^2)
        self.Cd_stack = 0.55            # Supersonic drag coefficient profile

    def get_stack_properties(self, t):
        """Calculates time-varying mass, dynamic composite CG, and full stack inertia tensor."""
        # A. Account for automated engine throttling strategy around Max-Q
        # Throttle down between 50s and 75s to survive peak aerodynamic pressures
        if 50.0 <= t <= 75.0:
            throttle = 0.65  # 65% Thrust Bucket
        else:
            throttle = 1.04  # 104% Nominal Rated Performance
            
        current_ssme_mdot = self.ssme_mdot_max * (throttle / 1.04)
        current_et_prop = max(0.0, self.m_et_prop_init - (current_ssme_mdot * t))
        m_et_total = self.m_et_empty + current_et_prop
        
        # B. Handle SRB fuel burn and staging separation boundary
        if t < self.t_srb_sep:
            current_srb_prop = max(0.0, self.m_srb_prop_init - (self.srb_mdot_nominal * t))
            m_srb_each = self.m_srb_casing_each + current_srb_prop
            srb_attached = True
            total_srb_thrust = 2.0 * self.thrust_srb_each
        else:
            m_srb_each = 0.0
            srb_attached = False
            total_srb_thrust = 0.0
            
        # C. Geometric Center of Gravity Synthesis
        total_mass = self.m_orbiter + m_et_total + (2.0 * m_srb_each)
        cg_composite = (self.m_orbiter * self.cg_orbiter + 
                        m_et_total * self.cg_et + 
                        2.0 * m_srb_each * np.array([self.srb_x_offset, 0.0, 0.0])) / total_mass
                        
        # D. Dynamic Thrust Vector Control (TVC) Gymbal Alignment Code
        # Computes the exact engine tilt angle needed to align thrust with the shifting CG
        dx = cg_composite[0] - self.ssme_location[0]
        dz = cg_composite[2] - self.ssme_location[2]
        tvc_gimbal_deg = np.degrees(np.arctan2(dz, dx))
        
        # E. Assemble Inertia Tensor Matrix
        I_stack = np.diag([3.0e7, 9.0e7, 9.0e7]) # Initial baseline core matrix estimation
        if srb_attached:
            for side in [-1.0, 1.0]:
                srb_cg = np.array([self.srb_x_offset, side * self.srb_y_offset, 0.0])
                I_roll = 0.5 * m_srb_each * (self.srb_radius**2)
                I_trans = (1/12) * m_srb_each * (self.srb_length**2) + (1/4) * m_srb_each * (self.srb_radius**2)
                I_local = np.diag([I_roll, I_trans, I_trans])
                
                d = cg_composite - srb_cg
                I_stack += I_local + m_srb_each * (np.dot(d, d) * np.eye(3) - np.outer(d, d))
                
        total_thrust_force = (self.thrust_ssme_max * throttle) + total_srb_thrust
        
        return total_mass, cg_composite, tvc_gimbal_deg, total_thrust_force, throttle

    def compute_ascent_aerodynamics(self, altitude, velocity):
        """Computes exponential barometric air density, dynamic pressure, and drag profile."""
        rho = self.rho_0 * np.exp(-max(0.0, altitude) / self.H_scale)
        q_inf = 0.5 * rho * (velocity**2) # Dynamic structural pressure
        drag_force = q_inf * self.S_ref_stack * self.Cd_stack
        return q_inf, drag_force

    def ascent_ode_system(self, t, y):
        """
        State Vector: y = [Altitude_Z, Velocity_V]
        Simulates vertical vertical acceleration paths matching structural shifts.
        """
        altitude, velocity = y[0], y[1]
        
        # Pull time-dependent vehicle configuration variables
        mass, _, _, thrust, _ = self.get_stack_properties(t)
        q_inf, drag = self.compute_ascent_aerodynamics(altitude, velocity)
        
        # Accelerations: Gravity (approximated) + Thrust over Mass - Drag over Mass
        g = 9.81
        dalt_dt = velocity
        dvel_dt = (thrust - drag) / mass - g
        
        return [dalt_dt, dvel_dt]

# --- Launch Execution Profile Telemetry ---
if __name__ == "__main__":
    launcher = SpaceShuttleAscentMaxQModel()
    
    # Track the vehicle across critical path milestones:
    # Liftoff, Entering the Throttle Bucket, Max-Q Peak, Throttling back up, and Separation
    flight_milestones = [0.0, 45.0, 65.0, 80.0, 119.9, 120.1]
    
    # Run a unified continuous numerical solver integration track
    initial_launch_conditions = [0.0, 0.0] # 0 meters altitude, 0 m/s velocity at liftoff
    sol = solve_ivp(
        fun=launcher.ascent_ode_system,
        t_span=(0, 125),
        y0=initial_launch_conditions,
        t_eval=flight_milestones,
        method='RK45'
    )
    
    print("=================== SHUTTLE ASCENT & MAX-Q PERFORMANCE TELEMETRY ===================")
    for idx, t in enumerate(sol.t):
        alt = sol.y[0][idx]
        vel = sol.y[1][idx]
        
        # Re-fetch internal time-varying metrics for structured readout reporting
        mass, cg, tvc_deg, thrust, throttle = launcher.get_stack_properties(t)
        q_inf, drag = launcher.compute_ascent_aerodynamics(alt, vel)
        
        # Flags for logging clarity
        milestone_tag = "LIFTOFF"
        if t == 45.0: milestone_tag = "ENTER THROTTLE BUCKET"
        if t == 65.0: milestone_tag = "!!! MAX-Q PRESSURE PEAK !!!"
        if t == 80.0: milestone_tag = "THROTTLE BACK TO 104%"
        if t == 119.9: milestone_tag = "PRE-SRB SEPARATION"
        if t == 120.1: milestone_tag = "POST-SRB JETTISON SUCCESS"
        
        print(f"Time: {t:5.1f}s | Alt: {alt/1000:5.1f}km | Vel: {vel:6.1f}m/s | Q-Pres: {q_inf/1000:5.1f}kPa | SSME Throttle: {throttle*100:3.0f}% | TVC Gimbal: {tvc_deg:4.2f}° | Event: {milestone_tag}")
