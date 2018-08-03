### FILE="Main.annotation"
# Filename:     MAIN.agc
# Purpose:      This program is designed to extensively test the Apollo Guidance Computer
#               (specifically the LM instantiation of it). It is built on top of a heavily
#               stripped-down Aurora 12, with all code ostensibly added by the DAP Group
#               removed. Instead Borealis expands upon the tests provided by Aurora,
#               including corrected tests from Retread 44 and tests from Ron Burkey's
#               Validation.
# Assembler:    yaYUL
# Contact:      Mike Stewart <mastewar1@gmail.com>.
# Website:      www.ibiblio.org/apollo/index.html
# Mod history:  2016-12-20 MAS  Created from Aurora 12 (with much DAP stuff removed).
#               2016-12-21 MAS  Added Retread instruction checks.
#               2017-01-15 MAS  Added a file for extended self-tests.
#               2017-03-27 RSB  Made this header ##-style rather than #-style.  (Headers
#                               in MAIN.agc are always #-style.)

# Source file name
# ----------------

$ASSEMBLY_AND_OPERATION_INFORMATION.agc
$ERASABLE_ASSIGNMENTS.agc
$INPUT_OUTPUT_CHANNELS.agc
$INTERRUPT_LEAD_INS.agc
$INTER-BANK_COMMUNICATION.agc
$INTERPRETER.agc
$SINGLE_PRECISION_SUBROUTINES.agc
$EXECUTIVE.agc
$WAITLIST.agc
$PHASE_TABLE_MAINTENANCE.agc
$FRESH_START_AND_RESTART.agc
$T4RUPT_PROGRAM.agc
$IMU_MODE_SWITCHING_ROUTINES.agc
$IMU_COMPENSATION_PACKAGE.agc
$AOTMARK.agc
$RADAR_LEAD-IN_ROUTINES.agc
$RADAR_TEST_PROGRAMS.agc
$EXTENDED_VERBS.agc
$KEYRUPT,_UPRUPT.agc
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc
$ALARM_AND_ABORT.agc
$DOWN-TELEMETRY_PROGRAM.agc
$AGC_BLOCK_TWO_SELF-CHECK.agc
$AGC_BLK2_INSTRUCTION_CHECK.agc
$AGC_BLOCK_TWO_EXTENDED_TESTS.agc
$INFLIGHT_ALIGNMENT_ROUTINES.agc
$RTB_OP_CODES.agc
$LEM_FLIGHT_CONTROL_SYSTEM_TEST.agc
$IMU_PERFORMANCE_TESTS_1.agc
$IMU_PERFORMANCE_TESTS_2.agc
$IMU_PERFORMANCE_TESTS_3.agc
$OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc
$AGC_VERSION_CHECK.agc
$SUM_CHECK_END_OF_BANK_MARKERS.agc
