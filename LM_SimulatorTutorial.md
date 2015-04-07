![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)

# 1. LM Simulator Tutorial #

This tutorial is intended to get you started with the AGC running in LGC (Lunar Guidance Computer) mode in conjunction with the virtual static simulator (developed by Stephan Hotto). Running the AGC in LGC mode  means that the AGC is configured to operate for conditions suitable for the Lunar Module. To do this you must run the yaAGC emulator with the option --cfg=your\_path/LM.ini
The LM\_Simulator itself is a so called "plant" model of the Apollo Lunar Module which simulates the hardware around the LGC.

## 1.1 Requirements ##

Since the LM Simulator is written in Tcl/Tk you must have both the tcl and tk packages installed for Linux and the free distribution of [ActiveTcl](http://www.activestate.com/Products/activetcl/index.mhtml) package for Windows. The simulator has been tested with Tcl version 8.4.

## 1.2 Starting the Simulation ##
To start the simulation you must first launch the AGC emulator running the Luminary131 code from MIT. The emulator must be forced into the LGC mode as previously discussed to avoid getting the yaAGC debug terminal due to an opcode trap that avoids infinite loops. Use the proper configuration option to select the LM mode.

Once the LGC is running you can optionally start the yaACA (Attitude Control Assembly) to control the Lunar Module with your joystick. The ACA capability is currently only available on Linux. To start the simulator simply run:
```
wish lm_simulator.tcl lm_simulator.ini 
```
If the specified configuration file cannot be found the simulator will assume the LM-7 mission configuration.

## 1.3 Simulator Layout ##
The simulator has 5 main areas of concern each of which is represented with its own window:
  * The computer keyboard and display interface also known as the DSKY
  * The LGC outputs for monitoring and correlating the AGC binary actuators
  * The LGC inputs to simulate the binary AGC sensors
  * The crew inputs to simulate the buttons, RHC/ACA and THC connected to the LGC
  * The Flight Director Attitude Indicator (FDAI) showing the LM attitude in relation to the Inertial Measurement Unit (IMU)

## 1.4 Taking Control ##
The following sections describe some simple steps to interact with the simulator and the DSKY to test and operate the LGC like a member of the Apollo crew. The subsections here will introduce the basic operation and control of the IMU as well as the Digital Auto Pilot (DAP).

### 1.4.1 Quick Start ###
If you want to do a real fast startup (see section IMU operations for correct procedures) then you should execute the following steps:
  * Switch the DAP to "ATTITUDE HOLD MODE ON" (AGC Crew Inputs)
  * Wait until "DRIVE CDU Z to X" goes on (AGC Outputs)
  * Type into the DSKY: V37E 00E (VERB 37 ENTR 00 ENTR) to send the AGC into the idle loop
  * DSKY: V77E (Normal DAP Mode) or V76E (Minimum Impulse Mode)
  * DSKY: V37E 00E to be sure that the AGC is in the idle mode

Now the vessel can be controlled by the RHC (Rotational Hand Controller) which can be found within the AGC Crew Inputs window.

### 1.4.2 IMU operations ###

#### 1.4.2.1 AGC/LGC Initialization ####
After a fresh AGC start there is a need to do a reset by typing V36E. To go into the idle loop it is necessary to change the program by V37E 00E. Probably that has to be repeated a couple of times until "PROG" shows 00.

#### 1.4.2.2 IMU Basics ####
The IMU is constructed of a gyro stabilized stable platform gimbaled by a three axis system to measure changes in attitude and velocity. The three axis provides the platform 3 degrees of freedom. However due to the construction of the gimbals gimbal-lock could occur when 2 gimbals align in the same plane. The platform stabilization is done with IRIGs (Inertial Rate Integrated Gyro). To measure the changes in velocity 3 PIPAs (pulsed-integrating pendulous accelerometer) are also orthogonally mounted on the stable platform.

The following mapping is valid after setting the IMU to zero degrees.
| **Axis** | **Gimbal** | **Controls** |
|:---------|:-----------|:-------------|
| X      | Outer    | Yaw        |
| Y      | Inner    | Pitch      |
| Z      | Middle   | Roll       |

A Gimbal-Lock Warning will be alerted when the Roll exceeds +/-70 Degrees. Usually the thrust vector of the spaceship is aligned with the X-axis of the IMU.

#### 1.4.2.3 IMU Start ####
After a fresh start of yaAGC and LM Simulator the AGC assumes an aligned IMU.
That means that the steps 1.1 to 1.4 are not urgently necessary if you want to do a fast start. To start the Inertial Subsystem (ISS) execute the following:

  * AGC Crew Inputs: Set "ISS TURN ON REQUESTED" to ON.
  * Wait for about 90 sec until the DSKY "NO ATT" signal goes off

#### 1.4.2.4 IMU Pre-flight Checkout ####
Pre-flight check-out of the FDAI display interface -> DSKY: V43E
All values should be set to +00000.

#### 1.4.2.5  IMU Coarse Align ####
The coarse align mode enables stable platform alignment to within approximately 2 degrees of a desired platform orientation. Prerequisite information to accomplish a coarse alignment consists of the desired platform orientation and present spacecraft attitude.
The desired platform orientation angles are computed by an alignment program executed by the AGC. The navigator determines the spacecraft attitude immediately prior to coarse alignment by making two or more sightings on stars or landmarks. Upon completion of the sightings, normally the AGC reads the optic angles and computes the gimbal angles necessary to attain the desired platform orientation. The AGC generates drive signals to position the CDU resolvers to the required gimbal angles. The IMU-CDU resolver error signals, generated by repositioning the CDUs, are applied to the gimbal torque servo amps which drive the gimbal torque motors to position the platform to the desired orientation. To coarse align with all zero gimbal angles execute the following:

  * Type the following sequence into the DSKY: V41N20E (V = VERB; N = NOUN; E = ENTR)
  * Now the AGC asks for the angles in the format 000.00 Deg. The sequence is X, Y, Z. Don't forget the "+" or "-" sign!
  * The AGC drives the IMU to the absolute position given
  * Use the "FDAI/IMU" window to control the angle changes

#### 1.4.2.6  IMU Fine Align ####
The fine align mode completes stable platform orientation to the required degree of accuracy. The navigator makes two or more star sightings, using on-board data and the optics to acquire the desired stars. Upon receipt of the optic angles the AGC computes the IMU angles necessary to complete the alignment. In the fine align mode, the IMU angles are repeated by the inertial CDUs which are monitored by the AGC to determine the actual IMU orientation. The AGC generates torquing signals to cancel any error between the actual IMU orientation and the desired orientation.

After IMU Coarse Align the "NO ATT" light indicates that the platform is not completely aligned. To finalize the alignment (fine align) execute the following procedure assuming our current attitude is already perfect so the relative angles are 0:
  * DSKY: V42E
  * Give the relative angles in format 00.000 Deg (e.g. three times +00000)

#### 1.4.2.7  Zero IMU ####
Here are three possible scenarios to reset the IMU to zero degrees:
  1. AGC Crew Inputs => Activate: "IMU CAGE COMMAND TO DRIVE IMU GIMBAL ANGLES TO 0"
  1. DSKY: V40N20E (AGC sends ZERO CAGE COMMAND)
  1. DSKY: V36E (AGC RESET which automatically resets the IMU)

#### 1.4.2.8  Monitor IMU Values ####
  * Monitor Gimbal Angles DSKY: V16N20E
  * Monitor PIPA Counter Values: DSKY: V16N21E

### 1.4.3 DAP Operations ###
DAP (Digital Autopilot) can maneuver and control the spacecraft. To operate correctly the DAP needs some initialization values to work correctly (e.g. LM Weight,Configuration,etc.).

#### 1.4.3.1 DAP Configuration ####
To observe the current DAP configuration use V48E on the DSKY. This will start software routine [R03](https://code.google.com/p/virtualagc/source/detail?r=03) and will show the current configuration in [R1](https://code.google.com/p/virtualagc/source/detail?r=1) (F06 46) on the DSKY. Each number represents a specific configurations (e.g. 21122). To decode or encode a configuration use ABCDE for each digit displayed where each character in this sequence represent a configuration option see the table below.

| **Value**  | **A: LM Stages**  | **B: RCS Translation** | **C: ACA Scale** | **D: ATT Dead-band** | **E: KALCMANU** |
|:-----------|:------------------|:-----------------------|:-----------------|:---------------------|:----------------|
| 0 | N/A                    | 2 Jet System A | 4°/sec   | 0.3°    |  0.2°/sec  |
| 1 | Ascent Only            | 2 Jet System B | 20°/sec  | 1.0°    |  0.5°/sec  |
| 2 | Ascent & Descent       | 4 Jet System A | N/A      | 5.0°    |  2.0°/sec  |
| 3 | Ascent & Descent & CSM | 4 Jet System B | N/A      | N/A     | 10.0°/sec  |

To manipulate these configuration settings try the following on the DSKY:
  * To change the value type V21E
  * Press "PRO" on the DSKY to start the entry of (F06 47) LM & CSM Weight
  * Use V21E or V22E to change the individual values
  * V24E allows to change both values sequencially (don't forget the leading + sign)
  * Press "PRO" to proceed
  * F06 48 allows the entry of the Engine Gimbal Angles.

#### 1.4.3.2 DAP Activation ####
To activate the DAP select on the AGC Crew Inputs either:
  * "ATTITUDE HOLD MODE ON" or
  * "AUTO STABILIZATION OF ATTITUDE ON".

#### 1.4.3.3 DAP Modes ####
With the DSKY you can set the following DAP Modes:
  * V76E Minimun Impulse Command Mode (each RHC deflection fires the thrusters for 14ms)
  * V77E Rate Command and Attitude Hold Mode

#### 1.4.3.4 DAP Crew Defined Maneuver ####
The Crew defined maneuver allows the astronauts to place the spacecraft into a specific attitude. As an example follow the following steps:
  1. DAP Switch to "AUTO STABILIZATION OF ATTITUDE ON"
  1. V37E 00E
  1. V62E (Display Angular Difference to N22 on Error Needles)
  1. V49E
  1. F 06 22 New ICDU Angles (e.g. V24E to load the Sequence ICDUX, ICDUY and ICDUZ)
  1. PRO
  1. F 50 18 New FDAI Angles in the Sequence Roll, Pitch and Yaw
  1. PRO
  1. The DAP steers the LM to the new orientation

#### 1.4.3.5 DAP - FDAI Error Needle Modes ####
To have the FDAI needles show how far the DAP is away from the desired position (i.e. the FDAI shows the attitude errors) which is the default FDAI mode use: V61E

To make the FDAI display the total attitude error (i.e. the absolute difference) between the entries shown by V16N22E and V16N20E (this is used for automatic positioning e.g. V49) use: V62E

To display the vehicle attitude rates on the FDAI error needles use: V60E

These outputs should provide the same information as the FDAI rate indicators do. The Roll, Yaw and Pitch rate shown by the FDAI bases on a separate Rate Gyro Assembly fixed mounted to the LM body, whereas the Information on the needles shown by V60E is derived from the AGC measurement of the angular changes. This is also a backup mode in case of a Rate Gyro Assembly Fault.