#!/bin/bash
# This script is intended to be used to autostart runPiDSKY2.sh upon
# Raspberry Pi power-up.  It is assumed that the desktop is automatically
# logged in.  Then, assuming this script is in /home/pi/virtualagc/piPeripheral/,
# the line
#
#	@/home/pi/virtualagc/piPeripheral/auto.sh
#
# should be added to the end of the file
#
#	/home/pi/.config/lxsession/LXDE-pi/autostart

cd /home/pi/virtualagc/piPeripheral
xterm -fullscreen  -e ./runPiDSKY2.sh --custom-bare --pigpio=7 --playback &
