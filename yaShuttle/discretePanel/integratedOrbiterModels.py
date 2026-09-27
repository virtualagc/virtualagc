from typing import Dict, Any

class ProductionSpaceShuttleSimulator:
    def __init__(self, initial_mass: float):
        self.mass = initial_mass
        self.velocity = 0.0
        self.altitude = 0.0
        
        # Structural configurations
        self.srb_attached = True
        self.et_attached = True
        self.meco_reached = False
        
        # Base propulsion specifications (lbs of thrust at 104% throttle)
        self.srb_thrust_base = 5300000.0  # Combined booster thrust
        self.ssme_thrust_base = 1181000.0 # 3 SSMEs combined at 104%
        
        # Dynamic Drag Coefficients (Cd) based on staging
        self.cd_stack = 0.45      
        self.cd_orbiter_et = 0.35 
        self.cd_orbiter = 0.28    

    def get_current_drag_coefficient(self) -> float:
        if self.srb_attached:
            return self.cd_stack
        if self.et_attached:
            return self.cd_orbiter_et
        return self.cd_orbiter

    def get_chamber_pressure(self, current_time: float) -> float:
        if current_time >= 122.0:
            return 10.0  
        return 750.0

    def get_et_propellant_level(self, current_time: float) -> float:
        total_fuel_duration = 510.0
        remaining_ratio = max(0.0, (total_fuel_duration - current_time) / total_fuel_duration)
        return remaining_ratio * 100.0  

    def drop_boosters(self) -> None:
        self.srb_attached = False
        self.mass -= 1180000.0  

    def trigger_meco_and_drop_et(self) -> None:
        self.meco_reached = True
        self.et_attached = False
        self.mass -= 76000.0   

    def step_simulation(self, time_delta: float, ssme_throttle: float) -> Dict[str, float]:
        self.altitude += self.velocity * time_delta
        
        # Calculate active thrust based on configuration and throttle optimization
        total_thrust = 0.0
        if self.srb_attached:
            total_thrust += self.srb_thrust_base
            
        if self.et_attached and not self.meco_reached:
            # SSME thrust scales linearly with the engine throttle percent (e.g. 0.65 to 1.04)
            total_thrust += self.ssme_thrust_base * (ssme_throttle / 1.04)
            
            # Simulate mass depletion of liquid propellants during burn steps
            fuel_burn_rate = 2270.0  # lbs/sec combined burn
            self.mass -= fuel_burn_rate * time_delta
            
        # Calculate acceleration: F = ma -> a = F/m (Converting mass to slugs/lbs accordingly)
        # Simplified acceleration physics accounting for mass reduction
        if self.mass > 0:
            accel = (total_thrust / (self.mass / 32.2)) 
        else:
            accel = 0.0
            
        if self.meco_reached:
            accel = 0.0  # Coasting immediately post-MECO
            
        self.velocity += accel * time_delta
        
        return {
            "altitude": self.altitude,
            "velocity": self.velocity,
            "air_density": 1.225 * (0.9 ** (self.altitude / 1000)),
            "drag_coefficient": self.get_current_drag_coefficient()
        }


class SpaceShuttleAscentMaxQModel:
    def calculate_dynamic_pressure(self, density: float, velocity: float) -> float:
        return 0.5 * density * (velocity ** 2)

    def calculate_total_drag(self, dynamic_pressure: float, cd: float, reference_area: float = 110.0) -> float:
        return dynamic_pressure * cd * reference_area


class ThrustWeightOptimizer:
    """Calculates TWR parameters and throttles down main engines during high dynamic pressure."""
    @staticmethod
    def calculate_twr(total_thrust: float, current_mass: float) -> float:
        if current_mass <= 0:
            return 0.0
        return total_thrust / current_mass

    @staticmethod
    def optimize_throttle(current_time: float, current_q: float, q_threshold: float = 600.0) -> float:
        """
        Throttles down SSMEs from 104% to 65% when dynamic pressure (q) 
        crosses structural safety thresholds during the Max-Q timeline.
        """
        # Shuttle profile typically throttles down between 45s and 60s to mitigate Max-Q stress
        if 45.0 <= current_time <= 60.0 or current_q > q_threshold:
            return 0.65  # Throttle down to 65% rated thrust
        return 1.04      # Standard operating ascent thrust (104%)


class IntegratedSpaceShuttleAscentModel:
    def __init__(self, initial_mass: float):
        self.simulator = ProductionSpaceShuttleSimulator(initial_mass=initial_mass)
        self.max_q_analyzer = SpaceShuttleAscentMaxQModel()
        self.optimizer = ThrustWeightOptimizer()
        
        # Telemetry logs
        self.max_q_value = 0.0
        self.max_q_time = 0.0
        self.srb_separation_time = None
        self.et_separation_time = None
        
        # Telemetry tracking for throttle events
        self.throttle_history = []
        self.twr_history = []

    def run_ascent_telemetry(self, total_duration: float, time_step: float) -> Dict[str, Any]:
        current_time = 0.0
        SRB_PRESSURE_THRESHOLD = 50.0  
        ET_FUEL_THRESHOLD = 0.5        
        
        # Approximate dynamic pressure threshold for structural stress mitigation
        DYNAMIC_PRESSURE_LIMIT = 650.0 
        
        # Seed an initial structural evaluation for the framework check loop
        estimated_q = 0.0
        
        while current_time < total_duration:
            # 1. Determine optimal throttle configuration for this time step
            ssme_throttle = self.optimizer.optimize_throttle(current_time, estimated_q, DYNAMIC_PRESSURE_LIMIT)
            self.throttle_history.append((current_time, ssme_throttle))
            
            # Track instantaneous TWR before physics mutations
            active_thrust = (self.simulator.ssme_thrust_base * (ssme_throttle / 1.04))
            if self.simulator.srb_attached:
                active_thrust += self.simulator.srb_thrust_base
            
            current_twr = self.optimizer.calculate_twr(active_thrust, self.simulator.mass)
            self.twr_history.append((current_time, current_twr))

            # 2. Evaluate Staging triggers
            if self.simulator.srb_attached:
                pc = self.simulator.get_chamber_pressure(current_time)
                if pc < SRB_PRESSURE_THRESHOLD:
                    self.simulator.drop_boosters()
                    self.srb_separation_time = current_time

            if self.simulator.et_attached and not self.simulator.srb_attached:
                fuel_left = self.simulator.get_et_propellant_level(current_time)
                if fuel_left < ET_FUEL_THRESHOLD:
                    self.simulator.trigger_meco_and_drop_et()
                    self.et_separation_time = current_time

            # 3. Step Physics Simulation using optimized engine outputs
            state = self.simulator.step_simulation(time_step, ssme_throttle)
            
            # 4. Refresh dynamic pressure estimates for the next structural execution frame
            estimated_q = self.max_q_analyzer.calculate_dynamic_pressure(
                density=state["air_density"], 
                velocity=state["velocity"]
            )
            
            if estimated_q > self.max_q_value:
                self.max_q_value = estimated_q
                self.max_q_time = current_time
                
            current_time += time_step
            
        return {
            "peak_dynamic_pressure": self.max_q_value,
            "max_q_timestamp": self.max_q_time,
            "srb_sep_timestamp": self.srb_separation_time,
            "et_sep_timestamp": self.et_separation_time,
            "final_twr": self.twr_history[-1][1] if self.twr_history else 0,
            "final_altitude": self.simulator.altitude
        }
